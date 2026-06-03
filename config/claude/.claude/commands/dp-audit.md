---
description: Diagnose a codebase from its git history before reading the code
allowed-tools: Bash, Glob, Read
---

# Audit

Use a repo's git history to decide what to read first and what to distrust, before opening any files. Run five checks, then report one prioritized verdict instead of five raw dumps.

## Arguments

- Path (optional): narrows the file-level checks (churn, bug clusters) to a subtree. Default is the whole repo with generated-file noise filtered out
- `--since RANGE`: window for churn, velocity, and firefighting (default `1 year ago`)
- `--top N`: files to list for churn and bug clusters (default 20)

## Setup

First confirm a git repo: `git rev-parse --is-inside-work-tree`. If not, stop and say so.

The file-level checks (churn, bug clusters) should reflect hand-written code, not generated files. Do not guess where source lives: `app/`, `src/`, and friends vary by stack and break the moment a repo is reorganized. Instead look at the whole repo and filter out the noise that would otherwise top the lists, which is small and nearly universal: lockfiles, vendored and build directories, minified assets, changelogs. Pipe both file-level checks through this filter, extending it for the repo at hand:

`<NOISE>` = `grep -viE '(^|/)([^/]*\.lock|[^/]*-lock\.(json|ya?ml)|go\.sum|changelog[^/]*)$|/(node_modules|vendor|dist|build|target)/|\.min\.(js|css)$'`

To focus on a subtree (say one package in a monorepo), pass an explicit path. It is applied as a git pathspec (`-- <path>`), never by `cd`, because running `git log` from a subdir does not filter its output. `<SCOPE>` below is `-- <path>` when a path is given, otherwise empty (whole repo).

The contributor, velocity, and firefighting checks always run over the whole repo.

In the commands below, substitute `<SINCE>`, `<TOP>`, `<SCOPE>`, and `<NOISE>`.

## The five checks

### 1. Churn: what changes most

`git log --format= --name-only --since="<SINCE>" <SCOPE> | grep -v '^$' | <NOISE> | sort | uniq -c | sort -nr | head -<TOP>`

The files where edits concentrate. (`grep -v '^$'` drops the blank line `--format=` prints per commit.) High churn on its own can just mean active development; it only signals risk where it overlaps with bugs, which the report handles.

### 2. Contributors: who built it, who maintains it

`git shortlog -sn --no-merges HEAD`
`git shortlog -sn --no-merges --since="6 months ago" HEAD`

The explicit `HEAD` is required: with no revision and a non-terminal stdin (any script, CI, or this command), `git shortlog` reads from stdin and prints nothing instead of summarizing HEAD.

One author with 60% or more of commits is a bus-factor risk. It becomes a crisis if they have nothing in the 6-month window, or if the all-time top author is missing from it. Many past contributors but few recent ones means the builders have moved on.

Caveat: if the author count looks too small for the repo's age, the team may squash PRs, so this counts who merged, not who wrote. Confirm the merge strategy before trusting it.

### 3. Bug clusters: where fixes land

`git log -i -E --grep="fix|bug|broken" --name-only --format= <SCOPE> | grep -v '^$' | <NOISE> | sort | uniq -c | sort -nr | head -<TOP>`

Files that keep showing up in fix and bug commits.

Caveat: this only works if commit messages say what they fix. Near-empty output on a busy repo means weak messages, not clean code; report the map as unreliable rather than "no bugs".

### 4. Velocity: accelerating or dying

`git log --format='%ad' --date=format:'%Y-%m' | sort | uniq -c`

Commits per month across the whole history. Steady is healthy. A month that drops by half, or a decline over 6 to 12 months, usually means lost capacity (someone left); name the month. Spikes with quiet gaps are batched releases, not decline.

### 5. Firefighting: how often they scramble

`git log --oneline --since="<SINCE>" | grep -iE '^[0-9a-f]+ (revert|hotfix|rollback|emergency)'`

The keyword must lead the commit subject, so `git revert`'s `Revert "..."` and prefixes like `hotfix:` match, but a feature that merely mentions a word (`feat: ... automatic rollback`) does not. Trade-off: it can miss buried mentions like `fix: hotfix for X`.

A few a year is normal. Roughly every couple of weeks or more means the team does not trust its deploy process (flaky tests, no staging, painful rollbacks). Zero is ambiguous: either stable, or undescriptive commits (see the caveat on check 3).

## Report

Start with the cross-reference: intersect the top 5 churn files with the bug-cluster list. Files on both are the highest risk, because they keep breaking and keep getting patched. Rank those by churn count, ties broken by bug count.

Then report:

- **Read first**: churn-and-bug overlap at the top, then any high-churn file that is also a bus-factor concentration point, then the remaining top-churn files. Only files that carry real risk; do not pad the list.
- **Bus factor**: the top author's share and whether they are still active.
- **Momentum**: the velocity shape (steady, declining, or spiky) and any sharp drop.
- **Firefighting**: revert and hotfix frequency, and what it says about the deploy process.
- **Caveats**: any from the checks above that apply.

Keep it pointed at one question: what to read first, and what to distrust when reading it.
