# Setup: Agent-Guided Install

**Agent: this file is your script.** Walk the operator through it one phase at a time. Ask, wait, act, confirm, move on. Never dump the whole file on them. Never skip the confirmation at the end of a phase. Keep a running checklist in your replies (`[x] Phase 1 ... [ ] Phase 2`) so they always know where they are.

**Operator: you don't need to read this.** Tell your agent: *"Read SETUP.md and set up my second brain."* It will ask you questions and do the rest.

Works with Claude Code, Codex, Grok (Grok Build / Grokbot), or any agent that can read files and run shell commands. Where steps differ by agent, this file says so.

---

## Phase 0: Make it yours (5 min)

Goal: the operator's vault is a **private** repo they own, not a clone of the public template.

1. Ask: *"Where should your vault live?"* Suggest `~/Second Brain`. Avoid `~/Documents`, `~/Desktop` and `~/Downloads` on macOS, since background jobs often lose file access there.
2. If the template is not already there, copy it in:
   ```bash
   git clone <template-repo-url> ~/"Second Brain"
   cd ~/"Second Brain"
   rm -rf .git && git init -b main
   ```
3. Ask whether they want GitHub sync (recommended: backup, phone access, multiple devices, other agents can read it). If yes, check `gh auth status`, then:
   ```bash
   gh repo create second-brain --private --source . --remote origin
   ```
   **It must be private.** Say so explicitly. This repo will hold their business context.
4. Ask which agent(s) they use: Claude Code, Codex, Grok, or several. Remember the answer: it decides the connector commands in Phase 3 and the scheduler in Phase 5.
5. Check for the optional tools and offer to install any that are missing:
   - Obsidian app (`https://obsidian.md`). Then: Open folder as vault, pick this folder.
   - Obsidian CLI (`obsidian` on PATH) for fast search.
   - `defuddle` for clean web extraction: `npm i -g defuddle`.

**Confirm:** "Vault at `<path>`, private repo `<url>`, agents: `<list>`. Ready for the interview?"

---

## Phase 1: The interview (15 to 25 min)

Goal: replace every `{{placeholder}}` in `Context/` with real, specific answers.

Ask **one category at a time**, conversationally. Accept voice-dictated rambling and messy answers, then distill them. Push for specifics: names, numbers (not financial ones, see Rule 16), examples. If an answer is generic ("we help businesses grow"), ask one follow-up for the concrete version.

| # | Category | Writes to | Questions to cover |
|---|---|---|---|
| 1 | Identity | `Context/me.md` | Name, role, location/time zone, 5 words that describe them, how they'd want to be introduced, origin story, contrarian belief, enemy |
| 2 | Working style | `Context/me.md` | Best hours, daily rhythm, what drains vs energizes them, strengths, failure modes, how they want to be challenged |
| 3 | Business | `Context/business.md` | What the company does, stage, model, team size, what makes it different |
| 4 | Services / products | `Context/services.md` | Each offer, who it's for, delivery process, rough pricing model (structure only, no hard numbers) |
| 5 | Customers | `Context/icp.md`, `Context/pain-points.md` | Best 3 customers and why, industries, titles, triggers, top pains in the customer's own words |
| 6 | Brand and voice | `Context/brand.md` | Tone, words they use, words they hate, writing samples (ask them to paste 2 to 3 real messages or posts) |
| 7 | Team | `Context/team.md` | Collaborators, roles, who owns what, external partners |
| 8 | Strategy | `Context/strategy.md` | 12-month goal, this quarter's 3 priorities, what they are saying no to |
| 9 | Unclosed loops | `Context/me.md` | What's on their mind right now that isn't done |

After each category: write the file, show a 3-line summary of what you saved, ask "anything wrong or missing?", fix, move on. Delete sections that don't apply instead of leaving placeholders. If they have no team, delete `Context/team.md` and its routing row.

Then ask: *"Name your active projects."* For each one, create `Projects/{Name}/README.md` from `Resources/templates/project-readme.md` with real status and next steps. Link each project from `Context/strategy.md` where it serves a goal.

**Confirm:** "Context files written: `<list>`. Projects created: `<list>`. Want to review any before we connect your tools?"

---

## Phase 2: Personal rules (5 min)

Goal: make the operator's non-negotiables permanent.

1. Read the Rules section of `AGENTS.md` aloud in short form. Ask which ones to drop or change. Rules 15 (drafts only) and 16 (no financial figures in git) should stay unless they insist.
2. Ask: *"What should I always or never do?"* Examples to prompt them: spelling (US vs UK), sign-off style, which client names are confidential, anything that has burned them before.
3. Append each as a numbered rule (20, 21, ...) under the marker comment in `AGENTS.md`, with the date: `(Added YYYY-MM-DD.)`.
4. Check `AGENTS.md` is still under **10,000 characters** (`wc -c AGENTS.md`). Grok truncates past that. If it's over, move detail into the relevant folder `AGENTS.md` or a `Resources/` note and leave a one-line pointer.

**Confirm:** "Added rules `<n>`. Ready to connect your tools?"

---

## Phase 3: Connect tools (20 to 40 min, the back-and-forth part)

Goal: the agent can read the operator's real systems: calendar, meetings, CRM, email, PM, docs.

Open `CONNECTORS.md`. It has the catalog, the per-agent install commands, and the verification step for each.

1. Show the operator the **categories** (not the full list) and ask which tools they use in each. Their stack, not the catalog's.
2. Prioritize in this order and do **one connector at a time**:
   1. Meeting recorder (Fireflies, Granola, Fathom, Otter, tl;dv...). The daily operator depends on it.
   2. Calendar and email (drafts only, see Rule 15).
   3. CRM and project management.
   4. Everything else.
3. For each connector:
   1. Look up the vendor's **current** MCP docs (search the web; endpoints change). Prefer an official remote MCP with OAuth. Fall back to an API-key MCP, then a CLI.
   2. Give the operator the exact command for their agent (templates in `CONNECTORS.md`), or run it yourself if you have shell access.
   3. If OAuth or an API key is needed, tell them exactly where to click to get it. **Never ask them to paste secrets into a vault file.** Keys go in the agent's config or environment, never in markdown.
   4. Verify with one read-only call (list 1 meeting, 1 calendar event, 1 CRM record). Show the result.
   5. Record it in `Context/infrastructure.md`: tool, what it's the source of truth for, connector name, auth type, date verified. Never the key.
4. If they use more than one agent, install each connector in each agent they want it in. Ask, don't assume.
5. For unattended jobs (Phase 5) with Claude Code: add read-only allow rules for the connected servers to `.claude/settings.json` under `permissions.allow`, e.g. `"mcp__fireflies"`. Otherwise the daily operator stalls on a permission prompt.

**Confirm:** a table of connector, agent(s), status (verified / failed / skipped). Retry failures once, then move on and note them.

---

## Phase 4: Sync (5 min, skip if no GitHub repo)

Goal: the vault stays identical across devices and agents without anyone remembering to commit.

1. Read `Resources/ops/vault-sync.md` and explain the model in two sentences: commit locally, rebase onto remote, push. It never auto-resolves conflicts.
2. Ask: *"Any folders with real financial figures, contracts, or client-confidential files?"* Add them to `.gitignore` under the financial section. Run `git check-ignore -v <path>` on one example to prove it.
3. Make scripts executable: `chmod +x Resources/ops/*.sh`.
4. Session hooks:
   - **Claude Code:** already wired in `.claude/settings.json` (pull on session start, sync on stop). Nothing to do.
   - **Codex / Grok:** no session hooks needed. The timer covers it.
5. Install the 10-minute timer with `Resources/ops/install-schedules.sh sync` (macOS launchd or Linux cron, detected automatically).
6. First commit and push: `Resources/ops/vault-sync.sh`. Show the log line.

**Confirm:** "Sync running every 10 minutes. Log at `<path>`."

---

## Phase 5: Scheduled jobs (10 min)

Goal: the vault cleans and organizes itself.

| Job | Default cadence | What it does |
|---|---|---|
| Daily operator | 7:00 local, daily | Pulls last 48h of meetings into notes, extracts action items, updates today's daily, 5 housekeeping fixes |
| Weekly optimizer | Sunday 18:00 | Re-indexes READMEs, fixes orphans and frontmatter drift, archives finished work, writes the weekly review |

1. Ask for their preferred times and time zone. Ask which agent should run the jobs.
2. Fill in the `{{...}}` placeholders in `Resources/vault-operator/daily-operator.md` and `weekly-optimizer.md`: operator name, team names for action-item attribution, meeting connector name, signature label.
3. Pick the scheduler. In order of preference:
   - **The agent has a built-in scheduler** (Grokbot scheduled tasks, Claude Code routines via `/schedule`, Codex automations): register each job there with the prompt *"Read `Resources/vault-operator/<job>.md` in my second brain repo and execute it."* Cloud schedulers need the vault on GitHub (Phase 4).
   - **Always-on Mac or Linux box:** `Resources/ops/install-schedules.sh jobs` installs launchd agents or cron entries that call `Resources/ops/run-job.sh` with the chosen agent CLI.
4. Do a dry run now: `Resources/ops/run-job.sh daily-operator <agent>`. Show the operator the report it wrote in `Resources/vault-operator/reports/`.

**Confirm:** "Daily at `<time>`, weekly on `<day time>`, running on `<agent/scheduler>`. First report: `<path>`."

---

## Phase 6: Skills and first week (5 min)

1. Ask: *"What do you do every week that follows the same steps?"* (proposals, reports, content, client updates). For each, scaffold `Skills/{skill-name}/` from `Skills/_template/` and note it as a candidate skill. Don't build them all now. One is plenty.
2. Optional: ask if they want the `Personal/` performance module (fitness, nutrition, focus scoring). If not, delete the folder and its routing row in `AGENTS.md`.
3. Write today's `Daily/YYYY-MM-DD.md` session log: what was set up, what failed, what's next.
4. Commit and sync.
5. Tell them how to use it from here:
   - Talk to the agent from inside the vault folder. It reads the context automatically.
   - Dump things in: meeting notes, ideas, decisions, voice memos. It routes them.
   - Correct it when it's wrong. Corrections become rules (Rule 7).
   - Read the Sunday review in `Intelligence/reviews/`.

**Done.** Final message: the checklist with every phase ticked, the repo URL, the job schedule, and the one thing to do tomorrow.
