	.segment "START"

cold_start:
	cli
	ldx #$00
	stx clock
	stx clock+1
new_session:
	jsr relocate_data
	stx zp_col
	bit hw_PAGE2
	bit hw_FULLSCREEN
	bit hw_HIRES
	bit hw_GRAPHICS
	jsr clear_hgr2
	nop
	jsr get_rowcol_addr
	lda #$94     ;Continue a game?
	jsr print_display_string
	jsr input_Y_or_N
	cmp #'Y'
	bne new_game
	jsr load_disk_or_tape
	lda #$96     ;Press any key
	nop
	nop
	jsr print_to_line2
	jsr input_char
	jsr load_from_tape
	jmp start_game

new_game:
	ldx #icmd_reset_game
	stx zp0F_action
	jsr item_cmd
start_game:
	ldx #char_ESC
	stx gd_parsed_action
	jsr player_cmd
	jmp main_game_loop

clear_hgr2:
	ldx #<screen_HGR2
	stx zp0E_ptr
	ldx #>screen_HGR2
	stx zp0E_ptr+1
	ldy #$00
@next_page:
	tya
:	sta (zp0E_ptr),y
	inc zp0E_ptr
	bne :-
	inc zp0E_ptr+1
	lda zp0E_ptr+1
	cmp #$60
	bne @next_page
	rts

	nop
	nop
	nop
load_from_tape:
	ldx #<game_save_begin
	stx tape_addr_start
	ldx #>game_save_begin
	stx tape_addr_start+1
	ldx #>game_save_end
	stx tape_addr_end+1
	ldx #<game_save_end
	stx tape_addr_end
	jsr rom_READ_TAPE
	jsr clear_hgr2
	jsr update_view
	jsr check_signature  ;NOTE: never returns, continues with PLA/PLA/JMP
	nop
	jmp item_cmd

