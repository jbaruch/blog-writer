---
name: create-personal-identity
description: Create, update, or audit a reusable personal writing identity from writing samples, transcripts, interviews, existing persona files, or editorial feedback. Use whenever someone wants to define, capture, refresh, migrate, or check an individual author's voice, tone, writing style, reasoning patterns, and writing preferences without absorbing employer brand rules.
---

# Create Personal Identity

This skill is an action router — pick the step that matches the user's intent and execute only that step. Do not run other steps; do not parallelize.

Personal identity owns how an author sounds and reasons, never employer positioning,
product claims, or corporate editorial policy.

Before any action, read the lifecycle reference completely and follow its ownership and
migration contract:

```text
skills/create-personal-identity/references/lifecycle.md
```

Use this package contract:

- Write `identity.json` with `schema_version: 1`, `type: personal`, a lowercase kebab-case
  `name`, `status` set to `draft` or `approved`, `entrypoint: identity.md`, and
  `sources: sources.md`.
- When supporting files exist, add `resources` as an ordered array of `{role, path}`
  objects. Each `role` is lowercase kebab-case. Each `path` is non-empty, does not start
  with `~`, is relative, and stays inside the package.
- Put concise shared guidance and routing in `identity.md`; add `voice`, `composition`,
  `examples`, or `bio` resources only when evidence supports them.
- In `sources.md`, record every source's location, date, scope, and authority.
- Trace each consequential inference to evidence.
- Label guidance Required, Preferred, Observed, Avoid, or Unresolved.
- Distinguish explicit preferences from observed patterns.
- Keep conflicting evidence and guidance visible.

Use this approval loop for every consequential create or update:

- Set `status` to `draft`.
- Show the one-paragraph summary, Required and Avoid guidance, high-impact inferences, and
  unresolved items.
- Ask one focused question at a time for consequential conflicts.
- When the user rejects or corrects a conclusion, revise it.
- Re-read each revised conclusion beside its cited sources.
- Present each corrected conclusion with its cited sources.
- Set `status` to `approved` only after explicit approval.

## Step 1 — Create a Personal Identity

Inventory every source the user supplies before drawing conclusions. Accept local files or
directories, URLs, pasted text, existing skills, transcripts, published posts, interviews,
editorial feedback, and legacy persona files. Distinguish the author's own work from
ghostwritten, heavily corporate-edited, experimental, or rejected material. Read each
accessible source deeply enough to establish its scope and authority.

Compile evidence about register, confidence, reader relationship, argument construction,
rhetorical devices, humor, references, technical depth, recurring elements, deliberate
variation, off-voice moves, and durable bio facts. Keep explicit preferences separate from
observed patterns. Sample frequency is evidence, not a quota.

Write the package through the contract above to the user's selected directory, defaulting
to `~/.claude/blog-writer-identities/personal/<name>/`. Run the approval loop, then finish
here.

## Step 2 — Migrate a Legacy Personal Identity

Read the source directory and run the exact v0-to-v1 rewrite in the lifecycle reference.
Stop unless the directory matches that reference's legacy v0 shape. Run the approval loop
and finish here.

## Step 3 — Update a Personal Identity

Read the existing v1 package and its provenance before reading new evidence. Preserve valid
guidance and source history. Identify which conclusions the new sources confirm, weaken,
replace, or leave unresolved; never regenerate the package as if prior decisions did not
exist. Stop on a non-v1 package; Step 2 owns the only supported older shape.

Apply accepted changes through the same package contract as Step 1. Keep the existing
status only when changes do not alter consequential guidance. For consequential changes,
run the approval loop. Finish here.

## Step 4 — Audit a Personal Identity

Compare the package and its provenance against the representative sources the user names.
Report stale, unsupported, contradictory, overfit, and missing guidance with the evidence
for each finding. Pay special attention to employer language misclassified as personal
voice and observed patterns promoted into requirements.

Do not modify the identity during an audit. If the user later asks to apply accepted
findings, that follow-up request routes to Step 3. Finish here.
