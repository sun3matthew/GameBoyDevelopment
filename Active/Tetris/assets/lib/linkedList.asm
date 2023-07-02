SECTION "Linked List", ROM0

; Create a new empty node
; @param bc: data
; @return hl: first node of the linked list
; @destroy all
LinkedListNodeNew::
	call LinkedListNodeAlloc
	ld [hli], 0
	ld [hli], 0
	ld [hli], b
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
	ld [hli], 0
	ld [hli], 0
	ld [hli], b
	ld [hl], c

	pop hl
	ld [hli], d
	ld [hli], e
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

            ld [hli], d
            ld [hl], e
            jp .done

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

