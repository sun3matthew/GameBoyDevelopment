; Init the stack to somewhere that is not the fucking hram.
; reserve 4 rows. So up to 64 bytes deep
SECTION "GB_STACK", WRAM0, ALIGN[4]
    GBStack:
        ds $40
    GBStackEnd::