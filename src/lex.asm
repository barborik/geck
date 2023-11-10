    %include "src/enum.inc"
    %include "src/macro.inc"

    ; bss section
    global token
    global size
    global putback

    ; text section
    global nextc
    global scan

    ; stdio.asm
    extern _getchar

    ; util.asm
    extern isdigit
    extern djb_hash

    section .bss

; token structure
; +--------+------------------------------------+
; | offset | structure member                   |
; +--------+------------------------------------+
; |  0     | TOKEN (enum.inc)                   |
; +--------+------------------------------------+
; |  1     | VALUE (enum.inc or literal value)  |
; |  2     |                                    |
; +--------+------------------------------------+
token:      resb 3

; operation size (enum.inc)
size:       resb 1

; store a character here if it was read, but not used
putback:    resb 1

    section .text

; reads the next non-whitespace character
;
; returns:
;   WORD - character read
nextc:
    _enter
.loop:
    xor     ax, ax
    mov     al, [putback]

    cmp     al, 0
    jne     .end

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

.end:
    mov     BYTE [putback], 0
    _leave 0

; scan the next lexical token and store it in the token structure
scan:
    _enter
.read:
    call    nextc
    cmp     ax, _EOF
    je      .end

    ; comma separator
    cmp     ax, ','
    jne     .L1
    call    nextc
.L1:

    ; register
    cmp     ax, '%'
    jne     .L2
    call    reg
    mov     BYTE [token + 0], _REG
    mov     WORD [token + 1], ax

    _leave  0
.L2:

    ; literal
    cmp     ax, '$'
    jne     .L3
    call    parse
    mov     BYTE [token + 0], _LIT
    mov     WORD [token + 1], ax

    _leave  0
.L3:

    ; unprefixed
    mov     [putback], al

    ; instruction
    call    djb_hash
    mov     BYTE [token + 0], _INS
    mov     WORD [token + 1], ax

.end:
    _leave  0


; TODO: ADD DESC
reg:
    _enter
    call    nextc
    mov     BYTE [size], _WORD

    cmp     ax, 'A'
    je      .A

    cmp     ax, 'B'
    je      .B

    cmp     ax, 'C'
    je      .C

    cmp     ax, 'D'
    je      .D

.A:
    mov     bx, _AX
    jmp     .next

.B:
    mov     bx, _BX
    jmp     .next

.C:
    mov     bx, _CX
    jmp     .next

.D:
    mov     bx, _DX
    jmp     .next

.next:
    call    nextc

    cmp     ax, 'L'
    je      .L

    cmp     ax, 'H'
    je      .H

    mov     ax, bx
    _leave  0

.H:
    add     bx, 4
.L:
    mov     ax, bx
    mov     BYTE [size], _BYTE
    _leave  0

; parse a decimal integer
;
; returns:
;   WORD - the integer
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
