package se.ifmo.ru.cw.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import se.ifmo.ru.cw.dto.ApiResponse;
import se.ifmo.ru.cw.dto.IncidentDto;
import se.ifmo.ru.cw.service.IncidentService;

import java.util.List;

@RestController
@RequestMapping("/api/incidents")
@RequiredArgsConstructor
public class IncidentController {
    private final IncidentService incidentService;

    @GetMapping("/expeditions/{expeditionId}")
    public ResponseEntity<ApiResponse<List<IncidentDto>>> getIncidentsByExpedition(@PathVariable Integer expeditionId) {
        List<IncidentDto> incidents = incidentService.getIncidentsByExpedition(expeditionId);
        return ResponseEntity.ok(ApiResponse.success(incidents));
    }

    @GetMapping("/expeditions/{expeditionId}/unresolved")
    public ResponseEntity<ApiResponse<List<IncidentDto>>> getUnresolvedIncidents(@PathVariable Integer expeditionId) {
        List<IncidentDto> incidents = incidentService.getUnresolvedIncidents(expeditionId);
        return ResponseEntity.ok(ApiResponse.success(incidents));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<IncidentDto>> getIncidentById(@PathVariable Integer id) {
        IncidentDto incident = incidentService.getIncidentById(id);
        return ResponseEntity.ok(ApiResponse.success(incident));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<IncidentDto>> createIncident(@RequestBody IncidentDto dto) {
        IncidentDto created = incidentService.createIncident(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success("Incident created", created));
    }

    @PostMapping("/{id}/resolve")
    public ResponseEntity<ApiResponse<IncidentDto>> resolveIncident(@PathVariable Integer id) {
        IncidentDto resolved = incidentService.resolveIncident(id);
        return ResponseEntity.ok(ApiResponse.success("Incident resolved", resolved));
    }
}

