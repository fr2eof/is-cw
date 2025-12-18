package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.ExpeditionEquipment;
import se.ifmo.ru.cw.entity.ExpeditionEquipmentId;

import java.util.List;

@Repository
public interface ExpeditionEquipmentRepository extends JpaRepository<ExpeditionEquipment, ExpeditionEquipmentId> {
    List<ExpeditionEquipment> findByExpeditionId(Integer expeditionId);
    List<ExpeditionEquipment> findByEquipmentId(Integer equipmentId);
}

