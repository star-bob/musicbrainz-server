-- Generated by CompileSchemaScripts.pl from:
-- 20200512-mbs-10821-orphaned-recording-collection.sql
-- 20200914-oauth-pkce.sql
-- 20201028-mbs-1424.sql
-- 20210215-mbs-11268.sql
-- 20210309-mbs-11431.sql
-- 20210319-mbs-11451.sql
-- 20210319-mbs-11453.sql
-- 20210319-mbs-11464.sql
-- 20210319-mbs-11466.sql
-- 20210406-mbs-11459.sql
-- 20210505-mbs-11641.sql
\set ON_ERROR_STOP 1
BEGIN;
SET search_path = musicbrainz, public;
SET LOCAL statement_timeout = 0;
--------------------------------------------------------------------------------
SELECT '20200512-mbs-10821-orphaned-recording-collection.sql';

CREATE OR REPLACE FUNCTION delete_orphaned_recordings()
RETURNS TRIGGER
AS $$
  BEGIN
    PERFORM TRUE
    FROM recording outer_r
    WHERE id = OLD.recording
      AND edits_pending = 0
      AND NOT EXISTS (
        SELECT TRUE
        FROM edit JOIN edit_recording er ON edit.id = er.edit
        WHERE er.recording = outer_r.id
          AND type IN (71, 207, 218)
          LIMIT 1
      ) AND NOT EXISTS (
        SELECT TRUE FROM track WHERE track.recording = outer_r.id LIMIT 1
      ) AND NOT EXISTS (
        SELECT TRUE FROM l_area_recording WHERE entity1 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_artist_recording WHERE entity1 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_event_recording WHERE entity1 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_instrument_recording WHERE entity1 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_label_recording WHERE entity1 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_place_recording WHERE entity1 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_recording_recording WHERE entity1 = outer_r.id OR entity0 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_recording_release WHERE entity0 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_recording_release_group WHERE entity0 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_recording_series WHERE entity0 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_recording_work WHERE entity0 = outer_r.id
          UNION ALL
         SELECT TRUE FROM l_recording_url WHERE entity0 = outer_r.id
      );

    IF FOUND THEN
      -- Remove references from tables that don't change whether or not this recording
      -- is orphaned.
      DELETE FROM isrc WHERE recording = OLD.recording;
      DELETE FROM recording_alias WHERE recording = OLD.recording;
      DELETE FROM recording_annotation WHERE recording = OLD.recording;
      DELETE FROM recording_gid_redirect WHERE new_id = OLD.recording;
      DELETE FROM recording_rating_raw WHERE recording = OLD.recording;
      DELETE FROM recording_tag WHERE recording = OLD.recording;
      DELETE FROM recording_tag_raw WHERE recording = OLD.recording;
      DELETE FROM editor_collection_recording WHERE recording = OLD.recording;

      DELETE FROM recording WHERE id = OLD.recording;
    END IF;

    RETURN NULL;
  END;
$$ LANGUAGE 'plpgsql';

--------------------------------------------------------------------------------
SELECT '20200914-oauth-pkce.sql';


DO $$
BEGIN
  PERFORM 1 FROM pg_type
  WHERE typname = 'oauth_code_challenge_method';

  IF NOT FOUND THEN
    CREATE TYPE oauth_code_challenge_method AS ENUM ('plain', 'S256');
  END IF;
END
$$;

ALTER TABLE editor_oauth_token ADD COLUMN IF NOT EXISTS code_challenge TEXT;
ALTER TABLE editor_oauth_token ADD COLUMN IF NOT EXISTS code_challenge_method oauth_code_challenge_method;

DO $$
BEGIN
  PERFORM 1 FROM information_schema.constraint_column_usage
  WHERE table_name = 'editor_oauth_token'
  AND constraint_name = 'valid_code_challenge';

  IF NOT FOUND THEN
    ALTER TABLE editor_oauth_token ADD CONSTRAINT valid_code_challenge CHECK (
      (code_challenge IS NULL) = (code_challenge_method IS NULL) AND
      (code_challenge IS NULL OR code_challenge ~ E'^[A-Za-z0-9.~_-]{43,128}$')
    );
  END IF;
END
$$;

--------------------------------------------------------------------------------
SELECT '20201028-mbs-1424.sql';


DROP TABLE IF EXISTS release_first_release_date CASCADE;
DROP TABLE IF EXISTS recording_first_release_date CASCADE;

CREATE TABLE release_first_release_date (
    release     INTEGER NOT NULL,
    year        SMALLINT,
    month       SMALLINT,
    day         SMALLINT
);

CREATE TABLE recording_first_release_date (
  recording   INTEGER NOT NULL,
  year        SMALLINT,
  month       SMALLINT,
  day         SMALLINT
);

INSERT INTO release_first_release_date (
  SELECT DISTINCT ON (release)
    release, date_year, date_month, date_day
    FROM (
      SELECT release, date_year, date_month, date_day
        FROM release_country
       UNION ALL
      SELECT release, date_year, date_month, date_day
        FROM release_unknown_country
    ) all_dates
    ORDER BY
      release,
      date_year NULLS LAST,
      date_month NULLS LAST,
      date_day NULLS LAST
);

INSERT INTO recording_first_release_date (
  SELECT DISTINCT ON (track.recording)
      track.recording,
      rd.year,
      rd.month,
      rd.day
    FROM track
    JOIN medium ON medium.id = track.medium
    JOIN release_first_release_date rd ON rd.release = medium.release
    ORDER BY
      track.recording,
      rd.year NULLS LAST,
      rd.month NULLS LAST,
      rd.day NULLS LAST
);

ALTER TABLE release_first_release_date
  ADD CONSTRAINT release_first_release_date_pkey
  PRIMARY KEY (release);

ALTER TABLE recording_first_release_date
  ADD CONSTRAINT recording_first_release_date_pkey
  PRIMARY KEY (recording);

CREATE OR REPLACE FUNCTION set_release_first_release_date(release_id INTEGER)
RETURNS VOID AS $$
BEGIN
  INSERT INTO release_first_release_date (release, year, month, day) (
    SELECT release_id, date_year, date_month, date_day FROM (
      SELECT date_year, date_month, date_day
        FROM release_country
       WHERE release = release_id
       UNION ALL
      SELECT date_year, date_month, date_day
        FROM release_unknown_country
       WHERE release = release_id
       UNION ALL
      SELECT NULL, NULL, NULL
    ) release_dates
    ORDER BY
      date_year NULLS LAST,
      date_month NULLS LAST,
      date_day NULLS LAST
    LIMIT 1
  )
  ON CONFLICT (release)
  DO UPDATE SET year = excluded.year,
                month = excluded.month,
                day = excluded.day;

  DELETE FROM release_first_release_date
   WHERE release = release_id
     AND year IS NULL
     AND month IS NULL
     AND day IS NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION set_release_group_first_release_date(release_group_id INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE release_group_meta SET first_release_date_year = first.year,
                                  first_release_date_month = first.month,
                                  first_release_date_day = first.day
      FROM (
        SELECT rd.year, rd.month, rd.day
        FROM release
        LEFT JOIN release_first_release_date rd ON (rd.release = release.id)
        WHERE release.release_group = release_group_id
        ORDER BY
          rd.year NULLS LAST,
          rd.month NULLS LAST,
          rd.day NULLS LAST
        LIMIT 1
      ) AS first
    WHERE id = release_group_id;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION set_recordings_first_release_dates(recording_ids INTEGER[])
RETURNS VOID AS $$
BEGIN
  INSERT INTO recording_first_release_date
  (
    SELECT DISTINCT ON (track.recording)
        track.recording,
        rd.year,
        rd.month,
        rd.day
      FROM track
      JOIN medium ON medium.id = track.medium
      LEFT JOIN release_first_release_date rd ON rd.release = medium.release
     WHERE track.recording = ANY(recording_ids)
     ORDER BY
      track.recording,
      rd.year NULLS LAST,
      rd.month NULLS LAST,
      rd.day NULLS LAST
  )
  ON CONFLICT (recording) DO UPDATE
  SET year = excluded.year,
      month = excluded.month,
      day = excluded.day;

  DELETE FROM recording_first_release_date
   WHERE recording = ANY(recording_ids)
     AND year IS NULL
     AND month IS NULL
     AND day IS NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION set_releases_recordings_first_release_dates(release_ids INTEGER[])
RETURNS VOID AS $$
BEGIN
  PERFORM set_recordings_first_release_dates((
    SELECT array_agg(recording)
      FROM track
      JOIN medium ON medium.id = track.medium
     WHERE medium.release = any(release_ids)
  ));
  RETURN;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_track() RETURNS trigger AS $$
BEGIN
    PERFORM inc_ref_count('artist_credit', NEW.artist_credit, 1);
    -- increment track_count in the parent medium
    UPDATE medium SET track_count = track_count + 1 WHERE id = NEW.medium;
    PERFORM materialise_recording_length(NEW.recording);
    PERFORM set_recordings_first_release_dates(ARRAY[NEW.recording]);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_track() RETURNS trigger AS $$
BEGIN
    IF NEW.artist_credit != OLD.artist_credit THEN
        PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
        PERFORM inc_ref_count('artist_credit', NEW.artist_credit, 1);
    END IF;
    IF NEW.medium != OLD.medium THEN
        -- medium is changed, decrement track_count in the original medium, increment in the new one
        UPDATE medium SET track_count = track_count - 1 WHERE id = OLD.medium;
        UPDATE medium SET track_count = track_count + 1 WHERE id = NEW.medium;
    END IF;
    IF OLD.recording <> NEW.recording THEN
      PERFORM materialise_recording_length(OLD.recording);
      PERFORM set_recordings_first_release_dates(ARRAY[OLD.recording, NEW.recording]);
    END IF;
    PERFORM materialise_recording_length(NEW.recording);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_track() RETURNS trigger AS $$
BEGIN
    PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
    -- decrement track_count in the parent medium
    UPDATE medium SET track_count = track_count - 1 WHERE id = OLD.medium;
    PERFORM materialise_recording_length(OLD.recording);
    PERFORM set_recordings_first_release_dates(ARRAY[OLD.recording]);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_release_event()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM set_release_first_release_date(NEW.release);

  PERFORM set_release_group_first_release_date(release_group)
  FROM release
  WHERE release.id = NEW.release;

  PERFORM set_releases_recordings_first_release_dates(ARRAY[NEW.release]);
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_release_event()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM set_release_first_release_date(OLD.release);
  PERFORM set_release_first_release_date(NEW.release);

  PERFORM set_release_group_first_release_date(release_group)
  FROM release
  WHERE release.id IN (NEW.release, OLD.release);

  PERFORM set_releases_recordings_first_release_dates(ARRAY[NEW.release, OLD.release]);
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_release_event()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM set_release_first_release_date(OLD.release);

  PERFORM set_release_group_first_release_date(release_group)
  FROM release
  WHERE release.id = OLD.release;

  PERFORM set_releases_recordings_first_release_dates(ARRAY[OLD.release]);
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

--------------------------------------------------------------------------------
SELECT '20210215-mbs-11268.sql';


CREATE OR REPLACE VIEW medium_track_durations AS
    SELECT
        medium.id AS medium,
        array_agg(track.length ORDER BY track.position) FILTER (WHERE track.position = 0) AS pregap_length,
        array_agg(track.length ORDER BY track.position) FILTER (WHERE track.position > 0 AND track.is_data_track = false) AS cdtoc_track_lengths,
        array_agg(track.length ORDER BY track.position) FILTER (WHERE track.is_data_track = true) AS data_track_lengths
    FROM medium
    JOIN track ON track.medium = medium.id
    GROUP BY medium.id;

--------------------------------------------------------------------------------
SELECT '20210309-mbs-11431.sql';


CREATE INDEX IF NOT EXISTS artist_idx_lower_unaccent_name_comment ON artist (lower(musicbrainz_unaccent(name)), lower(musicbrainz_unaccent(comment)));
CREATE INDEX IF NOT EXISTS label_idx_lower_unaccent_name_comment ON label (lower(musicbrainz_unaccent(name)), lower(musicbrainz_unaccent(comment)));
CREATE INDEX IF NOT EXISTS place_idx_lower_unaccent_name_comment ON place (lower(musicbrainz_unaccent(name)), lower(musicbrainz_unaccent(comment)));
CREATE INDEX IF NOT EXISTS series_idx_lower_unaccent_name_comment ON series (lower(musicbrainz_unaccent(name)), lower(musicbrainz_unaccent(comment)));

CREATE INDEX IF NOT EXISTS artist_alias_idx_lower_unaccent_name ON artist_alias (lower(musicbrainz_unaccent(name)));
CREATE INDEX IF NOT EXISTS label_alias_idx_lower_unaccent_name ON label_alias (lower(musicbrainz_unaccent(name)));
CREATE INDEX IF NOT EXISTS place_alias_idx_lower_unaccent_name ON place_alias (lower(musicbrainz_unaccent(name)));
CREATE INDEX IF NOT EXISTS series_alias_idx_lower_unaccent_name ON series_alias (lower(musicbrainz_unaccent(name)));

DROP INDEX IF EXISTS artist_idx_lower_name;
DROP INDEX IF EXISTS label_idx_lower_name;

--------------------------------------------------------------------------------
SELECT '20210319-mbs-11451.sql';

CREATE TABLE place_meta ( -- replicate
    id                  INTEGER NOT NULL, -- PK, references place.id CASCADE
    rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
    rating_count        INTEGER
);

CREATE TABLE place_rating_raw
(
    place               INTEGER NOT NULL, -- PK, references place.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    rating              SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 100)
);

ALTER TABLE place_meta ADD CONSTRAINT place_meta_pkey PRIMARY KEY (id);
ALTER TABLE place_rating_raw ADD CONSTRAINT place_rating_raw_pkey PRIMARY KEY (place, editor);

CREATE OR REPLACE FUNCTION a_ins_place() RETURNS trigger AS $$
BEGIN
    INSERT INTO place_meta (id) VALUES (NEW.id);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

INSERT INTO place_meta (id)
    (SELECT id FROM place);

CREATE INDEX place_rating_raw_idx_editor ON place_rating_raw (editor);

--------------------------------------------------------------------------------
SELECT '20210319-mbs-11453.sql';

ALTER TABLE link_type
    ALTER COLUMN entity0_cardinality SET DATA TYPE SMALLINT,
    ALTER COLUMN entity1_cardinality SET DATA TYPE SMALLINT;

--------------------------------------------------------------------------------
SELECT '20210319-mbs-11464.sql';

DROP TABLE IF EXISTS statistics.log_statistic;

--------------------------------------------------------------------------------
SELECT '20210319-mbs-11466.sql';

ALTER TABLE language
    ALTER COLUMN frequency SET DATA TYPE SMALLINT;

ALTER TABLE script
    ALTER COLUMN frequency SET DATA TYPE SMALLINT;

--------------------------------------------------------------------------------
SELECT '20210406-mbs-11459.sql';


CREATE OR REPLACE FUNCTION edit_data_type_info(data JSONB) RETURNS TEXT AS $$
BEGIN
    CASE jsonb_typeof(data)
    WHEN 'object' THEN
        RETURN '{' ||
            (SELECT string_agg(
                to_json(key) || ':' ||
                edit_data_type_info(jsonb_extract_path(data, key)),
                ',' ORDER BY key)
               FROM jsonb_object_keys(data) AS key) ||
            '}';
    WHEN 'array' THEN
        RETURN '[' ||
            (SELECT string_agg(
                DISTINCT edit_data_type_info(item),
                ',' ORDER BY edit_data_type_info(item))
               FROM jsonb_array_elements(data) AS item) ||
            ']';
    WHEN 'string' THEN
        RETURN '1';
    WHEN 'number' THEN
        RETURN '2';
    WHEN 'boolean' THEN
        RETURN '4';
    WHEN 'null' THEN
        RETURN '8';
    END CASE;
    RETURN '';
END;
$$ LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE STRICT;

--------------------------------------------------------------------------------
SELECT '20210505-mbs-11641.sql';


DROP INDEX IF EXISTS artist_rating_raw_idx_artist;
DROP INDEX IF EXISTS event_rating_raw_idx_event;
DROP INDEX IF EXISTS label_rating_raw_idx_label;
DROP INDEX IF EXISTS release_group_rating_raw_idx_release_group;

COMMIT;
