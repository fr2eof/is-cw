package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.Certification;

@Repository
public interface CertificationRepository extends JpaRepository<Certification, Integer> {
}

