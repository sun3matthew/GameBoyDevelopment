INCLUDE "inc/hardware.inc"
INCLUDE "inc/stackMemory.inc"
INCLUDE "inc/memoryBank.inc"

SECTION "STACK_MEMORY_HRAM", HRAM, ALIGN[4]
    hStackLowBytes:: ds STACK_HEADER_SIZE
    hStackEndOfMemory:: ds 2

SECTION "STACK_MEMORY", ROM0
; Metadata wram:
;   2 bytes for end of memory
;   2 bytes for previous end of memory
;   2 bytes for addresss storage - address of current pos
;*  Stored in little-endian

; Metadata shadow hram:
;   1 byte for high byte
;   16 bytes for 15 addresses of low bytes, zero terminated

; Header Structure:
;   16 bytes for low data, zero terminated
;   rest is just data.

; Stack structure:
;   16 layers deep
;   256 bytes per layer 
;      16 bytes low bytes of address
;      240 bytes of data
;   17 bytes in hram for storage of 16 vars (copied from header in layer)



; clean dmem
; @destroy a, hl
StackResetBank::
    ld a, HIGH(STACK_START)
    ld [hStackEndOfMemory], a
    ld a, LOW(STACK_START)
    ld [hStackEndOfMemory], a

    ; clear hram to zero
    ld d, 0
    ld hl, hStackLowBytes
    ld bc, 16; 16 low bytes + 1 high byte
    call MemSet

    ret


; allocate memory in stack memory, make sure to set bank to the correct bank
; @param e: size
; @return hl: address
StackMalloc::
    StackMallocMacro e
    ret


; This concept does not exist.
StackFreeAbstract::
    pop hl
StackFree::
    ret

; Move on the the next layer of the stack memory
; @destroy hl, de, a
StackPush::
    ; save shadow header to current layer
    ldh a, [hStackEndOfMemory]
    ld h, a
    ld l, 0

    ; store new high byte
    inc a
    ldh [hStackEndOfMemory], a

    ld de, hStackLowBytes
    .loop
        ld a, [de]
        ld [hli], a
        inc de
        cp 0
        jp nz, .loop

    ; calculate new low byte of memory
    ld a, STACK_HEADER_SIZE
    ldh [hStackEndOfMemory + 1], a
    ret

; Move to the next layer of the stack memory, without saving the current header
; @destroy a
StackPushNoSave::
    StackPushNoSaveMacro
    ret

; Return to the previous layer of the stack memory
; @destroy hl, de, a
StackPop::
    ; update shadow header with current layer
    ldh a, [hStackEndOfMemory]
    dec a
    ld d, a
    ld e, 0

    ldh [hStackEndOfMemory], a

    ld hl, hStackLowBytes
    .loop
        ld a, [de]
        ld [hli], a
        inc de
        cp 0
        jp nz, .loop


    ; calculate new end of memory
    ld a, STACK_HEADER_SIZE
    ldh [hStackEndOfMemory + 1], a
    ret