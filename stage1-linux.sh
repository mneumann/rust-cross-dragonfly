#!/bin/sh

. ./config.sh

if [ `uname -s` != "Linux" ]; then
  echo "You have to run this on Linux!"
  exit 1
fi

mkdir -p stage1-linux
cd stage1-linux

TOP=`pwd`

git clone --depth 1 --branch ${BRANCH} ${REPO}
cd rust
./configure --prefix=${TOP}/install
cd src/llvm
patch -p1 < ${TOP}/../patch-llvm
cd ../..

make
make install
