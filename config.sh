BRANCH=master
COMMIT=9006c3c0f14be45da8ffeba43d354d088e366c83
SHORT_COMMIT=9006c3c
REPO=https://github.com/rust-lang/rust.git
USE_GIT=YES
USE_NIGHTLY=NO
USE_LOCAL_RUST=NO

ALL_PATCHES="llvm main-mk"

if [ "${USE_NIGHTLY}" = "YES" ]; then
PACKAGE=rustc-nightly-src.tar.gz
PACKAGE_DIR=rustc-nightly
else
PACKAGE=rustc-1.0.0-alpha-src.tar.gz
PACKAGE_DIR=rustc-1.0.0-alpha
fi

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

gen_md5() {
  if [ `uname -s` = "Linux" ]; then
	  md5sum --tag $1
  elif [ `uname -s` = "DragonFly" ]; then
	  md5 $1
  else
	  md5 $1
  fi
}

# List of all crates to compile (order is important)
RUST_CRATES="core libc alloc unicode collections rand std arena regex log fmt_macros serialize term syntax flate"
RUST_CRATES="${RUST_CRATES} getopts test coretest graphviz rustc_back rustc_llvm rbml rustc rustc_borrowck"
RUST_CRATES="${RUST_CRATES} rustc_typeck rustc_trans rustc_resolve rustc_privacy rustc_driver rustdoc"

LLVM_LIBRARIES="LTO ObjCARCOpts Linker ipo Vectorize BitWriter IRReader AsmParser R600CodeGen R600Desc"
LLVM_LIBRARIES="${LLVM_LIBRARIES} R600Info R600AsmPrinter SystemZDisassembler SystemZCodeGen SystemZAsmParser"
LLVM_LIBRARIES="${LLVM_LIBRARIES} SystemZDesc SystemZInfo SystemZAsmPrinter HexagonCodeGen HexagonAsmPrinter"
LLVM_LIBRARIES="${LLVM_LIBRARIES} HexagonDesc HexagonInfo NVPTXCodeGen NVPTXDesc NVPTXInfo NVPTXAsmPrinter"
LLVM_LIBRARIES="${LLVM_LIBRARIES} CppBackendCodeGen CppBackendInfo MSP430CodeGen MSP430Desc MSP430Info"
LLVM_LIBRARIES="${LLVM_LIBRARIES} MSP430AsmPrinter XCoreDisassembler XCoreCodeGen XCoreDesc XCoreInfo"
LLVM_LIBRARIES="${LLVM_LIBRARIES} XCoreAsmPrinter MipsDisassembler MipsCodeGen MipsAsmParser MipsDesc"
LLVM_LIBRARIES="${LLVM_LIBRARIES} MipsInfo MipsAsmPrinter AArch64Disassembler AArch64CodeGen AArch64AsmParser"
LLVM_LIBRARIES="${LLVM_LIBRARIES} AArch64Desc AArch64Info AArch64AsmPrinter AArch64Utils ARMDisassembler"
LLVM_LIBRARIES="${LLVM_LIBRARIES} ARMCodeGen ARMAsmParser ARMDesc ARMInfo ARMAsmPrinter PowerPCDisassembler"
LLVM_LIBRARIES="${LLVM_LIBRARIES} PowerPCCodeGen PowerPCAsmParser PowerPCDesc PowerPCInfo PowerPCAsmPrinter"
LLVM_LIBRARIES="${LLVM_LIBRARIES} SparcDisassembler SparcCodeGen SparcAsmParser SparcDesc SparcInfo"
LLVM_LIBRARIES="${LLVM_LIBRARIES} SparcAsmPrinter TableGen DebugInfo Option X86Disassembler X86AsmParser"
LLVM_LIBRARIES="${LLVM_LIBRARIES} X86CodeGen SelectionDAG AsmPrinter X86Desc MCDisassembler X86Info"
LLVM_LIBRARIES="${LLVM_LIBRARIES} X86AsmPrinter X86Utils LineEditor Instrumentation Interpreter CodeGen"
LLVM_LIBRARIES="${LLVM_LIBRARIES} ScalarOpts InstCombine TransformUtils ipa Analysis ProfileData MCJIT Target"
LLVM_LIBRARIES="${LLVM_LIBRARIES} RuntimeDyld Object MCParser BitReader ExecutionEngine MC Core Support"

if [ `uname -s` = "DragonFly" ]; then
  FETCH="fetch --no-verify-peer"
else
  FETCH=wget
fi

extract_source_into() {
  if [ "${USE_GIT}" = "YES" ]; then
    opts=""
    if [ "$2" != "" ]; then
      opts="${opts} --reference $2"
    fi
    if [ "${GIT_NON_RECURSIVE}" != "YES" ]; then
      opts="${opts} --recursive"
    fi
    git clone --branch ${BRANCH} ${opts} ${REPO} $1
    p=`pwd`
    cd $1 && git checkout ${COMMIT}
    cd $p
  else
    if [ ! -e "${PACKAGE}" ]; then
        ${FETCH} https://static.rust-lang.org/dist/${PACKAGE}
    fi
    tar xvzf ${PACKAGE}
    gen_md5 ${PACKAGE} > package.md5
    if [ "$1" != "${PACKAGE_DIR}" ]; then
      mv ${PACKAGE_DIR} $1
    fi
  fi
}

patch_source() {
  cd ${RUST_SRC}
  patch -p1 < ${TOP}/patches/patch-$1
}

patch_source_all() {
  for patch in ${ALL_PATCHES}; do
    patch_source $patch
  done
}
