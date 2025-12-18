package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.Vessel;

import java.util.List;
import java.util.Optional;

@Repository
public interface VesselRepository extends JpaRepository<Vessel, Integer> {
    Optional<Vessel> findByImoNumber(String imoNumber);
    List<Vessel> findByStatus(Vessel.VesselStatus status);
}

