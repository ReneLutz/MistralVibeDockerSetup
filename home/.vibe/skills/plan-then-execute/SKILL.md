---
name: plan-then-execute
version: 1.1
description: Load this skill when the user requests a complex task requiring multiple steps or actions. Use when the task involves file modifications, multi-stage processes, or any operation that could have unintended side effects.
last_updated: 2026-11-05
related: git-change-plan, refactor-plan
---

# Plan-Then-Execute Skill

You are in plan-then-execute mode. **Do not execute any action until a complete plan is written and approved.**

## Required Workflow

### 1. Gather Full Requirements
Ask clarifying questions one at a time to fully understand the task. Do not assume or infer requirements.

### 2. Create a Detailed Plan
Before any tool call or file modification, create a structured plan with:
- **Goal**: What the user wants to achieve
- **Scope**: Files, systems, or components affected
- **Steps**: Numbered list of specific actions in order
- **Risks**: Potential issues or side effects
- **Validation**: How to verify success

Write the plan as a `todo` list with items marked as `pending`.

### 3. Get Explicit Approval
Present the plan to the user and **wait for explicit approval** ("yes", "proceed", "go ahead"). 

Do not interpret silence, "ok", or vague responses as approval. If the user asks for changes, revise the plan and get approval again.

### 4. Execute with Tracking
- Mark each todo item as `in_progress` when starting
- Mark as `completed` when done
- If a step fails, stop and report the issue to the user
- Do not proceed to the next step without user awareness

### 5. Verify and Report
After all steps are complete:
- Run validation checks
- Confirm the goal was achieved
- Report what was done and any remaining issues

## When to Use

Use this skill for:
- Multi-file modifications
- Refactoring operations
- Deployment tasks
- Configuration changes
- Any task where "undo" would be difficult

## Complexity Thresholds

A task requires this skill if ANY of these are true:
- Modifies 3+ files
- Includes 3+ sequential steps
- Has irreversible actions (deletes data, modifies config)
- Requires user input between steps
- User explicitly requests planning

## Blocking Conditions

**Do NOT execute** if any of these are true:
- The plan is incomplete or vague
- User has not explicitly approved the plan
- Steps depend on information you don't have
- You cannot verify success criteria

When blocked, ask the user for clarification or approval.

## Error Recovery

- If a step fails mid-execution: Stop immediately, report the failure, and wait for user instruction
- If user changes requirements mid-execution: Pause, update the plan, and get re-approval before continuing
- If external dependencies change: Re-assess the plan and get user confirmation

## Related Skills

- **git-change-plan**: Use together for git operations that modify repository history
- **refactor-plan**: Use together for code refactoring tasks
