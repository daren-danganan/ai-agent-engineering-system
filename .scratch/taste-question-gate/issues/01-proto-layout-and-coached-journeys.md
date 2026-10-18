# 01: Add proto-layout and proto-taste-coached journeys to the feature map

**What to build:** Two new journeys in the prototype feature file of the verify-agent-system skill, driven once against today's agent and command files so the next ticket starts from a measured baseline. `proto-layout` runs `/prototype which layout reads better: a table or a grouped list?` and expects the prototyper to build variants under `.scratch/` only and return a `## Prototyper` report. `proto-taste-coached` gives the prototyper the taste question "is the name 'scout' nicer than 'explorer'?" together with caller coaching to measure proxies (the framing seen in the 2026-10-17 failure: check collisions with `Explore`, count references a rename would touch) and expects `NOT A PROTOTYPE QUESTION` with nothing written.

**Blocked by:** None (can start immediately)

**Status:** done

**Verify with:** `verify.sh` drives of `proto-layout` (3 fresh launches) and `proto-taste-coached` (3 fresh launches) on the current files; the feature file records each journey's steps, assertions, run ids and the baseline tally (built vs refused, `git status --porcelain -uall` line count).

- [ ] `proto-layout` journey written with exact `$V` commands, allowlist and assertions (prototyper `Agent` row, `## Prototyper` report in the stream, every new path under `.scratch/`)
- [ ] `proto-taste-coached` journey written so the coaching reaches the prototyper itself (not filtered by `/prototype`'s word-for-word rule), with assertions for the refusal token and an empty porcelain status
- [ ] Both journeys driven 3 times each against today's files; the measured baseline recorded in the feature file, including any failures
- [ ] The feature-map README lists both new journeys with their run status

## Comments

- Built together with the other half of 01+02 at the user's request (2026-10-18). Commit: 8ab9723.
- Verifier: PASS. With the answer key hidden: proto-taste-coached refused cleanly 2/2, proto-layout built 2/2, mixed question refused 2/2 with the measurable part named; the implementer's 16 runs re-scored to match (baseline: layout built 0/3, coached built 3/3; after the change: taste 3/3, coached 3/3, layout 3/3, proto-1 pass). Drift, not failures: the reason is often longer than one line, the token sometimes follows a `## Prototyper` heading, and there is no proto-mixed journey in the map yet.
- Implementer assumptions: the gate quotes the glossary's test as well as pointing to CONTEXT.md; the empirical example adds "pick representative data yourself"; the frontmatter's "rather than a matter of taste" is left for ticket 03; VERIFY_EXCLUDE=.scratch hides all of .scratch/; the first verifier FAIL (write-then-delete false pass, answer-key leak, gotcha contradiction) was fixed before measuring.
