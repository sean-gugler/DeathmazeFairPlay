; This file contains data completely unused by the game.
; It's only purpose is to preserve the ability to build
; a program that exactly matches the retail binary.

	.segment "DRAW_JUNK"

; cruft leftover from earlier build
	.byte $10,$ad,$09,$01,$20,$02,$34,$ad
	.byte $08,$01,$20,$02,$34,$60,$a9,$00
	.byte $9d,$00,$01,$9d,$01,$01,$85,$df
	.byte $85,$e0,$20,$6e
;
;	bpl -83
;	ora #$01
;	jsr $3402
;	lda $0108
;	jsr $3402
;	rts
;
;	lda #$00
;	sta $0100,x
;	sta $0101,x
;	sta $df
;	sta $e0
;	jsr $??6e
;
; (end cruft)

