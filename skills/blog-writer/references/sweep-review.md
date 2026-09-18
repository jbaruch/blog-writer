# Sweep review and delivery

Shared procedure for a full blog and a scoped artifact. Replace `<draft-path>` with the
actual artifact path. For pasted prose, put a working copy in a temporary file; do not
create a blog home or rename the user's artifact merely to run a check.

```bash
python3 .tessl/plugins/jbaruch/blog-writer/skills/blog-writer/sweep.py --mode draft <draft-path>
```

Run with `--mode final` on the final artifact before claiming it ready. For a review-only
request, run it on the unchanged input and report blockers without modifying that input.

## Read the result

- Exit 0: no raw hits. Complete the manual catalog review; coverage is partial.
- Exit 1: read every hit and apply the dispositions below. Do not loop to zero at the
  expense of the assignment. Retained matches remain hits with exit 1.
- Exit 2: report the tool diagnostic. Do not claim the check ran or the artifact is ready.

Stdout carries `mode`, `hits`, `candidates`, `observations`, and `coverage`.
Each hit has `pattern`, `label`, `line`, `detail`, `context`, `token`, `verify_context`, and
`review`. `token` identifies literal residue; aggregate counting hits use null.
`review` is the required/contextual routing signal; its classification belongs to
`skills/blog-writer/sweep.py` (`CONTEXTUAL_PATTERNS`), not to an inferred exemption.
Read the full passage at the reported line; `context` is only a truncated preview.
`verify_context` requires checking sentence segmentation, not assuming it was wrong.

`candidates.assistant_chatter` carries phrases to judge with their emitted `test`.
Remove assistant-to-author residue, retain intentional reader-facing prose, and record
that decision. Em-dash observations inform the catalog's calibration judgment and never
constitute findings on their own. `coverage` names what ran and what still needs reading;
`not_run_judgment` is not an exhaustive list of unexamined catalog patterns.

## Give every hit a disposition

For `review: required`, correct the hit. Author preference is not a waiver for this class.
For `review: contextual`, verify the segmentation and apply the catalog's actual test to
the whole passage in its assignment. Record one of:

- **Rewrite:** name the defect and make the smallest correction that retains the protected
  meaning and rhetorical function. Avoid padding, invented facts, and unrelated rewording.
- **Retain:** cite the passage, its source or explicit author direction, and the concrete
  function the construction serves here. Explain why removing it harms that function or
  why the pattern's contextual test does not establish a defect. An earned contrast,
  short answer, or setup/payoff is not a quota to reproduce elsewhere.
- **Segmentation artifact:** cite the actual sentence boundary and the mistaken split.
  A real arithmetic match cannot use this disposition.

"It is the author's voice" without passage evidence is insufficient. Endorsement establishes
an assignment preference, not factual truth or independent authorship. Unsupported claims,
fabricated experience, citation problems, and scope violations still require correction or
an explicit unresolved report; they cannot inherit a stylistic retention decision.
Do not hide, filter, or relabel retained hits as a clean sweep. A retention applies only
to that passage in that assignment; reassess after changes to it or its surrounding argument.
If a requested exact wording conflicts with a non-stylistic requirement, identify the
conflict rather than silently changing the user's intent or declaring the artifact ready.

## Complete the editing pass

After either exit 0 or 1, read the full anti-pattern catalog and complete its contextual
checks; match strings are not automatic defects. Apply the same passage-specific
retention test to manual stylistic matches, including supported parallel or interrogative
rhetoric. Generic style preferences do not override evidenced assignment choices. Complete source-to-revision preservation,
argument continuity, accuracy, and any selected corporate review. Rerun the sweep after
all resulting edits, then verify preservation on that version. A local correction need
not reopen unrelated wording or ask for a new approval.

Delivery readiness requires a completed final-mode check, no remaining required hits,
a disposition for every contextual hit and assistant-chatter candidate, and no known
preservation regression or unresolved factual blocker. The raw exit may still be 1 for
justified stylistic hits. Report those retained hits and their reasons plainly alongside
the independent states in `skills/blog-writer/references/voice-calibration.md`.
Formal voice calibration may remain unresolved without erasing known assignment evidence.
A draft or review with unresolved work may be returned as such, never described as ready.
