#!/usr/bin/env python3
"""Run the counting sweeps of the Pass 1 anti-pattern check over a draft.

`references/process.md` Phase 3 Pass 1 splits the anti-pattern check into two
kinds of work. This script owns one of them.

    Counting  the verdict falls out of an arithmetic result and no reading is
              involved: word counts per sentence, occurrences per section,
              character presence, runs and windows. A model approximates these
              silently and reports clean; a script does not. That is this file.

    Judging   the string match is trivial and the call is the work: the delete
              test (#10, #35), the interchangeability test (#36), the usage
              qualifiers on the #12 watchlist ("key" as adjective, "navigate"
              abstract, "rich" figurative), whether two noun phrases denote one
              concept (#17), whether two numbers make the same point (#32),
              whether a "rather than" joins two candidates for the same slot
              (#1). No regex decides any of those. They stay with the agent.

This script therefore covers 5 of the 39 patterns, and says so on every run.
A bare "clean" is never printed: silence about coverage is what lets a passing
script displace the contextual read it never performed.

Usage:
    sweep.py <draft.md> [--json]

Input:
    $1        path to the draft. Markdown is parsed, not treated as flat text —
              see "What is excluded" below.
    --json    emit the structured result instead of the readable report.

Output (stdout):
    Default, a readable report: one line per hit with its source line, then the
    coverage statement naming what ran and what did not.

    With --json, a single object:
      {"ok": true, "path": "<file>", "hits": [ ... ], "ran": [...],
       "not_run": [...], "patterns_total": 39}
    Each hit carries {"pattern", "label", "line", "detail", "context"}.

Exit codes:
    0  swept, no hits in the counting sweeps. NOT "the draft is clean" — 34 of
       the 39 patterns were not examined by this script.
    1  swept, at least one hit. Each is a real finding: every predicate here is
       arithmetic, so there is no judgment call left for the caller to make.
    2  tool or usage error (no path given, file unreadable, not valid UTF-8).

Re-run after every rewrite. Both misses that motivated this script were
regressions introduced by edits made after a check had already reported clean.

The thresholds below are this script's decision contract per
`jbaruch/coding-policy: script-as-black-box` — skill prose points here rather
than restating them.
"""

import argparse
import json
import re
import sys
from pathlib import Path

# --- Decision contract -------------------------------------------------------
# Each constant is the literal figure `references/process.md` Pass 1 names for
# its sweep. Changing one changes the check; they are not tuning knobs.

# #3/#4 — "every sentence under six words ... whether 3+ appear consecutively"
FRAGMENT_MAX_WORDS = 6
FRAGMENT_RUN = 3

# #14 — "any run of 3+ consecutive sentences within 5 words of each other"
BURSTINESS_RUN = 3
BURSTINESS_SPREAD = 5

# #8 — "Count em-dashes per section. More than two in a section is a flag."
EMDASH_PER_SECTION = 2

# #7 — a paired em-dash is an aside inside one sentence, so the pair is matched
# per sentence. The span cap keeps two unrelated asides in a long sentence from
# reading as one pair.
PAIRED_EMDASH_MAX_SPAN = 80

EM_DASH = "—"

# #18 — characters a human keyboard does not produce by accident in a draft.
# The ASCII form is what belongs in the file; the curly and composed forms are
# what a model emits.
# Grouped by what the author would type instead, so an opening and closing quote
# report as one finding with one fix rather than as two identical-looking lines.
UNICODE_GIVEAWAYS = [
    ('curly double quotes (")', "“”"),
    ("curly single quotes / apostrophe (')", "‘’"),
    ("ellipsis character (...)", "…"),
    ("bullet character (-)", "•"),
    ("en dash (- or --)", "–"),
    ("non-breaking space", "\u00a0"),
]

# --- Coverage statement ------------------------------------------------------
# Printed on every run, hits or not. The inverse failure this script is built to
# avoid is a clean report displacing the read it never performed.

PATTERNS_TOTAL = 39

COUNTING_SWEEPS = [
    ("#3/#4", "fragment chains"),
    ("#7", "paired em-dashes"),
    ("#8", "em-dash density"),
    ("#14", "low burstiness"),
    ("#18", "unicode giveaways"),
]

JUDGMENT_SWEEPS = [
    ("#1", "contrastive negation — is it the same slot?"),
    ("#10", "introductory filler — apply the delete test"),
    ("#12", "AI vocabulary — the watchlist qualifiers are the check"),
    ("#17", "synonym cycling — do two phrases denote one concept?"),
    ("#32", "stacked data points — do two numbers make one point?"),
    ("#35", "temporal filler — apply the delete test"),
    ("#36", "corporate cliche — apply the interchangeability test"),
]

# --- Sentence segmentation ---------------------------------------------------

# A period inside one of these does not end a sentence. Fully enumerable, which
# is what keeps this a script and not a guess (`script-delegation` The Regex
# Trap). An unlisted abbreviation costs a false split, which inflates the count
# of short sentences and can only produce a false #3/#4 hit the agent then
# dismisses — never a miss.
ABBREVIATIONS = frozenset(
    """
    e.g. i.e. etc. vs. cf. al. ca. approx.
    mr. mrs. ms. dr. prof. sr. jr. st.
    inc. ltd. co. corp. dept. est.
    a.m. p.m. u.s. u.k. e.u.
    fig. no. vol. pp. ed. eds. repr.
    """.split()
)

_SENTENCE_END = re.compile(r"([.!?])([\"')\]]*)(\s+)")


def split_sentences(text):
    """Split prose into sentences, guarding abbreviations and numeric periods."""
    sentences = []
    start = 0
    for match in _SENTENCE_END.finditer(text):
        end = match.end(2)
        head = text[start:end]

        last_token = head.split()[-1].lower() if head.split() else ""
        if last_token in ABBREVIATIONS:
            continue

        # A lone capital before the period is an initial ("J. R. R. Tolkien"),
        # not a terminator. There is deliberately no digit guard here: the
        # pattern above requires whitespace after the period, so a decimal
        # ("v1.2", "0.3%") never matches in the first place, while "It failed at
        # 4. 3 people knew." is two real sentences that a digit guard would
        # merge — suppressing exactly the fragment-chain and burstiness findings
        # this script exists to catch.
        if re.search(r"\b[A-Z]\.$", head):
            continue

        sentence = head.strip()
        if sentence:
            sentences.append(sentence)
        start = match.end(3)

    tail = text[start:].strip()
    if tail:
        sentences.append(tail)
    return sentences


# --- Markdown handling -------------------------------------------------------

_FRONTMATTER = re.compile(r"\A---\n.*?\n---\n", re.DOTALL)
_HTML_COMMENT = re.compile(r"<!--.*?-->", re.DOTALL)
_PLACEHOLDER = re.compile(
    r"\[(?:Screenshot|Code|Link|Fact|Diagram)\s+\d+:[^\]]*\]", re.IGNORECASE
)
_FENCE = re.compile(r"^\s*(```|~~~)")
_HEADING = re.compile(r"^\s{0,3}#{1,6}\s")
_LIST_ITEM = re.compile(r"^\s*(?:[-*+]\s+|\d+[.)]\s+)")
_BLOCKQUOTE = re.compile(r"^\s*>")
_TABLE_ROW = re.compile(r"^\s*\|")

_LINK = re.compile(r"!?\[([^\]]*)\]\([^)]*\)")
_INLINE_CODE = re.compile(r"`[^`]*`")
_EMPHASIS = re.compile(r"(\*\*|\*|__|_)")


def normalize_inline(text):
    """Strip markdown decoration so a word count counts words, not syntax."""
    text = _PLACEHOLDER.sub(" ", text)
    text = _LINK.sub(r"\1", text)
    text = _INLINE_CODE.sub("code", text)
    text = _EMPHASIS.sub("", text)
    return text


def count_words(sentence):
    return len(normalize_inline(sentence).split())


class Block:
    """One markdown block, with the source lines it was built from.

    `numbered` keeps each surviving source line paired with its 1-indexed
    number, so a sweep that reports per line (#18) can point at the real line
    while still seeing only content the parser did not exclude.
    """

    def __init__(self, kind, line, text, numbered=None):
        self.kind = kind
        self.line = line
        self.text = text
        self.numbered = numbered if numbered is not None else [(line, text)]


def parse(raw):
    """Split a draft into blocks and sections.

    What is excluded, and why each exclusion is a correctness fix rather than a
    narrowing of the check:

      fenced code, frontmatter, HTML comments
          not prose. `<!-- VERIFY: ... -->` markers and ```d2 diagram sources
          are draft machinery per `process.md` placeholder conventions.
      headings
          not sentences. Counting them inflates the short-sentence runs #3/#4
          looks for.
      list items and table rows (for #3/#4 and #14 only)
          a list of five three-word items is a list, not a fragment chain, and
          parallel list items are supposed to be uniform in length. Flagging
          them would fire on every post that contains a list. Em-dash sweeps
          (#7, #8) and the unicode sweep (#18) still cover list text, since an
          em-dash in a list item is still an em-dash.
      placeholder lines
          `[Screenshot 01: ...]` is an asset marker, not a sentence.

    Returns (blocks, sections). A section is (heading_text, line, [block, ...])
    delimited by markdown headings; text before the first heading forms an
    implicit leading section so a heading-less draft is still swept.
    """
    raw = _FRONTMATTER.sub("", raw)
    raw = _HTML_COMMENT.sub("", raw)

    lines = raw.split("\n")
    blocks = []
    in_fence = False
    pending = []
    pending_line = 0

    def flush():
        nonlocal pending, pending_line
        if not pending:
            return
        text = "\n".join(line for _, line in pending).strip()
        if text:
            raw_lines = [line for _, line in pending]
            blocks.append(Block(classify(raw_lines), pending_line, text, list(pending)))
        pending = []

    def classify(group):
        first = group[0]
        if _HEADING.match(first):
            return "heading"
        if any(_LIST_ITEM.match(line) for line in group):
            return "list"
        if _TABLE_ROW.match(first):
            return "list"
        if _BLOCKQUOTE.match(first):
            return "quote"
        if _PLACEHOLDER.fullmatch(first.strip()):
            return "placeholder"
        return "prose"

    for index, line in enumerate(lines, start=1):
        if _FENCE.match(line):
            flush()
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        if not line.strip():
            flush()
            continue
        # A heading always stands alone, even when not blank-line separated.
        if _HEADING.match(line):
            flush()
            blocks.append(Block("heading", index, line.strip(), [(index, line)]))
            continue
        if not pending:
            pending_line = index
        pending.append((index, line))
    flush()

    sections = []
    current = ("(before the first heading)", 1, [])
    for block in blocks:
        if block.kind == "heading":
            if current[2]:
                sections.append(current)
            current = (block.text, block.line, [])
            continue
        current[2].append(block)
    if current[2]:
        sections.append(current)

    return blocks, sections


# --- Sweeps ------------------------------------------------------------------
# Each returns a list of hits. A hit is a dict, so --json and the readable
# report render the same finding rather than diverging.


def sentence_units(block):
    """Yield the units a sentence-level sweep may look inside.

    A prose paragraph is one unit wrapped across source lines, so it is
    sentence-split whole. A list or table is a set of independent items that
    happen to be adjacent, so each line is split separately — otherwise the
    trailing em-dash of one item pairs with the leading em-dash of the next and
    reports an aside that does not exist.
    """
    if block.kind in ("list", "quote"):
        sources = [line for line in block.text.split("\n") if line.strip()]
    else:
        sources = [block.text]
    for source in sources:
        for sentence in split_sentences(source):
            yield sentence


def hit(pattern, label, line, detail, context=""):
    return {
        "pattern": pattern,
        "label": label,
        "line": line,
        "detail": detail,
        "context": " ".join(context.split())[:90],
    }


def sweep_fragments(blocks):
    """#3/#4 — 3+ consecutive sentences under six words in one paragraph."""
    hits = []
    for block in blocks:
        if block.kind != "prose":
            continue
        sentences = split_sentences(block.text)
        run = []
        for sentence in sentences:
            if count_words(sentence) < FRAGMENT_MAX_WORDS:
                run.append(sentence)
                continue
            if len(run) >= FRAGMENT_RUN:
                hits.append(
                    hit(
                        "#3/#4",
                        "fragment chain",
                        block.line,
                        f"{len(run)} consecutive sentences under "
                        f"{FRAGMENT_MAX_WORDS} words",
                        " ".join(run),
                    )
                )
            run = []
        if len(run) >= FRAGMENT_RUN:
            hits.append(
                hit(
                    "#3/#4",
                    "fragment chain",
                    block.line,
                    f"{len(run)} consecutive sentences under "
                    f"{FRAGMENT_MAX_WORDS} words",
                    " ".join(run),
                )
            )
    return hits


def sweep_paired_emdash(blocks):
    """#7 — every paired em-dash. Each occurrence is a flag regardless of count.

    Matched per sentence: a parenthetical aside lives inside one sentence, so
    matching across the whole text would pair the dash of one sentence with the
    dash of the next.
    """
    pattern = re.compile(
        EM_DASH
        + r"[^"
        + EM_DASH
        + r"]{1,"
        + str(PAIRED_EMDASH_MAX_SPAN)
        + r"}"
        + EM_DASH
    )
    hits = []
    for block in blocks:
        if block.kind in ("heading", "placeholder"):
            continue
        for sentence in sentence_units(block):
            for match in pattern.finditer(sentence):
                hits.append(
                    hit(
                        "#7",
                        "PAIRED EM-DASH",
                        block.line,
                        match.group().replace("\n", " "),
                        sentence,
                    )
                )
    return hits


def sweep_emdash_density(sections):
    """#8 — more than two em-dashes in a section."""
    hits = []
    for heading, line, blocks in sections:
        count = sum(
            block.text.count(EM_DASH) for block in blocks if block.kind != "placeholder"
        )
        if count > EMDASH_PER_SECTION:
            hits.append(
                hit(
                    "#8",
                    "em-dash density",
                    line,
                    f"{count} em-dashes (limit {EMDASH_PER_SECTION})",
                    heading,
                )
            )
    return hits


def sweep_burstiness(blocks):
    """#14 — a run of sentences whose lengths sit within 5 words of each other."""
    hits = []
    for block in blocks:
        if block.kind != "prose":
            continue
        lengths = [count_words(s) for s in split_sentences(block.text)]
        if len(lengths) < BURSTINESS_RUN:
            continue
        for index in range(len(lengths) - BURSTINESS_RUN + 1):
            window = lengths[index : index + BURSTINESS_RUN]
            if max(window) - min(window) <= BURSTINESS_SPREAD:
                hits.append(
                    hit(
                        "#14",
                        "low burstiness",
                        block.line,
                        f"{window} of {lengths}",
                        block.text,
                    )
                )
                break  # one hit per paragraph; the fix is the paragraph
    return hits


def sweep_unicode(blocks):
    """#18 — characters that mark the text as machine-set.

    Runs over parsed blocks rather than the raw file, so the exclusions
    `parse()` documents hold here too: a bullet character inside a fenced code
    block, a curly quote in a `<!-- VERIFY -->` marker, or an en dash in the
    frontmatter is not a tell in the prose. Headings and lists are included,
    since the reader sees them; asset placeholders are not.
    """
    eligible = [
        (number, text)
        for block in blocks
        if block.kind != "placeholder"
        for number, text in block.numbered
    ]

    hits = []
    for description, chars in UNICODE_GIVEAWAYS:
        total = sum(text.count(char) for _, text in eligible for char in chars)
        if not total:
            continue
        number, text = next(
            (number, text)
            for number, text in eligible
            if any(char in text for char in chars)
        )
        hits.append(
            hit("#18", "unicode giveaway", number, f"{description} x{total}", text)
        )
    return hits


def run_sweeps(raw):
    blocks, sections = parse(raw)
    hits = []
    hits += sweep_fragments(blocks)
    hits += sweep_paired_emdash(blocks)
    hits += sweep_emdash_density(sections)
    hits += sweep_burstiness(blocks)
    hits += sweep_unicode(blocks)
    hits.sort(key=lambda h: (h["line"], h["pattern"]))
    return hits


# --- Reporting ---------------------------------------------------------------


def report(path, hits):
    """The readable report. Always states coverage, hits or not."""
    out = [f"=== MECHANICAL SWEEP: {path} ===", ""]

    if hits:
        for item in hits:
            out.append(f"  [{item['pattern']} {item['label']}] {item['detail']}")
            if item["context"]:
                out.append(f"      L{item['line']}: {item['context']}")
        out.append("")
        out.append(f"{len(hits)} hit(s). Every predicate here is arithmetic, so each")
        out.append("is a finding, not a candidate for you to weigh.")
    else:
        out.append("  no hits in the counting sweeps")

    out.append("")
    out.append(f"RAN ({len(COUNTING_SWEEPS)} counting sweeps):")
    out.append("  " + " · ".join(f"{num} {name}" for num, name in COUNTING_SWEEPS))
    out.append("")
    out.append("NOT RUN — these need your read, no regex decides them:")
    for num, name in JUDGMENT_SWEEPS:
        out.append(f"  {num:<6} {name}")
    covered = len(COUNTING_SWEEPS) + 1  # #3/#4 is two patterns under one sweep
    out.append("")
    out.append(
        f"This script examined {covered} of {PATTERNS_TOTAL} patterns. The other "
        f"{PATTERNS_TOTAL - covered} —"
    )
    out.append("  the seven above plus the rest of references/ai-anti-patterns.md —")
    out.append("  are unexamined. A zero-hit sweep is not an anti-pattern check.")
    return "\n".join(out)


def main(argv=None):
    parser = argparse.ArgumentParser(
        prog="sweep.py",
        description="Counting sweeps of the Pass 1 anti-pattern check.",
    )
    parser.add_argument("draft", help="path to the draft markdown file")
    parser.add_argument(
        "--json",
        action="store_true",
        dest="as_json",
        help="emit the structured result instead of the readable report",
    )
    args = parser.parse_args(argv)

    path = Path(args.draft)
    try:
        raw = path.read_text(encoding="utf-8")
    except FileNotFoundError:
        print(
            f"error: no such file: {path} — pass the path to the draft to sweep",
            file=sys.stderr,
        )
        return 2
    except IsADirectoryError:
        print(
            f"error: {path} is a directory — pass the draft file itself",
            file=sys.stderr,
        )
        return 2
    except PermissionError:
        print(
            f"error: cannot read {path} — check the file's permissions",
            file=sys.stderr,
        )
        return 2
    except UnicodeDecodeError:
        print(
            f"error: {path} is not valid UTF-8 — the sweep counts characters, so "
            "it needs decodable text; re-save the draft as UTF-8",
            file=sys.stderr,
        )
        return 2

    hits = run_sweeps(raw)

    if args.as_json:
        print(
            json.dumps(
                {
                    "ok": True,
                    "path": str(path),
                    "hits": hits,
                    "ran": [f"{num} {name}" for num, name in COUNTING_SWEEPS],
                    "not_run": [f"{num} {name}" for num, name in JUDGMENT_SWEEPS],
                    "patterns_total": PATTERNS_TOTAL,
                },
                indent=2,
            )
        )
    else:
        print(report(path, hits))

    return 1 if hits else 0


# Entry-point guard per `jbaruch/coding-policy: file-hygiene` — the script runs
# when executed and stays importable for testing or reuse.
if __name__ == "__main__":
    sys.exit(main())
