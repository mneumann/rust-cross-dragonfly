if [ `uname -s` != "DragonFly" ]; then
  echo "You have to run this on DragonFly!"
  exit 1
fi

if [ ! -e "stage3-dragonfly/bin/rustc" ]; then
  echo "stage3-dragonfly does not exist!"
  exit 1
fi
mkdir -p stage4-dragonfly

TOP=`pwd`
PREFIX=/usr/local
BRANCH=dragonfly4

if [ ! -e ${TOP}/stage4-dragonfly/rust ]; then
  cd stage4-dragonfly
  git clone --depth 1 --branch ${BRANCH} https://github.com/mneumann/rust.git
  cd rust
  git submodule init
  git submodule update
  cd ${TOP}
fi

cd ${TOP}/stage4-dragonfly/rust

./configure --enable-local-rust --local-rust-root=${TOP}/stage3-dragonfly --prefix=$PREFIX 2>stage4.err >stage4.out
cd src/llvm
patch -p1 < ${TOP}/patch-llvm
cd ../..

gmake 2>>stage4.err >>stage4.out

p=`pwd`

gmake snap-stage3
echo "To install to $PREFIX: cd $p && gmake install"
