#!/usr/bin/env bash
################################################################################
# \brief Tests for active 'screen' and 'tmux' sessions at login, and displays a
# banner if any exist
################################################################################

# If screen is installed, check for any active sessions
if [[ type screen >/dev/null 2>&1 ]]; then
    # Screens always prints output, so look for the PIDs instead
    screens=$(screen -list | grep -E '[0-9]+\.[a-zA-Z0-9]+')
    # Print the banner if anything was listed
    if [[ -n $screens ]]; then
        printf "\r\n"
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "! YOU HAVE ACTIVE SCREENS !"
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        printf "\r\n"
        screen -ls
        printf "\r\n"
    fi
fi

# If tmux is installed, check for those too
if [[ type tmux >/dev/null 2>&1 ]]; then

fi
