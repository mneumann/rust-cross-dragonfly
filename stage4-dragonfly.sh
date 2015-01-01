#!/bin/sh

. ./config.sh

assert_dragonfly

TOP=`pwd`
LOCAL_RUST_ROOT=${TOP}/stage3-dragonfly
PREFIX=/usr/local
DST_DIR=${TOP}/stage4-dragonfly

if [ ! -e "${LOCAL_RUST_ROOT}/bin/rustc" ]; then
  echo "Local rust compiler does not exist!"
  exit 1
fi

mkdir -p ${DST_DIR}

if [ ! -e ${DST_DIR}/rust ]; then
  cd ${DST_DIR}
  git clone --depth 1 --branch ${BRANCH} ${REPO}
  cd rust
  git submodule init
  git submodule update
  cd ${TOP}
fi

cd ${DST_DIR}/rust

./configure --enable-local-rust --local-rust-root=${LOCAL_RUST_ROOT} --prefix=$PREFIX 2>stage4.err >stage4.out
cd src/llvm
patch -p1 < ${TOP}/patch-llvm
cd ../..

gmake 2>>stage4.err >>stage4.out

p=`pwd`

gmake snap-stage3
echo "To install to $PREFIX: cd $p && gmake install"
