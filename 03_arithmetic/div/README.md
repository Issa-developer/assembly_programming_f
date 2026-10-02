# Division and EFLAGS

Both programs were assembled, run, and stepped with GDB immediately after
`div`. Unsigned `DIV` produces a quotient and remainder but leaves the
arithmetic status flags undefined. Consequently, none of `CF`, `PF`, `AF`,
`ZF`, `SF`, or `OF` can correctly be reported as set or cleared from these
executions. Any bits GDB happens to display are not guaranteed results of
division and must not be used to infer the quotient or remainder.

## `div1.asm` - 16-bit dividend divided by 8-bit divisor

`AX = 100`, divided by `BL = 7`, gives quotient `AL = 14` and remainder
`AH = 2`, because `100 = (14 * 7) + 2`.

| Flag | Status | Why |
| --- | --- | --- |
| CF, PF, AF, ZF, SF, OF | Undefined | `DIV` does not define these arithmetic flags. |

## `div2.asm` - 32-bit dividend divided by 16-bit divisor

`DX:AX = 50000`, divided by `BX = 300`, gives quotient `AX = 166` and
remainder `DX = 200`, because `50000 = (166 * 300) + 200`.

| Flag | Status | Why |
| --- | --- | --- |
| CF, PF, AF, ZF, SF, OF | Undefined | `DIV` does not define these arithmetic flags. |