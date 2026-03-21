---
description: Work on command files while maintaining consistency across the workflow
model: opus
---

# Commands

You are tasked with helping the user modify command files in this repository. Before any changes are made, you must read and understand all command files to maintain structural consistency and avoid logical errors between them.

## Key Rules

- **Simplicity over cleverness**: Commands must remain readable and editable by a human without AI assistance. Avoid cross-references, complex state, or clever abstractions that only an LLM can maintain.
- **Consistency by default**: Unless there is a documented reason, structural elements (frontmatter fields, section names and order, Key Rules, Definitions, Initial Setup, Project Context) should be present and consistent across all applicable commands. Use the Consistency Checklist after every change.
- **Reference files are read-only**: Files under `.refs/` may be consulted for inspiration on human-in-the-loop patterns or plan ideas, but must never be modified. They are not models for structural consistency — this repo's commands are more simplistic, deterministic, and manual-edit-friendly.
- **Present options before acting**: For any non-trivial change, present at least 2 design options with explicit tradeoffs before implementing. For changes the agent judges as low-risk (typos, obvious one-liners), describe what you'll do and wait for confirmation before implementing. Never make a change silently.
- **Don't duplicate specifics**: Thresholds, criteria, and implementation details belong in the command file that owns them. The README and other references should describe in general terms — never repeat specific numbers or conditions that would need to be updated in multiple places.
- **No superseded/stale file markers**: Never add `superseded_by`, `archived`, `deprecated`, or similar fields or status markers on artifact files (research docs, plan files). When multiple files of the same type exist in a TASK_FOLDER, list them ordered by most recently modified and let the human decide which to use.

## Workflow Reference

> Verify this section against the actual command files when loading. Note any divergences before asking the user what to change.

Standard workflow (each step runs in a fresh session):

1. `/start` — initialize the repo; creates `PROJECT.md`, links code repos, creates `TASK_FOLDER` and `current-task` symlink, writes `task.yaml`
2. `/research` — documents the codebase; produces `research-YYYY-MM-DD-*.md`; sets `task.yaml status: researching` → `researched`
3. `/plan` — creates the implementation plan; produces `plan.md`; sets `task.yaml status: planning` → `planned`
4. `/implement` — executes the plan phase by phase with TDD; sets `task.yaml status: in-progress` → `complete`

Independent utilities:
- `/split` — extracts phases from a large plan into a new `TASK_FOLDER`; does not own a task lifecycle status
- `/commands` — this file; modifies command files while maintaining consistency

Inter-session state: `current-task` symlink + `task.yaml` per `TASK_FOLDER` + `PROJECT.md`.

> **Important**: `task.yaml` status is git-based (eventual consistency) — it reflects pushed/pulled state, not real-time coordination. Do not rely on it to prevent concurrent edits across different machines.

## Command Registry

Read these files **fully** at session start. Update this list when a new command that contributes to the workflow is added.

**Workflow commands:**
- `.claude/commands/start.md`
- `.claude/commands/research.md`
- `.claude/commands/plan.md`
- `.claude/commands/implement.md`

**Utility commands:**
- `.claude/commands/split.md`

## Consistency Checklist

Run this after every change. If any item fails, raise it with the user before closing the session.

**Frontmatter**
- [ ] All commands have a `description:` field
- [ ] All commands that need to understand a lot of context and reason about it need to have `model: opus`; `start.md` uses `model: haiku`

**Sections — workflow commands** (`research`, `plan`, `implement`)
- [ ] `## Key Rules` present
- [ ] `## Definitions` present, `TASK_FOLDER` defined
- [ ] `## Initial Setup` present (no trailing colon)
- [ ] `## Project Context` present with env/tooling warning and sub-session redirect

**Sections — utility commands** (`split`)
- [ ] `## Key Rules` present
- [ ] `## Definitions` present, `TASK_FOLDER` defined

**Cross-command flow**
- [ ] `task.yaml` status progression is consistent: `pending → researching → researched → planning → planned → in-progress → complete`
- [ ] Every command that modifies files stages them with `git add` at the end
- [ ] `readlink -f current-task` used wherever task folder paths are needed
- [ ] File naming conventions consistent: `research-YYYY-MM-DD-*.md`, `plan.md`

**Terminology**
- [ ] `TASK_FOLDER` used consistently (not "task folder" or "T- folder")
- [ ] `current-task` (hyphenated, no spaces) used consistently

**README**
- [ ] All workflow commands are documented in `README.md`
- [ ] `/split` is mentioned inline in the `/plan` section (no subsection header)
- [ ] `/commands` tip appears in the Contributing section
- [ ] File structure overview lists current command files accurately

## Phases

### Phase A: Load and verify

- Check `git status .claude/commands/` — if any files are dirty, assume resumption of a
  previous incomplete session. Show the diff; the consistency check below will surface
  any issues as todo items without needing to ask the user.
- Read every file in the Command Registry fully, plus `README.md`.
- Verify the Workflow Reference section above against what you read. If anything has
  drifted, note it explicitly:
  ```
  Workflow reference drift detected:
  - [item]: reference says X, actual command says Y
  ```
- Build a mental model of: structural patterns, cross-command dependencies, task.yaml
  lifecycle, and Project Context handling across all commands.
- **Changes are applied directly after user confirmation per todo item** — no batching.

**Pre-flight consistency check** (runs at the end of Phase A, before anything else):
Run the full Consistency Checklist. Add all failures to the todo list as high-priority
items. Then add any provided command arguments as lower-priority items.

**Phase routing** (based on pre-flight results):

| Consistency issues found | Args provided | Route |
|---|---|---|
| Yes | Yes | → Phase C (startup issues first, then args) |
| Yes | No | → Phase C (startup issues first, then Phase D asks "what next?") |
| No | Yes | → Phase C (args only) |
| No | No | → Phase B (ask user what to change) |

When seeding from the pre-flight check, briefly inform the user:
"Found N consistency issues — added to todo list as priority items. Will process those
first before [your requested changes / asking for input]."

### Phase B: Gather work

*(Only reached if the pre-flight check found no issues AND no args were provided.)*

Present a brief status summary:

```
I've read all [N] commands. Here's the current workflow:

/start → /research → /plan → /implement  (/split is a utility for large plans)

Interactive Commands:
- start.md      — prepares the working tree, links code repos, creates task folder
- research.md   — explores codebase -> research-YYYY-MM-DD-*.md
- plan.md       — creates phased plan -> plan.md
- split.md      — split conflicting or big plans into new tasks
- implement.md  — executes the plan with TDD, phase by phase

What would you like to change or ask about the workflow in this repo?
```

Wait for input. Seed the todo list from the user's answer, ordered by **impact on
workflows/commands** (cross-command flow changes first; cosmetic or isolated changes last).

### Phase C: Work loop

This phase runs until the todo list is empty AND the Consistency Checklist passes.

**For each item in the todo list (in order):**

1. **For non-trivial changes**: present at least 2 design options with tradeoffs and wait
   for selection before implementing. **For low-risk changes** (agent judgment): describe
   what you'll do and wait for confirmation before implementing. Never implement silently.

2. **Implement** the change directly after confirmation. Briefly state what changed and why.
   If a change affects user-facing behavior, add a README update as the next todo item.
   If an unexpected complication surfaces, stop and raise it before continuing.

3. **Run the Consistency Checklist.** For each failure, add it to the todo list if not
   already present.

4. Mark the current item complete. Move to the next.

**When the todo list is empty**: run the Consistency Checklist one final time.
- All pass → proceed to Phase D
- Any fail → add failures to todo list and continue the loop

*(The agent does not ask the user for open-ended input during this loop — only for
confirmations or design option selections. The user is able to amend/add notes to options provided by the agent
and is informed of progress via todo list updates and brief change notes.)*

### Phase D: Stage and close

*(Requiring the stated assertion is a guard against agents skipping verification under task-completion momentum.)*
You MUST honestly remember the following state: "Consistency Checklist complete — all items pass. Todo list empty.", otherwise return to phase C.

```
git add .claude/commands/ README.md
```

Present the close message (info first, question last):

```
Summary:
- [What changed and why, one bullet per logical group]

Session guidance:
- [Only show applicable lines:]
  - If commands.md was edited: "commands.md was modified — use /clear and rerun /commands again so the updated version takes effect!"
  - If context >= 60%: "Consider /compact before continuing."

Context window used: ~[N]%

Is there more to do?
  → More similar topics to discuss → return to Phase B
  → Unrelated topics → /clear or start a new session
  → Done → close
```