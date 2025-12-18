package se.ifmo.ru.cw.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Table(name = "crew_member")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CrewMember {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "crew_id")
    private Integer id;

    @Column(name = "external_id")
    private String externalId;

    @Column(name = "first_name", nullable = false)
    private String firstName;

    @Column(name = "last_name", nullable = false)
    private String lastName;

    @Column(name = "birth_date")
    private LocalDate birthDate;

    @Column(name = "nationality")
    private String nationality;

    @Column(name = "email", unique = true)
    private String email;

    @Column(name = "phone")
    private String phone;

    @Column(name = "status", nullable = false)
    @Enumerated(EnumType.STRING)
    private CrewStatus status;

    @Column(name = "created_at")
    private Instant createdAt;

    @ManyToMany
    @JoinTable(
        name = "crew_role",
        joinColumns = @JoinColumn(name = "crew_id"),
        inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    @Builder.Default
    private Set<Role> roles = new HashSet<>();

    @OneToMany(mappedBy = "crew", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<CrewAssignment> assignments = new ArrayList<>();

    @OneToMany(mappedBy = "crew", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<CrewCertification> certifications = new ArrayList<>();

    @OneToMany(mappedBy = "responsibleCrew", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<MissionTask> responsibleTasks = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = Instant.now();
        }
        if (status == null) {
            status = CrewStatus.active;
        }
    }

    public enum CrewStatus {
        active, inactive, onboard, on_leave
    }
}

