package se.ifmo.ru.cw.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.Objects;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CrewAssignmentId implements Serializable {
    private Integer expedition;
    private Integer crew;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        CrewAssignmentId that = (CrewAssignmentId) o;
        return Objects.equals(expedition, that.expedition) && Objects.equals(crew, that.crew);
    }

    @Override
    public int hashCode() {
        return Objects.hash(expedition, crew);
    }
}

