---
description: Prepares your local copy of the repo to get you started working on a project or task.
---

# Starting a project or task

You are tasked with guiding the user to prepare his working tree for starting to work on a task or project based on user choices.

## Definitions

- **SLUG**: a URL-safe identifier derived from user input — lowercase, spaces and special characters including forward slashes are replaced with hyphens, leading/trailing hyphens stripped.
- **TASK_FOLDER**: A local folder on the repository root, it is created from a SLUG and prefixed with `T-`

## Process:

1. **Understand the current state of the working tree**
   - if `git status` is not clean, show the user the output and ask what to do with these changes before proceeding.
   - IMPORTANT: do not proceed unless the git status is clean.
   - use `git` to find out about the current branch
   - use `git fetch` to update the remotes

2. **Understand which project we are working on**
   - If they provided arguments to the command, use them to create a SLUG
   - If we are on the main branch, 
     - provide a list of local and remote branches except `main` to pick from or to pick a new project name.
     - If the user picks an existing branch, `git switch` to it
     - Otherwise, create a SLUG from the input and create the branch and `git switch` to it.
   - If we are not on the main branch
     - Ask the user if they want to work on a project (branch) or on a task (folder) in the current project
       - If they pick task in the current project, proceed to the next step
       - otherwise provide a list of local and remote branches except `main` to pick from or to pick a new project name.
       - If the user picks an existing branch, `git switch` to it
       - Otherwise, create a SLUG from the input and create the branch and `git switch` to it.
   - If there is a PROJECT.md file provide a summary to the user and proceed to the next step
   - Otherwise create PROJECT.md and add the project name provided by the user as a level one headline
     - ask the user to briefly describe the project and add that information to PROJECT.md
     - tell the user that general project level information should go into this file.
     - Ask the user if a Jira ticket should be created or exists for this project
       - When the user provides a link or a jira ticket number, check if it exists and show the ticket summary and add it to PROJECT.md
       - When the user asks to create a Jira ticket do that by setting the summary field to the project name input the user provided earlier and add it to PROJECT.md

3. **Get access to the relevant code or files**
   - if there already is a `code` folder, and it contains files or folders
     - check if it contains any broken soft links, if that is the case tell the user about it
     - for each repo already listed under `## Repositories` in PROJECT.md that does not yet have a `**GitHub**:` line: resolve its path, run `git -C {resolved_path} remote get-url origin`, derive the GitHub URL, and add it to the entry
     - proceed to the next step
   - if the `code` folder does not exist or is empty,
     - create it if it doesn't exist
     - ask the user if there is any code to add to the project.
       - for relative paths the user replies with: only accept paths of the form `../sibling` (one level up, sibling of the repo root) — reject absolute paths and any path with more than one `..` segment as non-portable and potentially unsafe. Create a soft link into the `code` folder using the relative path.
       - for any git URLs he is responding with try to clone them.
     - IMPORTANT: after each reply ask if there is more to add until he confirms the step is complete
   - **After each symlink is created or repo is cloned**, detect signs of configuration in that repo:
     - Resolve the path: `readlink -f code/{name}`
     - Run `git -C {resolved_path} remote get-url origin` to get the remote URL; derive the GitHub URL (e.g. `https://github.com/owner/repo`) by normalising SSH and HTTPS remote formats. If the command fails or returns nothing, note as "not a git repo / no remote"
     - Check for (presence only, don't read contents):
       - Agent instructions: `.claude/CLAUDE.md`, `CLAUDE.md`, `AGENTS.md`, `.agents`
       - Env: `.envrc.template`
       - Node version: `.nvmrc`
       - Tooling (in priority order): `pyproject.toml` → `uv sync`; `package-lock.json` → `npm ci`; `pnpm-lock.yaml` or `package.json` (no package-lock) → `pnpm install`; `Makefile` → `make install`
     - Show the detected info and ask the user to confirm or correct before saving:
       ```
       Detected for code/{name} (→ {resolved_path}):
       - GitHub: https://github.com/owner/repo (or "not a git repo / no remote")
       - Agent instructions: [list found, or "none"]
       - Env: .envrc.template found / not found
       - Node: .nvmrc found / not found
       - Tooling: [detected command or "none"]

       Does this look correct? Any corrections before I save to PROJECT.md?
       ```
     - After confirmation, add or update a `## Repositories` section in PROJECT.md:
       ```markdown
       ## Repositories

       ### {name}
       - **Path**: `/absolute/resolved/path`
       - **GitHub**: https://github.com/owner/repo
       - **Agent instructions**: CLAUDE.md, AGENTS.md — read before working in this repo
       - **Env**: `.envrc.template` found — `.envrc` must be configured and `direnv allow` run
       - **Node version**: `.nvmrc` found — ensure correct node version is active
       - **Install**: `pnpm install`
       ```
       Omit any line where nothing was detected (including GitHub if no remote was found).
       
4. **Provide a project overview**
   - List all TASK_FOLDERs; for each one read `task.yaml` if present (for status, description, dependencies); for tasks without one check for research/plan files to infer status
   - If the `current-task` link exists and points to an existing TASK_FOLDER, call it out
   - Show a task overview, for example:
     ```
     Tasks:
     - T-auth [planned]: Authentication flow
     - T-dashboard [pending]: Dashboard UI — depends on: T-auth
     ```
   - Note which files have been changed most recently in this branch

5. **Understand and link the task the user is working on**
   - Ask the user to pick an existing TASK_FOLDER to work on by providing a list of existing TASK_FOLDERs or to provide a new task name.
     - If the user wants to continue with the current task, proceed to the next step
     - If the user picks an existing TASK_FOLDER, recreate the soft link `current-task` that points to the selected TASK_FOLDER
     - If the user provides a new task name: create a TASK_FOLDER, create a new soft link `current-task` pointing to it, then create `{task_folder}/task.yaml` by asking:
       - "Describe this task in one line:"
       - "Does this task depend on completing any existing tasks first? (list TASK_FOLDER names or none)"
       - "Does any existing task need this one to complete first? (list TASK_FOLDER names or none)"
       Then write the file:
       ```yaml
       status: pending
       description: "[user's one-liner]"
       depends_on: []  # or list of TASK_FOLDER names
       blocks: []      # or list of TASK_FOLDER names
       jira: ""        # optional
       ```

6. **Stage changes for commit**
   - `git add {resolved_task_folder}/` (task folder with task.yaml)
   - `git add PROJECT.md` (if created or modified)
   - `git add code/` (if symlinks were created or repos were cloned)

7. **Suggest the next step**

   If `current-task` is set and `{resolved_task_folder}/task.yaml` exists, read its `status`
   and suggest accordingly:

   | status      | suggestion                                                               |
   |-------------|--------------------------------------------------------------------------|
   | pending     | "Run `/research` to begin research for this task."                       |
   | researching | "Research is in progress — run `/research` to continue."                 |
   | researched  | "Research is complete — run `/plan` to create an implementation plan."   |
   | planned     | "A plan exists — run `/implement` to start implementation."              |
   | in-progress | "Implementation is in progress — run `/implement` to continue."          |
   | blocked     | "This task is blocked on: {depends_on list}. Work on those tasks first." |
   | complete    | "This task is complete. Pick a new task or start a fresh session."       |

   In all cases, remind the user to start a new session or `/clear` before running the next command.

   If no `current-task` is set or no `task.yaml` exists, fall back to the generic reminder:
   "The steps are `/research` → `/plan` → `/implement`. Start a new session or `/clear` before continuing."
