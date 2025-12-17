-- =====================================================
-- Индексы для оптимизации запросов
-- =====================================================

-- =====================================================
-- ИНДЕКСЫ ДЛЯ ТАБЛИЦЫ EXPEDITION
-- =====================================================

-- Индекс по коду экспедиции (часто используется для поиска)
CREATE INDEX idx_expedition_code ON expedition(code);

COMMENT ON INDEX idx_expedition_code IS 
'Ускоряет поиск экспедиций по коду. Используется в прецедентах: просмотр информации об экспедиции, фильтрация списка экспедиций.';

-- Композитный индекс по статусу и датам (поисковый фильтр на планируемые/активные)
CREATE INDEX idx_expedition_status_dates ON expedition(status, planned_start, planned_end);

COMMENT ON INDEX idx_expedition_status_dates IS 
'Оптимизирует запросы фильтрации экспедиций по статусу и временным диапазонам. Критично для дашбордов с фильтрацией по статусу (planned, active, completed) и датам. Ускоряет прецеденты: список активных экспедиций, планирование на период.';

-- Индекс по vessel_id для быстрого поиска экспедиций судна
CREATE INDEX idx_expedition_vessel ON expedition(vessel_id) WHERE vessel_id IS NOT NULL;

COMMENT ON INDEX idx_expedition_vessel IS 
'Ускоряет поиск всех экспедиций для конкретного судна. Используется в прецедентах: история использования судна, планирование использования флота.';

-- =====================================================
-- ИНДЕКСЫ ДЛЯ ТАБЛИЦЫ VESSEL
-- =====================================================

-- Индекс по статусу (фильтрация доступных судов)
CREATE INDEX idx_vessel_status ON vessel(status);

COMMENT ON INDEX idx_vessel_status IS 
'Ускоряет фильтрацию судов по статусу. Критично для прецедента "Выбор судна для экспедиции" - быстрый поиск доступных судов (status = "available").';

-- =====================================================
-- ИНДЕКСЫ ДЛЯ ТАБЛИЦЫ SENSOR_OBSERVATION
-- =====================================================

-- Композитный индекс по sensor_id и времени наблюдения (временные ряды)
CREATE INDEX idx_obs_sensor_ts ON sensor_observation(sensor_id, observed_at DESC);

COMMENT ON INDEX idx_obs_sensor_ts IS 
'КРИТИЧЕСКИ ВАЖЕН: Ускоряет запросы временных рядов данных сенсоров. Сенсорные данные чаще всего читаются по sensor_id и времени (для графиков, аналитики, QC). DESC порядок обеспечивает быстрый доступ к последним данным. Используется в прецедентах: отображение графиков данных, контроль качества, мониторинг в реальном времени.';

-- Индекс по expedition_id для фильтрации наблюдений экспедиции
CREATE INDEX idx_obs_expedition ON sensor_observation(expedition_id) WHERE expedition_id IS NOT NULL;

COMMENT ON INDEX idx_obs_expedition IS 
'Ускоряет получение всех наблюдений для конкретной экспедиции. Используется в прецедентах: анализ данных экспедиции, генерация отчетов, экспорт данных.';

-- Индекс по qc_status для фильтрации проблемных данных
CREATE INDEX idx_obs_qc_status ON sensor_observation(qc_status) WHERE qc_status IN ('flagged', 'invalid');

COMMENT ON INDEX idx_obs_qc_status IS 
'Ускоряет поиск данных с проблемами контроля качества. Используется в прецедентах: мониторинг качества данных, обработка инцидентов, проверка триггеров.';

-- =====================================================
-- ИНДЕКСЫ ДЛЯ ТАБЛИЦЫ MISSION_TASK
-- =====================================================

-- Композитный индекс по expedition_id и status
CREATE INDEX idx_task_expedition_status ON mission_task(expedition_id, status);

COMMENT ON INDEX idx_task_expedition_status IS 
'Ускоряет получение задач по экспедиции с фильтрацией по статусу. Критично для прецедентов: список задач экспедиции, отслеживание прогресса (pending, in_progress, done), дашборд ответственного.';

-- Индекс по responsible_crew_id для задач конкретного сотрудника
CREATE INDEX idx_task_responsible ON mission_task(responsible_crew_id) WHERE responsible_crew_id IS NOT NULL;

COMMENT ON INDEX idx_task_responsible IS 
'Ускоряет получение всех задач для конкретного члена экипажа. Используется в прецедентах: личный дашборд сотрудника, распределение нагрузки.';

-- Индекс по parent_task_id для иерархии задач
CREATE INDEX idx_task_parent ON mission_task(parent_task_id) WHERE parent_task_id IS NOT NULL;

COMMENT ON INDEX idx_task_parent IS 
'Ускоряет получение подзадач для родительской задачи. Используется для отображения иерархической структуры задач.';

-- =====================================================
-- ИНДЕКСЫ ДЛЯ ТАБЛИЦЫ CREW_ASSIGNMENT
-- =====================================================

-- Композитный индекс по expedition_id и crew_id
CREATE INDEX idx_ca_expedition_crew ON crew_assignment(expedition_id, crew_id);

COMMENT ON INDEX idx_ca_expedition_crew IS 
'КРИТИЧЕСКИ ВАЖЕН: Ускоряет поиск назначений экипажа для экспедиции. Используется в прецедентах: получение состава экипажа экспедиции, проверка назначений при добавлении нового члена экипажа (триггер проверки перекрытий).';

-- Индекс по crew_id для поиска всех экспедиций сотрудника
CREATE INDEX idx_ca_crew ON crew_assignment(crew_id);

COMMENT ON INDEX idx_ca_crew IS 
'Ускоряет поиск всех экспедиций для конкретного члена экипажа. Используется в прецедентах: история работы сотрудника, проверка доступности, планирование карьеры.';

-- =====================================================
-- ИНДЕКСЫ ДЛЯ ТАБЛИЦЫ CREW_ROLE
-- =====================================================

-- Индекс по crew_id для поиска ролей сотрудника
CREATE INDEX idx_crew_role_crew ON crew_role(crew_id);

COMMENT ON INDEX idx_crew_role_crew IS 
'Ускоряет поиск всех ролей для конкретного члена экипажа. Используется в прецедентах: проверка квалификации, подбор экипажа по ролям.';

-- Индекс по role_id для поиска сотрудников с конкретной ролью
CREATE INDEX idx_crew_role_role ON crew_role(role_id);

COMMENT ON INDEX idx_crew_role_role IS 
'Ускоряет поиск всех членов экипажа с конкретной ролью. Используется в прецедентах: подбор экипажа для экспедиции по требуемым ролям.';

-- =====================================================
-- ИНДЕКСЫ ДЛЯ ТАБЛИЦЫ CREW_CERTIFICATION
-- =====================================================

-- Композитный индекс по certification_id и crew_id
CREATE INDEX idx_crew_cert_certid ON crew_certification(certification_id, crew_id);

COMMENT ON INDEX idx_crew_cert_certid IS 
'Ускоряет поиск всех членов экипажа с конкретным сертификатом. Используется в прецедентах: подбор экипажа по требованиям (функция assign_crew_to_expedition), проверка квалификации.';

-- Индекс по expiry_date для поиска просроченных сертификатов
CREATE INDEX idx_crew_cert_expiry ON crew_certification(crew_id, expiry_date) WHERE expiry_date IS NOT NULL;

COMMENT ON INDEX idx_crew_cert_expiry IS 
'Ускоряет поиск сертификатов, подлежащих обновлению. Используется в прецедентах: мониторинг актуальности сертификатов, предупреждения о истечении сроков.';

-- =====================================================
-- ИНДЕКСЫ ДЛЯ ТАБЛИЦЫ INVENTORY_ITEM
-- =====================================================

-- Индекс по quantity_onboard для быстрой фильтрации низких запасов
CREATE INDEX idx_inventory_qty ON inventory_item(quantity_onboard) WHERE quantity_onboard > 0;

COMMENT ON INDEX idx_inventory_qty IS 
'Ускоряет поиск позиций с низким остатком (для мониторинга запасов). Используется в прецедентах: предупреждения о низких запасах, планирование пополнения, отчеты по запасам.';

-- Индекс по expedition_id для запасов экспедиции
CREATE INDEX idx_inventory_expedition ON inventory_item(expedition_id) WHERE expedition_id IS NOT NULL;

COMMENT ON INDEX idx_inventory_expedition IS 
'Ускоряет получение всех позиций инвентаря для экспедиции. Используется в прецедентах: управление запасами экспедиции, отчеты по ресурсам.';

-- =====================================================
-- ИНДЕКСЫ ДЛЯ ТАБЛИЦЫ INVENTORY_TRANSACTION
-- =====================================================

-- Индекс по item_id для истории транзакций позиции
CREATE INDEX idx_inv_txn_item ON inventory_transaction(item_id, txn_ts DESC);

COMMENT ON INDEX idx_inv_txn_item IS 
'Ускоряет получение истории транзакций для позиции инвентаря (хронологический порядок). Используется в прецедентах: аудит движения запасов, анализ использования ресурсов.';

-- =====================================================
-- ИНДЕКСЫ ДЛЯ ТАБЛИЦЫ INCIDENT
-- =====================================================

-- Композитный индекс по expedition_id, severity и времени
CREATE INDEX idx_incident_expedition_sev ON incident(expedition_id, severity, reported_at DESC);

COMMENT ON INDEX idx_incident_expedition_sev IS 
'Ускоряет поиск инцидентов по экспедиции с фильтрацией по серьезности и сортировке по времени. Используется в прецедентах: мониторинг инцидентов экспедиции, приоритизация критичных проблем (severity = critical, high), история событий.';

-- Индекс по resolved_at для нерешенных инцидентов
CREATE INDEX idx_incident_unresolved ON incident(expedition_id, reported_at DESC) WHERE resolved_at IS NULL;

COMMENT ON INDEX idx_incident_unresolved IS 
'Ускоряет поиск открытых (нерешенных) инцидентов. Используется в прецедентах: дашборд активных проблем, мониторинг критичных ситуаций.';

-- =====================================================
-- ИНДЕКСЫ ДЛЯ ТАБЛИЦЫ PORT_CALL
-- =====================================================

-- Индекс по expedition_id для всех стоянок экспедиции
CREATE INDEX idx_port_call_expedition ON port_call(expedition_id, arrival_ts);

COMMENT ON INDEX idx_port_call_expedition IS 
'Ускоряет получение маршрута экспедиции (всех стоянок в хронологическом порядке). Используется в прецедентах: отображение маршрута, планирование логистики, отчеты о перемещениях.';

-- =====================================================
-- ИНДЕКСЫ ДЛЯ ТАБЛИЦЫ SENSOR
-- =====================================================

-- Индекс по installed_on_vessel для сенсоров судна
CREATE INDEX idx_sensor_vessel ON sensor(installed_on_vessel) WHERE installed_on_vessel IS NOT NULL;

COMMENT ON INDEX idx_sensor_vessel IS 
'Ускоряет получение всех сенсоров, установленных на судне. Используется в прецедентах: конфигурация судна, мониторинг оборудования.';

-- Индекс по sensor_type для поиска сенсоров типа (для сопоставления с environmental_rule)
CREATE INDEX idx_sensor_type ON sensor(sensor_type);

COMMENT ON INDEX idx_sensor_type IS 
'Ускоряет поиск сенсоров по типу. Используется в триггере fn_sensor_qc_and_env_check для сопоставления с environmental_rule.parameter.';

-- Индекс по rule_id для поиска сенсоров, связанных с правилом
CREATE INDEX idx_sensor_rule ON sensor(rule_id) WHERE rule_id IS NOT NULL;

COMMENT ON INDEX idx_sensor_rule IS 
'Ускоряет поиск всех сенсоров, связанных с конкретным экологическим правилом. Используется для управления правилами и проверки их применения.';

-- =====================================================
-- ИНДЕКСЫ ДЛЯ ТАБЛИЦЫ ENVIRONMENTAL_RULE
-- =====================================================

-- Индекс по parameter для быстрого поиска правил для типа сенсора
CREATE INDEX idx_env_rule_parameter ON environmental_rule(parameter, active) WHERE active = true;

COMMENT ON INDEX idx_env_rule_parameter IS 
'КРИТИЧЕСКИ ВАЖЕН: Ускоряет поиск активных правил для параметра сенсора в триггере fn_sensor_qc_and_env_check. Без этого индекса проверка каждого наблюдения требовала бы полного сканирования таблицы правил.';

-- =====================================================
-- ИНДЕКСЫ ДЛЯ ТАБЛИЦЫ SYSTEM_AUDIT
-- =====================================================

-- Композитный индекс для аудита по типу объекта и времени
CREATE INDEX idx_audit_object_time ON system_audit(object_type, event_ts DESC);

COMMENT ON INDEX idx_audit_object_time IS 
'Ускоряет получение истории событий для объекта (например, все изменения экспедиции). Используется в прецедентах: аудит изменений, откат операций, анализ активности.';

-- =====================================================
-- ИТОГОВАЯ СТАТИСТИКА
-- =====================================================

-- После создания индексов рекомендуется обновить статистику
ANALYZE;

