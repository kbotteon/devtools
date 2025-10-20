#!/usr/bin/env zsh
################################################################################
# \brief Set up a comfortable shell and development environment
#
# Arguments:
#   `-k` to set up ssh-agent with your SSH keys, e.g. for easy GitHub access
#
# This script will:
#   - Set up ssh-agent and key(s) if requested
#   - Reformat terminal colors and layout, including adding git status
#   - Run user environment script, if it exists
#
################################################################################

START_DIR=$(pwd)
SCRIPT_DIR=$(dirname "$(readlink -f "${(%):-%x}")")

if [[ 0 -eq 1 ]]; then
    echo "This script should be sourced, not executed"
    return 1
fi

################################################################################
# Parse Arguments
#
# We actually only have one optional argument '-k' which loads SSH keys
################################################################################

# No argument defaults to no keys
if [[ -z $1 ]]; then
  SCRIPT_ARG1=""
else
  # Transform to lowercase
  SCRIPT_ARG1=${1:l}
fi

# If there is a host definition file, source it
if [[ -f "${HOME}/.devtools/config" ]]; then
    source "${HOME}/.devtools/config"
fi

################################################################################
# Setup Prompt
################################################################################

# Color escape sequences
CLR_BLU='%F{blue}'
CLR_CYN='%F{cyan}'
CLR_GRN='%F{green}'
CLR_RED='%F{red}'
CLR_GRY=$'\033[90m'
CLR_END='%f'

# A colorized prompt with user@host:full_path
: ${DTC_FRIENDLY_NAME:=%m}
PS1_TITLE='%n@%m'
PS1_PROMPT="%n@${CLR_CYN}${DTC_FRIENDLY_NAME}${CLR_END}:%d"
PS1_NEWL=$'\n'

# If the script to format the prompt with git info exists, locate it

# MacOS
if command -v brew &>/dev/null; then
    GIT_PROMPT="`brew --prefix git`/etc/bash_completion.d/git-prompt.sh"
# Debian/Ubuntu
elif [[ -f '/usr/lib/git-core/git-sh-prompt' ]]; then
    GIT_PROMPT='/usr/lib/git-core/git-sh-prompt'
# RHEL
elif [[ -f '/usr/share/git-core/contrib/completion/git-prompt.sh' ]]; then
    GIT_PROMPT='/usr/share/git-core/contrib/completion/git-prompt.sh'
# Ubuntu 24.04+
elif [[ -f '/usr/lib/git-core/git-sh-prompt' ]]; then
    GIT_PROMPT='/usr/lib/git-core/git-sh-prompt'
fi

export VIRTUAL_ENV_DISABLE_PROMPT=1
PS1_PREFIX='$(w=$(tput cols); printf '-%.0s' $(seq 2 $((w >> 80 ? 80 : w))))${PS1_NEWL}'
PS1_DECORATOR=${DTC_PS1_DECORATOR:-"└──>"}

get_venv() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo " [$(basename "$VIRTUAL_ENV")]"
    fi
}

# If we could find a Git prompt setup script, source it and update our PS1
if [[ -n ${GIT_PROMPT} ]]; then
    source "${GIT_PROMPT}"
    # Add Git status to the command line
    setopt PROMPT_SUBST
    # export PROMPT="${PS1_PROMPT} ${CLR_CYN}\$(__git_ps1 '(%s)')${CLR_END}${PS1_NEWL}${CLR_CYN}└──> ${CLR_END}"
    export PROMPT="${CLR_GRY}${PS1_PREFIX}${CLR_END}${PS1_PROMPT} ${CLR_CYN}\$(__git_ps1 '[%s]')\$(get_venv)${PS1_NEWL}${PS1_DECORATOR} ${CLR_END}"
# Otherwise use the default PS1
else
    export PROMPT="${PS1_PROMPT}${PS1_NEWL}${CLR_CYN}└──> ${CLR_END}"
fi

################################################################################
# SSH Keys
################################################################################

# Start ssh-agent and add a key to avoid re-typing passwords for this session,
# which can happen a lot since folks use Git submodules so much
if [[ '-key' = ${SCRIPT_ARG1} ]]; then
    source ${SCRIPT_DIR}/../lib/agent-helper.sh
    echo "Agent in use is PID ${SSH_AGENT_PID}"
    # Stop ssh-agent we started in this shell when exiting or SSH disconnects
    trap 'test -n "${SSH_AGENT_PID}" && eval `ssh-agent -k`' EXIT HUP
fi

################################################################################
# Shell Behavior
################################################################################

# Share a history file across all sessions that use this script
export HISTFILE=${HOME}/.devtools/history

# Keep a long history; sometimes we need that obscure command from last month
if [[ "${DTC_HISTSIZE}" -gt 0 ]]; then
    export HISTSIZE="${DTC_HISTSIZE}"
    export HISTFILESIZE=${HISTSIZE}
else
    export HISTSIZE=1000
    export HISTFILESIZE=${HISTSIZE}
fi

export SAVEHIST=${HISTSIZE}

# Keep a subjectively clean history, if requested
if [[ -n ${DTC_CLEAN_HISTORY} ]]; then
    setopt APPEND_HISTORY
    unsetopt SHARE_HISTORY
    unsetopt EXTENDED_HISTORY
    setopt HIST_SAVE_NO_DUPS
    setopt HIST_IGNORE_ALL_DUPS
    setopt HIST_REDUCE_BLANKS
fi

# Optionally, override clean history and share with other shells
if [[ -n ${DTC_SHARE_HISTORY} ]]; then
    setopt SHARE_HISTORY
fi

# Prefer Homebrew tools to built-ins
if [[ -n ${DTC_PREFER_HOMEBREW} ]]; then
    export PATH=/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/bin:$PATH
fi

# Run login scripts, if it's a login shell
if [[ -n ${DTC_RUN_LOGIN} ]]; then
    if [[ -o login ]] || [[ -n $PS1 ]]; then
        # Collect the scripts in .login
        for SCRIPT in ${HOME}/.config/devtools/login/*; do
            # Run only executable files
            [ -f "${SCRIPT}" ] && [ -x "${SCRIPT}" ] && "${SCRIPT}"
        done
    fi
fi

################################################################################
# Host Setup
################################################################################

# Add user Python installs to path, if they exist
if [[ -n ${DTC_USE_LOCAL_PYTHON} ]] && [[ -f ${HOME}/.local/bin ]]; then
    export PATH=$PATH:${HOME}/.local/bin
fi

################################################################################

# If we moved around for some reason, go back to where we started
cd ${START_DIR}
