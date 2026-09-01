---
name: create-corporate-identity
description: Create, update, or audit a reusable corporate writing identity from brand and style guides, tone-of-voice guidance, corporate skills, published content, product messaging, examples, or editorial feedback. Use whenever someone wants to define, capture, refresh, migrate, or check a company voice, house style, corporate tone, audience, terminology, evidence, positioning, or editorial constraints without prescribing an individual author's personality.
---

# Create Corporate Identity

This skill is an action router — pick the step that matches the user's intent and execute only that step. Do not run other steps; do not parallelize.

Corporate identity owns audience, brand values, terminology, evidence standards, approved
claims, positioning, and editorial constraints. It does not prescribe an individual
author's personality. Before any action, read
`skills/blog-writer/references/identity-spec.md` completely and follow its package,
provenance, strength, ownership, approval, and storage contracts.

Every package has an `identity.json` manifest, concise shared guidance and routing in
`identity.md`, and source authority, dates, contradictions, and consequential inferences in
`sources.md`; optional Markdown resources are declared by role in the manifest.

Use one approval loop for every consequential create or update: set `status` to `draft`,
show the one-paragraph summary, Required and Avoid guidance, high-impact inferences, and
unresolved items, then ask one focused question at a time. If the user rejects or corrects
anything, revise the package, trace each changed conclusion to its cited sources, and present
it again. Set `status` to `approved` only after explicit approval.

## Step 1 — Create a Corporate Identity

Inventory every source the user supplies before drawing conclusions. Accept local files or
directories, URLs, pasted text, skills, style guides, example content, product
documentation, messaging frameworks, and editorial feedback. Establish each source's
scope, authority, and relevant date or version. A current formal guide normally outweighs
an older example, but conflicting authoritative policies remain unresolved until the user
decides.

Compile evidence about intended audiences, reader relationship, values, trust signals,
tone boundaries, terminology, product positioning, sources of truth, evidence standards,
format-specific conventions, editorial checks, and stated legal or reputational
constraints. Keep explicit policy separate from patterns observed in examples. Compile the
identity and review guidance from source skills without copying their workflow.

Write the package to the user's selected directory, defaulting to
`~/.claude/blog-writer-identities/corporate/<name>/`. Put concise shared guidance and
routing in `identity.md`; add roles such as `brand`, `terminology`, `editorial-review`, and
`product-context` only when the evidence supports them. Record every source and
consequential inference in `sources.md`. Run the approval loop, then finish here.

## Step 2 — Update a Corporate Identity

Read the existing package and its provenance before reading new evidence. Preserve valid
guidance and source history. Identify which conclusions the new sources confirm, weaken,
replace, or leave unresolved; never regenerate the package as if prior decisions did not
exist.

Apply accepted changes through the same package contract as Step 1. Keep the existing
status only when changes do not alter consequential guidance. For consequential changes,
run the approval loop and finish here.

## Step 3 — Audit a Corporate Identity

Compare the package and its provenance against the current authoritative sources and recent
representative content the user names. Report stale, unsupported, contradictory, overfit,
and missing guidance with the evidence for each finding. Pay special attention to old
examples outweighing current policy and unsupported claims presented as approved language.

Do not modify the identity during an audit. If the user later asks to apply accepted
findings, that follow-up request routes to Step 2. Finish here.
