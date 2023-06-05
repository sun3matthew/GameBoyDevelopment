INCLUDE "inc/hardware.inc"

SECTION "MemPaletteCopy Routine", ROM0
; Copy Pallet 
; @param hl: Source
; @param de: Destination Register
PaletteCopy::
	ld b, 8
	.loop
		ld a, [hli]
		ld [de], a
		dec b
		jr nz, .loop
    ret

SECTION "MemCopy Routine", ROM0
; Copy bytes from one area to another.
; @param de: Source
; @param hl: Destination
; @param bc: Length
Memcopy::
    ld a, [de]
    ld [hli], a
    inc de
    dec bc ;? does not set any flags
    ld a, b
    or a, c
    jp nz, Memcopy
    ret

SECTION "MemSet Routine", ROM0
; Sets a block of memory to a value
; @param d: Value
; @param hl: Destination
; @param bc: Length
MemSet::
    ld a, d
    ld [hli], a
    dec bc
    ld a, b
    or a, c
    jp nz, MemSet
    ret
