#!/usr/bin/env bash
################################################################################
# \brief Project-specific environment setup, run after image creation
# \warning This is NOT run as root
################################################################################

# Set this if you want to run the entire script as root
RUN_AS_ROOT=0

# Self-invoke as root if not already
if [ "$EUID" -ne 0 ] && [ "$RUN_AS_ROOT" -ne 0 ]; then
  exec sudo "$(realpath "$0")" "$@"
fi
