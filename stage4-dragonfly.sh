#!/bin/sh

. ./config.sh

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
DST_DIR=${TOP}/stage4-dragonfly
RUST_SRC=${TOP}/stage4-dragonfly/rust
LOCAL_RUST_ROOT=${TOP}/stage3-dragonfly
LLVM_ROOT=${TOP}/stage1-dragonfly/llvm-install

if [ ! -e "stage3-dragonfly/bin/rustc" ]; then
  echo "stage3-dragonfly/bin/rustc does not exist!"
  exit 1
fi

mkdir -p ${DST_DIR}

if [ ! -e ${RUST_SRC} ]; then
  cd ${DST_DIR}
  extract_source_into rust
  patch_source
fi

cd ${RUST_SRC}

#export RUST_BACKTRACE=1

# --enable-rpath ??
./configure --llvm-root=${LLVM_ROOT} --enable-local-rust --local-rust-root=${LOCAL_RUST_ROOT} --prefix=$PREFIX --disable-docs

gmake

gmake dist

#p=`pwd`
#gmake snap-stage3
#echo "To install to $PREFIX: cd $p && gmake install"
