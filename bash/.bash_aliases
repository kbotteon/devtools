# Homebrew prepends GNU tools with a `g` so lets check for them
commands_available() {

    local commands=(
        "gls"
        "gdu"
        "gtar"
    )

    for cmd in "${commands[@]}"; do
        # If any one command not avaiable, return failure
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
fi

# Copy: Remote & Interruptable
alias cp-ri='rsync -av --progress --append-verify --partial'

# Make running single Java files easier
# Usage: `jdo MyFile.` or `jdo MyFile`
# Expands to `javac MyFile.class && java MyFile`
jdo() {
    FILE="$1"
    # Shell completion includes the dot, so we remove it
    if [[ "${FILE}" == *"." ]]; then
        RUN="${FILE%?}"
    fi
    # Compile the bytecode and run if that was successful
    javac "${RUN}.java" && java "${RUN}"
}
