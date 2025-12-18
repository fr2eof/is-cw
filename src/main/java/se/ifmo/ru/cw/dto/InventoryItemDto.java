package se.ifmo.ru.cw.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InventoryItemDto {
    private Integer id;
    private Integer expeditionId;
    private String name;
    private String unit;
    private BigDecimal quantityOnboard;
}

