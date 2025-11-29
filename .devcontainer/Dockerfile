FROM ubuntu:24.04

ARG USERNAME=developer

RUN dpkg --add-architecture i386

# Use a local apt proxy, if it exists
ARG APT_PROXY=""
RUN if [ -n "$APT_PROXY" ]; then \
      PROXY_HOST=$(echo "$APT_PROXY" | sed -E 's|https?://([^:/]+).*|\1|'); \
      PROXY_PORT=$(echo "$APT_PROXY" | sed -E 's|.*:([0-9]+).*|\1|'); \
      if timeout 2 bash -c "</dev/tcp/${PROXY_HOST}/${PROXY_PORT}" 2>/dev/null; then \
        echo "Acquire::http::Proxy \"$APT_PROXY\";" > /etc/apt/apt.conf.d/01proxy && \
        echo 'Acquire::http::Pipeline-Depth "4";' >> /etc/apt/apt.conf.d/01proxy && \
        echo 'APT::Acquire::Retries "3";' >> /etc/apt/apt.conf.d/01proxy; \
      fi; \
    fi

# Force US mirrors
RUN sed -i 's|http://archive.ubuntu.com|http://us.archive.ubuntu.com|g' /etc/apt/sources.list.d/ubuntu.sources

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
