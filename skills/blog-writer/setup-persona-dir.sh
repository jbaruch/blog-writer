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
#   setup-persona-dir.sh [target-path]
#
# Input:
#   $1  optional path to hold the persona files. When given, it is created if
#       missing and the canonical path becomes a symlink to it. When omitted,
#       the canonical path is created as a real directory.
#
# Output (stdout), a single JSON object:
#   {"ok": true, "path": "<canonical>", "kind": "directory|symlink",
#    "target": "<resolved target>", "action": "created|linked|unchanged"}
#
#   action is `unchanged` when the canonical path already existed, which makes
#   re-running safe: an established persona is never relinked or replaced.
#
# Exit codes:
#   0  the canonical path exists and is usable
#   1  it exists but is unusable (a regular file, or a symlink that dangles)
#   2  tool or usage error (jq missing, too many arguments, mkdir/ln failed)
#
# Idempotent: a second run with the same arguments reports `unchanged` and
# touches nothing.

set -euo pipefail

readonly CANONICAL="${HOME}/.claude/blog-writer-persona"

if ! command -v jq >/dev/null; then
  echo "error: jq not found on PATH — required to emit the result as JSON" >&2
  exit 2
fi

if [ "$#" -gt 1 ]; then
  echo "error: expected at most one argument (target path), got $# — usage: setup-persona-dir.sh [target-path]" >&2
  exit 2
fi

emit() {
  jq -n \
    --arg path "$CANONICAL" \
    --arg kind "$1" \
    --arg target "$2" \
    --arg action "$3" \
    '{ok: true, path: $path, kind: $kind, target: $target, action: $action}'
}

# An existing persona is authoritative. Re-pointing it on a re-run would orphan
# the author's voice profile, so the only job here is to confirm it is usable.
if [ -L "$CANONICAL" ]; then
  if [ ! -d "$CANONICAL" ]; then
    echo "error: ${CANONICAL} is a symlink whose target is missing — repoint it at the persona directory, or remove it and re-run" >&2
    exit 1
  fi
  resolved=$(cd "$CANONICAL" && pwd -P)
  emit symlink "$resolved" unchanged
  exit 0
fi

if [ -d "$CANONICAL" ]; then
  resolved=$(cd "$CANONICAL" && pwd -P)
  emit directory "$resolved" unchanged
  exit 0
fi

if [ -e "$CANONICAL" ]; then
  echo "error: ${CANONICAL} exists but is not a directory or symlink — move it aside and re-run" >&2
  exit 1
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
  emit symlink "$resolved" linked
  exit 0
fi

if ! mkdir -p "$CANONICAL"; then
  echo "error: could not create ${CANONICAL} — check permissions on \$HOME and re-run" >&2
  exit 2
fi
resolved=$(cd "$CANONICAL" && pwd -P)
emit directory "$resolved" created
