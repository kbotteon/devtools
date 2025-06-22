#!/usr/bin/env bash
################################################################################
# \brief Post-creation setup to run as user specified in Dockerfile
################################################################################

WS='/sandboxes'
PKG="${WS}/devtools"

################################################################################

# Create symlinks for easy access
mkdir -p ${WS}/.mounts && ln -sf /persist ${WS}/.mounts/persist

# This *is* the tools repo Codespace, so we don't need to clone it
# cd ${WS} && git clone https://github.com/kbotteon/devtools.git

################################################################################

# Set up the default VNC
mkdir -p ${HOME}/.vnc
chmod 755 ${HOME}/.vnc
cp ${WS}/devtools/vnc/xstartup-xfce ${HOME}/.vnc/xstartup

################################################################################

ln -s ${WS}/devtools/shell/develop.zsh ${HOME}/develop.ln
touch ${HOME}/.zshrc && echo "source ${HOME}/develop.ln" >> ${HOME}/.zshrc
