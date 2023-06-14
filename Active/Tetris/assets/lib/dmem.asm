INCLUDE "inc/hardware.inc"
INCLUDE "inc/dmem.inc"

SECTION "DMEM Bank 7", WRAMX, BANK[7]
    ds WRAM_SIZE

SECTION "DMEM Bank 6", WRAMX, BANK[6]
    ds WRAM_SIZE

SECTION "DMEM Bank 5", WRAMX, BANK[5]
    ds WRAM_SIZE

SECTION "DMEM Bank 4", WRAMX, BANK[4]
    ds WRAM_SIZE

SECTION "DMEM Bank 3", WRAMX, BANK[3]
    ds WRAM_SIZE

SECTION "DMEM Bank 2", WRAMX, BANK[2]
    ds WRAM_SIZE

SECTION "DMEM Bank 1", WRAMX, BANK[1]
    ds WRAM_SIZE


SECTION "DMEM", ROM0
; Header Structure:
; 0xD000 - 0xD010: dmem metadata
;   2 bytes for end of memory metadata
;   2 bytes for end of memory
; 0xD011 - HEADER_SIZE: memory metadata
;   for each memory allocation
;       2 bytes for memory address
;       2 bytes for memory size
; HEADER_SIZE - 0xDFFF: memory




; clean dmem, set all to 0
; @destroy a, bc, d, gl
DMEM_clean::
    ld a, NUM_BANK
    ld d, 0
    .loop
        ld [rSVBK], a
        ld hl, DMEM_HEADER0
        ld bc, WRAM_SIZE
        push af
        call MemSet

        ld hl, DMEM_HEADER0
        ld a, HIGH(DMEM_HEADER1)
        ld [hli], a
        ld a, LOW(DMEM_HEADER1)
        ld [hli], a

        ld a, HIGH(DMEM_START)
        ld [hli], a
        ld a, LOW(DMEM_START) 
        ld [hli], a

        pop af

        dec a
        jp nz, .loop
    ret
    
; allocate memory in wram bank, make sure to set bank to the correct bank
; @param de: size
; @return hl: address
; @destroy a, bc, de
malloc::
    ld hl, DMEM_HEADER0 + 2
    ld a, [hli]
    ld b, a
    ld a, [hl]
    ld c, a

    ; bc = memory address to return
    push de
    push bc 

    call ADDr16r16
    
    ld hl, DMEM_END
    ; bc = end of memory metadata
    ; see if there is enough space
    ; bc < hl
    ld a, h
    cp b

    jp nc, .hasSpace
    
    ; not enough space, return 0
        pop bc
        pop de
        ld h, 0
        ld l, 0
        ret

    .hasSpace


    ; ld dc, [DMEM_HEADER0]
    ld hl, DMEM_HEADER0
    ld a, [hli]
    ld d, a
    ld a, [hl]
    ld e, a


    ld hl, DMEM_START
    ; check if there is enough space for metadata
    ; if de == hl
    ld a, h
    cp d
    jp nz, .hasSpaceMeta

    ld a, l
    cp e
    jp nz, .hasSpaceMeta

    ; not enough space for meta, return 0
        pop de
        pop bc
        ld h, 0
        ld l, 0
        ret
    .hasSpaceMeta


    ; bc = end of memory metadata
    
    ; ld [DMEM_HEADER0 + 2], bc
    ld hl, DMEM_HEADER0 + 2
    ld [hl], b
    inc hl
    ld [hl], c
    

    ld h, d
    ld l, e
    ; hl = start of memory metadata
    
    pop bc
    pop de

    ; ld [hl], bc
    ld [hl], b
    inc hl
    ld [hl], c
    inc hl
    ; ld [hl], de
    ld [hl], d
    inc hl
    ld [hl], e
    inc hl

    ld d, h
    ld e, l

    ; store the end of memory metadata
    ld hl, DMEM_HEADER0
    ld [hl], d
    inc hl
    ld [hl], e

    ld h, b
    ld l, c

    ret



; free memory in wram bank, make sure to set bank to the correct bank
; @param hl: address to free
; @return a: success 0, fail 1
; @destroy a, bc, de, hl
free::
    ld b, h
    ld c, l

    ld hl, DMEM_HEADER0
    ld a, [hli]
    ld d, a
    ld a, [hl]
    ld e, a


    ld hl, DMEM_HEADER1


    .while ; de != hl
        ld a, h
        cp d
        jp nz, .continue

        ld a, l
        cp e
        jp nz, .continue

        jp .end

        .continue
        ; bc != [hl]
        push de
        ld a, [hli]
        ld d, a
        ld a, [hli]
        ld e, a

        ld a, b
        cp d
        jp nz, .continue2

        ld a, c
        cp e
        jp nz, .continue2

        ; found match
        pop de
        ld a, [hli]
        ld d, a
        ld a, [hl]
        ld e, a
        jp .foundMatch

        .continue2
        pop de
        inc hl
        inc hl
        

    .end

    ld a, 1
    ret 

    .foundMatch
    ; bc = memory address to free
    ; de = memory size to free
    push bc
    push de

    ; clear memory metadata

    ld d, h
    ld e, l
    inc de
    ; de = start of memory metadata

    dec hl
    dec hl
    dec hl
    ; hl = start of memory metadata
    push hl

    ld hl, DMEM_HEADER0
    ld a, [hli]
    ld b, a
    ld a, [hl]
    ld c, a
    ; bc = end of memory metadata

    pop hl

    call Memcopy

    ld b, h
    ld c, l
    ld hl, DMEM_HEADER0
    ld [hl], b
    inc hl
    ld [hl], c


    ; clear memory
    pop de
    pop bc

    ld h, b
    ld l, c
    ; hl = start of memory
    push hl

    call ADDr16r16
    ld d, b
    ld e, c
    ; de = start of new memory



    ld hl, DMEM_HEADER0 + 2
    ld a, [hli]
    ld b, a
    ld a, [hl]
    ld c, a 
    ; bc = end of memory

    pop hl


    call Memcopy

    ld b, h
    ld c, l
    ld hl, DMEM_HEADER0 + 2
    ld [hl], b
    inc hl
    ld [hl], c


    ld a, 0
    ret


    
        





