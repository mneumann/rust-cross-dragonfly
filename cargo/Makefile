RUSTC=/usr/local/bin/rustc
CC=cc
AR=ar

WRKDIR=cargo/bootstrap
DSTDIR=${HOME}/cargo/install
TARGET=${HOME}/cargo/target

CARGOLIB=${TARGET}/cargo-boostrap/lib
GH=https://github.com

all: mkdirs \
	${DSTDIR}/lib/libgit2.so \
	${CARGOLIB}/libsemver.rlib \
	${CARGOLIB}/libdocopt.rlib \
	${CARGOLIB}/libgcc.rlib \
	${CARGOLIB}/libminiz-sys.rlib \
	${CARGOLIB}/libflate2.rlib \
	${CARGOLIB}/libglob.rlib \
	${CARGOLIB}/liblibz-sys.rlib \
	${CARGOLIB}/libopenssl-sys.rlib \
	${CARGOLIB}/libopenssl.rlib \
	${CARGOLIB}/liburl.rlib \
	${CARGOLIB}/libcurl-sys.rlib \
	${CARGOLIB}/libcurl.rlib \
	${CARGOLIB}/libtar.rlib \
	${CARGOLIB}/libssh2-sys.rlib \
	${CARGOLIB}/libssh2.rlib \
	${CARGOLIB}/libgit2-sys.rlib \
	${CARGOLIB}/libgit2.rlib \
	${CARGOLIB}/libhamcrest.rlib \
	${CARGOLIB}/libtoml.rlib \
	${CARGOLIB}/libpkg-config.rlib \
	${CARGOLIB}/libminiz.a

LIB_gcc_NAM=gcc
LIB_gcc_DEP=
LIB_gcc_REV=9904334cbfb5ee40c9583aa1cf94b45102b93c6d
LIB_gcc_DIR=gcc-rs
LIB_gcc_REP=${GH}/alexcrichton/gcc-rs

LIB_semver_DEP=
LIB_semver_REV=90a052ec5d4e871aa290e208780950e437bb37ab
LIB_semver_REP=${GH}/rust-lang/semver

LIB_rustc_serialize_NAM=rustc-serialize
LIB_rustc_serialize_DEP=
LIB_rustc_serialize_REV=c89c3343c9a7781c2a8ecfb5547853a2171745f5
LIB_rustc_serialize_DIR=rustc-serialize
LIB_rustc_serialize_REP=${GH}/rust-lang/rustc-serialize

LIB_regex_DEP=${CARGOLIB}/librustc-serialize.rlib
LIB_regex_REV=90ef3c4b58140d672ed97cdf45e59592d122368e
LIB_regex_REP=${GH}/rust-lang/regex.git

LIB_docopt_DEP=${CARGOLIB}/libregex.rlib
LIB_docopt_REV=6e9ceb2301418a0330e02391d20343ef2d66f0e4
LIB_docopt_REP=${GH}/docopt/docopt.rs

LIB_glob_REV=473d0089309db2da6c0d7bddbd079816de51e4af
LIB_glob_REP=${GH}/rust-lang/glob

LIB_libz_sys_NAM=libz-sys
LIB_libz_sys_REV=6c19f1309966ce5959ec0472a4730f457136f687
LIB_libz_sys_DIR=libz-sys
LIB_libz_sys_REP=${GH}/alexcrichton/libz-sys

LIB_openssl_NAM=openssl
LIB_openssl_REV=a68a74ff6b698f5240baac4819f8acf3da2e8ec5
LIB_openssl_DIR=rust-openssl
LIB_openssl_REP=${GH}/sfackler/rust-openssl
LIB_openssl_SRC=openssl/src

LIB_openssl_sys_NAM=openssl-sys
LIB_openssl_sys_DIR=${LIB_openssl_DIR}
LIB_openssl_sys_SRC=openssl-sys/src

LIB_url_REV=16923fb0a9c92a2ee5f42760812d9bfa1ea3f8f4
LIB_url_DIR=rust-url
LIB_url_REP=${GH}/servo/rust-url
LIB_url_DEP=${CARGOLIB}/librustc-serialize.rlib ${CARGOLIB}/libmatches.rlib

LIB_matches_REV=1240fab4ad404417bd439a1a1b0c36d00790d3e0
LIB_matches_DIR=rust-std-candidates
LIB_matches_REP=${GH}/SimonSapin/rust-std-candidates.git
LIB_matches_SRC=matches

LIB_pkg_config_NAM=pkg-config
LIB_pkg_config_REV=f33a689767afe4c521a380a129566b912c490103
LIB_pkg_config_VER=0.2.0
LIB_pkg_config_REP=${GH}/alexcrichton/pkg-config-rs.git
LIB_pkg_config_DIR=pkg-config-rs

LIB_toml_REV=00420259044e9e961b9d8a80e5482ffc58250145
LIB_toml_VER=0.1.16
LIB_toml_REP=${GH}/alexcrichton/toml-rs.git
LIB_toml_DIR=toml-rs
LIB_toml_DEP=${CARGOLIB}/librustc-serialize.rlib

LIB_curl_REV=9181ea8f4ea2c7eb60224b5ebf464751165e2881
LIB_curl_VER=0.1.14
LIB_curl_REP=${GH}/carllerche/curl-rust
LIB_curl_DIR=curl-rust
LIB_curl_DEP=${CARGOLIB}/libcurl-sys.rlib

LIB_curl_sys_NAM=curl-sys
LIB_curl_sys_DIR=curl-rust
LIB_curl_sys_SRC=curl-sys
LIB_curl_sys_DEP=${CARGOLIB}/liblibz-sys.rlib

LIB_tar_REV=60f0ad391c37539a9f99100c7bbeb0c6b7c71ef7
LIB_tar_REP=${GH}/alexcrichton/tar-rs
LIB_tar_VER=0.1.10
LIB_tar_DIR=tar-rs

LIB_ssh2_REV=e42ed21fe9174291189ab4488207c90578a0afed
LIB_ssh2_REP=${GH}/alexcrichton/ssh2-rs
LIB_ssh2_DIR=ssh2-rs
LIB_ssh2_DEP=${CARGOLIB}/libbitflags.rlib ${CARGOLIB}/libssh2-sys.rlib

LIB_ssh2_sys_NAM=ssh2-sys
LIB_ssh2_sys_DIR=ssh2-rs
LIB_ssh2_sys_SRC=libssh2-sys
LIB_ssh2_sys_DEP=${CARGOLIB}/liblibz-sys.rlib ${CARGOLIB}/libopenssl-sys.rlib

LIB_bitflags_REV=78241d80cb9d0e1d64976afd8be6d35dd58824b0
LIB_bitflags_REP=${GH}/rust-lang/bitflags
LIB_bitflags_VER=0.1.1

ALL_LIBS=gcc semver rustc_serialize regex docopt glob libz_sys \
	 openssl_sys openssl url matches pkg_config toml curl curl_sys \
	 tar ssh2 ssh2_sys bitflags

.for L in ${ALL_LIBS}
LIB_${L}_NAM?=${L}
LIB_${L}_DIR?=${L}
LIB_${L}_SRC?=src

.if defined(LIB_${L}_REP)
${WRKDIR}/${LIB_${L}_DIR}/${LIB_${L}_REV}:
	sh git-fetch.sh ${.TARGET} ${LIB_${L}_REP}
.endif

lib${L}: ${CARGOLIB}/lib${LIB_${L}_NAM}.rlib

${CARGOLIB}/lib${LIB_${L}_NAM}.rlib: \
		${WRKDIR}/${LIB_${L}_DIR}/${LIB_${L}_REV}  \
		${LIB_${L}_DEP}
	echo "*** Build ${L}"
	${RUSTC} ${WRKDIR}/${LIB_${L}_DIR}/${LIB_${L}_SRC}/lib.rs --crate-type lib --crate-name ${LIB_${L}_NAM} --out-dir ${CARGOLIB} -L ${CARGOLIB}/
.endfor

# fetch instructions

${WRKDIR}/libgit2/f1a374a67da77f85276b42d5d57cdcf2f0a05c08:
	sh git-fetch.sh ${.TARGET} ${GH}/alexcrichton/libgit2.git
${WRKDIR}/flate2-rs/c8ecf7a411bc6d43bf885f487c01e536490f2aea:
	sh git-fetch.sh ${.TARGET} ${GH}/alexcrichton/flate2-rs
${WRKDIR}/git2-rs/0a97e47340323c73e7bb9d294d462f8238ff265d:
	sh git-fetch.sh ${.TARGET} ${GH}/alexcrichton/git2-rs
${WRKDIR}/hamcrest-rust/2b9bd6cdae5dcf08acac84371fe889dc8eb5c528:
	sh git-fetch.sh ${.TARGET} ${GH}/carllerche/hamcrest-rust.git
${WRKDIR}/cargo/0caa5b58fd4aac95d3388bed878797becf544215:
	sh git-fetch.sh ${.TARGET} ${GH}/rust-lang/cargo.git


# build instructions

${DSTDIR}/lib/libgit2.so: ${WRKDIR}/libgit2/f1a374a67da77f85276b42d5d57cdcf2f0a05c08
	echo "*** Build libgit2"
	mkdir -p  ${WRKDIR}/libgit2/build
	(cd ${WRKDIR}/libgit2/build && cmake .. -DCMAKE_INSTALL_PREFIX=${DSTDIR} -DBUILD_SHARED_LIBS=ON)
	(cd ${WRKDIR}/libgit2/build && cmake --build . --target install)

${CARGOLIB}/libminiz.a: ${WRKDIR}/flate2-rs/c8ecf7a411bc6d43bf885f487c01e536490f2aea
	echo "*** Build libminiz"
	${CC} -c ${WRKDIR}/flate2-rs/miniz-sys/miniz.c -o ${CARGOLIB}/miniz.o
	${AR} -rc ${CARGOLIB}/libminiz.a ${CARGOLIB}/miniz.o
	ranlib ${CARGOLIB}/libminiz.a
	rm ${CARGOLIB}/miniz.o


mkdirs: 
	@mkdir -p ${WRKDIR}
	@mkdir -p ${DSTDIR}
	@mkdir -p ${CARGOLIB}

