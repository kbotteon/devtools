# Devtools sets up a pretty well-featured baseline environment
FROM ghcr.io/kbotteon/devtools/base:latest
USER root

# Set up FPGA tool dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    autoconf \
    bison \
    ccache \
    dpkg-dev:i386 \
    flex \
    ghdl \
    gtkwave \
    help2man \
    libfl-dev \
    libfl2 \
    libgl1-mesa-dev \
    libgl1-mesa-dri \
    libgoogle-perftools-dev \
    libgtk2.0-0:i386 \
    libncurses6 \
    libstdc++6:i386 \
    libtinfo6 \
    numactl \
    perl \
    perl-doc \
    zlib1g \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Build and install Verilator from source
RUN git clone --recursive -b v5.042 https://github.com/verilator/verilator /usr/local/src/verilator \
    && cd /usr/local/src/verilator \
    && autoconf \
    && ./configure --prefix=/usr/local \
    && make -j$(nproc) \
    && make install

USER developer
