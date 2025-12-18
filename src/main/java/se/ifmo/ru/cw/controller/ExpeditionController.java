package se.ifmo.ru.cw.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import se.ifmo.ru.cw.dto.ApiResponse;
import se.ifmo.ru.cw.dto.ExpeditionDto;
import se.ifmo.ru.cw.service.ExpeditionService;

import java.util.List;

@RestController
@RequestMapping("/api/expeditions")
@RequiredArgsConstructor
public class ExpeditionController {
    private final ExpeditionService expeditionService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<ExpeditionDto>>> getAllExpeditions() {
        List<ExpeditionDto> expeditions = expeditionService.getAllExpeditions();
        return ResponseEntity.ok(ApiResponse.success(expeditions));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ExpeditionDto>> getExpeditionById(@PathVariable Integer id) {
        ExpeditionDto expedition = expeditionService.getExpeditionById(id);
        return ResponseEntity.ok(ApiResponse.success(expedition));
    }

    @GetMapping("/code/{code}")
    public ResponseEntity<ApiResponse<ExpeditionDto>> getExpeditionByCode(@PathVariable String code) {
        ExpeditionDto expedition = expeditionService.getExpeditionByCode(code);
        return ResponseEntity.ok(ApiResponse.success(expedition));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ExpeditionDto>> createExpedition(@RequestBody ExpeditionDto dto) {
        ExpeditionDto created = expeditionService.createExpedition(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success("Expedition created", created));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<ExpeditionDto>> updateExpedition(
        @PathVariable Integer id,
        @RequestBody ExpeditionDto dto
    ) {
        ExpeditionDto updated = expeditionService.updateExpedition(id, dto);
        return ResponseEntity.ok(ApiResponse.success("Expedition updated", updated));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteExpedition(@PathVariable Integer id) {
        expeditionService.deleteExpedition(id);
        return ResponseEntity.ok(ApiResponse.success("Expedition deleted", null));
    }

    @PostMapping("/{id}/start")
    public ResponseEntity<ApiResponse<ExpeditionDto>> startExpedition(@PathVariable Integer id) {
        ExpeditionDto started = expeditionService.startExpedition(id);
        return ResponseEntity.ok(ApiResponse.success("Expedition started", started));
    }

    @PostMapping("/{id}/complete")
    public ResponseEntity<ApiResponse<ExpeditionDto>> completeExpedition(@PathVariable Integer id) {
        ExpeditionDto completed = expeditionService.completeExpedition(id);
        return ResponseEntity.ok(ApiResponse.success("Expedition completed", completed));
    }
}

