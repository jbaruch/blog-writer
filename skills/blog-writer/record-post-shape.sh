#!/usr/bin/env bash
#
# Append a finished post's structural skeleton to the shape history that backs
# audit 6 (shape convergence) in `references/structural-audits.md`.
#
# The skill supplies the shape the post ended up with; this script owns the
# record format, the schema stamp, the clobber guard, and the append itself.
#
# Usage:
#   record-post-shape.sh <shapes-file> <slug> <date> <opening_mode> <arc> \
#                        <closing_mode> [intervention ...]
#
# Input:
#   $1   path to the shape history (conventionally `_blog-skill/post-shapes.json`)
#   $2   the post's slug, matching its draft filename
#   $3   the date the post was finished, YYYY-MM-DD. Passed in rather than read
#        from the clock so a caller can record a post finished earlier and so
#        the tests stay deterministic.
#   $4   how the post opens
#   $5   the post's section spine
#   $6   how the post ends
#   $7+  optional intervention-menu moves used, one per argument
#
# Decision contract (this script owns these; callers must not restate them):
#   The `schema_version` stamped on new records, the accepted version range, and
#   the per-record field contract live in post-shapes-lib.sh, shared with the
#   reader so the two cannot drift. A history holding any record above the
#   accepted range is refused, never rewritten.
#
# Every existing record is validated before anything is appended: a history that
# does not match its documented schema is refused rather than extended, so a
# corrupt file is never made larger.
#
# Output (stdout), a single JSON object:
#   {"ok": true, "action": "created|appended|updated", "count": N,
#    "schema_version": N, "path": "<shapes-file>"}
#
#   action  `updated` when a record for this slug already existed. Recording is
#           idempotent by slug: a re-run replaces that post's record rather than
#           adding a second one, so re-running Step 12 after a late revision
#           corrects the history instead of corrupting the convergence window.
#
# Exit codes:
#   0  the record was written
#   1  the history file exists but cannot be used (unreadable, not valid JSON,
#      not the documented shape, or holds a record from a newer skill version).
#      Nothing is written in this case — a newer history is never clobbered.
#   2  tool or usage error (jq missing, too few arguments, malformed date,
#      destination directory missing or not writable)
#
# Idempotent by slug: re-recording the same post replaces its record rather than
# appending a duplicate, so a re-run cannot skew the convergence window.
#
# Keeps the history sorted by `date`, so the "newest last" invariant the reader
# depends on holds even when a post finished earlier is recorded after a later
# one. jq's sort is stable, so same-date records keep their insertion order.
#
# Writes atomically: the new history is staged beside the destination and moved
# into place only after jq succeeds, so an interrupted run cannot truncate an
# author's history.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=skills/blog-writer/post-shapes-lib.sh
. "${SCRIPT_DIR}/post-shapes-lib.sh"

if ! command -v jq >/dev/null; then
  echo "error: jq not found on PATH — required to write the shape history as JSON" >&2
  exit 2
fi

if [ "$#" -lt 6 ]; then
  echo "error: expected at least 6 arguments, got $# — usage: record-post-shape.sh <shapes-file> <slug> <date> <opening_mode> <arc> <closing_mode> [intervention ...]" >&2
  exit 2
fi

SHAPES_FILE=$1
SLUG=$2
DATE=$3
OPENING=$4
ARC=$5
CLOSING=$6
shift 6
interventions=("$@")

readonly SHAPES_FILE SLUG DATE OPENING ARC CLOSING

if ! printf '%s' "$DATE" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
  echo "error: date '${DATE}' is not YYYY-MM-DD — pass the date the post was finished, e.g. 2026-08-11" >&2
  exit 2
fi

if [ -z "$SLUG" ]; then
  echo "error: slug is empty — pass the post's slug, matching its draft filename" >&2
  exit 2
fi

action=created
existing='{"posts":[]}'

if [ -L "$SHAPES_FILE" ] && [ ! -e "$SHAPES_FILE" ]; then
  echo "error: ${SHAPES_FILE} is a symlink whose target is missing — repoint or remove it; refusing to write through a broken link" >&2
  exit 1
fi

if [ -e "$SHAPES_FILE" ]; then
  if [ ! -r "$SHAPES_FILE" ] || [ ! -w "$SHAPES_FILE" ]; then
    echo "error: ${SHAPES_FILE} exists but is not both readable and writable — fix its permissions (chmod u+rw) before recording; refusing to treat it as absent" >&2
    exit 1
  fi

  if ! loaded=$(post_shapes_load "$SHAPES_FILE"); then
    echo "error: refusing to append to ${SHAPES_FILE} until the problem above is fixed — the file was left untouched" >&2
    exit 1
  fi

  newer=$(jq '.skipped_newer' <<<"$loaded")
  if [ "$newer" -gt 0 ]; then
    echo "error: ${SHAPES_FILE} holds ${newer} record(s) written by a newer skill version (schema_version above ${POST_SHAPES_MAX_SCHEMA}) — update the blog-writer plugin before recording; refusing to write and risk losing them" >&2
    exit 1
  fi

  existing=$(cat "$SHAPES_FILE")
  if [ "$(jq --arg slug "$SLUG" '[.posts[] | select(.slug == $slug)] | length' "$SHAPES_FILE")" -gt 0 ]; then
    action=updated
  else
    action=appended
  fi
fi

staging="${SHAPES_FILE}.staging.$$"
cleanup() {
  rm -f "$staging"
  return 0
}
trap cleanup EXIT

destination_dir=$(dirname "$SHAPES_FILE")
if [ ! -d "$destination_dir" ]; then
  echo "error: directory ${destination_dir} does not exist — create the Blog Home Directory before recording a post's shape" >&2
  exit 2
fi

# Checked before staging rather than discovered at `mv`, so an unwritable
# directory reports as the environment problem it is (exit 2) instead of
# surfacing mv's status as though the history itself were unusable (exit 1).
if [ ! -w "$destination_dir" ]; then
  echo "error: directory ${destination_dir} is not writable — fix its permissions (chmod u+w) before recording a post's shape" >&2
  exit 2
fi

if ! jq -n \
  --argjson existing "$existing" \
  --argjson schema "$POST_SHAPES_MAX_SCHEMA" \
  --arg slug "$SLUG" \
  --arg date "$DATE" \
  --arg opening "$OPENING" \
  --arg arc "$ARC" \
  --arg closing "$CLOSING" \
  --args \
  '$existing
   | .posts = ((.posts | map(select(.slug != $slug))) + [{
       schema_version: $schema,
       slug: $slug,
       date: $date,
       opening_mode: $opening,
       arc: $arc,
       closing_mode: $closing,
       interventions: $ARGS.positional
     }])
   | .posts |= sort_by(.date)' "${interventions[@]+"${interventions[@]}"}" >"$staging"; then
  echo "error: failed to build the updated shape history for ${SHAPES_FILE} — the existing file was left untouched" >&2
  exit 1
fi

if ! mv "$staging" "$SHAPES_FILE"; then
  echo "error: could not move the staged history into place at ${SHAPES_FILE} — the existing file was left untouched" >&2
  exit 2
fi

count=$(jq '.posts | length' "$SHAPES_FILE")
jq -n \
  --arg action "$action" \
  --argjson count "$count" \
  --argjson schema "$POST_SHAPES_MAX_SCHEMA" \
  --arg path "$SHAPES_FILE" \
  '{ok: true, action: $action, count: $count, schema_version: $schema, path: $path}'
