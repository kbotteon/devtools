FROM ubuntu:24.04

ARG USERNAME=developer

RUN dpkg --add-architecture i386

# Install build and development tools
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    bzip2 \
    clang \
    clang-format \
    cmake \
    gcc \
    gcc-multilib \
    gdb \
    git \
    git-lfs \
    gzip \
    libtool \
    less \
    libtools \
    llvm \
    make \
    net-tools \
    netcat-openbsd \
    openjdk-21-jdk \
    pkg-config \
    portmap \
    python3 \
    python3-dev \
    python3-pip \
    rsync \
    screen \
    socat \
    strace \
    sudo \
    tcpdump \
    tmux \
    unzip \
    valgrind \
    vim \
    wget \
    zsh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Add in the graphical stuff
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    dbus-x11 \
    tigervnc-common \
    tigervnc-standalone-server \
    xfce4 \
    xfce4-terminal \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Make a non-root user and allow sudo without password
RUN useradd -m -d /persist/home -s /bin/zsh $USERNAME && \
    usermod -aG sudo $USERNAME && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER $USERNAME
