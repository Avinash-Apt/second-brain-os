# Skills

Operator-editable reference material for individual skills (repeatable workflows the agent runs: proposals, reports, content, outreach). Skills read from here at runtime.

```
Skills/{skill-name}/
  notes.md          operator notes, voice, working preferences
  strategy.md       high-level approach for this skill
  references/
    {topic}.md      examples, templates, deeper context
```

## Rules

- One folder per skill, named with the skill slug (kebab-case). Copy `Skills/_template/` to start.
- `notes.md` holds short, operator-voiced guidance the skill must respect.
- `references/` holds examples and longer material the skill loads on demand.
- Don't duplicate the skill's own SKILL.md. This folder is for the operator's customization.
- Where the skill itself lives depends on the agent: Claude Code `~/.claude/skills/{name}/SKILL.md`, Codex `~/.codex/skills/{name}/`, Grok `~/.grok/skills/{name}/`. Point each at this folder for references so all agents share them.
