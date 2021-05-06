-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

DROP FUNCTION _median(anyarray);
DROP FUNCTION a_del_alternative_medium_track();
DROP FUNCTION a_del_alternative_release_or_track();
DROP FUNCTION a_del_instrument();
DROP FUNCTION a_del_recording();
DROP FUNCTION a_del_release();
DROP FUNCTION a_del_release_event();
DROP FUNCTION a_del_release_group();
DROP FUNCTION a_del_track();
DROP FUNCTION a_ins_alternative_medium_track();
DROP FUNCTION a_ins_alternative_release_or_track();
DROP FUNCTION a_ins_artist();
DROP FUNCTION a_ins_edit_note();
DROP FUNCTION a_ins_editor();
DROP FUNCTION a_ins_event();
DROP FUNCTION a_ins_instrument();
DROP FUNCTION a_ins_label();
DROP FUNCTION a_ins_place();
DROP FUNCTION a_ins_recording();
DROP FUNCTION a_ins_release();
DROP FUNCTION a_ins_release_event();
DROP FUNCTION a_ins_release_group();
DROP FUNCTION a_ins_track();
DROP FUNCTION a_ins_work();
DROP FUNCTION a_upd_alternative_medium_track();
DROP FUNCTION a_upd_alternative_release_or_track();
DROP FUNCTION a_upd_edit();
DROP FUNCTION a_upd_instrument();
DROP FUNCTION a_upd_recording();
DROP FUNCTION a_upd_release();
DROP FUNCTION a_upd_release_event();
DROP FUNCTION a_upd_release_group();
DROP FUNCTION a_upd_track();
DROP FUNCTION b_ins_edit_materialize_status();
DROP FUNCTION b_upd_last_updated_table();
DROP FUNCTION b_upd_recording();
DROP FUNCTION check_editor_name();
DROP FUNCTION check_has_dates();
DROP FUNCTION controlled_for_whitespace(TEXT);
DROP FUNCTION create_bounding_cube(durations INTEGER[], fuzzy INTEGER);
DROP FUNCTION create_cube_from_durations(durations INTEGER[]);
DROP FUNCTION dec_nullable_artist_credit(row_id integer);
DROP FUNCTION dec_ref_count(tbl varchar, row_id integer, val integer);
DROP FUNCTION del_collection_sub_on_delete();
DROP FUNCTION del_collection_sub_on_private();
DROP FUNCTION delete_orphaned_recordings();
DROP FUNCTION delete_ratings(enttype TEXT, ids INTEGER[]);
DROP FUNCTION delete_unused_tag(tag_id INT);
DROP FUNCTION delete_unused_url(ids INTEGER[]);
DROP FUNCTION deny_deprecated_links();
DROP FUNCTION deny_special_purpose_deletion();
DROP FUNCTION edit_data_type_info(data JSONB);
DROP FUNCTION end_area_implies_ended();
DROP FUNCTION end_date_implies_ended();
DROP FUNCTION ensure_area_attribute_type_allows_text();
DROP FUNCTION ensure_artist_attribute_type_allows_text();
DROP FUNCTION ensure_event_attribute_type_allows_text();
DROP FUNCTION ensure_instrument_attribute_type_allows_text();
DROP FUNCTION ensure_label_attribute_type_allows_text();
DROP FUNCTION ensure_medium_attribute_type_allows_text();
DROP FUNCTION ensure_place_attribute_type_allows_text();
DROP FUNCTION ensure_recording_attribute_type_allows_text();
DROP FUNCTION ensure_release_attribute_type_allows_text();
DROP FUNCTION ensure_release_group_attribute_type_allows_text();
DROP FUNCTION ensure_series_attribute_type_allows_text();
DROP FUNCTION ensure_work_attribute_type_allows_text();
DROP FUNCTION from_hex(t text);
DROP FUNCTION generate_uuid_v3(namespace varchar, name varchar);
DROP FUNCTION generate_uuid_v4();
DROP FUNCTION get_recording_first_release_date_rows(condition TEXT);
DROP FUNCTION get_release_first_release_date_rows(condition TEXT);
DROP FUNCTION inc_nullable_artist_credit(row_id integer);
DROP FUNCTION inc_ref_count(tbl varchar, row_id integer, val integer);
DROP FUNCTION inserting_edits_requires_confirmed_email_address();
DROP FUNCTION materialise_recording_length(recording_id INT);
DROP FUNCTION mb_lower(input text);
DROP FUNCTION mb_simple_tsvector(input text);
DROP FUNCTION median_track_length(recording_id integer);
DROP FUNCTION padded_by_whitespace(TEXT);
DROP FUNCTION prevent_invalid_attributes();
DROP FUNCTION remove_unused_links();
DROP FUNCTION remove_unused_url();
DROP FUNCTION replace_old_sub_on_add();
DROP FUNCTION set_recordings_first_release_dates(recording_ids INTEGER[]);
DROP FUNCTION set_release_first_release_date(release_id INTEGER);
DROP FUNCTION set_release_group_first_release_date(release_group_id INTEGER);
DROP FUNCTION set_releases_recordings_first_release_dates(release_ids INTEGER[]);
DROP FUNCTION simplify_search_hints();
DROP FUNCTION track_count_matches_cdtoc(medium, int);
DROP FUNCTION trg_delete_unused_tag();
DROP FUNCTION trg_delete_unused_tag_ref();
DROP FUNCTION unique_primary_area_alias();
DROP FUNCTION unique_primary_artist_alias();
DROP FUNCTION unique_primary_event_alias();
DROP FUNCTION unique_primary_genre_alias();
DROP FUNCTION unique_primary_instrument_alias();
DROP FUNCTION unique_primary_label_alias();
DROP FUNCTION unique_primary_place_alias();
DROP FUNCTION unique_primary_recording_alias();
DROP FUNCTION unique_primary_release_alias();
DROP FUNCTION unique_primary_release_group_alias();
DROP FUNCTION unique_primary_series_alias();
DROP FUNCTION unique_primary_work_alias();
DROP FUNCTION whitespace_collapsed(TEXT);
DROP AGGREGATE array_accum (anyelement);
