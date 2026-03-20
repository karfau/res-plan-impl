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
- **Present options before acting**: For any non-trivial change, present at least 2 design options with explicit tradeoffs before making edits. One-line fixes (typos, punctuation) may be made directly.
- **Don't duplicate specifics**: Thresholds, criteria, and implementation details belong in the command file that owns them. The README and other references should describe in general terms — never repeat specific numbers or conditions that would need to be updated in multiple places.
- **No superseded/stale file markers**: Never add `superseded_by`, `archived`, `deprecated`, or similar fields or status markers on artifact files (research docs, plan files). When multiple files of the same type exist in a TASK_FOLDER, list them ordered by most recently modified and let the human decide which to use.

## Workflow Reference

> Verify this section against the actual command files when loading. Note any divergences before asking the user what to change.

Standard workflow (each step runs in a fresh session):

1. `/start` — initialize the repo; creates `PROJECT.md`, links code repos, creates `TASK_FOLDER` and `current-task` symlink, writes `task.yaml`
2. `/research` — documents the codebase; produces `research-YYYY-MM-DD-*.md`; sets `task.yaml status: researching` → `researched`
3. `/plan` — creates an implementation plan; produces `plan.md`; sets `task.yaml status: planning` → `planned`
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

## Steps

### 1. Load and verify

Read every file in the Command Registry fully. Then verify the Workflow Reference section above against what you read. If anything has drifted — a status name changed, a section was renamed, a new step was added — note it explicitly before proceeding:

```
Workflow reference drift detected:
- [item]: reference says X, actual command says Y
```

Build a mental model of: structural patterns, cross-command dependencies, task.yaml lifecycle, and Project Context handling across all commands.

Also read `README.md` fully to understand how the commands are presented to users and what is currently documented.

### 2. Ask the user what to change

Present a brief status summary, then ask:

```
I've read all [N] commands and verified the workflow reference. [Note any drift if found.]

Current structural state:
- [1-3 bullet summary of anything notable: inconsistencies, recent changes, open questions]

What would you like to change?
```

Wait for the user's input before proceeding.

### 3. Research reference material (if helpful)

For novel design questions — especially around human-in-the-loop interactions — you may inspect files under `.refs/github.com/humanlayer/humanlayer/` for inspiration. Use them for ideas only; never model structural consistency after them, and never modify them.

### 4. Present design options

For any non-trivial change, present 2–3 options. For each:
- Describe the approach in plain terms
- List concrete benefits
- List concrete drawbacks
- Note any consistency implications for other commands

Wait for the user to select or ask for more discussion.

### 5. Implement

Make changes to the command files. After each logical group of changes, briefly state what changed and why. If a change touches multiple commands, explain the cross-command impact.

If mid-implementation you discover an unexpected complication or a design choice that wasn't surfaced in step 4, stop and raise it before continuing.

### 6. Consistency check

Run through the Consistency Checklist. For each failing item:
- If it was introduced by the current changes: fix it
- If it pre-existed and is out of scope: note it for the user as a follow-up suggestion

### 7. Stage and summarize

If any command was added, removed, renamed, or its behavior significantly changed, suggest to update `README.md`, let the user refine wording or iterate over it before applying and staging.

```
git add .claude/commands/ README.md
```

Present a summary:
- What was changed and why
- Any pre-existing inconsistencies noted (not fixed) for future follow-up
- Any updates needed to the Workflow Reference or Consistency Checklist in this file

### 8. Continue or close

Ask the user:

```
Is there more related work to do, or any ideas to discuss while we have this context loaded?

Context window used: ~[N]% — for unrelated topics, starting a fresh session is recommended.
```

If the user has more to do, return to step 4 (if it's a new change request) or step 2 (if it's a new topic that requires re-reading). If not, close the session.