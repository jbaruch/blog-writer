#!/usr/bin/env bash
# shellcheck shell=bash
#
# Shared record contract for the two post-shapes scripts:
#   check-shape-convergence.sh  (reader)
#   record-post-shape.sh        (writer)
#
# Both must agree on what a well-formed record is and which schema versions they
# accept, so the definitions live here once rather than being restated in each.
# Sourced, never executed directly.
#
# Schema versions:
#   POST_SHAPES_MIN_SCHEMA  oldest version these scripts can read. A record below
#                           it predates the documented schema; since version 1 is
#                           the first, nothing legitimately sits below it and such
#                           a record is malformed rather than merely old. When a
#                           version 2 lands, this stays 1 and `migrate_record`
#                           below gains the upgrade path.
#   POST_SHAPES_MAX_SCHEMA  newest version these scripts understand. Records above
#                           it were written by a newer plugin: the reader skips
#                           them and the writer refuses, so neither destroys state
#                           it cannot represent.
#
# A record is well-formed when every required field is present with the type
# `references/post-shapes-schema.md` documents. Version range is checked
# separately, so "written by a newer plugin" stays distinguishable from "corrupt".
#
# Slugs are additionally checked for uniqueness across the history: recording is
# idempotent by slug, so two records sharing one make the history ambiguous.

readonly POST_SHAPES_MIN_SCHEMA=1
readonly POST_SHAPES_MAX_SCHEMA=1

readonly POST_SHAPES_RECORD_WELL_FORMED='
  (.schema_version | type) == "number"
  and (.schema_version | floor) == .schema_version
  and (.slug | type) == "string" and ((.slug | length) > 0)
  and (.date | type) == "string" and (.date | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}$"))
  and (.opening_mode | type) == "string"
  and (.arc | type) == "string"
  and (.closing_mode | type) == "string"
  and (.interventions | type) == "array"
  and (.interventions | all(type == "string"))
'

# Validates the envelope and every record in $1, and reports which records are
# usable. Writes an actionable diagnostic to stderr and returns non-zero when the
# history cannot be trusted; the caller decides whether that is fatal.
#
# On success, prints a JSON object:
#   {"usable": [...], "skipped_newer": N}
post_shapes_load() {
  local file=$1

  if ! jq -e 'type == "object" and (.posts | type) == "array"' "$file" >/dev/null 2>&1; then
    echo "error: ${file} is not valid JSON in the documented shape (an object with a \"posts\" array) — see references/post-shapes-schema.md and repair it" >&2
    return 1
  fi

  local malformed
  malformed=$(jq -c --argjson min "$POST_SHAPES_MIN_SCHEMA" \
    "[ .posts | to_entries[]
       | select( (.value | ${POST_SHAPES_RECORD_WELL_FORMED}) | not )
       | .key ]" "$file")

  if [ "$(jq 'length' <<<"$malformed")" -gt 0 ]; then
    echo "error: ${file} holds malformed record(s) at index ${malformed} — every record needs an integer schema_version, a non-empty slug, a YYYY-MM-DD date, string opening_mode/arc/closing_mode, and a string array of interventions. See references/post-shapes-schema.md and repair or remove them; refusing to act on a history that does not match its schema" >&2
    return 1
  fi

  # Recording is idempotent by slug, so a slug identifies exactly one post. Two
  # records sharing one means the history is ambiguous: the window could count a
  # single post twice, and an upsert could not say which record it replaced.
  local dupes
  dupes=$(jq -c '[.posts | group_by(.slug)[] | select(length > 1) | .[0].slug]' "$file")
  if [ "$(jq 'length' <<<"$dupes")" -gt 0 ]; then
    echo "error: ${file} holds more than one record for slug(s) ${dupes} — a slug identifies one post, so keep the record that matches the published post and remove the rest; see references/post-shapes-schema.md" >&2
    return 1
  fi

  local too_old
  too_old=$(jq -c --argjson min "$POST_SHAPES_MIN_SCHEMA" \
    '[ .posts | to_entries[] | select(.value.schema_version < $min) | .key ]' "$file")

  if [ "$(jq 'length' <<<"$too_old")" -gt 0 ]; then
    echo "error: ${file} holds record(s) at index ${too_old} with a schema_version below ${POST_SHAPES_MIN_SCHEMA}, which predates the documented schema and has no migration path — see references/post-shapes-schema.md and repair or remove them" >&2
    return 1
  fi

  jq -c \
    --argjson min "$POST_SHAPES_MIN_SCHEMA" \
    --argjson max "$POST_SHAPES_MAX_SCHEMA" \
    '{usable: [.posts[] | select(.schema_version >= $min and .schema_version <= $max)],
      skipped_newer: [.posts[] | select(.schema_version > $max)] | length}' "$file"
}
