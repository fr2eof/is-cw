package se.ifmo.ru.cw.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import se.ifmo.ru.cw.dto.ApiResponse;
import se.ifmo.ru.cw.dto.MissionTaskDto;
import se.ifmo.ru.cw.service.MissionTaskService;

import java.util.List;

@RestController
@RequestMapping("/api/tasks")
@RequiredArgsConstructor
public class MissionTaskController {
    private final MissionTaskService missionTaskService;

    @GetMapping("/expeditions/{expeditionId}")
    public ResponseEntity<ApiResponse<List<MissionTaskDto>>> getTasksByExpedition(@PathVariable Integer expeditionId) {
        List<MissionTaskDto> tasks = missionTaskService.getTasksByExpedition(expeditionId);
        return ResponseEntity.ok(ApiResponse.success(tasks));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<MissionTaskDto>> getTaskById(@PathVariable Integer id) {
        MissionTaskDto task = missionTaskService.getTaskById(id);
        return ResponseEntity.ok(ApiResponse.success(task));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<MissionTaskDto>> createTask(@RequestBody MissionTaskDto dto) {
        MissionTaskDto created = missionTaskService.createTask(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success("Task created", created));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<MissionTaskDto>> updateTask(
        @PathVariable Integer id,
        @RequestBody MissionTaskDto dto
    ) {
        MissionTaskDto updated = missionTaskService.updateTask(id, dto);
        return ResponseEntity.ok(ApiResponse.success("Task updated", updated));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteTask(@PathVariable Integer id) {
        missionTaskService.deleteTask(id);
        return ResponseEntity.ok(ApiResponse.success("Task deleted", null));
    }
}

