#!/usr/bin/env bash
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

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script should be sourced, not executed"
    exit 1
fi

START_DIR=$(pwd)
SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
CFG_DIR=${HOME}/.config/devtools

# Source the user's host-specific configuration, if it exists
if [[ -f "${CFG_DIR}/config" ]]; then
    source "${CFG_DIR}/config"
fi

# Optional first argument, e.g. '-k' for SSH keys
SCRIPT_ARG1=${1:+${1,,}}

#-------------------------------------------------------------------------------
# Theme
#-------------------------------------------------------------------------------

CLR_INFO='\[\033[38;5;39m\]'   # INFO colorization; sapphire
CLR_CTX='\033[38;5;208m'       # ATTN colorization; orange
CLR_END='\[\033[0m\]'
CLR_GRY='\033[90m'
CLR_RST='\033[0m'
# Wrapped variants for use inside PS1 $() calls
W_CTX="\001${CLR_CTX}\002"
W_GRY="\001${CLR_GRY}\002"
W_RST="\001${CLR_RST}\002"

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

: ${DTC_FRIENDLY_NAME:=$(hostname -s)}
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

__get_ruler() {
    local w=$(tput cols)
    printf '%b' "${W_GRY}"
    printf -- '-%.0s' $(seq 2 $((w > 80 ? 80 : w)))
    printf '%b' "${W_RST}"
}

__get_context() {
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
        printf '%b%s%b' "${W_CTX}" "${ctx}" "${W_RST}"
    fi
}

PS1_TITLE='\[\e]0;\u@\h:\w\a\]'
PS1_PROMPT="\u@${CLR_INFO}${DTC_FRIENDLY_NAME}${CLR_END}:\w"

if [[ -n ${GIT_PROMPT} ]]; then
    source "${GIT_PROMPT}"
    export PS1="${PS1_TITLE}\$(__get_ruler)\n${PS1_PROMPT} \$(__get_context)\n${CLR_INFO}${PS1_DECORATOR} ${CLR_END}"
else
    export PS1="${PS1_TITLE}${PS1_PROMPT}\n${CLR_INFO}${PS1_DECORATOR} ${CLR_END}"
fi

#-------------------------------------------------------------------------------
# Shell Behavior
#-------------------------------------------------------------------------------

# History
export HISTFILE=${CFG_DIR}/history
export HISTSIZE=${DTC_HISTSIZE:-1000}
export HISTFILESIZE=${HISTSIZE}

shopt -s histappend

# Optionally, write history after every command so other shells can access it
if [[ -n ${DTC_SHARE_HISTORY} ]]; then
    PROMPT_COMMAND="history -a; ${PROMPT_COMMAND}"
fi

# Prefer Homebrew tools to built-ins
if [[ -n ${DTC_PREFER_HOMEBREW} ]]; then
    export PATH=/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/bin:$PATH
fi

# Run login scripts in ${HOME}/.login, if it's a login shell
if [[ -n ${DTC_RUN_LOGIN} ]]; then
    if shopt -q login_shell; then
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

export DTC_EXISTS="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"

if [[ -n ${DTC_USE_LOCAL_PYTHON} ]] && [[ -d ${HOME}/.local/bin ]]; then
    export PATH=$PATH:${HOME}/.local/bin
fi

cd ${START_DIR}
