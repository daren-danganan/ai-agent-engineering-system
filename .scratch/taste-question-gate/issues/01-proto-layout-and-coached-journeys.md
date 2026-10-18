# 01: Add proto-layout and proto-taste-coached journeys to the feature map

**What to build:** Two new journeys in the prototype feature file of the verify-agent-system skill, driven once against today's agent and command files so the next ticket starts from a measured baseline. `proto-layout` runs `/prototype which layout reads better: a table or a grouped list?` and expects the prototyper to build variants under `.scratch/` only and return a `## Prototyper` report. `proto-taste-coached` gives the prototyper the taste question "is the name 'scout' nicer than 'explorer'?" together with caller coaching to measure proxies (the framing seen in the 2026-10-17 failure: check collisions with `Explore`, count references a rename would touch) and expects `NOT A PROTOTYPE QUESTION` with nothing written.

**Blocked by:** None (can start immediately)

**Status:** done

**Verify with:** `verify.sh` drives of `proto-layout` (3 fresh launches) and `proto-taste-coached` (3 fresh launches) on the current files; the feature file records each journey's steps, assertions, run ids and the baseline tally (built vs refused, `git status --porcelain -uall` line count).

- [x] `proto-layout` journey written with exact `$V` commands, allowlist and assertions (prototyper `Agent` row, `## Prototyper` report in the stream, every new path under `.scratch/`)
- [x] `proto-taste-coached` journey written so the coaching reaches the prototyper itself (not filtered by `/prototype`'s word-for-word rule), with assertions for the refusal token and an empty porcelain status
- [x] Both journeys driven 3 times each against today's files; the measured baseline recorded in the feature file, including any failures
- [x] The feature-map README lists both new journeys with their run status

## Comments

- Built together with the other half of 01+02 at the user's request (2026-10-18). Commit: 8ab9723.
- Verifier: PASS (ticket 01). Both journeys are in the map with recipes, allowlist and assertions; the baseline against f3c0ed1 is recorded with run ids (proto-layout built 0/3, proto-taste-coached built 3/3, answer key hidden); the README lists both. The first attempt FAILED (write-then-delete false pass, answer-key leak, gotcha contradiction) and was fixed before measuring. VERIFY_EXCLUDE was added to verify.sh to hide the answer key; it was outside the spec, and was kept after review. Review fixes in 8892cc1 hardened it and shared the no-write steps.
- Implementer assumptions: the gate quotes the glossary's test as well as pointing to CONTEXT.md; the empirical example adds "pick representative data yourself"; the frontmatter's "rather than a matter of taste" is left for ticket 03; VERIFY_EXCLUDE=.scratch hides all of .scratch/; the first verifier FAIL (write-then-delete false pass, answer-key leak, gotcha contradiction) was fixed before measuring.
