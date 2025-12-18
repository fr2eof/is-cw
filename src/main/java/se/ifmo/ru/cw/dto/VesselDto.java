package se.ifmo.ru.cw.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import se.ifmo.ru.cw.entity.Vessel;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VesselDto {
    private Integer id;
    private String imoNumber;
    private String name;
    private String callSign;
    private BigDecimal capacityTons;
    private Integer builtYear;
    private Vessel.VesselStatus status;
}

