    %include "src/enum.inc"
    %include "src/macro.inc"
    %include "src/extern.inc"

    global gen

    ; lex.asm
    extern scan
    extern token

gen:
    _enter
    call    scan

    cmp     WORD [token + 2], _MOV
    jne     .L1
    call    __MOV
    _leave  0
.L1:

    cmp     WORD [token + 2], _ADD
    jne     .L2
    call    __ADD
    _leave  0
.L2:
