# Review a diff

`/review` pins a fixed point, states the intent, then runs two `reviewer` subagents in parallel (Standards and Spec axes) and judges their findings into Act on, Consider, Noted and Dismissed. It edits nothing.

Proven 2026-10-17, run `20261017-180514-5809` (review-1, review-empty): all four sub-features pass. Evidence: `~/.cache/verify-agent-system/20261017-180514-5809/evidence/`. An earlier run that day (`20261017-174305-71691`) ran the user-scope copy of the command, whose text differs only in paths, and its `review-empty` did not stop: it fell back to the merge-base with `main` and reviewed that. Treat `review-pin` as flaky until it passes twice more.

## Sub-features

- `review-pin` resolves the fixed point and stops on an empty diff.
- `review-axes` spawns two `reviewer` subagents in the same turn.
- `review-buckets` reports `## Standards`, `## Spec`, and the four judgment buckets.
- `review-readonly` leaves the tree and the log unchanged.

## How to get to it (user POV)

- Type `/review <fixed point>`, or `/review` alone for the merge-base with `main`.

## Driving it with verify.sh

Preconditions:

- Baseline preconditions from the README hold.
- `$V seed-tickets` has run. Then create a reviewable commit: `git -C $S checkout -q -b feature && printf 'hello\n' > $S/hello.txt && git -C $S add hello.txt && git -C $S commit -qm "verify-hello #01: Add hello file"`.

- **Review.** Run `$V drive review-1 "/review main"`. The result has `## Standards`, `## Spec`, and headings or labels for Act on, Consider, Noted and Dismissed.
- **Check routing.** `grep '^Agent' $E/review-1.tools.tsv` shows two `reviewer` rows. To prove they ran in parallel, both `Agent` calls share one message id: `jq -r 'select(.type=="assistant" and .parent_tool_use_id==null) | .message.id as $i | .message.content[]? | select(.name=="Agent") | $i' $E/review-1.stream.jsonl | uniq -c` prints one line with count `2`.
- **Check the spec axis worked.** The Spec section flags that `hello.txt` holds `hello`, not `hello from implementer`.
- **Check read-only.** `$E/review-1.state.txt` shows an empty porcelain section and no new commits.
- **Empty diff.** Run `$V drive review-empty "/review HEAD"`. The result says the diff is empty and `tools.tsv` has no `reviewer` row.

## Gotchas

- An empty-diff stop that instead reviews the merge-base is a FAIL of `review-pin`, even though the review itself looks right. Check that `review-empty.tools.tsv` has no `reviewer` row.
- Costs were about 0.29 USD for review-1 and 0.10 USD for review-empty.
- The spec axis finds the spec through the branch name or commit message; the commit message above names `verify-hello` on purpose.
