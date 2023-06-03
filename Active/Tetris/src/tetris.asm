INCLUDE "hardware.inc"

INCLUDE "utils.asm"
INCLUDE "graphics.asm"


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
	ld a, 128 + 16
	ld [hli], a
	ld a, 16 + 8
	ld [hli], a
	ld a, 0
	ld [hli], a
	ld [hli], a


; Copy the tile data
    ld de, Tiles
    ld hl, $9000
    ld bc, TilesEnd - Tiles
	call Memcopy


; Copy the tilemap
    ld de, Tilemap
    ld hl, $9800
    ld bc, TilemapEnd - Tilemap
	call Memcopy

; Copy the paddle data
    ld de, Paddle
    ld hl, $8000
    ld bc, PaddleEnd - Paddle
	call Memcopy


; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
	ld [rLCDC], a


; During the first (blank) frame, Load pallet
	ld a, %11100100
	ld [rBGP], a
	ld a, %11100100
    ld [rOBP0], a

; Init vars
	ld a, 0
	ld [wFrameCounter], a


Main: ;*	
    ld a, [rLY]
    cp 144
    jp nc, Main
	WaitVBlank2:
		ld a, [rLY]
		cp 144
		jp c, WaitVBlank2
		
	jp Main


SECTION "Counter", WRAM0
	wFrameCounter: db

SECTION "Input Variables", WRAM0
	wCurKeys: db
	wNewKeys: db
	
