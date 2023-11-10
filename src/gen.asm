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

    cmp     WORD [token + 1], _MOV
    je      ._MOV

    cmp     WORD [token + 1], _ADD
    je      ._ADD

._MOV:
    call    __MOV
    jmp     .end

._ADD:
    call    __ADD
    jmp     .end

.end:
    _leave  0
