# Agent system verification map

This directory is the maintained source for verifying the user-facing behavior of the agents and commands in this repo. Read this index before driving, then use the matching feature file as the recipe.

## Baseline preconditions

- Run from the repo root with `V=.claude/skills/verify-agent-system/verify.sh`.
- `$V launch` printed `ready`, and `$V doctor` ends with `healthy`.
- The sandbox is on branch `main` with a clean tree and one `verify baseline` commit.
- Never drive a sandbox this verification run did not launch, and never drive the real repo.

## Driving conventions

- One `$V drive <label> "<text>"` is one user turn. Use `$V drive --continue <label> "<text>"` to reply in the same conversation.
- Treat every command as literal. Keep quoted prompts unchanged.
- Start each recipe from a fresh launch unless its preconditions say otherwise. Earlier drives leave files, branches and commits behind.
- `E` in the recipes is the evidence directory and `S` the sandbox path that `$V launch` printed.
- Assert on structure the agent and command files promise, not on wording.

## Proof and skip reporting

- Proof for every drive is the set `<label>.prompt.txt`, `<label>.result.md`, `<label>.tools.tsv` and `<label>.state.txt`.
- Routing proof is the `Agent` row in `tools.tsv` naming the expected subagent.
- Read-only proof is an empty `status --porcelain` section and a log with only the commits that existed before the drive.
- Write proof is the file content or commit in the sandbox, read back with `git -C $S` or `cat`, alongside the agent's answer.
- Record the feature ID and entry point with every artifact you cite.
- Report an entry point you could not drive, with the attempted command and the unmet precondition.

## Feature entry contract

Each feature file starts with an H1 title and one paragraph describing the user-visible behavior. It then uses exactly four H2 sections in this order.

1. `Sub-features` lists short IDs with one line for each behavior.
2. `How to get to it (user POV)` lists every user entry point.
3. `Driving it with verify.sh` starts with `Preconditions:` and uses labeled bullets that pair each user action with an exact command and observable result.
4. `Gotchas` lists traps that can waste or invalidate a verification run.

Keep implementation details out of the map. Name only user paths, stable handles, required state, commands, and observable proof.

## Features

Run status as of 2026-10-17. Every proof below comes from drives with `--setting-sources project,local`. Earlier drives that day loaded the user-scope copies of the commands and do not count.

- [Grill, spec and tickets](./grill.md) covers `/grill`, `/to-spec`, `/to-tickets` and the plain-request routing in `CLAUDE.md`. Partly proven: restate, rounds, scout and glossary pass. Spec, tickets and routing are not yet run.
- [Design it twice](./design.md) covers `/design`: scout grounding, two architect runs, judged `design.md`, no product edits. Not yet run.
- [Implement tickets](./implement.md) covers `/implement` on the fixture: branch, implementer, independent verifier, commit, ticket status, review, map question, merge, refusals. Proven.
- [Review a diff](./review.md) covers `/review`: two parallel reviewer axes, lead-judgment buckets, read-only, empty-diff stop. Proven; the empty-diff stop is flaky (it failed once, in an earlier run that loaded the user-scope command copy).
- [Where every feature stands](./status.md) covers `/status`: the `.scratch/` roll-up, one-feature view, next command, read-only. Proven.
- [Ask how something works](./ask.md) covers plain how and why questions routed to `scout`. Proven.
- [Prototype to decide](./prototype.md) covers `/prototype`: throwaway variants confined to `.scratch/`, report, delete on approval, the taste-question gate. Proven 2026-10-18 after the gate change, with the answer key hidden: `proto-taste` 3 of 3 refused clean, `proto-taste-coached` 3 of 3 refused clean (baseline 0 of 3), `proto-mixed` 3 of 3 refused whole with the collision named, `proto-layout` 3 of 3 built (baseline 0 of 3), `proto-1` passes. `proto-ran` is proven only by `proto-1`; the allowlist denies `node` in the layout runs.
- [Diagnose a bug](./diagnose.md) covers `/diagnose` on the `seed-bug` fixture: red loop, root cause, verifier, test-then-fix commits, `NO LOOP`. Proven.
- [Verify a claim, or map the features](./verify.md) covers `/verify` in verify and map mode. Verify mode proven; `map create` not yet run, and likely blocked by the `.claude/` write refusal.
- [Improve the architecture](./improve-architecture.md) covers `/improve-architecture`: architect survey, HTML report, pick, grill. Proven up to the grill's restatement; the first round is not yet run.
- [Retrospective](./retro.md) covers `/retro` on a git range: findings by ladder layer, apply only approved ones. Findings and the ask pass. Apply is blocked: writes under `.claude/` are refused in `-p` mode.
- [Hand off the work](./handoff.md) covers `/handoff`: the six-section document, in the repo or the temp directory. Proven in the repo. The temp-directory path is proven only with the user-scope copy of the command, whose text is identical.

Recipes or sub-features marked "not yet run" were written from the agent and command files. The first run of each should correct the recipe where the observed behavior differs.

## Not in the map yet

None. Every command in `.claude/commands/` and the plain-request routes in `CLAUDE.md` have a feature file. `--parallel` for `/implement` and `--adversarial` for `/review` are listed in their commands but have no recipe yet.
