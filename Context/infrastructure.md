---
type: context
status: draft
tags: [tools, infrastructure]
updated: {{YYYY-MM-DD}}
---

## Connected tools

| Tool | Source of truth for | Connector name | Agents | Auth | Verified |
|---|---|---|---|---|---|
| {{TOOL}} | {{WHAT}} | {{NAME}} | {{AGENTS}} | {{OAUTH_OR_ENV_KEY}} | {{DATE}} |

> [!warning] Never store keys here
> Record the auth type and where the key lives (agent config, env var), never the key itself.

## Agents

| Use case | 1st | 2nd |
|---|---|---|
| Desktop operator | {{AGENT}} | {{AGENT}} |
| Mobile | {{AGENT}} | {{AGENT}} |
| Scheduled jobs | {{AGENT}} | |

## Workflows to automate (top drains)

- {{DRAIN}}
