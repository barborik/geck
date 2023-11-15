_EOF:   equ -1

; TOKEN
_INS:   equ 1 ; instruction
_REG:   equ 2 ; register
_LIT:   equ 3 ; literal
_LBL:   equ 6 ; label

; OPERATION SIZE
_BYTE:  equ 1
_WORD:  equ 2

; REGISTERS
_AX:    equ 0
_BX:    equ 3
_CX:    equ 1
_DX:    equ 2

_AL:    equ 0
_AH:    equ 4

_BL:    equ 3
_BH:    equ 7

_CL:    equ 1
_CH:    equ 5

_DL:    equ 2
_DH:    equ 6

; the following values are not just magic numbers
; they are a product of hashing the corresponding string
; via a hash function defined in either ./hash.c or ./src/util.asm

; INSTRUCTIONS
_MOV:   equ 0xC7D1
_ADD:   equ 0xB664
