_EOF:   equ -1
_NULL:  equ 0

; TOKEN
_INS:   equ 1 ; instruction
_REG:   equ 2 ; register
_IMM:   equ 3 ; immediate value
_LBL:   equ 6 ; label

; REGISTERS
_AX:    equ 0
_BX:    equ 3
_CX:    equ 1
_DX:    equ 2
_SP:    equ 4
_BP:    equ 5
_SI:    equ 6
_DI:    equ 7

_AL:    equ 0
_AH:    equ 4

_BL:    equ 3
_BH:    equ 7

_CL:    equ 1
_CH:    equ 5

_DL:    equ 2
_DH:    equ 6

; DEREFERENCED REGISTERS
_D_SI:  equ 4
_D_DI:  equ 5
_D_BX:  equ 7

; DEREFERENCED BASE POINTER + BYTE OFFSET
_D_BP:  equ 6

; the following values are not just magic numbers
; they are a product of hashing the corresponding string
; via a hash function defined in either ./hash.c or ./src/util.asm

; OPERATION SIZE
_BYTE:  equ 0x0F
_WORD:  equ 0x6B

; INSTRUCTIONS
_MOV:   equ 0xC7D1
_ADD:   equ 0xB664
