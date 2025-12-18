package se.ifmo.ru.cw.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import se.ifmo.ru.cw.dto.ApiResponse;
import se.ifmo.ru.cw.dto.InventoryItemDto;
import se.ifmo.ru.cw.entity.InventoryTransaction;
import se.ifmo.ru.cw.service.InventoryService;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/inventory")
@RequiredArgsConstructor
public class InventoryController {
    private final InventoryService inventoryService;

    @GetMapping("/expeditions/{expeditionId}")
    public ResponseEntity<ApiResponse<List<InventoryItemDto>>> getInventoryByExpedition(@PathVariable Integer expeditionId) {
        List<InventoryItemDto> items = inventoryService.getInventoryByExpedition(expeditionId);
        return ResponseEntity.ok(ApiResponse.success(items));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<InventoryItemDto>> createInventoryItem(@RequestBody InventoryItemDto dto) {
        InventoryItemDto created = inventoryService.createInventoryItem(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success("Inventory item created", created));
    }

    @PostMapping("/{itemId}/adjust")
    public ResponseEntity<ApiResponse<Void>> adjustInventory(
        @PathVariable Integer itemId,
        @RequestParam InventoryTransaction.TransactionType type,
        @RequestParam BigDecimal quantity,
        @RequestParam(required = false) String notes
    ) {
        inventoryService.adjustInventory(itemId, type, quantity, notes);
        return ResponseEntity.ok(ApiResponse.success("Inventory adjusted", null));
    }
}

