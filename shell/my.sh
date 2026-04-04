# ------------------------------------------------------------------------------
# File Management
# ------------------------------------------------------------------------------

# Detailed info on current directory
alias here='pwd && LC_ALL=C LC_COLLATE=C ls -haF --group-directories-first'

# See where all the disk space is going
# --quiet to suppress permission errors
bloat() {
    if [[ "$1" == "--quiet" ]]; then
        du -hc --max-depth=1 2>&1 | grep -v "cannot" | sort -hr
    else
        du -hc --max-depth=1 | sort -hr
    fi
}

alias ll='ls -lha --color=auto'
alias ls='ls --color=auto'

# Remote Copy
rcp() {
    rsync -az --no-owner --no-group --info=progress2 "${1}" "${2}"
}

# ------------------------------------------------------------------------------
# Workspace
# ------------------------------------------------------------------------------

# Resize terminal
alias bigger="printf '\e[8;80;200t'"
alias smaller="printf '\e[8;40;90t'"

# Navigation
alias ..="cd .. && pwd && ls"

# History search
hgrep() {
    history | grep -i "$*"
}

# Run a command in all tmux panes
tmux-bcast() {
    local cmd=${1}
    tmux list-panes -s -F '#{session_name}:#{window_index}.#{pane_index}' | \
    while read -r pane; do
        tmux send-keys -t "$pane" "${cmd}" C-m
    done
}

# ------------------------------------------------------------------------------
# Application Management
# ------------------------------------------------------------------------------

if [[ "${OSTYPE}" == "darwin"* ]]; then
    # Launch new VS Code windows from terminal
    alias vscode='open -n -a "Visual Studio Code"'
fi

# ------------------------------------------------------------------------------
