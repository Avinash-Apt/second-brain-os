#!/usr/bin/env bash
# vault-sync.sh
#
# Ledger-style sync for the Second Brain. Commit local work, rebase onto
# whatever another device pushed, push. Straight to main, no pull requests.
#
# Safe to run concurrently: a lock makes extra runs exit immediately.
# Safe to run offline: no network means it commits locally and exits 0.
# Never auto-resolves a conflict. It stops, restores state, and shouts.
#
# Usage:  vault-sync.sh [pull-only] [--quiet]

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT="${VAULT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
LOCK="${TMPDIR:-/tmp}/vault-sync.lock"
if [ "$(uname)" = "Darwin" ]; then LOG="$HOME/Library/Logs/vault-sync.log"; else LOG="$HOME/.local/state/vault-sync.log"; fi
STALE_LOCK_MIN=15

MODE="full"; QUIET=0
for arg in "$@"; do
  case "$arg" in
    pull-only) MODE="pull-only" ;;
    --quiet)   QUIET=1 ;;
  esac
done

mkdir -p "$(dirname "$LOG")"

log() { printf '%s  %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG"; }
say() { [ "$QUIET" -eq 0 ] && printf '%s\n' "$*"; log "$*"; }

notify() {
  if command -v osascript >/dev/null 2>&1; then
    osascript -e "display notification \"$1\" with title \"Vault sync\" sound name \"Basso\"" 2>/dev/null || true
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "Vault sync" "$1" 2>/dev/null || true
  fi
}

# ---- lock ----------------------------------------------------------------
if ! mkdir "$LOCK" 2>/dev/null; then
  if [ -n "$(find "$LOCK" -maxdepth 0 -mmin +$STALE_LOCK_MIN 2>/dev/null)" ]; then
    log "clearing stale lock"
    rm -rf "$LOCK"; mkdir "$LOCK" 2>/dev/null || exit 0
  else
    exit 0   # another run is in flight, nothing to do
  fi
fi
trap 'rm -rf "$LOCK"' EXIT

# ---- preflight -----------------------------------------------------------
cd "$VAULT" 2>/dev/null || { log "FATAL vault not found at $VAULT"; exit 1; }
git rev-parse --git-dir >/dev/null 2>&1 || { log "FATAL not a git repo"; exit 1; }
git remote get-url origin >/dev/null 2>&1 || { log "FATAL no origin remote"; exit 1; }

BRANCH="$(git rev-parse --abbrev-ref HEAD)"

# A rebase or merge left half-finished blocks everything. Do not paper over it.
if [ -d "$(git rev-parse --git-path rebase-merge)" ] || [ -d "$(git rev-parse --git-path rebase-apply)" ] || [ -f "$(git rev-parse --git-path MERGE_HEAD)" ]; then
  say "BLOCKED: repo is mid-rebase or mid-merge. Resolve by hand, then rerun."
  notify "Vault is mid-rebase. Resolve by hand."
  exit 1
fi

ONLINE=0
git ls-remote --exit-code origin >/dev/null 2>&1 && ONLINE=1

# ---- 1. commit local work first (committed beats stashed) -----------------
if [ "$MODE" != "pull-only" ]; then
  git add -A
  if ! git diff --cached --quiet; then
    N=$(git diff --cached --name-only | wc -l | tr -d ' ')
    # top-level folders only; root-level files collapse to "root"
    AREAS=$(git diff --cached --name-only \
      | awk -F/ '{ if (NF>1) print $1; else print "root" }' \
      | sort -u | head -3 | tr '\n' '|' | sed 's/|$//; s/|/, /g')
    [ -z "$AREAS" ] && AREAS="vault"
    HOST=$(scutil --get ComputerName 2>/dev/null || hostname -s)
    git commit --quiet -m "vault: ${N} file(s) in ${AREAS}" -m "device: ${HOST}"
    say "committed ${N} file(s) in ${AREAS}"
  fi
fi

if [ "$ONLINE" -eq 0 ]; then
  say "offline: committed locally, will push on the next run"
  exit 0
fi

# ---- 2. rebase onto whatever another device pushed ------------------------
# pull-only runs at session start and may meet a dirty working tree, so it
# stashes around the rebase. The full path has already committed, so it does not.
PULL_ARGS=(--rebase --quiet)
[ "$MODE" = "pull-only" ] && PULL_ARGS+=(--autostash)

if ! git pull "${PULL_ARGS[@]}" origin "$BRANCH" 2>>"$LOG"; then
  git rebase --abort 2>/dev/null
  say "CONFLICT: pull --rebase failed and was rolled back. Nothing was lost."
  say "  Resolve:  cd \"$VAULT\" && git pull --rebase   then fix, then: git rebase --continue"
  notify "Vault sync conflict. Local work is safe but unpushed."
  exit 1
fi

# ---- 3. push -------------------------------------------------------------
if [ "$MODE" = "pull-only" ]; then
  say "pulled, up to date"
  exit 0
fi

if ! git push --quiet origin "$BRANCH" 2>>"$LOG"; then
  # another device pushed between our rebase and our push. Rebase once more.
  if git pull --rebase --quiet origin "$BRANCH" 2>>"$LOG" && git push --quiet origin "$BRANCH" 2>>"$LOG"; then
    say "pushed after retry"
    exit 0
  fi
  git rebase --abort 2>/dev/null
  say "PUSH FAILED. Work is committed locally and safe. Will retry next run."
  notify "Vault push failed. Work is committed but unpushed."
  exit 1
fi

say "synced"
