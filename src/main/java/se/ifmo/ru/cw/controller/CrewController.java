package se.ifmo.ru.cw.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import se.ifmo.ru.cw.dto.ApiResponse;
import se.ifmo.ru.cw.dto.CrewMemberDto;
import se.ifmo.ru.cw.service.CrewService;

import java.util.List;

@RestController
@RequestMapping("/api/crew")
@RequiredArgsConstructor
public class CrewController {
    private final CrewService crewService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<CrewMemberDto>>> getAllCrewMembers() {
        List<CrewMemberDto> crew = crewService.getAllCrewMembers();
        return ResponseEntity.ok(ApiResponse.success(crew));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<CrewMemberDto>> getCrewMemberById(@PathVariable Integer id) {
        CrewMemberDto crewMember = crewService.getCrewMemberById(id);
        return ResponseEntity.ok(ApiResponse.success(crewMember));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<CrewMemberDto>> createCrewMember(@RequestBody CrewMemberDto dto) {
        CrewMemberDto created = crewService.createCrewMember(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success("Crew member created", created));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<CrewMemberDto>> updateCrewMember(
        @PathVariable Integer id,
        @RequestBody CrewMemberDto dto
    ) {
        CrewMemberDto updated = crewService.updateCrewMember(id, dto);
        return ResponseEntity.ok(ApiResponse.success("Crew member updated", updated));
    }

    @PostMapping("/expeditions/{expeditionId}/assign/{crewId}")
    public ResponseEntity<ApiResponse<Void>> assignCrewToExpedition(
        @PathVariable Integer expeditionId,
        @PathVariable Integer crewId
    ) {
        crewService.assignCrewToExpedition(expeditionId, crewId);
        return ResponseEntity.ok(ApiResponse.success("Crew member assigned to expedition", null));
    }

    @DeleteMapping("/expeditions/{expeditionId}/remove/{crewId}")
    public ResponseEntity<ApiResponse<Void>> removeCrewFromExpedition(
        @PathVariable Integer expeditionId,
        @PathVariable Integer crewId
    ) {
        crewService.removeCrewFromExpedition(expeditionId, crewId);
        return ResponseEntity.ok(ApiResponse.success("Crew member removed from expedition", null));
    }

    @GetMapping("/expeditions/{expeditionId}")
    public ResponseEntity<ApiResponse<List<CrewMemberDto>>> getCrewForExpedition(@PathVariable Integer expeditionId) {
        List<CrewMemberDto> crew = crewService.getCrewForExpedition(expeditionId);
        return ResponseEntity.ok(ApiResponse.success(crew));
    }
}

