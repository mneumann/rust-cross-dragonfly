#!/bin/sh

if [ `uname -s` != "Linux" ]; then
  echo "You have to run this on Linux!"
  exit 1
fi

if [ ! -e "stage1-linux" ]; then
  echo "stage1-linux does not exist!"
  exit 1
fi

if [ ! -e "stage1-linux/install" ]; then
  echo "stage1-linux/install does not exist!"
  exit 1
fi

if [ ! -e "stage1-dragonfly/libs" ]; then
  echo "need stage1-dragonfly/libs!"
  exit 1
fi

TOP=`pwd`

RUST_PREFIX=${TOP}/stage1-linux/install
RUST_SRC=${TOP}/stage1-linux/rust
RUSTC=${RUST_PREFIX}/bin/rustc
TARGET=x86_64-pc-dragonfly-elf

DF_LIB_DIR=${TOP}/stage1-dragonfly/libs
RS_LIB_DIR=${TOP}/stage2-linux/rust-libs

export LD_LIBRARY_PATH=${RUST_PREFIX}/lib

mkdir -p ${TOP}/stage2-linux
mkdir -p ${TOP}/stage2-linux/rust-libs

# XXX
export CFG_VERSION="0.12.0-pre-nightly"
export CFG_RELEASE="dragonfly-cross"
export CFG_VER_HASH="hash"
export CFG_VER_DATE="`date`"
export CFG_COMPILER_HOST_TRIPLE="x86_64-unknown-dragonfly"
export CFG_PREFIX="/usr/local"

RUST_LIBS="core libc alloc unicode collections rustrt rand sync std native arena rustuv debug log fmt_macros serialize term syntax flate time url uuid getopts regex test coretest glob graphviz num rustc_back semver rustc_llvm rustc fourcc hexfloat regex_macros green rustdoc"

# compile rust libraries
for lib in $RUST_LIBS; do
  if [ -e ${RS_LIB_DIR}/lib${lib}.rlib ]; then
    echo "skipping $lib"
  else
    echo "compiling $lib"
    ${RUSTC} --target ${TARGET} --crate-type lib -L${DF_LIB_DIR} -L${RS_LIB_DIR} ${RUST_SRC}/src/lib${lib}/lib.rs -o ${RS_LIB_DIR}/lib${lib}.rlib
  fi
done

LLVM_LIBS="-lLLVMLTO -lLLVMObjCARCOpts -lLLVMLinker -lLLVMipo -lLLVMVectorize -lLLVMBitWriter -lLLVMIRReader -lLLVMAsmParser -lLLVMR600CodeGen -lLLVMR600Desc -lLLVMR600Info -lLLVMR600AsmPrinter -lLLVMSystemZDisassembler -lLLVMSystemZCodeGen -lLLVMSystemZAsmParser -lLLVMSystemZDesc -lLLVMSystemZInfo -lLLVMSystemZAsmPrinter -lLLVMHexagonCodeGen -lLLVMHexagonAsmPrinter -lLLVMHexagonDesc -lLLVMHexagonInfo -lLLVMNVPTXCodeGen -lLLVMNVPTXDesc -lLLVMNVPTXInfo -lLLVMNVPTXAsmPrinter -lLLVMCppBackendCodeGen -lLLVMCppBackendInfo -lLLVMMSP430CodeGen -lLLVMMSP430Desc -lLLVMMSP430Info -lLLVMMSP430AsmPrinter -lLLVMXCoreDisassembler -lLLVMXCoreCodeGen -lLLVMXCoreDesc -lLLVMXCoreInfo -lLLVMXCoreAsmPrinter -lLLVMMipsDisassembler -lLLVMMipsCodeGen -lLLVMMipsAsmParser -lLLVMMipsDesc -lLLVMMipsInfo -lLLVMMipsAsmPrinter -lLLVMAArch64Disassembler -lLLVMAArch64CodeGen -lLLVMAArch64AsmParser -lLLVMAArch64Desc -lLLVMAArch64Info -lLLVMAArch64AsmPrinter -lLLVMAArch64Utils -lLLVMARMDisassembler -lLLVMARMCodeGen -lLLVMARMAsmParser -lLLVMARMDesc -lLLVMARMInfo -lLLVMARMAsmPrinter -lLLVMPowerPCDisassembler -lLLVMPowerPCCodeGen -lLLVMPowerPCAsmParser -lLLVMPowerPCDesc -lLLVMPowerPCInfo -lLLVMPowerPCAsmPrinter -lLLVMSparcDisassembler -lLLVMSparcCodeGen -lLLVMSparcAsmParser -lLLVMSparcDesc -lLLVMSparcInfo -lLLVMSparcAsmPrinter -lLLVMTableGen -lLLVMDebugInfo -lLLVMOption -lLLVMX86Disassembler -lLLVMX86AsmParser -lLLVMX86CodeGen -lLLVMSelectionDAG -lLLVMAsmPrinter -lLLVMX86Desc -lLLVMMCDisassembler -lLLVMX86Info -lLLVMX86AsmPrinter -lLLVMX86Utils -lLLVMJIT -lLLVMLineEditor -lLLVMMCAnalysis -lLLVMInstrumentation -lLLVMInterpreter -lLLVMCodeGen -lLLVMScalarOpts -lLLVMInstCombine -lLLVMTransformUtils -lLLVMipa -lLLVMAnalysis -lLLVMProfileData -lLLVMMCJIT -lLLVMTarget -lLLVMRuntimeDyld -lLLVMObject -lLLVMMCParser -lLLVMBitReader -lLLVMExecutionEngine -lLLVMMC -lLLVMCore -lLLVMSupport"

LINK="-target ${TARGET} -B${DF_LIB_DIR}/usr/lib/gcc47 -B${DF_LIB_DIR}/usr/lib -B${DF_LIB_DIR}/lib -L${DF_LIB_DIR}/lib -L${DF_LIB_DIR}/usr/lib -L${DF_LIB_DIR}/usr/lib/gcc47 -L${DF_LIB_DIR}/lib -L${DF_LIB_DIR}/usr/lib/gcc47 -L${DF_LIB_DIR} -rpath .${DF_LIB_DIR}/usr/lib/gcc47 -rpath ${DF_LIB_DIR}/usr/lib -rpath ${DF_LIB_DIR}/lib -Wl,-whole-archive ${LLVM_LIBS} -Wl,-no-whole-archive -lz -lpthread -ledit -ltinfo -lm -lc -lrt -lstdc++ -lcompiler-rt -lrt"

${RUSTC} --emit obj -C linker=clang -C link-args="${LINK}" --target ${TARGET} -L${DF_LIB_DIR} -L${RS_LIB_DIR} --cfg rustc ${RUST_SRC}/src/driver/driver.rs
