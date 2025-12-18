package se.ifmo.ru.cw.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import se.ifmo.ru.cw.dto.ExpeditionDto;
import se.ifmo.ru.cw.entity.Expedition;
import se.ifmo.ru.cw.entity.Vessel;
import se.ifmo.ru.cw.exception.ResourceNotFoundException;
import se.ifmo.ru.cw.repository.ExpeditionRepository;
import se.ifmo.ru.cw.repository.VesselRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ExpeditionService {
    private final ExpeditionRepository expeditionRepository;
    private final VesselRepository vesselRepository;

    @Transactional(readOnly = true)
    public List<ExpeditionDto> getAllExpeditions() {
        return expeditionRepository.findAll().stream()
            .map(this::toDto)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public ExpeditionDto getExpeditionById(Integer id) {
        Expedition expedition = expeditionRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Expedition not found with id: " + id));
        return toDto(expedition);
    }

    @Transactional(readOnly = true)
    public ExpeditionDto getExpeditionByCode(String code) {
        Expedition expedition = expeditionRepository.findByCode(code)
            .orElseThrow(() -> new ResourceNotFoundException("Expedition not found with code: " + code));
        return toDto(expedition);
    }

    @Transactional
    public ExpeditionDto createExpedition(ExpeditionDto dto) {
        Expedition expedition = toEntity(dto);
        if (dto.getVesselId() != null) {
            Vessel vessel = vesselRepository.findById(dto.getVesselId())
                .orElseThrow(() -> new ResourceNotFoundException("Vessel not found with id: " + dto.getVesselId()));
            expedition.setVessel(vessel);
        }
        Expedition saved = expeditionRepository.save(expedition);
        return toDto(saved);
    }

    @Transactional
    public ExpeditionDto updateExpedition(Integer id, ExpeditionDto dto) {
        Expedition expedition = expeditionRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Expedition not found with id: " + id));
        
        expedition.setCode(dto.getCode());
        expedition.setName(dto.getName());
        expedition.setDescription(dto.getDescription());
        expedition.setPlannedStart(dto.getPlannedStart());
        expedition.setPlannedEnd(dto.getPlannedEnd());
        expedition.setStatus(dto.getStatus());
        
        if (dto.getVesselId() != null) {
            Vessel vessel = vesselRepository.findById(dto.getVesselId())
                .orElseThrow(() -> new ResourceNotFoundException("Vessel not found with id: " + dto.getVesselId()));
            expedition.setVessel(vessel);
        }
        
        Expedition saved = expeditionRepository.save(expedition);
        return toDto(saved);
    }

    @Transactional
    public void deleteExpedition(Integer id) {
        if (!expeditionRepository.existsById(id)) {
            throw new ResourceNotFoundException("Expedition not found with id: " + id);
        }
        expeditionRepository.deleteById(id);
    }

    @Transactional
    public ExpeditionDto startExpedition(Integer id) {
        Expedition expedition = expeditionRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Expedition not found with id: " + id));
        
        if (expedition.getStatus() != Expedition.ExpeditionStatus.planned && 
            expedition.getStatus() != Expedition.ExpeditionStatus.ready) {
            throw new IllegalStateException("Expedition cannot be started. Current status: " + expedition.getStatus());
        }
        
        expedition.setActualStart(java.time.Instant.now());
        expedition.setStatus(Expedition.ExpeditionStatus.active);
        Expedition saved = expeditionRepository.save(expedition);
        return toDto(saved);
    }

    @Transactional
    public ExpeditionDto completeExpedition(Integer id) {
        Expedition expedition = expeditionRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Expedition not found with id: " + id));
        
        if (expedition.getStatus() != Expedition.ExpeditionStatus.active) {
            throw new IllegalStateException("Expedition is not active. Current status: " + expedition.getStatus());
        }
        
        expedition.setActualEnd(java.time.Instant.now());
        expedition.setStatus(Expedition.ExpeditionStatus.completed);
        Expedition saved = expeditionRepository.save(expedition);
        return toDto(saved);
    }

    private ExpeditionDto toDto(Expedition expedition) {
        return ExpeditionDto.builder()
            .id(expedition.getId())
            .code(expedition.getCode())
            .name(expedition.getName())
            .description(expedition.getDescription())
            .vesselId(expedition.getVessel() != null ? expedition.getVessel().getId() : null)
            .vesselName(expedition.getVessel() != null ? expedition.getVessel().getName() : null)
            .managerUserId(expedition.getManagerUserId())
            .plannedStart(expedition.getPlannedStart())
            .plannedEnd(expedition.getPlannedEnd())
            .actualStart(expedition.getActualStart())
            .actualEnd(expedition.getActualEnd())
            .status(expedition.getStatus())
            .createdAt(expedition.getCreatedAt())
            .build();
    }

    private Expedition toEntity(ExpeditionDto dto) {
        return Expedition.builder()
            .code(dto.getCode())
            .name(dto.getName())
            .description(dto.getDescription())
            .managerUserId(dto.getManagerUserId())
            .plannedStart(dto.getPlannedStart())
            .plannedEnd(dto.getPlannedEnd())
            .status(dto.getStatus() != null ? dto.getStatus() : Expedition.ExpeditionStatus.planned)
            .build();
    }
}

