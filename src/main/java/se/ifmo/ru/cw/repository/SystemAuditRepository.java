package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.SystemAudit;

import java.time.Instant;
import java.util.List;

@Repository
public interface SystemAuditRepository extends JpaRepository<SystemAudit, Integer> {
    @Query("SELECT sa FROM SystemAudit sa WHERE sa.objectType = :objectType " +
           "ORDER BY sa.eventTs DESC")
    List<SystemAudit> findByObjectType(@Param("objectType") String objectType);
    
    @Query("SELECT sa FROM SystemAudit sa WHERE sa.objectType = :objectType " +
           "AND sa.objectId = :objectId ORDER BY sa.eventTs DESC")
    List<SystemAudit> findByObjectTypeAndObjectId(
        @Param("objectType") String objectType,
        @Param("objectId") String objectId
    );
    
    @Query("SELECT sa FROM SystemAudit sa WHERE sa.eventTs BETWEEN :startTime AND :endTime " +
           "ORDER BY sa.eventTs DESC")
    List<SystemAudit> findByTimeRange(
        @Param("startTime") Instant startTime,
        @Param("endTime") Instant endTime
    );
}

