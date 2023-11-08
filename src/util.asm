    %include "src/macro.inc"

    global isalpha
    global isdigit
    global djb_hash

    ; lex.asm
    extern nextc
    extern putback

; check if a character is a digit
;
; params:
;   [IN] BYTE - character to check
;
; returns:
;   1 if true, 0 if false
isdigit:
    _enter
    _param  ax, 0

    cmp     ax, '0'
    jl      .return

    cmp     ax, '9'
    jg      .return

    mov     ax, 1
    _leave  1

.return:
    mov     ax, 0
    _leave  1


; check if a character is alphabetical (UPPER CASE ONLY)
;
; params:
;   [IN] BYTE - character to check
;
; returns:
;   WORD - 1 if true, 0 if false
isalpha:
    _enter
    _param  ax, 0

    cmp     ax, 'A'
    jl      .return

    cmp     ax, 'Z'
    jg      .return

    mov     ax, 1
    _leave  1

.return:
    mov     ax, 0
    _leave  1


; simple hash function popularized by Dan Bernstein (djb)
; uses nextc for the keys, until a non-alphabetical character is reached
;
; returns:
;   WORD - the calculated hash
djb_hash:
    _enter
    mov     cx, 5381

.read:
    push    cx
    call    nextc
    pop     cx
    mov     bx, ax
    push    ax
    call    isalpha
    cmp     ax, 1
    jne     .end

    mov     ax, cx
    shl     ax, 5
    add     cx, ax
    xor     cx, bx

    jmp     .read

.end:
    mov     [putback], bl
    mov     ax, cx
    _leave  0
