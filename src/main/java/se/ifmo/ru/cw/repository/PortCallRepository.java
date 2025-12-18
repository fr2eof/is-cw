package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.PortCall;

import java.util.List;

@Repository
public interface PortCallRepository extends JpaRepository<PortCall, Integer> {
    List<PortCall> findByExpeditionId(Integer expeditionId);
    List<PortCall> findByPortId(Integer portId);
}

