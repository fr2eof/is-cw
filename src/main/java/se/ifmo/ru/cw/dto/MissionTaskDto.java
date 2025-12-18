package se.ifmo.ru.cw.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import se.ifmo.ru.cw.entity.MissionTask;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MissionTaskDto {
    private Integer id;
    private Integer expeditionId;
    private Integer parentTaskId;
    private String title;
    private String description;
    private Integer responsibleCrewId;
    private String responsibleCrewName;
    private Instant plannedStart;
    private Instant plannedEnd;
    private MissionTask.TaskStatus status;
}

