#!/bin/sh

. ./config.sh

assert_dragonfly

TOP=`pwd`

ROOT=${TOP}/stage1-dragonfly

TARGET_SUB=libs
TARGET=${ROOT}/${TARGET_SUB}
LLVM_TARGET="${ROOT}/llvm-install"
RUST_SRC="${ROOT}/rust"

mkdir -p ${ROOT}
mkdir -p ${TARGET}

echo "-- ROOT: ${ROOT}"
echo "-- TARGET: ${TARGET}"
echo "-- LLVM_TARGET: ${LLVM_TARGET}"
echo "-- RUST_SRC: ${RUST_SRC}"

cd ${ROOT}
extract_source_into rust
#patch_source llvm

cd ${RUST_SRC}/src
mkdir llvm-build
cd llvm-build
../llvm/configure --prefix=${LLVM_TARGET} --enable-pic --enable-optimized
gmake
gmake install

mkdir -p ${TARGET}/llvm
cp `${LLVM_TARGET}/bin/llvm-config --libfiles` ${TARGET}/llvm

cd ${RUST_SRC}/src/rustllvm
${CXX} ${CFLAGS} -c `${LLVM_TARGET}/bin/llvm-config --cxxflags` PassWrapper.cpp
${CXX} ${CFLAGS} -c `${LLVM_TARGET}/bin/llvm-config --cxxflags` RustWrapper.cpp
ar rcs librustllvm.a PassWrapper.o RustWrapper.o	
cp librustllvm.a ${TARGET}

# build libcompiler-rt.a
cd ${RUST_SRC}/src/compiler-rt
cmake -DLLVM_CONFIG_PATH=${LLVM_TARGET}/bin/llvm-config
gmake
cp ./lib/dragonfly/libclang_rt.x86_64.a ${TARGET}/libcompiler-rt.a


cd ${RUST_SRC}/src
ln -s libbacktrace include
cd libbacktrace
./configure --with-pic
gmake
cp .libs/libbacktrace.a ${TARGET}
cd ..
unlink include

cd ${RUST_SRC}/src/rt
${LLVM_TARGET}/bin/llc -enable-pie -relocation-model=pic -filetype=obj -o rust_try.o rust_try.ll
${CC} ${CFLAGS} -c -o record_sp.o arch/x86_64/record_sp.S
ar rcs ${TARGET}/librustrt_native.a rust_try.o record_sp.o

cd ${RUST_SRC}/src/rt
${CC} ${CFLAGS} -c -o rust_builtin.o rust_builtin.c
${CC} ${CFLAGS} -c -o morestack.o arch/x86_64/morestack.S
${CC} ${CFLAGS} -c -o miniz.o miniz.c
ar rcs ${TARGET}/librust_builtin.a rust_builtin.o 
ar rcs ${TARGET}/libmorestack.a morestack.o
ar rcs ${TARGET}/libminiz.a miniz.o 

cd ${RUST_SRC}/src/rt/hoedown
gmake libhoedown.a 
cp libhoedown.a ${TARGET}

cd ${RUST_SRC}/src/jemalloc
./configure --enable-xmalloc --with-jemalloc-prefix=je_ CFLAGS="${CFLAGS}"
#--enable-utrace --enable-debug --enable-ivsalloc
gmake
cp lib/libjemalloc.a ${TARGET}

# Copy Dragonfly system libraries

mkdir -p ${TARGET}/lib
mkdir -p ${TARGET}/usr/lib
cp -r /lib ${TARGET}/lib
cp -r /usr/lib ${TARGET}/usr/lib

# 
cd ${TOP}
python ${RUST_SRC}/src/etc/mklldeps.py stage1-dragonfly/llvmdeps.rs "x86 arm mips ipo bitreader bitwriter linker asmparser mcjit interpreter instrumentation" true "${LLVM_TARGET}/bin/llvm-config"

cd ${TOP}
tar cvzf stage1-dragonfly.tgz stage1-dragonfly/${TARGET_SUB} stage1-dragonfly/llvmdeps.rs stage1-dragonfly/package.md5

echo "Please copy stage1-dragonfly.tgz onto your Linux machine and extract it"
