; This file contains data completely unused by the game.
; It's only purpose is to preserve the ability to build
; a program that exactly matches the retail binary.

	.include "game_design.i"

	.segment "COMMAND_JUNK"

; cruft leftover from earlier build
.if REVISION = 1
	.byte $07
	nop
.elseif REVISION = 2
	.byte $95,$20,$22,$34,$a2,$01,$86,$1a
	.byte $20,$f3,$33,$20,$ca,$0c,$ad,$9c
	.byte $61,$c9,$46,$10,$0f,$20,$40,$26
	.byte $20,$19
; cruft decoded:
;	.byte $95
;	jsr $3422
;	ldx #$01
;	stx $1A
;	jsr $33F3
;	jsr get_player_input
;	lda gd_parsed_action
;	cmp #$46
;	bpl +15  ;to $337A
;	jsr player_cmd
;	jsr $??19
.endif

