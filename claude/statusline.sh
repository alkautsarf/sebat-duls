#!/bin/bash
# Claude Code status line
# Line 1: dir │ branch │ git status │ model │ context │ pragma
# Line 2: plan usage (5h │ 7d)

INPUT=$(cat)

# ── Parse model ──
MODEL_ID=$(echo "$INPUT" | jq -r '.model.id // "unknown"')
MODEL_NAME=$(echo "$MODEL_ID" | sed 's/claude-//' | cut -d'-' -f1 | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
MODEL_VER=$(echo "$MODEL_ID" | sed 's/claude-//' | sed 's/^[a-z]*-//' | cut -d'-' -f1,2 | tr '-' '.')
MODEL="$MODEL_NAME $MODEL_VER"

# ── Parse context ──
TOTAL=$(echo "$INPUT" | jq -r '(.context_window.current_usage.input_tokens // 0) + (.context_window.current_usage.output_tokens // 0) + (.context_window.current_usage.cache_creation_input_tokens // 0) + (.context_window.current_usage.cache_read_input_tokens // 0)')
CTX_SIZE=$(echo "$INPUT" | jq -r '.context_window.context_window_size // 200000')

# ══════════════════════════════════════
# LINE 1: existing status line
# ══════════════════════════════════════

# Directory
pwd | sed "s|^$HOME|~|" | awk '{printf "\033[38;5;37m%s\033[0m", $0}'

# Git branch + status
if git rev-parse --git-dir > /dev/null 2>&1; then
  printf " \033[90m│\033[0m "
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  printf "\033[38;5;208m%s\033[0m" "$BRANCH"
  printf " \033[90m│\033[0m "
  changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$changes" -eq 0 ]; then
    ahead_behind=$(git rev-list --left-right --count HEAD...@{u} 2>/dev/null)
    if [ -n "$ahead_behind" ]; then
      ahead=$(echo $ahead_behind | awk '{print $1}')
      behind=$(echo $ahead_behind | awk '{print $2}')
      if [ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ]; then
        printf "\033[38;5;33m↑%s ↓%s\033[0m" "$ahead" "$behind"
      else
        printf "\033[38;5;34m✓ clean\033[0m"
      fi
    else
      printf "\033[38;5;34m✓ clean\033[0m"
    fi
  else
    printf "\033[38;5;220m● %s changes\033[0m" "$changes"
  fi
fi

# Model
printf " \033[90m│\033[0m "
printf "\033[38;5;141m%s\033[0m" "$MODEL"

# Context remaining
printf " \033[90m│\033[0m "
if [ "$TOTAL" -lt "$CTX_SIZE" ]; then
  REMAINING=$((CTX_SIZE - TOTAL))
  PCT=$(((CTX_SIZE - TOTAL) * 100 / CTX_SIZE))
  REMAINING_K=$((REMAINING / 1000))
  if [ "$PCT" -gt 75 ]; then
    printf "\033[38;5;34m%s%% (%sk)\033[0m" "$PCT" "$REMAINING_K"
  elif [ "$PCT" -gt 50 ]; then
    printf "\033[38;5;226m%s%% (%sk)\033[0m" "$PCT" "$REMAINING_K"
  elif [ "$PCT" -gt 25 ]; then
    printf "\033[38;5;208m%s%% (%sk)\033[0m" "$PCT" "$REMAINING_K"
  else
    printf "\033[38;5;196m%s%% (%sk)\033[0m" "$PCT" "$REMAINING_K"
  fi
else
  TOTAL_K=$((TOTAL / 1000))
  printf "\033[38;5;247m%sk tokens\033[0m" "$TOTAL_K"
fi

# Pragma mode
PRAGMA_MODE=$(jq -r '.mode // ""' ~/.pragma/config.json 2>/dev/null | tr '[:lower:]' '[:upper:]' | sed 's/X402/x402/')
if [ -n "$PRAGMA_MODE" ]; then
  printf " \033[90m│\033[0m "
  printf "\033[38;5;33m⚡%s\033[0m" "$PRAGMA_MODE"
fi

# ══════════════════════════════════════
# LINE 2: plan usage
# ══════════════════════════════════════

CACHE_FILE="/tmp/claude-usage-cache.json"

# Background refresh (non-blocking)
# Skip if cache was updated less than 5 seconds ago
SHOULD_REFRESH=1
if [ -f "$CACHE_FILE" ]; then
  CACHE_AGE=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE") ))
  [ "$CACHE_AGE" -lt 5 ] && SHOULD_REFRESH=0
fi

if [ "$SHOULD_REFRESH" -eq 1 ]; then
  (
    CREDS=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
    if [ -n "$CREDS" ]; then
      TOKEN=$(printf '%s' "$CREDS" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['claudeAiOauth']['accessToken'])" 2>/dev/null)
      if [ -n "$TOKEN" ]; then
        USAGE=$(curl -s --max-time 3 "https://api.anthropic.com/api/oauth/usage" \
          -H "Authorization: Bearer $TOKEN" \
          -H "anthropic-beta: oauth-2025-04-20" 2>/dev/null)
        if [ -n "$USAGE" ] && echo "$USAGE" | jq . >/dev/null 2>&1; then
          echo "$USAGE" > "$CACHE_FILE"
        fi
      fi
    fi
  ) &
fi

# Render usage from cache
if [ -f "$CACHE_FILE" ]; then
  USAGE=$(cat "$CACHE_FILE")
  FIVE_H=$(echo "$USAGE" | jq -r '.five_hour.utilization // empty')
  SEVEN_D=$(echo "$USAGE" | jq -r '.seven_day.utilization // empty')

  # Color: high usage = bad (inverted from context remaining)
  usage_color() {
    local pct=$1
    if [ "$pct" -gt 90 ]; then echo "196"      # red
    elif [ "$pct" -gt 70 ]; then echo "208"     # orange
    elif [ "$pct" -gt 50 ]; then echo "226"     # yellow
    else echo "34"; fi                           # green
  }

  # Convert ISO 8601 UTC timestamp to local time (e.g., "2:00 PM")
  local_time() {
    python3 -c "
from datetime import datetime, timezone
import time
utc = datetime.fromisoformat('$1')
local_ts = utc.timestamp()
local_dt = datetime.fromtimestamp(local_ts)
print(local_dt.strftime('%-I:%M %p'))
" 2>/dev/null
  }

  # Convert ISO 8601 UTC timestamp to local date + time (e.g., "Feb 17, 2:00 PM")
  local_datetime() {
    python3 -c "
from datetime import datetime, timezone
import time
utc = datetime.fromisoformat('$1')
local_ts = utc.timestamp()
local_dt = datetime.fromtimestamp(local_ts)
print(local_dt.strftime('%b %-d, %-I:%M %p'))
" 2>/dev/null
  }

  FIVE_H_RESET=$(echo "$USAGE" | jq -r '.five_hour.resets_at // empty')
  SEVEN_D_RESET=$(echo "$USAGE" | jq -r '.seven_day.resets_at // empty')

  # Thresholds: 5h shows reset at 70%, 7d shows reset at 90%
  SHOW_5H=0; SHOW_7D=0
  if [ -n "$FIVE_H" ]; then
    FH=$(printf '%.0f' "$FIVE_H")
    FH_COLOR=$(usage_color "$FH")
    [ "$FH" -ge 80 ] && SHOW_5H=1
  fi
  if [ -n "$SEVEN_D" ]; then
    SD=$(printf '%.0f' "$SEVEN_D")
    SD_COLOR=$(usage_color "$SD")
    [ "$SD" -ge 90 ] && SHOW_7D=1
  fi

  if [ -n "$FIVE_H" ] || [ -n "$SEVEN_D" ]; then
    printf "\n"

    # Always show 5h percentage
    if [ -n "$FIVE_H" ]; then
      printf "\033[38;5;%sm5h: %s%%\033[0m" "$FH_COLOR" "$FH"
      if [ "$SHOW_5H" -eq 1 ] && [ -n "$FIVE_H_RESET" ]; then
        FH_LOCAL=$(local_time "$FIVE_H_RESET")
        printf " \033[90m↻ %s\033[0m" "$FH_LOCAL"
      fi
    fi

    if [ -n "$FIVE_H" ] && [ -n "$SEVEN_D" ]; then
      printf " \033[90m·\033[0m "
    fi

    # Always show 7d percentage
    if [ -n "$SEVEN_D" ]; then
      printf "\033[38;5;%sm7d: %s%%\033[0m" "$SD_COLOR" "$SD"
      if [ "$SHOW_7D" -eq 1 ] && [ -n "$SEVEN_D_RESET" ]; then
        SD_LOCAL=$(local_datetime "$SEVEN_D_RESET")
        printf " \033[90m↻ %s\033[0m" "$SD_LOCAL"
      fi
    fi
  fi
fi
