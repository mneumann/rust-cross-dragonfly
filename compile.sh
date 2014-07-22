RUSTC=rustc
RUSTDIR=/home/mneumann/rust

sh install.sh

mkdir -p target

# compile rust libraries
for lib in core libc alloc unicode collections; do
  echo compiling $lib
  ${RUSTC} --target x86_64-pc-freebsd-elf --crate-type lib -L target ${RUSTDIR}/src/lib${lib}/lib.rs -o target/lib${lib}.rlib
done

${RUSTC} --target x86_64-pc-freebsd-elf --crate-type lib src/my.rs -o target/libmy.rlib
${RUSTC} --target x86_64-pc-freebsd-elf --emit obj -L target src/main.rs -o target/main.o

clang \
 -L./df-tree/usr/lib \
 -L./df-tree/usr/lib/gcc47 \
 -B./df-tree/usr/lib \
 -B./df-tree/usr/lib/gcc47 \
 -target x86_64-pc-dragonfly-elf \
 -o target/app target/main.o ${RUSTDIR}/src/rt/arch/x86_64/morestack.S \
    target/lib*.rlib
    
