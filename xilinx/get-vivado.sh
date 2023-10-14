#!/usr/bin/env bash
################################################################################
# Set up shell to access Vivado tools based on .devtools-config
################################################################################

TMP_DIR="${HOME}/.Vivado"
SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

# We need a .devtools-config to describe the host configuration
# By default, that's in the user's home directory
source ${HOME}/.devtools-config

# Borrow the user's home directory for Vivado to drop logs into
mkdir -p ${TMP_DIR}

# Set up the Xilinx environment
export XILINXD_LICENSE_FILE=${XILINX_LICENSE_PATH}
export TMP=${TMP_DIR}

# This can potentially hose this shell due to conflicting binaries
# packaged with Vivado, so only use it for vivado
printf "!!!\r\n"
printf "!!! Vivado tools are on PATH; only use this shell for Vivado\r\n"
printf "!!!\r\n"

source ${XILINX_ROOT}/Vivado/${XILINX_VERSION}/settings64.sh
