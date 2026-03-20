---
description: Implement a plan using phase-level TDD — tests first, then code, with manual verification between phases
model: opus
---

# Implementation

You are tasked with implementing an approved plan using strict phase-level TDD: for each phase, all tests are written and confirmed failing before any implementation code is written.

## Key Rules

- **Never write implementation code before tests for that phase are written and confirmed red.**
- Prefer `make` targets over raw test/lint commands.
- Add docstrings to all new and modified public functions, classes, and modules following the project's existing language conventions and code style.
- If you cannot make a test fail (behavior already exists), always ask before skipping.
- Phases must be completed in order — do not start Phase N+1 until Phase N manual verification is confirmed.
- If instructed to execute multiple phases consecutively, skip intermediate pauses and pause only after the last phase.
- Use sub-tasks sparingly — mainly for targeted debugging or exploring unfamiliar code.

## Definitions

- **TASK_FOLDER**: A local folder on the repository root prefixed with `T-`

## Project Context

If `PROJECT.md` exists at the repository root, read it fully. For each repo listed under `## Repositories`:
- Note its resolved path
- If "Agent instructions" is listed: read each of those files fully (`CLAUDE.md`, `AGENTS.md`, etc.) before starting

When spawning any sub-agent, include the resolved repo path in the prompt:
*"The target codebase is at `{resolved_path}`. If `.claude/`, `CLAUDE.md`, or `AGENTS.md` exist there, follow their conventions."*

**If any repo in `## Repositories` has an "Env:", "Install:", or "Node version:" line**, pause and inform the user before proceeding:

> "This task involves `code/{name}` (`{resolved_path}`), which requires environment/tooling setup
> (detected: {list what was found}).
>
> For best results, run implementation from a Claude session started inside that repository, where
> the correct environment and repo-specific Claude instructions are automatically available:
> ```
> cd {resolved_path}
> claude
> ```
> Once inside that session, tell Claude:
> *"Implement the plan at `{absolute_path_to_plan}`"*
>
> Would you like to continue from this session anyway, or start from the target repository?"

If the user chooses to continue anyway, prefix all commands run in that repo with
`direnv exec {resolved_path}` (e.g. `direnv exec {resolved_path} make test`).

## Setup

1. **Find the plan to implement**:
   - If a file path was provided as a parameter, use that
   - Otherwise, list files matching `current-task/plan-*.md` and use the most recent one
   - Confirm with the user which plan you're implementing before proceeding

2. **Read everything fully** (no limit/offset parameters):
   - The plan file
   - The original ticket or task description if referenced
   - All files mentioned in the plan

3. **Check for existing checkmarks** (`- [x]`): if any exist, this is a resumption — trust that completed work is done, pick up from the first unchecked item, and verify previous work only if something seems off.

4. **Resolve `current-task`** to the real path: `readlink -f current-task`

5. **Check task dependencies**: read the current task's `task.yaml` if it exists. If `depends_on` lists any tasks, check their `task.yaml` status. If any dependency is not `complete`, warn the user before proceeding:
   ```
   Warning: This task depends on {T-other-task} which has status "{status}".
   Proceeding may cause conflicts or duplicate work. Confirm to continue anyway.
   ```
   After confirmation (or if no blockers): update `task.yaml` status to `in-progress`.

6. **Create a todo list** to track your progress through the phases.

## For Each Phase (strictly in order)

### 1. Understand the phase
Read the phase's Overview, Behavioral Specs, Changes Required, and Success Criteria. If any Behavioral Spec is ambiguous, ask for clarification before writing tests.

If reality diverges from what the plan describes, stop and present the issue before proceeding:
```
Issue in Phase [N]:
Expected: [what the plan says]
Found: [actual situation]
Why this matters: [explanation]

How should I proceed?
```

### 2. Write all tests first
Translate each Behavioral Spec into one or more tests using the project's existing test framework and conventions.

- Use `codebase-pattern-finder` to find existing test examples if conventions are unclear
- Write tests that will fail because the behavior doesn't exist yet
- Do **not** write any implementation code yet
- If a phase has no Behavioral Specs, ask the user whether to add specs or proceed without TDD for that phase

### 3. Confirm red
Run the tests. **All new tests must fail.** If any pass without implementation:
- The behavior may already exist — flag this to the user and ask how to proceed
- Or the test may be wrong — fix it before continuing

Do not proceed until failing tests are confirmed.

### 4. Implement until green
Write only the code needed to make the tests pass. Follow the Changes Required section of the plan and project conventions. Run tests frequently as you implement.

If you need to write code that can't be meaningfully tested (pure scaffolding, config files, infrastructure), note this explicitly.

### 5. Run automated verification
Run all commands from the phase's Automated Verification section. Prefer `make` targets over raw commands. Fix any failures before proceeding.
Check off completed automated items in the plan file using Edit.
Also run the project's code formatter if one is present (e.g. `make format`, `pnpm format`, `ruff format`).
Prefer a `make` target if available; otherwise detect from tooling (`pnpm`/`prettier`, `ruff`, etc.).

Update `affected_files` in `task.yaml`: add any files created or modified in this phase
that are not already listed, using the nested-by-repo structure (see data model in `/plan`).
Omit transient files (lock files, build artifacts, generated files).

### 6. Pause for manual verification

Present this to the user and wait for confirmation before moving to the next phase:
```
Phase [N] Complete - Ready for Manual Verification

Automated verification passed:
- [list of automated checks that passed]

Please perform the manual verification steps listed in the plan:
- [list of manual verification items]

Let me know when manual testing is complete so I can proceed to Phase [N+1].
```

Do not check off manual testing items in the plan until the user confirms them.

Once manual verification is confirmed, recommend committing and pushing:
```
git add {files modified in this phase}
git commit -m "Phase [N]: {phase name}"
git push
```
This is especially important when `task.yaml` was updated (affected_files changed), so
other tasks' overlap detection reflects current state immediately.

## Finishing Up

After all phases are complete and the final manual verification is confirmed:
- Update current task's `task.yaml` status to `complete`
- Stage: `git add {resolved_task_folder}/`

## If You Get Stuck

- Read more of the relevant code before trying anything else
- Consider whether the codebase has evolved since the plan was written
- Present the mismatch clearly using the format in Step 1 and ask for guidance
- Use sub-tasks for targeted debugging, not broad exploration