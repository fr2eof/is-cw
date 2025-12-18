package se.ifmo.ru.cw.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import se.ifmo.ru.cw.dto.ApiResponse;
import se.ifmo.ru.cw.dto.SensorObservationDto;
import se.ifmo.ru.cw.service.SensorObservationService;

import java.util.List;

@RestController
@RequestMapping("/api/sensor-observations")
@RequiredArgsConstructor
public class SensorObservationController {
    private final SensorObservationService sensorObservationService;

    @GetMapping("/sensors/{sensorId}")
    public ResponseEntity<ApiResponse<List<SensorObservationDto>>> getObservationsBySensor(@PathVariable Integer sensorId) {
        List<SensorObservationDto> observations = sensorObservationService.getObservationsBySensor(sensorId);
        return ResponseEntity.ok(ApiResponse.success(observations));
    }

    @GetMapping("/expeditions/{expeditionId}")
    public ResponseEntity<ApiResponse<List<SensorObservationDto>>> getObservationsByExpedition(@PathVariable Integer expeditionId) {
        List<SensorObservationDto> observations = sensorObservationService.getObservationsByExpedition(expeditionId);
        return ResponseEntity.ok(ApiResponse.success(observations));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<SensorObservationDto>> createObservation(@RequestBody SensorObservationDto dto) {
        SensorObservationDto created = sensorObservationService.createObservation(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success("Observation created", created));
    }
}

