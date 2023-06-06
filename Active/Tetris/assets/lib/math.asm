SECTION "MATH", ROM0
; SUB 16-bit register from 16-bit register
; @cycles 8
; @param bc: Register to subtract from
; @param de: Register to subtract
SUBr16r16::
    ld a, c ; 1 cycle
    sub e ; 1 cycle
    ld c, a ; 1 cycle

    ld a, b ; 1 cycle
    sbc a, d ; 1 cycle
    ld b, a ; 1 cycle
    ret
    

    