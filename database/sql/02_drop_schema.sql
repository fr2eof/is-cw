-- =====================================================
-- Удаление схемы базы данных
-- ВНИМАНИЕ: Удаляет все таблицы и данные!
-- =====================================================

-- Удаление в обратном порядке (учитывая зависимости)
DROP TABLE IF EXISTS system_audit CASCADE;
DROP TABLE IF EXISTS document CASCADE;
DROP TABLE IF EXISTS inventory_transaction CASCADE;
DROP TABLE IF EXISTS inventory_item CASCADE;
DROP TABLE IF EXISTS incident CASCADE;
DROP TABLE IF EXISTS permit CASCADE;
DROP TABLE IF EXISTS sensor_observation CASCADE;
DROP TABLE IF EXISTS sensor CASCADE;
DROP TABLE IF EXISTS mission_task CASCADE;
DROP TABLE IF EXISTS expedition_equipment CASCADE;
DROP TABLE IF EXISTS equipment CASCADE;
DROP TABLE IF EXISTS crew_certification CASCADE;
DROP TABLE IF EXISTS certification CASCADE;
DROP TABLE IF EXISTS crew_assignment CASCADE;
DROP TABLE IF EXISTS role CASCADE;
DROP TABLE IF EXISTS crew_member CASCADE;
DROP TABLE IF EXISTS port_call CASCADE;
DROP TABLE IF EXISTS port CASCADE;
DROP TABLE IF EXISTS expedition CASCADE;
DROP TABLE IF EXISTS vessel CASCADE;
DROP TABLE IF EXISTS environmental_rule CASCADE;

-- Удаление функций (если они были созданы)
DROP FUNCTION IF EXISTS fn_inventory_apply_txn() CASCADE;
DROP FUNCTION IF EXISTS fn_check_assignment_overlap() CASCADE;
DROP FUNCTION IF EXISTS fn_sensor_qc_and_env_check() CASCADE;
DROP FUNCTION IF EXISTS assign_crew_to_expedition(BIGINT, BIGINT, SMALLINT, DATE, DATE, BOOLEAN) CASCADE;
DROP FUNCTION IF EXISTS adjust_inventory(BIGINT, TEXT, NUMERIC, BIGINT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS recommend_crew_for_task(BIGINT, INT) CASCADE;

