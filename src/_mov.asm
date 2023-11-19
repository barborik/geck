    %include "src/enum.inc"
    %include "src/macro.inc"

    global __MOV

    ; lex.asm
    extern scan
    extern size
    extern last
    extern token

    ; util.asm
    extern encode

    ; stdio.asm
    extern _putchar
    extern putword

__MOV:
    _enter
    call    scan
    call    scan

    mov     al, [last]
    cmp     al, [token]
    je      ._R_R

    cmp     BYTE [last], _IMM
    je      ._IMM_R

    cmp     BYTE [token], _IMM
    je      ._R_IMM

    ; MOV R8, IMM
._R_IMM:
    cmp     BYTE [size], _WORD
    je      ._R_IMM_16

    ; write opcode
    mov     ax, 0xB0
    add     ax, [last + 2]
    push    ax
    call    _putchar

    ; write operand
    push    WORD [token + 2]
    call    _putchar

    _leave  0

    ; MOV R16, IMM
._R_IMM_16:
    ; write opcode
    mov     ax, 0xB8
    add     ax, [last + 2]
    push    ax
    call    _putchar

    ; write operand
    push    WORD [token + 2]
    call    putword

    _leave  0

    ; MOV R8/(R8), R8
._R_R:
    ; encode operand
    push    WORD [token + 2] ; second reg
    push    WORD [last  + 2] ; first reg
    call    encode

    cmp     BYTE [last + 1], 0
    jne     .noderef
    or      ax, 0xC0
.noderef:
    push    ax

    cmp     BYTE [size], _WORD
    je      ._R_R_16

    ; write opcode
    push    WORD 0x88
    call    _putchar

    ; write operand

    ; exception for (%BP) which doesnt have its own encoding
    ; this is a workaround that encodes it as (%BP + $0)
    cmp     WORD [last + 2], _D_BP
    jne     .bpexcept_8
    pop     ax
    or      al, 0x40
    push    ax
    call    _putchar
    push    WORD 0
    call    _putchar
    _leave  0
.bpexcept_8:

    call    _putchar

    _leave  0

    ; MOV R16/(R16), R16
._R_R_16:
    ; write opcode
    push    WORD 0x89
    call    _putchar

    ; write operand

    ; exception for (%BP) which doesnt have its own encoding
    ; this is a workaround that encodes it as (%BP + $0)
    cmp     WORD [last + 2], _D_BP
    jne     .bpexcept_16
    pop     ax
    or      al, 0x40
    push    ax
    call    _putchar
    push    WORD 0
    call    _putchar
    _leave  0
.bpexcept_16:

    call    _putchar

    _leave  0

    ; MOV (IMM), R8 
._IMM_R:
    ; encode operand
    push    WORD [token + 2]
    push    WORD 0x6
    call    encode
    push    ax

    cmp     BYTE [size], _WORD
    je      ._IMM_R_16

    ; write opcode
    push    WORD 0x88
    call    _putchar

    ; write operands
    call    _putchar
    push    WORD [last + 2]
    call    putword

    _leave  0

    ; MOV (IMM), R16
._IMM_R_16:
    ; write opcode
    push    WORD 0x89
    call    _putchar

    ; write operands
    call    _putchar
    push    WORD [last + 2]
    call    putword

    _leave  0
