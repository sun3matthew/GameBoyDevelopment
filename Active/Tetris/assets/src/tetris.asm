INCLUDE "inc/hardware.inc"
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
	
	; clean up the OAM
	ld d, 0
    ld bc, SOAMS
    ld hl, _OAMRAM
	call MemSet
    
	ld bc, SOAMS
    ld hl, wShadowOAM
	call MemSet

	; clean up the Board
	ld bc, WBOARDS
	ld hl, wBoard
	call MemSet

	; clean up the Shadow Tilemaps
	ld bc, SSCRNS
	ld hl, wShadowSCN_B0
	call MemSet

	ld bc, SSCRNS
	ld hl, wShadowSCN_B1
	call MemSet
	


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

; Init Shadow Vram Tilemap
	ld de, _SCRN0
	ld hl, wShadowSCN_B0
	ld bc, SSCRNS
	call MemcopyLen

; Copy the tilemap attributes
	ld a, 1
	ld [rVBK], a

	ld de, TilemapAttribute
	ld bc, TilemapAttributeEnd
	ld hl, _SCRN0
	call Memcopy

; Init Shadow Vram Tilemap attributes
	ld de, _SCRN0
	ld hl, wShadowSCN_B1
	ld bc, SSCRNS
	call MemcopyLen




; Load Color pallet
	ld a, BCPSF_AUTOINC
	ld [rBCPS], a

	ld hl, Palette
	ld de, rBCPD
	call PaletteCopy
	call PaletteCopy
	call PaletteCopy
	call PaletteCopy

	ld a, OCPSF_AUTOINC
	ld [rOCPS], a

	ld hl, Palette + 24
	ld de, rOCPD
	call PaletteCopy


; Init vars
	ld a, 0
	ld [wFrameCounter], a


call CopyDMARoutine



; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
	ld [rLCDC], a



Main:
	; Buffer Time
	ld a, [wFrameCounter]
	inc a

	cp 10
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

	ld a, $03
	ld [wShadowSCN_B0], a
	
	
	; DMA Transfers
	call WaitVBlank

	ld a, 0
	ld [rVBK], a

	ld de, wShadowSCN_B0
	ld hl, _SCRN0
	ld b, SSCRNSL
	call VRAMDMA

	ld a, 1
	ld [rVBK], a

	ld de, wShadowSCN_B1
	ld hl, _SCRN0
	ld b, SSCRNSL
	call VRAMDMA


	ld a, HIGH(wShadowOAM)
	call hOAMDMA

		
	jp Main

	
