package se.ifmo.ru.cw.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "vessel")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Vessel {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "vessel_id")
    private Integer id;

    @Column(name = "imo_number", unique = true)
    private String imoNumber;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "call_sign")
    private String callSign;

    @Column(name = "capacity_tons", precision = 10, scale = 2)
    private BigDecimal capacityTons;

    @Column(name = "built_year")
    private Integer builtYear;

    @Column(name = "status", nullable = false)
    @Enumerated(EnumType.STRING)
    private VesselStatus status;

    @Column(name = "created_at")
    private Instant createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = Instant.now();
        }
        if (status == null) {
            status = VesselStatus.available;
        }
    }

    public enum VesselStatus {
        available, on_mission, maintenance, decommissioned
    }
}

