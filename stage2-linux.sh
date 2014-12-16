#!/bin/sh

if [ `uname -s` != "Linux" ]; then
  echo "You have to run this on Linux!"
  exit 1
fi

if [ ! -e "stage1-linux" ]; then
  echo "stage1-linux does not exist!"
  exit 1
fi

if [ ! -e "stage1-linux/install" ]; then
  echo "stage1-linux/install does not exist!"
  exit 1
fi

if [ ! -e "stage1-dragonfly/libs" ]; then
  echo "need stage1-dragonfly/libs!"
  exit 1
fi

TOP=`pwd`

TARGET=x86_64-unknown-dragonfly
RUST_PREFIX=${TOP}/stage1-linux/install
RUST_SRC=${TOP}/stage2-linux/rust
RUSTC=${RUST_PREFIX}/bin/rustc
RUSTC_FLAGS="--target ${TARGET}"

BRANCH=dragonfly4

DF_LIB_DIR=${TOP}/stage1-dragonfly/libs
RS_LIB_DIR=${TOP}/stage2-linux/rust-libs

export LD_LIBRARY_PATH=${RUST_PREFIX}/lib

mkdir -p ${TOP}/stage2-linux
mkdir -p ${TOP}/stage2-linux/rust-libs

if [ ! -e ${TOP}/stage2-linux/rust ]; then
  cd stage2-linux
  git clone --depth 1 --branch ${BRANCH} https://github.com/mneumann/rust.git
  cd ${TOP}
fi

# XXX
export CFG_VERSION="0.13.0-pre-nightly"
export CFG_RELEASE="dragonfly-cross"
export CFG_VER_HASH="hash"
export CFG_VER_DATE="`date`"
export CFG_COMPILER_HOST_TRIPLE="x86_64-unknown-dragonfly"
export CFG_PREFIX="/usr/local"

RUST_FLAGS="--cfg jemalloc"

export CFG_LLVM_LINKAGE_FILE=${TOP}/stage1-dragonfly/llvmdeps.rs

RUST_LIBS="core libc alloc unicode collections rustrt rand std arena regex log fmt_macros serialize term syntax flate time getopts test coretest graphviz rustc_back rustc_llvm rbml rustc rustc_borrowck rustc_typeck rustc_trans regex_macros rustc_driver rustdoc"

# compile rust libraries
for lib in $RUST_LIBS; do
  if [ -e ${RS_LIB_DIR}/lib${lib}.rlib ]; then
    echo "skipping $lib"
  else
    echo "compiling $lib"
    ${RUSTC} ${RUSTC_FLAGS} --crate-type lib -L${DF_LIB_DIR} -L${DF_LIB_DIR}/llvm -L${RS_LIB_DIR} ${RUST_SRC}/src/lib${lib}/lib.rs -o ${RS_LIB_DIR}/lib${lib}.rlib
  fi
done

${RUSTC} ${RUSTC_FLAGS} --emit obj -o ${TOP}/stage2-linux/driver.o -L${DF_LIB_DIR} -L${RS_LIB_DIR} --cfg rustc ${RUST_SRC}/src/driver/driver.rs

tar cvzf ${TOP}/stage2-linux.tgz stage2-linux/*.o stage2-linux/rust-libs
