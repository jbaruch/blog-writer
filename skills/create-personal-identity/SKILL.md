---
name: create-personal-identity
description: Create, update, or audit a reusable personal writing identity from writing samples, transcripts, interviews, existing persona files, editorial feedback, or other user-supplied sources. Use whenever someone wants to capture, refresh, migrate, or check an individual author's voice and writing preferences without absorbing employer brand rules.
---

# Create Personal Identity

This skill is an action router — pick the step that matches the user's intent and execute only that step. Do not run other steps; do not parallelize.

Personal identity owns how an author sounds and reasons. It does not own employer
positioning, product claims, or corporate editorial policy. Before any action, read
`skills/blog-writer/references/identity-spec.md` completely and follow its package,
provenance, strength, ownership, approval, and storage contracts.

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

Write the package to the user's selected directory, defaulting to
`~/.claude/blog-writer-identities/personal/<name>/`. Put concise guidance and routing in
`identity.md`; add roles such as `voice`, `composition`, `examples`, and `bio` only when the
evidence supports them. Record every source and consequential inference in `sources.md`.
Set `status` to `draft` first.

Show the user the one-paragraph identity summary, Required and Avoid guidance, high-impact
inferences, and unresolved items. Ask one focused question at a time for consequential
conflicts. Set `status` to `approved` only after explicit approval. Finish here.

## Step 2 — Update a Personal Identity

Read the existing package and its provenance before reading new evidence. Preserve valid
guidance and source history. Identify which conclusions the new sources confirm, weaken,
replace, or leave unresolved; never regenerate the package as if prior decisions did not
exist.

Apply accepted changes through the same package contract as Step 1. Keep the existing
status only when changes do not alter consequential guidance. For consequential changes,
set `status` to `draft`, show the changed summary, Required and Avoid guidance, high-impact
inferences, and unresolved items, then restore `approved` only after explicit approval.
Finish here.

## Step 3 — Audit a Personal Identity

Compare the package and its provenance against the representative sources the user names.
Report stale, unsupported, contradictory, overfit, and missing guidance with the evidence
for each finding. Pay special attention to employer language misclassified as personal
voice and observed patterns promoted into requirements.

Do not modify the identity during an audit. If the user later asks to apply accepted
findings, that follow-up request routes to Step 2. Finish here.
