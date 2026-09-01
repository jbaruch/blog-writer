# Personal Identity Interview Source

Use this flow only when the author wants an interview or lacks enough supplied material for
`create-personal-identity`. The interview is one source among many; it does not define a
special persona format. The creator must still follow the shared identity specification,
record provenance, distinguish explicit from inferred guidance, and obtain approval.

## 1. Explain the outcome

Tell the author that the result is a reusable personal writing identity compiled from their
answers and representative work. It captures their expression, not an employer's brand,
product claims, or corporate editorial policy.

## 2. Basic personal facts

Ask one question at a time: how the author should be credited; which durable role or
experience facts belong in a bio; which employer facts are temporary context; and whether
bios use a fixed close or post-specific kicker. Do not place employer or product language
in voice rules.

## 3. Representative sources

Request 2–5 representative sources, while accepting any mixture of published URLs, pasted
prose, local files or directories, talks, transcripts, interviews, meeting notes, existing
personas, and editorial feedback. Ask which sources are truly the author's voice and which
were ghostwritten, heavily corporate-edited, experimental, or known to be weak. Read every
accessible source selected for compilation.

## 4. Analyze

Look for register, confidence, relationship to the reader, argument construction,
rhetorical devices, references, humor, technical depth, recurring motifs, and off-voice
moves. Preserve natural variation instead of turning sample frequency into quotas.

Classify conclusions as Required, Preferred, Observed, Avoid, or Unresolved. A pattern in
examples is Observed unless the author or an authoritative personal profile makes it
explicit.

## 5. Return the interview source

Return the answers, source classifications, and analysis to the calling
`Skill(skill: "create-personal-identity")`. The creator compiles the package, presents its
summary and consequential guidance, and owns the approval transition.

## 6. Select for the blog

Set the approved identity path through `configure-identities.py`, preserving any existing
corporate selection. Rerun `resolve-identities.py` and continue only when it resolves the
intended personal identity. Never hand-edit the project selection record.

The legacy `~/.claude/blog-writer-persona/` remains a compatibility fallback. New setup
must create a v1 identity instead of writing new legacy persona files.
