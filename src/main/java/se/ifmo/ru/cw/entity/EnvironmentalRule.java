package se.ifmo.ru.cw.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "environmental_rule")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EnvironmentalRule {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "rule_id")
    private Integer id;

    @Column(name = "name", nullable = false, unique = true)
    private String name;

    @Column(name = "parameter", nullable = false)
    private String parameter;

    @Column(name = "threshold_value", precision = 20, scale = 6)
    private BigDecimal thresholdValue;

    @Column(name = "threshold_operator")
    @Enumerated(EnumType.STRING)
    private ThresholdOperator thresholdOperator;

    @Column(name = "active")
    @Builder.Default
    private Boolean active = true;

    @OneToMany(mappedBy = "rule", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Sensor> sensors = new ArrayList<>();

    public enum ThresholdOperator {
        LE("<="), GE(">="), GT(">"), LT("<");

        private final String symbol;

        ThresholdOperator(String symbol) {
            this.symbol = symbol;
        }

        public String getSymbol() {
            return symbol;
        }
    }
}

