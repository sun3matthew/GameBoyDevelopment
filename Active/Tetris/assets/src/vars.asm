INCLUDE "inc/tetris.inc"

SECTION "Board", WRAM0
    wBoard::
        ds BOARD_SIZE

SECTION "Counter", WRAM0
	wFrameCounter:: db
    wRowCounter:: db
    wColorCounter:: db
    wMemCounter:: db