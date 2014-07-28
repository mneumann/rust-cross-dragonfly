#!/bin/sh

TOP=`pwd`

if [ `uname -s` != "Linux" ]; then
  echo "You have to run this on Linux!"
  exit 1
fi

mkdir -p stage1-linux
cd stage1-linux

git clone https://github.com/mneumann/rust.git
cd rust
git checkout dragonfly
./configure --prefix=${TOP}/stage1-linux/install
make
make install
