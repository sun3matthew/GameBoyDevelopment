INCLUDE "inc/hardware.inc"
INCLUDE "inc/dmem.inc"

SECTION "Dynamic Memory Bank 7", WRAMX, BANK[7]
    ds WRAM_SIZE

SECTION "Dynamic Memory Bank 6", WRAMX, BANK[6]
    ds WRAM_SIZE

SECTION "Dynamic Memory Bank 5", WRAMX, BANK[5]
    ds WRAM_SIZE

SECTION "Dynamic Memory Bank 4", WRAMX, BANK[4]
    ds WRAM_SIZE

SECTION "Dynamic Memory Bank 3", WRAMX, BANK[3]
    ds WRAM_SIZE

SECTION "Dynamic Memory Bank 2", WRAMX, BANK[2]
    ds WRAM_SIZE

SECTION "Dynamic Memory Bank 1", WRAMX, BANK[1]
    ds WRAM_SIZE

SECTION "dmem vars", WRAM0
    wDmemIdx:: ds NUM_BANK * 2


SECTION "dmem", ROM0
    malloc::
        ret

