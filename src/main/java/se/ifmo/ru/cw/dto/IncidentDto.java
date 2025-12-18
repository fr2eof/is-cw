package se.ifmo.ru.cw.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import se.ifmo.ru.cw.entity.Incident;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class IncidentDto {
    private Integer id;
    private Integer expeditionId;
    private Instant reportedAt;
    private Integer reportedByCrewId;
    private String reportedByCrewName;
    private Incident.IncidentSeverity severity;
    private String category;
    private String description;
    private Instant resolvedAt;
}

