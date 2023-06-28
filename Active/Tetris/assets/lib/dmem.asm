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
; * for efficiency, have simmilar memory sizes together (bank)
; Header Structure:
; 0xD000 - 0xD010: dmem metadata * don't try to skimp out of this sh~t, its required
;   1 byte for num entires of memory adresses 
;   1 byte for num entries of memory gaps
;   2 bytes for end of memory
;   2 bytes for temp data
; 0xD011 - HEADER_1: memory addresses
;   for each memory allocation
;       2 bytes for memory address
; HEADER_1 - HEADER_2: memory gaps
;   for each memory gap
;       2 bytes for memory address
;       2 bytes for memory gap size
; HEADER_2 - 0xDFFF: memory

; * When not enough space to store gaps on free, it does not store
; *     This means the previous memory adress just "owns" that space
; *     Freeing that adress will free the full memory

; clean dmem
; @destroy a, hl
DMEM_reset::
    ld a, NUM_BANK
    .loop
        ld [rSVBK], a

        push af
        call DMEM_reset_bank
        pop af

        dec a
        jp nz, .loop
    ret

; clean one bank of dmem, set all to 0
; @destroy a, hl
DMEM_reset_bank::
    ld hl, DMEM_HEADER_0
    
    ld a, 0

    ld [hli], a

    ld [hli], a

    ld a, HIGH(DMEM_START)
    ld [hli], a
    ld a, LOW(DMEM_START) 
    ld [hli], a

    ld a, 0
    ld [hli], a
    ld [hli], a



    ret

; allocate memory fast (does not fill fragmented memory) in wram bank, make sure to set bank to the correct bank, end of memory
; @param de: size
; @return hl: address
; @destroy a, de, bc
mallocFast::
    ; check if there is enough space for metadata
        ; load length into a
        ld a, [DMEM_HEADER_0_NUMADDRESS]

        ; check if there is enough space for metadata
        ; if a == MAX_NUM
        cp DMEM_HEADER_1_ENTRIES
        jp nz, .hasSpaceMeta

        ;! not enough space for meta, return 0
            ld h, 0
            ld l, 0
            ret
        .hasSpaceMeta

    ; no gaps, see if there is enough space at the end of memory
    ld hl, DMEM_HEADER_0_ENDOFMEM
    ld a, [hli]
    ld b, a
    ld a, [hl]
    ld c, a

    ; bc = end of memory
    push bc 

    ; add de to bc
    ld a, c
    add e
    ld c, a
    ld a, b
    adc d
    ld b, a
    
    ld hl, DMEM_END
    ; bc = new end of memory
    ; see if there is enough space
    ; only need to check high byte since no number can be bigger than 0xFF
    ; bc < hl
    ld a, h
    cp b

    jp nc, .hasSpace
    
    ;! not enough space, return 0
        pop bc
        ld h, 0
        ld l, 0
        ret

    .hasSpace

    ; increment number of memory addresses
    ld hl, DMEM_HEADER_0_NUMADDRESS
    ld a, [hl]
    inc a
    ld [hli], a

    ; skip num gaps
    inc hl

    ; load new end of memory into header
    ld [hl], b
    inc hl
    ld [hl], c        


    ; add new entry of the start address to the memory address header
    ld hl, DMEM_HEADER_1

    ; multiply a by 2
    dec a
    sla a
    
    ; add a to hl
    add l
    ld l, a

    ld a, h
    adc 0
    ld h, a

    pop bc

    ; store address
    ld [hl], b
    inc hl
    ld [hl], c

    ; return address
    ld h, b
    ld l, c

    ret

    
; allocate memory in wram bank, make sure to set bank to the correct bank, end of memory
; @param de: size
; @return hl: address
; @destroy a, de, bc
malloc::
    ld hl, DMEM_HEADER_0_LASTALLOCS
    ld [hl], d
    inc hl
    ld [hl], e

    ; check if there is enough space for metadata
        ; load length into a
        ld a, [DMEM_HEADER_0_NUMADDRESS]

        ; check if there is enough space for metadata
        ; if a == MAX_NUM
        cp DMEM_HEADER_1_ENTRIES
        jp nz, .hasSpaceMeta

        ;! not enough space for meta, return 0
            ld h, 0
            ld l, 0
            ret
        .hasSpaceMeta

    ; scan the gaps

        ; load length into a
        ld a, [DMEM_HEADER_0_NUMGAPS]

        ; load gap header start into hl
        ld hl, DMEM_HEADER_2

        ; calculate end of memory gap header
        sla a
        sla a

        add l
        ld l, a

        ld a, h
        adc 0
        ld h, a

        dec hl

        ; load length into b
        ld a, [DMEM_HEADER_0_NUMGAPS]
        ld b, a

        ; itterate through gaps in reverse order
        ; ? it should be faster, less elements to shift when inserting or deleting, since it favours the end.
        cp 0
        .loopGaps
            jp z, .noGap

            dec hl

            ; see if de <= [hl]
            ld a, [hli]
            cp d
            jp c, .continue
            jp nz, .hasGap

            ld a, [hl]
            cp e
            jp c, .continue

            jp .hasGap

            
            .continue
                ; skip address
                dec hl
                dec hl

                dec hl
                dec hl

                dec b
                jp .loopGaps
        .loopGapsE

    .noGap
        ; no gaps, see if there is enough space at the end of memory
        ld hl, DMEM_HEADER_0_ENDOFMEM
        ld a, [hli]
        ld b, a
        ld a, [hl]
        ld c, a

        ; bc = end of memory
        push bc 

        ; add de to bc
        ld a, c
        add e
        ld c, a
        ld a, b
        adc d
        ld b, a
        
        ld hl, DMEM_END
        ; bc = new end of memory
        ; see if there is enough space
        ; only need to check high byte since no number can be bigger than 0xFF
        ; bc < hl
        ld a, h
        cp b

        jp nc, .hasSpace
        
        ;! not enough space, return 0
            pop bc
            ld h, 0
            ld l, 0
            ret

        .hasSpace

        ; increment number of memory addresses
        ld hl, DMEM_HEADER_0_NUMADDRESS
        ld a, [hl]
        inc a
        ld [hli], a

        ; skip num gaps
        inc hl

        ; load new end of memory into header
        ld [hl], b
        inc hl
        ld [hl], c        


        ; add new entry of the start address to the memory address header
        ld hl, DMEM_HEADER_1

        ; multiply a by 2
        dec a
        sla a
        
        ; add a to hl
        add l
        ld l, a

        ld a, h
        adc 0
        ld h, a

        pop bc

        ; store address
        ld [hl], b
        inc hl
        ld [hl], c

        ; return address
        ld h, b
        ld l, c

        ret

    .hasGap
        dec hl
        dec b
        ; b = index of gap entry

        ; hl = start of gap entry, entry two, gap size
        ; store address into de

        dec hl
        ld e, [hl]
        dec hl
        ld d, [hl]
        inc hl
        inc hl

        push de
        push bc

        ld b, [hl]
        inc hl
        ld c, [hl]
        dec hl

        push hl
        ld hl, DMEM_HEADER_0_LASTALLOCS
        ld d, [hl]
        inc hl
        ld e, [hl]
        pop hl

        ; check if fully filled, bc == de
        ld a, c
        cp e
        jp nz, .notFull

        ld a, b
        cp d
        jp nz, .notFull



        ; modify gap header
            ; remove gap entry
            .isFull
                ; setup de
                ld d, h
                ld e, l
                inc de
                inc de

                ; setup hl
                dec hl
                dec hl

                ; setup bc
                pop bc
                ld a, [DMEM_HEADER_0_NUMGAPS]
                sub b
                sla a
                sla a
                ld b, 0
                ld c, a

                call MemcopyLen

                ; decrement number of gaps
                ld hl, DMEM_HEADER_0_NUMGAPS
                dec [hl]

                jp .fullE

            ; store new gap address
            .notFull
                ; calculate new gap size, bc - de
                ld a, c
                sub e
                ld c, a

                ld a, b
                sbc d
                ld b, a

                ; store new gap size
                ld [hl], b
                inc hl
                ld [hl], c
                
                ; load bc with gap address
                dec hl
                dec hl
                ld c, [hl]
                dec hl
                ld b, [hl]

                ; calculate & store new gap address, [hl] = bc + de
                inc hl
                ld a, c
                add e
                ld [hld], a

                ld a, b
                adc d
                ld [hl], a

                pop bc ; clear stack

        .fullE
            ; de = address
            pop de
            push de

            ld hl, DMEM_HEADER_1

            ld a, [DMEM_HEADER_0_NUMADDRESS]
            cp 0
            jp z, .emptyAddressList

            ld c, a

            ; itterate through addresses
            .loopAddresses
                ; see if de < [hl]
                ld a, [hli]
                cp d
                jp c, .loopAddressesC
                jp nz, .foundAddress

                ld a, [hl]
                cp e
                jp nc, .foundAddress

                .loopAddressesC
                inc hl
                dec c
                jp nz, .loopAddresses
            .loopAddressesE

        inc hl
        ld a, [DMEM_HEADER_0_NUMADDRESS]
        sub c
        ld b, a

        .foundAddress
            dec hl
            ; hl = address entry
            ; b = index of address entry

            ; setup bc
            ld a, [DMEM_HEADER_0_NUMADDRESS]
            sub b
            sla a
            ld b, 0
            ld c, a

            ; check if bc == 0
            ld a, b
            or c
            jp z, .emptyAddressList

            ; setup hl 
            add l
            ld l, a
            ld a, h
            adc 0
            ld h, a
            dec hl

            ; setup de
            ld d, h
            ld e, l

            ; setup hl
            inc hl
            inc hl

            ; copy memory
            call MemcopyLenR
            
            ld h, d
            ld l, e

            inc hl

            .emptyAddressList

            pop de
            ; insert address
            ld [hl], d
            inc hl
            ld [hl], e

            ; increment number of memory addresses
            ld hl, DMEM_HEADER_0_NUMADDRESS
            inc [hl]


            ; return address
            ld h, d
            ld l, e

            ret





            




; free memory in wram bank, make sure to set bank to the correct bank
; @param hl: address to free
; @destroy a, bc, de, hl
free::
    ; this is the hard part..

    ; find the address in the memory address header
        ld d, h
        ld e, l

        ; load gap header start into hl
        ld hl, DMEM_HEADER_1

        ld b, 0

        ; itterate through addresses
        ; TODO make this not a infinite loop, return error values
        .loopAddresses
            ; see if de == [hl]
            ld a, [hli]
            cp d
            jp nz, .continue

            ld a, [hl]
            cp e
            jp nz, .continue

            dec hl
            jp .foundAddress

            
            .continue
                inc hl
                inc b

                jp .loopAddresses
        .loopAddressesE

    .foundAddress
    push hl
    push bc
    push de
    ; remove entry
        ; hl = address entry
        ; b = index of address entry

        ; setup hl

        ; setup de
        ld d, h
        ld e, l
        inc de
        inc de

        ; setup bc
        ld a, [DMEM_HEADER_0_NUMADDRESS]
        sub b
        sla a
        ld b, 0
        ld c, a

        call MemcopyLen

        ld hl, DMEM_HEADER_0_NUMADDRESS
        dec [hl]


    pop de
    pop bc
    pop hl

    ; hl = address entry
    ; b = index of address entry
    ; calculate gap size

        ; check if is last entry
        ld a, [DMEM_HEADER_0_NUMADDRESS]
        cp b
        jp nz, .notLast

        .isLast
            ld hl, DMEM_HEADER_0_ENDOFMEM
            ld b, [hl]
            inc hl
            ld c, [hl]
            jp .LastE

        .notLast
            ld b, [hl]
            inc hl
            ld c, [hl]

        .LastE
        ; calculate gap size, bc - de
        ld a, c
        sub e
        ld c, a
        ld a, b
        sbc d
        ld b, a

        ; bc = gap size + free size
        ; de = address of gap
    
    ; store gap size
        ;? not the most elegant solution, but should be fastest.
        ; first itterate through till you find the sorted position
        ; then see if you can merge with front, if so, merge
        ;   then check if you can merge the new gap with the back, if so, merge & delete back
        ; then see if you can merge with back, if so, merge
        ; if none, insert.


        ; bc = gap size + free size
        ; de = address of gap

        push bc

        ld hl, DMEM_HEADER_2

        ld a, [DMEM_HEADER_0_NUMGAPS]
        ld b, a

        ; itterate through addresses
        cp 0
        jp nz, .loopGaps
        ;empty gap list
            ; store new start adress, [hl] = de
            ld [hl], d
            inc hl
            ld [hl], e
            inc hl

            ; store new end of gap, [hl] = bc
            pop bc
            ld [hl], b
            inc hl
            ld [hl], c

            ld hl, DMEM_HEADER_0_NUMGAPS
            inc [hl]

            ret

        .loopGaps
            ; see if de < [hl]
            ld a, [hli]
            cp d
            jp c, .loopGapsC 
            jp nz, .foundGap

            ld a, [hl]
            cp e
            jp nc, .foundGap

            .loopGapsC
            inc hl
            inc hl
            inc hl

            dec b
            jp nz, .loopGaps

        jp .checkFront

        .foundGap


        ld a, b
        ld [DMEM_HEADER_0_LASTALLOCS], a

        ; calculate new gap size, bc -= free gap size

        ; only when there is a gap that is included
        ; if de + bc > [hl]
        pop bc
        push bc

        ld a, c
        add e
        ld c, a
        ld a, b
        adc d
        ld b, a

        dec hl
        ld a, b
        cp [hl]
        inc hl
        jp c, .calculateE
        jp nz, .calculate

        ld a, c
        cp [hl]
        jp c, .calculateE
        

        .calculate
            inc hl
            inc hl
            pop bc
            ld a, c
            sub [hl]
            dec hl
            ld c, a
            ld a, b
            sbc [hl]
            ld b, a
            push bc
            dec hl
        .calculateE
        dec hl

        ; check if it has a front
        ld a, [DMEM_HEADER_0_LASTALLOCS]
        ld b, a
        inc b
        ld a, [DMEM_HEADER_0_NUMGAPS]
        cp b
        jp z, .checkFront
        dec hl
        dec hl
        jp .checkBack

        ; hl = gap entry of front

            .checkFront
                dec hl
                dec hl
                dec hl
                dec hl

                ; set bc to the memory address
                ld b, [hl]
                inc hl
                ld c, [hl]
                inc hl 

                ; set bc += [hl], [hl] = gap size
                ld a, c
                inc hl
                add [hl]
                ld c, a
                ld a, b
                dec hl
                adc [hl]
                ld b, a

                ; check if bc == de
                ld a, b
                cp d
                jp nz, .checkBack

                ld a, c
                cp e
                jp nz, .checkBack

                pop bc
                push bc

                ; bc = gap size

                ; merge
                ; store new gap size, [hl] += bc
                inc hl
                ld a, [hl]
                add c
                ld [hl], a
                dec hl
                ld a, [hl]
                adc b
                ld [hl], a

                inc hl
                inc hl

                ; see if you can merge with back

                    ; check if is last entry
                    ; set bc to the end of memory
                    ld bc, DMEM_HEADER_2
                    ld a, [DMEM_HEADER_0_NUMGAPS]
                    sla a
                    sla a
                    add c
                    ld c, a
                    ld a, b
                    adc 0
                    ld b, a

                    ; check if hl == bc
                    ld a, b
                    cp h
                    jp nz, .isLastEntryE

                    ld a, c
                    cp l
                    jp nz, .isLastEntryE

                    .isLastEntry
                        pop bc ; clear stack
                        ret
                    .isLastEntryE

                    ; calculate end of gap, de += bc
                    pop bc
                    ld a, e
                    add c
                    ld e, a
                    ld a, d
                    adc b
                    ld d, a

                    ; see if de == [hl]
                    ld a, [hl]
                    cp d
                    jp nz, .cantMergeBackWF

                    inc hl 
                    ld a, [hl]
                    cp e
                    jp nz, .cantMergeBackWF

                    ; merge
                        ; store new gap size, bc
                        inc hl
                        inc hl

                        ld c , [hl]
                        dec hl
                        ld b , [hl]
                        dec hl

                        dec hl
                        dec hl
                        ;dec hl

                        ; store new gap size, [hl] += bc
                        ;inc hl
                        ld a, [hl]
                        add c
                        ld [hl], a
                        dec hl
                        ld a, [hl]
                        adc b
                        ld [hl], a
                        
                        inc hl
                        inc hl


                        ; shift everything forward
                        ; setup bc
                            ; bc = end of memory
                            ld bc, DMEM_HEADER_2
                            ld a, [DMEM_HEADER_0_NUMGAPS]
                            sla a
                            sla a
                            add c
                            ld c, a
                            ld a, b
                            adc 0
                            ld b, a

                            ; bc -= hl, bc = size of memory to shift
                            ld a, c
                            sub l
                            ld c, a
                            ld a, b
                            sbc h
                            ld b, a

                        ; setup hl

                        ; setup de
                        ld d, h
                        ld e, l
                        inc de
                        inc de
                        inc de
                        inc de

                        call MemcopyLen

                        ; decrement number of gaps
                        ld hl, DMEM_HEADER_0_NUMGAPS
                        dec [hl]

                    .cantMergeBackWF
                        ret


            .checkBack
                ; hl = gap entry of back
                inc hl
                inc hl

                ; calculate end of gap, bc += de
                pop bc
                push bc

                ld a, c
                add e
                ld c, a
                ld a, b
                adc d
                ld b, a

                ; see if bc == [hl]
                ld a, [hl]
                cp b
                jp nz, .insertEntry
                
                inc hl 
                ld a, [hld]
                cp c
                jp nz, .insertEntry

                ; merge
                    ; store new start adress, [hl] = de
                    ld [hl], d
                    inc hl
                    ld [hl], e
                    inc hl

                    ; store new end of gap, [hl] += bc
                    pop bc
                    inc hl
                    ld a, [hl]
                    add c
                    ld [hl], a
                    dec hl
                    ld a, [hl]
                    adc b
                    ld [hl], a

                    ret

            
            .insertEntry
                ; hl = gap entry of back

                ; check if enough space
                ld a, [DMEM_HEADER_0_NUMGAPS]

                cp DMEM_HEADER_2_ENTRIES
                jp z, .isLastEntry ;! bad code

                push de

                ; shift everything back

                ; setup bc
                    ; bc = end of memory
                    ld bc, DMEM_HEADER_2
                    ld a, [DMEM_HEADER_0_NUMGAPS]
                    sla a
                    sla a
                    add c
                    ld c, a
                    ld a, b
                    adc 0
                    ld b, a

                    ; bc -= hl, bc = size of memory to shift
                    ld a, c
                    sub l
                    ld c, a
                    ld a, b
                    sbc h
                    ld b, a

                    ; check if bc == 0
                    ld a, b
                    or c
                    jp z, .insertAtEnd

                ; setup hl, hl += bc
                ld a, l
                add c
                ld l, a
                ld a, h
                adc b
                ld h, a
                dec hl

                ; setup de
                ld d, h
                ld e, l

                ; setup hl
                inc hl
                inc hl
                inc hl
                inc hl

                ; copy memory
                call MemcopyLenR

                ; insert new entry
                ld h, d
                ld l, e
                inc hl

                .insertAtEnd

                pop de
                pop bc
                
                ; store new start adress, [hl] = de
                ld [hl], d
                inc hl
                ld [hl], e
                inc hl

                ; store new end of gap, [hl] = bc
                ld [hl], b
                inc hl
                ld [hl], c

                ; increment number of gaps
                ld hl, DMEM_HEADER_0_NUMGAPS
                inc [hl]

                ret
