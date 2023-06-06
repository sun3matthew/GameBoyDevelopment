INCLUDE "inc/hardware.inc"

SECTION "VBlank", ROM0
; Wait for VBlank
WaitVBlank::
	ld a, [rLY]
	cp 144
	jp nz, WaitVBlank
	ret
