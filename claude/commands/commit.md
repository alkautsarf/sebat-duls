---
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
argument-hint: "[commit message (optional)]"
description: "Analyze git changes and memory system to create intelligent conventional commits"
---

# Intelligent Git Commit

## CRITICAL RULES
- **NO WATERMARKS**: Never add Claude attribution, emoji watermarks, "Generated with Claude", "Co-Authored-By: Claude", or any AI-related signatures
- **SINGLE-LINE DEFAULT**: Always prefer one-line commit messages unless changes genuinely span multiple unrelated features

You are creating a git commit. Follow this workflow:

## Step 1: Gather All Changes

Run these commands to understand the full picture:
```bash
git status
git diff --stat
git diff
```

Also check memory system if it exists:
- Read `.claude/memory/RECENT_CHANGES.md` if present
- This provides context about documented work

## Step 2: Generate Commit Message

**Format:** Conventional commits
```
type: concise description covering all changes
```

**Types (auto-detect from changes):**
- `feat` - New feature or functionality
- `fix` - Bug fix
- `chore` - Dependencies, configs, tooling
- `refactor` - Code restructuring
- `docs` - Documentation only
- `test` - Test additions/changes
- `perf` - Performance improvements
- `style` - Formatting only
- `ci` - CI/CD changes

**Rules:**
- Under 72 chars, imperative mood, lowercase after colon
- No period at end, no emoji, no attribution

**Only use multi-line when changes span different features/domains:**
```
type: concise summary

- Detail about first change
- Detail about second change
```

## Step 3: Present for Confirmation

**Show the user:**
1. List of ALL files that will be committed (staged + unstaged)
2. Brief summary of key changes
3. Proposed commit message

**Ask:** "Confirm to stage all, commit, and push? (or suggest changes)"

## Step 4: Execute Everything

**When user confirms**, execute in sequence:
```bash
git add -A
git commit -m "commit message"
git push
```

**Report:**
- Commit hash
- Push status
- Done.

## Special Cases

**If user provided commit message as argument:**
- Use their message directly
- Still show file list and ask for confirmation before executing

**If no changes exist:**
- Report "Nothing to commit" and stop

**If push fails:**
- Report the error
- Suggest: "Run `git pull --rebase` then retry?"

## Important

- Stage ALL changes (git add -A) - no cherry-picking unless user specifies
- One confirmation = stage + commit + push
- Keep it fast and minimal
- NEVER add any watermark, attribution, emoji, "Generated with Claude", or "Co-Authored-By" lines
