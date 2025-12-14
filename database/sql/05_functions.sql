-- =====================================================
-- PL/pgSQL функции и процедуры для критичных операций
-- =====================================================

-- =====================================================
-- ФУНКЦИЯ 1: Назначение экипажа на экспедицию с проверками
-- =====================================================
CREATE OR REPLACE FUNCTION assign_crew_to_expedition(
    p_expedition_id BIGINT,
    p_crew_id BIGINT,
    p_role_id SMALLINT,
    p_from DATE,
    p_to DATE DEFAULT NULL,
    p_is_backup BOOLEAN DEFAULT FALSE
)
RETURNS BIGINT -- возвращает assignment_id
LANGUAGE plpgsql
AS $$
DECLARE
    v_assignment_id BIGINT;
    v_expedition_exists BOOLEAN;
    v_role_requires_cert BOOLEAN;
    v_crew_has_cert BOOLEAN;
BEGIN
    -- Проверка существования экспедиции
    SELECT EXISTS(SELECT 1 FROM expedition WHERE expedition_id = p_expedition_id)
    INTO v_expedition_exists;
    
    IF NOT v_expedition_exists THEN
        RAISE EXCEPTION 'Expedition % not found', p_expedition_id;
    END IF;

    -- Проверка существования члена экипажа
    IF NOT EXISTS(SELECT 1 FROM crew_member WHERE crew_id = p_crew_id) THEN
        RAISE EXCEPTION 'Crew member % not found', p_crew_id;
    END IF;

    -- Проверка существования роли
    IF NOT EXISTS(SELECT 1 FROM role WHERE role_id = p_role_id) THEN
        RAISE EXCEPTION 'Role % not found', p_role_id;
    END IF;

    -- Проверка пригодности: если роль требует сертификат, проверяем наличие действующего сертификата
    SELECT min_cert_required INTO v_role_requires_cert
    FROM role 
    WHERE role_id = p_role_id;

    IF v_role_requires_cert THEN
        -- Ищем любую действующую сертификацию для crew
        SELECT EXISTS(
            SELECT 1 
            FROM crew_certification cc
            JOIN certification c ON c.certification_id = cc.certification_id
            WHERE cc.crew_id = p_crew_id
                AND (cc.expiry_date IS NULL OR cc.expiry_date >= CURRENT_DATE)
        ) INTO v_crew_has_cert;

        IF NOT v_crew_has_cert THEN
            RAISE EXCEPTION 'Crew member % lacks required certifications for role %', p_crew_id, p_role_id;
        END IF;
    END IF;

    -- Вставляем запись (trigger проверит перекрытие)
    INSERT INTO crew_assignment(
        expedition_id, 
        crew_id, 
        role_id, 
        assigned_from, 
        assigned_to, 
        is_backup
    )
    VALUES (
        p_expedition_id, 
        p_crew_id, 
        p_role_id, 
        p_from, 
        p_to, 
        p_is_backup
    )
    RETURNING assignment_id INTO v_assignment_id;

    -- Логируем
    INSERT INTO system_audit(object_type, object_id, action, performed_by, details)
    VALUES (
        'crew_assignment', 
        v_assignment_id::TEXT, 
        'assign', 
        NULL, 
        jsonb_build_object(
            'expedition_id', p_expedition_id, 
            'crew_id', p_crew_id,
            'role_id', p_role_id
        )
    );

    RETURN v_assignment_id;
END;
$$;

COMMENT ON FUNCTION assign_crew_to_expedition IS 'Назначение члена экипажа на экспедицию с проверками сертификатов и доступности';

-- =====================================================
-- ФУНКЦИЯ 2: Корректировка инвентаря (атомарно)
-- =====================================================
CREATE OR REPLACE FUNCTION adjust_inventory(
    p_item_id BIGINT,
    p_txn_type TEXT,
    p_qty NUMERIC,
    p_performed_by BIGINT DEFAULT NULL,
    p_notes TEXT DEFAULT NULL
)
RETURNS BIGINT -- возвращает txn_id
LANGUAGE plpgsql
AS $$
DECLARE
    v_txn_id BIGINT;
BEGIN
    -- Проверка существования позиции инвентаря
    IF NOT EXISTS(SELECT 1 FROM inventory_item WHERE item_id = p_item_id) THEN
        RAISE EXCEPTION 'Inventory item % not found', p_item_id;
    END IF;

    -- Проверка типа транзакции
    IF p_txn_type NOT IN ('load', 'unload', 'consume', 'transfer_in', 'transfer_out', 'adjust') THEN
        RAISE EXCEPTION 'Invalid transaction type: %', p_txn_type;
    END IF;

    -- Вставляем транзакцию (триггер применит изменения и бросит исключение если негативно)
    INSERT INTO inventory_transaction(item_id, txn_type, qty, performed_by, notes)
    VALUES (p_item_id, p_txn_type, p_qty, p_performed_by, p_notes)
    RETURNING txn_id INTO v_txn_id;

    RETURN v_txn_id;
END;
$$;

COMMENT ON FUNCTION adjust_inventory IS 'Атомарная операция корректировки инвентаря с автоматическим обновлением количества';

-- =====================================================
-- ФУНКЦИЯ 3: Рекомендация экипажа для задачи
-- =====================================================
CREATE OR REPLACE FUNCTION recommend_crew_for_task(
    p_task_id BIGINT,
    p_limit INT DEFAULT 10
)
RETURNS TABLE(
    crew_id BIGINT,
    crew_name TEXT,
    score INT,
    recommended_role_id SMALLINT,
    recommended_role_title TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_expedition_id BIGINT;
    v_task_start TIMESTAMP WITH TIME ZONE;
    v_task_end TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Получаем информацию о задаче
    SELECT expedition_id, planned_start, planned_end
    INTO v_expedition_id, v_task_start, v_task_end
    FROM mission_task
    WHERE task_id = p_task_id;

    IF v_expedition_id IS NULL THEN
        RAISE EXCEPTION 'Task % not found', p_task_id;
    END IF;

    RETURN QUERY
    SELECT 
        cm.crew_id,
        (cm.first_name || ' ' || cm.last_name)::TEXT as crew_name,
        (
            -- Простая оценка: +10 за наличие действующего сертификата
            CASE WHEN EXISTS (
                SELECT 1 
                FROM crew_certification cc 
                WHERE cc.crew_id = cm.crew_id
                    AND (cc.expiry_date IS NULL OR cc.expiry_date >= CURRENT_DATE)
            ) THEN 10 ELSE 0 END
            -- -5 за уже назначенных в тот период
            - CASE WHEN EXISTS (
                SELECT 1 
                FROM crew_assignment ca
                WHERE ca.crew_id = cm.crew_id
                    AND ca.expedition_id = v_expedition_id
                    AND (
                        (v_task_start IS NULL OR v_task_end IS NULL) OR
                        (ca.assigned_to IS NULL AND v_task_end >= ca.assigned_from) OR
                        (ca.assigned_to IS NOT NULL AND NOT (ca.assigned_to < v_task_start OR v_task_end < ca.assigned_from))
                    )
            ) THEN 5 ELSE 0 END
            -- +20 если уже назначен на эту экспедицию (предпочтительно)
            + CASE WHEN EXISTS (
                SELECT 1 
                FROM crew_assignment ca
                WHERE ca.crew_id = cm.crew_id
                    AND ca.expedition_id = v_expedition_id
            ) THEN 20 ELSE 0 END
        )::INT as score,
        r.role_id as recommended_role_id,
        r.title as recommended_role_title
    FROM crew_member cm
    CROSS JOIN role r
    WHERE cm.status = 'active'
        AND r.role_id IN (
            -- Можно добавить фильтрацию по нужным ролям
            SELECT role_id FROM role
        )
    ORDER BY score DESC, crew_name
    LIMIT p_limit;
END;
$$;

COMMENT ON FUNCTION recommend_crew_for_task IS 'Рекомендация кандидатов из экипажа для выполнения задачи на основе сертификатов и доступности';

-- =====================================================
-- ФУНКЦИЯ 4: Получение текущего состояния экспедиции
-- =====================================================
CREATE OR REPLACE FUNCTION get_expedition_status(p_expedition_id BIGINT)
RETURNS TABLE(
    expedition_code TEXT,
    expedition_name TEXT,
    vessel_name TEXT,
    status TEXT,
    crew_count BIGINT,
    equipment_count BIGINT,
    tasks_pending BIGINT,
    tasks_completed BIGINT,
    incidents_count BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.code,
        e.name,
        v.name::TEXT as vessel_name,
        e.status,
        (SELECT COUNT(*) FROM crew_assignment WHERE expedition_id = e.expedition_id)::BIGINT as crew_count,
        (SELECT COUNT(*) FROM expedition_equipment WHERE expedition_id = e.expedition_id)::BIGINT as equipment_count,
        (SELECT COUNT(*) FROM mission_task WHERE expedition_id = e.expedition_id AND status = 'pending')::BIGINT as tasks_pending,
        (SELECT COUNT(*) FROM mission_task WHERE expedition_id = e.expedition_id AND status = 'done')::BIGINT as tasks_completed,
        (SELECT COUNT(*) FROM incident WHERE expedition_id = e.expedition_id AND resolved_at IS NULL)::BIGINT as incidents_count
    FROM expedition e
    LEFT JOIN vessel v ON v.vessel_id = e.vessel_id
    WHERE e.expedition_id = p_expedition_id;
END;
$$;

COMMENT ON FUNCTION get_expedition_status IS 'Получение сводной информации о текущем состоянии экспедиции';

-- =====================================================
-- ФУНКЦИЯ 5: Проверка готовности экспедиции к старту
-- =====================================================
CREATE OR REPLACE FUNCTION check_expedition_readiness(p_expedition_id BIGINT)
RETURNS TABLE(
    check_item TEXT,
    status TEXT,
    message TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 'vessel_assigned'::TEXT, 
        CASE WHEN EXISTS(SELECT 1 FROM expedition WHERE expedition_id = p_expedition_id AND vessel_id IS NOT NULL)
            THEN 'ok' ELSE 'missing' END,
        CASE WHEN EXISTS(SELECT 1 FROM expedition WHERE expedition_id = p_expedition_id AND vessel_id IS NOT NULL)
            THEN 'Vessel assigned' ELSE 'No vessel assigned' END

    UNION ALL

    SELECT 'crew_assigned'::TEXT,
        CASE WHEN (SELECT COUNT(*) FROM crew_assignment WHERE expedition_id = p_expedition_id) > 0
            THEN 'ok' ELSE 'missing' END,
        CASE WHEN (SELECT COUNT(*) FROM crew_assignment WHERE expedition_id = p_expedition_id) > 0
            THEN 'Crew members assigned' ELSE 'No crew members assigned' END

    UNION ALL

    SELECT 'required_permits'::TEXT,
        CASE WHEN EXISTS(SELECT 1 FROM permit WHERE expedition_id = p_expedition_id 
            AND valid_from <= CURRENT_DATE AND (valid_to IS NULL OR valid_to >= CURRENT_DATE))
            THEN 'ok' ELSE 'missing' END,
        CASE WHEN EXISTS(SELECT 1 FROM permit WHERE expedition_id = p_expedition_id 
            AND valid_from <= CURRENT_DATE AND (valid_to IS NULL OR valid_to >= CURRENT_DATE))
            THEN 'Valid permits exist' ELSE 'No valid permits found' END

    UNION ALL

    SELECT 'critical_tasks'::TEXT,
        CASE WHEN (SELECT COUNT(*) FROM mission_task 
            WHERE expedition_id = p_expedition_id AND status = 'pending' 
            AND planned_start <= CURRENT_DATE) = 0
            THEN 'ok' ELSE 'warning' END,
        CASE WHEN (SELECT COUNT(*) FROM mission_task 
            WHERE expedition_id = p_expedition_id AND status = 'pending' 
            AND planned_start <= CURRENT_DATE) = 0
            THEN 'No overdue tasks' 
            ELSE format('%s overdue tasks', (SELECT COUNT(*) FROM mission_task 
                WHERE expedition_id = p_expedition_id AND status = 'pending' 
                AND planned_start <= CURRENT_DATE)::TEXT) END;
END;
$$;

COMMENT ON FUNCTION check_expedition_readiness IS 'Проверка готовности экспедиции к старту (судно, экипаж, разрешения, задачи)';

-- =====================================================
-- ПРОЦЕДУРА 1: Старт экспедиции
-- =====================================================
CREATE OR REPLACE PROCEDURE start_expedition(
    p_expedition_id BIGINT,
    p_start_time TIMESTAMP WITH TIME ZONE DEFAULT now()
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_readiness_ok BOOLEAN;
BEGIN
    -- Проверяем готовность
    SELECT NOT EXISTS(
        SELECT 1 FROM check_expedition_readiness(p_expedition_id)
        WHERE status IN ('missing', 'error')
    ) INTO v_readiness_ok;

    IF NOT v_readiness_ok THEN
        RAISE EXCEPTION 'Expedition % is not ready to start. Check readiness first.', p_expedition_id;
    END IF;

    -- Устанавливаем actual_start (триггер обновит статус на 'active')
    UPDATE expedition
    SET actual_start = p_start_time
    WHERE expedition_id = p_expedition_id;

    -- Логируем
    INSERT INTO system_audit(object_type, object_id, action, performed_by, details)
    VALUES (
        'expedition',
        p_expedition_id::TEXT,
        'start',
        NULL,
        jsonb_build_object('start_time', p_start_time)
    );

END;
$$;

COMMENT ON PROCEDURE start_expedition IS 'Процедура запуска экспедиции с проверкой готовности';

-- =====================================================
-- ПРОЦЕДУРА 2: Завершение экспедиции
-- =====================================================
CREATE OR REPLACE PROCEDURE complete_expedition(
    p_expedition_id BIGINT,
    p_end_time TIMESTAMP WITH TIME ZONE DEFAULT now()
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_expedition_status TEXT;
BEGIN
    -- Получаем текущий статус
    SELECT status INTO v_expedition_status
    FROM expedition
    WHERE expedition_id = p_expedition_id;

    IF v_expedition_status IS NULL THEN
        RAISE EXCEPTION 'Expedition % not found', p_expedition_id;
    END IF;

    IF v_expedition_status != 'active' THEN
        RAISE EXCEPTION 'Expedition % is not active (current status: %)', p_expedition_id, v_expedition_status;
    END IF;

    -- Устанавливаем actual_end (триггер обновит статус на 'completed')
    UPDATE expedition
    SET actual_end = p_end_time
    WHERE expedition_id = p_expedition_id;

    -- Логируем
    INSERT INTO system_audit(object_type, object_id, action, performed_by, details)
    VALUES (
        'expedition',
        p_expedition_id::TEXT,
        'complete',
        NULL,
        jsonb_build_object('end_time', p_end_time)
    );

END;
$$;

COMMENT ON PROCEDURE complete_expedition IS 'Процедура завершения экспедиции';

