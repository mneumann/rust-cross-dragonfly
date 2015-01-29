#!/bin/sh

. ./config.sh
COMMIT=
SHORT_COMMIT=

assert_dragonfly

if [ -e "/usr/local/bin/rustc" ]; then
  echo "Does not work when rustc installed! Please remove rustc:"
  echo "  rm /usr/local/bin/{rustc,rust-gdb,rustdoc}"
  echo "  rm -rf /usr/local/lib/lib*-????????.so"
  echo "  rm -rf /usr/local/lib/rustlib"
  exit 1
fi

TOP=`pwd`
PREFIX=/usr/local
DST_DIR=${TOP}/stage5-dragonfly
RUST_SRC=${TOP}/stage5-dragonfly/rust
LLVM_ROOT=${TOP}/stage1-dragonfly/llvm-install

mkdir -p ${DST_DIR}

if [ ! -e ${RUST_SRC} ]; then
  cd ${DST_DIR}
  extract_source_into rust
  #patch_source_all
fi

cd ${RUST_SRC}

./configure --llvm-root=${LLVM_ROOT} --prefix=$PREFIX --disable-docs

gmake
