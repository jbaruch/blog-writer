#!/usr/bin/env bash
#
# Fetch the raw wikitext of Wikipedia's "Signs of AI writing" article.
#
# Wikipedia blocks the standard WebFetch user agent, so the article is pulled
# over HTTP with an explicit browser user agent and the `action=raw` endpoint.
# The article is community-maintained and changes as LLM writing patterns
# change, which is why the skill re-reads it instead of trusting a snapshot.
#
# Usage:
#   fetch-signs-of-ai-writing.sh [output-path]
#
# Input:
#   $1  optional destination path. Defaults to a mktemp file. The article runs
#       well past a comfortable inline read, so output always lands in a file
#       and the path is what comes back on stdout.
#
# The fetch is atomic with respect to the destination: the download lands in a
# script-owned staging file beside it and is moved into place only after the
# status and size checks pass. A failed or truncated fetch therefore never
# replaces or empties an existing file at the caller's path.
#
# Output (stdout):
#   On success, a single JSON object:
#     {"ok": true, "path": "<file>", "bytes": N}
#
# Exit codes:
#   0  fetched; the file at .path holds the raw wikitext
#   1  fetch failed (network unreachable, HTTP error, or empty body). The
#      caller proceeds with the existing anti-pattern file, which is
#      self-contained and does not depend on this check.
#   2  tool or usage error (curl missing, destination not writable)
#
# A non-zero exit is a real signal, never swallowed: the diagnostic goes to
# stderr and the caller decides. This script does not fall back silently.

set -euo pipefail

readonly ARTICLE_URL="https://en.wikipedia.org/w/index.php?title=Wikipedia:Signs_of_AI_writing&action=raw"
readonly USER_AGENT="Mozilla/5.0 (compatible; blog-writer-skill/1.0)"
readonly MIN_BYTES=1000

if ! command -v curl >/dev/null; then
  echo "error: curl not found on PATH — install curl, or skip the freshness check and proceed with references/ai-anti-patterns.md as-is" >&2
  exit 2
fi

# The success line is JSON, and the path is caller-supplied, so it goes through a
# real encoder. A path holding a quote, backslash, or newline would otherwise
# produce output that parses as something else, or not at all.
if ! command -v jq >/dev/null; then
  echo '{"ok": false, "reason": "jq not found on PATH — required to emit the result as JSON"}' >&2
  exit 2
fi

if [ "$#" -gt 1 ]; then
  echo "error: expected at most one argument (output path), got $# — usage: fetch-signs-of-ai-writing.sh [output-path]" >&2
  exit 2
fi

if [ "$#" -eq 1 ]; then
  out_path=$1
  out_dir=$(dirname "$out_path")
  if [ ! -d "$out_dir" ]; then
    echo "error: destination directory does not exist: ${out_dir} — create it or pass a different path" >&2
    exit 2
  fi
  if [ ! -w "$out_dir" ]; then
    echo "error: destination directory is not writable: ${out_dir}" >&2
    exit 2
  fi
else
  out_dir=${TMPDIR:-/tmp}
  out_path=""
fi

# The download always lands in a script-owned staging file, never on the
# caller's path. curl truncates its --output target the moment it starts
# writing, so pointing it at the destination would destroy an existing file
# before the status and size checks have decided whether the fetch is any good.
# The staging file is created alongside the destination so the final move is a
# same-filesystem rename rather than a copy that could half-finish.
if ! staging=$(mktemp "${out_dir}/.signs-of-ai-writing.XXXXXX"); then
  echo "error: could not create a staging file under ${out_dir}" >&2
  exit 2
fi

# The staging file is owned from creation until it either moves into place or
# the script ends. An EXIT trap covers every way out — an explicit error branch,
# an interrupt, or an unexpected failure under `set -e` in wc, tr, mv, or jq —
# so no exit path can strand it. Ownership is released the moment the file stops
# being staging: on a successful move it belongs to the caller's path, and with
# no destination the caller owns the staging file itself.
staging_owned=1

discard_staging() {
  if [ "$staging_owned" -eq 1 ] && [ -e "$staging" ]; then
    rm -f "$staging"
  fi
  return 0
}

trap discard_staging EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

http_status=0
if ! http_status=$(curl --silent --location --show-error \
  --user-agent "$USER_AGENT" \
  --max-time 30 \
  --write-out '%{http_code}' \
  --output "$staging" \
  "$ARTICLE_URL"); then
  echo "error: curl could not reach Wikipedia (network error or timeout) — proceed with references/ai-anti-patterns.md as-is" >&2
  exit 1
fi

if [ "$http_status" != "200" ]; then
  echo "error: Wikipedia returned HTTP ${http_status} for the article — proceed with references/ai-anti-patterns.md as-is" >&2
  exit 1
fi

bytes=$(wc -c < "$staging" | tr -d ' ')

if [ "$bytes" -lt "$MIN_BYTES" ]; then
  echo "error: fetched body is ${bytes} bytes, under the ${MIN_BYTES}-byte floor — the page is likely an error stub rather than the article; proceed with references/ai-anti-patterns.md as-is" >&2
  exit 1
fi

# Every validation passed, so the result is now fit to occupy the destination.
if [ -n "$out_path" ]; then
  if ! mv -f "$staging" "$out_path"; then
    echo "error: could not move the fetched article into place at ${out_path}" >&2
    exit 2
  fi
else
  out_path=$staging
fi

# The file is the caller's from here, by either route. Releasing ownership stops
# the EXIT trap from deleting the very result being reported.
staging_owned=0

jq -n --arg path "$out_path" --argjson bytes "$bytes" '{ok: true, path: $path, bytes: $bytes}'
