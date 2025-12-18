package se.ifmo.ru.cw.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import se.ifmo.ru.cw.dto.ApiResponse;
import se.ifmo.ru.cw.dto.VesselDto;
import se.ifmo.ru.cw.entity.Vessel;
import se.ifmo.ru.cw.service.VesselService;

import java.util.List;

@RestController
@RequestMapping("/api/vessels")
@RequiredArgsConstructor
public class VesselController {
    private final VesselService vesselService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<VesselDto>>> getAllVessels() {
        List<VesselDto> vessels = vesselService.getAllVessels();
        return ResponseEntity.ok(ApiResponse.success(vessels));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<VesselDto>> getVesselById(@PathVariable Integer id) {
        VesselDto vessel = vesselService.getVesselById(id);
        return ResponseEntity.ok(ApiResponse.success(vessel));
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<ApiResponse<List<VesselDto>>> getVesselsByStatus(@PathVariable Vessel.VesselStatus status) {
        List<VesselDto> vessels = vesselService.getVesselsByStatus(status);
        return ResponseEntity.ok(ApiResponse.success(vessels));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<VesselDto>> createVessel(@RequestBody VesselDto dto) {
        VesselDto created = vesselService.createVessel(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success("Vessel created", created));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<VesselDto>> updateVessel(
        @PathVariable Integer id,
        @RequestBody VesselDto dto
    ) {
        VesselDto updated = vesselService.updateVessel(id, dto);
        return ResponseEntity.ok(ApiResponse.success("Vessel updated", updated));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteVessel(@PathVariable Integer id) {
        vesselService.deleteVessel(id);
        return ResponseEntity.ok(ApiResponse.success("Vessel deleted", null));
    }
}

