#!/usr/bin/env bash
# install-schedules.sh
#
# Installs the vault's background schedules on an always-on machine.
# macOS: launchd agents in ~/Library/LaunchAgents. Linux: crontab entries.
#
# Usage:  install-schedules.sh sync          # vault-sync every 10 minutes
#         install-schedules.sh jobs          # daily operator + weekly optimizer
#         install-schedules.sh all
#         install-schedules.sh uninstall
#
# Settings (env vars, all optional):
#   SECOND_BRAIN_AGENT=claude|codex|grok   agent that runs the jobs (default claude)
#   DAILY_HOUR=7   DAILY_MINUTE=0          daily operator time, local
#   WEEKLY_WEEKDAY=0 WEEKLY_HOUR=18 WEEKLY_MINUTE=0   weekly optimizer (0 = Sunday)
#   SYNC_INTERVAL_MIN=10

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT="${VAULT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
WHAT="${1:-all}"
AGENT="${SECOND_BRAIN_AGENT:-claude}"
DAILY_HOUR="${DAILY_HOUR:-7}"; DAILY_MINUTE="${DAILY_MINUTE:-0}"
WEEKLY_WEEKDAY="${WEEKLY_WEEKDAY:-0}"; WEEKLY_HOUR="${WEEKLY_HOUR:-18}"; WEEKLY_MINUTE="${WEEKLY_MINUTE:-0}"
SYNC_INTERVAL_MIN="${SYNC_INTERVAL_MIN:-10}"
TAG="second-brain-os"

chmod +x "$SCRIPT_DIR"/*.sh

# ---------------------------------------------------------------- macOS --
mac_plist() {  # label, program args (xml), schedule (xml)
  local label="$1" args="$2" sched="$3" file="$HOME/Library/LaunchAgents/$1.plist"
  mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
  cat > "$file" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$label</string>
  <key>ProgramArguments</key>
  <array>
$args
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>SECOND_BRAIN_AGENT</key><string>$AGENT</string>
    <key>VAULT_DIR</key><string>$VAULT</string>
  </dict>
$sched
  <key>StandardOutPath</key><string>$HOME/Library/Logs/$label.log</string>
  <key>StandardErrorPath</key><string>$HOME/Library/Logs/$label.log</string>
  <key>ProcessType</key><string>Background</string>
</dict>
</plist>
PLIST
  launchctl unload "$file" 2>/dev/null || true
  launchctl load "$file"
  echo "installed $label"
}

mac_install_sync() {
  mac_plist "com.$TAG.vault-sync" \
"    <string>/bin/bash</string>
    <string>$SCRIPT_DIR/vault-sync.sh</string>
    <string>--quiet</string>" \
"  <key>StartInterval</key><integer>$((SYNC_INTERVAL_MIN * 60))</integer>
  <key>RunAtLoad</key><true/>"
}

mac_install_jobs() {
  mac_plist "com.$TAG.daily-operator" \
"    <string>/bin/bash</string>
    <string>$SCRIPT_DIR/run-job.sh</string>
    <string>daily-operator</string>" \
"  <key>StartCalendarInterval</key>
  <dict><key>Hour</key><integer>$DAILY_HOUR</integer><key>Minute</key><integer>$DAILY_MINUTE</integer></dict>"
  mac_plist "com.$TAG.weekly-optimizer" \
"    <string>/bin/bash</string>
    <string>$SCRIPT_DIR/run-job.sh</string>
    <string>weekly-optimizer</string>" \
"  <key>StartCalendarInterval</key>
  <dict><key>Weekday</key><integer>$WEEKLY_WEEKDAY</integer><key>Hour</key><integer>$WEEKLY_HOUR</integer><key>Minute</key><integer>$WEEKLY_MINUTE</integer></dict>"
}

mac_uninstall() {
  for f in "$HOME"/Library/LaunchAgents/com.$TAG.*.plist; do
    [ -e "$f" ] || continue
    launchctl unload "$f" 2>/dev/null || true; rm -f "$f"; echo "removed $f"
  done
}

# ---------------------------------------------------------------- Linux --
cron_set() {  # replaces this vault's lines with the given block
  local block="$1"
  { crontab -l 2>/dev/null | grep -v "# $TAG" || true; printf '%s\n' "$block"; } | sed '/^$/d' | crontab -
}

linux_install() {
  local lines=""
  if [ "$WHAT" = "sync" ] || [ "$WHAT" = "all" ]; then
    lines+="*/$SYNC_INTERVAL_MIN * * * * \"$SCRIPT_DIR/vault-sync.sh\" --quiet # $TAG"$'\n'
  fi
  if [ "$WHAT" = "jobs" ] || [ "$WHAT" = "all" ]; then
    lines+="$DAILY_MINUTE $DAILY_HOUR * * * SECOND_BRAIN_AGENT=$AGENT \"$SCRIPT_DIR/run-job.sh\" daily-operator # $TAG"$'\n'
    lines+="$WEEKLY_MINUTE $WEEKLY_HOUR * * $WEEKLY_WEEKDAY SECOND_BRAIN_AGENT=$AGENT \"$SCRIPT_DIR/run-job.sh\" weekly-optimizer # $TAG"$'\n'
  fi
  # keep lines for the part we are not touching
  local keep; keep=$(crontab -l 2>/dev/null | grep "# $TAG" || true)
  [ "$WHAT" = "sync" ] && keep=$(printf '%s\n' "$keep" | grep 'run-job.sh' || true)
  [ "$WHAT" = "jobs" ] && keep=$(printf '%s\n' "$keep" | grep 'vault-sync.sh' || true)
  cron_set "$keep"$'\n'"$lines"
  crontab -l | grep "# $TAG"
}

# ----------------------------------------------------------------- main --
if [ "$(uname)" = "Darwin" ]; then
  case "$WHAT" in
    sync) mac_install_sync ;;
    jobs) mac_install_jobs ;;
    all)  mac_install_sync; mac_install_jobs ;;
    uninstall) mac_uninstall ;;
    *) echo "usage: $0 sync|jobs|all|uninstall"; exit 1 ;;
  esac
else
  case "$WHAT" in
    sync|jobs|all) linux_install ;;
    uninstall) cron_set "" ; echo "removed $TAG cron lines" ;;
    *) echo "usage: $0 sync|jobs|all|uninstall"; exit 1 ;;
  esac
fi
