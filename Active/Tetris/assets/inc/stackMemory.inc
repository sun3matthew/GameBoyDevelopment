INCLUDE "inc/memoryBank.inc"

IF !DEF(STACK_INC) ;include guard
    DEF STACK_INC EQU 1

DEF STACK_MEM_BANKS          EQU %10000000
DEF STACK_MEM_BANK           EQU 0

DEF STACK_MEM_BANK_0         EQU 0

DEF STACK_HEADER_SIZE        EQU $1 * $10

DEF STACK_HEADER             EQU MEM_HEADER
DEF STACK_START              EQU STACK_HEADER + STACK_HEADER_SIZE


; allocate memory in stack memory, make sure to set bank to the correct bank
; @param \1: size of memory to allocate
; @return a: low byte of address
; @return hl: full address
MACRO StackMallocMacro
    ldh a, [hStackEndOfMemory + 1]
    ld l, a
    add \1
    ldh [hStackEndOfMemory + 1], a

    ldh a, [hStackEndOfMemory]
    ld h, a
ENDM

; Move to the next layer of the stack memory, without saving the current header
; @destroy a
MACRO StackPushNoSaveMacro
    ; save shadow header to current layer
    ldh a, [hStackEndOfMemory]
    inc a
    ldh [hStackEndOfMemory], a

    ld a, STACK_HEADER_SIZE
    ldh [hStackEndOfMemory + 1], a
ENDM

; allocate memory in stack memory, make sure to set bank to the correct bank
; @param l: low byte of address to store
; @param \1: var number
; @destroy a
MACRO StackStoreAddressMacro
    ld a, l
    ldh [hStackLowBytes + \1], a
ENDM

; terminate sequence of stack memory
; @destroy a
MACRO StackZeroTerminateMacro
    ld a, 0
    ldh [hStackLowBytes + \1], a
ENDM

; read address from stack memory
; @param \1: var number
; @return hl: address the address of data
; @destroy a
MACRO StackReadAddressMacro
    ldh a, [hStackEndOfMemory]
    ld h, a
    ldh a, [hStackLowBytes + \1]
    ld l, a
ENDM


    ENDC ;STACK_INC