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
CFG_DIR=${HOME}/.config/devtools

if [[ 0 -eq 1 ]]; then
    echo "This script should be sourced, not executed"
    return 1
fi

# If there is a host definition file, source it
if [[ -f "${CFG_DIR}/config" ]]; then
    source "${CFG_DIR}/config"
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

################################################################################
# Setup Prompt
################################################################################

# Color escape sequences
CLR_BLU='%F{blue}'
CLR_CYN='%F{cyan}'
CLR_RED='%F{red}'
CLR_GRN=$'\033[32m'
CLR_YLW=$'\033[33m'
CLR_GRY=$'\033[90m'
CLR_RST=$'\033[0m'
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
PS1_DECORATOR=${DTC_PS1_DECORATOR:-"└──>"}

CLR_BAR="${CLR_GRY}"
CLR_CTX="${CLR_GRN}"

get_ruler() {
    local w=$(tput cols)
    printf '%s' "${CLR_BAR}"
    printf -- '-%.0s' $(seq 2 $((w > 80 ? 80 : w)))
    printf '%s' "${CLR_RST}"
}

get_context() {
    local ctx=""
    # Add a label for git branch, if in a repo
    if command -v __git_ps1 &>/dev/null; then
        ctx+="$(__git_ps1 '[%s]')"
    fi
    # Add a label for venv, if active
    if [[ -n "$VIRTUAL_ENV" ]]; then
        ctx+=" ($(basename "$VIRTUAL_ENV"))"
    fi
    # Compose the prompt string
    if [[ -n "$ctx" ]]; then
        printf '%s%s%s' "${CLR_CTX}" "${ctx}" "${CLR_RST}"
    fi
}

# Build the PROMPT
source "${GIT_PROMPT}"
setopt PROMPT_SUBST
export PROMPT="\$(get_ruler)${PS1_NEWL}${PS1_PROMPT} \$(get_context)${PS1_NEWL}${CLR_CYN}${PS1_DECORATOR} ${CLR_END}"

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

# Init completion
autoload -Uz compinit
compinit

# Share a history file across all sessions that use this script
export HISTFILE=${CFG_DIR}/history

# Keep a long history; sometimes we need that obscure command from last month
if [[ "${DTC_HISTSIZE}" -gt 0 ]]; then
    export HISTSIZE="${DTC_HISTSIZE}"
    export HISTFILESIZE=${DTC_HISTSIZE}
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
        for SCRIPT in ${CFG_DIR}/login/*; do
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

# Set DTC_EXISTS to this script's directory
export DTC_EXISTS="${0:A:h:h}"

################################################################################

# If we moved around for some reason, go back to where we started
cd ${START_DIR}
