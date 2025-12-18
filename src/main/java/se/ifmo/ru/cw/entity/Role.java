package se.ifmo.ru.cw.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "role")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Role {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "role_id")
    private Integer id;

    @Column(name = "code", unique = true, nullable = false)
    private String code;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "min_cert_required")
    @Builder.Default
    private Boolean minCertRequired = false;

    @ManyToMany(mappedBy = "roles")
    @Builder.Default
    private Set<CrewMember> crewMembers = new HashSet<>();
}

