INCLUDE "inc/debugPrint.inc"
INCLUDE "inc/memoryBank.inc"

SECTION "DEBUG_PRINT", ROM0

; reset memory banks for dmem
; @destroy all
DebugPrintReset::
    ld hl, wUniversalCounter
    ld a, 0
    ld [hli], a
    ld [hli], a

    ld hl, wAddressCounter
    ld [hl], HIGH(MEM_HEADER)
    inc hl
    ld [hl], LOW(MEM_HEADER)

    ld a, DEBUG_MEM_BANKS
    ld hl, DebugPrintClear
    call ResetAllBanks
    ret 

; Clear the print buffer
; @destroy a, de, bc
DebugPrintClear::
    ld d, 0
    ld hl, MEM_HEADER
    ld bc, WRAM_SIZE
    call MemSet
    ret

CopyRegistersIntoBuffer:
    ld [wTempDebugA], a

    ld a, b
    ld [wTempDebugBC], a
    ld a, c
    ld [wTempDebugBC + 1], a

    ld a, d
    ld [wTempDebugDE], a
    ld a, e
    ld [wTempDebugDE + 1], a

    ld a, h
    ld [wTempDebugHL], a
    ld a, l
    ld [wTempDebugHL + 1], a

    ret

CopyRegistersFromBuffer:
    ld a, [wTempDebugBC]
    ld b, a
    ld a, [wTempDebugBC + 1]
    ld c, a

    ld a, [wTempDebugDE]
    ld d, a
    ld a, [wTempDebugDE + 1]
    ld e, a

    ld a, [wTempDebugHL]
    ld h, a
    ld a, [wTempDebugHL + 1]
    ld l, a

    ld a, [wTempDebugA]
    ret



; pull starting 14 bytes from the return stack - 3
; @destroy flags
DebugPrint::
    call CopyRegistersIntoBuffer

    ; JP n16 -> 3 bytes

    pop hl ; return address
    push hl

    ; sub 17 (14 + 3)
    ld a, l
    sub 17
    ld e, a
    ld a, h
    sbc 0
    ld d, a

    ld hl, wAddressCounter
    ld a, [hli]
    ld l, [hl]
    ld h, a
    inc hl
    inc hl

    ld bc, 14

    call MemcopyLen

    call UpdateDebugLog

    call CopyRegistersFromBuffer
    ret

UpdateDebugLog:
    ld hl, wUniversalCounter
    ld d, [hl]
    inc hl
    ld e, [hl]

    ld hl, wAddressCounter
    ld a, [hli]
    ld l, [hl]
    ld h, a

    ld a, d
    ld [hli], a
    ld a, e
    ld [hli], a

    ld hl, wAddressCounter
    ld a, [hli]
    ld e, [hl]
    ld d, a

    ld a, $10
    add e
    ld e, a
    ld a, 0
    adc d
    ld d, a

    cp HIGH(MEM_END + 1)
    jp nz, .skip

    ld de, MEM_HEADER
    .skip:



    ld hl, wAddressCounter
    ld [hl], d
    inc hl
    ld [hl], e
    
    ret


; Print all registers
; @param hl: address
; @destroy all
DebugPrintRegisters::
    call CopyRegistersIntoBuffer

    ld hl, wAddressCounter
    ld a, [hli]
    ld l, [hl]
    ld h, a
    inc hl
    inc hl

    ld [hl], $0A
    inc hl

    ld a, [wTempDebugA]
    ld [hli], a

    ld [hl], $BC
    inc hl

    ld a, [wTempDebugBC]
    ld [hli], a

    ld a, [wTempDebugBC + 1]
    ld [hli], a

    ld [hl], $DE
    inc hl

    ld a, [wTempDebugDE]
    ld [hli], a

    ld a, [wTempDebugDE + 1]
    ld [hli], a

    ld [hl], $F0
    inc hl

    ld a, [wTempDebugHL]
    ld [hli], a

    ld a, [wTempDebugHL + 1]
    ld [hli], a

    ld [hl], $FF
    inc hl

    push hl
    ld a, [wTempDebugHL]
    ld h, a
    ld a, [wTempDebugHL + 1]
    ld l, a

    ld d, [hl]
    inc hl
    ld e, [hl]
    pop hl

    ld [hl], d
    inc hl

    ld [hl], e

    call UpdateDebugLog

    call CopyRegistersFromBuffer
    ret

; Increment the universal counter
DebugIncrementCounter::
    ld hl, wUniversalCounter
    ld d, [hl]
    inc hl
    ld e, [hl]
    inc de
    ld [hl], e
    dec hl
    ld [hl], d
    ret

SECTION "DEBUG_VARS", WRAM0
    wUniversalCounter:: ds 2
    wAddressCounter:: ds 2

    wTempDebugA:: ds 1
    wTempDebugBC:: ds 2
    wTempDebugDE:: ds 2
    wTempDebugHL:: ds 2

