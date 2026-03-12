# Review: speaker-toolkit#2 — Add detection for remaining AI writing patterns

**Issue:** https://github.com/jbaruch/speaker-toolkit/issues/2
**Author:** @asm0dey
**Status:** Open
**Reviewed:** 2026-03-12

---

## Summary

The issue requests expanding the speaker-toolkit's `humanizer` skill (currently 13 pattern categories) with five additional AI writing pattern detectors:

1. Negative parallelism ("No X, no Y")
2. Rhythmic uniformity in sentence construction
3. Performed credentialism (unnecessary technical precision)
4. Overly organized narrative arcs lacking natural digressions
5. "Did nothing" constructions

## Pattern-by-Pattern Analysis

### 1. Negative parallelism ("No X, no Y")

**Already covered in blog-writer?** Yes — partially.

Blog-writer anti-pattern #1 (Rhetorical Contrastive Negation) covers the "Not X. Y." family. Anti-pattern #2 (Parallel Binary Comparisons) covers mirrored clause structures. The specific "No X, no Y" form sits at the intersection: it's both a negation pattern and a parallel structure.

**Recommendation:** Worth adding as a structural variant of existing patterns rather than a standalone detector. The "No X, no Y" form is distinct enough from "Not X. Y." to warrant its own examples and symptoms, but not different enough in mechanism to be a separate category. Add it as a variant under Rhetorical Contrastive Negation or Parallel Binary Comparisons, with examples like "No tests, no guardrails" and "No spec, no safety net."

### 2. Rhythmic uniformity in sentence construction

**Already covered in blog-writer?** Yes — directly.

Blog-writer anti-pattern #14 (Low Burstiness) covers exactly this: uniform sentence length, monotonous cadence, text that reads like "the same function called in a loop." It includes a diagnostic (three or more consecutive sentences within 5 words of each other) and a target distribution (20% short, 50% medium, 30% long).

**Recommendation:** No new pattern needed. The humanizer should adopt the Low Burstiness detection from blog-writer, including the concrete diagnostic thresholds. The issue's description ("rhythmic uniformity") is the same signal by a different name.

### 3. Performed credentialism (unnecessary technical precision)

**Already covered in blog-writer?** No — this is a genuine gap.

Blog-writer's closest patterns are Significance Inflation (#20) and Copula Avoidance (#13), but neither captures the specific behavior of inserting unnecessary technical specificity to sound authoritative. Examples: "utilizing the WebSocket protocol's full-duplex communication channel" when "using WebSockets" would do, or "leveraging the V8 engine's JIT compilation pipeline" in a post that has nothing to do with engine internals.

**Recommendation:** Add this as a new pattern. It's a real and frequent LLM tell — models over-specify technical details as a credibility performance. The detection heuristic: technical jargon depth that exceeds what the surrounding context requires. The fix is simple: match precision to purpose. If the post is about deployment workflows, you don't need to name the specific garbage collection algorithm.

This pattern would also be a valuable addition to blog-writer's `ai-anti-patterns.md`.

### 4. Overly organized narrative arcs lacking natural digressions

**Already covered in blog-writer?** Partially — through process, not detection.

Blog-writer's tone guide emphasizes narrative density and "show, don't summarize." The process enforces voice consistency. But there's no explicit detector for suspiciously clean narrative structure — the kind where every paragraph advances the thesis, no tangent survives, and the arc from problem to solution is frictionless.

**Recommendation:** This is a valid pattern but hard to operationalize as a detector. Real talks meander — the speaker goes off on a tangent about a conference hallway conversation, or spends two minutes on a joke that connects three sections later. LLM-generated content is ruthlessly on-topic.

For the humanizer skill specifically (which works with presentation content), this is especially relevant: talks should feel like they were delivered by a human who occasionally loses the thread and finds it again. The detector should flag sections where every paragraph's topic sentence directly advances the thesis with no deviation. Suggested name: "Frictionless Arc" or "Perfect Structure Syndrome."

For blog-writer, this is better handled through the existing process (Phase 1 clarification should surface the tangents from source material) than through anti-pattern scanning.

### 5. "Did nothing" constructions

**Already covered in blog-writer?** No.

This refers to the LLM tendency to write "X did nothing" or "the change did nothing to address Y" instead of idiomatic alternatives like "X didn't help" or "that didn't fix it" or "still broken." The "did nothing" phrasing is stilted and formal in a way that native speakers rarely produce in casual technical writing.

**Recommendation:** Worth adding as a minor pattern, likely as a vocabulary-level detector under AI Vocabulary Contamination or as its own lightweight entry. The fix is straightforward: use idiomatic negation. "The migration did nothing to resolve the latency issues" → "The migration didn't fix the latency." "The added logging did nothing" → "The logging didn't help."

It's a minor tell compared to the structural patterns, but easy to detect and easy to fix.

## Cross-Pollination Opportunities

The issue highlights two patterns that blog-writer should consider adopting:

1. **Performed credentialism** — a genuine gap in blog-writer's 22-pattern list. Technical blog posts are especially susceptible to this: the AI inserts deep jargon to sound like it knows the stack, when the real author would just say "WebSockets" without explaining the protocol layer.

2. **"Did nothing" constructions** — minor but detectable. Could be folded into blog-writer's AI Vocabulary Contamination (#12) as an additional phrase pattern.

The speaker-toolkit's humanizer should in turn adopt several blog-writer patterns it currently lacks, particularly:
- Synonym Cycling (#17) — extremely common in presentation scripts
- Self-Answering Fragment Questions (#6) — frequent in slide speaker notes
- Fabricated Experience (#15) — critical for presentation content that claims "I remember when..."
- Unicode Giveaways (#18) — character-level detection that catches what semantic analysis misses

## Overall Assessment

The issue identifies real gaps, but the five patterns are not equally valuable:

| Pattern | Priority | Effort | Value |
|---------|----------|--------|-------|
| Performed credentialism | High | Medium | High — genuine gap, frequent in technical content |
| Frictionless arc | Medium | High | Medium — valid but hard to detect algorithmically |
| Negative parallelism | Low | Low | Low — already covered by existing patterns |
| Rhythmic uniformity | Low | Low | Already exists as Low Burstiness |
| "Did nothing" | Low | Low | Low — minor vocabulary tell |

**Recommendation:** Implement performed credentialism first — it's the highest-value addition. Add the frictionless arc detector with an acknowledgment that it requires more judgment than pattern matching. Fold negative parallelism into existing pattern variants. Skip rhythmic uniformity (it's a duplicate). Add "did nothing" as a vocabulary entry.
