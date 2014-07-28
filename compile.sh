RUST_PREFIX=/home/mneumann/disk/rust-dfly
RUSTC=${RUST_PREFIX}/bin/rustc
RUST_SRC=/home/mneumann/disk/new/rust
TARGET=x86_64-pc-dragonfly-elf
DF_TREE=/home/mneumann/rust-cross-dragonfly/df-tree

#CC_TARGET="clang --sysroot=${DF_TREE} -target ${TARGET} -D__DragonFly__"
#LINK="-L${DF_TREE}/lib -B${DF_TREE}/lib -L${DF_TREE}/usr/lib -L${DF_TREE}/usr/lib/gcc47 -B${DF_TREE}/usr/lib -B${DF_TREE}/usr/lib/gcc47 -rpath ${DF_TREE}/lib" 

export LD_LIBRARY_PATH=${RUST_PREFIX}/lib

mkdir -p target

export CFG_VERSION="0.12.0-pre-nightly"
export CFG_RELEASE="dragonfly-cross"
export CFG_VER_HASH="hash"
export CFG_VER_DATE="`date`"
export CFG_COMPILER_HOST_TRIPLE="x86_64-unknown-dragonfly"
export CFG_PREFIX="/usr/local"

# compile rust libraries
for lib in core libc alloc unicode collections rustrt rand sync std native arena rustuv debug log fmt_macros serialize term syntax flate time url uuid getopts regex test coretest glob graphviz num rustc_back semver rustc_llvm rustc fourcc hexfloat regex_macros green rustdoc; do

  if [ -e target/lib${lib}.rlib ]; then
    echo "skipping $lib"
  else
    echo "compiling $lib"
    ${RUSTC} --target ${TARGET} --crate-type lib --cfg rtdebug \
                -Ltarget ${RUST_SRC}/src/lib${lib}/lib.rs -o target/lib${lib}.rlib

  fi
done


#${RUSTC} -Z print-link-args -C linker=clang \
#  -C link-args="-target ${TARGET} -B./target -L./target -rpath ./target -lrt -lc -lsupc++ -lstdc++ -lcompiler-rt -lm `cat flags`" \
#  --target ${TARGET} -Ltarget -o t t.rs

#${RUSTC} --emit obj --target ${TARGET} -Ltarget -o rustc.o --cfg rustc ${RUST_SRC}/src/driver/driver.rs
#exit

echo compiling
LIBS="-lLLVMLTO -lLLVMObjCARCOpts -lLLVMLinker -lLLVMipo -lLLVMVectorize -lLLVMBitWriter -lLLVMIRReader -lLLVMAsmParser -lLLVMR600CodeGen -lLLVMR600Desc -lLLVMR600Info -lLLVMR600AsmPrinter -lLLVMSystemZDisassembler -lLLVMSystemZCodeGen -lLLVMSystemZAsmParser -lLLVMSystemZDesc -lLLVMSystemZInfo -lLLVMSystemZAsmPrinter -lLLVMHexagonCodeGen -lLLVMHexagonAsmPrinter -lLLVMHexagonDesc -lLLVMHexagonInfo -lLLVMNVPTXCodeGen -lLLVMNVPTXDesc -lLLVMNVPTXInfo -lLLVMNVPTXAsmPrinter -lLLVMCppBackendCodeGen -lLLVMCppBackendInfo -lLLVMMSP430CodeGen -lLLVMMSP430Desc -lLLVMMSP430Info -lLLVMMSP430AsmPrinter -lLLVMXCoreDisassembler -lLLVMXCoreCodeGen -lLLVMXCoreDesc -lLLVMXCoreInfo -lLLVMXCoreAsmPrinter -lLLVMMipsDisassembler -lLLVMMipsCodeGen -lLLVMMipsAsmParser -lLLVMMipsDesc -lLLVMMipsInfo -lLLVMMipsAsmPrinter -lLLVMAArch64Disassembler -lLLVMAArch64CodeGen -lLLVMAArch64AsmParser -lLLVMAArch64Desc -lLLVMAArch64Info -lLLVMAArch64AsmPrinter -lLLVMAArch64Utils -lLLVMARMDisassembler -lLLVMARMCodeGen -lLLVMARMAsmParser -lLLVMARMDesc -lLLVMARMInfo -lLLVMARMAsmPrinter -lLLVMPowerPCDisassembler -lLLVMPowerPCCodeGen -lLLVMPowerPCAsmParser -lLLVMPowerPCDesc -lLLVMPowerPCInfo -lLLVMPowerPCAsmPrinter -lLLVMSparcDisassembler -lLLVMSparcCodeGen -lLLVMSparcAsmParser -lLLVMSparcDesc -lLLVMSparcInfo -lLLVMSparcAsmPrinter -lLLVMTableGen -lLLVMDebugInfo -lLLVMOption -lLLVMX86Disassembler -lLLVMX86AsmParser -lLLVMX86CodeGen -lLLVMSelectionDAG -lLLVMAsmPrinter -lLLVMX86Desc -lLLVMMCDisassembler -lLLVMX86Info -lLLVMX86AsmPrinter -lLLVMX86Utils -lLLVMJIT -lLLVMLineEditor -lLLVMMCAnalysis -lLLVMInstrumentation -lLLVMInterpreter -lLLVMCodeGen -lLLVMScalarOpts -lLLVMInstCombine -lLLVMTransformUtils -lLLVMipa -lLLVMAnalysis -lLLVMProfileData -lLLVMMCJIT -lLLVMTarget -lLLVMRuntimeDyld -lLLVMObject -lLLVMMCParser -lLLVMBitReader -lLLVMExecutionEngine -lLLVMMC -lLLVMCore -lLLVMSupport"

LINK="-target ${TARGET} -B./target/usr/lib/gcc47 -B./target/usr/lib -B./target/lib -L./target/lib -L./target/usr/lib -L./target/usr/lib/gcc47 -L./target/lib -L./target/usr/lib/gcc47 -L./target -rpath ./target/usr/lib/gcc47 -rpath ./target/usr/lib -rpath ./target/lib -Wl,-whole-archive ${LIBS} -Wl,-no-whole-archive -lz -lpthread -ledit -ltinfo -lm -lc -lrt -lstdc++ -lcompiler-rt -lrt"

${RUSTC} --emit obj -C linker=clang -C link-args="${LINK}" --target ${TARGET} -Ltarget --cfg rustc ${RUST_SRC}/src/driver/driver.rs
