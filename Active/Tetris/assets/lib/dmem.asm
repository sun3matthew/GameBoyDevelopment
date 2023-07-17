INCLUDE "inc/heapMemory.inc"
INCLUDE "inc/stackMemory.inc"

SECTION "DMEM_TYPE", HRAM
    hMallocAddress:  ds 2
    hFreeAddress:    ds 2

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

    ld a, 0
    ; call DmemUpdateType
    ; ret 


; Update Type Between Heap and Stack
; @param a: 0 for heap, 1 for stack
DmemUpdateType::
    cp 1
    jr z, .DmemUpdateStackType
        ld a, HIGH(HeapMalloc)
        ldh [hMallocAddress], a
        ld a, LOW(HeapMalloc)
        ldh [hMallocAddress + 1], a

        ld a, HIGH(HeapFreeAbstract)
        ldh [hFreeAddress], a
        ld a, LOW(HeapFreeAbstract)
        ldh [hFreeAddress + 1], a
    ret
    .DmemUpdateStackType
        ld a, HIGH(StackMalloc)
        ldh [hMallocAddress], a
        ld a, LOW(StackMalloc)
        ldh [hMallocAddress + 1], a

        ld a, HIGH(StackFreeAbstract)
        ldh [hFreeAddress], a
        ld a, LOW(StackFreeAbstract)
        ldh [hFreeAddress + 1], a
        ret

; Malloc
; @param de: size
; @return hl: address
; @destroy a, de, bc
Malloc::
    ldh a, [hMallocAddress]
    ld h, a
    ldh a, [hMallocAddress + 1]
    ld l, a
    jp hl

; Free
; @param hl: address to free
; @destroy all
Free::
    push hl

    ldh a, [hFreeAddress]
    ld h, a
    ldh a, [hFreeAddress + 1]
    ld l, a
    jp hl

