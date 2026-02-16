---
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - AskUserQuestion
argument-hint: "[optional: what to tweet about or specific instructions]"
description: "Generate tweets/threads about app updates in elpabl0's signature style"
---

# Tweet Generator

Generate Twitter/X content for Pragma updates, features, or educational content.

## Style Guide (elpabl0's voice)

**Tone:**
- all lowercase (except proper nouns like Pragma, Monad, NFT, EIP)
- conversational, not salesy
- dev-friendly, show real examples
- punchy short lines, not paragraphs
- minimal emojis (1-2 max, only if fits naturally)

**Handles:**
- @pragma_xyz - product handle
- @s0nderlabs - builder credit
- @monad - tag for Monad-related content

---

## Tweet Categories

### Category 1: BIG FEATURE (Thread)

**When to use:**
- New major feature or capability
- New integration (e.g., new DEX, new protocol)
- Launch announcements
- Significant UX overhaul

**Format:** Full 5-7 tweet thread
1. **Hook** - question or bold statement
2. **Intro** - what it is + @monad tag
3. **Problem** - pain point being solved
4. **Solution** - how it works
5. **Examples** - real commands in quotes
6. **Transparency** - under the hood (optional)
7. **CTA** - pr4gma.xyz + "built by @s0nderlabs"

---

### Category 2: UPDATE/CHANGELOG (Single or Short Thread)

**When to use:**
- Bug fixes
- Performance improvements
- QoL enhancements
- Minor features
- Multiple small changes bundled

**Format Options:**

**Option A - Single tweet with list:**
```
Pragma update

— instant tx confirmations
— verifiable explorer links
— gas estimation fixes

pr4gma.xyz
```

**Option B - Single tweet narrative:**
```
small but important update: transactions now confirm instantly

no more 5-10 second waits after swaps

pr4gma.xyz
```

**Option C - Short thread (2-3 tweets) for multiple updates:**
```
1/2
Pragma update — a few improvements shipping today

— instant tx confirmations (cached EIP-7966 receipts)
— every tx now shows verifiable explorer link
— cleaner execution plan formatting

2/2
these are behind-the-scenes fixes but you'll notice things feel snappier

pr4gma.xyz
```

---

### Category 3: EDUCATIONAL/EXPLAINER (Thread)

**When to use:**
- User wants to explain a concept (not tied to changes)
- How something works (signing, session keys, smart accounts)
- Ecosystem education
- Technical deep-dives

**Format:** 3-5 tweet thread
```
1/4
how does Pragma sign transactions without your private key?

thread 🧵

2/4
when you connect, Pragma creates a session key — a temporary signer that can only do what you approve

it never touches your main wallet

3/4
every action creates a single-use permission

"swap 50 MON to USDC" → permission created → executed → permission expires

if someone intercepts it? useless. it's already done.

4/4
want to see it in action?

pr4gma.xyz
```

---

## Workflow

### Step 1: Determine What to Tweet About

**If user provided instruction:**
- Use their description
- If they mention a topic (e.g., "how signing works") → Category 3 (Educational)
- If they mention specific changes → analyze and categorize

**If no instruction (auto-detect):**
Run these to gather context:
```bash
git log main..HEAD --oneline 2>/dev/null || git log --oneline -10
git diff main..HEAD --stat 2>/dev/null || git diff --stat HEAD~5
```

Also check:
- `.claude/memory/RECENT_CHANGES.md` if exists
- `CHANGELOG.md` if exists

### Step 2: Auto-Categorize

Analyze the changes/instruction and determine category:

**→ BIG FEATURE if:**
- New user-facing feature (feat: commit with significant scope)
- New integration or protocol support
- User explicitly says "launch", "introducing", "new feature"
- Changes span multiple components with new capability

**→ UPDATE/CHANGELOG if:**
- Bug fixes (fix: commits)
- Performance improvements (perf: commits)
- Small enhancements
- Multiple minor changes
- User says "update", "changelog", "improvements"

**→ EDUCATIONAL if:**
- User asks to explain something
- Topic not tied to recent changes
- User says "explain", "how does X work", "thread about X"

### Step 3: Ask Clarifying Questions (ONLY if unclear)

Only ask if:
- Can't determine category from context
- Multiple big features and unclear which to highlight
- User instruction is ambiguous

**When asking, use AskUserQuestion with options:**
- Big feature thread
- Update/changelog tweet
- Educational explainer

### Step 4: Generate Content

Based on category, generate appropriate format.

**Always include:**
- Character count for each tweet
- Media suggestions where helpful
- pr4gma.xyz link
- Credit (@s0nderlabs) where appropriate

### Step 5: Present Output

```
━━━ [CATEGORY] ━━━
[Brief summary of what this tweet is about]

━━━ TWEET/THREAD ━━━

[content with character counts]

━━━ END ━━━

💡 Suggested visuals:
- [list if applicable]
```

---

## Examples

### Example 1: Big Feature
Input: `/tweet we just shipped NFT trading support`

Output: Full 5-7 tweet thread with hook, problem, solution, examples, CTA

### Example 2: Update/Changelog
Input: `/tweet` (auto-detects fix commits)

Output:
```
Pragma update

— instant tx confirmations
— verifiable explorer links
— cleaner batch execution

pr4gma.xyz
```

### Example 3: Educational
Input: `/tweet explain how Pragma handles gas`

Output: 3-4 tweet thread explaining gas sponsorship, session keys, etc.

### Example 4: Override
Input: `/tweet the receipt caching fix - make it a thread, this is a big deal for UX`

Output: Full thread even though it's technically a "fix"

---

## Important Rules

- NEVER use corporate speak or marketing fluff
- NEVER overuse emojis or hashtags
- NEVER exceed 280 characters per tweet
- ALWAYS use lowercase (except Pragma, Monad, NFT, EIP, etc.)
- ALWAYS show real command examples when relevant
- ALWAYS include character counts
- Auto-detect category but respect user overrides
- Ask questions only when truly unclear
- Use @pragma_xyz for product, @s0nderlabs for builder credit
