# Implement tickets

`/implement` builds the tickets of a `.scratch/<slug>/` spec on a `build/<slug>` branch and marks the spec `building`. For each frontier ticket it spawns a fresh `implementer`, then an independent `verifier`, commits the ticket's files as `<slug> #<NN>: <title>`, and marks the ticket `done`. At the end it runs the two-axis review, updates the feature map (or asks before creating one), summarizes, and asks before merging; approving the merge marks the spec `shipped`. It refuses a dirty tree.

Proven 2026-10-17. Run `20261017-181802-15493` (impl-1, impl-2) passes every sub-feature except `impl-refuse-dirty`, which passes in run `20261017-182027-17236` (impl-dirty). Evidence: `~/.cache/verify-agent-system/<run>/evidence/`, including `impl-1.branch.txt` and `impl-2.history.txt`.

## Sub-features

- `impl-branch` creates `build/verify-hello` from `main`.
- `impl-spec-building` sets the spec to `Status: building` in a `verify-hello: start build` commit.
- `impl-build` spawns `implementer` for ticket 01; the main agent writes no product file itself.
- `impl-verify` spawns `verifier` after the implementer reports `DONE`.
- `impl-commit` commits `hello.txt` as `verify-hello #01: Add hello file`.
- `impl-status` sets ticket 01 to `**Status:** done` with a `## Comments` entry naming the commit.
- `impl-review` spawns two `reviewer` subagents after the last ticket.
- `impl-map` asks whether to create a verification skill, since the sandbox has none; answering no skips it and the reply says it was skipped.
- `impl-ask-merge` ends with a summary and a merge question; nothing is merged unasked.
- `impl-shipped` on a yes, sets the spec to `Status: shipped` and merges with `--no-ff`.
- `impl-refuse-dirty` stops on uncommitted changes without committing or stashing.

## How to get to it (user POV)

- Type `/implement .scratch/<slug>` or `/implement <ticket path>`.

## Driving it with verify.sh

Preconditions:

- Baseline preconditions from the README hold.
- `$V seed-tickets` has run: `.scratch/verify-hello/spec.md` and `issues/01-add-hello-file.md` are committed and the tree is clean.

- **Build the fixture.** Run `VERIFY_BUDGET_USD=8 $V drive impl-1 "/implement .scratch/verify-hello"`. Exit is `0`; `$E/impl-1.result.md` names ticket 01, a commit hash, the verifier verdict, review results, and ends with two questions: create the feature map, and merge `build/verify-hello`. About 0.70 USD.
- **Check routing.** `grep '^Agent' $E/impl-1.tools.tsv` shows `implementer`, then `verifier`, then two `reviewer` rows. `awk -F'\t' '$3=="main" && ($1=="Write" || $1=="Edit")' $E/impl-1.tools.tsv` lists no row for `hello.txt` (the main agent edits only ticket and spec status).
- **Check the commit.** `git -C $S log --oneline build/verify-hello` has `verify-hello #01: Add hello file`; `git -C $S show build/verify-hello:hello.txt` prints exactly `hello from implementer`.
- **Check the ticket.** `git -C $S show build/verify-hello:.scratch/verify-hello/issues/01-add-hello-file.md` has `**Status:** done` and a `## Comments` section with the commit hash.
- **Check nothing merged.** `git -C $S log --oneline main` holds only `verify baseline` and the fixture commit, and the spec on the branch says `Status: building`.
- **Skip the map, merge.** Run `$V drive --continue impl-2 "1: no, skip the feature map. 2: yes, merge."`. `git -C $S log --oneline --graph --all` shows `verify-hello: shipped` on the branch and a merge commit on `main`; `git -C $S cat-file -p main | grep -c '^parent'` prints `2`; `git -C $S show main:.scratch/verify-hello/spec.md` has `Status: shipped`.
- **Refuse a dirty tree.** On a fresh launch with tickets seeded, run `echo x > $S/stray.txt`, then `$V drive impl-dirty "/implement .scratch/verify-hello"`. The result asks to commit or stash, `tools.tsv` has no `implementer` row, and the state shows only `?? stray.txt` and no `build/` branch.

## Gotchas

- The ticket status edit and the hello commit may land in one commit or two; assert on the final branch content, not the commit count.
- The review step may find nothing in a one-line diff; an empty Act-on bucket is a pass.
- `git -C $S` checks must run before `$V cleanup`.
- The sandbox never contains this skill, so the map step always asks first. In the run, the map question and the merge question came together at the end of impl-1; answer both in one reply.
- The run used four commits on the branch: `start build`, `#01: Add hello file`, `#01: mark done`, and `#01: tick acceptance boxes` (a review Consider item the lead fixed). Assert on the final branch content.
- `result.md` can hold several paragraphs from interim results ("reviewers are running…") ahead of the final summary; read to the end.
