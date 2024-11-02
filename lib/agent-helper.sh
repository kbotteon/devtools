################################################################################
# \brief Helper to save SSH keys with passphrases on Linux boxes
#
# https://docs.github.com/en/authentication/connecting-to-github-with-ssh/working-with-ssh-key-passphrases
################################################################################

SSH_ENV="${HOME}/.ssh/agent.env"

agent_load_env() { test -f "${SSH_ENV}" && . "${SSH_ENV}" > /dev/null; }
agent_start() { (umask 077; ssh-agent >| "${SSH_ENV}") . "${SSH_ENV}" > /dev/null; }

agent_load_env

agent_run_state=$(ssh-add -l > /dev/null 2>&1; echo $?)

# Agent is not running
if [ -z "$SSH_AUTH_SOCK" ] || [ $agent_run_state -eq 2 ]; then
    agent_start
    ssh-add -t 3600
# Agent is running with nothing loaded
elif [ -n "$SSH_AUTH_SOCK" ] && [ $agent_run_state -eq 1 ]; then
    ssh-add -t 3600
fi

unset SSH_ENV
