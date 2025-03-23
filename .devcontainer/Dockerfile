FROM ubuntu:24.04

ARG USERNAME=developer

RUN dpkg --add-architecture i386

# Install basic build tools
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    clang \
    cmake \
    gdb \
    make \
    python3 \
    python3-dev \
    python3-pip \
    screen \
    sudo \
    unzip \
    vim \
    zsh

# Add in the graphical stuff
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    dbus-x11 \
    tigervnc-common \
    tigervnc-standalone-server \
    xfce4 \
    xfce4-terminal

# Make a non-root user, but allow sudo
# The devcontainer.json takes care of this
RUN useradd -m -s /bin/bash $USERNAME
RUN usermod -aG sudo $USERNAME

# Allow sudo without a password
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Keep bash history between sessions
RUN CMDLINE="export PROMPT_COMMAND='history -a' && export HISTFILE=/persist/.bash_history" \
    && mkdir /persist \
    && touch /persist/.bash_history \
    && chown -R $USERNAME /persist \
    && echo "$CMDLINE" >> "/home/$USERNAME/.bashrc"

USER $USERNAME
WORKDIR /home/$USERNAME
ENV SHELL=/bin/bash
