package se.ifmo.ru.cw.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "sensor_observation")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SensorObservation {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "observation_id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sensor_id", nullable = false)
    private Sensor sensor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "expedition_id")
    private Expedition expedition;

    @Column(name = "observed_at", nullable = false)
    private Instant observedAt;

    @Column(name = "value_num", precision = 20, scale = 6)
    private BigDecimal valueNum;

    @Column(name = "value_text", columnDefinition = "TEXT")
    private String valueText;

    @Column(name = "qc_status")
    @Enumerated(EnumType.STRING)
    private QcStatus qcStatus;

    @Column(name = "created_at")
    private Instant createdAt;

    @PrePersist
    protected void onCreate() {
        if (observedAt == null) {
            observedAt = Instant.now();
        }
        if (createdAt == null) {
            createdAt = Instant.now();
        }
        if (qcStatus == null) {
            qcStatus = QcStatus.unchecked;
        }
    }

    public enum QcStatus {
        unchecked, ok, flagged, invalid
    }
}

