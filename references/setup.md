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

Ask the author:

1. **Name** — How should you be credited in the author bio?
2. **Role and company** (optional) — e.g., "Developer Advocate at Acme Corp." Leave blank
   if you're writing independently.
3. **One-line career context** (optional) — A previous role or experience that gives you
   credibility. e.g., "Previously spent 10 years building distributed systems at Netflix."

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

Using the basic info from Step 2, ask the author about their bio preferences:

> How do you want your author bio to work? I need:
> 1. A **bio template** — the fixed part that appears on every post
> 2. Whether you want a **rotating kicker** — a final sentence that changes per post
>    (usually a dry joke or callback to the post's content)
>
> Here's an example of a bio with a rotating kicker:
> > "[Name] is a [Role] at [Company], where [current focus]. Previously, [career context].
> > [Dry kicker that callbacks to the post.]"

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

Ask the author:

> Do you write about a specific product or platform? If so, I can set up a product
> context file so I'll check technical accuracy against your docs during drafting.
>
> This is optional — skip it if you write about general topics.

**If yes:**
1. Ask for the product name
2. Ask for the docs URL or a list of key doc pages
3. Ask for key concepts/terminology the blog should get right
4. Generate `persona/product.md` with the same structure as `example-persona/product.md`:
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
>
> Ready to write a blog post? Just tell me what you're working on.

Proceed to the normal blog writing flow (back to SKILL.md).
