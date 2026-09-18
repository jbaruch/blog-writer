# Author-preservation assessment

## Method and limits

Baseline: main at `5935dea`, version 1.1.45. Candidate: this change, based on that commit.
Both received the versioned prompts in `cases/` and their respective skill resources.
Initial-abstract trials used separate fresh agent contexts with no later preferred copy,
issue discussion, or expected answer. Later editing cases used another agent per variant;
those agents handled seven distinct assignments. Full-blog trials used fresh contexts.
Outputs stayed outside the source trees. The evaluator read the actual answers and review
records; the judgments below are editorial assessments, not instruction-string assertions.

The initial prompt reconstructs the framing available in #69. The original complete
abstract and session are unavailable. The copyedit source is a reconstructed collaborative
excerpt, not an independently authored sample. This is one paired trial per case, without
an independent blinded scoring panel or statistical success-rate claim. Current main
already handled several cases well; the historical 1.1.42 failure is not reproduced in
every 1.1.45 trial.

One isolation error affected the candidate editing agent: its first scanner loop also
scanned the neighboring initial trial's **prompt**, exposing truncated excerpts. It did
not read the initial answer or later change the initial trial. The editing decisions had
already been planned. Treat those seven candidate trials as having this limitation, not
as perfectly isolated. The original initial agent's `commands.md`, `sweep-draft.json`,
`sweep-final.json`, and `review.md` remain intact; do not use the extra `commands.json` or
`draft-scanner.json` created by the accidental prompt scan as initial-trial evidence.

Raw local records: `/tmp/blog-writer-69-baseline/<case>/` and
`/tmp/blog-writer-69-candidate/<case>/`. Baseline answers are `final-answer.md`; candidate
editing answers are `answer.md`, and its initial answer is `final-answer.md`. These paths
are transient. The concrete output excerpts and assessments below preserve the important
evidence in the repository. No trial published, installed a plugin, or changed source files.

## Initial assignment

Both outputs preserve third person, the rejection of vibecoding spectacle, changeable
projects, day-two engineering, the moving bottleneck, enterprise context, and a useful
human decision. Both describe the audience watching the speakers inspect decisions and
question fixes. Neither adds a named product, fixed project inventory, or biography.

Baseline opening:

> By 2027, vibecoding another app on stage is an engineering anti-pattern with an audience.
> The interesting trouble starts on day two.

Baseline progression:

> Add more agents and someone has to coordinate them. Goldratt would recognize the
> situation: each improvement moves the bottleneck elsewhere.

Baseline enterprise objection:

> A person asked to approve a change needs enough information to judge it; an approval
> button alone supplies a ceremony.

Candidate opening and format:

> Baruch and Viktor could spend this session vibecoding a new app. In 2027, that would be
> an unimpressive demo of an engineering anti-pattern. Instead, they'll open projects,
> work through different scenarios, and question one another's fixes. The audience will
> follow the decisions behind those fixes and see what remains broken when the code runs.

Candidate progression:

> Architectural decisions disappear when an agent's conversation ends; saving them leaves
> the problem of sharing coding rules between projects. Adding agents brings coordination
> work of its own. Goldratt would recognize the plot: each improvement moves the bottleneck
> elsewhere.

Candidate enterprise objection:

> That human needs enough information to judge the proposal; a ceremonial approval won't
> do the engineering.

Baseline had no draft-mode hits. Candidate retained two #14 hits, with verified sentence
counts `[11, 12, 13]` and `[20, 16, 20]`, through draft and final checks. Its record maps
the first sequence to proposed demo → objection → actual format, and the second to
enterprise decision → information requirement → attendee experience. The counts remain
findings, not a clean sweep. This demonstrates an explicit disposition without padding;
it does not prove the candidate abstract is better literature than the baseline.

Baseline resolved a legacy personal profile, created a research bank and blog-named draft,
and checked blog shape history. Candidate used scoped notes and a temporary draft, with
no identity creation or blog bookkeeping. Baseline formal calibration was unresolved;
candidate calibration was not applicable without a selected personal identity. Neither
claimed that the assignment framing established full personal calibration. Baseline's
catalog version check succeeded, but its full upstream article comparison was incomplete.

## Editing cases

| Case | Baseline output | Candidate output | Assessment |
| --- | --- | --- | --- |
| Local correction | Moves the example after the session explanation; preserves every sentence | Same passage, plus source-to-revision explanation | Both satisfy the requested local move. Candidate identifies the restored relationship explicitly. |
| Copyedit | Fixes agreement and splits the enterprise sentence; retains rhetoric and three rhythm hits | Same substantive repair, with preservation evidence and three retained contextual hits | Both preserve self-implication, frustration, Goldratt, and closing. Candidate makes the disposition part of the workflow. |
| Neutral | Combines the opening two sentences to clear #14 | Keeps the original note verbatim and explains why #14 does not establish a defect | Both stay neutral and accurate. Candidate avoids an unnecessary arithmetic rewrite. |
| Mechanical | Connects the fragmented incident sequence; final sweep clean | Connects the first four sentences; preserves the final source sentence; final sweep clean | Both repair disconnected prose without filler or semantic loss. |
| Factual | Corrects exactly-once to at-least-once and assigns deduplication to consumers | Same factual correction while retaining blunt phrasing | Both use the supplied specification rather than preserving a false guarantee as voice. |
| Review-only | Reports agreement error, citation residue, and missing fact; source unchanged | Same findings; labels unresolved finalization blockers; source unchanged | Both honor review-only scope and invent no client count. |
| Corporate | Converts the question to a statement and preserves the engineering argument | Same scoped correction, rejecting the unapproved generic replacement explicitly | Both retain stance; candidate documents comparison after the editorial requirement. |

The local-correction output is identical in both variants:

> Instead, they're bringing stories from projects that survived their first demo and had
> to face day two. They'll open the projects and question each other's fixes as they work
> out how to keep testing, changing, and releasing the software after the vibe wears off.
> An architectural decision disappears with the agent's conversation. Saving it helps,
> until the next project needs the same coding rules and adding another agent gives them
> somebody else to coordinate. Each improvement moves the bottleneck somewhere else.
> Goldratt would recognize the factory.

Copyedit enterprise paragraph, baseline:

> In enterprise software, the decisions, documentation and permissions are scattered
> across ten different services, all hostile to AI with prejudice. Compliance requires a
> human in the loop, but that human needs to be more than a rubber-stamping meat-proxy.
> They need useful insights about the proposed change and its consequences before
> approving it.

Candidate:

> In enterprise software, the decisions, documentation and permissions are scattered
> across ten different services, all hostile to AI with prejudice. The compliance-required
> human-in-the-loop needs to be more than a rubber-stamping meat-proxy. They need useful
> insights about the proposed change and its consequences before approving it.

Both retain the supplied “shtick”/autocomplete opening, moving-bottleneck/Goldratt sequence,
and “Did AI solve coding? Maybe.” closing. Baseline retains the rhythm hits under explicit
user instructions despite its zero-hit skill gate. Candidate retains them under the shared
contextual procedure, with no claim that collaborative copy proves sole authorship.

Neutral opening, baseline:

> For each completed request, the exporter writes one JSON object containing a timestamp,
> a status code, and the request ID.

Candidate retains:

> The exporter writes one JSON object for each completed request. Each object contains a
> timestamp, a status code, and the request ID.

Both keep the log-correlation instruction and request-body exclusion. Candidate retains
one reported #14 match for a connected explanation, without inventing personality.

Mechanical repair, baseline:

> When the worker failed, the queue grew, but nobody noticed because metrics were disabled.
> Restarting the worker did not fix the missing metrics, so the team enabled them before
> replaying the queued jobs.

Candidate:

> The worker failed and the queue grew, but nobody noticed because metrics were disabled.
> Restarting the worker did not fix the missing metrics, so the team enabled them before
> replaying the queued jobs.

Factual repair, baseline:

> Our queue guarantees at-least-once delivery, so consumers must deduplicate using the
> message ID; duplicate work is their problem.

Candidate:

> Our queue delivers at least once, so duplicate work is our problem: consumers must
> deduplicate using the message ID.

The candidate's “our” preserves the source's blunt collective stance; the explicit
consumer responsibility supplies the technical meaning. Neither output claims exactly-once.

Corporate correction, baseline:

> That demonstration now dodges the harder issue of who keeps the software running after
> the audience leaves.

Candidate:

> That demonstration now dodges the harder question of who keeps the software running
> after the audience leaves.

Both preserve the surrounding sentences, including “used to build apps live on stage” and
“Each improvement moves the bottleneck somewhere else. Goldratt would recognize this
factory.” Both retain the remaining #14 hit. The candidate explicitly rejects the proposed
unapproved corporate edit for losing maintenance responsibility and the bottleneck argument.

## Full blog and existing-blog routes

The full-blog prompt explicitly selected a synthetic approved corporate identity, disabled
personal identity, and supplied an approved plan. Both variants used the full workflow,
kept three connected body paragraphs plus the CTA, and created no published shape record.
Both retained the supplied “we,” moving bottleneck, Goldratt reference, useful human
decision, and absence of evidence that agents eliminated coordination work.

Baseline's initial opening:

> The prototype worked in the demo. We used to think the demo was the hard part. Then we
> had to live with the software.

After a #14 finding with counts `[6, 10, 8]`, baseline changed it to:

> The prototype worked in the demo, which we used to think was the hard part. Then we had
> to live with the software.

It also removed a redundant sentence. Its final 205-word body had no draft/final hits.
This was a reasonable edit that retained self-implication, not a demonstrated voice loss.

Candidate retained the five supplied sentences verbatim, including:

> We used to think the demo was the hard part. Then we had to live with the software.

and:

> Adding agents creates another coordination problem. Each improvement moves the
> bottleneck somewhere else. Goldratt would recognize this factory.

Its final 214-word body keeps the demo → retained decisions → coordination → informed approval
progression. Draft and final scans retain two contextual #14 findings: `[6, 7, 5]` in the
coordination/bottleneck/Goldratt sequence and `[12, 16, 12]` in the approval explanation.
It removed only the assistant-added redundancy “A successful demo leaves that work ahead
of us.” and then repeated the scan and preservation comparison. All five protected
sentences remained exact. No required hits or assistant-chatter candidates remain.
Corporate review required no rhetorical questions, preserved claims and
qualifications, and added no positioning or personal identity. The separate corporate
editing case above supplies the stronger regression check where an actual rewrite was
needed. The full-blog pair demonstrates continued routing and preservation under a
selected identity, not that every corporate pass changes prose.
Both full-blog agents recorded limited upstream catalog comparisons rather than claiming
an exhaustive review of every Wikipedia example; neither changed the installed catalog.

An additional fresh candidate trial used `existing-blog.md`. Its entire edit was:

> The deploy logs **shows** which migration failed.

to:

> The deploy logs **show** which migration failed.

Headings, line wrapping, and every other word stayed unchanged. Both scans returned zero
hits; no identity selection, new-post intake, or publication state was created. This
supplementary scope check has no paired baseline and is not counted as a comparison win.

## Deterministic coverage

Scanner fixtures verify that the Goldratt cadence remains a #14 hit, the endorsed closing
remains #14 plus #3/#4, and mixed stylistic/finalization output distinguishes contextual
review from required corrections. Neither thresholds nor exit codes changed. Existing
coverage continues to exercise placeholder modes, residue, segmentation, errors, and
coverage reporting. These assertions establish scanner behavior, not editorial quality.

Local validation passed: all eight script suites (including 106 scanner checks), Python
format/lint/type diagnostics, shell lint, skill frontmatter validation, and plugin lint.
The packed plugin includes both shared references and excludes this validation tree.
Tessl quality review returned the organization's out-of-credits error, not a score. The
existing publish workflow opts into the credit-outage exception; this is an unreviewed
quality result and must not be presented as a passing Tessl review.
