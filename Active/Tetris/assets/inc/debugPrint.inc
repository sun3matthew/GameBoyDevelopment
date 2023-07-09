INCLUDE "inc/memoryBank.inc"

IF !DEF(DEBUG_INC) ;include guard
    DEF DEBUG_INC EQU 1

DEF DEBUG_MEM_BANKS         EQU %00000010

    ENDC ;DEBUG_INC