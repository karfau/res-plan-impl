---
description: Extract phases from a large plan or multiple overlapping plans into an independent task to reduce cognitive load and implementation session cost
model: opus
---

# Split a plan

## Key Rules

IMPORTANT: This command is strictly interactive. You MUST present proposals as options and
wait for explicit user confirmation at every decision point. NEVER create, modify, or delete
any file — including plan files, task.yaml, or task folders — without the user typing an
explicit acceptance.

ALWAYS present the proposed split as a structured proposal (Step F) before taking any
action. If multiple split options are possible, YOU MUST present them as distinct choices
rather than picking one.

The proposal step is not a formality — it is the primary value this command delivers.
The user needs to understand and agree with the proposed structure before any changes are
made to their task folders.

## Definitions

- **TASK_FOLDER**: A local folder on the repository root prefixed with `T-`

## Purpose

Extract phases from a large plan into an independent task, reducing cognitive load during
review, shortening implementation sessions, and producing a cleaner dependency graph.
Also supports multi-plan reorganization: when multiple plans are provided, phases across
them can be consolidated or redistributed.

## Input

One or more plan file paths (space-separated). If none provided, use `current-task/plan.md`
and ask if any other plan(s) should be investigated in addition. Provide a list to pick from.

## Steps

### A. Load context

- Read all provided plan files fully
- Read all `T-*/task.yaml` files (for `affected_files` and the existing dependency graph)

### B. Cross-plan overlap analysis (when multiple plans provided)

- Find phases across the provided plans that touch the same files
- Identify logically identical or duplicated phases
- Flag these as candidates for consolidation into a shared extracted task

### C. Evaluate each plan for extractable units

Look for:

- **Foundation layer**: one or more phases whose output all/most later phases depend on,
  and which themselves depend on nothing in later phases
- **Parallel branch**: two or more phase groups where the groups have no shared files —
  a clean seam exists between them

### D. Keep-as-is check

Recommend keeping the plan as-is if **either** of these applies:

- **≤5 phases total** (across all provided plans) — splitting offers little benefit for
  the cognitive load and session cost it saves
- **No extractable unit** — neither a foundation layer nor a clean seam can be identified;
  splitting would create coordination overhead without meaningful isolation

If keep-as-is applies, explain which criterion triggered it and stop:

```
Recommendation: keep T-big-task as a single plan.
Reason: no clean seam found — all phase groups share files, so splitting would require
coordination on shared files rather than eliminating it.
```

### E. Factor in related tasks

For tasks whose `affected_files` overlaps with the plan(s) being split:

- Note which files are shared
- If the extracted task would own those files, flag that the related task should declare
  `depends_on` on the new extracted task
- Include this wiring in the proposal

### F. Present proposal

Present the split as a structured proposal and wait for explicit user confirmation.
If multiple valid splits exist, present them as numbered options.

Example proposal format:

```
Split proposal for T-big-task:

Extract Phases 1–2 → T-big-task-foundation (new task)
  Phases:
    1. Schema migration
    2. Type definitions

T-big-task updated in-place (Phases 3–7 renumbered to 1–5):
  task.yaml: depends_on: [T-big-task-foundation]

[Warning if >3 tasks would result from the split: managing N dependent tasks adds
coordination overhead — confirm this is worth it.]

Related tasks affected:
  T-auth-ui shares src/auth/session.ts (in extracted Phases 1–2).
  After split, T-auth-ui should declare depends_on: [T-big-task-foundation].

Accept, adjust, or decline?
```

### G. On acceptance

Only proceed after explicit user acceptance.

1. Create `T-{extracted-name}/` folder
2. Write `task.yaml` in the new folder:
   - `status: planned`
   - `affected_files` populated from the extracted phases (nested by repo)
3. Write `plan.md` in the new folder with only the extracted phases, renumbered from Phase 1
4. Edit the original `plan.md`: remove extracted phases, renumber remaining phases from 1
5. Update the original `task.yaml`:
   - Add `depends_on: [{extracted-task-name}]`
   - Update `affected_files` to reflect the remaining phases only
6. Update `current-task` symlink to the new extracted task (it must be completed first)
7. Stage changes: `git add {extracted task folder}/ {original task folder}/`