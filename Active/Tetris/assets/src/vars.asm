INCLUDE "inc/tetris.inc"

SECTION "Board", WRAM0
    wBoard::
        ds BOARD_SIZE

SECTION "Vars", WRAM0
	wFrameCounter:: db
    wPeiceLoc:: ds 8; 2 bytes per peice

SECTION "Init", ROM0
    InitVars::
        ; clean up the Board
        ld bc, BOARD_SIZE
        ld hl, wBoard
        call MemSet	

        ld a, 0
        ld [wFrameCounter], a

        ld d, 0
        ld b, 0
        ld c, 8
        ld hl, wPeiceLoc
        call MemSet
        ret

