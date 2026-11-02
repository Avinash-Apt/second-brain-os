# Second Brain OS

An Obsidian vault that works as an operating system for you and your AI agents. Your context, projects, meetings, decisions and ideas live in plain markdown. Claude Code, Codex and Grok all read the same instructions, write to the same places, and keep the vault clean on a schedule.

## Install (2 minutes of your time, the agent does the rest)

Paste this into your agent (Claude Code, Codex, Grok / Grokbot, or similar):

> Clone https://github.com/Avinash-Apt/second-brain-os into a new folder for my second brain, then read SETUP.md and walk me through setting it up, one phase at a time.

The agent will:

1. Make it **your** private repo (not a fork of this one)
2. Interview you about yourself, your business, customers, brand, team and goals, and write your `Context/` files
3. Add your personal rules
4. Connect your tools one by one (meetings, calendar, email, CRM, PM, outbound, research) and verify each
5. Turn on git sync across devices
6. Schedule the daily operator and weekly optimizer
7. Scaffold your first skill

Expect 60 to 90 minutes, mostly talking.

## How it works

```
AGENTS.md            the one rule set every agent follows
CLAUDE.md            imports AGENTS.md (Claude Code reads CLAUDE.md)
SETUP.md             the agent's install script
CONNECTORS.md        tool catalog + install commands per agent

Context/             who you are, the business, ICP, brand, team, strategy, tools
Daily/               one note per day: state + session logs
Projects/{name}/     living project folders, README as index
Intelligence/        meetings, decisions, new ideas, competitors, market, reviews, archive
Resources/           templates, frameworks, prompts, lessons
  ops/               sync script, job runner, schedule installer
  vault-operator/    daily + weekly job prompts, task list, run reports
Skills/{name}/       your notes and references for repeatable workflows
Personal/            optional: fitness, nutrition, focus scoring
```

### One rule set, every agent

Every folder has an `AGENTS.md` (the rules) and a `CLAUDE.md` that contains only `@AGENTS.md`.

| Agent | Reads | Result |
|---|---|---|
| Codex | `AGENTS.md`, root down to the working folder | Same rules |
| Grok | `AGENTS.md` and `CLAUDE.md`, root down to the working folder | Same rules (the CLAUDE.md shim adds one line) |
| Claude Code | `CLAUDE.md`, which imports `AGENTS.md` | Same rules |

So you edit rules in one place, `AGENTS.md`, and every agent picks them up. Keep the root `AGENTS.md` under 10,000 characters; Grok truncates past that.

### It maintains itself

| Job | When | What |
|---|---|---|
| Vault sync | Every 10 min, plus Claude session start/end | Commit, rebase, push. Never auto-resolves conflicts |
| Daily operator | Every morning | Last 48h of meetings into notes, action items into the task list, today's daily updated, 5 housekeeping fixes |
| Weekly optimizer | Sunday evening | Rebuilds indexes, fixes orphans and dead links, archives finished work, flags goals with no project, writes your weekly review |

Run them through your agent's own scheduler (Grokbot, Claude routines, Codex automations) or on an always-on Mac/Linux box with `Resources/ops/install-schedules.sh`.

### Built-in guardrails

- **Drafts only.** Agents never send emails or messages for you.
- **No financial figures in git.** A two-layer `.gitignore` (explicit folders plus a pattern net for invoices, statements, bank exports) keeps hard numbers on your machine.
- **No secrets in markdown.** Connector keys live in agent config, never in the vault.
- **Corrections become rules.** Tell the agent it got something wrong and it writes a permanent rule.
- **Evidence over history.** Old observations are labeled with their date, not presented as current.

## Requirements

- An agent CLI: [Claude Code](https://claude.com/claude-code), [Codex](https://github.com/openai/codex), or Grok
- git, and the GitHub CLI (`gh`) for sync
- [Obsidian](https://obsidian.md) to browse it (optional but recommended)
- macOS or Linux for background schedules (or a cloud scheduler)

## Customizing

- Rules: append to `AGENTS.md` under the marker comment, numbered from 20.
- Routing: add a row to the Knowledge Routing table and a folder `AGENTS.md`.
- Jobs: edit the prompts in `Resources/vault-operator/`. Add a new job by adding a prompt there and a line in `install-schedules.sh`.

Folder structure adapted from BenAI Obsidian OS.
