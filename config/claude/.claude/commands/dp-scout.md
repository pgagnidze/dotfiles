---
description: Clone and explore external repos to learn patterns relevant to the current project
allowed-tools: Bash, Read, Glob, Grep, WebSearch
---

# Scout

Clone external repositories and explore their source code to find patterns, conventions, and implementation details relevant to the current project. Always clone and explore locally. Never use WebFetch to read repo contents.

## Arguments

- First arg (optional): repository URL, `owner/repo` shorthand, or a topic/question
- `--branch NAME`: checkout a specific branch or tag
- `--shallow`: shallow clone with `--depth 1` (default for large repos)
- `--question "..."`: specific question to answer about the repo
- `--compare`: clone multiple repos and compare their approaches

## Resolving what to clone

First, read key config files in the working directory to understand the current project's tech stack and context.

If no specific repo is provided, determine what to clone from context:

1. **Topic or question given**: use WebSearch to find relevant repositories, then clone the most promising ones. For example, if the current project uses Express and the user asks about "request validation", find and clone projects known for good validation patterns
2. **Conversation context**: look at recent discussion for mentions of libraries, tools, or projects that would benefit from source-level exploration
3. **Comparison requests**: if the user is deciding between options, clone multiple repos to compare their approaches

When discovering repos via search, prefer repos with high stars/activity and clone 2-3 candidates rather than just one, unless the user is clearly asking about a specific project.

## Workflow

1. Read the current project's config and structure to understand its stack
2. Determine the target repo(s) from args, search, or conversation context
3. Clone into `/tmp/dp-scout-<repo-name>`. Reuse if already exists (run `git pull` instead)
4. If `--branch`, checkout that ref after cloning
5. Orient: read the README, list top-level structure, check for key config files
6. Focus on what is relevant to the current project:
   - How do they solve the problem the user is researching?
   - What patterns or conventions could be adopted?
   - How is the relevant code structured?
7. If `--compare`, explore each repo and compare their approaches
8. Summarize findings with actionable takeaways for the current project

## Output format

Always tie findings back to the current project:

- What the explored repo does and how it is relevant
- Specific patterns, code structures, or approaches worth adopting
- Key files and modules to look at for reference
- Concrete suggestions for how to apply what was learned

Do not describe the external repo in isolation. The goal is to bring insights back.

## Guidelines

- Always clone. Never use WebFetch or WebSearch to read repo file contents
- Use shallow clones by default
- Use Glob and Grep to navigate the codebase efficiently
- If the clone already exists in `/tmp`, reuse it
- For monorepos, identify the relevant sub-project before diving deep
- Do not modify the cloned repo
- Do not modify the current project unless asked
