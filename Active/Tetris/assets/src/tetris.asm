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
	ld [wRowCounter], a
	ld [wColorCounter], a

; Init DMA
	call InitDMA


; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
	ld [rLCDC], a



Main:
	; Buffer Time
	ld a, [wFrameCounter]
	cp 0
	jp nz, .skipDrawRow


	ld a, [wRowCounter]

	ld b, $01
	ld c, $01
	call DrawRow

	ld a, [wRowCounter]

	inc a
	cp BOARD_HEIGHT
	jr nz, .resetEnd

	;.reset:
		ld a, 0
	.resetEnd:

	ld [wRowCounter], a

	ld b, $03
	ld c, $03
	call DrawRow

	.skipDrawRow


	call WaitVBlank
	call DMATransfer

	ld a, [wFrameCounter]
	cp 0
	jp nz, .skipDrawColor

	ld a, BCPSF_AUTOINC
	add 24
	ld [rBCPS], a

	ld hl, Palette + 24

	ld b, h
	ld c, l

	ld a, [wColorCounter]
	ld d, 0
	ld e, a

	sla e
	sla e
	sla e

	call ADDr16r16

	ld h, b
	ld l, c
	ld de, rBCPD
	call PaletteCopy

	ld a, [wColorCounter]
	inc a
	cp 6
	jp nz, .resetColorEnd
		ld a, 0
	.resetColorEnd:
	ld [wColorCounter], a

	.skipDrawColor

	ld a, [wFrameCounter]
	inc a
	cp 4
	jp nz, .resetFrameEnd
		ld a, 0
	.resetFrameEnd:
	ld [wFrameCounter], a




	
		
	jp Main


; Draw a row
; @param a: row
; @param b: tileIdx
; @param c: tileAttr
DrawRow:
	push bc

	ld b, 0
	ld c, a

	ld de, SCRN_VX_B
	call MULr16R16

	ld de, BOARD_LEFT + 1
	call ADDr16r16

	ld d, b
	ld e, c

	push bc
	ld bc, wShadowSCN_B0
	call ADDr16r16
	ld h, b
	ld l, c
	pop bc

	push bc
	ld bc, wShadowSCN_B1
	call ADDr16r16
	ld d, b
	ld e, c
	pop bc

	pop bc

	ld a, BOARD_WIDTH
	.rowLoop
		dec a

		ld [hl], b
		push hl
		ld h, d
		ld l, e
		ld [hl], c
		pop hl

		inc hl
		inc de
		jp nz, .rowLoop
	
	ret