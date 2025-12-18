package se.ifmo.ru.cw.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import se.ifmo.ru.cw.dto.VesselDto;
import se.ifmo.ru.cw.entity.Vessel;
import se.ifmo.ru.cw.exception.ResourceNotFoundException;
import se.ifmo.ru.cw.repository.VesselRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class VesselService {
    private final VesselRepository vesselRepository;

    @Transactional(readOnly = true)
    public List<VesselDto> getAllVessels() {
        return vesselRepository.findAll().stream()
            .map(this::toDto)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public VesselDto getVesselById(Integer id) {
        Vessel vessel = vesselRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Vessel not found with id: " + id));
        return toDto(vessel);
    }

    @Transactional(readOnly = true)
    public List<VesselDto> getVesselsByStatus(Vessel.VesselStatus status) {
        return vesselRepository.findByStatus(status).stream()
            .map(this::toDto)
            .collect(Collectors.toList());
    }

    @Transactional
    public VesselDto createVessel(VesselDto dto) {
        Vessel vessel = toEntity(dto);
        Vessel saved = vesselRepository.save(vessel);
        return toDto(saved);
    }

    @Transactional
    public VesselDto updateVessel(Integer id, VesselDto dto) {
        Vessel vessel = vesselRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Vessel not found with id: " + id));
        
        vessel.setImoNumber(dto.getImoNumber());
        vessel.setName(dto.getName());
        vessel.setCallSign(dto.getCallSign());
        vessel.setCapacityTons(dto.getCapacityTons());
        vessel.setBuiltYear(dto.getBuiltYear());
        vessel.setStatus(dto.getStatus());
        
        Vessel saved = vesselRepository.save(vessel);
        return toDto(saved);
    }

    @Transactional
    public void deleteVessel(Integer id) {
        if (!vesselRepository.existsById(id)) {
            throw new ResourceNotFoundException("Vessel not found with id: " + id);
        }
        vesselRepository.deleteById(id);
    }

    private VesselDto toDto(Vessel vessel) {
        return VesselDto.builder()
            .id(vessel.getId())
            .imoNumber(vessel.getImoNumber())
            .name(vessel.getName())
            .callSign(vessel.getCallSign())
            .capacityTons(vessel.getCapacityTons())
            .builtYear(vessel.getBuiltYear())
            .status(vessel.getStatus())
            .build();
    }

    private Vessel toEntity(VesselDto dto) {
        return Vessel.builder()
            .imoNumber(dto.getImoNumber())
            .name(dto.getName())
            .callSign(dto.getCallSign())
            .capacityTons(dto.getCapacityTons())
            .builtYear(dto.getBuiltYear())
            .status(dto.getStatus() != null ? dto.getStatus() : Vessel.VesselStatus.available)
            .build();
    }
}

