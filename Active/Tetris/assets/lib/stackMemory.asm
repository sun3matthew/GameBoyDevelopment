INCLUDE "inc/hardware.inc"
INCLUDE "inc/stackMemory.inc"
INCLUDE "inc/memoryBank.inc"

SECTION "STACK_MEMORY", ROM0
; Header Structure:
; 0xD000 - 0xD010: dmem metadata
;   1 byte for num entires of memory adresses 
;   1 byte for num entries of memory gaps
;   2 bytes for end of memory
;   2 bytes for temp data
; 0xD011 - 0xDFFF: memory


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