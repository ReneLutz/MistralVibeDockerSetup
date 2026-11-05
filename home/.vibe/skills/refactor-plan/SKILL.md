---
name: refactor-plan
version: 1.1
description: Load this skill when the user mentions refactoring, restructuring, or significantly modifying existing code. Use when the task involves changing code structure without adding new features.
last_updated: 2026-11-05
related: plan-then-execute, git-change-plan
---

# Refactor Plan Skill

You are in refactor planning mode. **All refactoring must be carefully planned to avoid breaking changes.**

## Required Workflow

### 1. Understand the Goal
Ask the user:
- What code needs refactoring?
- Why is refactoring needed? (performance, readability, maintainability, etc.)
- What is the desired outcome?

### 2. Analyze Impact
Before any changes, conduct thorough analysis:

#### Find All References
- Search for all usages of the function/class/module being refactored
- Use `grep -r` or IDE "Find References" feature
- Document every call site in the plan

#### Dependency Mapping
- Identify upstream dependencies (code that calls this)
- Identify downstream dependencies (code this calls)
- Identify parallel code that might need similar changes

#### Test Coverage
- Run existing tests to establish baseline
- Note which tests cover the code being refactored
- Identify gaps in test coverage

### 3. Create Refactor Plan
Write a detailed plan with:

#### Phases
Break refactoring into **atomic, testable phases**:
1. **Extract**: Create new structure without removing old
2. **Migrate**: Update call sites one by one
3. **Remove**: Delete old structure after all migrations complete
4. **Clean**: Format, lint, and finalize

#### For Each Phase
- Specific files to modify
- Exact changes to make
- Tests that must pass after the change

#### Risk Assessment
- **Low Risk**: Internal function renaming (no external API)
- **Medium Risk**: Changing function signature in a module
- **High Risk**: Changing public API, database schema, or config format

### 4. Safety Strategies

#### For Low-Medium Risk
- Use feature flags to toggle between old and new implementations
- Maintain backward compatibility during transition
- Add deprecation warnings before removing old code

#### For High Risk
- **Require**: Branch protection and code review
- **Require**: Comprehensive test coverage (>90%)
- **Require**: Rollback plan
- **Suggest**: Pair programming

### 5. Execution Rules

#### Never Do
- Refactor and add features in the same commit
- Make large refactors without test coverage
- Change public APIs without deprecation period
- Refactor during critical deadlines

#### Always Do
- Run tests after each atomic change
- Commit each phase separately with descriptive messages
- Include "refactor:" prefix in commit messages
- Document breaking changes in CHANGELOG

### 6. Special Refactor Types

#### Rename
- Rename files first, then update imports
- Use IDE refactor tools when possible
- Verify no broken imports after rename

#### Extract Method/Function
- Keep original function, call new function from it
- Update tests to cover new function
- Remove original only after all callers use new function

#### Change Function Signature
- Add new function with new signature
- Update callers gradually
- Mark old function as deprecated
- Remove old function after migration complete

#### Database Schema Changes
- **Require** migration script
- **Require** backward-compatible changes first
- **Never** run destructive schema changes without backup

### 7. Validation After Refactor
- [ ] All existing tests pass
- [ ] New tests cover refactored code
- [ ] Performance characteristics unchanged (if not intentional)
- [ ] Error handling preserved
- [ ] Logs and metrics still work

## When to Stop and Re-evaluate

Stop the refactor and ask the user if:
- Tests start failing and can't be fixed quickly
- The scope grows beyond original intent
- The code becomes more complex instead of simpler
- Deadline pressures make completion risky

## Error Recovery

- If tests fail after refactor: Revert to last working commit and re-examine the refactor plan
- If production issues arise: Roll back using the migration scripts or git revert
- If data migration fails: Restore from backup and investigate the schema changes

## Related Skills

- **plan-then-execute**: Use for complex multi-step refactoring operations
- **git-change-plan**: Use for git operations related to refactoring (commits, branches)
