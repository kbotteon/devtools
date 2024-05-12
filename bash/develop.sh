#!/usr/bin/env bash -n
################################################################################
# \brief Set up a consistent development environment
#
# Arguments:
#   `-key` to set up ssh-agent with your SSH keys, e.g. for easy GitHub access
#
# This script will:
#   - Set up ssh-agent and key(s) if requested
#   - Reformat terminal colors and layout, including adding git status
#   - Run user environment script, if it exists
#
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

# If the script to format the prompt with git info exists, locate it
# Default Linux location
GIT_PROMPT_LOC_1='/usr/lib/git-core/git-sh-prompt'
# Default Mac location if using HomeBrew
if command -v brew &>/dev/null; then
    GIT_PROMPT_LOC_2="`brew --prefix git`/etc/bash_completion.d/git-prompt.sh"
fi

if [ -f ${GIT_PROMPT_LOC_1} ]; then
    GIT_PROMPT=${GIT_PROMPT_LOC_1}
elif [ -f ${GIT_PROMPT_LOC_2} ]; then
    GIT_PROMPT=${GIT_PROMPT_LOC_2}
fi

# If we could find a Git prompt setup script, source it and update our PS1
if [[ -n ${GIT_PROMPT} ]]; then
    source ${GIT_PROMPT}
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
    source ${SCRIPT_DIR}/lib/github-agent-helper.sh
    echo "Agent in use is PID ${SSH_AGENT_PID}"
    # Stop ssh-agent we started in this shell when exiting or SSH disconnects
    trap 'test -n "${SSH_AGENT_PID}" && eval `ssh-agent -k`' EXIT HUP
fi

################################################################################
# Shell Config
################################################################################

# Share a history file across all active Bash sessions using this script
HISTFILE=${HOME}/.devtools-history
# Keep a long history; sometimes we need that obscure command from last month
HISTSIZE=5000
shopt -s histappend
# Optionally, write history after every command so other shells can access it
if [[ -n ${DTC_SHARE_HISTORY} ]]; then
    PROMPT_COMMAND="history -a; ${PROMPT_COMMAND}"
fi

# Don't try to run login scripts in non-login shells, like screens
if [[ -n ${DTC_RUN_LOGIN} ]]; then
    if shopt -q login_shell; then
        # Collect the scripts in .login
        for script in ${HOME}/.login/*.sh; do
            # Run only executable files
            [ -f "${script}" ] && [ -x "${script}" ] && "${script}"
        done
    fi
fi

################################################################################
# Host Setup
################################################################################

# If there is a host definition file, source it
# We always expect it to be in a user's home directory
if [[ -f "${HOME}/.devtools-config" ]]; then
    source "${HOME}/.devtools-config"
fi

# Set up Xilinx tools, if the roots were defined
if [[ -n ${DTC_XILINX_ROOT} ]] && [[ -n ${DTC_XILINX_VERSION} ]]; then
    export VITIS_ROOT=${XILINX_ROOT}/Vitis/${XILINX_VERSION}
    export MICROBLAZE_BIN_DIR=${VITIS_ROOT}/gnu/microblaze/lin/bin
    # Do **NOT** put all Xilinx tools on path by default because, for
    # example, there is an old CMake included for Vivado that will cause
    # problems with your other build systems
fi

# Add user Python installs to path, if they exist
if [ -f ${HOME}/.local/bin ]; then
    export PATH=$PATH:${HOME}/.local/bin
fi

# Run the user environment configuration, if it exists
if [[ -f ${DTC_USER_ENV_SCRIPT} ]]; then
    source ${DTC_USER_ENV_SCRIPT}
fi

################################################################################

# If we moved around for some reason, go back to where we started
cd $STARTING_DIR
