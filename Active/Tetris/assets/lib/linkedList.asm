SECTION "Linked List", ROM0


/*
; * List structure:
; 2 bytes for the head pointer

; Create a new empty linked list
; @return hl: new linked list
; @destroy all
LinkedListNew::
    ld de, 2
    call malloc
    ld a, 0
    ld [hli], a
    ld [hl], a
    dec hl
    ret

; Delete a linked list
; @param hl: linked list
; @destroy all
LinkedListDelete::
    push hl
    call free
    pop hl

	ld a, [hli]
    ld l, [hl]
    ld h, a

    cp l
    jp nz, LinkedListDelete
    ret

; Add data to the end of the linked list
; @param hl: linked list
; @param bc: data
LinkedListAppend::
    push hl

    ld a, [hli]
    cp [hl]
    jp nz, .LinkedListAppend
        call LinkedListNodeNew

        ld d, h
        ld e, l

        pop hl
        ld [hl], a
        inc hl
        ld [hl], e

        dec hl
        ret

    .LinkedListAppend
    ld l, [hl]
    ld h, a
    call LinkedListNodeAppend
    pop hl
    ret

; Remove data from the linked list
; @param hl: linked list
; @param bc: data
; @return hl: linked list head
LinkedListRemove::
    push hl

    ld a, [hli]
    cp [hl]
    jp nz, .LinkedListRemoveE
        pop hl
        ret
    .LinkedListRemoveE
    ld l, [hl]
    ld h, a

    call LinkedListNodeRemove
    ld d, h
    ld e, l

    pop hl

    ld [hl], d
    inc hl
    ld [hl], e
    ret



; Create a new empty node
; @param bc: data
; @return hl: first node of the linked list
; @destroy all
LinkedListNodeNew::
	call LinkedListNodeAlloc
    ld a, 0
	ld [hli], a
	ld [hli], a
	ld [hl], b
    inc hl
	ld [hl], c

	dec hl
	dec hl
	dec hl
	ret

; Add a new node to the end of the linked list
; @param hl: linked list
; @param bc: data
; @destroy all
LinkedListNodeAppend::
	jp .CheckAddress
	.LinkedListLoop
	; ld a, [hli]
	ld l, [hl]
	ld h, a
	.CheckAddress
	ld a, [hli]
	cp [hl]
	jp nz, .LinkedListLoop

	dec hl

	push hl
	push bc
	call LinkedListNodeAlloc
	ld d, h
	ld e, l

	pop bc
    ld a, 0
	ld [hli], a
	ld [hli], a
	ld [hl], b
    inc hl
	ld [hl], c

	pop hl
	ld [hl], d
    inc hl
	ld [hl], e
	ret

; Remove a node from the linked list
; @param hl: linked list
; @param bc: node to remove
; @return hl: linked list head 
; @destroy all
LinkedListNodeRemove::
    push hl ; save head

    ld de, 0
    push de ; null prev head

	jp .CheckData
	.LinkedListLoop
    
    ; move back to address of node
    dec hl
    dec hl
    dec hl

    ; store current node
    pop af ; dummy, clear stack
    push hl

    ; hl = [hl], move to next node
    ld a, [hli]
    ld l, [hl]
    ld h, a

	.CheckData
    inc hl
    inc hl

    ; see if data matches
	ld a, [hli]
    cp b
    jp nz, .LinkedListLoop

    ld a, [hl]
    cp c
    jp nz, .LinkedListLoop

    ; remove node
        ; go to start of node
        dec hl
        dec hl
        dec hl

        ; store address (to free later)
        ld b, h
        ld c, l

        ; move to next node
        ld a, [hli]
        ld l, [hl]
        ld h, a

        ; store next node
        ld d, h
        ld e, l

        ; go to original node
        pop hl

        ; check if prev node exists
        ld a, h
        or l
        jp z, .LinkedListNoPrev

            ld [hl], d
            inc hl
            ld [hl], e

            ; free node
            ld h, b
            ld l, c
            call free

            ; same head
            pop hl

            ret

        .LinkedListNoPrev

            ; no prev node, this is the head
            pop hl
            call free

            ld h, d
            ld l, e

            ret
    

; * Node structure:
; 2 bytes for the next pointer
; 2 bytes for the data
; Create a new linked list node
; @return hl: new node
; @destroy all
LinkedListNodeAlloc:
	ld de, 4
	call malloc
	ret
*/