#!/usr/bin/env bash
################################################################################
# \brief Post-creation setup to run as user specified in Dockerfile
# \warning This is NOT run as root
################################################################################

WS='/persist/sandboxes'
PKG="${WS}/devtools"

#-------------------------------------------------------------------------------
# Filesystem
#-------------------------------------------------------------------------------

# Create symlinks for easy access
mkdir -p ${WS}/.mounts && ln -sf /persist/home ${WS}/.mounts/home

# Make a persistent bin directory to put applications in
mkdir -p ${WS}/.bin

# Remove unused default directories
rmdir ${HOME}/{Documents,Music,Pictures,Public,Templates,Videos} 2>/dev/null || true

#-------------------------------------------------------------------------------
# Devtools
#-------------------------------------------------------------------------------

# This *is* the tools repo Codespace, so we don't need to clone it
# cd ${WS} && git clone https://github.com/kbotteon/devtools.git
mkdir -p ${HOME}/.devtools
touch ${HOME}/.devtools/history

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
# GUI Apps
#-------------------------------------------------------------------------------

# VNC
mkdir -p ${HOME}/.vnc
chmod 755 ${HOME}/.vnc
cp ${PKG}/vnc/xstartup-xfce ${HOME}/.vnc/xstartup

# Browser
curl -o /tmp/firefox.tar.xz https://download-installer.cdn.mozilla.net/pub/firefox/releases/139.0.4/linux-x86_64/en-US/firefox-139.0.4.tar.xz
(
    cd /tmp
    tar -xvf firefox.tar.xz -C ${WS}/.bin
    ln -sf ${WS}/.bin/firefox/firefox ${WS}/.bin/start-firefox
)

#-------------------------------------------------------------------------------
# SSH
#-------------------------------------------------------------------------------

mkdir -p ${HOME}/.ssh && chmod 700 ${HOME}/.ssh

echo "# Access all of your repos by adding a key called {USER}@github.com
Host github.com
    User git
    IdentityFile ~/.ssh/${GITHUB_USER}@github.com
" >> ${HOME}/.ssh/config

#-------------------------------------------------------------------------------
# Preferences
#-------------------------------------------------------------------------------

ln -s ${PKG}/.config/procps/toprc ${HOME}/.config/procps/toprc
ln -s ${PKG}/.config/.tmux.conf ${HOME}/.tmux.conf

#-------------------------------------------------------------------------------
