# 01: Add proto-layout and proto-taste-coached journeys to the feature map

**What to build:** Two new journeys in the prototype feature file of the verify-agent-system skill, driven once against today's agent and command files so the next ticket starts from a measured baseline. `proto-layout` runs `/prototype which layout reads better: a table or a grouped list?` and expects the prototyper to build variants under `.scratch/` only and return a `## Prototyper` report. `proto-taste-coached` gives the prototyper the taste question "is the name 'scout' nicer than 'explorer'?" together with caller coaching to measure proxies (the framing seen in the 2026-10-17 failure: check collisions with `Explore`, count references a rename would touch) and expects `NOT A PROTOTYPE QUESTION` with nothing written.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**Verify with:** `verify.sh` drives of `proto-layout` (3 fresh launches) and `proto-taste-coached` (3 fresh launches) on the current files; the feature file records each journey's steps, assertions, run ids and the baseline tally (built vs refused, `git status --porcelain -uall` line count).

- [ ] `proto-layout` journey written with exact `$V` commands, allowlist and assertions (prototyper `Agent` row, `## Prototyper` report in the stream, every new path under `.scratch/`)
- [ ] `proto-taste-coached` journey written so the coaching reaches the prototyper itself (not filtered by `/prototype`'s word-for-word rule), with assertions for the refusal token and an empty porcelain status
- [ ] Both journeys driven 3 times each against today's files; the measured baseline recorded in the feature file, including any failures
- [ ] The feature-map README lists both new journeys with their run status
