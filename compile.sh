RUST_PREFIX=/home/mneumann/disk/localrust
RUSTC=${RUST_PREFIX}/bin/rustc
RUST_SRC=/home/mneumann/disk/rust
TARGET=x86_64-pc-dragonfly-elf
DF_TREE=/home/mneumann/rust-cross-dragonfly/df-tree

CC_TARGET="clang --sysroot=${DF_TREE} -target ${TARGET} -D__DragonFly__"
LINK="-L${DF_TREE}/lib -B${DF_TREE}/lib -L${DF_TREE}/usr/lib -L${DF_TREE}/usr/lib/gcc47 -B${DF_TREE}/usr/lib -B${DF_TREE}/usr/lib/gcc47 -rpath ${DF_TREE}/lib" 

export LD_LIBRARY_PATH=${RUST_PREFIX}/lib

sh install.sh

mkdir -p target

# XXX: do this on Dragonfly
llc -filetype=obj -mtriple=x86_64-pc-dragonfly -relocation-model=pic \
  -o target/rust_try.o ${RUST_SRC}/src/rt/rust_try.ll
# record_sp.S
ar rcs target/librustrt_native.a target/rust_try.o

# Builtin
${CC_TARGET} -c -o target/rust_builtin.o -I${RUST_SRC}/src/rt \
  ${RUST_SRC}/src/rt/rust_builtin.c 
ar rcs target/librust_builtin.a target/rust_builtin.o

# MINIZ
${CC_TARGET} -c -o target/miniz.o -I${RUST_SRC}/src/rt \
  ${RUST_SRC}/src/rt/miniz.c
ar rcs target/libminiz.a target/miniz.o

${CC_TARGET} -c -o target/uv_support.o \
  -I${RUST_SRC}/src/rt \
  -I${RUST_SRC}/src/libuv/include \
  ${RUST_SRC}/src/rt/rust_uv.c

ar rcs target/libuv_support.a target/uv_support.o

${CC_TARGET} -c -o target/morestack.o \
  -I${RUST_SRC}/src/rt \
  -D__DragonFly__ -D__ELF__ \
  ${RUST_SRC}/src/rt/arch/x86_64/morestack.S
ar rcs target/libmorestack.a target/morestack.o

cp lib/libuv.a target/
cp lib/libcompiler-rt.a target/
cp lib/libbacktrace.a target/
 
# rustllvm

# green: context_switch

# compile rust libraries
for lib in core libc alloc unicode collections rustrt rand sync std native arena rustuv debug log fmt_macros serialize term syntax flate time url uuid getopts regex test coretest glob graphviz num rustc_back semver; do

  if [ -e target/lib${lib}.rlib ]; then
    echo "skipping $lib"
  else
    echo "compiling $lib"
    ${RUSTC} --target ${TARGET} --crate-type lib \
                -Ltarget ${RUST_SRC}/src/lib${lib}/lib.rs -o target/lib${lib}.rlib

  fi 
done

#NOTYET=rustc_llvm rustc rustdoc fourcc hexfloat regex_macros


${RUSTC} -Z print-link-args -C linker=clang \
  -C link-args="-target ${TARGET} --sysroot=${DF_TREE} -L${DF_TREE}/lib -B${DF_TREE}/lib -L${DF_TREE}/usr/lib -L${DF_TREE}/usr/lib/gcc47 -B${DF_TREE}/usr/lib -B${DF_TREE}/usr/lib/gcc47 -rpath ${DF_TREE}/lib" \
  --target ${TARGET} -Ltarget -o target/app src/test.rs
