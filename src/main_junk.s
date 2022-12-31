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
	lda gd_parsed_object
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
	bpl :+  ;GUG: bcs preferred
	jmp nonsense

:	cmp #noun_zero
	bmi :+  ;GUG: bcc preferred
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
	bne row8_table+2  ;cruft_cmd
	ldx #noun_brush
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_known
	beq :+
	jmp not_carried

:	lda #$6f
; (end cruft)

