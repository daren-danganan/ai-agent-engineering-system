#!/usr/bin/env bash
# Harness for verify-agent-system. Drives this repo's agents and slash commands
# through the real `claude` CLI inside a disposable copy of the working tree.
# Usage is documented in SKILL.md next to this file.
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(git -C "$SKILL_DIR" rev-parse --show-toplevel)"
HOME_DIR="${VERIFY_HOME:-$HOME/.cache/verify-agent-system}"
SKILL_REL=".claude/skills/verify-agent-system"
ALLOWED_TOOLS="${VERIFY_ALLOWED_TOOLS:-Read Glob Grep Edit Write Agent Task WebSearch WebFetch Bash(git:*) Bash(ls:*) Bash(cat:*) Bash(date:*) Bash(test:*) Bash(grep:*)}"
BUDGET_USD="${VERIFY_BUDGET_USD:-3}"
# User-scope commands in ~/.claude/commands override the sandbox's project
# commands of the same name (measured 2026-10-17), so drives load project and
# local settings only. This also keeps user MCP servers and CLAUDE.md out.
SETTING_SOURCES="${VERIFY_SETTING_SOURCES:-project,local}"

die() { echo "verify: $*" >&2; exit 1; }

# The run to act on: $VERIFY_RUN, else the most recent launch.
resolve_run() {
  RUN_ID="${VERIFY_RUN:-$(cat "$HOME_DIR/current" 2>/dev/null || true)}"
  [ -n "$RUN_ID" ] || die "no run; start one with: verify.sh launch"
  RUN_DIR="$HOME_DIR/$RUN_ID"
  SANDBOX="$RUN_DIR/sandbox"
  EVIDENCE="$RUN_DIR/evidence"
}

need_sandbox() {
  resolve_run
  [ -f "$RUN_DIR/meta" ] && [ -d "$SANDBOX/.git" ] || die "run $RUN_ID has no sandbox (cleaned up?); run: verify.sh launch"
}

# Claude Code session env from a parent session must not leak into the drive.
clean_env() {
  env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT -u CLAUDE_CODE_SESSION_ID \
      -u CLAUDE_CODE_CHILD_SESSION -u CLAUDE_CODE_SESSION_ATTENDED \
      -u CLAUDE_CODE_MESSAGING_SOCKET -u CLAUDE_CODE_MESSAGING_TOKEN \
      -u CLAUDE_PID -u CLAUDE_EFFORT "$@"
}

sandbox_git() { git -C "$SANDBOX" "$@"; }

cmd_launch() {
  RUN_ID="$(date +%Y%m%d-%H%M%S)-$$"
  RUN_DIR="$HOME_DIR/$RUN_ID"; SANDBOX="$RUN_DIR/sandbox"; EVIDENCE="$RUN_DIR/evidence"
  mkdir -p "$SANDBOX" "$EVIDENCE"

  # Copy the working tree as it is now (tracked + untracked, minus ignored and
  # minus this skill), so the drive exercises uncommitted changes too.
  # VERIFY_EXCLUDE (space-separated folders) keeps out files that would give a
  # drive the answer, such as a spec that names the expected verdict.
  git -C "$REPO" ls-files -co --exclude-standard -z | while IFS= read -r -d '' f; do
    case "$f" in "$SKILL_REL"/*) continue ;; esac
    for x in ${VERIFY_EXCLUDE:-}; do case "$f" in "$x"/*) continue 2 ;; esac; done
    [ -f "$REPO/$f" ] || continue
    mkdir -p "$SANDBOX/$(dirname "$f")"
    cp -p "$REPO/$f" "$SANDBOX/$f"
  done

  git -C "$SANDBOX" init -q -b main
  sandbox_git config user.name "verify-agent-system"
  sandbox_git config user.email "verify@localhost"
  sandbox_git add -A
  sandbox_git commit -q -m "verify baseline"

  {
    echo "run=$RUN_ID"
    echo "repo=$REPO"
    echo "repo_head=$(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo none)"
    echo "excluded=${VERIFY_EXCLUDE:-}"
    echo "repo_dirty_files=$(git -C "$REPO" status --porcelain | wc -l | tr -d ' ')"
    echo "claude=$(claude --version 2>&1)"
  } > "$RUN_DIR/meta"
  cp "$RUN_DIR/meta" "$EVIDENCE/meta.txt"
  echo "$RUN_ID" > "$HOME_DIR/current"

  echo "run:      $RUN_ID"
  echo "sandbox:  $SANDBOX"
  echo "evidence: $EVIDENCE"
  echo "ready"
}

cmd_doctor() {
  resolve_run
  local ok=0
  check() { if eval "$2" >/dev/null 2>&1; then echo "ok    $1"; else echo "FAIL  $1"; ok=1; fi; }
  echo "run:      $RUN_ID"
  echo "sandbox:  $SANDBOX"
  check "sandbox was created by a launch (meta file)"      '[ -f "$RUN_DIR/meta" ]'
  check "sandbox is its own git repo"                      '[ -d "$SANDBOX/.git" ]'
  check "sandbox is not the real repo"                     '[ "$(cd "$SANDBOX" && pwd -P)" != "$(cd "$REPO" && pwd -P)" ]'
  check "claude CLI on PATH"                               'command -v claude'
  check "claude is logged in"                              'clean_env claude auth status'
  check "agents match the repo working tree"               'diff -r "$REPO/.claude/agents" "$SANDBOX/.claude/agents"'
  check "commands match the repo working tree"             'diff -r "$REPO/.claude/commands" "$SANDBOX/.claude/commands"'
  check "CLAUDE.md matches the repo working tree"          'diff "$REPO/CLAUDE.md" "$SANDBOX/CLAUDE.md"'
  check "docs/agents matches the repo working tree"        'diff -r "$REPO/docs/agents" "$SANDBOX/docs/agents"'
  check "scripts match the repo working tree"              'diff -r "$REPO/.claude/scripts" "$SANDBOX/.claude/scripts"'
  # A global install (install-global.sh) puts same-named agents and commands in
  # ~/.claude. A user command beats the project one unless drives exclude user
  # settings (they do, via --setting-sources). Agents resolve to the project.
  local dup=""
  for d in agents commands; do
    for f in "$HOME/.claude/$d"/*.md; do
      [ -e "$f" ] && [ -e "$SANDBOX/.claude/$d/$(basename "$f")" ] && dup="$dup $d/$(basename "$f")"
    done
  done
  [ -z "$dup" ] || echo "warn  same-named files in ~/.claude:$dup (drives use --setting-sources $SETTING_SOURCES; never set VERIFY_SETTING_SOURCES to include user)"
  if [ -d "$SANDBOX/.git" ]; then
    echo "branch:   $(sandbox_git branch --show-current)"
    echo "dirty:    $(sandbox_git status --porcelain | wc -l | tr -d ' ') file(s)"
    echo "agents:   $(ls "$SANDBOX/.claude/agents" 2>/dev/null | tr '\n' ' ')"
    echo "commands: $(ls "$SANDBOX/.claude/commands" 2>/dev/null | tr '\n' ' ')"
  fi
  [ "$ok" -eq 0 ] && echo "healthy" || { echo "unhealthy: run cleanup, then launch again"; return 1; }
}

# Record the sandbox's git state under a label.
capture_state() {
  {
    echo "## branch";  sandbox_git branch --show-current
    echo "## branches"; sandbox_git branch --list
    echo "## status --porcelain (empty = clean)"; sandbox_git status --porcelain
    echo "## log --oneline --all"; sandbox_git log --oneline --all --decorate
    echo "## files changed since baseline"
    sandbox_git diff --stat "$(sandbox_git rev-list --max-parents=0 HEAD | tail -1)" || true
  } > "$EVIDENCE/$1.state.txt" 2>&1
}

cmd_state() {
  need_sandbox
  [ $# -ge 1 ] || die "usage: verify.sh state <label>"
  capture_state "$1"
  cat "$EVIDENCE/$1.state.txt"
}

cmd_drive() {
  need_sandbox
  local cont=()
  if [ "${1:-}" = "--continue" ]; then cont=(--continue); shift; fi
  [ $# -ge 2 ] || die "usage: verify.sh drive [--continue] <label> <prompt> [extra claude args...]"
  local label="$1" prompt="$2"; shift 2
  local base="$EVIDENCE/$label"
  [ ! -e "$base.stream.jsonl" ] || die "label '$label' already used in this run; pick another"

  printf '%s\n' "$prompt" > "$base.prompt.txt"
  local code=0
  # shellcheck disable=SC2086
  (cd "$SANDBOX" && clean_env claude -p "$prompt" ${cont[@]+"${cont[@]}"} \
      --output-format stream-json --verbose \
      --permission-mode acceptEdits \
      --setting-sources "$SETTING_SOURCES" \
      --allowedTools $ALLOWED_TOOLS \
      --max-budget-usd "$BUDGET_USD" "$@" \
      > "$base.stream.jsonl" 2> "$base.stderr.txt") || code=$?
  echo "$code" > "$base.exit.txt"

  # Final answer as the user would read it, plus which tools/subagents ran.
  jq -r 'select(.type=="result") | .result // empty' "$base.stream.jsonl" > "$base.result.md" 2>/dev/null || true
  # Columns: tool, target, who ran it ("main", or "sub:<subagent type>").
  jq -rs '
    [ .[] | select(.type=="assistant") | . as $m | .message.content[]? | select(.type=="tool_use")
      | {id, name, sub: (.input.subagent_type // null), p: $m.parent_tool_use_id,
         t: (.input.subagent_type // .input.file_path // .input.command // .input.pattern // "")} ] as $c
    | ($c | map(select(.name=="Agent" or .name=="Task")) | map({key: .id, value: (.sub // "?")}) | from_entries) as $ag
    | $c[] | [.name, (.t | tostring), (if .p then "sub:" + ($ag[.p] // "?") else "main" end)] | @tsv' \
     "$base.stream.jsonl" > "$base.tools.tsv" 2>/dev/null || true
  capture_state "$label"

  # A drive that never reached the model proves nothing; say so loudly.
  if grep -qi 'failed to authenticate\|not logged in\|invalid api key' "$base.result.md" "$base.stderr.txt" 2>/dev/null; then
    echo "verify: claude is not logged in; this drive did not run. Run 'claude auth login' in a terminal, then drive again with a new label." >&2
  fi

  echo "exit:     $code"
  echo "result:   $base.result.md"
  echo "tools:    $base.tools.tsv"
  echo "state:    $base.state.txt"
  echo "stream:   $base.stream.jsonl"
  return "$code"
}

# Put the fixture spec and ticket into the sandbox's .scratch/ and commit them,
# so /implement starts from the clean tree it requires.
cmd_seed_tickets() {
  need_sandbox
  mkdir -p "$SANDBOX/.scratch"
  cp -R "$SKILL_DIR/fixtures/verify-hello" "$SANDBOX/.scratch/"
  sandbox_git add .scratch/verify-hello
  sandbox_git commit -q -m "verify fixture: verify-hello spec and ticket"
  echo "seeded:   .scratch/verify-hello/ (spec.md, issues/01-add-hello-file.md, committed)"
}

# Put a small, known bug into the sandbox and commit it, so /diagnose has a real
# symptom to chase: tools/sum.sh drops the last line of a file that has no
# trailing newline (tools/numbers.txt sums to 6, expected 10).
cmd_seed_bug() {
  need_sandbox
  cp -R "$SKILL_DIR/fixtures/sum-bug/." "$SANDBOX/"
  sandbox_git add tools
  sandbox_git commit -q -m "verify fixture: tools/sum.sh"
  echo "seeded:   tools/sum.sh, tools/numbers.txt (committed); 'bash tools/sum.sh tools/numbers.txt' prints 6, expected 10"
}

cmd_cleanup() {
  resolve_run
  [ -f "$RUN_DIR/meta" ] || die "run $RUN_ID was not created by launch; refusing to delete"
  # Session transcripts Claude Code stored for the sandbox directory.
  local real proj
  if [ -d "$SANDBOX" ]; then
    real="$(cd "$SANDBOX" && pwd -P)"
    proj="$HOME/.claude/projects/$(printf '%s' "$real" | sed 's/[^A-Za-z0-9]/-/g')"
    case "$proj" in *verify-agent-system*sandbox) [ -d "$proj" ] && rm -rf "$proj" ;; esac
    rm -rf "$SANDBOX"
  fi
  [ "$(cat "$HOME_DIR/current" 2>/dev/null || true)" != "$RUN_ID" ] || rm -f "$HOME_DIR/current"
  echo "removed:  $SANDBOX"
  echo "kept:     $EVIDENCE"
}

case "${1:-}" in
  launch)    shift; cmd_launch "$@" ;;
  doctor)    shift; cmd_doctor "$@" ;;
  drive)     shift; cmd_drive "$@" ;;
  state)     shift; cmd_state "$@" ;;
  seed-tickets) shift; cmd_seed_tickets "$@" ;;
  seed-bug)  shift; cmd_seed_bug "$@" ;;
  cleanup)   shift; cmd_cleanup "$@" ;;
  *) die "usage: verify.sh {launch|doctor|drive|state|seed-tickets|seed-bug|cleanup}" ;;
esac
