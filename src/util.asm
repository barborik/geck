    %include "src/macro.inc"

    global isalpha
    global isdigit
    global djb_hash

    ; stdio.asm
    extern _getchar

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


djb_hash:
    _enter
    mov     cx, 0xAB

.read:
    call    _getchar
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
    mov     ax, cx
    _leave  0
