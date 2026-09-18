---
name: blog-writer
description: >
  Write and revise developer blog posts, and humanize existing drafts using the AI
  anti-pattern catalog, structural checks, and author voice calibration. Use when asked
  for a "humanizer", "humanization pass", "humanisation pass", "humanize this",
  "humanise this", "de-AI this", "remove AI slop", "remove AI tells", "anti-AI pass",
  "make this sound less AI-generated", "less robotic", or "more natural" in a writing
  or editing request, even when the user does not mention a blog. Also use for writing
  a blog post, revising blog content, turning a video transcript, meeting notes, or
  rough ideas into a blog, and continuing a blog series. Preserve the author's meaning,
  technical accuracy, and voice while identifying and rewriting formulaic prose.
---

# Blog Writer

Process steps in order. Do not skip ahead.

Write developer blog posts for practitioners who build things, break things, and have
opinions about their tools. Compose the author's personal identity with an optional,
explicitly selected corporate identity. Personal identity supplies expression; corporate
identity supplies audience, terminology, evidence, positioning, and editorial constraints.

**Script invocation.** Run every script this skill calls through its interpreter: `bash`
for a `.sh`, `python3` for a `.py`. Never invoke one by bare path.

**Author preservation.** Before drafting or revising, record the assignment's claim,
stance, argument progression, and author-supplied wording under the preservation contract
in `skills/blog-writer/references/voice-calibration.md`. Check it after each completed
editing pass, including scanner-driven and corporate edits. Apply it to non-blog artifacts
too, preserving their format and requested scope.

## Step 1 — Route the Assignment

For a scoped humanization pass, review, copyedit, or local revision of an existing artifact,
read `skills/blog-writer/references/scoped-edit.md`, execute that route, and finish here.
Use that route for a non-blog writing assignment too. Preserve a review-only request.

For a new blog post or an explicitly requested full blog workflow, continue below.

Ask for or infer the blog home from the current project, then read
`skills/blog-writer/references/identity-composition.md`. Run its resolver with any
assignment-specific identity paths the author supplied. Personal and corporate identities
are independently optional, but at least one must resolve. Corporate identity is active
only when explicitly selected for the assignment or configured by the project. Never infer
corporate identity from the author, employer, topic, product, source URL, or personal
identity contents.

The resolver's JSON defines `personal/`, optional `corporate/`, and the exact `read_order`
for this session. These labels refer to resolved directories, not fixed paths.

Proceed immediately to Step 2.

## Step 2 — Route Identity Selection

On resolver exit 0 with a present project configuration, follow the draft-status and reading
rules in `skills/blog-writer/references/identity-composition.md`. Treat that selection as
authoritative and skip to Step 5. Do not run discovery or ask again. Apply the same route
when every assignment-specific identity path resolved.

For an unconfigured project with no complete assignment-specific selection, read
`skills/blog-writer/references/identity-storage.md`. Follow its shared-root discovery and
first-use selection flow. A resolver result carrying only the legacy fallback is still an
unconfigured project. Configure confirmed existing candidates together, rerun the resolver,
and skip to Step 5 only when it returns the confirmed personal-only, corporate-only, or
combined selection.

Proceed to Step 3 when the confirmed choice requires personal creation or legacy migration.
Proceed to Step 4 when it requires only corporate creation. If both require creation,
proceed to Step 3 first and retain the confirmed corporate choice for Step 4.

On resolver exit 1 reporting no selection, run the first-use flow above. For every other
exit 1, including an unusable selected or requested package, report the diagnostic and ask
the author to repair it or choose a replacement. Never fall back silently. On exit 2,
report the diagnostic and stop.

## Step 3 — Create a Personal Identity

If the author requests an interview or the supplied evidence is insufficient, read
`skills/blog-writer/references/setup.md` and collect that interview as another source. Do
not force the interview when representative sources already support an identity. Gather all
supplied and collected sources as creator input. For a legacy migration, add the resolver's
legacy root and request the creator's Step 2 v0-to-v1 rewrite. Invoke
`Skill(skill: "create-personal-identity")` with that input.

After approval, configure the returned directory through `configure-identities.py` as
described in `skills/blog-writer/references/identity-composition.md`. Preserve an existing
corporate selection or include the corporate candidate confirmed during first-use discovery.
Rerun the resolver. If the confirmed corporate choice still requires creation, proceed
immediately to Step 4; otherwise proceed immediately to Step 5.

## Step 4 — Create a Corporate Identity

Invoke `Skill(skill: "create-corporate-identity")` with the sources the author supplies.
Corporate-only configuration passes an empty personal value to `configure-identities.py`;
combined configuration preserves the selected v1 personal path. When the current personal
identity is legacy, keep the corporate path as an assignment-only resolver override. Step 2
routes persistent combined configuration through personal migration first. Never silently
replace the legacy personal layer.

After approval, configure the returned directory when the selection is persistent. Preserve
an existing personal selection or include the personal candidate returned by Step 3. Rerun
the resolver and proceed immediately to Step 5.

## Step 5 — Refresh the Anti-Pattern File

Read and execute `skills/blog-writer/references/catalog-refresh.md` in order. Run its
version check before fetching or comparing. Report the installed and latest versions.
Only the check's exit 0 permits the comparison; follow its exit 1/2 routes otherwise.
Never edit the installed catalog during refresh.

Proceed immediately to Step 6.

## Step 6 — Read the Reference Files

Read these reference files in order:

1. Every personal identity file in the resolver's `read_order`, stopping before the first
   corporate file. Read its entry point first and follow its routing. For a legacy identity,
   this starts with `persona/voice.md`. If there is no personal identity, use the generic
   tone guide for expression without inventing an individual persona.
2. Every corporate identity file in `read_order`, if selected. Read its entry point first
   and follow its routing. Record any explicit conflict the assignment does not resolve.
3. `persona/framework.md` for a legacy identity, if it exists and has content. It defines
   post-level architecture and overrides `skills/blog-writer/references/blog-anatomy.md`
   and the narrative-density doctrine in `skills/blog-writer/references/tone-guide.md`.
4. `skills/blog-writer/references/voice-calibration.md` — The evidence gate for personal
   voice, assignment-mode matching, paragraph continuity, and independent completion states.
5. `skills/blog-writer/references/tone-guide.md` — The generic writing framework. Narrative density rules,
   anti-pattern index, tone calibration, TLDR format.
6. `skills/blog-writer/references/ai-anti-patterns.md` — the catalog of named AI writing patterns to never use. Each has
   symptoms, examples, structural variants, and alternatives. The anti-pattern check in
   Phase 3 and 4 scans the draft against this file.
7. `skills/blog-writer/references/structural-audits.md` — Six discourse-level audits that work above the
   sentence: theme explicitness, structural tidiness, emotion mode, reference specificity,
   reader engagement, and shape convergence. Audits 1, 2, and 6 run on the outline in Phase 2;
   audits 3, 4, and 5 run on the prose in Phase 3 and 4.
8. `skills/blog-writer/references/process.md` — The workflow from transcript to published draft.
9. `skills/blog-writer/references/blog-anatomy.md` — Post shape (TLDR, hook, technical meat, CTA, bio) and
   series handling. Fallback only — a selected personal `composition` resource, including
   legacy `persona/framework.md`, overrides it.
10. Product-context resources from selected identities. Scan an index to know what is
   available, then fetch only relevant sources during Phase 0. A legacy
   `persona/product.md` remains available but does not activate corporate identity.

Proceed immediately to Step 7.

## Step 7 — Run Phase 0: Intake

Read the source material and build the narrative model: who is involved, what was built,
what went wrong, what went right, what was shown on screen, and the jokes and references
that surfaced naturally. Gather product context and previous posts in the series if either
is configured. `skills/blog-writer/references/process.md` Phase 0 has the full procedure.

Gate: the gaps in your understanding are identified. Do not summarize, and do not start
writing.

Proceed immediately to Step 8.

## Step 8 — Run Phase 1: Clarification

Ask the author one question at a time, each with 1-4 concrete options plus an open answer,
your best guess marked. Group questions by narrative, technical, visual, and context gaps.
`skills/blog-writer/references/process.md` Phase 1 has the question format and grouping rules.

Gate: the author confirms the narrative reconstruction is accurate and no ambiguity
remains.

Proceed immediately to Step 9.

## Step 9 — Run Phase 2: Editorial Planning

Lock the main idea, the CTA, and the section outline. `skills/blog-writer/references/process.md` Phase 2 has
the main-idea template and the outline requirements.

Name the assignment mode and select two or three usable passages written for that mode.
Follow `skills/blog-writer/references/voice-calibration.md`. These do not pass the evidence
gate:

- an approved identity
- a list of devices
- links without fetched prose

Record voice calibration as unresolved when matching evidence is unavailable.

Before locking, audit the outline against `skills/blog-writer/references/structural-audits.md`
audits 1, 2, and 6 — theme explicitness, structural tidiness, shape convergence — one audit
at a time. `skills/blog-writer/references/process.md` section 2g has the procedure.

For audit 6, ask the script for the verdict rather than reading the shape history yourself:

```bash
bash .tessl/plugins/jbaruch/blog-writer/skills/blog-writer/check-shape-convergence.sh \
  <blog-home>/_blog-skill/post-shapes.json "<opening_mode>" "<arc>" "<closing_mode>"
```

Route on the exit code:

- **Exit 0, `can_fire` false** — no verdict is possible. Report the `blocked_by` code and continue.
- **Exit 0, `converged` false** — the planned shape differs enough. Proceed silently.
- **Exit 0, `converged` true** — the audit fired. Follow the correction loop below before locking.
- **Exit 1** — the history exists but is unusable. Report the script's diagnostic and continue without audit 6.
- Never delete or overwrite an unusable history file.
- **Exit 2** — a tool error. Report the diagnostic and stop.

`blocked_by` says why no verdict was possible, and the three need different answers. Do not
report one as another:

- `no_history` — nothing recorded yet. Normal for a new author.
- `insufficient_history` — some posts recorded, not enough yet.
- `newer_records` — a newer plugin wrote part of the history, so this install cannot read the
  most recent posts. The fix is updating the plugin, not writing more posts.

On a `converged` verdict, verify before acting. The shape history is a hint, not authority.
Check each entry in `compared_posts` against the actual post.

Where a record disagrees, the post wins. Correct it by re-recording that post through
`record-post-shape.sh` (Step 12's script) with the corrected values, passing back every
field the entry carries — its `interventions` included, since re-recording without them
replaces the list with an empty one. Never hand-edit the JSON; the writer owns the file.
Then re-run the check.

Once the verdict is built on verified records, change the axes in `converged_axes`, re-run
on the revised plan, and repeat until it reports no convergence.

If an audit finds no issue, proceed silently.

Gate: the author approves the plan.

Proceed immediately to Step 10.

## Step 10 — Run Phase 3: First Draft

Write the draft to `blog-draft-[slug].md`, insert and confirm placeholders, then run the
anti-pattern, structural, accuracy, and tightening checks.
`skills/blog-writer/references/process.md` Phase 3 has the writing rules, the placeholder
conventions, and the check procedure.

Six rules bind this step and Step 11:

**Identity adherence.** When personal identity is selected, re-read its entry point, voice
resource, and selected calibration passages before every writing action — before this
draft, before every Step 11 revision, and before the anti-pattern rewrite voice-calibration
check. Name the assignment mode, calibration readiness, and passages used. If corporate identity is
selected, re-read its entry point and name its consequential requirements too.

**Voice calibration adherence.** Follow `skills/blog-writer/references/voice-calibration.md`.
Compare the pre-edit and post-edit prose on narrator presence, spoken cadence, connective
flow, reader relationship, and argument movement. Run the paragraph continuity check after
prose edits. Verify author preservation against source and revision passages before
delivery. Report author preservation, mechanical sweep, manual anti-pattern review, voice
calibration, and paragraph continuity as independent states. Never report voice as
calibrated while its evidence gate is unresolved.

**Anti-pattern check adherence.** Follow the three rules under "Running the check" at the
top of `skills/blog-writer/references/ai-anti-patterns.md` — re-read the file first, run the three-pass
procedure in order, and never invent a pattern the file or mechanical sweep does not define.

**Mechanical sweep adherence.** Run the draft-mode command and exit-code routing in
`skills/blog-writer/references/sweep-review.md`. Record a disposition for every hit.
Preserve raw findings when a contextual stylistic hit is retained. Run the catalog's
manual checks after either successful sweep exit. Rerun after a completed editing pass.

**Structural check adherence.** Run audits 3, 4, and 5 from
`skills/blog-writer/references/structural-audits.md` one at a time, after the anti-pattern
passes. Read the personal voice resource first when selected. Where the profile already prescribes the human-side
behavior, the audit is a drift check rather than a new rule. Never apply more than two
interventions from the menu to one post.

Run paragraph continuity after those audits. It is a voice-calibration check, not a seventh
structural intervention, and it does not change the two-intervention limit.

**Corporate review adherence.** If the selected corporate identity declares an
`editorial-review` resource, run it after the generic structural checks. Apply its scoped
requirements, then rerun the sweep and source-to-revision preservation check.

> **General rule — if you can't find a required file, ask the author. Don't claim it
> doesn't exist, don't assume its contents, don't skip the step.**

Gate: the draft is delivered to the author.

Proceed immediately to Step 11.

## Step 11 — Run Phase 4: Revision

Edit the draft file on the author's feedback, and rerun the Step 10 checks after each
completed editing pass. Preserve unaffected wording in local edits.
`skills/blog-writer/references/process.md` Phase 4 has the revision procedure.

After the author declares the post done, execute the final-mode procedure in
`skills/blog-writer/references/sweep-review.md` on the final file.

Gate: the author declares the post done, final-mode checks completed, all required hits
are resolved, and every contextual hit and assistant-chatter candidate has a recorded
disposition. Retained stylistic hits remain reported findings. Preservation must pass;
formal voice calibration may remain unresolved with its evidence gap stated.

Proceed immediately to Step 12.

## Step 12 — Record the Post's Shape

Append the finished post's skeleton to the shape history so the next post's audit 6 has
something to compare against. Do not write the file yourself. Run:

```bash
bash .tessl/plugins/jbaruch/blog-writer/skills/blog-writer/record-post-shape.sh \
  <blog-home>/_blog-skill/post-shapes.json "<slug>" "<YYYY-MM-DD>" \
  "<opening_mode>" "<arc>" "<closing_mode>" [intervention ...]
```

Record the post as it ended up, not as it was first drafted. Reuse an existing mode string
verbatim when the shape is the same; the comparison is by equality.
`skills/blog-writer/references/post-shapes-schema.md` has the field meanings.

Route on the exit code:

- **Exit 1** — the history was refused and left untouched. Report the script's stderr diagnostic to the author.
- Never work around a refusal by deleting the file.
- **Exit 2** — report the diagnostic and stop.

Finish here.
