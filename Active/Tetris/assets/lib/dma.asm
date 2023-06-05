INCLUDE "inc/hardware.inc"

SECTION "OAM DMA routine", ROM0
	; Init the DMA routine in HRAM
	CopyDMARoutine::
	  ld  hl, DMARoutine
	  ld  b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
	  ld  c, LOW(hOAMDMA) ; Low byte of the destination address
	.copy
	  ld  a, [hli]
	  ldh [c], a
	  inc c
	  dec b
	  jr  nz, .copy
	  ret
	
	DMARoutine:
	  ldh [rDMA], a
	  
	  ld  a, 40
	.wait
	  dec a
	  jr  nz, .wait
	  ret
	DMARoutineEnd:

SECTION "OAM DMA", HRAM
	; Start an OAM DMA transfer.
	; @param a: HIGH(source)
	hOAMDMA::
		ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to

