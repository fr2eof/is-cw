package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.CrewMember;

import java.util.List;
import java.util.Optional;

@Repository
public interface CrewMemberRepository extends JpaRepository<CrewMember, Integer> {
    Optional<CrewMember> findByEmail(String email);
    List<CrewMember> findByStatus(CrewMember.CrewStatus status);
    
    @Query("SELECT cm FROM CrewMember cm WHERE cm.id NOT IN " +
           "(SELECT ca.crew.id FROM CrewAssignment ca WHERE ca.expedition.id = :expeditionId)")
    List<CrewMember> findAvailableForExpedition(@Param("expeditionId") Integer expeditionId);
}

