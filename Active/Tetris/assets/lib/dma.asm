INCLUDE "inc/hardware.inc"
INCLUDE "inc/dma.inc"

SECTION "Shadow OAM", WRAM0, ALIGN[8]
    wShadowOAM::
        ds SOAMS

SECTION "Shadow SCN", WRAM0, ALIGN[4]
    wShadowSCN_B0::
        ds SSCRNS
    wShadowSCN_B1::
        ds SSCRNS
    wShadowSCN_END::


SECTION "DMA", ROM0
; Init OAM Transfer HRAM and shadow DMA from current VRAM and OAM
InitDMA::
	call CopyDMARoutine

	; Init Shadow OAM
		ld de, _OAMRAM
		ld hl, wShadowOAM
		ld bc, SOAMS
		call MemcopyLen

	; Init Shadow Vram Tilemap
		ld a, 0
		ld [rVBK], a

		ld de, _SCRN0
		ld hl, wShadowSCN_B0
		ld bc, SSCRNS
		call MemcopyLen

	; Init Shadow Vram Tilemap attributes
		ld a, 1
		ld [rVBK], a

		ld de, _SCRN0
		ld hl, wShadowSCN_B1
		ld bc, SSCRNS
		call MemcopyLen
	ret

; Start the DMA transfers to the VRAM and OAM
DMATransfer::
	
	; Transfer Tilemap
		ld a, 0
		ld [rVBK], a

		ld de, wShadowSCN_B0
		ld hl, _SCRN0
		ld b, SSCRNSL
		call VRAMDMA

	; Transfer Tilemap attributes
		ld a, 1
		ld [rVBK], a

		ld de, wShadowSCN_B1
		ld hl, _SCRN0
		ld b, SSCRNSL
		call VRAMDMA


	; Transfer OAM
		ld a, HIGH(wShadowOAM)
		call hOAMDMA
	ret


; Start a VRAM DMA transfer.
; @param de: Source
; @param hl: Destination
; @param b: Length
VRAMDMA:
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

; Init the DMA routine in HRAM
CopyDMARoutine:
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
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to


