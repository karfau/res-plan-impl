# Research - Plan - Implement

A repository for managing the structured LLM-assisted development workflow based on the

> research → plan → implement

approach described [here](.refs/github.com/humanlayer/advanced-context-engineering-for-coding-agents/ace-fca.md).

## Why it works

AI coding agents degrade in long sessions. The context fills with search results, file reads, and failed attempts, and
quality drops as the window grows.
This workflow counters that by keeping each phase focused — research, plan, and implement each run in a fresh session
with only the compact output of the previous phase as input, keeping context utilization lean and accurate throughout.

The structured artifacts are a second, compounding benefit. Research documents and plans are committed 
and can serve as a reference of detailed progress on a topic, handover in case of sickness, etc

Errors compound across phases: a bad line of code is just a bad line of code, but a bad line of a plan
could lead to hundreds of bad lines of code, and a bad line of research — a misunderstanding of how the codebase
works — could produce thousands. Human effort is highest-leverage when applied to research and plan review, not
code review.

![errors compound across phases](https://github.com/user-attachments/assets/dab49f61-caae-4c15-b481-ee9b8f64995f)

Reviewing a 200-line plan before implementation begins is therefore higher leverage than reviewing the resulting
2,000-line PR.

Teams that adopt this workflow report better mental alignment — everyone can read a plan in minutes, 
without spelunking through dozens of files to understand why code was written a certain way.

The three phases are implemented as Claude Code slash commands:

## 1. `/research`

[`/research`](.claude/commands/research.md) documents the relevant parts of the codebase as they exist today. It spawns
parallel sub-agents to explore
different areas concurrently and synthesizes their findings into a structured Markdown document saved to the current
task folder. The document captures file references, architectural patterns, and open questions — without recommendations
or critiques. It serves as the factual foundation for `/plan`.

**Input**: a research question or area of interest.
**Output**: `T-{task}/research-YYYY-MM-DD-{topic}.md`

## 2. `/plan`

[`/plan`](.claude/commands/plan.md) takes research findings and produces a detailed, phased implementation plan through
an interactive process. Each
phase defines observable behavioral specs, the code changes required, and both automated and manual success criteria.
The plan must be reviewed and approved before implementation begins.

**Input**: research document and requirements discussion.
**Output**: `T-{task}/plan-YYYY-MM-DD-{description}.md`

## 3. `/implement`

[`/implement`](.claude/commands/implement.md) executes an approved plan one phase at a time using phase-level TDD: all
tests for a phase are written and
confirmed failing before any implementation code is written. After the tests pass, automated verification runs and you
confirm manual testing before the next phase begins. Progress is tracked via checkboxes in the plan file so work can be
resumed at any point.

**Input**: a plan file (passed as argument, or the most recent one in the task folder).
**Output**: implemented and verified code, with the plan file fully checked off.

## Getting `/start`ed

Start by running [`/start`](.claude/commands/start.md) in a fresh Claude session to start working on something new or
switch to a different project or task.

Each project lives on its own branch — switching projects means switching branches.
The `main` branch stays clean, so the repo can be used as a template.

Within a project, work is broken into task folders prefixed with `T-` (e.g. `T-auth-refactor`). The
`current-task` symlink points to whichever task you are currently working on; it is gitignored so each contributor sets
their own independently.

For single-contributor work, tasks progress sequentially through research, plan, and implement.

In a team setting, multiple contributors can work on the same branch simultaneously
by each pointing `current-task` at a different task folder.

Task dependencies are declared in each task's `task.yaml` so `/start` warns when a task depends on work not yet
complete.

Each command is designed for a dedicated Claude session. After `/start` sets everything up, start a new session or
`/clear` before running `/research`, `/plan`, or `/implement`.

### File Structure Overview

- `PROJECT.md` — project description and linked repository metadata (paths, tooling, env requirements)
- `T-{name}/` — task folder containing research docs, plan files, and `task.yaml` (status and dependencies)
- `code/` — symlinks or clones of the repositories being worked on
- `.claude/commands/` — the `/start`, `/research`, `/plan`, and `/implement` command definitions

## Why an extra repo?

In its simplest form you do not need a dedicated repository for this workflow.

But sharing learnings matters. And when creating the artifacts — Markdown files that are the output of one phase and the
input of the next — it helps to have a place for them that is separate from the target codebase, away from CI pipelines
that trigger on every push.

It also makes it easy to track multiple plans for an epic or initiative without polluting the git history of the repo
you are actually shipping.

Use this repo as a template: create a branch to get started, or use the GitHub UI to create a new repo from it.

## Contributing

If you've found better prompting patterns, hit edge cases in the workflow, or have ideas for new commands, contributions are welcome. 
Open a pull request, improvements here benefit everyone building with this setup.

And of course Not all of this is easily maintainable by hand. Use the LLM to explore, refine and improve things across multiple commands or subagents. 
