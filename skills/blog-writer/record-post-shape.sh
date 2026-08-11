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
#   2  tool or environment error (jq missing, too few arguments, malformed date,
#      destination directory missing, the staged file cannot be created or
#      written — unwritable directory, path too long, filesystem full — or the
#      staged file cannot be moved into place)
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
# author's history. When the destination is a symlink, the staging and the move
# happen at its target, so the link survives the write rather than being replaced
# by a regular file.

# Shell options are set inside main() rather than at file scope: the entry-point
# guard below makes this file sourceable, and a sourced file must not change the
# caller's shell options.

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=skills/blog-writer/post-shapes-lib.sh
. "${SCRIPT_DIR}/post-shapes-lib.sh"

# Assigned inside main but declared here: the EXIT trap runs after main returns,
# so a local would be out of scope exactly when cleanup needs it.
staging=""

main() {
  set -euo pipefail

  if ! command -v jq >/dev/null; then
    echo "error: jq not found on PATH — required to write the shape history as JSON" >&2
    exit 2
  fi

  if [ "$#" -lt 6 ]; then
    echo "error: expected at least 6 arguments, got $# — usage: record-post-shape.sh <shapes-file> <slug> <date> <opening_mode> <arc> <closing_mode> [intervention ...]" >&2
    exit 2
  fi

  local SHAPES_FILE=$1
  local SLUG=$2
  local DATE=$3
  local OPENING=$4
  local ARC=$5
  local CLOSING=$6
  shift 6
  local interventions=("$@")
  local action existing loaded newer write_target link_target destination_dir count
  # `staging` stays global on purpose: the EXIT trap runs after main returns, so a
  # local would be out of scope exactly when cleanup needs it.

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

  # A history kept on a synced drive is reachable through a symlink, the same shape
  # the persona directory uses. Staging beside the LINK and moving onto it would
  # replace the link with a regular file and orphan the real history, so resolve
  # the link first and write to the target it points at.
  write_target=$SHAPES_FILE
  if [ -L "$SHAPES_FILE" ]; then
    link_target=$(readlink "$SHAPES_FILE")
    case "$link_target" in
      /*) write_target=$link_target ;;
      *)  write_target="$(dirname "$SHAPES_FILE")/${link_target}" ;;
    esac
  fi

  destination_dir=$(dirname "$write_target")
  if [ ! -d "$destination_dir" ]; then
    echo "error: directory ${destination_dir} does not exist — create the Blog Home Directory before recording a post's shape" >&2
    exit 2
  fi

  # mktemp rather than a `$$`-suffixed name: a PID repeats, so a predictable path
  # could collide with a stale file, and a pre-created symlink at that path would
  # redirect the write outside the history's directory entirely.
  if ! staging=$(mktemp "${write_target}.staging.XXXXXX"); then
    echo "error: cannot create a staging file beside ${write_target} — check that $(dirname "$write_target") is writable (chmod u+w) and that the path length is within the filesystem's limit" >&2
    exit 2
  fi
  # Guarded rather than relying on `rm -f` to be harmless: when the staging path is
  # itself unusable (too long for the filesystem), `rm` fails, and under `set -e`
  # that aborts the trap before `return 0` — so the trap would rewrite the script's
  # exit status with rm's, which is exactly what `return 0` is here to prevent.
  cleanup() {
    if [ -e "$staging" ]; then
      rm -f "$staging"
    fi
    return 0
  }
  trap cleanup EXIT



  # The existing history goes through stdin, not --argjson: as it grows, passing it
  # as a command-line argument would eventually exceed the argv size limit and fail
  # on a file that is perfectly valid.
  if ! printf '%s' "$existing" | jq \
    --argjson schema "$POST_SHAPES_MAX_SCHEMA" \
    --arg slug "$SLUG" \
    --arg date "$DATE" \
    --arg opening "$OPENING" \
    --arg arc "$ARC" \
    --arg closing "$CLOSING" \
    --args \
    '.posts = ((.posts | map(select(.slug != $slug))) + [{
         schema_version: $schema,
         slug: $slug,
         date: $date,
         opening_mode: $opening,
         arc: $arc,
         closing_mode: $closing,
         interventions: $ARGS.positional
       }])
     | .posts |= sort_by(.date)' "${interventions[@]+"${interventions[@]}"}" >"$staging"; then
    echo "error: failed to write the updated shape history for ${SHAPES_FILE} — the existing file was left untouched; check for a full filesystem or a jq failure" >&2
    exit 2
  fi

  if ! mv "$staging" "$write_target"; then
    echo "error: could not move the staged history into place at ${write_target} — the existing file was left untouched" >&2
    exit 2
  fi

  count=$(jq '.posts | length' "$SHAPES_FILE")
  jq -n \
    --arg action "$action" \
    --argjson count "$count" \
    --argjson schema "$POST_SHAPES_MAX_SCHEMA" \
    --arg path "$SHAPES_FILE" \
    '{ok: true, action: $action, count: $count, schema_version: $schema, path: $path}'
}

# Entry-point guard per `jbaruch/coding-policy: file-hygiene` — the script runs when
# executed and stays sourceable for testing or reuse.
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main "$@"
fi
