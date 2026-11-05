---
name: pre-commit-review
version: 1.1
description: Load this skill when the user is preparing to commit code changes with git commit. Use before any git commit operation to ensure code quality.
last_updated: 2026-11-05
related: format-markdown, git-change-plan
---

# Pre-Commit Review Skill

You are in pre-commit review mode. **Before executing `git commit`, run this checklist.**

## Required Workflow

### 1. Verify Working Tree
Before reviewing, ensure you understand what will be committed:
- Run `git status` to see staged and unstaged changes
- Run `git diff --cached` to review staged changes
- Ask user: "Are you ready to commit these specific changes?"

### 2. Checklist Before Commit
Do not allow commit until these are satisfied:

#### Code Quality
- [ ] **Linting**: Run project linter (ESLint, Pylint, RuboCop, etc.)
- [ ] **Formatting**: Run code formatter (Prettier, Black, gofmt, etc.)
- [ ] **Type Checking**: If applicable, run type checker (TypeScript, mypy, etc.)

#### Testing
- [ ] **Unit Tests**: All unit tests pass for modified code
- [ ] **Integration Tests**: Relevant integration tests pass
- [ ] **Regression Tests**: No existing tests broken by changes

#### Code Review
- [ ] **Self-Review**: Code has been manually reviewed for logic errors
- [ ] **Complexity**: No overly complex functions or methods (>20 lines, >5 parameters)
- [ ] **Duplication**: No copy-pasted code without good reason

#### Security
- [ ] **Secrets**: No hardcoded API keys, passwords, or tokens
- [ ] **Sensitive Data**: No PII, credentials, or confidential information
- [ ] **Dependencies**: No insecure or unverified dependencies added

#### Documentation
- [ ] **Comments**: Complex logic has explanatory comments
- [ ] **Docs**: Updated relevant documentation if behavior changed

### Critical vs Advisory Checks

| Priority | Check | Block Commit? |
|----------|-------|---------------|
| Critical | Secrets in code | YES |
| Critical | Broken tests | YES |
| Critical | Syntax errors | YES |
| Advisory | Linting warnings | NO (warn only) |
| Advisory | Formatting | NO (warn only) |

### 3. Commit Message Quality
Before allowing commit, verify the message follows conventions:

#### Structure
```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Requirements
- [ ] **Subject Line**: 50 characters or less
- [ ] **Subject**: Starts with verb in imperative mood ("Add", "Fix", "Remove")
- [ ] **Subject**: Describes the change, not the motivation
- [ ] **Body**: Explains *what* and *why* (not how)
- [ ] **Body**: Wraps at 72 characters
- [ ] **Footer**: References issues, breaking changes, etc.

#### Type Prefixes (use appropriate)
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semicolons)
- `refactor`: Code refactoring (no functional changes)
- `test`: Adding or fixing tests
- `chore`: Maintenance, build process, dependencies
- `perf`: Performance improvements
- `revert`: Revert a previous commit

### 4. Interactive Review
If any checklist item fails:
- Report the specific issue
- Suggest how to fix it
- **Block the commit** until resolved

### 5. Final Confirmation
Once all checks pass:
- Present summary: "✓ All pre-commit checks passed"
- Show the proposed commit message
- Ask: "Commit with this message? (yes/no/abort)"
- Only execute `git commit` after explicit "yes"

## Example Good Commit Message
```
feat(auth): add OAuth2 token refresh support

Implement automatic token refresh when accessing protected endpoints
with an expired token. Uses refresh_token from initial auth response.

Fixes #1234
```

## Example Bad Commit Message (to avoid)
```
fixed bug

/* this is a bad commit message */
```

## Never Allow
- Commit message: "wip", "work in progress", "temp"
- Commit message: "fixes stuff", "misc changes"
- Committing broken tests
- Committing commented-out code
- Committing large binary files unintentionally

## Error Recovery

- If secrets detected: Remove the file from staging, clean the secret, and re-stage
- If tests fail: Fix the failing tests before proceeding with commit
- If syntax errors found: Correct the errors and re-run the pre-commit check

## Related Skills

- **format-markdown**: Use for formatting markdown content in commit messages
- **git-change-plan**: Use together for git operations that modify repository history
