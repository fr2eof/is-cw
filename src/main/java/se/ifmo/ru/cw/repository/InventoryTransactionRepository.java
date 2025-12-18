package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.InventoryTransaction;

import java.time.Instant;
import java.util.List;

@Repository
public interface InventoryTransactionRepository extends JpaRepository<InventoryTransaction, Integer> {
    List<InventoryTransaction> findByItemId(Integer itemId);
    
    @Query("SELECT it FROM InventoryTransaction it WHERE it.item.id = :itemId " +
           "ORDER BY it.txnTs DESC")
    List<InventoryTransaction> findHistoryByItemId(@Param("itemId") Integer itemId);
    
    @Query("SELECT it FROM InventoryTransaction it WHERE it.item.expedition.id = :expeditionId " +
           "AND it.txnTs BETWEEN :startTime AND :endTime")
    List<InventoryTransaction> findByExpeditionIdAndTimeRange(
        @Param("expeditionId") Integer expeditionId,
        @Param("startTime") Instant startTime,
        @Param("endTime") Instant endTime
    );
}

