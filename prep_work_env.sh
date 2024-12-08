#!/bin/bash

BINUTILS="binutils-2.43"
GCC="gcc-14.2.0"

# Base install
sudo zypper update --no-confirm
sudo zypper install --no-confirm nasm qemu bless gdb wget xz

# Cross Compiler
# References from https://wiki.osdev.org/GCC_Cross-Compiler
sudo zypper install --no-confirm gcc make bison flex gmp-devel mpc-devel mpfr-devel texinfo isl-devel
sudo zypper install --no-confirm -t pattern devel_basis

mkdir $HOME/src
wget -nc https://ftp.gnu.org/gnu/binutils/$BINUTILS.tar.xz -P $HOME/src
wget -nc https://ftp.fu-berlin.de/unix/languages/gcc/releases/$GCC/$GCC.tar.gz -P $HOME/src

tar -xvJf $HOME/src/$BINUTILS.tar.xz -C $HOME/src
tar -xvzf $HOME/src/$GCC.tar.gz -C $HOME/src

# Required exports
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

# BINUTILS build
cd $HOME/src
mkdir build-binutils
cd build-binutils
../$BINUTILS/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make
make install

# GCC build
cd $HOME/src
# The $PREFIX/bin dir _must_ be in the PATH. We did that above.
which -- $TARGET-as || echo $TARGET-as is not in the PATH

mkdir build-gcc
cd build-gcc
../$GCC/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc

# Check
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

echo
echo
$HOME/opt/cross/bin/$TARGET-gcc --version
