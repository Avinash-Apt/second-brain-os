# Resources

The library for reusable content, plus the vault's own infrastructure.

| Subfolder | What goes here |
|---|---|
| `frameworks/` | Reusable frameworks and methodologies |
| `templates/` | Note templates (daily, meeting, decision, project, idea) |
| `prompts/` | Saved prompts for recurring tasks |
| `tools/` | How-tos and gotchas for tools and platforms |
| `swipe/` | Swipe files and inspiration |
| `lessons/` | Distilled videos and courses, each ending with the practices actually adopted. Index: `lessons/README.md` |
| `archive/` | Superseded resources |
| `ops/` | Vault infrastructure: sync, schedules, job runner. Read `ops/vault-sync.md` before touching `.gitignore` |
| `vault-operator/` | Scheduled job prompts, task list, run reports |

## Rules

- When the operator shares reusable content, save it here with a descriptive filename.
- Light nesting. Use the folders above; add a new one only with clear warrant.
- Don't duplicate content that lives in a project. Link to it.
- `finance/` (create when needed) is git-ignored by default. Put anything with real figures there.
