#!/usr/bin/env bash -n
################################################################################
# Bash Helpers
################################################################################

# Creates an environment variable for the number of cores to use for a build,
# which is either the total minus two, to leave some breathing room for a user,
# or just the total for 2-core machines, which are typically action runners.
suggest_make_jobs() {
    cpus=$(nproc)
    if [ "${cpus}" -le 2 ]; then
        echo 2
    else
        echo $((cpus-2))
    fi
}

# Checks that one or more variables exist
check_env() {
    rval=0
    for var in "$@"; do
        if [[ -z "${!var}" ]]; then
            echo "${var} must be set in environment"
            rval=1
        fi
    done
    return $rval
}

# Move to the parent directory of a shell script; useful if you're invoking
# the script from any other directory
cd_to_parent() {
    SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")"})
    cd $SCRIPT_DIR/..
}
