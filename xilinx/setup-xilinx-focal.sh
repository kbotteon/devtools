#!/usr/bin/env bash
################################################################################
# Sets up Ubuntu 20.02 for Vivado/Vitis and PetaLinux
################################################################################

ln -s /usr/bin/make /usr/bin/gmake

dpkg --add-architecture i386

apt-get -y install libtinfo5 libncurses5 libstdc++6:i386 libgtk2.0-0:i386 dpkg-dev:i386

apt-get -y install iproute2 gawk python3 python build-essential gcc git make net-tools libncurses5-dev tftpd zlib1g-dev libssl-dev flex bison libselinux1 gnupg wget git-core diffstat chrpath socat xterm autoconf libtool tar unzip texinfo zlib1g-dev gcc-multilib automake zlib1g:i386 screen pax gzip cpio python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint3
