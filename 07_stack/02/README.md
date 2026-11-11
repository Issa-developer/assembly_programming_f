# 02.asm – Function call with a stack frame (x86-64)

Source: [`../02.asm`](../02.asm) · Full trace: [`output.txt`](output.txt)

## What I did
In the `07_stack` folder I assembled, linked and ran `02.asm`, then single-stepped it in gdb. In the `07_stack/02` folder I saved the run and trace as `output.txt` and wrote this README.

## What the program does
`_start` calls `work`. `work` builds a standard stack frame (`push rbp / mov rbp,rsp`), reserves 16 bytes of local variables with `sub rsp,16`, stores 100 and 200 in them, loads them into `RAX`/`RBX`, tears the frame down and returns. `_start` then exits with status 0.

## How I ran it
```bash
nasm -f elf64 -g -F dwarf 02.asm -o 02.o && ld 02.o -o stack_02
./stack_02 ; echo $?                          # -> 0
gdb -q -batch -x ../trace64.gdb ./stack_02
```

## Stack walkthrough
Let `S = 0x7fffffffe1b0` be `RSP` when `_start` begins (it points at `argc`).

| Instruction | RSP after | RBP after | Effect on the stack |
|---|---|---|---|
| (start of `_start`) | `S` | 0 | `argc` at top |
| `call work` | `e1a8` (S−8) | 0 | **pushes return address `0x401005`** (the `mov rax,60` after the call) |
| `push rbp` | `e1a0` (S−16) | 0 | saves caller's `RBP` (0) |
| `mov rbp,rsp` | `e1a0` | `e1a0` | frame base set; nothing pushed |
| `sub rsp,16` | `e190` | `e1a0` | 16 bytes of local space allocated (still 0 – never written) |
| `mov [rbp-8],100` | `e190` | `e1a0` | local #1 at `e198` = `0x64` |
| `mov [rbp-16],200` | `e190` | `e1a0` | local #2 at `e190` = `0xc8` |
| `mov rax,[rbp-8]` / `mov rbx,[rbp-16]` | `e190` | `e1a0` | reads only: `RAX=100`, `RBX=200` |
| `mov rsp,rbp` | `e1a0` | `e1a0` | locals discarded (just a pointer move) |
| `pop rbp` | `e1a8` | 0 | restores caller's `RBP` |
| `ret` | `e1b0` (= S) | 0 | pops `0x401005` into `RIP` → back in `_start` |
| exit sequence | `e1b0` | 0 | exit(0) |

Frame layout while inside `work` (high → low address):
```
e1b0  argc                      <- RSP before the call
e1a8  return address 0x401005   <- pushed by call
e1a0  saved RBP (0)             <- RBP points here
e198  local #1  [rbp-8]  = 100
e190  local #2  [rbp-16] = 200  <- RSP
```

### Explanation
* `call` is an implicit "push address of next instruction; jmp work". `ret` is an implicit `pop rip`. That is why the return address must be exactly at `[RSP]` when `ret` runs.
* Locals are addressed relative to `RBP` (a fixed anchor) because `RSP` can move. They sit at *negative* offsets because the stack grows down.
* `mov rsp, rbp` followed by `pop rbp` is exactly what `leave` does; it frees the locals no matter how much was allocated.
* After `ret`, `RSP` is back to `S`: call (+8 pushed) / ret (+8 popped), `push rbp` / `pop rbp` balanced, `sub 16` undone by `mov rsp,rbp`.

## Observations from running it
* Exit status `0`, no output.
* `RSP` sequence: `e1b0 → e1a8 → e1a0 → e1a0 → e190 → … → e1a0 → e1a8 → e1b0`.
* The return address on the stack was `0x401005`, which gdb confirms is `_start+5`, the instruction right after the 5-byte `call`.
* The two local slots were `0` right after `sub rsp,16`, then `0x64` and `0xc8` after the stores. `RAX`/`RBX` still hold 100/200 after return – registers survive, the locals do not (they are below `RSP` and will be overwritten by the next push or call).
