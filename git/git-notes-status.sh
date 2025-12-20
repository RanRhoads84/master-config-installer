#!/bin/bash

NOTES_DIR="$HOME/git.thelinuxcast.org/notes"

if [ ! -d "$NOTES_DIR" ]; then
    exit 0
fi

# Simple lock to prevent multiple simultaneous executions
LOCK_FILE="/tmp/git-notes-status.lock"
if [ -f "$LOCK_FILE" ]; then
    exit 0
fi
touch "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

cd "$NOTES_DIR" || exit 0

# Fetch latest changes silently
git fetch origin >/dev/null 2>&1

# Get current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
if [ -z "$CURRENT_BRANCH" ]; then
    exit 0
fi

# Check commits behind and ahead
BEHIND=$(git rev-list --count HEAD..origin/"$CURRENT_BRANCH" 2>/dev/null || echo "0")
AHEAD=$(git rev-list --count origin/"$CURRENT_BRANCH"..HEAD 2>/dev/null || echo "0")

# Build status message
if [ "$AHEAD" -gt 0 ] && [ "$BEHIND" -gt 0 ]; then
    notify-send "Git Notes" "$AHEAD ahead, $BEHIND behind"
elif [ "$AHEAD" -gt 0 ]; then
    notify-send "Git Notes" "$AHEAD commits ahead"
elif [ "$BEHIND" -gt 0 ]; then
    notify-send "Git Notes" "$BEHIND commits behind"
else
    notify-send "Git Notes" "Up to date"
fi
