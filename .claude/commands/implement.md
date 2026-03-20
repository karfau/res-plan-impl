---
description: Implement a plan using phase-level TDD — tests first, then code, with manual verification between phases
model: opus
---

# Implementation

You are tasked with implementing an approved plan using strict phase-level TDD: for each phase, all tests are written and confirmed failing before any implementation code is written.

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

5. **Create a todo list** to track your progress through the phases.

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
Run all commands from the phase's Automated Verification section. Prefer `make` targets over raw commands. Fix any failures before proceeding. Check off completed automated items in the plan file using Edit.

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

## Key Rules

- **Never write implementation code before tests for that phase are written and confirmed red.**
- Prefer `make` targets over raw test/lint commands.
- If you cannot make a test fail (behavior already exists), always ask before skipping.
- Phases must be completed in order — do not start Phase N+1 until Phase N manual verification is confirmed.
- If instructed to execute multiple phases consecutively, skip intermediate pauses and pause only after the last phase.
- Use sub-tasks sparingly — mainly for targeted debugging or exploring unfamiliar code.

## If You Get Stuck

- Read more of the relevant code before trying anything else
- Consider whether the codebase has evolved since the plan was written
- Present the mismatch clearly using the format in Step 1 and ask for guidance
- Use sub-tasks for targeted debugging, not broad exploration