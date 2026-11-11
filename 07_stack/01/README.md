# 01.asm – Basic `push` / `pop` (x86-64)

Source: [`../01.asm`](../01.asm) · Full trace: [`output.txt`](output.txt)

## What I did
In the `07_stack` folder I assembled, linked and ran `01.asm`, then single-stepped it in gdb. In the `07_stack/01` folder I saved the run and trace as `output.txt` and wrote this README. In the `07_stack` folder I also created `trace64.gdb`, `trace32.gdb` and `run_all.sh` to reproduce the runs.

## What the program does
Loads `RAX = 100` and `RBX = 200`, pushes both onto the stack, then pops them into `RCX` and `RDX`, then exits with status 0. It prints nothing; the only way to see it work is in a debugger.

## How I ran it
```bash
nasm -f elf64 -g -F dwarf 01.asm -o 01.o
ld 01.o -o stack_01
./stack_01 ; echo $?                          # -> 0
gdb -q -batch -x ../trace64.gdb ./stack_01    # single-steps, prints RSP + top of stack
```
(`../run_all.sh` does this for every program in the folder.)

## Stack walkthrough
Addresses are from gdb (ASLR off); exact numbers differ outside gdb, the *differences* do not.

| Step | Instruction | RSP after | What is on the stack (top first) |
|---|---|---|---|
| start | – | `0x7fffffffe1b0` | `1` (argc), argv pointer… – left by the kernel |
| 1–2 | `mov rax,100` / `mov rbx,200` | `…e1b0` (unchanged) | same – `mov` never touches the stack |
| 3 | `push rax` | `…e1a8` (−8) | `0x64`, argc… |
| 4 | `push rbx` | `…e1a0` (−8) | `0xc8`, `0x64`, argc… |
| 5 | `nop` | `…e1a0` | `0xc8`, `0x64` – the "both values stored" snapshot |
| 6 | `pop rcx` | `…e1a8` (+8) | `0x64`, argc… → `RCX = 0xc8` |
| 7 | `pop rdx` | `…e1b0` (+8) | argc… → `RDX = 0x64` |
| 8+ | `mov rax,60`, `xor rdi,rdi`, `syscall` | `…e1b0` | exit(0) |

### Explanation
* At `_start` there is no `call`, so there is **no return address** on the stack. `RSP` already points at `argc`, which the Linux loader placed there.
* `push` does two things: `RSP = RSP - 8`, then stores the 8-byte operand at `[RSP]`. The stack **grows downward**: after two pushes `RSP` is 16 bytes lower (`0x…e1b0 → 0x…e1a0`).
* `pop` is the reverse: read `[RSP]` into the register, then `RSP = RSP + 8`.
* **LIFO order:** `RBX` (200) was pushed last, so the first `pop rcx` returns 200 and `pop rdx` returns 100. Final registers: `RCX = 200`, `RDX = 100` – the values come back **swapped** relative to the register names they were pushed from.
* After the last `pop`, `RSP` is exactly where it started (`0x7fffffffe1b0`): pushes and pops are balanced.

## Observations from running it
* Exit status `0`, no output.
* `RSP` sequence: `e1b0 → e1a8 → e1a0 → e1a8 → e1b0`.
* Even after `pop`, the old values `0x64` / `0xc8` physically remain in memory below `RSP` (popping only moves the pointer; it does not erase). Anything pushed later overwrites them.
* `mov rax, 100` is encoded as `mov eax,0x64` by the assembler (writing a 32-bit register zero-extends into the 64-bit one) – visible in the gdb disassembly.
