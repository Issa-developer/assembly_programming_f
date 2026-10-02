# Subtraction and EFLAGS

Both programs were assembled, run, and stepped with GDB immediately after
`sub`. `CF` reports an unsigned borrow; `OF` separately reports signed
overflow, so they can differ.

## `sub1.asm` - 8-bit subtraction

`50 - 80` produces `-30`, represented in 8 bits as `0xE2`. The unsigned
subtraction needs a borrow, while -30 is representable as a signed 8-bit
value.

| Flag | Status | Why |
| --- | --- | --- |
| CF | Set | Unsigned 50 is less than 80, so subtraction borrows. |
| OF | Cleared | The signed result -30 is within -128 through 127. |
| SF | Set | Bit 7 of `0xE2` is 1. |
| ZF | Cleared | The result is nonzero. |
| AF | Cleared | The low nibble subtracts as `0x2 - 0x0`, with no borrow from bit 4. |
| PF | Set | The low byte `0xE2` has four 1 bits, an even number. |

## `sub2.asm` - 16-bit subtraction

`1000 - 2000 = -1000`, represented in 16 bits as `0xFC18`. It borrows as an
unsigned subtraction, but -1000 is within the signed 16-bit range.

| Flag | Status | Why |
| --- | --- | --- |
| CF | Set | Unsigned 1000 is less than 2000, so subtraction borrows. |
| OF | Cleared | The signed result -1000 is within -32768 through 32767. |
| SF | Set | Bit 15 of `0xFC18` is 1. |
| ZF | Cleared | The result is nonzero. |
| AF | Cleared | The low nibbles subtract as `8 - 0`, with no borrow from bit 4. |
| PF | Set | The low byte `0x18` has two 1 bits, an even number. |