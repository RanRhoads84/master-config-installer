#!/usr/bin/env bats
# Tests for modularshell/bash/functions/help.bash
# Run from repo root: bats tests/bats/test_help.bats

REPO_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"
HELP_SH="$REPO_DIR/modularshell/bash/functions/help.bash"
# Point at the repo's modularshell/bash so shelp reads the real aliases.bash
# and functions/ without touching the live ~/.config/bash.
export BASH_CONFIG_DIR="$REPO_DIR/modularshell/bash"

# ---------------------------------------------------------------------------
# als — alias search
# ---------------------------------------------------------------------------

@test "als: finds aliases matching a term" {
    run bash --norc -c "
        source '$HELP_SH'
        export NO_COLOR=1
        alias my_git_commit='git commit -m'
        alias my_git_push='git push'
        alias my_nav_up='cd ..'
        als git
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"my_git_commit"* ]]
    [[ "$output" == *"my_git_push"* ]]
    [[ "$output" != *"my_nav_up"* ]]
}

@test "als: returns exit 1 and error message when term has no matches" {
    run bash --norc -c "
        source '$HELP_SH'
        export NO_COLOR=1
        als xyzzy_no_such_alias_ever
    "
    [ "$status" -eq 1 ]
    [[ "$output" == *"No aliases matching"* ]]
}

@test "als: no-arg, no-fzf lists all aliases without error" {
    # The no-fzf fallback is only reachable on systems without fzf installed.
    # PATH='' would also hide sed (same /usr/bin directory), so skip instead.
    if command -v fzf >/dev/null 2>&1; then
        skip "fzf is installed; no-fzf fallback path not reachable on this system"
    fi
    run bash --norc -c "
        source '$HELP_SH'
        export NO_COLOR=1
        alias aaa_foo='echo foo'
        alias aaa_bar='echo bar'
        als
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"aaa_foo"* ]]
    [[ "$output" == *"aaa_bar"* ]]
}

@test "als: NO_COLOR=1 produces no ANSI escape codes" {
    run bash --norc -c "
        source '$HELP_SH'
        export NO_COLOR=1
        alias chk_alias='ls -la'
        als chk
    "
    [ "$status" -eq 0 ]
    # No ESC character (\033) in the output
    [[ "$output" != *$'\033'* ]]
}

@test "als: colorised output contains ANSI codes when NO_COLOR unset" {
    run bash --norc -c "
        source '$HELP_SH'
        unset NO_COLOR
        alias chk_alias='ls -la'
        als chk
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *$'\033'* ]]
}

@test "als: search is case-insensitive" {
    run bash --norc -c "
        source '$HELP_SH'
        export NO_COLOR=1
        alias MyGitAlias='git status'
        als mygit
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"MyGitAlias"* ]]
}

# ---------------------------------------------------------------------------
# shelp — help browser
# ---------------------------------------------------------------------------

@test "shelp: --help exits 0 and shows usage" {
    run bash --norc -c "
        source '$HELP_SH'
        export BASH_CONFIG_DIR='$BASH_CONFIG_DIR'
        export NO_COLOR=1
        shelp --help
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"--aliases"* ]]
    [[ "$output" == *"--functions"* ]]
}

@test "shelp: -h is a shorthand for --help" {
    run bash --norc -c "
        source '$HELP_SH'
        export BASH_CONFIG_DIR='$BASH_CONFIG_DIR'
        export NO_COLOR=1
        shelp -h
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
}

@test "shelp: unknown option returns exit 2" {
    run bash --norc -c "
        source '$HELP_SH'
        export BASH_CONFIG_DIR='$BASH_CONFIG_DIR'
        export NO_COLOR=1
        shelp --not-a-real-option
    "
    [ "$status" -eq 2 ]
}

@test "shelp --aliases: shows alias section headers from aliases.bash" {
    run bash --norc -c "
        source '$HELP_SH'
        export BASH_CONFIG_DIR='$BASH_CONFIG_DIR'
        export NO_COLOR=1
        shelp --aliases
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"NAVIGATION"* ]]
    [[ "$output" == *"GIT"* ]]
    [[ "$output" == *"UTILITIES"* ]]
}

@test "shelp --aliases: shows known aliases under their sections" {
    run bash --norc -c "
        source '$HELP_SH'
        export BASH_CONFIG_DIR='$BASH_CONFIG_DIR'
        export NO_COLOR=1
        shelp --aliases
    "
    [ "$status" -eq 0 ]
    # Navigation aliases
    [[ "$output" == *".."* ]]
    # Git aliases
    [[ "$output" == *"gs"* ]]
    [[ "$output" == *"gp"* ]]
}

@test "shelp --aliases: does not show function names" {
    run bash --norc -c "
        source '$HELP_SH'
        export BASH_CONFIG_DIR='$BASH_CONFIG_DIR'
        export NO_COLOR=1
        shelp --aliases
    "
    [ "$status" -eq 0 ]
    # system.bash defines mkcd — should not appear in --aliases output
    [[ "$output" != *"[system]"* ]]
}

@test "shelp --functions: lists function names from functions/*.bash" {
    run bash --norc -c "
        source '$HELP_SH'
        export BASH_CONFIG_DIR='$BASH_CONFIG_DIR'
        export NO_COLOR=1
        shelp --functions
    "
    [ "$status" -eq 0 ]
    # system.bash exports these functions
    [[ "$output" == *"mkcd"* ]]
    [[ "$output" == *"sysinfo"* ]]
    [[ "$output" == *"extract"* ]]
}

@test "shelp --functions: does not show alias section headers" {
    run bash --norc -c "
        source '$HELP_SH'
        export BASH_CONFIG_DIR='$BASH_CONFIG_DIR'
        export NO_COLOR=1
        shelp --functions
    "
    [ "$status" -eq 0 ]
    [[ "$output" != *"── GIT ──"* ]]
}

@test "shelp: full mode shows both Aliases and Functions headers" {
    run bash --norc -c "
        source '$HELP_SH'
        export BASH_CONFIG_DIR='$BASH_CONFIG_DIR'
        export NO_COLOR=1
        shelp
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"Aliases"* ]]
    [[ "$output" == *"Functions"* ]]
}

@test "shelp <term>: search finds matching git aliases" {
    run bash --norc -c "
        source '$HELP_SH'
        export BASH_CONFIG_DIR='$BASH_CONFIG_DIR'
        export NO_COLOR=1
        shelp git
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"Aliases matching"* ]]
    # gs, gp, gc are all git aliases in aliases.bash
    [[ "$output" == *"gs"* ]]
    [[ "$output" == *"gp"* ]]
}

@test "shelp <term>: search finds matching function names" {
    run bash --norc -c "
        source '$HELP_SH'
        export BASH_CONFIG_DIR='$BASH_CONFIG_DIR'
        export NO_COLOR=1
        shelp mkcd
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"mkcd"* ]]
}

@test "shelp <term>: no matches returns exit 1 with message" {
    run bash --norc -c "
        source '$HELP_SH'
        export BASH_CONFIG_DIR='$BASH_CONFIG_DIR'
        export NO_COLOR=1
        shelp xyzzy_no_such_thing_ever
    "
    [ "$status" -eq 1 ]
    [[ "$output" == *"No matches"* ]]
}

@test "shelp <term>: search results include [SECTION] prefix for aliases" {
    run bash --norc -c "
        source '$HELP_SH'
        export BASH_CONFIG_DIR='$BASH_CONFIG_DIR'
        export NO_COLOR=1
        shelp git
    "
    [ "$status" -eq 0 ]
    # Each matching alias line is prefixed with [GIT]
    [[ "$output" == *"[GIT]"* ]]
}

@test "shelp --aliases <term>: filters only aliases, not functions" {
    run bash --norc -c "
        source '$HELP_SH'
        export BASH_CONFIG_DIR='$BASH_CONFIG_DIR'
        export NO_COLOR=1
        shelp --aliases sys
    "
    # 'sys' matches 'sysinfo' function, but --aliases should skip functions
    [[ "$output" != *"Functions matching"* ]]
}

@test "shelp: NO_COLOR=1 produces no ANSI escape codes" {
    run bash --norc -c "
        source '$HELP_SH'
        export BASH_CONFIG_DIR='$BASH_CONFIG_DIR'
        export NO_COLOR=1
        shelp --aliases
    "
    [ "$status" -eq 0 ]
    [[ "$output" != *$'\033'* ]]
}

@test "shelp: colorised output contains ANSI codes when NO_COLOR unset" {
    run bash --norc -c "
        source '$HELP_SH'
        export BASH_CONFIG_DIR='$BASH_CONFIG_DIR'
        unset NO_COLOR
        shelp --aliases
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *$'\033'* ]]
}
