alias ll='ls -lha'

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
