
/*
DEF PIECE_I EQU 0
DEF PIECE_J EQU 1
DEF PIECE_L EQU 2
DEF PIECE_O EQU 3
DEF PIECE_S EQU 4
DEF PIECE_Z EQU 5
DEF PIECE_T EQU 6
*/
SECTION "Pieces", ROM0
Pieces::
    ; PIECE_I
        ; R0
            db 0, 0, 1, 0
            db 0, 0, 1, 0
            db 0, 0, 1, 0
            db 0, 0, 1, 0
        ; R1
            db 0, 0, 0, 0
            db 0, 0, 0, 0
            db 1, 1, 1, 1
            db 0, 0, 0, 0
        ; R2
            db 0, 0, 1, 0
            db 0, 0, 1, 0
            db 0, 0, 1, 0
            db 0, 0, 1, 0
        ; R3
            db 0, 0, 0, 0
            db 0, 0, 0, 0
            db 1, 1, 1, 1
            db 0, 0, 0, 0
    
    ; PIECE_J
        ; R0
            db 0, 0, 0, 0
            db 0, 1, 1, 1
            db 0, 0, 0, 1
            db 0, 0, 0, 0
        ; R1
            db 0, 0, 1, 0
            db 0, 0, 1, 0
            db 0, 1, 1, 0
            db 0, 0, 0, 0
        ; R2
            db 0, 1, 0, 0
            db 0, 1, 1, 1
            db 0, 0, 0, 0
            db 0, 0, 0, 0
        ; R3
            db 0, 0, 1, 1
            db 0, 0, 1, 0
            db 0, 0, 1, 0
            db 0, 0, 0, 0
    
    ; PIECE_L
        ; R0
            db 0, 0, 0, 0
            db 0, 1, 1, 1
            db 0, 1, 0, 0
            db 0, 0, 0, 0
        ; R1
            db 0, 1, 1, 0
            db 0, 0, 1, 0
            db 0, 0, 1, 0
            db 0, 0, 0, 0
        ; R2
            db 0, 0, 0, 1
            db 0, 1, 1, 1
            db 0, 0, 0, 0
            db 0, 0, 0, 0
        ; R3
            db 0, 0, 1, 0
            db 0, 0, 1, 0
            db 0, 0, 1, 1
            db 0, 0, 0, 0
    
    ; PIECE_O
        ; R0
            db 0, 0, 0, 0
            db 0, 1, 1, 0
            db 0, 1, 1, 0
            db 0, 0, 0, 0
        ; R1
            db 0, 0, 0, 0
            db 0, 1, 1, 0
            db 0, 1, 1, 0
            db 0, 0, 0, 0
        ; R2
            db 0, 0, 0, 0
            db 0, 1, 1, 0
            db 0, 1, 1, 0
            db 0, 0, 0, 0
        ; R3
            db 0, 0, 0, 0
            db 0, 1, 1, 0
            db 0, 1, 1, 0
            db 0, 0, 0, 0

    ; PIECE_S
        ; R0
            db 0, 0, 0, 0
            db 0, 0, 1, 1
            db 0, 1, 1, 0
            db 0, 0, 0, 0
        ; R1
            db 0, 0, 1, 0
            db 0, 0, 1, 1
            db 0, 0, 0, 1
            db 0, 0, 0, 0
        ; R2
            db 0, 0, 0, 0
            db 0, 0, 1, 1
            db 0, 1, 1, 0
            db 0, 0, 0, 0
        ; R3
            db 0, 0, 1, 0
            db 0, 0, 1, 1
            db 0, 0, 0, 1
            db 0, 0, 0, 0
            
    ; PIECE_Z
        ; R0
            db 0, 0, 0, 0
            db 0, 1, 1, 0
            db 0, 0, 1, 1
            db 0, 0, 0, 0
        ; R1
            db 0, 0, 0, 1
            db 0, 0, 1, 1
            db 0, 0, 1, 0
            db 0, 0, 0, 0
        ; R2
            db 0, 0, 0, 0
            db 0, 1, 1, 0
            db 0, 0, 1, 1
            db 0, 0, 0, 0
        ; R3
            db 0, 0, 0, 1
            db 0, 0, 1, 1
            db 0, 0, 1, 0
            db 0, 0, 0, 0
    
    ; PIECE_T
        ; R0
            db 0, 0, 0, 0
            db 0, 1, 1, 1
            db 0, 0, 1, 0
            db 0, 0, 0, 0
        ; R1
            db 0, 0, 1, 0
            db 0, 0, 1, 1
            db 0, 0, 1, 0
            db 0, 0, 0, 0
        ; R2
            db 0, 0, 1, 0
            db 0, 1, 1, 1
            db 0, 0, 0, 0
            db 0, 0, 0, 0
        ; R3
            db 0, 0, 1, 0
            db 0, 1, 1, 0
            db 0, 0, 1, 0
            db 0, 0, 0, 0
    
    


PiecesEnd::