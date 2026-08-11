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
#   9. Atomicity — a failed fetch leaves an existing destination file byte-for-byte
#      intact and strands no staging file beside it.
#  10. Interrupt — a SIGTERM mid-fetch removes the script-owned staging file
#      via the EXIT trap rather than stranding it.
#  11. Hygiene — no default-named temp file is left in TMPDIR once the suite
#      finishes, covering both the script's own failure-path cleanup and the
#      success path whose reported file the caller owns.
#
# Approach: put a stub `curl` first on PATH and invoke the real script as an
# executable, so the tests exercise the shipped file rather than a sourced copy.
# The stub reads its scripted behavior from env vars, so no test depends on the
# network, the clock, or randomness.
#
# Run: bash skills/blog-writer/tests/test_fetch_signs_of_ai_writing.sh

# Shell options are set inside main() rather than at file scope: the entry-point
# guard below makes this file sourceable, and a sourced file must not change the
# caller's shell options.

# Every case directory is created inside one suite-owned root, so a single EXIT
# trap removes them all. `return 0` keeps cleanup from rewriting the suite's exit
# status (`jbaruch/coding-policy: error-handling`).


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
  # Brace expansion rather than $(seq ...) — bash-native, one less external
  # command, and portable to systems without seq.
  printf 'signs of ai writing %.0s' {1..200}
}

run_case() {
  local name=$1; shift
  local expect_rc=$1; shift
  local stub_status=$1; shift
  local stub_rc=$1; shift
  local body=$1; shift

  local tmp bin rc out err
  tmp=$(mktemp -d "${SUITE_TMP}/case.XXXXXX")
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

# Removes the case directory and any file the script reported on stdout. Without
# a destination argument the script mktemps outside the case directory, so
# dropping only LAST_TMP would strand that file in TMPDIR.
cleanup_case() {
  local reported
  # Failure cases print nothing, so only parse when there is stdout to parse.
  # jq's own diagnostic stays visible: unparseable stdout from a case that was
  # supposed to emit JSON is a real signal, not noise to be silenced.
  if [ -n "${LAST_STDOUT:-}" ]; then
    reported=$(jq -r '.path // empty' <<<"$LAST_STDOUT")
    if [ -n "$reported" ]; then
      rm -f "$reported"
    fi
  fi
  if [ -n "${LAST_TMP:-}" ]; then
    rm -rf "$LAST_TMP"
  fi
  LAST_STDOUT=""
  LAST_TMP=""
}

# Counts leftover script-named temp files, so a leak shows up as a test failure
# rather than as silent litter in TMPDIR. find's diagnostic is surfaced and its
# exit status checked: an unreadable TMPDIR would otherwise yield an empty count
# and let the hygiene assertion pass on a directory it never actually read.
count_stray_temps() {
  local dir=${TMPDIR:-/tmp} out status
  out=$(find "$dir" -maxdepth 1 -name '*signs-of-ai-writing.*')
  status=$?
  if [ "$status" -ne 0 ]; then
    echo "error: could not scan ${dir} for stray temp files (find exited ${status}) — the hygiene check cannot be trusted" >&2
    return 1
  fi
  if [ -z "$out" ]; then
    echo 0
  else
    printf '%s\n' "$out" | wc -l | tr -d ' '
  fi
}

main() {
  set -uo pipefail

  if ! SUITE_TMP=$(mktemp -d); then
    echo "error: could not create the suite temp directory — check TMPDIR is writable" >&2
    exit 1
  fi
  cleanup_suite_tmp() {
    rm -rf "$SUITE_TMP"
    return 0
  }
  trap cleanup_suite_tmp EXIT

  if ! strays_before=$(count_stray_temps); then
    echo "    FAIL: could not establish the temp-file baseline" >&2
    exit 1
  fi

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
    cleanup_case
  fi

  # 2. HTTP error
  if run_case "http error: 503 exits 1" 1 503 0 "$(long_body)"; then
    if ! grep -q "503" <<<"$LAST_STDERR"; then
      fail "stderr does not name the HTTP status, got: ${LAST_STDERR}"
    else
      ok
    fi
    cleanup_case
  fi

  # 3. Transport failure
  if run_case "transport failure: curl exit 7 exits 1" 1 200 7 ""; then
    if [ -z "$LAST_STDERR" ]; then
      fail "expected a stderr diagnostic on transport failure"
    else
      ok
    fi
    cleanup_case
  fi

  # 4. Short body
  if run_case "short body: 200 under the floor exits 1" 1 200 0 "too short"; then
    if ! grep -q "floor" <<<"$LAST_STDERR"; then
      fail "stderr does not explain the size floor, got: ${LAST_STDERR}"
    else
      ok
    fi
    cleanup_case
  fi

  # 5. Explicit destination honoured
  dest_tmp=$(mktemp -d "${SUITE_TMP}/case.XXXXXX")
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
    cleanup_case
  fi
  rm -rf "$dest_tmp"

  # 6. JSON escaping regression — a quote in the path must not break the contract
  quote_tmp=$(mktemp -d "${SUITE_TMP}/case.XXXXXX")
  weird_path="${quote_tmp}/we\"ird.txt"
  if run_case "json escaping: a quote in the path still yields valid JSON" 0 200 0 "$(long_body)" "$weird_path"; then
    if ! jq -e . >/dev/null 2>&1 <<<"$LAST_STDOUT"; then
      fail "stdout is not parseable JSON when the path contains a quote, got: ${LAST_STDOUT}"
    else
      ok
    fi
    round_tripped=$(jq -r '.path' <<<"$LAST_STDOUT")
    if [ "$round_tripped" != "$weird_path" ]; then
      fail "path did not round-trip through JSON, got: ${round_tripped}"
    else
      ok
    fi
    cleanup_case
  fi
  rm -rf "$quote_tmp"

  # 6b. Atomicity — a failed fetch must not disturb an existing destination file.
  atomic_tmp=$(mktemp -d "${SUITE_TMP}/case.XXXXXX")
  printf 'original contents' > "${atomic_tmp}/existing.txt"
  if run_case "atomicity: a failed fetch leaves the destination untouched" 1 503 0 "$(long_body)" "${atomic_tmp}/existing.txt"; then
    if [ "$(cat "${atomic_tmp}/existing.txt")" != "original contents" ]; then
      fail "a failed fetch modified the caller's file, got: $(cat "${atomic_tmp}/existing.txt")"
    else
      ok
    fi
    remaining=$(find "$atomic_tmp" -name '.signs-of-ai-writing.*')
    if [ -n "$remaining" ]; then
      fail "staging file left beside the destination: ${remaining}"
    else
      ok
    fi
    cleanup_case
  fi
  rm -rf "$atomic_tmp"

  # 6c. Interrupt — the EXIT trap must remove the staging file when the script is
  # killed mid-fetch, not only on its own explicit error branches.
  #
  # Synchronisation is a FIFO rendezvous, not a timed guess: the stub publishes its
  # PID once the fetch is under way, which is after the script created its staging
  # file. Both processes are then signalled, because bash defers a trapped signal
  # until its foreground child returns — killing only the script would leave it
  # blocked in the curl call with the TERM still pending.
  interrupt_tmp=$(mktemp -d "${SUITE_TMP}/case.XXXXXX")
  mkfifo "${interrupt_tmp}/ready"
  mkfifo "${interrupt_tmp}/block"
  cat > "${interrupt_tmp}/curl" <<'SLOWSTUB'
#!/usr/bin/env bash
# Stands in for a fetch still running when the signal arrives.
set -uo pipefail
echo "$$" > "${READY_FIFO}"
# Blocks in the kernel on a FIFO nobody writes — no polling, no CPU spin.
read -r _ < "${BLOCK_FIFO}"
SLOWSTUB
  chmod +x "${interrupt_tmp}/curl"
  echo "  interrupt: the staging file is removed when the script is killed"

  READY_FIFO="${interrupt_tmp}/ready" BLOCK_FIFO="${interrupt_tmp}/block" \
    PATH="${interrupt_tmp}:${PATH}" \
    "$SCRIPT" "${interrupt_tmp}/dest.txt" >/dev/null 2>&1 &
  victim=$!

  # Blocks until the stub announces itself — a happens-after edge on the staging
  # file's creation, with no dependence on scheduling or the clock.
  read -r stub_pid < "${interrupt_tmp}/ready"

  kill -TERM "$victim"
  kill -TERM "$stub_pid"

  victim_status=0
  wait "$victim" || victim_status=$?
  # The script maps TERM to exit 143, so that is the only status this case accepts.
  if [ "$victim_status" -ne 143 ]; then
    fail "expected the interrupted script to exit 143, got ${victim_status}"
  else
    ok
  fi

  stranded=$(find "$interrupt_tmp" -name '.signs-of-ai-writing.*')
  if [ -n "$stranded" ]; then
    fail "staging file survived an interrupt: ${stranded}"
  else
    ok
  fi
  rm -rf "$interrupt_tmp"

  # 7. Arg-count validation
  if run_case "usage: two arguments exit 2" 2 200 0 "$(long_body)" one two; then
    if ! grep -q "usage" <<<"$LAST_STDERR"; then
      fail "stderr does not carry usage text, got: ${LAST_STDERR}"
    else
      ok
    fi
    cleanup_case
  fi

  # 8. Bad destination directory
  if run_case "bad destination: missing directory exits 2" 2 200 0 "$(long_body)" "/nonexistent-dir-for-tests/out.txt"; then
    if ! grep -q "does not exist" <<<"$LAST_STDERR"; then
      fail "stderr does not explain the missing directory, got: ${LAST_STDERR}"
    else
      ok
    fi
    cleanup_case
  fi

  # 9. No stray temp files — the script removes its own mktemp file on failure,
  # and the tests remove the one it reports on success.
  echo "  hygiene: no default-named temp files are stranded"
  if ! strays_after=$(count_stray_temps); then
    fail "could not scan for stray temp files after the run"
  elif [ "$strays_after" != "$strays_before" ]; then
    fail "temp files leaked: ${strays_before} before, ${strays_after} after"
  else
    ok
  fi

  echo
  echo "passed: ${pass_count}  failed: ${fail_count}"
  [ "$fail_count" -eq 0 ]
}

# Entry-point guard per `jbaruch/coding-policy: file-hygiene` — the suite runs when
# executed and stays sourceable, so nothing happens merely by loading this file.
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main "$@"
fi
