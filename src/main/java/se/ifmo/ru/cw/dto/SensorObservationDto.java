package se.ifmo.ru.cw.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import se.ifmo.ru.cw.entity.SensorObservation;

import java.math.BigDecimal;
import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SensorObservationDto {
    private Integer id;
    private Integer sensorId;
    private String sensorName;
    private Integer expeditionId;
    private Instant observedAt;
    private BigDecimal valueNum;
    private String valueText;
    private SensorObservation.QcStatus qcStatus;
}

