FROM ubuntu:20.04

RUN \
    dpkg --add-architecture i386

# Install basic build tools
RUN \
    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        make \
        unzip \
        screen \
        python3 \
        python3-pip \
        build-essential \
        cmake \
        clang \
        gdb \
        python3-dev

# Add in the graphical stuff
RUN \
    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        tigervnc-common \
        tigervnc-standalone-server \
        xfce4 \
        xfce4-terminal \
        dbus-x11

ENV SHELL=/bin/bash
