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

if [ ! -e ${TOP}/stage4-dragonfly/rust ]; then
  cd stage4-dragonfly
  if [ -e ${TOP}/stage1-dragonfly/rust ]; then
    git clone --reference ${TOP}/stage1-dragonfly/rust https://github.com/rust-lang/rust.git
  else
    git clone https://github.com/rust-lang/rust.git
  fi
  cd ${TOP}
fi

cd ${TOP}/stage4-dragonfly/rust
./configure --enable-local-rust --local-rust-root=${TOP}/stage3-dragonfly --prefix=/usr/local
cd src/llvm
patch -p1 < ${TOP}/patch-llvm
cd ../jemalloc
patch -p1 < ${TOP}/patch-jemalloc
cd ../..

gmake

p=`pwd`

echo "To install to /usr/local: cd $p && gmake install"
