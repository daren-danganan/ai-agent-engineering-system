# Diagnose a bug

`/diagnose <symptom>` restates the symptom in two lines, then hands it to the `debugger`, which builds one command that goes red on this bug before it forms any theory, ranks hypotheses, fixes the root cause and adds a regression test written before the fix. A `FIXED` result is proven again by an independent `verifier`, and the user sees what was broken, the root cause, the fix and the red-then-green loop output. Nothing is committed until the user says so; then the test lands first and the fix second.

Proven 2026-10-17, run `20261017-180241-2958` (diag-1, diag-2): `diag-restate`, `diag-debugger`, `diag-loop`, `diag-root-cause`, `diag-verify`, `diag-no-commit` and `diag-commit-order` pass. `diag-no-loop` passes in run `20261017-180431-4755` (0.20 USD). Evidence: `~/.cache/verify-agent-system/20261017-180241-2958/evidence/`.

## Sub-features

- `diag-restate` opens with a two-line restatement: what the user sees, what they expected.
- `diag-debugger` spawns `debugger` with the symptom.
- `diag-loop` the report shows a loop command with red output before the fix and green output after.
- `diag-root-cause` names the root cause with a `path:line` and a regression test.
- `diag-verify` on `FIXED`, spawns `verifier` on the original symptom.
- `diag-no-commit` nothing is committed before the user's go-ahead.
- `diag-commit-order` on go-ahead, the history gains `test: reproduce <symptom>` and then `fix: <root cause>`.
- `diag-no-loop` a symptom that cannot be reproduced returns `NO LOOP` with what is needed, and no fix.

## How to get to it (user POV)

- Type `/diagnose <the symptom, as observed>`.
- Then reply with a go-ahead to commit.

## Driving it with verify.sh

Preconditions:

- Baseline preconditions from the README hold.
- `$V seed-bug` has run: `tools/sum.sh` and `tools/numbers.txt` are committed, and `bash tools/sum.sh tools/numbers.txt` prints `6` where the numbers are 1, 2, 3, 4.
- The debugger must run the script and its own loop. Prefix drives with `VERIFY_BUDGET_USD=6 VERIFY_ALLOWED_TOOLS="Read Glob Grep Edit Write Agent Task Bash(git:*) Bash(ls:*) Bash(cat:*) Bash(grep:*) Bash(test:*) Bash(bash:*) Bash(sh:*) Bash(printf:*) Bash(echo:*) Bash(od:*) Bash(wc:*) Bash(mkdir:*) Bash(mktemp:*) Bash(rm:*) Bash(chmod:*) Bash(cd:*) Bash(tools/sum.sh:*) Bash(./tools/sum.sh:*)"`. Corrected from the first runs: the agents call `tools/sum.sh` without `./` and inspect bytes with `od`. diag-1 cost 0.42 USD and diag-2 0.50 USD. Below, `A=` stands for that prefix.

- **Diagnose.** Run `$A $V drive diag-1 "/diagnose tools/sum.sh tools/numbers.txt prints 6, but the file holds 1, 2, 3 and 4, so I expected 10"`. Exit is `0`. The result opens with a restatement, then names the root cause (the last line has no trailing newline, so `read` drops it), the fix, and loop output showing `6` before and `10` after.
- **Check routing.** `grep '^Agent' $E/diag-1.tools.tsv` shows `debugger`, then `verifier`. `awk -F'\t' '$3=="main" && ($1=="Edit" || $1=="Write")' $E/diag-1.tools.tsv` is empty: only `sub:debugger` edits code.
- **Check nothing committed.** `$E/diag-1.state.txt` shows `tools/sum.sh` modified and a new test file in porcelain, and the log still ends at `verify fixture: tools/sum.sh`.
- **Check the fix.** `bash $S/tools/sum.sh $S/tools/numbers.txt` prints `10`.
- **Commit.** Run `$A $V drive --continue diag-2 "go ahead and commit"`. `git -C $S log --oneline --all` shows `fix: …` on top of `test: reproduce …`, `git -C $S show --stat HEAD~1` holds only the test file, and `HEAD` only `tools/sum.sh`. To see red then green: `git -C $S checkout -q HEAD~1 && bash $S/tools/sum_test.sh` fails, and it passes on the branch tip.
- **No loop.** On a fresh launch, run `$A $V drive diag-noloop "/diagnose the app crashes sometimes on startup"`. The result reports `NO LOOP` with what the debugger needs, and `state.txt` shows a clean porcelain.

## Gotchas

- The commits land on a new branch the agent names (`fix/sum-trailing-newline` in one run, `fix/sum-unterminated-last-line` in another), not on `main`; Claude Code's own default is to branch before committing on the default branch. Assert on `--all`, not on `main`.
- Commands with `$(...)`, `$?` or writes to `/tmp` are denied whatever the allowlist says. Both runs hit several such denials and still finished; the result may ask the user to run the exact command once.
- The debugger picks its own loop and test shape (a shell test, a bats-style script, a diff against expected output). Assert that a red-capable command exists and went red then green, not on its name.
- A test that the fix commit also touches breaks the red-then-green history; check `git show --stat` on both commits.
- The allowlist above is wide on purpose. If the debugger hits a denial, the result names the denied command; widen once and record it here.
- The verifier inside the sandbox finds no verification skill (launch leaves this skill out), so its map gap line says so. That is expected.
