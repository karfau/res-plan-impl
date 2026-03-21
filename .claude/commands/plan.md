---
description: Create the detailed implementation plan through interactive research and iteration
model: opus
---

# Implementation Plan

You are tasked with creating the detailed implementation plan through an interactive, iterative process. Be skeptical, thorough, and work collaboratively with the user to produce high-quality technical specifications.

## Key Rules

- **Be Skeptical**: Question vague requirements, identify issues early, verify with code rather than assuming.
- **No Open Questions in Final Plan**: If you encounter unresolved questions during planning, stop and research or ask immediately. Every decision must be made before the plan is finalized.
- **Automated success criteria should use `make` whenever possible** (e.g., `make test` instead of `cd subdir && npm run test`).
- IMPORTANT: The iterative phases are the most valuable part of this command — they let the user guide the plan's direction before details are written, making the final plan easy to review rather than a document to start from scratch on. ALWAYS present the phase outline and get explicit user feedback before writing phase details (Step 3). NEVER skip straight to writing the full plan. YOU MUST discuss and confirm structural choices with the user as they emerge.

## Definitions

- **TASK_FOLDER**: A local folder on the repository root prefixed with `T-`

## Initial Setup

- If the `current-task` link does not exist or is a broken link, ask the user to pick an existing TASK_FOLDER or provide a new task name.
  - If the user picks an existing TASK_FOLDER, recreate the soft link `current-task` pointing to it
  - Otherwise, create a TASK_FOLDER from the input and create a new soft link `current-task` pointing to it
- Resolve `current-task` to the real path: `readlink -f current-task`
- Read `task.yaml` from all TASK_FOLDERs at the repo root; note each task's status and dependencies — be aware of potential overlap with parallel work
- **Status check**: if the current task has a `task.yaml` and its status is not `researched`, `planned`, or `planning`, warn before proceeding:
  > "Current status is `{status}` — expected `researched` before planning. Continue anyway?"
  Wait for confirmation before proceeding.
- If `plan.md` already exists in the current task folder, read it fully — this is a refinement session, not a fresh start.
- List all `research-*.md` files in the current task folder ordered by most recently modified and read them all fully into context. Report which files were found (e.g. "Found 2 research docs: research-2025-01-08-auth-flow.md, research-2025-01-10-session-storage.md").
- If the current task has `depends_on` entries, read those tasks' `plan.md` for context

Then proceed to the Initial Response.

## Project Context

If `PROJECT.md` exists at the repository root, read it fully. For each repo listed under `## Repositories`:
- Note its resolved path
- If "Agent instructions" is listed: read each of those files fully (`CLAUDE.md`, `AGENTS.md`, etc.) before any research

When spawning any sub-agent, include the resolved repo path in the prompt:
*"The target codebase is at `{resolved_path}`. If `.claude/`, `CLAUDE.md`, or `AGENTS.md` exist there, follow their conventions."*

**If any repo in `## Repositories` has an "Env:", "Install:", or "Node version:" line**, pause and inform the user before proceeding:

> "This task involves `code/{name}` (`{resolved_path}`), which requires environment/tooling setup
> (detected: {list what was found}).
>
> For best results, run planning from a Claude session started inside that repository, where the
> correct environment and repo-specific Claude instructions are automatically available:
> ```
> cd {resolved_path}
> claude
> ```
> Once inside that session, tell Claude:
> *"Create the plan — read the research at `{absolute_path_to_research_file}`"*
>
> Would you like to continue from this session anyway, or start from the target repository?"

If the user chooses to continue anyway, proceed. Note any env-dependent success criteria commands
should be prefixed with `direnv exec {resolved_path}` and marked with a caveat that they require
a configured `.envrc`.

## Initial Response

1. **If `plan.md` was loaded in Initial Setup**: summarize the existing plan (phases, key decisions) and ask: "What would you like to change or refine?" Skip to whichever Step best matches the requested change — the user may only need to adjust a phase (Step 4) or restructure (Step 3) without redoing full research.

2. **If no existing plan**: Welcome the user, summarize the research docs already loaded (from Initial Setup), and ask for the task description and any additional context, constraints, or relevant files. Wait for input.

## Process Steps

### Step 1: Context Gathering & Initial Analysis

1. **Read all mentioned files immediately and FULLY** using the Read tool without limit/offset parameters.
   - **CRITICAL**: Do NOT spawn sub-tasks before reading these files yourself in the main context.

2. **Spawn codebase-locator and codebase-analyzer agents in parallel** to find relevant files and understand the current implementation. After they complete, read ALL files they identified as relevant, fully into the main context. Be specific about exact paths in your agent prompts; if an agent returns unexpected results, spawn follow-up tasks to verify.

3. **Present informed understanding and focused questions**:
   - Summarize what you found (with file:line references)
   - List only questions that code investigation couldn't answer (technical decisions, business logic, design preferences)

### Step 2: Research & Discovery

1. **Ask about external dependencies** before spawning any research agents: "Are there any external dependencies for this task — things outside the codebase that must be in place before implementation can begin (e.g. third-party API access, infrastructure provisioning, approvals from stakeholders)?" Note each item — they will inform research scope and design options, and will be written to the plan in Step 5.

2. **If the user corrects a misunderstanding**: do NOT just accept it — spawn new research tasks to verify, then read the relevant files yourself before proceeding.

3. **Create a research todo list** using the task list tool.

4. **Spawn parallel sub-tasks** using the right agent for each area:
   - **codebase-locator** — find specific files
   - **codebase-analyzer** — understand implementation details
   - **codebase-pattern-finder** — find similar features to model after

5. **Wait for ALL sub-tasks to complete**, then present findings, design options, and any remaining open questions. Ask which approach aligns with the user's vision.

### Step 3: Plan Structure Development

Once aligned on approach, present a proposed outline (overview + phases) and **get feedback on structure before writing details**.

### Step 4: Detailed Plan Writing

After structure approval:

1. **Save the file**:
   - Resolve `current-task` to the real path: `readlink -f current-task`
   - Filename: `plan.md`
   - After saving, update `task.yaml`: set `status: planning`.

2. **Use this template**:

````markdown
# [Feature/Task Name] Implementation Plan

## Overview

[Brief description of what we're implementing and why]

## Current State Analysis

[What exists now, what's missing, key constraints discovered]

## Desired End State

[A specification of the desired end state and how to verify it]

### Key Discoveries:
- [Important finding with file:line reference]
- [Pattern to follow]
- [Constraint to work within]

## What We're NOT Doing

[Explicitly list out-of-scope items to prevent scope creep]

## External Dependencies

[Things outside the codebase that must be in place before implementation can begin — one checkbox per item. Write "None identified." if there are none.]

## Implementation Approach

[High-level strategy and reasoning]

## Phase 1: [Descriptive Name]

### Overview
[What this phase accomplishes]

### Behavioral Specs:
- [observable behavior in plain language — no test code, no function names]
- [another behavior this phase must satisfy]
- [edge case or error condition to handle]

### Changes Required:

#### 1. [Component/File Group]
**File**: `path/to/file.ext`
**Changes**: [Summary of changes]

```[language]
// Specific code to add/modify
```

### Success Criteria:

#### Prerequisites:
- [ ] Dependencies installed: `direnv exec code/{name} pnpm install` *(omit if no linked repo)*
- [ ] Env configured: `.envrc` exists and `direnv allow` has been run *(omit if no .envrc required)*

#### Automated Verification:
- [ ] Migration applies cleanly: `direnv exec code/{name} make migrate`
- [ ] Unit tests pass: `direnv exec code/{name} make test`
- [ ] Type checking passes: `direnv exec code/{name} npm run typecheck`
- [ ] Linting passes: `direnv exec code/{name} make lint`

#### Manual Verification:
- [ ] Feature works as expected when tested via UI
- [ ] Performance is acceptable under load
- [ ] Edge case handling verified manually
- [ ] No regressions in related features

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Phase 2: [Descriptive Name]

[Similar structure with both automated and manual success criteria...]

---

## Testing Strategy

### Unit Tests:
- [What to test]
- [Key edge cases]

### Integration Tests:
- [End-to-end scenarios]

### Manual Testing Steps:
1. [Specific step to verify feature]
2. [Another verification step]
3. [Edge case to test manually]

## Performance Considerations

[Any performance implications or optimizations needed]

## Migration Notes

[If applicable, how to handle existing data/systems]

## References

- Related research: `current-task/research-YYYY-MM-DD-[topic].md`
- Similar implementation: `[file:line]`
````

### Step 5: Review

Share the file path and ask whether the phasing, success criteria, and technical details need adjustment. Iterate until the user is satisfied.

Populate the `## External Dependencies` section from items gathered in Step 2: add a `- [ ] {item}` checkbox for each one. If none were identified, write "None identified."

Before finalizing, extract all file paths from this plan's Changes Required sections and
write them to `task.yaml` as `affected_files` (nested by repo, flat list per repo, scope
as inline comments). This happens unconditionally. Purpose: this cache lets overlap
detection read small `task.yaml` files rather than full plan files, keeping context usage
lean during planning sessions.

Using those same extracted paths, check in a single pass:

- **Overlap signal**: read `affected_files` from all other task folders in `planning`,
  `planned`, `researching`, `researched`, or `in-progress` status. If any files appear in both this
  plan and another task's list, note the overlapping task(s) and files.
- **Split signal**: count the phases in this plan. Check for a foundation layer or a clean
  seam (a group of phases with no shared files with the remaining phases). Signal fires if
  >5 phases or an extractable unit exists.

If any signal fires, prepend a single `> **Note**:` block to the plan file (after the `## Overview` section):

- Overlap → list overlapping task(s) and files; suggest declaring a dependency
- Split → note phase count and/or extractable unit; suggest running `/split` in a new session

Example:
```
> **Note**: Overlaps with `T-auth-foundation` (shared: `src/auth/session.ts`). Consider
> declaring a dependency. This plan also has 7 phases — consider running `/split` in a
> new session to reduce cognitive load and session cost.
```

If neither signal fires, write no note.

**Decision Records**: Review the decisions made during this planning session. For each one,
judge whether it could affect other tasks or future work beyond the current task (e.g.
architectural choices, shared patterns, technology selections). Skip anything that is
clearly scoped to this task alone. If any cross-task decisions are identified, present them:

> The following decisions may be worth recording at the project level:
> - **[Title]**: [brief description]
> - ...
>
> Should any of these be added to PROJECT.md?

For each decision the user confirms, append to the `## Decision Records` section of
`PROJECT.md` (create the section if absent), using this format:

```
YYYY-MM-DD · [git config user.name] · [T-task-name/plan.md](T-task-name/plan.md)
**[Title]**: [Decision and rationale in one or two sentences.]
```

Use today's date and `git config user.name` for the prefix. The link uses the task folder
name and `plan.md` as a relative path from the repo root. Add a blank line between entries.

If any records were added: `git add PROJECT.md`

Once the plan is finalized:
- Update current task's `task.yaml`: set `status: planned`
- Stage: `git add {resolved_task_folder}/`