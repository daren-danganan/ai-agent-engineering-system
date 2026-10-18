#!/usr/bin/env bash
# Install this agent kit into ~/.claude so every project can use it.
# Re-run any time to update. Existing files with the same names are backed up first.
#
#   ./install-global.sh            add the kit, keep your other global agents and commands
#   ./install-global.sh --replace  move ALL existing global agents, commands and skills to a backup
#                                  first, so only the kit remains
set -euo pipefail

REPLACE=0
[ "${1:-}" = "--replace" ] && REPLACE=1

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${CLAUDE_HOME:-$HOME/.claude}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$DEST/agent-kit-backup/$STAMP"

mkdir -p "$DEST/agents" "$DEST/commands" "$DEST/agent-kit"

backup_if_exists() {
  if [ -e "$1" ] && ! cmp -s "$1" "$2"; then
    mkdir -p "$BACKUP/$(basename "$(dirname "$1")")"
    cp "$1" "$BACKUP/$(basename "$(dirname "$1")")/"
  fi
}

# Rewrite repo-relative pointers so they resolve from any project.
rewrite() {
  sed -e 's#\.\./\.\./docs/agents/principles\.md#~/.claude/agent-kit/principles.md#g' \
      -e 's#docs/agents/principles\.md#~/.claude/agent-kit/principles.md#g' \
      -e 's#docs/agents/flows\.md#~/.claude/agent-kit/flows.md#g' \
      -e 's#docs/agents/triage-labels\.md#~/.claude/agent-kit/triage-labels.md#g' \
      -e 's#`docs/agents/domain\.md`#`docs/agents/domain.md` (or `~/.claude/agent-kit/domain.md` when the project has none)#g' \
      -e 's#docs/agents/glossary\.md#~/.claude/agent-kit/glossary.md#g' \
      -e 's#`\.claude/agents/griller\.md`#`~/.claude/agents/griller.md`#g' \
      -e 's#`\.claude/commands/review\.md`#`~/.claude/commands/review.md`#g' \
      -e 's#\.claude/scripts/status\.sh#~/.claude/agent-kit/status.sh#g' \
      "$1"
}

install_file() { # src dest
  local tmp; tmp="$(mktemp)"
  rewrite "$1" > "$tmp"
  backup_if_exists "$2" "$tmp"
  mv "$tmp" "$2"
  echo "  $2"
}

if [ "$REPLACE" -eq 1 ]; then
  for d in agents commands skills; do
    if [ -d "$DEST/$d" ] && [ -n "$(ls -A "$DEST/$d")" ]; then
      mkdir -p "$BACKUP"
      mv "$DEST/$d" "$BACKUP/$d"
      mkdir -p "$DEST/$d"
      echo "Moved existing $DEST/$d to $BACKUP/$d"
    fi
  done
fi

echo "Installing agent kit into $DEST"
for f in "$KIT"/.claude/agents/*.md;   do install_file "$f" "$DEST/agents/$(basename "$f")"; done
for f in "$KIT"/.claude/commands/*.md; do install_file "$f" "$DEST/commands/$(basename "$f")"; done
for f in principles flows triage-labels domain glossary; do install_file "$KIT/docs/agents/$f.md" "$DEST/agent-kit/$f.md"; done
install_file "$KIT/.claude/scripts/status.sh" "$DEST/agent-kit/status.sh" && chmod +x "$DEST/agent-kit/status.sh"

[ -d "$BACKUP" ] && echo "Backed up replaced files to $BACKUP"
echo "Done. Restart Claude Code, then check with /agents and by typing /grill."
