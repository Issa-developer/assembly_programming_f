# 05.asm – Pushing 64-bit values, 8-byte slots & byte order (x86-64)

Source: [`../05.asm`](../05.asm) · Full trace: [`output.txt`](output.txt)

## What I did
In the `07_stack` folder I assembled, linked and ran `05.asm`, then single-stepped it in gdb. In the `07_stack/05` folder I saved the run and trace as `output.txt` and wrote this README.

## What the program does
`RAX = 0x1122334455667788`, `RBX = 0x1234`. Both are pushed (`RAX` first), then popped back (`pop rbx`, then `pop rax`) into the **same** registers, then exit(0). It demonstrates that **each push consumes a full 8 bytes** even for a small value like `0x1234`, and LIFO order.

## How I ran it
```bash
nasm -f elf64 -g -F dwarf 05.asm -o 05.o && ld 05.o -o stack_05
./stack_05 ; echo $?                          # -> 0
gdb -q -batch -x ../trace64.gdb ./stack_05
```

## Stack walkthrough
| Instruction | RSP after | Top of stack (8-byte slots) |
|---|---|---|
| (start) | `0x7fffffffe1b0` | `argc`… |
| `mov rax,0x1122334455667788` | `e1b0` | unchanged |
| `mov rbx,0x1234` | `e1b0` | unchanged |
| `push rax` | `e1a8` (−8) | `0x1122334455667788` |
| `push rbx` | `e1a0` (−8) | `0x0000000000001234`, `0x1122334455667788` |
| `nop` | `e1a0` | snapshot of both pushed values |
| `pop rbx` | `e1a8` (+8) | `RBX ← 0x1234`; top is again `0x1122334455667788` |
| `pop rax` | `e1b0` (+8) | `RAX ← 0x1122334455667788`; top is `argc` |
| exit sequence | `e1b0` | |

### Explanation
* `push rbx` stores `0x0000000000001234`, a **full 8-byte** slot – the upper 6 bytes are zero. In 64-bit mode a stack slot is always 8 bytes; you cannot push a 4-byte or 1-byte register with `push r64`.
* Pop order is the opposite of push order. `pop rbx` comes first and receives what was pushed last (`rbx` itself). The program was written so each register gets its own value back, so the registers look unchanged – a LIFO-correctness check: with the pops in the wrong order, `RAX` would end up `0x1234` and `RBX` the big number.
* Net effect on `RSP`: −16 then +16, no change.

## Observations from running it
* Exit status `0`, no output.
* `RSP`: `e1b0 → e1a8 → e1a0 → e1a8 → e1b0`.
* gdb's `x/gx` view shows 64-bit words (`0x1122334455667788`), but in memory they are **little-endian**: the lowest address holds the least significant byte `0x88` (`x/8xb` on that slot would show `88 77 66 55 44 33 22 11`).
* `mov rax, 0x1122334455667788` is assembled as a 10-byte `movabs` (the only `mov` that carries a full 64-bit immediate); `mov rbx, 0x1234` became a short `mov ebx,0x1234`, which zero-extends into `RBX`.
