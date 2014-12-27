BRANCH=dragonfly-fixes2
REPO=https://github.com/mneumann/rust.git

CC=cc
CFLAGS="-m64 -fPIC"
CXX="g++"

if [ `uname -s` = "DragonFly" ]; then
  FETCH="fetch --no-verify-peer"
else
  FETCH=wget
fi

get_and_extract_nightly() {
  ${FETCH} https://static.rust-lang.org/dist/rust-nightly.tar.gz
  tar xvzf rust-nightly.tar.gz
}

patch_source() {
  cd ${RUST_SRC}
  patch -p1 < ${TOP}/patch-thread-local
}
