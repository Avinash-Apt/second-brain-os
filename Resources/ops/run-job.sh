#!/usr/bin/env bash
# run-job.sh
#
# Runs one scheduled vault job headless with the chosen agent CLI.
# The job prompt lives in Resources/vault-operator/<job>.md.
#
# Usage:  run-job.sh <daily-operator|weekly-optimizer> [claude|codex|grok]
#         Agent defaults to $SECOND_BRAIN_AGENT, then claude.
#
# Each job pulls first and syncs after, so a run on any device lands on GitHub.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT="${VAULT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
JOB="${1:?usage: run-job.sh <job> [claude|codex|grok]}"
AGENT="${2:-${SECOND_BRAIN_AGENT:-claude}}"
PROMPT_FILE="$VAULT/Resources/vault-operator/$JOB.md"
if [ "$(uname)" = "Darwin" ]; then LOGDIR="$HOME/Library/Logs"; else LOGDIR="$HOME/.local/state"; fi
LOG="$LOGDIR/second-brain-$JOB.log"

# launchd and cron start with a bare PATH. Add the usual install locations.
export PATH="$HOME/.local/bin:$HOME/.grok/bin:/opt/homebrew/bin:/usr/local/bin:$HOME/.npm-global/bin:$PATH"

mkdir -p "$LOGDIR"
[ -f "$PROMPT_FILE" ] || { echo "no prompt at $PROMPT_FILE" >> "$LOG"; exit 1; }
cd "$VAULT" || exit 1

PROMPT="You are running the scheduled job '$JOB' in this vault. Read AGENTS.md, then read Resources/vault-operator/$JOB.md and execute it exactly. Today is $(date +%Y-%m-%d). Do not ask questions."

{
  echo "==== $(date '+%Y-%m-%d %H:%M:%S') $JOB via $AGENT"
  [ -x "$SCRIPT_DIR/vault-sync.sh" ] && "$SCRIPT_DIR/vault-sync.sh" pull-only --quiet

  case "$AGENT" in
    claude)
      # Permissions come from .claude/settings.json (permissions.allow).
      # Add each connected MCP server there, e.g. "mcp__fireflies".
      claude -p "$PROMPT" --permission-mode acceptEdits ${CLAUDE_JOB_FLAGS:-}
      ;;
    codex)
      codex exec -C "$VAULT" -s workspace-write ${CODEX_JOB_FLAGS:-} "$PROMPT"
      ;;
    grok)
      grok -p "$PROMPT" --cwd "$VAULT" --always-approve ${GROK_JOB_FLAGS:-}
      ;;
    *)
      echo "unknown agent: $AGENT"; exit 1
      ;;
  esac
  STATUS=$?

  [ -x "$SCRIPT_DIR/vault-sync.sh" ] && "$SCRIPT_DIR/vault-sync.sh" --quiet
  echo "==== exit $STATUS"
} >> "$LOG" 2>&1
