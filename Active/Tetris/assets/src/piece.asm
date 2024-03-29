INCLUDE "inc/dma.inc"
INCLUDE "inc/tetris.inc"
INCLUDE "inc/stackMemory.inc"
INCLUDE "inc/hardware.inc"


SECTION "Piece", ROM0
GeneratePiece::
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

	call DrawNextPiece
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


ReloadPeiceInfo::
	call LoadPieceLoc
	call ShiftPieceLoc
	ret

; load new offsets into wPieceLoc
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
	
; update the offset to shift with x and y
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

DrawPieceOnBoard::
	ld hl, wPieceLoc
	ld b, 4
	.loop
		ld a, [hli]
		ld d, a
		ld a, [hli]
		ld e, a

		push bc
		push hl
		call DrawTileOnBoard
		pop hl
		pop bc

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
GetScreenIdx::
	; de = xy

	ld hl, wShadowSCN_B0
	ld b, 0
	ld c, e
	; bc *= 32
	
	REPT 5
		sla c
		rl b
	ENDR

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


; calculate all the peice offsets
InitPieceInfo::
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

; Get a random Piece
; @destroy hl, d
; @return a
RandPiece::
	call Rand
	ld a, l
	and %00000111
	cp NUM_PIECES
	jr z, RandPiece
	ld e, a
	ld a, [wNextPiece]
	ld d, a
	ld a, e
	ld [wNextPiece], a
	ld a, d
	ret


DrawNextPiece::
	ld b, 0
	ld a, [wNextPiece]
	ld c, a

	REPT 6
		sla c
		rl b
	ENDR


	ld hl, Pieces
	ld a, c
	add l
	ld l, a
	ld a, h
	adc b
	ld h, a

	ld d, h
	ld e, l

	StackMallocMacro 2 ; address of piece info
	StackStoreAddressMacro 0 
	ld [hl], d
	inc hl
	ld [hl], e

	ld de, $C0ED
	ld b, 4
	.loop1
		push bc
		push de
		ld b, 4
		.loop2
			StackReadAddressMacro 0
			ld a, [hli]
			ld l, [hl]
			ld h, a

			ld a, [hli]

			push af
			push de
			push hl
			StackReadAddressMacro 0
			pop de
			ld [hl], d
			inc hl
			ld [hl], e

			pop de
			pop af


			cp 0
			jr z, .Black
				ld a, [wNextPiece]
				call GetTileIdx
			jr .ColorFound
			.Black:
				ld a, 1
			.ColorFound

			ld h, d
			ld l, e

			ld [hl], a
			push af

			ld a, l
			add LOW(SSCRNS)
			ld l, a
			ld a, h
			adc HIGH(SSCRNS)
			ld h, a

			pop af
			ld [hl], a

			inc de

			dec b
			jr nz, .loop2
		
		pop de
		ld a, e
		add SCRN_VX_B
		ld e, a
		ld a, d
		adc 0
		ld d, a

		pop bc
		dec b
		jp nz, .loop1



	ret
