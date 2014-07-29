rust-cross-dragonfly
====================

Cross-compiling Rust to DragonFlyBSD.

This is a work in progress and is aimed at creating a rustc binary to run
natively on DragonFly. The current status is that it can cross-compile rustc to
DragonFly.

Read [this document][rust-cross] on how to cross-compile Rust to Dragonfly.

## Dependencies on Linux

Basic dependencies needed to build rust.

## Dependencies on Dragonfly

We need to build the following libraries on a DragonFly system, as we can't
easily cross-compile them on a Linux system:

* libuv
* llvm (our patched version)
* rustllvm (easy to compile as we already build llvm on DragonFly)

To build, we need:

* gmake
* cmake
* git
* perl
* libtool
* automake
* python

We need to make the following change as root user:

```
ln -s /usr/local/bin/perl /usr/bin/perl
```

This is because git-submodule uses a hard-coded perl.

[rust-cross]: http://ntecs.de/blog/2014/07/29/rust-ported-to-dragonfly-bsd/
