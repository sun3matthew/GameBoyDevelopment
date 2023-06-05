SECTION "Shadow OAM", WRAM0, ALIGN[8]
    wShadowOAM::
        ds 4 * 40 ; This is the buffer we'll write sprite data to