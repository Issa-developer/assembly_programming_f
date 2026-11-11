# 04.asm – Function with a stack frame (32-bit / i386)

Source: [`../04.asm`](../04.asm) · Full trace: [`output.txt`](output.txt)

## What I did
In the `07_stack` folder I assembled (32-bit), linked and ran `04.asm`, then single-stepped it in gdb. In the `07_stack/04` folder I saved the run and trace as `output.txt` and wrote this README.

## What the program does
Same logic as `02.asm` but written for 32-bit (`BITS 32`): `_start` calls `work`; `work` creates a frame with `ebp`/`esp`, reserves 8 bytes, stores 100 and 200, loads them into `EAX`/`EBX`, and returns. Exit uses the i386 syscall `int 0x80` (`eax=1`).

## How I ran it
```bash
nasm -f elf32 -g -F dwarf 04.asm -o 04.o
ld -m elf_i386 04.o -o stack_04
./stack_04 ; echo $?                          # -> 0
gdb -q -batch -x ../trace32.gdb ./stack_04
```

## Stack walkthrough
Slots are **4 bytes** here, so every push/pop/call changes `ESP` by 4. Let `S = 0xffffd2d0` (points at `argc`).

| Instruction | ESP after | EBP after | Effect |
|---|---|---|---|
| (start) | `S` (`d2d0`) | 0 | `argc` on top |
| `call work` | `d2cc` (−4) | 0 | pushes return address `0x08049005` |
| `push ebp` | `d2c8` (−4) | 0 | saves old EBP (0) |
| `mov ebp,esp` | `d2c8` | `d2c8` | frame base |
| `sub esp,8` | `d2c0` | `d2c8` | 8 bytes of locals |
| `mov [ebp-4],100` | `d2c0` | `d2c8` | local #1 @`d2c4` = `0x64` |
| `mov [ebp-8],200` | `d2c0` | `d2c8` | local #2 @`d2c0` = `0xc8` |
| `mov eax,[ebp-4]` / `mov ebx,[ebp-8]` | `d2c0` | `d2c8` | `EAX=0x64`, `EBX=0xc8` |
| `mov esp,ebp` | `d2c8` | `d2c8` | locals released |
| `pop ebp` | `d2cc` | 0 | restore caller's EBP |
| `ret` | `d2d0` | 0 | pops `0x08049005` into EIP |
| `mov eax,1`, `xor ebx,ebx`, `int 0x80` | `d2d0` | 0 | exit(0) |

Frame while in `work`:
```
d2d0  argc
d2cc  return address 0x08049005   <- pushed by call
d2c8  saved EBP (0)               <- EBP
d2c4  local #1 = 100  [ebp-4]
d2c0  local #2 = 200  [ebp-8]     <- ESP
```

### Explanation
* The mechanism is identical to the 64-bit version; only the word size changes: 4-byte return address, 4-byte saved `EBP`, 4-byte locals, `ESP` steps of 4.
* `ESP` sequence: `d2d0 → d2cc → d2c8 → d2c0 → … → d2c8 → d2cc → d2d0`. It ends where it started, proving the frame was cleaned up properly.
* Locals are reached through `EBP` at negative offsets; `sub esp,8` sized the space for exactly two dword locals.

## Observations from running it
* Exit status `0`, no output.
* Addresses are 32-bit (`0x08049…` code, `0xffffd…` stack); the return address `0x08049005` is `_start+5`, right after the 5-byte `call` at `0x08049000`.
* The locals were `0` right after `sub esp,8`, then `0x64`/`0xc8` after the two `mov`s.
* `EAX`/`EBX` still hold 100/200 after `ret`, while the stack slots that held them are now below `ESP`.
