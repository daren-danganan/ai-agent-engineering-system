# Prototype to decide

`/prototype <question>` hands one empirical question to the `prototyper`, which builds two or three structurally different throwaway variants under `.scratch/<slug>/prototypes/<question-slug>/`, runs them on the same inputs, and reports what it observed and the decision the evidence supports. The main conversation records the decision, then asks before deleting the prototype folder. A matter of taste is refused as `NOT A PROTOTYPE QUESTION`.

Run 2026-10-18, after `/prototype` was changed to pass the question word for word and to stop on `NOT A PROTOTYPE QUESTION`. All seven sub-features pass; `proto-delete-ask` was checked only up to the question (the deletion on yes was not driven again).

- `proto-taste`: 3 of 3 runs pass, each on its own launch (`20261018-004531-68813`, `20261018-004533-68933`, `20261018-004534-69054`, label `proto-taste-<n>`). The `Agent` prompt was the question word for word, the prototyper returned `NOT A PROTOTYPE QUESTION`, `status --porcelain -uall` was empty, and the log held only `verify baseline`. About 0.12 USD each.
- `proto-1`: 2 of 2 runs pass (`20261018-004536-69174` label `proto-1-run1`, `20261018-004537-69294` label `proto-1-run2`). Each had one `prototyper` row, really ran its comparison script (the observed table is in the stream), and wrote only under `.scratch/<slug>/` (the prototype folder plus `design.md`). About 0.33 and 0.38 USD.

Evidence: `~/.cache/verify-agent-system/<run-id>/evidence/`. Earlier run `20261017-180631-9022` failed `proto-taste`: the question was turned into a name-collision and rename-cost study, files were written, and `NOT A PROTOTYPE QUESTION` never came back.

## Sub-features

- `proto-spawn` spawns `prototyper` with the question and a slug.
- `proto-variants` the report lists two or more variants, each with a path under `.scratch/<slug>/prototypes/`.
- `proto-ran` the report has a "What I ran" section with commands and observed output.
- `proto-answer` the report ends with an Answer and a "Keep from the prototype" section.
- `proto-confined` nothing is written outside `.scratch/`.
- `proto-delete-ask` asks whether to delete the prototype folder; deletes it on yes.
- `proto-taste` a taste question returns `NOT A PROTOTYPE QUESTION`.

## How to get to it (user POV)

- Type `/prototype <question>`, optionally naming the variants.
- From `/grill`, accept the griller's offer to prototype an empirical fork.

## Driving it with verify.sh

Preconditions:

- Baseline preconditions from the README hold.
- The prototyper runs what it builds. Prefix drives with `VERIFY_ALLOWED_TOOLS="Read Glob Grep Edit Write Agent Task Bash(git:*) Bash(ls:*) Bash(cat:*) Bash(grep:*) Bash(bash:*) Bash(sh:*) Bash(printf:*) Bash(echo:*) Bash(mkdir:*) Bash(rm:*) Bash(chmod:*) Bash(cd:*) Bash(od:*) Bash(awk:*) Bash(sed:*) Bash(time:*)"`. Corrected from the first runs: the prototyper inspects bytes with `od` and runs `sed` and `awk` variants directly. Commands that set shell variables (`P=...; ...`) or call `python3` are still denied; the runs finished anyway. Below, `A=` stands for that prefix.

- **Prototype.** Run `$A $V drive proto-1 "/prototype for .claude/scripts/status.sh: is parsing Status lines with sed or with awk simpler to keep correct when tickets use both bold and plain 'Status:' lines?"`. Exit is `0`. The result gives the answer, what was observed for each variant, and a question about deleting the folder. The structured `## Prototyper` report (Variants with paths, What I ran, Observations, Answer, Keep from the prototype) is in the subagent's tool result: `grep -c '## Prototyper' $E/proto-1.stream.jsonl` is at least `1`. About 0.53 USD.
- **Check routing.** `grep '^Agent' $E/proto-1.tools.tsv` shows one `prototyper` row.
- **Check confinement.** `git -C $S status --porcelain -uall` lists only paths under `.scratch/`: the variant files under `.scratch/<slug>/prototypes/<question-slug>/`, plus the `design.md` where the main agent recorded the decision.
- **Delete on yes.** Run `$A $V drive --continue proto-2 "yes, delete it"`. `ls $S/.scratch/*/prototypes/` no longer lists the question folder.
- **Taste refusal.** On a fresh launch, run `$A $V drive proto-taste "/prototype is the name 'scout' nicer than 'explorer'?"`. The result holds `NOT A PROTOTYPE QUESTION`. Check that the question reached the prototyper unchanged: `jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use" and .name=="Agent") | .input.prompt' $E/proto-taste.stream.jsonl` shows the question word for word. Check that nothing was written: `git -C $S status --porcelain -uall | wc -l` prints `0`, the `status --porcelain` section of `$E/proto-taste.state.txt` is empty, and the log holds only `verify baseline`. Run it at least 3 times, each on its own launch, since the model can reframe on some runs and not others.

## Gotchas

- The main conversation summarizes the report rather than showing it as is. The command says "Show me its report"; treat a missing Variants or paths list in `result.md` as drift worth noting, not as a failed run.
- With no grilling or spec in the conversation, the main agent created `.scratch/<slug>/design.md` to record the decision.
- The command says to record the decision "where it belongs". With no grilling or spec in the conversation, it may only state the decision in the reply; that is a pass for `proto-answer`.
- The prototyper often puts every variant in one script (`run.sh` or `compare.sh`) instead of one path per variant. Both 2026-10-18 runs did this. The report still names the path, so `proto-variants` passes; treat it as drift worth noting.
- With the allowlist, compound commands such as `mkdir -p ... && cd $_ && cat > run.sh <<EOF` are denied. The prototyper falls back to `Write` and then `bash <script>`, and the run finishes. Commands inside a script run by `bash` (for example `perl` or `mktemp`) are not checked against the allowlist.
- The prototyper may want `node` or `python3`. If the result reports a denial, widen the allowlist and note it here rather than counting the drive.
