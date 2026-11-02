# Projects

Projects are living directories that grow as information accumulates. Not flat README-only folders.

## Routing

| Content type | Route to |
|---|---|
| Status update, overview, deadline | `Projects/{name}/README.md` |
| Research finding | `Projects/{name}/research/{topic}.md` |
| Spec, requirement, brief | `Projects/{name}/specs/{name}.md` |
| Draft, script, written content | `Projects/{name}/drafts/{name}.md` |
| Idea, brainstorm | `Projects/{name}/ideas/{name}.md` |
| Working notes | `Projects/{name}/notes/{name}.md` |
| Feedback, review comments | `Projects/{name}/feedback/{name}.md` |
| Contracts, pricing (git-ignored) | `Projects/{name}/agreements/`, `Projects/{name}/pricing/` |

## Rules

- **Subfolders on the fly.** Don't pre-create empty folders. Create one when content needs it, and link it from the README.
- **README is the index**: overview, status, next steps, links to subfolder content. Don't duplicate subfolder content in it.
- **Lifecycle**: a new project is just a README (template: `Resources/templates/project-readme.md`). Completed projects move to `Intelligence/archive/{name}/`.
- Include `project:` in frontmatter on every project note.

## Goal cascade

Every project should trace back to a goal: `Context/strategy.md` goals → Projects → weekly review → daily tasks. Link each project README to the goal it serves. The weekly optimizer flags goals with no project and projects with no goal.
