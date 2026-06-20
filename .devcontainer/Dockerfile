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

RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then \
        dpkg --add-architecture i386 && \
        apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y gcc-multilib; \
    fi

# Force US mirrors
RUN sed -i 's|http://archive.ubuntu.com|http://us.archive.ubuntu.com|g' /etc/apt/sources.list.d/ubuntu.sources

# Install build and development tools
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    autoconf \
    bison \
    build-essential \
    bzip2 \
    ccache \
    clang \
    clang-format \
    cmake \
    curl \
    docker-compose \
    flex \
    gcc \
    gdb \
    git \
    git-lfs \
    gzip \
    help2man \
    libtool \
    less \
    llvm \
    make \
    net-tools \
    netcat-openbsd \
    openssh-server \
    openjdk-21-jdk \
    perl \
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
    ruby \
    ruby-dev \
    wget \
    zsh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Asciidoctor toolchain for rendering course documents
RUN gem install asciidoctor asciidoctor-pdf --no-document

# NVIDIA CUDA compiler
RUN wget -qO /tmp/cuda-keyring.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb \
    && dpkg -i /tmp/cuda-keyring.deb \
    && rm /tmp/cuda-keyring.deb \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        cuda-nvcc-13-2 \
        cuda-cudart-dev-13-2 \
        cuda-profiler-api-13-2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/local/cuda-13.2/bin:${PATH}"

# Add in the graphical stuff
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    dbus-x11 \
    tigervnc-common \
    tigervnc-standalone-server \
    xfce4 \
    xfce4-terminal \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# FPGA tools
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ghdl \
    gtkwave \
    libfl-dev \
    libfl2 \
    libgoogle-perftools-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Build and install Verilator from source
RUN git clone --recursive -b v5.042 https://github.com/verilator/verilator /usr/local/src/verilator \
    && cd /usr/local/src/verilator \
    && autoconf \
    && ./configure --prefix=/usr/local \
    && make -j$(nproc) \
    && make install

# Set up persistent storage for future bind or volume mount, depending on host
RUN mkdir -p /mnt/persist && \
    ln -s /mnt/persist /persist

# 'gh ssh' requires default home location, so symlink it
# Make a non-root user and allow sudo without password
# Also drop default user and grab UID 1000 for SSH
RUN (userdel -r ubuntu 2>/dev/null || true) && \
    useradd -m -d /persist/home -s /bin/zsh -u 1000 $USERNAME && \
    usermod -aG sudo $USERNAME && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    ln -s /persist/home /home/$USERNAME

# Configure sshd on port 50122 and require key auth
RUN sed -i 's/^#*Port .*/Port 50122/' /etc/ssh/sshd_config && \
    sed -i 's/^#*PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    mkdir -p /run/sshd

# These are historically a raging pain to interact with via devcontainer.json,
# so place them inside the container here and invoke elsewhere
COPY --chmod=755 on-create.sh post-create.sh /usr/local/bin/

USER $USERNAME
