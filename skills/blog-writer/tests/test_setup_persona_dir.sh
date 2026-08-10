#!/usr/bin/env bash
# Outcome-based tests for setup-persona-dir.sh.
#
# Covers behaviors the script promises in its header contract:
#   1. Default — no argument creates the canonical path as a real directory and
#      reports kind=directory, action=created.
#   2. Custom target — an argument creates that directory and makes the canonical
#      path a symlink to it, reporting kind=symlink, action=linked.
#   3. Idempotence (directory) — a second no-argument run reports unchanged.
#   4. Idempotence (symlink) — a re-run over an established symlink reports
#      unchanged and does NOT repoint it, so an existing persona is never orphaned.
#   5. Dangling symlink — a canonical path pointing nowhere exits 1 rather than
#      silently replacing the author's link.
#   6. Occupied by a file — a regular file at the canonical path exits 1.
#   7. Probe — --probe reports state, creates nothing, and tracks voice_ready
#      against voice.md's contents; it rejects a target path.
#   8. Arg-count validation — more than one argument exits 2 with usage.
#
# Approach: each case runs with HOME pointed at a fresh temp directory, so the
# canonical path is real but disposable and no test can touch the developer's
# actual persona. No network, no clock, no randomness.
#
# Run: bash skills/blog-writer/tests/test_setup_persona_dir.sh

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly SCRIPT="${SCRIPT_DIR}/setup-persona-dir.sh"

pass_count=0
fail_count=0

fail() {
  echo "    FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

ok() {
  pass_count=$((pass_count + 1))
}

# Runs the script with HOME isolated to a fresh directory. Sets CASE_HOME,
# CASE_OUT, CASE_ERR and CASE_RC for the assertions that follow.
run_case() {
  local name=$1; shift
  local expect_rc=$1; shift

  CASE_HOME=$(mktemp -d)
  local err_file="${CASE_HOME}.err"

  echo "  ${name}"
  CASE_OUT=$(HOME="$CASE_HOME" "$SCRIPT" "$@" 2>"$err_file")
  CASE_RC=$?
  CASE_ERR=$(cat "$err_file")
  rm -f "$err_file"

  if [ "$CASE_RC" -ne "$expect_rc" ]; then
    fail "expected exit ${expect_rc}, got ${CASE_RC} (stderr: ${CASE_ERR})"
    return 1
  fi
  ok
  return 0
}

# Re-invokes the script against the same HOME, for the idempotence cases.
rerun_in_case() {
  local err_file="${CASE_HOME}.err2"
  CASE_OUT=$(HOME="$CASE_HOME" "$SCRIPT" "$@" 2>"$err_file")
  CASE_RC=$?
  CASE_ERR=$(cat "$err_file")
  rm -f "$err_file"
}

assert_json() {
  local filter=$1 expected=$2 label=$3 actual
  actual=$(jq -r "$filter" <<<"$CASE_OUT")
  if [ "$actual" != "$expected" ]; then
    fail "${label}: expected '${expected}', got '${actual}'"
  else
    ok
  fi
}

echo "test_setup_persona_dir"

# 1. Default — real directory
if run_case "default: creates the canonical path as a directory" 0; then
  assert_json '.kind' directory "kind"
  assert_json '.action' created "action"
  if [ ! -d "${CASE_HOME}/.claude/blog-writer-persona" ]; then
    fail "canonical path was not created"
  elif [ -L "${CASE_HOME}/.claude/blog-writer-persona" ]; then
    fail "canonical path is a symlink but no target was requested"
  else
    ok
  fi
fi
rm -rf "${CASE_HOME:?}"

# 2. Custom target — symlink
custom_root=$(mktemp -d)
custom_target="${custom_root}/persona"
if run_case "custom target: links the canonical path to it" 0 "$custom_target"; then
  assert_json '.kind' symlink "kind"
  assert_json '.action' linked "action"
  if [ ! -L "${CASE_HOME}/.claude/blog-writer-persona" ]; then
    fail "canonical path is not a symlink"
  else
    ok
  fi
  if [ ! -d "$custom_target" ]; then
    fail "target directory was not created"
  else
    ok
  fi
  # The link must resolve to the requested target, not merely exist.
  linked=$(cd "${CASE_HOME}/.claude/blog-writer-persona" && pwd -P)
  if [ "$linked" != "$(cd "$custom_target" && pwd -P)" ]; then
    fail "symlink resolves to ${linked}, not the requested target"
  else
    ok
  fi
fi
rm -rf "${CASE_HOME:?}" "${custom_root:?}"

# 3. Idempotence over a real directory
if run_case "idempotent: a second default run reports unchanged" 0; then
  rerun_in_case
  if [ "$CASE_RC" -ne 0 ]; then
    fail "re-run exited ${CASE_RC} (stderr: ${CASE_ERR})"
  else
    ok
  fi
  assert_json '.action' unchanged "action on re-run"
  assert_json '.kind' directory "kind on re-run"
fi
rm -rf "${CASE_HOME:?}"

# 4. Idempotence over a symlink — an established persona is never repointed
first_root=$(mktemp -d)
first_target="${first_root}/first"
second_root=$(mktemp -d)
second_target="${second_root}/second"
if run_case "idempotent: an established symlink is not repointed" 0 "$first_target"; then
  rerun_in_case "$second_target"
  if [ "$CASE_RC" -ne 0 ]; then
    fail "re-run exited ${CASE_RC} (stderr: ${CASE_ERR})"
  else
    ok
  fi
  assert_json '.action' unchanged "action on re-run"
  still=$(cd "${CASE_HOME}/.claude/blog-writer-persona" && pwd -P)
  if [ "$still" != "$(cd "$first_target" && pwd -P)" ]; then
    fail "re-run repointed the persona to ${still}, orphaning the original"
  else
    ok
  fi
  if [ -d "$second_target" ]; then
    fail "re-run created the second target even though the persona was established"
  else
    ok
  fi
fi
rm -rf "${CASE_HOME:?}" "${first_root:?}" "${second_root:?}"

# 5. Dangling symlink
dangling_home=$(mktemp -d)
mkdir -p "${dangling_home}/.claude"
ln -s "${dangling_home}/nowhere" "${dangling_home}/.claude/blog-writer-persona"
echo "  dangling symlink: exits 1 instead of replacing the author's link"
dangle_err="${dangling_home}.err"
HOME="$dangling_home" "$SCRIPT" >/dev/null 2>"$dangle_err"
dangle_rc=$?
if [ "$dangle_rc" -ne 1 ]; then
  fail "expected exit 1 on a dangling symlink, got ${dangle_rc}"
else
  ok
fi
if ! grep -q "target is missing" "$dangle_err"; then
  fail "stderr does not explain the dangling target, got: $(cat "$dangle_err")"
else
  ok
fi
if [ ! -L "${dangling_home}/.claude/blog-writer-persona" ]; then
  fail "the dangling symlink was removed rather than reported"
else
  ok
fi
rm -rf "$dangling_home" "$dangle_err"

# 6. Canonical path occupied by a regular file
file_home=$(mktemp -d)
mkdir -p "${file_home}/.claude"
printf 'not a directory' > "${file_home}/.claude/blog-writer-persona"
echo "  occupied by a file: exits 1"
file_err="${file_home}.err"
HOME="$file_home" "$SCRIPT" >/dev/null 2>"$file_err"
file_rc=$?
if [ "$file_rc" -ne 1 ]; then
  fail "expected exit 1 when a regular file occupies the path, got ${file_rc}"
else
  ok
fi
if [ "$(cat "${file_home}/.claude/blog-writer-persona")" != "not a directory" ]; then
  fail "the occupying file was modified"
else
  ok
fi
rm -rf "$file_home" "$file_err"

# 7. Probe — reports state without creating anything
if run_case "probe: reports a missing persona without creating it" 0 --probe; then
  assert_json '.exists' false "exists"
  assert_json '.action' probed "action"
  assert_json '.voice_ready' false "voice_ready"
  if [ -e "${CASE_HOME}/.claude/blog-writer-persona" ]; then
    fail "probe created the canonical path"
  else
    ok
  fi
fi
rm -rf "${CASE_HOME:?}"

# 7b. Probe — voice_ready tracks whether onboarding actually produced a profile
if run_case "probe: voice_ready is false until voice.md has content" 0; then
  : > "${CASE_HOME}/.claude/blog-writer-persona/voice.md"
  rerun_in_case --probe
  assert_json '.exists' true "exists with empty voice.md"
  assert_json '.voice_ready' false "voice_ready with empty voice.md"
  # A probe over an existing persona still reports `probed`, not `unchanged` —
  # the header promises the action names how the script was invoked.
  assert_json '.action' probed "action probing an existing directory"

  printf 'the author voice profile' > "${CASE_HOME}/.claude/blog-writer-persona/voice.md"
  rerun_in_case --probe
  assert_json '.voice_ready' true "voice_ready with populated voice.md"
  assert_json '.action' probed "action probing a populated persona"
fi
rm -rf "${CASE_HOME:?}"

# 7c. Probe rejects a target path rather than silently ignoring it
if run_case "probe: refuses a target path" 2 --probe /tmp/somewhere; then
  if ! grep -q "changes nothing" <<<"$CASE_ERR"; then
    fail "stderr does not explain that --probe is read-only, got: ${CASE_ERR}"
  else
    ok
  fi
fi
rm -rf "${CASE_HOME:?}"

# 7d. Probe over a symlinked persona reports `probed`, while a setup re-run over
# the same persona reports `unchanged` — the two invocations stay distinguishable.
symlink_root=$(mktemp -d)
symlink_target="${symlink_root}/persona"
if run_case "probe: a symlinked persona reports probed, setup reports unchanged" 0 "$symlink_target"; then
  rerun_in_case --probe
  assert_json '.kind' symlink "kind on probe"
  assert_json '.action' probed "action probing a symlinked persona"

  rerun_in_case
  assert_json '.action' unchanged "action on a setup re-run"
fi
rm -rf "${CASE_HOME:?}" "${symlink_root:?}"

# 8. Arg-count validation
if run_case "usage: two arguments exit 2" 2 one two; then
  if ! grep -q "usage" <<<"$CASE_ERR"; then
    fail "stderr does not carry usage text, got: ${CASE_ERR}"
  else
    ok
  fi
fi
rm -rf "${CASE_HOME:?}"

echo
echo "passed: ${pass_count}  failed: ${fail_count}"
[ "$fail_count" -eq 0 ]
