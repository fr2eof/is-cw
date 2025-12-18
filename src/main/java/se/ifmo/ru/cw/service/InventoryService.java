package se.ifmo.ru.cw.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import se.ifmo.ru.cw.dto.InventoryItemDto;
import se.ifmo.ru.cw.entity.Expedition;
import se.ifmo.ru.cw.entity.InventoryItem;
import se.ifmo.ru.cw.entity.InventoryTransaction;
import se.ifmo.ru.cw.exception.ResourceNotFoundException;
import se.ifmo.ru.cw.repository.ExpeditionRepository;
import se.ifmo.ru.cw.repository.InventoryItemRepository;
import se.ifmo.ru.cw.repository.InventoryTransactionRepository;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class InventoryService {
    private final InventoryItemRepository inventoryItemRepository;
    private final InventoryTransactionRepository inventoryTransactionRepository;
    private final ExpeditionRepository expeditionRepository;

    @Transactional(readOnly = true)
    public List<InventoryItemDto> getInventoryByExpedition(Integer expeditionId) {
        return inventoryItemRepository.findByExpeditionId(expeditionId).stream()
            .map(this::toDto)
            .collect(Collectors.toList());
    }

    @Transactional
    public InventoryItemDto createInventoryItem(InventoryItemDto dto) {
        Expedition expedition = expeditionRepository.findById(dto.getExpeditionId())
            .orElseThrow(() -> new ResourceNotFoundException("Expedition not found with id: " + dto.getExpeditionId()));
        
        InventoryItem item = InventoryItem.builder()
            .expedition(expedition)
            .name(dto.getName())
            .unit(dto.getUnit())
            .quantityOnboard(dto.getQuantityOnboard() != null ? dto.getQuantityOnboard() : BigDecimal.ZERO)
            .build();
        
        InventoryItem saved = inventoryItemRepository.save(item);
        return toDto(saved);
    }

    @Transactional
    public void adjustInventory(Integer itemId, InventoryTransaction.TransactionType type, BigDecimal quantity, String notes) {
        InventoryItem item = inventoryItemRepository.findById(itemId)
            .orElseThrow(() -> new ResourceNotFoundException("Inventory item not found with id: " + itemId));
        
        InventoryTransaction transaction = InventoryTransaction.builder()
            .item(item)
            .txnType(type)
            .qty(quantity)
            .notes(notes)
            .build();
        
        // Триггер в БД автоматически обновит quantity_onboard
        inventoryTransactionRepository.save(transaction);
    }

    private InventoryItemDto toDto(InventoryItem item) {
        return InventoryItemDto.builder()
            .id(item.getId())
            .expeditionId(item.getExpedition() != null ? item.getExpedition().getId() : null)
            .name(item.getName())
            .unit(item.getUnit())
            .quantityOnboard(item.getQuantityOnboard())
            .build();
    }
}

