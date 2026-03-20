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
     - proceed to the next step
   - if the `code` folder does not exist or is empty,
     - create it if it doesn't exist
     - ask the user if there is any code to add to the project.
       - for absolute or relative folders he replies with, create a soft link into the `code` folder 
       - for any git URLs he is responding with try to clone them.
     - IMPORTANT: after each reply ask if there is more to add until he confirms the step is complete
       
4. **Provide a project overview**
   - Explore the TASK_FOLDERs and the current status regarding the tasks contained in them.
   - check which files in those folders have been changed most recently in this branch
   - If the `current-task` link exists and points to an existing TASK_FOLDER, inform the user about the currently selected task (the name of the folder that the link points to.)
   - Provide a quick summary of the project from PROJECT.md, the existing tasks and their status:
     - which of the tasks have a research or plan file and for plan files how much of it is completed
   
5. **Understand and link the task the user is working on**
   - Ask the user to pick an existing TASK_FOLDER to work on by providing a list of existing TASK_FOLDERs or to provide a new task name.
     - If the user wants to continue with the current task, proceed to the next step
     - If the user picks an existing TASK_FOLDER, recreate the soft link `current-task` that points to the selected TASK_FOLDER
     - Otherwise, create a TASK_FOLDER from the input and create a new soft link `current-task` that points to it
     
6. Remind the user about the order of the steps: `/research`, `/plan`, `/implement` and ask them to start a new session or `/clear` this one before continuing.
