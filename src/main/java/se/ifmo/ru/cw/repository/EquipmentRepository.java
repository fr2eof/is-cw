package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.Equipment;

import java.util.List;
import java.util.Optional;

@Repository
public interface EquipmentRepository extends JpaRepository<Equipment, Integer> {
    Optional<Equipment> findBySerialNumber(String serialNumber);
    List<Equipment> findByCondition(Equipment.EquipmentCondition condition);
    List<Equipment> findByCategory(String category);
}

