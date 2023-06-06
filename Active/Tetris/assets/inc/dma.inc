
IF !DEF(DMA_INC) ;include guard
    DEF DMA_INC EQU 1

DEF SSCRNS        EQU 16 * 2 * 18
DEF SOAMS        EQU 40 * 4
DEF SSCRNSL       EQU SSCRNS / 16 - 1

    ENDC ;DMA_INC