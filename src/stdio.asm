    %include "src/macro.inc"
    
    global _getchar
    global _putchar
    global putword

    extern getchar
    extern putchar

; read one character from standard input
;
; returns:
;   WORD - character read
_getchar:
    _enter
    call    getchar
    _leave  0


; write one character to standard output
;
; params:
;   [IN] BYTE - character to write
_putchar:
    _enter
    _param  di, 0
    call    putchar
    _leave  1


; write a word, LSB first
;
; params:
;   [IN] WORD - the word to be written
putword:
    _enter
    _param  ax, 0

    xor     bx, bx
    mov     bl, al
    push    bx
    call    _putchar

    xor     bx, bx
    mov     bl, ah
    push    bx
    call    _putchar

    _leave  1
