INCLUDE "inc/hardware.inc"

SECTION "MEM", ROM0
; Copy Pallet 
; @param hl: Source
; @param de: Destination Register
; @destroy: a, b, hl
PaletteCopy::
	ld b, 8
	.loop
		ld a, [hli]
		ld [de], a
		dec b
		jr nz, .loop
    ret

; Copy bytes from one area to another.
; @param de: Source
; @param hl: Destination
; @param bc: Length
; @return: hl: end
; @destroy: a, bc, de, hl
MemcopyLen::
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c

    jp nz, MemcopyLen
    ret

; Copy bytes from one area to another.
; @param de: Source
; @param bc: End
; @param hl: Destination
; @return: hl: end
; @destroy: a, bc, de, hl
Memcopy::
    call SUBr16r16
    call MemcopyLen
    ret

; Sets a block of memory to a value
; @param d: Value
; @param hl: Destination
; @param bc: Length
; @destroy: a, bc, hl
MemSet::
    ld a, d
    ld [hli], a
    dec bc
    ld a, b
    or a, c
    jp nz, MemSet
    ret
