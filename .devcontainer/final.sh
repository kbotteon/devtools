#!/usr/bin/env bash
################################################################################
# \brief Post-creation setup to run as user specified in Dockerfile
################################################################################

WORKSPACE='/workspaces'
THIS_REPO='devtools'
TOOLS_DIR="${WORKSPACE}/tools"

################################################################################

# Create a symbolic link to Codespace home directory and persisted folder so you
# can easily interact via VSCode, which opens ${WORKSPACE}/{THIS_REPO} by default
mkdir .mounts
ln -s /home/developer ${WORKSPACE}/${THIS_REPO}/.mounts/home
ln -s /persist ${WORKSPACE}/${THIS_REPO}/.mounts/persist

################################################################################

# These persist between start/stop/rebuild but not delete/create
# mkdir -p ${TOOLS_DIR}
# cd ${TOOLS_DIR} && git clone https://github.com/kbotteon/devtools.git

################################################################################

# Set up the default xstartup
mkdir -p ${HOME}/.vnc
chmod 755 ${HOME}/.vnc
ln -sf ${TOOLS_DIR}/devtools/vnc/xstartup-xfce ${HOME}/.vnc/xstartup
