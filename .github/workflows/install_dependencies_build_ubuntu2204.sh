#!/usr/bin/env bash

# The package list is designed for Ubuntu 22.04 LTS
add-apt-repository -y ppa:ubuntu-toolchain-r/test
apt-get update
apt-get install -y \
    autoconf \
    automake \
    bison \
    ccache \
    cmake \
    exuberant-ctags \
    curl \
    doxygen \
    flex \
    fontconfig \
    gdb \
    git \
    gperf \
    iverilog \
    libc6-dev \
    libcairo2-dev \
    libevent-dev \
    libffi-dev \
    libfontconfig1-dev \
    liblist-moreutils-perl \
    libncurses5-dev \
    libreadline-dev \
    libreadline8 \
    libx11-dev \
    libxft-dev \
    libxml++2.6-dev \
    make \
    perl \
    pkg-config \
    python3 \
    python3-setuptools \
    python3-lxml \
    python3-pip \
    qtbase5-dev \
    tcllib \
    tcl8.6-dev \
    texinfo \
    time \
    valgrind \
    wget \
    zip \
    swig \
    expect \
    g++-9 \
    gcc-9 \
    g++-10 \
    gcc-10 \
    g++-11 \
    gcc-11 \
    clang-12 \
    clang-format-12 \
    libxml2-utils
