INCLUDE "inc/hardware.inc"

; ******************************************************************************
; RESTART VECTORS ($0000--$003F)
; ******************************************************************************

;* "The restart vectors are locations that are jumped to if the CPU happens upon
;* a RST $XX opcode. Basically, they are used in routines as a fast CALL, since
;* a normal CALL opcode takes 3 bytes and an RST only takes one byte. Usually,
;* an RST will either have a very short routine, only a few bytes long, since
;* there are only 8 bytes between each RST (eg: $00, $08, $10, $18, etc).
;* Sometimes, if you need a routine a little bit longer than 8 bytes, you can
;* place a JP (jump) at the RST that jumps to your other routine, but TAKE NOTE
;* that jumping is a 3 byte long instruction and defeats the purpose of speed in
;* a RST." [ASMS]

;* Note that an RST $XX and a JP a16 both take three CPU cycles so RST is not
;* faster but only shorter.

SECTION "Restart Vectors", ROM0[$0000]

;* The SECTION directive RGBASM specific:
;* "Before you can start writing code, you must define a section. This tells the
;* assembler what kind of information follows and, if it is code, where to put
;* it." [RGBDS]
;* For more information please refer to the RGBDS Documentation.

SECTION "RST00", ROM0[$0000]
    ret                         ; 1/4
    DS 7                        ; 7/0   define storage, 7 pad bytes
                                ; b|c   shows the required bytes and CPU cycles

SECTION "RST08", ROM0[$0008]
    ret                         ; 1|4
    DS 7                        ; 7|0

SECTION "RST10", ROM0[$0010]
    ret                         ; 1|4
    DS 7                        ; 7|0

SECTION "RST18", ROM0[$0018]
    ret                         ; 1|4
    DS 7                        ; 7|0

SECTION "RST20", ROM0[$0020]
    ret                         ; 1|4
    DS 7                        ; 7|0

SECTION "RST28", ROM0[$0028]
    ret                         ; 1|4
    DS 7                        ; 7|0

SECTION "RST30", ROM0[$0030]
    ret                         ; 1|4
    DS 7                        ; 7|0

SECTION "RST38", ROM0[$0038]
    ret                         ; 1|4
    DS 7                        ; 7|0


; ******************************************************************************
; INTERRUPT VECTORS ($0040--$00FF)
; ******************************************************************************

;* "The interrupt vectors are locations that the CPU will jump to if certain
;* hardware conditions are met. These hardware conditions are easily
;* enabled/disabled by setting the corresponding bits in the IE (located at
;* $FFFF) register." [ASMS]

;* "When multiple interrupts occur simultaneously, the IE flag of each is set,
;* but only that with the highest priority is started. Those with lower
;* priorities are suspended." [GBPM]

;* "The CPU automatically disables all other interrupts by setting IME=0 when it
;* executes an interrupt. Usually IME remains zero until the interrupt procedure
;* returns (and sets IME=1 by the RETI instruction). However, if you want any
;* other interrupts of lower or higher (or same) priority to be allowed to be
;* executed from inside of the interrupt procedure, then you can place an EI
;* instruction into the interrupt procedure." [PD]

;* "The interrupt processing routine should push the registers during interrupt
;* processing." [GBPM]

;* "Usually, an interrupt vector consists of pushing all 4 registers pairs,
;* followed by a jump to another location." [GBD.IRQV]

SECTION "Interrupt Vectors", ROM0[$0040]

;* "LCD Display Vertical Blanking (Vblank) happens once every frame when the LCD
;* screen has drawn the final scanline. During this short time it’s safe to mess
;* with the video hardware and there won’t be interference." [AD.SKEL]
SECTION	"LCD Display Vertical Blanking", ROM0[$0040]               ; Priority: 1
    reti                        ; 1|4
    DS 7                        ; 7|0

;* "Status Interrupts from LCDC is fired when certain conditions are met in the
;* LCD Status register. Writing to the LCD Status Register, it’s possible to
;* configure which events trigger the Status interrupt. One use is to trigger
;* Horizontal Blank (“h-blank”) interrupts, which occur when there’s a very
;* small window of time between scanlines of the screen, to make a really tiny
;* change to the video memory." [AD.SKEL]
SECTION	"Status Interrupts from LCDC", ROM0[$0048]                 ; Priority: 2
    reti                        ; 1|4
    DS 7                        ; 7|0

;* "Timer Overflow Interrupt is fired when the Game Boy’s 8-bit timer wraps
;* around from 255 to 0. The timer’s update frequency is customizable."
;* [AD.SKEL]
SECTION	"Timer Overflow Interrupt", ROM0[$0050]                    ; Priority: 3
    reti                        ; 1|4
    DS 7                        ; 7|0

;* "Serial Transfer Completion Interrupt is triggered when the a serial link
;* cable transfer has completed sending/receiving a byte of data."  [AD.SKEL]
SECTION	"Serial Transfer Completion Interrupt", ROM0[$0058]        ; Priority: 4
    reti                        ; 1|4
    DS 7                        ; 7|0

;* End of Input Signal for ports P10-P13 (Joypad) Interrupt is triggered when
;* any of the six buttons is pressed on the joypad. "The primary purpose of this
;* interrupt is to break the Game Boy from its low-power standby state, and
;* isn’t terribly useful for much else." [AD.SKEL]
SECTION	"End of Input Signal for ports P10-P13 Interrupt", ROM0[$0060]
                                                                   ; Priority: 5
    reti                        ; 1|4
    DS 7                        ; 7|0

;* "After the interrupt vectors there is a small area with some free space which
;* you can use for whatever you want." [AD.SKEL]
;*
;* This space can be used for anything you want including an uncommon longer
;* joypad interrupt handler or anything else. You might also enlarge it with the
;* previous seven pad area if you are fine with the plain reti joypad handler.
;* Moreover, the whole $0000--$00FF area can be used freely if your program
;* does not use restarts and disables interrupts. You can also do relative jumps
;* over required restart and/or interrupt handlers if necessary.
SECTION	"Free Space from $068", ROM0[$0068]
    DS 152                      ; 152|0 $0068--$00FF


; ******************************************************************************
; ROM REGISTRATION DATA ($0100--$014F)
; ******************************************************************************

;* The first part of the ROM is the 80 bytes long registration data with
;* information regarding the game title and Game Boy software specifications.
;* This 80 bytes are located at $0100--$014F on the ROM. (The $ before a number
;* indicates that the number is a hex value.)
SECTION	"ROM Registration Data", ROM0[$0100]  ; ends with $014F

;* 1. Code execution starting point and start address: The program starts after
;*    Initial Program Load (IPL) is run on the CPU. The standard first two
;*    commands are usually always a NOP (NO Operation) and then a JP (Jump)
;*    command. This JP command should 'jump' to the start of user code. It jumps
;*    over the remaining ROM Registration Data, usually to $0150. The jump
;*    command length is three byte with bytes 2 and 3 containing the address,
;*    which is in this case the start address of the program. As the Game Boy
;*    CPU is little-endian so the low byte of the starting address is stored
;*    first, then the high byte.
    nop                         ; 1|1   $00
    jp $0150                     ; 3|4   $C3 $Lo $Hi (begin is a label which will
                                ;       get replaced with its start address by
                                ;       the assembler)

;* 2. Nintendo logo:  "For a piece of software to run on a Game Boy, it must
;*    contain a copy of Nintendo's logo identical to the one in the console's
;*    internal ROM, and that logo will be displayed at startup; this was
;*    presumably done for similar reasons as Sega's TMSS, in that it forces any
;*    unlicensed producer of cartridges (whether a pirate or an otherwise
;*    legitimate unlicensed developer) to include the Nintendo logo in their
;*    games, theoretically committing trademark infringement in the process. ...
;*    But, fortunately for unlicensed developers, Sega's TMSS didn't hold up in
;*    court (in the US anyway), which I'd guess rendered Nintendo's Game Boy
;*    efforts largely pointless too." [GGLOGO]
;*
;*    The included HARDWARE.INC have a "NINTENDO_LOGO" macro to make this easy.
;*    Note that RGBFIX (-v) als set this data properly.
SECTION	"Nintendo Logo", ROM0[$0104]
    NINTENDO_LOGO               ; 30|0

;* 3. Game title: "The game title is an ASCII code up to 11 characters. Use code
;*    $20 for a space and code $00 for all unused areas in the game title."
;*    [GBPM] The following (uppercase) characters are allowed
;*    (between >> and <<):
;*      >> !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_<<   "
;*    Note that forthslashes (\) might be treated as ¥ signs.
SECTION	"Game Title", ROM0[$0134]
    DB "TETRIS"                 ; 6|0
       ;0123456789A
    DS 5                        ; 5|0   unused area

;* 4. Game code: Ideally the Game Code is assigned by Nintendo. Its allowed
;*    ASCII characters are the same as for the game title. Best practice for
;*    unlicensed products is to fill this area with spaces.
SECTION	"Game Code", ROM0[$013F]
    DB "    "                   ; 4|0
       ;0123

;* 5. CGB Support Code: "This value distinguishes between games that are CGB
;*    (Game Boy Color) compatible, and those that are not. Valid values:
;*    • $00: CGB Incompatible. A program which does not use CGB functions, but
;*           operates with both CGB and DMG (Monochrome).
;*    • $80: CGB Compatible. A program which uses CGB functions, and operates
;*           with both CGB and DMG.
;*    • $C0: CGB Exclusive. A program which uses CGB functions, but will only
;*           operate on a Game Boy Color unit (not on DMG/MGB). If a user
;*           attempts to play this software on Game Boy, a screen must be
;*           displayed telling the user that the game must be played on Game Boy
;*           Color." [GBPM]
SECTION	"CGB Support Code", ROM0[$0143]
    DB $C0                      ; 1|0

;* 6. Maker Code: 2-digit uppercase ASCII code assigned by Nintendo. Best
;*    practice for unlicensed products is to fill this area with spaces.
SECTION	"Maker Code", ROM0[$0144]
    DB "  "                     ; 2|0
       ;01

;* 7. SGB Support Code: Specifies whether the game supports SGB functions. Valid
;*    values:
;*    • $00: No Super Game Boy Functions
;*    • $03: Uses Super Game Boy Functions
;*    In order to use Super Game Boy Functions, the Legacy Maker Code must be
;*    $33. [GBPM]
SECTION	"SGB Support Code", ROM0[$0146]
    DB $00	                    ; 1|0

;* 8. Software Type (Cartridge Type): "Specifies which Memory Bank Controller
;*    (if any) is used in the cartridge, and if further external hardware exists
;*    in the cartridge." [PD] The valid values are listed in the first block of
;*    the "Cart related" section of HARDWARE.INC.
SECTION	"Software Type", ROM0[$0147]
    DB CART_ROM                 ; 1|0

;* 9. ROM Size: "Specifies the ROM Size of the cartridge." [PD] The valid values
;*    are listed in the second block of the "Cart related" section of
;*    HARDWARE.INC.
;* rgbfix -p 0xFF to pad & fill this area
SECTION	"ROM Size", ROM0[$0148]
    DB $00            ; 1|0

;* 10. External RAM Size: "Specifies the size of the external RAM in the
;*     cartridge (if any)." [PD] The valid values are listed in the third block
;*     of the "Cart related" section of HARDWARE.INC.
SECTION	"External RAM Size", ROM0[$0149]
    DB CART_SRAM_NONE            ; 1|0

;* 11. Destination Code: "Specifies if this version of the game is supposed to
;*     be sold in Japan, or anywhere else. Only two values are defined:" [PD]
;*     • $00: Japan
;*     • $01: All Others
SECTION	"Destination Code", ROM0[$014A]
    DB $01                      ; 1|0

;* 12. Legacy Maker Code: "Specifies the games company/publisher code in range
;*     $00--$FF." [PD] A value of $33 signalizes that the new Maker Code in
;*     header bytes $0144--$0145 is used instead. Note that Super GameBoy
;*     functions will not work if this value is not $33. [PD]
SECTION	"Legacy Maker Code", ROM0[$014B]
    DB $33                      ; 1|0

;* 13. Mask ROM Version N0.: "The mask ROM version number starts from $00 and
;*     increases by 1 for each revised version sent after starting production."
;*     [GBPM] Therefore this value is usually $00.
SECTION	"Mask ROM Version N0.", ROM0[$014C]
    DB $00                      ; 1|0

;* 14. Complement Check (Header Checksum): "After all the registration data has
;*     been entered ($0134--$014C), add $19 to the sum of the data stored at
;*     addresses $0134 through $014C and store the complement value of the
;*     resulting sum.
;*             ($0134) + ($0135) + ... + ($014C) + $19 + ($014D) = $00
;*     " [GBPM]
;*     We usually use RGBFIX (-v) to set this value for us, thus, set it to $00.
SECTION	"Complement Check", ROM0[$014D]
    DB $00                      ; 1|0

;* 15. Check Sum Hi and Lo (Global Checksum): "Contains a 16 bit checksum (upper
;*     byte first) across the whole cartridge ROM. Produced by adding all bytes
;*     of the cartridge (except for the two checksum bytes). The Gameboy doesn't
;*     verify this checksum." [PD]
;*     We usually use RGBFIX (-v) to set this value for us, thus, set it to $00.
SECTION	"Check Sum Hi and Lo", ROM0[$014E]
    DW $0000                    ; 2|0
