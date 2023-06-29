INCLUDE "inc/tetris.inc"

SECTION "Board", WRAM0

    wBoard::
        ds BOARD_SIZE

SECTION "Vars", WRAM0

    wFrameCounter:: db

    wPeiceLoc:: ds 8; 2 bytes per peice

    wCurrentPeice:: db
    wCurrentRotation:: db
    wCurrentX:: db
    wCurrentY:: db

SECTION "Piece Info", WRAM0, ALIGN[4]
    wPieceInfo:: ds 2*4*4*NUM_PIECES


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

        ld a, 7
        ld [wCurrentPeice], a

        ld a, 0
        ld [wCurrentRotation], a
        ld [wCurrentX], a
        ld [wCurrentY], a

        ret



