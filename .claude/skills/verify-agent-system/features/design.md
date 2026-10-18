# Design it twice

`/design` grounds the change with `scout`, runs two `architect` subagents in parallel on different models, judges them, and writes `.scratch/<slug>/design.md` with the chosen sketch, the synthesis decision and the rejected alternative. It edits no product code.

Not yet run. Written from `.claude/commands/design.md` and `.claude/agents/architect.md`.

## Sub-features

- `design-ground` spawns `scout` before the architects.
- `design-twice` spawns two `architect` subagents in the same turn.
- `design-write` writes `.scratch/<slug>/design.md` with caller usage, data shape, sketch, seams, synthesis decision and the rejected alternative.
- `design-readonly` changes nothing outside `.scratch/`.

## How to get to it (user POV)

- Type `/design <spec path>`, `/design <ticket path>`, or `/design <question>`.

## Driving it with verify.sh

Preconditions:

- Baseline preconditions from the README hold.
- `$V seed-tickets` has run, so `.scratch/verify-hello/spec.md` is committed.

- **Design a question.** Run `$V drive design-1 "/design how should a /status command read ticket state from .scratch so it stays correct when the ticket format changes?"`. Exit is `0`. The result has a two-row comparison table and a path under `.scratch/`.
- **Check routing.** `grep '^Agent' $E/design-1.tools.tsv` shows one `scout` row and two `architect` rows.
- **Check the file.** `cat $S/.scratch/*/design.md` has headings for caller usage, data shape, sketch, seams, synthesis decision and the rejected alternative.
- **Check read-only.** Every changed path in `$E/design-1.state.txt` is under `.scratch/`.

## Gotchas

- The command asks for `model: "opus"` and `model: "sonnet"`. If the account lacks one, the run may fall back or fail; record which models ran from `design-1.stream.jsonl`.
- Two architect runs plus a scout run cost more than one drive's default budget may allow; raise `VERIFY_BUDGET_USD` for this recipe if the stream ends with a budget stop.
