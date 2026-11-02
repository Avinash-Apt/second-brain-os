# Second Brain OS

This folder is an Obsidian vault that doubles as your operator's operating system. Every piece of state (who they are, what the business does, projects, meetings, decisions, ideas) lives in markdown files that you read, write, and maintain.

This file is the **single source of truth** for every agent. `CLAUDE.md` imports it, Codex and Grok read it directly. Each folder has its own `AGENTS.md` with local rules; read it before writing in that folder. Never put rules in `CLAUDE.md`. Edit this file instead.

> [!important] First run
> If `Context/me.md` still contains `{{` placeholders, the vault is not set up yet. Open `SETUP.md` and walk the user through it, one phase at a time.

## Session Startup

On your first response in a session, silently:

1. Read the latest file in `Daily/`.
2. Read `Context/me.md`.

Do not announce it. Read, absorb, respond.

## Knowledge Routing

Every piece of information has one home. No catch-all files.

| Type | Route to |
|---|---|
| Operator preferences, style, habits | `Context/me.md` |
| Strategy, goals, OKRs | `Context/strategy.md` |
| Business / company context | `Context/business.md` |
| Services, products, revenue lines | `Context/services.md` |
| Ideal customer profile | `Context/icp.md` |
| Customer pain points | `Context/pain-points.md` |
| Tool stack, connectors, integrations | `Context/infrastructure.md` |
| Brand, voice, tone | `Context/brand.md` |
| Team and collaborators | `Context/team.md` |
| Project info | `Projects/{name}/` (see `Projects/AGENTS.md`) |
| Meetings, competitors, market, decisions | `Intelligence/` (see `Intelligence/AGENTS.md`) |
| New ideas (business, product, strategy) | `Intelligence/new-ideas/` |
| Weekly reviews | `Intelligence/reviews/` |
| Reusable content (prompts, frameworks, templates) | `Resources/` (see `Resources/AGENTS.md`) |
| Vault infrastructure (sync, scheduled jobs) | `Resources/ops/` and `Resources/vault-operator/` |
| Skill-specific references | `Skills/{skill-name}/` |
| Personal performance (optional module) | `Personal/` |
| Daily journal and session logs | `Daily/YYYY-MM-DD.md` |
| Rules for assistant behavior | This file, Rules section |

## Document Voice

Vault docs sound like a sharp teammate, not an AI. Specific names, specific context, specific consequences.

- BAD: "The project is progressing well. Key milestones are being tracked."
- GOOD: "Landing page 70% done. Next checkpoint: copy review with [[Sam]] Thursday. Blocked on pricing decision."

## Obsidian Syntax

- **Wikilinks**, never markdown links for internal notes: `[[Note Name]]`, `[[Note|Display Text]]`. Weave them into sentences, not bullet lists.
- **Embeds**: `![[Note Name]]`, `![[image.png|300]]`
- **Callouts**: `> [!type] Title` (note, tip, warning, important, question, todo, success, failure, info)
- **Highlights**: `==text==` (sparingly). **Comments**: `%%internal%%`. **Tags**: `#tag` or frontmatter.

Prefer the Obsidian CLI (`obsidian read`, `obsidian search`) when installed. Fall back to direct file access.

## Frontmatter

```yaml
---
type: meeting
date: 2026-01-21
project: Project-Alpha
status: completed
tags: [client-call, onboarding]
---
```

Standard fields: `type`, `date`, `project`, `status`, `tags`, `priority`. Always include `status:` and 2+ specific `tags:`. Include `project:` whenever the note relates to a project (the most often missed field).

## Rules

1. On the first response of a session, read the latest `Daily/` note and `Context/me.md`.
2. When meaningful work happens (not casual chat), write a session log to `Daily/YYYY-MM-DD.md`.
3. Use `[[wikilinks]]` for every entity (people, companies, projects, notes). Weave them into sentences.
4. Every note is standalone and composable, like a Lego block.
5. Use callouts for visual structure, sparingly (1 to 3 per doc).
6. Use `grep` or `obsidian search` to scan many files. Don't read whole files just to scan.
7. When the operator corrects you, save the correction as a new numbered rule below (or in the right folder `AGENTS.md`). Don't ask.
8. Respect `.claudeignore` (applies to every agent, not just Claude).
9. Never ask permission to save. Auto-save to the right vault file, then report what was saved.
10. Before the final response of a session, persist meaningful information into the vault. Skip casual chat.
11. For web content extraction, prefer `defuddle parse <url> --md` (or a scraping connector) over raw HTML fetches.
12. Never use em dashes in vault writing. Use periods, commas, colons, or restructure.
13. Move completed projects to `Intelligence/archive/`.
14. Never create files or folders in the vault root. Every file lives in an existing folder.
15. **Never send emails or messages on the operator's behalf.** Create drafts only. The operator reviews and sends.
16. **Hard financial numbers never get committed to git.** Revenue, pricing, bank statements, invoices, tax and entity IDs stay local. Percentages, ratios and trends are fine. Before saving anything with real figures, run `git check-ignore -v <path>` and confirm it is covered. Protocol: `Resources/ops/vault-sync.md`.
17. **Evidence over history.** Never present an old observation (a subscription, a price, a status) as current fact. Re-verify against a live source or label it with its date.
18. **New ideas live in `Intelligence/new-ideas/`.** When the operator raises an idea, first read `Intelligence/new-ideas/README.md` and grep that folder plus `Intelligence/decisions/` for overlap. If it already exists, say so plainly and link the earlier note, then add only what is new. Save as `YYYY-MM-DD-{slug}.md` and add a row to the README index.
19. **Pre-meeting briefs.** When the operator says they are preparing for a meeting, save a request at `Intelligence/meetings/pre-meeting-briefs/requests/YYYY-MM-DD-{slug}.md` from `_TEMPLATE.md`, check `Intelligence/meetings/pre-meeting-briefs/` for an existing brief, and use it as context.

<!-- Operator-specific rules get appended below this line, numbered from 20. -->

## Anti-Patterns

Do NOT:

- Put a `# Title` heading that duplicates the filename.
- Create orphan notes. Always link a new note from at least one existing note.
- Update vault files on casual chat.
- Cram all project info into `README.md`. Route to subfolders.
- Write project names, people, or note references as plain text. Use `[[wikilinks]]`.
- Use `[markdown](links)` for internal vault notes.
- Write rules into `CLAUDE.md`. It only imports this file.

## Scheduled Jobs

The vault maintains itself. Prompts live in `Resources/vault-operator/`, the runner and schedules in `Resources/ops/`.

| Job | Cadence | Prompt |
|---|---|---|
| Vault sync (git) | Every 10 min + session start/end | `Resources/ops/vault-sync.sh` |
| Daily operator | Daily, morning | `Resources/vault-operator/daily-operator.md` |
| Weekly optimizer | Weekly, Sunday | `Resources/vault-operator/weekly-optimizer.md` |

When running as one of these jobs, follow that prompt exactly and do not ask questions.
