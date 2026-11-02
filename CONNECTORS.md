# Connectors

**Agent:** this is the reference for Phase 3 of `SETUP.md`. Go one connector at a time, verify each with a read-only call, and record it in `Context/infrastructure.md`. Endpoints change: **always confirm the current MCP endpoint in the vendor's docs before installing.** The endpoints below are starting points, not guarantees.

**Never write an API key, token or password into any markdown file.** Keys live in the agent's config or the shell environment.

## How to install (per agent)

Replace `<name>`, `<url>`, `<package>` and `<KEY>` with the connector's values.

### Remote MCP (HTTP, usually OAuth)

| Agent | Command |
|---|---|
| Claude Code | `claude mcp add --transport http --scope user <name> <url>` then run `/mcp` inside Claude Code to log in |
| Codex | `codex mcp add <name> --url <url>` then `codex mcp login <name>` |
| Grok | `grok mcp add <name> <url> --scope user` (add `-H "Authorization: Bearer $KEY"` for key-based servers) |

### Local MCP (stdio, usually API key)

| Agent | Command |
|---|---|
| Claude Code | `claude mcp add --scope user <name> -e <KEY>=... -- npx -y <package>` |
| Codex | `codex mcp add <name> --env <KEY>=... -- npx -y <package>` |
| Grok | `grok mcp add <name> --scope user -e <KEY>=... -- npx -y <package>` |

### Verify

| Agent | List | Diagnose |
|---|---|---|
| Claude Code | `claude mcp list` | `/mcp` in a session |
| Codex | `codex mcp list` | `codex mcp get <name>` |
| Grok | `grok mcp list` | `grok mcp doctor` |

Then make one read-only call through the connector (list 1 item) and show the operator the result.

> [!tip] Claude.ai connectors
> If the operator uses Claude on the web, connectors added at claude.ai (Settings, Connectors) are also available to Claude Code when logged in with the same account. Google Calendar, Gmail and Drive are easiest this way.

> [!warning] Email and messaging connectors
> Connect them, but Rule 15 applies: drafts only. If a connector exposes a "send" tool, tell the operator, and for Claude Code add it to `permissions.deny` in `.claude/settings.json`.

## Catalog

Ask the operator which category they use first, then which tool. Only install what they actually use.

### 1. Meetings and call intelligence (install first: the daily operator needs it)

| Tool | Starting point | Notes |
|---|---|---|
| Fireflies | Vendor MCP (check docs), or `fireflies-cli` via npm | Transcripts, summaries, action items |
| Granola | Vendor remote MCP (check docs) | Notes and summaries; transcripts may need a paid plan |
| Fathom / Otter / tl;dv / Zoom | Check vendor docs for MCP or API | Same role |

### 2. Calendar, email, files

| Tool | Starting point | Notes |
|---|---|---|
| Google Calendar, Gmail, Drive | Claude.ai connectors, or the `gws` Google Workspace CLI | For `gws`, request `gmail.readonly` plus drafts scope only, so sending is impossible |
| Microsoft 365 / Outlook | Vendor MCP or Graph API | Same rule: drafts only |

### 3. Team communication

| Tool | Starting point | Notes |
|---|---|---|
| Slack | Official Slack MCP (check docs) | Read channels, draft messages. No sending without explicit approval |
| Telegram / WhatsApp / Discord | Usually a bot or bridge | Optional |

### 4. CRM and pipeline

| Tool | Starting point | Notes |
|---|---|---|
| Attio | Vendor remote MCP (check docs) | Deals, people, notes |
| HubSpot | Vendor remote MCP (check docs) | |
| GoHighLevel / Pipedrive / Close | Check vendor docs | |

### 5. Project management

| Tool | Starting point | Notes |
|---|---|---|
| ClickUp | Vendor remote MCP (check docs) | Tasks, docs, time tracking |
| Notion | `https://mcp.notion.com/mcp` | Pages and databases |
| Linear | `https://mcp.linear.app/mcp` | |
| Asana / Monday / Jira | Check vendor docs | |

### 6. Outbound and lead gen

| Tool | Starting point | Notes |
|---|---|---|
| Instantly | Vendor MCP (check docs; some use a key in the URL, treat that URL as a secret) | Campaigns, replies, analytics. One server per workspace if you run several |
| Smartlead | Vendor MCP or API | |
| HeyReach | Vendor MCP (check docs) | LinkedIn outreach |
| Apollo / FindyMail / enrichment providers | Check vendor docs | |
| Clay or a Clay replacement | Check vendor docs | |

### 7. Research and web

| Tool | Starting point | Notes |
|---|---|---|
| Firecrawl | stdio: `npx -y firecrawl-mcp`, env `FIRECRAWL_API_KEY` | Scrape, crawl, search |
| Exa | `https://mcp.exa.ai/mcp` | Semantic web search |
| Parallel | Check vendor docs | Web search and fetch |
| YouTube transcripts | A transcript MCP or API (check docs) | For the lessons bank in `Resources/lessons/` |
| Browser automation | Claude in Chrome extension, or `npx @playwright/mcp@latest` | For sites with no API |

### 8. Content and design

| Tool | Starting point | Notes |
|---|---|---|
| Canva | Vendor remote MCP (check docs) | |
| Figma | Vendor remote MCP (check docs) | |
| Beehiiv / Kit (ConvertKit) | Vendor MCP (check docs) | Newsletter. Drafts only |
| VidIQ / YouTube Studio | Check vendor docs | |
| Webflow / Framer | Vendor MCP (check docs) | Website and proof sections |

### 9. Finance (read-only, and mind Rule 16)

| Tool | Starting point | Notes |
|---|---|---|
| Stripe | `https://mcp.stripe.com` | Read-only keys |
| Business bank (Mercury, Brex, Relay...) | Vendor MCP (check docs) | Read-only. Never move money |
| QuickBooks / Xero | Vendor MCP (check docs) | |

Any figures pulled from these stay out of git. Save reports into a folder covered by `.gitignore` (default: `Resources/finance/`).

### 10. Build and automation

| Tool | Starting point | Notes |
|---|---|---|
| n8n / Make / Zapier | Instance MCP or API (check docs) | Workflow automation |
| Supabase | `https://mcp.supabase.com/mcp` | |
| Vercel | `https://mcp.vercel.com` | |
| GitHub | `gh` CLI (`gh auth login`) | Needed for sync and cloud schedulers |

## Recording a connector

Add one row per connector to `Context/infrastructure.md`:

```markdown
| Tool | Source of truth for | Connector name | Agents | Auth | Verified |
|---|---|---|---|---|---|
| Fireflies | What was said on calls | fireflies | Claude, Grok | API key (env) | 2026-01-21 |
```
