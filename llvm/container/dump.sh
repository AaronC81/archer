#!/bin/bash
set -e

# ==================================================================================================
# DON'T RUN THIS SCRIPT YOURSELF
#
# This script runs inside the Docker container, and is automatically executed by
# `generate_tablegen_dumps.sh`.
#
# This script will generate dumps for all Archer-supported architectures, and write them to `/out`,
# which is expected to be a mapped volume within the container.
# ==================================================================================================


# Matches Dockerfile
llvm_src=/llvm/mainline/llvm-project
llvm_bin=/llvm/mainline/build/bin
llvm_include=$llvm_src/llvm/include
llvm_mainline_target=/llvm/mainline/llvm-project/llvm

# dump_arch <base> <architecture_name> <td_name>
dump_arch () {
    echo $2

    # Regardless of the LLVM base ($1), we still use the mainline includes, so they're compatible 
    # with the tblgen we're using
    $llvm_bin/llvm-tblgen $1/lib/Target/$2/$3.td -I $1/lib/Target/$2 -I $llvm_include -class=Instruction -dump-json -o /out/$2.json
    $llvm_bin/llvm-tblgen $1/lib/Target/$2/$3.td -I $1/lib/Target/$2 -I $llvm_include -class=Instruction -o /out/$2.td
}

dump_arch $llvm_mainline_target X86 X86
dump_arch $llvm_mainline_target PowerPC PPC
dump_arch $llvm_mainline_target RISCV RISCV
dump_arch /llvm/tricore/llvm-tricore TriCore TriCore
dump_arch /llvm/j2/j2-llvm J2 J2
