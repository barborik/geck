    %include "src/macro.inc"
    
    global _getchar
    global _putchar

    extern getchar
    extern putchar

; read one character from standard input
;
; returns:
;   WORD - character read
_getchar:
    _enter
    call    getchar
    _leave 0


; write one character to standard output
;
; params:
;   [IN] BYTE - character to write
_putchar:
    _enter
    _param  di, 0
    call    putchar
    _leave 1
