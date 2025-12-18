package se.ifmo.ru.cw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import se.ifmo.ru.cw.entity.Document;

import java.util.List;

@Repository
public interface DocumentRepository extends JpaRepository<Document, Integer> {
    List<Document> findByExpeditionId(Integer expeditionId);
    List<Document> findByDocType(String docType);
}

