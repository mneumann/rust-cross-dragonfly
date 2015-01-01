#!/bin/sh

. ./config.sh

assert_dragonfly

if [ ! -e "stage1-dragonfly/libs" ]; then
  echo "stage1-dragonfly does not exist!"
  exit 1
fi

if [ ! -e "stage2-linux/rust-libs" ]; then
  echo "stage2-linux does not exist!"
  exit 1
fi

RL=stage2-linux/rust-libs

SUP_LIBS="-Wl,-whole-archive -lmorestack -Wl,-no-whole-archive -lrust_builtin -lrustllvm -lcompiler-rt -lbacktrace -lhoedown -lminiz -lrustrt_native"

LLVM_LIBS=""
for lib in $LLVM_LIBRARIES; do
  LLVM_LIBS="${LLVM_LIBS} -lLLVM${lib}"
done

RUST_DEPS=""
for lib in $RUST_CRATES; do
  RUST_DEPS="${RL}/lib${lib}.rlib ${RUST_DEPS}"
done

TARGET=x86_64-unknown-dragonfly
DST_DIR=stage3-dragonfly
DST_LIB=${DST_DIR}/lib/rustlib/${TARGET}/lib

mkdir -p ${DST_DIR}/bin
mkdir -p ${DST_LIB}

${CC} ${CFLAGS} -o ${DST_DIR}/bin/rustc stage2-linux/driver.o ${RUST_DEPS} -L./stage1-dragonfly/libs/llvm -L./stage1-dragonfly/libs $SUP_LIBS $LLVM_LIBS -lrt -lpthread -lgcc_pic -lc -lm -lz -ledit -ltinfo -lstdc++

echo "rustc done"

cp stage1-dragonfly/libs/libcompiler-rt.a ${DST_LIB}
cp stage1-dragonfly/libs/libmorestack.a ${DST_LIB}
cp stage2-linux/rust-libs/*.rlib ${DST_LIB}

./${DST_DIR}/bin/rustc -L${DST_LIB} hw.rs && ./hw
