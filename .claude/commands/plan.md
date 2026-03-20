---
description: Create detailed implementation plans through interactive research and iteration
model: opus
---

# Implementation Plan

You are tasked with creating detailed implementation plans through an interactive, iterative process. Be skeptical, thorough, and work collaboratively with the user to produce high-quality technical specifications.

## Definitions

- **TASK_FOLDER**: A local folder on the repository root prefixed with `T-`

## Initial Setup

- If the `current-task` link does not exist or is a broken link, ask the user to pick an existing TASK_FOLDER or provide a new task name.
  - If the user picks an existing TASK_FOLDER, recreate the soft link `current-task` pointing to it
  - Otherwise, create a TASK_FOLDER from the input and create a new soft link `current-task` pointing to it

Then proceed to the Initial Response.

## Initial Response

1. **If a file path was provided as a parameter**: read it FULLY and begin research immediately.

2. **If no parameters provided**: Welcome the user, ask for the task description, relevant context/constraints, and any related files or research. Mention the `/plan <file>` shortcut. Wait for input.

## Process Steps

### Step 1: Context Gathering & Initial Analysis

1. **Read all mentioned files immediately and FULLY** using the Read tool without limit/offset parameters.
   - **CRITICAL**: Do NOT spawn sub-tasks before reading these files yourself in the main context.

2. **Spawn codebase-locator and codebase-analyzer agents in parallel** to find relevant files and understand the current implementation. After they complete, read ALL files they identified as relevant, fully into the main context. Be specific about exact paths in your agent prompts; if an agent returns unexpected results, spawn follow-up tasks to verify.

3. **Present informed understanding and focused questions**:
   - Summarize what you found (with file:line references)
   - List only questions that code investigation couldn't answer (technical decisions, business logic, design preferences)

### Step 2: Research & Discovery

1. **If the user corrects a misunderstanding**: do NOT just accept it — spawn new research tasks to verify, then read the relevant files yourself before proceeding.

2. **Create a research todo list** using the task list tool.

3. **Spawn parallel sub-tasks** using the right agent for each area:
   - **codebase-locator** — find specific files
   - **codebase-analyzer** — understand implementation details
   - **codebase-pattern-finder** — find similar features to model after

4. **Wait for ALL sub-tasks to complete**, then present findings, design options, and any remaining open questions. Ask which approach aligns with the user's vision.

### Step 3: Plan Structure Development

Once aligned on approach, present a proposed outline (overview + phases) and **get feedback on structure before writing details**.

### Step 4: Detailed Plan Writing

After structure approval:

1. **Save the file**:
   - Resolve `current-task` to the real path: `readlink -f current-task`
   - Filename format: `plan-YYYY-MM-DD-description.md` (kebab-case description, today's date)

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

#### Automated Verification:
- [ ] Migration applies cleanly: `make migrate`
- [ ] Unit tests pass: `make test-component`
- [ ] Type checking passes: `npm run typecheck`
- [ ] Linting passes: `make lint`
- [ ] Integration tests pass: `make test-integration`

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

- Related research: `current-task/research-[date]-[topic].md`
- Similar implementation: `[file:line]`
````

### Step 5: Review

Share the file path and ask whether the phasing, success criteria, and technical details need adjustment. Iterate until the user is satisfied.

## Key Rules

- **Be Skeptical**: Question vague requirements, identify issues early, verify with code rather than assuming.
- **No Open Questions in Final Plan**: If you encounter unresolved questions during planning, stop and research or ask immediately. Every decision must be made before the plan is finalized.
- **Automated success criteria should use `make` whenever possible** (e.g., `make test` instead of `cd subdir && npm run test`).