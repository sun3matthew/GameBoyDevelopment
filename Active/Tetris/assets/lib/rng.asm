INCLUDE "inc/hardware.inc"

SECTION "RNG SEED", HRAM
    RNGSEED: ds 4

SECTION "RNG", ROM0

; generate 4 bytes of randomness from semi random initial wram trash and store them in RNGSEED
InitRNG::
    ld de, RNGSEED
    ld hl, $C000                
    .repeat                         
        push de                     
        ld bc, $0080                
        call extract_byte_from_data 
        pop de                      
        ld [de], a                 
        ld a, h                   
        cp a, $D0                

        jr z, .done                 

        inc de                     
        jr .repeat                 
    .done
    call comb16_rand_init
ret

comb16_rand_init:
    ld hl, RNGSEED+2            
    ; .seed34
        ld a, [hl+]                 
        and a, a                    
        jr nz, .done                
        ld a, [hl]                  
        and a, a                    
        jr nz, .done                
    .repeat2                        
        ld a, [rDIV]                
        and a, a                    
        jr z, .repeat2              
        ld [hl], a                  
    .done
ret                         

; generates a random 16 bit number
; @cycles 38 (I think)
; @return hl: the random number
Rand:: 
    ; .lcg                            
        ld a, [RNGSEED]             
        ld h, a                     
        ld a, [RNGSEED+1]           
        ld l, a                     
    
        ld b, h                     
        ld c, l                     
        add hl, hl                  
        add hl, hl                  
        add hl, bc                  
        inc l                       
    
        ld a, l                     
        ld [RNGSEED+1], a           
        ld a, h                     
        ld [RNGSEED], a             
    
    ; .lfsr
        ld a, [RNGSEED+2]           
        ld h, a                     
        ld a, [RNGSEED+3]           
        ld l, a                     
    
        add hl, hl                  
        sbc a, a                    
        and a, $2D                  
        xor a, l                    
        ld l, a                     
    
        ld [RNGSEED+3], a           
        ld a, h                     
        ld [RNGSEED+2], a           
    
    ; .mixup
        add hl, bc                  
    
    ret                         

; Gets randomness of a memory by using the popcount parities of eight subsequent N length data chunks.
; @param hl: A pointer to the beginning of the target buffer
; @param bc: N (feed counter) in the 13 LS bits
; @destroy de
; @return a, d: the extracted byte
extract_byte_from_data:
    ; .prepare_result_variable
        xor a, a                    
     .rept_with_next_bit             
        ld d, a                     
    ; .prepare_feed_counter           
        push bc                     
        ld a, b                     
        and a, %00011111            
        ld b, a                     
    .rept_with_this_bit             
        ld a, [hl+]                 
    
    ; .popcount_parity_of_byte_to_a   
        ld e, a                     
        swap a                      
        xor a, e                    
        ld e, a                     
        rlca                        
        rlca                        
        xor a, e                    
        ld e, a                     
        rlca                        
        xor a, e                    
    
        ld e, a                     ; abs a
        xor a, a                    
        sub a, e                    
    
    ; .adjust_global_popcount_parity  
        xor a, d                    
        ld d, a                    
        dec bc                     
    ; .feed_counter_zero_check
        ld a, c                     
        and a                       
        jr nz, .rept_with_this_bit  
        ld a, b                     
        and a                       
        jr nz, .rept_with_this_bit  
    ; .feed_counter_at_zero
    ; .adjust_bit_counter             
        pop bc                      
        ld a, b                     
        and a, %11100000            
        rrca                        
        swap a                      
        inc a                       
        cp a, 8                     
    
        jr z, .extraction_done      
    ; .prepare_bit_counter            
        rlca                        
        swap a                      
        ld e, a                     
        ld a, b                     
        and a, %00011111            
        or a, e                     
        ld b, a                     
    ; .adjust_result_variable         
        ld a, d                     
        rlca                        
    ; .continue_with_next_bit         
        jr .rept_with_next_bit      
    .extraction_done
        ld a, d                     
        ret                         
