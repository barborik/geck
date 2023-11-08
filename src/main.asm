    %include "src/macro.inc"
    
    global main

    ; lex.asm
    extern scan
    extern token

    extern _putchar

main:
    _enter

    call    scan
    xor     ax, ax
    mov     al, [token]
    add     al, 65
    push    ax
    call    _putchar

    call    scan
    xor     ax, ax
    mov     al, [token]
    add     al, 65
    push    ax
    call    _putchar

    call    scan
    xor     ax, ax
    mov     al, [token]
    add     al, 65
    push    ax
    call    _putchar


    xor     ax, ax
    mov     ax, [token + 1]
    push    ax
    call    _putchar

    _leave 0
