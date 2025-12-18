package se.ifmo.ru.cw.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import se.ifmo.ru.cw.dto.MissionTaskDto;
import se.ifmo.ru.cw.entity.CrewMember;
import se.ifmo.ru.cw.entity.Expedition;
import se.ifmo.ru.cw.entity.MissionTask;
import se.ifmo.ru.cw.exception.ResourceNotFoundException;
import se.ifmo.ru.cw.repository.CrewMemberRepository;
import se.ifmo.ru.cw.repository.ExpeditionRepository;
import se.ifmo.ru.cw.repository.MissionTaskRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MissionTaskService {
    private final MissionTaskRepository missionTaskRepository;
    private final ExpeditionRepository expeditionRepository;
    private final CrewMemberRepository crewMemberRepository;

    @Transactional(readOnly = true)
    public List<MissionTaskDto> getTasksByExpedition(Integer expeditionId) {
        return missionTaskRepository.findByExpeditionId(expeditionId).stream()
            .map(this::toDto)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public MissionTaskDto getTaskById(Integer id) {
        MissionTask task = missionTaskRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Task not found with id: " + id));
        return toDto(task);
    }

    @Transactional
    public MissionTaskDto createTask(MissionTaskDto dto) {
        MissionTask task = toEntity(dto);
        MissionTask saved = missionTaskRepository.save(task);
        return toDto(saved);
    }

    @Transactional
    public MissionTaskDto updateTask(Integer id, MissionTaskDto dto) {
        MissionTask task = missionTaskRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Task not found with id: " + id));
        
        task.setTitle(dto.getTitle());
        task.setDescription(dto.getDescription());
        task.setPlannedStart(dto.getPlannedStart());
        task.setPlannedEnd(dto.getPlannedEnd());
        task.setStatus(dto.getStatus());
        
        if (dto.getResponsibleCrewId() != null) {
            CrewMember crew = crewMemberRepository.findById(dto.getResponsibleCrewId())
                .orElseThrow(() -> new ResourceNotFoundException("Crew member not found with id: " + dto.getResponsibleCrewId()));
            task.setResponsibleCrew(crew);
        }
        
        if (dto.getParentTaskId() != null) {
            MissionTask parent = missionTaskRepository.findById(dto.getParentTaskId())
                .orElseThrow(() -> new ResourceNotFoundException("Parent task not found with id: " + dto.getParentTaskId()));
            task.setParentTask(parent);
        }
        
        MissionTask saved = missionTaskRepository.save(task);
        return toDto(saved);
    }

    @Transactional
    public void deleteTask(Integer id) {
        if (!missionTaskRepository.existsById(id)) {
            throw new ResourceNotFoundException("Task not found with id: " + id);
        }
        missionTaskRepository.deleteById(id);
    }

    private MissionTaskDto toDto(MissionTask task) {
        return MissionTaskDto.builder()
            .id(task.getId())
            .expeditionId(task.getExpedition() != null ? task.getExpedition().getId() : null)
            .parentTaskId(task.getParentTask() != null ? task.getParentTask().getId() : null)
            .title(task.getTitle())
            .description(task.getDescription())
            .responsibleCrewId(task.getResponsibleCrew() != null ? task.getResponsibleCrew().getId() : null)
            .responsibleCrewName(task.getResponsibleCrew() != null ? 
                task.getResponsibleCrew().getFirstName() + " " + task.getResponsibleCrew().getLastName() : null)
            .plannedStart(task.getPlannedStart())
            .plannedEnd(task.getPlannedEnd())
            .status(task.getStatus())
            .build();
    }

    private MissionTask toEntity(MissionTaskDto dto) {
        Expedition expedition = expeditionRepository.findById(dto.getExpeditionId())
            .orElseThrow(() -> new ResourceNotFoundException("Expedition not found with id: " + dto.getExpeditionId()));
        
        MissionTask task = MissionTask.builder()
            .expedition(expedition)
            .title(dto.getTitle())
            .description(dto.getDescription())
            .plannedStart(dto.getPlannedStart())
            .plannedEnd(dto.getPlannedEnd())
            .status(dto.getStatus() != null ? dto.getStatus() : MissionTask.TaskStatus.pending)
            .build();
        
        if (dto.getResponsibleCrewId() != null) {
            CrewMember crew = crewMemberRepository.findById(dto.getResponsibleCrewId())
                .orElseThrow(() -> new ResourceNotFoundException("Crew member not found with id: " + dto.getResponsibleCrewId()));
            task.setResponsibleCrew(crew);
        }
        
        if (dto.getParentTaskId() != null) {
            MissionTask parent = missionTaskRepository.findById(dto.getParentTaskId())
                .orElseThrow(() -> new ResourceNotFoundException("Parent task not found with id: " + dto.getParentTaskId()));
            task.setParentTask(parent);
        }
        
        return task;
    }
}

