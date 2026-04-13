# Write a Developer Blog Post That Uses a Diagram to Explain Architecture

## Problem/Feature Description

Mira Okafor is a backend engineer who writes about distributed systems. She just recorded a walkthrough of how her team built a per-tenant rate limiter in front of their public API. The talk spends a full section walking through the request flow — client to edge gateway to rate-limiter middleware to Redis counter, with branches for allow/deny and a separate path for refill — and the flow is the whole point of that section. Prose alone would turn into a nested enumeration.

Mira needs a complete blog post draft written from the transcript below. The draft should be ready for Mira to review — she'll confirm the diagram, verify the code, and supply the screenshots later.

The slug for this post is `per-tenant-rate-limiter`.

## Output Specification

Produce the following files in the working directory:
- `blog-research-per-tenant-rate-limiter.md` -- a structured research/notes file capturing key information from the transcript
- `blog-draft-per-tenant-rate-limiter.md` -- the complete blog post draft
- `draft-summary.md` -- a brief summary of the draft: word count, counts of each placeholder type (including Diagram), and any open questions

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: ~/.claude/blog-writer-persona/voice.md ===============
# Voice Profile: Mira Okafor

## The Voice in One Paragraph

You're a backend engineer who thinks in boxes and arrows. You tell system stories as if you're drawing them on a whiteboard — structure first, then the gotcha that made the structure necessary. You're direct about tradeoffs. You cite real numbers. You treat infrastructure components as characters with motives: the gateway is impatient, Redis is reliable-until-it-isn't, the rate limiter is the bouncer at the door.

## Rhetorical Devices That Work

### Concrete numbers
Specifics over vague claims.

> "120,000 requests per minute at peak. Redis was handling 4,000 of those at 0.8ms p99."

### Component anthropomorphization
Infrastructure pieces as actors with intent.

> "The gateway doesn't care whose request it is. That's Redis's job, and Redis is suspicious of everyone."

### Short paragraph punchline
One-sentence paragraph for emphasis.

> "The limit held. Nothing else did."

## Cultural Reference Style
References to architecture patterns, queueing theory, and old sysadmin wisdom. Occasional allusions to bouncers, gatekeepers, and door policies when describing rate limiting or access control.

## Recurring Characters

- **Dev** -- staff engineer, veteran of two previous rate-limiter implementations. Tends to start sentences with "last time we tried this." Always skeptical of configuration-heavy solutions.

## Voice Consistency Notes
The voice stays structural even in narrative sections. Boxes and arrows come through in prose. Tradeoff language ("we picked X because Y, knowing Z would eventually bite us") appears naturally, not as a rhetorical move.

=============== FILE: ~/.claude/blog-writer-persona/bio.md ===============
# Author Bio: Mira Okafor

## Bio Schema
Mira Okafor is a backend engineer at Gridline, where she builds infrastructure that meters, throttles, and occasionally refuses traffic on purpose. Previously spent four years at a payments company learning what happens when a distributed system runs out of budget for second chances. [Rotating kicker connecting to post content.]

## Kicker Notes
Rotating. Dry, matter-of-fact observation tied to something specific in the post. Self-deprecating preferred.

=============== FILE: ~/.claude/blog-writer-persona/examples.md ===============
# Example Posts: Mira Okafor

## "The Queue That Ate Our SLO"
Key patterns: component anthropomorphization, architectural tradeoff framing, Dev as voice of prior experience

=============== FILE: transcript.txt ===============
MIRA: So we needed per-tenant rate limiting in front of the public API. Every tenant gets their own budget, enforced at the edge, because we had one big customer who could DDoS us by accident just running their nightly batch.

DEV: Last time we tried per-tenant limits, we put the logic inside the application servers and it fell over at 40,000 RPM.

MIRA: Right. That was the lesson. The application layer is the wrong place for this. Anything the application has to check on every request becomes a shared-state problem the minute you have more than one process. So we pushed it out to the edge.

DEV: How did you structure it?

MIRA: Four pieces. The client hits our edge load balancer. The load balancer forwards every request to a rate-limiter middleware that sits in front of the API. The middleware asks Redis whether this tenant is under their limit. If yes, the request goes through to the API. If no, the middleware returns a 429 directly, and the request never touches the API servers.

DEV: What does the Redis interaction look like?

MIRA: We use a sliding window counter. For each tenant, there's a key like `ratelimit:tenant:<id>:<minute>`. The middleware does an atomic INCR on the key, sets a TTL of 120 seconds on first write, and compares the result to the tenant's configured limit. Two round trips in the worst case. We measured 0.8ms p99 on the Redis side and 1.4ms p99 on the full middleware round trip.

DEV: So there's a fifth piece, right? The configuration. How does the middleware know each tenant's limit?

MIRA: Good catch. There's a control plane service that owns tenant configuration. Every 30 seconds, the middleware pulls the current tenant-to-limit mapping from the control plane and caches it in memory. If the control plane is down, the middleware keeps using the last known config. It doesn't fail open and it doesn't fail closed — it stays at the last known state. We learned that the hard way in an earlier iteration where a config reload returned an empty map during a deploy and we rate-limited everyone to zero for four minutes.

DEV: That's a good story. Tell me about the numbers.

MIRA: At peak we're at 120,000 requests per minute across all tenants. Redis handles the counter operations at 0.8ms p99. About 3% of all requests get a 429, which sounds like a lot, but it's concentrated in about a dozen tenants who are deliberately pushing their limits. The other 99% of tenants never hit their cap.

DEV: What about the refill path?

MIRA: The refill is implicit. We don't do token buckets. The sliding window key expires after the window passes, so the "refill" is just the TTL rolling forward. No separate refill worker, no cron, nothing to go wrong in the refill path because there isn't one.

DEV: What went wrong?

MIRA: Two things. First, the initial version had the middleware fail open when Redis was unreachable. During a Redis failover, we let everything through for about 90 seconds and one tenant used that window to pump through their entire monthly budget. Now the middleware fails closed on Redis errors, with a 2-second circuit breaker before it retries.

DEV: Fail closed is the correct default for a rate limiter.

MIRA: Yeah. The other thing is the cache refresh. The 30-second refresh felt fast enough until we onboarded a tenant, set their limit, and watched requests get 429'd for the first 30 seconds because the middleware hadn't pulled the new config yet. We added a push notification from the control plane to the middleware on config change. The 30-second poll is still there as a backstop.

DEV: Show me the middleware config.

MIRA: [Mira pulls up the config file showing the middleware settings, the Redis connection, and the tenant cache TTL]

DEV: And the Grafana dashboard?

MIRA: [Mira shows the dashboard with the request rate, the 429 rate per tenant, and the middleware latency histogram]

DEV: One more thing. For the post, I'd draw this flow out. Words make it sound like a chain, but it's really a branching decision.

MIRA: Yeah, agree. The request goes in, takes one of three paths — allowed, denied, or control-plane-fallback — and the diagram makes that obvious in a way three paragraphs never would.
=============== END TRANSCRIPT ===============
