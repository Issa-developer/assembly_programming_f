# 03.asm – `call` / `ret` and the return address (x86-64)

Source: [`../03.asm`](../03.asm) · Full trace: [`output.txt`](output.txt)

## What I did
In the `07_stack` folder I assembled, linked and ran `03.asm`, then single-stepped it in gdb. In the `07_stack/03` folder I saved the run and trace as `output.txt` and wrote this README.

## What the program does
Sets `RAX = 10`, calls `calculate`, which does `add rax,5` and returns. Back at `after_call`, `RAX` is 15. The program then exits with status 0. There are **no explicit `push`/`pop`** – the only stack use is what `call` and `ret` do by themselves.

## How I ran it
```bash
nasm -f elf64 -g -F dwarf 03.asm -o 03.o && ld 03.o -o stack_03
./stack_03 ; echo $?                          # -> 0
gdb -q -batch -x ../trace64.gdb ./stack_03
```

## Stack walkthrough
| Instruction | RSP after | Stack top | Notes |
|---|---|---|---|
| (start) | `0x7fffffffe1b0` | `argc` (1) | |
| `mov rax,10` | `e1b0` | `argc` | `RAX = 10` |
| `call calculate` | `e1a8` (−8) | **`0x40100a`** | pushes the address of `after_call` |
| `add rax,5` | `e1a8` | `0x40100a` | `RAX = 0xf` (15); stack untouched |
| `ret` | `e1b0` (+8) | `argc` | pops `0x40100a` into `RIP` |
| `nop` at `after_call` | `e1b0` | `argc` | execution resumed at `0x40100a` |
| `mov rax,60 / xor rdi,rdi / syscall` | `e1b0` | | exit(0) |

### Explanation
* `call calculate` = *push the address of the next instruction, then jump*. The next instruction is `after_call` at `0x40100a`; gdb shows `0x40100a` at `[RSP]` right after the call, and `RSP` dropped by 8.
* `calculate` never touches `RSP` (no push, no locals). That is the requirement for `ret` to work: when `ret` runs, `[RSP]` must still be the return address. It is, so `ret` loads `0x40100a` into `RIP` and `RSP` goes back up by 8.
* The stack is how the CPU remembers where to come back to. If `calculate` had pushed something and not popped it, `ret` would jump to a wrong address and crash.

## Observations from running it
* Exit status `0`, no output; the check is `RAX = 0xf` after `ret` (visible in the trace).
* `RSP` sequence: `e1b0 → e1a8 → e1a8 → e1b0` – a single 8-byte push/pop pair created entirely by `call`/`ret`.
* The leftover `0x40100a` stays in memory at `e1a8` after `ret` (not erased), but it is below `RSP` and so no longer part of the live stack.
