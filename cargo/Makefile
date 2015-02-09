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

LIB_gcc_DEP=
LIB_gcc_REV=9904334cbfb5ee40c9583aa1cf94b45102b93c6d
LIB_gcc_DIR=gcc-rs
LIB_gcc_REP=${GH}/alexcrichton/gcc-rs

ALL_LIBS=gcc

.for L in ${ALL_LIBS}
${WRKDIR}/${LIB_${L}_DIR}/${LIB_${L}_REV}:
	sh git-fetch.sh ${.TARGET} ${LIB_${L}_REP}

${CARGOLIB}/lib${L}.rlib: ${WRKDIR}/${LIB_${L}_DIR}/${LIB_${L}_REV}
	echo "*** Build ${L}"
	${RUSTC} ${WRKDIR}/${LIB_${L}_DIR}/src/lib.rs --crate-type lib --crate-name ${L} --out-dir ${CARGOLIB} -L ${CARGOLIB}/
.endfor

# fetch instructions

${WRKDIR}/libgit2/f1a374a67da77f85276b42d5d57cdcf2f0a05c08:
	sh git-fetch.sh ${.TARGET} ${GH}/alexcrichton/libgit2.git
${WRKDIR}/semver/90a052ec5d4e871aa290e208780950e437bb37ab:
	sh git-fetch.sh ${.TARGET} ${GH}/rust-lang/semver
${WRKDIR}/docopt/6e9ceb2301418a0330e02391d20343ef2d66f0e4:
	sh git-fetch.sh ${.TARGET} ${GH}/docopt/docopt.rs
${WRKDIR}/flate2-rs/c8ecf7a411bc6d43bf885f487c01e536490f2aea:
	sh git-fetch.sh ${.TARGET} ${GH}/alexcrichton/flate2-rs
${WRKDIR}/glob/7e1bd4c5917fde41861ee93e067d5d84d3caf5d1:
	sh git-fetch.sh ${.TARGET} ${GH}/rust-lang/glob
${WRKDIR}/libz-sys/6c19f1309966ce5959ec0472a4730f457136f687:
	sh git-fetch.sh ${.TARGET} ${GH}/alexcrichton/libz-sys
${WRKDIR}/rust-openssl/9754b8e47db5faff2930ed070527d2d71e76e094:
	sh git-fetch.sh ${.TARGET} ${GH}/sfackler/rust-openssl
${WRKDIR}/rust-url/1c738d2640731f6da58b85bb5a04883b81835b66:
	sh git-fetch.sh ${.TARGET} ${GH}/servo/rust-url
${WRKDIR}/curl-rust/8e8e28955c3289fa77f7d6eb3962dc87a18df9ce:
	sh git-fetch.sh ${.TARGET} ${GH}/carllerche/curl-rust
${WRKDIR}/tar-rs/c431eeae10c0ad008a252127ffa599df5ab2c0ca:
	sh git-fetch.sh ${.TARGET} ${GH}/alexcrichton/tar-rs
${WRKDIR}/ssh2-rs/5319ce3a7dc4d417af9d94b8671c41ad43018b10:
	sh git-fetch.sh ${.TARGET} ${GH}/alexcrichton/ssh2-rs
${WRKDIR}/git2-rs/0a97e47340323c73e7bb9d294d462f8238ff265d:
	sh git-fetch.sh ${.TARGET} ${GH}/alexcrichton/git2-rs
#${WRKDIR}/gcc-rs/9904334cbfb5ee40c9583aa1cf94b45102b93c6d:
#	sh git-fetch.sh ${.TARGET} ${GH}/alexcrichton/gcc-rs
${WRKDIR}/hamcrest-rust/2b9bd6cdae5dcf08acac84371fe889dc8eb5c528:
	sh git-fetch.sh ${.TARGET} ${GH}/carllerche/hamcrest-rust.git
${WRKDIR}/toml-rs/944b94c21a064d0b1ad80ccabf12d95726c72139:
	sh git-fetch.sh ${.TARGET} ${GH}/alexcrichton/toml-rs
${WRKDIR}/pkg-config-rs/9b3b44a2e1a8ccc70c3f701aeb5154ad79e665e9:
	sh git-fetch.sh ${.TARGET} ${GH}/alexcrichton/pkg-config-rs
${WRKDIR}/cargo/0caa5b58fd4aac95d3388bed878797becf544215:
	sh git-fetch.sh ${.TARGET} ${GH}/rust-lang/cargo.git

${WRKDIR}/regex/90ef3c4b58140d672ed97cdf45e59592d122368e:
	sh git-fetch.sh ${.TARGET} ${GH}/rust-lang/regex.git

${WRKDIR}/rustc-serialize/c89c3343c9a7781c2a8ecfb5547853a2171745f5:
	sh git-fetch.sh ${.TARGET} ${GH}/rust-lang/rustc-serialize.git


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

${CARGOLIB}/libsemver.rlib: ${WRKDIR}/semver/90a052ec5d4e871aa290e208780950e437bb37ab
	echo "*** Build semver"
	${RUSTC} ${WRKDIR}/semver/src/lib.rs --crate-type lib --crate-name semver --out-dir ${CARGOLIB} -L ${CARGOLIB}/

${CARGOLIB}/libdocopt.rlib: ${WRKDIR}/docopt/6e9ceb2301418a0330e02391d20343ef2d66f0e4 ${CARGOLIB}/libregex.rlib
	echo "*** Build docopt"
	${RUSTC} ${WRKDIR}/docopt/src/lib.rs --crate-type lib --crate-name docopt --out-dir ${CARGOLIB} -L ${CARGOLIB}/


${CARGOLIB}/libregex.rlib: ${WRKDIR}/regex/90ef3c4b58140d672ed97cdf45e59592d122368e ${CARGOLIB}/librustc-serialize.rlib 
	echo "*** Build regex"
	${RUSTC} ${WRKDIR}/regex/src/lib.rs --crate-type lib --crate-name regex --out-dir ${CARGOLIB} -L ${CARGOLIB}/

${CARGOLIB}/librustc-serialize.rlib: ${WRKDIR}/rustc-serialize/c89c3343c9a7781c2a8ecfb5547853a2171745f5
	echo "*** Build rustc-serialize"
	${RUSTC} ${WRKDIR}/rustc-serialize/src/lib.rs --crate-type lib --crate-name rustc-serialize --out-dir ${CARGOLIB} -L ${CARGOLIB}/

mkdirs: 
	@mkdir -p ${WRKDIR}
	@mkdir -p ${DSTDIR}
	@mkdir -p ${CARGOLIB}

