#!/usr/bin/env bash
################################################################################
# Set up shell to access Vivado tools based on ${HOME}/.devtools-config
################################################################################

TMP_DIR="${HOME}/.Vivado"
SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
CURRENT_DIR=$(pwd)

# Require devtools
if [ -z "${DTC_EXISTS}" ]; then
    echo "You must first source develop.sh"
    exit 1
else
    source ${DTC_EXISTS}/bash/helpers.sh
    # Grab the latest host configuration
    source ${HOME}/.devtools-config
fi

# Make sure the variables we need were set in .devtools-config
check_env DTC_XILINX_ROOT DTC_XILINX_VERSION

# Borrow the user's home directory for Vivado to drop logs into
mkdir -p ${TMP_DIR}
# Tell Vivado to use it
export TMP=${TMP_DIR}

# Set up the Xilinx environment
if [[ -n ${DTC_XILINX_LICENSE_PATH} ]]; then
    export XILINXD_LICENSE_FILE=${DTC_XILINX_LICENSE_PATH}
fi

# This can potentially hose this shell due to conflicting binaries
# packaged with Vivado, so only use it for vivado
printf "!!!\r\n"
printf "!!! Vivado tools are on PATH; only use this shell for Vivado\r\n"
printf "!!!\r\n"

# Grab the Xilinx tools
source ${DTC_XILINX_ROOT}/Vivado/${DTC_XILINX_VERSION}/settings64.sh
