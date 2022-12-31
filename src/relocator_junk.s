; This file contains data completely unused by the game.
; It's only purpose is to preserve the ability to build
; a program that exactly matches the retail binary.

	.include "apple.i"

	.segment "RELOCATOR_JUNK"

; cruft leftover from earlier build
	ldy #$00
	tya
	sta ($C2),y
	cmp #$ff
	bne b3F68
	dec $C3
b3F68:
	pla
	pla
	jmp $2C04 ;within open_box

	stx $BC
	ldx #$2b
	jsr $244B ;within keyhole
	jmp $2C04 ;within open_box

s3F77:
	lda $0124
	sta tape_addr_start
	lda $0125
	sta tape_addr_start+1
	lda $0126
	sta tape_addr_end
	lda $0127
	sta tape_addr_end+1
	rts

	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00

; cruft leftover from earlier build
	lda $EE
	beq b3FA3
	jsr s3FA0
	rts

s3FA0:
	jmp ($00F6)

b3FA3:
	jsr s3F77
	jsr rom_READ_TAPE
	ldx #$00
	rts

	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00

; cruft leftover from even earlier build
	lda $EF
	beq b3FD3
	jsr s3FD0
	rts

s3FD0:
	jmp ($00F4)

b3FD3:
	jsr s3F77
	jsr rom_WRITE_TAPE
	rts

	jsr $FD35
	cmp #$95
	bne b3FE3
	lda ($28),y
b3FE3:
	rts

	ora #$80
	jmp rom_COUT

	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$08,$00

