#!/usr/bin/env bash

TOOLS_DIR="/workspaces/tools"
TMP_DIR="/workspaces/tmp"

# These persist between start/stop/rebuild but not delete/create
mkdir -p ${TMP_DIR}
mkdir -p ${TOOLS_DIR}

# Clone devtools so we can use those scripts
cd ${TOOLS_DIR} && git clone https://github.com/kbotteon/devtools.git

# Set up the default xstartup
mkdir -p ${HOME}/.vnc
chmod 755 ${HOME}/.vnc
ln -sf ${TOOLS_DIR}/devtools/vnc/xstatup-xfce ${HOME}/.vnc/xstartup

# For the life of a Codespace, retain installed ssh keys and config
mkdir -p ${TMP_DIR}/dot-ssh
chmod 700 ${TMP_DIR}/dot-ssh
ln -s ${TMP_DIR}/dot-ssh ${HOME}/.ssh
