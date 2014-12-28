#!/bin/sh

. ./config.sh

if [ `uname -s` != "DragonFly" ]; then
  echo "You have to run this on DragonFly!"
  exit 1
fi

if [ ! -e "stage1-dragonfly/libs" ]; then
  echo "stage1-dragonfly does not exist!"
  exit 1
fi

if [ ! -e "stage2-linux/rust-libs" ]; then
  echo "stage2-linux does not exist!"
  exit 1
fi


RL=stage2-linux/rust-libs

SUP_LIBS="-Wl,-whole-archive -lmorestack -Wl,-no-whole-archive -lrust_builtin -lrustllvm -lcompiler-rt -lbacktrace -lhoedown -lminiz -lrustrt_native"

LLVM_LIBS="-lLLVMLTO -lLLVMObjCARCOpts -lLLVMLinker -lLLVMipo -lLLVMVectorize -lLLVMBitWriter -lLLVMIRReader -lLLVMAsmParser -lLLVMR600CodeGen -lLLVMR600Desc -lLLVMR600Info -lLLVMR600AsmPrinter -lLLVMSystemZDisassembler -lLLVMSystemZCodeGen -lLLVMSystemZAsmParser -lLLVMSystemZDesc -lLLVMSystemZInfo -lLLVMSystemZAsmPrinter -lLLVMHexagonCodeGen -lLLVMHexagonAsmPrinter -lLLVMHexagonDesc -lLLVMHexagonInfo -lLLVMNVPTXCodeGen -lLLVMNVPTXDesc -lLLVMNVPTXInfo -lLLVMNVPTXAsmPrinter -lLLVMCppBackendCodeGen -lLLVMCppBackendInfo -lLLVMMSP430CodeGen -lLLVMMSP430Desc -lLLVMMSP430Info -lLLVMMSP430AsmPrinter -lLLVMXCoreDisassembler -lLLVMXCoreCodeGen -lLLVMXCoreDesc -lLLVMXCoreInfo -lLLVMXCoreAsmPrinter -lLLVMMipsDisassembler -lLLVMMipsCodeGen -lLLVMMipsAsmParser -lLLVMMipsDesc -lLLVMMipsInfo -lLLVMMipsAsmPrinter -lLLVMAArch64Disassembler -lLLVMAArch64CodeGen -lLLVMAArch64AsmParser -lLLVMAArch64Desc -lLLVMAArch64Info -lLLVMAArch64AsmPrinter -lLLVMAArch64Utils -lLLVMARMDisassembler -lLLVMARMCodeGen -lLLVMARMAsmParser -lLLVMARMDesc -lLLVMARMInfo -lLLVMARMAsmPrinter -lLLVMPowerPCDisassembler -lLLVMPowerPCCodeGen -lLLVMPowerPCAsmParser -lLLVMPowerPCDesc -lLLVMPowerPCInfo -lLLVMPowerPCAsmPrinter -lLLVMSparcDisassembler -lLLVMSparcCodeGen -lLLVMSparcAsmParser -lLLVMSparcDesc -lLLVMSparcInfo -lLLVMSparcAsmPrinter -lLLVMTableGen -lLLVMDebugInfo -lLLVMOption -lLLVMX86Disassembler -lLLVMX86AsmParser -lLLVMX86CodeGen -lLLVMSelectionDAG -lLLVMAsmPrinter -lLLVMX86Desc -lLLVMMCDisassembler -lLLVMX86Info -lLLVMX86AsmPrinter -lLLVMX86Utils -lLLVMLineEditor -lLLVMInstrumentation -lLLVMInterpreter -lLLVMCodeGen -lLLVMScalarOpts -lLLVMInstCombine -lLLVMTransformUtils -lLLVMipa -lLLVMAnalysis -lLLVMProfileData -lLLVMMCJIT -lLLVMTarget -lLLVMRuntimeDyld -lLLVMObject -lLLVMMCParser -lLLVMBitReader -lLLVMExecutionEngine -lLLVMMC -lLLVMCore -lLLVMSupport"

RUST_DEPS=""
for lib in $RUST_CRATES; do
  RUST_DEPS="${RL}/lib${lib}.rlib ${RUST_DEPS}"
done

TARGET=x86_64-unknown-dragonfly
DST_DIR=stage3-dragonfly
DST_LIB=${DST_DIR}/lib/rustlib/${TARGET}/lib

mkdir -p ${DST_DIR}/bin
mkdir -p ${DST_LIB}

${CC} ${CFLAGS} -o ${DST_DIR}/bin/rustc stage2-linux/driver.o ${RUST_DEPS} -L./stage1-dragonfly/libs/llvm -L./stage1-dragonfly/libs $SUP_LIBS $LLVM_LIBS -lrt -lpthread -lgcc_pic -lc -lm -lz -ledit -ltinfo -lstdc++

echo "rustc done"

cp stage1-dragonfly/libs/libcompiler-rt.a ${DST_LIB}
cp stage1-dragonfly/libs/libmorestack.a ${DST_LIB}
cp stage2-linux/rust-libs/*.rlib ${DST_LIB}

#./${DST_DIR}/bin/rustc -L${DST_LIB} hw.rs && ./hw
