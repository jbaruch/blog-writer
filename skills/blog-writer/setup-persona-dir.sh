#!/usr/bin/env bash
#
# Establish the persona directory the skill reads its voice profile from.
#
# The canonical location is `$HOME/.claude/blog-writer-persona`. It is either a
# real directory or a symlink pointing at wherever the author keeps the files
# (a synced drive, a dotfiles repo). The skill always resolves `persona/` to the
# canonical path, so the symlink is what makes a custom location work.
#
# Usage:
#   setup-persona-dir.sh --probe          report the persona state, change nothing
#   setup-persona-dir.sh [target-path]    establish the persona directory
#
# Input:
#   --probe  read-only. Reports whether the persona exists and whether the voice
#            profile has content, so the caller routes on this result instead of
#            performing its own filesystem checks.
#   $1       optional path to hold the persona files. When given, it is created
#            if missing and the canonical path becomes a symlink to it. When
#            omitted, the canonical path is created as a real directory.
#
# Output (stdout), a single JSON object:
#   {"ok": true, "path": "<canonical>", "exists": bool, "kind": "directory|symlink|none",
#    "target": "<resolved target>", "voice_ready": bool,
#    "action": "created|linked|unchanged|probed"}
#
#   exists       the canonical path is present and usable
#   voice_ready  voice.md is present and non-empty — the caller's signal that
#                onboarding has already been completed
#   action       `unchanged` when the canonical path already existed, which makes
#                re-running safe: an established persona is never relinked or
#                replaced. `probed` under --probe, which never writes.
#
# Exit codes:
#   0  the reported state is authoritative (under --probe, even when nothing exists)
#   1  the canonical path exists but is unusable (a regular file, or a dangling symlink)
#   2  tool or usage error (jq missing, bad arguments, mkdir/ln failed)
#
# Idempotent: a second run with the same arguments reports `unchanged` and
# touches nothing.

# Shell options are set inside main() rather than at file scope: the entry-point
# guard below makes this file sourceable, and a sourced file must not change the
# caller's shell options.

readonly CANONICAL="${HOME}/.claude/blog-writer-persona"

main() {
  set -euo pipefail

  if ! command -v jq >/dev/null; then
    echo "error: jq not found on PATH — required to emit the result as JSON" >&2
    exit 2
  fi

  probe_only=0
  if [ "${1:-}" = "--probe" ]; then
    probe_only=1
    shift
  fi

  if [ "$#" -gt 1 ]; then
    echo "error: expected at most one argument (target path), got $# — usage: setup-persona-dir.sh [--probe] [target-path]" >&2
    exit 2
  fi

  if [ "$probe_only" -eq 1 ] && [ "$#" -eq 1 ]; then
    echo "error: --probe takes no target path — it reports state and changes nothing" >&2
    exit 2
  fi

  # voice.md carries the author's voice profile. Present-and-non-empty is what
  # distinguishes a finished onboarding from a directory that merely exists, and
  # deciding it here keeps the caller out of the filesystem.
  voice_ready() {
    if [ -s "${CANONICAL}/voice.md" ]; then
      echo true
    else
      echo false
    fi
  }

  emit() {
    jq -n \
      --arg path "$CANONICAL" \
      --argjson exists "$1" \
      --arg kind "$2" \
      --arg target "$3" \
      --argjson voice_ready "$4" \
      --arg action "$5" \
      '{ok: true, path: $path, exists: $exists, kind: $kind, target: $target, voice_ready: $voice_ready, action: $action}'
  }

  # `probed` under --probe, `unchanged` under a setup run that found the persona
  # already in place. Both describe "nothing was written", but the caller routes on
  # them differently, so they stay distinct.
  if [ "$probe_only" -eq 1 ]; then
    found_action=probed
  else
    found_action=unchanged
  fi

  # An existing persona is authoritative. Re-pointing it on a re-run would orphan
  # the author's voice profile, so the only job here is to confirm it is usable.
  if [ -L "$CANONICAL" ]; then
    if [ ! -d "$CANONICAL" ]; then
      echo "error: ${CANONICAL} is a symlink whose target is missing — repoint it at the persona directory, or remove it and re-run" >&2
      exit 1
    fi
    resolved=$(cd "$CANONICAL" && pwd -P)
    emit true symlink "$resolved" "$(voice_ready)" "$found_action"
    exit 0
  fi

  if [ -d "$CANONICAL" ]; then
    resolved=$(cd "$CANONICAL" && pwd -P)
    emit true directory "$resolved" "$(voice_ready)" "$found_action"
    exit 0
  fi

  if [ -e "$CANONICAL" ]; then
    echo "error: ${CANONICAL} exists but is not a directory or symlink — move it aside and re-run" >&2
    exit 1
  fi

  # Nothing is there. A probe reports that and stops; only a setup run creates.
  if [ "$probe_only" -eq 1 ]; then
    emit false none "" false probed
    exit 0
  fi

  parent=$(dirname "$CANONICAL")
  if ! mkdir -p "$parent"; then
    echo "error: could not create ${parent} — check permissions on \$HOME and re-run" >&2
    exit 2
  fi

  if [ "$#" -eq 1 ]; then
    target=$1
    if ! mkdir -p "$target"; then
      echo "error: could not create the target directory ${target} — check the path and permissions" >&2
      exit 2
    fi
    resolved=$(cd "$target" && pwd -P)
    if ! ln -s "$resolved" "$CANONICAL"; then
      echo "error: could not link ${CANONICAL} to ${resolved}" >&2
      exit 2
    fi
    emit true symlink "$resolved" "$(voice_ready)" linked
    exit 0
  fi

  if ! mkdir -p "$CANONICAL"; then
    echo "error: could not create ${CANONICAL} — check permissions on \$HOME and re-run" >&2
    exit 2
  fi
  resolved=$(cd "$CANONICAL" && pwd -P)
  emit true directory "$resolved" "$(voice_ready)" created
}

# Entry-point guard per `jbaruch/coding-policy: file-hygiene` — the script runs when
# executed and stays sourceable for testing or reuse.
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main "$@"
fi
