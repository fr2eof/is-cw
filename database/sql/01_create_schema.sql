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
    vessel_id           SERIAL PRIMARY KEY,
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
    expedition_id       SERIAL PRIMARY KEY,
    code                TEXT NOT NULL UNIQUE, -- краткий код/номер экспедиции
    name                TEXT NOT NULL,
    description         TEXT,
    vessel_id           INTEGER REFERENCES vessel(vessel_id) ON DELETE SET NULL,
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
    port_id             SERIAL PRIMARY KEY,
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
    port_call_id        SERIAL PRIMARY KEY,
    expedition_id       INTEGER NOT NULL REFERENCES expedition(expedition_id) ON DELETE CASCADE,
    port_id             INTEGER NOT NULL REFERENCES port(port_id),
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
    crew_id             SERIAL PRIMARY KEY,
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
    role_id             SERIAL PRIMARY KEY,
    code                TEXT UNIQUE NOT NULL,
    title               TEXT NOT NULL,
    min_cert_required   BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE role IS 'Справочник ролей/должностей';
COMMENT ON COLUMN role.min_cert_required IS 'Требуется ли минимальная сертификация для роли';

-- =====================================================
-- 7. ТАБЛИЦА СВЯЗИ ЭКИПАЖ-РОЛИ (many-to-many)
-- =====================================================
CREATE TABLE crew_role (
    role_id             INTEGER NOT NULL REFERENCES role(role_id) ON DELETE CASCADE,
    crew_id             INTEGER NOT NULL REFERENCES crew_member(crew_id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, crew_id)
);

COMMENT ON TABLE crew_role IS 'Связь членов экипажа с ролями (many-to-many)';

-- =====================================================
-- 8. ТАБЛИЦА НАЗНАЧЕНИЙ ЭКИПАЖА НА ЭКСПЕДИЦИИ (many-to-many)
-- =====================================================
CREATE TABLE crew_assignment (
    expedition_id       INTEGER NOT NULL REFERENCES expedition(expedition_id) ON DELETE CASCADE,
    crew_id             INTEGER NOT NULL REFERENCES crew_member(crew_id) ON DELETE CASCADE,
    PRIMARY KEY (expedition_id, crew_id)
);

COMMENT ON TABLE crew_assignment IS 'Назначения членов экипажа на экспедиции (many-to-many)';

-- =====================================================
-- 9. ТАБЛИЦА СЕРТИФИКАТОВ
-- =====================================================
CREATE TABLE certification (
    certification_id    SERIAL PRIMARY KEY,
    name                TEXT NOT NULL,
    issuer              TEXT,
    valid_from          DATE,
    valid_to            DATE,
    UNIQUE(name, issuer)
);

COMMENT ON TABLE certification IS 'Справочник сертификатов/квалификаций';

-- =====================================================
-- 10. ТАБЛИЦА СВЯЗИ ЭКИПАЖ-СЕРТИФИКАТЫ (many-to-many)
-- =====================================================
CREATE TABLE crew_certification (
    crew_id             INTEGER NOT NULL REFERENCES crew_member(crew_id) ON DELETE CASCADE,
    certification_id    INTEGER NOT NULL REFERENCES certification(certification_id) ON DELETE CASCADE,
    certificate_number  TEXT,
    issued_date         DATE,
    expiry_date         DATE,
    PRIMARY KEY (crew_id, certification_id)
);

COMMENT ON TABLE crew_certification IS 'Сертификаты членов экипажа';

-- =====================================================
-- 11. ТАБЛИЦА ОБОРУДОВАНИЯ
-- =====================================================
CREATE TABLE equipment (
    equipment_id        SERIAL PRIMARY KEY,
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
-- 12. ТАБЛИЦА СВЯЗИ ЭКСПЕДИЦИЯ-ОБОРУДОВАНИЕ (many-to-many)
-- =====================================================
CREATE TABLE expedition_equipment (
    expedition_id       INTEGER NOT NULL REFERENCES expedition(expedition_id) ON DELETE CASCADE,
    equipment_id        INTEGER NOT NULL REFERENCES equipment(equipment_id) ON DELETE RESTRICT,
    PRIMARY KEY (expedition_id, equipment_id)
);

COMMENT ON TABLE expedition_equipment IS 'Оборудование, используемое в экспедициях (many-to-many)';

-- =====================================================
-- 13. ТАБЛИЦА ЭКОЛОГИЧЕСКИХ ПРАВИЛ/ПОРОГОВ
-- =====================================================
CREATE TABLE environmental_rule (
    rule_id             SERIAL PRIMARY KEY,
    name                TEXT NOT NULL UNIQUE,
    parameter           TEXT NOT NULL, -- e.g., 'oil_concentration'
    threshold_value     NUMERIC,
    threshold_operator  TEXT DEFAULT '<=' CHECK (threshold_operator IN ('<=', '>=', '>', '<')),
    active              BOOLEAN DEFAULT TRUE
);

COMMENT ON TABLE environmental_rule IS 'Экологические правила и пороговые значения';
COMMENT ON COLUMN environmental_rule.parameter IS 'Параметр (должен соответствовать sensor.sensor_type)';

-- =====================================================
-- 14. ТАБЛИЦА ЗАДАЧ ЭКСПЕДИЦИИ
-- =====================================================
CREATE TABLE mission_task (
    task_id             SERIAL PRIMARY KEY,
    expedition_id       INTEGER NOT NULL REFERENCES expedition(expedition_id) ON DELETE CASCADE,
    parent_task_id      INTEGER REFERENCES mission_task(task_id) ON DELETE SET NULL,
    title               TEXT NOT NULL,
    description         TEXT,
    responsible_crew_id INTEGER REFERENCES crew_member(crew_id) ON DELETE SET NULL,
    planned_start       TIMESTAMP WITH TIME ZONE,
    planned_end         TIMESTAMP WITH TIME ZONE,
    status              TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'done', 'blocked', 'cancelled')),
    CHECK (planned_end IS NULL OR planned_start IS NULL OR planned_end >= planned_start)
);

COMMENT ON TABLE mission_task IS 'Задачи внутри экспедиций';
COMMENT ON COLUMN mission_task.status IS 'Статус: pending, in_progress, done, blocked, cancelled';

-- =====================================================
-- 15. ТАБЛИЦА СЕНСОРОВ
-- =====================================================
CREATE TABLE sensor (
    sensor_id           SERIAL PRIMARY KEY,
    equipment_id        INTEGER REFERENCES equipment(equipment_id) ON DELETE SET NULL,
    name                TEXT NOT NULL,
    sensor_type         TEXT NOT NULL,
    unit                TEXT,
    installed_on_vessel INTEGER REFERENCES vessel(vessel_id) ON DELETE SET NULL,
    installed_at        TIMESTAMP WITH TIME ZONE,
    rule_id             INTEGER REFERENCES environmental_rule(rule_id) ON DELETE SET NULL
);

COMMENT ON TABLE sensor IS 'Сенсоры для сбора данных';
COMMENT ON COLUMN sensor.sensor_type IS 'Тип сенсора (для сопоставления с environmental_rule.parameter)';
COMMENT ON COLUMN sensor.rule_id IS 'Экологическое правило, применяемое к данному сенсору';

-- =====================================================
-- 16. ТАБЛИЦА НАБЛЮДЕНИЙ СЕНСОРОВ
-- =====================================================
CREATE TABLE sensor_observation (
    observation_id      SERIAL PRIMARY KEY,
    sensor_id           INTEGER NOT NULL REFERENCES sensor(sensor_id) ON DELETE CASCADE,
    expedition_id       INTEGER REFERENCES expedition(expedition_id) ON DELETE SET NULL,
    observed_at         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    value_num           NUMERIC,
    value_text          TEXT,
    qc_status           TEXT DEFAULT 'unchecked' CHECK (qc_status IN ('unchecked', 'ok', 'flagged', 'invalid')),
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT now()
);

COMMENT ON TABLE sensor_observation IS 'Наблюдения/измерения сенсоров';
COMMENT ON COLUMN sensor_observation.qc_status IS 'Статус контроля качества: unchecked, ok, flagged, invalid';

-- =====================================================
-- 17. ТАБЛИЦА РАЗРЕШЕНИЙ/ДОКУМЕНТОВ ДЛЯ ЭКСПЕДИЦИЙ
-- =====================================================
CREATE TABLE permit (
    permit_id           SERIAL PRIMARY KEY,
    expedition_id       INTEGER REFERENCES expedition(expedition_id) ON DELETE CASCADE,
    permit_type         TEXT NOT NULL,
    issuing_authority   TEXT,
    valid_from          DATE,
    valid_to            DATE,
    document_ref        TEXT,
    CHECK (valid_to IS NULL OR valid_from IS NULL OR valid_to >= valid_from)
);

COMMENT ON TABLE permit IS 'Разрешения и документы для экспедиций';

-- =====================================================
-- 18. ТАБЛИЦА ИНЦИДЕНТОВ
-- =====================================================
CREATE TABLE incident (
    incident_id         SERIAL PRIMARY KEY,
    expedition_id       INTEGER REFERENCES expedition(expedition_id) ON DELETE SET NULL,
    reported_at         TIMESTAMP WITH TIME ZONE DEFAULT now(),
    reported_by_crew_id INTEGER REFERENCES crew_member(crew_id) ON DELETE SET NULL,
    severity            TEXT NOT NULL DEFAULT 'medium' CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    category            TEXT,
    description         TEXT,
    resolved_at         TIMESTAMP WITH TIME ZONE
);

COMMENT ON TABLE incident IS 'Журнал инцидентов и событий';
COMMENT ON COLUMN incident.severity IS 'Уровень серьезности: low, medium, high, critical';

-- =====================================================
-- 19. ТАБЛИЦА ЗАПАСОВ/ИНВЕНТАРЯ
-- =====================================================
CREATE TABLE inventory_item (
    item_id             SERIAL PRIMARY KEY,
    expedition_id       INTEGER REFERENCES expedition(expedition_id) ON DELETE CASCADE,
    name                TEXT NOT NULL,
    unit                TEXT NOT NULL,
    quantity_onboard    NUMERIC(12,3) DEFAULT 0 CHECK (quantity_onboard >= 0)
);

COMMENT ON TABLE inventory_item IS 'Запасы и ресурсы экспедиций';

-- =====================================================
-- 20. ТАБЛИЦА ТРАНЗАКЦИЙ ИНВЕНТАРЯ
-- =====================================================
CREATE TABLE inventory_transaction (
    txn_id              SERIAL PRIMARY KEY,
    item_id             INTEGER NOT NULL REFERENCES inventory_item(item_id) ON DELETE CASCADE,
    txn_type            TEXT NOT NULL CHECK (txn_type IN ('load', 'unload', 'consume', 'transfer_in', 'transfer_out', 'adjust')),
    qty                 NUMERIC(12,3) NOT NULL,
    txn_ts              TIMESTAMP WITH TIME ZONE DEFAULT now(),
    performed_by        INTEGER REFERENCES crew_member(crew_id) ON DELETE SET NULL,
    notes               TEXT
);

COMMENT ON TABLE inventory_transaction IS 'Движения запасов (погрузка, расход, корректировки)';
COMMENT ON COLUMN inventory_transaction.txn_type IS 'Тип: load, unload, consume, transfer_in, transfer_out, adjust';

-- =====================================================
-- 21. ТАБЛИЦА ДОКУМЕНТОВ
-- =====================================================
CREATE TABLE document (
    document_id         SERIAL PRIMARY KEY,
    expedition_id       INTEGER REFERENCES expedition(expedition_id) ON DELETE CASCADE,
    doc_type            TEXT,
    title               TEXT,
    version             TEXT,
    stored_at           TEXT, -- path or external storage ref
    uploaded_by         INTEGER REFERENCES crew_member(crew_id) ON DELETE SET NULL,
    uploaded_at         TIMESTAMP WITH TIME ZONE DEFAULT now()
);

COMMENT ON TABLE document IS 'Общие документы экспедиций';

-- =====================================================
-- 22. ТАБЛИЦА СИСТЕМНОГО АУДИТА
-- =====================================================
CREATE TABLE system_audit (
    audit_id            SERIAL PRIMARY KEY,
    event_ts            TIMESTAMP WITH TIME ZONE DEFAULT now(),
    object_type         TEXT,
    object_id           TEXT,
    action              TEXT,
    performed_by        INTEGER REFERENCES crew_member(crew_id) ON DELETE SET NULL,
    details             JSONB
);

COMMENT ON TABLE system_audit IS 'Журнал системных событий для аудита';

