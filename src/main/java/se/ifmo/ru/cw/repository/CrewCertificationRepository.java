package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.CrewCertification;
import se.ifmo.ru.cw.entity.CrewCertificationId;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface CrewCertificationRepository extends JpaRepository<CrewCertification, CrewCertificationId> {
    List<CrewCertification> findByCrewId(Integer crewId);
    List<CrewCertification> findByCertificationId(Integer certificationId);
    
    @Query("SELECT cc FROM CrewCertification cc WHERE cc.expiryDate IS NOT NULL AND cc.expiryDate < :date")
    List<CrewCertification> findExpiredCertifications(@Param("date") LocalDate date);
}

