---
name: git-change-plan
version: 1.1
description: Load this skill when the user wants to perform git operations including commits, merges, rebases, pushes, resets, or any other git commands that modify repository history.
last_updated: 2026-11-05
related: pre-commit-review, plan-then-execute
---

# Git Change Plan Skill

You are in git change planning mode. **Every git operation must be planned and approved before execution.**

## Required Workflow

### 1. Understand the Intent
Ask the user what they want to achieve with the git operation:
- What change are they making?
- Why do they need this operation?
- What is the target branch or state?

### 2. Assess Current State
Before any git command, verify and report:
- Current branch: `git branch --show-current`
- Working tree status: `git status` (clean or modified files)
- Remote tracking: `git remote -v` and `git rev-parse --abbrev-ref @{u}` if applicable
- Uncommitted changes: List any modified/untracked files
- Commit history: Recent commits that might be affected

### 3. Create Operation Plan
Write a plan that includes:
- **Operation Type**: commit, merge, rebase, push, reset, etc.
- **Current State**: Branch, commit hash, status
- **Target State**: What will change after the operation
- **Impact**: Will this affect other branches or collaborators?
- **Recovery Plan**: How to undo if something goes wrong

### 4. Classification and Warnings

#### Safe Operations (still require plan, lower risk)
- `git add` - Adding files to staging
- `git commit` - Creating a new commit
- `git pull` - Pulling changes (with merge/rebase awareness)
- `git fetch` - Fetching remote changes

#### Medium Risk (require explicit confirmation)
- `git checkout` - Switching branches (verify uncommitted changes)
- `git merge` - Merging branches
- `git push` - Pushing to remote
- `git stash` - Stashing changes

#### High Risk (require STRONG warning and confirmation)
- `git reset --hard` - Discards all uncommitted changes
- `git rebase` - Rewrites commit history
- `git push --force` / `git push --force-with-lease` - Overwrites remote history
- `git clean -fd` - Deletes untracked files
- `git stash drop` / `git stash clear` - Deletes stashed changes

### 5. Execute with Caution
For high-risk operations:
- State the blast radius explicitly: "This will discard all uncommitted changes"
- Ask: "Do you want to proceed with [operation]? Type 'yes' to confirm."
- Do not execute unless user types exactly "yes"

### 6. Post-Operation Verification
After each operation:
- Report what was done
- Show new state: `git status`, `git log -1`, etc.
- Confirm the operation achieved the intended result

## Special Cases

### Protected Branches
If pushing to `main`, `master`, or any protected branch:
- Warn that this may trigger CI/CD pipelines
- Ask if the user has push permissions
- Remind about PR requirements

### Force Push
For `git push --force`:
- **Always** warn about overwriting remote history
- Verify the user has checked with collaborators
- Require explicit "yes, force push" confirmation

### Rebase
For `git rebase`:
- Explain that commit hashes will change
- Warn that this will break any branches based on the old commits
- Suggest using `git rebase --interactive` for complex rebases
- Require explicit approval

## Never Do
- Never run `git reset --hard` without checking for uncommitted work first
- Never force push to a shared branch without confirmation
- Never delete branches that others might be using

## Error Recovery

- If `git reset --hard` run accidentally: Check `git reflog` to find the previous commit and restore with `git reset --hard <commit-hash>`
- If wrong branch deleted: Use `git reflog` to find the commit and create a new branch with `git branch <name> <commit-hash>`
- If force push breaks remote: Revert locally and push with `--force-with-lease` if safe, or coordinate with team to restore

## Related Skills

- **pre-commit-review**: Use before git commit operations to ensure code quality
- **plan-then-execute**: Use for complex multi-step git operations
