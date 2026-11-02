# Daily

The operator's daily journal and session log. One file per day: `YYYY-MM-DD.md`.

## Frontmatter

```yaml
---
type: daily-note
date: YYYY-MM-DD
status: active
tags: [daily, session-log]
---
```

## Rules

- The daily is **state, not a log**. Update sections in place; never stack timestamped "pass" callouts.
- Today's file holds today only. Open tasks from earlier days live in `Resources/vault-operator/task-list/Tasks.md`.
- Session logs from interactive work go under `## Sessions` with what was done, what was decided, and links to the notes created.
- Standard sections (create as needed): `## Calendar / Deadlines`, `## Meetings`, `## Open Action Items`, `## Sessions`, `## Tasks Carried Forward`, `## Key Themes`.
- Template: `Resources/templates/daily-note.md`.
