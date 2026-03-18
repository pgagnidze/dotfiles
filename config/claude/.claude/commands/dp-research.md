---
description: Research a claim and provide supporting sources
allowed-tools: WebSearch, WebFetch, Read
---

# Research

Research a claim and provide supporting evidence with credible sources.

## Arguments

- First arg: the claim or statement to research. If no argument is provided, look at the recent conversation context and identify claims, assertions, or statements that would benefit from source verification. If multiple candidates exist, list them and ask which to research.
- `--against`: also look for evidence that contradicts the claim
- `--depth shallow|moderate|deep`: how thorough the research should be (default: moderate)
  - `shallow`: quick search, 2-3 sources
  - `moderate`: multiple searches, 4-6 sources
  - `deep`: exhaustive research, 7+ sources with cross-referencing

## Workflow

1. Parse the claim. If ambiguous, ask the user to clarify before proceeding
2. Break the claim into searchable sub-questions
3. Search for evidence using multiple queries and angles
4. Fetch and read the most relevant results
5. Evaluate source credibility (prefer peer-reviewed, institutional, primary sources)
6. Compile findings into a structured response

## Output format

### Claim
> [restate the claim]

### Verdict
[Supported | Partially Supported | Mixed Evidence | Unsupported | Inconclusive]

Brief summary of the overall finding.

### Evidence

For each piece of evidence:

- **Finding**: what the source says
- **Source**: [title](url), publication/org, date
- **Credibility**: [High | Medium | Low], brief reason

### Counter-evidence
_(only if `--against` flag is used or evidence naturally contradicts the claim)_

Same format as above.

### Summary
2-3 sentence synthesis of the research. Note any caveats, nuance, or gaps in the available evidence.

## Guidelines

- Prefer primary sources over secondary reporting
- Prefer recent sources unless the claim is historical
- Always include the URL so the user can verify
- If a claim is too broad, break it into specific sub-claims
- Be honest about uncertainty. Say "I could not find strong evidence" rather than overstating weak sources
- Do not fabricate or hallucinate sources. Only cite pages you actually fetched and read
- When sources disagree, present both sides rather than picking one
