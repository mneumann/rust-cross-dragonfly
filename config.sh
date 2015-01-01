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
      opts="--reference $2"
    fi
    git clone --depth 1 --branch ${BRANCH} ${opts} --recursive ${REPO} $1
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
