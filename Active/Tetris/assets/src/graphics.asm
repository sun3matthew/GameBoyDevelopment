; SCAN_FULL_FILE

SECTION "Graphics", ROM0
TetrisB::
	INCBIN "graphics/bin/Tetris.2bpp"
TetrisBEnd::

BG::
	INCBIN "graphics/bin/BG-1.2bpp"
	INCBIN "graphics/bin/BG-2.2bpp"
	INCBIN "graphics/bin/BG-3.2bpp"
	INCBIN "graphics/bin/Tetris.2bpp"
BGEnd::

Palette::
	INCBIN "graphics/bin/BG-1.pal"
	INCBIN "graphics/bin/BG-2.pal"
	INCBIN "graphics/bin/BG-3.pal"
	INCBIN "graphics/bin/Tetris-p1.pal"	
	INCBIN "graphics/bin/Tetris-p2.pal"	
	INCBIN "graphics/bin/Tetris-p3.pal"	
	INCBIN "graphics/bin/Tetris-p4.pal"	
	INCBIN "graphics/bin/Tetris-p5.pal"	
	INCBIN "graphics/bin/Tetris-p6.pal"	
	; INCBIN "graphics/bin/font.pal"	
PaletteEnd::

SECTION "TileMaps", ROM0
Tilemap::
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
TilemapEnd::

TilemapAttribute::
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
	db $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $02, $02, 0,0,0,0,0,0,0,0,0,0,0,0
TilemapAttributeEnd::

