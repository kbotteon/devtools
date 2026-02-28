#!/usr/bin/env bash
################################################################################
# \brief On-create setup to run as user specified in Dockerfile
################################################################################

LV='/persist'

WS="${LV}/sandboxes"
PKG="${WS}/devtools"

BIN=${LV}/.tools   # For binaires to be downloaded and placed
TOOLS=${LV}/.local # For the configure/install prefix when building from source

#-------------------------------------------------------------------------------
# Filesystem
#-------------------------------------------------------------------------------

# Set up the volume mount
sudo chown -R $(whoami): /persist
mkdir -p ${WS}

# Rebuilds will nest a new home skeleton, but we want to keep the existing one
if [ -d "${HOME}/home" ]; then
    rm -rf "${HOME}/home"
fi

# Devcontainers seems to force /workspaces bind mounts in Codespaces, so use
# a symlink to make it work locally and remotely all the same
if [ -d "/workspaces/devtools" ]; then
    ln -sfn /workspaces/devtools /persist/sandboxes/devtools
fi

mkdir -p ${BIN}
mkdir -p ${TOOLS}

# Remove unused default directories
rmdir ${HOME}/{Documents,Music,Pictures,Public,Templates,Videos} 2>/dev/null || true

#-------------------------------------------------------------------------------
# Devtools
#-------------------------------------------------------------------------------

# This *is* the tools repo Codespace, so we don't need to clone it
# cd ${WS} && git clone https://github.com/kbotteon/devtools.git
mkdir -p ${HOME}/.config/devtools
touch ${HOME}/.config/devtools/history

# Default devtools config
echo "
export DTC_CLEAN_HISTORY=1
source ${PKG}/shell/my.sh
" >> ${HOME}/.config/devtools/config

# Source devtools in every shell
echo "# Grab devtools in every shell
source ${PKG}/shell/develop.zsh
" >> ${HOME}/.zshrc

# Make devtools available at ${HOME} for scripts that reference it
ln -s ${WS}/devtools ${HOME}/devtools

#-------------------------------------------------------------------------------
# Git
#-------------------------------------------------------------------------------

echo "
# Include default Git setup
[include]
    path = ${PKG}/git/.gitconfig
" >> ${HOME}/.gitconfig

#-------------------------------------------------------------------------------
# GUI
#-------------------------------------------------------------------------------

# VNC
mkdir -p ${HOME}/.vnc
chmod 755 ${HOME}/.vnc
cp ${PKG}/vnc/xstartup-xfce ${HOME}/.vnc/xstartup

# Browser
curl -o /tmp/firefox.tar.xz https://download-installer.cdn.mozilla.net/pub/firefox/releases/139.0.4/linux-x86_64/en-US/firefox-139.0.4.tar.xz
(
    cd /tmp
    tar -xvf firefox.tar.xz -C ${BIN}
    ln -sf ${BIN}/firefox/firefox ${BIN}/start-firefox
    ln -sf ${BIN}/firefox/firefox ${HOME}/Desktop/start-firefox
)

#-------------------------------------------------------------------------------
# SSH
#-------------------------------------------------------------------------------

mkdir -p ${HOME}/.ssh && chmod 700 ${HOME}/.ssh

# This only works in Codespaces, not local builds
if [[ -n ${GITHUB_USER} ]]; then
    echo "# Access all of your repos by adding a key called {USER}@github.com
    Host github.com
        User git
        IdentityFile ~/.ssh/${GITHUB_USER}@github.com
    " >> ${HOME}/.ssh/config
fi

#-------------------------------------------------------------------------------
# Preferences
#-------------------------------------------------------------------------------

mkdir -p ${HOME}/.config/procps
ln -sf ${PKG}/.config/procps/toprc ${HOME}/.config/procps/toprc
ln -sf ${PKG}/.config/.tmux.conf ${HOME}/.tmux.conf

if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Install plugins defined in .tmux.conf
${HOME}/.tmux/plugins/tpm/bin/install_plugins

#-------------------------------------------------------------------------------
