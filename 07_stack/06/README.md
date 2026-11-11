# 06.asm – Pushing 32-bit values, 4-byte slots (i386)

Source: [`../06.asm`](../06.asm) · Full trace: [`output.txt`](output.txt)

## What I did
In the `07_stack` folder I assembled (32-bit), linked and ran `06.asm`, then single-stepped it in gdb. In the `07_stack/06` folder I saved the run and trace as `output.txt` and wrote this README.

## What the program does
32-bit counterpart of `05.asm`: `EAX = 0x11223344`, `EBX = 0x1234`; `push eax`, `push ebx`, then `pop ebx`, `pop eax`, then exit(0) via `int 0x80`.

## How I ran it
```bash
nasm -f elf32 -g -F dwarf 06.asm -o 06.o
ld -m elf_i386 06.o -o stack_06
./stack_06 ; echo $?                          # -> 0
gdb -q -batch -x ../trace32.gdb ./stack_06
```

## Stack walkthrough
| Instruction | ESP after | Top of stack (4-byte slots) |
|---|---|---|
| (start) | `0xffffd2d0` | `argc`… |
| `mov eax,0x11223344` / `mov ebx,0x1234` | `d2d0` | unchanged |
| `push eax` | `d2cc` (−4) | `0x11223344` |
| `push ebx` | `d2c8` (−4) | `0x00001234`, `0x11223344` |
| `nop` | `d2c8` | snapshot of both values |
| `pop ebx` | `d2cc` (+4) | `EBX ← 0x1234`; top `0x11223344` |
| `pop eax` | `d2d0` (+4) | `EAX ← 0x11223344`; top is `argc` |
| `mov eax,1` / `xor ebx,ebx` / `int 0x80` | `d2d0` | exit(0) |

### Explanation
* In 32-bit mode a push moves `ESP` by **4**, not 8 (compare `05.asm`). `0x1234` is stored as the 4-byte `0x00001234`.
* LIFO: `ebx` was pushed last so `pop ebx` runs first; swapping the two pops would swap the register contents.
* `ESP` returns to `0xffffd2d0`, its value at entry – balanced.

## Observations from running it
* Exit status `0`, no output.
* `ESP`: `d2d0 → d2cc → d2c8 → d2cc → d2d0` (8 bytes of stack for two values, versus 16 in `05.asm`).
* Bytes in memory are little-endian (`0x11223344` is stored `44 33 22 11`); the gdb word dump (`x/4wx`) shows whole words and hides that.
* The last trace lines show `EAX=0x1`, `EBX=0x0` only because the exit-syscall setup overwrote them; the pops had already restored `0x11223344` / `0x1234` (visible right after the `pop eax`).
