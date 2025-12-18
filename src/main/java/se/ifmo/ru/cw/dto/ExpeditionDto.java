package se.ifmo.ru.cw.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import se.ifmo.ru.cw.entity.Expedition;

import java.time.Instant;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExpeditionDto {
    private Integer id;
    private String code;
    private String name;
    private String description;
    private Integer vesselId;
    private String vesselName;
    private Long managerUserId;
    private LocalDate plannedStart;
    private LocalDate plannedEnd;
    private Instant actualStart;
    private Instant actualEnd;
    private Expedition.ExpeditionStatus status;
    private Instant createdAt;
}

