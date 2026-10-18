#!/usr/bin/env bash
# Roll up feature and ticket progress from .scratch/.
#   status.sh            every feature
#   status.sh <slug>     one feature, with every ticket listed
# Read-only. Conventions: docs/agents/issue-tracker.md and triage-labels.md.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SCRATCH="$ROOT/.scratch"
ONLY="${1:-}"

[ -d "$SCRATCH" ] || { echo "No .scratch/ here. Start a feature with /grill."; exit 0; }

# First value of a "Label:" line, CR-stripped. Accepts Label:, **Label:**
# and **Label**: (colon inside or outside the bold).
field_of() { # file label
  tr -d '\r' < "$1" | sed -n "s/^\**$2\**:\**[[:space:]]*//p" | head -1
}
status_of() { field_of "$1" Status | tr -d '*` ' | tr '[:upper:]' '[:lower:]'; }
title_of() { tr -d '\r' < "$1" | sed -n '1s/^#[[:space:]]*//p'; }
blockers_of() {
  field_of "$1" 'Blocked by' | grep -oE '[0-9]+' | sed 's/^0*//' || true
}
# A blocker is cleared once its work has landed: done or resolved.
# wontfix does not clear it — the work the dependent needs will never land.
clears_blocker() { case "$1" in done|resolved) return 0 ;; *) return 1 ;; esac; }
ticket_status() { # dir num -> status of issues/NN-*.md, or "missing"
  local f; f="$(ls "$1"/issues/"$(printf '%02d' "$2")"-*.md 2>/dev/null | head -1 || true)"
  [ -n "$f" ] && status_of "$f" || echo missing
}

found=0
for dir in "$SCRATCH"/*/; do
  dir="${dir%/}"; slug="$(basename "$dir")"
  [ -z "$ONLY" ] || [ "$slug" = "$ONLY" ] || continue
  found=1

  fstatus="no spec"
  [ -f "$dir/spec.md" ] && fstatus="$(status_of "$dir/spec.md")" && fstatus="${fstatus:-no status}"

  total=0 done=0 ready=0 blocked=0 other=0
  lines=""
  for t in "$dir"/issues/[0-9]*.md; do
    [ -e "$t" ] || continue
    total=$((total+1))
    name="$(basename "$t" .md)"; num="${name%%-*}"; st="$(status_of "$t")"
    case "$st" in
      done) done=$((done+1)); kind=done ;;
      ready-for-agent)
        waiting=""
        for b in $(blockers_of "$t"); do
          clears_blocker "$(ticket_status "$dir" "$b")" || waiting="$waiting $(printf '%02d' "$b")"
        done
        if [ -z "$waiting" ]; then ready=$((ready+1)); kind=ready
        else blocked=$((blocked+1)); kind="blocked by${waiting}"; fi ;;
      *) other=$((other+1)); kind="${st:-no status}" ;;
    esac
    if [ -n "$ONLY" ] || [ "$kind" != done ]; then
      lines="$lines    $num  $kind  — $(title_of "$t" | sed 's/^[0-9]*:[[:space:]]*//')
"
    fi
  done

  if [ "$total" -eq 0 ]; then
    printf '%-28s %-16s no tickets\n' "$slug" "$fstatus"
  else
    printf '%-28s %-16s %d/%d done · %d ready · %d blocked · %d other\n' \
      "$slug" "$fstatus" "$done" "$total" "$ready" "$blocked" "$other"
    [ "$fstatus" = shipped ] && [ -z "$ONLY" ] || printf '%s' "$lines"
  fi
done

[ "$found" -eq 1 ] || { echo "No feature '$ONLY' under .scratch/."; exit 1; }
