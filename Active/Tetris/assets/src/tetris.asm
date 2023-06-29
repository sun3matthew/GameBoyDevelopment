INCLUDE "inc/hardware.inc"
INCLUDE "inc/dma.inc"
INCLUDE "inc/dmem.inc"

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

call InitPieceInfo

; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
	ld [rLCDC], a


Main:
	call WaitVBlank
	call DMATransfer

	ld a, [wFrameCounter]
	inc a
	cp 60
	jp nz, .resetFrameEnd

	call RandPeice



	.resetFrameEnd:
	ld [wFrameCounter], a

	jp Main

; Get a random peice
; @destroy hl
; @return a
RandPiece:
	call Rand
	ld a, l
	and %00000111
	cp NUM_PIECES
	jp z, RandPiece
	ret

GeneratePiece:
	call RandPiece
	; a = random peice from 0 to 6
	ld hl, wCurrentPiece
	ld [hl], a

	ld hl, wCurrentRotation
	ld [hl], 0

	ld hl, wCurrentX
	ld [hl], BOARD_WIDTH / 2 - 2

	ld hl, wCurrentY
	call GetMaxYCoord
	xor a ; set a to 0
	sub c ; subtract the max y coord
	ld [hl], a

	call UpdatePieceLoc
	ret

; get the y coord of the bottom of the current peice
; @return c
GetMaxYCoord:
    ; wPeiceLoc:: ds 8; 2 bytes per peice
	ld a, [wCurrentPeice]
	ld b, a
	ld a, [wCurrentRotation]
	ld c, a

	call GetPieceLocAddress

	ld b, 4
	ld c, 0
	.loop
		inc hl
		ld a, [hli]

		cp c
		jp nc, .lessThen
		ld c, a
		.lessThen

		dec b
		jp nz, .loop
	ret



UpdatePieceLoc:
    ; wPeiceLoc:: ds 8; 2 bytes per peice
	ld a, [wCurrentPeice]
	ld b, a
	ld a, [wCurrentRotation]
	ld c, a

	call GetPieceLocAddress

	ld d, h
	ld e, l

	ld hl, wPeiceLoc

	ld b, 0
	ld c, 8

	call MemcopyLen

	ld b, 4
	ld c, 0
	.loop
		inc hl
		ld a, [hli]

		cp c
		jp nc, .lessThen
		ld c, a
		.lessThen

		dec b
		jp nz, .loop


	ret
	

; gets the address of the current peice location
; @param b = peice id
; @param c = rotation
; @return hl
GetPieceLocAddress:
	ld a, b

	; a *= 4 (rotations)
	sla a
	sla a

	add c

	; a *= 8 (bytes per peice)
	sla a
	sla a
	sla a

	ld hl, wPeiceLoc
	add l
	ld l, a
	ld a, h
	adc 0
	ld h, a

	ret



InitPieceInfo:
	ld hl, Pieces

	ld de, wPieceInfo

	.loop:

	 	ld b, 0
		.loop2:
			ld a, [hli]
			cp 0
			jp z, .skip

			push hl
			ld h, d
			ld l, e

			; mod a, 4
			ld a, b
			and %00000011
			ld [hli], a

			; a /= 4
			ld a, b
			srl a
			srl a
			ld [hl], a

			inc de
			inc de

			pop hl

			.skip:

			inc b
			ld a, b
			cp 16
			jp nz, .loop2

		ld bc, PiecesEnd
		ld a, h
		cp b
		jp nz, .loop

		ld a, l
		cp c
		jp nz, .loop

	ret


	
	



