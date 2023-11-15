    %include "src/enum.inc"
    %include "src/macro.inc"
    
    global main

    ; lex.asm
    extern putback
    extern nextc

    ; gen.asm
    extern gen

main:
    _enter

.start:
    call    nextc
    cmp     ax, _EOF
    je      .end
    mov     BYTE [putback], al

    call    gen

    jmp     .start

.end:
    _leave  0
