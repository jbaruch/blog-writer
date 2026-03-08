# AI Writing Anti-Patterns

These are hard rules. If you catch yourself writing any of these patterns, rewrite.
During the anti-pattern check (Phase 3 and Phase 4), scan the draft for every pattern
listed here. Zero tolerance.

---

## 1. Rhetorical Contrastive Negation

**The tell:** "Not X. Y." or "Not X. Just Y." or "It's not about X. It's about Y."
A negation followed by an affirmation, framed as revelation.

**Symptoms:**
- Two short sentences, first negating, second affirming
- Often starts with "Not" or "It's not about"
- The pair is supposed to sound like a mic drop

**Examples:**
- ❌ "Not just a tool. A methodology."
- ❌ "It's not about the code. It's about the process."
- ❌ "Not hype. Results."

**Structural variants:**
The negation doesn't have to lead the sentence or use the word "Not."
- "I went from 65 to zero by fixing the input, not the output." — Contrastive negation
  embedded at the end of a sentence.
- "The only thing I changed was the prompt, not the code." — Same structure, different
  position.
- Any "[positive claim], not [contrasting thing]" at the end of a sentence is this pattern
  in a less obvious position.

**Why it's a tell:** This is the single most common LLM writing pattern. It sounds
confident and pithy to a machine. To a human reader it sounds like a LinkedIn post.

**Instead:** Make the point directly.
- ✅ "The process matters more than the code, and here's three hours of public
  embarrassment proving it."

---

## 2. Parallel Binary Comparisons

**The tell:** Balanced A/B sentence pairs with mirrored structure. One thing does X,
the other does Y, and the two clauses are suspiciously symmetrical.

**Symptoms:**
- Two clauses with identical grammatical structure
- "Where X gives you A, Y gives you B"
- "One approach [verb]. The other [same verb]."

**Examples:**
- ❌ "Where vibecoding gives you speed, spec-driven development gives you correctness."
- ❌ "One approach trusts the model. The other trusts the process."

**Structural variants:**
Watch for identical grammatical skeletons even when the vocabulary differs.
- "Tessl gates what goes into the agent. SonarQube validates what comes out." — Different
  verbs, different subjects, but the skeleton is identical: [Tool] [verb] what [preposition]
  the agent.
- "'Build queries dynamically' meant X. 'Graceful error recovery' meant Y." — Two quoted
  phrases followed by the same verb. The parallel is in the structure, not the words.
- "skills (how to build things), rules (what to always do), and documentation (accurate API
  knowledge)" — Triple parallel with identical parenthetical structure.

**Why it's a tell:** Real comparisons are messy. Things don't map 1:1 onto neat
structural parallels. When they do in prose, it's because the writer manufactured
the symmetry.

**Instead:** Show the comparison through narrative. Tell the story of A failing,
then tell the story of B succeeding. Let the reader draw the conclusion.

---

## 3. Asyndetic Tricolon with a Kicker

**The tell:** Three short fragments in sequence, followed by a punchline.
"X. Y. Z. And then [dramatic conclusion]."

**Symptoms:**
- Three sentence fragments, usually 1-4 words each
- Followed by a longer sentence starting with "And"
- Designed to build rhythm toward a reveal

**Examples:**
- ❌ "Fast. Cheap. Wrong. And deployed to production."
- ❌ "No tests. No specs. No way to verify. And 25% of Y Combinator is built this way."

**Structural variants:**
The three items don't have to be single words or short fragments.
- "We wrote the spec. We tested the agent. We validated the output. And then we realized
  the spec was wrong." — Full sentences, but the same rhythm: three setup beats + punchline.
- Any list of three that exists only to build momentum toward a fourth item is this pattern,
  regardless of item length.

**Why it's a tell:** The published posts DO use lists of three sometimes. The difference:
they occur inside natural paragraphs, not as standalone staccato fragments designed to
sound dramatic.

**Instead:** Embed the list in a flowing sentence.
- ✅ "No tests. No specs. No way to verify if it's doing what you actually wanted."
  (Works because it's part of a paragraph about vibecoding's failures, not standing
  alone as a dramatic fragment.)

---

## 4. Choppy Fragment Chains

**The tell:** Multiple sentence fragments in sequence for "dramatic effect." Each
fragment is 1-5 words, usually noun phrases.

**Symptoms:**
- Three or more consecutive fragments
- No verbs, just noun phrases with periods
- Reads like a movie trailer voiceover

**Examples:**
- ❌ "Purple gradients. Chat interface. Zero tests. Pure vibes."
- ❌ "Same model. Same prompt. Different result."

**Structural variants:**
Fragments don't have to be noun phrases.
- "Tested it. Broke it. Fixed it. Shipped it." — Verb-phrase fragments, same pattern.
- "New model. Retrained from scratch. Still hallucinating." — Mixed lengths, but still a
  chain of fragments substituting rhythm for meaning.
- Any sequence of three or more sentences under six words where none carries a full thought.

**Why it's a tell:** It substitutes rhythm for meaning. Every fragment carries equal
weight, which means none of them carry any weight.

**Instead:** Write actual sentences.
- ✅ "You get something that looks like an app. Purple gradients, chat interface, the
  whole AI-generated aesthetic. But underneath? Useless error handling."

---

## 5. Symmetrical LLM Patterns

**The tell:** Any sentence where the two halves mirror each other structurally.
The clauses are balanced like a seesaw.

**Symptoms:**
- "[Subject A] [verb] [object]. [Subject B] [same verb] [contrasting object]."
- Chiasmus or antithesis that reads like a fortune cookie
- Inverted parallelism: "X without Y yields A. Y without X yields B."

**Examples:**
- ❌ "The model is smart, but the context is dumb."
- ❌ "Process without knowledge yields organized hallucinations. Knowledge without
  process yields correctly spelled chaos."
- ❌ "The linter handles the style. The formatter provides the structure."

**Structural variants:**
The symmetry can span separate sentences and use different vocabulary.
- "The old pipeline caught errors at deployment. The new pipeline catches them at design
  time." — Two sentences, structurally mirrored, different words.
- "Without guardrails, the agent hallucinates. With guardrails, the agent delivers." — The
  only difference is one word; the grammatical skeleton is identical.
- Three parallel clauses are a tricolon wearing a fortune-cookie costume and should be caught
  as both this pattern and #3.

**Why it's a tell:** These read like fortune cookies. The structural balance makes
the writer feel clever, but the reader feels lectured.

**Instead:** Make the point once, directly, without the balancing act.
- ✅ "The linter will tell your code what's wrong, but it has no idea what your
  API endpoint actually needs to look like. That's what integration tests are for."

---

## 6. Self-Answering Fragment Questions

**The tell:** A short noun phrase posed as a question, immediately answered by its
own punchy fragment. The "question" never actually asks anything.

**Symptoms:**
- [Short noun phrase, 2-4 words]? [Short declarative fragment].
- Two fragments, neither a real sentence
- The question mark is doing the work of an em-dash

**Examples:**
- ❌ "And the UI? No purple gradients."
- ❌ "The result? A cleaner architecture."
- ❌ "The best part? It just works."
- ❌ "The takeaway? Context is everything."
- ❌ "And the error message? Also hallucinated."

**Structural variants:**
The question can be any length. The tell is the structure, not the word count.
- "Every single one of those 65 SonarQube findings from earlier? Now a prevention rule." —
  Same move as "The result? Great." The question exists only to set up its own answer.
- "That prompt I thought matched my design philosophy? It was basically an OWASP tutorial."
  — Full-clause question, still only exists to deliver the punchline.
- Any sentence you could restructure as "[statement]. [period]" without losing information
  is this pattern wearing a question mark as a costume.

**Why it's a tell:** It creates fake dramatic tension where none exists. It's a
formatting trick pretending to be rhetoric — a setup/punchline couplet disguised
as inquiry.

**Instead:** Use real rhetorical questions that invite the reader to actually think.
- ✅ "You know what's worse than an agent that hallucinates an API? One that
  hallucinates the error message too."
- ✅ "Who hasn't shipped code they were embarrassed by?"

Real rhetorical questions work because the reader pauses to consider them. The
self-answering version never invites thought.

---

## 7. Parenthetical Em-Dashes

**The tell:** Paired em-dashes used to set off an aside, where commas or parentheses
would do the same job.

**Symptoms:**
- "X — [subordinate clause] — Y" structure
- The aside between the dashes is not dramatic or surprising enough to warrant them
- Often used for simple relative clauses or appositives

**Examples:**
- ❌ "The agent — which had already failed twice — tried again."
- ❌ "The project's CLI — the part most developers interact with first — handles all of this."

**Why it's a tell:** Paired em-dashes make every aside feel like a dramatic reveal when
it's just a subordinate clause. LLMs scatter them everywhere because they pattern-match
on "emphasis" without understanding that not everything deserves it.

**Instead:** Use commas or parentheses.
- ✅ "The agent, which had already failed twice, tried again."
- ✅ "The project's CLI (the part most developers interact with first) handles all of this."

**Note:** A single em-dash for a hard break at the end of a clause is fine:
"It worked — barely." It's the matched pair acting as fancy commas that's the problem.

---

## 8. Excessive Em-Dashes

**The tell:** More than two em-dashes per section, even when used correctly.

**Symptoms:**
- Three or more em-dashes in a paragraph
- Em-dashes used as default punctuation instead of commas, colons, or periods

**Why it's a tell:** The published posts use em-dashes, but moderately. One or two per
section is fine. Five per paragraph means you're using them as a crutch instead of
writing clearer sentences.

**Instead:** Use commas, colons, semicolons, or periods. The em-dash is a spice,
not a staple.

---

## 9. Preamble Announcements

**The tell:** Announcing what the post is about to do before doing it.

**Symptoms:**
- "In this post, we'll explore..."
- "Let's take a look at..."
- "What follows is..."
- Closing variants: "In summary," "In conclusion," "Overall," "To sum up"

**Why it's a tell:** The TLDR handles the preview. The reader clicked the title. They
know what the post is about. Announcing it again is filler. The closing variant is the
same move in reverse — restating the point the reader just read.

**Instead:** Just start. Open with the hook, the story, the confession. End with the CTA
or the kicker, not a restatement. The reader doesn't need a table of contents narrated to
them, and they don't need the post summarized back at them.

---

## 10. Sycophantic Hedging

**The tell:** Filler phrases that soften a point without adding information.

**Symptoms:**
- "It's worth noting that..."
- "Interestingly enough..."
- "To be fair..."
- "It bears mentioning that..."
- Didactic variants: "It's important to note/remember...", "It's crucial to consider...",
  "It's essential to understand...", "may vary"

**Why it's a tell:** These are throat-clearing. They signal the writer isn't confident
enough to just make the point. LLMs insert them as politeness padding. The didactic
variants are worse — they talk down to the reader, implying they need to be told what's
important.

**Instead:** Delete the hedge and start with the actual point. If it's important, the
reader will know because you showed them why, not because you announced it.

---

## 11. Emojis

Never. Zero. Not even in the TLDR. Not even ironically.

---

## 12. AI Vocabulary Contamination

**The tell:** Specific words and phrases that appear 5-50x more frequently in AI-generated
text than in human writing. These are LLM "comfort words" — they sound authoritative to
a model but scream machine to a reader.

**The watchlist:**

Verbs: "delve", "underscore", "highlight" (as verb), "foster", "leverage", "harness",
"showcase", "streamline", "navigate" (abstract), "cultivate", "illuminate", "orchestrate",
"spearhead", "bolster", "enhance" (when inflating mundane improvements), "garner",
"align with", "resonate with", "exemplify", "encompass"

Nouns: "tapestry", "landscape" (abstract), "realm", "journey" (abstract), "ecosystem",
"paradigm", "trajectory", "blueprint", "interplay", "intricacies", "testament", "focal
point", "commitment" (abstract), "diverse array"

Adjectives: "pivotal", "crucial", "vital", "nuanced", "multifaceted", "robust", "seamless",
"comprehensive", "cutting-edge", "groundbreaking", "transformative", "enduring", "vibrant",
"meticulous/meticulously", "renowned", "nestled", "profound", "rich" (figurative: "rich
history", "rich cultural heritage"), "key" (as adjective: "key role", "key turning point"),
"valuable" ("valuable insights")

Inflation phrases: "plays a significant role in shaping", "serves as a testament to",
"it is important to note", "a vibrant tapestry of", "in the heart of", "setting the stage
for", "reflects broader", "deeply rooted", "marks/represents a significant shift",
"evolving landscape", "Additionally," (as sentence opener — research-backed strong tell)

**Why it's a tell:** Research tracking word frequency before and after ChatGPT shows
"delve" spiked 10-50x, "tapestry" and "landscape" (abstract) 5-20x, and "plays a
significant role in shaping" appeared 207x more often in AI text. Readers have learned
to pattern-match on these words even if they can't articulate why.

**Instead:** Use plain words. "Delve into" → "look at." "Leverage" → "use."
"Navigate the landscape" → "figure out." "Pivotal" → "important" (or better: show
why it matters instead of asserting it). "Nuanced" → "detailed" or just describe the
actual nuance.

One of these words in a 2,000-word post is fine. Three in a paragraph is a contamination
event. Scan for them.

---

## 13. Copula Avoidance

**The tell:** LLMs avoid simple "is", "are", and "has" constructions, substituting
elaborate verbs that inflate the significance of mundane statements.

**Symptoms:**
- "serves as" / "stands as" / "acts as" instead of "is"
- "boasts" / "features" / "offers" instead of "has"
- "represents" / "marks" / "signals" instead of "is"
- "underscores" / "highlights" / "reflects" instead of "shows"

**Examples:**
- ❌ "This feature serves as a bridge between the developer and the runtime."
- ❌ "The config file stands as the single source of truth."
- ❌ "The dashboard boasts a real-time monitoring panel."

**Structural variants:**
The inflated verb doesn't always replace "is" — it can replace any simple verb.
- "provides" / "delivers" / "enables" instead of "has" or "lets you"
- "This approach empowers developers to..." instead of "This lets developers..."
- "The framework facilitates seamless integration" instead of "The framework connects to..."
- Any verb that makes a mundane statement sound like a press release.

**Why it's a tell:** These substitutions make everything sound ceremonial. A config
file doesn't "stand as" anything. It IS the source of truth. The inflated verb implies
the sentence is making a grander point than it actually is.

**Instead:** Use "is", "are", "has." They're not boring — they're precise.
- ✅ "This feature connects the developer to the runtime."
- ✅ "The config file is the source of truth."
- ✅ "The dashboard has a real-time monitoring panel."

---

## 14. Low Burstiness

**The tell:** Every sentence is roughly the same length and structure. No rhythm
variation between short punchy sentences and longer complex ones.

**Symptoms:**
- Three or more consecutive sentences within 5 words of each other in length
- Every paragraph has the same cadence: medium sentence, medium sentence, medium sentence
- No one-line paragraphs for emphasis, no long flowing sentences for complexity
- Reads like it was generated by the same function called in a loop

**Why it's a tell:** Human writers naturally vary sentence length. A short sentence
after a long one creates emphasis. A long sentence after two short ones builds complexity.
LLMs produce text with remarkably uniform sentence length — researchers call this "low
burstiness." It's one of the most reliable structural signals of AI text, even when the
vocabulary is clean.

**Instead:** Read your paragraphs out loud. If every sentence takes the same number of
breaths, rewrite. Break a long sentence into a punchy two-worder. Combine two medium
sentences into one that flows. The goal is rhythm, not uniformity.

Good target distribution: roughly 20% short (under 10 words), 50% medium (10-20 words),
30% long (20+ words). You don't need to count — just listen for monotony.

---

## 15. Fabricated Experience

**The tell:** The AI simulates personal encounters, emotional reactions, or sensory
moments that never happened. It narrates an internal state to sound human.

**Symptoms:**
- "What I find genuinely interesting is..."
- "I keep bumping into this pattern..."
- "Picture the workflow: you sit down at your desk and..."
- "I've been wrestling with this question..."
- "Something feels off about this approach..."
- "The thing that struck me watching this was..."

**Why it's a tell:** Blog posts SHOULD have personal voice and real experience — that's
what makes them good. The problem is when the AI manufactures these moments instead of
drawing from the author's actual experience. The fabricated version is always vague ("I
find this interesting") where real experience is specific ("I tried this at 2 AM and the
build broke in a way I'd never seen").

**Instead:** Personal moments must come from the source material — the transcript, the
author's notes, the actual events. If the author said something funny on camera, use that.
If you don't have a real moment, don't invent one. Write the point directly instead of
wrapping it in fake experience.

- ❌ "I keep coming back to this idea that agents need guardrails."
- ✅ "Twelve minutes into the demo, the agent deleted the test database. That's when we
  started talking about guardrails."

---

## 16. False Ranges

**The tell:** "From X to Y" constructions that claim universal applicability without
evidence. The range sounds inclusive but says nothing specific.

**Symptoms:**
- "From beginners to experts"
- "From startups to enterprises"
- "From simple scripts to complex architectures"
- "Whether you're building a side project or scaling to millions of users"

**Examples:**
- ❌ "This approach works for teams of all sizes, from two-person startups to
  hundred-engineer organizations."
- ❌ "From junior developers just learning the ropes to seasoned architects designing
  distributed systems, everyone can benefit."

**Why it's a tell:** Real tools have a sweet spot. Real blog posts are honest about who
they're for. "From X to Y" is a hedge disguised as inclusivity — it avoids committing
to an audience because the AI doesn't know who the audience actually is. It's the
equivalent of a restaurant claiming to serve "everyone from toddlers to gourmands."

**Instead:** Be specific about who this is for and own the limitation.
- ✅ "If you've shipped a production app and gotten paged for it, this will make sense.
  If you're still in tutorials, bookmark it for later."

---

## 17. Synonym Cycling

**The tell:** The same thing is called by a different name every time it appears.
"The CLI" becomes "the tool" becomes "the interface" becomes "the command-line solution"
across consecutive paragraphs — all referring to the exact same thing.

**Symptoms:**
- A technical concept is named differently in each paragraph
- "Developers" → "engineers" → "practitioners" → "builders" → "teams"
- "The feature" → "the capability" → "the functionality" → "the offering"
- Each synonym is less precise than the original term

**Examples:**
- ❌ "The CLI scaffolds the project. Once the tool finishes, review the output.
  The interface will prompt you for confirmation."
- ❌ "Developers can install the tile. Engineers who need customization can fork it.
  Practitioners in larger teams should use the workspace feature."

**Structural variants:**
Cycling can happen within a single sentence or across sections, not just adjacent paragraphs.
- "managing your dependencies, tracking your packages, and updating your libraries" — all
  three noun phrases describe the same concept within one sentence.
- The intro calls it "the CLI" and the conclusion calls it "the command-line experience" —
  cycling across sections is harder to spot but equally confusing.
- Pronoun avoidance is a subtle form: using "the tool" or "the solution" instead of "it"
  when the referent is obvious from context.

**Why it's a tell:** LLMs are trained with repetition penalties that discourage reusing
tokens. So the model reaches for synonyms even when the original word was the right one.
In technical writing, this creates confusion — the reader wonders whether "the tool" and
"the interface" are the same thing or different things. Repetition of the precise term
is clarity. Variation with imprecise synonyms is noise.

**Instead:** Use the same word. "The CLI" is "the CLI" every time. If it appears too
often in a passage, restructure the sentences or use a pronoun — don't swap in a vaguer
synonym.
- ✅ "The CLI scaffolds the project. Once it finishes, review the output. It will
  prompt you for confirmation."

---

## 18. Unicode Giveaways

**The tell:** The draft contains Unicode characters that a human typing in a text editor
would not produce. These are character-level fingerprints of LLM-generated text.

**Characters to scan for:**
- Curly double quotes: `\u201C` (") and `\u201D` (") — instead of straight `"` (U+0022)
- Curly single quotes: `\u2018` (') and `\u2019` (') — instead of straight `'` (U+0027)
- Horizontal ellipsis: `\u2026` (…) — instead of three dots `...`
- Bullet character: `\u2022` (•) — instead of markdown `-` or `*`
- En dash: `\u2013` (–) — instead of a hyphen or em-dash

**Why it's a tell:** A human writing in a text editor, markdown file, or code editor
produces straight quotes, three dots, and hyphens. The CMS or publishing platform
converts these to typographically correct characters for the reader. When the markdown
source already contains curly quotes or a Unicode ellipsis, it means the text was
generated by an LLM (ChatGPT in particular outputs curly quotes by default).

**Instead:** Use plain ASCII in the draft. Straight quotes, three dots, hyphens. Let the
publishing system handle typography. During the anti-pattern scan, search the draft file
for these Unicode characters and replace any that appear.

---

## 19. Participle-Phrase Filler

**The tell:** A sentence ends with a present-participle ("-ing") clause tacked on as
fake analysis. The clause sounds like it's adding insight but says nothing the main
clause didn't already say.

**Symptoms:**
- "..., significantly enhancing developer productivity."
- "..., highlighting the importance of testing."
- "..., demonstrating the ongoing relevance of this approach."
- "..., ensuring consistent behavior across environments."
- "..., contributing to the overall reliability of the system."
- The "-ing" clause could be deleted without losing any information

**Examples:**
- ❌ "The new feature reduces build times by 40%, significantly enhancing developer
  productivity."
- ❌ "The team adopted trunk-based development, reflecting a broader industry shift toward
  continuous integration."
- ❌ "We added input validation to every endpoint, ensuring robust error handling across
  the application."

**Structural variants:**
The participle clause doesn't have to be at the end.
- "Significantly reducing build times, the new feature..." — participle clause leading the
  sentence instead of trailing it. Same pattern, different position.
- "The migration, encompassing three services and two databases, completed on schedule." —
  participle clause as a parenthetical aside, combining this pattern with #7.
- A participle clause used as a transition between paragraphs: "Building on this success,
  we then turned to..." — the "-ing" phrase connects paragraphs without adding information.

**Why it's a tell:** LLMs append these clauses to make simple statements sound analytical.
The participle phrase restates the main clause's implication as if it's a separate insight.
"Reduces build times by 40%" already means "enhances developer productivity" — saying both
is redundant inflation.

**Instead:** End the sentence at the real point. If the implication is worth stating, give
it its own sentence with specific evidence.
- ✅ "The new feature reduces build times by 40%."
- ✅ "We added input validation to every endpoint. The 500-error rate dropped from twelve
  per hour to zero."

---

## 20. Significance Inflation

**The tell:** Mundane facts are framed as historically important moments, broader shifts,
or lasting legacies. The sentence asserts significance instead of showing it.

**Symptoms:**
- "This marks a pivotal moment in..."
- "...represented a significant shift toward..."
- "...solidifying its role as..."
- "This highlights the enduring legacy of..."
- "...the transformative power of..."
- "...plays a crucial role in the ecosystem"

**Examples:**
- ❌ "The v2.0 release marks a pivotal moment in the evolution of developer tooling."
- ❌ "This migration represented a significant shift toward cloud-native architecture."
- ❌ "The framework's adoption highlights the transformative power of open source."

**Structural variants:**
The inflation doesn't have to use the word "pivotal" or "significant."
- "This was a turning point for how we thought about deployment." — "turning point" is
  significance inflation without the flagged vocabulary.
- "The decision would go on to reshape our entire engineering culture." — retrospective
  inflation that frames a mundane choice as historically momentous.
- "It was at this moment that everything changed." — narrative inflation without any
  specific AI vocabulary tells.

**Why it's a tell:** LLMs inflate significance because they pattern-match on authoritative
encyclopedia prose. A version bump is not a pivotal moment. A migration is not a
significant shift. These phrases are significance-assertions without evidence — the
written equivalent of an applause sign.

**Instead:** Show the impact with specifics. Let the reader decide if it's significant.
- ✅ "The v2.0 release cut the config file from 200 lines to 12."
- ✅ "After the migration, deploys went from 45 minutes to 90 seconds."

---

## 21. Challenge-Optimism Sandwich

**The tell:** A formulaic structure: acknowledge positives, pivot to challenges with
"Despite," then resolve with vague optimism about the future.

**Symptoms:**
- "Despite its [positive words], [subject] faces several challenges..."
- "Despite these challenges, [subject] continues to thrive/gain traction/evolve"
- "Future investments/developments could further enhance..."
- The "challenges" are vague and the "optimism" is unsupported

**Examples:**
- ❌ "Despite its growing adoption, the framework faces challenges in enterprise
  environments. Despite these challenges, the community continues to thrive, and future
  developments could further enhance its capabilities."
- ❌ "Despite its promise, the tool faces challenges around documentation and onboarding.
  Nevertheless, it continues to gain traction among developers."

**Structural variants:**
The pivot word doesn't have to be "Despite."
- "While the framework has seen impressive adoption, scalability remains a concern.
  Nevertheless, the community continues to grow." — "While" as the pivot word.
- "Although early results were promising, the team faced hurdles. Even so, the project
  moved forward." — "Although" + "Even so" is the same sandwich.
- The optimism half can be disguised as a forward-looking statement: "Future improvements
  are expected to address these limitations." — vague future tense is the tell.

**Why it's a tell:** This is a structural formula, not analysis. The "despite" pivot is
a template the LLM fills in for any subject. Real analysis of challenges names specific
problems and proposes specific solutions. The sandwich structure exists to sound balanced
without committing to an actual opinion.

**Instead:** If there are real challenges, name them specifically and say what you'd do
about them. If there aren't, don't manufacture them for "balance."
- ✅ "The docs assume you already know Kubernetes. If you don't, you'll spend your first
  hour on Stack Overflow, not on the tool."

---

## 22. Inline-Header Lists

**The tell:** Bullet points where each item starts with a boldfaced term followed by a
colon and then a description. The format is inherited from READMEs, sales pages, and
how-to guides.

**Symptoms:**
- "**Term:** Description of what it does..."
- "**Feature Name:** Why this matters..."
- Every bullet follows the identical bold-colon-description structure
- Often used for "Key Takeaways" or "What We Learned" sections

**Examples:**
- ❌ "**Spec-driven development:** Define what you're building before the agent starts."
- ❌ "**Context management:** Keep the agent focused by limiting what it can see."
- ❌ "**Guardrails:** Prevent the agent from making unauthorized changes."

**Structural variants:**
The pattern doesn't require bold formatting or bullet points.
- "Spec-driven development -- Define what you're building before the agent starts." — em-dash
  instead of bold+colon, same glossary structure.
- Numbered lists with the same format: "1. Context management: Keep the agent focused..." —
  numbered instead of bulleted.
- A "Key takeaways" or "What we learned" section where every item follows the same
  term-then-definition template is this pattern at the section level.

**Why it's a tell:** This format is a glossary pretending to be prose. It signals that the
content was generated as a list of definitions rather than written as part of a narrative.
Blog posts should flow, not read like a feature matrix.

**Instead:** Integrate the points into the narrative. If a list is genuinely the right
format, use plain bullets without the bold-colon template.
- ✅ "We defined what we were building before the agent started (the spec). We limited
  what it could see (context). We told it what it couldn't do (guardrails). Three files.
  That's it."
