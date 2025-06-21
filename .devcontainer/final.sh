#!/usr/bin/env bash
################################################################################
# \brief Post-creation setup to run as user specified in Dockerfile
################################################################################

USER=$(whoami)
WS='/sandboxes'
PKG="${WS}/devtools"
TOOLS="${WS}/tools"

################################################################################

# Create symlinks for easy access
mkdir ${WS}/.mounts && ln -s /persist ${PKG}/.mounts/persist

# cd ${TOOLS_DIR} && git clone https://github.com/kbotteon/devtools.git
ln -s ${WS}/devtools ${TOOLS}/devtools

################################################################################

# Migrate home directory to persistent storage
mkdir /persist/home
cp -a /home/${USER}/. /persist/home/
rm -rf /home/${USER}
ln -s /persist/home /home/${USER}

################################################################################

# Set up the default VNC
mkdir -p ${HOME}/.vnc
chmod 755 ${HOME}/.vnc
cp ${TOOLS}/devtools/vnc/xstartup-xfce ${HOME}/.vnc/xstartup

################################################################################

ln -s ${TOOLS}/devtools/shell/develop.sh ${HOME}/develop.ln
touch ${HOME}/.zshrc && echo "source ${HOME}/develop.ln" >> ${HOME}/.zshrc
