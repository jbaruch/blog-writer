# Tighten a Developer Blog Draft

## Problem/Feature Description

A developer advocate wrote a draft about migrating a monolith to microservices. The technical content and structure are solid, and there are no obvious AI vocabulary issues or formatting problems. But the draft reads like the author doesn't trust the reader — it over-explains, labels its own rhetoric, summarizes things the narrative already showed, and announces transitions instead of making them. It also piles redundant statistics and buries key sentences inside paragraphs.

Review the draft and produce a tightened version that respects the reader's intelligence. Also produce a report documenting each issue and the fix.

## Output Specification

Produce the following files:
- `tightened-draft.md` -- the full draft with all issues fixed
- `tighten-report.md` -- a report listing each issue found, with the original text, what the problem is, and the replacement text

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: inputs/draft-to-tighten.md ===============
# Breaking up the monolith: how we split one service into twelve

We ran a single Rails monolith for four years. It handled user auth, billing, notifications, PDF generation, and three internal CRUD apps. By year three it took 22 minutes to run the test suite and deploys happened twice a week because everyone was afraid of breaking something.

## Why we finally did it

The irony? The monolith was supposed to keep things simple. The beauty of it is that we'd built a system so "simple" that nobody could change it without a two-day code review.

Our deploy frequency had dropped to twice a week. Our mean time to recovery was four hours. Our test suite took 22 minutes to run. Our average PR review time had climbed to 1.8 days. The combined effect of these metrics was that our velocity had essentially halved year over year, a decline of roughly 48% when measured against story points completed per sprint.

Here's the thing: we didn't decide to break up the monolith because of some grand architectural vision. And here's the most interesting part: the trigger was a billing bug that took three days to fix because the billing code was tangled with the notification system.

## How we split it

We started with the billing service because it had the clearest domain boundary. We drew the API contract on a whiteboard, built the new service in Go, and ran both versions in parallel for two weeks.

The paradox here is that breaking things apart actually made them simpler. What we discovered — and this is the key insight — is that each service could now be deployed independently, tested in isolation, and owned by a single team.

We proved that the extraction works. We proved that parallel running catches edge cases. We proved that Go handles the billing domain well. The main lesson: start with the service that has the clearest boundary, not the one that causes the most pain.

Now, here's where it gets interesting. After billing, we extracted notifications. The important thing to understand is that notifications had tentacles into almost every other module. This is where things get tricky: we had to build an event bus before we could cleanly separate the notification logic.

The event bus took three weeks to build. It processes roughly 50,000 events per day, with a p99 latency of 12ms. The notification service now handles email, SMS, push, and in-app notifications. After the extraction, notification-related bugs dropped by 70%, from an average of 3.2 per week to 0.9 per week, saving the on-call engineer approximately 4 hours per week in incident response time.

## The results

The implications for our engineering org are significant. The direction is clear.

After twelve months, we went from one monolith to twelve services. Deploy frequency went from twice a week to multiple times a day. Our test suite — once 22 minutes — now runs in under 3 minutes per service. Mean time to recovery dropped from four hours to twenty minutes. The combined operational improvements represent a fundamental shift in our engineering capabilities.

In other words, the migration was worth it. The key takeaway: if your monolith is slowing you down, start with the service that has the clearest domain boundary and go from there.

The most important lesson from this entire migration is that you don't need to plan the whole thing upfront. Start small, prove the pattern, and expand.

---

*Sam Torres is a principal engineer at InvoiceCloud, where they've recently discovered that twelve services means twelve things that can break independently. Previously architected a "microservices-first" startup that had more services than customers. Firmly believes that the right number of services is always "one more than you have."*
=============== END INPUT ===============
