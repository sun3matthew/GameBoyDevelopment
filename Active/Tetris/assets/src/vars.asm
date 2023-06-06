INCLUDE "inc/tetris.inc"

SECTION "Board", WRAM0
    wBoard::
        ds WBOARDS

SECTION "Counter", WRAM0
	wFrameCounter:: db