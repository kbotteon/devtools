FROM ubuntu:20.04

RUN dpkg --add-architecture i386

RUN \
    apt-get update \
    && apt-get upgrade -y

# Install basic build tools
RUN \
    apt-get update \
    && apt-get upgrade -y \
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

ENV SHELL=/bin/bash
