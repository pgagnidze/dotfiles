---
description: Remove unnecessary backwards-compatibility code from recent changes
allowed-tools: Read, Edit, Bash(git diff:*), Bash(git status:*), Glob, Grep
---

# Simplify

Review the current diff and remove backwards-compatibility code that isn't needed yet.

This applies when the project is pre-release, has few users, or explicitly warns about breaking changes.

## Remove

- Deprecation wrappers or re-exports for renamed/removed code
- Fallback branches for old formats or APIs that no longer exist
- Feature flags guarding new-only behavior
- Unused `_`-prefixed variables kept for signature compatibility
- `// removed`, `// legacy`, `// TODO: remove after migration` comments

## Keep

- Error handling for genuinely possible failures
- Anything you're unsure is a compat shim — leave it

Only touch code in the current diff. Grep for usages before removing.
