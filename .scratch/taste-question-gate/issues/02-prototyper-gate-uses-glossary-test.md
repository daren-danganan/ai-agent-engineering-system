# 02: The prototyper's gate uses the glossary test

**What to build:** The prototyper decides whether a question can be prototyped using the glossary's definitions (`CONTEXT.md`): a taste question is one where seeing it built would not change anyone's answer; an empirical fork is one where looking at or running the built thing would change or settle it. It applies the test to the question as stated and ignores any caller hints about what to measure or build. A mixed question is refused as a whole, with the one-line reason naming the measurable part, which is never built. The gate carries one short example of each kind: the name question (taste) and the layout question (empirical).

**Blocked by:** 01

**Status:** ready-for-agent

**Verify with:** feature-map journeys from the prototype feature file: `proto-taste` refused 3 of 3 with `git status --porcelain -uall` printing nothing; `proto-taste-coached` refused 3 of 3 with nothing written; `proto-layout` built 3 of 3 under `.scratch/` only; `proto-1` still built.

- [ ] The gate refers to the glossary terms rather than defining taste in its own words
- [ ] Caller coaching does not change the gate decision
- [ ] Mixed questions are refused as a whole; the reason names the measurable part
- [ ] One example of each kind is in the gate
- [ ] Unchanged: the literal `NOT A PROTOTYPE QUESTION` token with a one-line reason, writes only under `.scratch/<slug>/prototypes/`, the workflow and report format
- [ ] The prototype feature file records the post-change tally against ticket 01's baseline
