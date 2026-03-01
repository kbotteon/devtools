FROM ubuntu:24.04

ARG USERNAME=developer
ARG APT_PROXY=""

# Use a local apt proxy, if it exists
RUN if [ -n "$APT_PROXY" ]; then \
      PROXY_HOST=$(echo "$APT_PROXY" | sed -E 's|https?://([^:/]+).*|\1|'); \
      PROXY_PORT=$(echo "$APT_PROXY" | sed -E 's|.*:([0-9]+).*|\1|'); \
      if timeout 2 bash -c "</dev/tcp/${PROXY_HOST}/${PROXY_PORT}" 2>/dev/null; then \
        echo "Acquire::http::Proxy \"$APT_PROXY\";" > /etc/apt/apt.conf.d/01proxy && \
        echo 'Acquire::http::Pipeline-Depth "4";' >> /etc/apt/apt.conf.d/01proxy && \
        echo 'APT::Acquire::Retries "3";' >> /etc/apt/apt.conf.d/01proxy; \
      fi; \
    fi

RUN dpkg --add-architecture i386

# Force US mirrors
RUN sed -i 's|http://archive.ubuntu.com|http://us.archive.ubuntu.com|g' /etc/apt/sources.list.d/ubuntu.sources

# Install build and development tools
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    bzip2 \
    clang \
    clang-format \
    cmake \
    curl \
    docker-compose \
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
    python3-venv \
    python3-pip \
    pv \
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
# /persist is a volume mount provided by devcontainer.json
RUN useradd -m -d /persist/home -s /bin/zsh $USERNAME && \
    usermod -aG sudo $USERNAME && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# These are historically a raging pain to interact with via devcontainer.json,
# so place them inside the container here and invoke elsewhere
COPY --chmod=755 on-create.sh post-create.sh /usr/local/bin/

USER $USERNAME
