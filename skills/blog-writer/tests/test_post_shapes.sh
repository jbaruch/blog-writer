#!/usr/bin/env bash
# Outcome-based tests for check-shape-convergence.sh and record-post-shape.sh.
#
# Covers the behaviors the scripts promise in their header contracts:
#
# check-shape-convergence.sh
#   1. Absent history — exit 0 with can_fire=false. A first post has nothing to
#      compare against and must never block planning.
#   2. Malformed history — exit 1, NOT folded into the absent case. A corrupt
#      file is a visible failure, not "no history yet".
#   3. Wrong shape — an object without a `posts` array exits 1.
#   4. Below MIN_HISTORY — one record reports can_fire=false.
#   5. Exactly MIN_HISTORY — two records produce a real verdict. This is the
#      case where "matches across all three" was previously unsatisfiable.
#   6. Converged — enough axes matching every compared post reports converged.
#   7. Not converged — a single matching axis does not trip the verdict.
#   8. Window bound — records older than the window do not affect the verdict,
#      and the window is selected by date even when the file is out of order.
#   9. Newer records disable the verdict for the whole history — including when
#      enough older records remain readable, since those describe the wrong
#      posts and a lagging reader has no usable prior state.
#  10. Read-only — a check never modifies the history file.
#  11. Malformed records — a missing schema_version, a bad date, a mistyped
#      field, or a non-string intervention each exit 1 rather than producing an
#      authoritative verdict from state that does not match its schema.
#  12. Below-minimum schema — a record older than the documented schema has no
#      migration path and exits 1.
#  13. Duplicate slugs — two records for one post make the history ambiguous and
#      contradict the idempotent-by-slug contract, so it exits 1.
#  14. Dangling symlink — an existing-but-broken link exits 1 rather than
#      collapsing into the absent case.
#  15. Argument validation — wrong count exits 2.
#
# record-post-shape.sh
#  14. Creates a history that does not exist yet.
#  15. Appends to an existing history, keeping it sorted by date so a backfilled
#      earlier post does not break the reader's "newest last" window.
#  16. Every written record carries schema_version.
#  17. Interventions round-trip, and absent ones produce an empty array.
#  18. Newer-schema history is refused and left byte-identical (clobber guard).
#  19. Malformed history is refused and left byte-identical.
#  20. A history whose records lack schema_version is refused, not extended.
#  21. A history holding a malformed record is refused and left byte-identical.
#  22. Re-recording the same slug replaces its record rather than duplicating it,
#      so re-running the recording step cannot skew the convergence window.
#  23. An unwritable destination directory exits 2 (environment) rather than 1
#      (history unusable). Skipped with a visible note when the process can write
#      to a chmod a-w directory, which is the case as root.
#  24. A dangling symlink is refused rather than written through.
#  25. A valid symlink destination is written through to its target, leaving the
#      link intact and no staging file behind.
#  26. Date format is validated.
#  27. Empty slug is rejected.
#  28. Argument count is validated.
#
# Approach: every case runs in a fresh temp directory under one suite-owned root,
# so no test touches a real history file and the EXIT trap removes everything.
# Dates are fixed past literals passed as arguments; the scripts never read the
# clock, so these assertions are as true next year as today. No network, no
# randomness, no future dates.
#
# Run: bash skills/blog-writer/tests/test_post_shapes.sh

set -uo pipefail

# Every case directory is created inside one suite-owned root, so a single EXIT
# trap removes them all. `return 0` keeps cleanup from rewriting the suite's exit
# status (`jbaruch/coding-policy: error-handling`).
if ! SUITE_TMP=$(mktemp -d); then
  echo "error: could not create the suite temp directory — check TMPDIR is writable" >&2
  exit 1
fi
cleanup_suite_tmp() {
  rm -rf "$SUITE_TMP"
  return 0
}
trap cleanup_suite_tmp EXIT

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly CHECK="${SCRIPT_DIR}/check-shape-convergence.sh"
readonly RECORD="${SCRIPT_DIR}/record-post-shape.sh"

pass_count=0
fail_count=0

fail() {
  echo "    FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

ok() {
  pass_count=$((pass_count + 1))
}

CASE_DIR=""
CASE_OUT=""
CASE_ERR=""
CASE_RC=0

# Runs a script in a fresh temp directory. Sets CASE_OUT, CASE_ERR, CASE_RC.
run_case() {
  local name=$1; shift
  local expect_rc=$1; shift

  echo "  ${name}"
  local err_file
  err_file=$(mktemp "${SUITE_TMP}/err.XXXXXX")
  # The suite runs without errexit, so no save/restore is needed here. Enabling
  # it would leave errexit on for every later case.
  CASE_OUT=$("$@" 2>"$err_file")
  CASE_RC=$?
  CASE_ERR=$(cat "$err_file")
  rm -f "$err_file"

  if [ "$CASE_RC" -ne "$expect_rc" ]; then
    fail "${name}: expected exit ${expect_rc}, got ${CASE_RC} (stderr: ${CASE_ERR})"
    return 1
  fi
  ok
  return 0
}

new_dir() {
  CASE_DIR=$(mktemp -d "${SUITE_TMP}/case.XXXXXX")
}

# Builds a history file from a list of "opening|arc|closing" triples.
write_history() {
  local path=$1; shift
  local schema=$1; shift
  local records="[]"
  local i=0
  local triple
  for triple in "$@"; do
    local opening="${triple%%|*}"
    local rest="${triple#*|}"
    local arc="${rest%%|*}"
    local closing="${rest##*|}"
    i=$((i + 1))
    records=$(jq \
      --argjson schema "$schema" \
      --arg slug "post-${i}" \
      --arg date "2025-0${i}-01" \
      --arg opening "$opening" \
      --arg arc "$arc" \
      --arg closing "$closing" \
      '. += [{schema_version: $schema, slug: $slug, date: $date,
              opening_mode: $opening, arc: $arc, closing_mode: $closing,
              interventions: []}]' <<<"$records")
  done
  jq -n --argjson posts "$records" '{posts: $posts}' >"$path"
}

assert_json() {
  local label=$1 filter=$2 expected=$3
  local actual
  actual=$(jq -r "$filter" <<<"$CASE_OUT")
  if [ "$actual" != "$expected" ]; then
    fail "${label}: expected ${filter} == '${expected}', got '${actual}'"
  else
    ok
  fi
}

assert_contains() {
  local label=$1 haystack=$2 needle=$3
  case "$haystack" in
    *"$needle"*) ok ;;
    *) fail "${label}: expected text containing '${needle}', got '${haystack}'" ;;
  esac
}

echo "check-shape-convergence.sh"

new_dir
if run_case "absent history reports can_fire=false, not an error" 0 \
    bash "$CHECK" "${CASE_DIR}/missing.json" a b c; then
  assert_json "absent" '.can_fire' "false"
  assert_json "absent" '.compared' "0"
  assert_json "absent" '.ok' "true"
fi

new_dir
printf 'not json at all' >"${CASE_DIR}/bad.json"
if run_case "malformed history exits 1 rather than reading as absent" 1 \
    bash "$CHECK" "${CASE_DIR}/bad.json" a b c; then
  assert_contains "malformed" "$CASE_ERR" "not valid JSON"
fi

new_dir
printf '{"shapes":[]}' >"${CASE_DIR}/wrong.json"
run_case "history without a posts array exits 1" 1 \
  bash "$CHECK" "${CASE_DIR}/wrong.json" a b c

new_dir
write_history "${CASE_DIR}/one.json" 1 "emb|p->m|stop"
if run_case "one record is below the history minimum" 0 \
    bash "$CHECK" "${CASE_DIR}/one.json" emb "p->m" stop; then
  assert_json "one record" '.can_fire' "false"
fi

new_dir
write_history "${CASE_DIR}/two.json" 1 "emb|p->m|stop" "emb|p->m|stop"
if run_case "two records produce a verdict (the old unsatisfiable case)" 0 \
    bash "$CHECK" "${CASE_DIR}/two.json" emb "p->m" stop; then
  assert_json "two records" '.can_fire' "true"
  assert_json "two records" '.compared' "2"
  assert_json "two records" '.converged' "true"
fi

new_dir
write_history "${CASE_DIR}/three.json" 1 "emb|p->m|stop" "emb|p->m|open" "emb|p->m|hot"
if run_case "matching opening and arc across all three converges" 0 \
    bash "$CHECK" "${CASE_DIR}/three.json" emb "p->m" brand-new; then
  assert_json "converged" '.converged' "true"
  assert_json "converged" '.converged_axes | sort | join(",")' "arc,opening_mode"
fi

new_dir
write_history "${CASE_DIR}/vary.json" 1 "emb|p->m|stop" "cold|outcome|open" "named|delayed|hot"
if run_case "a single matching axis does not converge" 0 \
    bash "$CHECK" "${CASE_DIR}/vary.json" emb "brand-new" brand-new; then
  assert_json "not converged" '.converged' "false"
fi

# The writer keeps the file in date order, but a hand edit or a bad merge could
# not. "Most recent" must mean by date, not by position.
new_dir
jq -n '{posts: [
   {schema_version: 1, slug: "newest", date: "2025-09-01", opening_mode: "brand-new", arc: "brand-new", closing_mode: "brand-new", interventions: []},
   {schema_version: 1, slug: "a", date: "2025-01-01", opening_mode: "emb", arc: "p->m", closing_mode: "stop", interventions: []},
   {schema_version: 1, slug: "b", date: "2025-02-01", opening_mode: "emb", arc: "p->m", closing_mode: "stop", interventions: []}
 ]}' >"${CASE_DIR}/unsorted.json"
if run_case "an out-of-order history still windows by date" 0 \
    bash "$CHECK" "${CASE_DIR}/unsorted.json" emb "p->m" stop; then
  assert_json "unsorted" '.compared' "3"
  assert_json "unsorted" '.converged' "false"
fi

new_dir
write_history "${CASE_DIR}/window.json" 1 \
  "ancient|ancient|ancient" "emb|p->m|stop" "emb|p->m|open" "emb|p->m|hot"
if run_case "records older than the window do not affect the verdict" 0 \
    bash "$CHECK" "${CASE_DIR}/window.json" emb "p->m" brand-new; then
  assert_json "window" '.compared' "3"
  assert_json "window" '.converged' "true"
fi

new_dir
write_history "${CASE_DIR}/newer.json" 99 "emb|p->m|stop" "emb|p->m|stop"
if run_case "a history written entirely by a newer version cannot fire" 0 \
    bash "$CHECK" "${CASE_DIR}/newer.json" emb "p->m" stop; then
  assert_json "newer" '.skipped_newer_records' "2"
  assert_json "newer" '.can_fire' "false"
  assert_contains "newer" "$CASE_ERR" "newer skill version"
fi

# A lagging reader can only parse the OLDER records, so a verdict built from them
# would describe the wrong posts. Enough readable history must not rescue it.
new_dir
jq -n '{posts: [
   {schema_version: 1,  slug: "a", date: "2025-01-01", opening_mode: "emb", arc: "p->m", closing_mode: "stop", interventions: []},
   {schema_version: 1,  slug: "b", date: "2025-02-01", opening_mode: "emb", arc: "p->m", closing_mode: "stop", interventions: []},
   {schema_version: 99, slug: "c", date: "2025-03-01", opening_mode: "new", arc: "new", closing_mode: "new", interventions: []}
 ]}' >"${CASE_DIR}/mixed.json"
if run_case "one newer record disables the verdict even with readable history" 0 \
    bash "$CHECK" "${CASE_DIR}/mixed.json" emb "p->m" stop; then
  assert_json "mixed" '.skipped_newer_records' "1"
  assert_json "mixed" '.can_fire' "false"
  assert_json "mixed" '.converged' "false"
fi

new_dir
write_history "${CASE_DIR}/ro.json" 1 "emb|p->m|stop" "emb|p->m|stop"
before=$(cat "${CASE_DIR}/ro.json")
run_case "checking never modifies the history" 0 \
  bash "$CHECK" "${CASE_DIR}/ro.json" emb "p->m" stop
if [ "$(cat "${CASE_DIR}/ro.json")" = "$before" ]; then ok; else fail "read-only: the check modified the history file"; fi

new_dir
printf '{"posts":[{"slug":"a","date":"2025-01-01","opening_mode":"o","arc":"a","closing_mode":"c","interventions":[]}]}' >"${CASE_DIR}/nover.json"
if run_case "a record without schema_version is malformed, not version zero" 1 \
    bash "$CHECK" "${CASE_DIR}/nover.json" o a c; then
  assert_contains "no schema_version" "$CASE_ERR" "malformed record"
fi

new_dir
printf '{"posts":[{"schema_version":1,"slug":"a","date":"2025-01-01","opening_mode":"o","arc":"a","closing_mode":"c","interventions":[]},{"schema_version":1,"slug":"b","date":"not-a-date","opening_mode":"o","arc":"a","closing_mode":"c","interventions":[]}]}' >"${CASE_DIR}/baddate.json"
run_case "a record with a malformed date is rejected" 1 \
  bash "$CHECK" "${CASE_DIR}/baddate.json" o a c

new_dir
printf '{"posts":[{"schema_version":1,"slug":"a","date":"2025-01-01","opening_mode":"o","arc":"a","closing_mode":"c","interventions":[]},{"schema_version":1,"slug":"b","date":"2025-02-01","opening_mode":123,"arc":"a","closing_mode":"c","interventions":[]}]}' >"${CASE_DIR}/badtype.json"
run_case "a record with a mistyped field is rejected" 1 \
  bash "$CHECK" "${CASE_DIR}/badtype.json" o a c

new_dir
jq -n '{posts: [
   {schema_version: 1, slug: "same", date: "2025-01-01", opening_mode: "o", arc: "a", closing_mode: "c", interventions: []},
   {schema_version: 1, slug: "same", date: "2025-02-01", opening_mode: "o", arc: "a", closing_mode: "c", interventions: []}
 ]}' >"${CASE_DIR}/dupe.json"
if run_case "a history with duplicate slugs is ambiguous and rejected" 1 \
    bash "$CHECK" "${CASE_DIR}/dupe.json" o a c; then
  assert_contains "duplicate slugs" "$CASE_ERR" "more than one record for slug"
fi

new_dir
printf '{"posts":[{"schema_version":1,"slug":"a","date":"2025-01-01","opening_mode":"o","arc":"a","closing_mode":"c","interventions":[7]}]}' >"${CASE_DIR}/badiv.json"
run_case "a record with a non-string intervention is rejected" 1 \
  bash "$CHECK" "${CASE_DIR}/badiv.json" o a c

new_dir
printf '{"posts":[{"schema_version":0,"slug":"a","date":"2025-01-01","opening_mode":"o","arc":"a","closing_mode":"c","interventions":[]}]}' >"${CASE_DIR}/old.json"
if run_case "a record below the minimum schema has no migration path and is rejected" 1 \
    bash "$CHECK" "${CASE_DIR}/old.json" o a c; then
  assert_contains "below minimum" "$CASE_ERR" "below"
fi

new_dir
ln -s "${CASE_DIR}/nowhere.json" "${CASE_DIR}/dangling.json"
if run_case "a dangling symlink is reported, not read as absent" 1 \
    bash "$CHECK" "${CASE_DIR}/dangling.json" a b c; then
  assert_contains "dangling" "$CASE_ERR" "target is missing"
fi

new_dir
run_case "wrong argument count exits 2" 2 bash "$CHECK" "${CASE_DIR}/x.json" only-one

echo "record-post-shape.sh"

new_dir
if run_case "creates a history that does not exist yet" 0 \
    bash "$RECORD" "${CASE_DIR}/new.json" my-slug 2025-06-01 emb "p->m" stop; then
  assert_json "create" '.action' "created"
  assert_json "create" '.count' "1"
fi

if run_case "appends to an existing history" 0 \
    bash "$RECORD" "${CASE_DIR}/new.json" second 2025-06-02 cold outcome hot; then
  assert_json "append" '.action' "appended"
  assert_json "append" '.count' "2"
fi

written=$(jq -r '.posts[-1].slug' "${CASE_DIR}/new.json")
if [ "$written" = "second" ]; then ok; else fail "append: newest record is not last (got '${written}')"; fi

stamped=$(jq -r '[.posts[] | .schema_version] | unique | join(",")' "${CASE_DIR}/new.json")
if [ "$stamped" = "1" ]; then ok; else fail "schema stamp: every record should carry schema_version 1, got '${stamped}'"; fi

new_dir
run_case "interventions round-trip" 0 \
  bash "$RECORD" "${CASE_DIR}/iv.json" s 2025-06-01 a b c open-thread named-thing
got=$(jq -r '.posts[0].interventions | join(",")' "${CASE_DIR}/iv.json")
if [ "$got" = "open-thread,named-thing" ]; then ok; else fail "interventions: expected two recorded, got '${got}'"; fi

run_case "no interventions produces an empty array" 0 \
  bash "$RECORD" "${CASE_DIR}/iv.json" s2 2025-06-01 a b c
got=$(jq -r '.posts[1].interventions | length' "${CASE_DIR}/iv.json")
if [ "$got" = "0" ]; then ok; else fail "interventions: expected empty array, got length '${got}'"; fi

new_dir
write_history "${CASE_DIR}/guard.json" 99 "emb|p->m|stop"
before=$(cat "${CASE_DIR}/guard.json")
if run_case "refuses to write over a newer-schema history" 1 \
    bash "$RECORD" "${CASE_DIR}/guard.json" s 2025-06-01 a b c; then
  assert_contains "clobber guard" "$CASE_ERR" "newer skill version"
fi
if [ "$(cat "${CASE_DIR}/guard.json")" = "$before" ]; then ok; else fail "clobber guard: the history was modified"; fi

new_dir
printf 'garbage' >"${CASE_DIR}/bad.json"
before=$(cat "${CASE_DIR}/bad.json")
run_case "refuses to write over a malformed history" 1 \
  bash "$RECORD" "${CASE_DIR}/bad.json" s 2025-06-01 a b c
if [ "$(cat "${CASE_DIR}/bad.json")" = "$before" ]; then ok; else fail "malformed guard: the history was modified"; fi

new_dir
run_case "recording the same slug twice updates rather than duplicates" 0 \
  bash "$RECORD" "${CASE_DIR}/idem.json" same 2025-05-01 first-open first-arc first-close
if run_case "re-recording the same post reports updated" 0 \
    bash "$RECORD" "${CASE_DIR}/idem.json" same 2025-05-01 second-open second-arc second-close; then
  assert_json "idempotent" '.action' "updated"
  assert_json "idempotent" '.count' "1"
fi
kept=$(jq -r '.posts[0].opening_mode' "${CASE_DIR}/idem.json")
if [ "$kept" = "second-open" ]; then ok; else fail "idempotent: expected the re-run to replace the record, got opening_mode '${kept}'"; fi
total=$(jq '.posts | length' "${CASE_DIR}/idem.json")
if [ "$total" = "1" ]; then ok; else fail "idempotent: expected 1 record after a re-run, got ${total}"; fi

new_dir
mkdir -p "${CASE_DIR}/ro"
printf '{"posts":[]}' >"${CASE_DIR}/ro/s.json"
chmod a-w "${CASE_DIR}/ro"
if [ -w "${CASE_DIR}/ro" ]; then
  echo "    NOTE: running with write access to a chmod a-w directory (root?); skipping the unwritable-directory case" >&2
else
  run_case "an unwritable destination directory exits 2, not 1" 2 \
    bash "$RECORD" "${CASE_DIR}/ro/s.json" s 2025-06-01 a b c
fi
chmod u+w "${CASE_DIR}/ro"

new_dir
run_case "a backfilled earlier post lands in date order, not at the end" 0 \
  bash "$RECORD" "${CASE_DIR}/order.json" late 2025-09-01 a b c
run_case "recording an earlier post after a later one" 0 \
  bash "$RECORD" "${CASE_DIR}/order.json" early 2025-03-01 a b c
order=$(jq -r '[.posts[].slug] | join(",")' "${CASE_DIR}/order.json")
if [ "$order" = "early,late" ]; then ok; else fail "date order: expected 'early,late' (newest last), got '${order}'"; fi

new_dir
printf '{"posts":[{"slug":"a","date":"2025-01-01","opening_mode":"o","arc":"a","closing_mode":"c","interventions":[]}]}' >"${CASE_DIR}/nover.json"
before=$(cat "${CASE_DIR}/nover.json")
run_case "refuses to append to a history whose records lack schema_version" 1 \
  bash "$RECORD" "${CASE_DIR}/nover.json" s 2025-06-01 a b c
if [ "$(cat "${CASE_DIR}/nover.json")" = "$before" ]; then ok; else fail "unversioned guard: the history was modified"; fi

new_dir
printf '{"posts":[{"schema_version":1,"slug":"a","date":"nope","opening_mode":"o","arc":"a","closing_mode":"c","interventions":[]}]}' >"${CASE_DIR}/badrec.json"
before=$(cat "${CASE_DIR}/badrec.json")
run_case "refuses to append to a history holding a malformed record" 1 \
  bash "$RECORD" "${CASE_DIR}/badrec.json" s 2025-06-01 a b c
if [ "$(cat "${CASE_DIR}/badrec.json")" = "$before" ]; then ok; else fail "malformed record guard: the history was modified"; fi

new_dir
ln -s "${CASE_DIR}/nowhere.json" "${CASE_DIR}/dangling.json"
run_case "refuses to write through a dangling symlink" 1 \
  bash "$RECORD" "${CASE_DIR}/dangling.json" s 2025-06-01 a b c

# A history on a synced drive is reached through a symlink, the same shape the
# persona directory uses. The write must land on the target, not replace the link.
new_dir
mkdir -p "${CASE_DIR}/real"
printf '{"posts":[]}' >"${CASE_DIR}/real/history.json"
ln -s "${CASE_DIR}/real/history.json" "${CASE_DIR}/link.json"
run_case "writing through a valid symlink preserves the link" 0 \
  bash "$RECORD" "${CASE_DIR}/link.json" s 2025-06-01 a b c
if [ -L "${CASE_DIR}/link.json" ]; then ok; else fail "symlink: the link was replaced by a regular file"; fi
landed=$(jq -r '.posts[0].slug' "${CASE_DIR}/real/history.json" 2>/dev/null || echo MISSING)
if [ "$landed" = "s" ]; then ok; else fail "symlink: the record did not land on the target, got '${landed}'"; fi
strays=$(find "${CASE_DIR}" -name '*.staging.*' | wc -l | tr -d ' ')
if [ "$strays" = "0" ]; then ok; else fail "symlink: ${strays} staging file(s) stranded"; fi

new_dir
run_case "rejects a date that is not YYYY-MM-DD" 2 \
  bash "$RECORD" "${CASE_DIR}/d.json" s "Aug 11 2026" a b c

new_dir
run_case "rejects an empty slug" 2 \
  bash "$RECORD" "${CASE_DIR}/e.json" "" 2025-06-01 a b c

new_dir
run_case "rejects too few arguments" 2 \
  bash "$RECORD" "${CASE_DIR}/f.json" s 2025-06-01

echo
echo "passed: ${pass_count}  failed: ${fail_count}"
[ "$fail_count" -eq 0 ]
