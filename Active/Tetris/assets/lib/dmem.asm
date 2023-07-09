INCLUDE "inc/heapMemory.inc"
INCLUDE "inc/stackMemory.inc"

SECTION "DMEM", ROM0
; master memory allocation functions, heap & stack
; abstract malloc and free functions

; reset memory banks for dmem
DmemReset::
    ld a, HEAP_MEM_BANKS
    ld hl, HeapResetBank
    call ResetAllBanks

    ld a, STACK_MEM_BANKS
    ld hl, StackResetBank
    call ResetAllBanks
    ret 




