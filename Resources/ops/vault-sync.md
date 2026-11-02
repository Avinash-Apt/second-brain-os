---
type: reference
status: active
tags: [ops, git, sync, security]
---

How the Second Brain stays identical across devices and agents, and what never leaves the machine. Scripts live beside this note in `Resources/ops/`.

## The model

The vault is a **private** git repo. Every device clones it. Changes commit straight to `main` with no pull requests and no branches, appended like a ledger.

Two rules make it work. Commit before pulling, so local work is committed rather than stashed and can never be lost to a failed rebase. And never auto-resolve a conflict: the script rolls back, keeps the work safe locally, and raises a desktop notification.

## What triggers a sync

| Trigger | What it does | Covers |
|---|---|---|
| Claude Code session starts | `vault-sync.sh pull-only` | Picking up what another device pushed |
| Claude Code session ends | `vault-sync.sh` full | Everything a session wrote |
| Timer, every 10 minutes | `vault-sync.sh --quiet` full | Obsidian edits, phone edits, Codex and Grok sessions |
| Scheduled jobs | pull before, sync after (`run-job.sh`) | Daily operator, weekly optimizer |
| Manual | `./Resources/ops/vault-sync.sh` | When you want it now |

Claude hooks live in `.claude/settings.json`. Install the timer with `Resources/ops/install-schedules.sh sync`.

The timer is the piece that matters most. Hooks only fire inside Claude Code, so without it an Obsidian-only or Codex edit could sit unpushed indefinitely.

> [!info] Behaviour worth knowing
> Concurrent runs are a no-op: the second sees a lock and exits, with stale locks cleared after 15 minutes. Offline, it commits locally and pushes next run. If another device pushes between the rebase and the push, it rebases and retries once. Log: `~/Library/Logs/vault-sync.log` (macOS) or `~/.local/state/vault-sync.log` (Linux).

## What never gets pushed

Hard numbers stay on the machine. Percentages, ratios, trends and dashboards are fine to push, since they carry the signal without the exposure.

The `.gitignore` has two layers:

| Layer | Example | Why |
|---|---|---|
| Explicit folders | `Resources/finance/`, `Projects/*/agreements/`, `Projects/*/pricing/` | Places you deliberately keep figures |
| Pattern net | `*invoice*.pdf`, `**/statements/`, `*.csv` bank exports | Catches a stray file before it is ever staged |

The pattern net matters more than the explicit paths. A statement PDF dropped anywhere in the vault is ignored on sight.

### Checking it still holds

```bash
git check-ignore -v "path/to/file"                    # is this file protected?
git ls-files | grep -iE 'statement|pricing|invoice'   # anything financial still tracked?
```

Run the second one after any big reorganisation. It should return nothing.

> [!warning] Ignoring a file does not remove it from history
> If a financial file was committed before being ignored, untracking it removes it from future clones but not from past commits. Rewriting history (`git filter-repo`) fixes that, but changes every commit SHA, so every other clone must be deleted and re-cloned. Do it before setting up extra devices.

## Phone setup

**iOS:** install Working Copy, clone the repo, then in Obsidian mobile choose "Open folder from storage" and point it at the Working Copy directory. Enable automatic push and background fetch.

**Android:** install the obsidian-git community plugin in Obsidian mobile. Auto-pull on start, auto-push on an interval.

Either way, authenticate with a **fine-grained GitHub personal access token** scoped to this one repo with Contents read and write. Never an account password.

## When something breaks

| Symptom | Fix |
|---|---|
| Notification: sync conflict | `git pull --rebase` in the vault, resolve, `git rebase --continue`. Work is committed and safe |
| "repo is mid-rebase or mid-merge" | Finish or abort the rebase by hand. The script refuses to act on a half-finished state |
| Phone changes not on laptop | Wait for the timer, or run the script manually |
| Timer not running (macOS) | `launchctl list \| grep second-brain-os`, then rerun `install-schedules.sh sync` |
| Timer not running (Linux) | `crontab -l \| grep second-brain-os` |
| A financial file got committed | Untrack it (`git rm --cached`), add it to `.gitignore`, decide whether a history rewrite is warranted |
