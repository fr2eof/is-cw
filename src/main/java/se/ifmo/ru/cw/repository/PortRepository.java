package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.Port;

import java.util.Optional;

@Repository
public interface PortRepository extends JpaRepository<Port, Integer> {
    Optional<Port> findByUnlocode(String unlocode);
}

