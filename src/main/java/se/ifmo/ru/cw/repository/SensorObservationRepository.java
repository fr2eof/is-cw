package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.SensorObservation;

import java.time.Instant;
import java.util.List;

@Repository
public interface SensorObservationRepository extends JpaRepository<SensorObservation, Integer> {
    List<SensorObservation> findBySensorId(Integer sensorId);
    List<SensorObservation> findByExpeditionId(Integer expeditionId);
    List<SensorObservation> findByQcStatus(SensorObservation.QcStatus qcStatus);
    
    @Query("SELECT so FROM SensorObservation so WHERE so.sensor.id = :sensorId " +
           "ORDER BY so.observedAt DESC")
    List<SensorObservation> findLatestBySensorId(@Param("sensorId") Integer sensorId);
    
    @Query("SELECT so FROM SensorObservation so WHERE so.sensor.id = :sensorId " +
           "AND so.observedAt BETWEEN :startTime AND :endTime ORDER BY so.observedAt")
    List<SensorObservation> findBySensorIdAndTimeRange(
        @Param("sensorId") Integer sensorId,
        @Param("startTime") Instant startTime,
        @Param("endTime") Instant endTime
    );
}

