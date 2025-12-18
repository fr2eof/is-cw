package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.InventoryItem;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface InventoryItemRepository extends JpaRepository<InventoryItem, Integer> {
    List<InventoryItem> findByExpeditionId(Integer expeditionId);
    
    @Query("SELECT ii FROM InventoryItem ii WHERE ii.quantityOnboard > 0")
    List<InventoryItem> findItemsWithStock();
    
    @Query("SELECT ii FROM InventoryItem ii WHERE ii.quantityOnboard < :threshold")
    List<InventoryItem> findLowStockItems(@Param("threshold") BigDecimal threshold);
}

