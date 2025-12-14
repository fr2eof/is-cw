-- =====================================================
-- Создание схемы базы данных для системы управления океанскими экспедициями
-- PostgreSQL 14+
-- =====================================================

-- Создание базы данных (выполняется от имени суперпользователя)
-- CREATE DATABASE ocean_expeditions;
-- \c ocean_expeditions

-- =====================================================
-- 1. ТАБЛИЦА СУДОВ
-- =====================================================
CREATE TABLE vessel (
    vessel_id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    imo_number          TEXT UNIQUE, -- международный идентификатор
    name                TEXT NOT NULL,
    call_sign           TEXT,
    capacity_tons       NUMERIC(10,2) CHECK (capacity_tons >= 0),
    built_year          INTEGER CHECK (built_year >= 1800 AND built_year <= EXTRACT(YEAR FROM CURRENT_DATE)),
    status              TEXT NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'on_mission', 'maintenance', 'decommissioned')),
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT now()
);

COMMENT ON TABLE vessel IS 'Справочник судов';
COMMENT ON COLUMN vessel.imo_number IS 'Международный идентификатор судна (IMO number)';
COMMENT ON COLUMN vessel.status IS 'Статус: available, on_mission, maintenance, decommissioned';

-- =====================================================
-- 2. ТАБЛИЦА ЭКСПЕДИЦИЙ
-- =====================================================
CREATE TABLE expedition (
    expedition_id       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code                TEXT NOT NULL UNIQUE, -- краткий код/номер экспедиции
    name                TEXT NOT NULL,
    description         TEXT,
    vessel_id           BIGINT REFERENCES vessel(vessel_id) ON DELETE SET NULL,
    manager_user_id     BIGINT, -- id пользователя/менеджера
    planned_start       DATE NOT NULL,
    planned_end         DATE NOT NULL,
    actual_start        TIMESTAMP WITH TIME ZONE,
    actual_end          TIMESTAMP WITH TIME ZONE,
    status              TEXT NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'ready', 'active', 'completed', 'cancelled')),
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT now(),
    CHECK (planned_end >= planned_start),
    CHECK (actual_end IS NULL OR actual_start IS NULL OR actual_end >= actual_start)
);

COMMENT ON TABLE expedition IS 'Экспедиции';
COMMENT ON COLUMN expedition.code IS 'Уникальный код экспедиции';
COMMENT ON COLUMN expedition.status IS 'Статус: planned, ready, active, completed, cancelled';

-- =====================================================
-- 3. ТАБЛИЦА ПОРТОВ
-- =====================================================
CREATE TABLE port (
    port_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name                TEXT NOT NULL,
    country             TEXT,
    latitude            NUMERIC(9,6) CHECK (latitude BETWEEN -90 AND 90),
    longitude           NUMERIC(9,6) CHECK (longitude BETWEEN -180 AND 180),
    unlocode            TEXT UNIQUE -- UN/LOCODE
);

COMMENT ON TABLE port IS 'Справочник портов';

-- =====================================================
-- 4. ТАБЛИЦА СТОЯНОК В ПОРТАХ
-- =====================================================
CREATE TABLE port_call (
    port_call_id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    expedition_id       BIGINT NOT NULL REFERENCES expedition(expedition_id) ON DELETE CASCADE,
    port_id             BIGINT NOT NULL REFERENCES port(port_id),
    arrival_ts          TIMESTAMP WITH TIME ZONE,
    departure_ts        TIMESTAMP WITH TIME ZONE,
    operation_notes     TEXT,
    CHECK (departure_ts IS NULL OR arrival_ts IS NULL OR departure_ts >= arrival_ts)
);

COMMENT ON TABLE port_call IS 'Стоянки экспедиций в портах';

-- =====================================================
-- 5. ТАБЛИЦА ЧЛЕНОВ ЭКИПАЖА
-- =====================================================
CREATE TABLE crew_member (
    crew_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    external_id         TEXT, -- id из HR/внешней системы
    first_name          TEXT NOT NULL,
    last_name           TEXT NOT NULL,
    birth_date          DATE,
    nationality         TEXT,
    email               TEXT UNIQUE,
    phone               TEXT,
    status              TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'onboard', 'on_leave')),
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT now()
);

COMMENT ON TABLE crew_member IS 'Члены экипажа';
COMMENT ON COLUMN crew_member.status IS 'Статус: active, inactive, onboard, on_leave';

-- =====================================================
-- 6. ТАБЛИЦА РОЛЕЙ/ДОЛЖНОСТЕЙ
-- =====================================================
CREATE TABLE role (
    role_id             SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code                TEXT UNIQUE NOT NULL,
    title               TEXT NOT NULL,
    min_cert_required   BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE role IS 'Справочник ролей/должностей';
COMMENT ON COLUMN role.min_cert_required IS 'Требуется ли минимальная сертификация для роли';

-- =====================================================
-- 7. ТАБЛИЦА НАЗНАЧЕНИЙ ЭКИПАЖА НА ЭКСПЕДИЦИИ (many-to-many)
-- =====================================================
CREATE TABLE crew_assignment (
    assignment_id       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    expedition_id       BIGINT NOT NULL REFERENCES expedition(expedition_id) ON DELETE CASCADE,
    crew_id             BIGINT NOT NULL REFERENCES crew_member(crew_id) ON DELETE CASCADE,
    role_id             SMALLINT REFERENCES role(role_id) ON DELETE SET NULL,
    assigned_from       DATE NOT NULL,
    assigned_to         DATE,
    is_backup           BOOLEAN DEFAULT FALSE,
    UNIQUE (expedition_id, crew_id),
    CHECK (assigned_to IS NULL OR assigned_to >= assigned_from)
);

COMMENT ON TABLE crew_assignment IS 'Назначения членов экипажа на экспедиции';
COMMENT ON COLUMN crew_assignment.is_backup IS 'Резервный член экипажа';

-- =====================================================
-- 8. ТАБЛИЦА СЕРТИФИКАТОВ
-- =====================================================
CREATE TABLE certification (
    certification_id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name                TEXT NOT NULL,
    issuer              TEXT,
    valid_from          DATE,
    valid_to            DATE,
    UNIQUE(name, issuer)
);

COMMENT ON TABLE certification IS 'Справочник сертификатов/квалификаций';

-- =====================================================
-- 9. ТАБЛИЦА СВЯЗИ ЭКИПАЖ-СЕРТИФИКАТЫ (many-to-many)
-- =====================================================
CREATE TABLE crew_certification (
    crew_id             BIGINT NOT NULL REFERENCES crew_member(crew_id) ON DELETE CASCADE,
    certification_id    BIGINT NOT NULL REFERENCES certification(certification_id) ON DELETE CASCADE,
    certificate_number  TEXT,
    issued_date         DATE,
    expiry_date         DATE,
    PRIMARY KEY (crew_id, certification_id)
);

COMMENT ON TABLE crew_certification IS 'Сертификаты членов экипажа';

-- =====================================================
-- 10. ТАБЛИЦА ОБОРУДОВАНИЯ
-- =====================================================
CREATE TABLE equipment (
    equipment_id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    serial_number       TEXT UNIQUE,
    name                TEXT NOT NULL,
    category            TEXT,
    condition           TEXT DEFAULT 'good' CHECK (condition IN ('good', 'needs_service', 'retired')),
    location_description TEXT,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT now()
);

COMMENT ON TABLE equipment IS 'Оборудование';
COMMENT ON COLUMN equipment.condition IS 'Состояние: good, needs_service, retired';

-- =====================================================
-- 11. ТАБЛИЦА СВЯЗИ ЭКСПЕДИЦИЯ-ОБОРУДОВАНИЕ (many-to-many)
-- =====================================================
CREATE TABLE expedition_equipment (
    ee_id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    expedition_id       BIGINT NOT NULL REFERENCES expedition(expedition_id) ON DELETE CASCADE,
    equipment_id        BIGINT NOT NULL REFERENCES equipment(equipment_id) ON DELETE RESTRICT,
    attached_stage      TEXT, -- e.g., 'transit', 'research', 'loading'
    qty                 INTEGER DEFAULT 1 CHECK (qty > 0),
    UNIQUE (expedition_id, equipment_id)
);

COMMENT ON TABLE expedition_equipment IS 'Оборудование, используемое в экспедициях';
COMMENT ON COLUMN expedition_equipment.attached_stage IS 'Этап использования: transit, research, loading и т.д.';

-- =====================================================
-- 12. ТАБЛИЦА ЗАДАЧ ЭКСПЕДИЦИИ
-- =====================================================
CREATE TABLE mission_task (
    task_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    expedition_id       BIGINT NOT NULL REFERENCES expedition(expedition_id) ON DELETE CASCADE,
    parent_task_id      BIGINT REFERENCES mission_task(task_id) ON DELETE SET NULL,
    title               TEXT NOT NULL,
    description         TEXT,
    responsible_crew_id BIGINT REFERENCES crew_member(crew_id) ON DELETE SET NULL,
    planned_start       TIMESTAMP WITH TIME ZONE,
    planned_end         TIMESTAMP WITH TIME ZONE,
    status              TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'done', 'blocked', 'cancelled')),
    CHECK (planned_end IS NULL OR planned_start IS NULL OR planned_end >= planned_start)
);

COMMENT ON TABLE mission_task IS 'Задачи внутри экспедиций';
COMMENT ON COLUMN mission_task.status IS 'Статус: pending, in_progress, done, blocked, cancelled';

-- =====================================================
-- 13. ТАБЛИЦА СЕНСОРОВ
-- =====================================================
CREATE TABLE sensor (
    sensor_id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    equipment_id        BIGINT REFERENCES equipment(equipment_id) ON DELETE SET NULL,
    name                TEXT NOT NULL,
    sensor_type         TEXT NOT NULL,
    unit                TEXT,
    installed_on_vessel BIGINT REFERENCES vessel(vessel_id) ON DELETE SET NULL,
    installed_at        TIMESTAMP WITH TIME ZONE
);

COMMENT ON TABLE sensor IS 'Сенсоры для сбора данных';
COMMENT ON COLUMN sensor.sensor_type IS 'Тип сенсора (для сопоставления с environmental_rule.parameter)';

-- =====================================================
-- 14. ТАБЛИЦА НАБЛЮДЕНИЙ СЕНСОРОВ
-- =====================================================
CREATE TABLE sensor_observation (
    observation_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sensor_id           BIGINT NOT NULL REFERENCES sensor(sensor_id) ON DELETE CASCADE,
    expedition_id       BIGINT REFERENCES expedition(expedition_id) ON DELETE SET NULL,
    observed_at         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    value_num           NUMERIC,
    value_text          TEXT,
    qc_status           TEXT DEFAULT 'unchecked' CHECK (qc_status IN ('unchecked', 'ok', 'flagged', 'invalid')),
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT now()
);

COMMENT ON TABLE sensor_observation IS 'Наблюдения/измерения сенсоров';
COMMENT ON COLUMN sensor_observation.qc_status IS 'Статус контроля качества: unchecked, ok, flagged, invalid';

-- =====================================================
-- 15. ТАБЛИЦА РАЗРЕШЕНИЙ/ДОКУМЕНТОВ ДЛЯ ЭКСПЕДИЦИЙ
-- =====================================================
CREATE TABLE permit (
    permit_id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    expedition_id       BIGINT REFERENCES expedition(expedition_id) ON DELETE CASCADE,
    permit_type         TEXT NOT NULL,
    issuing_authority   TEXT,
    valid_from          DATE,
    valid_to            DATE,
    document_ref        TEXT,
    CHECK (valid_to IS NULL OR valid_from IS NULL OR valid_to >= valid_from)
);

COMMENT ON TABLE permit IS 'Разрешения и документы для экспедиций';

-- =====================================================
-- 16. ТАБЛИЦА ИНЦИДЕНТОВ
-- =====================================================
CREATE TABLE incident (
    incident_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    expedition_id       BIGINT REFERENCES expedition(expedition_id) ON DELETE SET NULL,
    reported_at         TIMESTAMP WITH TIME ZONE DEFAULT now(),
    reported_by_crew_id BIGINT REFERENCES crew_member(crew_id) ON DELETE SET NULL,
    severity            TEXT NOT NULL DEFAULT 'medium' CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    category            TEXT,
    description         TEXT,
    resolved_at         TIMESTAMP WITH TIME ZONE
);

COMMENT ON TABLE incident IS 'Журнал инцидентов и событий';
COMMENT ON COLUMN incident.severity IS 'Уровень серьезности: low, medium, high, critical';

-- =====================================================
-- 17. ТАБЛИЦА ЗАПАСОВ/ИНВЕНТАРЯ
-- =====================================================
CREATE TABLE inventory_item (
    item_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    expedition_id       BIGINT REFERENCES expedition(expedition_id) ON DELETE CASCADE,
    name                TEXT NOT NULL,
    unit                TEXT NOT NULL,
    quantity_onboard    NUMERIC(12,3) DEFAULT 0 CHECK (quantity_onboard >= 0)
);

COMMENT ON TABLE inventory_item IS 'Запасы и ресурсы экспедиций';

-- =====================================================
-- 18. ТАБЛИЦА ТРАНЗАКЦИЙ ИНВЕНТАРЯ
-- =====================================================
CREATE TABLE inventory_transaction (
    txn_id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    item_id             BIGINT NOT NULL REFERENCES inventory_item(item_id) ON DELETE CASCADE,
    txn_type            TEXT NOT NULL CHECK (txn_type IN ('load', 'unload', 'consume', 'transfer_in', 'transfer_out', 'adjust')),
    qty                 NUMERIC(12,3) NOT NULL,
    txn_ts              TIMESTAMP WITH TIME ZONE DEFAULT now(),
    performed_by        BIGINT REFERENCES crew_member(crew_id),
    notes               TEXT
);

COMMENT ON TABLE inventory_transaction IS 'Движения запасов (погрузка, расход, корректировки)';
COMMENT ON COLUMN inventory_transaction.txn_type IS 'Тип: load, unload, consume, transfer_in, transfer_out, adjust';

-- =====================================================
-- 19. ТАБЛИЦА ЭКОЛОГИЧЕСКИХ ПРАВИЛ/ПОРОГОВ
-- =====================================================
CREATE TABLE environmental_rule (
    rule_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name                TEXT NOT NULL UNIQUE,
    parameter           TEXT NOT NULL, -- e.g., 'oil_concentration'
    threshold_value     NUMERIC,
    threshold_operator  TEXT DEFAULT '<=' CHECK (threshold_operator IN ('<=', '>=', '>', '<')),
    active              BOOLEAN DEFAULT TRUE
);

COMMENT ON TABLE environmental_rule IS 'Экологические правила и пороговые значения';
COMMENT ON COLUMN environmental_rule.parameter IS 'Параметр (должен соответствовать sensor.sensor_type)';

-- =====================================================
-- 20. ТАБЛИЦА ДОКУМЕНТОВ
-- =====================================================
CREATE TABLE document (
    document_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    expedition_id       BIGINT REFERENCES expedition(expedition_id) ON DELETE CASCADE,
    doc_type            TEXT,
    title               TEXT,
    version             TEXT,
    stored_at           TEXT, -- path or external storage ref
    uploaded_by         BIGINT REFERENCES crew_member(crew_id),
    uploaded_at         TIMESTAMP WITH TIME ZONE DEFAULT now()
);

COMMENT ON TABLE document IS 'Общие документы экспедиций';

-- =====================================================
-- 21. ТАБЛИЦА СИСТЕМНОГО АУДИТА
-- =====================================================
CREATE TABLE system_audit (
    audit_id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_ts            TIMESTAMP WITH TIME ZONE DEFAULT now(),
    object_type         TEXT,
    object_id           TEXT,
    action              TEXT,
    performed_by        BIGINT,
    details             JSONB
);

COMMENT ON TABLE system_audit IS 'Журнал системных событий для аудита';

