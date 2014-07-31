#!/bin/sh

CARGO_VERSION=0.0.1-pre
CARGO_BINS="cargo-build cargo-git-checkout cargo-test cargo-clean cargo-new cargo-run \
  cargo-verify-project cargo-doc cargo-read-manifest cargo-rustc cargo-version"

RUSTC=rustc
BUILD_DIR=`pwd`/cargo-build

gmake -v && GMAKE=gmake
if [ "x${GMAKE}" = "x" ]; then
  GMAKE=make
fi

export RUST_PATH=""

download() {
  cd ${BUILD_DIR}
  if [ ! -e "cargo" ]; then 
    git clone https://github.com/rust-lang/cargo.git
  fi

  if [ ! -e "docopt.rs" ]; then 
    git clone https://github.com/burntsushi/docopt.rs
  fi

  if [ ! -e "toml-rs" ]; then 
    git clone https://github.com/alexcrichton/toml-rs
  fi
}

checkout_revs() {
  cd ${BUILD_DIR}/cargo
  git checkout 59689f0bc2680b5517eab484112ad3cf50702286
  cd ${BUILD_DIR}/docopt.rs
  git checkout 0babd54a
  cd ${BUILD_DIR}/toml-rs
  git checkout a3c7f2c3
}

build_deps() {
  cd ${BUILD_DIR}/toml-rs
  ${GMAKE}
  unset RUST_PATH
  cd ${BUILD_DIR}/docopt.rs
  ${GMAKE}
}

compile_cargo() {
  cd ${BUILD_DIR}/cargo
  mkdir -p target

  export CFG_VERSION="$CARGO_VERSION"
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${BUILD_DIR}/docopt.rs/target"

  ${RUSTC} -L ${BUILD_DIR}/docopt.rs/target -L ${BUILD_DIR}/toml-rs/build \
        ./src/cargo/lib.rs --out-dir=./target

  for bin in cargo $CARGO_BINS; do
     ${RUSTC} -L ${BUILD_DIR}/docopt.rs/target -L ${BUILD_DIR}/toml-rs/build \
        -L ${BUILD_DIR}/cargo/target \
        ./src/bin/${bin}.rs --out-dir=./target
  done
}

mkdir -p ${BUILD_DIR}

if [ "$1" = "install" ]; then
  echo "install"
  prefix="$2"
  if [ "x${prefix}" = "x" ]; then
    prefix=/usr/local
  fi
  echo "prefix: ${prefix}"


  mkdir -p $prefix/bin $prefix/lib/cargo

  echo $prefix/bin/cargo > $prefix/lib/cargo/manifest  
  install -v ${BUILD_DIR}/cargo/target/cargo $prefix/bin/cargo 

  for bin in $CARGO_BINS; do
    install -v ${BUILD_DIR}/cargo/target/$bin $prefix/lib/cargo/$bin
    echo $prefix/lib/cargo/$bin >> $prefix/lib/cargo/manifest  
  done
elif [ "$1" = "compile" ]; then
  echo "compile"
  download
  checkout_revs
  build_deps
  compile_cargo
else
  echo "USAGE: $0 compile | install [prefix=/usr/local]"
fi
