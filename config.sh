BRANCH=dragonfly-fixes2
REPO=https://github.com/mneumann/rust.git

CC=cc
CFLAGS="-m64 -fPIC"
CXX="g++"

# List of all crates to compile (order is important)
RUST_CRATES="core libc alloc unicode collections rand std arena regex log fmt_macros serialize term syntax flate"
RUST_CRATES="${RUST_CRATES} time getopts test coretest graphviz rustc_back rustc_llvm rbml rustc rustc_borrowck"
RUST_CRATES="${RUST_CRATES} rustc_typeck rustc_trans regex_macros rustc_resolve rustc_driver rustdoc"

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
