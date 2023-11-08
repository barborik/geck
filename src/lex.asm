    %include "src/enum.inc"
    %include "src/macro.inc"

    global scan
    global token

    ; stdio.asm
    extern _getchar

    ; util.asm
    extern isdigit
    extern djb_hash

    section .bss

; +------+------------------------------------+
; | byte | structure member                   |
; +------+------------------------------------+
; |  1   | TOKEN (macro.asm)                  |
; +------+------------------------------------+
; |  2   | VALUE (macro.asm or literal value) |
; |  3   |                                    |
; +------+------------------------------------+
token:  resb  3

    section .text

; reads the next non-whitespace character
;
; returns:
;   WORD - character read
nextc:
    _enter
.loop:
    call    _getchar

    cmp     ax, ' '
    je      .loop
    cmp     ax, `\r`
    je      .loop
    cmp     ax, `\n`
    je      .loop
    cmp     ax, `\t`
    je      .loop
    cmp     ax, `\f`
    je      .loop

    _leave 0

; scan the next lexical token and store it in the token structure
scan:
    _enter
.read:
    call    nextc
    cmp     ax, _EOF
    je      .end

    ; register
    cmp     ax, '%'
    jne     .L1
    call    djb_hash
    mov     BYTE [token + 0], _REG
    mov     WORD [token + 1], ax

    _leave  0
.L1:

    ; literal
    cmp     ax, '$'
    jne     .L2
    call    parse
    mov     BYTE [token + 0], _LIT
    mov     WORD [token + 1], ax

    _leave  0
.L2:

    ; instruction
    call    djb_hash
    mov     BYTE [token + 0], _INS
    mov     WORD [token + 1], ax

.end:
    _leave  0


parse:
    _enter
    mov     cx, 0

.read:
    call    _getchar
    mov     bx, ax
    push    ax
    call    isdigit
    cmp     ax, 1
    jne     .end

    mov     ax, 10
    mul     cx
    mov     cx, ax

    mov     ax, bx
    sub     ax, '0'
    add     cx, ax

    jmp     .read

.end:
    mov     ax, cx
    _leave  0
