    %include "src/enum.inc"
    %include "src/macro.inc"

    global __ADD

    ; lex.asm
    extern scan
    extern token

    ; stdio.asm
    extern _putchar

__ADD:
    _enter
    _leave
