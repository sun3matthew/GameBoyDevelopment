INCLUDE "inc/hardware.inc"

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
		WaitVBlank:
			ld a, [rLY]
			cp 144
			jp c, WaitVBlank

		; Turn the LCD off
		ld a, 0
		ld [rLCDC], a
		
	;* screen must be off to access OAM and VRAM
	
	; clean up the OAM
	ld a, 0
    ld b, 160
    ld hl, _OAMRAM
	ClearOam:
		ld [hli], a
		dec b
		jp nz, ClearOam

; create a object
	ld hl, _OAMRAM
	ld a, 128 + 16 ; y
	ld [hli], a
	ld a, 16 + 8 ; x
	ld [hli], a
	ld a, 0
	ld [hli], a ; tileIdx
	ld [hli], a ; flags

; Copy the tetris data
    ld de, TetrisB
    ld hl, _VRAM
    ld bc, TetrisBEnd - TetrisB
	call Memcopy

; Copy the tile data
    ld de, BG
    ld hl, _VRAM9000
    ld bc, BGEnd - BG
	call Memcopy


; Copy the tilemap
    ld de, Tilemap
    ld hl, _SCRN0
    ld bc, TilemapEnd - Tilemap
	call Memcopy

; Copy the tilemap attributes
	ld a, 1
	ld [rVBK], a
	ld de, TilemapAttribute
	ld hl, _SCRN0
	ld bc, TilemapAttributeEnd - TilemapAttribute
	call Memcopy



; Load Color pallet
	ld a, BCPSF_AUTOINC
	ld [rBCPS], a

	ld hl, Palette
	call PaletteCopy
	call PaletteCopy
	call PaletteCopy
	call PaletteCopy

; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
	ld [rLCDC], a


/*
; Init vars
	ld a, 0
	ld [wFrameCounter], a
*/


Main: ;*	
    ld a, [rLY]
    cp 144
    jp nc, Main
	WaitVBlank2:
		ld a, [rLY]
		cp 144
		jp c, WaitVBlank2
		
	jp Main

/*
SECTION "Counter", WRAM0
	wFrameCounter: db
*/
	
