#!/bin/sh

TOP=`pwd`
TARGET=${TOP}/target

CC="g++"
LLVM_INCLUDE="${TOP}/target/usr/local/llvm34/include"
CFLAGS="-std=c++11 -D__STDC_LIMIT_MACROS -D__STDC_CONSTANT_MACROS -I${LLVM_INCLUDE}"

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
../llvm/configure --prefix=${TARGET}
gmake ENABLE_OPTIMIZED=1
gmake install

cd ${TOP}/rust/src/rustllvm
${CC} ${CFLAGS} -c PassWrapper.cpp
${CC} ${CFLAGS} -c RustWrapper.cpp
ar rcs rustllvm.a PassWrapper.o RustWrapper.o	
cp rustllvm.a ${TARGET}

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

# Copy Dragonfly system libraries

for i in m c kvm dl rt pthread ncurses z; do
  cp /usr/lib/lib${i}.a ${TARGET}
done

cp /usr/lib/gcc47/*.o ${TARGET}
for i in gcc gcc_eh gcc_pic ssp stdc++ supc++; do
  cp /usr/lib/gcc47/lib${i}.a ${TARGET}
done
