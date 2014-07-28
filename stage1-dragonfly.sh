#!/bin/sh

if [ `uname -s` != "DragonFly" ]; then
  echo "You have to run this on DragonFly!"
  exit 1
fi

mkdir -p stage1-dragonfly
cd stage1-dragonfly

TOP=`pwd`

TARGET_SUB=libs
TARGET=${TOP}/${TARGET_SUB}

CC=cc
CXX="g++"
LLVM_TARGET="${TOP}/llvm-install"

mkdir -p ${TARGET}

echo "-- TOP: ${TOP}"
echo "-- TARGET: ${TARGET}"
echo "-- LLVM_TARGET: ${LLVM_TARGET}"

###
# "git submodule" does not work on DragonFly as it does not 
# find perl in /usr/bin/perl. To make it work:
#
#     ln -s /usr/local/bin/perl /usr/bin/perl
##

git clone https://github.com/mneumann/rust.git
cd rust
git checkout dragonfly
git submodule init
git submodule update  
cd src/llvm
patch -p1 < ../../patch-llvm
cd ..
mkdir llvm-build
cd llvm-build
../llvm/configure --prefix=${LLVM_TARGET}
gmake ENABLE_OPTIMIZED=1
gmake ENABLE_OPTIMIZED=1 install

mkdir -p ${TARGET}/llvm
cp `${LLVM_TARGET}/bin/llvm-config --libfiles` ${TARGET}/llvm

cd ${TOP}/rust/src/rustllvm
${CXX} -c `${LLVM_TARGET}/bin/llvm-config --cxxflags` PassWrapper.cpp
${CXX} -c `${LLVM_TARGET}/bin/llvm-config --cxxflags` RustWrapper.cpp
ar rcs librustllvm.a PassWrapper.o RustWrapper.o	
cp librustllvm.a ${TARGET}

# build libcompiler-rt.a
cd ${TOP}/rust/src/compiler-rt
cmake -DLLVM_CONFIG_PATH=${LLVM_TARGET}/bin/llvm-config
make
cp ./lib/dragonfly/libclang_rt.x86_64.a ${TARGET}/libcompiler-rt.a


cd ${TOP}/rust/src
ln -s libbacktrace include
cd libbacktrace
./configure
make
cp .libs/libbacktrace.a ${TARGET}
cd ..
unlink include

# Or use "pkg ins libuv"
cd ${TOP}/rust/src/libuv
sh autogen.sh
./configure
make
cp .libs/libuv.a ${TARGET}

cd ${TOP}/rust/src/rt
${LLVM_TARGET}/bin/llc rust_try.ll
${CC} -c -o rust_try.o rust_try.s
${CC} -c -o record_sp.o arch/x86_64/record_sp.S
ar rcs ${TARGET}/librustrt_native.a rust_try.o record_sp.o

cd ${TOP}/rust/src/rt
${CC} -c -o context.o arch/x86_64/_context.S
ar rcs ${TARGET}/libcontext_switch.a context.o

cd ${TOP}/rust/src/rt
${CC} -c -o rust_builtin.o rust_builtin.c
ar rcs ${TARGET}/librust_builtin.a rust_builtin.o 

cd ${TOP}/rust/src/rt
${CC} -c -o morestack.o arch/x86_64/morestack.S
ar rcs ${TARGET}/libmorestack.a morestack.o

cd ${TOP}/rust/src/rt
${CC} -c -o miniz.o miniz.c
ar rcs ${TARGET}/libminiz.a miniz.o 

cd ${TOP}/rust/src/rt
${CC} -c -I../libuv/include -o rust_uv.o rust_uv.c
ar rcs ${TARGET}/libuv_support.a rust_uv.o 

cd ${TOP}/rust/src/rt/hoedown
gmake libhoedown.a 
cp libhoedown.a ${TARGET}

# Copy Dragonfly system libraries

mkdir -p ${TARGET}/lib
mkdir -p ${TARGET}/usr/lib
cp -r /lib ${TARGET}/lib
cp -r /usr/lib ${TARGET}/usr/lib

cd ${TOP}/..
tar cvzf stage1-dragonfly.tgz stage1-dragonfly/${TARGET_SUB}

echo "Please copy stage1-dragonfly.tgz onto your Linux machine and extract it"
