#!/usr/bin/env bash
################################################################################
# \brief Post-creation setup to run as user specified in Dockerfile
################################################################################

WS='/persist/sandboxes'
PKG="${WS}/devtools"

# Create symlinks for easy access
mkdir -p ${WS}/.mounts && ln -sf /persist/home ${WS}/.mounts/home

#-------------------------------------------------------------------------------
# Devtools
#-------------------------------------------------------------------------------

# This *is* the tools repo Codespace, so we don't need to clone it
# cd ${WS} && git clone https://github.com/kbotteon/devtools.git
mkdir -p ${HOME}/.devtools && touch ${HOME}/.devtools/history

# Default devtools config
echo "
export DTC_CLEAN_HISTORY=1
source ${PKG}/shell/my.sh
" >> ${HOME}/.devtools/config

# Source devtools in every shell
echo "# Grab devtools in every shell
source ${PKG}/shell/develop.zsh
" >> ${HOME}/.zshrc

#-------------------------------------------------------------------------------
# Git
#-------------------------------------------------------------------------------

echo "
# Include default Git setup
[include]
    path = ${PKG}/git/.gitconfig
" >> ${HOME}/.gitconfig

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

echo "# Access all repos by adding a key called id_gh
Host github.com
    User git
    IdentityFile ~/.ssh/${GITHUB_USER}@github.com
" >> ${HOME}/.ssh/config

#-------------------------------------------------------------------------------
