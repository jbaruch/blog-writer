#!/usr/bin/env bash
# Outcome-based tests for sweep.py.
#
# Covers the behaviors the script promises in its header contract:
#   1. Exit codes — 0 with no hits, 1 with hits, 2 for every usage/tool error.
#   2. Coverage is always stated — the report names what ran and what did not on
#      a zero-hit run too, and never prints a bare "clean". This is the contract
#      that stops a passing sweep from displacing the contextual read.
#   3. #7 paired em-dash — fires on a real pair of any interior length, and does
#      NOT pair across a sentence boundary or across two list items.
#   4. #8 em-dash density — fires above the per-section limit, not at it, and
#      counts per section rather than per document.
#   5. #3/#4 fragment chains — fires on a run of short sentences, not on a
#      shorter run, and not on a list of short items. Blockquotes count as
#      prose; sentence boundaries survive a trailing capital.
#   6. #14 low burstiness — fires on a monotone run, not on varied lengths.
#   7. #18 unicode giveaways — an opening and closing curly quote report as one
#      finding with the combined count, not as two identical lines.
#   8. Markdown exclusions — a region is excluded only when it closes, so an
#      unterminated fence or a leading thematic break cannot sweep the draft
#      clean. Fenced code, frontmatter, HTML comments, headings
#      and asset placeholders do not contribute hits, for #18 as well as for the
#      sentence sweeps, with a control proving the sweep still fires in prose.
#   9. Abbreviation guard — "e.g." does not end a sentence, so it cannot
#      manufacture a fragment chain.
#  10. Output shape — valid JSON carrying each hit's documented fields, and
#      `verify_context` set on the sentence-counting sweeps only, since that is
#      the flag SKILL.md routes on.
#  11. Judgment patterns are never reported — the watchlist families stay with
#      the agent, so no hit may carry #1, #10, #12, #17, #32, #35, #36, #40,
#      or #41.
#  12. Coverage total — read from references/ai-anti-patterns.md on every run,
#      never a literal. A file that cannot be counted exits 2 rather than
#      reporting a guessed figure, and so does a catalog no larger than the
#      sweep's own examined count, which would report zero unexamined or drive
#      the note negative.
#  13. Entry-point guard — importing the module runs nothing.
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

# The findings, flattened to one line each. The coverage object names every
# sweep on every run, so a negative assertion against the whole document would
# always match coverage's own "ran" list and never fail.
hit_lines() {
  jq -r '.hits[] | "\(.pattern) \(.label) \(.detail)"' <<<"$CASE_OUT"
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

# Asserts the sweep of $2 exits $3 and that the jq filter $4 holds on the result.
# Used for the coverage object, which is deliberately not a finding.
assert_json() {
  local label=$1 body=$2 expect_rc=$3 filter=$4

  sweep_fixture "$(echo "$label" | tr -c 'a-zA-Z0-9' '_')" "$body"

  if [ "$CASE_RC" -ne "$expect_rc" ]; then
    fail "${label}: expected exit ${expect_rc}, got ${CASE_RC} (stderr: ${CASE_ERR})"
    return 1
  fi
  if ! jq -e "$filter" <<<"$CASE_OUT" >/dev/null; then
    fail "${label}: filter '${filter}' did not hold on the result"
    return 1
  fi

  ok
  echo "  ${label}"
  return 0
}

# Asserts the first hit whose pattern is $4 sits on line $5.
assert_hit_line() {
  local label=$1 body=$2 pattern=$3 expect_line=$4
  local actual

  sweep_fixture "$(echo "$label" | tr -c 'a-zA-Z0-9' '_')" "$body"
  actual=$(jq -r --arg p "$pattern" 'first(.hits[] | select(.pattern == $p) | .line) // "none"' <<<"$CASE_OUT")

  if [ "$actual" != "$expect_line" ]; then
    fail "${label}: expected ${pattern} on line ${expect_line}, got ${actual}"
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

  assert_json "clean draft exits 0 with no hits" "$clean_draft" 0 '(.hits | length) == 0'
  assert_json "clean draft still names what ran" "$clean_draft" 0 '(.coverage.ran | length) == 5'
  assert_json "clean draft names supplemental checks" "$clean_draft" 0 '(.coverage.supplemental_checks | length) == 3'
  assert_json "clean draft still names what did not run" "$clean_draft" 0 '(.coverage.not_run_judgment | length) == 9'
  # The total is read out of the pattern file, never restated here — a literal
  # in the suite would be the same stale second copy the script stopped keeping.
  # grep's status is captured explicitly rather than discarded by the command
  # substitution: an unreadable catalog exits 2 and no-match exits 1, and both
  # would otherwise leave `defined` empty for a numeric test to choke on.
  local defined="" grep_rc=0
  defined=$(grep -cE '^## [0-9]+\. ' "${SCRIPT_DIR}/references/ai-anti-patterns.md") || grep_rc=$?
  if [ "$grep_rc" -ne 0 ]; then
    fail "could not count patterns in references/ai-anti-patterns.md (grep exit ${grep_rc})"
  elif [ "$defined" -lt 2 ]; then
    fail "references/ai-anti-patterns.md reported only ${defined} pattern(s)"
  else
    assert_json "clean draft states partial coverage" "$clean_draft" 0 ".coverage.patterns_examined == 6 and .coverage.patterns_total == ${defined} and (.coverage.note | length) > 0"
  fi

  # The contract's core guarantee: a zero-hit run must still carry coverage, so
  # no consumer can read an empty hits list as "the check passed".
  sweep_fixture coverage_on_clean "$clean_draft"
  if ! jq -e '(.hits | length) == 0 and (.coverage | has("note")) and (.coverage.patterns_examined < .coverage.patterns_total)' <<<"$CASE_OUT" >/dev/null; then
    fail "a zero-hit run does not carry the coverage statement"
  else
    ok
    echo "  a zero-hit run still carries coverage"
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

  # 7. Fixed model-interface artifacts
  assert_sweep "citation artifacts cover each vendor family" \
    'ChatGPT left turn0search0. Gemini left [cite: 1]. Grok left grok_card.
DeepSeek left 【85†L261-269】. Perplexity left [web:1].' \
    1 yes "citation artifact"

  assert_json "every documented citation artifact form is covered" \
    'contentReference[oaicite:0]{index=0}
oai_citation
turn0search0
attributableIndex
[cite: 1]
[span_1](start_span)
grok_card
grok_render_citation_card_json
【85†L261-269】
[attached_file:1]
[web:1]
:::writing{variant="document" id=12345}
turn1search2 +1' \
    1 '([.hits[] | select(.pattern == "WP:OAICITE")] | length) == 14 and any(.hits[]; .detail == "ChatGPT trailing +1")'

  assert_json "ordinary arithmetic ending in +1 is not a citation artifact" \
    'Increment the retry count by +1' \
    0 '([.hits[] | select(.pattern == "WP:OAICITE")] | length) == 0'

  assert_sweep "unclassified writing wrappers are citation artifacts" \
    ':::writing{variant="document" id=12345}' \
    1 yes "unclassified writing wrapper"

  assert_sweep "AI-source tracking parameters are reported" \
    'Read https://example.test/post?utm_source=chatgpt.com and judge the source yourself.' \
    1 yes "AI-source tracking parameter"

  assert_json "every documented AI-source parameter is covered" \
    'https://a.test/?utm_source=openai
https://b.test/?utm_source=chatgpt.com
https://c.test/?utm_source=copilot.com
https://d.test/?referrer=grok.com' \
    1 '[.hits[] | select(.pattern == "WP:TRACKING")] | length == 4'

  assert_json "longer tracking values do not match known attribution values" \
    'https://example.test/?utm_source=copilot.com.evil' \
    0 '([.hits[] | select(.pattern == "WP:TRACKING")] | length) == 0'

  assert_json "analytics config outside a URL is not a tracking leak" \
    'utm_source=openai is the analytics source configured for this test.' \
    0 '([.hits[] | select(.pattern == "WP:TRACKING")] | length) == 0'

  assert_sweep "tracking parameter in a double-quoted URL is reported" \
    'Read "https://example.test/?utm_source=openai" before publishing.' \
    1 yes "AI-source tracking parameter"

  assert_sweep "tracking parameter in a single-quoted URL is reported" \
    "Read 'https://example.test/?referrer=grok.com' before publishing." \
    1 yes "AI-source tracking parameter"

  assert_sweep "thematic breaks between every H2 section are reported" \
    '## First

Ordinary prose belongs here.

---

## Second

More ordinary prose belongs here.

---

## Third

The final prose belongs here.' \
    1 yes "thematic break between every section"

  assert_sweep "an occasional thematic break is not reported" \
    '## First

Ordinary prose belongs here.

---

## Second

More ordinary prose belongs here.

## Third

The final prose belongs here.' \
    0 no "thematic break between every section"

  # 8. Markdown exclusions
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

  assert_json "artifact checks ignore fenced code" \
    '# Title

```text
turn0search0 utm_source=openai
```

The visible prose carries no leaked tokens or parameters in it.' \
    0 '(.hits | length) == 0'

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

  # Regression: every sentence ending in a lone capital was read as an initial,
  # so an ordinary sentence merged with the next and took the chain with it.
  assert_sweep "a sentence ending in a capital still ends" \
    'Pick A. Go. Stop. Then the pager went off at three in the morning and woke us.' \
    1 yes "fragment chain"

  # The guard it was replaced by, asserted on a fixture that discriminates: the
  # run must survive whole, its LAST initial included. Splitting anywhere inside
  # "J. R. R. Tolkien" turns one 11-word sentence into [4, 1, 1, 5] and the
  # paragraph into a six-sentence fragment chain, so a regression here is a
  # finding the author is told to fix rather than a silent difference.
  assert_json "a run of initials survives whole, last initial included" \
    'It failed. We knew. Beside it sat J. R. R. Tolkien, unopened for eleven years.' \
    0 '(.hits | length) == 0'

  # Regression: blockquotes were classified, handled by the splitter, and then
  # silently dropped from both sentence sweeps.
  assert_sweep "#3/#4 covers a blockquote" \
    '> It failed. We knew. Nobody cared. Then the pager went off at three today.' \
    1 yes "fragment chain"

  assert_sweep "#14 covers a blockquote" \
    '> The system indexes every file on disk. It writes results to a local cache.
> The cache is invalidated on each commit.' \
    1 yes "low burstiness"

  # A wrapped blockquote is one sentence across two lines, not two sentences,
  # and its markers are not words.
  assert_sweep "a wrapped blockquote is not cut at the line break" \
    '> This quoted sentence wraps across two source lines without ending
> anywhere near the first of them, so it must not read as two.' \
    0 no "fragment chain"

  # Regression: the span cap silently exempted the long asides that are the most
  # characteristic form of #7.
  assert_sweep "#7 finds a pair spanning more than 80 characters" \
    'The system — a Rails monolith running on three boxes in a colo nobody remembers renting — finally fell over.' \
    1 yes "PAIRED EM-DASH"

  # Regression: an opener with no closer made every later line transparent, so a
  # draft with no blocks swept clean. A false clean is the worst outcome this
  # script can produce, and it exited 0 while examining nothing.
  assert_sweep "unclosed frontmatter does not swallow the draft" \
    '---
It failed. We knew. Nobody cared. Then the pager went off at three today.' \
    1 yes "fragment chain"

  assert_sweep "an unterminated code fence does not swallow the draft" \
    '# Title

```bash
echo hi

It failed. We knew. Nobody cared. Then the pager went off at three today.' \
    1 yes "fragment chain"

  # A leading thematic break is valid markdown, not an unclosed frontmatter.
  assert_sweep "a leading thematic break is content" \
    '---

It failed. We knew. Nobody cared. Then the pager went off at three today.' \
    1 yes "fragment chain"

  # The control: closed regions are still excluded, so the fixes above widened
  # the input rather than disabling the exclusions.
  assert_sweep "closed frontmatter is still excluded" \
    '---
title: It failed. We knew. Nobody cared.
---

The body itself carries nothing wrong at all, so the sweep must stay quiet.' \
    0 no "fragment chain"

  # Regression: any later `---` counted as the closing delimiter, so a document
  # opening with a thematic break and carrying a second one hid every line
  # between them from every sweep.
  assert_sweep "two thematic breaks are not frontmatter" \
    '---

It failed. We knew. Nobody cared. Then the pager went off at three today.

---

More prose follows here.' \
    1 yes "fragment chain"

  # Regression: a fence closed by a different marker, or a shorter run of the
  # same one, is not a close (CommonMark). Accepting either silently excluded
  # the prose after it.
  assert_sweep "a backtick fence is not closed by a tilde fence" \
    '# Title

```bash
echo hi
~~~

It failed. We knew. Nobody cared. Then the pager went off at three today.' \
    1 yes "fragment chain"

  assert_sweep "a fence is not closed by a shorter run" \
    '# Title

````bash
echo hi
```

It failed. We knew. Nobody cared. Then the pager went off at three today.' \
    1 yes "fragment chain"

  # Regression: an unterminated comment made every later line transparent, so
  # the sweep exited 0 after examining no prose.
  assert_sweep "an unterminated HTML comment does not swallow the draft" \
    '# Title

<!-- VERIFY: this comment never closes

It failed. We knew. Nobody cared. Then the pager went off at three today.' \
    1 yes "fragment chain"

  # The control for all four: a real closed region is still excluded, so the
  # fixes widened the input rather than disabling the exclusions.
  assert_json "real frontmatter is still excluded" \
    '---
title: It failed. We knew. Nobody cared.
---

The body carries nothing wrong at all so the sweep must stay entirely quiet.' \
    0 '(.hits | length) == 0'

  assert_sweep "a matched fence is still excluded" \
    '# Title

````bash
echo "this — has — paired dashes and must be ignored"
````

The prose itself carries nothing wrong at all, so the sweep must stay quiet.' \
    0 no "PAIRED EM-DASH"

  # Regression: a group was labelled a list if ANY line in it looked like a list
  # item, so prose running straight into a list (valid markdown, no blank line)
  # was swept as a list — and the sentence sweeps skip lists.
  assert_sweep "prose running straight into a list is still swept" \
    'It failed. We knew. Nobody cared.
- one thing
- another thing' \
    1 yes "fragment chain"

  assert_hit_line "the transition reports the prose line, not the list" \
    '# Title

It failed. We knew. Nobody cared.
- one thing
- another thing' \
    "#3/#4" 3

  # The control: a wrapped list item is a lazy continuation, so it stays with
  # its list rather than opening a prose segment of one-line fragments.
  assert_sweep "a wrapped list item is still one list" \
    '- one item that wraps
  onto a second line
- two
- three
- four' \
    0 no "fragment chain"

  # `verify_context` is the routing signal SKILL.md acts on, so which sweeps set
  # it is part of the emitted contract rather than something the skill restates.
  # Sentence-counting sweeps rest on segmentation; character-counting ones do not.
  sweep_fixture verify_flag 'It failed. We knew. Nobody cared. Then it broke.

Three facilities — Austin, Berlin, Osaka — ran the nightly job without complaint.'
  if ! jq -e '[.hits[] | select(.pattern == "#3/#4" or .pattern == "#14") | .verify_context] | length > 0 and all' <<<"$CASE_OUT" >/dev/null; then
    fail "sentence-counting hits do not carry verify_context true"
  elif ! jq -e '[.hits[] | select(.pattern == "#7" or .pattern == "#8" or .pattern == "#18") | .verify_context] | all(. == false)' <<<"$CASE_OUT" >/dev/null; then
    fail "character-counting hits carry verify_context true"
  else
    ok
    echo "  verify_context marks the segmentation-dependent hits only"
  fi

  # 9. Judgment families are never reported
  sweep_fixture judgment 'Rather than delve into the tapestry, we leveraged a seamless, robust paradigm.
In todays landscape, it is important to note that this is, of course, pivotal.'
  local leaked
  leaked=$(jq -r '[.hits[].pattern] - ["#3/#4","#7","#8","#14","#18","WP:OAICITE","WP:TRACKING","WP:SECTIONBREAK"] | join(" ")' <<<"$CASE_OUT")
  if [ -n "$leaked" ]; then
    fail "judgment patterns reported as hits: ${leaked} — those stay with the agent"
  else
    ok
    echo "  judgment patterns are never reported as hits"
  fi

  # 10. The object shape every consumer routes on
  local json_fixture="${SUITE_TMP}/shape.md"
  printf '%s\n' 'Three facilities — Austin, Berlin, Osaka — ran the job.' >"$json_fixture"
  local json_out json_rc
  json_out=$("$PYTHON" "$SCRIPT" "$json_fixture")
  json_rc=$?
  if [ "$json_rc" -ne 1 ]; then
    fail "object shape: expected exit 1 on a hit, got ${json_rc}"
  elif ! jq -e '.ok == true and (.hits | length) >= 1 and (.path | length) > 0' <<<"$json_out" >/dev/null; then
    fail "object shape: output is not the promised object"
  elif ! jq -e '.hits[0] | has("pattern") and has("label") and has("line") and has("detail") and has("context") and has("verify_context")' <<<"$json_out" >/dev/null; then
    fail "object shape: a hit is missing a documented field"
  else
    ok
    echo "  stdout is the promised JSON object"
  fi

  # 11. Exact hit lines. Excluded regions are blanked rather than deleted, so a
  # finding after frontmatter or a multi-line comment still points at the line
  # the author sees in their editor.
  assert_hit_line "line is exact after frontmatter" \
    '---
title: A post
date: 2026-01-01
---

# Heading

Three facilities — Austin, Berlin, Osaka — ran the nightly job.' \
    "#7" 8

  assert_hit_line "line is exact after a multi-line HTML comment" \
    '# Heading

<!-- VERIFY: reconstructed
     from the transcript
     confirm this -->

Three facilities — Austin, Berlin, Osaka — ran the nightly job.' \
    "#7" 7

  # A multi-line comment must not join the prose on either side of it into one
  # line, and must not split a paragraph the author wrote as one. Deleting the
  # comment does the first; blanking it does the second, which would lose this
  # fragment chain entirely.
  assert_sweep "a multi-line comment does not split the paragraph around it" \
    'It failed. We knew.
<!-- VERIFY: reconstructed
     confirm this -->
Nobody cared. Then the pager went off at three in the morning.' \
    1 yes "fragment chain"

  assert_hit_line "prose before a multi-line comment keeps its own line" \
    'It failed. We knew. Nobody cared.

<!-- VERIFY: a note
     spanning two lines -->

Then the pager went off at three in the morning and everyone woke up at once.' \
    "#3/#4" 1

  # An inline comment is removed without breaking the sentence around it.
  assert_sweep "an inline comment does not break the sentence around it" \
    'The build broke <!-- VERIFY: which build? --> twice that week, and the second
time nobody noticed until the pager went off at three in the morning.' \
    0 no "fragment chain"

  # Inside a list, the finding points at the item, not at the block.
  assert_hit_line "line is the list item, not the block" \
    '# Heading

- a plain first item
- a plain second item
- a third item — with an aside — inside it' \
    "#7" 5

  # Inside a wrapped paragraph, the finding points at the sentence's own line.
  assert_hit_line "line is the sentence, not the paragraph" \
    '# Heading

This first sentence is perfectly ordinary and carries nothing worth reporting.
This second one is also ordinary and equally quiet on every count.
The third — an aside — is not.' \
    "#7" 5

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

  # 12. Coverage total is derived from the pattern file, not carried as a
  # literal. Each case runs a copy of the script beside its own pattern file, so
  # the shipped one is never touched.
  local iso="${SUITE_TMP}/isolated"
  mkdir -p "${iso}/references"
  cp "$SCRIPT" "${iso}/sweep.py"
  local probe="${SUITE_TMP}/probe.md"
  printf 'A sentence of ordinary length that trips none of the counting sweeps.\n' >"$probe"

  printf '## 1. A\n\n## 2. B\n\n## 3. C\n\n## 4. D\n\n## 5. E\n\n## 6. F\n\n## 7. G\n\n## 8. H\n' >"${iso}/references/ai-anti-patterns.md"
  local iso_out iso_rc
  iso_out=$("$PYTHON" "${iso}/sweep.py" "$probe" 2>"${SUITE_TMP}/iso_err")
  iso_rc=$?
  if [ "$iso_rc" -ne 0 ]; then
    fail "isolated sweep expected exit 0, got ${iso_rc} ($(cat "${SUITE_TMP}/iso_err"))"
  elif ! jq -e '.coverage.patterns_total == 8' <<<"$iso_out" >/dev/null; then
    fail "the total ignores the pattern file: expected 8, got $(jq -r '.coverage.patterns_total' <<<"$iso_out")"
  else
    ok
    echo "  the total is counted from the pattern file"
  fi

  printf '## Running the check\n\nProse with no numbered pattern headings.\n' >"${iso}/references/ai-anti-patterns.md"
  "$PYTHON" "${iso}/sweep.py" "$probe" >/dev/null 2>"${SUITE_TMP}/iso_err"
  iso_rc=$?
  if [ "$iso_rc" -ne 2 ]; then
    fail "a pattern file with no numbered headings expected exit 2, got ${iso_rc}"
  elif ! grep -qF 'defines 0 numbered pattern(s)' "${SUITE_TMP}/iso_err"; then
    fail "the empty-pattern-file diagnostic is not actionable: $(cat "${SUITE_TMP}/iso_err")"
  else
    ok
    echo "  a pattern file with no numbered headings exits 2"
  fi

  # A catalog no larger than the sweep is the dangerous case. At exactly six
  # the note claims zero unexamined while not_run_judgment still names sweeps;
  # below six the arithmetic goes negative. Both must fail rather than report.
  printf '## 1. A\n\n## 2. B\n\n## 3. C\n\n## 4. D\n\n## 5. E\n\n## 6. F\n' >"${iso}/references/ai-anti-patterns.md"
  "$PYTHON" "${iso}/sweep.py" "$probe" >/dev/null 2>"${SUITE_TMP}/iso_err"
  iso_rc=$?
  if [ "$iso_rc" -ne 2 ]; then
    fail "a catalog of exactly the examined count expected exit 2, got ${iso_rc}"
  elif ! grep -qF 'not more than the 6 this script sweeps for' "${SUITE_TMP}/iso_err"; then
    fail "the exactly-six diagnostic is not actionable: $(cat "${SUITE_TMP}/iso_err")"
  else
    ok
    echo "  a catalog of exactly the examined count exits 2"
  fi

  printf '## 1. A\n\n## 2. B\n\n## 3. C\n' >"${iso}/references/ai-anti-patterns.md"
  "$PYTHON" "${iso}/sweep.py" "$probe" >/dev/null 2>"${SUITE_TMP}/iso_err"
  iso_rc=$?
  if [ "$iso_rc" -ne 2 ]; then
    fail "a catalog smaller than the examined count expected exit 2, got ${iso_rc}"
  elif ! grep -qF 'not more than the 6 this script sweeps for' "${SUITE_TMP}/iso_err"; then
    fail "the truncated-catalog diagnostic is not actionable: $(cat "${SUITE_TMP}/iso_err")"
  else
    ok
    echo "  a catalog smaller than the examined count exits 2"
  fi

  printf '## 1. A\n\n## 2. B\n\n## 3. C\n\n## 4. D\n\n## 5. E\n\n## 6. F\n' >"${iso}/references/ai-anti-patterns.md"
  printf '\xff\xfe not utf-8\n' >>"${iso}/references/ai-anti-patterns.md"
  "$PYTHON" "${iso}/sweep.py" "$probe" >/dev/null 2>"${SUITE_TMP}/iso_err"
  iso_rc=$?
  if [ "$iso_rc" -ne 2 ]; then
    fail "a non-UTF-8 pattern file expected exit 2, got ${iso_rc}"
  elif ! grep -qF 'is not valid UTF-8' "${SUITE_TMP}/iso_err"; then
    fail "the non-UTF-8 catalog diagnostic is not actionable: $(cat "${SUITE_TMP}/iso_err")"
  else
    ok
    echo "  a non-UTF-8 pattern file exits 2"
  fi

  rm -f "${iso}/references/ai-anti-patterns.md"
  "$PYTHON" "${iso}/sweep.py" "$probe" >/dev/null 2>"${SUITE_TMP}/iso_err"
  iso_rc=$?
  if [ "$iso_rc" -ne 2 ]; then
    fail "a missing pattern file expected exit 2, got ${iso_rc}"
  elif ! grep -qF 'cannot read the pattern file' "${SUITE_TMP}/iso_err"; then
    fail "the missing-pattern-file diagnostic is not actionable: $(cat "${SUITE_TMP}/iso_err")"
  else
    ok
    echo "  a missing pattern file exits 2"
  fi

  # 13. Entry-point guard — importing runs nothing and prints nothing
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
