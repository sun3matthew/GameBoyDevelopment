INCLUDE "inc/hardware.inc"
INCLUDE "inc/stackMemory.inc"
INCLUDE "inc/memoryBank.inc"

SECTION "STACK_MEMORY_WRAM0", WRAM0
    wStackEndOfMemory:: ds 2
    wStackEndOfMemoryPrev:: ds 2
    wStackCurrentAddress:: ds 2

SECTION "STACK_MEMORY_HRAM", HRAM, ALIGN[4]
    wStackLowBytes:: ds 16
    wStackHighByte:: ds 1


SECTION "STACK_MEMORY", ROM0
; Metadata wram:
;   2 bytes for end of memory
;   2 bytes for previous end of memory
;   2 bytes for addresss storage - address of current pos

; Metadata shadow hram:
;   1 byte for high byte
;   16 bytes for 16 addresses of low bytes

; Header Structure:
;   16 bytes for low data
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
    ret

; allocate memory fast (does not fill fragmented memory) in wram bank, make sure to set bank to the correct bank, end of memory
; @param de: size
; @return hl: address
; @destroy a, de, bc
StackMallocFast::
    call StackMalloc
    ret

    
; allocate memory in wram bank, make sure to set bank to the correct bank, end of memory
; @param de: size
; @return hl: address
; @destroy all
StackMalloc::
    ret

; free memory in wram bank, make sure to set bank to the correct bank
; @param hl: address to free
; @destroy all
StackFree::
    ret