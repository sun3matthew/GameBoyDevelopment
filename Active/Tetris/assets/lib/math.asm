SECTION "MATH", ROM0

; SUBTRACT 16-bit register from 16-bit register
; @cycles 8
; @param bc: Register to subtract from
; @param de: Register to subtract
; @destroy a
SUBr16r16::
    ld a, c ; 1 cycle
    sub e ; 1 cycle
    ld c, a ; 1 cycle

    ld a, b ; 1 cycle
    sbc a, d ; 1 cycle
    ld b, a ; 1 cycle
    ret

; ADD 16-bit register from 16-bit register
; @cycles 8
; @param bc: Register to add from
; @param de: Register to add
; @destroy a
ADDr16r16::
    ld a, c ; 1 cycle
    add e ; 1 cycle
    ld c, a ; 1 cycle

    ld a, b ; 1 cycle
    adc a, d ; 1 cycle
    ld b, a ; 1 cycle
    ret

; MULTIPLY 16-bit register with 16-bit register (do booths algorithm later)
; @cycles f~ ton
; @param bc: register to multiply from
; @param de: register to multiply
; @destroy hl, a
MULr16R16::
    ld h, b
    ld l, c

    ld a, b
    or a, c
    jp z, .done ; multiply by 0

    ld hl, 0 

    
    .addLoop
        add hl, bc
        dec de
        ld a, d
        or e
        jp nz, .addLoop 

    .done
    ld b, h
    ld c, l
    ret

; MULTIPLY 8-bit register with 8-bit register (do booths algorithm later)
; @cycles f~ ton
; @param b: Register to multiply from
; @param c: Register to multiply
; @destroy a
MULr8r8::
    ld a, c 
    cp a, 0
    jp z, .done ; multiply by 0

    ld a, 0 
    
    .addLoop
        add b 
        dec c
        jp nz, .addLoop 

    .done
    ld b, a 
    ret

; DIVIDE 8-bit register with 8-bit register
; @cycles f~ ton
; @param b: Register to divide from
; @param c: Register to divide
; @destroy a
DIVr8r8::
    ld a, c 
    cp a, 0
    jp z, .done ; divide by 0

    ld a, b
    ld b, 0

    jp .startLoop
    
    .addLoop
        inc b
    .startLoop
        sub c 
        jp nc, .addLoop 
    
    .done
    ret 

; DIVIDE 16-bit register with 16-bit register
; @cycles f~ ton
; @param bc: register to divide from
; @param de: register to divide
; @destroy hl, a
DIVr16R16::
    ld a, d
    or a, e
    jp z, .done ; divide by 0

    ld h, b
    ld l, c
    ld bc, 0

    jp .startLoop
    
    .addLoop
        inc bc
    .startLoop
        ; sub hl, de
            ld a, l
            sub e 
            ld l, a 

            ld a, h 
            sbc a, d 
            ld h, a 
        jp nc, .addLoop 
    
    .done
    ret

; MODULO 8-bit register with 8-bit register
; @cycles f~ ton
; @param b: Register to modulo from
; @param c: Register to modulo
; @destroy a