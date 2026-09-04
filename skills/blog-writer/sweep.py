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

This script covers 4 numbered patterns across 3 sweeps (#3 and #4 share the
fragment-chain sweep), plus supplemental fixed-output checks. It says so on
every run. The numbered total is counted from `references/ai-anti-patterns.md`
rather than restated here.
Every result carries its coverage, including a result with no findings: silence
about coverage is what lets a passing script displace the contextual read it
never performed.

Usage:
    sweep.py [--mode draft|final] <draft.md>

Input:
    --mode  `draft` permits supported asset placeholders and VERIFY comments;
            `final` reports them as finalization blockers. Defaults to `draft`.
    draft   path to the draft. Markdown is parsed, not treated as flat text —
            see "What is excluded" in parse().

Output (stdout):
    A single JSON object (`script-delegation` Script Requirements):
      {"ok": true, "path": "<file>", "hits": [ ... ],
       "candidates": {"assistant_chatter": [ ... ]},
       "observations": { ... }, "coverage": { ... }}

    Each hit carries {"pattern", "label", "line", "detail", "context",
    "verify_context", "token"}. `line` is the 1-indexed source line. `token`
    is the exact matched text for deterministic residue and finalization hits;
    aggregate counting hits use null.

    Each assistant-chatter candidate carries {"pattern", "label", "line",
    "detail", "context", "token", "test"}. These ambiguous phrases require
    contextual review and do not affect the exit code.

    `observations.em_dashes` carries paired-aside locations and per-section
    counts. They require the identity/genre judgment in patterns #7 and #8 and
    never affect the exit code on their own.

    `coverage` carries {"ran", "supplemental_checks", "not_run_judgment",
    "patterns_examined", "patterns_total", "note"}. It is present on every run,
    including a run with no hits, because an empty `hits` reads as "the check
    passed" when it means "the counting half passed".

Exit codes:
    0  swept, no hits in the counting sweeps. NOT "the draft is clean" — most
       of the patterns were not examined by this script, and `.coverage.note`
       says how many.
    1  swept, at least one hit. Each is a real finding: every predicate here is
       arithmetic, so there is no judgment call left for the caller to make.
    2  tool or usage error (no path given, file unreadable, not valid UTF-8,
       or references/ai-anti-patterns.md missing so the coverage total cannot
       be counted).

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

EM_DASH = "—"

# Blocks whose sentences the fragment and burstiness sweeps read. A blockquote
# is reader-visible prose the author most often wrote, so excluding it narrowed
# the sweep without saying so. A quoted passage that is genuinely someone else's
# words is a finding the agent dismisses, which is the safe direction.
PROSE_KINDS = ("prose", "quote")

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

# WP:OAICITE — fixed output artifacts emitted by specific model interfaces.
CITATION_ARTIFACTS = [
    (
        "ChatGPT contentReference",
        re.compile(r"\bcontentReference(?:\[oaicite:\d+\]\{index=\d+\}|\b)"),
    ),
    ("ChatGPT oaicite", re.compile(r"(?<!contentReference\[)\boaicite\b")),
    ("ChatGPT oai_citation", re.compile(r"\boai_citation\b")),
    ("ChatGPT search reference", re.compile(r"\bturn\d+search\d+\b")),
    ("ChatGPT attributableIndex", re.compile(r"\battributableIndex\b")),
    ("Gemini citation", re.compile(r"\[cite:\s*\d+\]")),
    ("Gemini span", re.compile(r"\[span_\d+\]\(start_span\)")),
    ("Grok card", re.compile(r"\bgrok_card\b")),
    ("Grok citation card", re.compile(r"\bgrok_render_citation_card_json\b")),
    ("DeepSeek line citation", re.compile(r"【\d+†L\d+(?:-\d+)?】")),
    ("Perplexity attached file", re.compile(r"\[attached_file:\d+\]")),
    ("Perplexity web citation", re.compile(r"\[web:\d+\]")),
    ("Perplexity file upload", re.compile(r"\bppl-ai-file-upload\b")),
    (
        "unclassified writing wrapper",
        re.compile(r":::writing\{[^}\r\n]*\}"),
    ),
]

ASSISTANT_CHATTER_CANDIDATES = [
    ("assistant sign-off", re.compile(r"\bI hope this helps\b", re.IGNORECASE)),
    ("assistant offer", re.compile(r"\bWould you like\b", re.IGNORECASE)),
    ("assistant follow-up", re.compile(r"\blet me know\b", re.IGNORECASE)),
]

TRACKING_PARAMETERS = re.compile(
    r"[?&]"
    r"(?P<parameter>utm_source=(?:openai|chatgpt\.com|copilot\.com)|referrer=grok\.com)"
    r"(?=$|[&#\s)\]}>]|['\"]|[.,;](?:\s|$))",
    re.IGNORECASE,
)

THEMATIC_BREAK = re.compile(r"^\s{0,3}(?:-{3,}|\*{3,}|_{3,})\s*$")
H2_HEADING = re.compile(r"^\s{0,3}##\s+")

# --- Coverage statement ------------------------------------------------------
# Printed on every run, hits or not. The inverse failure this script is built to
# avoid is a clean report displacing the read it never performed.

# The total is not a literal here. `references/ai-anti-patterns.md` defines the
# patterns, so it is the thing that knows how many there are; a number copied
# into this script is a second answer that goes stale the next time the
# Wikipedia refresh adds a pattern, and it goes stale silently, inside the one
# sentence whose job is to state honestly how much went unexamined.
ANTI_PATTERNS_FILE = (
    Path(__file__).resolve().parent / "references" / "ai-anti-patterns.md"
)

# A pattern is an H2 heading that opens with its number: "## 12. AI Vocabulary
# Contamination". The "## Running the check" preamble carries no number and is
# not a pattern.
PATTERN_HEADING = re.compile(r"^## \d+\. ", re.MULTILINE)

# Four, not three: #3 and #4 are two patterns sharing one fragment-chain sweep.
PATTERNS_EXAMINED = 4

COUNTING_SWEEPS = [
    ("#3/#4", "fragment chains"),
    ("#14", "low burstiness"),
    ("#18", "unicode giveaways"),
]

SUPPLEMENTAL_SWEEPS = [
    ("WP:OAICITE", "citation-artifact leakage"),
    ("WP:TRACKING", "AI-source tracking parameters"),
    ("WP:ASSISTANT", "assistant-chatter candidate discovery"),
    ("WP:SECTIONBREAK", "thematic breaks between every section"),
]

FINAL_SUPPLEMENTAL_SWEEP = (
    "WP:FINALIZATION",
    "unresolved placeholders and VERIFY markers",
)

JUDGMENT_SWEEPS = [
    ("#1", "contrastive negation — is it the same slot?"),
    ("#7", "paired em-dashes — compare identity, genre, and rhetorical function"),
    ("#8", "em-dash density — compare observations with same-mode evidence"),
    ("#10", "introductory filler — apply the delete test"),
    ("#12", "AI vocabulary — the watchlist qualifiers are the check"),
    ("#17", "synonym cycling — do two phrases denote one concept?"),
    ("#32", "stacked data points — do two numbers make one point?"),
    ("#35", "temporal filler — apply the delete test"),
    ("#36", "corporate cliche — apply the interchangeability test"),
    ("#40", "vague connection — name the relationship"),
    ("#41", "source-unavailability hedging — cut unsupported claims"),
    ("#42", "ceremonial coverage — use what the source establishes"),
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

# A run of two or more single-letter initials ("J. R. R. ", "H. G. "). Two is
# the threshold that makes this enumerable: one lone capital before a period is
# genuinely ambiguous ("A. Smith wrote it." against "Pick A. Smith wrote it."),
# and no regex settles it. Two in a row is a name.
_INITIAL_RUN = re.compile(r"(?:\b[A-Z]\.[ \t]+){2,}")


def split_sentences(text):
    """Split prose into sentences, guarding abbreviations and runs of initials."""
    protected = [found.span() for found in _INITIAL_RUN.finditer(text)]
    sentences = []
    start = 0
    for match in _SENTENCE_END.finditer(text):
        end = match.end(2)
        head = text[start:end]

        last_token = head.split()[-1].lower() if head.split() else ""
        if last_token in ABBREVIATIONS:
            continue

        # No period inside a run of initials ends a sentence, the run's last one
        # included — "J. R. R. Tolkien" is one name, and splitting before the
        # surname leaves two one-word sentences that read as a fragment chain.
        #
        # A single lone capital is deliberately NOT protected. Treating every
        # trailing capital as an initial swallowed the boundary in ordinary
        # prose ("Pick A. Go. Stop." merged at "A."), and telling the two apart
        # needs to know whether a name follows, which is reasoning rather than
        # scripting (`script-delegation` The Regex Trap).
        #
        # There is deliberately no digit guard either: the pattern above
        # requires whitespace after the period, so a decimal ("v1.2", "0.3%")
        # never matches in the first place, while "It failed at 4. 3 people
        # knew." is two real sentences a digit guard would merge.
        #
        # Every remaining ambiguity falls toward a split rather than a merge. A
        # false split inflates the count of short sentences and surfaces as a
        # #3/#4 hit the agent dismisses; a merge removes a finding silently.
        if any(lo <= match.start(1) < hi for lo, hi in protected):
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

_PLACEHOLDER = re.compile(
    r"\[(?:Screenshot|Code|Link|Fact|Diagram)\s+\d+:[^\]]*\]", re.IGNORECASE
)
_FENCE = re.compile(r"^(\s{0,3})(`{3,}|~{3,})(.*)$")

# A YAML key line, and a continuation or list item under one. Together they are
# the bounded grammar that separates real frontmatter from a thematic break.
_YAML_KEY = re.compile(r"^[A-Za-z_][A-Za-z0-9_.-]*\s*:")
_YAML_CONTINUATION = re.compile(r"^(?:\s+\S|-\s+\S)")

# Only a comment that closes. A stray `<!--` stays ordinary content.
_CLOSED_COMMENT = re.compile(r"<!--.*?-->", re.DOTALL)
_HEADING = re.compile(r"^\s{0,3}#{1,6}\s")
_LIST_ITEM = re.compile(r"^\s*(?:[-*+]\s+|\d+[.)]\s+)")
_BLOCKQUOTE = re.compile(r"^\s*>")

# The marker itself, stripped before a blockquote is read as prose.
_BLOCKQUOTE_MARKER = re.compile(r"^\s*>\s?")
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


def line_kind(line):
    """The structural kind of a single line."""
    if _HEADING.match(line):
        return "heading"
    if _LIST_ITEM.match(line):
        return "list"
    if _TABLE_ROW.match(line):
        return "list"
    if _BLOCKQUOTE.match(line):
        return "quote"
    if _PLACEHOLDER.fullmatch(line.strip()):
        return "placeholder"
    return "prose"


def segment(group):
    """Split one blank-line-delimited group into runs of a single kind.

    Markdown lets prose run straight into a list with no blank line between
    them. Labelling the whole group by whether any line looked like a list item
    put that prose in a list block, and the sentence sweeps skip lists — so a
    real fragment chain sitting immediately above a list went unreported.

    A prose line following a list, table, or quote is the opposite case: markdown
    reads it as a lazy continuation of the item above, so it stays with its
    segment rather than opening a new one. That keeps a wrapped list item whole.

    Yields (kind, [(line number, text), ...]).
    """
    segments = []
    for number, text in group:
        kind = line_kind(text)
        if segments and (
            kind == segments[-1][0] or (kind == "prose" and segments[-1][0] != "prose")
        ):
            segments[-1][1].append((number, text))
            continue
        segments.append((kind, [(number, text)]))
    return segments


def frontmatter_end(source):
    """Index of the line closing YAML frontmatter, or None when there is none.

    Frontmatter is recognised by a bounded grammar, not by "a `---` followed by
    another `---`. A document that opens with a thematic break and carries a
    second one later would otherwise hide every line between them from every
    sweep, and a draft with no blocks sweeps clean. So the delimiter must be
    followed by a YAML key, and every non-blank line up to the closer must keep
    looking like YAML; the first line that does not means this was never
    frontmatter.
    """
    if not source or source[0].strip() != "---":
        return None
    if len(source) < 2 or not _YAML_KEY.match(source[1]):
        return None

    for index in range(1, len(source)):
        stripped = source[index].strip()
        if stripped == "---":
            return index
        if not stripped:
            continue
        if not (
            _YAML_KEY.match(source[index]) or _YAML_CONTINUATION.match(source[index])
        ):
            return None
    return None


def fence_end(source, index, marker):
    """Index of the line closing the fence opened at `index`, or None.

    Per CommonMark the closer uses the same character, runs at least as long as
    the opener, and carries no info string. Accepting any fence-looking line let
    a ``` block be closed by ~~~, or by a shorter run, which silently excluded
    the prose in between.
    """
    char = marker[0]
    for candidate in range(index + 1, len(source)):
        found = _FENCE.match(source[candidate])
        if not found:
            continue
        closer = found.group(2)
        if (
            closer[0] == char
            and len(closer) >= len(marker)
            and not found.group(3).strip()
        ):
            return candidate
    return None


def excluded_spans(source):
    """Line indices inside frontmatter or a closed fenced block.

    Every region here must close. An opener with no closer that still swallowed
    the rest of the file would leave the sweep with nothing to examine and an
    exit code that reads as clean — the failure this script exists to prevent.
    An unterminated fence is a typo whose content still reads.
    """
    spans = set()
    index = 0

    close = frontmatter_end(source)
    if close is not None:
        spans.update(range(0, close + 1))
        index = close + 1

    while index < len(source):
        found = _FENCE.match(source[index])
        if found:
            fence_close = fence_end(source, index, found.group(2))
            if fence_close is None:
                index += 1
                continue
            spans.update(range(index, fence_close + 1))
            index = fence_close + 1
            continue
        index += 1

    return spans


def strip_closed_comments(source):
    """Blank the characters inside closed HTML comments, keeping every line.

    Only a comment with a closing marker is a comment. Tracking `<!--` as state
    meant an unterminated one made every later line transparent, so the sweep
    exited 0 having examined no prose. Matching the closed form leaves a stray
    `<!--` as ordinary content instead.

    Characters are replaced one for one and newlines are left alone, so line
    numbers and the columns around the comment survive untouched.
    """
    text = "\n".join(source)
    if "<!--" not in text:
        return list(source)

    out = list(text)
    for found in _CLOSED_COMMENT.finditer(text):
        for position in range(found.start(), found.end()):
            if out[position] != "\n":
                out[position] = " "
    return "".join(out).split("\n")


def read_lines(source):
    """Label every source line content, blank, or transparent.

    Three roles rather than two, because deleting excluded text is not safe in
    either direction. Deleting it outright collapses its newlines, which shifts
    the reported line of every later finding and can concatenate the prose on
    either side onto one line. Blanking it preserves the numbering but turns a
    multi-line comment into a paragraph break, which splits a paragraph the
    author wrote as one and can lose a fragment-chain or burstiness finding
    entirely — the failure this script exists to prevent.

    A transparent line therefore holds its number without being either content
    or a separator: block assembly skips it and does not flush on it.
    """
    excluded = excluded_spans(source)
    stripped = strip_closed_comments(source)
    records = []

    for index, line in enumerate(stripped, start=1):
        if index - 1 in excluded:
            records.append((index, "", "transparent"))
            continue

        if not line.strip():
            # A line the author left empty separates paragraphs; a line left
            # empty by removing a comment does not.
            was_blank = not source[index - 1].strip()
            records.append((index, "", "blank" if was_blank else "transparent"))
            continue

        records.append((index, line, "content"))

    return records


def parse(raw):
    """Split a draft into blocks and sections.

    What is excluded, and why each exclusion is a correctness fix rather than a
    narrowing of the check:

      fenced code, frontmatter, HTML comments
          not prose. `<!-- VERIFY: ... -->` markers and ```d2 diagram sources
          are draft machinery per `process.md` placeholder conventions. Draft
          mode makes them transparent rather than deleting them. Final mode also
          scans unresolved machinery directly from the raw artifact through
          sweep_finalization_artifacts().
      headings
          not sentences. Counting them inflates the short-sentence runs #3/#4
          looks for. They are still swept for #18, which the reader sees.
      list items and table rows (for #3/#4 and #14 only)
          a list of five three-word items is a list, not a fragment chain, and
          parallel list items are supposed to be uniform in length. Flagging
          them would fire on every post that contains a list. Em-dash
          observations (#7, #8) and the unicode sweep (#18) still cover list
          text, including em dashes inside list items.
      placeholder lines
          `[Screenshot 01: ...]` is an asset marker, not a sentence.

    Returns (blocks, sections). A section is (heading_text, line, [block, ...])
    delimited by markdown headings; text before the first heading forms an
    implicit leading section so a heading-less draft is still swept.
    """
    blocks = []
    pending = []
    pending_line = 0

    def flush():
        nonlocal pending, pending_line
        if not pending:
            return
        for kind, lines in segment(pending):
            text = "\n".join(line for _, line in lines).strip()
            if text:
                blocks.append(Block(kind, lines[0][0], text, list(lines)))
        pending = []

    for index, text, role in read_lines(raw.split("\n")):
        if role == "transparent":
            continue
        if role == "blank":
            flush()
            continue
        if _HEADING.match(text):
            flush()
            blocks.append(Block("heading", index, text.strip(), [(index, text)]))
            continue
        if not pending:
            pending_line = index
        pending.append((index, text))
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
    """Yield (source line, sentence) for every sentence a sweep may look inside.

    A prose paragraph is one unit wrapped across source lines, so it is
    sentence-split whole and each sentence is mapped back to the line it starts
    on. A blockquote is prose too — wrapped the same way, just marked — so it
    takes the same path with the markers stripped; splitting it per line would
    cut every wrapped sentence in half. A list or table is a set of independent
    items that happen to be adjacent, so each line is split separately —
    otherwise the trailing em-dash of one item pairs with the leading em-dash of
    the next and reports an aside that does not exist.
    """
    if block.kind == "list":
        for number, text in block.numbered:
            for sentence in split_sentences(text):
                yield number, sentence
        return

    sources = [
        (number, _BLOCKQUOTE_MARKER.sub("", text) if block.kind == "quote" else text)
        for number, text in block.numbered
    ]

    starts = []
    cursor = 0
    for number, text in sources:
        starts.append((cursor, number))
        cursor += len(text) + 1
    whole = "\n".join(text for _, text in sources)

    searched = 0
    for sentence in split_sentences(whole):
        found = whole.find(sentence, searched)
        if found < 0:
            found = searched
        searched = found + len(sentence)
        number = starts[0][1] if starts else block.line
        for start, candidate in starts:
            if start > found:
                break
            number = candidate
        yield number, sentence


def hit(
    pattern,
    label,
    line,
    detail,
    context="",
    verify_context=False,
    token=None,
):
    """One finding.

    `verify_context` says whether the finding rests on where this script placed
    sentence boundaries. Counting characters or punctuation does not; counting
    sentences does, and where a boundary is ambiguous the splitter splits rather
    than merges, so a rare hit is the artifact of a split and not a real run.
    The flag travels with the hit so the consuming skill routes on emitted data
    instead of carrying its own copy of which sweeps are which
    (`jbaruch/coding-policy: script-as-black-box`).
    """
    return {
        "pattern": pattern,
        "label": label,
        "line": line,
        "detail": detail,
        "context": " ".join(context.split())[:90],
        "verify_context": verify_context,
        "token": token,
    }


def sweep_fragments(blocks):
    """#3/#4 — a run of consecutive short sentences in one paragraph."""
    hits = []
    for block in blocks:
        if block.kind not in PROSE_KINDS:
            continue

        def flag(run):
            hits.append(
                hit(
                    "#3/#4",
                    "fragment chain",
                    run[0][0],
                    f"{len(run)} consecutive sentences under "
                    f"{FRAGMENT_MAX_WORDS} words",
                    " ".join(sentence for _, sentence in run),
                    verify_context=True,
                )
            )

        run = []
        for number, sentence in sentence_units(block):
            if count_words(sentence) < FRAGMENT_MAX_WORDS:
                run.append((number, sentence))
                continue
            if len(run) >= FRAGMENT_RUN:
                flag(run)
            run = []
        if len(run) >= FRAGMENT_RUN:
            flag(run)
    return hits


def observe_emdashes(blocks, sections):
    """Count #7/#8 candidates without turning them into findings.

    Pair locations and section counts are arithmetic. Their verdict depends on
    author identity, assignment genre, and rhetorical function, so patterns #7
    and #8 own the judgment.
    """
    pattern = re.compile(EM_DASH + r"[^" + EM_DASH + r"]+" + EM_DASH)

    pairs = []
    for block in blocks:
        if block.kind in ("heading", "placeholder"):
            continue
        for number, sentence in sentence_units(block):
            for match in pattern.finditer(sentence):
                pairs.append(
                    {
                        "line": number,
                        "token": match.group(),
                        "context": " ".join(sentence.split())[:90],
                    }
                )

    section_counts = []
    for heading, line, blocks in sections:
        count = sum(
            block.text.count(EM_DASH) for block in blocks if block.kind != "placeholder"
        )
        section_counts.append(
            {
                "heading": heading,
                "line": line,
                "count": count,
            }
        )

    return {
        "paired_asides": pairs,
        "sections": section_counts,
        "total": sum(section["count"] for section in section_counts),
        "note": (
            "Observations only: apply patterns #7 and #8 with same-mode identity "
            "evidence and assignment genre."
        ),
    }


def sweep_burstiness(blocks):
    """#14 — a run of sentences whose lengths sit close to each other."""
    hits = []
    for block in blocks:
        if block.kind not in PROSE_KINDS:
            continue
        units = list(sentence_units(block))
        lengths = [count_words(sentence) for _, sentence in units]
        if len(lengths) < BURSTINESS_RUN:
            continue
        for index in range(len(lengths) - BURSTINESS_RUN + 1):
            window = lengths[index : index + BURSTINESS_RUN]
            if max(window) - min(window) <= BURSTINESS_SPREAD:
                hits.append(
                    hit(
                        "#14",
                        "low burstiness",
                        units[index][0],
                        f"{window} of {lengths}",
                        block.text,
                        verify_context=True,
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


def eligible_lines(blocks):
    """Reader-visible draft lines used by literal artifact sweeps."""
    return [
        (number, text)
        for block in blocks
        if block.kind != "placeholder"
        for number, text in block.numbered
    ]


def sweep_citation_artifacts(blocks):
    """WP:OAICITE — model-interface citation tokens leaked into the draft."""
    hits = []
    for number, text in eligible_lines(blocks):
        chatgpt_artifact = False
        for description, pattern in CITATION_ARTIFACTS:
            for found in pattern.finditer(text):
                chatgpt_artifact = chatgpt_artifact or description.startswith("ChatGPT")
                hits.append(
                    hit(
                        "WP:OAICITE",
                        "citation artifact",
                        number,
                        description,
                        found.group(),
                        token=found.group(),
                    )
                )
        if chatgpt_artifact and re.search(r"\+1\s*$", text):
            hits.append(
                hit(
                    "WP:OAICITE",
                    "citation artifact",
                    number,
                    "ChatGPT trailing +1",
                    "+1",
                    token="+1",
                )
            )
    return hits


def sweep_tracking_parameters(blocks):
    """WP:TRACKING — AI-product attribution leaked into a pasted URL."""
    hits = []
    for number, text in eligible_lines(blocks):
        for found in TRACKING_PARAMETERS.finditer(text):
            parameter = found.group("parameter")
            hits.append(
                hit(
                    "WP:TRACKING",
                    "AI-source tracking parameter",
                    number,
                    parameter,
                    text,
                    token=found.group(),
                )
            )
    return hits


def find_assistant_chatter_candidates(blocks):
    """Locate phrases that need a reader-facing-prose judgment.

    The same phrase can be leaked assistant chatter or an intentional address to
    the post's reader. The script reports exact locations; it does not decide
    which use the author intended.
    """
    candidates = []
    for number, text in eligible_lines(blocks):
        for description, pattern in ASSISTANT_CHATTER_CANDIDATES:
            for found in pattern.finditer(text):
                candidates.append(
                    {
                        "pattern": "WP:ASSISTANT",
                        "label": "possible assistant chatter",
                        "line": number,
                        "detail": description,
                        "context": " ".join(text.split())[:90],
                        "token": found.group(),
                        "test": (
                            "remove only if an assistant is addressing the author; "
                            "keep intentional prose addressed to the post's reader"
                        ),
                    }
                )
    return candidates


def sweep_finalization_artifacts(raw):
    """WP:FINALIZATION — unresolved draft machinery in a final artifact."""
    source = raw.split("\n")
    hits = []

    for index, text in enumerate(source, start=1):
        for found in _PLACEHOLDER.finditer(text):
            token = found.group()
            hits.append(
                hit(
                    "WP:FINALIZATION",
                    "unresolved asset placeholder",
                    index,
                    token,
                    text,
                    token=token,
                )
            )

    for found in re.finditer(r"<!--\s*VERIFY\b", raw, re.IGNORECASE):
        line = raw.count("\n", 0, found.start()) + 1
        close = raw.find("-->", found.end())
        if close >= 0:
            token = raw[found.start() : close + 3]
        else:
            token = raw[found.start() :].split("\n", 1)[0]
        hits.append(
            hit(
                "WP:FINALIZATION",
                "unresolved VERIFY marker",
                line,
                token,
                token,
                token=token,
            )
        )
    return hits


def sweep_section_breaks(raw):
    """WP:SECTIONBREAK — a thematic break in every gap between H2 sections."""
    visible = [
        (number, text)
        for number, text, role in read_lines(raw.split("\n"))
        if role == "content"
    ]
    headings = [number for number, text in visible if H2_HEADING.match(text)]
    breaks = [number for number, text in visible if THEMATIC_BREAK.match(text)]
    if len(headings) < 3:
        return []

    gaps = list(zip(headings, headings[1:]))
    separated = [
        (left, right)
        for left, right in gaps
        if any(left < line < right for line in breaks)
    ]
    if len(separated) != len(gaps):
        return []

    return [
        hit(
            "WP:SECTIONBREAK",
            "thematic break between every section",
            separated[0][0],
            f"{len(separated)} of {len(gaps)} section gaps contain a thematic break",
            "remove the repeated separators",
        )
    ]


def run_sweeps(raw, mode="draft"):
    blocks, sections = parse(raw)
    observations = {"em_dashes": observe_emdashes(blocks, sections)}
    hits = []
    hits += sweep_fragments(blocks)
    hits += sweep_burstiness(blocks)
    hits += sweep_unicode(blocks)
    hits += sweep_citation_artifacts(blocks)
    hits += sweep_tracking_parameters(blocks)
    hits += sweep_section_breaks(raw)
    if mode == "final":
        hits += sweep_finalization_artifacts(raw)
    hits.sort(key=lambda h: (h["line"], h["pattern"]))
    candidates = {
        "assistant_chatter": find_assistant_chatter_candidates(blocks),
    }
    return hits, candidates, observations


# --- Result -----------------------------------------------------------------


class PatternCountError(Exception):
    """`ai-anti-patterns.md` could not be counted. Carries an actionable message."""


def count_patterns(path=ANTI_PATTERNS_FILE):
    """How many patterns `ai-anti-patterns.md` defines.

    Raises PatternCountError rather than falling back to a guess: a coverage
    note built on a wrong total understates what went unexamined, which is the
    exact failure the note exists to prevent. A run that cannot count is a run
    that reports nothing.
    """
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as exc:
        # strerror is None on some OSError shapes, which would render the cause
        # as "None"; the exception's own str is the fallback.
        raise PatternCountError(
            f"error: cannot read the pattern file at {path} ({exc.strerror or exc}) — "
            "it ships beside this script, so a missing or unreadable copy means "
            "a broken install; reinstall the plugin"
        ) from exc
    except UnicodeDecodeError as exc:
        # Not an OSError, so it needs its own branch or it escapes as a
        # traceback — a crash where the contract promises exit 2.
        raise PatternCountError(
            f"error: the pattern file at {path} is not valid UTF-8 — its headings "
            "are counted from decoded text; re-save it as UTF-8"
        ) from exc

    total = len(PATTERN_HEADING.findall(text))
    # The floor is strictly above the examined count, not zero. This script's
    # whole contract is that it covers a minority: at four the note reports zero
    # unexamined while `not_run_judgment` still names seven sweeps it did not
    # run, and below four the arithmetic goes negative ("-1 of the 3 patterns
    # were not examined"). Both are structured nonsense, which is worse than no
    # report at all.
    if total <= PATTERNS_EXAMINED:
        raise PatternCountError(
            f"error: {path} defines {total} numbered pattern(s), not more than "
            f"the {PATTERNS_EXAMINED} this script sweeps for — the coverage note "
            "reports how many patterns went unexamined, which is only meaningful "
            "for a catalog larger than the sweep; every pattern is an H2 heading "
            'opening with its number ("## 12. AI Vocabulary Contamination"), so '
            "check the file was not truncated"
        )
    return total


def result(path, hits, candidates, observations, patterns_total, mode="draft"):
    """The full result object.

    `coverage` is not decoration. This script examines a minority of the
    patterns, and an empty `hits` on its own reads as "the check passed" rather
    than "the counting half passed". Every consumer sees what was not examined
    in the same object that tells it what was.
    """
    examined = PATTERNS_EXAMINED
    return {
        "ok": True,
        "path": str(path),
        "mode": mode,
        "hits": hits,
        "candidates": candidates,
        "observations": observations,
        "coverage": {
            "ran": [f"{number} {name}" for number, name in COUNTING_SWEEPS],
            "supplemental_checks": [
                f"{number} {name}" for number, name in SUPPLEMENTAL_SWEEPS
            ]
            + (
                [f"{FINAL_SUPPLEMENTAL_SWEEP[0]} {FINAL_SUPPLEMENTAL_SWEEP[1]}"]
                if mode == "final"
                else []
            ),
            "not_run_judgment": [
                f"{number} {name}" for number, name in JUDGMENT_SWEEPS
            ],
            "patterns_examined": examined,
            "patterns_total": patterns_total,
            "note": (
                f"{patterns_total - examined} of the {patterns_total} patterns "
                "were not examined by this script. An empty hits list is not an "
                "anti-pattern check: the judgment sweeps in not_run_judgment and "
                "the rest of references/ai-anti-patterns.md still need a read."
            ),
        },
    }


def main(argv=None):
    parser = argparse.ArgumentParser(
        prog="sweep.py",
        description="Counting sweeps of the Pass 1 anti-pattern check.",
    )
    parser.add_argument("draft", help="path to the draft markdown file")
    parser.add_argument(
        "--mode",
        choices=("draft", "final"),
        default="draft",
        help="draft permits placeholders; final reports unresolved draft machinery",
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

    # Counted before the sweep runs: a report this script cannot state the
    # coverage of is a report it must not print at all.
    try:
        patterns_total = count_patterns()
    except PatternCountError as exc:
        print(exc, file=sys.stderr)
        return 2

    hits, candidates, observations = run_sweeps(raw, args.mode)
    print(
        json.dumps(
            result(
                path,
                hits,
                candidates,
                observations,
                patterns_total,
                args.mode,
            ),
            indent=2,
        )
    )
    return 1 if hits else 0


# Entry-point guard per `jbaruch/coding-policy: file-hygiene` — the script runs
# when executed and stays importable for testing or reuse.
if __name__ == "__main__":
    sys.exit(main())
