#!/usr/bin/env bash
# Outcome-based tests for sweep.py.
#
# Covers the behaviors the script promises in its header contract:
#   1. Exit codes — 0 with no hits, 1 with hits, 2 for every usage/tool error.
#   2. Coverage is always stated — the report names what ran and what did not on
#      a zero-hit run too, and never prints a bare "clean". This is the contract
#      that stops a passing sweep from displacing the contextual read.
#   3. #7 paired em-dash — fires on a real pair, and does NOT pair across a
#      sentence boundary or across two list items.
#   4. #8 em-dash density — fires above the per-section limit, not at it, and
#      counts per section rather than per document.
#   5. #3/#4 fragment chains — fires on a run of short sentences, not on a
#      shorter run, and not on a list of short items.
#   6. #14 low burstiness — fires on a monotone run, not on varied lengths.
#   7. #18 unicode giveaways — an opening and closing curly quote report as one
#      finding with the combined count, not as two identical lines.
#   8. Markdown exclusions — fenced code, frontmatter, HTML comments, headings
#      and asset placeholders do not contribute hits, for #18 as well as for the
#      sentence sweeps, with a control proving the sweep still fires in prose.
#   9. Abbreviation guard — "e.g." does not end a sentence, so it cannot
#      manufacture a fragment chain.
#  10. --json — valid JSON carrying each hit's pattern, line, and detail.
#  11. Judgment patterns are never reported — the watchlist families stay with
#      the agent, so no hit may carry #1, #10, #12, #17, #32, #35 or #36.
#  12. Entry-point guard — importing the module runs nothing.
#
# Approach: every fixture is written programmatically into a suite-owned temp
# directory, so the suite touches no network, clock, randomness, or real draft.
#
# Run: bash skills/blog-writer/tests/test_sweep.sh

# Shell options are set inside main() rather than at file scope: the entry-point
# guard below makes this file sourceable, and a sourced file must not change the
# caller's shell options.
#
# The suite drops `-e` under `jbaruch/coding-policy: error-handling`'s
# aggregate-reporting carve-out — each case is independent, every exit code is
# captured explicitly, and main() returns non-zero if any case failed.
#
# Every fixture lives inside one suite-owned root, so a single EXIT trap removes
# them all. `return 0` keeps cleanup from rewriting the suite's exit status.

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly SCRIPT="${SCRIPT_DIR}/sweep.py"

pass_count=0
fail_count=0

fail() {
  echo "    FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

ok() {
  pass_count=$((pass_count + 1))
}

# Writes $2 to a fixture named $1 and sweeps it. Sets CASE_OUT and CASE_RC.
sweep_fixture() {
  local name=$1
  local body=$2
  local fixture="${SUITE_TMP}/${name}.md"

  printf '%s\n' "$body" >"$fixture"
  CASE_OUT=$("$PYTHON" "$SCRIPT" "$fixture" 2>"${SUITE_TMP}/err")
  CASE_RC=$?
  CASE_ERR=$(cat "${SUITE_TMP}/err")
}

# The findings only. The coverage statement names every sweep on every run, so a
# negative assertion against the whole report would always match its own "RAN"
# line and never fail. Hit lines are the ones opening with "  [#".
hit_lines() {
  grep '^  \[#' <<<"$CASE_OUT"
  return 0
}

# Asserts the sweep of $2 exits $3 and that its FINDINGS do ($4=yes) or do not
# ($4=no) mention $5.
assert_sweep() {
  local label=$1 body=$2 expect_rc=$3 want=$4 needle=$5
  local found

  sweep_fixture "$(echo "$label" | tr -c 'a-zA-Z0-9' '_')" "$body"

  if [ "$CASE_RC" -ne "$expect_rc" ]; then
    fail "${label}: expected exit ${expect_rc}, got ${CASE_RC} (stderr: ${CASE_ERR}) findings: $(hit_lines | tr '\n' ';')"
    return 1
  fi

  found=$(hit_lines)
  if [ "$want" = "yes" ] && ! grep -qF "$needle" <<<"$found"; then
    fail "${label}: findings do not mention '${needle}' (findings: ${found:-none})"
    return 1
  fi
  if [ "$want" = "no" ] && grep -qF "$needle" <<<"$found"; then
    fail "${label}: findings should not mention '${needle}' but do"
    return 1
  fi

  ok
  echo "  ${label}"
  return 0
}

# Asserts the sweep of $2 exits $3 and that the FULL report mentions $4. Used for
# the coverage statement, which is deliberately not a finding.
assert_report() {
  local label=$1 body=$2 expect_rc=$3 needle=$4

  sweep_fixture "$(echo "$label" | tr -c 'a-zA-Z0-9' '_')" "$body"

  if [ "$CASE_RC" -ne "$expect_rc" ]; then
    fail "${label}: expected exit ${expect_rc}, got ${CASE_RC} (stderr: ${CASE_ERR})"
    return 1
  fi
  if ! grep -qF "$needle" <<<"$CASE_OUT"; then
    fail "${label}: report does not carry '${needle}'"
    return 1
  fi

  ok
  echo "  ${label}"
  return 0
}

main() {
  set -uo pipefail

  if ! command -v python3 >/dev/null; then
    echo "error: python3 not found on PATH — sweep.py needs it; install python3 and re-run" >&2
    exit 2
  fi
  PYTHON=python3

  if ! SUITE_TMP=$(mktemp -d); then
    echo "error: could not create the suite temp directory — check TMPDIR is writable" >&2
    exit 1
  fi
  cleanup_suite_tmp() {
    rm -rf "$SUITE_TMP"
    return 0
  }
  trap cleanup_suite_tmp EXIT

  echo "test_sweep"

  # 1. Exit codes and the coverage contract
  local clean_draft='# Title

The deploy took ninety seconds. Before the rewrite it ran for forty-five minutes,
which everyone had quietly accepted as simply the cost of shipping anything at all.

We cut it.'

  assert_report "clean draft exits 0" "$clean_draft" 0 "no hits in the counting sweeps"
  assert_report "clean draft still names what ran" "$clean_draft" 0 "RAN (5 counting sweeps)"
  assert_report "clean draft still names what did not run" "$clean_draft" 0 "NOT RUN"
  assert_report "clean draft states partial coverage" "$clean_draft" 0 "is not an anti-pattern check"

  # A bare "clean" is the exact string the contract forbids, since it reads as
  # "the check passed" rather than "five of thirty-nine passed".
  sweep_fixture bare_clean "$clean_draft"
  if grep -qxE ' *clean *' <<<"$CASE_OUT"; then
    fail "report prints a bare 'clean' line, which the output contract forbids"
  else
    ok
    echo "  clean draft never prints a bare 'clean'"
  fi

  # 2. #7 paired em-dash
  assert_sweep "#7 fires on a real pair" \
    'Three facilities — Austin, Berlin, Osaka — ran the nightly job without complaint.' \
    1 yes "PAIRED EM-DASH"

  # Two asides in adjacent sentences are not one pair. Matching over the whole
  # paragraph would join the dash of one sentence to the dash of the next.
  assert_sweep "#7 does not pair across a sentence boundary" \
    'The build broke — again, predictably. Nobody noticed for a while — the alerts were off.' \
    0 no "PAIRED EM-DASH"

  # Regression: two list items each ending in an em-dash aside were reported as
  # a single pair spanning both items.
  assert_sweep "#7 does not pair across two list items" \
    '- **Surface scan** — matches known pattern forms
- **Skeleton scan** — compares grammatical shape' \
    0 no "PAIRED EM-DASH"

  # 3. #8 em-dash density, per section
  assert_sweep "#8 fires above the section limit" \
    '## Section

One — two — three — four dashes live in this single section of the draft.' \
    1 yes "em-dash density"

  assert_sweep "#8 does not fire at the section limit" \
    '## Section

The build broke — twice that week. Nobody filed a ticket — we all just moved on.' \
    0 no "em-dash density"

  # Counting per document rather than per section would flag this.
  assert_sweep "#8 counts per section, not per document" \
    '## First

The build broke — twice that week. Nobody filed a ticket — we all moved on.

## Second

The deploy stalled — briefly, that time. The alert stayed quiet — as it always does.' \
    0 no "em-dash density"

  # 4. #3/#4 fragment chains
  assert_sweep "#3/#4 fires on three short sentences" \
    'It failed. We knew. Nobody cared. Then the pager went off at three in the morning.' \
    1 yes "fragment chain"

  assert_sweep "#3/#4 does not fire on two short sentences" \
    'It failed. We knew. Then the pager went off at three in the morning and stayed on.' \
    0 no "fragment chain"

  # A list of short items is a list, not a fragment chain.
  assert_sweep "#3/#4 does not fire on a list of short items" \
    '- one thing
- another thing
- a third thing
- a fourth thing' \
    0 no "fragment chain"

  # 5. #14 low burstiness
  assert_sweep "#14 fires on a monotone run" \
    'The system indexes every file on disk. It writes the results to a local cache.
The cache is invalidated on each commit.' \
    1 yes "low burstiness"

  assert_sweep "#14 does not fire on varied lengths" \
    'We shipped. The rewrite had taken eleven weeks of steady, unglamorous work that
nobody outside the team ever saw or asked about. It held.' \
    0 no "low burstiness"

  # 6. #18 unicode giveaways
  assert_sweep "#18 groups a curly quote pair into one finding" \
    'He said “no” and walked out of the room without waiting for an answer.' \
    1 yes 'curly double quotes (") x2'

  assert_sweep "#18 catches the ellipsis character" \
    'The build finished… eventually, after three unexplained retries on the runner.' \
    1 yes "ellipsis character"

  # 7. Markdown exclusions
  assert_sweep "fenced code does not contribute hits" \
    '# Title

```bash
echo "this — has — paired dashes and must be ignored"
```' \
    0 no "PAIRED EM-DASH"

  assert_sweep "HTML comments do not contribute hits" \
    '# Title

<!-- VERIFY: reconstructed — from — the transcript -->

The paragraph itself is ordinary prose that carries no findings of any kind here.' \
    0 no "PAIRED EM-DASH"

  assert_sweep "frontmatter does not contribute hits" \
    '---
title: A — post — title
---

The body itself is ordinary prose that carries no findings of any kind at all.' \
    0 no "PAIRED EM-DASH"

  assert_sweep "asset placeholders do not form a fragment chain" \
    '[Screenshot 01: the dashboard]

[Screenshot 02: the detail view]

[Screenshot 03: the error state]' \
    0 no "fragment chain"

  # 8. Abbreviation guard — a false split here manufactures short sentences
  assert_sweep "e.g. does not split a sentence into fragments" \
    'We pinned the usual suspects, e.g. the linter, e.g. the formatter, e.g. the
test runner, and the build finally went quiet for the first time in weeks.' \
    0 no "fragment chain"

  # Regression: a digit guard on the sentence splitter merged two real
  # sentences when one ended and the next began with a number, which suppressed
  # exactly the fragment-chain and burstiness findings the script exists for.
  assert_sweep "adjacent numeric sentences still split" \
    'It failed at 4. 3 people knew. Nobody cared. Then the pager went off at three.' \
    1 yes "fragment chain"

  # Regression: #18 read the raw file, so it reported characters inside regions
  # the parser excludes for every other sweep.
  assert_sweep "#18 ignores unicode inside fenced code" \
    '# Title

```text
Bullet • and “curly quotes” and an en–dash live in this sample output.
```

The prose itself carries nothing wrong at all, so the sweep must stay quiet.' \
    0 no "unicode giveaway"

  assert_sweep "#18 ignores unicode inside an HTML comment" \
    '# Title

<!-- VERIFY: reconstructed, the “quoted” bit is uncertain -->

The prose itself carries nothing wrong at all, so the sweep must stay quiet.' \
    0 no "unicode giveaway"

  assert_sweep "#18 ignores unicode inside frontmatter" \
    '---
title: A “quoted” title
---

The body itself carries nothing wrong at all, so the sweep must stay quiet.' \
    0 no "unicode giveaway"

  assert_sweep "#18 ignores unicode inside an asset placeholder" \
    '[Screenshot 01: the “dashboard” view]

The prose itself carries nothing wrong at all, so the sweep must stay quiet.' \
    0 no "unicode giveaway"

  # Control for the four above: the same character in prose is still a finding,
  # so the exclusions narrow the input rather than disabling the sweep.
  assert_sweep "#18 still fires on unicode in the prose itself" \
    'The prose carries a “curly quote” that genuinely sits in the sentence.' \
    1 yes "unicode giveaway"

  # #18 covers headings and list items, since the reader sees them.
  assert_sweep "#18 covers a heading" \
    '## A “quoted” heading

The prose itself carries nothing else wrong at all in any way whatsoever.' \
    1 yes "unicode giveaway"

  # 9. Judgment families are never reported
  sweep_fixture judgment 'Rather than delve into the tapestry, we leveraged a seamless, robust paradigm.
In todays landscape, it is important to note that this is, of course, pivotal.'
  local leaked=""
  local judged
  for judged in '[#1 ' '[#10 ' '[#12 ' '[#17 ' '[#32 ' '[#35 ' '[#36 '; do
    if grep -qF "$judged" <<<"$CASE_OUT"; then
      leaked="${leaked} ${judged}"
    fi
  done
  if [ -n "$leaked" ]; then
    fail "judgment patterns reported as hits:${leaked} — those stay with the agent"
  else
    ok
    echo "  judgment patterns are never reported as hits"
  fi

  # 10. --json
  local json_fixture="${SUITE_TMP}/json.md"
  printf '%s\n' 'Three facilities — Austin, Berlin, Osaka — ran the job.' >"$json_fixture"
  local json_out
  json_out=$("$PYTHON" "$SCRIPT" "$json_fixture" --json)
  local json_rc=$?
  if [ "$json_rc" -ne 1 ]; then
    fail "--json: expected exit 1 on a hit, got ${json_rc}"
  elif ! jq -e '.ok == true and (.hits | length) >= 1' <<<"$json_out" >/dev/null; then
    fail "--json: output is not the promised object shape"
  elif ! jq -e '.hits[0] | has("pattern") and has("line") and has("detail")' <<<"$json_out" >/dev/null; then
    fail "--json: a hit is missing pattern, line, or detail"
  elif ! jq -e '(.ran | length) == 5 and (.not_run | length) == 7' <<<"$json_out" >/dev/null; then
    fail "--json: coverage arrays do not match the documented split"
  else
    ok
    echo "  --json emits the promised object shape"
  fi

  # 11. Error paths all exit 2 with an actionable diagnostic
  local case_err
  "$PYTHON" "$SCRIPT" "${SUITE_TMP}/absent.md" >/dev/null 2>"${SUITE_TMP}/err"
  case_err=$?
  if [ "$case_err" -ne 2 ] || ! grep -q "no such file" "${SUITE_TMP}/err"; then
    fail "missing file: expected exit 2 naming the path, got ${case_err}"
  else
    ok
    echo "  a missing file exits 2"
  fi

  "$PYTHON" "$SCRIPT" "$SUITE_TMP" >/dev/null 2>"${SUITE_TMP}/err"
  case_err=$?
  if [ "$case_err" -ne 2 ] || ! grep -q "is a directory" "${SUITE_TMP}/err"; then
    fail "directory argument: expected exit 2, got ${case_err}"
  else
    ok
    echo "  a directory argument exits 2"
  fi

  printf '\xff\xfe not utf8\n' >"${SUITE_TMP}/bad.md"
  "$PYTHON" "$SCRIPT" "${SUITE_TMP}/bad.md" >/dev/null 2>"${SUITE_TMP}/err"
  case_err=$?
  if [ "$case_err" -ne 2 ] || ! grep -q "not valid UTF-8" "${SUITE_TMP}/err"; then
    fail "non-UTF-8 file: expected exit 2, got ${case_err}"
  else
    ok
    echo "  a non-UTF-8 file exits 2"
  fi

  "$PYTHON" "$SCRIPT" >/dev/null 2>&1
  case_err=$?
  if [ "$case_err" -ne 2 ]; then
    fail "no argument: expected exit 2, got ${case_err}"
  else
    ok
    echo "  a missing argument exits 2"
  fi

  # 12. Entry-point guard — importing runs nothing and prints nothing
  local import_out
  import_out=$(cd "$SCRIPT_DIR" && "$PYTHON" -c 'import sweep' 2>&1)
  if [ -n "$import_out" ]; then
    fail "importing sweep.py produced output: ${import_out}"
  else
    ok
    echo "  importing the module runs nothing"
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
