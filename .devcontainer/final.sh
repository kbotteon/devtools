#!/usr/bin/env bash
################################################################################
# \brief Post-creation setup to run as user specified in Dockerfile
################################################################################

# Codespaces default
WORKSPACE='/workspaces'
THIS_REPO='devtools'

TOOLS_DIR="${WORKSPACE}/tools"
TMP_DIR="${WORKSPACE}/tmp"

################################################################################

# Create a symbolic link to Codespace home directory and persisted folder so
# you can easily interact via VSCode, which opens ${WORKSPACE}/{REPO}
mkdir .mounts
ln -s /home/developer ${WORKSPACE}/${THIS_REPO}/.mounts/home
ln -s /persist ${WORKSPACE}/${THIS_REPO}/.mounts/persist

################################################################################

# These persist between start/stop/rebuild but not delete/create
mkdir -p ${TMP_DIR}
mkdir -p ${TOOLS_DIR}

# Clone devtools so we can use its scripts
cd ${TOOLS_DIR} && git clone https://github.com/kbotteon/devtools.git

################################################################################

# Set up the default xstartup
mkdir -p ${HOME}/.vnc
chmod 755 ${HOME}/.vnc
ln -sf ${TOOLS_DIR}/devtools/vnc/xstatup-xfce ${HOME}/.vnc/xstartup

# For the life of a Codespace, retain installed ssh keys and config
# !!! Nope, this breaks key authentication, like with `gh cs ssh` so don't to it
# mkdir -p ${TMP_DIR}/dot-ssh
# hmod 700 ${TMP_DIR}/dot-ssh
# ln -s ${TMP_DIR}/dot-ssh ${HOME}/.ssh
