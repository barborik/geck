    %include "src/enum.inc"
    %include "src/macro.inc"
    
    global main

    ; lex.asm
    extern putback

    ; gen.asm
    extern gen

    ; stdio.asm
    extern _getchar

main:
    _enter

.start:
    call    _getchar
    cmp     ax, _EOF
    je      .end
    mov     BYTE [putback], al

    call    gen

    jmp     .start

.end:
    _leave  0
