INCLUDE "inc/hardware.inc"

SECTION "VBlank", ROM0
; Wait for VBlank
WaitVBlank::
	ld a, [rLY]
	cp 144
	jp nz, WaitVBlank
	ret


SECTION "Frame Counters", ROM0
AddFrameCounter::

SECTION "Frame Counters Ptr", ROM0
FrameCountersPtr::
	ds 2, 0
