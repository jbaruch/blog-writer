# Create an Editorial Plan for a Blog Post

## Problem/Feature Description

A developer advocate named Sam Reeves has rough meeting notes from a team retro where they discussed their experience migrating from a monolith to microservices using AI-assisted code splitting. The meeting was chaotic and wide-ranging, but there's a good blog post in there. Sam needs the source material analyzed and an editorial plan created -- not the draft itself, just the plan.

This is part 2 of Sam's "Migration Diaries" series. The slug for this post is `migration-diaries-ep2`.

Sam's persona files and series context are provided below. Analyze the source material, create a structured research bank, identify gaps in the material, and produce an editorial plan with a focused main idea, CTA, and section outline. Do NOT write the actual blog post -- just the plan.

## Output Specification

Produce the following files:
- `blog-research-migration-diaries-ep2.md` -- structured research notes from the source material
- `editorial-plan.md` -- the editorial plan containing: main idea statement, proposed CTA, section outline with descriptions, and proposed placeholder locations
- `clarification-questions.md` -- questions you'd need answered before writing the draft, organized by category

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: persona/voice.md ===============
# Voice Profile: Sam Reeves

## The Voice in One Paragraph
You're a developer advocate who spent years as a platform engineer before switching to the dark side of developer relations. You write like you're explaining something to a smart friend over coffee -- technical depth without condescension. You find humor in the gap between how things should work and how they actually work. You're honest about failures because you've seen too many "we migrated perfectly" blog posts that you know are lies.

## Rhetorical Devices That Work

### The honest admission
Starting a section by admitting something most people wouldn't.
> "We had no idea what we were doing. We had a Miro board and strong opinions."

### The callback
Referencing earlier parts of the post or previous posts for continuity.
> "Remember the 'simple refactor' from Episode 1? Yeah, me neither."

### Real numbers
Using specific numbers instead of vague claims.
> "14 services. 3 teams. 1 shared database that nobody wanted to own."

## Recurring Characters
- **Dana** -- tech lead, makes pragmatic decisions that annoy Sam but are usually right
- **The Miro Board** -- treated as a character; the team's planning artifact that keeps growing

## Voice Consistency Notes
Sam's voice stays conversational even in architectural discussions. Diagrams and code are introduced with context about why the reader is seeing them, never just dropped in.

=============== FILE: persona/bio.md ===============
# Author Bio: Sam Reeves

## Bio Schema
Sam Reeves is a developer advocate at SplitStack, where he helps teams migrate monoliths without losing their minds. Previously spent six years as a platform engineer, mostly apologizing for breaking the build. [Rotating kicker.]

## Kicker Notes
Rotating. Dry humor. Should reference something specific from the post.

=============== FILE: series-tracker.md ===============
# Series Tracker

## Migration Diaries
- Episode 1: "The Miro Board of Doom" -- published
  - Established: Dana as pragmatic foil, the Miro board as running character
  - Callbacks: "the simple refactor" (ironic reference to a 3-month project)
  - Running joke: the team's shared database that nobody wants to own
  - Teaser at end: "Next time: we actually start splitting services. The database problem gets worse before it gets better."
- Episode 2: IN PROGRESS
  - Should callback to: "the simple refactor", the shared database, the Miro board
  - Should address the teaser about database splitting getting worse

=============== FILE: inputs/meeting-notes.txt ===============
RETRO NOTES: Microservices Migration - Week 8 Check-in
Date: Tuesday

Attendees: Sam, Dana, Raj, Keiko

WHAT WENT WELL:
- Finally extracted the user service. It has its own database now.
- Raj figured out the event bus pattern for keeping user data in sync across services.
- Keiko's integration tests caught a race condition in the order service that would have been invisible in the monolith.
- Dana's decision to start with the user service (instead of orders like Sam wanted) turned out to be right. User data had fewer foreign key dependencies.

WHAT WENT WRONG:
- The shared database is now THREE databases. We went from "one database nobody owns" to "three databases that all need the same user data." The sync is fragile.
- Sam spent two days trying to get the AI code-splitting tool to understand our domain boundaries. It kept wanting to split along technical layers (controllers/services/repos) instead of business domains (users/orders/inventory).
- The AI tool generated migration scripts that would have dropped a column still used by the order service. Dana caught it in code review.
- We're now running the monolith AND two microservices simultaneously. Deploys take 3x longer.
- Raj's event bus pattern works but the error handling is "optimistic" (his word). Failed events just disappear.

WHAT WE LEARNED:
- AI code-splitting tools think in technical layers, not business domains. You have to be extremely explicit about domain boundaries or it defaults to splitting controllers from services from repositories.
- The hardest part isn't splitting the code. It's splitting the data. We underestimated this by about 300%.
- Running monolith + microservices simultaneously is operationally miserable. We need a timeline for killing the monolith.
- Dana: "The AI is great at the mechanical work -- extracting interfaces, generating service stubs, writing migration scripts. It's terrible at deciding WHAT to extract. That's still a human judgment call."
- Integration tests between services need to exist BEFORE you split, not after. Keiko had to backfill tests for behaviors that were implicit in the monolith.

ACTION ITEMS:
- Raj: add dead letter queue for failed events (2 days)
- Sam: write blog post about the migration so far
- Keiko: set up contract tests between user service and order service
- Dana: create timeline for monolith sunset

RANDOM QUOTES:
- Sam: "I told the AI to split by domain and it split by file extension."
- Dana: "If we'd started with the order service we'd still be untangling foreign keys."
- Raj: "The event bus works perfectly. As long as nothing fails. Which it does."
- Keiko: "I found a race condition that's been there for two years. The monolith just hid it."
=============== END INPUT ===============
