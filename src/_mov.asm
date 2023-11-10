    %include "src/enum.inc"
    %include "src/macro.inc"

    global __MOV

    ; lex.asm
    extern scan
    extern size
    extern token

    ; stdio.asm
    extern _putchar

__MOV:
    _enter
    call    scan

    cmp     BYTE [size], _BYTE
    je      ._BYTE

    cmp     BYTE [size], _WORD
    je      ._WORD

    ; MOV R8, IMM

._BYTE:
    mov     ax, 0xB0
    add     ax, [token + 1]

    push    ax
    call    _putchar

    jmp     .end8

    ; MOV R16, IMM

._WORD:
    mov     ax, 0xB8
    add     ax, [token + 1]

    push    ax
    call    _putchar

    jmp     .end16

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
