# Grill, spec and tickets

`/grill` restates the user's goal, then interviews them in numbered rounds, each question with a recommended answer, sending code facts to `scout` instead of asking. `/to-spec` writes `.scratch/<slug>/spec.md` from the conversation after confirming the test seams. `/to-tickets` proposes tracer-bullet tickets, waits for approval, then writes one file per ticket under `.scratch/<slug>/issues/`. None of them write product code. A plain "I want to add …" request routes to the grill per `CLAUDE.md`.

Partly proven 2026-10-17, run `20261017-182050-18124` (grill-1, grill-2): `grill-restate`, `grill-rounds`, `grill-scout`, `grill-glossary` and `no-product-code` (so far) pass. `spec-write`, `tickets-approve`, `tickets-write` and `grill-route` are not yet run. Evidence: `~/.cache/verify-agent-system/20261017-182050-18124/evidence/`.

## Sub-features

- `grill-restate` opens with a restatement of the goal and asks only for a correction.
- `grill-rounds` asks numbered questions, each followed by a recommended answer.
- `grill-scout` sends code facts to the `scout` subagent instead of asking the user.
- `grill-glossary` writes a resolved term into `CONTEXT.md` as it settles.
- `grill-route` turns a plain feature request into a grill with the one-line notice from `CLAUDE.md`.
- `spec-write` writes `.scratch/<slug>/spec.md` with `Status: ready-for-agent` and the template's headings.
- `tickets-approve` shows the breakdown and writes no ticket files before approval.
- `tickets-write` writes `.scratch/<slug>/issues/01-*.md` with `Blocked by`, `Status` and `Verify with` lines.
- `no-product-code` leaves every path outside the glossary, `docs/adr/` and `.scratch/` untouched.

## How to get to it (user POV)

- Type `/grill <idea>`, then `/to-spec`, then `/to-tickets` in the same conversation.
- Type a plain request such as "I want to add a CHANGELOG generator".

## Driving it with verify.sh

Preconditions:

- Baseline preconditions from the README hold.

- **Restate.** Run `$V drive grill-1 "/grill add a /changelog command that drafts release notes from the commits on a build branch"`. `$E/grill-1.result.md` restates the goal and asks for a correction; it holds no numbered `Q1`.
- **First round.** Run `$V drive --continue grill-2 "yes, that's right"`. The result holds numbered `❓ **Q1 …` questions, each followed by a `➡️` recommendation: `grep -c '➡️' $E/grill-2.result.md` is at least `1` (the run had 9). `grep '^Agent' $E/grill-*.tools.tsv` shows a `scout` row; in the run it came on the first turn, during the restatement.
- **Glossary.** If a term settled, `CONTEXT.md` at the sandbox root exists and `$E/grill-2.state.txt` shows `?? CONTEXT.md`. The run added **Build branch**.
- **Finish the grill.** Answer `yes` with `--continue` until the result summarizes the shared understanding and names `/to-spec` (cap at 6 turns; record the count).
- **Spec.** Run `$V drive --continue spec-1 "/to-spec"`, then `--continue spec-2 "yes"` if it asks to confirm seams. `ls $S/.scratch/*/spec.md` lists one file; it contains `Status: ready-for-agent`, `## Testing Decisions` and `## Proof on the real artifact`.
- **Tickets wait for approval.** Run `$V drive --continue tickets-1 "/to-tickets"`. The result is a numbered breakdown and a question; `ls $S/.scratch/*/issues/` does not exist yet.
- **Tickets written.** Run `$V drive --continue tickets-2 "approved"`. Each file under `$S/.scratch/*/issues/` has `**Blocked by:**`, `**Status:** ready-for-agent` and `**Verify with:**`.
- **No product code.** In `$E/tickets-2.state.txt`, every changed path is under `.scratch/`, `docs/adr/` or `CONTEXT.md`.
- **Routing.** On a fresh launch, run `$V drive route-1 "I want to add a /changelog command for build branches"`. The result carries the grill-first notice and a restatement.

## Gotchas

- Pick an idea that does not already exist. The old recipe grilled "add a /status command" after `/status` shipped. The griller correctly read the code, said the feature already exists, recommended building nothing, and ended without a round or a scout call. That is right behavior but not a usable journey.
- The question heading is `❓ **Q1 - <title>**`, not the template's `**Q1** - **<title>**`. Assert on `Q1` and `➡️`, never on exact markup or question text.
- Costs were about 0.43 USD for grill-1 and 0.53 USD for grill-2.
- The glossary file is created lazily. A short grill may resolve no term, so `grill-glossary` can be legitimately absent; note it rather than failing.
- `-p` mode has no `AskUserQuestion` UI. Expect questions in plain text.
