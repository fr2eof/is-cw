package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.CrewAssignment;
import se.ifmo.ru.cw.entity.CrewAssignmentId;

import java.util.List;

@Repository
public interface CrewAssignmentRepository extends JpaRepository<CrewAssignment, CrewAssignmentId> {
    @Query("SELECT ca FROM CrewAssignment ca WHERE ca.expedition.id = :expeditionId")
    List<CrewAssignment> findByExpeditionId(@Param("expeditionId") Integer expeditionId);
    
    @Query("SELECT ca FROM CrewAssignment ca WHERE ca.crew.id = :crewId")
    List<CrewAssignment> findByCrewId(@Param("crewId") Integer crewId);
    
    @Query("SELECT COUNT(ca) > 0 FROM CrewAssignment ca WHERE ca.expedition.id = :expeditionId AND ca.crew.id = :crewId")
    boolean existsByExpeditionIdAndCrewId(@Param("expeditionId") Integer expeditionId, @Param("crewId") Integer crewId);
}

