    %include "src/enum.inc"
    %include "src/macro.inc"

    ; bss section
    global token
    global last
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
; +--------+-----------------------------------------+
; | offset | structure member                        |
; +--------+-----------------------------------------+
; |  0     | TOKEN (enum.inc) MSb = 1 -> dereference |
; +--------+-----------------------------------------+
; |  1     | VALUE (enum.inc or literal value)       |
; |  2     |                                         |
; +--------+-----------------------------------------+
token:      resb 3

; last token
last:       resb 3
; temporary token
temp:       resb 3

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
; sets the global token and last (token) structures
scan:
    _enter
.read:
    call    nextc
    cmp     ax, _EOF
    je      .end

    ; change last token
    mov     bl, [token + 0]
    mov     [last + 0], bl
    mov     bx, [token + 1]
    mov     [last + 1], bx

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

    ; dereference
    cmp     ax, '('
    jne     .L4

    ; save last token
    mov     bl, [last + 0]
    mov     [temp + 0], bl
    mov     bx, [last + 1]
    mov     [temp + 1], bx

    ; parse the actual token
    call    scan

    ; recover last token
    mov     bl, [temp + 0]
    mov     [last + 0], bl
    mov     bx, [temp + 1]
    mov     [last + 1], bx

    ; set token MSb to 1
    mov     al, [token + 0]
    or      al, 0x80
    mov     [token + 0], al

    ; get the ending ')'
    call    nextc

    _leave  0
.L4:

    ; unprefixed
    mov     [putback], al

    ; instruction
    call    djb_hash
    mov     BYTE [token + 0], _INS
    mov     WORD [token + 1], ax

.end:
    _leave  0


; loads the next register and sets operation size accordingly
;
; returns:
;   WORD - internal register value from enum.inc
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

    ; Horner's method moment
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
