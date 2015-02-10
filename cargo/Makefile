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
	${CARGOLIB}/liblibssh2-sys.rlib \
	${CARGOLIB}/libssh2.rlib \
	${CARGOLIB}/liblibgit2-sys.rlib \
	${CARGOLIB}/libgit2.rlib \
	${CARGOLIB}/libhamcrest.rlib \
	${CARGOLIB}/libtoml.rlib \
	${CARGOLIB}/libpkg-config.rlib \
	${CARGOLIB}/libminiz.a \
	${CARGOLIB}/libcargo.rlib

.include "Makefile.libs"

.for L in ${ALL_LIBS}
LIB_${L}_NAM?=${L}
LIB_${L}_DIR?=${L}
LIB_${L}_SRC?=src

.if defined(LIB_${L}_REP)
${WRKDIR}/${LIB_${L}_DIR}/${LIB_${L}_REV}:
	@sh git-fetch.sh ${.TARGET} ${LIB_${L}_REP}
.endif

lib${L}: ${CARGOLIB}/lib${LIB_${L}_NAM}.rlib

${CARGOLIB}/lib${LIB_${L}_NAM}.rlib: \
		${WRKDIR}/${LIB_${L}_DIR}/${LIB_${L}_REV}  \
		${LIB_${L}_DEP}
	@echo "*** Build ${L}"
	${LIB_${L}_ENV} ${RUSTC} ${WRKDIR}/${LIB_${L}_DIR}/${LIB_${L}_SRC}/lib.rs --crate-type lib ${LIB_${L}_OPT} --crate-name ${LIB_${L}_NAM} --out-dir ${CARGOLIB} -L ${CARGOLIB}/
.endfor

# fetch instructions

${WRKDIR}/libgit2/f1a374a67da77f85276b42d5d57cdcf2f0a05c08:
	sh git-fetch.sh ${.TARGET} ${GH}/alexcrichton/libgit2.git


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
