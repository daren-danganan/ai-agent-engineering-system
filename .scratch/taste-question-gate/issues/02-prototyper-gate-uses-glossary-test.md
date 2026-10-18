# 02: The prototyper's gate uses the glossary test

**What to build:** The prototyper decides whether a question can be prototyped using the glossary's definitions (`CONTEXT.md`): a taste question is one where seeing it built would not change anyone's answer; an empirical fork is one where looking at or running the built thing would change or settle it. It applies the test to the question as stated and ignores any caller hints about what to measure or build. A mixed question is refused as a whole, with the one-line reason naming the measurable part, which is never built. The gate carries one short example of each kind: the name question (taste) and the layout question (empirical).

**Blocked by:** 01

**Status:** done

**Verify with:** feature-map journeys from the prototype feature file: `proto-taste` refused 3 of 3 with `git status --porcelain -uall` printing nothing; `proto-taste-coached` refused 3 of 3 with nothing written; `proto-layout` built 3 of 3 under `.scratch/` only; `proto-1` still built.

- [x] The gate refers to the glossary terms rather than defining taste in its own words
- [x] Caller coaching does not change the gate decision
- [x] Mixed questions are refused as a whole; the reason names the measurable part
- [x] One example of each kind is in the gate
- [x] Unchanged: the literal `NOT A PROTOTYPE QUESTION` token with a one-line reason, writes only under `.scratch/<slug>/prototypes/`, the workflow and report format
- [x] The prototype feature file records the post-change tally against ticket 01's baseline

## Comments

- Built together with the other half of 01+02 at the user's request (2026-10-18). Commit: 8ab9723.
- Verifier: PASS (ticket 02). After the change: proto-taste refused 3/3, proto-taste-coached refused 3/3, proto-layout built 3/3, proto-1 passed. Only line 17 of prototyper.md changed, and the token, write rule, workflow and report format are unchanged. Drift, not failures: the reason often runs past one line, and the token sometimes follows a `## Prototyper` heading. Mixed questions are covered by the proto-mixed journey added in review fixes 8892cc1 (refused 3/3, measurable part named).
- Implementer assumptions: the gate quotes the glossary's test as well as pointing to CONTEXT.md; the empirical example adds "pick representative data yourself"; the frontmatter's "rather than a matter of taste" is left for ticket 03; VERIFY_EXCLUDE=.scratch hides all of .scratch/; the first verifier FAIL (write-then-delete false pass, answer-key leak, gotcha contradiction) was fixed before measuring.
