#!/bin/sh
# Build, run and trace every program in this folder (needs nasm, ld, gdb).
set -e
cd "$(dirname "$0")"
for n in 01 02 03 05; do
  nasm -f elf64 -g -F dwarf $n.asm -o /tmp/$n.o && ld /tmp/$n.o -o /tmp/stack_$n
  { echo "\$ ./stack_$n ; echo \$?"; /tmp/stack_$n; echo "exit status: $?"; echo; gdb -q -batch -x trace64.gdb /tmp/stack_$n 2>&1; } > $n/output.txt
done
for n in 04 06; do
  nasm -f elf32 -g -F dwarf $n.asm -o /tmp/$n.o && ld -m elf_i386 /tmp/$n.o -o /tmp/stack_$n
  { echo "\$ ./stack_$n ; echo \$?"; /tmp/stack_$n; echo "exit status: $?"; echo; gdb -q -batch -x trace32.gdb /tmp/stack_$n 2>&1; } > $n/output.txt || true
done
