FROM ubuntu:20.04

ARG USERNAME=developer

RUN dpkg --add-architecture i386

# Install basic build tools
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        sudo \
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
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        tigervnc-common \
        tigervnc-standalone-server \
        xfce4 \
        xfce4-terminal \
        dbus-x11

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
