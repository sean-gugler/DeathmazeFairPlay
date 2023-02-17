; This file contains data completely unused by the game.
; It's only purpose is to preserve the ability to build
; a program that exactly matches the retail binary.

	.import pit
	.import update_view
	.import item_cmd
	.import nonsense
	.import print_to_line2
	.import row8_table
	.import see_inventory

	.include "game_state.i"
	.include "item_commands.i"
	.include "string_noun_decl.i"

zp0E_object        = $0E;
zp0F_action        = $0F;
zp1A_item_place    = $1A;

	.segment "MAIN4"

; cruft leftover from earlier build
	.byte $95,$61
	;[sta] gs_player_x
	jsr pit
	jsr update_view
	jmp $3493  ;in special_bat

	rts

	stx zp0F_action
	jsr item_cmd
	lda #$06
	cmp $1A
	beq b110D
	dec $11
	.byte $d0, $dd  ;bne -35
	pla
	sta zp0E_object
	pla
	sta zp0F_action
	jmp $2EFB  ;in cmd_take

b110D:
	pla
	sta zp0E_object
	pla
	sta zp0F_action
	lda gs_parsed_object
	cmp #noun_torch
	beq :+
	jmp $2E72  ;in cmd_take

:	inc gs_torches_unlit
	jmp $2E72  ;in cmd_take

; cruft leftover from even earlier build
	dec zp0F_action
	bne cruft_cmd_paint
	lda zp0E_object
	cmp #noun_snake
	beq @not_here
	cmp #nouns_item_end
	bpl :+
	jmp nonsense

:	cmp #noun_zero
	bmi :+
	jmp nonsense

:	cmp #noun_door
	bne @not_here
	jmp nonsense

@not_here:
	lda #$90     ;I don't see that here.
	jsr print_to_line2
	rts

cruft_cmd_paint:
	dec zp0F_action
	.byte $d0,$18  ;bne +24 to next command
	ldx #noun_brush
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_known
	beq :+
	jmp see_inventory

:	lda #$6f
; (end cruft)

