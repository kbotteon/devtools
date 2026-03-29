#!/usr/bin/env zsh
################################################################################
# Set up a comfortable and consistent development environment
#
# Arguments:
#   `-k` to set up ssh-agent with your SSH keys, e.g. for easy GitHub access
#
################################################################################

#-------------------------------------------------------------------------------
# Preamble
#-------------------------------------------------------------------------------

if [[ 0 -eq 1 ]]; then
    echo "This script should be sourced, not executed"
    return 1
fi

START_DIR=$(pwd)
SCRIPT_DIR=$(dirname "$(readlink -f "${(%):-%x}")")
CFG_DIR=${HOME}/.config/devtools

# Source the user's host-specific configuration, if it exists
if [[ -f "${CFG_DIR}/config" ]]; then
    source "${CFG_DIR}/config"
fi

# Optional first argument, e.g. '-k' for SSH keys
SCRIPT_ARG1=${1:+${1:l}}

#-------------------------------------------------------------------------------
# Theme
#-------------------------------------------------------------------------------

CLR_INFO='%F{39}'           # INFO colorization; sapphire
CLR_CTX=$'\033[38;5;208m'   # ATTN colorization; orange
CLR_END='%f'
CLR_GRY=$'\033[90m'
CLR_RST=$'\033[0m'

# Initialize LS_COLORS from the system database, then override the standard
# blues which are illegible on dark terminals
if command -v dircolors &>/dev/null; then
    eval "$(dircolors -b)"
fi

# 38;5;N = 256-color foreground N, 01 = bold; 27 = #005fff, 37 = #00afaf
export LS_COLORS="${LS_COLORS:+${LS_COLORS}:}di=38;5;27:ln=01;38;5;37"

#-------------------------------------------------------------------------------
# Prompt
#-------------------------------------------------------------------------------

: ${DTC_FRIENDLY_NAME:=%m}
PS1_DECORATOR=${DTC_PS1_DECORATOR:-"└──>"}
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Locate git-prompt.sh for branch/tag display
if command -v brew &>/dev/null; then
    GIT_PROMPT="$(brew --prefix git)/etc/bash_completion.d/git-prompt.sh"
elif [[ -f '/usr/lib/git-core/git-sh-prompt' ]]; then
    GIT_PROMPT='/usr/lib/git-core/git-sh-prompt'
elif [[ -f '/usr/share/git-core/contrib/completion/git-prompt.sh' ]]; then
    GIT_PROMPT='/usr/share/git-core/contrib/completion/git-prompt.sh'
fi

get_ruler() {
    local w=$(tput cols)
    printf '%s' "${CLR_GRY}"
    printf -- '-%.0s' $(seq 2 $((w > 80 ? 80 : w)))
    printf '%s' "${CLR_RST}"
}

get_context() {
    local ctx=""
    # Git branch/ref; ':' prefix denotes detached HEAD
    if command -v __git_ps1 &>/dev/null; then
        local git_info="$(__git_ps1 '%s')"
        if [[ "$git_info" == \(*\) ]]; then
            ctx+="[:${git_info//[()]/}]"
        elif [[ -n "$git_info" ]]; then
            ctx+="[${git_info}]"
        fi
    fi
    # Python venv, if active
    if [[ -n "${VIRTUAL_ENV:-}" ]]; then
        ctx+=" ($(basename "$VIRTUAL_ENV"))"
    fi
    if [[ -n "$ctx" ]]; then
        printf '%s%s%s' "${CLR_CTX}" "${ctx}" "${CLR_RST}"
    fi
}

source "${GIT_PROMPT}"
setopt PROMPT_SUBST

PS1_PROMPT="%n@${CLR_INFO}${DTC_FRIENDLY_NAME}${CLR_END}:%d"
PS1_NL=$'\n'
export PROMPT="\$(get_ruler)${PS1_NL}${PS1_PROMPT} \$(get_context)${PS1_NL}${CLR_INFO}${PS1_DECORATOR} ${CLR_END}"

#-------------------------------------------------------------------------------
# Shell Behavior
#-------------------------------------------------------------------------------

autoload -Uz compinit
compinit

# History
export HISTFILE=${CFG_DIR}/history
export HISTSIZE=${DTC_HISTSIZE:-1000}
export HISTFILESIZE=${HISTSIZE}
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

# Run login scripts in ${HOME}/.login, if it's a login shell
if [[ -n ${DTC_RUN_LOGIN} ]]; then
    if [[ -o login ]] || [[ -n $PS1 ]]; then
        for SCRIPT in ${CFG_DIR}/login/*; do
            [ -f "${SCRIPT}" ] && [ -x "${SCRIPT}" ] && "${SCRIPT}"
        done
    fi
fi

#-------------------------------------------------------------------------------
# SSH Keys
#-------------------------------------------------------------------------------

if [[ '-k' = ${SCRIPT_ARG1} ]]; then
    source ${SCRIPT_DIR}/../lib/agent-helper.sh
    echo "Agent in use is PID ${SSH_AGENT_PID}"
    trap 'test -n "${SSH_AGENT_PID}" && eval `ssh-agent -k`' EXIT HUP
fi

#-------------------------------------------------------------------------------
# Environment
#-------------------------------------------------------------------------------

export DTC_EXISTS="${0:A:h:h}"

if [[ -n ${DTC_USE_LOCAL_PYTHON} ]] && [[ -d ${HOME}/.local/bin ]]; then
    export PATH=$PATH:${HOME}/.local/bin
fi

cd ${START_DIR}

#-------------------------------------------------------------------------------
