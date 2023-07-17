INCLUDE "inc/hardware.inc"

SECTION "BANK_MEMORY_CALL", ROM0
; Clear all banks with a function call
; @param hl: function to call
; @param a: banks to use
; @destroy a, hl
ResetAllBanks::
    ld d, h
    ld e, l

    ld b, 7
    ld c, %10000000
    .loop
        push af
        and c
        jp z, .skip

        ld a, 8
        sub b
        ld [rSVBK], a

        push af
        push bc

        ld hl, .ReturnPoint
        push hl

        ld h, d
        ld l, e
        jp hl ; abstract function call
        .ReturnPoint:

        pop bc
        pop af

        .skip
        pop af ; clear stack
        srl c
        dec b
        jp nz, .loop
    ret
