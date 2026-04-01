#!/usr/bin/env bash

# Terminal Welcome Message
if [[ $- == *i* ]] && [[ -z "$SYSTEM_OVERVIEW_SHOWN" ]]; then
    export SYSTEM_OVERVIEW_SHOWN=1
    print_distro_logo
    system_overview
fi
