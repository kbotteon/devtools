# ------------------------------------------------------------------------------
# Generic
# ------------------------------------------------------------------------------

# Filesystem info
alias here='pwd && LC_ALL=C LC_COLLATE=C ls -lhaF --group-directories-first'
alias bloat='du -hc --max-depth=1'
alias ll='ls -lha --color=auto'
alias ls='ls --color=auto'

# Navigation
alias ..="cd .. && pwd && ls"

# History search
hgrep() {
    history | grep -i "$*"
}

# ------------------------------------------------------------------------------
# MacOS
# ------------------------------------------------------------------------------

if [[ "${OSTYPE}" == "darwin"* ]]; then
    # Launch new VS Code windows from terminal
    alias vscode='open -n -a "Visual Studio Code"'
fi
