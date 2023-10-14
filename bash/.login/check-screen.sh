#!/usr/bin/env bash
#############################################################################
# Tests for active 'screen' sessions and displays a banner if any exist
#############################################################################

screens=$(screen -list | grep -E '[0-9]+\.[a-zA-Z0-9]+')

if [[ -n $screens ]]; then
    printf "\r\n"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "! YOU HAVE ACTIVE SCREENS !"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    printf "\r\n"
    screen -ls
    printf "\r\n"
fi
