#!/usr/bin/env bash
# Regression tests for status.sh. Builds throwaway git repos with .scratch/
# fixtures under $TMPDIR, runs status.sh in them, and asserts the output.
#   bash .claude/scripts/status.test.sh
set -uo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/status.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/status-test.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
pass=0 fail=0

# new_repo -> path of a fresh git repo with an empty .scratch/
new_repo() {
  local r; r="$(mktemp -d "$WORK/repo.XXXXXX")"
  mkdir -p "$r/.scratch" && git -C "$r" init -q && echo "$r"
}
# spec repo slug status-line [crlf]
spec() {
  mkdir -p "$1/.scratch/$2/issues"
  printf '# Feature %s\n\n%s\n\n## Problem Statement\nx\n' "$2" "$3" > "$1/.scratch/$2/spec.md"
  [ "${4:-}" = crlf ] && to_crlf "$1/.scratch/$2/spec.md"
  return 0
}
# ticket repo slug NN-name title status-line blocked-line [crlf]
ticket() {
  local f="$1/.scratch/$2/issues/$3.md"
  printf '# %s\n\n**What to build:** x\n\n%s\n\n%s\n\n- [ ] y\n' "$4" "$6" "$5" > "$f"
  [ "${7:-}" = crlf ] && to_crlf "$f"
  return 0
}
to_crlf() { sed 's/$/\r/' "$1" > "$1.tmp" && mv "$1.tmp" "$1"; }
run() { (cd "$1" && bash "$SCRIPT" "$2" 2>&1); }

# check name output fixed-string-that-must-appear
check() {
  if printf '%s\n' "$2" | grep -qF -- "$3"; then pass=$((pass+1))
  else fail=$((fail+1)); printf 'FAIL %s\n  expected to contain: %s\n  got:\n%s\n' "$1" "$3" "$(printf '%s\n' "$2" | sed 's/^/    | /' | tr '\r' '~')"; fi
}
check_no_cr() {
  if printf '%s' "$2" | grep -q "$(printf '\r')"; then
    fail=$((fail+1)); printf 'FAIL %s\n  output contains \\r (shown as ~):\n%s\n' "$1" "$(printf '%s\n' "$2" | tr '\r' '~' | sed 's/^/    | /')"
  else pass=$((pass+1)); fi
}

# --- blocker states -------------------------------------------------------
for case in "done:1 ready · 0 blocked:02  ready" \
            "resolved:1 ready · 0 blocked:02  ready" \
            "wontfix:0 ready · 1 blocked:02  blocked by 01" \
            "in-progress:0 ready · 1 blocked:02  blocked by 01"; do
  st="${case%%:*}"; rest="${case#*:}"; counts="${rest%%:*}"; line="${rest#*:}"
  r="$(new_repo)"; spec "$r" feat "Status: building"
  ticket "$r" feat 01-blocker "01: Blocker" "**Status:** $st" "**Blocked by:** None"
  ticket "$r" feat 02-dependent "02: Dependent" "**Status:** ready-for-agent" "**Blocked by:** #01"
  out="$(run "$r" feat)"
  check "blocker $st: counts" "$out" "$counts"
  check "blocker $st: dependent line" "$out" "$line"
done

# --- Status line spellings ------------------------------------------------
for form in "Status: building" "**Status:** building" "**Status**: building" "Status:building"; do
  r="$(new_repo)"; spec "$r" feat "$form"
  ticket "$r" feat 01-one "01: One" "$form" "**Blocked by:** None"
  out="$(run "$r" feat)"
  check "spec '$form'" "$out" "feat                         building"
  check "ticket '$form'" "$out" "01  building  — One"
done
for form in "Status: done" "**Status:** done" "**Status**: done"; do
  r="$(new_repo)"; spec "$r" feat "Status: building"
  ticket "$r" feat 01-one "01: One" "$form" "**Blocked by:** None"
  out="$(run "$r" feat)"
  check "ticket '$form' counts done" "$out" "1/1 done"
done

# --- Blocked by spellings -------------------------------------------------
for form in "**Blocked by:** #01" "**Blocked by**: #01" "Blocked by: 01"; do
  r="$(new_repo)"; spec "$r" feat "Status: building"
  ticket "$r" feat 01-blocker "01: Blocker" "**Status:** in-progress" "**Blocked by:** None"
  ticket "$r" feat 02-dependent "02: Dependent" "**Status:** ready-for-agent" "$form"
  out="$(run "$r" feat)"
  check "'$form'" "$out" "02  blocked by 01"
done

# --- CRLF files -----------------------------------------------------------
r="$(new_repo)"; spec "$r" feat "**Status:** building" crlf
ticket "$r" feat 01-blocker "01: Blocker" "**Status:** done" "**Blocked by:** None" crlf
ticket "$r" feat 02-dependent "02: Dependent" "**Status:** ready-for-agent" "**Blocked by:** #01" crlf
ticket "$r" feat 03-waiting "03: Waiting" "**Status:** ready-for-agent" "**Blocked by:** #04" crlf
ticket "$r" feat 04-busy "04: Busy" "**Status:** in-progress" "**Blocked by:** None" crlf
out="$(run "$r" feat)"
check "crlf: spec status" "$out" "feat                         building "
check "crlf: counts" "$out" "1/4 done · 1 ready · 1 blocked · 1 other"
check "crlf: done blocker clears" "$out" "02  ready  — Dependent"
check "crlf: blocker parsed" "$out" "03  blocked by 04  — Waiting"
check "crlf: other status" "$out" "04  in-progress  — Busy"
check_no_cr "crlf: no \\r in output (one feature)" "$out"
check_no_cr "crlf: no \\r in output (all features)" "$(run "$r" "")"

echo "status.test.sh: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
