TMP_DIR="${HOME}/.Vivado"
SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

# We need a host.sh file to describe the host configuration
source ${SCRIPT_DIR}/../host.sh

# Borrow the user's home directory for Vivado to drop logs into
mkdir -p ${TMP_DIR}

# Set up the Xilinx environment
export XILINXD_LICENSE_FILE=${XILINX_LICENSE_PATH}
export TMP=${TMP_DIR}

# This can potentially hose this shell due to conflicting binaries
# packaged with Vivado
source ${XILINX_ROOT}/Vivado/${XILINX_VERSION}/settings64.sh
