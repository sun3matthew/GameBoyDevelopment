INCLUDE "inc/hardware.inc"
INCLUDE "inc/stack_memory.inc"


SECTION "Stack Bank 1", WRAMX, BANK[1]
    ds WRAM_SIZE

SECTION "STACK_MEMORY", ROM0
; Header Structure:
; 0xD000 - 0xD010: dmem metadata * don't try to skimp out of this sh~t, its required
;   1 byte for num entires of memory adresses 
;   1 byte for num entries of memory gaps
;   2 bytes for end of memory
;   2 bytes for temp data
; 0xD011 - 0xDFFF: memory


; clean dmem
; @destroy a, hl
Stack_reset::
    
    ret

; allocate memory fast (does not fill fragmented memory) in wram bank, make sure to set bank to the correct bank, end of memory
; @param de: size
; @return hl: address
; @destroy a, de, bc
Stack_mallocFast::
    call Stack_malloc
    ret

    
; allocate memory in wram bank, make sure to set bank to the correct bank, end of memory
; @param de: size
; @return hl: address
; @destroy all
Stack_malloc::
    ret

; free memory in wram bank, make sure to set bank to the correct bank
; @param hl: address to free
; @destroy all
Stack_free::
    ret