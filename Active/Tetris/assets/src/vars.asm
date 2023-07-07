INCLUDE "inc/tetris.inc"


SECTION "Vars", WRAM0

    wFrameCounter:: db

    wPieceLoc:: ds 8; 2 bytes per peice

    wCurrentPiece:: db
    wCurrentRotation:: db
    wCurrentX:: db
    wCurrentY:: db

    wPreviousRotation:: db
    wPreviousX:: db
    wPreviousY:: db

    wMoveTimersLeft:: db
    wMoveTimersRight:: db
    wMoveTimersDown:: db

SECTION "Piece Info", WRAM0, ALIGN[4]
    wPieceInfo:: ds 2*4*4*NUM_PIECES


SECTION "Init", ROM0
    InitVars::
        ld a, 0
        ld [wFrameCounter], a

        ld d, 0
        ld b, 0
        ld c, 8
        ld hl, wPieceLoc
        call MemSet

        ld a, 7
        ld [wCurrentPiece], a

        ld a, 0
        ld [wCurrentRotation], a
        ld [wCurrentX], a
        ld [wCurrentY], a

        ret



