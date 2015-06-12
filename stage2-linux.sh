#!/bin/sh

. ./config.sh

assert_linux

TOP=`pwd`

ROOT=${TOP}/stage2-linux
RUST_SRC=${ROOT}/rust

if [ "$USE_LOCAL_RUST" = "YES" ]; then
  RUST_PREFIX=/usr/local
else
  RUST_PREFIX=${ROOT}/install
fi

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
  patch_source libstd-os-dragonfly
fi

if [ "$USE_LOCAL_RUST" != "YES" ]; then
  cd ${ROOT}/rust
  patch_source libstd-os-dragonfly
  ./configure --prefix=${RUST_PREFIX} --disable-docs
  cd ${RUST_SRC}
  make || exit 1
  make install || exit 1
fi

if [ "$USE_GIT" != "YES" ]; then
  cd $ROOT
  MD5_DF=`cat ${TOP}/stage1-dragonfly/package.md5`
  MD5=`gen_md5 ${PACKAGE}`
  if [ "${MD5_DF}" != "${MD5}" ]; then
    echo "invalid md5 sum"
    exit 1
  fi
fi

TARGET=x86_64-unknown-dragonfly
RUSTC_FLAGS="--target ${TARGET}"
RUSTC_FLAGS="${RUSTC_FLAGS} --cfg stage1"
DF_LIB_DIR=${TOP}/stage1-dragonfly/libs
RS_LIB_DIR=${ROOT}/rust-libs

export LD_LIBRARY_PATH=${RUST_PREFIX}/lib

mkdir -p ${RS_LIB_DIR}

export CFG_RELEASE="${RELEASE_TAG}"
export CFG_VER_HASH="${COMMIT}"
export CFG_SHORT_VER_HASH="${SHORT_COMMIT}"
export CFG_VER_DATE="`date '+%F %T %z'`"
export CFG_VERSION="${CFG_RELEASE} (${CFG_SHORT_VER_HASH} ${CFG_VER_DATE})"

export CFG_COMPILER_HOST_TRIPLE="x86_64-unknown-dragonfly"
export CFG_PREFIX="/usr/local"


export CFG_LLVM_LINKAGE_FILE=${TOP}/stage1-dragonfly/llvmdeps.rs

# compile rust libraries
for lib in $RUST_CRATES; do
  if [ -e ${RS_LIB_DIR}/lib${lib}.rlib ]; then
    echo "skipping $lib"
  else
    echo "compiling $lib"
    ${RUSTC} ${RUSTC_FLAGS} --crate-type lib -L${DF_LIB_DIR} -L${DF_LIB_DIR}/llvm -L${RS_LIB_DIR} ${RUST_SRC}/src/lib${lib}/lib.rs -o ${RS_LIB_DIR}/lib${lib}.rlib || exit 1
  fi
done

${RUSTC} ${RUSTC_FLAGS} --emit obj -o ${ROOT}/driver.o -L${DF_LIB_DIR} -L${RS_LIB_DIR} --cfg rustc ${RUST_SRC}/src/driver/driver.rs

cd ${TOP}
tar cvzf ${TOP}/stage2-linux.tgz stage2-linux/driver.o stage2-linux/rust-libs

echo "Please copy stage2-linux.tgz onto your DragonFly machine and extract it"
