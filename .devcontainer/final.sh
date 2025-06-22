#!/usr/bin/env bash
################################################################################
# \brief Post-creation setup to run as user specified in Dockerfile
################################################################################

WS='/persist/sandboxes'
PKG="${WS}/devtools"

#-------------------------------------------------------------------------------
# Devtools
#-------------------------------------------------------------------------------

# Create symlinks for easy access
mkdir -p ${WS}/.mounts && ln -sf /persist/home ${WS}/.mounts/home

# This *is* the tools repo Codespace, so we don't need to clone it
# cd ${WS} && git clone https://github.com/kbotteon/devtools.git

ln -sf ${PKG}/shell/develop.zsh ${HOME}/develop.ln
touch ${HOME}/.zshrc && echo "source ${HOME}/develop.ln" >> ${HOME}/.zshrc

#-------------------------------------------------------------------------------
# Git
#-------------------------------------------------------------------------------

echo '# Include default Git setup
[include]
    path = /persist/sandboxes/devtools/git/.gitconfig
' >> ${HOME}/.gitconfig

#-------------------------------------------------------------------------------
# VNC
#-------------------------------------------------------------------------------

# Set up the default VNC
mkdir -p ${HOME}/.vnc
chmod 755 ${HOME}/.vnc
cp ${PKG}/vnc/xstartup-xfce ${HOME}/.vnc/xstartup

#-------------------------------------------------------------------------------
# SSH
#-------------------------------------------------------------------------------

mkdir -p ${HOME}/.ssh && chmod 700 ${HOME}/.ssh

echo '# Access all repos by adding a key called id_gh
Host github.com
    User git
    IdentityFile ~/.ssh/kbotteon@github.com
' >> ${HOME}/.ssh/config

#-------------------------------------------------------------------------------
