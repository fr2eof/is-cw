package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.MissionTask;

import java.util.List;

@Repository
public interface MissionTaskRepository extends JpaRepository<MissionTask, Integer> {
    List<MissionTask> findByExpeditionId(Integer expeditionId);
    List<MissionTask> findByStatus(MissionTask.TaskStatus status);
    List<MissionTask> findByExpeditionIdAndStatus(Integer expeditionId, MissionTask.TaskStatus status);
    List<MissionTask> findByResponsibleCrewId(Integer crewId);
    List<MissionTask> findByParentTaskId(Integer parentTaskId);
    
    @Query("SELECT t FROM MissionTask t WHERE t.expedition.id = :expeditionId AND t.parentTask IS NULL")
    List<MissionTask> findRootTasksByExpeditionId(@Param("expeditionId") Integer expeditionId);
}

