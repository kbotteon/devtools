#!/usr/bin/env bash -n
################################################################################
# Build Helpers
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
