package se.ifmo.ru.cw.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import se.ifmo.ru.cw.dto.IncidentDto;
import se.ifmo.ru.cw.entity.CrewMember;
import se.ifmo.ru.cw.entity.Expedition;
import se.ifmo.ru.cw.entity.Incident;
import se.ifmo.ru.cw.exception.ResourceNotFoundException;
import se.ifmo.ru.cw.repository.CrewMemberRepository;
import se.ifmo.ru.cw.repository.ExpeditionRepository;
import se.ifmo.ru.cw.repository.IncidentRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class IncidentService {
    private final IncidentRepository incidentRepository;
    private final ExpeditionRepository expeditionRepository;
    private final CrewMemberRepository crewMemberRepository;

    @Transactional(readOnly = true)
    public List<IncidentDto> getIncidentsByExpedition(Integer expeditionId) {
        return incidentRepository.findByExpeditionId(expeditionId).stream()
            .map(this::toDto)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<IncidentDto> getUnresolvedIncidents(Integer expeditionId) {
        return incidentRepository.findUnresolvedByExpeditionId(expeditionId).stream()
            .map(this::toDto)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public IncidentDto getIncidentById(Integer id) {
        Incident incident = incidentRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Incident not found with id: " + id));
        return toDto(incident);
    }

    @Transactional
    public IncidentDto createIncident(IncidentDto dto) {
        Incident incident = Incident.builder()
            .severity(dto.getSeverity() != null ? dto.getSeverity() : Incident.IncidentSeverity.medium)
            .category(dto.getCategory())
            .description(dto.getDescription())
            .build();
        
        if (dto.getExpeditionId() != null) {
            Expedition expedition = expeditionRepository.findById(dto.getExpeditionId())
                .orElseThrow(() -> new ResourceNotFoundException("Expedition not found with id: " + dto.getExpeditionId()));
            incident.setExpedition(expedition);
        }
        
        if (dto.getReportedByCrewId() != null) {
            CrewMember crew = crewMemberRepository.findById(dto.getReportedByCrewId())
                .orElseThrow(() -> new ResourceNotFoundException("Crew member not found with id: " + dto.getReportedByCrewId()));
            incident.setReportedByCrew(crew);
        }
        
        Incident saved = incidentRepository.save(incident);
        return toDto(saved);
    }

    @Transactional
    public IncidentDto resolveIncident(Integer id) {
        Incident incident = incidentRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Incident not found with id: " + id));
        
        incident.setResolvedAt(java.time.Instant.now());
        Incident saved = incidentRepository.save(incident);
        return toDto(saved);
    }

    private IncidentDto toDto(Incident incident) {
        return IncidentDto.builder()
            .id(incident.getId())
            .expeditionId(incident.getExpedition() != null ? incident.getExpedition().getId() : null)
            .reportedAt(incident.getReportedAt())
            .reportedByCrewId(incident.getReportedByCrew() != null ? incident.getReportedByCrew().getId() : null)
            .reportedByCrewName(incident.getReportedByCrew() != null ? 
                incident.getReportedByCrew().getFirstName() + " " + incident.getReportedByCrew().getLastName() : null)
            .severity(incident.getSeverity())
            .category(incident.getCategory())
            .description(incident.getDescription())
            .resolvedAt(incident.getResolvedAt())
            .build();
    }
}

