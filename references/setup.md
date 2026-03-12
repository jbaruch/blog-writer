# Persona Setup Flow

This file defines the interactive onboarding that runs when `persona/voice.md` is empty
or missing. Follow these steps in order. The goal: generate persona files that let the
blog-writer skill match the author's actual voice.

---

## Step 1: Welcome

Tell the author:

> **Welcome to the blog-writer skill!**
>
> Before we write anything, I need to learn your voice. I'll ask a few questions, then
> analyze some of your existing writing to build a voice profile. This takes about 5
> minutes and only happens once.
>
> You can see an example of a completed persona in `example-persona/` if you want to
> know what we're building toward.

---

## Step 2: Basic Info

Ask these **one at a time**, waiting for each answer before proceeding:

**Question 1:**
> How should you be credited in the author bio?
>
> 1. Your full name (e.g., "Jane Smith")
> 2. A handle or pen name
> 3. Something else (type it out)

**Question 2:**
> What's your current role? (This is optional — skip if you're writing independently.)
>
> 1. [Guess based on any context you have] ← my guess
> 2. A different role (type it out)
> 3. Skip — I'm writing independently

**Question 3:**
> Any previous role or experience to mention for credibility? (Optional)
>
> 1. [Guess if you have context] ← my guess
> 2. Something else (type it out)
> 3. Skip — not needed

Record the answers. These feed into the bio template later.

---

## Step 3: Writing Samples

Ask for 2-5 writing samples. These are the foundation of the voice analysis. The more
representative the samples, the better the voice profile.

Accepted formats:
- **URLs** to published blog posts (use WebFetch to retrieve)
- **Pasted text** directly in the conversation
- **Local file paths** (use Read to retrieve)

Tell the author:

> I need 2-5 samples of your writing. These should be posts or articles that sound
> like YOU — your natural voice, not corporate ghostwriting. Blog posts, newsletter
> issues, conference talk write-ups all work. The more "you" they sound, the better
> I can learn your voice.
>
> Give me URLs, paste text, or point me to local files.

Fetch/read all samples before proceeding.

---

## Step 4: Voice Analysis

Analyze the collected samples to identify patterns across these dimensions:

### 4a: Overall voice and personality
- What's the general register? (casual, technical, academic, conversational)
- How does the author relate to the reader? (peer, teacher, storyteller, provocateur)
- What's the confidence level? (assertive, hedging, self-deprecating, authoritative)

### 4b: Rhetorical devices
Catalog the specific devices the author actually uses, with examples pulled from their
writing. Common ones to look for:
- Self-deprecation (and how it's calibrated — mild, escalating, absurd)
- Parenthetical asides (and what they're used for — commentary, jokes, caveats)
- Deadpan delivery (stating absurd things matter-of-factly)
- Cultural references (what domains — movies, books, history, games, music)
- Short paragraphs as punchlines
- Direct address to the reader
- Rhetorical questions (real ones, not the self-answering fragment kind)
- ALL CAPS emphasis
- Italics for emphasis or voices
- Any other patterns that appear consistently

For each device found, include 1-2 direct quotes from the samples.

### 4c: Cultural reference style
- What era/domains do the references come from?
- How frequent are they? (every paragraph, once per post, rare)
- Are they explained or left for the reader to get?

### 4d: Humor type and calibration
- What kind of humor? (dry, self-deprecating, absurdist, observational, none)
- How often? (constant undercurrent, occasional beats, rare)
- What's off-limits or out of character?

### 4e: Technical depth tendencies
- Does the author go deep on implementation details?
- How are code examples introduced and framed?
- How are technical concepts explained to the audience?

### 4f: Recurring elements
- Named characters, collaborators, or foils
- Catchphrases or signature transitions
- Running jokes or callbacks between posts
- Structural patterns (how posts typically open, close, transition)

---

## Step 5: Generate and Review `persona/voice.md`

Using the analysis from Step 4, generate `persona/voice.md` with this structure:

```markdown
# Voice Profile: [Author Name]

## The Voice in One Paragraph
[Synthesized description of the author's voice — what makes them sound like them]

## Rhetorical Devices That Work
[Each device as a subsection with description and quoted examples from their writing]

## Cultural Reference Style
[Era, domains, frequency, approach]

## Recurring Characters
[Named collaborators, foils, or recurring figures — if any]

## Voice Consistency Notes
[How the voice behaves in technical sections, whether it changes register, etc.]
```

**Present the generated file to the author for review.** Ask:

> Here's the voice profile I built from your writing samples. Read through it — does
> this sound like you? Anything missing, wrong, or overemphasized?

Apply their feedback, then write the final version to `persona/voice.md`.

---

## Step 6: Generate `persona/bio.md`

Using the basic info from Step 2, ask **one question at a time**:

> Do you want a rotating kicker at the end of your bio? That's a final sentence that
> changes per post — usually a dry joke or callback to the post's content.
>
> Example: "[Name] is a [Role] at [Company]. Previously [career context].
> [Dry kicker that connects to this specific post.]"
>
> 1. Yes — rotating kicker per post ← my guess (it adds personality)
> 2. No — fixed bio every time
> 3. Not sure — show me examples of both

Generate `persona/bio.md` with:

```markdown
# Author Bio: [Author Name]

## Bio Schema
[The template with variable parts marked]

## Examples
[1-2 example bios if available from the writing samples, or generate examples
based on the template and the author's info]

## Kicker Notes
[How the kicker should work — rotating or fixed, tone guidance]
```

Write to `persona/bio.md`.

---

## Step 7: Product Context (Optional)

Ask:

> Do you write about a specific product or platform?
>
> 1. Yes — I write about a specific product ← let me set up accuracy checks
> 2. No — I write about general topics (skip this step)

**If yes**, ask follow-up questions **one at a time**:

> What's the product name?
> 1. [Guess if you have context] ← my guess
> 2. Something else (type it out)

> Where are the docs?
> 1. [Guess URL if you have context] ← my guess
> 2. A different URL (type it out)
> 3. I'll provide a list of key pages

> Any key concepts or terminology the blog must get right?
> 1. Just use what's in the docs
> 2. Let me list some specific terms (type them out)

Generate `persona/product.md` with the same structure as `example-persona/product.md`:
- Product name and docs site
- Topic-to-URL index
- How to use the index during Phase 0 and Phase 3

**If no:**
Leave `persona/product.md` empty. The process phases will skip product accuracy checks
automatically.

---

## Step 8: Record Examples in `persona/examples.md`

Write the sample URLs/references from Step 3 to `persona/examples.md`:

```markdown
# Example Posts: [Author Name]

The following posts define the canonical tone. Fetch them during Phase 0 to calibrate
voice when writing in a series or when the tone needs recalibration.

## [Post title or description]
URL: [url]
Key patterns: [1-line note about what this sample demonstrates about the voice]
```

---

## Step 9: Confirm Setup Complete

Tell the author:

> **Setup complete!** Your persona files are ready:
> - `persona/voice.md` — Your voice profile
> - `persona/bio.md` — Your bio template
> - `persona/product.md` — [Product context / Skipped]
> - `persona/examples.md` — Your reference posts
>
> You can edit any of these files directly at any time. The skill reads them fresh
> each session.

Then ask the global voice question (see Step 10).

After the author answers, tell them:

> Ready to write a blog post? Just tell me what you're working on.

Proceed to the normal blog writing flow (back to SKILL.md).

---

## Step 10: Global Voice Preference

**Ask this every time the persona is updated** — after the initial setup (Step 9) AND
after new blog posts are added to `persona/examples.md`.

> Want me to use this voice profile as my default voice when talking to you across
> all projects? I can save it to your global Claude Code user memory so every
> conversation picks it up automatically.
>
> 1. Yes — make this my global voice
> 2. No — only use it for blog writing
> 3. Not sure — remind me next time

**If yes:** Write a summary of the voice profile to `~/.claude/user-memory/voice.md`
(or update if it already exists). Include the key voice characteristics, rhetorical
devices, and tone notes from `persona/voice.md` — enough for any Claude Code session
to adopt the voice without access to the persona files.

**If no:** Do nothing. The voice stays local to the blog-writer skill.

**If not sure:** Do nothing now, but ask again next time the persona is updated.
