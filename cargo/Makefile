#
# pkg ins libgit2(version 0.22.1) libssh2
#

RUSTC=/usr/local/bin/rustc
CC=cc
AR=ar

WRKDIR=work
DSTDIR=${HOME}/cargo/install
TARGET=${HOME}/cargo/target

CARGOLIB=${TARGET}/cargo-boostrap/lib
GH=https://github.com

cargo: mkdirs ${DSTDIR}/bin/cargo

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
	@echo "*** Build lib${L}"
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

${CARGOLIB}/libminiz.a: ${WRKDIR}/${LIB_flate2_DIR}/${LIB_flate2_REV}
	echo "*** Build libminiz"
	${CC} -fPIC -c ${WRKDIR}/flate2-rs/miniz-sys/miniz.c -o ${CARGOLIB}/miniz.o
	${AR} -rc ${CARGOLIB}/libminiz.a ${CARGOLIB}/miniz.o
	ranlib ${CARGOLIB}/libminiz.a
	rm ${CARGOLIB}/miniz.o

${DSTDIR}/bin/cargo: libcargo libenv_logger
	echo "*** Build cargo"
	${RUSTC} ${WRKDIR}/${LIB_cargo_DIR}/src/bin/cargo.rs \
		--out-dir ${DSTDIR}/bin \
		--extern log=${CARGOLIB}/liblog.rlib \
		-L ${CARGOLIB}/ -C link-args="-L${DSTDIR}/lib" \
		-lminiz -lcurl -lssl -lcrypto -lz -lssh2 -lgit2


mkdirs: 
	@mkdir -p ${WRKDIR}
	@mkdir -p ${DSTDIR}/lib ${DSTDIR}/bin
	@mkdir -p ${CARGOLIB}
