INCLUDE "inc/hardware.inc"
INCLUDE "inc/dma.inc"
INCLUDE "inc/dmem.inc"

INCLUDE "inc/tetris.inc"

SECTION "Header", ROM0[$150]
; Init & clean up
	; Turn off interrupts
	di

	; Shut down audio circuitry
		ld a, 0
		ld [rNR52], a

	; Turn off lcd on blank
		call WaitVBlank

		; Turn the LCD off
		ld a, 0
		ld [rLCDC], a
		
	;* screen must be off to access OAM and VRAM

	; init RNG
	call InitRNG

	; init DMEM
	call DMEM_reset

	; init vars
	call InitVars
	
	; clean up the OAM
	ld d, 0
    ld bc, SOAMS
    ld hl, _OAMRAM
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

		call PaletteCopy
		call PaletteCopy
		call PaletteCopy

	; Load Object pallet
		ld a, OCPSF_AUTOINC
		ld [rOCPS], a

		ld hl, Palette + 24

		ld de, rOCPD
		call PaletteCopy

; Init DMA
	call InitDMA

; Init Piece Info
	call InitPieceInfo


; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
	ld [rLCDC], a


call GeneratePiece
call DrawPieceOnBoard

Main:
	call WaitVBlank
	call DMATransfer

	call UpdateKeys

	ld a, [wFrameCounter]
	inc a
	cp 10
	jp nz, .resetFrameEnd
	
	; undraw old piece
	ld a, [wCurrentPiece]
	push af
	ld a, 7
	ld [wCurrentPiece], a
	call DrawPieceOnBoard
	pop af
	ld [wCurrentPiece], a

	/*
	ld a, [wCurrentRotation]
	inc a
	cp 4
	jp nz, .keepRotation
	ld a, 0
	.keepRotation:
	ld [wCurrentRotation], a
	*/

	; move down piece
	ld a, [wCurrentY]
	inc a
	ld [wCurrentY], a


	; generate and draw new piece
	cp BOARD_HEIGHT - 3
	jp z, .NewPiece
	jp .OldPiece
	.NewPiece:
		call GeneratePiece
		jp .PieceEnd
	.OldPiece:
		call LoadPieceLoc
		call ShiftPieceLoc
	.PieceEnd
	call DrawPieceOnBoard

	.resetFrameEnd:
	ld [wFrameCounter], a

	jp Main


