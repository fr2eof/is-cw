package se.ifmo.ru.cw.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.Objects;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ExpeditionEquipmentId implements Serializable {
    private Integer expedition;
    private Integer equipment;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ExpeditionEquipmentId that = (ExpeditionEquipmentId) o;
        return Objects.equals(expedition, that.expedition) && Objects.equals(equipment, that.equipment);
    }

    @Override
    public int hashCode() {
        return Objects.hash(expedition, equipment);
    }
}

