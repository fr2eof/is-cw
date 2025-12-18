package se.ifmo.ru.cw.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.Objects;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CrewCertificationId implements Serializable {
    private Integer crew;
    private Integer certification;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        CrewCertificationId that = (CrewCertificationId) o;
        return Objects.equals(crew, that.crew) && Objects.equals(certification, that.certification);
    }

    @Override
    public int hashCode() {
        return Objects.hash(crew, certification);
    }
}

