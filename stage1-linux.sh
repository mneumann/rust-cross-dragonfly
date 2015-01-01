#!/bin/sh

. ./config.sh

assert_linux

TOP=`pwd`

ROOT=${TOP}/stage1-linux

mkdir -p ${ROOT}

cd ${ROOT}
extract_source_into rust
cd rust
./configure --prefix=${ROOT}/install
cd src/llvm
patch -p1 < ${TOP}/patch-llvm
cd ../..

make
make install
