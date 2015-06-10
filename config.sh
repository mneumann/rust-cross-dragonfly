BRANCH=master
COMMIT=a59de37e99060162a2674e3ff45409ac73595c0e
SHORT_COMMIT=a59de37
REPO=https://github.com/rust-lang/rust.git
RELEASE_TAG="1.0.0"
USE_GIT=NO
USE_NIGHTLY=NO
USE_LOCAL_RUST=NO

ALL_PATCHES="main-mk"

if [ "${USE_NIGHTLY}" = "YES" ]; then
PACKAGE=rustc-nightly-src.tar.gz
PACKAGE_DIR=rustc-nightly
else
PACKAGE=rustc-1.0.0-src.tar.gz
PACKAGE_DIR=rustc-1.0.0
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
RUST_CRATES="core libc alloc unicode collections rand std rustc_bitflags arena log fmt_macros serialize"
RUST_CRATES="${RUST_CRATES} term syntax flate getopts test coretest graphviz rustc_back"
RUST_CRATES="${RUST_CRATES} rustc_llvm rbml rustc rustc_borrowck rustc_typeck rustc_trans"
RUST_CRATES="${RUST_CRATES} rustc_resolve rustc_privacy rustc_lint rustc_driver rustdoc"

LLVM_LIBRARIES="LTO ObjCARCOpts Linker ipo Vectorize BitWriter IRReader AsmParser R600CodeGen R600Desc"
LLVM_LIBRARIES="${LLVM_LIBRARIES} R600Info R600AsmPrinter SystemZDisassembler SystemZCodeGen SystemZAsmParser"
LLVM_LIBRARIES="${LLVM_LIBRARIES} SystemZDesc SystemZInfo SystemZAsmPrinter HexagonCodeGen"
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
