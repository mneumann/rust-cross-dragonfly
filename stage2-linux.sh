#!/bin/sh

. ./config.sh

assert_linux

TOP=`pwd`

ROOT=${TOP}/stage2-linux
RUST_SRC=${ROOT}/rust
RUST_PREFIX=${ROOT}/install
RUSTC=${RUST_PREFIX}/bin/rustc

if [ ! -e "stage1-dragonfly" ]; then
  if [ -e "stage1-dragonfly.tgz" ]; then
    tar xvzf stage1-dragonfly.tgz
  fi
fi

if [ ! -e "stage1-dragonfly/libs" ]; then
  echo "need stage1-dragonfly/libs!"
  exit 1
fi

mkdir -p ${ROOT}

if [ ! -e ${RUST_SRC} ]; then
  cd ${ROOT}
  extract_source_into rust
fi

if [ ! -e "${RUSTC}" ]; then
  echo "${RUSTC} does not exist! Generating..."

  cd ${ROOT}
  extract_source_into rust
  cd rust
  ./configure --prefix=${ROOT}/install --disable-docs
  patch_source
  cd ${RUST_SRC}

  make || exit 1
  make install || exit 1
fi

TARGET=x86_64-unknown-dragonfly
RUSTC_FLAGS="--target ${TARGET}"
DF_LIB_DIR=${TOP}/stage1-dragonfly/libs
RS_LIB_DIR=${ROOT}/rust-libs

export LD_LIBRARY_PATH=${RUST_PREFIX}/lib

mkdir -p ${RS_LIB_DIR}


# XXX
export CFG_VERSION="0.13.0-pre-nightly"
export CFG_RELEASE="dragonfly-cross"
export CFG_VER_HASH="hash"
export CFG_VER_DATE="`date`"
export CFG_COMPILER_HOST_TRIPLE="x86_64-unknown-dragonfly"
export CFG_PREFIX="/usr/local"

RUST_FLAGS="--cfg jemalloc"

export CFG_LLVM_LINKAGE_FILE=${TOP}/stage1-dragonfly/llvmdeps.rs

# compile rust libraries
for lib in $RUST_CRATES; do
  if [ -e ${RS_LIB_DIR}/lib${lib}.rlib ]; then
    echo "skipping $lib"
  else
    echo "compiling $lib"
    ${RUSTC} ${RUSTC_FLAGS} --crate-type lib -L${DF_LIB_DIR} -L${DF_LIB_DIR}/llvm -L${RS_LIB_DIR} ${RUST_SRC}/src/lib${lib}/lib.rs -o ${RS_LIB_DIR}/lib${lib}.rlib
  fi
done

${RUSTC} ${RUSTC_FLAGS} --emit obj -o ${ROOT}/driver.o -L${DF_LIB_DIR} -L${RS_LIB_DIR} --cfg rustc ${RUST_SRC}/src/driver/driver.rs

cd ${TOP}
tar cvzf ${TOP}/stage2-linux.tgz stage2-linux/driver.o stage2-linux/rust-libs

echo "Please copy stage2-linux.tgz onto your DragonFly machine and extract it"
