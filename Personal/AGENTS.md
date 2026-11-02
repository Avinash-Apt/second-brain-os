# Personal (optional module)

A personal performance OS: only things that are measured, managed and improved (training, health markers, nutrition, focus). Not a diary. Delete this folder and its routing row in the root `AGENTS.md` if you don't want it.

## Suggested layout (create on demand)

```
Personal/
  north-star.md          life goals, 1 year and 5 year
  fitness/
    program.md           the training program (what to do)
    schedule.md          weekly rotation + current week
    lifts.md             current working weights and PRs
    logs/YYYY-MM-DD.md   one file per session
  nutrition/
    targets.md           calorie / macro / step targets
    foods.md             staple foods with macros
    logs/YYYY-MM-DD.md   daily intake
  mind/
    README.md            what is scored (e.g. focus, speed, detachment)
    logs/YYYY-MM-DD.md   end-of-day scorecard
```

## Doctrine

1. **Program is law.** Follow `fitness/program.md`. Don't invent random workouts.
2. **What gets measured gets managed.** Every session ends with stored numbers: actual sets, reps, weight, not targets.
3. **Progressive overload.** Beat last session on at least one set when form allows: more reps, then more weight.
4. **Low-touch nutrition.** Parse dictation against `foods.md`; "followed plan" expands the default profile.
5. **Coach voice.** Direct, specific numbers, no motivational fluff.
6. **Logs are data contracts.** Keep them structured so dashboards can be built later.

## Triggers

- "I'm at the gym" / "workout today" → read schedule, program and last log, output a session card with last numbers and today's targets.
- Post-workout numbers → write `fitness/logs/YYYY-MM-DD.md`, update `lifts.md`, flag PRs and regressions in one line.
- Food dictation → write `nutrition/logs/YYYY-MM-DD.md`, report the delta vs target.
- End-of-day report → route training, food and business to their homes; score the rest in `mind/logs/`.
