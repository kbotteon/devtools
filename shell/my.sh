# Launch new VS Code windows from terminal
if [[ "${OSTYPE}" == "darwin"* ]]; then
    alias vscode='open -n -a "Visual Studio Code"'
fi

# Filesystem info
alias info-dir='LC_ALL=C LC_COLLATE=C ls -lhaF --group-directories-first'
alias info-disk='du -hc --max-depth=1 .'

# History grep
hgrep() {
    grep -e "$*" ${HISTFILE}
}
