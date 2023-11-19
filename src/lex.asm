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
; |  0     | TOKEN (enum.inc)                        |
; +--------+-----------------------------------------+
; |  1     | DEREF (bool) dereference                |
; +--------+-----------------------------------------+
; |  2     | VALUE (enum.inc or immediate value)     |
; |  3     |                                         |
; +--------+-----------------------------------------+
token:      resb 4

; last token
last:       resb 4
; temporary token
temp:       resb 4

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
    call    nextc
    cmp     ax, _EOF
    je      .end

    ; operation size
    cmp     ax, '#'
    jne     .L0
    call    djb_hash
    mov     [size], al
    jmp     .end
.L0:

    ; change last token
    mov     bl, [token + 0]
    mov     [last + 0], bl
    mov     bl, [token + 1]
    mov     [last + 1], bl
    mov     bx, [token + 2]
    mov     [last + 2], bx

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
    mov     BYTE [token + 1], 0
    mov     WORD [token + 2], ax

    jmp     .end
.L2:

    ; immediate value
    cmp     ax, '$'
    jne     .L3
    call    parse
    mov     BYTE [token + 0], _IMM
    mov     BYTE [token + 1], 0
    mov     WORD [token + 2], ax

    jmp     .end
.L3:

    ; dereference
    cmp     ax, '('
    jne     .L4
    call    deref
    ; get the ending ')'
    call    nextc
    jmp     .end
.L4:

    ; unprefixed
    mov     [putback], al

    ; instruction
    call    djb_hash
    mov     BYTE [token + 0], _INS
    mov     WORD [token + 2], ax

.end:
    _leave  0


; modify register token values to its dereference counterparts
deref:
    _enter

    ; save last token
    mov     bl, [last + 0]
    mov     [temp + 0], bl
    mov     bl, [last + 1]
    mov     [temp + 1], bl
    mov     bx, [last + 2]
    mov     [temp + 2], bx

    ; parse the actual token
    call    scan
    ; set DEREF field to 1
    mov     BYTE [token + 1], 1

    ; recover last token
    mov     bl, [temp + 0]
    mov     [last + 0], bl
    mov     bl, [temp + 1]
    mov     [last + 1], bl
    mov     bx, [temp + 2]
    mov     [last + 2], bx

    ; modify token

    cmp     BYTE [token + 2], _SI
    jne     .L1
    mov     BYTE [token + 2], _D_SI
    jmp     .end
.L1:

    cmp     BYTE [token + 2], _DI
    jne     .L2
    mov     BYTE [token + 2], _D_DI
    jmp     .end
.L2:

    cmp     BYTE [token + 2], _BP
    jne     .L3
    mov     BYTE [token + 2], _D_BP
    jmp     .end
.L3:

    cmp     BYTE [token + 2], _BX
    jne     .L4
    mov     BYTE [token + 2], _D_BX
    jmp     .end
.L4:

.end:
    _leave  0


; loads the next register and sets operation size accordingly
;
; returns:
;   WORD - internal register value from enum.inc
reg:
    _enter
    call    nextc
    mov     bx, ax
    call    nextc

    mov     BYTE [size], _WORD

    ; exceptions (sp/bp/si/di)
    mov     cx, ax
    shl     cx, 8
    or      cx, bx

    cmp     cx, "SP"
    jne     .SP
    mov     ax, _SP
    jmp     .end
.SP:

    cmp     cx, "BP"
    jne     .BP
    mov     ax, _BP
    jmp     .end
.BP:

    cmp     cx, "SI"
    jne     .SI
    mov     ax, _SI
    jmp     .end
.SI:

    cmp     cx, "DI"
    jne     .DI
    mov     ax, _DI
    jmp     .end
.DI:

    ; general purpose registers
    cmp     bx, 'A'
    jne     .A
    mov     bx, _AX
    jmp     .next
.A:

    cmp     bx, 'B'
    jne     .B
    mov     bx, _BX
    jmp     .next
.B:

    cmp     bx, 'C'
    jne     .C
    mov     bx, _CX
    jmp     .next
.C:

    cmp     bx, 'D'
    jne     .D
    mov     bx, _DX
    jmp     .next
.D:

.next:
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
.end:
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
