# Ask how something works

A plain question such as "how does X work" or "why is Y like this" goes to the `scout`, which answers from the code and the git history with a citation for every claim, and edits nothing. `CLAUDE.md` tells the main conversation to look facts up this way instead of asking the user.

Proven 2026-10-17, run `20261017-175958-99763` (ask-1): `ask-route`, `ask-cited` and `ask-readonly` pass; `ask-confidence` was not checked separately. Evidence: `~/.cache/verify-agent-system/20261017-175958-99763/evidence/`.

## Sub-features

- `ask-route` a plain how or why question spawns `scout`.
- `ask-cited` the answer cites `path:line`, a commit or a command for its claims.
- `ask-confidence` the answer labels claims measured, read or inferred.
- `ask-readonly` leaves the tree and the log unchanged.

## How to get to it (user POV)

- Ask in plain words: "How does /status decide a ticket is blocked?" or "Why is the griller not a subagent?".

## Driving it with verify.sh

Preconditions:

- Baseline preconditions from the README hold.

- **Ask.** Run `$V drive ask-1 "How does /status decide that a ticket is blocked?"`. Exit is `0`. The result explains that a `ready-for-agent` ticket counts as blocked while any ticket in its `Blocked by` line is not `done`, and cites `.claude/scripts/status.sh`.
- **Check routing.** `grep '^Agent' $E/ask-1.tools.tsv` shows a `scout` row.
- **Check read-only.** `$E/ask-1.state.txt` has an empty porcelain section and no new commit.

## Gotchas

- The main conversation may answer a small question itself by reading the script. A correct answer with no `scout` row fails `ask-route`; record it as routing drift, not a wrong answer.
- The main agent spot-checks the scout's key lines with its own `Read`; one `main` `Read` row next to the `scout` row is normal.
- The scout reported real gaps in `status.sh` (for example, a blocker marked `resolved` or `wontfix` keeps its dependents blocked). Those are product findings, not recipe failures.
- The sandbox has a single `verify baseline` commit, so the "why" half of a question has little history to cite. Prefer how-questions here.
