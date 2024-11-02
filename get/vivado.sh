#!/usr/bin/env bash
################################################################################
# Set up shell to access Vivado tools based on ${HOME}/.devtools-config
################################################################################

TMP_DIR="${HOME}/.Vivado"
SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
CURRENT_DIR=$(pwd)

################################################################################

# This script is meant to be sourced, not executed alone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    printf "This script should be sourced, not executed\r\n"
    exit 1
fi

# Require the devtools helpers
if [ -z "${DTC_EXISTS}" ]; then
    echo "You must first source develop.sh"
    return 1
else
    source ${DTC_EXISTS}/bash/helpers.sh
    # Grab the latest host configuration
    source ${HOME}/.config/devtools/config
fi

################################################################################

# By default, that's in the user's home directory
check_env DTC_XILINX_ROOT DTC_XILINX_VERSION

# Borrow the user's home directory for Vivado to drop logs into
mkdir -p ${TMP_DIR}
# Tell Vivado to use it
export TMP=${TMP_DIR}

# Set up the Xilinx environment
if [[ -n ${DTC_XILINX_LICENSE_PATH} ]]; then
    export XILINXD_LICENSE_FILE=${DTC_XILINX_LICENSE_PATH}
fi

################################################################################

# Grab the Xilinx tools
source ${DTC_XILINX_ROOT}/Vivado/${DTC_XILINX_VERSION}/settings64.sh

# This can potentially hose this shell due to conflicting binaries
# packaged with Vivado, so only use it for vivado
echo "!!!"
echo "!!! Vivado tools are on PATH"
echo "!!! Only use this shell for Vivado"
echo "!!!"

# No, but really only use it for Vivado
export PS1="${CLR_RED}Vivado > ${CLR_END}"

################################################################################
