# Author-preservation behavioral checks

These are editorial task fixtures, not Tessl eval scenarios or instruction-string tests.
Run the same task against an unchanged baseline skill and the candidate in separate fresh
agent contexts. Allow reading the supplied skill and its references and running its local
scripts; keep outputs outside either source tree. Record the prompt, source revision,
output passages, scanner results, and an editorial assessment. A single run is evidence
about that case, not a general success rate.

`initial-abstract.md` reconstructs the initial assignment from issue #69's available
framing and constraints. The complete original draft/session was not supplied. It is not
an exact historical replay. Keep later corrections and preferred text out of that run.
The assignment year is fixed input and is never compared with the execution date.

Later cases are separate tasks: `local-correction`, `copyedit`, `neutral`, `mechanical`,
`factual`, `review-only`, and `corporate`. The copyedit fixture reconstructs an excerpt
from supplied collaborative material; it is not a claim of sole authorship or a verbatim
full abstract. Do not expose these fixtures to an initial-abstract run. Evaluate semantic
preservation and edit scope, not conformity to a preferred final answer.

`full-blog.md` separately exercises the main workflow with an explicitly selected synthetic
corporate identity, no personal layer, and an approved plan. `corporate-fixture/` is test
input, not a real organization's identity. Preserve its source stance after the editorial
review; do not create publication history for a requested draft.

`existing-blog.md` checks a grammar-only edit of an existing Markdown blog excerpt. Its
headings and unaffected wording must survive without new-post intake or publication state.

See `results.md` for the paired outputs, editorial assessment, and trial limitations.
