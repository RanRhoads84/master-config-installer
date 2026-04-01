#!/usr/bin/env bash

# Multi Git push
# Push current branch to both 'gitea' and 'github' remotes if configured.
# Non-fatal: continue if one remote is missing or a push fails.

set -euo pipefail

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
if [ -z "$CURRENT_BRANCH" ]; then
	echo "Unable to determine current branch; exiting." >&2
	exit 1
fi

push_remote() {
	local remote="$1"
	if git remote get-url "$remote" >/dev/null 2>&1; then
		echo "Pushing $CURRENT_BRANCH -> $remote/$CURRENT_BRANCH"
		if git push "$remote" "$CURRENT_BRANCH"; then
			echo "Push to $remote succeeded"
			return 0
		else
			echo "Push to $remote failed" >&2
			return 1
		fi
	else
		echo "Remote '$remote' not configured; skipping"
		return 2
	fi
}

EXIT_CODE=0
push_remote gitea || EXIT_CODE=$((EXIT_CODE | 1))
push_remote github || EXIT_CODE=$((EXIT_CODE | 2))

if [ "$EXIT_CODE" -ne 0 ]; then
	echo "One or more pushes failed (exit=$EXIT_CODE)" >&2
fi
exit "$EXIT_CODE"
