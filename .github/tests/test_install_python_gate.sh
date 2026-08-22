#!/usr/bin/env bash
# Outcome-based tests for .github/install-python-gate.sh.
#
# Covers the behaviors the script promises in its header contract:
#   1. Idempotence — an engine already at the pinned version is reported and no
#      installer runs.
#   2. Exact version matching — 0.9.50 does NOT satisfy a 0.9.5 pin. A substring
#      test accepted it and left the wrong release installed, defeating the pin.
#   3. Mismatch installs — a differing version invokes the installer.
#   4. Missing installer — no pipx, or no npm, exits 2 naming what to install.
#   5. Installer failure — a non-zero pipx or npm exits 2 rather than continuing
#      to a gate that would run whatever happens to be on PATH.
#   6. Post-install verification — an installer that "succeeds" without putting
#      the tool on PATH exits 2.
#   7. Entry-point guard — sourcing the script installs nothing and runs nothing.
#
# Approach: every engine and installer is a stub on a suite-owned PATH, so no
# case reaches the network, a real package index, or the developer's tools. Stub
# invocations are recorded to a log so "no installer ran" is asserted rather than
# assumed. No clock, no randomness.
#
# Run: bash .github/tests/test_install_python_gate.sh

# Shell options are set inside main() rather than at file scope: the entry-point
# guard below makes this file sourceable, and a sourced file must not change the
# caller's shell options.
#
# The suite drops `-e` under `jbaruch/coding-policy: error-handling`'s
# aggregate-reporting carve-out — each case is independent, every exit code is
# captured explicitly, and main() returns non-zero if any case failed.

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly SCRIPT="${SCRIPT_DIR}/install-python-gate.sh"

pass_count=0
fail_count=0

fail() {
  echo "    FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

ok() {
  pass_count=$((pass_count + 1))
}

# Writes a stub named $1 that prints $2 and exits $3, recording its invocation.
stub() {
  local name=$1 output=$2 code=$3
  cat >"${CASE_BIN}/${name}" <<STUB
#!/usr/bin/env bash
echo "${name} \$*" >>"${CASE_LOG}"
[ -n "${output}" ] && echo "${output}"
exit ${code}
STUB
  chmod +x "${CASE_BIN}/${name}"
}

# Fresh PATH holding only the stubs a case defines, plus the real coreutils the
# script needs (awk, head, command).
new_case() {
  CASE_BIN=$(mktemp -d "${SUITE_TMP}/bin.XXXXXX")
  CASE_LOG="${CASE_BIN}/invocations.log"
  : >"$CASE_LOG"
}

run_script() {
  CASE_OUT=$(PATH="${CASE_BIN}:/usr/bin:/bin" bash "$SCRIPT" 2>"${CASE_BIN}/err")
  CASE_RC=$?
  CASE_ERR=$(cat "${CASE_BIN}/err")
}

assert_rc() {
  local label=$1 want=$2
  if [ "$CASE_RC" -ne "$want" ]; then
    fail "${label}: expected exit ${want}, got ${CASE_RC} (stderr: ${CASE_ERR})"
    return 1
  fi
  ok
  return 0
}

assert_ran() {
  local label=$1 needle=$2
  if ! grep -q "$needle" "$CASE_LOG"; then
    fail "${label}: expected '${needle}' to run, log holds: $(tr '\n' ';' <"$CASE_LOG")"
    return 1
  fi
  ok
}

assert_not_ran() {
  local label=$1 needle=$2
  if grep -q "$needle" "$CASE_LOG"; then
    fail "${label}: '${needle}' ran but should not have"
    return 1
  fi
  ok
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

  echo "test_install_python_gate"

  # The pins the script declares. Read from the script rather than restated, so
  # a bump does not silently strand this suite on the old values.
  local ruff_pin pyright_pin
  ruff_pin=$(grep -m1 '^readonly RUFF_VERSION=' "$SCRIPT" | cut -d= -f2)
  pyright_pin=$(grep -m1 '^readonly PYRIGHT_VERSION=' "$SCRIPT" | cut -d= -f2)
  if [ -z "$ruff_pin" ] || [ -z "$pyright_pin" ]; then
    echo "error: could not read the pinned versions from ${SCRIPT} — the readonly declarations moved or changed shape" >&2
    exit 1
  fi

  # 1. Both engines already pinned — nothing installs
  new_case
  stub ruff "ruff ${ruff_pin}" 0
  stub pyright "pyright ${pyright_pin}" 0
  stub pipx "" 0
  stub npm "" 0
  run_script
  if assert_rc "already pinned" 0; then
    assert_not_ran "already pinned" "pipx install"
    assert_not_ran "already pinned" "npm install"
    if ! grep -q "already present" <<<"$CASE_OUT"; then
      fail "already pinned: stdout does not report the engines as present, got: ${CASE_OUT}"
    else
      ok
    fi
  fi
  echo "  both engines already pinned: nothing installs"

  # 2. Exact matching — a longer version sharing the pin as a prefix is NOT it
  new_case
  stub ruff "ruff ${ruff_pin}0" 0
  stub pyright "pyright ${pyright_pin}" 0
  stub pipx "" 0
  stub npm "" 0
  run_script
  if assert_rc "substring near-miss" 0; then
    assert_ran "substring near-miss" "pipx install"
  fi
  echo "  ${ruff_pin}0 does not satisfy the ${ruff_pin} pin"

  # 3. A plainly different version installs
  new_case
  stub ruff "ruff 0.1.0" 0
  stub pyright "pyright 1.0.0" 0
  stub pipx "" 0
  stub npm "" 0
  run_script
  if assert_rc "version mismatch" 0; then
    assert_ran "version mismatch" "pipx install"
    assert_ran "version mismatch" "npm install"
  fi
  echo "  a differing version installs both engines"

  # 4. Missing installers
  new_case
  stub ruff "ruff 0.1.0" 0
  stub pyright "pyright ${pyright_pin}" 0
  stub npm "" 0
  run_script
  if assert_rc "pipx missing" 2; then
    if ! grep -q "pipx not found" <<<"$CASE_ERR"; then
      fail "pipx missing: stderr does not name pipx, got: ${CASE_ERR}"
    else
      ok
    fi
  fi
  echo "  a missing pipx exits 2 naming pipx"

  new_case
  stub ruff "ruff ${ruff_pin}" 0
  stub pyright "pyright 1.0.0" 0
  stub pipx "" 0
  run_script
  if assert_rc "npm missing" 2; then
    if ! grep -q "npm not found" <<<"$CASE_ERR"; then
      fail "npm missing: stderr does not name npm, got: ${CASE_ERR}"
    else
      ok
    fi
  fi
  echo "  a missing npm exits 2 naming npm"

  # 5. Installer failures
  new_case
  stub ruff "ruff 0.1.0" 0
  stub pyright "pyright ${pyright_pin}" 0
  stub pipx "" 1
  stub npm "" 0
  run_script
  if assert_rc "pipx fails" 2; then
    if ! grep -q "could not install ruff" <<<"$CASE_ERR"; then
      fail "pipx fails: stderr does not report the ruff install failure, got: ${CASE_ERR}"
    else
      ok
    fi
  fi
  echo "  a failing pipx exits 2"

  new_case
  stub ruff "ruff ${ruff_pin}" 0
  stub pyright "pyright 1.0.0" 0
  stub pipx "" 0
  stub npm "" 1
  run_script
  if assert_rc "npm fails" 2; then
    if ! grep -q "could not install pyright" <<<"$CASE_ERR"; then
      fail "npm fails: stderr does not report the pyright install failure, got: ${CASE_ERR}"
    else
      ok
    fi
  fi
  echo "  a failing npm exits 2"

  # 6. An installer that reports success without putting the tool on PATH
  new_case
  stub pyright "pyright ${pyright_pin}" 0
  stub pipx "" 0
  stub npm "" 0
  run_script
  if assert_rc "install leaves nothing on PATH" 2; then
    if ! grep -q "still not on PATH" <<<"$CASE_ERR"; then
      fail "install leaves nothing on PATH: stderr does not report it, got: ${CASE_ERR}"
    else
      ok
    fi
  fi
  echo "  an install that leaves nothing on PATH exits 2"

  # 7. Entry-point guard
  new_case
  local sourced_out
  sourced_out=$(PATH="${CASE_BIN}:/usr/bin:/bin" bash -c "source '$SCRIPT'" 2>&1)
  if [ -n "$sourced_out" ]; then
    fail "sourcing the script produced output: ${sourced_out}"
  elif [ -s "$CASE_LOG" ]; then
    fail "sourcing the script invoked: $(tr '\n' ';' <"$CASE_LOG")"
  else
    ok
    echo "  sourcing the script runs nothing"
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
