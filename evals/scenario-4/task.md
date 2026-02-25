# Prepare a New Contributor's Draft for Publication

## Problem/Feature Description

A new contributor (Mateo Silva) submitted his first blog post draft. The technical content and narrative are solid -- it's about building a rate limiter that accidentally took down their own health check endpoint. Mateo hasn't written for this blog before and isn't familiar with the formatting conventions for summaries, visual asset references, and overall structure.

Before publication, the draft needs a formatting review to bring it in line with how the blog handles things. Preserve the actual content -- this is a formatting and tightening pass, not a rewrite. Document what you changed so Mateo can learn the conventions for his next post.

## Output Specification

Produce the following files:
- `fixed-draft.md` -- the corrected draft, ready for publication
- `changes-log.md` -- a log explaining each formatting change: what was wrong, what it was changed to, and why

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: inputs/draft-to-fix.md ===============
# The Rate Limiter That Rate Limited Us

## TLDR

We built a rate limiter for our public API to stop abuse from scrapers, but we made the mistake of applying it globally without excluding internal services. Our health check endpoint started getting rate limited during traffic spikes, which caused the load balancer to think our servers were down, which triggered a rolling restart across the fleet. The rate limiter designed to protect us from external abuse essentially became a self-inflicted denial of service. We fixed it by adding an allowlist for internal service IPs and moving the health check to a separate port that bypasses the middleware stack. Yuki, our on-call engineer, described the incident as "the system attacking itself like an autoimmune disease" which is basically the most accurate metaphor anyone has ever used for this class of bug.

## The Setup

Last month, our API started getting hammered by scrapers. Hundreds of requests per second from a rotating pool of IPs, all hitting our product catalog endpoint. Response times for legitimate users crept from 50ms to 800ms during peak scraping hours.

I told the team we needed a rate limiter. In order to protect our users, we'd throttle requests per IP to 100 per minute. Standard stuff.

[Placeholder 1: Terminal showing the scraper traffic pattern in our access logs]

Yuki -- our on-call engineer who has essentially survived every major incident in the last two years -- asked if we'd thought about which endpoints to exclude. I said "no, we'll apply it globally, it's simpler that way."

Famous last words.

## The Implementation

We dropped in a Redis-backed sliding window rate limiter as Express middleware. Basically, every request increments a counter in Redis keyed by IP, and if you exceed 100 requests per minute, you get a 429 Too Many Requests response.

[Placeholder 2: The rate limiter middleware code]

```javascript
// Rate limiter configuration
const limiter = rateLimit({
  store: new RedisStore({ client: redisClient }),
  windowMs: 60 * 1000,
  max: 100,
  message: { error: "Rate limit exceeded" }
});

app.use(limiter); // Applied to ALL routes
```

[Placeholder 3: Redis dashboard showing the rate limit counter keys]

The scraper traffic dropped immediately. Response times went back to normal. Victory.

For about four hours.

## The Incident

At 3:47 PM, our monitoring fired. Half our fleet was showing as unhealthy. The load balancer was pulling servers out of rotation.

[Placeholder 4: PagerDuty alert showing the fleet health dropping]

[Placeholder 5: Grafana dashboard showing the cascading server restarts]

I pulled up the health check logs and found... nothing. No logs. The health check endpoint was returning 429. Our load balancer hits the health check endpoint from the same internal IP range, and during the traffic spike, the combined load of health checks plus legitimate traffic was exceeding the rate limit for those IPs.

[Placeholder 6: The load balancer config showing the health check endpoint]

Yuki was already on it. She'd basically figured out the problem before I finished reading the alerts. "The rate limiter is rate limiting the health checks. The load balancer thinks we're dead. It's restarting us in order to fix a problem that only exists because it's restarting us."

## The Fix

Two changes:

First, we added an allowlist for internal CIDR ranges. Health checks, service-to-service calls, and monitoring probes now bypass the rate limiter entirely.

[Placeholder 7: The updated middleware with the allowlist]

```javascript
// Fixed: internal services bypass rate limiting
const isInternal = (ip) => internalCIDRs.some(cidr => cidr.contains(ip));

app.use((req, res, next) => {
  if (isInternal(req.ip)) return next();
  return limiter(req, res, next);
});
```

Second, we moved the health check to a dedicated port that doesn't go through the middleware stack at all. In order to ensure the health check is always reachable, it runs on port 8081 with essentially zero middleware.

[Placeholder 8: The separate health check server configuration]

[Placeholder 9: Updated Grafana dashboard showing stable fleet health after the fix]

## The Broader Point

Rate limiters are essentially a form of access control, and access control that doesn't distinguish between friends and enemies is just a wall. We were so focused on stopping the scrapers that we forgot our own infrastructure is also a client of our API.

[Placeholder 10: Link to the OWASP rate limiting best practices]

Yuki suggested we basically add the allowlist pattern to our service template so new services get it by default. We did. It took twenty minutes. The incident took four hours.

## Try It

If you're adding rate limiting to an existing service, check your internal callers first. Grep your load balancer config for health check endpoints and make sure they're excluded before you deploy.

[Placeholder 11: Link to our internal rate limiter template on GitHub]

---

*Mateo Silva is a backend engineer at CartStack, where he builds systems that occasionally protect themselves from their own infrastructure. Previously spent four years at a payments company where "rate limiting" meant the database was too slow to process requests at any rate. He now has strong opinions about allowlists and a healthy distrust of global middleware.*
=============== END INPUT ===============
