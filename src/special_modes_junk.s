; This file contains data completely unused by the game.
; It's only purpose is to preserve the ability to build
; a program that exactly matches the retail binary.

	.include "game_design.i"

	.segment "SPECIAL_MODES"

; cruft leftover from earlier build
.if REVISION = 1
; cruft decoded:
	.byte $86
	inc $C3
	bne b3EDC
	ldx #$2e
	jsr $244B ;within keyhole
b3EDC:
	stx $BE
	stx $BD
	lda $018F
	.byte $f0,$5B  ;beq +71 to $3F40
	lda $0135,y
	cmp #$28
	beq b3EF4
	ldx #$25
	jsr $244B ;within keyhole
	jmp $3F56

b3EF4:
	stx $E5
	iny
	jsr $2510 ;draw_keyhole somewhere
	cmp #$3b
	.byte $f0,$3a  ;beq +58 to $3F38
	cpy #$50

.elseif REVISION = 2

	.byte $66,$f0,$3a,$c0,$50
; cruft decoded
;	beq +58 ;to $3F38
;	cpy #$50
.endif
; (end cruft)

