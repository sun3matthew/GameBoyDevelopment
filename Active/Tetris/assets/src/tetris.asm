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


call GeneratePiece
call DrawPieceOnBoard

Main:
	call WaitVBlank
	call DMATransfer

	ld a, [wFrameCounter]
	inc a
	cp 10
	jp nz, .resetFrameEnd
	
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

	ld a, [wCurrentY]
	inc a
	ld [wCurrentY], a


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

; Get a random Piece
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
	; a = random Piece from 0 to 6
	ld hl, wCurrentPiece
	ld [hl], a

	ld hl, wCurrentRotation
	ld [hl], 0

	call LoadPieceLoc

	ld hl, wCurrentX
	ld [hl], BOARD_TWIDTH / 2 - 1

	call GetMinYCoord
	xor a ; set a to 0
	sub c ; subtract the max y coord
	ld hl, wCurrentY
	ld [hl], a

	call ShiftPieceLoc
	ret

; get the y coord of the bottom of the current Piece
; @return c
GetMinYCoord:
	ld hl, wPieceLoc

	ld b, 4
	ld c, $FF
	.loop
		inc hl
		ld a, [hli]

		cp c
		jp nc, .skip

			ld c, a

		.skip:

		dec b
		jp nz, .loop
	ret



LoadPieceLoc:
    ; wPieceLoc:: ds 8; 2 bytes per Piece
	ld a, [wCurrentPiece]
	ld b, a
	ld a, [wCurrentRotation]
	ld c, a

	call GetPieceLocAddress

	ld d, h
	ld e, l

	ld hl, wPieceLoc

	ld b, 0
	ld c, 8

	call MemcopyLen

	ret
	
ShiftPieceLoc:
	ld hl, wCurrentX
	ld d, [hl]

	ld hl, wCurrentY
	ld e, [hl]

	ld hl, wPieceLoc
	ld b, 4
	.loop
		ld a, [hl]
		add d
		ld [hli], a

		ld a, [hl]
		add e
		ld [hli], a

		dec b
		jp nz, .loop
	ret

DrawPieceOnBoard:
	ld hl, wPieceLoc
	ld b, 4
	.loop
		ld a, [hli]
		ld d, a
		ld a, [hli]
		ld e, a

		; verify e < BOARD_HEIGHT + 2
		cp BOARD_HEIGHT + 2
		jp nc, .outOfBounds

		push bc
		push hl
		call DrawTileOnBoard
		pop hl
		pop bc

		.outOfBounds:

		dec b
		jp nz, .loop
	ret	

DrawTileOnBoard:
	; de = xy
	call GetScreenIdx


	ld a, [wCurrentPiece]
	call GetTileIdx
	ld [hl], a

	ld bc, SSCRNS
	ld a, l
	add c
	ld l, a
	ld a, h
	adc b
	ld h, a


	ld a, [wCurrentPiece]
	call GetTileColor
	ld [hl], a
	ret

; @param a = tile idx
GetTileIdx:
	cp 7
	jp z, .blank
		and %00000001
		add 3
		ret
	.blank:
		ld a, 1
		ret


; @param a = tile attr
GetTileColor:
	cp 7
	jp z, .blank
		and %00000001
		add 3
		ret
	.blank:
		ld a, 1
		ret


; @param de = xy
; @destroy a, bc
; @return hl
GetScreenIdx:
	; de = xy

	ld hl, wShadowSCN_B0
	ld b, 0
	ld c, e
	; bc *= 32
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b

	; hl += bc
	ld a, l
	add c
	ld l, a
	ld a, h
	adc b
	ld h, a

	ld a, d
	add BOARD_LEFT

	; hl += a
	add l
	ld l, a
	ld a, h
	adc 0
	ld h, a

	ret






; gets the address of the current Piece location
; @param b = Piece id
; @param c = rotation
; @return hl
GetPieceLocAddress:
	ld a, b

	; a *= 4 (rotations)
	sla a
	sla a

	add c

	; a *= 8 (bytes per Piece)
	sla a
	sla a
	sla a

	ld hl, wPieceInfo
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