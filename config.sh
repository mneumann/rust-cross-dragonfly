BRANCH=master
REPO=https://github.com/rust-lang/rust.git
USE_GIT=YES

CC=cc
CFLAGS="-m64 -fPIC"
CXX="g++"

assert_dragonfly() {
  if [ `uname -s` != "DragonFly" ]; then
    echo "You have to run this on DragonFly!"
    exit 1
  fi
}

assert_linux() {
  if [ `uname -s` != "Linux" ]; then
    echo "You have to run this on Linux!"
    exit 1
  fi
}

# List of all crates to compile (order is important)
RUST_CRATES="core libc alloc unicode collections rand std arena regex log fmt_macros serialize term syntax flate"
RUST_CRATES="${RUST_CRATES} time getopts test coretest graphviz rustc_back rustc_llvm rbml rustc rustc_borrowck"
RUST_CRATES="${RUST_CRATES} rustc_typeck rustc_trans regex_macros rustc_resolve rustc_driver rustdoc"

if [ `uname -s` = "DragonFly" ]; then
  FETCH="fetch --no-verify-peer"
else
  FETCH=wget
fi

extract_source_into() {
  if [ "${USE_GIT}" = "YES" ]; then
    git clone --depth 1 --branch ${BRANCH} --recursive ${REPO} $1
  else
    ${FETCH} https://static.rust-lang.org/dist/rust-nightly.tar.gz
    tar xvzf rust-nightly.tar.gz
    if [ "$1" != "rust-nightly" ]; then
      mv rust-nightly $1
    fi
  fi
}

patch_source() {
  cd ${RUST_SRC}
  patch -p1 < ${TOP}/patch-thread-local
}
