package se.ifmo.ru.cw.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Entity
@Table(name = "port_call")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PortCall {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "port_call_id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "expedition_id", nullable = false)
    private Expedition expedition;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "port_id", nullable = false)
    private Port port;

    @Column(name = "arrival_ts")
    private Instant arrivalTs;

    @Column(name = "departure_ts")
    private Instant departureTs;

    @Column(name = "operation_notes", columnDefinition = "TEXT")
    private String operationNotes;
}

