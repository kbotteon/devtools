#!/usr/bin/env bash
################################################################################
# Starts Vivado using configuration in ${HOME}/.devtools-config
################################################################################

SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

# In this script, if any one step fails, we cannot continue
set -e

# The `get` script does most of the work for us already
source ${SCRIPT_DIR}/../get/vivado.sh

# This can potentially hose this shell due to conflicting binaries
# packaged with Vivado, but the get script already warned the user
source ${DTC_XILINX_ROOT}/Vivado/${DTC_XILINX_VERSION}/settings64.sh

# Launch in the foreground so we don't try to re-use the shell
vivado
