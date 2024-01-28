#!/usr/bin/env bash

brew update

# Development tools
brew install cmake git git-lfs gcc htop ninja octave rsync verilator

# Cross compilers
# brew install --cask gcc-arm-embedded

# Java
brew install java openjdk@21
sudo ln -sn /usr/local/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
