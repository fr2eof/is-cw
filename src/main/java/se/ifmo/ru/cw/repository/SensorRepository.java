package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.Sensor;

import java.util.List;

@Repository
public interface SensorRepository extends JpaRepository<Sensor, Integer> {
    List<Sensor> findBySensorType(String sensorType);
    List<Sensor> findByInstalledOnVesselId(Integer vesselId);
    List<Sensor> findByRuleId(Integer ruleId);
}

