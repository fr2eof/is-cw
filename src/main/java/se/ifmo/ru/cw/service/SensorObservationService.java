package se.ifmo.ru.cw.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import se.ifmo.ru.cw.dto.SensorObservationDto;
import se.ifmo.ru.cw.entity.Expedition;
import se.ifmo.ru.cw.entity.Sensor;
import se.ifmo.ru.cw.entity.SensorObservation;
import se.ifmo.ru.cw.exception.ResourceNotFoundException;
import se.ifmo.ru.cw.repository.ExpeditionRepository;
import se.ifmo.ru.cw.repository.SensorObservationRepository;
import se.ifmo.ru.cw.repository.SensorRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SensorObservationService {
    private final SensorObservationRepository sensorObservationRepository;
    private final SensorRepository sensorRepository;
    private final ExpeditionRepository expeditionRepository;

    @Transactional(readOnly = true)
    public List<SensorObservationDto> getObservationsBySensor(Integer sensorId) {
        return sensorObservationRepository.findBySensorId(sensorId).stream()
            .map(this::toDto)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<SensorObservationDto> getObservationsByExpedition(Integer expeditionId) {
        return sensorObservationRepository.findByExpeditionId(expeditionId).stream()
            .map(this::toDto)
            .collect(Collectors.toList());
    }

    @Transactional
    public SensorObservationDto createObservation(SensorObservationDto dto) {
        Sensor sensor = sensorRepository.findById(dto.getSensorId())
            .orElseThrow(() -> new ResourceNotFoundException("Sensor not found with id: " + dto.getSensorId()));
        
        SensorObservation observation = SensorObservation.builder()
            .sensor(sensor)
            .observedAt(dto.getObservedAt() != null ? dto.getObservedAt() : java.time.Instant.now())
            .valueNum(dto.getValueNum())
            .valueText(dto.getValueText())
            .qcStatus(SensorObservation.QcStatus.unchecked)
            .build();
        
        if (dto.getExpeditionId() != null) {
            Expedition expedition = expeditionRepository.findById(dto.getExpeditionId())
                .orElseThrow(() -> new ResourceNotFoundException("Expedition not found with id: " + dto.getExpeditionId()));
            observation.setExpedition(expedition);
        }
        
        SensorObservation saved = sensorObservationRepository.save(observation);
        return toDto(saved);
    }

    private SensorObservationDto toDto(SensorObservation observation) {
        return SensorObservationDto.builder()
            .id(observation.getId())
            .sensorId(observation.getSensor() != null ? observation.getSensor().getId() : null)
            .sensorName(observation.getSensor() != null ? observation.getSensor().getName() : null)
            .expeditionId(observation.getExpedition() != null ? observation.getExpedition().getId() : null)
            .observedAt(observation.getObservedAt())
            .valueNum(observation.getValueNum())
            .valueText(observation.getValueText())
            .qcStatus(observation.getQcStatus())
            .build();
    }
}

