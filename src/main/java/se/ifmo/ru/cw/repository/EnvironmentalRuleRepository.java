package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.EnvironmentalRule;

import java.util.List;
import java.util.Optional;

@Repository
public interface EnvironmentalRuleRepository extends JpaRepository<EnvironmentalRule, Integer> {
    Optional<EnvironmentalRule> findByName(String name);
    List<EnvironmentalRule> findByActiveTrue();
    List<EnvironmentalRule> findByParameterAndActiveTrue(String parameter);
}

