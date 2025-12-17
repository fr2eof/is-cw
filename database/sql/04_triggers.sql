-- =====================================================
-- Триггеры для обеспечения целостности данных
-- =====================================================

-- =====================================================
-- ТРИГГЕР 1: Контроль отрицательных запасов
-- =====================================================
-- При вставке транзакции обновляет quantity_onboard и запрещает отрицательное значение
CREATE OR REPLACE FUNCTION fn_inventory_apply_txn() 
RETURNS TRIGGER AS $$
BEGIN
    -- Применяем транзакцию к inventory_item
    IF (TG_OP = 'INSERT') THEN
        -- Обновляем quantity_onboard в таблице inventory_item
        UPDATE inventory_item
        SET quantity_onboard = quantity_onboard +
            CASE
                WHEN NEW.txn_type IN ('load', 'transfer_in') THEN NEW.qty
                WHEN NEW.txn_type IN ('unload', 'transfer_out', 'consume') THEN -NEW.qty
                WHEN NEW.txn_type = 'adjust' THEN NEW.qty
                ELSE 0
            END
        WHERE item_id = NEW.item_id;

        -- Проверяем значение
        IF (SELECT quantity_onboard FROM inventory_item WHERE item_id = NEW.item_id) < 0 THEN
            RAISE EXCEPTION 'Inventory level would become negative for item %', NEW.item_id;
        END IF;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        -- Запрещаем удаление транзакции (или можно откатно корректировать)
        RAISE EXCEPTION 'Deleting inventory transactions is not allowed. Use reverse transaction instead.';
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_inventory_apply_txn
AFTER INSERT ON inventory_transaction
FOR EACH ROW EXECUTE FUNCTION fn_inventory_apply_txn();

COMMENT ON FUNCTION fn_inventory_apply_txn() IS 'Триггерная функция для автоматического обновления количества запасов и контроля отрицательных значений';

-- =====================================================
-- ТРИГГЕР 2: Проверка уникальности назначений (опционально)
-- =====================================================
-- Триггер не требуется, так как уникальность обеспечивается PRIMARY KEY (expedition_id, crew_id)
-- Оставлено как комментарий для будущего расширения, если потребуется дополнительная логика

-- =====================================================
-- ТРИГГЕР 3: Проверка экологических правил и создание инцидентов
-- =====================================================
-- При вставке sensor_observation сравнивает значение с environmental_rule 
-- и автоматически создает incident при превышении порога
CREATE OR REPLACE FUNCTION fn_sensor_qc_and_env_check() 
RETURNS TRIGGER AS $$
DECLARE
    r RECORD;
    op TEXT;
    threshold NUMERIC;
    sensor_type_val TEXT;
BEGIN
    -- Простой QC: если value_num IS NULL и value_text IS NULL — пометим invalid
    IF NEW.value_num IS NULL AND NEW.value_text IS NULL THEN
        NEW.qc_status := 'invalid';
        RETURN NEW;
    END IF;

    -- Получаем тип сенсора
    SELECT sensor_type INTO sensor_type_val
    FROM sensor 
    WHERE sensor_id = NEW.sensor_id;

    -- Проходим по активным правилам для параметра sensor_type
    FOR r IN 
        SELECT * 
        FROM environmental_rule 
        WHERE active = true AND parameter = sensor_type_val
    LOOP
        threshold := r.threshold_value;
        op := r.threshold_operator;

        IF NEW.value_num IS NOT NULL THEN
            -- Проверяем нарушение правила
            IF (op = '<=' AND NEW.value_num > threshold) OR
               (op = '>=' AND NEW.value_num < threshold) OR
               (op = '>' AND NEW.value_num <= threshold) OR
               (op = '<' AND NEW.value_num >= threshold) THEN
                
                -- Создаем инцидент
                INSERT INTO incident(
                    expedition_id, 
                    reported_by_crew_id, 
                    severity, 
                    category, 
                    description
                )
                VALUES (
                    NEW.expedition_id, 
                    NULL, 
                    'high', 
                    'environmental_threshold', 
                    format('Sensor %s value %s violates rule "%s" (threshold: %s %s %s)',
                        NEW.sensor_id, 
                        NEW.value_num, 
                        r.name,
                        op,
                        threshold,
                        sensor_type_val)
                );
                
                NEW.qc_status := 'flagged';
                RETURN NEW;
            END IF;
        END IF;
    END LOOP;

    -- Если все проверки пройдены
    IF NEW.qc_status = 'unchecked' THEN
        NEW.qc_status := 'ok';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sensor_qc
BEFORE INSERT ON sensor_observation
FOR EACH ROW EXECUTE FUNCTION fn_sensor_qc_and_env_check();

COMMENT ON FUNCTION fn_sensor_qc_and_env_check() IS 'Триггерная функция для контроля качества данных сенсоров и проверки экологических порогов';

-- =====================================================
-- ТРИГГЕР 4: Автоматическое обновление статуса экспедиции
-- =====================================================
-- Обновляет статус экспедиции на 'active' при установке actual_start
CREATE OR REPLACE FUNCTION fn_update_expedition_status() 
RETURNS TRIGGER AS $$
BEGIN
    -- Если установили actual_start и статус был 'planned' или 'ready', меняем на 'active'
    IF NEW.actual_start IS NOT NULL AND OLD.actual_start IS NULL THEN
        IF NEW.status IN ('planned', 'ready') THEN
            NEW.status := 'active';
        END IF;
    END IF;
    
    -- Если установили actual_end и статус был 'active', меняем на 'completed'
    IF NEW.actual_end IS NOT NULL AND OLD.actual_end IS NULL THEN
        IF NEW.status = 'active' THEN
            NEW.status := 'completed';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_expedition_status
BEFORE UPDATE ON expedition
FOR EACH ROW EXECUTE FUNCTION fn_update_expedition_status();

COMMENT ON FUNCTION fn_update_expedition_status() IS 'Триггерная функция для автоматического обновления статуса экспедиции при изменении дат';

-- =====================================================
-- ТРИГГЕР 5: Логирование изменений в system_audit
-- =====================================================
-- Пример триггера для аудита изменений в критичных таблицах
CREATE OR REPLACE FUNCTION fn_audit_expedition_changes() 
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO system_audit(object_type, object_id, action, performed_by, details)
    VALUES (
        'expedition',
        COALESCE(NEW.expedition_id, OLD.expedition_id)::TEXT,
        TG_OP,
        NULL, -- можно получить из сессии пользователя
        jsonb_build_object(
            'old', to_jsonb(OLD),
            'new', to_jsonb(NEW)
        )
    );
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_expedition_changes
AFTER INSERT OR UPDATE OR DELETE ON expedition
FOR EACH ROW EXECUTE FUNCTION fn_audit_expedition_changes();

COMMENT ON FUNCTION fn_audit_expedition_changes() IS 'Триггерная функция для логирования изменений экспедиций в system_audit';

