package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.Expedition;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface ExpeditionRepository extends JpaRepository<Expedition, Integer> {
    Optional<Expedition> findByCode(String code);
    List<Expedition> findByStatus(Expedition.ExpeditionStatus status);
    List<Expedition> findByVesselId(Integer vesselId);
    
    @Query("SELECT e FROM Expedition e WHERE e.plannedStart >= :startDate AND e.plannedEnd <= :endDate")
    List<Expedition> findByDateRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
}

