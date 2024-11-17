#!/bin/bash
set -e

# TODO: will explode at any moment

# Checkouts:
#   llvm-project: mainline, on tag release/17.x
#   llvm-tricore: head of https://github.com/TriDis/llvm-tricore
#   j2-llvm: head of https://github.com/francisvm/j2-llvm.git
#            BUT modified to comment out `let decodePositionallyEncodedOperands = 1;` in: lib/Target/J2/J2.td

rm -rf tblgen_dump
mkdir -p tblgen_dump

llvm_bin=/opt/homebrew/Cellar/llvm/17.0.6/bin
llvm_src=/Users/aaron/Source/llvm-project

llvm_mainline_target=/Users/aaron/Source/llvm-project/llvm
llvm_include=$llvm_src/llvm/include

# dump_arch <base> <architecture_name> <td_name>
dump_arch () {
    # Regardless of the LLVM base ($1), we still use the mainline includes, so they're compatible 
    # with the tblgen we're using
    $llvm_bin/llvm-tblgen $1/lib/Target/$2/$3.td -I $1/lib/Target/$2 -I $llvm_include -class=Instruction -dump-json > tblgen_dump/$2.json
    $llvm_bin/llvm-tblgen $1/lib/Target/$2/$3.td -I $1/lib/Target/$2 -I $llvm_include -class=Instruction > tblgen_dump/$2.td
}

dump_arch $llvm_mainline_target X86 X86
dump_arch $llvm_mainline_target PowerPC PPC
dump_arch $llvm_mainline_target RISCV RISCV
dump_arch /Users/aaron/Source/llvm-tricore TriCore TriCore
dump_arch /Users/aaron/Source/j2-llvm J2 J2
