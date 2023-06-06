INCLUDE "inc/tetris.inc"

SECTION "Shadow OAM", WRAM0, ALIGN[8]
    wShadowOAM::
        ds SOAMS

SECTION "Shadow SCN_B0", WRAM0
    wShadowSCN_B0::
        ds SSCRNS

SECTION "Shadow SCN_B1", WRAM0
    wShadowSCN_B1::
        ds SSCRNS

SECTION "Board", WRAM0
    wBoard::
        ds WBOARDS

SECTION "Counter", WRAM0
	wFrameCounter:: db