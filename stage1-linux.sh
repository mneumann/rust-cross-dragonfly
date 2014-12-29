#!/bin/sh

. ./config.sh

assert_linux

TOP=`pwd`

ROOT=${TOP}/stage1-linux

mkdir -p ${ROOT}

cd ${ROOT}
get_and_extract_nightly
cd rust-nightly
./configure --prefix=${ROOT}/install
cd src/llvm
patch -p1 < ${TOP}/patch-llvm
cd ../..

make
make install
