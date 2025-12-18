package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.Incident;

import java.util.List;

@Repository
public interface IncidentRepository extends JpaRepository<Incident, Integer> {
    List<Incident> findByExpeditionId(Integer expeditionId);
    List<Incident> findBySeverity(Incident.IncidentSeverity severity);
    List<Incident> findByExpeditionIdAndSeverity(Integer expeditionId, Incident.IncidentSeverity severity);
    
    @Query("SELECT i FROM Incident i WHERE i.expedition.id = :expeditionId AND i.resolvedAt IS NULL")
    List<Incident> findUnresolvedByExpeditionId(@Param("expeditionId") Integer expeditionId);
}

