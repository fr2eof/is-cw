package se.ifmo.ru.cw.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Entity
@Table(name = "incident")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Incident {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "incident_id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "expedition_id")
    private Expedition expedition;

    @Column(name = "reported_at")
    private Instant reportedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reported_by_crew_id")
    private CrewMember reportedByCrew;

    @Column(name = "severity", nullable = false)
    @Enumerated(EnumType.STRING)
    private IncidentSeverity severity;

    @Column(name = "category")
    private String category;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "resolved_at")
    private Instant resolvedAt;

    @PrePersist
    protected void onCreate() {
        if (reportedAt == null) {
            reportedAt = Instant.now();
        }
        if (severity == null) {
            severity = IncidentSeverity.medium;
        }
    }

    public enum IncidentSeverity {
        low, medium, high, critical
    }
}

