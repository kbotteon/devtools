#!/usr/bin/env bash

# Don't try to run login scripts in non-login shells, like screens
if shopt -q login_shell; then
    # Collect the scripts in .login
    for script in ${HOME}/.login/*.sh; do
        # Run that which is a regular executable file
        [ -f "$script" ] && [ -x "$script" ] && "$script"
    done
fi

