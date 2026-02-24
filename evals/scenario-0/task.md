# Write a Developer Blog Post from a Livestream Transcript

## Problem/Feature Description

Marcus Chen runs a developer blog where he writes about his real experiences building software with AI tools. He just finished a livestream where he and his colleague Priya paired on building a recipe recommendation API using an AI coding agent. The session had some dramatic failures and a satisfying resolution.

Marcus needs a complete blog post draft written from the transcript below. The post should be part 3 of his "Agent Disasters" series. His voice profile and previous series context are provided. The draft should be ready for Marcus to review -- he'll fill in screenshots and verify code blocks later.

The slug for this post is `agent-disasters-ep3`.

## Output Specification

Produce the following files in the working directory:
- `blog-research-agent-disasters-ep3.md` -- a structured research/notes file capturing key information from the transcript
- `blog-draft-agent-disasters-ep3.md` -- the complete blog post draft
- `draft-summary.md` -- a brief summary of the draft: word count, counts of each placeholder type, and any open questions

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: persona/voice.md ===============
# Voice Profile: Marcus Chen

## The Voice in One Paragraph

You're a backend engineer who has strong opinions about code quality but isn't above admitting when you're wrong. You tell stories about debugging sessions and production incidents like war stories -- with enough detail that the reader can feel the panic. You're skeptical of hype but genuinely excited when things actually work. Your humor is dry and self-directed, often taking the form of understating disasters.

## Rhetorical Devices That Work

### The understatement
Describe something catastrophic in calm, measured tones.

> "The agent helpfully decided to store API keys in a public JSON file. Suboptimal."

> "We lost about forty minutes to what I'll generously call a 'learning experience.'"

### Parenthetical confessions
Used for admitting things you probably shouldn't.

> "(I did not, in fact, read the documentation first)"

> "(this was the third time this week)"

### Short paragraph emphasis
A one-sentence paragraph after a longer one for comedic or dramatic effect.

> "The agent had generated a fully functional authentication system. For a completely different application."

### Direct reader address
Pulling the reader into the experience.

> "You know that feeling when the tests pass but you don't trust them? That."

## Cultural Reference Style
References to programming culture, classic debugging war stories, and occasional movie references. Never forced, always illuminating the point.

## Recurring Characters

- **Priya** -- colleague and co-debugger. The voice of reason when Marcus goes down rabbit holes. Often quoted saying things like "maybe we should just read the error message."

## Voice Consistency Notes
The dry humor continues into technical explanations. Code blocks are introduced with personality, not clinical descriptions. The voice stays consistent whether discussing architecture or describing a 2 AM incident.

=============== FILE: persona/bio.md ===============
# Author Bio: Marcus Chen

## Bio Schema
Marcus Chen is a backend engineer at DataPipe, where he builds things that occasionally work on the first try. Previously spent eight years convincing databases to behave at a Fortune 500 company. [Rotating kicker connecting to post content.]

## Kicker Notes
Rotating. Should be a dry observation connecting to something specific in the post. Self-deprecating preferred.

=============== FILE: persona/examples.md ===============
# Example Posts: Marcus Chen

## Agent Disasters, Episode 1: "The Authentication Incident"
Key patterns: understatement of catastrophe, Priya as voice of reason, technical detail woven into narrative

## Agent Disasters, Episode 2: "The Database That Wasn't"
Key patterns: slow reveal of the problem, parenthetical confessions, reader address in technical sections

=============== FILE: series-tracker.md ===============
# Series Tracker

## Agent Disasters
- Episode 1: "The Authentication Incident" -- published
  - Callbacks: "the authentication incident" as a running reference
  - Priya's catchphrase established: "maybe we should just read the error message"
- Episode 2: "The Database That Wasn't" -- published
  - Callbacks: referenced Episode 1's auth disaster
  - New running joke: Marcus's tendency to say "it's probably a quick fix"
  - Teaser at end: "Next time: we let the agent loose on a real API. What could go wrong?"
- Episode 3: IN PROGRESS
  - Should callback to "it's probably a quick fix" and the Episode 2 teaser

=============== FILE: transcript.txt ===============
MARCUS: Alright, we're live. Welcome back to another episode of us embarrassing ourselves in public. Today Priya and I are going to build a recipe recommendation API. The idea is simple: you send it ingredients you have in your fridge, it tells you what you can cook.

PRIYA: Simple. Famous last words.

MARCUS: Right. So we're going to use the AI agent to scaffold the whole thing. FastAPI backend, a simple matching algorithm, maybe some nutritional data. Let's just prompt it and see what happens.

[Marcus types a prompt asking the agent to create a FastAPI recipe recommendation service]

MARCUS: Okay it's generating... and it's going fast. Look at all those files. It made a models directory, a routes directory, a services directory...

PRIYA: It even made a Dockerfile. We didn't ask for a Dockerfile.

MARCUS: I mean, that's fine, we'll probably need one eventually. Let's look at the main endpoint first. [reads screen] Okay so it takes a POST request with a list of ingredients... and it... wait.

PRIYA: What?

MARCUS: It's calling the OpenAI API. For every single request. It's not matching against a database of recipes. It's literally asking GPT to invent recipes on the fly.

PRIYA: We said "recommendation engine." It heard "ask another AI."

MARCUS: And look at the cost estimation here. At maybe 2000 tokens per request, if we get any traffic at all, we'd be paying more for recipe suggestions than the ingredients cost.

PRIYA: Maybe we should just read the error message. Oh wait, there isn't one. It works perfectly. It's just architecturally insane.

MARCUS: Okay so let's fix this. I'm going to tell it to use a local recipe database instead. SQLite for now, seed it with some sample recipes. Match based on ingredient overlap.

[Marcus prompts the agent to refactor to use a local SQLite database]

MARCUS: It's refactoring... okay. It created the database models, a seed script, and... it kept the OpenAI call.

PRIYA: What?

MARCUS: Yeah, look. It uses SQLite to find candidate recipes, then sends those candidates to OpenAI to "rank them by relevance." We went from fully AI-powered to a hybrid approach that's somehow worse.

PRIYA: It's probably a quick fix. [both laugh]

MARCUS: Famous last words from Episode 2, back to haunt us. Okay, round three. I'm being extremely explicit this time. No external API calls. SQLite only. Match recipes where the user has at least 70% of the required ingredients. Sort by match percentage.

[Marcus writes a very detailed prompt]

MARCUS: And... look at that. It actually did it. Clean query, percentage calculation, sorted results. No OpenAI anywhere.

PRIYA: The seed data looks good too. Fifty recipes with ingredients and steps. Although... [squints at screen] Marcus, it seeded a recipe for "chocolate spaghetti."

MARCUS: [reads screen] "Chocolate Spaghetti: A fusion dish combining the comfort of pasta with the richness of chocolate." I'm going to pretend I didn't see that.

PRIYA: The matching algorithm works though. I sent it eggs, flour, and sugar, and it correctly returned pancakes, crepes, and basic cake. Not chocolate spaghetti, thankfully.

MARCUS: Let's add the nutritional data endpoint. [prompts agent]

[Agent generates a nutrition endpoint that scrapes a website in real-time]

MARCUS: It's... scraping a nutrition website. In real time. For every request.

PRIYA: At least it's not calling OpenAI this time?

MARCUS: Progress! [sighs] Okay. Static nutrition data. In the database. Seed it. No scraping. No external calls.

[After another round, the agent produces a working version with static nutritional data]

MARCUS: There we go. Took us four tries on the recipe matching and two on the nutrition data, but we have a working API. FastAPI, SQLite, no external dependencies. You POST your ingredients, you get back recipes sorted by match percentage with nutritional info.

PRIYA: The real lesson here is that the agent's first instinct was to outsource the hard part to another AI. It generated a wrapper around GPT instead of actually solving the problem.

MARCUS: Which is kind of what a lot of us do, honestly. When you have a hammer that can call GPT-4, everything looks like a prompt.

PRIYA: Maybe the agent learned it from watching us.

MARCUS: Harsh but fair. The code it eventually wrote is solid though. Clean separation of concerns, proper error handling on the database queries, and the matching algorithm is actually clever -- it uses set intersection for the ingredient matching instead of iterating through everything.

[They run the test suite the agent generated]

MARCUS: 14 tests, all passing. And these are real tests -- they actually check edge cases like empty ingredient lists and recipes with no matches. The agent wrote better tests than I usually do.

PRIYA: Low bar.

MARCUS: [laughs] Okay, we're going to wrap up. The API works, the tests pass, and we only had to tell the agent "no, don't call the internet" four separate times.
=============== END TRANSCRIPT ===============
