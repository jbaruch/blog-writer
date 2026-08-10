#!/usr/bin/env bash
# Outcome-based tests for fetch-signs-of-ai-writing.sh.
#
# Covers behaviors the script promises in its header contract:
#   1. Success — HTTP 200 with a body over the size floor emits
#      {"ok": true, "path": ..., "bytes": N} and exits 0; the file holds the body.
#   2. HTTP error — a non-200 status exits 1 with a diagnostic naming the code.
#   3. Transport failure — curl itself failing exits 1 with a diagnostic.
#   4. Short body — HTTP 200 under the byte floor exits 1 rather than passing an
#      error stub off as the article.
#   5. Explicit destination — a caller-supplied path is honoured and reported.
#   6. JSON escaping — a destination path containing a double quote still yields
#      parseable JSON whose .path round-trips exactly. This is the regression
#      test for the printf-interpolation bug.
#   7. Arg-count validation — more than one argument exits 2 with usage.
#   8. Bad destination — a directory that does not exist exits 2.
#
# Approach: put a stub `curl` first on PATH and invoke the real script as an
# executable, so the tests exercise the shipped file rather than a sourced copy.
# The stub reads its scripted behavior from env vars, so no test depends on the
# network, the clock, or randomness.
#
# Run: bash skills/blog-writer/tests/test_fetch_signs_of_ai_writing.sh

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly SCRIPT="${SCRIPT_DIR}/fetch-signs-of-ai-writing.sh"

pass_count=0
fail_count=0

fail() {
  echo "    FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

ok() {
  pass_count=$((pass_count + 1))
}

# Builds a stub `curl` on PATH. STUB_STATUS is the HTTP code it reports,
# STUB_BODY the bytes it writes to the --output path, STUB_RC its own exit code.
make_stub_bin() {
  local bin=$1
  mkdir -p "$bin"
  cat > "${bin}/curl" <<'STUB'
#!/usr/bin/env bash
set -uo pipefail
out=""
prev=""
for arg in "$@"; do
  if [ "$prev" = "--output" ]; then out=$arg; fi
  prev=$arg
done
if [ -n "${STUB_BODY:-}" ] && [ -n "$out" ]; then
  printf '%s' "$STUB_BODY" > "$out"
fi
if [ "${STUB_RC:-0}" -ne 0 ]; then
  echo "stub curl: simulated transport failure" >&2
  exit "${STUB_RC}"
fi
printf '%s' "${STUB_STATUS:-200}"
STUB
  chmod +x "${bin}/curl"
}

long_body() {
  # Deterministic filler comfortably above the script's 1000-byte floor.
  printf 'signs of ai writing %.0s' $(seq 1 200)
}

run_case() {
  local name=$1; shift
  local expect_rc=$1; shift
  local stub_status=$1; shift
  local stub_rc=$1; shift
  local body=$1; shift

  local tmp bin rc out err
  tmp=$(mktemp -d)
  bin="${tmp}/bin"
  make_stub_bin "$bin"

  out=$(STUB_STATUS="$stub_status" STUB_RC="$stub_rc" STUB_BODY="$body" \
    PATH="${bin}:${PATH}" "$SCRIPT" "$@" 2>"${tmp}/err")
  rc=$?
  err=$(cat "${tmp}/err")

  echo "  ${name}"
  if [ "$rc" -ne "$expect_rc" ]; then
    fail "expected exit ${expect_rc}, got ${rc} (stderr: ${err})"
    rm -rf "$tmp"
    return 1
  fi
  ok
  LAST_STDOUT=$out
  LAST_STDERR=$err
  LAST_TMP=$tmp
  return 0
}

echo "test_fetch_signs_of_ai_writing"

# 1. Success
if run_case "success: 200 with a full body exits 0" 0 200 0 "$(long_body)"; then
  if ! jq -e '.ok == true' >/dev/null 2>&1 <<<"$LAST_STDOUT"; then
    fail "stdout is not JSON with .ok true, got: ${LAST_STDOUT}"
  else
    ok
  fi
  path=$(jq -r '.path' <<<"$LAST_STDOUT")
  if [ ! -s "$path" ]; then
    fail "reported path is missing or empty: ${path}"
  else
    ok
  fi
  bytes=$(jq -r '.bytes' <<<"$LAST_STDOUT")
  actual=$(wc -c < "$path" | tr -d ' ')
  if [ "$bytes" != "$actual" ]; then
    fail "reported bytes ${bytes} does not match file size ${actual}"
  else
    ok
  fi
  rm -rf "$LAST_TMP"
fi

# 2. HTTP error
if run_case "http error: 503 exits 1" 1 503 0 "$(long_body)"; then
  if ! grep -q "503" <<<"$LAST_STDERR"; then
    fail "stderr does not name the HTTP status, got: ${LAST_STDERR}"
  else
    ok
  fi
  rm -rf "$LAST_TMP"
fi

# 3. Transport failure
if run_case "transport failure: curl exit 7 exits 1" 1 200 7 ""; then
  if [ -z "$LAST_STDERR" ]; then
    fail "expected a stderr diagnostic on transport failure"
  else
    ok
  fi
  rm -rf "$LAST_TMP"
fi

# 4. Short body
if run_case "short body: 200 under the floor exits 1" 1 200 0 "too short"; then
  if ! grep -q "floor" <<<"$LAST_STDERR"; then
    fail "stderr does not explain the size floor, got: ${LAST_STDERR}"
  else
    ok
  fi
  rm -rf "$LAST_TMP"
fi

# 5. Explicit destination honoured
dest_tmp=$(mktemp -d)
if run_case "explicit destination is honoured" 0 200 0 "$(long_body)" "${dest_tmp}/article.txt"; then
  if [ "$(jq -r '.path' <<<"$LAST_STDOUT")" != "${dest_tmp}/article.txt" ]; then
    fail "reported path is not the requested destination, got: ${LAST_STDOUT}"
  else
    ok
  fi
  if [ ! -s "${dest_tmp}/article.txt" ]; then
    fail "requested destination was not written"
  else
    ok
  fi
  rm -rf "$LAST_TMP"
fi
rm -rf "$dest_tmp"

# 6. JSON escaping regression — a quote in the path must not break the contract
quote_tmp=$(mktemp -d)
weird_path="${quote_tmp}/we\"ird.txt"
if run_case "json escaping: a quote in the path still yields valid JSON" 0 200 0 "$(long_body)" "$weird_path"; then
  if ! jq -e . >/dev/null 2>&1 <<<"$LAST_STDOUT"; then
    fail "stdout is not parseable JSON when the path contains a quote, got: ${LAST_STDOUT}"
  else
    ok
  fi
  if [ "$(jq -r '.path' <<<"$LAST_STDOUT")" != "$weird_path" ]; then
    fail "path did not round-trip through JSON, got: $(jq -r '.path' <<<"$LAST_STDOUT" 2>/dev/null)"
  else
    ok
  fi
  rm -rf "$LAST_TMP"
fi
rm -rf "$quote_tmp"

# 7. Arg-count validation
if run_case "usage: two arguments exit 2" 2 200 0 "$(long_body)" one two; then
  if ! grep -q "usage" <<<"$LAST_STDERR"; then
    fail "stderr does not carry usage text, got: ${LAST_STDERR}"
  else
    ok
  fi
  rm -rf "$LAST_TMP"
fi

# 8. Bad destination directory
if run_case "bad destination: missing directory exits 2" 2 200 0 "$(long_body)" "/nonexistent-dir-for-tests/out.txt"; then
  if ! grep -q "does not exist" <<<"$LAST_STDERR"; then
    fail "stderr does not explain the missing directory, got: ${LAST_STDERR}"
  else
    ok
  fi
  rm -rf "$LAST_TMP"
fi

echo
echo "passed: ${pass_count}  failed: ${fail_count}"
[ "$fail_count" -eq 0 ]
