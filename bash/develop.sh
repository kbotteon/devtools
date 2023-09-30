#!/usr/bin/env bash -n
################################################################################
# Development Environment Setup
################################################################################

STARTING_DIR=$(pwd)
SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

################################################################################
# Parse Arguments
#
# We actually only have one optional argument '-key' which loads SSH keys
################################################################################

# No argument defaults to no keys
if [ -z $1 ]; then
  SCRIPT_ARG1=""
else
  # Transform to lowercase
  SCRIPT_ARG1=${1,,}
fi

################################################################################
# Setup Prompt
################################################################################

# Color escape sequences
CLR_BLU='\[\033[01;34m\]'
CLR_GRN='\[\033[01;32m\]'
CLR_RED='\[\033[01;31m\]'
CLR_END='\[\033[00m\]'

# A colorized prompt with user@host:full_path
PS1_TITLE='\[\e]0;\u@\h:\w\a\]'
PS1_PROMPT="\u@${CLR_RED}\h${CLR_END}:\w"

# If a colorization and/or format for Git exists, locate it
GIT_PROMPT_LOC_1='/usr/lib/git-core/git-sh-prompt'
GIT_PROMPT_LOC_2="${SCRIPT_DIR}/git-sh-prompt"
if command -v brew &>/dev/null; then
    GIT_PROMPT_LOC_3="`brew --prefix git`/etc/bash_completion.d/git-prompt.sh"
fi

if [ -f ${GIT_PROMPT_LOC_1} ]; then
    GIT_PROMPT=${GIT_PROMPT_LOC_1}
elif [ -f ${GIT_PROMPT_LOC_2} ]; then
    GIT_PROMPT=${GIT_PROMPT_LOC_2}
elif [ -f ${GIT_PROMPT_LOC_3} ]; then
    GIT_PROMPT=${GIT_PROMPT_LOC_3}
fi

# If we could find a Git prompt setup script, source it and update our PS1
if [[ -n ${GIT_PROMPT} ]]; then
    source $GIT_PROMPT
    # Add Git status to the command line
    export PS1="${PS1_TITLE}${PS1_PROMPT} ${CLR_RED}\$(__git_ps1 '(%s)')${CLR_END}\n└──> "
# Otherwise use the default PS1
else
    export PS1="${PS1_TITLE}${PS1_PROMPT}\n└──> "
fi

################################################################################
# SSH Keys
################################################################################

# Start ssh-agent and add a key to avoid re-typing passwords for this session,
# which can happen a lot since folks use Git submodules so much
if [[ '-key' = ${SCRIPT_ARG1} ]]; then
    . ${SCRIPT_DIR}/lib/github-agent-helper.sh
    echo "Agent in use is PID ${SSH_AGENT_PID}"
    # Stop ssh-agent we started in this shell when exiting or SSH disconnects
    trap 'test -n "${SSH_AGENT_PID}" && eval `ssh-agent -k`' EXIT HUP
fi

################################################################################
# Host Setup
################################################################################

# If there is a host definition file, source it
# We always expect it one directory above this repository
if [[ -f "${SCRIPT_DIR}/../host.sh" ]]; then
    source "${SCRIPT_DIR}/../host.sh"
fi

# Set up Xilinx tools
if [[ -n ${XILINX_ROOT} ]] && [[ -n ${XILINX_VERSION} ]]; then
    export VITIS_ROOT=${XILINX_ROOT}/Vitis/${XILINX_VERSION}
    export MB_BIN_DIR=${VITIS_ROOT}/gnu/microblaze/lin/bin
    export PATH=${PATH}:${MB_BIN_DIR}
    # Do **NOT** put all Xilinx tools on path by default because, for
    # example, there is an old CMake included for Vivado that will cause
    # problems with your other build systems
    # Skip this: source ${XILINX_ROOT}/Vivado/${XILINX_VERSION}/settings64.sh
fi

# Add user Python installs to path, if they exist
if [ -f ${HOME}/.local/bin ]; then
    export PATH=$PATH:${HOME}/.local/bin
fi

# Run the user environment configuration, if it exists
if [[ -f ${USER_ENV_SCRIPT} ]]; then
    source ${USER_ENV_SCRIPT}
fi

################################################################################

# If we moved around for some reason, go back to where we started
cd $STARTING_DIR
