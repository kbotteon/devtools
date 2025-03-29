# Launch new VS Code windows from terminal
if [[ "${OSTYPE}" == "darwin"* ]]; then
    alias vscode='open -n -a "Visual Studio Code"'
fi

# Filesystem info
alias info-dir='LC_ALL=C LC_COLLATE=C ls -lhaF --group-directories-first'
alias info-disk='du -hc --max-depth=1 .'
alias ll='ls -lha --color=auto'
alias ls='ls --color=auto'

# Navigation
alias ..="cd .. && ls"

# History grep
hgrep() {
    grep -e "$*" ${HISTFILE}
}

