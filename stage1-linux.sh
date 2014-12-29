#!/bin/sh

. ./config.sh

assert_linux

mkdir -p stage1-linux
cd stage1-linux

TOP=`pwd`

get_and_extract_nightly
#git clone --depth 1 --branch ${BRANCH} ${REPO}
cd rust-nightly
./configure --prefix=${TOP}/install
cd src/llvm
patch -p1 < ${TOP}/../patch-llvm
cd ../..

make
make install
