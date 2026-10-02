# Multiplication and EFLAGS

Both programs were assembled, run, and stepped with GDB immediately after
`mul`. For unsigned `MUL`, `CF` and `OF` are set together when the upper half
of the full product is nonzero. The other arithmetic flags are undefined by
the instruction; their observed bit values must not be interpreted as a
result condition.

## `mul1.asm` - 8-bit multiplication

`25 * 10 = 250` (`AX = 0x00FA`). The upper half of this 8-by-8-bit product is
`AH = 0`, so the product fits in `AL`.

| Flag | Status | Why |
| --- | --- | --- |
| CF | Cleared | `AH` is zero, so the product fits in the low 8-bit half. |
| OF | Cleared | `AH` is zero; unsigned `MUL` uses the same upper-half condition for `OF`. |
| PF, AF, ZF, SF | Undefined | `MUL` does not define these flags. |

## `mul2.asm` - 16-bit multiplication

`3000 * 200 = 600000` (`DX:AX = 0x0009:0x27C0`). Since `DX` is nonzero, the
product does not fit in the low 16-bit half.

| Flag | Status | Why |
| --- | --- | --- |
| CF | Set | `DX` is nonzero, indicating significant bits above the low 16 bits. |
| OF | Set | The upper half `DX` is nonzero; this is the same condition as for `CF`. |
| PF, AF, ZF, SF | Undefined | `MUL` does not define these flags. |