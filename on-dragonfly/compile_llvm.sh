git clone https://github.com/rust-lang/llvm.git
cd llvm
git checkout rust-llvm-2014-07-24
patch -p1 < ../patch-llvm
cd ..
mkdir llvm-build
cd llvm-build
../llvm/configure --prefix=$HOME/llvm-install
make
