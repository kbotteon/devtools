#!/usr/bin/env bash
################################################################################
# \brief Project-specific environment setup, run after image creation
# \warning Do not run this as root from devcontainer.json; it self-invokes as root
################################################################################

# Set this if you want to self-invoke as root
RUN_AS_ROOT=1

# Self-invoke as root if not already
if [ "$EUID" -ne 0 ] && [ "$RUN_AS_ROOT" -ne 0 ]; then
  exec sudo "$(realpath "$0")" "$@"
fi
