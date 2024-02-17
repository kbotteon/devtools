# For Mac, assuming GNU tools were installed with Homebrew

commands_available() {

    local commands=(
        "gls"
        "gdu"
        "gtar"
    )

    for cmd in "${commands[@]}"; do
        # If any one command not avaiable, return failurre
        if ! command -v "$cmd" &> /dev/null; then
            return 1
        fi
    done

    return 0
}

if [[ "${OSTYPE}" == "darwin"* ]] && commands_available; then
    alias ls='gls'
    alias du='gdu'
    alias tar='gtar'
    # Plus the more complicated stuff
    alias info-dir='LC_ALL=C LC_COLLATE=C ls -lhaF --group-directories-first'
    alias info-disk='du -hc --max-depth=1 .'
fi

# Copy- Remote & Interruptable
alias cp-ri='rsync -av --progress --append-verify --partial'

# Make running single Java files easier
# Usage: `jdo MyFile.` or `jdo MyFile`
# Expands to `javac MyFile.class && java MyFile`
jdo() {
    FILE="$1"
    # Shell completion includes the dot, and we remove it, but
    # you can also omit it yourself
    if [[ "${FILE}" == *"." ]]; then
        RUN="${FILE%?}"
    fi
    # Compile the bytecode and run if successful
    javac "$RUN.java" && java "$RUN"
}
