# Create an Editorial Plan for a Blog Post

## Problem/Feature Description

Elena Vasquez is a site reliability engineer who writes a blog about operational lessons and infrastructure war stories. She has rough notes from an on-call incident where her team discovered that their logging pipeline was silently dropping 30% of logs during peak traffic, masking a cascading failure in their payment service. The incident is resolved and she wants to turn it into a blog post.

Elena needs the source material analyzed and an editorial plan created -- not the draft itself, just the plan. This is part 3 of her "Ops War Stories" series. The slug for this post is `ops-war-stories-ep3`.

Analyze the source material, create a structured research bank, identify gaps where you'd need more information, and produce an editorial plan with a focused main idea, call to action, and section outline. Do NOT write the actual blog post -- just the plan and the questions you'd ask before drafting.

## Output Specification

Produce the following files:
- `blog-research-ops-war-stories-ep3.md` -- structured research notes from the source material
- `editorial-plan.md` -- the editorial plan for the blog post
- `clarification-questions.md` -- questions you'd need answered before writing the draft

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: persona/voice.md ===============
# Voice Profile: Elena Vasquez

## The Voice in One Paragraph

You're an SRE who has been on enough 2 AM pages to know that the incident report never captures the real story. You write with dark humor about operational failures because laughing about them is healthier than crying. You name your incidents like hurricanes -- it helps the team remember them and it makes the postmortems more readable. You believe that every system is one bad deploy away from a very interesting night.

## Rhetorical Devices That Work

### The incident name
Giving colorful names to incidents that the team actually uses.

> "We call it 'The Great Log Famine of March' internally. It's easier than saying 'that time we lost thirty percent of our logs and didn't notice for nine hours.'"

### The 2 AM detail
Including the specific unglamorous details of on-call work.

> "I was debugging in my kitchen at 2:14 AM, wearing one sock because I'd gotten the page mid-getting-dressed, with a cat on my keyboard contributing error messages of her own."

### The comparison to a worse thing
Making a point by comparing the current failure to something more dramatic.

> "Our log pipeline had the reliability of a WiFi connection at a stadium concert."

## Cultural Reference Style
References to ops culture, on-call life, and the eternal gap between architecture diagrams and 3 AM reality. Occasional references to disaster movies and survival shows.

## Recurring Characters

- **Mika** -- junior SRE on the team, asks questions that sound naive but turn out to be exactly right. The one who noticed the log gap during an unrelated investigation.
- **The on-call phone** -- treated as a character, usually delivering bad news at inconvenient times.

## Voice Consistency Notes
Elena's dark humor continues into technical sections. Diagrams and architecture are presented as "what we thought was happening" vs "what was actually happening." Config files are described with personality.

=============== FILE: persona/bio.md ===============
# Author Bio: Elena Vasquez

## Bio Schema
Elena Vasquez is a site reliability engineer at PageCo, where she keeps distributed systems from paging her at 2 AM. (They page her anyway.) Previously spent five years running infrastructure for a gaming company where "five nines" was aspirational and "three nines" was optimistic. [Rotating kicker.]

## Kicker Notes
Rotating. Should reference something specific from the post. Dark humor preferred.

=============== FILE: series-tracker.md ===============
# Series Tracker

## Ops War Stories
- Episode 1: "The Kafka Incident" -- published
  - Callbacks: "the Kafka incident" as shorthand for cascading failures
  - Elena's naming convention established: giving incidents colorful names
  - Running joke: debugging at 2 AM as a recurring life event
  - Mika's first appearance: asked "wait, are we sure Kafka is even running?"
- Episode 2: "The Config That Wasn't" -- published
  - Callbacks: referenced the Kafka incident
  - New running element: Elena's cat appearing during late-night debugging
  - Teaser at end: "Next time: the one where the logs disappeared and we didn't notice for nine hours."
- Episode 3: IN PROGRESS
  - Should callback to: the Kafka incident, Elena's naming convention, the 2 AM debugging lifestyle
  - Should address the teaser about disappearing logs

=============== FILE: inputs/incident-notes.txt ===============
INCIDENT NOTES: The Great Log Famine
Resolved: last Thursday
Severity: Sev-2 (upgraded from Sev-3 during investigation)

TIMELINE:
- Three weeks ago: logs started dropping during peak traffic (5-7 PM UTC)
- Nobody noticed because the logging pipeline doesn't have its own monitoring (ironic)
- Last Monday: Mika was investigating a latency spike in the payment service
- Mika noticed log gaps -- searched for payment service logs from 5:30 PM and found nothing
- Mika asked: "Should there be logs here?" (yes, there should be thousands)
- Investigation revealed: Fluentd was dropping ~30% of logs during peak hours
- Root cause: Fluentd buffer was sized for our traffic from 18 months ago, before the payment service was added
- The buffer fills up during peak, Fluentd silently drops overflow records
- This had been happening for at least three weeks, possibly longer

THE PAYMENT SERVICE PROBLEM:
- The payment service had been throwing intermittent 503 errors for two weeks
- We couldn't find the errors in our logs because those were exactly the logs being dropped
- The dropped logs were disproportionately from high-traffic services (payment, search)
- Low-traffic services (admin panel, internal tools) logged fine -- their volume fit in the buffer
- So our log search made it look like the payment service was healthy when it wasn't
- Customers were reporting failed payments but our dashboards showed no errors

THE FIX:
- Immediate: tripled the Fluentd buffer size (stopgap)
- Short-term: added monitoring for Fluentd's own drop rate (should have had this from day one)
- Medium-term: moving to a backpressure-based system so Fluentd slows down the source instead of dropping
- Also: Mika wrote a script to estimate how many logs we'd lost, based on expected vs actual log volume per service

NOTABLE QUOTES FROM THE INCIDENT:
- Elena: "We were monitoring everything except the monitoring."
- Mika: "Is it normal for there to be no logs? Because this seems like a thing."
- Elena to her manager: "The good news is we found the payment bug. The bad news is we found it by discovering a different, worse bug."
- Team joke during postmortem: "The logs were there the whole time. They just chose not to be recorded."

UNRESOLVED QUESTIONS:
- How long had this actually been happening? Mika's script estimates 3-5 weeks but we're not sure
- Were there other incidents masked by the log gap that we haven't found yet?
- Should we implement log sampling instead of dropping during overflow?

PEOPLE INVOLVED:
- Elena (led the investigation after Mika flagged it)
- Mika (discovered the gap)
- Carlos (platform team, helped with the Fluentd config)
- Payment team (provided context on the 503 errors)
=============== END INPUT ===============
