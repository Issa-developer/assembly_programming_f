# Addition and EFLAGS

Both programs were assembled, run, and stepped with GDB immediately after `add`.
The flag descriptions below are based on the operation's result and operand
width, not on the debugger's display alone.

## `add1.asm` - 8-bit addition

`120 + 10 = 130`. In an 8-bit register, the result is `0x82` (binary
`10000010`). As signed 8-bit values, the operands sum to 130, which is above
the maximum 127 and therefore wraps to -126.

| Flag | Status | Why |
| --- | --- | --- |
| CF | Cleared | The unsigned sum 130 fits in 8 bits; there is no carry out of bit 7. |
| OF | Set | The positive signed operands produce a negative 8-bit result because 130 exceeds 127. |
| SF | Set | Bit 7 of `0x82` is 1. |
| ZF | Cleared | The result is nonzero. |
| AF | Set | `0x8 + 0xA` carries from the low nibble into bit 4. |
| PF | Set | The low byte `0x82` has two 1 bits, an even number. |

## `add2.asm` - 16-bit addition

`32000 + 500 = 32500` (`0x7EF4`). It fits both the unsigned 16-bit range and
the signed 16-bit range, so neither carry nor signed overflow occurs.

| Flag | Status | Why |
| --- | --- | --- |
| CF | Cleared | The sum is less than `65536`, so there is no carry out of bit 15. |
| OF | Cleared | 32500 is within the signed 16-bit range, -32768 through 32767. |
| SF | Cleared | Bit 15 of `0x7EF4` is 0. |
| ZF | Cleared | The result is nonzero. |
| AF | Cleared | The low nibbles add as `0 + 4`, with no carry into bit 4. |
| PF | Cleared | The low byte `0xF4` has five 1 bits, an odd number. |