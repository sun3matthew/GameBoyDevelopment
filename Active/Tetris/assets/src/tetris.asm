INCLUDE "inc/hardware.inc"
INCLUDE "inc/dma.inc"

INCLUDE "inc/tetris.inc"

SECTION "Header", ROM0[$100]

jp EntryPoint ; true entry point: at $100

ds $150 - @, 0 ; Make room for the header

; gets filled by rgbfix


EntryPoint: ;*
; Init & clean up
	; Shut down audio circuitry
		ld a, 0
		ld [rNR52], a

	; Turn off lcd on blank
		call WaitVBlank

		; Turn the LCD off
		ld a, 0
		ld [rLCDC], a
		
	;* screen must be off to access OAM and VRAM

	; init rng
	call InitRNG
	
	; clean up the OAM
	ld d, 0
    ld bc, SOAMS
    ld hl, _OAMRAM
	call MemSet
    
	; clean up the Board
	ld bc, BOARD_SIZE
	ld hl, wBoard
	call MemSet	


; create a object
/*
	ld hl, _OAMRAM
	ld a, 128 + 16 ; y
	ld [hli], a
	ld a, 16 + 8 ; x
	ld [hli], a
	ld a, 0
	ld [hli], a ; tileIdx
	ld [hli], a ; flags
*/

; Copy the tetris data
    ld de, TetrisB
    ld bc, TetrisBEnd
    ld hl, _VRAM
	call Memcopy

; Copy the tile data
    ld de, BG
    ld bc, BGEnd
    ld hl, _VRAM9000
	call Memcopy


; Copy the tilemap
    ld de, Tilemap
    ld bc, TilemapEnd
    ld hl, _SCRN0
	call Memcopy


; Copy the tilemap attributes
	ld a, 1
	ld [rVBK], a

	ld de, TilemapAttribute
	ld bc, TilemapAttributeEnd
	ld hl, _SCRN0
	call Memcopy



; Load Color pallet
	; Load BG pallet
		ld a, BCPSF_AUTOINC
		ld [rBCPS], a

		ld hl, Palette
		ld de, rBCPD
		call PaletteCopy
		call PaletteCopy
		call PaletteCopy
		call PaletteCopy

	; Load Object pallet
		ld a, OCPSF_AUTOINC
		ld [rOCPS], a

		ld hl, Palette + 24
		ld de, rOCPD
		call PaletteCopy


; Init vars
	ld a, 0
	ld [wFrameCounter], a

; Init DMA
	call InitDMA


; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
	ld [rLCDC], a



Main:
	; Buffer Time
	/*

	ld a, [wFrameCounter]
	inc a

	cp 1
	jr nz, .updatePosEnd
		ld hl, wShadowOAM
		ld a, [hl]
		inc a
		ld [hli], a
		ld a, [hl]
		inc a
		ld [hli], a

		ld a, 0
	.updatePosEnd
	ld [wFrameCounter], a
	*/
	call Rand
	ld a, h
	ld [wShadowOAM], a
	ld a, l
	ld [wShadowOAM+1], a

	
	call WaitVBlank
	call DMATransfer
		
	jp Main

	
