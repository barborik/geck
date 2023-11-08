    %include "src/enum.inc"
    %include "src/macro.inc"

    global __MOV

    ; lex.asm
    extern scan
    extern token

    ; stdio.asm
    extern _putchar

__MOV:
    _enter
    call    scan

    cmp     WORD [token + 1], _AX
    je      ._AX

    cmp     WORD [token + 1], _BX
    je      ._BX

    cmp     WORD [token + 1], _CX
    je      ._CX

    cmp     WORD [token + 1], _DX
    je      ._DX

    cmp     WORD [token + 1], _AX
    je      ._AL

    cmp     WORD [token + 1], _AX
    je      ._AH

    cmp     WORD [token + 1], _AX
    je      ._BL

    cmp     WORD [token + 1], _AX
    je      ._BH

    cmp     WORD [token + 1], _AX
    je      ._CL

    cmp     WORD [token + 1], _AX
    je      ._CH

    cmp     WORD [token + 1], _AX
    je      ._DL

    cmp     WORD [token + 1], _AX
    je      ._DH

    ; MOV R16, IMM

._AX:
    push    WORD 0xB8
    call    _putchar
    jmp     .end16

._BX:
    push    WORD 0xBB
    call    _putchar
    jmp     .end16

._CX:
    push    WORD 0xB9
    call    _putchar
    jmp     .end16

._DX:
    push    WORD 0xBA
    call    _putchar
    jmp     .end16

    ; MOV R8, IMM

._AL:
    push    WORD 0xB0
    call    _putchar
    jmp     .end8

._AH:
    push    WORD 0xB4
    call    _putchar
    jmp     .end8

._BL:
    push    WORD 0xB3
    call    _putchar
    jmp     .end8

._BH:
    push    WORD 0xB7
    call    _putchar
    jmp     .end8

._CL:
    push    WORD 0xB1
    call    _putchar
    jmp     .end8

._CH:
    push    WORD 0xB5
    call    _putchar
    jmp     .end8

._DL:
    push    WORD 0xB2
    call    _putchar
    jmp     .end8

._DH:
    push    WORD 0xB6
    call    _putchar
    jmp     .end8

    ; OPERAND

.end8:
    call    scan
    push    WORD [token + 1]
    call    _putchar
    _leave  0

.end16:
    call    scan
    push    WORD [token + 1]
    call    _putchar
    push    WORD [token + 2]
    call    _putchar
    _leave  0
