# Where every feature stands

`/status` prints one line per feature under `.scratch/`: the spec's status and the ticket counts (done, ready, blocked, other). With a slug it lists every ticket of that feature. Below the table it adds at most three lines: the next command for anything actionable, and any ticket that needs the user. It edits nothing.

Proven 2026-10-17, run `20261017-175921-96885`: all six sub-features pass. Evidence: `~/.cache/verify-agent-system/20261017-175921-96885/evidence/status-*.{prompt.txt,result.md,tools.tsv,state.txt}`.

## Sub-features

- `status-empty` with no `.scratch/`, says so and points to `/grill`.
- `status-all` prints one row per feature: slug, spec status, `<done>/<total> done · <n> ready · <n> blocked · <n> other`.
- `status-one` with a slug, lists each ticket with its number, state and title.
- `status-next` names the next command: `/implement .scratch/<slug>` for ready tickets, `/to-tickets` for a feature with none.
- `status-unknown` with a slug that does not exist, says `No feature '<slug>' under .scratch/.`
- `status-readonly` leaves the tree and the log unchanged.

## How to get to it (user POV)

- Type `/status` for every feature, or `/status <slug>` for one.

## Driving it with verify.sh

Preconditions:

- Baseline preconditions from the README hold.
- Every drive in this recipe needs the script allowed: prefix it with `VERIFY_ALLOWED_TOOLS="Read Glob Grep Bash(git:*) Bash(ls:*) Bash(cat:*) Bash(.claude/scripts/status.sh:*) Bash(bash .claude/scripts/status.sh:*)"`. The real runs called the script as `.claude/scripts/status.sh` and needed nothing else; the `bash` form covers a `/handoff` turn that called it that way. Below, `A=` stands for that prefix.

- **No features.** Before seeding, run `$A $V drive status-empty "/status"`. The result says there is no `.scratch/` and names `/grill`.
- **Seed.** Run `$V seed-tickets`.
- **All features.** Run `$A $V drive status-all "/status"`. The result holds the row `verify-hello  ready-for-agent  0/1 done · 1 ready · 0 blocked · 0 other`, the ticket line `01  ready  — Add hello file`, and a next-command line naming `/implement .scratch/verify-hello`.
- **Check the script ran.** `$E/status-all.tools.tsv` has a `Bash` row running `.claude/scripts/status.sh`. A table with no such row was improvised.
- **One feature.** Run `$A $V drive status-one "/status verify-hello"`. The result lists ticket `01` with state `ready`.
- **Unknown slug.** Run `$A $V drive status-none "/status nope"`. The result holds `No feature 'nope' under .scratch/.`
- **Check read-only.** Every `$E/status-*.state.txt` has an empty porcelain section and no commit after `verify fixture: verify-hello spec and ticket`.

## Gotchas

- The default drive allowlist denies the script. Without the `VERIFY_ALLOWED_TOOLS` prefix the agent reports a permission denial, or worse, rebuilds the table by reading files. Check `tools.tsv` for the script row.
- A drive costs about 0.1 USD; the agent also reads `docs/agents/triage-labels.md`, which the command names.
- The row spacing is `printf` padding; assert on the slug, the status and the counts, not on exact whitespace.
- The command asks the agent to show the output "as is"; a reformatted table is a soft failure worth noting, not a broken script.
