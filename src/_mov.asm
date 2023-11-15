    %include "src/enum.inc"
    %include "src/macro.inc"

    global __MOV

    ; lex.asm
    extern scan
    extern size
    extern last
    extern token

    ; util.asm
    extern encode_rr
    extern encode_mr

    ; stdio.asm
    extern _putchar
    extern putword

__MOV:
    _enter
    call    scan
    call    scan

    mov     al, [last]
    and     al, 0x80
    cmp     al, 0
    jl      ._MI_R

    cmp     BYTE [token], _REG
    je      ._R_R

    cmp     BYTE [token], _LIT
    je      ._R_IMM

    ; MOV R8, IMM
._R_IMM:
    cmp     BYTE [size], _WORD
    je      ._R_IMM_16

    ; write opcode
    mov     ax, 0xB0
    add     ax, [last + 1]
    push    ax
    call    _putchar

    ; write operand
    push    WORD [token + 1]
    call    _putchar

    _leave  0

    ; MOV R16, IMM
._R_IMM_16:
    ; write opcode
    mov     ax, 0xB8
    add     ax, [last + 1]
    push    ax
    call    _putchar

    ; write operand
    push    WORD [token + 1]
    call    putword

    _leave  0

    ; MOV R8, R8
._R_R:
    ; encode operand
    push    WORD [token + 1] ; second reg
    push    WORD [last  + 1] ; first reg
    call    encode_rr
    push    ax

    cmp     BYTE [size], _WORD
    je      ._R_R_16

    ; write opcode
    push    WORD 0x88
    call    _putchar
    ; write operand
    call    _putchar

    _leave  0

    ; MOV R16, R16
._R_R_16:
    ; write opcode
    push    WORD 0x89
    call    _putchar
    ; write operand
    call    _putchar

    _leave  0

    ; MOV M(IMM)16, R8 
._MI_R:
    ; encode operand
    push    WORD [token + 1] ; reg
    call    encode_mr
    push    ax

    cmp     BYTE [size], _WORD
    je      ._MI_R_16

    ; write opcode
    push    WORD 0x88
    call    _putchar

    ; write operands
    call    _putchar
    push    WORD [last + 1]
    call    putword

    ; MOV M(IMM)16, R16
._MI_R_16:
    ; write opcode
    push    WORD 0x89
    call    _putchar

    ; write operands
    call    _putchar
    push    WORD [last + 1]
    call    putword

    _leave  0