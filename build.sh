#!/bin/sh

echo "Requirements: gmake, python"

SNAPSHOT_FILE=rust-stage0-2015-01-20-9006c3c-dragonfly-x86_64-0bb1d3eedbcd0b36ab01e4ac0539fb8a393c348d.tar.bz2

download() {
  fetch https://raw.githubusercontent.com/mneumann/rust-cross-dragonfly/master/patches/patch-libstd-os
  fetch https://static.rust-lang.org/dist/rustc-nightly-src.tar.gz
  fetch http://www.ntecs.de/downloads/rust/${SNAPSHOT_FILE}
}

mkdir build
cd build
download

tar xvzf rustc-nightly-src.tar.gz
cd rustc-nightly
patch -p1 < ../patch-libstd-os
export SNAPSHOT_FILE="../${SNAPSHOT_FILE}"
./configure
gmake

echo "cd build/rustc-nightly && sudo gmake install"
