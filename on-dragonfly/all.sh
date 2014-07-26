TOP=`pwd`

CC=g++
LLVM_INCLUDE=$TOP/target/usr/local/llvm34/include
CFLAGS="-std=c++11 -D__STDC_LIMIT_MACROS -D__STDC_CONSTANT_MACROS -I$(LLVM_INCLUDE)"

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
../llvm/configure --prefix=$TOP/target
make
make install

cd ..
cd rustllvm

${CC} ${CFLAGS} -c PassWrapper.cpp
${CC} ${CFLAGS} -c RustWrapper.cpp
ar rcs rustllvm.a PassWrapper.o RustWrapper.o	
cp rustllvm.a $TOP/target
