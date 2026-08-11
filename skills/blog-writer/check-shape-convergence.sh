#!/usr/bin/env bash
#
# Compare a planned post's shape against recent history for audit 6 (shape
# convergence) in `references/structural-audits.md`.
#
# The skill supplies the shape it is planning; this script owns reading the
# history, deciding how many prior posts to compare, and applying the
# convergence predicate. The skill routes on the result rather than doing any
# of that itself.
#
# Usage:
#   check-shape-convergence.sh <shapes-file> <opening_mode> <arc> <closing_mode>
#
# Input:
#   $1  path to the shape history (conventionally `_blog-skill/post-shapes.json`)
#   $2  the planned opening mode
#   $3  the planned arc
#   $4  the planned closing mode
#
# Decision contract (this script owns these; callers must not restate them):
#   SUPPORTED_SCHEMA  highest per-record `schema_version` this script reads.
#                     Records above it are skipped, never rewritten.
#   WINDOW            how many of the most recent usable records to compare against.
#   MIN_HISTORY       fewest usable records that permit a verdict. Below it the
#                     audit cannot fire, which is the normal state for a new author.
#   An axis counts as converged when the planned value matches that axis in
#   EVERY compared record — so the rule is well-defined whether the window holds
#   MIN_HISTORY records or WINDOW of them.
#   CONVERGED_AXES_REQUIRED  converged axes needed before the verdict is `true`.
#
# Output (stdout), a single JSON object:
#   {"ok": true, "can_fire": bool, "reason": "<why>", "compared": N,
#    "converged": bool, "converged_axes": ["opening_mode", ...],
#    "skipped_newer_records": N}
#
#   can_fire  false means there is not enough usable history for a verdict.
#             `converged` is false in that case and carries no meaning.
#
# Exit codes:
#   0  the reported result is authoritative, including can_fire=false
#   1  the history file exists but cannot be used (unreadable, or not valid JSON,
#      or not the documented shape) — distinct from absent, which is exit 0
#   2  tool or usage error (jq missing, wrong argument count)
#
# Read-only: never creates, edits, or migrates the history file. Writing is
# `record-post-shape.sh`.

set -euo pipefail

readonly SUPPORTED_SCHEMA=1
readonly WINDOW=3
readonly MIN_HISTORY=2
readonly CONVERGED_AXES_REQUIRED=2

if ! command -v jq >/dev/null; then
  echo "error: jq not found on PATH — required to read the shape history and emit JSON" >&2
  exit 2
fi

if [ "$#" -ne 4 ]; then
  echo "error: expected 4 arguments, got $# — usage: check-shape-convergence.sh <shapes-file> <opening_mode> <arc> <closing_mode>" >&2
  exit 2
fi

readonly SHAPES_FILE=$1
readonly PLANNED_OPENING=$2
readonly PLANNED_ARC=$3
readonly PLANNED_CLOSING=$4

emit() {
  jq -n \
    --argjson can_fire "$1" \
    --arg reason "$2" \
    --argjson compared "$3" \
    --argjson converged "$4" \
    --argjson converged_axes "$5" \
    --argjson skipped "$6" \
    '{ok: true, can_fire: $can_fire, reason: $reason, compared: $compared,
      converged: $converged, converged_axes: $converged_axes,
      skipped_newer_records: $skipped}'
}

# An absent history file is the normal first-post state, not a failure.
if [ ! -e "$SHAPES_FILE" ]; then
  emit false "no shape history at ${SHAPES_FILE} — audit 6 cannot fire until ${MIN_HISTORY} posts are recorded" 0 false '[]' 0
  exit 0
fi

if [ ! -r "$SHAPES_FILE" ]; then
  echo "error: ${SHAPES_FILE} exists but is not readable — fix its permissions (chmod +r) or move it aside; refusing to treat an unreadable history as an absent one" >&2
  exit 1
fi

if ! jq -e 'type == "object" and (.posts | type) == "array"' "$SHAPES_FILE" >/dev/null 2>/tmp/shape-jq-err.$$; then
  rm -f "/tmp/shape-jq-err.$$"
  echo "error: ${SHAPES_FILE} is not valid JSON in the documented shape (an object with a \"posts\" array) — see references/post-shapes-schema.md and repair or remove the file" >&2
  exit 1
fi
rm -f "/tmp/shape-jq-err.$$"

total_records=$(jq '.posts | length' "$SHAPES_FILE")
usable=$(jq --argjson max "$SUPPORTED_SCHEMA" \
  '[.posts[] | select((.schema_version // 0) <= $max)]' "$SHAPES_FILE")
usable_count=$(jq 'length' <<<"$usable")
skipped=$((total_records - usable_count))

if [ "$skipped" -gt 0 ]; then
  echo "warning: skipped ${skipped} record(s) in ${SHAPES_FILE} written by a newer skill version (schema_version above ${SUPPORTED_SCHEMA}) — update the blog-writer plugin to read them; they were left untouched" >&2
fi

if [ "$usable_count" -lt "$MIN_HISTORY" ]; then
  emit false "only ${usable_count} usable record(s) in ${SHAPES_FILE} — audit 6 needs ${MIN_HISTORY}" \
    "$usable_count" false '[]' "$skipped"
  exit 0
fi

window=$(jq --argjson n "$WINDOW" '.[-$n:]' <<<"$usable")
compared=$(jq 'length' <<<"$window")

converged_axes=$(jq -c \
  --arg opening "$PLANNED_OPENING" \
  --arg arc "$PLANNED_ARC" \
  --arg closing "$PLANNED_CLOSING" \
  '[
     {axis: "opening_mode", planned: $opening},
     {axis: "arc",          planned: $arc},
     {axis: "closing_mode", planned: $closing}
   ]
   | map(select(. as $a | ($in | all(.[$a.axis] == $a.planned))) | .axis)
  ' --argjson in "$window" <<<'null')

converged_count=$(jq 'length' <<<"$converged_axes")
if [ "$converged_count" -ge "$CONVERGED_AXES_REQUIRED" ]; then
  converged=true
  reason="planned shape matches ${converged_count} axis/axes across all ${compared} compared post(s) — vary one before locking the outline"
else
  converged=false
  reason="planned shape differs from the last ${compared} post(s) on enough axes"
fi

emit true "$reason" "$compared" "$converged" "$converged_axes" "$skipped"
