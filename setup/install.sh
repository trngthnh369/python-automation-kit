#!/bin/bash
set -e

KIT_NAME="python-automation-kit"
KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AGENT="${1:-}"

# Auto-detect agent
if [ -z "$AGENT" ]; then
  if [ -d ".agents" ]; then AGENT="antigravity"
  elif [ -d ".claude" ]; then AGENT="claude-code"
  elif [ -d ".gemini" ]; then AGENT="gemini-cli"
  elif [ -d ".cursor" ]; then AGENT="cursor"
  else AGENT="antigravity"; fi
fi

case $AGENT in
  antigravity) SKILLS_DIR=".agents/skills/$KIT_NAME" ;;
  claude-code) SKILLS_DIR=".claude/skills/$KIT_NAME" ;;
  gemini-cli)  SKILLS_DIR=".gemini/skills/$KIT_NAME" ;;
  cursor)      SKILLS_DIR=".cursor/skills/$KIT_NAME" ;;
esac

echo "🐍 Installing $KIT_NAME for $AGENT..."

rm -rf "$SKILLS_DIR"
mkdir -p "$SKILLS_DIR"

for item in _moc.md _registry.yaml kit.json tier-1-orchestrators tier-2-hubs tier-3-utilities tier-4-domains; do
  [ -e "$KIT_ROOT/$item" ] && cp -r "$KIT_ROOT/$item" "$SKILLS_DIR/"
done

echo "✅ Installed to $SKILLS_DIR"
echo "📖 Entry point: $SKILLS_DIR/_moc.md"
