# AI Writing Anti-Patterns

These are hard rules. If you catch yourself writing any of these patterns, rewrite.
During the anti-pattern check (Phase 3 and Phase 4), scan the draft for every pattern
listed here. Zero tolerance.

## Running the check

The anti-pattern check is a defined procedure, not a vibe check. Three rules govern it:

**Always re-read this file before running the check.** Use the definitions below —
specific patterns, symptoms, examples, structural variants, and alternatives — not your
general knowledge of AI writing patterns.

**Follow the three-pass procedure exactly as written in `skills/blog-writer/references/process.md`.** Pass 1
is the surface scan against every pattern in this file. Pass 2 is the skeleton scan on adjacent
sentence pairs. Pass 3 is the soul check — a holistic read for sterile, voiceless writing
that passes pattern checks but still reads as AI. Then the rewrite audit. Then the voice
check. Then the proportionality check — was the amount of rewriting proportional to the
slop found, and would the author still recognize the draft as their own voice. In that
order. Do not skip passes, do not merge them, do not substitute your own method.

**Do not invent patterns that aren't in this file.** If something feels "AI-ish" but
doesn't match a pattern defined here or one of its structural variants, leave it alone.
False positives from improvised rules damage the author's voice more than the pattern
they're trying to fix.

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
- "X rather than Y" — the same contrast wearing a comparative. "The agent inherits the
  developer's permissions rather than the automation account's." Reads as measured prose,
  but it is still negation-then-affirmation with "rather than" doing the work of "not."
  The hardest of the three to catch by eye: "Not X. Y." announces itself, while this one
  survives a read precisely because it does not sound like a mic drop. It also fronts:
  "Rather than the automation account's, the agent inherits the developer's permissions."
  Catch it mechanically: any "rather than" joining two candidates for the same slot,
  searched case-insensitively so the sentence-initial form doesn't slip through.
- "No tests, no guardrails." / "No spec, no safety net." — Negative parallelism. Two
  "no [noun]" phrases mirrored for dramatic effect. Same mechanism as "Not X. Y." but
  using symmetrical negation instead of negation-then-affirmation.
- "No monitoring, no alerting, no idea what's happening in production." — Extended
  negative parallelism building to a kicker. Overlaps with pattern #3 (tricolon).
- "I wasn't measuring the plugin. I was measuring the judge's reading comprehension." —
  Confession-as-negation. The most dangerous variant because it disguises contrastive
  negation as self-deprecating narration. "I wasn't doing X. I was doing Y." feels like
  a genuine admission, which makes it pattern-match to the voice profile's
  confession-as-thesis device during review. It's still "Not X. Y." — the confession
  doesn't change the structure. Catch it mechanically: any "I wasn't [verb]. I was [verb]."
  or "I wasn't measuring X. I was measuring Y." is this pattern regardless of tone.

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
- **Dense-paragraph tricolon:** Three examples buried in a long paragraph, each following
  the same grammatical skeleton (e.g., "[problem] — fix went into [location]"). The length
  and density of the paragraph disguises the repetition, but the skeleton is identical across
  all three items. Especially suspect when followed by a neat summary like "Three bugs, three
  different parts" that announces the manufactured symmetry.
- **Thematic number echo:** When the post's topic already involves a specific number (e.g.,
  three tiers, three layers), the LLM will manufacture tricolons to echo it. The content
  showing three examples is fine; a sentence announcing "Three X, three Y" on top of that
  is the pattern.

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
- **Examples-after-a-colon trap:** "AI is good at local problems. Buffer overflows. Missing
  null checks. SQL injection." — The colon or introductory sentence makes the fragments
  *feel* like an embedded list, but each one has its own period, making it a fragment chain.
  If the items are period-terminated, they're fragments regardless of what precedes them.
  The fix is a comma-separated list inside a single sentence: "...local problems -- buffer
  overflows, missing null checks, SQL injection in a query builder."

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
- **The colon reveal** — the same setup/punchline couplet with a colon instead of a
  question mark. "The best part: it learns." "The result: a cleaner architecture." "The
  detail that makes it work: a separate agent grades it." A noun phrase, a colon, then a
  dramatic reveal. No question mark anywhere, but structurally identical: fake tension,
  then the payoff. Colons are for lists, labels, and quotes — not for drama. Rewrite as a
  plain sentence: "A separate agent does the grading, and that's what makes it work."

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

**Structural variants — casual filler hedges:**
- "basically" — adds nothing, signals the writer is about to oversimplify
- "essentially" — same as "basically" in a blazer
- "in order to" — always replaceable with "to"
- "it turns out" / "it turns out that" — false surprise, especially when the thing that
  "turned out" was the whole point of the investigation
- "just" (as minimizer) — "we just added an allowlist" downplays what might be the key fix

These are subtler than the formal hedges above but equally empty. They pad sentences
without adding meaning.

**Structural variants — introductory filler words:**

These words serve as verbal scaffolding — they helped the writer organize their thoughts
while drafting, but in the final text they add zero information. They're the written
equivalent of "um" and "so" in speech. Each one can almost always be deleted without
changing the meaning. When they can't be deleted (rare), they're doing real work — marking
a genuine contrast, a genuine concession, or a genuine sequence.

The watchlist (delete unless doing real grammatical work):
- **False-emphasis openers:** "of course", "naturally", "obviously", "clearly", "certainly",
  "indeed", "in fact", "as a matter of fact", "needless to say"
- **False-concession openers:** "to be honest", "honestly", "frankly", "admittedly",
  "truth be told"
- **False-structure markers:** "first of all", "on another note", "on a related note",
  "speaking of which", "that said", "with that in mind", "that being said"
- **Padding connectors:** "additionally", "furthermore", "moreover" (when they connect two
  points that don't need a connector — the paragraph break does it), "also" (at sentence
  start as filler), "in addition to this"
- **Downtoners:** "somewhat", "rather", "quite", "fairly", "pretty much" — these soften
  claims that should either be stated directly or supported with evidence
- **Empty framing phrases:** "at the end of the day", "when it comes to", "at its core",
  "the reality is", "the truth is", "in terms of", "with regard to" — multi-word wrappers
  that delay the point. "When it comes to testing, coverage matters" is "Test coverage
  matters" with a warm-up lap. "The reality is" and "the truth is" imply everything else
  you wrote was neither.

**The delete test:** remove the filler word and re-read the sentence. If the meaning is
identical, the word was scaffolding. If the sentence now reads as too abrupt or loses a
genuine logical connection, the word was earning its place — keep it.

**Why it's a tell:** These are throat-clearing. They signal the writer isn't confident
enough to just make the point. LLMs insert them as politeness padding. The didactic
variants are worse — they talk down to the reader, implying they need to be told what's
important. The casual filler hedges are sneakier — they sound conversational but still
add zero information. The introductory fillers are sneakiest of all — they sound like
natural English transitions but in aggregate they bloat the text with empty calories,
one per sentence, until the reader feels like they're wading through cotton.

**Instead:** Delete the hedge and start with the actual point. If it's important, the
reader will know because you showed them why, not because you announced it. For casual
fillers: delete the word and re-read the sentence. If it still works (it will), leave it
out.

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
"align with", "resonate with", "exemplify", "encompass", "embark" (on a journey/effort),
"elevate" (figurative: "elevate your workflow")

Pretentious-for-no-reason verbs (use the plain alternative): "utilize" (use), "leverage"
(use), "facilitate" (help, enable), "demonstrate" (show), "implement" (build, add, write —
when the verb is vague filler, not a technical term), "optimize" (improve, speed up, shrink —
when vague), "indicate" (show, mean), "enable the creation of" (let you create)

Nouns: "tapestry", "landscape" (abstract), "realm", "journey" (abstract), "ecosystem",
"paradigm", "trajectory", "blueprint", "interplay", "intricacies", "testament", "beacon",
"focal point", "commitment" (abstract), "diverse array", "game changer"

Pretentious-for-no-reason nouns: "functionality" (feature), "methodology" (method, approach),
"utilization" (use), "implementation" (when used as a noun to avoid a verb: "the
implementation of X" → "we built X")

Adjectives: "pivotal", "crucial", "vital", "paramount", "nuanced", "multifaceted", "robust", "seamless",
"comprehensive", "cutting-edge", "groundbreaking", "transformative", "enduring", "vibrant",
"meticulous/meticulously", "renowned", "nestled", "profound", "rich" (figurative: "rich
history", "rich cultural heritage"), "key" (as adjective: "key role", "key turning point"),
"valuable" ("valuable insights")

Inflation phrases: "plays a significant role in shaping", "serves as a testament to",
"it is important to note", "a vibrant tapestry of", "in the heart of", "setting the stage
for", "reflects broader", "deeply rooted", "marks/represents a significant shift",
"evolving landscape", "this is huge", "Additionally," (as sentence opener — research-backed
strong tell)

**Why it's a tell:** Research tracking word frequency before and after ChatGPT shows
"delve" spiked 10-50x, "tapestry" and "landscape" (abstract) 5-20x, and "plays a
significant role in shaping" appeared 207x more often in AI text. Readers have learned
to pattern-match on these words even if they can't articulate why.

**Instead:** Use plain words. "Delve into" → "look at." "Leverage" → "use."
"Navigate the landscape" → "figure out." "Pivotal" → "important" (or better: show
why it matters instead of asserting it). "Nuanced" → "detailed" or just describe the
actual nuance. "Utilize" → "use." "Facilitate" → "help." "Methodology" → "method."
"Functionality" → "feature." "Prior to" → "before." "In order to" → "to."
"Subsequent" → "next."

The test for pretentious vocabulary: replace the fancy word with the plain one. If nothing
is lost, it was showing off. If the fancy word carries a precise technical nuance the plain
word lacks, keep it — but only if you're sure the reader needs that nuance.

One of these words in a 2,000-word post is fine. Three in a paragraph is a contamination
event. Scan for them.

---

## 13. Copula Avoidance and Nominal Style

**The tell:** LLMs avoid simple "is", "are", and "has" constructions, substituting
elaborate verbs that inflate the significance of mundane statements. They also hide
actions behind verbal nouns (nominal style), turning verbs into -tion/-ment/-ance nouns
that require filler verbs to function.

**Symptoms:**
- "serves as" / "stands as" / "acts as" instead of "is"
- "boasts" / "features" / "offers" instead of "has"
- "represents" / "marks" / "signals" instead of "is"
- "underscores" / "highlights" / "reflects" instead of "shows"
- "the implementation of X" instead of "we implemented X"
- "perform an evaluation" instead of "evaluate"
- "provides support for" instead of "supports"

**Examples:**
- ❌ "This feature serves as a bridge between the developer and the runtime."
- ❌ "The config file stands as the single source of truth."
- ❌ "The dashboard boasts a real-time monitoring panel."
- ❌ "The utilization of the API requires careful consideration."
- ❌ "We conducted an analysis of the failure modes."
- ❌ "The execution of the pipeline enables the generation of artifacts."

**Structural variants:**
The inflated verb doesn't always replace "is" — it can replace any simple verb.
- "provides" / "delivers" / "enables" instead of "has" or "lets you"
- "This approach empowers developers to..." instead of "This lets developers..."
- "The framework facilitates seamless integration" instead of "The framework connects to..."
- Any verb that makes a mundane statement sound like a press release.

Nominal style has its own variants:
- A noun ending in -tion/-ment/-ance/-ence + a supporting verb (perform, conduct, provide,
  ensure, enable, carry out) is almost always a verb hiding behind a noun. Replace the whole
  construction with the verb it's hiding.
- "The deployment of the service was completed" → "We deployed the service."
- Passive voice compounds the problem: "An investigation was conducted" → "We investigated."
  The noun hides the action; the passive hides the actor. Fix both.

**Why it's a tell:** These substitutions make everything sound ceremonial. A config
file doesn't "stand as" anything. It IS the source of truth. The inflated verb implies
the sentence is making a grander point than it actually is. Nominal style does the same
thing in reverse — it drains the action from a sentence, making it read like a government
memo. Active verbs create motion in the reader's head. Nouns create still lifes.

**Instead:** Use "is", "are", "has." They're not boring — they're precise. And use verbs
for actions — they're not informal, they're alive.
- ✅ "This feature connects the developer to the runtime."
- ✅ "The config file is the source of truth."
- ✅ "The dashboard has a real-time monitoring panel."
- ✅ "We used the API." (not "the utilization of the API")
- ✅ "We analyzed the failure modes." (not "conducted an analysis of")
- ✅ "The pipeline runs and produces artifacts." (not "the execution enables the generation")

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
- ❌ "Developers can install the plugin. Engineers who need customization can fork it.
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

**How to check:** After writing, build a term inventory: list every noun phrase used for
each core concept in the post. Example inventory:
- The export job: "the pipeline", "the export job", "the batch process" ← PICK ONE
- The database: "Postgres", "the database", "the data store" ← PICK ONE

If any concept has more than one name, replace all variants with the most precise term.
Do this as an explicit pass — read the draft looking ONLY for this. Cross-section synonym
cycling (one term in the Problem section, a different one in the Fix section) is the most
common miss because each section reads fine in isolation.

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
- **Editorial superlatives:** "The most underrated announcement," "The most important shift
  this year," "The most predictable turn in AI history." The superlative form is significance
  inflation cranked to maximum — it doesn't just assert importance, it asserts MOST importance.
  Let the content prove the claim; don't announce the ranking.

**Why it's a tell:** LLMs inflate significance because they pattern-match on authoritative
encyclopedia prose. A version bump is not a pivotal moment. A migration is not a
significant shift. These phrases are significance-assertions without evidence — the
written equivalent of an applause sign.

**Instead:** Show the impact with specifics. Let the reader decide if it's significant.
- ✅ "The v2.0 release cut the config file from 200 lines to 12."
- ✅ "After the migration, deploys went from 45 minutes to 90 seconds."

**The repair is not to tone it down — it's to replace the evaluation with the fact that
earns it.** When you catch a significance-inflated sentence, ask: "What fact would make
the reader reach this conclusion on their own?" Write that fact. Don't write
"groundbreaking performance improvements" — write "p95 latency dropped from 800ms to 12ms."
Don't write "a revolutionary approach to testing" — write "we deleted 6,000 lines of mocks
and the test suite got faster."

The strongest evaluations are the ones the reader makes themselves. Give them the evidence.
Never give them the verdict.

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
- **Standalone positive conclusions** — the optimism half of the sandwich without the
  challenge preamble. "The future looks bright." "Exciting times lie ahead." "This is just
  the beginning of the journey toward excellence." These can appear as the last sentence of
  a post, a section closer, or a TLDR bullet. The tell is vague optimism that asserts a
  bright future without naming a single specific thing that will happen.
- "As [tool/approach] continues to evolve, it will reshape how we think about [topic]." —
  forward-looking vagueness masquerading as a conclusion.

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

---

## 23. Performed Credentialism

**The tell:** Inserting unnecessary technical specificity to sound authoritative. The
jargon depth exceeds what the surrounding context requires — the writer is performing
expertise rather than communicating.

**Symptoms:**
- Naming protocols, algorithms, or internal engine components that are irrelevant to
  the point being made
- Qualifying simple concepts with their formal computer-science terminology
- Dropping implementation details from a layer below the one the post operates at
- Technical precision that impresses but doesn't inform

**Examples:**
- ❌ "Utilizing the WebSocket protocol's full-duplex communication channel" when the
  post is about a chat feature (just say "using WebSockets")
- ❌ "Leveraging V8's TurboFan JIT compilation pipeline" in a post about Node.js
  deployment workflows
- ❌ "The garbage collector's concurrent mark-sweep phase" in a post about reducing
  memory usage (just say "the GC")
- ❌ "Employing a declarative, idempotent infrastructure-as-code paradigm" instead of
  "using Terraform"

**Structural variants:**
The credentialism doesn't have to be jargon — it can be unnecessary precision in any form.
- "The 200 OK HTTP response status code indicates..." — specifying the status code number
  AND its name AND that it's HTTP, when context makes all three obvious.
- "We observed a 47.3% reduction in p99 latency" in a post where the actual number doesn't
  matter and "latency dropped by half" would serve the story better.
- Parenthetical specifications that nobody asked for: "the container orchestrator
  (Kubernetes, specifically the kube-scheduler component)" — each layer of specificity
  adds precision that the reader doesn't need and didn't request.

**Why it's a tell:** LLMs over-specify because their training data rewards technical
precision. A human writer matches depth to context — you say "WebSockets" in a blog post
about chat features and "the WebSocket protocol's frame-masking mechanism" in a post about
WebSocket security. The LLM doesn't adjust; it defaults to maximum specificity because
that's what gets rewarded in training data (Stack Overflow answers, documentation,
textbooks). The result reads like someone trying to pass a job interview, not someone
explaining something to a peer.

**Instead:** Match precision to purpose. Name the technology at the level your reader
needs. If the post is about deployment, "WebSockets" is enough. If the post is about
WebSocket internals, then name the internals.
- ✅ "We switched to WebSockets and the UI stopped polling every 500ms."
- ✅ "Latency dropped by half."
- ✅ "We use Terraform."

---

## 24. "Did Nothing" Constructions

**The tell:** Using "did nothing" or "did little" as a formal negation where a native
speaker would use idiomatic alternatives. The phrasing is grammatically correct but
stilted.

**Symptoms:**
- "X did nothing to address Y"
- "X did nothing to resolve the issue"
- "The change did little to improve performance"
- "This approach did nothing for reliability"

**Examples:**
- ❌ "The migration did nothing to resolve the latency issues."
- ❌ "Adding more replicas did nothing to improve throughput."
- ❌ "The refactor did little to address the underlying problem."

**Structural variants:**
The stilted negation extends beyond "did nothing."
- "failed to yield any improvement" — formal negation of a formal positive
- "proved insufficient to address" — bureaucratic hedging
- "did not succeed in resolving" — passive circumlocution around "didn't fix"

**Why it's a tell:** Native speakers in casual technical writing say "didn't help,"
"didn't fix it," "made no difference," or just "still broken." The "did nothing to
[verb]" construction reads like a formal report or a translated text. It's not wrong —
it's just not how practitioners talk about things that didn't work.

**Instead:** Use idiomatic negation.
- ✅ "The migration didn't fix the latency."
- ✅ "More replicas didn't help."
- ✅ "Still broken after the refactor."

---

## 25. Vague Attributions

**The tell:** Citing unnamed "experts," "reports," or "observers" to lend authority to a
claim without naming an actual source.

**Symptoms:**
- "Experts argue that..."
- "Industry reports suggest..."
- "Observers have noted..."
- "Many developers believe..."
- "Studies have shown..."
- "According to recent research..."

**Examples:**
- ❌ "Experts argue that this approach will dominate the next decade of software development."
- ❌ "Industry reports suggest adoption has tripled year over year."
- ❌ "Many seasoned engineers have noted the shift toward this paradigm."

**Structural variants:**
The attribution doesn't have to be at the start of the sentence.
- "...a trend that analysts have widely recognized." — vague attribution buried at the end.
- "The community has largely embraced..." — "the community" is a weasel-word collective
  standing in for unnamed individuals.
- "It's widely accepted that..." / "It's generally understood that..." — passive-voice
  attributions to nobody in particular.

**Why it's a tell:** LLMs can't cite real sources, so they invent authoritative-sounding
collectives. A human writer either names the source ("Kelsey Hightower said on stage at
KubeCon...") or makes the claim on their own authority ("I think this approach wins").
The vague attribution is a confidence trick — it borrows credibility from a source that
doesn't exist.

**Instead:** Name the actual source, or own the opinion yourself.
- ✅ "ThoughtWorks put it on their 'Adopt' ring in the last Technology Radar."
- ✅ "I've seen three teams adopt this in the last year, and two of them stuck with it."

---

## 26. Boldface Overuse

**The tell:** Mechanical bolding of key terms throughout prose paragraphs, as if the text
is a study guide or a sales page highlighting features.

**Symptoms:**
- Multiple `**bolded terms**` per paragraph in body prose (not headings, not code)
- Every new concept gets bolded on first mention like a textbook definition
- Bold used for emphasis on words that don't need it: "This is **really** important"
- The bolding pattern is uniform — every Nth sentence has a bold term

**Examples:**
- ❌ "The **spec-driven approach** ensures that the **agent** operates within **guardrails**,
  producing **deterministic output** that matches the **developer's intent**."
- ❌ "We used **Tessl** to define the **skill**, added **rules** for the **context window**,
  and deployed the **plugin** to production."

**Structural variants:**
- Italics used the same way — `*every concept*` gets emphasized on first appearance.
- Bold-colon inline headers outside of lists: "**The key insight:** we needed to..." in
  the middle of a flowing paragraph.
- Bold used on every instance of a term, not just first mention — the page looks like it
  was attacked by a highlighter.

**Why it's a tell:** LLMs bold terms to signal "this is important" because they can't
achieve emphasis through sentence structure or narrative position. A human writer makes
something important by where they put it in the story and how they set it up, not by
formatting it in bold. When everything is emphasized, nothing is.

**Instead:** Remove the bold from prose. If a term needs emphasis, earn it through the
sentence around it. Reserve bold for actual structural elements: headings, the occasional
single-word emphasis where the reader genuinely needs a visual anchor.
- ✅ "The spec-driven approach keeps the agent inside guardrails. The output is
  deterministic — it matches what you asked for."

---

## 27. Title Case Headings

**The tell:** Headings where Every Significant Word Is Capitalized, like a book title or
a news headline.

**Symptoms:**
- "## Strategic Negotiations And Global Partnerships"
- "## How We Built The New Pipeline"
- "## Key Takeaways From The Migration"

**Why it's a tell:** Blog posts use sentence case ("How we built the new pipeline"). Title
case is the default for LLMs because their training data includes a disproportionate amount
of formal titles, academic papers, and news headlines. It's a small tell but an easy one to
catch — and it stacks with other tells to create an overall "AI-generated" impression.

**Instead:** Sentence case for all headings. Capitalize only the first word and proper nouns.
- ✅ "## How we built the new pipeline"
- ✅ "## Key takeaways from the migration"

---

## 28. Labeling the Device

**The tell:** Announcing the rhetorical move you're about to make instead of just making it.
Naming irony, beauty, paradox, or a pattern before executing it.

**Symptoms:**
- "The irony?" / "The irony is that..."
- "The beauty of it is..."
- "The paradox here is..."
- "Compound effect." / "That's the scale."
- "Here's the kicker:"
- "The punchline:" / "Plot twist:"

**Examples:**
- ❌ "The irony? Anthropic brands itself as safety-first, but reliability is safety tier zero."
- ❌ "Post 1: 12 corrections. Post 5: three. Compound effect."
- ❌ "The beauty of it is that the whole thing fits in a single file."

**Structural variants:**
The label doesn't have to be a standalone sentence.
- "There's a certain irony in the fact that..." — buried in a clause instead of a standalone
  fragment, but still labeling.
- "Which brings us to the paradox at the heart of this approach..." — transition that labels
  the device while pretending to introduce it.
- Naming an emotion the reader should feel: "The surprising part is..." — if it's really
  surprising, the reader will be surprised without the label.

**Why it's a tell:** When you label a rhetorical device, you kill it. "The irony?" warns the
reader that irony is coming, so they process it analytically instead of feeling it. A human
writer trusts the device to land on its own. LLMs label devices because they're constructing
rhetoric from a template — "insert ironic observation here" — and the label is the template
leaking through.

**Instead:** Delete the label. Let the device do its own work.
- ✅ "Anthropic brands itself as safety-first, but their API was down for six hours last
  Tuesday."
- ✅ "Post 1: 12 corrections. Post 5: three."
- ✅ "The whole thing fits in a single file."

---

## 29. Restating the Proven Point

**The tell:** A concluding paragraph that summarizes what the narrative already demonstrated.
The story proved the point, and then a paragraph explains what the reader just read.

**Symptoms:**
- A paragraph at the end of a section starting with "The key takeaway:", "The main lesson:",
  "What this shows is...", "In other words..."
- A summary sentence that could be deleted without the reader losing any information
- The concluding paragraph says the same thing as the preceding narrative but in abstract terms

**Examples:**
- ❌ "We added input validation. The error rate dropped from twelve per hour to zero.
  [paragraph break] The key takeaway: input validation matters."
- ❌ "Three teams adopted the framework. Two shipped faster. One abandoned it after a week.
  [paragraph break] What this shows is that the framework works for most teams but isn't
  universal."

**Structural variants:**
The restatement doesn't have to be labeled with "key takeaway."
- "In short, the migration paid off." — after two paragraphs that already showed it paying
  off with specific metrics.
- "All of this goes to show that..." — burying the restatement in a transition to the next
  section.
- A TLDR bullet that restates a section's narrative instead of provoking curiosity is this
  pattern at the post level.

**Why it's a tell:** This is the tail-end mirror of #9 (Preamble Announcements). Where #9
announces what the post is about to say, this pattern announces what the post just said.
LLMs do it because they're trained on explanatory text (textbooks, documentation) where
summaries serve a pedagogical purpose. In a blog post, the reader doesn't need a teacher
restating the lesson — they just lived through the story.

**Instead:** End on the strongest moment in the narrative. If the data or story proves the
point, stop. Trust the reader to connect the dots.
- ✅ "We added input validation. The error rate dropped from twelve per hour to zero."
  (End. Done. The reader gets it.)

---

## 30. Telegraphing Transitions

**The tell:** Announcing that something important is about to be said, instead of just
saying it. Mid-post preamble announcements that create artificial suspense.

**Symptoms:**
- "But here's the thing:"
- "Here's what I mean:"
- "And here's the most interesting part:"
- "Now, here's where it gets interesting:"
- "This is where things get tricky:"
- "The important thing to understand is:"

**Examples:**
- ❌ "We migrated to trunk-based development. But here's the thing: the migration wasn't
  the hard part."
- ❌ "The agent handled most of the work. And here's the most interesting part: it caught
  a bug we'd missed for months."

**Structural variants:**
The telegraph can be subtle.
- "What's worth paying attention to here is..." — politely announcing importance instead of
  demonstrating it.
- "The part that really matters is..." — same move with different words.
- "This next part is crucial:" — labeling the importance of what follows rather than letting
  the content earn its own weight.
- **Faux-insight setups:** "What nobody tells you...", "The part everyone misses...",
  "What most people get wrong...", "Here's what they don't want you to know...". Same
  telegraph, plus an extra move: it flatters the writer as the lone expert and the reader
  as the initiated insider. Neither has earned it. "The part everyone misses: distribution
  is the real moat" becomes "Distribution is the moat" — if the claim is genuinely
  non-obvious, the reader will notice without being told everyone else is blind.
- **The Matrix setup:** "What if I told you..." — a rhetorical question that exists only
  to make its own answer sound revelatory. Delete the setup, state the claim.
- Any sentence that could be deleted while leaving the following sentence perfectly intact is
  this pattern.

**Why it's a tell:** These are the mid-post cousins of #9 (Preamble Announcements). LLMs
insert them because they model writing as a sequence of importance signals followed by content.
A human writer makes something important by WHAT they say, not by announcing that importance
is coming. The telegraph is an empty calorie — it takes up space without adding meaning, and
it trains the reader to ignore your emphasis because you emphasize everything.

**Instead:** Delete the telegraph and start with the content.
- ✅ "We migrated to trunk-based development. The migration wasn't the hard part."
- ✅ "The agent handled most of the work. It caught a bug we'd missed for months."

---

## 31. Incomplete Assertions

**The tell:** A sentence that sounds conclusive but says nothing specific. It asserts that
something is clear, significant, or important without naming what it actually is.

**Symptoms:**
- "The direction is clear."
- "The implications are significant."
- "The impact cannot be overstated."
- "This changes everything."
- "The writing is on the wall."
- "The takeaway is obvious."

**Examples:**
- ❌ "The direction is clear." (What direction? Clear to whom?)
- ❌ "The implications for the industry are significant." (Name one.)
- ❌ "This fundamentally changes the game." (How? For whom?)

**Structural variants:**
The assertion can be dressed up with specificity that doesn't actually specify.
- "The future of developer tooling will never be the same." — sounds specific (developer
  tooling) but says nothing about HOW it will be different.
- "These results speak for themselves." — sounds confident but is actually an abdication;
  the writer's job is to speak for the results.
- "The numbers tell the story." — close cousin of "speak for themselves." If the numbers
  tell a story, tell the reader which story.

**Why it's a tell:** LLMs generate these because they're trained on persuasive text that
asserts conclusions. But the assertion is a placeholder — the model knows a conclusion
belongs here but doesn't have a specific one. A human writer knows what the direction is
and says it: "Everything will run on tokens within three years." An LLM says "The direction
is clear" and moves on.

**Instead:** Say the specific thing, or delete the sentence entirely.
- ✅ "Everything will run on tokens within three years."
- ✅ "Deploy times dropped 80%. The migration was worth it."
- Or just delete the sentence — if the evidence is already there, the reader drew the
  conclusion before you did.

---

## 32. Stacked Data Points

**The tell:** Multiple statistics making the same point piled into a single sentence or
passage. Each number restates what the previous one already proved, but from a different
angle.

**Symptoms:**
- Three or more data points in a row that all say "this improved"
- A raw number, a percentage, AND a time/cost savings all describing the same change
- "From X to Y, a Z% improvement, saving N hours per week"
- The second and third numbers don't add new information — they restate the first

**Examples:**
- ❌ "Deploy frequency went from biweekly to daily, a 1,400% improvement, saving roughly
  80 engineering hours per month."
- ❌ "Reduced from 45 minutes to 90 seconds, a 97% improvement, saving 6 hours per week."
- ❌ "Error rate dropped from 12 per hour to zero — a 100% reduction that eliminated
  roughly 2,000 false alerts per month."

**Structural variants:**
The stack doesn't have to be in one sentence.
- "Build times dropped from 20 minutes to 3 minutes. That's an 85% reduction. Over a
  month, it saves the team 40 hours." — Three sentences, one fact restated three ways.
- A TLDR bullet with two statistics making the same point is this pattern in compressed
  form.
- Data stacking across a paragraph: the opening sentence states the metric, the middle
  restates it as a percentage, and the closing converts it to business impact. Each sentence
  sounds like it's adding information, but it's the same number in a different costume.

**Why it's a tell:** LLMs stack data points because they pattern-match on "evidence" —
more numbers sounds more convincing. But past the first strong number, each additional
statistic dilutes the impact. "From biweekly to daily" is vivid. "A 1,400% improvement"
restates it abstractly. "Saving 80 engineering hours" restates it a third time in business
terms. The reader gets the point at "biweekly to daily" — the rest is noise.

**Instead:** Pick the one number that hits hardest and cut the rest. Usually that's the
most concrete, human-scale metric — not the percentage.
- ✅ "Deploy frequency went from biweekly to daily."
- ✅ "Build times dropped from 20 minutes to 3."
- If two metrics genuinely add different information (one about speed, one about
  reliability), they can coexist. The test: would a reader learn something NEW from the
  second number that the first didn't already tell them?

---

## 33. Amplifier Intensifiers

**The tell:** Adverbs stacked on top of evaluative adjectives to make claims sound
stronger. "Very", "truly", "really", "incredibly", "extremely", "absolutely",
"remarkably", "exceptionally", "fundamentally" before an adjective or verb.

**Symptoms:**
- Adverb + evaluative adjective where removing the adverb changes nothing
- The amplifier is doing the work the *evidence* should be doing
- Often clustered: "truly remarkable", "incredibly powerful", "extremely efficient"

**Examples:**
- ❌ "This is a truly powerful feature."
- ❌ "The results were incredibly promising."
- ❌ "We were extremely impressed with the performance."
- ❌ "The API is remarkably simple to use."
- ❌ "This fundamentally changes how we think about deployment."

**Structural variants:**
- "Absolutely" before a non-gradable adjective: "absolutely essential", "absolutely
  critical" — redundant by definition (essential is already absolute).
- "Really" as filler intensifier: "It really does simplify the workflow." Remove "really"
  and the sentence is identical.
- "Just" as a false-modesty amplifier: "It just works." Sounds casual but functions as
  an amplifier — it asserts reliability without evidence.
- Amplifiers hiding in verbs: "dramatically improved", "significantly reduced",
  "substantially increased" — the adverb inflates a vague verb instead of letting a
  specific number speak for itself.

**Why it's a tell:** Amplifiers signal that the author is trying to *convince* rather
than *prove*. They're a substitute for evidence. "Very powerful" is weaker than
"handles 10K concurrent connections" because the reader has to take your word for it.
Facts don't need amplifiers. If you need to write "incredibly fast," you haven't found
the number yet.

**Instead:** Replace the amplifier + adjective with the fact that proves the claim.
- ✅ "This feature handles 10K concurrent connections." (not "truly powerful")
- ✅ "Error rate dropped from 12% to 0.3%." (not "incredibly promising")
- ✅ "We shipped it to production that week." (not "extremely impressed")
- ✅ "Three endpoints. No auth dance. Returns JSON." (not "remarkably simple")
- ✅ "Deploy time went from 45 minutes to 90 seconds." (not "dramatically improved")

The test: remove the amplifier. If the sentence means the same thing, the amplifier was
dead weight. If the sentence now feels too weak, the problem isn't the missing amplifier —
it's the missing fact.

---

## 34. Unproven Assessment Adjectives

**The tell:** Evaluative adjectives that assert a quality without providing the fact that
proves it. The adjective does *word work* — it makes the author feel like they've said
something meaningful — but the reader learns nothing they can verify.

**Symptoms:**
- An adjective the reader can't verify from the sentence alone
- The adjective could apply to any product/feature/tool — it's not specific to this one
- Stripping the adjective from the sentence leaves it empty or trivially obvious
- Multiple assessment adjectives stacked: "innovative, robust, and scalable"

**Examples:**
- ❌ "A robust and scalable solution for modern teams."
- ❌ "An elegant API design that developers love."
- ❌ "Comprehensive documentation with everything you need."
- ❌ "Our innovative approach to CI/CD pipelines."
- ❌ "A seamless developer experience from start to finish."

**Structural variants:**
- Assessment adjective + vague noun: "quality content", "effective solution",
  "powerful platform" — the noun is as empty as the adjective.
- Adjective chains that substitute for research: "fast, reliable, and easy to use" —
  three unsupported claims in a row. Each one should be a fact.
- Assessment buried in a relative clause: "the framework, which provides a seamless
  experience, also supports..." — the assessment hides inside a clause to look like
  incidental description.
- Assessment as assumed context: "Given the robust architecture..." — the adjective is
  presented as a premise rather than a claim, so it never gets questioned.

**The false-work test:** Strip all evaluative adjectives from the paragraph. Read what's
left. If the skeleton is empty — "A solution for teams," "An API design," "Documentation"
— the paragraph needs *research*, not better adjectives. The author did *word work* instead
of finding the facts that would make the reader reach the conclusion on their own.

**Why it's a tell:** LLMs reach for assessment adjectives because they pattern-match on
marketing copy and product descriptions. They've learned that "innovative" sounds like
praise, but they can't provide the evidence because they don't have it. Human writers
who know their subject lead with the evidence and let the adjective become unnecessary.

**Instead:** Replace each adjective with the specific fact that earns it.
- ✅ "Handles 50K RPS on a single node. Add nodes to grow linearly." (not "robust and scalable")
- ✅ "Three endpoints. No auth dance. Returns JSON." (not "elegant API")
- ✅ "400 pages. Every method has a runnable example." (not "comprehensive documentation")
- ✅ "We deleted the Jenkinsfile and replaced it with 12 lines of YAML." (not "innovative approach")
- ✅ "Install, run one command, deploy. No config file." (not "seamless experience")

Any evaluative adjective that the reader has to take on faith is this pattern. If you can't
immediately follow the adjective with the evidence, delete the adjective and go find the
evidence.

---

## 35. Temporal Filler (Time Parasites)

**The tell:** Phrases that assert present-tense relevance when present tense is already
the default. The reader assumes everything you write is current unless you say otherwise —
so "in today's world" adds zero information.

**Symptoms:**
- Sentence opens with a temporal phrase asserting "now" or "currently"
- The temporal phrase can be deleted without changing the meaning
- Often paired with a vague noun: "landscape," "era," "world," "climate"
- Used to make a mundane observation sound urgent

**The watchlist:**

Opening phrases (delete entirely): "In today's [anything]", "In the current [anything]",
"Now more than ever", "In this day and age", "In the modern era", "As we move into [year]",
"In an increasingly [adjective] world", "In the age of [technology]", "As [technology]
continues to evolve", "In the rapidly evolving landscape of", "At a time when",
"In the ever-changing world of"

Urgency filler (delete or replace with data): "today" (when not contrasting with a specific
past), "currently" (when not contrasting with a planned future state), "nowadays", "these
days", "at this point in time", "going forward"

**Examples:**
- ❌ "In today's rapidly evolving tech landscape, developers need better tools."
- ❌ "Now more than ever, observability matters."
- ❌ "In the age of AI, testing is critical."
- ❌ "As cloud-native architectures continue to evolve, teams face new challenges."
- ❌ "In an increasingly distributed world, latency is king."

**Structural variants:**
- Mid-sentence insertion: "Developers, in today's fast-paced environment, need..." — same
  parasite, different position.
- Pseudo-contrast with no actual past: "Today, teams deploy hundreds of times a day." — If
  you're not explicitly comparing to a specific past state, "today" is filler.
- Compound temporal + significance: "In today's landscape, it's more important than ever
  to..." — combines temporal filler (#35) with significance inflation (#20). Double flag.

**Why it's a tell:** LLMs front-load temporal phrases to create a sense of urgency and
relevance. Human writers writing about current technology don't need to remind the reader
it's current — the context makes that obvious. The temporal phrase is a crutch: it lets
the writer skip the work of explaining *why* the topic matters by asserting that it matters
because it's happening *now*. The book "Пиши, сокращай" calls these "паразиты времени"
(time parasites) — they pollute the sentence with meaningless information.

**Instead:** Delete the temporal phrase. If the sentence collapses without it, the sentence
had no real content — replace it with a specific fact that earns the reader's attention.
- ✅ "Developers spend 40% of their time context-switching between tools." (not "In today's
  rapidly evolving tech landscape, developers need better tools.")
- ✅ "When your p99 latency hits 2 seconds, users leave." (not "Now more than ever,
  observability matters.")
- ✅ "LLMs generate plausible code that passes linting and fails in production." (not "In
  the age of AI, testing is critical.")

If you ARE contrasting with a specific past state, the temporal marker is earned:
- ✅ "Five years ago, deploying meant a weekend maintenance window. Now it's a git push."
  — "Now" contrasts with "five years ago." The temporal phrase does work.

---

## 36. Corporate Cliché Phrases

**The tell:** Multi-word phrases borrowed from corporate marketing and "About Us" pages.
Each individual word might pass a vocabulary check, but the phrase as a whole is an empty
calorie — it says something that any company could say about any product.

**Symptoms:**
- The phrase could describe any competitor's product without changing a word
- It asserts a quality ("passionate," "trusted," "comprehensive") without evidence
- It addresses no specific reader need — it's written to impress, not to inform
- Multiple cliché phrases cluster together, reinforcing each other's emptiness

**The watchlist:**

Team/company phrases: "passionate team of engineers", "team of like-minded professionals",
"dedicated team", "world-class engineers", "our talented team", "driven by innovation"

Product phrases: "end-to-end solution", "one-stop shop", "best-in-class", "industry-leading",
"enterprise-grade", "production-ready" (when not followed by what that means), "battle-tested"
(without the battle), "turnkey solution", "out-of-the-box"

Relationship phrases: "trusted by industry leaders", "trusted partner", "your success is our
success", "we're committed to [vague noun]", "empowering developers to", "enabling teams to"

Value phrases: "solve your business problems", "drive business value", "accelerate your
digital transformation", "unlock the full potential of", "take your [X] to the next level",
"supercharge your workflow"

**Examples:**
- ❌ "Our passionate team of engineers built an end-to-end solution for modern development teams."
- ❌ "Trusted by industry leaders, our platform empowers developers to ship faster."
- ❌ "We're committed to helping teams unlock the full potential of their CI/CD pipelines."
- ❌ "A best-in-class, enterprise-grade platform that drives real business value."

**Structural variants:**
- Cliché-as-aside: "The tool — trusted by thousands of developers — integrates with..." —
  corporate cliché hiding inside em-dashes.
- Testimonial framing: "Teams love our solution because it's production-ready and
  battle-tested." — The cliché phrases masquerade as user sentiment.
- Cliché chain: when 2+ corporate phrases appear in the same sentence, the sentence is
  almost certainly empty. "Our world-class team built an industry-leading, enterprise-grade
  platform" is four clichés in one sentence and says nothing.

**The interchangeability test:** Replace the product/company name with a competitor's. If the
sentence still works perfectly, it's a corporate cliché. "Acme's passionate team built an
end-to-end solution" → "Globex's passionate team built an end-to-end solution." Nothing
changed. The sentence was about no one.

**Why it's a tell:** LLMs train on corporate websites, marketing copy, and landing pages.
These phrases are statistically dominant in that corpus. When an LLM describes a product,
it defaults to the vocabulary of product marketing because that's what it's seen most. Human
writers with actual experience describe what the product *does*, not what category of praise
it belongs to.

**Instead:** Replace the phrase with the specific fact it's hiding behind.
- ✅ "Four engineers built it over six months. Two of them had shipped container runtimes
  before." (not "our passionate team of engineers")
- ✅ "Covers build, test, deploy, and rollback — one config file, no glue scripts." (not
  "end-to-end solution")
- ✅ "Stripe and Shopify run their deploy pipelines on it." (not "trusted by industry leaders")
- ✅ "Cut our deploy time from 45 minutes to 90 seconds." (not "drives real business value")

One corporate cliché in a 2,000-word post is a yellow flag. Two or more in the same
paragraph is a contamination event — the paragraph needs to be rewritten with facts.

---

## 37. Euphemistic Smoothing

**The tell:** Softening uncomfortable truths with padded, indirect language. Instead of
saying what happened, the writer wraps it in a cushion of formal or abstract phrasing
that reduces the reader's ability to understand the actual situation.

**Symptoms:**
- A negative event is described without any sharp edges
- The sentence uses more words than a plain description would
- Removing the euphemism reveals a simpler, more honest statement
- The writer seems to be protecting someone (the product, the team, themselves) from
  looking bad

**Examples:**
- ❌ "We encountered some challenges during the migration." → It broke.
- ❌ "Performance was suboptimal under load." → It was slow.
- ❌ "The initial results were not entirely aligned with expectations." → It gave wrong answers.
- ❌ "There were some issues with data consistency." → We lost data.
- ❌ "The deployment process presented some complexity." → Deploys kept failing.
- ❌ "The team had to make some adjustments to the timeline." → We missed the deadline.

**Structural variants:**
- Passive euphemism: "Errors were encountered" — hides both the actor and the severity.
  Who encountered them? How bad were they? The passive + euphemism combo conceals everything.
- Hedge-wrapped euphemism: "There were arguably some minor inconsistencies in the output."
  — hedging (#10) + euphemism together. The sentence has four layers of padding around
  "the output was wrong."
- Euphemism-as-positive-spin: "This gave us an opportunity to revisit our approach." — The
  "opportunity" was a failure. Say so.
- Technical euphemism: "The system exhibited non-deterministic behavior" — it crashed
  randomly. Technical vocabulary used not for precision but to soften the blow.
- Euphemistic smoothing of others' failures: "The vendor's solution didn't fully meet our
  requirements" — when the vendor's product was broken and you switched away. Being polite
  is fine; being so smooth the reader can't tell what happened is not.

**Why it's a tell:** LLMs are trained with RLHF to be diplomatic and non-confrontational.
They default to softening negative events because their training rewards inoffensive output.
But blog posts — especially technical ones — earn trust through honesty. When you describe
a failure, the reader wants to know what actually happened so they can avoid it. Smoothing
the failure robs them of that knowledge. The book "Пиши, сокращай" calls this "сглаженные
углы" (smoothed corners) — language designed to hide inconvenient truths rather than
communicate them.

**Instead:** Say what happened. Use plain, specific language. If it broke, say it broke.
If it was slow, say how slow. The reader respects honesty more than polish.
- ✅ "The migration broke three production tables. We rolled back at 2 AM." (not "encountered
  some challenges")
- ✅ "Response time hit 12 seconds under load. Users saw timeout errors." (not "suboptimal
  performance")
- ✅ "It hallucinated API endpoints that don't exist." (not "results were not entirely aligned
  with expectations")
- ✅ "We lost two hours of transaction data." (not "issues with data consistency")
- ✅ "We missed the deadline by three weeks." (not "adjustments to the timeline")

Euphemistic smoothing is the opposite of the blog's core principle: show the failure, earn
trust, then show the fix. If you smooth the failure, there's nothing to fix and nothing to
trust.

---

## 38. Fake-Profound Kickers

**The tell:** The post or section ends on a "deep" line — a cute metaphor, an aphorism, or
a mic-drop sentence that reframes the concrete story as a universal truth. The ending
performs profundity instead of earning it.

**Symptoms:**
- The final sentence is a metaphor that appeared nowhere else in the post
- The ending zooms out from the specific story to a life lesson
- The last line would work as an inspirational poster or a fortune cookie
- Reads like the writer is stepping toward the microphone drop in slow motion

**Examples:**
- ❌ "In the end, the real bug was never in the code. It was in how we thought about code."
- ❌ "Maybe the best deploy pipeline is the one you never have to think about."
- ❌ "The agent didn't just write our tests. It taught us what testing means."
- ❌ "Because at the end of the day, software is people."

**Structural variants:**
- The aphorism can be section-level, not just post-level: a paragraph that ends its section
  with a zoomed-out "and isn't that what engineering is really about?" beat.
- The callback kicker: reusing an earlier image ("the 2 AM rollback") but inflating it into
  a metaphor for everything. Callbacks are good; callbacks promoted to universal truths are
  this pattern.
- The rhetorical-question kicker: ending on "And isn't that the point?" — a question that
  performs depth instead of asking anything.

**Why it's a tell:** LLMs end on fake-profound kickers because their training data rewards
closure — essays that "land." But the profundity is generated, not earned; the metaphor is
assembled from the post's keywords, not from insight. The reader can feel the difference
between an ending that follows from the story and one that's been draped over it.

**The repair rule — delete, don't rewrite:** When you catch a fake-profound kicker, the fix
is NOT a better metaphor. An LLM asked to fix a bad kicker will produce a shinier bad
kicker — same costume, better tailoring. Delete the line entirely and end on the strongest
concrete sentence already in the draft. If the ending then feels abrupt, the problem is a
missing fact or a missing CTA, not a missing aphorism.
- ✅ "We added input validation. The error rate dropped from twelve per hour to zero." (End
  there. No lesson about what error rates teach us about ourselves.)

**Carve-out:** The author bio may end with a deliberate kicker when the personal identity's
`bio` resource defines one — that's
a schema element, a joke connected to the post's content, not a profundity claim. This
pattern is about body prose endings. The bio kicker stays.

---

## 39. Body-Performance Emotion

**The tell:** A feeling delivered through the body or the room instead of named. The
stomach drops, the chest tightens, the cursor blinks mockingly. The emotion gets staged
rather than stated.

**Symptoms:**
- A body part acting on the writer's behalf: chest tightening, stomach dropping, breath
  catching, heart sinking, throat closing, hands shaking
- The environment carrying the mood: the cold glow of the monitor, the silence of the
  office at 3 AM, the cursor blinking accusingly
- An emotional beat where no feeling is ever named, only performed
- "Something shifted." "Something clicked." — an internal event reported without saying
  what it was

**Examples:**
- ❌ "My stomach dropped when I saw the diff."
- ❌ "I felt my chest tighten as the pipeline went red."
- ❌ "The terminal sat there, cursor blinking, mocking me."
- ❌ "Something shifted in how I thought about testing that day."
- ❌ "I let out a breath I didn't know I was holding."

**Structural variants:**
- **Setting as mirror** — the weather, the lighting, or the empty office doing the
  emotional work the sentence won't do. "The rain hadn't stopped since the incident began."
- **Sensory pile-on** — stacking smell, sound, and texture detail at an emotional beat as
  a substitute for saying what the beat was.
- **The unnamed realization** — "something clicked," "it finally made sense," without ever
  stating what clicked or what made sense.
- **Deferred naming** — three sentences of body-performance followed by the feeling named
  anyway. The naming was the whole sentence; the performance was throat-clearing.

**Why it's a tell:** This is the single largest human-AI gap measured in the StoryScope
corpus (Russell et al. 2026, arXiv:2604.03136): AI performs emotion through the body 81%
of the time against 38% for human writers, while humans name the feeling outright 29%
against 8%. It inverts the advice every writing class gives, and that's exactly why it
became a signature — models were trained on "show, don't tell" and apply it far harder
than people do. The underlying mechanism is worth knowing: a model reaches for a body
because it has no feeling to report.

**Instead:** Name it plainly, in the author's register. Reserve physical detail for the one
moment that actually earns it.
- ✅ "Honestly, that one stung."
- ✅ "I was pissed."
- ✅ "I read the diff twice, then went to get coffee, which is what I do instead of
  screaming."

**Carve-out — this is not a ban on physical detail.** Detail that is factually what
happened is reportage: the one sock, the cat on the keyboard, the 2:14 AM kitchen, the
terminal output you actually saw. That's narrative density and it stays (see
`skills/blog-writer/references/tone-guide.md`). The pattern is a body part standing in for a feeling the
sentence declines to name. Concrete lived specifics are the human marker; body-performance
is the machine one.
