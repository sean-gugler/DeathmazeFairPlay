	.export swap_saved_A_2
	.export swap_saved_A
	.export swap_saved_vars

zp13_temp = $13

	.segment "SWAP_DATA"
	
saved_A:
	.byte "D"
saved_zp0E:
	.byte "E"
saved_zp0F:
	.byte "A"
saved_zp10:
	.byte "T"
saved_zp11:
	.byte "H"
saved_zp19:
	.byte $07
saved_zp1A:
	.byte $00


	.segment "SWAP_CODE_DUPE"

swap_saved_A_2:
	sta zp13_temp
	lda saved_A
	pha
	lda zp13_temp
	sta saved_A
	pla
	rts

	.segment "SWAP_CODE"

swap_saved_A:
	sta zp13_temp
	lda saved_A
	pha
	lda zp13_temp
	sta saved_A
	pla
	rts

swap_saved_vars:
	lda $0E
	tax
	lda saved_zp0E
	sta $0E
	txa
	sta saved_zp0E
	lda $0F
	tax
	lda saved_zp0F
	sta $0F
	txa
	sta saved_zp0F
	lda $10
	tax
	lda saved_zp10
	sta $10
	txa
	sta saved_zp10
	lda $11
	tax
	lda saved_zp11
	sta $11
	txa
	sta saved_zp11
	lda $19
	tax
	lda saved_zp19
	sta $19
	txa
	sta saved_zp19
	lda saved_zp1A
	tax
	lda $1A
	sta saved_zp1A
	txa
	sta $1A
	rts


