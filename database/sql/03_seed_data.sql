-- =====================================================
-- Заполнение базы данных тестовыми данными
-- =====================================================

-- СУДА
INSERT INTO vessel(name, imo_number, call_sign, capacity_tons, built_year, status)
VALUES 
    ('R/V Oceanus', '1234567', 'OCN1', 1200.00, 2002, 'available'),
    ('CargoAlpha', '7654321', 'CARGA', 5000.00, 1998, 'maintenance'),
    ('Research Vessel Aurora', '9876543', 'AUR1', 2500.00, 2010, 'available');

-- ЭКСПЕДИЦИИ
INSERT INTO expedition(code, name, description, vessel_id, planned_start, planned_end, status)
VALUES 
    ('EXP-2026-001', 'Antarctic Survey', 'Scientific survey of southern ocean', 1, '2026-01-10', '2026-02-10', 'planned'),
    ('EXP-2026-002', 'Arctic Research', 'Study of Arctic ice conditions', 3, '2026-03-15', '2026-04-20', 'planned');

-- ПОРТЫ
INSERT INTO port(name, country, latitude, longitude, unlocode)
VALUES 
    ('Port of Example', 'Norway', 60.3913, 5.3221, 'NOEGO'),
    ('Longyearbyen', 'Norway', 78.2232, 15.6267, 'NOLYR'),
    ('Ushuaia', 'Argentina', -54.8019, -68.3030, 'ARUSH');

-- СТОЯНКИ
INSERT INTO port_call(expedition_id, port_id, arrival_ts, departure_ts, operation_notes)
VALUES 
    (1, 1, '2026-01-08 10:00:00+00', '2026-01-10 14:00:00+00', 'Loading equipment and supplies'),
    (2, 3, '2026-03-10 08:00:00+00', '2026-03-15 16:00:00+00', 'Final preparations');

-- ЧЛЕНЫ ЭКИПАЖА
INSERT INTO crew_member(first_name, last_name, email, birth_date, nationality, status)
VALUES 
    ('Ivan', 'Petrov', 'ivan.petrov@example.org', '1980-05-15', 'Russian', 'active'),
    ('Anna', 'Sidorova', 'anna.sidorova@example.org', '1985-08-22', 'Russian', 'active'),
    ('John', 'Smith', 'john.smith@example.org', '1975-03-10', 'British', 'active'),
    ('Maria', 'Garcia', 'maria.garcia@example.org', '1990-11-05', 'Spanish', 'onboard'),
    ('Hans', 'Mueller', 'hans.mueller@example.org', '1988-07-18', 'German', 'active');

-- РОЛИ
INSERT INTO role(code, title, min_cert_required)
VALUES 
    ('CAPT', 'Captain', true),
    ('ENG', 'Engineer', true),
    ('SCI', 'Scientist', false),
    ('NAV', 'Navigator', true),
    ('DECK', 'Deck Officer', true);

-- НАЗНАЧЕНИЯ ЭКИПАЖА
INSERT INTO crew_assignment(expedition_id, crew_id, role_id, assigned_from, is_backup)
VALUES 
    (1, 1, 1, '2026-01-05', false),  -- Ivan Petrov as Captain
    (1, 2, 3, '2026-01-06', false),  -- Anna Sidorova as Scientist
    (1, 3, 2, '2026-01-05', false),  -- John Smith as Engineer
    (2, 1, 1, '2026-03-01', false),  -- Ivan Petrov as Captain for second expedition
    (2, 4, 3, '2026-03-01', false);  -- Maria Garcia as Scientist

-- СЕРТИФИКАТЫ
INSERT INTO certification(name, issuer, valid_from, valid_to)
VALUES 
    ('Master Mariner', 'Maritime Authority', '2018-01-01', '2028-01-01'),
    ('STCW Basic Safety', 'Maritime Authority', '2019-06-01', '2029-06-01'),
    ('Chief Engineer License', 'Maritime Authority', '2015-03-15', '2025-03-15'),
    ('GMDSS Operator', 'Maritime Authority', '2020-01-01', '2030-01-01');

-- СЕРТИФИКАТЫ ЭКИПАЖА
INSERT INTO crew_certification(crew_id, certification_id, certificate_number, issued_date, expiry_date)
VALUES 
    (1, 1, 'MMM-0001', '2018-02-01', '2028-02-01'),  -- Ivan has Master Mariner
    (1, 2, 'STCW-100', '2019-06-05', '2029-06-05'),  -- Ivan has STCW
    (2, 2, 'STCW-101', '2020-01-10', '2030-01-10'),  -- Anna has STCW
    (3, 3, 'CEL-0500', '2015-04-01', '2025-04-01'),  -- John has Chief Engineer License
    (3, 2, 'STCW-102', '2019-07-01', '2029-07-01');  -- John has STCW

-- ОБОРУДОВАНИЕ
INSERT INTO equipment(serial_number, name, category, condition)
VALUES 
    ('SN-1000', 'CTD Profiler', 'sensor', 'good'),
    ('SN-2000', 'Davit Crane', 'deck', 'good'),
    ('SN-3000', 'Water Sampler', 'laboratory', 'good'),
    ('SN-4000', 'ROV System', 'research', 'needs_service'),
    ('SN-5000', 'Winch System', 'deck', 'good');

-- ОБОРУДОВАНИЕ В ЭКСПЕДИЦИЯХ
INSERT INTO expedition_equipment(expedition_id, equipment_id, attached_stage, qty)
VALUES 
    (1, 1, 'research', 1),
    (1, 3, 'research', 2),
    (1, 2, 'transit', 1),
    (2, 4, 'research', 1);

-- СЕНСОРЫ
INSERT INTO sensor(equipment_id, name, sensor_type, unit, installed_on_vessel, installed_at)
VALUES 
    (1, 'CTD-01', 'CTD', 'psu,degC', 1, now()),
    (1, 'Depth Sensor', 'depth', 'meters', 1, now()),
    (NULL, 'Temperature Sensor', 'temperature', 'degC', 3, now()),
    (NULL, 'Oil Concentration Sensor', 'oil_concentration', 'ppm', 1, now());

-- ЗАДАЧИ ЭКСПЕДИЦИИ
INSERT INTO mission_task(expedition_id, title, description, responsible_crew_id, planned_start, planned_end, status)
VALUES 
    (1, 'Initial Setup', 'Prepare equipment and crew for expedition', 1, '2026-01-10 08:00:00+00', '2026-01-12 18:00:00+00', 'pending'),
    (1, 'Data Collection', 'Collect oceanographic data', 2, '2026-01-15 06:00:00+00', '2026-02-05 20:00:00+00', 'pending'),
    (1, 'Equipment Maintenance', 'Regular maintenance check', 3, '2026-01-20 10:00:00+00', '2026-01-21 16:00:00+00', 'pending'),
    (1, 'Final Report', 'Compile expedition report', 1, '2026-02-08 09:00:00+00', '2026-02-10 17:00:00+00', 'pending');

-- Подзадача
INSERT INTO mission_task(expedition_id, parent_task_id, title, description, responsible_crew_id, planned_start, planned_end, status)
VALUES 
    (1, 2, 'CTD Profiling', 'Conduct CTD profiling at designated stations', 2, '2026-01-15 08:00:00+00', '2026-01-25 18:00:00+00', 'pending');

-- РАЗРЕШЕНИЯ
INSERT INTO permit(expedition_id, permit_type, issuing_authority, valid_from, valid_to, document_ref)
VALUES 
    (1, 'Research Permit', 'Antarctic Authority', '2026-01-01', '2026-12-31', 'ANT-2026-001'),
    (1, 'Environmental Clearance', 'Environmental Agency', '2025-12-15', '2026-06-30', 'ENV-CLEAR-2025-089'),
    (2, 'Arctic Research Permit', 'Arctic Council', '2026-03-01', '2026-05-31', 'ARC-2026-042');

-- ИНЦИДЕНТЫ
INSERT INTO incident(expedition_id, reported_by_crew_id, severity, category, description, reported_at)
VALUES 
    (1, 3, 'low', 'equipment', 'Minor issue with winch system', '2026-01-18 14:30:00+00'),
    (1, 2, 'medium', 'weather', 'Strong winds delayed operations', '2026-01-22 09:15:00+00');

-- ЗАПАСЫ
INSERT INTO inventory_item(expedition_id, name, unit, quantity_onboard)
VALUES 
    (1, 'Fuel', 'liters', 5000),
    (1, 'Fresh Water', 'liters', 2000),
    (1, 'Food Supplies', 'kg', 1500),
    (2, 'Fuel', 'liters', 8000),
    (2, 'Fresh Water', 'liters', 3500);

-- ТРАНЗАКЦИИ ИНВЕНТАРЯ
INSERT INTO inventory_transaction(item_id, txn_type, qty, performed_by, notes)
VALUES 
    (1, 'load', 5000, 1, 'Initial fuel loading'),
    (2, 'load', 2000, 1, 'Initial water loading'),
    (3, 'load', 1500, 1, 'Food supplies loaded'),
    (4, 'load', 8000, 1, 'Initial fuel loading for expedition 2'),
    (5, 'load', 3500, 1, 'Initial water loading for expedition 2');

-- ЭКОЛОГИЧЕСКИЕ ПРАВИЛА
INSERT INTO environmental_rule(name, parameter, threshold_value, threshold_operator, active)
VALUES 
    ('Max Oil Conc', 'oil_concentration', 0.05, '<=', true),
    ('Min Temperature', 'temperature', -2.0, '>=', true),
    ('Max Depth', 'depth', 6000, '<=', true);

-- ДОКУМЕНТЫ
INSERT INTO document(expedition_id, doc_type, title, version, uploaded_by, stored_at)
VALUES 
    (1, 'report', 'Expedition Plan', '1.0', 1, '/docs/exp-001-plan.pdf'),
    (1, 'safety', 'Safety Protocol', '2.1', 1, '/docs/exp-001-safety.pdf'),
    (2, 'report', 'Research Proposal', '1.0', 1, '/docs/exp-002-proposal.pdf');

-- НАБЛЮДЕНИЯ СЕНСОРОВ (несколько примеров)
INSERT INTO sensor_observation(sensor_id, expedition_id, observed_at, value_num, qc_status)
VALUES 
    (1, 1, '2026-01-15 10:00:00+00', 35.2, 'ok'),
    (1, 1, '2026-01-15 11:00:00+00', 35.1, 'ok'),
    (2, 1, '2026-01-15 10:00:00+00', 1250.5, 'ok'),
    (3, 1, '2026-01-15 10:00:00+00', 4.5, 'ok'),
    (4, 1, '2026-01-15 10:00:00+00', 0.02, 'ok');  -- Oil concentration below threshold

