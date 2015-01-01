#!/bin/sh

. ./config.sh

assert_dragonfly

TOP=`pwd`
PREFIX=/usr/local
DST_DIR=${TOP}/stage4-dragonfly
RUST_SRC=${TOP}/stage4-dragonfly/rust
LOCAL_RUST_ROOT=${TOP}/stage4-dragonfly/local
LLVM_ROOT=${TOP}/stage1-dragonfly/llvm-install

if [ ! -e "stage3-dragonfly/bin/rustc" ]; then
  echo "stage3-dragonfly/bin/rustc does not exist!"
  exit 1
fi

mkdir -p ${DST_DIR}
mkdir -p ${LOCAL_RUST_ROOT}/bin
cp ${TOP}/stage3-dragonfly/bin/rustc ${LOCAL_RUST_ROOT}/bin/exe
echo "#!/usr/bin/env ruby" > ${LOCAL_RUST_ROOT}/bin/rustc
echo "system('${DST_DIR}/local/bin/exe', *ARGV)" >> ${LOCAL_RUST_ROOT}/bin/rustc
echo "p ARGV; exit 0" >> ${LOCAL_RUST_ROOT}/bin/rustc
#echo "${DST_DIR}/local/bin/exe \$*; exit 0" > ${LOCAL_RUST_ROOT}/bin/rustc
cat ${LOCAL_RUST_ROOT}/bin/rustc
chmod +x ${LOCAL_RUST_ROOT}/bin/rustc
mkdir -p ${LOCAL_RUST_ROOT}/lib
cp -r ${TOP}/stage3-dragonfly/lib/rustlib ${LOCAL_RUST_ROOT}/lib

if [ ! -e ${RUST_SRC} ]; then
  cd ${DST_DIR}
  extract_source_into rust #${TOP}/stage1-dragonfly/rust
  patch_source
fi

cd ${RUST_SRC}

export RUST_BACKTRACE=1

./configure --llvm-root=${LLVM_ROOT} --enable-local-rust --local-rust-root=${LOCAL_RUST_ROOT} --prefix=$PREFIX --disable-docs 2>stage4.err >stage4.out

gmake 2>>stage4.err >>stage4.out

p=`pwd`

gmake snap-stage3
echo "To install to $PREFIX: cd $p && gmake install"
