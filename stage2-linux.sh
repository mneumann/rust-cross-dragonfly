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

RUST_PREFIX=${TOP}/stage1-linux/install
RUST_SRC=${TOP}/stage2-linux/rust
RUSTC=${RUST_PREFIX}/bin/rustc
TARGET=x86_64-unknown-dragonfly

DF_LIB_DIR=${TOP}/stage1-dragonfly/libs
RS_LIB_DIR=${TOP}/stage2-linux/rust-libs

export LD_LIBRARY_PATH=${RUST_PREFIX}/lib

mkdir -p ${TOP}/stage2-linux
mkdir -p ${TOP}/stage2-linux/rust-libs

if [ ! -e ${TOP}/stage2-linux/rust ]; then
  cd stage2-linux
  git clone --reference ${TOP}/stage1-linux/rust https://github.com/rust-lang/rust.git
  cd ${TOP}
fi

cp ${TOP}/stage1-dragonfly/llvmdeps.rs ${TOP}/stage2-linux/rust/src/librustc_llvm/

# XXX
export CFG_VERSION="0.12.0-pre-nightly"
export CFG_RELEASE="dragonfly-cross"
export CFG_VER_HASH="hash"
export CFG_VER_DATE="`date`"
export CFG_COMPILER_HOST_TRIPLE="x86_64-unknown-dragonfly"
export CFG_PREFIX="/usr/local"

RUST_FLAGS="--cfg jemalloc"

RUST_LIBS="core libc alloc unicode collections rustrt rand sync std native arena rustuv debug log fmt_macros serialize term syntax flate time url uuid getopts regex test coretest glob graphviz num rustc_back semver rustc_llvm rustc fourcc hexfloat regex_macros green rustdoc"

# compile rust libraries
for lib in $RUST_LIBS; do
  if [ -e ${RS_LIB_DIR}/lib${lib}.rlib ]; then
    echo "skipping $lib"
  else
    echo "compiling $lib"
    ${RUSTC} --target ${TARGET} ${RUST_FLAGS} --crate-type lib -L${DF_LIB_DIR} -L${DF_LIB_DIR}/llvm -L${RS_LIB_DIR} ${RUST_SRC}/src/lib${lib}/lib.rs -o ${RS_LIB_DIR}/lib${lib}.rlib
  fi
done

${RUSTC} ${RUST_FLAGS} --emit obj -o ${TOP}/stage2-linux/driver.o --target ${TARGET} -L${DF_LIB_DIR} -L${RS_LIB_DIR} --cfg rustc ${RUST_SRC}/src/driver/driver.rs

tar cvzf ${TOP}/stage2-linux.tgz stage2-linux/*.o stage2-linux/rust-libs
