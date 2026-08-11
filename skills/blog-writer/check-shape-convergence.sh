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
#   WINDOW            how many of the most recent usable records to compare
#                     against, selected by `date` rather than by file order.
#   MIN_HISTORY       fewest usable records that permit a verdict. Below it the
#                     audit cannot fire, which is the normal state for a new author.
#   An axis counts as converged when the planned value matches that axis in
#   EVERY compared record — so the rule is well-defined whether the window holds
#   MIN_HISTORY records or WINDOW of them.
#   CONVERGED_AXES_REQUIRED  converged axes needed before the verdict is `true`.
#   Accepted schema versions and the per-record field contract live in
#   post-shapes-lib.sh, shared with the writer so the two cannot drift.
#
# Every record is validated before any verdict is computed: a history that does
# not match its documented schema is reported, never silently averaged over.
#
# Output (stdout), a single JSON object:
#   {"ok": true, "can_fire": bool, "blocked_by": "<code>"|null, "reason": "<why>",
#    "compared": N, "converged": bool, "converged_axes": ["opening_mode", ...],
#    "compared_posts": [{"slug", "date", "opening_mode", "arc", "closing_mode",
#                        "interventions"}],
#    "skipped_newer_records": N}
#
#   can_fire        false means no verdict is possible. `converged` is false in
#                   that case and carries no meaning.
#   blocked_by      why no verdict was possible, so the caller can route without
#                   parsing prose: `no_history` (nothing recorded yet),
#                   `insufficient_history` (some records, too few),
#                   `newer_records` (a newer plugin wrote part of it, so this
#                   install cannot read the most recent). null when can_fire is
#                   true. The three need different remediation, so they are
#                   distinguished rather than collapsed.
#   compared_posts  the records the verdict was computed from, identified so the
#                   caller can check each recalled shape against the actual post
#                   before acting (`stateful-artifacts`: hints, not authority).
#                   Each entry is the complete record, so correcting a wrong one
#                   through the writer cannot drop a field. Empty when can_fire
#                   is false.
#
# Exit codes:
#   0  the reported result is authoritative, including can_fire=false
#   1  the history file exists but cannot be used (unreadable, or not valid JSON,
#      or not the documented shape) — distinct from absent, which is exit 0
#   2  tool or usage error (jq missing, wrong argument count)
#
# Read-only: never creates, edits, or migrates the history file. Writing is
# `record-post-shape.sh`.

# Shell options are set inside main() rather than at file scope: the entry-point
# guard below makes this file sourceable, and a sourced file must not change the
# caller's shell options.

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=skills/blog-writer/post-shapes-lib.sh
. "${SCRIPT_DIR}/post-shapes-lib.sh"

readonly WINDOW=3
readonly MIN_HISTORY=2
readonly CONVERGED_AXES_REQUIRED=2

main() {
  set -euo pipefail

  if ! command -v jq >/dev/null; then
    echo "error: jq not found on PATH — required to read the shape history and emit JSON" >&2
    exit 2
  fi

  if [ "$#" -ne 4 ]; then
    echo "error: expected 4 arguments, got $# — usage: check-shape-convergence.sh <shapes-file> <opening_mode> <arc> <closing_mode>" >&2
    exit 2
  fi

  local SHAPES_FILE=$1
  local PLANNED_OPENING=$2
  local PLANNED_ARC=$3
  local PLANNED_CLOSING=$4
  local loaded usable usable_count skipped window compared converged_axes converged_count converged reason

  emit() {
    jq -n \
      --argjson can_fire "$1" \
      --arg reason "$2" \
      --argjson compared "$3" \
      --argjson converged "$4" \
      --argjson converged_axes "$5" \
      --argjson skipped "$6" \
      --arg blocked_by "$7" \
      --argjson compared_posts "$8" \
      '{ok: true, can_fire: $can_fire, blocked_by: (if $blocked_by == "" then null else $blocked_by end),
        reason: $reason, compared: $compared, converged: $converged,
        converged_axes: $converged_axes, compared_posts: $compared_posts,
        skipped_newer_records: $skipped}'
  }

  # A dangling symlink is an existing-but-broken setup, not an absent history.
  # `-e` is false for one, so it would otherwise collapse into the empty case and
  # hide a real problem — the same distinction the unreadable case below draws.
  if [ -L "$SHAPES_FILE" ] && [ ! -e "$SHAPES_FILE" ]; then
    echo "error: ${SHAPES_FILE} is a symlink whose target is missing — repoint or remove it; refusing to treat a broken link as an absent history" >&2
    exit 1
  fi

  # An absent history file is the normal first-post state, not a failure.
  if [ ! -e "$SHAPES_FILE" ]; then
    emit false "no shape history at ${SHAPES_FILE} — audit 6 cannot fire until ${MIN_HISTORY} posts are recorded" 0 false '[]' 0 no_history '[]'
    exit 0
  fi

  if [ ! -r "$SHAPES_FILE" ]; then
    echo "error: ${SHAPES_FILE} exists but is not readable — fix its permissions (chmod u+r) or move it aside; refusing to treat an unreadable history as an absent one" >&2
    exit 1
  fi

  if ! loaded=$(post_shapes_load "$SHAPES_FILE"); then
    exit 1
  fi

  usable=$(jq -c '.usable' <<<"$loaded")
  usable_count=$(jq 'length' <<<"$usable")
  skipped=$(jq '.skipped_newer' <<<"$loaded")

  # A newer record means this install is lagging, not that the history is partly
  # valid. The records it can still parse are the OLDER ones, so a verdict built
  # from them would describe ancient history while claiming to describe the most
  # recent posts. The whole history is unusable until the plugin is updated
  # (`jbaruch/coding-policy: stateful-artifacts`, Migration Policy).
  if [ "$skipped" -gt 0 ]; then
    echo "warning: ${SHAPES_FILE} holds ${skipped} record(s) written by a newer skill version (schema_version above ${POST_SHAPES_MAX_SCHEMA}) — update the blog-writer plugin to read them; they were left untouched" >&2
    emit false "${skipped} record(s) in ${SHAPES_FILE} were written by a newer skill version, so the most recent history cannot be read — update the blog-writer plugin; a verdict from the remaining older records would describe the wrong posts" \
      0 false '[]' "$skipped" newer_records '[]'
    exit 0
  fi

  if [ "$usable_count" -lt "$MIN_HISTORY" ]; then
    emit false "only ${usable_count} usable record(s) in ${SHAPES_FILE} — audit 6 needs ${MIN_HISTORY}" \
      "$usable_count" false '[]' "$skipped" insufficient_history '[]'
    exit 0
  fi

  # Sorted here rather than trusting file order: the writer keeps the history in
  # date order, but a hand edit, a bad merge, or an older tool could leave it out
  # of order, and the window must mean "most recent" whatever the file says.
  window=$(jq --argjson n "$WINDOW" 'sort_by(.date) | .[-$n:]' <<<"$usable")
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

  local compared_posts
  # interventions rides along: the caller corrects a wrong record by re-recording
  # it through the writer, and a re-record without them would silently blank the
  # field. Reporting the complete record is what makes the correction lossless.
  compared_posts=$(jq -c '[.[] | {slug, date, opening_mode, arc, closing_mode, interventions}]' <<<"$window")

  emit true "$reason" "$compared" "$converged" "$converged_axes" "$skipped" "" "$compared_posts"
}

# Entry-point guard per `jbaruch/coding-policy: file-hygiene` — the script runs when
# executed and stays sourceable for testing or reuse.
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main "$@"
fi
