# Fix Craft and Substance Problems in a Blog Draft

## Problem/Feature Description

A staff engineer submitted a blog post about migrating from Nagios to Prometheus. It has already had a light copyedit -- no AI-vocabulary tells, no structural gimmicks, no emoji, clean formatting -- but it still reads like a rough draft rather than finished writing.

Give it a craft and substance editing pass: sharpen the prose and make its claims concrete, while preserving the technical content. Also produce a report documenting each change you made -- the original text, what was wrong with it, and your replacement.

## Output Specification

Produce the following files:
- `revised-draft.md` -- the full draft with craft and substance issues fixed
- `revision-report.md` -- a report listing each issue found, with: the original problematic text, what the problem is, and the replacement text

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: inputs/draft-to-fix.md ===============
# How we replaced our monitoring stack

## The beginning

Of course, monitoring is something every engineering team needs to get right. Our team had been running Nagios for five years, and naturally, as the infrastructure grew, we started hitting limitations. Obviously, we needed something better.

The implementation of a new monitoring solution required careful evaluation of multiple tools, frameworks, and approaches, including Prometheus, Grafana, Datadog, New Relic, and Thanos, by our infrastructure team over the course of several months in order to determine the best path forward for our organization's observability needs.

The presence of outdated monitoring configurations in our Nagios setup, which had been maintained by three different teams over the years, each of whom had their own conventions for naming alerts, because the original documentation had been lost when we migrated wikis in 2021, meant that we couldn't simply port our existing alerts to the new system.

## Choosing Prometheus

We evaluated Prometheus, Datadog, New Relic, Thanos, and VictoriaMetrics. Prometheus won because it was the best fit.

Prometheus offers a truly powerful query language. The alerting capabilities are remarkably flexible. The community support is incredibly active. We were extremely impressed with the overall quality of the ecosystem.

Prometheus is a robust, scalable, and comprehensive monitoring solution for modern cloud-native teams. It provides an elegant and innovative approach to metrics collection that delivers a seamless observability experience.

We built a monitoring system with 25,000-metric cardinality capacity, automatic service dependency mapping, and configurable retention policies ranging from 15 days to 2 years.

## The migration

Frankly, the migration was harder than expected. We had some issues with data continuity during the cutover period. There were some inconsistencies in the metric naming that required attention. The team had to make some adjustments to the original timeline.

Additionally, our infrastructure team, which had been working on the migration since January, when we first approved the project after the quarterly planning meeting where Sasha presented the proposal that included cost projections based on our current Datadog spend, completed the Prometheus deployment in March.

Furthermore, we moved alerting rules from Nagios to Prometheus in batches. Moreover, each batch required validation against production traffic. Also, the on-call team reviewed every alert threshold. In addition to this, we documented the new runbook procedures.

The migration reduced our monitoring costs by 60%, from $8,400 per month to $3,360 per month, saving us $60,480 annually, which represents a 5x return on the three engineer-months we invested in the project.

## Results

The new monitoring stack handles our current load well. We haven't had any issues since the deployment. The team is happy with the tooling.

---

*Priya Mehta is a staff infrastructure engineer at CloudRoute, where she keeps the dashboards honest and the alerts meaningful. Previously spent six years at a financial services company where "monitoring" meant checking if the website was up by refreshing the homepage. Still has nightmares about Nagios configuration syntax.*
=============== END INPUT ===============
