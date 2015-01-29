#!/bin/sh
# =================================================================================================
# Supporting functions and definitions

PREFIX=$HOME/src/cargo-freebsd
TARGET=$PREFIX/target

build-rust () {
  RUSTVERSION=$1

  if [ ! -d rust-nightly-$RUSTVERSION ]; then
    if [ $RUSTVERSION \< "2015-01-01" ]; then
      RUST_TAR=rust-nightly.tar.gz
      RUST_DIR=rust-nightly
    elif [ $RUSTVERSION \< "2015-01-05" ]; then
      RUST_TAR=rust-nightly-src.tar.gz
      RUST_DIR=rust-nightly
    else 
      RUST_TAR=rustc-nightly-src.tar.gz
      RUST_DIR=rustc-nightly
    fi 
    RUST_URL=https://static.rust-lang.org/dist/$RUSTVERSION/$RUST_TAR
    echo "*** fetch rust-nightly-$RUSTVERSION from $RUST_URL"
    curl -# -f -O $RUST_URL
    if [ $? -ne 0 ]; then
      echo "*** failed to fetch rust nightly $?"
      return 1
    fi
    tar zxvf $RUST_TAR
    if [ $? -ne 0 ]; then
      echo "*** failed to extract rust nightly $?"
      return 2
    fi
    rm $RUST_TAR
    mv $RUST_DIR rust-nightly-$RUSTVERSION
		mkdir -p $TARGET/rust-nightly-$RUSTVERSION
    rm -f rust-nightly && ln -s rust-nightly-$RUSTVERSION rust-nightly
  fi

  if [ ! -f rust-nightly-$RUSTVERSION/config.stamp ]; then
    echo "*** configure rust-nightly-$RUSTVERSION --prefix=$TARGET"
    (cd rust-nightly-$RUSTVERSION && ./configure --disable-docs --prefix=$TARGET/rust-nightly-$RUSTVERSION)
  fi

  if [ ! -f $TARGET/rust-nightly-$RUSTVERSION/bin/rustc ]; then
    echo "*** Build rust-nightly-$RUSTVERSION"
    (cd rust-nightly-$RUSTVERSION && gmake -s -j `sysctl -n hw.ncpu` && gmake -s install)
    if [ $? -ne 0 ]; then
      echo "*** failed to build rust nightly $?"
      return 3
    fi
  else
    echo "*** rust-nightly-$RUSTVERSION already exists"
  fi
  return 0
}

git-fetch () {
	if [ ! -d $1 ]; then
    echo "*** git clone $2 -> $1"
    git clone --recursive $2 $1
  fi
  echo "*** git checkout $1 $3"
  (cd $1 && git checkout -q $3)
}

# =================================================================================================
# Create target directory, for intermediate builds, if necessary

if [ ! -d $PREFIX/target ]; then
  echo "*** mkdir $PREFIX/target"
  mkdir $PREFIX/target
fi

# =================================================================================================
# Create bootstrap version of cargo, if necessary

ORIG_PATH=$PATH
ORIG_LD_LIBRARY_PATH=$LD_LIBRARY_PATH

mkdir -p $HOME/apps/cargo/bin
mkdir -p $HOME/apps/cargo/lib

if [ ! -f $HOME/apps/cargo/cargo-version.txt ]; then
  # We need to build the bootstrap version of cargo
  build-rust 2014-12-12
  if [ $? -ne 0 ]; then
    echo "*** Build failed"
    exit
  fi

  mkdir -p  cargo/bootstrap

	mkdir -p $TARGET/cargo-bootstrap/bin
	mkdir -p $TARGET/cargo-bootstrap/lib

  # Fetch dependencies for Cargo
  git-fetch cargo/bootstrap/libgit2       https://github.com/alexcrichton/libgit2.git     f1a374a67da77f85276b42d5d57cdcf2f0a05c08
  git-fetch cargo/bootstrap/semver        https://github.com/rust-lang/semver             c09b5bdf6b2fcaa719da588a7da98b1145264f56
  git-fetch cargo/bootstrap/docopt        https://github.com/docopt/docopt.rs             38cc4572bef4dc5cbcb7526500aa14d1898c426d
  git-fetch cargo/bootstrap/flate2-rs     https://github.com/alexcrichton/flate2-rs       c8ecf7a411bc6d43bf885f487c01e536490f2aea
  git-fetch cargo/bootstrap/glob          https://github.com/rust-lang/glob               7e1bd4c5917fde41861ee93e067d5d84d3caf5d1
  git-fetch cargo/bootstrap/libz-sys      https://github.com/alexcrichton/libz-sys        6c19f1309966ce5959ec0472a4730f457136f687
  git-fetch cargo/bootstrap/rust-openssl  https://github.com/sfackler/rust-openssl        9754b8e47db5faff2930ed070527d2d71e76e094
  git-fetch cargo/bootstrap/rust-url      https://github.com/servo/rust-url               1c738d2640731f6da58b85bb5a04883b81835b66
  git-fetch cargo/bootstrap/curl-rust     https://github.com/carllerche/curl-rust         8e8e28955c3289fa77f7d6eb3962dc87a18df9ce
  git-fetch cargo/bootstrap/tar-rs        https://github.com/alexcrichton/tar-rs          c431eeae10c0ad008a252127ffa599df5ab2c0ca
  git-fetch cargo/bootstrap/ssh2-rs       https://github.com/alexcrichton/ssh2-rs         5319ce3a7dc4d417af9d94b8671c41ad43018b10
  git-fetch cargo/bootstrap/git2-rs       https://github.com/alexcrichton/git2-rs         0a97e47340323c73e7bb9d294d462f8238ff265d
  git-fetch cargo/bootstrap/gcc-rs        https://github.com/alexcrichton/gcc-rs          3caf7309ef72644cd56a9d3a6f515ae553683176
  git-fetch cargo/bootstrap/hamcrest-rust https://github.com/carllerche/hamcrest-rust.git 2b9bd6cdae5dcf08acac84371fe889dc8eb5c528
  git-fetch cargo/bootstrap/toml-rs       https://github.com/alexcrichton/toml-rs         944b94c21a064d0b1ad80ccabf12d95726c72139
  git-fetch cargo/bootstrap/pkg-config-rs https://github.com/alexcrichton/pkg-config-rs   9b3b44a2e1a8ccc70c3f701aeb5154ad79e665e9
  git-fetch cargo/bootstrap/cargo         https://github.com/rust-lang/cargo.git          0caa5b58fd4aac95d3388bed878797becf544215

  # Build non-Rust dependencies for Cargo
  echo "*** Build libgit2"
  mkdir -p  cargo/bootstrap/libgit2/build
  (cd cargo/bootstrap/libgit2/build && cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/apps/cargo -DBUILD_SHARED_LIBS=ON)
  (cd cargo/bootstrap/libgit2/build && cmake --build . --target install)

  echo "*** Build libminiz"
  clang -c cargo/bootstrap/flate2-rs/miniz-sys/miniz.c -o $TARGET/cargo-bootstrap/lib/miniz.o
  ar -rc $TARGET/cargo-bootstrap/lib/libminiz.a $TARGET/cargo-bootstrap/lib/miniz.o
  ranlib $TARGET/cargo-bootstrap/lib/libminiz.a 
  rm $TARGET/cargo-bootstrap/lib/miniz.o

  # Build Rust dependencies for Cargo
  PATH=$TARGET/rust-nightly-$RUSTVERSION/bin:$ORIG_PATH
  export PATH

  LD_LIBRARY_PATH=$HOME/apps/cargo/lib:$TARGET/rust-nightly-$RUSTVERSION/lib:$TARGET/cargo-bootstrap/lib:$ORIG_LD_LIBRARY_PATH
  export LD_LIBRARY_PATH

  RUSTC=$TARGET/rust-nightly-$RUSTVERSION/bin/rustc 
	CARGOLIB=$TARGET/cargo-bootstrap/lib

  echo "*** Build semver"         && $RUSTC cargo/bootstrap/semver/src/lib.rs                   --crate-type lib --crate-name semver       --out-dir $CARGOLIB -L $CARGOLIB/
  echo "*** Build docopt"         && $RUSTC cargo/bootstrap/docopt/src/lib.rs                   --crate-type lib --crate-name docopt       --out-dir $CARGOLIB -L $CARGOLIB/
  echo "*** Build gcc"            && $RUSTC cargo/bootstrap/gcc-rs/src/lib.rs                   --crate-type lib --crate-name gcc          --out-dir $CARGOLIB -L $CARGOLIB/ 
  echo "*** Build miniz-sys"      && $RUSTC cargo/bootstrap/flate2-rs/miniz-sys/lib.rs          --crate-type lib --crate-name miniz-sys    --out-dir $CARGOLIB -L $CARGOLIB/ -l miniz:static
  echo "*** Build flate2"         && $RUSTC cargo/bootstrap/flate2-rs/src/lib.rs                --crate-type lib --crate-name flate2       --out-dir $CARGOLIB -L $CARGOLIB/ --extern gcc=$CARGOLIB/libgcc.rlib
  echo "*** Build glob"           && $RUSTC cargo/bootstrap/glob/src/lib.rs                     --crate-type lib --crate-name glob         --out-dir $CARGOLIB -L $CARGOLIB/
  echo "*** Build libz-sys"       && $RUSTC cargo/bootstrap/libz-sys/src/lib.rs                 --crate-type lib --crate-name libz-sys     --out-dir $CARGOLIB -L $CARGOLIB/
  echo "*** Build openssl-sys"    && $RUSTC cargo/bootstrap/rust-openssl/openssl-sys/src/lib.rs --crate-type lib --crate-name openssl-sys  --out-dir $CARGOLIB -L $CARGOLIB/
  echo "*** Build openssl"        && $RUSTC cargo/bootstrap/rust-openssl/src/lib.rs             --crate-type lib --crate-name openssl      --out-dir $CARGOLIB -L $CARGOLIB/
  echo "*** Build url"            && $RUSTC cargo/bootstrap/rust-url/src/lib.rs                 --crate-type lib --crate-name url          --out-dir $CARGOLIB -L $CARGOLIB/
  echo "*** Build curl-sys"       && $RUSTC cargo/bootstrap/curl-rust/curl-sys/lib.rs           --crate-type lib --crate-name curl-sys     --out-dir $CARGOLIB -L $CARGOLIB/
  echo "*** Build curl"           && $RUSTC cargo/bootstrap/curl-rust/src/lib.rs                --crate-type lib --crate-name curl         --out-dir $CARGOLIB -L $CARGOLIB/ --extern url=$CARGOLIB/liburl.rlib
  echo "*** Build tar"            && $RUSTC cargo/bootstrap/tar-rs/src/lib.rs                   --crate-type lib --crate-name tar          --out-dir $CARGOLIB -L $CARGOLIB/
  echo "*** Build libssh2-sys"    && $RUSTC cargo/bootstrap/ssh2-rs/libssh2-sys/lib.rs          --crate-type lib --crate-name libssh2-sys  --out-dir $CARGOLIB -L $CARGOLIB/
  echo "*** Build ssh2"           && $RUSTC cargo/bootstrap/ssh2-rs/src/lib.rs                  --crate-type lib --crate-name ssh2         --out-dir $CARGOLIB -L $CARGOLIB/
  echo "*** Build libgit2"        && $RUSTC cargo/bootstrap/git2-rs/libgit2-sys/lib.rs          --crate-type lib --crate-name libgit2-sys  --out-dir $CARGOLIB -L $CARGOLIB/ 
  echo "*** Build git2"           && $RUSTC cargo/bootstrap/git2-rs/src/lib.rs                  --crate-type lib --crate-name git2         --out-dir $CARGOLIB -L $CARGOLIB/ --extern url=$CARGOLIB/liburl.rlib 
  echo "*** Build hamcrest-rust"  && $RUSTC cargo/bootstrap/hamcrest-rust/src/hamcrest/lib.rs   --crate-type lib --crate-name hamcrest     --out-dir $CARGOLIB -L $CARGOLIB/
  echo "*** Build toml"           && $RUSTC cargo/bootstrap/toml-rs/src/lib.rs                  --crate-type lib --crate-name toml         --out-dir $CARGOLIB -L $CARGOLIB/
  echo "*** Build pkg-config"     && $RUSTC cargo/bootstrap/pkg-config-rs/src/lib.rs            --crate-type lib --crate-name pkg-config   --out-dir $CARGOLIB -L $CARGOLIB/

  # Build Cargo

  export CARGO_PKG_VERSION_MAJOR=0
  export CARGO_PKG_VERSION_MINOR=0
  export CARGO_PKG_VERSION_PATCH=1

  echo "*** Build cargo/registry" && $RUSTC cargo/bootstrap/cargo/src/registry/lib.rs --crate-type lib --crate-name registry --out-dir $CARGOLIB -L $CARGOLIB/
  echo "*** Build cargo (lib)"    && $RUSTC cargo/bootstrap/cargo/src/cargo/lib.rs    --crate-type lib --crate-name cargo    --out-dir $CARGOLIB -L $CARGOLIB --extern glob=$CARGOLIB/libglob.rlib --extern semver=$CARGOLIB/libsemver.rlib

  echo "*** Build cargo (bin)"    && $RUSTC cargo/bootstrap/cargo/src/bin/cargo.rs -L $HOME/apps/cargo/lib -L $CARGOLIB --out-dir $TARGET/cargo-bootstrap/bin -lflate -lcurl -lssl -lcrypto -lz -lssh2 -lgit2

  # Install Cargo
  if [ -f $TARGET/cargo-bootstrap/bin/cargo ]; then
    mkdir -p $HOME/apps/cargo/bin
    install -m 755 $TARGET/cargo-bootstrap/bin/cargo  $HOME/apps/cargo/bin/
    echo "0caa5b58fd4aac95d3388bed878797becf544215" > $HOME/apps/cargo/cargo-version.txt
  else 
    echo "*** build failed"
    exit
  fi
fi

# =================================================================================================
# Clone or update Cargo repository

if [ ! -d cargo/head ]; then
  echo "*** Clone Cargo repository"
  git clone https://github.com/rust-lang/cargo.git cargo/head
else 
  echo "*** Update Cargo repository"
  (cd cargo/head && git pull)
fi

# =================================================================================================
# Update Cargo

# List of Cargo revisions that have been shown not to build
CARGO_BLACKLIST="085784ad7fa36968a05d7b4c050f84859f091c06
                 7bd6d0918a47b57295798e4a69ed3ce44d266a61"

CURR=`cat $HOME/apps/cargo/cargo-version.txt`
REVS=`(cd cargo/head && git rev-list --merges $CURR..HEAD | tail -r)`
NUMR=`echo $REVS | wc -w`

if [ $NUMR -gt 0 ]; then
  echo "*** Installed Cargo is $NUMR merges behind HEAD"
	for rev in $REVS
	do
    echo "*** Processing cargo/$rev"

    # Check the blacklist
    blacklisted=0
    for b in $CARGO_BLACKLIST 
    do
		  if [ $b == $rev ]; then
        blacklisted=1
			fi
		done

    if [ $blacklisted == 1 ]; then
      echo "*** Blacklisted carg0/$rev - skipping"
      continue
    fi

    # Fetch and build next Cargo revision
    git-fetch cargo/$rev https://github.com/rust-lang/cargo.git $rev

    echo "*** Run "git submodule update --init" in cargo/$rev"
		(cd cargo/$rev && git submodule update --init)

    # Fix broken dependencies (some versions of Cargo seem to require a
    # version of https://github.com/alexcrichton/docopt.rs that is no
    # longer available in the gitub repo. Substitute a slightly later
    # version that seems to work in its place. 
    cat cargo/$rev/Cargo.lock \
     | sed 's/ad176d540d344beb932cea8aa6270b92696a48bc/ec21366f88d09a06b4c2221dbecb57e3e1f07967/' > cargo/$rev/Cargo.lock.new 
    mv cargo/$rev/Cargo.lock.new cargo/$rev/Cargo.lock

    # Fetch and install the appropriate Rust nightly
    RUSTVERSION=`cat cargo/$rev/src/rustversion.txt`
		build-rust $RUSTVERSION
    if [ $? -ne 0 ]; then
      echo "*** Build of rust nightly failed - consider updating script to add to the blacklist"
      exit
    fi

    PATH=$TARGET/rust-nightly-$RUSTVERSION/bin:$ORIG_PATH
    export PATH

    LD_LIBRARY_PATH=$HOME/apps/cargo/lib:$TARGET/rust-nightly-$RUSTVERSION/lib:$ORIG_LD_LIBRARY_PATH
    export LD_LIBRARY_PATH

    if [ ! -f cargo/$rev/config.stamp ]; then
		  echo "*** Configure cargo/$rev"
      (cd cargo/$rev && ./configure --prefix=$HOME/apps/cargo \
                                    --local-cargo=$HOME/apps/cargo/bin/cargo \
                                    --local-rust-root=$TARGET/rust-nightly-$RUSTVERSION
																	  )
    else 
		  echo "*** Configure cargo/$rev - already configured"
    fi

		echo "*** Build cargo/$rev"
    (cd cargo/$rev && gmake -s && gmake -s install && echo $rev > $HOME/apps/cargo/cargo-version.txt)
    if [ $? -ne 0 ]; then
      echo "*** Build failed - skip? (y/n)"
      read r
      if [ $r != "y" ]; then
        echo "*** Abort"
        exit
      fi
    fi

    sleep 5
	done
else
  echo "*** Installed Cargo is up to date"
fi

# =================================================================================================

