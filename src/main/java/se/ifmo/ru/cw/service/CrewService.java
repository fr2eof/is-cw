package se.ifmo.ru.cw.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import se.ifmo.ru.cw.dto.CrewMemberDto;
import se.ifmo.ru.cw.entity.CrewAssignment;
import se.ifmo.ru.cw.entity.CrewAssignmentId;
import se.ifmo.ru.cw.entity.CrewMember;
import se.ifmo.ru.cw.entity.Expedition;
import se.ifmo.ru.cw.entity.Role;
import se.ifmo.ru.cw.exception.ResourceNotFoundException;
import se.ifmo.ru.cw.repository.CrewAssignmentRepository;
import se.ifmo.ru.cw.repository.CrewMemberRepository;
import se.ifmo.ru.cw.repository.ExpeditionRepository;
import se.ifmo.ru.cw.repository.RoleRepository;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CrewService {
    private final CrewMemberRepository crewMemberRepository;
    private final ExpeditionRepository expeditionRepository;
    private final CrewAssignmentRepository crewAssignmentRepository;
    private final RoleRepository roleRepository;

    @Transactional(readOnly = true)
    public List<CrewMemberDto> getAllCrewMembers() {
        return crewMemberRepository.findAll().stream()
            .map(this::toDto)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public CrewMemberDto getCrewMemberById(Integer id) {
        CrewMember crewMember = crewMemberRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Crew member not found with id: " + id));
        return toDto(crewMember);
    }

    @Transactional
    public CrewMemberDto createCrewMember(CrewMemberDto dto) {
        CrewMember crewMember = toEntity(dto);
        if (dto.getRoleCodes() != null && !dto.getRoleCodes().isEmpty()) {
            Set<Role> roles = dto.getRoleCodes().stream()
                .map(code -> roleRepository.findByCode(code)
                    .orElseThrow(() -> new ResourceNotFoundException("Role not found with code: " + code)))
                .collect(Collectors.toSet());
            crewMember.setRoles(roles);
        }
        CrewMember saved = crewMemberRepository.save(crewMember);
        return toDto(saved);
    }

    @Transactional
    public CrewMemberDto updateCrewMember(Integer id, CrewMemberDto dto) {
        CrewMember crewMember = crewMemberRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Crew member not found with id: " + id));
        
        crewMember.setExternalId(dto.getExternalId());
        crewMember.setFirstName(dto.getFirstName());
        crewMember.setLastName(dto.getLastName());
        crewMember.setBirthDate(dto.getBirthDate());
        crewMember.setNationality(dto.getNationality());
        crewMember.setEmail(dto.getEmail());
        crewMember.setPhone(dto.getPhone());
        crewMember.setStatus(dto.getStatus());
        
        if (dto.getRoleCodes() != null) {
            Set<Role> roles = dto.getRoleCodes().stream()
                .map(code -> roleRepository.findByCode(code)
                    .orElseThrow(() -> new ResourceNotFoundException("Role not found with code: " + code)))
                .collect(Collectors.toSet());
            crewMember.setRoles(roles);
        }
        
        CrewMember saved = crewMemberRepository.save(crewMember);
        return toDto(saved);
    }

    @Transactional
    public void assignCrewToExpedition(Integer expeditionId, Integer crewId) {
        Expedition expedition = expeditionRepository.findById(expeditionId)
            .orElseThrow(() -> new ResourceNotFoundException("Expedition not found with id: " + expeditionId));
        
        CrewMember crewMember = crewMemberRepository.findById(crewId)
            .orElseThrow(() -> new ResourceNotFoundException("Crew member not found with id: " + crewId));
        
        if (crewAssignmentRepository.existsByExpeditionIdAndCrewId(expeditionId, crewId)) {
            throw new IllegalStateException("Crew member already assigned to this expedition");
        }
        
        CrewAssignment assignment = CrewAssignment.builder()
            .expedition(expedition)
            .crew(crewMember)
            .build();
        
        crewAssignmentRepository.save(assignment);
    }

    @Transactional
    public void removeCrewFromExpedition(Integer expeditionId, Integer crewId) {
        CrewAssignmentId id = new CrewAssignmentId(expeditionId, crewId);
        if (!crewAssignmentRepository.existsById(id)) {
            throw new ResourceNotFoundException("Crew assignment not found");
        }
        crewAssignmentRepository.deleteById(id);
    }

    @Transactional(readOnly = true)
    public List<CrewMemberDto> getCrewForExpedition(Integer expeditionId) {
        List<CrewAssignment> assignments = crewAssignmentRepository.findByExpeditionId(expeditionId);
        return assignments.stream()
            .map(assignment -> toDto(assignment.getCrew()))
            .collect(Collectors.toList());
    }

    private CrewMemberDto toDto(CrewMember crewMember) {
        Set<String> roleCodes = crewMember.getRoles().stream()
            .map(Role::getCode)
            .collect(Collectors.toSet());
        
        return CrewMemberDto.builder()
            .id(crewMember.getId())
            .externalId(crewMember.getExternalId())
            .firstName(crewMember.getFirstName())
            .lastName(crewMember.getLastName())
            .birthDate(crewMember.getBirthDate())
            .nationality(crewMember.getNationality())
            .email(crewMember.getEmail())
            .phone(crewMember.getPhone())
            .status(crewMember.getStatus())
            .roleCodes(roleCodes)
            .build();
    }

    private CrewMember toEntity(CrewMemberDto dto) {
        return CrewMember.builder()
            .externalId(dto.getExternalId())
            .firstName(dto.getFirstName())
            .lastName(dto.getLastName())
            .birthDate(dto.getBirthDate())
            .nationality(dto.getNationality())
            .email(dto.getEmail())
            .phone(dto.getPhone())
            .status(dto.getStatus() != null ? dto.getStatus() : CrewMember.CrewStatus.active)
            .build();
    }
}

