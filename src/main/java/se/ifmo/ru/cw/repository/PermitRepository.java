package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.Permit;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface PermitRepository extends JpaRepository<Permit, Integer> {
    List<Permit> findByExpeditionId(Integer expeditionId);
    
    @Query("SELECT p FROM Permit p WHERE p.expedition.id = :expeditionId " +
           "AND p.validFrom <= :date AND (p.validTo IS NULL OR p.validTo >= :date)")
    List<Permit> findValidPermitsForExpedition(
        @Param("expeditionId") Integer expeditionId,
        @Param("date") LocalDate date
    );
}

