INCLUDE "inc/hardware.inc"
INCLUDE "inc/dma.inc"
INCLUDE "inc/stackMemory.inc"

INCLUDE "inc/tetris.inc"

SECTION "Header", ROM0[$150]
; Init & clean up
	; Turn off interrupts
	di

	; Init stack pointer
	ld sp, GBStackEnd

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

	; init dmem memory
	call DmemReset

	; init debug print
	call DebugPrintReset

	; clean up the OAM
	ld d, 0
    ld bc, SOAMS
    ld hl, _OAMRAM
	call MemSet

ResetGame:

	; init vars
	call InitVars
	
    

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
	ld a, 0
	ld [rVBK], a

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


call RandPiece
call GeneratePiece
call DrawPieceOnBoard

Main:
	call WaitVBlank
	call DMATransfer

	call UpdateKeys
	call ClearOldPeice
	call StorePreviousPositions

	call HandleInputsOther

	ld a, 2
	ld [rSVBK], a

	ld a, [wFrameCounter]
	inc a
	cp 20
	jp nz, .resetFrameEnd


	ld a, [wCurrentY]
	inc a
	ld [wCurrentY], a
	call TestNewPosition
	cp 1
	jp z, .collision

	ld a, 0
	.resetFrameEnd:
	ld [wFrameCounter], a


	call StorePreviousPositions
	call HandleInputsC
	call TestNewPosition
	cp 1
	jp z, .collision


	call StorePreviousPositions
	call HandleInputsNC
	call TestNewPosition
	cp 0
	jp z, .collisionEnd
	call ResetToOldPosition
	jp .collisionEnd

	.collision
	call ResetToOldPosition
	call ReloadPeiceInfo
	call DrawPieceOnBoard

	call CheckForFullRows


	call GeneratePiece


	jp .end
	.collisionEnd
	call ReloadPeiceInfo

	.end:
	call DrawPieceOnBoard

	call DebugIncrementCounter

	jp Main



StorePreviousPositions:
	ld a, [wCurrentX]
	ld [wPreviousX], a
	ld a, [wCurrentY]
	ld [wPreviousY], a
	ld a, [wCurrentRotation]
	ld [wPreviousRotation], a
	ret

ResetToOldPosition:
	ld a, [wPreviousX]
	ld [wCurrentX], a
	ld a, [wPreviousY]
	ld [wCurrentY], a
	ld a, [wPreviousRotation]
	ld [wCurrentRotation], a
	ret

; set a = 0 if valid, 1 if invalid
TestNewPosition:
	call ReloadPeiceInfo
	ld hl, wPieceLoc
	ld b, 4
	.loop
		ld a, [hli]
		ld d, a
		cp BOARD_LEFT - 1
		jp z, .invalid

		cp BOARD_RIGHT - 1
		jp z, .invalid

		ld a, [hli]
		ld e, a
		cp BOARD_HEIGHT
		jp z, .invalid


		push hl
		push bc

		call GetScreenIdx
		ld a, [hl]
		cp 1
		jp nz, .invalidFromTile

		pop bc
		pop hl

		dec b
		jp nz, .loop
	.valid
	ld a, 0
	ret
	.invalidFromTile
	pop af
	pop af
	.invalid
	ld a, 1
	ret

HandleInputsNC:
	.left:
	ld a, [wNewKeys]
	bit PADB_LEFT, a
	jp z, .leftHold
		ld a, [wCurrentX]
		dec a
		ld [wCurrentX], a
		ld a, MOVEDELAY1
		ld [wMoveTimersLeft], a
		jp .rotate


	.leftHold:
	ld a, [wCurKeys]
	bit PADB_LEFT, a
	jp z, .right
		ld a, [wMoveTimersLeft]
		dec a
		ld [wMoveTimersLeft], a
		jp nz, .rotate

		ld a, MOVEDELAY2
		ld [wMoveTimersLeft], a

		ld a, [wCurrentX]
		dec a
		ld [wCurrentX], a
		jp .rotate
		
	.right:
	ld a, [wNewKeys]
	bit PADB_RIGHT, a
	jp z, .rightHold
		ld a, [wCurrentX]
		inc a
		ld [wCurrentX], a
		ld a, MOVEDELAY1
		ld [wMoveTimersRight], a
		jp .rotate
	
	.rightHold:
	ld a, [wCurKeys]
	bit PADB_RIGHT, a
	jp z, .rotateC
		ld a, [wMoveTimersRight]
		dec a
		ld [wMoveTimersRight], a
		jp nz, .rotate

		ld a, MOVEDELAY2
		ld [wMoveTimersRight], a

		ld a, [wCurrentX]
		inc a
		ld [wCurrentX], a
		jp .rotate

	.rotate
	
	.rotateC:
	ld a, [wNewKeys]
	bit PADB_A, a
	jp z, .rotateCW
		ld a, [wCurrentRotation]
		inc a
		ld [wCurrentRotation], a
		cp 4
		jp nz, .end
		ld a, 0
		ld [wCurrentRotation], a
		ret
	
	.rotateCW
	ld a, [wNewKeys]
	bit PADB_B, a
	jp z, .end
		ld a, [wCurrentRotation]
		dec a
		ld [wCurrentRotation], a
		cp $FF
		jp nz, .end
		ld a, 3
		ld [wCurrentRotation], a
		ret

	.end
	ret

HandleInputsC:
	.down:
	ld a, [wNewKeys]
	bit PADB_DOWN, a
	jp z, .downHold
		ld a, [wCurrentY]
		inc a
		ld [wCurrentY], a
		ld a, PUSHDOWNDELAY
		ld [wMoveTimersDown], a
		ret
	
	.downHold:
	ld a, [wCurKeys]
	bit PADB_DOWN, a
	jp z, .end
		ld a, [wMoveTimersDown]
		dec a
		ld [wMoveTimersDown], a
		jp nz, .end

		ld a, PUSHDOWNDELAY
		ld [wMoveTimersDown], a

		ld a, [wCurrentY]
		inc a
		ld [wCurrentY], a
		ret
	
	.end
	ret

HandleInputsOther:
	.Start
	ld a, [wNewKeys]
	bit PADB_START, a
	jp z, .end

		; Shut down audio circuitry
		ld a, 0
		ld [rNR52], a

		; Turn off lcd on blank
		call WaitVBlank

		; Turn the LCD off
		ld a, 0
		ld [rLCDC], a

		jp ResetGame
	.end
	ret

ClearOldPeice:
	; undraw old piece
	ld a, [wCurrentPiece]
	push af
	ld a, 7
	ld [wCurrentPiece], a
	call DrawPieceOnBoard
	pop af
	ld [wCurrentPiece], a
	ret


CheckForFullRows:
	ld a, STACK_MEM_BANK
	ld [rSVBK], a

	StackMallocMacro 4 ; 1 byte for each row, zero terminated
	StackStoreAddressMacro 0

	ld hl, wPieceLoc
	ld b, 4


	.loop
		ld a, [hli]
		ld d, a
		ld a, [hli]
		ld e, a

		push hl
		push bc

			; de = xy

			ld hl, wShadowSCN_B0
			ld b, 0
			ld c, e
			; bc *= 32
			
			REPT 5
				sla c
				rl b
			ENDR

			ld a, l
			add c
			ld l, a
			ld a, h
			adc b
			ld h, a

			ld a, l
			add BOARD_LEFT + 1
			ld l, a
			ld a, h
			adc 0
			ld h, a

			; hl = screen idx

			ld b, BOARD_TWIDTH
			.RowLoop
				ld a, [hli]
				cp 1
				jr z, .NotFullRow

				dec b
				jr nz, .RowLoop
			jr .FullRow

			.NotFullRow
			ld e, $ff

			.FullRow
		pop bc

		StackReadAddressMacro 0
		ld a, b
		dec a
		add l
		ld l, a
		xor a
		adc h
		ld h, a

		ld [hl], e

		pop hl

		dec b
		jp nz, .loop

	ld b, BOARD_HEIGHT

	; find max row
	StackReadAddressMacro 0
	ld b, 5

	ld c, 0
	.findMaxRowLoop
		dec b
		jr z, .findMaxRowLoopE

		ld a, [hli]
		cp $ff
		jr z, .findMaxRowLoop
		cp c
		jr c, .findMaxRowLoop
		ld c, a
		jr .findMaxRowLoop
	.findMaxRowLoopE
	
	ld a, c
	cp 0
	jr nz, .clearRows
		ret
	.clearRows

	push af

	StackMallocMacro 2 ; address of the current row to clear
	StackStoreAddressMacro 1
	; calculate lowest row idx
		ld de, wShadowSCN_B0
		ld b, 0

		; bc *= 32
		REPT 5
			sla c
			rl b
		ENDR

		ld a, e
		add c
		ld e, a
		ld a, d
		adc b
		ld d, a

		ld a, e
		add BOARD_LEFT + 1
		ld e, a
		ld a, d
		adc 0
		ld d, a

		ld [hl], d
		inc hl
		ld [hl], e


	
	pop af
	ld b, a
	dec b
	.RowClearLoop
		push bc


			; de = xy
			ld de, wShadowSCN_B0
			ld c, b
			ld b, 0
			; bc *= 32
			
			REPT 5
				sla c
				rl b
			ENDR

			ld a, e
			add c
			ld e, a
			ld a, d
			adc b
			ld d, a

			ld a, e
			add BOARD_LEFT + 1
			ld e, a
			ld a, d
			adc 0
			ld d, a

			StackReadAddressMacro 1
			ld a, [hli]
			ld l, [hl]
			ld h, a

			ld bc, BOARD_TWIDTH

			push de
			push hl

			call MemcopyLen

			pop hl
			pop de

			ld a, l
			add LOW(SSCRNS)
			ld l, a
			ld a, h
			adc HIGH(SSCRNS)
			ld h, a

			ld a, e
			add LOW(SSCRNS)
			ld e, a
			ld a, d
			adc HIGH(SSCRNS)
			ld d, a

			ld bc, BOARD_TWIDTH
			call MemcopyLen

		pop bc

		StackReadAddressMacro 0
		ld c, 4
		.isCurrentRowAlsoClear
			ld a, [hli]
			cp b
			jp z, .skipMoveRow
			dec c
			jr nz, .isCurrentRowAlsoClear

		StackReadAddressMacro 1
		ld a, [hli]
		ld d, a
		ld a, [hl]

		sub SCRN_VX_B
		ld [hld], a
		ld a, d
		sbc 0
		ld [hl], a

		.skipMoveRow

		dec b
		jp nz, .RowClearLoop

	ret	
