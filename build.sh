#!/bin/bash
# https://wiki.osdev.org/GCC_Cross-Compiler#Preparation

export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"
make all