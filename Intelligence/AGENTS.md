# Intelligence

Organizational knowledge: meetings, competitors, market intel, decisions, ideas, processes, reviews, archive.

## Routing

| Category | Type | Route to |
|---|---|---|
| Meetings | Client or prospect call | `meetings/client-calls/` |
| Meetings | One-on-one | `meetings/one-on-ones/` |
| Meetings | Team standup | `meetings/team-standups/` |
| Meetings | Anything else | `meetings/general/` |
| Meetings | Pre-meeting brief | `meetings/pre-meeting-briefs/` (requests in `requests/`) |
| Knowledge | Competitor | `competitors/{name}.md` |
| Knowledge | Market insight | `market/{topic}.md` |
| Knowledge | Decision with reasoning | `decisions/YYYY-MM-DD-{title}.md` |
| Knowledge | New idea (pre-decision) | `new-ideas/YYYY-MM-DD-{slug}.md`, indexed in `new-ideas/README.md` (overlap check first, root Rule 18) |
| Knowledge | Org-wide process / SOP | `processes/{name}.md` |
| Reviews | Weekly review | `reviews/YYYY-Www.md` |
| Archive | Completed or superseded | `archive/{name}/` |

Meeting filenames: `YYYY-MM-DD-{slug}.md`. Template: `Resources/templates/meeting-note.md`.

## Decision records

Include the *why*: who was involved, what tension prompted it, what trade-off was made. Use `> [!important]` for the decision itself and `> [!warning]` for known risks. Template: `Resources/templates/decision.md`.

## Competitor profiles

Use `> [!important]` for strategic implications and `> [!tip]` for opportunities.

## Rules

- Move completed projects, sunset competitors and superseded research to `archive/`.
- Every meeting note links its attendees, company and project with `[[wikilinks]]`.
