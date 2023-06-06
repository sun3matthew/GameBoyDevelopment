INCLUDE "inc/hardware.inc"

SECTION "VRAM DMA routine", ROM0
; Start a VRAM DMA transfer.
; @param de: Source
; @param hl: Destination
; @param b: Length
VRAMDMA::
	; apparently the VRAM DMA transfer does not have the same restrictions on memory like the OAM DMA
	; yea, it just fully pauses the cpu untill the transfer is finished
	ld a, d
	ld [rHDMA1], a
	ld a, e
	ld [rHDMA2], a

	ld a, h
	ld [rHDMA3], a
	ld a, l
	ld [rHDMA4], a

	ld a, b
	ld [rHDMA5], a
	ret

SECTION "OAM DMA routine", ROM0
; Init the DMA routine in HRAM
CopyDMARoutine::
	ld  hl, DMARoutine
	ld  b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
	ld  c, LOW(hOAMDMA) ; Low byte of the destination address
.copy
	ld  a, [hli]
	ldh [c], a
	inc c
	dec b
	jr  nz, .copy
	ret

DMARoutine:
	ldh [rDMA], a
	
	ld  a, 40
.wait
	dec a
	jr  nz, .wait
	ret
DMARoutineEnd:

SECTION "OAM DMA", HRAM
; Start an OAM DMA transfer.
; @param a: HIGH(source)
hOAMDMA::
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to
