---
description: Create a semantic commit message
allowed-tools: Bash(git diff:*), Bash(git status:*)
---

# Commit

Review the staged changes and create a git commit with a semantic commit message.

Requirements:

- Use conventional commit format: type(scope): description
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore
- Keep the message as a single line
- Use lowercase throughout
- Be concise and descriptive
- Do not mention any AI or tooling in the commit message

Current changes:

- Staged: !`git diff --cached --stat`
- Status: !`git status --short`
