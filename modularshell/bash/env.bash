#!/usr/bin/env bash

# Global Environment Variables for Bash

# ============================================================================
# BAT / BAT-EXTRAS
# ============================================================================
if command -v bat >/dev/null 2>&1; then
    # Default theme and style — override in ~/.bashrc.local
    export BAT_THEME="${BAT_THEME:-Dracula}"
    export BAT_STYLE="${BAT_STYLE:-numbers,changes,header-filename}"

    # batman: renders man pages through bat (sets MANPAGER + MANROFFOPT)
    if command -v batman >/dev/null 2>&1; then
        eval "$(batman --export-env)"
    fi

    # batpipe: hooks bat into less via LESSOPEN so piped content is highlighted
    if command -v batpipe >/dev/null 2>&1; then
        eval "$(batpipe)"
    fi
fi

