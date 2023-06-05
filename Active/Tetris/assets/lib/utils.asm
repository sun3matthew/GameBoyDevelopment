INCLUDE "inc/hardware.inc"

SECTION "VBlank", ROM0
WaitVBlank::
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank
	ret