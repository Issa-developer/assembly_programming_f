# 07 – The Stack

## What I did
In the `07_stack` folder I ran all six `.asm` programs and traced them in gdb. In the folders `07_stack/01` to `07_stack/06` I created one `README.md` and one `output.txt` per program. In `07_stack` I also created `trace64.gdb`, `trace32.gdb`, `run_all.sh` and this index.

Each program has its own folder with a `README.md` (step-by-step stack explanation) and `output.txt` (real run + gdb single-step trace).

| Program | Mode | Topic | Write-up |
|---|---|---|---|
| [01.asm](01.asm) | x86-64 | `push` / `pop`, LIFO, RSP −8/+8 | [01/README.md](01/README.md) |
| [02.asm](02.asm) | x86-64 | `call`, `push rbp`, stack frame, locals | [02/README.md](02/README.md) |
| [03.asm](03.asm) | x86-64 | `call`/`ret`, return address | [03/README.md](03/README.md) |
| [04.asm](04.asm) | i386 | Same as 02 with 4-byte slots | [04/README.md](04/README.md) |
| [05.asm](05.asm) | x86-64 | 8-byte slots, 64-bit values, endianness | [05/README.md](05/README.md) |
| [06.asm](06.asm) | i386 | 4-byte slots, 32-bit values | [06/README.md](06/README.md) |

Reproduce everything with `sh run_all.sh` (needs `nasm`, `ld`, `gdb` on Linux/WSL). `trace64.gdb` / `trace32.gdb` single-step each program and print RSP/ESP, the registers and the top of the stack after every instruction.
