DROP TABLE IF EXISTS _raw_sentences CASCADE;
CREATE TABLE _raw_sentences (
    sentence_id TEXT,
    sentence TEXT,
    terms TEXT,
    id BIGINT  -- reserved for DeepDive?
    );

DROP TABLE IF EXISTS _annotated_sentences CASCADE;
CREATE TABLE _annotated_sentences(
  sentence_id TEXT,
  words TEXT[],
  has_term BOOLEAN,
  id BIGINT   -- reserved for DeepDive
  );

DROP TABLE IF EXISTS _extracted_features CASCADE;
  CREATE TABLE _extracted_features (
  sentence_id TEXT,
  feature TEXT
  );
