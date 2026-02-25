# Clean Up a Blog Draft for Publication

## Problem/Feature Description

A developer blog editor received a draft from a writer who used AI assistance heavily during the writing process. The draft covers a real technical topic -- migrating to trunk-based development -- and the narrative arc is solid, but the prose has quality issues throughout that make it read like AI-generated text rather than authentic developer writing.

Review the draft below for writing quality problems. Produce a cleaned-up version that preserves the technical content and narrative structure but fixes the prose quality issues. Also produce a detailed report documenting every issue you found, with the original text and your replacement.

## Output Specification

Produce the following files:
- `cleaned-draft.md` -- the full draft with all prose quality issues fixed
- `edit-report.md` -- a report listing each issue found, with: the original problematic text, what the problem is, and the replacement text

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: inputs/draft-to-clean.md ===============
# How Our Team Adopted Trunk-Based Development

In this post, we\u2019ll explore how our team navigated the transition to trunk-based development. What follows is a deep dive into the lessons we learned, the tools we leveraged, and the streamlined workflow we built along the way.

## The Problem

Not a branching strategy. A survival mechanism.

Our team of eight engineers had been running GitFlow for three years. Release branches, hotfix branches, feature branches that lived for weeks. Merge conflicts were a daily ritual. It\u2019s worth noting that we spent more time resolving conflicts than writing code some weeks. Interestingly enough, nobody questioned the process until our deploy frequency dropped to once every two weeks.

The CI pipeline \u2013 which had been configured by a contractor two years ago \u2013 served as the backbone of our entire release process. It boasted a grand total of 340 test cases and stood as a testament to our commitment to quality. The integration system showcased automated linting and type checking across all branches.

To be fair, GitFlow had worked when we were four people. But at eight engineers with three active feature branches, the build infrastructure was buckling. It bears mentioning that the merge queue alone added two hours to every release.

## The Decision

Where feature branches give you isolation, trunk-based gives you speed. Where long-lived branches give you safety, short-lived ones give you momentum. One approach trusts the branch. The other trusts the team.

We decided to adopt trunk-based development with feature flags. The result? Zero rollbacks in the first month. The best part? Everyone could deploy independently. And the tests? All green, all the time.

Fast. Reliable. Tested. And shipped on a Monday.

Feature flags. Dark launches. Percentage rollouts. Pure control.

The code doesn\u2019t define the process; the process defines the code.

## The Migration

The pipeline \u2013 which we had built over three sprints \u2013 handled the transition gracefully. The config \u2013 our most critical file \u2013 was updated to support the new workflow. The tests \u2013 all 200 of them \u2013 passed on the first run. The monitoring \u2013 our Datadog setup \u2013 confirmed zero regressions.

We reviewed the pipeline configuration. We updated the branch protection rules. We enabled the feature flag service. We migrated the first three services. We monitored for regressions closely. We documented the new workflow thoroughly. We trained the team on the process.

What I find genuinely interesting about this transition is that it fundamentally transforms how you think about the development landscape. I keep coming back to the idea that trunk-based development isn\u2019t just a technical choice\u2026 it\u2019s a cultural one. The team delved into the codebase with renewed energy, navigating the complexity of the migration and fostering a more robust and seamless development experience. This pivotal shift was nothing short of transformative.

## The Results

We shipped the new pipeline on a Thursday \ud83d\ude80 and by Monday our deploy frequency had tripled \ud83d\udd25. The team was finally able to ship features daily instead of biweekly \ud83c\udf89.

Not just a workflow. A philosophy.

From solo developers just learning version control to hundred-person engineering orgs running multi-region deployments, this approach works. Whether you\u2019re running a side project or a Fortune 500 deployment pipeline, the same principles apply. The automation layer handles everything regardless of scale.

\u2022 Deploy frequency went from biweekly to daily
\u2022 Merge conflicts dropped by 90%
\u2022 Mean time to recovery fell from 4 hours to 20 minutes

The build infrastructure proved that small, frequent commits beat large, infrequent merges every time.

---

*Jordan Kim is a senior engineer at ShipFast, where they build deploy pipelines that occasionally deploy on time. Previously spent five years at a consulting firm where \u201ctrunk-based development\u201d meant everyone committed to main and hoped for the best. Once mass-deployed to production during a company all-hands and discovered that \u201cfeature complete\u201d and \u201cworking\u201d are different concepts.*
=============== END INPUT ===============
