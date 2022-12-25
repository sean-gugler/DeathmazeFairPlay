	.include "deathmaze_b.i"

	.feature  string_escapes

;
; **** ZP FIELDS ****
;
f61 = $61
;
; **** ZP ABSOLUTE ADRESSES ****
;
zp_col = $06
zp_row = $07
screen_ptr = $08
;screen_ptr+1 = $09
zp0A_text_ptr = $0a
;text_ptr+1 = $0b
zp_0C_string = $0c
zp_0D = $0d
zp0E_object = $0e
zp0F_action = $0f
zp10_noun = $10
zp11_box_item = $11
a13 = $13
a14 = $14
line_count = $15
zp_counter = $16
clock = $17
;clock+1 = $18
a19 = $19
zp1A_item_place = $1a
tape_addr_start = $3c
;tape_addr_start+1 = $3d
tape_addr_end = $3e
;tape_addr_end+1 = $3f
aBC = $bc
aBD = $bd
aBE = $be
aC3 = $c3
aE5 = $e5
aEE = $ee
aEF = $ef
;
; **** ZP POINTERS ****
;
;screen_ptr = $08
;zp0A_text_ptr = $0a
;zp_0C_string = $0c
;zp0E_object = $0e
;zp10_noun = $10
p13 = $13
p19 = $19
p28 = $28
pC2 = $c2
;
; **** FIELDS ****
;
f0135 = $0135
;
; **** ABSOLUTE ADRESSES ****
;
a0124 = $0124
a0125 = $0125
a0126 = $0126
a0127 = $0127
a018F = $018f
;
; **** POINTERS ****
;
p01 = $0001
p00F4 = $00f4
p00F6 = $00f6
p0402 = $0402
;
; **** EXTERNAL JUMPS ****
;
eFD35 = $fd35
;
; **** USER LABELS ****
;
DOS_call_rwts = $03d9
DOS_hook_monitor = $03f8
;DOS_hook_monitor+1 = $03f9
;DOS_hook_monitor+2 = $03fa
screen_GR1 = $0400
hw_KEYBOARD = $c000
hw_STROBE = $c010
hw_GRAPHICS = $c050
hw_TEXT = $c051
hw_FULLSCREEN = $c052
hw_PAGE1 = $c054
hw_PAGE2 = $c055
hw_LORES = $c056
hw_HIRES = $c057
rom_COUT = $fded
rom_WRITE_TAPE = $fecd
rom_READ_TAPE = $fefd
rom_MONITOR = $ff69



	.segment "MAIN"

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
	stx zp0E_object
	ldx #>screen_HGR2
	stx zp0F_action
	ldy #$00
@next_page:
	tya
:	sta (zp0E_object),y
	inc zp0E_object
	bne :-
	inc zp0F_action
	lda zp0F_action
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
	jsr draw_view
	jsr check_signature ;NOTE: never returns, continues with PLA/PLA/JMP
	nop
	jmp item_cmd

print_to_line1:
	ldx #$00
	stx zp_col
	ldx #$16
	stx zp_row
	ldx #<text_buffer1
	stx zp0A_text_ptr
	ldx #>text_buffer1
	stx text_ptr+1
	bne print_to_line
print_to_line2:
	ldx #$00
	stx zp_col
	ldx #$17
	stx zp_row
	ldx #<text_buffer2
	stx zp0A_text_ptr
	ldx #>text_buffer2
	stx text_ptr+1
print_to_line:
	jsr get_display_string
	jsr get_rowcol_addr
	jsr clear_text_buf
	ldy #$00
	lda (zp_0C_string),y
	and #$7f
@next_char:
	sta (zp0A_text_ptr),y
	jsr print_char
	inc zp_0C_string
	bne :+
	inc zp_0D
:	inc zp0A_text_ptr
	bne :+
	inc text_ptr+1
:	ldy #$00
	lda (zp_0C_string),y
	bpl @next_char
	lda #char_ClearLine
	jsr char_out
	rts

print_display_string:
	jsr get_display_string
print_string:
	jsr get_rowcol_addr
	ldy #$00
	lda (zp_0C_string),y
	and #$7f
@next_char:
	jsr print_char
	inc zp_0C_string
	bne :+
	inc zp_0D
:	ldy #$00
	lda (zp_0C_string),y
	bpl @next_char
	rts

get_display_string:
	sta zp_string_number
	ldx #<display_string_table
	stx zp_0C_string
	ldx #>display_string_table
	stx zp_0D
	ldy #$00
@scan:
	lda (zp_0C_string),y
	bmi @found_string
@next_char:
	inc zp_0C_string
	bne @scan
	inc zp_0D
	bne @scan
@found_string:
	dec zp_string_number
	bne @next_char
	rts

clear_text_buf:
	ldy #$27
	lda #' '
:	sta (zp0A_text_ptr),y
	dey
	bpl :-
	rts

main_game_loop:
	jsr get_player_input
	lda gd_parsed_action
	cmp #verb_movement_begin
	bmi cmd_verbal
	jsr cmd_movement
next_game_loop:
	lda gs_special_mode
	beq main_game_loop
	jsr check_special_mode
	jmp main_game_loop

cmd_verbal:
	jsr player_cmd
	jmp next_game_loop

cmd_movement:
	ldx gs_facing
	stx zp1A_item_place
	cmp #verb_forward
	beq move_forward
	jsr move_turn
	rts

move_turn:
	cmp #verb_left
	beq b0975
	cmp #verb_uturn
	beq b0987
	lda zp1A_item_place
	cmp #$04
	beq b0969
	inc gs_facing
	bne b096E
b0969:
	ldx #$01
	stx gs_facing
b096E:
	jsr draw_view
	jsr print_timers
	rts

b0975:
	lda zp1A_item_place
	cmp #$01
	beq b0980
	dec gs_facing
	bpl b096E
b0980:
	ldx #$04
	stx gs_facing
	bne b096E
b0987:
	lda zp1A_item_place
	cmp #$03
	bmi b0995
	dec gs_facing
	dec gs_facing
	bpl b096E
b0995:
	inc gs_facing
	inc gs_facing
	bpl b096E
move_forward:
	lda gs_level
	cmp #$03
	bne b09C9
	lda gs_player_x
	cmp #$07
	bne b09C9
	lda gs_player_y
	ldx gs_facing
	stx zp1A_item_place
	cmp #$08
	beq b09C3
	cmp #$09
	bne b09C9
	lda zp1A_item_place
	cmp #$04
	bne b09C9
	beq b09DF
b09C3:
	lda zp1A_item_place
	cmp #$02
	beq b09DF
b09C9:
	lda a619A
	and #$e0
	bne b09DF
	jsr clear_maze_window
	lda #$09
	sta zp_col
	sta zp_row
	lda #$7c     ;Splat!
	jsr print_display_string
	rts

b09DF:
	ldx gs_facing
	dex
	beq b09FA
	dex
	beq b09F5
	dex
	beq b09F0
	dec gs_player_y
	bpl b09FD
b09F0:
	inc gs_player_x
	bpl b09FD
b09F5:
	inc gs_player_y
	bpl b09FD
b09FA:
	dec gs_player_x
b09FD:
	jsr check_special_position
	lda gs_special_mode
	beq b0A06
	rts

b0A06:
	jsr complete_turn
	jsr draw_view
	jsr print_timers
	rts

check_special_position:
	lda gs_player_y
	sta a19
	lda gs_player_x
	sta zp1A_item_place
	lda gs_level
	cmp #$03
	bne :+
	rts

:	bmi :+
	jmp check_levels_4_5

:	cmp #$02
	beq check_level_2
	lda zp1A_item_place
	cmp #$03
	beq check_calculator
	cmp #$06
	beq check_guillotine
	rts

check_calculator:
	lda a19
	cmp #$03
	beq at_calculator
special_return:
	rts

at_calculator:
	ldx #special_calc_puzzle
	stx gs_special_mode
	rts

check_guillotine:
	lda a19
	cmp #$0a
	beq beheaded
	rts

beheaded:
	jsr clear_hgr2
	lda #$00
	sta zp_col
	lda #$09
	sta zp_row
	lda #$29     ;Invisible guillotine
	jsr print_display_string
	jmp game_over

check_level_2:
	lda a19
	cmp #$05
	beq check_guarded_pit
check_dog_roaming:
	lda gs_level_turns_lo
	cmp #turns_until_dog1
	bcs :+
	lda gs_level_turns_hi
	beq special_return
:	lda gs_dog1_alive
	and #$01
	beq special_return
	lda gs_special_mode
	bne :+
	ldx #special_dog1
	stx gs_special_mode
	rts

:	ldx #special_dog1
	stx gs_mode_stack1
	rts

check_guarded_pit:
	lda zp1A_item_place
	cmp #$05
	beq at_guard_dog
	cmp #$08
	bne check_dog_roaming
	ldx #$03
	stx gs_facing
	stx gs_level
	ldx #$08
	stx gs_player_x
	ldx #$05
	stx gs_player_y
	ldx #$00
	stx gs_level_turns_hi
	stx gs_level_turns_lo
	jsr pit
	rts

at_guard_dog:
	lda gs_dog2_alive
	and #$01
	beq @return
	ldx #special_dog2
	stx gs_special_mode
@return:
	rts

check_levels_4_5:
	cmp #$04
	beq check_monster
	lda zp1A_item_place
	cmp #$04
	beq check_bat
check_mother:
	lda gs_level_turns_lo
	cmp #turns_until_mother
	bcs :+
	lda gs_level_turns_hi
	beq @return
:	lda a61AC
	and #mother_flag_roaming
	beq @return
	lda gs_special_mode
	bne :+
	ldx #special_mother
	stx gs_special_mode
	rts

:	ldx #$09
	stx gs_mode_stack1
	rts

check_bat:
	lda a19
	cmp #$04
	bne check_mother
	lda gs_bat_alive
	and #$02
	beq check_mother
	jsr push_special_mode2
	ldx #special_bat
	stx gs_special_mode
	rts

check_monster:
	lda gs_level_turns_lo
	cmp #turns_until_monster
	bcs :+
	lda gs_level_turns_hi
	beq @return
:	lda gs_monster_lurks
	and #$02
	beq done_timer
	ldx #special_monster
	stx gs_special_mode
done_timer:
	rts

complete_turn:
	lda gs_level_turns_lo
	cmp #$ff
	beq :+
	inc gs_level_turns_lo
	jmp @consume

:	ldx #$00
	stx gs_level_turns_lo
	inc gs_level_turns_hi
@consume:
	lda gs_level
	cmp #$05
	beq @dec_food
	lda gs_torch_time
	beq @dec_food
	dec gs_torch_time
	bne @dec_food
	dec gs_torches_lit
	ldx #$00
	stx gs_room_lit
	jsr push_special_mode2
	ldx #special_dark
	stx gs_special_mode
@dec_food:
	dec gs_food_time_lo
	lda gs_food_time_lo
	cmp #$ff
	bne :+
	dec gs_food_time_hi
:	lda gs_food_time_hi
	ora gs_food_time_lo
	bne done_timer
starved:
	jsr clear_hgr2
	lda #$35     ;Died of starvation!
	ldx #$07
	stx zp_col
	ldx #$02
	stx zp_row
	jsr print_display_string
	jmp game_over

print_timers:
	lda gs_food_time_hi
	bne :+
	lda gs_food_time_lo
	cmp #food_low
	bcs :+
	lda #$32     ;Stomach is growling
	jsr print_to_line1
:	lda gs_torch_time
	beq rts_bb2
	cmp #torch_low
	bcs rts_bb2
	lda #$33     ;Torch is dying
	jsr print_to_line2
	rts

noun_to_item:
	lda gd_parsed_object
	cmp #nouns_unique_end
	bpl multiples
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_active
	bpl rts_bb2
pop_not_carried:
	pla
	pla
not_carried:
	lda #$7b     ;Check your inventory!
print_return:
	jsr print_to_line2
rts_bb2:
	rts

multiples:
	cmp #noun_food
	beq @food
	cmp #noun_torch
	beq @torch
	ldx #icmd_which_box
	stx zp0F_action
	jsr item_cmd
	cmp #$00
	beq pop_not_carried
	rts

@food:
	ldx #icmd_which_food
	stx zp0F_action
	jsr item_cmd
	cmp #$00
	beq pop_not_carried
	rts

@torch:
	ldx #icmd_which_torch_unlit
	stx zp0F_action
	jsr item_cmd
	cmp #$00
	bne rts_bb2
	lda gs_level
	cmp #$05
	beq pop_not_carried
	lda gs_room_lit
	beq pop_not_carried
	ldx #icmd_which_torch_lit
	stx zp0F_action
	jsr item_cmd
	cmp #$00
	bne rts_bb2
	lda gs_torches_lit
	cmp #$01
	bne pop_not_carried
	pla
	pla
	lda #$98     ;You will do no such thing!
	bne print_return

memcpy:
	ldy #$00
@next_byte:
	lda (zp0E_object),y
	sta (zp10_noun),y
	inc zp0E_object
	bne :+
	inc zp0F_action
:	inc zp10_noun
	bne :+
	inc zp11_box_item
:	dec a19
	beq @check_done
	lda a19
	cmp #$ff
	bne @next_byte
	dec zp1A_item_place
	jmp @next_byte

@check_done:
	lda zp1A_item_place
	ora a19
	bne @next_byte
textbuf_prev_input-1:
	rts

textbuf_prev_input:
	.byte $c9,$50,$90,$03,$20,$15,$10,$ad
	.byte $9e,$61,$f0,$08,$a2,$00,$8e,$b3
	.byte $61,$4c,$93,$34,$a2,$00,$8e,$a4
	.byte $61,$ad,$b3,$61,$d0,$29,$ad,$94
	.byte $61,$c9,$05,$f0,$0a,$ad,$ad,$61
	.byte $29,$02,$d0,$08,$4c,$93,$34,$ad
	.byte $ac,$61,$f0,$f8,$20,$26,$36,$a9
	.byte $43,$20,$92,$08,$a9,$44,$20,$a4
	.byte $08,$ee,$b3,$61,$4c,$08,$36,$c9
	.byte $01,$d0,$13,$20,$26,$36,$ee
p0C79:
	.byte $b3
text_buffer1:
	.byte $61,$a9,$45,$20,$92,$08,$a9,$47
	.byte $20,$a4,$08,$4c,$08,$36,$20,$26
	.byte $36,$ad,$94,$61,$c9,$05,$f0,$0d
	.byte $a9,$36,$20,$92,$08,$a9,$37,$20 ;The monster attacks you and
	.byte $a4,$08,$4c,$b9,$10,$a9,$48,$20
text_buffer2:
	.byte $92,$08,$a9,$4b,$20,$a4,$08,$4c
	.byte $b9,$10,$ca,$d0,$6f,$ad,$9d,$61
	.byte $c9,$11,$f0,$07,$20,$5f,$10,$a9
	.byte $20,$d0,$e9,$ad,$9c,$61,$c9,$0e
	.byte $f0,$52,$c9,$13,$d0,$ee,$a2,$04
get_player_input:
	bit hw_STROBE
:	bit hw_KEYBOARD
	bpl :-
	lda hw_KEYBOARD
	and #$7f
	cmp #$40
	bmi :+
	and #char_mask_upper
:	pha
	lda #>text_buffer1
	sta zp0F_action
	lda #<text_buffer1
	sta zp0E_object
	lda #>textbuf_prev_input
	sta zp11_box_item
	lda #<textbuf_prev_input
	sta zp10_noun
	lda #$00
	sta zp1A_item_place
	lda #$50
	sta a19
	jsr memcpy
	jsr clear_status_lines
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	dec zp_row
	jsr get_rowcol_addr
	lda #>p0C79
	sta zp_0D
	lda #<p0C79
	sta zp_0C_string
	lda #$80
	ldy #$50
:	sta (zp_0C_string),y
	dey
	bne :-
	lda #$00
	sta zp11_count_chars
	sta zp10_count_words
	lda #>p0C79
	sta zp1A_item_place
	lda #<p0C79
	sta a19
	pla
	jmp process_input_char

input_blink_cursor:
	bit hw_STROBE
:	jsr blink_cursor
	bit hw_KEYBOARD
	bpl :-
	lda hw_KEYBOARD
	and #$7f
	cmp #$40
	bmi process_input_char
	and #char_mask_upper
process_input_char:
	pha
	lda zp11_count_chars
	bne @check_backspace
	pla
	cmp #'Z'
	bne :+
	jmp @forward

:	cmp #'X'
	bne :+
	jmp @around

:	cmp #char_left
	bne :+
	jmp @left

:	cmp #char_right
	bne :+
	jmp @right

:	cmp #' '
	beq input_blink_cursor
	cmp #char_enter
	beq input_blink_cursor
	bne @check_enter
@check_backspace:
	pla
	cmp #char_left
	bne @check_enter
	jmp input_backspace

@check_enter:
	cmp #char_enter
	bne @check_esc
	jmp input_enter

; Cancel whatever is currently typed
@check_esc:
	cmp #char_esc
	bne @check_space
	lda #$00
	sta zp_col
	lda #$16
	sta zp_row
	jsr get_rowcol_addr
	lda #>textbuf_prev_input-1
	sta zp0F_action
	lda #<textbuf_prev_input-1
	sta zp0E_object
	ldy #$50
@next_char:
	lda (zp0E_object),y
	sta (p19),y
	dey
	bne @next_char

	ldy #$50
	sty zp0E_object
	ldy #$01
	sty zp0F_action
@repeat_display:
	lda (p19),y
	cmp #$80
	bmi :+
	lda #' '
:	jsr char_out
	inc zp0F_action
	ldy zp0F_action
	dec zp0E_object
	bne @repeat_display
	jmp get_player_input

@check_space:
	cmp #' '
	beq input_space
	bcs input_letter
	jmp input_blink_cursor

@forward:
	lda #verb_forward
	bne @return_move
@right:
	lda #verb_right
	bne @return_move
@left:
	lda #verb_left
	bne @return_move
@around:
	lda #verb_uturn
@return_move:
	sta gd_parsed_action
	jmp clear_cursor

input_enter:
	jmp parse_input

input_backspace:
	jsr clear_cursor
	dec zp_col
	jsr get_rowcol_addr
	lda #' '
	jsr char_out
	dec zp_col
	jsr get_rowcol_addr
	ldy zp11_count_chars
	lda (p19),y
	cmp #' '
	bne :+
	dec zp10_count_words
:	lda #$80
	sta (p19),y
	dec zp11_count_chars
	jmp input_blink_cursor

input_letter:
	sta zp13_raw_input
	cmp #'A'
	bcc @no_modification
	ldy zp11_count_chars
	beq @no_modification
	lda (p19),y  ;Check previous character
	cmp #' '
	beq @no_modification
	lda zp13_raw_input
	ora #$20     ;Make lower-case
	bne :+
@no_modification:
	lda zp13_raw_input
:	pha
	jsr char_out
	pla
	inc zp11_count_chars
	ldy zp11_count_chars
	sta (p19),y
	cpy #max_input
	beq parse_input
	jmp input_blink_cursor

; BUG: meant to prevent double-space, but only prevents WORD_L_
input_space:
	ldy zp11_count_chars
	dey          ;BUG: remove to fix.
	lda (p19),y
	cmp #' '
	bne :+
	jmp input_blink_cursor

:	lda zp10_count_words
	bne parse_input
	inc zp10_count_words
	lda #' '
	bne input_letter

parse_input:
	jsr clear_cursor
	lda #' '
	inc zp11_count_chars
	ldy zp11_count_chars
	sta (p19),y
	inc a19
	bne @parse_verb
	inc zp1A_item_place
@parse_verb:
	jsr get_vocab
	lda zp10_noun
	sta gd_parsed_action
	ldy #$00
@skip_word:
	inc a19
	bne :+
	inc zp1A_item_place
:	lda (p19),y
	cmp #' '
	bne @skip_word
	inc a19
	bne :+
	inc zp1A_item_place
:	lda (p19),y
	cmp #$80
	beq @verb_only
	cmp #' '
	bne @parse_object
@verb_only:
	lda #$00
	sta gd_parsed_object
	beq @check_verb
@parse_object:
	jsr get_vocab
	lda zp10_noun
	sta gd_parsed_object
@check_verb:
	lda gd_parsed_action
	cmp #verbs_end
	bcc @known_verb
	lda #$8d     ;I'm sorry, but I can't
	jsr print_to_line2
	lda #<text_buffer1
	sta a19
	lda #>text_buffer1
	sta zp1A_item_place
	ldy #$00
@echo_next_char:
	tya
	pha
	lda (p19),y
	cmp #' '
	beq @echo_period
	jsr char_out
	pla
	tay
	iny
	bne @echo_next_char
@echo_period:
	pla
	lda #'.'
	jsr print_char
	jmp get_player_input

@known_verb:
	cmp #verb_intransitive
	bcs @verb_no_object
	lda gd_parsed_object
	beq @verb_no_object
	cmp #vocab_end
	beq @unknown_object
	cmp #verbs_end
	bcc @unknown_object
	sec
	sbc #verbs_end-1
	sta gd_parsed_object
@done_verb:
	rts

@unknown_object:
	lda #$8f     ;What in tarnation is a
	jsr print_to_line2
	lda #<text_buffer1
	sta a19
	lda #>text_buffer1
	sta zp1A_item_place
	ldy #$00
@find_word_end:
	lda (p19),y
	cmp #$20
	beq @found_word_end
	inc a19
	bne @find_word_end
	inc zp1A_item_place
	bne @find_word_end
@found_word_end:
	inc a19
	bne @obj_next_letter
	inc zp1A_item_place
@obj_next_letter:
	tya
	pha
	lda (p19),y
	cmp #$20
	beq @obj_word_end
	jsr char_out
	pla
	tay
	iny
	bne @obj_next_letter
@obj_word_end:
	lda #'?'
	jsr char_out
	pla
	jmp get_player_input

@verb_no_object:
	lda gd_parsed_action
	cmp #verb_intransitive
	bcs @done_verb
	cmp #verb_look
	beq @cmd_look
	lda #>text_buffer1
	sta zp1A_item_place
	lda #<text_buffer1
	sta a19
	lda #$00
	sta zp_col
	lda #$17
	sta zp_row
	jsr get_rowcol_addr
	lda #char_ClearLine
	jsr char_out
	ldy #$00
	sty zp11_box_item
	lda (p19),y
	and #char_mask_upper
	bne @echo
@next_verb_letter:
	lda (p19),y
	cmp #$20
	beq @verb_word_end
@echo:
	jsr char_out
	inc zp11_box_item
	ldy zp11_box_item
	bne @next_verb_letter
@verb_word_end:
	lda #$56     ;what?
	jsr print_display_string
	jmp get_player_input

@cmd_look:
	lda gs_room_lit
	beq @dark
	lda #$8b     ;Look at your monitor.
	bne :+
@dark:
	lda #$8a     ;It's awfully dark.
:	jsr print_to_line2
	jmp get_player_input

get_vocab:
	lda zp1A_item_place
	pha
	lda a19
	pha
	lda #>vocab_table
	sta zp0F_action
	lda #<vocab_table
	sta zp0E_object
	lda #$00
	sta zp10_noun
@next_word:
	ldy #$01
@find_string:
	lda (zp0E_object),y
	and #$80
	bne @found_start
	inc zp0E_object
	bne @find_string
	inc zp0F_action
	bne @find_string
@found_start:
	dey
	lda (zp0E_object),y
	cmp #'*'
	beq :+
	inc zp10_noun
:	inc zp0E_object
	bne :+
	inc zp0F_action
:	lda #$04
	sta zp11_box_item
@compare_char:
	lda (zp0E_object),y
	and #char_mask_upper
	sta a13
	lda (p19),y
	and #char_mask_upper
	cmp a13
	bne @mismatch
	inc a19
	bne :+
	inc zp1A_item_place
:	inc zp0E_object
	bne :+
	inc zp0F_action
:	dec zp11_box_item
	bne @compare_char
@done:
	pla
	sta a19
	pla
	sta zp1A_item_place
	rts

@mismatch:
	lda zp10_noun
	cmp #vocab_end-1
	beq @fail
	pla
	sta a19
	pla
	sta zp1A_item_place
	pha
	lda a19
	pha
	jmp @next_word

@fail:
	inc zp10_noun
	bne @done

wait_short:
	ldx #$90
	stx zp0F_action
:	dec zp0E_object
	bne :-
	dec zp0F_action
	bne :-
	rts

input_char:
	bit hw_STROBE
:	jsr blink_cursor
	bit hw_KEYBOARD
	bpl :-
	jmp clear_cursor

input_Y_or_N:
	bit hw_STROBE
:	jsr blink_cursor
	bit hw_KEYBOARD
	bpl :-
	lda hw_KEYBOARD
	and #$7f
	cmp #'Y'
	beq :+
	cmp #'N'
	bne input_Y_or_N
:	pha
	jsr clear_cursor
	pla
	rts

draw_view:
	jsr clear_maze_window
	jsr s17BF
	lda gs_room_lit
	beq @done
	jsr s12A6
	jsr s1DDF
	lda zp0F_action
	ora zp0E_object
	beq :+
	jsr s1E5A
:	ldx #icmd_0a
	stx zp0F_action
	jsr item_cmd
	lda a619B
	beq @done
	sta zp0E_object
	ldx #$06
	stx zp0F_action
	jsr s1E5A
@done:
	rts

wait_long:
	ldx #$05
	stx zp10_noun
@dec16:
	ldx #$00
	stx zp0F_action
:	dec zp0E_object
	bne :-
	dec zp0F_action
	bne :-
	dec zp10_noun
	bne @dec16
	rts

nonsense:
	lda #$55     ;Little sense.
	jmp print_to_line2

clear_status_lines:
	pha
	ldx #$00
	stx zp_col
	ldx #$16
	stx zp_row
	jsr get_rowcol_addr
	lda #char_ClearLine
	jsr char_out
	inc zp_row
	jsr get_rowcol_addr
	lda #char_ClearLine
	jsr char_out
	pla
	rts

pit:
	jsr clear_maze_window
	ldx #$05
	stx zp_col
	ldx #$08
	stx zp_row
	jsr get_rowcol_addr
	lda #$a7     ;Oh no! A pit!
	jsr print_display_string
	jsr wait_short
	ldx #$05
	stx zp_col
	inc zp_row
	jsr get_rowcol_addr
	lda #$2c     ;AAAAAAHH!
	jsr print_display_string
	jsr wait_long
	jsr clear_maze_window
	ldx #$09
	stx zp_col
	ldx #$08
	stx zp_row
	jsr get_rowcol_addr
	lda #$2d     ;WHAM!
	jsr print_display_string
	jmp wait_long

game_over:
	jsr wait_long
	jsr clear_status_lines
	lda #$34     ;Victim of the maze!
	jsr print_to_line1
play_again:
	lda #$39     ;Play again?
	jsr print_to_line2
	jsr input_Y_or_N
	cmp #'Y'
	bne :+
	jmp new_session

:	bit hw_PAGE1
	bit hw_TEXT
	jmp rom_MONITOR

push_special_mode2:
	lda gs_mode_stack1
b10E1=*+$02
	sta gs_mode_stack2
	lda gs_special_mode
	sta gs_mode_stack1
	rts

; cruft leftover from earlier build
	sta f61,x    ;gs_player_x
	jsr pit
	jsr draw_view
	jmp j3493

	rts

	stx zp0F_action
	jsr item_cmd
	lda #$06
	cmp zp1A_item_place
	beq b110D
	dec zp11_box_item
	bne b10E1
	pla
	sta zp0E_object
	pla
	sta zp0F_action
	jmp j2EFB

b110D:
	pla
	sta zp0E_object
	pla
	sta zp0F_action
	lda gd_parsed_object
	cmp #noun_torch
	beq :+
	jmp j2E72

:	inc gs_torches_unlit
	jmp j2E72

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
	bne cruft_cmd
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
row8_table:
	.byte $40,$00
cruft_cmd:
	.byte $40,$80,$41,$00,$41,$80,$42,$00
	.byte $42,$80,$43,$00,$43,$80,$40,$28
	.byte $40,$a8,$41,$28,$41,$a8,$42,$28
	.byte $42,$a8,$43,$28,$43,$a8,$40,$50
	.byte $40,$d0,$41,$50,$41,$d0,$42,$50
	.byte $42,$d0,$43,$50,$43,$d0
char_out:
	cmp #char_newline
	beq control_newline
	cmp #char_ClearLine
	bne :+
	jmp clear_to_end_line

:	cmp #$c0
	bcc print_char
	jmp clear_up_to_3F

print_char:
	sta a13
	lda #$00
	sta a14
	asl a13
	rol a14
	asl a13
	rol a14
	asl a13
	rol a14
	clc
	lda #<font
	adc a13
	sta a13
	lda #>font
	adc a14
	sta a14
	ldx #$00
	ldy #$00
	lda #$08
	sta line_count
	clc
@next_line:
	lda (p13),y
	sta (screen_ptr,x)
	lda #$04
	adc screen_ptr+1
	sta screen_ptr+1
	iny
	dec line_count
	bne @next_line
	inc zp_col
	lda #$28
	cmp zp_col
	bne get_rowcol_addr
	lda #$00
	sta zp_col
	lda #$17
	cmp zp_row
	beq get_rowcol_addr
	inc zp_row
get_rowcol_addr:
	lda zp_row
	asl
	clc
	adc #<row8_table
	sta a13
	lda #$00
	adc #>row8_table
	sta a14
	ldy #$01
	clc
	lda (p13),y
	adc zp_col
	sta screen_ptr
	dey
	lda (p13),y
	sta screen_ptr+1
	rts

control_newline:
	jsr clear_cursor
	lda #$17
	cmp zp_row
	beq :+
	inc zp_row
:	lda #$00
	sta zp_col
	jmp get_rowcol_addr

clear_to_end_line:
	lda #$28
	sec
	sbc zp_col
	jmp clear_N

clear_up_to_3F:
	sec
	sbc #$c0
clear_N:
	sta zp_counter
	lda zp_col
	pha
	lda zp_row
	pha
:	lda #' '
	jsr print_char
	dec zp_counter
	bne :-
	pla
	sta zp_row
	pla
	sta zp_col
	jmp get_rowcol_addr

blink_cursor:
	inc clock
	bne :+
	inc clock+1
:	lda clock+1
	cmp #$18
	beq show_cursor
	cmp #$30
	beq clear_cursor
done_cursor:
	rts

show_cursor:
	lda #$00
	cmp clock
	bne done_cursor
	lda zp_col
	pha
	lda zp_row
	pha
	lda #char_cursor
render_cursor:
	jsr print_char
	pla
	sta zp_row
	pla
	sta zp_col
	jmp get_rowcol_addr

clear_cursor:
	lda zp_col
	pha
	lda zp_row
	pha
	lda #$00
	sta clock
	sta clock+1
	lda #' '
	bne render_cursor

clear_maze_window:
	lda #$00
	sta zp_col
	lda #$14
	sta zp_row
@clear_row:
	jsr get_rowcol_addr
	clc
	lda #$08
	sta a19
@clear_raster:
	lda #$00
	ldy #$16
:	sta (screen_ptr),y
	dey
	bpl :-
	lda #$04
	adc screen_ptr+1
	sta screen_ptr+1
	dec a19
	bne @clear_raster
	dec zp_row
	bpl @clear_row
	rts

s12A6:
	lda a619A
	lsr
	lsr
	lsr
	lsr
	lsr
	pha
	cmp #$05
	bcc b12C3
	lda #<p4133
	sta screen_ptr
	lda #>p4133
	sta screen_ptr+1
	lda #$05
	jsr char_out
	jmp j135C

b12C3:
	cmp #$04
	bne b12E0
	lda #<p4132
	sta screen_ptr
	lda #>p4132
	sta screen_ptr+1
	ldy #$01
	jsr s1777
	lda #$5d
	sta screen_ptr+1
	ldy #$01
	jsr s1777
	jmp j135C

b12E0:
	cmp #$03
	bne b12FD
	lda #>p40B1
	sta screen_ptr+1
	lda #<p40B1
	sta screen_ptr
	ldy #$03
	jsr s1777
	lda #$5d
	sta screen_ptr+1
	ldy #$03
	jsr s1777
	jmp j1430

b12FD:
	cmp #$02
	bne b131E
	lda #>p4387
	sta screen_ptr+1
	lda #<p4387
	sta screen_ptr
	ldy #$07
	jsr s1777
	lda #>p5EAF
	sta screen_ptr+1
	lda #<p5EAF
	sta screen_ptr
	ldy #$07
	jsr s1777
	jmp j1518

b131E:
	cmp #$01
	bne b133F
	lda #>p4204
	sta screen_ptr+1
	lda #<p4204
	sta screen_ptr
	ldy #$0d
	jsr s1777
	lda #>p5C54
	sta screen_ptr+1
	lda #<p5C54
	sta screen_ptr
	ldy #$0d
	jsr s1777
	jmp j1600

b133F:
	lda #>screen_HGR2
	sta screen_ptr+1
	lda #<screen_HGR2
	sta screen_ptr
	ldy #$15
	jsr s1777
	lda #>p5E50
	sta screen_ptr+1
	lda #<p5E50
	sta screen_ptr
	ldy #$15
	jsr s1777
	jmp j16E8

j135C:
	lda a6199
	and #$10
	bne b139C
	pla
	pha
	cmp #$04
	beq b1376
	lda #>p4132
	sta screen_ptr+1
	lda #<p4132
	sta screen_ptr
	lda #$04
	jsr char_out
b1376:
	lda #>p4131
	sta screen_ptr+1
	lda #<p4131
	sta screen_ptr
	ldy #$01
	jsr s1777
	lda #$5d
	sta screen_ptr+1
	ldy #$01
	jsr s1777
	lda #$09
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$03
	jsr s17A7
	jmp j13C5

b139C:
	pla
	pha
	cmp #$04
	bne b13AF
	lda #>p4132
	sta screen_ptr+1
	lda #<p4132
	sta screen_ptr
	lda #$04
	jsr char_out
b13AF:
	lda #$0a
	sta zp_col
	lda #$09
	sta zp_row
	ldy #$01
	jsr s1795
	dec zp_col
	inc zp_row
	ldy #$01
	jsr s177F
j13C5:
	lda a619A
	and #$10
	bne b1407
	pla
	pha
	cmp #$04
	beq b13DF
	lda #>p4134
	sta screen_ptr+1
	lda #<p4134
	sta screen_ptr
	lda #$03
	jsr char_out
b13DF:
	lda #>p4133
	sta screen_ptr+1
	lda #<p4133
	sta screen_ptr
	ldy #$01
	jsr s1777
	lda #$5d
	sta screen_ptr+1
	ldy #$01
	jsr s1777
	lda #$0d
	sta zp_col
	lda #$09
	sta zp_row
	lda #$03
	ldy #$03
	jsr s17A7
	jmp j1430

b1407:
	pla
	pha
	cmp #$04
	bne b141A
	lda #>p4134
	sta screen_ptr+1
	lda #<p4134
	sta screen_ptr
	lda #$03
	jsr char_out
b141A:
	lda #$0c
	sta zp_col
	lda #$09
	sta zp_row
	ldy #$01
	jsr s177F
	inc zp_col
	inc zp_row
	ldy #$01
	jsr s1795
j1430:
	lda a6199
	and #$08
	bne b1474
	pla
	pha
	cmp #$03
	beq b144A
	lda #$09
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$03
	jsr s17A7
b144A:
	lda #>p40AF
	sta screen_ptr+1
	lda #<p40AF
	sta screen_ptr
	ldy #$02
	jsr s1777
	lda #>p5DAF
	sta screen_ptr+1
	lda #<p5DAF
	sta screen_ptr
	ldy #$02
	jsr s1777
	lda #$07
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$07
	jsr s17A7
	jmp j14A1

b1474:
	pla
	pha
	cmp #$03
	bne b1487
	lda #$09
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$03
	jsr s17A7
b1487:
	lda #$08
	sta zp_col
	lda #$07
	sta zp_row
	ldy #$02
	jsr s1795
	lda #$09
	sta zp_col
	lda #$0c
	sta zp_row
	ldy #$02
	jsr s177F
j14A1:
	lda a619A
	and #$08
	bne b14E9
	pla
	pha
	cmp #$03
	beq b14BD
	lda #$0d
	sta zp_col
	lda #$09
	sta zp_row
	lda #$03
	ldy #$03
	jsr s17A7
b14BD:
	lda #>p40B4
	sta screen_ptr+1
	lda #<p40B4
	sta screen_ptr
	ldy #$02
	jsr s1777
	lda #>p5DB4
	sta screen_ptr+1
	lda #<p5DB4
	sta screen_ptr
	ldy #$02
	jsr s1777
	lda #$0f
	sta zp_col
	lda #$07
	sta zp_row
	lda #$03
	ldy #$07
	jsr s17A7
	jmp j1518

b14E9:
	pla
	pha
	cmp #$03
	bne b14FE
	lda #$0d
	sta zp_col
	lda #$09
	sta zp_row
	lda #$03
	ldy #$03
	jsr s17A7
b14FE:
	lda #$0e
	sta zp_col
	lda #$07
	sta zp_row
	ldy #$02
	jsr s177F
	lda #$0d
	sta zp_col
	lda #$0c
	sta zp_row
	ldy #$02
	jsr s1795
j1518:
	lda a6199
	and #$04
	bne b155C
	pla
	pha
	cmp #$02
	beq b1532
	lda #$07
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$07
	jsr s17A7
b1532:
	lda #>p4384
	sta screen_ptr+1
	lda #<p4384
	sta screen_ptr
	ldy #$03
	jsr s1777
	lda #>p5EAC
	sta screen_ptr+1
	lda #<p5EAC
	sta screen_ptr
	ldy #$03
	jsr s1777
	lda #$04
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$0d
	jsr s17A7
	jmp j1589

b155C:
	pla
	pha
	cmp #$02
	bne b156F
	lda #$07
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$07
	jsr s17A7
b156F:
	lda #$05
	sta zp_col
	lda #$04
	sta zp_row
	ldy #$03
	jsr s1795
	lda #$07
	sta zp_col
	lda #$0e
	sta zp_row
	ldy #$03
	jsr s177F
j1589:
	lda a619A
	and #$04
	bne b15D1
	pla
	pha
	cmp #$02
	beq b15A5
	lda #$0f
	sta zp_col
	lda #$07
	sta zp_row
	lda #$03
	ldy #$07
	jsr s17A7
b15A5:
	lda #>p438E
	sta screen_ptr+1
	lda #<p438E
	sta screen_ptr
	ldy #$03
	jsr s1777
	lda #>p5EB6
	sta screen_ptr+1
	lda #<p5EB6
	sta screen_ptr
	ldy #$03
	jsr s1777
	lda #$12
	sta zp_col
	lda #$04
	sta zp_row
	lda #$03
	ldy #$0d
	jsr s17A7
	jmp j1600

b15D1:
	pla
	pha
	cmp #$02
	bne b15E6
	lda #$0f
	sta zp_col
	lda #$07
	sta zp_row
	lda #$03
	ldy #$07
	jsr s17A7
b15E6:
	lda #$11
	sta zp_col
	lda #$04
	sta zp_row
	ldy #$03
	jsr s177F
	lda #$0f
	sta zp_col
	lda #$0e
	sta zp_row
	ldy #$03
	jsr s1795
j1600:
	lda a6199
	and #$02
	bne b1644
	pla
	pha
	cmp #$01
	beq b161A
	lda #$04
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$0d
	jsr s17A7
b161A:
	lda #>p4200
	sta screen_ptr+1
	lda #<p4200
	sta screen_ptr
	ldy #$04
	jsr s1777
	lda #>p5C50
	sta screen_ptr+1
	lda #<p5C50
	sta screen_ptr
	ldy #$04
	jsr s1777
	lda #$00
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$15
	jsr s17A7
	jmp j1671

b1644:
	pla
	pha
	cmp #$01
	bne b1657
	lda #$04
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$0d
	jsr s17A7
b1657:
	lda #$01
	sta zp_col
	lda #$00
	sta zp_row
	ldy #$04
	jsr s1795
	lda #$04
	sta zp_col
	lda #$11
	sta zp_row
	ldy #$04
	jsr s177F
j1671:
	lda a619A
	and #$02
	bne b16B9
	pla
	pha
	cmp #$01
	beq b168D
	lda #$12
	sta zp_col
	lda #$04
	sta zp_row
	lda #$03
	ldy #$0d
	jsr s17A7
b168D:
	lda #>p4211
	sta screen_ptr+1
	lda #<p4211
	sta screen_ptr
	ldy #$04
	jsr s1777
	lda #>p5C61
	sta screen_ptr+1
	lda #<p5C61
	sta screen_ptr
	ldy #$04
	jsr s1777
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #$03
	ldy #$15
	jsr s17A7
	jmp j16E8

b16B9:
	pla
	pha
	cmp #$01
	bne b16CE
	lda #$12
	sta zp_col
	lda #$04
	sta zp_row
	lda #$03
	ldy #$0d
	jsr s17A7
b16CE:
	lda #$15
	sta zp_col
	lda #$00
	sta zp_row
	ldy #$04
	jsr s177F
	lda #$12
	sta zp_col
	lda #$11
	sta zp_row
	ldy #$04
	jsr s1795
j16E8:
	pla
	cmp #$00
	beq b174C
	lda a6199
	and #$01
	bne b171B
	lda #$00
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$15
	jsr s17A7
	lda #>relocated
	sta screen_ptr+1
	lda #<relocated
	sta screen_ptr
	ldy #$01
	jsr s1777
	lda #>p5E4F
	sta screen_ptr+1
	lda #<p5E4F
	sta screen_ptr
	ldy #$01
	jsr s1777
b171B:
	lda a619A
	and #$01
	bne b174B
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #$03
	ldy #$15
	jsr s17A7
	lda #>p4015
	sta screen_ptr+1
	lda #<p4015
	sta screen_ptr
	ldy #$01
	jsr s1777
	lda #>p5E65
	sta screen_ptr+1
	lda #<p5E65
	sta screen_ptr
	ldy #$01
	jsr s1777
b174B:
	rts

b174C:
	lda a6199
	and #$01
	beq b1760
	lda #$00
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$15
	jsr s17A7
b1760:
	lda a619A
	and #$01
	beq b174B
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #$03
	ldy #$15
	jsr s17A7
	rts

s1777:
	lda #$ff
b1779:
	sta (screen_ptr),y
	dey
	bne b1779
	rts

s177F:
	tya
	sta zp1A_item_place
b1782:
	jsr get_rowcol_addr
	lda #$02
	jsr char_out
	dec zp_col
	dec zp_col
	inc zp_row
	dec zp1A_item_place
	bne b1782
	rts

s1795:
	tya
	sta zp1A_item_place
b1798:
	jsr get_rowcol_addr
	lda #$01
	jsr char_out
	inc zp_row
	dec zp1A_item_place
	bne b1798
	rts

s17A7:
	pha
	tya
	sta zp1A_item_place
	pla
b17AC:
	pha
	jsr get_rowcol_addr
	pla
	pha
	jsr print_char
	pla
	dec zp_col
	inc zp_row
	dec zp1A_item_place
	bne b17AC
	rts

s17BF:
	ldy #$00
	lda #<p6000
	sta zp0A_text_ptr
	lda #>p6000
	sta text_ptr+1
	ldx gs_level
	lda #$00
	clc
j17CF:
	dex
	beq b17D7
	adc #$21
	jmp j17CF

b17D7:
	adc zp0A_text_ptr
	sta zp0A_text_ptr
	ldx gs_player_x
j17DE:
	dex
	beq b17EA
	inc zp0A_text_ptr
	inc zp0A_text_ptr
	inc zp0A_text_ptr
	jmp j17DE

b17EA:
	lda gs_player_y
	cmp #$05
	bmi b17FF
	cmp #$09
	bmi b17FA
	inc zp0A_text_ptr
	sec
	sbc #$04
b17FA:
	inc zp0A_text_ptr
	sec
	sbc #$04
b17FF:
	tax
	lda #$80
j1802:
	dex
	beq b180A
	lsr
	lsr
	jmp j1802

b180A:
	sta zp1A_item_place
	stx a19
	stx zp11_box_item
	stx a6199
	stx a619A
	ldx gs_facing
	dex
	bne b181F
	jmp j1910

b181F:
	dex
	bne b1825
	jmp j197C

b1825:
	dex
	beq b18A7
j1828:
	lda (zp0A_text_ptr),y
	and zp1A_item_place
	bne b184C
	inc a19
	lda a19
	cmp #$05
	beq b184C
	lda zp1A_item_place
	cmp #$80
	bne b1845
	dec zp0A_text_ptr
	lda #$02
	sta zp1A_item_place
	jmp j1828

b1845:
	asl zp1A_item_place
	asl zp1A_item_place
	jmp j1828

b184C:
	lda a19
	jsr s1A10
	lsr zp1A_item_place
j1853:
	lda (zp0A_text_ptr),y
	and zp1A_item_place
	beq b185C
	inc a619A
b185C:
	ldy #$03
	lda (zp0A_text_ptr),y
	ldy #$00
	and zp1A_item_place
	beq b1869
	inc a6199
b1869:
	jsr s1A10
	cmp zp11_box_item
	beq b189A
	jsr s1A10
	lda #$04
	cmp zp11_box_item
	beq b1897
	asl a6199
	asl a619A
	inc zp11_box_item
	lda zp1A_item_place
	cmp #$01
	beq b188E
	lsr zp1A_item_place
	lsr zp1A_item_place
	jmp j1853

b188E:
	lda #$40
	sta zp1A_item_place
	inc zp0A_text_ptr
	jmp j1853

b1897:
	jsr s1A10
b189A:
	asl
	asl
	asl
	asl
	asl
	clc
	adc a619A
	sta a619A
	rts

b18A7:
	lsr zp1A_item_place
b18A9:
	clc
	lda zp0A_text_ptr
	adc #$03
	sta zp0A_text_ptr
	lda (zp0A_text_ptr),y
	and zp1A_item_place
	bne b18BE
	inc a19
	lda a19
	cmp #$05
	bne b18A9
b18BE:
	lda a19
	jsr s1A10
	lda zp1A_item_place
	sta a19
	asl zp1A_item_place
	clc
	ror a19
	bcc b18D0
	ror a19
b18D0:
	dec zp0A_text_ptr
	dec zp0A_text_ptr
	dec zp0A_text_ptr
	lda (zp0A_text_ptr),y
	and zp1A_item_place
	beq b18DF
	inc a619A
b18DF:
	lda a19
	cmp #$80
	beq b18EA
	lda (zp0A_text_ptr),y
	jmp j18EE

b18EA:
	iny
	lda (zp0A_text_ptr),y
	dey
j18EE:
	and a19
	beq b18F5
	inc a6199
b18F5:
	lda zp11_box_item
	cmp #$04
b18F9:
	beq b1897
	jsr s1A10
	cmp zp11_box_item
b1900:
	beq b189A
	jsr s1A10
	inc zp11_box_item
	asl a6199
	asl a619A
	jmp b18D0

j1910:
	lsr zp1A_item_place
j1912:
	lda (zp0A_text_ptr),y
	and zp1A_item_place
	bne b1929
	inc a19
	lda a19
	cmp #$05
	beq b1929
	dec zp0A_text_ptr
	dec zp0A_text_ptr
	dec zp0A_text_ptr
	jmp j1912

b1929:
	lda a19
	jsr s1A10
	lda zp1A_item_place
	sta a19
	asl zp1A_item_place
	clc
	ror a19
	bcc b193B
	ror a19
b193B:
	lda (zp0A_text_ptr),y
	and zp1A_item_place
	beq b1944
	inc a6199
b1944:
	lda a19
	cmp #$80
	bne b194C
	inc zp0A_text_ptr
b194C:
	lda (zp0A_text_ptr),y
	and a19
	beq b1955
	inc a619A
b1955:
	lda a19
	cmp #$80
	beq b195D
	inc zp0A_text_ptr
b195D:
	inc zp0A_text_ptr
	inc zp0A_text_ptr
	jsr s1A10
	cmp zp11_box_item
	beq b1900
	jsr s1A10
	lda #$04
	cmp zp11_box_item
b196F:
	beq b18F9
	inc zp11_box_item
	asl a6199
	asl a619A
	jmp b193B

j197C:
	lda zp1A_item_place
	cmp #$02
	bne b198B
	lda #$80
	sta zp1A_item_place
	inc zp0A_text_ptr
	jmp j198F

b198B:
	lsr zp1A_item_place
	lsr zp1A_item_place
j198F:
	lda (zp0A_text_ptr),y
	and zp1A_item_place
	bne b19B3
	inc a19
	lda a19
	cmp #$05
	beq b19B3
	lda zp1A_item_place
	cmp #$02
	bne b19AC
	inc zp0A_text_ptr
	lda #$80
	sta zp1A_item_place
	jmp j198F

b19AC:
	lsr zp1A_item_place
	lsr zp1A_item_place
	jmp j198F

b19B3:
	lda zp1A_item_place
	cmp #$80
	beq b19BE
	asl zp1A_item_place
	jmp j19C4

b19BE:
	dec zp0A_text_ptr
	lda #$01
	sta zp1A_item_place
j19C4:
	lda a19
	jsr s1A10
j19C9:
	lda (zp0A_text_ptr),y
	and zp1A_item_place
	beq b19D2
	inc a6199
b19D2:
	ldy #$03
	lda (zp0A_text_ptr),y
	ldy #$00
	and zp1A_item_place
	beq b19DF
	inc a619A
b19DF:
	lda #$04
	cmp zp11_box_item
	beq b196F
	jsr s1A10
	cmp zp11_box_item
	bne b19EF
	jmp b189A

b19EF:
	jsr s1A10
	asl a6199
	inc zp11_box_item
	asl a619A
	lda zp1A_item_place
	cmp #$40
	beq b1A07
	asl zp1A_item_place
	asl zp1A_item_place
	jmp j19C9

b1A07:
	lda #$01
	sta zp1A_item_place
	dec zp0A_text_ptr
	jmp j19C9

s1A10:
	sta a13
	lda saved_A
	pha
	lda a13
	sta saved_A
	pla
	rts

; junk
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00

item_cmd:
	lda zp0F_action
	cmp #execs_no_location
	bpl icmd07_draw_inv
	asl zp0E_object
	pha
	lda #$00
	sta zp0F_action
	clc
	lda #<(gs_item_location-2)
	adc zp0E_object
	sta zp0E_object
	lda #>(gs_item_location-2)
	adc zp0F_action
	sta zp0F_action
	pla
	cmp #icmd_drop
	bpl icmd06_where_item
	cmp #$00
	beq @destroy_item
	sec
	sbc #$01
	beq @destroy_item
	clc
	adc #$05
@destroy_item:
	ldy #$00
	sta (zp0E_object),y
	inc zp0E_object
	bne :+
	inc zp0F_action
:	lda #$00
	sta (zp0E_object),y
	rts

icmd06_where_item:
	cmp #icmd_drop
	beq icmd05_drop_item
	ldy #$00
	lda (zp0E_object),y
	sta zp1A_item_place
	iny
	lda (zp0E_object),y
	sta a19
	rts

icmd05_drop_item:
	lda gs_level
	ldy #$00
	sta (zp0E_object),y
	lda gs_player_x
	asl
	asl
	asl
	asl
	ora gs_player_y
	iny
	sta (zp0E_object),y
	rts

icmd07_draw_inv:
	sec
	sbc #execs_location_end
	beq @clear_window
	jmp icmd08_count_inv

@clear_window:
	lda #$0f
	sta zp1A_item_place
	lda #$19
	sta zp_col
	lda #$03
	sta zp_row
:	jsr get_rowcol_addr
	lda #$1e     ;char_ClearLine
	jsr char_out
	inc zp_row
	dec zp1A_item_place
	bne :-

; print inventory
	lda #items_unique + items_food
	sta zp1A_item_place
	lda #<gs_item_locs
	sta zp0E_object ;zp_FIXME
	lda #>gs_item_locs
	sta zp0F_action
	lda #$1a
	sta zp_col
	lda #$03
	sta zp_row
	jsr get_rowcol_addr
	lda #$01     ;Inventory:
	jsr print_display_string
	lda #$1b
	sta zp_col
	lda #$04
	sta zp_row
	jsr get_rowcol_addr
check_item_known:
	ldy #$00
	lda (zp0E_object),y
	cmp #$08
	bne :+
	jmp print_known_item

:	cmp #$07
	bne next_known_item
	jmp print_known_item

next_known_item:
	inc zp0E_object
	bne :+
	inc zp0F_action
:	inc zp0E_object
	bne :+
	inc zp0F_action
:	dec zp1A_item_place
	bne check_item_known

	lda #<gs_item_locs
	sta zp0E_object
	lda #>gs_item_locs
	sta zp0F_action
	lda #items_unique + items_food + items_torches
	sta zp1A_item_place
check_item_boxed:
	ldy #$00
	lda (zp0E_object),y
	cmp #carried_boxed
	bne next_boxed_item
	jmp print_boxed_item

next_boxed_item:
	inc zp0E_object
	bne :+
	inc zp0F_action
:	inc zp0E_object
	bne :+
	inc zp0F_action
:	dec zp1A_item_place
	bne check_item_boxed

	lda #$1a
	sta zp_col
	lda #$10
	sta zp_row
	jsr get_rowcol_addr
	lda #$02     ;Torches:
	jsr print_display_string
	lda #$1b
	sta zp_col
	lda #$11
	sta zp_row
	jsr get_rowcol_addr
	lda #$03     ;Lit:
	jsr print_display_string
	inc zp_col
	inc zp_col
	inc zp_col
	jsr get_rowcol_addr
	lda gs_torches_lit
	clc
	adc #'0'
	jsr char_out
	lda #$1b
	sta zp_col
	lda #$12
	sta zp_row
	jsr get_rowcol_addr
	lda #$04     ;Unlit:
	jsr print_display_string
	lda #' '
	jsr char_out
	lda gs_torches_unlit
	clc
	adc #'0'
	jsr char_out
	rts

print_known_item:
	lda #$15
	sec
	sbc zp1A_item_place
	cmp #items_unique
	bmi :+
	lda #noun_food
:	sta a13      ;zp_FIXME
	lda zp_col
	pha
	lda zp_row
	pha
	lda a13
	jsr print_noun
	pla
	sta zp_row
	inc zp_row
	pla
	sta zp_col
	jsr get_rowcol_addr
	jmp next_known_item

print_boxed_item:
	lda zp_col
	pha
	lda zp_row
	pha
	lda #noun_box
	jsr print_noun
	pla
	sta zp_row
	inc zp_row
	pla
	sta zp_col
	jsr get_rowcol_addr
	jmp next_boxed_item

icmd08_count_inv:
	sta zp1A_item_place
	dec zp1A_item_place
	bne icmd09_new_game

	lda #>gs_item_locs
	sta zp0F_action ;zp_FIXME
	lda #<gs_item_locs
	sta zp0E_object
	lda #items_unique + items_food
	sta zp1A_item_place
	lda #$00
	sta a19
	ldy #$00
@check_carried:
	lda (zp0E_object),y
	cmp #$06
	bmi :+
	inc a19
:	iny
	iny
	dec zp1A_item_place
	bne @check_carried
	lda gs_torch_time
	bne @add_one
	lda gs_torches_unlit
	beq @done
@add_one:
	inc a19
@done:
	rts

icmd09_new_game:
	dec zp1A_item_place
	bne icmd0A

	ldy #gs_size-1
	lda #>data_new_game
	sta zp0F_action
	lda #<data_new_game
	sta zp0E_object
	lda #<gs_facing
	sta zp10_noun
	lda #>gs_facing
	sta zp11_box_item
:	lda (zp0E_object),y
	sta (zp10_noun),y
	dey
	bpl :-
	rts

icmd0A:
	dec zp1A_item_place
	bne icmd0B_which_box
	jmp icmd0A_impl

icmd0B_which_box:
	dec zp1A_item_place
	beq :+
	jmp icmd0C_which_food

:	lda gs_player_x
	asl
	asl
	asl
	asl
	clc
	adc gs_player_y
	sta zp11_box_item
	lda #>(gs_item_locs+1)
	sta zp0F_action
	lda #<(gs_item_locs+1)
	sta zp0E_object
	lda #items_unique + items_food + items_torches
	sta zp1A_item_place
	ldy #$00
	lda zp11_box_item
@check_is_here:
	cmp (zp0E_object),y
	beq @check_level
@not_here:
	iny
	iny
	dec zp1A_item_place
	bne @check_is_here

	lda #>gs_item_locs
	sta zp0F_action
	lda #<gs_item_locs
	sta zp0E_object
	lda #noun_snake-1
	sta zp1A_item_place
	lda #carried_boxed
	ldy #$00
@check_is_carried:
	cmp (zp0E_object),y
	beq @return_item_num
	iny
	iny
	dec zp1A_item_place
	bne @check_is_carried

; Skip over snake
	lda #>gs_item_food_torch
	sta zp0F_action
	lda #<gs_item_food_torch
	sta zp0E_object
	lda #items_food + items_torches
	sta zp1A_item_place
	ldy #$00
@next_other:
	cmp (zp0E_object),y
	beq @return_item_num
	iny
	iny
	dec zp1A_item_place
	bne @next_other

; Last, check for carrying boxed snake
	ldx #>gs_item_snake
	stx zp0F_action
	ldx #<gs_item_snake
	stx zp0E_object
	ldy #$00
	cmp (zp0E_object),y
	beq @return_item_num
	lda #$00
	rts

@check_level:
	dec zp0E_object
	lda (zp0E_object),y
	sta a13
	inc zp0E_object
	dey
	lda a13
	cmp gs_level
	beq @return_item_num
	iny
	lda zp11_box_item
	jmp @not_here

@return_item_num:
	clc
	tya
	bpl :+
	lda #$00     ;clamp min 0
:	adc zp0E_object
	sta zp0E_object
	lda #$00
	adc zp0F_action
	sta zp0F_action
	sec
	lda zp0E_object
	sbc #<gs_item_locs
	clc
	ror
	clc
	adc #$01
	rts

icmd0C_which_food:
	dec zp1A_item_place
	bne icmd0D_which_torch
	lda #items_food
	sta zp11_box_item
	lda #carried_known
	sta zp10_noun
	lda #icmd_where
	sta zp0F_action
	lda #item_food_begin
	sta zp0E_object
find_which_multiple:
	lda zp0F_action
	pha
	lda zp0E_object
	pha
	jsr item_cmd
	lda zp10_noun
	cmp zp1A_item_place
	beq @found
	pla
	sta zp0E_object
	pla
	sta zp0F_action
	inc zp0E_object
	dec zp11_box_item
	bne find_which_multiple
	lda #$00
	rts

@found:
	pla
	sta zp0E_object
	pla
	lda zp0E_object
	rts

icmd0D_which_torch:
	dec zp1A_item_place
	bne icmd0E_which_torch
	lda #items_torches
	sta zp11_box_item
	lda #carried_active
	sta zp10_noun
	bne set_action
icmd0E_which_torch:
	dec zp1A_item_place
	bne icmd_default
	lda #items_torches
	sta zp11_box_item
	lda #carried_known
	sta zp10_noun
set_action:
	lda #icmd_where
	sta zp0F_action
	lda #item_torch_begin
	sta zp0E_object
	jsr find_which_multiple
icmd_default:
	rts

icmd0A_impl:
	lda a619A
	and #$e0
	lsr
	lsr
	lsr
	lsr
	lsr
	beq b1D35
	cmp #$05
	bne b1D21
	sec
	sbc #$01
b1D21:
	sta zp1A_item_place
	lda gs_player_x
	sta zp11_box_item
	lda gs_player_y
	sta zp10_noun
	lda gs_level
	sta a19
	jmp j1D3B

b1D35:
	lda #$00
	sta a619B
	rts

j1D3B:
	lda zp1A_item_place
	sta zp0F_action
	lda #$00
	sta zp0E_object
j1D43:
	lda gs_facing
	jsr s1DC7
	jsr s1D69
	dec zp1A_item_place
	beq b1D55
	lsr zp0E_object
	jmp j1D43

b1D55:
	lda #$04
	sec
	sbc zp0F_action
	beq b1D63
b1D5C:
	lsr zp0E_object
	sec
	sbc #$01
	bne b1D5C
b1D63:
	lda zp0E_object
	sta a619B
	rts

s1D69:
	pha
	lda zp11_box_item
	pha
	lda zp10_noun
	pha
	lda zp0F_action
	pha
	lda zp0E_object
	pha
	lda zp11_box_item
	asl
	asl
	asl
	asl
	clc
	adc zp10_noun
	pha
	lda #>(gs_item_locs+1)
	sta zp0F_action
	lda #<(gs_item_locs+1)
	sta zp0E_object
	lda #$17
	sta zp11_box_item
	pla
	ldy #$00
b1D8F:
	cmp (zp0E_object),y
	beq b1DA7
j1D93:
	iny
	iny
	dec zp11_box_item
	bne b1D8F
	pla
	sta zp0E_object
	pla
	sta zp0F_action
b1D9F:
	pla
	sta zp10_noun
	pla
	sta zp11_box_item
	pla
	rts

b1DA7:
	sta zp10_noun
	dec zp0E_object
	lda (zp0E_object),y
	inc zp0E_object
	cmp a19
	beq b1DB8
	lda zp10_noun
	jmp j1D93

b1DB8:
	pla
	sta zp0E_object
	pla
	sta zp0F_action
	lda zp0E_object
	clc
	adc #$08
	sta zp0E_object
	bne b1D9F
s1DC7:
	cmp #$01
	beq b1DD6
	cmp #$02
	beq b1DD9
	cmp #$03
	beq b1DDC
	dec zp10_noun
	rts

b1DD6:
	dec zp11_box_item
	rts

b1DD9:
	inc zp10_noun
	rts

b1DDC:
	inc zp11_box_item
	rts

s1DDF:
	lda gs_facing
	asl
	asl
	asl
	asl
	clc
	adc gs_level
	sta zp11_box_item
	lda gs_player_x
	asl
	asl
	asl
	asl
	clc
	adc gs_player_y
	sta zp10_noun
	lda #>p60A5
	sta zp0F_action
	lda #<p60A5
	sta zp0E_object
	lda #$26
	sta a19
	ldy #$00
	lda zp11_box_item
b1E09:
	cmp (zp0E_object),y
	beq b1E1C
	iny
b1E0E:
	iny
	iny
	iny
	dec a19
	bne b1E09
	lda #$00
	sta zp0F_action
	sta zp0E_object
	rts

b1E1C:
	lda zp10_noun
	iny
	cmp (zp0E_object),y
	beq b1E27
	lda zp11_box_item
	bne b1E0E
b1E27:
	iny
	lda (zp0E_object),y
	sta zp11_box_item
	iny
	lda (zp0E_object),y
	sta zp0E_object
	lda zp11_box_item
	sta zp0F_action
	rts

p1E36:
	.byte $06,$0b,$0b,$07,$0b,$0b,$0b,$0b
	.byte $0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b
	.byte $08,$0b,$0b,$09,$20,$0b,$0b,$20
	.byte $20,$0b,$0b,$20,$0b,$0b,$0b,$0b
	.byte $0b,$0b,$0b,$0b
s1E5A:
	ldy zp0F_action
	dey
	bne b1EA1
	lda #$09
	sta zp1A_item_place
	sta zp_col
	lda #$06
	sta zp_row
	jsr get_rowcol_addr
	lda #>p1E36
	sta text_ptr+1
	lda #<p1E36
	sta zp0A_text_ptr
	ldy #$00
j1E76:
	lda #$04
	sta a19
b1E7A:
	tya
	pha
	lda (zp0A_text_ptr),y
	jsr print_char
	pla
	tay
	iny
	dec a19
	bne b1E7A
	dec zp1A_item_place
	beq b1EA0
	tya
	pha
	inc zp_row
	dec zp_col
	dec zp_col
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	pla
	tay
	jmp j1E76

b1EA0:
	rts

b1EA1:
	dey
	bne b1F1B
	lda #$03
	sta zp_row
	lda #$05
	sta zp_col
	lda #$04
	ldy #$12
	jsr s17A7
	lda #$03
	sta zp_row
	lda #$0a
	sta zp_col
	lda #$04
	ldy #$12
	jsr s17A7
	lda #$03
	sta zp_row
	lda #$10
	sta zp_col
	lda #$03
	ldy #$12
	jsr s17A7
	lda #>p5E50
	sta screen_ptr+1
	lda #<p5E50
	sta screen_ptr
	ldy #$14
	jsr s1777
	lda #<p5D05
	sta screen_ptr
	lda #>p5D05
	sta screen_ptr+1
	ldy #$0a
	jsr s1777
	lda #$07
	sta zp_col
	lda #$01
	sta zp_row
	jsr get_rowcol_addr
	lda #>string_elevator
	sta text_ptr+1
	lda #<string_elevator
	sta zp0A_text_ptr
	ldy #$00
	lda #$08
	sta zp1A_item_place
b1F04:
	tya
	pha
	lda (zp0A_text_ptr),y
	jsr print_char
	pla
	tay
	iny
	dec zp1A_item_place
	bne b1F04
	rts

string_elevator:
	.byte "ELEVATOR"
b1F1B:
	dey
	beq b1F21
	jmp j206A

b1F21:
	lda #$06
	sta zp_0C_string
j1F25:
	lda #$00
	sta zp_row
	lda #$06
	sec
	sbc zp_0C_string
	sta zp_col
	pha
	lda #$20
	ldy #$15
	jsr s17A7
	pla
	pha
	sta zp_col
	inc zp_col
	lda #$00
	sta zp_row
	lda #$04
	ldy #$15
	jsr s17A7
	pla
	pha
	sta zp_col
	inc zp_col
	inc zp_col
	lda #$01
	sta zp_row
	jsr get_rowcol_addr
	lda #$20
	jsr char_out
	inc zp_row
	jsr get_rowcol_addr
	lda #$20
	jsr char_out
	pla
	sta zp_col
	inc zp_col
	inc zp_col
	lda #$00
	sta zp_row
	ldy #$04
	jsr s1795
	dec zp_col
	dec zp_col
	lda zp_col
	pha
	lda zp_row
	pha
	dec zp_row
	lda #$20
	ldy #$0f
	jsr s17A7
	dec zp_col
	jsr get_rowcol_addr
	lda #$20
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #$20
	jsr char_out
	pla
	sta zp_row
	pla
	sta zp_col
	inc zp_col
	lda #$04
	ldy #$0d
	jsr s17A7
	ldy #$04
	jsr s177F
	lda #$00
	sta zp_row
	lda #$10
	clc
	adc zp_0C_string
	sta zp_col
	pha
	lda #$20
	ldy #$15
	jsr s17A7
	pla
	pha
	sta zp_col
	dec zp_col
	lda #$00
	sta zp_row
	lda #$03
	ldy #$15
	jsr s17A7
	pla
	pha
	sta zp_col
	dec zp_col
	dec zp_col
	lda #$01
	sta zp_row
	jsr get_rowcol_addr
	lda #$20
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #$20
	jsr char_out
	pla
	sta zp_col
p1FFF:
	dec zp_col
	dec zp_col
	lda #$00
	sta zp_row
	ldy #$04
	jsr s177F
	inc zp_col
	inc zp_col
	lda zp_col
	pha
	lda zp_row
	pha
	dec zp_row
	lda #$20
	ldy #$0f
	jsr s17A7
	inc zp_col
	jsr get_rowcol_addr
	lda #$20
	jsr char_out
	inc zp_row
	jsr get_rowcol_addr
	lda #$20
	jsr char_out
	pla
	sta zp_row
	pla
	sta zp_col
	dec zp_col
	lda #$03
	ldy #$0d
	jsr s17A7
	ldy #$04
	jsr s1795
	dec zp_0C_string
	beq b2051
	jsr wait_brief
	jmp j1F25

b2051:
	rts

p2052:
	.byte $11,$11,$04,$05,$11,$04,$40,$d4
	.byte $0d,$5e,$50,$15,$0e,$0e,$03,$08
	.byte $0e,$03,$43,$2f,$07,$5c,$54,$0d
j206A:
	dey
	bne b20E7
	lda #<p2052
	sta zp0A_text_ptr
	lda #>p2052
	sta text_ptr+1
	lda #$02
	sta a19
	lda zp0E_object
	beq b207F
	ldy #$0c
b207F:
	lda (zp0A_text_ptr),y
	sta zp_col
	iny
	lda (zp0A_text_ptr),y
	sta zp_row
	iny
	lda (zp0A_text_ptr),y
	iny
	sta zp1A_item_place
	tya
	pha
	lda zp1A_item_place
	tay
	lda #$02
	clc
	adc a19
	jsr s17A7
	pla
	tay
	dec a19
	bne b207F
	lda #$02
	sta a19
b20A5:
	lda (zp0A_text_ptr),y
	sta screen_ptr+1
	iny
	lda (zp0A_text_ptr),y
	sta screen_ptr
	iny
	lda (zp0A_text_ptr),y
	sta zp1A_item_place
	iny
	tya
	pha
	lda zp1A_item_place
	tay
	jsr s1777
	pla
	tay
	dec a19
	bne b20A5
	rts

p20C3:
	.byte $11,$00,$04,$05,$00,$04,$40,$00
	.byte $15,$42,$04,$0d,$0e,$04,$03,$08
	.byte $04,$03,$42,$04,$0d,$43,$87,$07
	.byte $0c,$07,$02,$0a,$07,$02,$43,$87
	.byte $07,$40,$b1,$03
b20E7:
	dey
	bne b2107
	lda #<p20C3
	sta zp0A_text_ptr
	lda #>p20C3
	sta text_ptr+1
	lda #$02
	sta a19
	ldy zp0E_object
	beq b2102
	dey
	beq b207F
	ldy #$0c
	jmp b207F

b2102:
	ldy #$18
	jmp b207F

b2107:
	dey
	beq b210D
	jmp j2272

b210D:
	lda a619B
	and #$08
	beq b2122
	lda #$0b
	sta zp_col
	sta zp_row
	jsr get_rowcol_addr
	lda #$0c
	jsr char_out
b2122:
	lda a619B
	and #$04
	beq b215D
	lda #$0a
	sta zp_col
	lda #$0c
	sta zp_row
	jsr get_rowcol_addr
	lda #$0d
	jsr char_out
	lda #$10
	jsr char_out
	lda #$0e
	jsr char_out
	lda #$0a
	sta zp_col
	lda #$0d
	sta zp_row
	jsr get_rowcol_addr
	lda #$12
	jsr char_out
	lda #$13
	jsr char_out
	lda #$0f
	jsr char_out
b215D:
	lda a619B
	and #$02
	beq b21CB
	lda #$09
	sta zp_col
	lda #$0e
	sta zp_row
	jsr get_rowcol_addr
	lda #$0d
	jsr char_out
	lda #$10
	jsr char_out
	lda #$10
	jsr char_out
	lda #$10
	jsr char_out
	lda #$0e
	jsr char_out
	lda #$09
	sta zp_col
	lda #$0f
	sta zp_row
	jsr get_rowcol_addr
	lda #$03
	jsr char_out
	inc zp_col
	inc zp_col
	inc zp_col
	jsr get_rowcol_addr
	lda #$11
	jsr char_out
	dec zp_col
	inc zp_row
	jsr get_rowcol_addr
	lda #$0f
	jsr char_out
	lda #$09
	sta zp_col
	jsr get_rowcol_addr
	lda #$03
	jsr char_out
	lda #>p40D8
	sta screen_ptr+1
	lda #<p40D8
	sta screen_ptr
	ldy #$04
	jsr s1777
b21CB:
	lda a619B
	and #$01
	beq b2245
	lda #$0e
	sta zp_col
	lda #$11
	sta zp_row
	jsr get_rowcol_addr
	lda #$02
	jsr char_out
	lda #$07
	sta zp_col
	jsr get_rowcol_addr
	ldy #$07
	jsr s1777
	lda #$02
	jsr char_out
	lda #$06
	sta zp_col
	lda #$12
	sta zp_row
	lda #$04
	ldy #$03
	jsr s17A7
	lda #$0d
	sta zp_col
	lda #$12
	sta zp_row
	lda #$04
	ldy #$03
	jsr s17A7
	dec zp_row
	inc zp_col
	jsr get_rowcol_addr
	lda #$02
	jsr char_out
	lda #>p4156
	sta screen_ptr+1
	lda #<p4156
	sta screen_ptr
	ldy #$07
	jsr s1777
	lda #$0f
	sta zp_col
	lda #$11
	sta zp_row
	lda #$03
	tay
	jsr s17A7
	ldx #>p5E56
	stx screen_ptr+1
	ldx #<p5E56
	stx screen_ptr
	ldy #$07
	jsr s1777
b2245:
	rts

p2246:
	.byte $07,$20,$0b,$07,$0b,$0b,$0b,$0b
	.byte $0b,$0b,$0b,$09,$09,$20
p2254:
	.byte $20,$06,$06,$0b,$0b,$0b,$0b,$0b
	.byte $0b,$0b,$08,$0b,$20,$08
string_square:
	.byte "THEPERFECTSQUARE"
j2272:
	dey
	beq b2278
	jmp j2347

b2278:
	lda zp0E_object
	cmp #$01
	beq b22F8
	cmp #$04
	bne b2285
	jmp j2332

b2285:
	lda #$08
	sta zp_col
	pha
	lda #$07
	sta zp_row
	pha
j228F:
	lda #$0b
	ldy #$07
	jsr s17A7
	pla
	sta zp_row
	pla
	sta zp_col
	inc zp_col
	lda zp_col
	cmp #$0f
	beq b22AB
	pha
	lda zp_row
	pha
	jmp j228F

b22AB:
	lda #<string_square
	sta zp0A_text_ptr
	lda #>string_square
	sta text_ptr+1
	lda #$0a
	sta zp_col
	lda #$04
	sta zp_row
	jsr get_rowcol_addr
	lda #$03
	sta zp1A_item_place
	jsr s22E6
	lda #$08
	sta zp_col
	lda #$05
	sta zp_row
	jsr get_rowcol_addr
	lda #$07
	sta zp1A_item_place
	jsr s22E6
	lda #$09
	sta zp_col
	lda #$06
	sta zp_row
	jsr get_rowcol_addr
	lda #$06
	sta zp1A_item_place
s22E6:
	ldy #$00
	lda (zp0A_text_ptr),y
	jsr char_out
	inc zp0A_text_ptr
	bne b22F3
	inc text_ptr+1
b22F3:
	dec zp1A_item_place
	bne s22E6
	rts

b22F8:
	lda #<p2254
	sta zp0A_text_ptr
	lda #>p2254
	sta text_ptr+1
	lda #$13
	sta zp_col
	lda #$07
	sta zp_row
	sta zp1A_item_place
b230A:
	jsr get_rowcol_addr
	ldy #$00
	lda (zp0A_text_ptr),y
	jsr char_out
	inc zp0A_text_ptr
	bne b231A
	inc text_ptr+1
b231A:
	ldy #$00
	lda (zp0A_text_ptr),y
	jsr char_out
	inc zp0A_text_ptr
	bne b2327
	inc text_ptr+1
b2327:
	inc zp_row
	dec zp_col
	dec zp_col
	dec zp1A_item_place
	bne b230A
	rts

j2332:
	lda #<p2246
	sta zp0A_text_ptr
	lda #>p2246
	sta text_ptr+1
	lda #$02
	sta zp_col
	lda #$07
	sta zp_row
	sta zp1A_item_place
	jmp b230A

j2347:
	dey
	beq b234D
	jmp j2410

b234D:
	lda zp0E_object
	cmp #$04
	bne b2356
	jmp j23DD

b2356:
	cmp #$02
	beq b23A8
	lda #$10
	sta zp_col
	lda #$08
	sta zp_row
	jsr get_rowcol_addr
	lda #$14
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	lda #$0a
	ldy #$05
	jsr s17A7
	jsr get_rowcol_addr
	lda #$17
	jsr char_out
	inc zp_row
	jsr get_rowcol_addr
	lda #$15
	jsr char_out
	lda #$10
	sta zp_col
	lda #$09
	sta zp_row
	lda #$16
	ldy #$06
	jsr s17A7
	lda #$11
	sta zp_col
	lda #$08
	sta zp_row
	lda #$03
	ldy #$08
	jsr s17A7
	rts

b23A8:
	lda #$14
	sta zp_col
	lda #$04
	sta zp_row
	ldy #$02
	jsr s177F
	inc zp_col
	lda #$03
	ldy #$0c
	jsr s17A7
	lda #$14
	sta zp_col
	lda #$05
	sta zp_row
	lda #$03
	ldy #$0e
	jsr s17A7
	lda #$15
	sta zp_col
	lda #$04
	sta zp_row
	lda #$03
	ldy #$10
	jsr s17A7
	rts

j23DD:
	lda #$02
	sta zp_col
	lda #$04
	sta zp_row
	ldy #$02
	jsr s1795
	dec zp_col
	lda #$04
	ldy #$0c
	jsr s17A7
	lda #$02
	sta zp_col
	lda #$05
	sta zp_row
	lda #$04
	ldy #$0e
	jsr s17A7
	lda #$01
	sta zp_col
	lda #$04
	sta zp_row
	ldy #$10
	jsr s17A7
	rts

j2410:
	dey
	beq b2416
	jmp j254C

b2416:
	lda zp0E_object
	and #$0f
	beq b244F
	and #$08
	beq b2427
	lda #$0c
	sta zp_col
	jsr draw_keyhole_2
b2427:
	lda zp0E_object
	and #$04
	beq b2434
	lda #$0d
	sta zp_col
	jsr draw_keyhole_1
b2434:
	lda zp0E_object
	and #$02
	beq b2441
	lda #$0f
	sta zp_col
	jsr draw_keyhole_0
b2441:
	lda zp0E_object
	and #$01
	beq b244E
	lda #$13
	sta zp_col
s244B:
	jsr s2484
b244E:
	rts

b244F:
	lda zp0E_object
	and #$10
	beq b245C
	lda #$02
	sta zp_col
	jsr s2484
b245C:
	lda zp0E_object
	and #$20
	beq b2469
	lda #$05
	sta zp_col
	jsr draw_keyhole_0
b2469:
	lda zp0E_object
	and #$40
	beq b2476
	lda #$08
	sta zp_col
	jsr draw_keyhole_1
b2476:
	lda zp0E_object
	and #$80
	beq b2483
	lda #$0a
	sta zp_col
	jsr draw_keyhole_2
b2483:
	rts

s2484:
	lda #$08
	sta zp_row
	jsr get_rowcol_addr
	lda #$7c
	jsr char_out
	lda #$7d
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #$0b
	jsr char_out
	lda #$0b
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #$7e
	jsr char_out
	lda #$7f
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #$1f
	jsr char_out
	lda #$7b
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #$0b
	jsr char_out
	lda #$0b
	jsr char_out
	rts

draw_keyhole_0:
	lda #$09
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_R_notched
	jsr print_char
	lda #glyph_solid
	jsr char_out
	lda #glyph_L_notched
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #glyph_UR_triangle
	jsr print_char
	lda #glyph_solid
	jsr char_out
	lda #glyph_UL_triangle
s2510=*+$01
	jsr print_char
	inc zp_row
	dec zp_col
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #glyph_R_solid
	jsr char_out
	lda #glyph_solid
	jsr char_out
	lda #glyph_L_solid
	jsr char_out
	rts

draw_keyhole_1:
	lda #$0a
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_keyhole_R
	jsr char_out
	lda #glyph_keyhole_L
	jsr char_out
	rts

draw_keyhole_2:
	lda #$0a
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_keyhole_C
	jsr char_out
	rts

j254C:
	lda #$0a
	sta zp_col
	lda #$03
	sta zp_row
	ldy #$12
	jsr s17A7
	lda #$0b
	sta zp_col
	lda #$03
	sta zp_row
	lda #$04
	ldy #$12
	jsr s17A7
	lda #>p40D9
	sta screen_ptr+1
	lda #<p40D9
	sta screen_ptr
	ldy #$02
	jsr s1777
	lda #$0a
	sta zp_0C_string
	lda #$0b
	sta a19
	lda #>p0402
	sta zp11_box_item
	lda #<p0402
	sta zp10_noun
b2585:
	jsr wait_brief
	lda zp_0C_string
	sta zp_col
	lda #$03
	sta zp_row
	lda #$20
	ldy #$12
	jsr s17A7
	lda a19
	sta zp_col
	lda #$03
	sta zp_row
	lda #$20
	ldy #$12
	jsr s17A7
	dec zp_0C_string
	inc a19
	lda zp_0C_string
	sta zp_col
	lda #$03
	sta zp_row
	ldy #$12
	jsr s17A7
	lda a19
	sta zp_col
	lda #$03
	sta zp_row
	lda #$04
	ldy #$12
	jsr s17A7
	lda #$11
	sta zp_row
	dec zp_0C_string
	lda zp_0C_string
	inc zp_0C_string
	sta zp_col
	jsr get_rowcol_addr
	inc zp10_noun
	inc zp10_noun
	ldy zp10_noun
	jsr s1777
	dec zp11_box_item
	bne b2585
	rts

print_noun:
	sta a13
	lda #<noun_table
	sta zp_0C_string
	lda #>noun_table
	sta zp_0D
	ldy #$00
@find_string:
	lda (zp_0C_string),y
	bmi @found_start
@next_char:
	inc zp_0C_string
	bne @find_string
	inc zp_0D
	bne @find_string
@found_start:
	dec a13
	bne @next_char
	lda (zp_0C_string),y
	and #$7f
@print_char:
	jsr char_out
	inc zp_0C_string
	bne :+
	inc zp_0D
:	ldy #$00
	lda (zp_0C_string),y
	bpl @print_char
	lda #' '
	jmp char_out

wait_brief:
	ldx #$28
	stx zp0F_action
:	dec zp0E_object
	bne :-
	dec zp0F_action
	bne :-
	rts

; junk
	.byte $10,$ad,$09,$01,$20,$02,$34,$ad
	.byte $08,$01,$20,$02,$34,$60,$a9,$00
	.byte $9d,$00,$01,$9d,$01,$01,$85,$df
	.byte $85,$e0,$20,$6e

player_cmd:
	lda gd_parsed_object
	sta zp0E_object
	lda gd_parsed_action
	sta zp0F_action
	cmp #$0e
	bmi :+
	jmp cmd_look

:	lda zp0E_object
	cmp #nouns_item_end
	bmi :+
	jmp nonsense

:	jsr noun_to_item
	sta zp11_box_item
	lda gd_parsed_object
	sta zp0E_object
	lda gd_parsed_action
	sta zp0F_action

cmd_raise:
	dec zp0F_action
	bne @cmd_blow

	lda #noun_ring
	cmp zp0E_object
	beq @ring
	lda #noun_staff
	cmp zp0E_object
	beq @staff
@having_fun:
	lda #$1f     ;Having fun?
@print_line2:
	jmp print_to_line2

@staff:
	lda #$73     ;Staff begins to quake
	bne @print_line2
@ring:
	lda gs_level
	cmp #$05
	bne @having_fun
	lda #$07
	cmp zp1A_item_place
	beq @having_fun
	lda #noun_ring
	sta zp0E_object
	lda #icmd_set_carried_active
	sta zp0F_action
	jsr item_cmd
	lda #$01
	sta gs_room_lit
	jsr draw_view
	lda #$71     ;The ring is activated and
	jsr print_to_line1
	lda #$72     ;shines light everywhere!
	bne @print_line2

@cmd_blow:
	dec zp0F_action
	bne cmd_break

	lda zp0E_object
	cmp #noun_flute
	beq @play
	cmp #noun_horn
	bne @having_fun
	lda gs_level
	cmp #$05
	bne :+
	lda gs_special_mode
	cmp #special_mother
	bne :+
	lda #noun_horn
	sta zp0E_object
	lda #icmd_set_carried_active
	sta zp0F_action
	jsr item_cmd
:	lda #$7f     ;A deafening roar envelopes
	jsr print_to_line1
	lda #$80     ;you. Your ears are ringing!
	jsr print_to_line2
	rts

@play:
	lda #noun_play - noun_blow
	sta zp0F_action
cmd_break:
	dec zp0F_action
	bne cmd_burn

	lda zp0E_object
	cmp #noun_ring
	bne :+
	jsr lose_ring
:	cmp #nouns_unique_end
	bmi @broken
	sta a13
	lda zp10_noun
	pha
	lda zp11_box_item
	pha
	lda a13
	cmp #noun_torch
	bne :+
	jsr lose_one_torch
:	pla
	sta zp11_box_item
	pla
	sta zp10_noun
	lda zp11_box_item
	sta zp0E_object
@broken:
	jsr item_cmd
	jsr draw_view
	lda #$4e     ;You break the
	jsr print_to_line1
	lda gd_parsed_object
	jsr print_noun
	lda #$4f     ;and it disappears!
	jmp print_to_line2

lose_one_torch:
	lda gs_torches_unlit
	bne @unlit
	dec gs_torches_lit
	lda gs_level
	cmp #$05     ;level 5 is lit by ring, not torches
	beq @done
	lda #$00
	sta gs_torch_time
	sta gs_room_lit
	jsr push_special_mode
	lda #special_dark
	sta gs_special_mode
@done:
	rts

@unlit:
	dec gs_torches_unlit
	lda #icmd_which_torch_unlit
	sta zp0F_action
	jsr item_cmd
	sta zp0E_object
	lda #icmd_destroy1
	sta zp0F_action
	jmp item_cmd

cmd_burn:
	dec zp0F_action
	bne cmd_eat

	lda gs_torches_lit
	beq @no_fire
	lda zp0E_object
	cmp #noun_ring
	bne :+
	jsr lose_ring
:	cmp #nouns_unique_end
	bmi @burned
	cmp #noun_torch
	beq make_cmd_light
	lda zp11_box_item
	sta zp0E_object
@burned:
	jsr item_cmd
	jsr clear_status_lines
	lda #$52     ;It vanishes in a
	jsr print_to_line1
	lda #$53     ;burst of flames!
@print:
	jmp print_to_line2

@no_fire:
	lda #$88     ;You have no fire.
	bne @print
push_special_mode:
	lda gs_mode_stack1
	sta gs_mode_stack2
	lda gs_special_mode
	sta gs_mode_stack1
	rts

make_cmd_light:
	lda #verb_light - verb_burn
	sta zp0F_action
cmd_eat:
	dec zp0F_action
	beq :+
	jmp cmd_throw

:	lda zp0E_object
	cmp #noun_ring
	bne :+
	jsr lose_ring
:	cmp #nouns_unique_end
	bmi @eaten
	beq @food
	cmp #noun_torch
	beq @torch
@torch_return:
	lda zp11_box_item
	sta zp0E_object
@eaten:
	jsr item_cmd
	jsr draw_view
	lda #$7d     ;You eat the
	jsr print_to_line1
	lda #' '
	jsr char_out
	lda gd_parsed_object
	jsr print_noun
	lda #$7e     ;and you get heartburn!
@print:
	jsr print_to_line2
	lda #icmd_draw_inv
	sta zp0F_action
	jmp item_cmd

@torch:
	lda zp10_noun
	pha
	lda zp11_box_item
	pha
	jsr lose_one_torch
	pla
	sta zp11_box_item
	pla
	sta zp10_noun
	jmp @torch_return

@food:
	lda zp11_box_item
	sta zp0E_object
	jsr item_cmd
	lda gs_food_time_hi
	sta zp0F_action
	lda gs_food_time_lo
	sta zp0E_object
	lda #<food_amount
	sta a19
	lda #>food_amount
	sta zp1A_item_place
	clc
	lda a19
	adc zp0E_object
	sta zp0E_object
	lda zp1A_item_place
	adc zp0F_action
	sta zp0F_action
	sta gs_food_time_hi
	lda zp0E_object
	sta gs_food_time_lo
	lda #$58     ;Digested
	bne @print

lose_ring:
	lda gs_level
	cmp #$05
	bne @done
	lda #$00
	sta gs_room_lit
	lda a61AC
	beq @done
	lda #special_dark
	sta gs_special_mode
	jsr clear_maze_window
@done:
	lda #$0b
	rts

cmd_throw:
	dec zp0F_action
	beq :+
	jmp cmd_climb

:	lda zp0E_object
	cmp #noun_ring
	bne :+
	jsr lose_ring
:	cmp #noun_frisbee
	bne :+
	jmp @throw_frisbee

:	cmp #noun_wool
	beq @throw_wool
	cmp #noun_yoyo
	beq @throw_yoyo
	cmp #noun_food
	bmi @thrown
	beq @throw_food
	cmp #noun_torch
	bne :+
	jsr lose_one_torch
:	lda zp11_box_item
	sta zp0E_object
@thrown:
	jsr item_cmd
	jsr @print_thrown
	jsr throw_react
	nop
	nop
	bne :+
	lda #$97     ;and it vanishes!
	jmp print_to_line1

:	lda #$5c     ;and is eaten by
	jsr print_to_line1
	lda #$5d     ;the monster!
	jmp print_to_line2

@throw_wool:
	lda gs_level
	cmp #$04
	bne @thrown
	lda gs_level_turns_lo
	cmp #turns_until_trippable
	bcc @thrown
	jsr push_special_mode
	lda #special_tripped
	sta gs_special_mode
	lda #noun_wool
	sta zp0E_object
	lda #icmd_destroy1
	sta zp0F_action
	jsr item_cmd
	jsr @print_thrown
	lda #$5e     ;and the monster grabs it,
	jsr print_to_line1
	lda #$5f     ;gets tangled, and topples over!
	jsr print_to_line2
	lda #$00
	sta gs_monster_proximity
	rts

@throw_yoyo:
	jsr @print_thrown
	lda #$6b     ;returns and hits you
	jsr print_to_line1
	lda #$6c     ;in the eye!
	jmp print_to_line2

@throw_food:
	lda zp11_box_item
	sta zp0E_object
	jsr item_cmd
	lda #icmd_draw_inv
	sta zp0F_action
	jsr item_cmd
	lda #$81     ;Food fight!
	jmp print_to_line2

@print_thrown:
	lda #icmd_draw_inv
	sta zp0F_action
	jsr item_cmd
	lda #$59     ;The
	jsr print_to_line1
	lda gd_parsed_object
	jsr print_noun
	jsr dec_item_ptr
	lda #' '
	ldy #$00
	cmp (zp0E_object),y
	beq :+
	inc zp0E_object
	bne :+
	inc zp0F_action
:	inc zp0E_object
	bne :+
	inc zp0F_action
:	lda #$5a     ;magically sails
	jsr print_display_string
	lda #$5b     ;around a nearby corner
	jsr print_to_line2
	jsr wait_long
	jmp clear_status_lines

@throw_frisbee:
	lda gs_monster_lurks
	and #$02
	bne :+
	jmp @thrown

:	lda #noun_frisbee
	sta zp0E_object
	lda #icmd_destroy1
	sta zp0F_action
	jsr item_cmd
	jsr @print_thrown
	jsr clear_status_lines
	lda #$3f     ;The monster grabs the frisbee, throws
	jsr print_to_line1
	lda #$40     ;it back, and it saws your head off!
	jsr print_to_line2
	jsr wait_long
	jmp game_over

cmd_climb:
	dec zp0F_action
	bne cmd_drop
	jmp nonsense ;Climbing only possible during special_climb

cmd_drop:
	dec zp0F_action
	bne cmd_fill

	jsr swap_saved_vars
	lda #icmd_which_box
	sta zp0F_action
	jsr item_cmd
	cmp #$00
	beq @vacant_at_feet
	sta zp0E_object
	lda #icmd_where
	sta zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_begin
	bcs @vacant_at_feet
	lda #$82     ;The hallway is too crowded.
	jsr print_to_line2
	jmp swap_saved_vars

@vacant_at_feet:
	jsr swap_saved_vars
	lda zp0E_object
	cmp #nouns_unique_end
	bpl @multiples
	cmp #noun_ring
	bne @dropped
	jsr lose_ring
@dropped:
	lda #icmd_drop
	sta zp0F_action
	jsr item_cmd
	ldx #icmd_draw_inv
	stx zp0F_action
	jmp item_cmd

@multiples:
	cmp #noun_torch
	beq @torch_unlit
	lda zp11_box_item
	sta zp0E_object
	jmp @dropped

@torch_unlit:
	lda #icmd_which_torch_unlit
	sta zp0F_action
	jsr item_cmd
	beq @torch_lit
	dec gs_torches_unlit
	jmp @dropped

@torch_lit:
	lda #icmd_which_torch_lit
	sta zp0F_action
	jsr item_cmd
	sta zp0E_object
	dec gs_torches_lit
	jsr push_special_mode
	lda #$00
	sta gs_room_lit
	sta gs_torches_lit
	lda #special_dark
	sta gs_special_mode
	jsr clear_maze_window
	jmp @dropped

cmd_fill:
	dec zp0F_action
	bne cmd_light

	lda zp0E_object
	cmp #noun_jar
	beq :+
	jmp nonsense

:	lda #$89     ;With what? Air?
	jmp print_to_line2

cmd_light:
	dec zp0F_action
	bne cmd_play

	sta zp11_box_item
	lda zp0E_object
	cmp #noun_torch
	beq :+
	jmp nonsense

:	lda zp1A_item_place
	cmp #carried_active
	bne cmd_light_impl
	jmp not_carried

cmd_light_impl:
	lda gs_room_lit
	bne @have_fire
	lda #$88     ;You have no fire.
	jsr print_to_line2
	lda #icmd_draw_inv
	sta zp0F_action
	jmp item_cmd

@have_fire:
	lda #icmd_which_torch_lit
	sta zp0F_action
	jsr item_cmd
	cmp #$00
	beq @light_torch
	sta zp0E_object
	lda #icmd_destroy2
	sta zp0F_action
	jsr item_cmd
@light_torch:
	lda #icmd_which_torch_unlit
	sta zp0F_action
	jsr item_cmd
	sta zp0E_object
	lda #icmd_set_carried_active
	sta zp0F_action
	jsr item_cmd
	jsr clear_status_lines
	lda #$65     ;The torch is lit and the
	jsr print_to_line1
	lda #$66     ;old torch dies and vanishes!
	jsr print_to_line2
	dec gs_torches_unlit
	lda #icmd_draw_inv
	sta zp0F_action
	jsr item_cmd
	lda #torch_lifespan
	sta gs_torch_time
	rts

cmd_play:
	dec zp0F_action
	beq :+
	jmp cmd_strike

:	lda zp0E_object
	cmp #item_flute
	beq play_flute
	cmp #item_ball
	beq play_ball
	cmp #$08     ;item_horn
	beq play_horn
	jmp nonsense

play_horn:
	lda #cmd_blow
	sta gd_parsed_action
	jmp player_cmd

play_ball:
	lda #$87     ;With who? The monster?
print_and_rts:
	jmp print_to_line2

play_flute:
	lda #noun_snake
	sta zp0E_object
	lda #icmd_where
	sta zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp gs_level
	bne @music
	lda gs_player_x
	asl
	asl
	asl
	asl
	clc
	adc gs_player_y
	cmp a19
	beq @charm
@music:
	jsr clear_status_lines
	lda #$83     ;A high shrill note comes
	jsr print_to_line1
	lda #$84     ;from the flute!
	jmp print_and_rts ;GUG: saves no bytes, adds time.

@charm:
	lda #$0a
	sta zp_col
	lda #$14
	sta zp_row
@draw_snake:
	jsr get_rowcol_addr
	lda #glyph_R_solid
	jsr print_char
	lda #glyph_X
	jsr print_char
	lda #glyph_L_solid
	jsr print_char
	lda #$30
	sta zp11_box_item
:	dec zp10_noun
	bne :-
	dec zp11_box_item
	bne :-
	dec zp_col
	dec zp_col
	dec zp_col
	dec zp_row
	bpl @draw_snake
	lda #icmd_set_carried_active
	sta zp0F_action
	lda #noun_snake
	sta zp0E_object
	jsr item_cmd
	jsr push_special_mode
	lda #special_climb
	sta gs_special_mode
	lda #$00
	sta gs_snake_used
	rts

cmd_strike:
	dec zp0F_action
	bne cmd_wear

	lda zp0E_object
	cmp #noun_staff
	beq :+
	jmp nonsense

:	jsr clear_status_lines
	lda #$21     ;Thunderbolts shoot out above you!
	jsr print_to_line1
	lda #$22     ;The staff thunders with uselss energy!
	jmp print_to_line2

cmd_wear:
	dec zp0F_action
	beq :+
	rts

:	lda zp0E_object
	cmp #noun_hat
	beq @hat
@print:
	jsr clear_status_lines
	lda #$91     ;OK...if you really want to,
	jsr print_to_line1
	lda #$23     ;you are wearing it.
	jmp print_to_line2

@hat:
	lda #icmd_set_carried_active
	sta zp0F_action
	jsr item_cmd
	jmp @print

cmd_look:
	lda zp0F_action
	sec
	sbc #$0e
	sta zp0F_action
	bne cmd_rub

	lda zp0E_object
	cmp #noun_hat
	bne :+
	jmp look_hat

:	cmp #nouns_item_end
	bmi look_item
	cmp #noun_zero
	bmi :+
	jmp nonsense

:	cmp #noun_door
	beq look_door
look_not_here:
	lda #$90     ;I don't see that here.
look_print:
	jmp print_to_line2

look_door:
	jsr which_door
	cmp #$00
	beq look_not_here
	bne print_inspected
look_item:
	jsr noun_to_item
print_inspected:
	jsr clear_status_lines
	lda #$67     ;A close inspection reveals
	jsr print_to_line1
	lda gd_parsed_object
	cmp #noun_calculator
	beq :+
	lda #$68     ;Nothing of value
	bne look_print
:	lda #$69     ;a smudged display
	bne look_print

cmd_rub:
	dec zp0F_action
	bne cmd_open

	jsr noun_to_item
	lda gd_parsed_object
	cmp #noun_calculator
	beq :+
	lda #$7a     ;Ok, it is clean
	bne look_print
:	lda #$28     ;It displays 317.2 !
	bne look_print

cmd_open:
	dec zp0F_action
	beq :+
	jmp cmd_press

:	lda zp0E_object
	cmp #noun_door
	bne :+
	jmp @open_door

:	cmp #noun_box
	beq @open_box
	jmp nonsense

@open_box:
	lda #icmd_which_box
	sta zp0F_action
	jsr item_cmd
	sta zp11_box_item
	beq look_not_here
	lda zp10_noun
	pha
	lda zp11_box_item
	pha
	sta zp0E_object
	lda #icmd_where
	sta zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_begin
	bcs :+
	jmp @check_contents

:	lda zp11_box_item
	sta zp0E_object
	lda #icmd_set_carried_known
	sta zp0F_action
	jsr item_cmd
@check_contents:
	lda zp11_box_item
	cmp #noun_snake
	beq @push_mode_snake
	bmi @print_item_name
	cmp #item_food_begin
	bmi :+
	lda #noun_torch
	bne @print_item_name
:	lda #noun_food
@print_item_name:
	jsr clear_status_lines
	sta zp10_noun
	clc
	adc #$04
	jsr print_to_line2
	lda #$18     ;Inside the box there is a
	jsr print_to_line1
	lda zp10_noun
	cmp #noun_calculator
	bne :+
	jsr on_reveal_calc
:	sta a13
	cmp #noun_snake
	bne :+
	jsr wait_long
:	pla
	sta zp11_box_item
	pla
	sta zp10_noun
	lda a13
	cmp #noun_torch
	bne @done
	lda #icmd_where
	sta zp0F_action
j2C04=*+$01
	lda zp11_box_item
	sta zp0E_object
	jsr item_cmd
	lda #carried_known
	cmp zp1A_item_place
	bne @done
	inc gs_torches_unlit
@done:
	lda #icmd_draw_inv
	sta zp0F_action
	jmp item_cmd

@push_mode_snake:
	jsr push_special_mode
	ldx #special_snake
	stx gs_special_mode
	lda #noun_snake
	bne @print_item_name

@open_door:
	jsr which_door
	cmp #$00
	bne :+
	jmp look_not_here

:	cmp #$05
	bcs :+
	jmp @push_mode_elevator

:	jsr swap_saved_A
	ldx #noun_key
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_unboxed
	bmi @no_key
	jsr swap_saved_A
	clc
	adc #door_lock_begin - doors_elevators
	cmp #door_lock_begin + door_correct
	beq @correct_lock
	jsr swap_saved_A
	jsr clear_status_lines
	lda #$19     ;You unlock the door...
	jsr print_to_line1
	jsr swap_saved_A
	jsr print_to_line2
	jmp game_over

@no_key:
	jsr swap_saved_A
	lda #$92     ;But you have no key.
	jmp print_to_line2

@correct_lock:
	ldx #special_bomb
	stx gs_special_mode
	jsr clear_status_lines
	lda #$19     ;You unlock the door...
	jsr print_to_line1
	lda #door_lock_begin + door_correct
	jmp print_to_line2

@push_mode_elevator:
	jsr push_special_mode
	ldx #special_elevator
	stx gs_special_mode
	jmp j325D

which_door:
	ldx #$e8
	stx zp0E_object
	ldx #$2c
	stx zp0F_action
	ldx gs_level
	stx a19
	lda gs_player_x
	ldx #$04
	stx zp1A_item_place
:	asl
	asl a19
	dec zp1A_item_place
	bne :-
	clc
	adc gs_player_y
	sta zp11_box_item
	lda a19
	clc
	adc gs_facing
	sta a19
	ldx #$09
	stx zp1A_item_place
@find:
	ldy #$00
	cmp (zp0E_object),y
	bne @next
	lda zp11_box_item
	inc zp0E_object
	bne :+
	inc zp0F_action
:	cmp (zp0E_object),y
	bne :+
	lda #$0a
	sec
	sbc zp1A_item_place
	rts

@next:
	inc zp0E_object
	bne :+
	inc zp0F_action
:	inc zp0E_object
	bne :+
	inc zp0F_action
:	lda a19
	dec zp1A_item_place
	bne @find
	lda #$00
	rts

	.byte $23,$77,$31,$44,$42,$14,$52,$35
	.byte $52,$4a,$52,$5a,$52,$6a,$52,$7a
	.byte $52,$8a

cmd_press:
	dec zp0F_action
	beq :+
	jmp cmd_take

:	lda zp0E_object
	cmp #noun_zero
	bpl :+
	jmp nonsense

:	ldx #icmd_where
	stx zp0F_action
	ldx #noun_calculator
	stx zp0E_object
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_known
	beq :+
	jmp not_carried

:	lda gs_monster_lurks
	and #$02
	bne @display
	lda gs_special_mode
	beq @teleport
@display:
	lda #$85     ;The calculator displays
	jsr print_to_line2
	lda #' '
	jsr char_out
	lda gd_parsed_object
	clc
	adc #''0' - noun_zero
	jmp char_out

@teleport:
	lda gd_parsed_object
	sec
	sbc #noun_zero-1
	ldx #<teleport_table
	stx zp0E_object
	ldx #>teleport_table
	stx zp0F_action
@find_location:
	sec
	sbc #$01
	beq @found
	clc
	pha
	lda #$04
	adc zp0E_object
	sta zp0E_object
	lda zp0F_action
	adc #$00
	sta zp0F_action
	pla
	jmp @find_location

@found:
	ldy #$00
	lda (zp0E_object),y
	sta gs_facing
	inc zp0E_object
	bne :+
	inc zp0F_action
:	lda (zp0E_object),y
	sta gs_level
	inc zp0E_object
	bne :+
	inc zp0F_action
:	lda (zp0E_object),y
	sta gs_player_x
	inc zp0E_object
	bne :+
	inc zp0F_action
:	lda (zp0E_object),y
	sta gs_player_y
	ldx #$00
	stx gs_level_turns_hi
	stx gs_level_turns_lo
	lda gd_parsed_object
	cmp #noun_two
	bne @teleported
	lda gs_room_lit
	bne @snuff
	ldx #$01
	stx gs_teleported_lit
	bne @teleported
@snuff:
	dec gs_room_lit
	ldx #$00
	stx gs_teleported_lit
	inc gs_torches_unlit
	dec gs_torches_lit
	ldx #icmd_which_torch_lit
	stx zp0F_action
	jsr item_cmd
	ldx #icmd_set_carried_known
	stx zp0F_action
	sta zp0E_object
	jsr item_cmd
@teleported:
	ldx #noun_calculator
	stx zp0E_object
	ldx #icmd_destroy2
	stx zp0F_action
	ldx #special_dark
	stx gs_special_mode
	jsr item_cmd
	jsr clear_maze_window
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
	lda #$86     ;You have been teleported!
	jsr print_to_line1
	lda #$74     ;The calculator vanishes.
	jsr print_to_line2
	lda gd_parsed_object
	cmp #noun_two
	bne @done
	lda gs_teleported_lit
	bne @done
	jsr wait_long
	jsr clear_status_lines
	lda #$70     ;A draft blows your torch out.
	jsr print_to_line2
	jmp wait_short

@done:
	rts

teleport_table:
	.byte $02,$02,$05,$04,$02,$02,$07,$09
	.byte $01,$05,$03,$03,$02,$03,$04,$06
	.byte $02,$01,$08,$05,$03,$02,$01,$03
	.byte $02,$01,$05,$05,$01,$01,$07,$0a
	.byte $03,$04,$09,$0a,$03,$03,$07,$0a

cmd_take:
	dec zp0F_action
	beq :+
	jmp cmd_attack

:	ldx #icmd_which_box
	stx zp0F_action
	jsr item_cmd
	tax
	bne :+
	jmp @cannot

:	sta zp11_box_item
	sta zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda gd_parsed_object
	cmp #noun_box
	bne :+
	jmp @take_box

:	cmp #nouns_unique_end
	bmi @unique_item
	jmp @multiple

@unique_item:
	cmp zp11_box_item
	bne @open_if_carried
	ldx zp11_box_item
	stx zp0E_object
	lda zp1A_item_place
	cmp #carried_boxed
	bne @take_if_space ;at feet
	lda zp11_box_item
@open_if_carried:
	sta zp0E_object
	ldx #icmd_where
	stx zp0F_action
j2E72=*+$02
	jsr item_cmd
	lda #carried_boxed
	cmp zp1A_item_place
	beq :+
	jmp @cannot

:	ldx gd_parsed_object
	stx zp0E_object
	jmp @take

@ensure_inv_space:
	jsr swap_saved_vars
	ldx #icmd_count_inv
	stx zp0F_action
	jsr item_cmd
	lda zp19_count
	cmp #inventory_max
	bcc :+
	jmp @inventory_full

:	jmp swap_saved_vars

@take_if_space:
	jsr @ensure_inv_space
@take:
	ldx #icmd_set_carried_known
	stx zp0F_action
	jsr item_cmd
@react_taken:
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
	lda gd_parsed_object
	cmp #noun_calculator
	bne :+
	jsr on_reveal_calc
:	cmp #noun_snake
	bne @done
	jsr push_special_mode
	ldx #special_snake
	stx gs_special_mode
@done:
	rts

on_reveal_calc:
	lda gs_special_mode
	cmp #special_calc_puzzle
	bne @done
	lda gd_parsed_action
	cmp #verb_take
	beq :+
	jsr wait_long
:	jsr clear_status_lines
	lda #$27     ;The calculator displays 317.
	jsr print_to_line2
@done:
	lda #noun_calculator
	rts

@take_box:
	lda zp1A_item_place
	cmp #carried_begin
	bpl @cannot
	jsr @ensure_inv_space
	ldx zp11_box_item
	stx zp0E_object
	ldx #icmd_set_carried_boxed
	stx zp0F_action
	jsr item_cmd
	jmp @react_taken

@multiple:
	cmp #noun_food
	beq @food

	lda zp11_box_item
j2EFB:
	cmp #item_torch_end
	bpl @find_boxed_torch
	cmp #item_torch_begin
	bmi @find_boxed_torch
	ldx zp11_box_item
	stx zp0E_object
	lda zp1A_item_place
	cmp #carried_boxed
	beq @take    ;BUG: get box > get torch: does not increment unlit count if it's the only box
	jsr @ensure_inv_space
	inc gs_torches_unlit
	jmp @take

@food:
	lda zp11_box_item
	cmp #item_food_end
	bpl @find_boxed_food
	cmp #item_food_begin
	bmi @find_boxed_food
	ldx zp11_box_item
	stx zp0E_object
	lda zp1A_item_place
	cmp #carried_boxed
	bne :+
	jmp @take

:	jmp @take_if_space

@cannot:
	lda #$9a     ;It is currently impossible.
@print_rts:
	jmp print_to_line2

@inventory_full:
	pla
	sta zp0E_object
	pla
	sta zp0F_action
	jsr swap_saved_vars
	lda #$99     ;Carrying the limit.
	bne @print_rts

@find_boxed_torch:
	ldx #item_torch_begin - 1
	stx zp0E_object
	bne @begin_search
@find_boxed_food:
	ldx #item_food_begin - 1
	stx zp0E_object
@begin_search:
	lda zp0F_action
	pha
	lda zp0E_object
	pha
	ldx #items_food

; .assert items_food = items_torch, error, "Need to edit cmd_take for separate food,torch counts"
	stx zp11_box_item ;count
@next:
	pla
	sta zp0E_object
	pla
	sta zp0F_action
	inc zp0E_object
	bne :+
	inc zp0F_action
:	lda zp0F_action
	pha
	lda zp0E_object
	pha
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #carried_boxed
	cmp zp1A_item_place
	beq @found
	dec zp11_box_item
	bne @next
	pla
	sta zp0E_object
	pla
	sta zp0F_action
	jmp @cannot

@found:
	pla
	sta zp0E_object
	pla
	sta zp0F_action
	lda gd_parsed_object
	cmp #noun_torch
	beq :+
	jmp @take

:	inc gs_torches_unlit
	jmp @take

cmd_attack:
	dec zp0F_action
	bne cmd_paint

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
@print:
	jsr print_to_line2
	rts

cmd_paint:
	dec zp0F_action
	bne cmd_grendel
	ldx #noun_brush
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_known
	beq :+
	jmp not_carried

:	lda #$6f     ;With what? Toenail polish?
	bne @print

cmd_grendel:
	dec zp0F_action
	bne cmd_say
	jmp nonsense ;GUG: maybe disguise this better

cmd_say:
	dec zp0F_action
	bne cmd_charge
	lda #$76     ;OK...
	jsr print_to_line2
	lda #<text_buffer1
	sta zp0E_object
	lda #>text_buffer1
	sta zp0F_action
	ldy #$00
	lda #$20
b2FF5:
	cmp (zp0E_object),y
	beq b300E
	inc zp0E_object
	bne b2FF5
	inc zp0F_action
	bne b2FF5
b3001:
	ldy #$00
	lda (zp0E_object),y
	cmp #$20
	beq b301C
	sta (zp0A_text_ptr),y
	jsr print_char
b300E:
	inc zp0A_text_ptr
	bne b3014
	inc text_ptr+1
b3014:
	inc zp0E_object
	bne b3001
	inc zp0F_action
	bne b3001
b301C:
	rts

cmd_charge:
	dec zp0F_action
	beq @propel_player
	jmp cmd_fart

@propel_player:
	lda #$02
	cmp gs_facing
	bne b3072
	tax
	dex
	txa
	cmp gs_level
	bne b3072
	cmp gs_player_x
	bne b3072
	lda #$0b
	cmp gs_player_y
	bne b3072
	ldx #noun_hat
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #carried_active
	cmp zp1A_item_place
	bne b30A5
	jsr draw_view
	jsr wait_short
	jsr flash_screen
	jsr pit
	inc gs_level
	ldx #$03
	stx gs_player_y
	stx gs_player_x
	ldx #$00
	stx gs_level_turns_hi
	stx gs_level_turns_lo
	jmp draw_view

b3072:
	lda a619A
	and #$e0
	beq b30A5
	jsr s3085
	jsr wait_short
	jsr draw_view
	jmp @propel_player

s3085:
	lda gs_facing
	tax
	dex
	txa
	beq b3099
	dex
	txa
	beq b309D
	dex
	txa
	beq b30A1
	dec gs_player_y
	rts

b3099:
	dec gs_player_x
	rts

b309D:
	inc gs_player_y
	rts

b30A1:
	inc gs_player_x
	rts

b30A5:
	jsr draw_view
	jsr wait_short
	jsr flash_screen
	jsr clear_status_lines
	lda #$2a     ;You have rammed your head into a steel
	jsr print_to_line1
	lda #$2b     ;wall and bashed your brains out!
	jsr print_to_line2
	jmp game_over

cmd_fart:
	dec zp0F_action
	beq check_fart
	jmp cmd_save

flash_screen:
	ldx #<screen_GR1
	stx zp0E_object
	ldx #>screen_GR1
	stx zp0F_action
	ldy #$00
@fill:
	lda #$dd     ;yellow
:	sta (zp0E_object),y
	inc zp0E_object
	bne :-
	inc zp0F_action
	lda zp0F_action
	cmp #>screen_GR2
	bne @fill
	bit hw_PAGE1
	bit hw_FULLSCREEN
	bit hw_LORES
	bit hw_GRAPHICS
	jsr wait_short
	bit hw_PAGE2
	bit hw_FULLSCREEN
	bit hw_HIRES
	bit hw_GRAPHICS
	rts

check_fart:
	lda gs_special_mode
	beq :+
	lda #$98     ;You will do no such thing!
	jmp print_to_line1

:	jsr flash_screen
	jmp @propel_player

@next_propel:
	jsr wait_short
	jsr draw_view
@propel_player:
	lda a619A
	and #$e0
	beq b313F
	jsr s3085
	lda gs_level
	cmp #$01
	bne b3130
	lda gs_player_x
	cmp #$06
	bne b3130
	lda gs_player_y
	cmp #$0a
	beq b3136
b3130:
	jsr complete_turn
	jmp @next_propel

b3136:
	jsr draw_view
	jsr wait_short
	jmp beheaded

b313F:
	jsr draw_view
	ldx gs_food_time_hi
	stx zp0F_action
	ldx gs_food_time_lo
	stx zp0E_object
	lda zp0F_action
	bne b315D
	lda zp0E_object
	cmp #$05
	bcs :+
	jmp starved

:	cmp #$0f
	bcc b3190
b315D:
	lda #>zp0A_text_ptr
	sta zp1A_item_place
	lda #<zp0A_text_ptr
	sta a19
	lda zp0E_object
	sec
	sbc a19
	sta zp0E_object
	lda zp0F_action
	sbc zp1A_item_place
	sta zp0F_action
	sta gs_food_time_hi
	lda zp0E_object
	sta gs_food_time_lo
b317A:
	jsr wait_short
	jsr clear_maze_window
	lda #$2d     ;WHAM!
	ldx #$08
	stx zp_col
	ldx #$0a
	stx zp_row
	jsr print_display_string
	jmp check_special_position

b3190:
	ldx #$05
	stx gs_food_time_lo
	bne b317A

cmd_save:
	dec zp0F_action
	bne cmd_quit
	lda gs_special_mode
	beq b31A5
	lda #$9a     ;It is currently impossible.
	jmp print_to_line2

b31A5:
	jsr clear_status_lines
	lda #$93     ;Save the game?
	jsr print_to_line1
	jsr input_Y_or_N
	and #$7f
	cmp #'Y'
	beq :+
	jmp clear_status_lines

:	jmp save_disk_or_tape

save_to_tape:
	lda #$95     ;Prepare cassette
	jsr print_to_line1
	lda #$96     ;Press any key
	jsr print_to_line2
	jsr input_char
	ldx #<game_save_begin
	stx tape_addr_start
	ldx #>game_save_begin
	stx tape_addr_start+1
	ldx #<game_save_end
	stx tape_addr_end
	ldx #>game_save_end
	stx tape_addr_end+1
	jsr rom_WRITE_TAPE
	jmp clear_status_lines

cmd_quit:
	dec zp0F_action
	bne cmd_directions
	jsr clear_status_lines
	lda #$9c     ;Are you sure you want to quit?
	jsr print_to_line1
	jsr input_Y_or_N
	cmp #$59
	beq b31F5
	jmp clear_status_lines

b31F5:
	jsr b31A5
	jmp play_again

cmd_directions:
	dec zp0F_action
	bne cmd_hint
	jsr clear_hgr2
	lda #$00
	sta zp_col
	sta zp_row
	jsr get_rowcol_addr
	ldx #<p77BF
	stx zp0E_object
	ldx #>p77BF
	stx zp0F_action
b3213:
	inc zp0E_object
	bne b3219
	inc zp0F_action
b3219:
	ldy #$00
	lda (zp0E_object),y
	and #$7f
	jsr char_out
	ldy #$00
	lda (zp0E_object),y
	bpl b3213
	jsr input_char
	jsr clear_hgr2
	jsr draw_view
	lda #icmd_draw_inv
	sta zp0F_action
	jmp item_cmd

cmd_hint:
	lda gs_special_mode
	cmp #special_calc_puzzle
	beq @calc_hint
	lda gs_next_hint
	beq :+
	lda #$9d     ;Try examining things.
	jsr print_to_line2
	ldx #$00
	stx gs_next_hint
	rts

:	lda #$9e     ;Type instructions.
	jsr print_to_line2
	inc gs_next_hint
	rts

@calc_hint:
	lda #$9f     ;Invert and telephone.
	jmp print_to_line2

j325D:
	jsr draw_view
	lda #$0a
	sta zp0F_action
	jmp s1E5A

swap_saved_A:
	sta a13
	lda saved_A
	pha
	lda a13
	sta saved_A
	pla
	rts

swap_saved_vars:
	lda zp0E_object
	tax
	lda saved_zp0E
	sta zp0E_object
	txa
	sta saved_zp0E
	lda zp0F_action
	tax
	lda saved_zp0F
	sta zp0F_action
	txa
	sta saved_zp0F
	lda zp10_noun
	tax
	lda saved_zp10
	sta zp10_noun
	txa
	sta saved_zp10
	lda zp11_box_item
	tax
	lda saved_zp11
	sta zp11_box_item
	txa
	sta saved_zp11
	lda a19
	tax
	lda saved_zp19
	sta a19
	txa
	sta saved_zp19
	lda saved_zp1A
	tax
	lda zp1A_item_place
	sta saved_zp1A
	txa
	sta zp1A_item_place
	rts

dec_item_ptr:
	pha
	dec zp0E_object
	lda zp0E_object
	cmp #$ff
	bne :+
	dec zp0F_action
:	pla
	rts

text_hat:
	.byte "AN INSCRIPTION READS: WEAR THIS HAT AND "
	.byte "CHARGE A WALL NEAR WHERE YOU FOUND IT!", $A0
look_hat:
	ldx #>text_hat
	stx zp_0D
	ldx #<text_hat
	stx zp_0C_string
	jsr clear_status_lines
	lda #$00
	sta zp_col
	lda #$16
	sta zp_row
	jmp print_string

throw_react:
	lda gd_parsed_object
	cmp #noun_ball
	beq :+
	lda gs_monster_lurks
	and #$02
	rts

:	jsr flash_screen
	jsr clear_hgr2
	jmp game_over

	.byte $07,$ea
check_special_mode:
	ldx gs_special_mode
	bne :+
	rts

:	dex
	dex
	beq special_calc_puzzle
	jmp special_bat

special_calc_puzzle:
	jsr draw_view
	jsr @init_puzzle
	ldx #$01
	stx zp1A_hint_mode
	jsr @print_hint
@puzzle_loop:
	jsr get_player_input
	lda gd_parsed_action
	cmp #$46
	bpl @move
	jsr player_cmd
@continue_loop:
	jsr complete_turn
	jsr print_timers
	jsr @print_timed_hint
	jmp @puzzle_loop

@move:
	cmp #verb_forward
	beq @bump_into_wall
	sta zp1A_move_action
	lda gs_rotate_direction
	bne @check_repeat_turn
	ldx zp1A_item_place ;Set initial turn direction
	stx gs_rotate_direction
	inc gs_rotate_count
	jmp @update_display

@check_repeat_turn:
	cmp zp1A_move_action
	bne @new_direction
	inc gs_rotate_count
	lda gs_rotate_target
	cmp #$03
	bne @update_display
	cmp gs_rotate_count
	bne @update_display
	ldx #$04
	stx gs_facing
	jsr draw_view
	jsr @init_puzzle
	jmp j34D5

@new_direction:
	ldx zp1A_move_action
	stx gs_rotate_direction
	lda gs_rotate_target
	cmp gs_rotate_count
	bne :+
	ldx #$01
	stx gs_rotate_count
	dec gs_rotate_target
	jmp @update_display

:	jsr @reset_target
	inc gs_rotate_count
	ldx zp1A_move_action
	stx gs_rotate_direction
@update_display:
	jsr draw_view
	inc gs_rotate_total
	jmp @continue_loop

@bump_into_wall:
	jsr clear_maze_window
	ldx #$09
	stx zp_col
	ldx #$0a
	stx zp_row
	lda #$7c     ;Splat!
	jsr print_display_string
	jsr @reset_target
	jmp @puzzle_loop

@print_hint:
	lda gd_parsed_action
	cmp #verb_drop
	beq :+
	cmp #verb_movement_begin
	bpl :+
	jsr wait_long
:	lda #$24     ;To everything
	jsr print_to_line1
	lda zp1A_hint_mode
	cmp #$01
	beq :+
	lda #$26     ;Turn turn turn
	jsr print_display_string
:	lda #$25     ;There is a season
	jsr print_to_line2
	lda zp1A_hint_mode
	cmp #$01
	beq @done
	lda #$26     ;Turn turn turn
	jsr print_display_string
@done:
	rts

@init_puzzle:
	ldx #$00
	stx gs_rotate_total
@reset_target:
	ldx #puzzle_step1
	stx gs_rotate_target
	ldx #$00
	stx gs_rotate_count
	stx gs_rotate_direction
	rts

@print_timed_hint:
	lda gs_rotate_total
	cmp #$06
	bcc @print_hint_basic
	cmp #$0f
	bcc @done
	cmp #$15
	bcc @print_hint_basic
	cmp #$1a
	bcc @print_hint_extra
	rts

@print_hint_basic:
	ldx #$01
	stx zp1A_hint_mode
	jmp @print_hint

@print_hint_extra:
	ldx #$00
	stx zp1A_hint_mode
	jmp @print_hint

special_bat:
	dex
	dex
	beq :+
	jmp special_dog

:	jsr draw_view
	lda #$31     ;A vampire bat attacks you!
	jsr print_to_line2
	jsr wait_long
@bat_loop:
	jsr get_player_input
	ldx gd_parsed_object
	stx zp1A_object
	lda gd_parsed_action
	cmp #verb_look
	beq @look
	cmp #verb_throw
	beq @try_action
	cmp #verb_break
	beq @try_action
@dead:
	jsr clear_status_lines
	lda #$9b     ;The bat drains you!
	jsr print_to_line1
	jmp game_over

@look:
	lda zp1A_object
	cmp #noun_bat
	bne @dead
	lda #$8c     ;It looks very dangerous!
j3493:
	jsr print_to_line2
	jmp @bat_loop

@try_action:
	jsr clear_status_lines
	ldx #noun_jar
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_active
	bne @dead
	lda gd_parsed_object
	cmp #noun_jar
	bne @dead
	lda #$50     ;What a mess! The vampire bat
	jsr print_to_line1
	lda #$51     ;drinks the blood and dies!
	jsr print_to_line2
	ldx #icmd_destroy1
	stx zp0F_action
	ldx #noun_jar
	stx zp0E_object
	jsr item_cmd
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
	ldx #$00
	stx gs_bat_alive
j34D5:
	lda gs_mode_stack1
	sta zp1A_item_place
	sta gs_special_mode
	ldx gs_mode_stack2
	stx gs_mode_stack1
	ldx #$00
	stx gs_mode_stack2
	lda zp1A_item_place
	beq b34EF
	jmp check_special_mode

b34EF:
	rts

special_dog:
	dex
	dex
	bne @dog2
	jsr @confront_dog
	ldx #$00
	stx gs_dog1_alive
	jmp j34D5

@dog2:
	dex
	beq :+
	jmp special_monster

:	jsr @confront_dog
	ldx #$00
	stx gs_dog2_alive
	jmp j34D5

@confront_dog:
	jsr draw_view
	lda #$2e     ;A vicious dog attacks you!
	jsr print_to_line2
	jsr wait_long ;GUG: can this be wait_short?
	jsr get_player_input
	lda gd_parsed_object
	sta zp1A_object
	lda gd_parsed_action
	cmp #$59
	bcs @dead
	cmp #verb_throw
	beq @throw
	cmp #verb_attack
	beq @attack
	cmp #verb_look
	beq @look
@dead:
	jsr clear_status_lines
	lda #$2f     ;He rips your throat out!
	jsr print_to_line2
	jmp game_over

@look:
	lda zp1A_object
	cmp #noun_dog
	bne @dead
	lda #$28     ;It displays 317.2!  ;BUG: should be $8c
	jsr print_to_line2
	jmp @confront_dog ;BUG: should JMP to get_player_input

@attack:
	lda zp1A_object
	cmp #noun_dog
	bne @dead
	ldx #noun_dagger
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #$08
	cmp zp1A_item_place
	beq b3585
	ldx #noun_sword
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #$08
	cmp zp1A_item_place
	bne @dead
	jsr clear_status_lines
	lda #$97     ;and it vanishes!
	jsr print_to_line2
j357F:
	lda #$63     ;You have killed it.
	jsr print_to_line1
	rts

b3585:
	ldx #icmd_destroy1
	stx zp0F_action
	ldx #noun_dagger
	stx zp0E_object
	jsr item_cmd
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
	lda #$64     ;The dagger disappears!
	jsr print_to_line2
	jmp j357F

@throw:
	lda zp1A_item_place
	cmp #noun_sneaker
	bne @dead
	ldx #noun_sneaker
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #$08
	cmp zp1A_item_place
	bne @dead
	ldx #noun_sneaker
	stx zp0E_object
	ldx #icmd_destroy1
	stx zp0F_action
	jsr item_cmd
	jsr @print_thrown
	lda #$5c     ;and is eaten by
	jsr print_to_line1
	lda #$5d     ;the monster!
	jsr print_to_line2
	jsr wait_long
	jsr clear_status_lines
	lda #$30     ;The dog chases the sneaker!
	jsr print_to_line1
	jsr wait_long
	jsr clear_status_lines
	lda #$5c     ;and is eaten by
	jsr print_to_line1
	lda #$5d     ;the monster!
	jsr print_to_line2
	rts

special_monster:
	dex
	beq :+
	jmp special_mother

:	lda gd_parsed_action
	cmp #$50
	bcc :+
	jsr draw_view
:	lda gs_monster_proximity
	bne @monster_smell
	jsr wait_if_moved
	lda #$43     ;The ground beneath your feet
	jsr print_to_line1
	lda #$44     ;begins to shake!
	jsr print_to_line2
	inc gs_monster_proximity
	jmp input_near_danger

@monster_smell:
	lda gs_monster_proximity
	cmp #$01
	bne monster_kills_you
	lda #$45     ;A disgusting odor permeates
	jsr print_to_line1
	lda #$46     ;the hallway!
	jsr print_to_line2
	inc gs_monster_proximity
	jmp input_near_danger

monster_kills_you:
	jsr clear_hgr2
	lda #$36     ;The monster attacks you and
	jsr print_to_line1
	lda #$37     ;you are his next meal!
	jsr print_to_line2
	lda gs_lair_raided
	bne :+
	jmp game_over

:	lda #$75     ;Never raid a monster's lair
	ldx #$00
	stx zp_col
	ldx #$15
	stx zp_row
	jsr print_display_string
	jmp game_over

input_near_danger:
	jsr get_player_input
	lda gd_parsed_action
	cmp #$50
	bcc :+
	jsr cmd_movement
	jmp check_special_mode

:	jsr player_cmd
	ldx #$0c
	stx gs_monster_proximity
	jsr wait_if_moved
	jmp check_special_mode

wait_if_moved:
	lda text_buffer1
	cmp #$80
	beq :+
	cmp #$20
	bne @wait
:	lda text_buffer2
	cmp #$80
	bne @wait
	rts

@wait:
	jsr wait_long
	jsr clear_status_lines
	rts

special_mother:
	dex
	beq :+
	jmp special_dark

:	lda gd_parsed_action
	cmp #$50
	bcc :+
	jsr draw_view
:	lda gs_mother_proximity
	bne @mother_smell
	jsr wait_if_moved
	lda #$43     ;The ground beneath your feet
	jsr print_to_line1
	lda #$44     ;begins to shake!
	jsr print_to_line2
	inc gs_mother_proximity
	jmp input_near_danger

@mother_smell:
	tax
	dex
	bne @mother_arrives
	ldx #icmd_where
	stx zp0F_action
	ldx #noun_horn
	stx zp0E_object
	jsr item_cmd
	lda #$07
	cmp zp1A_item_place
	beq @mother_arrives
	lda #$45     ;A disgusting odor permeates
	jsr print_to_line1
	lda #$46     ;the hallway as it darkens!
	jsr print_to_line2
	inc gs_mother_proximity
	jmp input_near_danger

@mother_arrives:
	lda #$48     ;It is the monster's mother!
	jsr print_to_line1
	ldx #noun_horn
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #$07
	cmp zp1A_item_place
	bne @input_near_mother
	lda #$49     ;She has been seduced!
	jsr print_to_line2
@input_near_mother:
	lda zp1A_item_place
	pha
	lda a19
	pha
	jsr get_player_input
	jsr clear_status_lines
	lda gd_parsed_object
	cmp #noun_monster
	beq @look
	cmp #noun_mother
	beq @look
@dead_pop:
	pla
	sta a19
	pla
	sta zp1A_item_place
	lda #$07
	cmp zp1A_item_place
	bne @dead
	lda #$4a     ;She tiptoes up to you!
	jsr print_to_line1
@dead:
	lda #$4b     ;She slashes you to bits!
	jsr print_to_line2
	jmp game_over

@look:
	lda gd_parsed_action
	cmp #verb_look
	bne @attack
	lda #$8c     ;It looks very dangerous!
	jsr print_to_line2
	tax
	pla
	sta a19
	pla
	sta zp1A_item_place
	txa
	jmp @input_near_mother

@attack:
	cmp #verb_attack
	bne @dead_pop
	ldx #noun_sword
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #$08
	cmp zp1A_item_place
	bne @dead_pop
	pla
	sta a19
	pla
	sta zp1A_item_place
	lda #$07
	cmp zp1A_item_place
	bne @dead
	lda #$4a     ;She tiptoes up to you!
	jsr print_to_line1
	lda #$4c     ;You slash her to bits!
	jsr print_to_line2
	jsr wait_long
	lda #$78     ;The body has vanished!
	jsr print_to_line2
	ldx #$00
	stx gs_mother_proximity
	stx a61AC
	stx gs_special_mode
	stx gs_mode_stack1
	rts

special_dark:
	dex
	beq :+
	jmp special_snake

:	lda gd_parsed_action
	cmp #$50
	bcc :+
	jsr draw_view
:	lda gs_room_lit
	beq b3794
	ldx #$00
	stx gs_mother_proximity
	jmp j34D5

b3794:
	ldx #$00
	stx gs_level_turns_lo ;GUG: careful, if I revise to allow re-lighting torch
	lda gs_mother_proximity
	bne @monster_smell
	lda gs_level
	cmp #$05
	beq b37AF
	lda gs_monster_lurks
	and #$02
	bne b37B4
b37AC:
	jmp j34D5

b37AF:
	lda a61AC
	beq b37AC
b37B4:
	jsr wait_if_moved
	lda #$43     ;The ground beneath your feet
	jsr print_to_line1
	lda #$44     ;begins to shake!
	jsr print_to_line2
	inc gs_mother_proximity
	jmp input_near_danger

@monster_smell:
	cmp #$01
	bne @monster_attacks
	jsr wait_if_moved
	inc gs_mother_proximity
	lda #$45     ;A disgusting odor permeates
	jsr print_to_line1
	lda #$47     ;the hallway!
	jsr print_to_line2
	jmp input_near_danger

@monster_attacks:
	jsr wait_if_moved
	lda gs_level
	cmp #$05
	beq @mother
	lda #$36     ;The monster attacks you and
	jsr print_to_line1
	lda #$37     ;you are his next meal!
	jsr print_to_line2
	jmp game_over

@mother:
	lda #$48     ;It is the monster's mother!
	jsr print_to_line1
	lda #$4b     ;She slashes you to bits!
dead_bit:
	jsr print_to_line2
	jmp game_over

special_snake:
	dex
	bne special_bomb

	lda gd_parsed_object
	cmp #noun_snake
	beq snake_check_verb
dead_by_snake:
	jsr clear_status_lines
	lda #$20     ;Snake bites you!
	bne dead_bit
snake_check_verb:
	lda gd_parsed_action
	cmp #verb_look
	beq @look
	cmp #verb_attack
	bne dead_by_snake
@attack:
	ldx #noun_dagger
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #$07
	bpl b3842
	ldx #noun_sword
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #$07
	bmi dead_by_snake
	bpl @killed
b3842:
	ldx #noun_dagger
	stx zp0E_object
	ldx #icmd_destroy1
	stx zp0F_action
	jsr item_cmd
	ldx #icmd_destroy1
	stx zp0F_action
	ldx #noun_snake
	stx zp0E_object
	jsr item_cmd
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
	lda #$64     ;The dagger disappears!
	jsr print_to_line2
@killed:
	lda #$63     ;You have killed it.
	jsr print_to_line1
	jmp j34D5

@look:
	lda #$8c     ;It looks very dangerous!
	jsr print_to_line2
	jmp input_near_danger

special_bomb:
	dex
	beq :+
	jmp special_elevator

:	lda gd_parsed_action
	cmp #$50
	bcc :+
	jsr draw_view
:	lda gs_rotate_direction
	cmp #$09
	beq b38EA
	inc gs_rotate_direction
	jsr s3894
	jmp j392C

s3894:
	lda gs_facing
	sta zp1A_item_place
	lda gs_player_x
	cmp #$0a
	bne b38DD
	lda gs_player_y
	sec
	sbc #$09
	beq b38CC
	tax
	dex
	beq b38BB
	dex
	bne b38DD
	lda #$01
	cmp zp1A_item_place
	bne b38DD
	ldx #$01
	stx zp0F_action
	bne b38DA
b38BB:
	lda #$02
	cmp zp1A_item_place
	bne b38DD
	ldx #$10
	stx zp0E_object
	ldx #$09
	stx zp0F_action
	jmp b38DA

b38CC:
	lda #$02
	cmp zp1A_item_place
	bne b38DD
	ldx #$20
	stx zp0E_object
	lda #$09
	stx zp0F_action
b38DA:
	jsr s1E5A
b38DD:
	lda #$41     ;Tick tick
	ldx #$06
	stx zp_col
	ldx #$02
	stx zp_row
	jmp print_display_string

b38EA:
	jsr s3894
	jsr get_player_input
	lda gd_parsed_action
	cmp #$10
	bne b3916
	lda gd_parsed_object
	cmp #$17
	bne b3916
	lda gs_facing
	cmp #$01
	bne b3916
	lda gs_player_x
	cmp #$0a
	bne b3916
	lda gs_player_y
	cmp #$0b
	bne b3916
	jmp special_exit

b3916:
	jsr flash_screen
	jsr clear_hgr2
	ldx #$00
	stx zp_col
	ldx #$15
	stx zp_row
	lda #$42     ;The key blows up the whole maze!
	jsr print_display_string
	jmp game_over

j392C:
	jsr get_player_input
	lda gd_parsed_action
	cmp #$59
	bcc :+
	jsr cmd_movement
	jmp check_special_mode

:	lda gd_parsed_action
	cmp #verb_open
	bne b3962
	lda gd_parsed_object
	cmp #noun_door
	bne b3962
	lda gs_facing
	cmp #$01
	bne b3962
	lda gs_player_x
	cmp #$0a
	bne b3962
	lda gs_player_y
	cmp #$0b
	bne b3962
	jmp special_exit

b3962:
	jsr complete_turn
	jsr player_cmd
	jsr print_timers
	jmp check_special_mode

special_elevator:
	dex
	beq :+
	jmp special_tripped

:	jsr get_player_input
	lda gd_parsed_action
	cmp #$5b
	beq b39B5
j397E:
	lda gs_mode_stack1
	sta gs_special_mode
	lda gs_mode_stack2
	ldx #$00
	stx gs_mode_stack2
	sta gs_mode_stack1
	jsr draw_view
	lda gd_parsed_action
	cmp #$5b
	bcc b399C
	jmp cmd_movement

b399C:
	jmp player_cmd

j399F:
	lda #$a3     ;The elevator is moving!
	jsr print_to_line1
	jsr wait_long
	lda #$a4     ;You are deposited at the next level.
	jsr print_to_line2
	jsr wait_long
	jsr draw_view
	jmp j34D5

b39B5:
	jsr clear_maze_window
	ldx gs_level
	dex
	dex
	beq b39D2
	dex
	beq b3A03
	dex
	beq b3A0D
	lda #$6d     ;You are trapped in a fake
	jsr print_to_line1
	lda #$6e     ;elevator. There is no escape!
	jsr print_to_line2
	jmp game_over

b39D2:
	jsr clear_maze_window
	ldx #$03
	stx zp0F_action
	stx a6199
	ldx #$23
	stx zp0E_object
	stx a619A
	jsr s12A6
	ldx #$03
	stx zp0F_action
	jsr s1E5A
	jsr wait_short
	jsr clear_maze_window
	lda #$79     ;Glitch!
	ldx #$08
	stx zp_col
	ldx #$0a
	stx zp_row
	jsr print_display_string
	jmp game_over

b3A03:
	inc gs_level
	ldx #$01
	stx gs_player_x
	bne b3A15
b3A0D:
	dec gs_level
	ldx #$04
	stx gs_player_x
b3A15:
	ldx #$00
	stx gs_level_turns_hi
	stx gs_level_turns_lo
	jmp j399F

special_tripped:
	dex
	beq :+
	jmp special_climb

:	lda gs_monster_proximity
	cmp #$0c
	bne :+
	jsr get_player_input
:	ldx #$00
	stx gs_monster_proximity
@check_input:
	lda gd_parsed_object
	cmp #noun_monster
	beq :+
@dead:
	jmp monster_kills_you

:	lda gd_parsed_action
	cmp #verb_look
	bne :+
	jmp @look

:	cmp #verb_attack
	bne @dead
@attack:
	lda gs_room_lit
	beq @dead
	ldx #noun_dagger
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #$08
	cmp zp1A_item_place
	bne @dead
	jsr clear_status_lines
	ldx #noun_dagger
	stx zp0E_object
	ldx #icmd_destroy2
	stx zp0F_action
	jsr item_cmd
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
	lda #$64     ;The dagger disappears!
	jsr print_to_line1
	jsr wait_long
	lda #$61     ;The monster is dead and
	jsr print_to_line1
	lda #$62     ;much blood is spilt!
	jsr print_to_line2
	ldx #$00
	stx gs_monster_lurks
	lda gs_mode_stack1
	cmp #$08
	bne :+
	lda gs_mode_stack2
	sta gs_mode_stack1
	stx gs_mode_stack2
:	jsr get_player_input
	lda gd_parsed_action
	cmp #verb_fill
	bne @done
	lda gd_parsed_object
	cmp #noun_jar
	bne @done
	ldx #icmd_where
	stx zp0F_action
	ldx #noun_jar
	stx zp0E_object
	jsr item_cmd
	lda #$08
	cmp zp1A_item_place
	bne @done
	ldx #noun_jar
	stx zp0E_object
	ldx #icmd_set_carried_active
	stx zp0F_action
	jsr item_cmd
	lda #$60     ;It is now full of blood.
	jsr print_to_line2
	jmp j34D5

@look:
	lda #$8c     ;It looks very dangerous!
	jsr print_to_line1
	jsr get_player_input
	jmp @check_input

@done:
	jsr clear_status_lines
	lda #$78     ;The body has vanished!
	jsr print_to_line1
	jmp j397E

special_climb:
	dex
	beq :+
	jmp special_exit

:	jsr get_player_input
	lda gd_parsed_action
	cmp #$5a
	bcc :+
@dead:
	jmp dead_by_snake

:	cmp #verb_climb
	bne @dead
	lda gd_parsed_object
	cmp #noun_snake
	bne @dead
	lda gs_player_x
	sta zp1A_item_place
	lda gs_player_y
	sta a19
	lda gs_level
	cmp #$03
	beq b3B2C
	cmp #$04
	bne b3B38
	lda zp1A_item_place
	cmp #$01
	bne b3B38
	lda a19
	cmp #$0a
	bne b3B38
	jmp j3B61

b3B2C:
	lda zp1A_item_place
	cmp #$08
	bne b3B38
	lda a19
	cmp #$05
	beq b3B56
b3B38:
	jsr flash_screen
	lda #$2d     ;Wham!
	jsr print_to_line1
	lda #$a5     ;Your head smashes into the ceiling!
	jsr print_to_line2
	jsr wait_long
	jsr clear_status_lines
	lda #$a6     ;You fall on the snake!
	jsr print_to_line1
	jsr wait_long
	jmp dead_by_snake

b3B56:
	ldx #$01
	stx a19
	inx
	stx gs_facing
	jmp j3B6A

j3B61:
	ldx #$00
	stx a19
	ldx #$03
	stx gs_facing
j3B6A:
	dec gs_level
	lda zp1A_item_place
	pha
	lda a19
	pha
	jsr draw_view
	jsr get_player_input
	lda gd_parsed_action
	cmp #$5b
	beq :+
	jsr clear_status_lines
	lda #$54     ;You can't be serious!
	jsr print_to_line1
	jsr wait_long
	jmp dead_by_snake

:	pla
	sta a19
	pla
	sta zp1A_item_place
	pha
	lda a19
	pha
	cmp #$01
	beq :+
	inc gs_player_x
	jmp j3BA5

:	inc gs_player_y
j3BA5:
	jsr draw_view
	lda #$59     ;The
	jsr print_to_line1
	lda #$11     ;snake
	jsr print_noun
	lda #$77     ;has vanished
	jsr print_display_string
	ldx #noun_snake
	stx zp0E_object
	ldx #icmd_destroy1
	stx zp0F_action
	jsr item_cmd
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
	pla
	sta a19
	pla
	sta zp1A_item_place
	lda a19
	cmp #$01
	bne b3BD8
	jmp j34D5

b3BD8:
	lda gs_monster_lurks
	beq b3C03
	lda #$59     ;The
	jsr print_to_line2
	lda #$0f     ;wool
	jsr print_noun
	lda #$77     ;has vanished
	jsr print_display_string
	ldx #icmd_destroy1
	stx zp0F_action
	ldx #noun_wool
	stx zp0E_object
	jsr item_cmd
	ldx #$01
	stx gs_lair_raided
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
b3C03:
	ldx #$01
	stx gs_snake_used
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
j3C0F:
	jsr get_player_input
	lda gd_parsed_action
	cmp #$5a
	bcs b3C2B
	cmp #verb_press
	bne b3C25
	lda #$98     ;You will do no such thing!
	jsr print_to_line2
	jmp j3C0F

b3C25:
	jsr player_cmd
	jmp j3C37

b3C2B:
	cmp #$5b
	beq b3C58
	ldx gs_facing
	stx zp1A_item_place
	jsr move_turn
j3C37:
	lda gs_facing
	ldx #$00
	stx zp0E_object
	ldx #$04
	stx zp0F_action
	cmp #$01
	bne b3C55
	lda gs_room_lit
	beq b3C55
	lda a619A
	and #$e0
	beq b3C55
	jsr s1E5A
b3C55:
	jmp j3C0F

b3C58:
	lda gs_facing
	cmp #$01
	beq b3C72
	jsr clear_maze_window
	ldx #$09
	stx zp_col
	ldx #$0a
	stx zp_row
	lda #$7c     ;Splat!
	jsr print_display_string
	jmp j3C0F

b3C72:
	inc gs_level
	ldx #$03
	stx gs_facing
	dec gs_player_x
	jsr pit
	jsr draw_view
	jmp j34D5

special_exit:
	jsr clear_maze_window
	lda #$07
	sta a6199
	ldx #$47
	stx a619A
	jsr s12A6
	ldx #$08
	stx zp0F_action
	ldx #$01
	stx zp0E_object
	jsr s1E5A
	ldx #$01
	stx gs_exit_turns
j3CA6:
	lda #$a0     ;Don't make unnecessary turns.
	jsr print_to_line1
	jsr get_player_input
	lda gs_exit_turns
	sta zp1A_item_place
	lda gd_parsed_action
	dec zp1A_item_place
	bne b3CE9
	cmp #$5a
	bpl b3CC1
	jmp j3ECA

b3CC1:
	cmp #$5b
	beq b3CC8
	jmp j3EAA

b3CC8:
	jsr clear_maze_window
	ldx #$03
	stx a6199
	ldx #$23
	stx a619A
	jsr s12A6
	ldx #$08
	stx zp0F_action
	ldx #$02
	stx zp0E_object
	jsr s1E5A
	inc gs_exit_turns
	jmp j3CA6

b3CE9:
	dec zp1A_item_place
	bne b3D11
	cmp #$5a
	bpl b3CF4
	jmp j3ECA

b3CF4:
	cmp #$5b
	beq b3CFB
	jmp j3EAA

b3CFB:
	jsr clear_maze_window
	ldx #<p01
	stx a6199
	ldx #>p01
	stx a619A
	jsr s12A6
	inc gs_exit_turns
	jmp j3CA6

b3D11:
	dec zp1A_item_place
	bne b3D40
	cmp #$5a
	bpl b3D1C
	jmp j3ECA

b3D1C:
	cmp #$5d
	beq b3D23
	jmp j3EAA

b3D23:
	jsr clear_maze_window
	ldx #<p01
	stx a6199
	ldx #>p01
	stx a619A
	jsr s12A6
	ldx #$02
	stx zp0F_action
	jsr s1E5A
	inc gs_exit_turns
	jmp j3CA6

b3D40:
	dec zp1A_item_place
	bne b3D69
	cmp #$5a
	bmi b3D4B
	jmp j3EAA

b3D4B:
	cmp #$10
	beq b3D52
	jmp j3ECA

b3D52:
	lda gd_parsed_object
	cmp #noun_door
	beq b3D5C
	jmp j3ECA

b3D5C:
	ldx #$0a
	stx zp0F_action
	jsr s1E5A
	inc gs_exit_turns
	jmp j3CA6

b3D69:
	dec zp1A_item_place
	bne b3DDD
	cmp #$5b
	bne b3D8E
	jsr clear_maze_window
	ldx #$00
	stx zp_col
	ldx #$14
	stx zp_row
	lda #$3a     ;You fall through the floor
	jsr print_display_string
	lda #char_newline
	jsr char_out
	lda #$3b     ;onto a bed of spikes!
	jsr print_display_string
	jmp game_over

b3D8E:
	cmp #$5a
	bmi b3D95
	jmp j3EAA

b3D95:
	cmp #$06
	beq b3D9C
b3D99:
	jmp j3ECA

b3D9C:
	lda gd_parsed_object
	cmp #$01
	bne b3D99
	ldx #icmd_where
	stx zp0F_action
	ldx #noun_ball
	stx zp0E_object
	jsr item_cmd
	lda zp1A_item_place
	cmp #$08
	bne b3D99
	jsr clear_maze_window
	jsr flash_screen
	ldx #$07
	stx a6199
	ldx #$46
	stx a619A
	jsr s12A6
	ldx #icmd_destroy2  ;and #noun_ball
	stx zp0F_action
	stx zp0E_object
	jsr item_cmd
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
	inc gs_exit_turns
	jmp j3CA6

b3DDD:
	dec zp1A_item_place
	bne b3E05
	cmp #$5a
	bpl b3DE8
b3DE5:
	jmp j3ECA

b3DE8:
	cmp #$5b
	beq b3DEF
b3DEC:
	jmp j3EAA

b3DEF:
	jsr clear_maze_window
	ldx #$03
	stx a6199
	ldx #$23
	stx a619A
	jsr s12A6
	inc gs_exit_turns
	jmp j3CA6

b3E05:
	cmp #$5a
	bmi b3DE5
	cmp #$5b
	bne b3DEC
	jsr clear_maze_window
	ldx #$01
	stx a6199
	stx a619A
	jsr s12A6
j3E1B:
	lda #$3c     ;Before I let you go free
	jsr print_to_line1
	lda #$3d     ;what was the name of the monster?
	jsr print_to_line2
	jsr get_player_input
	lda gd_parsed_action
	cmp #$5a
	bpl b3DEC
	cmp #$15
	beq b3E89
	jmp j3E49

p3E36:
	.byte $42,$45,$4f,$57,$55,$4c,$46,$20
	.byte $44,$49,$53,$41,$47,$52,$45,$45
	.byte $53,$21,$80
j3E49:
	jsr clear_status_lines
	ldx #$00
	stx zp_col
	ldx #$16
	stx zp_row
	ldx #<p3E36
	stx zp_0C_string
	ldx #>p3E36
	stx zp_0D
	jsr print_string
	jsr wait_long
	jmp j3E1B

text_congrats:
	.byte "RETURN TO SANITY BY PRESSING RESET!", $80
b3E89:
	jsr clear_hgr2
	ldx #$00
	stx zp_col
	stx zp_row
	lda #$4d     ;Correct! You have survived!
	jsr print_display_string
	lda #char_newline
	jsr char_out
	ldx #<text_congrats
	stx zp_0C_string
	ldx #>text_congrats
	stx zp_0D
	jsr print_string
@infinite_loop:
	jmp @infinite_loop

j3EAA:
	jsr clear_maze_window
	jsr clear_status_lines
	ldx #$00
	stx zp_col
	ldx #$14
	stx zp_row
	lda #$a1     ;You have turned into a pillar of salt!
	jsr print_display_string
	lda #char_newline
	jsr char_out
	lda #$a2     ;Don't say I didn't warn you!
	jsr print_display_string
	jmp game_over

j3ECA:
	lda #$9a     ;It is currently impossible.
	jsr print_to_line2
	jmp j3CA6

	.byte $86
	inc aC3
	bne b3EDC
	ldx #$2e
	jsr s244B
b3EDC:
	stx aBE
	stx aBD
	lda a018F
	beq b3F40
	lda f0135,y
	cmp #$28
	beq b3EF4
	ldx #$25
	jsr s244B
	jmp j3F56

b3EF4:
	stx aE5
	iny
	jsr s2510
	cmp #$3b
	beq b3F38
	cpy #$50
relocate_data:
	lda relocated
	beq @write_DEATH

; Relocate data above HGR2: ($4000-$5FFF) to ($6000-$7FFF)
	ldx #$00
	stx zp0E_object
	stx zp10_noun
	stx relocated
	ldx #$40
	stx zp0F_action
	ldx #$60
	stx zp11_box_item
	ldx #<p1FFF
	stx a19
	ldx #>p1FFF
	stx zp1A_item_place
	jsr memcpy
	ldx #opcode_JMP
	stx DOS_hook_monitor
	ldx #<vector_reset
	stx DOS_hook_monitor+1
	ldx #>vector_reset
	stx DOS_hook_monitor+2
@write_DEATH:
	ldx #'D'
	stx signature
	ldx #'E'
b3F38=*+$01
	stx signature+1
	ldx #'A'
	stx signature+2
b3F40=*+$01
	ldx #'T'
	stx signature+3
	ldx #'H'
	stx signature+4
	ldx #$00
	stx zp_row
	rts

vector_reset:
	bit hw_PAGE2
	bit hw_FULLSCREEN
j3F56=*+$02
	bit hw_HIRES
	bit hw_GRAPHICS
	jmp next_game_loop

	ldy #$00
	tya
	sta (pC2),y
	cmp #$ff
	bne b3F68
	dec aC3
b3F68:
	pla
	pla
	jmp j2C04

	stx aBC
	ldx #$2b
	jsr s244B
	jmp j2C04

s3F77:
	lda a0124
	sta tape_addr_start
	lda a0125
	sta tape_addr_start+1
	lda a0126
	sta tape_addr_end
	lda a0127
	sta tape_addr_end+1
	rts

	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	lda aEE
	beq b3FA3
	jsr s3FA0
	rts

s3FA0:
	jmp (p00F6)

b3FA3:
	jsr s3F77
	jsr rom_READ_TAPE
	ldx #$00
	rts

	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	lda aEF
	beq b3FD3
	jsr s3FD0
	rts

s3FD0:
	jmp (p00F4)

b3FD3:
	jsr s3F77
	jsr rom_WRITE_TAPE
	rts

	jsr eFD35
	cmp #$95
	bne b3FE3
	lda (p28),y
b3FE3:
	rts

	ora #$80
	jmp rom_COUT

	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$08,$00
relocated:
	.byte $ff
screen_HGR2:
	.byte $d5,$7d,$57,$a6,$95,$d3,$b6,$56
	.byte $9c,$a5,$da,$48,$96,$13,$6f,$cb
	.byte $94,$af,$b8,$57,$2f
p4015:
	.byte $a9,$da,$6f,$a3,$49,$2f,$94,$95
	.byte $0f,$ff,$ff,$ff,$df,$77,$5f,$c8
	.byte $aa,$cf,$9d,$1a,$df,$cd,$4a,$6f
	.byte $9b,$68,$8f,$a2,$a4,$df,$96,$96
	.byte $af,$d8,$4e,$cf,$b7,$76,$9f,$88
	.byte $88,$4f,$ff,$ff,$ff,$d5,$d5,$7f
	.byte $9c,$bd,$af,$cb,$a2,$9f,$99,$b6
	.byte $2f,$cd,$99,$2f,$a2,$55,$af,$b5
	.byte $5a,$bf,$8d,$e2,$6f,$a2,$37,$2f
	.byte $95,$54,$4f,$ff,$ff,$ff,$d7,$f7
	.byte $7f,$b2,$66,$af,$a5,$28,$af,$97
	.byte $0c,$8f,$c8,$bb,$df,$9b,$22,$2f
	.byte $ea,$d9,$6f,$92,$2d,$af,$d3,$22
	.byte $2f,$94,$55,$4f,$ff,$ff,$ff,$d7
	.byte $55,$df,$9a,$cc,$4f,$da,$b9,$5f
	.byte $a0,$f6,$6f,$b1,$9b,$2f,$ac,$e0
	.byte $6f,$bd,$9d,$af,$aa,$4a,$af,$a2
	.byte $52,$2f,$9c,$9d,$07,$ff,$ff,$ff
	.byte $42,$34,$05,$01,$42,$35,$05,$02
	.byte $42,$36
p40AF:
	.byte $05,$00
p40B1:
	.byte $22,$83,$04
p40B4:
	.byte $01,$22,$84,$04,$00,$42,$86,$04
	.byte $00,$22,$75,$08,$01,$22,$76,$08
	.byte $02,$32,$77,$02,$00,$23,$43,$08
	.byte $04,$13,$44,$02,$00,$13,$95,$05
	.byte $01,$33,$68,$07
p40D8:
	.byte $04
p40D9:
	.byte $23,$78,$07,$02,$13,$88,$07,$01
	.byte $24,$14,$02,$00,$14,$24,$08,$02
	.byte $14,$2a,$05,$01,$14,$3a,$05,$02
	.byte $14,$4a,$05,$00,$35,$25,$08,$04
	.byte $25,$35,$02,$00,$35,$3a,$09,$f0
	.byte $35,$4a,$09,$f0,$35,$5a,$09,$70
	.byte $35,$6a,$09,$30,$35,$7a,$09,$10
	.byte $15,$5a,$09,$01,$15,$6a,$09,$03
	.byte $15,$7a,$09,$07,$15,$8a,$09,$0f
	.byte $15,$9a,$09,$0f,$15,$aa,$09,$0e
	.byte $25,$4a,$01,$00,$25,$5a,$01,$00
p4131:
	.byte $25
p4132:
	.byte $6a
p4133:
	.byte $01
p4134:
	.byte $00,$25,$7a,$01,$00,$25,$8a,$01
	.byte $00,$02,$01,$0a,$06,$01,$00,$07
	.byte $bf,$00,$00,$00,$01,$00,$a0,$c8
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$02
p4156:
	.byte $04,$02,$01,$01,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$01
	.byte $35,$03,$a5,$01,$33,$01,$46,$04
	.byte $58,$01,$64,$01,$1b,$04,$71,$02
	.byte $11,$05,$72,$01,$23,$01,$72,$02
	.byte $86,$03,$2a,$03,$6a,$04,$57,$02
	.byte $39,$02,$26,$03,$56,$04,$72,$02
	.byte $82,$03,$26,$04,$96,$02,$05,$04
	.byte $0a,$00,$01,$00,$00,$00,$10,$17
	.byte $01,$00,$80,$80,$00,$00,$29,$00
	.byte $00,$00,$00,$00,$00,$00,$04,$00
	.byte $00,$01,$00,$00,$0c,$00,$05,$00
	.byte $00,$00,$00,$01,$00,$08,$00,$03
	.byte $a5,$00,$00,$04,$a9,$08,$00,$01
	.byte $64,$02,$33,$08,$00,$00,$00,$05
	.byte $72,$07,$00,$00,$00,$02,$86,$08
	.byte $00,$04,$a8,$04,$57,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$08,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$44,$45,$41,$54,$48,$07,$00
	.byte $00,$00
p4200:
	.byte $44,$45,$41,$54
p4204:
	.byte $48,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00
p4211:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$10,$08,$3e,$7f,$ff
	.byte $ff,$be,$1c,$01,$02,$04,$08,$08
	.byte $10,$20,$40,$40,$20,$10,$08,$08
	.byte $04,$02,$01,$01,$01,$01,$01,$01
	.byte $01,$01,$01,$40,$40,$40,$40,$40
	.byte $40,$40,$40,$41,$22,$14,$08,$14
	.byte $22,$41,$41,$40,$60,$70,$78,$78
	.byte $7c,$7e,$7f,$01,$03,$07,$0f,$0f
	.byte $1f,$3f,$7f,$7f,$7e,$7c,$78,$78
	.byte $70,$60,$40,$7f,$3f,$1f,$0f,$0f
	.byte $07,$03,$01,$41,$41,$41,$41,$41
	.byte $41,$41,$41,$ff,$ff,$ff,$ff,$ff
	.byte $ff,$ff,$ff,$00,$78,$64,$5e,$52
	.byte $32,$1e,$00,$00,$00,$00,$00,$78
	.byte $04,$02,$7f,$00,$00,$00,$00,$0f
	.byte $0c,$0a,$09,$09,$09,$09,$09,$09
	.byte $05,$03,$01,$00,$00,$00,$00,$7f
	.byte $00,$00,$7f,$09,$09,$09,$09,$09
	.byte $09,$09,$09,$01,$01,$01,$01,$01
	.byte $01,$01,$7f,$00,$00,$00,$00,$00
	.byte $00,$00,$7f,$40,$20,$10,$08,$08
	.byte $0c,$0a,$09,$09,$0a,$0c,$08,$08
	.byte $10,$20,$40,$08,$08,$08,$08,$08
	.byte $08,$08,$08,$41,$42,$44,$48,$48
	.byte $50,$60,$40,$00,$00,$00,$1c,$08
	.byte $1c,$00,$00,$60,$70,$70,$60,$60
	.byte $70,$70,$70,$03,$07,$07,$03,$03
	.byte $07,$07,$07,$07,$07,$07,$07,$07
	.byte $07,$07,$07,$70,$70,$70,$70,$70
	.byte $70,$70,$70,$01,$03,$07,$07,$07
	.byte $07,$07,$07
p4384:
	.byte $40,$60,$70
p4387:
	.byte $70,$70,$70,$70,$70,$78,$78
p438E:
	.byte $78,$78,$7f,$7f,$7f,$7f,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$08,$08
	.byte $08,$08,$08,$00,$08,$00,$14,$14
	.byte $14,$00,$00,$00,$00,$00,$14,$14
	.byte $3e,$14,$3e,$14,$14,$00,$1c,$2a
	.byte $0a,$1c,$28,$2a,$1c,$00,$26,$26
	.byte $10,$08,$04,$32,$32,$00,$04,$0a
	.byte $0a,$04,$2a,$12,$2c,$00,$08,$08
	.byte $08,$00,$00,$00,$00,$00,$10,$08
	.byte $04,$04,$04,$08,$10,$00,$04,$08
	.byte $10,$10,$10,$08,$04,$00,$08,$2a
	.byte $1c,$08,$1c,$2a,$08,$00,$00,$08
	.byte $08,$3e,$08,$08,$00,$00,$00,$00
	.byte $00,$00,$10,$10,$08,$00,$00,$00
	.byte $00,$3e,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$0c,$0c,$00,$20,$20
	.byte $10,$08,$04,$02,$02,$00,$1c,$22
	.byte $32,$2a,$26,$22,$1c,$00,$08,$0c
	.byte $08,$08,$08,$08,$1c,$00,$1c,$22
	.byte $20,$1c,$02,$02,$3e,$00,$1e,$20
	.byte $20,$1c,$20,$20,$1e,$00,$10,$18
	.byte $14,$12,$3e,$10,$10,$00,$3e,$02
	.byte $1e,$20,$20,$20,$1e,$00,$18,$04
	.byte $02,$1e,$22,$22,$1c,$00,$3e,$20
	.byte $10,$08,$04,$04,$04,$00,$1c,$22
	.byte $22,$1c,$22,$22,$1c,$00,$1c,$22
	.byte $22,$3c,$20,$10,$0c,$00,$00,$0c
	.byte $0c,$00,$0c,$0c,$00,$00,$00,$0c
	.byte $0c,$00,$0c,$0c,$04,$00,$10,$08
	.byte $04,$02,$04,$08,$10,$00,$00,$00
	.byte $3e,$00,$3e,$00,$00,$00,$04,$08
	.byte $10,$20,$10,$08,$04,$00,$1c,$22
	.byte $10,$08,$08,$00,$08,$00,$1c,$22
	.byte $3a,$2a,$3a,$02,$3c,$00,$08,$14
	.byte $22,$22,$3e,$22,$22,$00,$1e,$24
	.byte $24,$1c,$24,$24,$1e,$00,$1c,$22
	.byte $02,$02,$02,$22,$1c,$00,$1e,$24
	.byte $24,$24,$24,$24,$1e,$00,$3e,$02
	.byte $02,$1e,$02,$02,$3e,$00,$3e,$02
	.byte $02,$1e,$02,$02,$02,$00,$3c,$02
	.byte $02,$02,$32,$22,$3c,$00,$22,$22
	.byte $22,$3e,$22,$22,$22,$00,$1c,$08
	.byte $08,$08,$08,$08,$1c,$00,$20,$20
	.byte $20,$20,$22,$22,$1c,$00,$22,$12
	.byte $0a,$06,$0a,$12,$22,$00,$02,$02
	.byte $02,$02,$02,$02,$7e,$00,$22,$36
	.byte $2a,$2a,$22,$22,$22,$00,$22,$26
	.byte $2a,$32,$22,$22,$22,$00,$1c,$22
	.byte $22,$22,$22,$22,$1c,$00,$1e,$22
	.byte $22,$1e,$02,$02,$02,$00,$1c,$22
	.byte $22,$22,$2a,$12,$2c,$00,$1e,$22
	.byte $22,$1e,$0a,$12,$22,$00,$1c,$22
	.byte $02,$1c,$20,$22,$1c,$00,$3e,$08
	.byte $08,$08,$08,$08,$08,$00,$22,$22
	.byte $22,$22,$22,$22,$1c,$00,$22,$22
	.byte $22,$14,$14,$08,$08,$00,$22,$22
	.byte $2a,$2a,$2a,$36,$22,$00,$22,$22
	.byte $14,$08,$14,$22,$22,$00,$22,$22
	.byte $22,$1c,$08,$08,$08,$00,$3e,$20
	.byte $10,$08,$04,$02,$3e,$00,$08,$1c
	.byte $2a,$08,$08,$08,$08,$00,$08,$08
	.byte $08,$08,$2a,$1c,$08,$00,$00,$04
	.byte $02,$7f,$02,$04,$00,$00,$00,$10
	.byte $20,$7f,$20,$10,$00,$00,$70,$60
	.byte $40,$00,$00,$00,$00,$00,$07,$03
	.byte $01,$00,$00,$00,$00,$00,$00,$00
	.byte $1c,$20,$3c,$22,$3c,$00,$02,$02
	.byte $1a,$26,$22,$22,$1e,$00,$00,$00
	.byte $1c,$22,$02,$22,$1c,$00,$20,$20
	.byte $2c,$32,$22,$22,$3c,$00,$00,$00
	.byte $1c,$22,$3e,$02,$1c,$00,$18,$24
	.byte $04,$0e,$04,$04,$04,$00,$00,$00
	.byte $2c,$32,$22,$3c,$20,$1e,$02,$02
	.byte $1a,$26,$22,$22,$22,$00,$08,$00
	.byte $0c,$08,$08,$08,$1c,$00,$20,$00
	.byte $20,$20,$20,$20,$22,$1c,$02,$02
	.byte $12,$0a,$06,$0a,$12,$00,$00,$0c
	.byte $08,$08,$08,$08,$1c,$00,$00,$00
	.byte $16,$2a,$2a,$2a,$2a,$00,$00,$00
	.byte $1a,$26,$22,$22,$22,$00,$00,$00
	.byte $1c,$22,$22,$22,$1c,$00,$00,$00
	.byte $1e,$22,$22,$1e,$02,$02,$00,$00
	.byte $3c,$22,$22,$3c,$20,$20,$00,$00
	.byte $1a,$26,$02,$02,$02,$00,$00,$00
	.byte $3c,$02,$1c,$20,$1e,$00,$04,$04
	.byte $1e,$04,$04,$24,$18,$00,$00,$00
	.byte $22,$22,$22,$32,$2c,$00,$00,$00
	.byte $22,$22,$14,$14,$08,$00,$00,$00
	.byte $2a,$2a,$2a,$2a,$14,$00,$00,$00
	.byte $22,$14,$08,$14,$22,$00,$00,$00
	.byte $22,$22,$22,$3c,$20,$1c,$00,$00
	.byte $3e,$10,$08,$04,$3e,$00,$0f,$0f
	.byte $0f,$0f,$7f,$7f,$7f,$7f,$70,$78
	.byte $7c,$7e,$7f,$7f,$7f,$7f,$07,$0f
	.byte $1f,$3f,$7f,$7f,$7f,$7f,$7f,$7f
	.byte $7f,$7f,$7e,$7c,$78,$70,$7f,$7f
	.byte $7f,$7f,$3f,$1f,$0f,$07,$ff,$f2
	.byte $61,$69,$73,$e2,$6c,$6f,$77,$e2
	.byte $72,$65,$61,$e2,$75,$72,$6e,$e3
	.byte $68,$65,$77,$2a,$e5,$61,$74,$20
	.byte $f2,$6f,$6c,$6c,$2a,$e3,$68,$75
	.byte $63,$2a,$e8,$65,$61,$76,$2a,$f4
	.byte $68,$72,$6f,$e3,$6c,$69,$6d,$e4
	.byte $72,$6f,$70,$2a,$ec,$65,$61,$76
	.byte $2a,$f0,$75,$74,$20,$e6,$69,$6c
	.byte $6c,$ec,$69,$67,$68,$f0,$6c,$61
	.byte $79,$f3,$74,$72,$69,$f7,$65,$61
	.byte $72,$e5,$78,$61,$6d,$2a,$ec,$6f
	.byte $6f,$6b,$f7,$69,$70,$65,$2a,$e3
	.byte $6c,$65,$61,$2a,$f0,$6f,$6c,$69
	.byte $2a,$f2,$75,$62,$20,$ef,$70,$65
	.byte $6e,$2a,$f5,$6e,$6c,$6f,$f0,$72
	.byte $65,$73,$e7,$65,$74,$20,$2a,$e7
	.byte $72,$61,$62,$2a,$e8,$6f,$6c,$64
	.byte $2a,$f4,$61,$6b,$65,$f3,$74,$61
	.byte $62,$2a,$eb,$69,$6c,$6c,$2a,$f3
	.byte $6c,$61,$73,$2a,$e1,$74,$74,$61
	.byte $2a,$e8,$61,$63,$6b,$f0,$61,$69
	.byte $6e,$e7,$72,$65,$6e,$f3,$61,$79
	.byte $20,$2a,$f9,$65,$6c,$6c,$2a,$f3
	.byte $63,$72,$65,$e3,$68,$61,$72,$e6
	.byte $61,$72,$74,$f3,$61,$76,$65,$f1
	.byte $75,$69,$74,$e9,$6e,$73,$74,$2a
	.byte $e4,$69,$72,$65,$e8,$65,$6c,$70
	.byte $2a,$e8,$69,$6e,$74,$c2,$61,$6c
	.byte $6c,$c2,$72,$75,$73,$68,$c3,$61
	.byte $6c,$63,$75,$6c,$61,$74,$6f,$72
	.byte $c4,$61,$67,$67,$65,$72,$c6,$6c
	.byte $75,$74,$65,$c6,$72,$69,$73,$62
	.byte $65,$65,$c8,$61,$74,$20,$c8,$6f
	.byte $72,$6e,$ca,$61,$72,$20,$cb,$65
	.byte $79,$20,$d2,$69,$6e,$67,$d3,$6e
	.byte $65,$61,$6b,$65,$72,$d3,$74,$61
	.byte $66,$66,$d3,$77,$6f,$72,$64,$d7
	.byte $6f,$6f,$6c,$d9,$6f,$79,$6f,$d3
	.byte $6e,$61,$6b,$65,$c6,$6f,$6f,$64
	.byte $d4,$6f,$72,$63,$68,$c2,$6f,$78
	.byte $20,$c2,$61,$74,$20,$c4,$6f,$67
	.byte $20,$c4,$6f,$6f,$72,$2a,$c5,$6c
	.byte $65,$76,$cd,$6f,$6e,$73,$74,$65
	.byte $72,$cd,$6f,$74,$68,$65,$72,$da
	.byte $65,$72,$6f,$cf,$6e,$65,$20,$d4
	.byte $77,$6f,$20,$d4,$68,$72,$65,$65
	.byte $c6,$6f,$75,$72,$c6,$69,$76,$65
	.byte $d3,$69,$78,$20,$d3,$65,$76,$65
	.byte $6e,$c5,$69,$67,$68,$74,$ce,$69
	.byte $6e,$65,$ff,$ff,$00,$00,$ff,$ff
	.byte $00,$00,$ff,$c9,$6e,$76,$65,$6e
	.byte $74,$6f,$72,$79,$3a,$d4,$6f,$72
	.byte $63,$68,$65,$73,$3a,$cc,$69,$74
	.byte $3a,$d5,$6e,$6c,$69,$74,$3a,$e3
	.byte $72,$79,$73,$74,$61,$6c,$20,$62
	.byte $61,$6c,$6c,$2e,$f0,$61,$69,$6e
	.byte $74,$62,$72,$75,$73,$68,$20,$75
	.byte $73,$65,$64,$20,$62,$79,$20,$56
	.byte $61,$6e,$20,$47,$6f,$67,$68,$2e
	.byte $e3,$61,$6c,$63,$75,$6c,$61,$74
	.byte $6f,$72,$20,$77,$69,$74,$68,$20
	.byte $31,$30,$20,$62,$75,$74,$74,$6f
	.byte $6e,$73,$2e,$ea,$65,$77,$65,$6c
	.byte $65,$64,$20,$68,$61,$6e,$64,$6c
	.byte $65,$64,$20,$64,$61,$67,$67,$65
	.byte $72,$2e,$e6,$6c,$75,$74,$65,$2e
	.byte $f0,$72,$65,$63,$69,$73,$69,$6f
	.byte $6e,$20,$63,$72,$61,$66,$74,$65
	.byte $64,$20,$66,$72,$69,$73,$62,$65
	.byte $65,$2e,$e8,$61,$74,$20,$77,$69
	.byte $74,$68,$20,$74,$77,$6f,$20,$72
	.byte $61,$6d,$27,$73,$20,$68,$6f,$72
	.byte $6e,$73,$2e,$e3,$61,$72,$65,$66
	.byte $75,$6c,$6c,$79,$20,$70,$6f,$6c
	.byte $69,$73,$68,$65,$64,$20,$68,$6f
	.byte $72,$6e,$2e,$e7,$6c,$61,$73,$73
	.byte $20,$6a,$61,$72,$20,$63,$6f,$6d
	.byte $70,$6c,$65,$74,$65,$20,$77,$69
	.byte $74,$68,$20,$6c,$69,$64,$2e,$e7
	.byte $6f,$6c,$64,$65,$6e,$20,$6b,$65
	.byte $79,$2e,$e4,$69,$61,$6d,$6f,$6e
	.byte $64,$20,$72,$69,$6e,$67,$2e,$f2
	.byte $6f,$74,$74,$65,$64,$20,$6d,$75
	.byte $74,$69,$6c,$61,$74,$65,$64,$20
	.byte $73,$6e,$65,$61,$6b,$65,$72,$2e
	.byte $ed,$61,$67,$69,$63,$20,$73,$74
	.byte $61,$66,$66,$2e,$b9,$30,$20,$70
	.byte $6f,$75,$6e,$64,$20,$74,$77,$6f
	.byte $2d,$68,$61,$6e,$64,$65,$64,$20
	.byte $73,$77,$6f,$72,$64,$2e,$e2,$61
	.byte $6c,$6c,$20,$6f,$66,$20,$62,$6c
	.byte $75,$65,$20,$77,$6f,$6f,$6c,$2e
	.byte $f9,$6f,$79,$6f,$2e,$f3,$6e,$61
	.byte $6b,$65,$20,$21,$21,$21,$e2,$61
	.byte $73,$6b,$65,$74,$20,$6f,$66,$20
	.byte $66,$6f,$6f,$64,$2e,$f4,$6f,$72
	.byte $63,$68,$2e,$c9,$6e,$73,$69,$64
	.byte $65,$20,$74,$68,$65,$20,$62,$6f
	.byte $78,$20,$74,$68,$65,$72,$65,$20
	.byte $69,$73,$20,$61,$d9,$6f,$75,$20
	.byte $75,$6e,$6c,$6f,$63,$6b,$20,$74
	.byte $68,$65,$20,$64,$6f,$6f,$72,$2e
	.byte $2e,$2e,$e1,$6e,$64,$20,$74,$68
	.byte $65,$20,$77,$61,$6c,$6c,$20,$66
	.byte $61,$6c,$6c,$73,$20,$6f,$6e,$20
	.byte $79,$6f,$75,$21,$e1,$6e,$64,$20
	.byte $74,$68,$65,$20,$6b,$65,$79,$20
	.byte $62,$65,$67,$69,$6e,$73,$20,$74
	.byte $6f,$20,$74,$69,$63,$6b,$21,$e1
	.byte $6e,$64,$20,$61,$20,$32,$30,$2c
	.byte $30,$30,$30,$20,$76,$6f,$6c,$74
	.byte $20,$73,$68,$6f,$63,$6b,$20,$6b
	.byte $69,$6c,$6c,$73,$20,$79,$6f,$75
	.byte $21,$c1,$20,$36,$30,$30,$20,$70
	.byte $6f,$75,$6e,$64,$20,$67,$6f,$72
	.byte $69,$6c,$6c,$61,$20,$72,$69,$70
	.byte $73,$20,$79,$6f,$75,$72,$20,$66
	.byte $61,$63,$65,$20,$6f,$66,$66,$21
	.byte $d4,$77,$6f,$20,$6d,$65,$6e,$20
	.byte $69,$6e,$20,$77,$68,$69,$74,$65
	.byte $20,$63,$6f,$61,$74,$73,$20,$74
	.byte $61,$6b,$65,$20,$79,$6f,$75,$20
	.byte $61,$77,$61,$79,$21,$c8,$61,$76
	.byte $69,$6e,$67,$20,$66,$75,$6e,$3f
	.byte $d4,$68,$65,$20,$73,$6e,$61,$6b
	.byte $65,$20,$62,$69,$74,$65,$73,$20
	.byte $79,$6f,$75,$20,$61,$6e,$64,$20
	.byte $79,$6f,$75,$20,$64,$69,$65,$21
	.byte $d4,$68,$75,$6e,$64,$65,$72,$62
	.byte $6f,$6c,$74,$73,$20,$73,$68,$6f
	.byte $6f,$74,$20,$6f,$75,$74,$20,$61
	.byte $62,$6f,$76,$65,$20,$79,$6f,$75
	.byte $21,$d4,$68,$65,$20,$73,$74,$61
	.byte $66,$66,$20,$74,$68,$75,$6e,$64
	.byte $65,$72,$73,$20,$77,$69,$74,$68
	.byte $20,$75,$73,$65,$6c,$65,$73,$73
	.byte $20,$65,$6e,$65,$72,$67,$79,$21
	.byte $f9,$6f,$75,$20,$61,$72,$65,$20
	.byte $77,$65,$61,$72,$69,$6e,$67,$20
	.byte $69,$74,$2e,$d4,$6f,$20,$65,$76
	.byte $65,$72,$79,$74,$68,$69,$6e,$67
	.byte $d4,$68,$65,$72,$65,$20,$69,$73
	.byte $20,$61,$20,$73,$65,$61,$73,$6f
	.byte $6e,$ac,$20,$54,$55,$52,$4e,$2c
	.byte $54,$55,$52,$4e,$2c,$54,$55,$52
	.byte $4e,$d4,$68,$65,$20,$63,$61,$6c
	.byte $63,$75,$6c,$61,$74,$6f,$72,$20
	.byte $64,$69,$73,$70,$6c,$61,$79,$73
	.byte $20,$33,$31,$37,$2e,$c9,$74,$20
	.byte $64,$69,$73,$70,$6c,$61,$79,$73
	.byte $20,$33,$31,$37,$2e,$32,$20,$21
	.byte $d4,$68,$65,$20,$69,$6e,$76,$69
	.byte $73,$69,$62,$6c,$65,$20,$67,$75
	.byte $69,$6c,$6c,$6f,$74,$69,$6e,$65
	.byte $20,$62,$65,$68,$65,$61,$64,$73
	.byte $20,$79,$6f,$75,$21,$d9,$6f,$75
	.byte $20,$68,$61,$76,$65,$20,$72,$61
	.byte $6d,$6d,$65,$64,$20,$79,$6f,$75
	.byte $72,$20,$68,$65,$61,$64,$20,$69
	.byte $6e,$74,$6f,$20,$61,$20,$73,$74
	.byte $65,$65,$6c,$f7,$61,$6c,$6c,$20
	.byte $61,$6e,$64,$20,$62,$61,$73,$68
	.byte $65,$64,$20,$79,$6f,$75,$72,$20
	.byte $62,$72,$61,$69,$6e,$73,$20,$6f
	.byte $75,$74,$21,$c1,$41,$41,$41,$41
	.byte $41,$41,$41,$41,$41,$41,$48,$48
	.byte $48,$48,$48,$21,$d7,$48,$41,$4d
	.byte $21,$21,$21,$c1,$20,$76,$69,$63
	.byte $69,$6f,$75,$73,$20,$64,$6f,$67
	.byte $20,$61,$74,$74,$61,$63,$6b,$73
	.byte $20,$79,$6f,$75,$21,$c8,$65,$20
	.byte $72,$69,$70,$73,$20,$79,$6f,$75
	.byte $72,$20,$74,$68,$72,$6f,$61,$74
	.byte $20,$6f,$75,$74,$21,$d4,$68,$65
	.byte $20,$64,$6f,$67,$20,$63,$68,$61
	.byte $73,$65,$73,$20,$74,$68,$65,$20
	.byte $73,$6e,$65,$61,$6b,$65,$72,$21
	.byte $c1,$20,$76,$61,$6d,$70,$69,$72
	.byte $65,$20,$62,$61,$74,$20,$61,$74
	.byte $74,$61,$63,$6b,$73,$20,$79,$6f
	.byte $75,$21,$d9,$6f,$75,$72,$20,$73
	.byte $74,$6f,$6d,$61,$63,$68,$20,$69
	.byte $73,$20,$67,$72,$6f,$77,$6c,$69
	.byte $6e,$67,$21,$d9,$6f,$75,$72,$20
	.byte $74,$6f,$72,$63,$68,$20,$69,$73
	.byte $20,$64,$79,$69,$6e,$67,$21,$d9
	.byte $6f,$75,$20,$61,$72,$65,$20,$61
	.byte $6e,$6f,$74,$68,$65,$72,$20,$76
	.byte $69,$63,$74,$69,$6d,$20,$6f,$66
	.byte $20,$74,$68,$65,$20,$6d,$61,$7a
	.byte $65,$21,$d9,$6f,$75,$20,$68,$61
	.byte $76,$65,$20,$64,$69,$65,$64,$20
	.byte $6f,$66,$20,$73,$74,$61,$72,$76
	.byte $61,$74,$69,$6f,$6e,$21,$d4,$68
	.byte $65,$20,$6d,$6f,$6e,$73,$74,$65
	.byte $72,$20,$61,$74,$74,$61,$63,$6b
	.byte $73,$20,$79,$6f,$75,$20,$61,$6e
	.byte $64,$f9,$6f,$75,$20,$61,$72,$65
	.byte $20,$68,$69,$73,$20,$6e,$65,$78
	.byte $74,$20,$6d,$65,$61,$6c,$21,$f4
	.byte $68,$65,$20,$6d,$61,$67,$69,$63
	.byte $20,$77,$6f,$72,$64,$20,$77,$6f
	.byte $72,$6b,$73,$21,$20,$79,$6f,$75
	.byte $20,$68,$61,$76,$65,$20,$65,$73
	.byte $63,$61,$70,$65,$64,$21,$c4,$6f
	.byte $20,$79,$6f,$75,$20,$77,$61,$6e
	.byte $74,$20,$74,$6f,$20,$70,$6c,$61
	.byte $79,$20,$61,$67,$61,$69,$6e,$20
	.byte $28,$59,$20,$6f,$72,$20,$4e,$29
	.byte $3f,$d9,$6f,$75,$20,$66,$61,$6c
	.byte $6c,$20,$74,$68,$72,$6f,$75,$67
	.byte $68,$20,$74,$68,$65,$20,$66,$6c
	.byte $6f,$6f,$72,$ef,$6e,$74,$6f,$20
	.byte $61,$20,$62,$65,$64,$20,$6f,$66
	.byte $20,$73,$70,$69,$6b,$65,$73,$21
	.byte $c2,$65,$66,$6f,$72,$65,$20,$49
	.byte $20,$6c,$65,$74,$20,$79,$6f,$75
	.byte $20,$67,$6f,$20,$66,$72,$65,$65
	.byte $f7,$68,$61,$74,$20,$77,$61,$73
	.byte $20,$74,$68,$65,$20,$6e,$61,$6d
	.byte $65,$20,$6f,$66,$20,$74,$68,$65
	.byte $20,$6d,$6f,$6e,$73,$74,$65,$72
	.byte $3f,$e9,$74,$20,$73,$61,$79,$73
	.byte $20,$22,$74,$68,$65,$20,$6d,$61
	.byte $67,$69,$63,$20,$77,$6f,$72,$64
	.byte $20,$69,$73,$20,$63,$61,$6d,$65
	.byte $6c,$6f,$74,$22,$2e,$d4,$68,$65
	.byte $20,$6d,$6f,$6e,$73,$74,$65,$72
	.byte $20,$67,$72,$61,$62,$73,$20,$74
	.byte $68,$65,$20,$66,$72,$69,$73,$62
	.byte $65,$65,$2c,$20,$74,$68,$72,$6f
	.byte $77,$73,$20,$e9,$74,$20,$62,$61
	.byte $63,$6b,$2c,$20,$61,$6e,$64,$20
	.byte $69,$74,$20,$73,$61,$77,$73,$20
	.byte $79,$6f,$75,$72,$20,$68,$65,$61
	.byte $64,$20,$6f,$66,$66,$21,$d4,$49
	.byte $43,$4b,$21,$20,$54,$49,$43,$4b
	.byte $21,$d4,$68,$65,$20,$6b,$65,$79
	.byte $20,$62,$6c,$6f,$77,$73,$20,$75
	.byte $70,$20,$74,$68,$65,$20,$77,$68
	.byte $6f,$6c,$65,$20,$6d,$61,$7a,$65
	.byte $21,$d4,$68,$65,$20,$67,$72,$6f
	.byte $75,$6e,$64,$20,$62,$65,$6e,$65
	.byte $61,$74,$68,$20,$79,$6f,$75,$72
	.byte $20,$66,$65,$65,$74,$e2,$65,$67
	.byte $69,$6e,$73,$20,$74,$6f,$20,$73
	.byte $68,$61,$6b,$65,$21,$c1,$20,$64
	.byte $69,$73,$67,$75,$73,$74,$69,$6e
	.byte $67,$20,$6f,$64,$6f,$72,$20,$70
	.byte $65,$72,$6d,$65,$61,$74,$65,$73
	.byte $f4,$68,$65,$20,$68,$61,$6c,$6c
	.byte $77,$61,$79,$20,$61,$73,$20,$69
	.byte $74,$20,$64,$61,$72,$6b,$65,$6e
	.byte $73,$21,$f4,$68,$65,$20,$68,$61
	.byte $6c,$6c,$77,$61,$79,$21,$c9,$74
	.byte $20,$69,$73,$20,$74,$68,$65,$20
	.byte $6d,$6f,$6e,$73,$74,$65,$72,$27
	.byte $73,$20,$6d,$6f,$74,$68,$65,$72
	.byte $21,$d3,$68,$65,$20,$68,$61,$73
	.byte $20,$62,$65,$65,$6e,$20,$73,$65
	.byte $64,$75,$63,$65,$64,$21,$d3,$68
	.byte $65,$20,$74,$69,$70,$74,$6f,$65
	.byte $73,$20,$75,$70,$20,$74,$6f,$20
	.byte $79,$6f,$75,$21,$d3,$68,$65,$20
	.byte $73,$6c,$61,$73,$68,$65,$73,$20
	.byte $79,$6f,$75,$20,$74,$6f,$20,$62
	.byte $69,$74,$73,$21,$d9,$6f,$75,$20
	.byte $73,$6c,$61,$73,$68,$20,$68,$65
	.byte $72,$20,$74,$6f,$20,$62,$69,$74
	.byte $73,$21,$c3,$6f,$72,$72,$65,$63
	.byte $74,$21,$20,$59,$6f,$75,$20,$68
	.byte $61,$76,$65,$20,$73,$75,$72,$76
	.byte $69,$76,$65,$64,$21,$d9,$6f,$75
	.byte $20,$62,$72,$65,$61,$6b,$20,$74
	.byte $68,$65,$e1,$6e,$64,$20,$69,$74
	.byte $20,$64,$69,$73,$61,$70,$70,$65
	.byte $61,$72,$73,$21,$d7,$68,$61,$74
	.byte $20,$61,$20,$6d,$65,$73,$73,$21
	.byte $20,$54,$68,$65,$20,$76,$61,$6d
	.byte $70,$69,$72,$65,$20,$62,$61,$74
	.byte $e4,$72,$69,$6e,$6b,$73,$20,$74
	.byte $68,$65,$20,$62,$6c,$6f,$6f,$64
	.byte $20,$61,$6e,$64,$20,$64,$69,$65
	.byte $73,$21,$c9,$74,$20,$76,$61,$6e
	.byte $69,$73,$68,$65,$73,$20,$69,$6e
	.byte $20,$61,$e2,$75,$72,$73,$74,$20
	.byte $6f,$66,$20,$66,$6c,$61,$6d,$65
	.byte $73,$21,$d9,$6f,$75,$20,$63,$61
	.byte $6e,$27,$74,$20,$62,$65,$20,$73
	.byte $65,$72,$69,$6f,$75,$73,$21,$d9
	.byte $6f,$75,$20,$61,$72,$65,$20,$6d
	.byte $61,$6b,$69,$6e,$67,$20,$6c,$69
	.byte $74,$74,$6c,$65,$20,$73,$65,$6e
	.byte $73,$65,$2e,$a0,$77,$68,$61,$74
	.byte $3f,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$e1,$6c,$6c,$20
	.byte $66,$6f,$72,$6d,$20,$69,$6e,$74
	.byte $6f,$20,$64,$61,$72,$74,$73,$21
	.byte $d4,$68,$65,$20,$66,$6f,$6f,$64
	.byte $20,$69,$73,$20,$62,$65,$69,$6e
	.byte $67,$20,$64,$69,$67,$65,$73,$74
	.byte $65,$64,$2e,$d4,$68,$65,$20,$ed
	.byte $61,$67,$69,$63,$61,$6c,$6c,$79
	.byte $20,$73,$61,$69,$6c,$73,$e1,$72
	.byte $6f,$75,$6e,$64,$20,$61,$20,$6e
	.byte $65,$61,$72,$62,$79,$20,$63,$6f
	.byte $72,$6e,$65,$72,$e1,$6e,$64,$20
	.byte $69,$73,$20,$65,$61,$74,$65,$6e
	.byte $20,$62,$79,$f4,$68,$65,$20,$6d
	.byte $6f,$6e,$73,$74,$65,$72,$20,$21
	.byte $21,$21,$21,$e1,$6e,$64,$20,$74
	.byte $68,$65,$20,$6d,$6f,$6e,$73,$74
	.byte $65,$72,$20,$67,$72,$61,$62,$73
	.byte $20,$69,$74,$2c,$e7,$65,$74,$73
	.byte $20,$74,$61,$6e,$67,$6c,$65,$64
	.byte $2c,$20,$61,$6e,$64,$20,$74,$6f
	.byte $70,$70,$6c,$65,$73,$20,$6f,$76
	.byte $65,$72,$21,$c9,$74,$20,$69,$73
	.byte $20,$6e,$6f,$77,$20,$66,$75,$6c
	.byte $6c,$20,$6f,$66,$20,$62,$6c,$6f
	.byte $6f,$64,$2e,$d4,$68,$65,$20,$6d
	.byte $6f,$6e,$73,$74,$65,$72,$20,$69
	.byte $73,$20,$64,$65,$61,$64,$20,$61
	.byte $6e,$64,$ed,$75,$63,$68,$20,$62
	.byte $6c,$6f,$6f,$64,$20,$69,$73,$20
	.byte $73,$70,$69,$6c,$74,$21,$d9,$6f
	.byte $75,$20,$68,$61,$76,$65,$20,$6b
	.byte $69,$6c,$6c,$65,$64,$20,$69,$74
	.byte $2e,$d4,$68,$65,$20,$64,$61,$67
	.byte $67,$65,$72,$20,$64,$69,$73,$61
	.byte $70,$70,$65,$61,$72,$73,$21,$d4
	.byte $68,$65,$20,$74,$6f,$72,$63,$68
	.byte $20,$69,$73,$20,$6c,$69,$74,$20
	.byte $61,$6e,$64,$20,$74,$68,$65,$ef
	.byte $6c,$64,$20,$74,$6f,$72,$63,$68
	.byte $20,$64,$69,$65,$73,$20,$61,$6e
	.byte $64,$20,$76,$61,$6e,$69,$73,$68
	.byte $65,$73,$21,$c1,$20,$63,$6c,$6f
	.byte $73,$65,$20,$69,$6e,$73,$70,$65
	.byte $63,$74,$69,$6f,$6e,$20,$72,$65
	.byte $76,$65,$61,$6c,$73,$e1,$62,$73
	.byte $6f,$6c,$75,$74,$65,$6c,$79,$20
	.byte $6e,$6f,$74,$68,$69,$6e,$67,$20
	.byte $6f,$66,$20,$76,$61,$6c,$75,$65
	.byte $21,$e1,$20,$73,$6d,$75,$64,$67
	.byte $65,$64,$20,$64,$69,$73,$70,$6c
	.byte $61,$79,$21,$c1,$20,$63,$61,$6e
	.byte $20,$6f,$66,$20,$73,$70,$69,$6e
	.byte $61,$63,$68,$3f,$f2,$65,$74,$75
	.byte $72,$6e,$73,$20,$61,$6e,$64,$20
	.byte $68,$69,$74,$73,$20,$79,$6f,$75
	.byte $e9,$6e,$20,$74,$68,$65,$20,$65
	.byte $79,$65,$21,$d9,$6f,$75,$20,$61
	.byte $72,$65,$20,$74,$72,$61,$70,$70
	.byte $65,$64,$20,$69,$6e,$20,$61,$20
	.byte $66,$61,$6b,$65,$e5,$6c,$65,$76
	.byte $61,$74,$6f,$72,$2e,$20,$54,$68
	.byte $65,$72,$65,$20,$69,$73,$20,$6e
	.byte $6f,$20,$65,$73,$63,$61,$70,$65
	.byte $21,$d7,$69,$74,$68,$20,$77,$68
	.byte $61,$74,$3f,$20,$54,$6f,$65,$6e
	.byte $61,$69,$6c,$20,$70,$6f,$6c,$69
	.byte $73,$68,$3f,$c1,$20,$64,$72,$61
	.byte $66,$74,$20,$62,$6c,$6f,$77,$73
	.byte $20,$79,$6f,$75,$72,$20,$74,$6f
	.byte $72,$63,$68,$20,$6f,$75,$74,$21
	.byte $d4,$68,$65,$20,$72,$69,$6e,$67
	.byte $20,$69,$73,$20,$61,$63,$74,$69
	.byte $76,$61,$74,$65,$64,$20,$61,$6e
	.byte $64,$f3,$68,$69,$6e,$65,$73,$20
	.byte $6c,$69,$67,$68,$74,$20,$65,$76
	.byte $65,$72,$79,$77,$68,$65,$72,$65
	.byte $21,$d4,$68,$65,$20,$73,$74,$61
	.byte $66,$66,$20,$62,$65,$67,$69,$6e
	.byte $73,$20,$74,$6f,$20,$71,$75,$61
	.byte $6b,$65,$21,$d4,$68,$65,$20,$63
	.byte $61,$6c,$63,$75,$6c,$61,$74,$6f
	.byte $72,$20,$76,$61,$6e,$69,$73,$68
	.byte $65,$73,$2e,$ce,$45,$56,$45,$52
	.byte $2c,$20,$45,$56,$45,$52,$20,$72
	.byte $61,$69,$64,$20,$61,$20,$6d,$6f
	.byte $6e,$73,$74,$65,$72,$27,$73,$20
	.byte $6c,$61,$69,$72,$2e,$cf,$4b,$2e
	.byte $2e,$2e,$e8,$61,$73,$20,$76,$61
	.byte $6e,$69,$73,$68,$65,$64,$2e,$d4
	.byte $68,$65,$20,$62,$6f,$64,$79,$20
	.byte $68,$61,$73,$20,$76,$61,$6e,$69
	.byte $73,$68,$65,$64,$21,$c7,$4c,$49
	.byte $54,$43,$48,$21,$cf,$4b,$2e,$2e
	.byte $2e,$69,$74,$20,$69,$73,$20,$63
	.byte $6c,$65,$61,$6e,$2e,$c3,$68,$65
	.byte $63,$6b,$20,$79,$6f,$75,$72,$20
	.byte $69,$6e,$76,$65,$6e,$74,$6f,$72
	.byte $79,$2c,$20,$44,$4f,$4c,$54,$21
	.byte $d3,$50,$4c,$41,$54,$21,$d9,$6f
	.byte $75,$20,$65,$61,$74,$20,$74,$68
	.byte $65,$e1,$6e,$64,$20,$79,$6f,$75
	.byte $20,$67,$65,$74,$20,$68,$65,$61
	.byte $72,$74,$62,$75,$72,$6e,$21,$c1
	.byte $20,$64,$65,$61,$66,$65,$6e,$69
	.byte $6e,$67,$20,$72,$6f,$61,$72,$20
	.byte $65,$6e,$76,$65,$6c,$6f,$70,$65
	.byte $73,$f9,$6f,$75,$2e,$20,$59,$6f
	.byte $75,$72,$20,$65,$61,$72,$73,$20
	.byte $61,$72,$65,$20,$72,$69,$6e,$67
	.byte $69,$6e,$67,$21,$c6,$4f,$4f,$44
	.byte $20,$46,$49,$47,$48,$54,$21,$21
	.byte $20,$46,$4f,$4f,$44,$20,$46,$49
	.byte $47,$48,$54,$21,$21,$d4,$68,$65
	.byte $20,$68,$61,$6c,$6c,$77,$61,$79
	.byte $20,$69,$73,$20,$74,$6f,$6f,$20
	.byte $63,$72,$6f,$77,$64,$65,$64,$2e
	.byte $c1,$20,$68,$69,$67,$68,$20,$73
	.byte $68,$72,$69,$6c,$6c,$20,$6e,$6f
	.byte $74,$65,$20,$63,$6f,$6d,$65,$73
	.byte $e6,$72,$6f,$6d,$20,$74,$68,$65
	.byte $20,$66,$6c,$75,$74,$65,$21,$d4
	.byte $68,$65,$20,$63,$61,$6c,$63,$75
	.byte $6c,$61,$74,$6f,$72,$20,$64,$69
	.byte $73,$70,$6c,$61,$79,$73,$d9,$6f
	.byte $75,$20,$68,$61,$76,$65,$20,$62
	.byte $65,$65,$6e,$20,$74,$65,$6c,$65
	.byte $70,$6f,$72,$74,$65,$64,$21,$d7
	.byte $69,$74,$68,$20,$77,$68,$6f,$3f
	.byte $20,$54,$68,$65,$20,$6d,$6f,$6e
	.byte $73,$74,$65,$72,$3f,$d9,$6f,$75
	.byte $20,$68,$61,$76,$65,$20,$6e,$6f
	.byte $20,$66,$69,$72,$65,$2e,$d7,$69
	.byte $74,$68,$20,$77,$68,$61,$74,$3f
	.byte $20,$41,$69,$72,$3f,$c9,$74,$27
	.byte $73,$20,$61,$77,$66,$75,$6c,$6c
	.byte $79,$20,$64,$61,$72,$6b,$2e,$cc
	.byte $6f,$6f,$6b,$20,$61,$74,$20,$79
	.byte $6f,$75,$72,$20,$6d,$6f,$6e,$69
	.byte $74,$6f,$72,$2e,$c9,$74,$20,$6c
	.byte $6f,$6f,$6b,$73,$20,$76,$65,$72
	.byte $79,$20,$64,$61,$6e,$67,$65,$72
	.byte $6f,$75,$73,$21,$c9,$27,$6d,$20
	.byte $73,$6f,$72,$72,$79,$2c,$20,$62
	.byte $75,$74,$20,$49,$20,$63,$61,$6e
	.byte $27,$74,$20,$d9,$6f,$75,$20,$61
	.byte $72,$65,$20,$63,$6f,$6e,$66,$75
	.byte $73,$69,$6e,$67,$20,$6d,$65,$2e
	.byte $d7,$68,$61,$74,$20,$69,$6e,$20
	.byte $74,$61,$72,$6e,$61,$74,$69,$6f
	.byte $6e,$20,$69,$73,$20,$61,$20,$c9
	.byte $20,$64,$6f,$6e,$27,$74,$20,$73
	.byte $65,$65,$20,$74,$68,$61,$74,$20
	.byte $68,$65,$72,$65,$2e,$cf,$4b,$2e
	.byte $2e,$2e,$69,$66,$20,$79,$6f,$75
	.byte $20,$72,$65,$61,$6c,$6c,$79,$20
	.byte $77,$61,$6e,$74,$20,$74,$6f,$2c
	.byte $c2,$75,$74,$20,$79,$6f,$75,$20
	.byte $68,$61,$76,$65,$20,$6e,$6f,$20
	.byte $6b,$65,$79,$2e,$c4,$6f,$20,$79
	.byte $6f,$75,$20,$77,$69,$73,$68,$20
	.byte $74,$6f,$20,$73,$61,$76,$65,$20
	.byte $74,$68,$65,$20,$67,$61,$6d,$65
	.byte $20,$28,$59,$20,$6f,$72,$20,$4e
	.byte $29,$3f,$c4,$6f,$20,$79,$6f,$75
	.byte $20,$77,$69,$73,$68,$20,$74,$6f
	.byte $20,$63,$6f,$6e,$74,$69,$6e,$75
	.byte $65,$20,$61,$20,$67,$61,$6d,$65
	.byte $20,$28,$59,$20,$6f,$72,$20,$4e
	.byte $29,$3f,$d0,$6c,$65,$61,$73,$65
	.byte $20,$70,$72,$65,$70,$61,$72,$65
	.byte $20,$79,$6f,$75,$72,$20,$63,$61
	.byte $73,$73,$65,$74,$74,$65,$2e,$d7
	.byte $68,$65,$6e,$20,$72,$65,$61,$64
	.byte $79,$2c,$20,$70,$72,$65,$73,$73
	.byte $20,$61,$6e,$79,$20,$6b,$65,$79
	.byte $2e,$e1,$6e,$64,$20,$69,$74,$20
	.byte $76,$61,$6e,$69,$73,$68,$65,$73
	.byte $21,$d9,$6f,$75,$20,$77,$69,$6c
	.byte $6c,$20,$64,$6f,$20,$6e,$6f,$20
	.byte $73,$75,$63,$68,$20,$74,$68,$69
	.byte $6e,$67,$21,$d9,$6f,$75,$20,$61
	.byte $72,$65,$20,$63,$61,$72,$72,$79
	.byte $69,$6e,$67,$20,$74,$68,$65,$20
	.byte $6c,$69,$6d,$69,$74,$2e,$c9,$74
	.byte $20,$69,$73,$20,$63,$75,$72,$72
	.byte $65,$6e,$74,$6c,$79,$20,$69,$6d
	.byte $70,$6f,$73,$73,$69,$62,$6c,$65
	.byte $2e,$d4,$68,$65,$20,$62,$61,$74
	.byte $20,$64,$72,$61,$69,$6e,$73,$20
	.byte $79,$6f,$75,$20,$6f,$66,$20,$79
	.byte $6f,$75,$72,$20,$76,$69,$74,$61
	.byte $6c,$20,$66,$6c,$75,$69,$64,$73
	.byte $21,$c1,$72,$65,$20,$79,$6f,$75
	.byte $20,$73,$75,$72,$65,$20,$79,$6f
	.byte $75,$20,$77,$61,$6e,$74,$20,$74
	.byte $6f,$20,$71,$75,$69,$74,$20,$28
	.byte $59,$20,$6f,$72,$20,$4e,$29,$3f
	.byte $d4,$72,$79,$20,$65,$78,$61,$6d
	.byte $69,$6e,$69,$6e,$67,$20,$74,$68
	.byte $69,$6e,$67,$73,$2e,$d4,$79,$70
	.byte $65,$20,$69,$6e,$73,$74,$72,$75
	.byte $63,$74,$69,$6f,$6e,$73,$2e,$c9
	.byte $6e,$76,$65,$72,$74,$20,$61,$6e
	.byte $64,$20,$74,$65,$6c,$65,$70,$68
	.byte $6f,$6e,$65,$2e,$c4,$6f,$6e,$27
	.byte $74,$20,$6d,$61,$6b,$65,$20,$75
	.byte $6e,$6e,$65,$63,$65,$73,$73,$61
	.byte $72,$79,$20,$74,$75,$72,$6e,$73
	.byte $2e,$d9,$6f,$75,$20,$68,$61,$76
	.byte $65,$20,$74,$75,$72,$6e,$65,$64
	.byte $20,$69,$6e,$74,$6f,$20,$61,$20
	.byte $70,$69,$6c,$6c,$61,$72,$20,$6f
	.byte $66,$20,$73,$61,$6c,$74,$21,$c4
	.byte $6f,$6e,$27,$74,$20,$73,$61,$79
	.byte $20,$49,$20,$64,$69,$64,$6e,$27
	.byte $74,$20,$77,$61,$72,$6e,$20,$79
	.byte $6f,$75,$21,$d4,$68,$65,$20,$65
	.byte $6c,$65,$76,$61,$74,$6f,$72,$20
	.byte $69,$73,$20,$6d,$6f,$76,$69,$6e
	.byte $67,$21,$d9,$6f,$75,$20,$61,$72
	.byte $65,$20,$64,$65,$70,$6f,$73,$69
	.byte $74,$65,$64,$20,$61,$74,$20,$74
	.byte $68,$65,$20,$6e,$65,$78,$74,$20
	.byte $6c,$65,$76,$65,$6c,$2e,$d9,$6f
	.byte $75,$72,$20,$68,$65,$61,$64,$20
	.byte $73,$6d,$61,$73,$68,$65,$73,$20
	.byte $69,$6e,$74,$6f,$20,$74,$68,$65
	.byte $20,$63,$65,$69,$6c,$69,$6e,$67
	.byte $21,$d9,$6f,$75,$20,$66,$61,$6c
	.byte $6c,$20,$6f,$6e,$20,$74,$68,$65
	.byte $20,$73,$6e,$61,$6b,$65,$21,$cf
	.byte $68,$20,$6e,$6f,$21,$20,$41,$20
	.byte $70,$69,$74,$21,$ff,$46,$45,$d2
	.byte $85,$59,$20,$53,$54,$41,$20,$2a
	.byte $c8,$90,$20,$20,$20,$41,$49,$56
	.byte $20,$44,$45,$59,$41,$4c,$50,$53
	.byte $49,$44,$20,$59,$4c,$54,$4e,$41
	.byte $54,$53,$4e,$4f,$43,$20,$53,$49
	.byte $20,$4e,$4f,$49,$08,$08,$08,$08
	.byte $20,$4e,$4f,$49,$54,$41,$43,$4f
	.byte $0c,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$30
	.byte $30,$30,$30,$35,$20,$45,$5a,$08
	.byte $58,$41,$4d,$54,$41,$45,$04,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$25,$60,$47,$52,$45,$4e
	.byte $20,$44,$45,$43,$20,$2a,$c8,$30
	.byte $60,$20,$42,$4e,$45,$20,$47,$4f
	.byte $4f,$4e,$36,$b8,$35,$60,$20,$4a
	.byte $4d,$50,$20,$55,$4e,$43,$4f,$4d
	.byte $d0,$40,$60,$47,$4f,$4f,$4e,$36
	.byte $38,$20,$44,$45,$43,$20,$2a,$c8
	.byte $45,$60,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$44,$65,$61
	.byte $74,$68,$6d,$61,$7a,$65,$20,$35
	.byte $30,$30,$30,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$4c,$6f,$63,$61,$74
	.byte $69,$6f,$6e,$20,$69,$73,$20,$63
	.byte $6f,$6e,$73,$74,$61,$6e,$74,$6c
	.byte $79,$20,$64,$69,$73,$70,$6c,$61
	.byte $79,$65,$64,$20,$76,$69,$61,$20
	.byte $20,$20,$33,$2d,$44,$20,$67,$72
	.byte $61,$70,$68,$69,$63,$73,$2e,$20
	.byte $54,$6f,$20,$6d,$6f,$76,$65,$20
	.byte $66,$6f,$72,$77,$61,$72,$64,$20
	.byte $6f,$6e,$65,$20,$73,$74,$65,$70
	.byte $2c,$20,$70,$72,$65,$73,$73,$20
	.byte $5a,$2e,$20,$54,$6f,$20,$74,$75
	.byte $72,$6e,$20,$74,$6f,$20,$74,$68
	.byte $65,$20,$6c,$65,$66,$74,$20,$6f
	.byte $72,$20,$72,$69,$67,$68,$74,$2c
	.byte $20,$20,$70,$72,$65,$73,$73,$20
	.byte $74,$68,$65,$20,$6c,$65,$66,$74
	.byte $20,$6f,$72,$20,$72,$69,$67,$68
	.byte $74,$20,$61,$72,$72,$6f,$77,$2e
	.byte $20,$54,$6f,$20,$74,$75,$72,$6e
	.byte $20,$20,$61,$72,$6f,$75,$6e,$64
	.byte $2c,$20,$70,$72,$65,$73,$73,$20
	.byte $58,$2e,$20,$4f,$6e,$6c,$79,$20
	.byte $5a,$20,$61,$63,$74,$75,$61,$6c
	.byte $6c,$79,$20,$63,$68,$61,$6e,$67
	.byte $65,$73,$79,$6f,$75,$72,$20,$70
	.byte $6f,$73,$69,$74,$69,$6f,$6e,$2e
	.byte $20,$41,$64,$64,$69,$74,$69,$6f
	.byte $6e,$61,$6c,$6c,$79,$2c,$20,$77
	.byte $6f,$72,$64,$73,$20,$73,$75,$63
	.byte $68,$20,$61,$73,$20,$43,$48,$41
	.byte $52,$47,$45,$20,$6d,$61,$79,$20
	.byte $62,$65,$20,$68,$65,$6c,$70,$66
	.byte $75,$6c,$20,$69,$6e,$20,$6d,$6f
	.byte $76,$65,$6d,$65,$6e,$74,$2e,$20
	.byte $20,$20,$20,$41,$74,$20,$61,$6e
	.byte $79,$20,$74,$69,$6d,$65,$2c,$20
	.byte $6f,$6e,$65,$20,$61,$6e,$64,$20
	.byte $74,$77,$6f,$20,$77,$6f,$72,$64
	.byte $20,$63,$6f,$6d,$6d,$61,$6e,$64
	.byte $73,$20,$6d,$61,$79,$20,$62,$65
	.byte $20,$65,$6e,$74,$65,$72,$65,$64
	.byte $2e,$20,$53,$6f,$6d,$65,$20,$75
	.byte $73,$65,$66,$75,$6c,$20,$63,$6f
	.byte $6d,$6d,$61,$6e,$64,$73,$20,$61
	.byte $72,$65,$4f,$50,$45,$4e,$20,$42
	.byte $4f,$58,$2c,$20,$47,$45,$54,$20
	.byte $42,$4f,$58,$2c,$20,$44,$52,$4f
	.byte $50,$20,$61,$6e,$64,$20,$48,$45
	.byte $4c,$50,$2e,$20,$4d,$61,$6e,$79
	.byte $20,$20,$6d,$6f,$72,$65,$20,$65
	.byte $78,$69,$73,$74,$2e,$20,$54,$6f
	.byte $20,$6d,$61,$6e,$69,$70,$75,$6c
	.byte $61,$74,$65,$20,$61,$6e,$20,$6f
	.byte $62,$6a,$65,$63,$74,$2c,$20,$79
	.byte $6f,$75,$6d,$75,$73,$74,$20,$62
	.byte $65,$20,$6f,$6e,$20,$74,$6f,$70
	.byte $20,$6f,$66,$20,$69,$74,$2c,$20
	.byte $6f,$72,$20,$62,$65,$20,$63,$61
	.byte $72,$72,$79,$69,$6e,$67,$20,$69
	.byte $74,$2e,$20,$54,$6f,$20,$73,$61
	.byte $76,$65,$20,$61,$20,$67,$61,$6d
	.byte $65,$20,$69,$6e,$20,$70,$72,$6f
	.byte $67,$72,$65,$73,$73,$2c,$20,$65
	.byte $6e,$74,$65,$72,$20,$53,$41,$56
	.byte $45,$2e,$54,$68,$69,$73,$20,$69
	.byte $73,$20,$65,$6e,$63,$6f,$75,$72
	.byte $61,$67,$65,$64,$2e,$20,$44,$65
	.byte $61,$74,$68,$6d,$61,$7a,$65,$20
	.byte $69,$73,$20,$68,$75,$67,$65,$2e
	.byte $20,$20,$49,$74,$20,$77,$69,$6c
	.byte $6c,$20,$74,$61,$6b,$65,$20,$73
	.byte $6f,$6d,$65,$20,$74,$69,$6d,$65
	.byte $20,$74,$6f,$20,$65,$73,$63,$61
	.byte $70,$65,$2e,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$54,$68,$65,$20,$66
	.byte $69,$76,$65,$20,$6c,$65,$76,$65
	.byte $6c,$73,$20,$6f,$66,$20,$44,$65
	.byte $61,$74,$68,$6d,$61,$7a,$65,$20
	.byte $61,$72,$65,$20,$63,$6f,$6e,$2d
	.byte $20,$20,$6e,$65,$63,$74,$65,$64
	.byte $20,$62,$79,$20,$65,$6c,$65,$76
	.byte $61,$74,$6f,$72,$73,$2c,$20,$70
	.byte $69,$74,$73,$2c,$20,$61,$6e,$64
	.byte $20,$73,$63,$69,$65,$6e,$63,$65
	.byte $2e,$20,$43,$6f,$6e,$6e,$65,$63
	.byte $74,$69,$6f,$6e,$73,$20,$61,$72
	.byte $65,$20,$6e,$6f,$74,$20,$61,$6c
	.byte $77,$61,$79,$73,$20,$6f,$62,$76
	.byte $69,$6f,$75,$73,$2e,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$47
	.byte $6f,$6f,$64,$20,$4c,$75,$63,$6b
	.byte $21,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$43,$6f,$70,$79,$72,$69
	.byte $67,$68,$74,$20,$31,$39,$38,$30
	.byte $20,$62,$79,$20,$4d,$65,$64,$20
	.byte $53,$79,$73,$74,$65,$6d,$73,$20
	.byte $53,$6f,$66,$74,$77,$61,$72,$65
	.byte $20,$20,$41,$6c,$6c,$20,$72,$69
	.byte $67,$68,$74,$73,$20,$72,$65,$73
	.byte $65,$72,$76,$65,$64,$2e,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20
	.byte $a0,$80,$52,$54,$d3,$70,$64,$55
	.byte $4e,$20,$44,$45,$43,$20,$49,$59
	.byte $b2,$75,$64,$20,$52,$54,$d3,$80
	.byte $64,$44,$45,$55,$58,$20,$49,$4e
	.byte $43,$20,$49,$59,$b3,$85,$64,$20
	.byte $52,$54,$d3,$90,$64,$54,$52,$4f
	.byte $49,$53,$20,$49,$4e,$43,$20,$49
	.byte $59,$b2,$95,$64,$20,$52,$54,$d3
	.byte $00,$65,$4a,$55,$4b,$49,$4c,$4c
	.byte $20,$4a,$53,$52,$20,$44,$52,$41
	.byte $d7,$05,$65,$20,$4a,$53,$52,$20
	.byte $54,$49,$4d,$45,$b1,$10,$65,$20
	.byte $4a,$53,$52,$20,$57,$48,$49,$54
	.byte $c5,$15,$65,$20,$4a,$53,$52,$20
	.byte $43,$4c,$52,$57,$4e,$c4,$20,$65
	.byte $20,$4c,$44,$41,$20,$23,$34,$b2
	.byte $25,$65,$20,$4a,$53,$52,$20,$50
	.byte $4f,$49,$4e,$d4,$30,$65,$20,$4c
	.byte $44,$41,$20,$23,$34,$b3,$35,$65
	.byte $20,$4a,$53,$52,$20,$50,$4f,$49
	.byte $4e,$54,$b5,$40,$65,$20,$4a,$4d
	.byte $50,$20,$53,$61,$76,$65,$20,$74
	.byte $6f,$20,$44,$49,$53,$4b,$20,$6f
	.byte $72,$20,$54,$41,$50,$45,$20,$28
	.byte $54,$20,$6f,$72,$20,$44,$29,$3f
	.byte $80,$c7,$65,$74,$20,$66,$72,$6f
	.byte $6d,$20,$44,$49,$53,$4b,$20,$6f
	.byte $72,$20,$54,$41,$50,$45,$20,$28
	.byte $54,$20,$6f,$72,$20,$44,$29,$3f
	.byte $80,$20,$55,$08,$a2,$00,$86,$06
	.byte $86,$07,$a2,$1f,$86,$0c,$a2,$7c
	.byte $86,$0d
p5C50:
	.byte $20,$e5,$08,$20
p5C54:
	.byte $94,$7c,$c9,$44,$d0,$03,$4c,$0c
	.byte $7d,$20,$55,$08,$a9
p5C61:
	.byte $95,$20,$92,$08,$60,$20,$55,$08
	.byte $a2,$00,$86,$06,$86,$07,$a2,$00
	.byte $86,$0c,$a2,$7c,$86,$0d,$20,$e5
	.byte $08,$20,$94,$7c,$c9,$54,$f0,$03
	.byte $4c,$ef,$7c,$20,$55,$08,$20,$15
	.byte $10,$a2,$07,$86,$0f,$20,$34,$1a
	.byte $4c,$bc,$31,$2c,$10,$c0,$20,$43
	.byte $12,$2c,$00,$c0,$10,$f8,$ad,$00
	.byte $c0,$29,$7f,$c9,$54,$f0,$04,$c9
	.byte $44,$d0,$e8,$48,$20,$6e,$12,$68
	.byte $60,$00,$01,$ef,$d8,$01,$60,$01
	.byte $00,$03,$00,$00,$3f,$93,$61,$00
	.byte $00,$01,$00,$00,$60,$01,$d0,$6c
	.byte $61,$63,$65,$20,$64,$61,$74,$61
	.byte $20,$64,$69,$73,$6b,$65,$74,$74
	.byte $65,$20,$69,$6e,$20,$44,$52,$49
	.byte $56,$45,$20,$31,$2c,$20,$53,$4c
	.byte $4f,$54,$20,$36,$2e,$80,$a2,$02
	.byte $8e,$c2,$7c,$20,$4f,$7d,$90,$06
	.byte $20,$74,$7d,$4c,$23,$7e,$20,$55
	.byte $08,$20,$15,$10
p5D05:
	.byte $a2,$07,$86,$0f,$4c,$34,$1a,$a2
	.byte $01,$8e,$c2,$7c,$20,$4f,$7d,$90
	.byte $06,$20,$74,$7d,$4c,$1d,$7e,$a0
	.byte $00,$b9,$00,$62,$c9,$44,$d0,$25
	.byte $c8,$b9,$00,$62,$c9,$45,$d0,$1d
	.byte $c8,$b9,$00,$62,$c9,$41,$d0,$15
	.byte $c8,$b9,$00,$62,$c9,$54,$d0,$0d
	.byte $c8,$b9,$00,$62,$c9,$48,$d0,$05
	.byte $68,$68,$4c,$4a,$08,$a9,$05,$4c
	.byte $1d,$7e,$a9,$0a,$20,$92,$11,$a2
	.byte $c7,$86,$0c,$a2,$7c,$86,$0d,$20
	.byte $e5,$08,$a9,$0a,$20,$92,$11,$a9
	.byte $96,$20,$e2,$08,$20,$e9,$0f,$a9
	.byte $7c,$a0,$b6,$20,$d9,$03,$60,$ad
	.byte $c3,$7c,$c9,$10,$d0,$03,$a9,$01
	.byte $60,$c9,$20,$d0,$03,$a9,$02,$60
	.byte $c9,$40,$d0,$03,$a9,$03,$60,$a9
	.byte $04,$60,$44,$49,$53,$4b,$45,$54
	.byte $54,$45,$20,$57,$52,$49,$54,$45
	.byte $20,$50,$52,$4f,$54,$45,$43,$54
	.byte $45,$44,$21,$80,$56,$4f,$4c,$55
	.byte $4d,$45
p5DAF:
	.byte $20,$4d,$49,$53,$4d
p5DB4:
	.byte $41,$54,$43,$48,$21,$80,$44,$52
	.byte $49,$56,$45,$20,$45,$52,$52,$4f
	.byte $52,$21,$20,$43,$41,$55,$53,$45
	.byte $20,$55,$4e,$4b,$4e,$4f,$57,$4e
	.byte $21,$80,$52,$45,$41,$44,$20,$45
	.byte $52,$52,$4f,$52,$21,$20,$43,$48
	.byte $45,$43,$4b,$20,$59,$4f,$55,$52
	.byte $20,$44,$49,$53,$4b,$45,$54,$54
	.byte $45,$21,$80,$4e,$4f,$54,$20,$41
	.byte $20,$44,$45,$41,$54,$48,$4d,$41
	.byte $5a,$45,$20,$46,$49,$4c,$45,$21
	.byte $20,$49,$4e,$50,$55,$54,$20,$52
	.byte $45,$4a,$45,$43,$54,$45,$44,$21
	.byte $80,$a2,$00,$86,$10,$f0,$04,$a2
	.byte $ff,$86,$10,$a8,$88,$d0,$02,$f0
	.byte $17,$88,$d0,$04,$a0,$1a,$d0,$10
	.byte $88,$d0,$04,$a0,$2b,$d0,$09,$88
	.byte $d0,$04,$a0,$47,$d0,$02,$a0,$68
	.byte $84,$19,$a2,$00,$86,$1a,$a2,$8f
	.byte $86,$0c,$a2
p5E4F:
	.byte $7d
p5E50:
	.byte $86,$0d,$18,$a5,$19,$65
p5E56:
	.byte $0c,$85,$0c,$a5,$1a,$65,$0d,$85
	.byte $0d,$a9,$0a,$20,$92,$11,$20
p5E65:
	.byte $e5,$08,$20,$e9,$0f,$a5,$10,$f0
	.byte $03,$4c,$ff,$7c,$68,$68,$4c,$05
	.byte $08,$ad,$a5,$61,$d0,$06,$a2,$06
	.byte $8e,$a5,$61,$60,$06,$a9,$04,$85
	.byte $07,$a9,$03,$a0,$0d,$20,$a7,$17
	.byte $a9,$42,$85,$09,$a9,$11,$85,$08
	.byte $a0,$04,$20,$77,$17,$a9,$5c,$85
	.byte $09,$a9,$61,$85,$08,$a0,$04,$20
	.byte $77,$17,$a9,$16,$85,$06,$a9
p5EAC:
	.byte $00,$85,$07
p5EAF:
	.byte $a9,$03,$a0,$15,$20,$a7,$17
p5EB6:
	.byte $4c,$e8,$16,$68,$48,$c9,$01,$d0
	.byte $0f,$a9,$12,$85,$06,$a9,$04,$85
	.byte $07,$a9,$03,$a0,$0d,$20,$a7,$17
	.byte $a9,$15,$85,$06,$a9,$00,$85,$07
	.byte $a0,$04,$20,$7f,$17,$a9,$12,$85
	.byte $06,$a9,$11,$85,$07,$a0,$04,$20
	.byte $95,$17,$68,$c9,$00,$f0,$5f,$ad
	.byte $99,$61,$29,$01,$d0,$27,$a9,$00
	.byte $85,$06,$85,$07,$a9,$04,$a0,$15
	.byte $20,$a7,$17,$a9,$3f,$85,$09,$a9
	.byte $ff,$85,$08,$a0,$01,$20,$77,$17
	.byte $a9,$5e,$85,$09,$a9,$4f,$85,$08
	.byte $a0,$01,$20,$77,$17,$ad,$9a,$61
	.byte $29,$01,$d0,$29,$a9,$16,$85,$06
	.byte $a9,$00,$85,$07,$a9,$03,$a0,$15
	.byte $20,$a7,$17,$a9,$40,$85,$09,$a9
	.byte $15,$85,$08,$a0,$01,$20,$77,$17
	.byte $a9,$5e,$85,$09,$a9,$65,$85,$08
	.byte $a0,$01,$20,$77,$17,$60,$ad,$99
	.byte $61,$29,$01,$f0,$0d,$a9,$00,$85
	.byte $06,$85,$07,$a9,$04,$a0,$15,$20
	.byte $a7,$17,$ad,$9a,$61,$29,$01,$f0
	.byte $e4,$a9,$16,$85,$06,$a9,$00,$85
	.byte $07,$a9,$03,$a0,$15,$20,$a7,$17
	.byte $60,$a9,$ff,$91,$08,$88,$d0,$fb
	.byte $60,$98,$85,$1a,$20,$ef,$11,$a9
	.byte $02,$20,$92,$11,$c6,$06,$c6,$06
	.byte $e6,$07,$c6,$1a,$d0,$ee,$60,$98
	.byte $85,$1a,$20,$ef,$11,$a9,$01,$20
	.byte $92,$11,$e6,$07,$c6,$1a,$d0,$f2
	.byte $60,$48,$98,$85,$1a,$68,$48,$20
	.byte $ef,$11,$68,$48,$20,$a4,$11,$68
	.byte $c6,$06,$e6,$07,$c6,$1a,$d0,$ee
	.byte $60,$a0,$00,$a9,$00,$85,$0a,$a9
	.byte $60,$85,$0b,$ae,$94,$61,$a9,$00
	.byte $18,$ca,$f0,$05,$69,$21,$4c,$cf
	.byte $17,$65,$0a,$85,$0a,$ae,$95,$61
	.byte $ca,$f0,$09,$e6,$0a,$e6,$0a,$e6
	.byte $0a,$4c,$de,$17,$ad,$96,$61,$c9
	.byte $05,$30,$0e,$c9,$09,$30,$05,$e6
	.byte $0a,$38,$e9,$04,$e6,$0a,$38,$e9
	.byte $04,$00
p6000:
	.byte $d5,$7d,$57,$a6,$95,$d3,$b6,$56
	.byte $9c,$a5,$da,$48,$96,$13,$6f,$cb
	.byte $94,$af,$b8,$57,$2f,$a9,$da,$6f
	.byte $a3,$49,$2f,$94,$95,$0f,$ff,$ff
	.byte $ff,$df,$77,$5f,$c8,$aa,$cf,$9d
	.byte $1a,$df,$cd,$4a,$6f,$9b,$68,$8f
	.byte $a2,$a4,$df,$96,$96,$af,$d8,$4e
	.byte $cf,$b7,$76,$9f,$88,$88,$4f,$ff
	.byte $ff,$ff,$d5,$d5,$7f,$9c,$bd,$af
	.byte $cb,$a2,$9f,$99,$b6,$2f,$cd,$99
	.byte $2f,$a2,$55,$af,$b5,$5a,$bf,$8d
	.byte $e2,$6f,$a2,$37,$2f,$95,$54,$4f
	.byte $ff,$ff,$ff,$d7,$f7,$7f,$b2,$66
	.byte $af,$a5,$28,$af,$97,$0c,$8f,$c8
	.byte $bb,$df,$9b,$22,$2f,$ea,$d9,$6f
	.byte $92,$2d,$af,$d3,$22,$2f,$94,$55
	.byte $4f,$ff,$ff,$ff,$d7,$55,$df,$9a
	.byte $cc,$4f,$da,$b9,$5f,$a0,$f6,$6f
	.byte $b1,$9b,$2f,$ac,$e0,$6f,$bd,$9d
	.byte $af,$aa,$4a,$af,$a2,$52,$2f,$9c
	.byte $9d,$07,$ff,$ff,$ff
p60A5:
	.byte $42,$34,$05,$01,$42,$35,$05,$02
	.byte $42,$36,$05,$00,$22,$83,$04,$01
	.byte $22,$84,$04,$00,$42,$86,$04,$00
	.byte $22,$75,$08,$01,$22,$76,$08,$02
	.byte $32,$77,$02,$00,$23,$43,$08,$04
	.byte $13,$44,$02,$00,$13,$95,$05,$01
	.byte $33,$68,$07,$04,$23,$78,$07,$02
	.byte $13,$88,$07,$01,$24,$14,$02,$00
	.byte $14,$24,$08,$02,$14,$2a,$05,$01
	.byte $14,$3a,$05,$02,$14,$4a,$05,$00
	.byte $35,$25,$08,$04,$25,$35,$02,$00
	.byte $35,$3a,$09,$f0,$35,$4a,$09,$f0
	.byte $35,$5a,$09,$70,$35,$6a,$09,$30
	.byte $35,$7a,$09,$10,$15,$5a,$09,$01
	.byte $15,$6a,$09,$03,$15,$7a,$09,$07
	.byte $15,$8a,$09,$0f,$15,$9a,$09,$0f
	.byte $15,$aa,$09,$0e,$25,$4a,$01,$00
	.byte $25,$5a,$01,$00,$25,$6a,$01,$00
	.byte $25,$7a,$01,$00,$25,$8a,$01,$00
data_new_game:
	.byte $02,$01,$0a,$06,$01,$00,$07,$bf
	.byte $00,$00,$00,$01,$00,$a0,$c8,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $02,$04,$02,$01,$01,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $01,$35,$03,$a5,$01,$33,$01,$46
	.byte $04,$58,$01,$64,$01,$1b,$04,$71
	.byte $02,$11,$05,$72,$01,$23,$01,$72
	.byte $02,$86,$03,$2a,$03,$6a,$04,$57
	.byte $02,$39,$02,$26,$03,$56,$04,$72
	.byte $02,$82,$03,$26,$04,$96
gs_facing:
	.byte $02
gs_level:
	.byte $05
gs_player_x:
	.byte $04
gs_player_y:
	.byte $0a
gs_torches_lit:
	.byte $00
gs_torches_unlit:
	.byte $01
a6199:
	.byte $00
a619A:
	.byte $00
a619B:
	.byte $00
gd_parsed_action:
	.byte $10
gd_parsed_object:
	.byte $17
gs_room_lit:
	.byte $01
gs_food_time_hi:
	.byte $00
gs_food_time_lo:
	.byte $80
gs_torch_time:
	.byte $80
gs_teleported_lit:
	.byte $00
gs_level_turns_hi:
	.byte $00
gs_level_turns_lo:
	.byte $29
gs_special_mode:
	.byte $00
gs_mode_stack1:
	.byte $00
gs_mode_stack2:
	.byte $00
gs_exit_turns:
	.byte $00,$00,$00
gs_bat_alive:
	.byte $00
a61AC:
	.byte $04
gs_monster_lurks:
	.byte $00
gs_dog1_alive:
	.byte $00
gs_dog2_alive:
	.byte $01,$00
gs_next_hint:
	.byte $00
gs_monster_proximity:
	.byte $0c
gs_mother_proximity:
	.byte $00
gs_rotate_target:
	.byte $05
gs_rotate_count:
	.byte $00
gs_rotate_direction:
	.byte $00
gs_rotate_total:
	.byte $00
gs_lair_raided:
	.byte $00
gs_snake_used:
	.byte $01,$00
gs_item_locs:
	.byte $08,$00,$03,$a5,$00,$00,$04,$a9
	.byte $08,$00,$01,$64,$02,$33,$08,$00
	.byte $00,$00,$05,$72,$07,$00,$00,$00
	.byte $02,$86,$08,$00,$04,$a8,$04,$57
gs_item_snake:
	.byte $00,$00
gs_item_food_torch:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$08,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00
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
	.byte $00,$00,$00
signature:
	.byte "D"
	.byte "E"
	.byte "A"
	.byte "T"
	.byte "H"
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00
game_save_end:
	.byte $00,$00
font:
	.byte $10,$08,$3e,$7f,$ff,$ff,$be,$1c
	.byte $01,$02,$04,$08,$08,$10,$20,$40
	.byte $40,$20,$10,$08,$08,$04,$02,$01
	.byte $01,$01,$01,$01,$01,$01,$01,$01
	.byte $40,$40,$40,$40,$40,$40,$40,$40
	.byte $41,$22,$14,$08,$14,$22,$41,$41
	.byte $40,$60,$70,$78,$78,$7c,$7e,$7f
	.byte $01,$03,$07,$0f,$0f,$1f,$3f,$7f
	.byte $7f,$7e,$7c,$78,$78,$70,$60,$40
	.byte $7f,$3f,$1f,$0f,$0f,$07,$03,$01
	.byte $41,$41,$41,$41,$41,$41,$41,$41
	.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	.byte $00,$78,$64,$5e,$52,$32,$1e,$00
	.byte $00,$00,$00,$00,$78,$04,$02,$7f
	.byte $00,$00,$00,$00,$0f,$0c,$0a,$09
	.byte $09,$09,$09,$09,$09,$05,$03,$01
	.byte $00,$00,$00,$00,$7f,$00,$00,$7f
	.byte $09,$09,$09,$09,$09,$09,$09,$09
	.byte $01,$01,$01,$01,$01,$01,$01,$7f
	.byte $00,$00,$00,$00,$00,$00,$00,$7f
	.byte $40,$20,$10,$08,$08,$0c,$0a,$09
	.byte $09,$0a,$0c,$08,$08,$10,$20,$40
	.byte $08,$08,$08,$08,$08,$08,$08,$08
	.byte $41,$42,$44,$48,$48,$50,$60,$40
	.byte $00,$00,$00,$1c,$08,$1c,$00,$00
	.byte $60,$70,$70,$60,$60,$70,$70,$70
	.byte $03,$07,$07,$03,$03,$07,$07,$07
	.byte $07,$07,$07,$07,$07,$07,$07,$07
	.byte $70,$70,$70,$70,$70,$70,$70,$70
	.byte $01,$03,$07,$07,$07,$07,$07,$07
	.byte $40,$60,$70,$70,$70,$70,$70,$70
	.byte $78,$78,$78,$78,$7f,$7f,$7f,$7f
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $08,$08,$08,$08,$08,$00,$08,$00
	.byte $14,$14,$14,$00,$00,$00,$00,$00
	.byte $14,$14,$3e,$14,$3e,$14,$14,$00
	.byte $1c,$2a,$0a,$1c,$28,$2a,$1c,$00
	.byte $26,$26,$10,$08,$04,$32,$32,$00
	.byte $04,$0a,$0a,$04,$2a,$12,$2c,$00
	.byte $08,$08,$08,$00,$00,$00,$00,$00
	.byte $10,$08,$04,$04,$04,$08,$10,$00
	.byte $04,$08,$10,$10,$10,$08,$04,$00
	.byte $08,$2a,$1c,$08,$1c,$2a,$08,$00
	.byte $00,$08,$08,$3e,$08,$08,$00,$00
	.byte $00,$00,$00,$00,$10,$10,$08,$00
	.byte $00,$00,$00,$3e,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$0c,$0c,$00
	.byte $20,$20,$10,$08,$04,$02,$02,$00
	.byte $1c,$22,$32,$2a,$26,$22,$1c,$00
	.byte $08,$0c,$08,$08,$08,$08,$1c,$00
	.byte $1c,$22,$20,$1c,$02,$02,$3e,$00
	.byte $1e,$20,$20,$1c,$20,$20,$1e,$00
	.byte $10,$18,$14,$12,$3e,$10,$10,$00
	.byte $3e,$02,$1e,$20,$20,$20,$1e,$00
	.byte $18,$04,$02,$1e,$22,$22,$1c,$00
	.byte $3e,$20,$10,$08,$04,$04,$04,$00
	.byte $1c,$22,$22,$1c,$22,$22,$1c,$00
	.byte $1c,$22,$22,$3c,$20,$10,$0c,$00
	.byte $00,$0c,$0c,$00,$0c,$0c,$00,$00
	.byte $00,$0c,$0c,$00,$0c,$0c,$04,$00
	.byte $10,$08,$04,$02,$04,$08,$10,$00
	.byte $00,$00,$3e,$00,$3e,$00,$00,$00
	.byte $04,$08,$10,$20,$10,$08,$04,$00
	.byte $1c,$22,$10,$08,$08,$00,$08,$00
	.byte $1c,$22,$3a,$2a,$3a,$02,$3c,$00
	.byte $08,$14,$22,$22,$3e,$22,$22,$00
	.byte $1e,$24,$24,$1c,$24,$24,$1e,$00
	.byte $1c,$22,$02,$02,$02,$22,$1c,$00
	.byte $1e,$24,$24,$24,$24,$24,$1e,$00
	.byte $3e,$02,$02,$1e,$02,$02,$3e,$00
	.byte $3e,$02,$02,$1e,$02,$02,$02,$00
	.byte $3c,$02,$02,$02,$32,$22,$3c,$00
	.byte $22,$22,$22,$3e,$22,$22,$22,$00
	.byte $1c,$08,$08,$08,$08,$08,$1c,$00
	.byte $20,$20,$20,$20,$22,$22,$1c,$00
	.byte $22,$12,$0a,$06,$0a,$12,$22,$00
	.byte $02,$02,$02,$02,$02,$02,$7e,$00
	.byte $22,$36,$2a,$2a,$22,$22,$22,$00
	.byte $22,$26,$2a,$32,$22,$22,$22,$00
	.byte $1c,$22,$22,$22,$22,$22,$1c,$00
	.byte $1e,$22,$22,$1e,$02,$02,$02,$00
	.byte $1c,$22,$22,$22,$2a,$12,$2c,$00
	.byte $1e,$22,$22,$1e,$0a,$12,$22,$00
	.byte $1c,$22,$02,$1c,$20,$22,$1c,$00
	.byte $3e,$08,$08,$08,$08,$08,$08,$00
	.byte $22,$22,$22,$22,$22,$22,$1c,$00
	.byte $22,$22,$22,$14,$14,$08,$08,$00
	.byte $22,$22,$2a,$2a,$2a,$36,$22,$00
	.byte $22,$22,$14,$08,$14,$22,$22,$00
	.byte $22,$22,$22,$1c,$08,$08,$08,$00
	.byte $3e,$20,$10,$08,$04,$02,$3e,$00
	.byte $08,$1c,$2a,$08,$08,$08,$08,$00
	.byte $08,$08,$08,$08,$2a,$1c,$08,$00
	.byte $00,$04,$02,$7f,$02,$04,$00,$00
	.byte $00,$10,$20,$7f,$20,$10,$00,$00
	.byte $70,$60,$40,$00,$00,$00,$00,$00
	.byte $07,$03,$01,$00,$00,$00,$00,$00
	.byte $00,$00,$1c,$20,$3c,$22,$3c,$00
	.byte $02,$02,$1a,$26,$22,$22,$1e,$00
	.byte $00,$00,$1c,$22,$02,$22,$1c,$00
	.byte $20,$20,$2c,$32,$22,$22,$3c,$00
	.byte $00,$00,$1c,$22,$3e,$02,$1c,$00
	.byte $18,$24,$04,$0e,$04,$04,$04,$00
	.byte $00,$00,$2c,$32,$22,$3c,$20,$1e
	.byte $02,$02,$1a,$26,$22,$22,$22,$00
	.byte $08,$00,$0c,$08,$08,$08,$1c,$00
	.byte $20,$00,$20,$20,$20,$20,$22,$1c
	.byte $02,$02,$12,$0a,$06,$0a,$12,$00
	.byte $00,$0c,$08,$08,$08,$08,$1c,$00
	.byte $00,$00,$16,$2a,$2a,$2a,$2a,$00
	.byte $00,$00,$1a,$26,$22,$22,$22,$00
	.byte $00,$00,$1c,$22,$22,$22,$1c,$00
	.byte $00,$00,$1e,$22,$22,$1e,$02,$02
	.byte $00,$00,$3c,$22,$22,$3c,$20,$20
	.byte $00,$00,$1a,$26,$02,$02,$02,$00
	.byte $00,$00,$3c,$02,$1c,$20,$1e,$00
	.byte $04,$04,$1e,$04,$04,$24,$18,$00
	.byte $00,$00,$22,$22,$22,$32,$2c,$00
	.byte $00,$00,$22,$22,$14,$14,$08,$00
	.byte $00,$00,$2a,$2a,$2a,$2a,$14,$00
	.byte $00,$00,$22,$14,$08,$14,$22,$00
	.byte $00,$00,$22,$22,$22,$3c,$20,$1c
	.byte $00,$00,$3e,$10,$08,$04,$3e,$00
	.byte $0f,$0f,$0f,$0f,$7f,$7f,$7f,$7f
	.byte $70,$78,$7c,$7e,$7f,$7f,$7f,$7f
	.byte $07,$0f,$1f,$3f,$7f,$7f,$7f,$7f
	.byte $7f,$7f,$7f,$7f,$7e,$7c,$78,$70
	.byte $7f,$7f,$7f,$7f,$3f,$1f,$0f,$07
vocab_table:
	.byte $ff
verb_table:
	.byte $F2, "ais", $E2, "low", $E2, "rea", $E2, "urn", $E3, "hew*", $E5, "at ", $F2, "oll*", $E3, "huc*", $E8, "eav*"
	.byte $F4, "hro", $E3, "lim", $E4, "rop*", $EC, "eav*", $F0, "ut ", $E6, "ill", $EC, "igh", $F0, "lay", $F3, "tri", $F7, "e"
	.byte "ar", $E5, "xam*", $EC, "ook", $F7, "ipe*", $E3, "lea*", $F0, "oli*", $F2, "ub ", $EF, "pen*", $F5, "nlo", $F0
	.byte "res", $E7, "et *", $E7, "rab*", $E8, "old*", $F4, "ake", $F3, "tab*", $EB, "ill*", $F3, "las*", $E1, "tt"
	.byte "a*", $E8, "ack", $F0, "ain", $E7, "ren", $F3, "ay *", $F9, "ell*", $F3, "cre", $E3, "har", $E6, "art", $F3, "ave"
	.byte $F1, "uit", $E9, "nst*", $E4, "ire", $E8, "elp*", $E8, "int"
noun_table:
	.byte $C2, "all", $C2, "rush", $C3, "alculator", $C4, "agger", $C6, "lute", $C6, "risbee", $C8, "at"
	.byte " ", $C8, "orn", $CA, "ar ", $CB, "ey ", $D2, "ing", $D3, "neaker", $D3, "taff", $D3, "word", $D7, "ool", $D9, "o"
	.byte "yo", $D3, "nake", $C6, "ood", $D4, "orch", $C2, "ox ", $C2, "at ", $C4, "og ", $C4, "oor*", $C5, "lev", $CD, "on"
	.byte "ster", $CD, "other", $DA, "ero", $CF, "ne ", $D4, "wo ", $D4, "hree", $C6, "our", $C6, "ive", $D3, "ix ", $D3
	.byte "even", $C5, "ight", $CE, "ine"
junk_string:
	.byte $ff,$ff,$00,$00,$ff,$ff,$00,$00
	.byte $ff
display_string_table:
	.byte $C9, "nventory:", $D4, "orches:", $CC, "it:", $D5, "nlit:", $E3, "rystal ball"
	.byte ".", $F0, "aintbrush used by Van Gogh.", $E3, "alculator "
	.byte "with 10 buttons.", $EA, "eweled handled dagger.", $E6
	.byte "lute.", $F0, "recision crafted frisbee.", $E8, "at with "
	.byte "two ram's horns.", $E3, "arefully polished horn."
	.byte $E7, "lass jar complete with lid.", $E7, "olden key.", $E4
	.byte "iamond ring.", $F2, "otted mutilated sneaker.", $ED, "ag"
	.byte "ic staff.", $B9, "0 pound two-handed sword.", $E2, "all "
	.byte "of blue wool.", $F9, "oyo.", $F3, "nake !!!", $E2, "asket of foo"
	.byte "d.", $F4, "orch.", $C9, "nside the box there is a", $D9, "ou unl"
	.byte "ock the door...", $E1, "nd the wall falls on you"
	.byte "!", $E1, "nd the key begins to tick!", $E1, "nd a 20,000"
	.byte " volt shock kills you!", $C1, " 600 pound gorill"
	.byte "a rips your face off!", $D4, "wo men in white co"
	.byte "ats take you away!", $C8, "aving fun?", $D4, "he snake b"
	.byte "ites you and you die!", $D4, "hunderbolts shoot "
	.byte "out above you!", $D4, "he staff thunders with us"
	.byte "eless energy!", $F9, "ou are wearing it.", $D4, "o every"
	.byte "thing", $D4, "here is a season", $AC, " TURN,TURN,TURN", $D4, "h"
	.byte "e calculator displays 317.", $C9, "t displays 31"
	.byte "7.2 !", $D4, "he invisible guillotine beheads yo"
	.byte "u!", $D9, "ou have rammed your head into a steel"
	.byte $F7, "all and bashed your brains out!", $C1, "AAAAAAA"
	.byte "AAAHHHHH!", $D7, "HAM!!!", $C1, " vicious dog attacks yo"
	.byte "u!", $C8, "e rips your throat out!", $D4, "he dog chases"
	.byte " the sneaker!", $C1, " vampire bat attacks you!", $D9
	.byte "our stomach is growling!", $D9, "our torch is dy"
	.byte "ing!", $D9, "ou are another victim of the maze!", $D9
	.byte "ou have died of starvation!", $D4, "he monster a"
	.byte "ttacks you and", $F9, "ou are his next meal!", $F4, "he "
	.byte "magic word works! you have escaped!", $C4, "o yo"
	.byte "u want to play again (Y or N)?", $D9, "ou fall t"
	.byte "hrough the floor", $EF, "nto a bed of spikes!", $C2, "ef"
	.byte "ore I let you go free", $F7, "hat was the name o"
	.byte "f the monster?", $E9, "t says "the magic word is"
	.byte " camelot".", $D4, "he monster grabs the frisbee,"
	.byte " throws ", $E9, "t back, and it saws your head o"
	.byte "ff!", $D4, "ICK! TICK!", $D4, "he key blows up the whole"
	.byte " maze!", $D4, "he ground beneath your feet", $E2, "egins"
	.byte " to shake!", $C1, " disgusting odor permeates", $F4, "he"
	.byte " hallway as it darkens!", $F4, "he hallway!", $C9, "t is"
	.byte " the monster's mother!", $D3, "he has been seduc"
	.byte "ed!", $D3, "he tiptoes up to you!", $D3, "he slashes you"
	.byte " to bits!", $D9, "ou slash her to bits!", $C3, "orrect! "
	.byte "You have survived!", $D9, "ou break the", $E1, "nd it di"
	.byte "sappears!", $D7, "hat a mess! The vampire bat", $E4, "ri"
	.byte "nks the blood and dies!", $C9, "t vanishes in a", $E2
	.byte "urst of flames!", $D9, "ou can't be serious!", $D9, "ou "
	.byte "are making little sense.", $A0, "what?          "
	.byte "         ", $E1, "ll form into darts!", $D4, "he food is"
	.byte " being digested.", $D4, "he ", $ED, "agically sails", $E1, "roun"
	.byte "d a nearby corner", $E1, "nd is eaten by", $F4, "he mons"
	.byte "ter !!!!", $E1, "nd the monster grabs it,", $E7, "ets ta"
	.byte "ngled, and topples over!", $C9, "t is now full o"
	.byte "f blood.", $D4, "he monster is dead and", $ED, "uch bloo"
	.byte "d is spilt!", $D9, "ou have killed it.", $D4, "he dagger"
	.byte " disappears!", $D4, "he torch is lit and the", $EF, "ld "
	.byte "torch dies and vanishes!", $C1, " close inspecti"
	.byte "on reveals", $E1, "bsolutely nothing of value!", $E1, " "
	.byte "smudged display!", $C1, " can of spinach?", $F2, "eturns"
	.byte " and hits you", $E9, "n the eye!", $D9, "ou are trapped "
	.byte "in a fake", $E5, "levator. There is no escape!", $D7, "i"
	.byte "th what? Toenail polish?", $C1, " draft blows yo"
	.byte "ur torch out!", $D4, "he ring is activated and", $F3, "h"
	.byte "ines light everywhere!", $D4, "he staff begins t"
	.byte "o quake!", $D4, "he calculator vanishes.", $CE, "EVER, E"
	.byte "VER raid a monster's lair.", $CF, "K...", $E8, "as vanis"
	.byte "hed.", $D4, "he body has vanished!", $C7, "LITCH!", $CF, "K...it"
	.byte " is clean.", $C3, "heck your inventory, DOLT!", $D3, "PL"
	.byte "AT!", $D9, "ou eat the", $E1, "nd you get heartburn!", $C1, " de"
	.byte "afening roar envelopes", $F9, "ou. Your ears are"
	.byte " ringing!", $C6, "OOD FIGHT!! FOOD FIGHT!!", $D4, "he ha"
	.byte "llway is too crowded.", $C1, " high shrill note "
	.byte "comes", $E6, "rom the flute!", $D4, "he calculator displ"
	.byte "ays", $D9, "ou have been teleported!", $D7, "ith who? Th"
	.byte "e monster?", $D9, "ou have no fire.", $D7, "ith what? Ai"
	.byte "r?", $C9, "t's awfully dark.", $CC, "ook at your monitor"
	.byte ".", $C9, "t looks very dangerous!", $C9, "'m sorry, but "
	.byte "I can't ", $D9, "ou are confusing me.", $D7, "hat in tar"
	.byte "nation is a ", $C9, " don't see that here.", $CF, "K...i"
	.byte "f you really want to,", $C2, "ut you have no key"
	.byte ".", $C4, "o you wish to save the game (Y or N)?", $C4
	.byte "o you wish to continue a game (Y or N)?", $D0
	.byte "lease prepare your cassette.", $D7, "hen ready, "
	.byte "press any key.", $E1, "nd it vanishes!", $D9, "ou will d"
	.byte "o no such thing!", $D9, "ou are carrying the lim"
	.byte "it.", $C9, "t is currently impossible.", $D4, "he bat dr"
	.byte "ains you of your vital fluids!", $C1, "re you su"
	.byte "re you want to quit (Y or N)?", $D4, "ry examini"
	.byte "ng things.", $D4, "ype instructions.", $C9, "nvert and t"
	.byte "elephone.", $C4, "on't make unnecessary turns.", $D9, "o"
	.byte "u have turned into a pillar of salt!", $C4, "on'"
	.byte "t say I didn't warn you!", $D4, "he elevator is "
	.byte "moving!", $D9, "ou are deposited at the next lev"
	.byte "el.", $D9, "our head smashes into the ceiling!", $D9, "o"
	.byte "u fall on the snake!", $CF, "h no! A pit!"
	.byte $ff
	.byte "FE", $D2, $85, "Y STA *", $C8, $90, "   AIV DEYALPSID YLTNATSNOC"
	.byte " SI NOI", $08, $08, $08, $08, " NOITACO", $0C, "              00005 "
	.byte "EZ", $08, "XAMTAE", $04, "           %`GREN DEC *", $C8, "0` BNE"
	.byte " GOON6", $B8, "5` JMP UNCOM", $D0, "@`GOON68 DEC *", $C8, "E"
p77BF:
	.byte "`"
intro_text:
	.byte "           Deathmaze 5000               "
	.byte " Location is constantly displayed via   "
	.byte "3-D graphics. To move forward one step, "
	.byte "press Z. To turn to the left or right,  "
	.byte "press the left or right arrow. To turn  "
	.byte "around, press X. Only Z actually changes"
	.byte "your position. Additionally, words such "
	.byte "as CHARGE may be helpful in movement.   "
	.byte " At any time, one and two word commands "
	.byte "may be entered. Some useful commands are"
	.byte "OPEN BOX, GET BOX, DROP and HELP. Many  "
	.byte "more exist. To manipulate an object, you"
	.byte "must be on top of it, or be carrying it."
	.byte " To save a game in progress, enter SAVE."
	.byte "This is encouraged. Deathmaze is huge.  "
	.byte "It will take some time to escape.       "
	.byte " The five levels of Deathmaze are con-  "
	.byte "nected by elevators, pits, and science. "
	.byte "Connections are not always obvious.     "
	.byte "             Good Luck!                 "
	.byte "                                        "
	.byte "Copyright 1980 by Med Systems Software  "
	.byte "All rights reserved.                  ", $A0
junk_intro:
	.byte $80, "RT", $D3, "pdUN DEC IY", $B2, "ud RT", $D3, $80, "dDEUX INC IY", $B3, $85, "d R"
	.byte "T", $D3, $90, "dTROIS INC IY", $B2, $95, "d RT", $D3, $00, "eJUKILL JSR DRA", $D7
	.byte $05, "e JSR TIME", $B1, $10, "e JSR WHIT", $C5, $15, "e JSR CLRWN", $C4, " e "
	.byte "LDA #4", $B2, "%e JSR POIN", $D4, "0e LDA #4", $B3, "5e JSR POIN"
	.byte "T", $B5, "@e JMP "
text_save_device:
	.byte "Save to DISK or TAPE (T or D)?", $80
text_load_device:
	.byte $C7, "et from DISK or TAPE (T or D)?", $80
load_disk_or_tape:
	jsr clear_hgr2
	ldx #$00
	stx zp_col
	stx zp_row
	ldx #<text_load_device
	stx zp_0C_string
	ldx #>text_load_device
	stx zp_0D
	jsr print_string
	jsr input_T_or_D
	cmp #'D'
	bne prompt_tape
	jmp load_from_disk

prompt_tape:
	jsr clear_hgr2
	lda #$95     ;Prepare your cassette
	jsr print_to_line1
	rts

save_disk_or_tape:
	jsr clear_hgr2
	ldx #$00
	stx zp_col
	stx zp_row
	ldx #<text_save_device
	stx zp_0C_string
	ldx #>text_save_device
	stx zp_0D
	jsr print_string
	jsr input_T_or_D
	cmp #'T'
	beq prepare_tape_save
	jmp save_to_disk

prepare_tape_save:
	jsr clear_hgr2
	jsr draw_view
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
	jmp save_to_tape

input_T_or_D:
	bit hw_STROBE
:	jsr blink_cursor
	bit hw_KEYBOARD
	bpl :-
	lda hw_KEYBOARD
	and #$7f
	cmp #'T'
	beq :+
	cmp #'D'
	bne input_T_or_D
:	pha
	jsr clear_cursor
	pla
	rts

dos_dct:
	.byte $00,$01
	.word $d8ef
dos_iob:
	.byte $01,$60,$01,$00,$03,$00
iob_dct:
	.word relocate_data
iob_buffer:
	.word #game_save_begin
	.byte $00,$00
iob_cmd:
	.byte $01
iob_return_code:
	.byte $00
iob_last_volume:
	.byte $00,$60,$01

text_insert_disk:
	.byte $D0, "lace data diskette in DRIVE 1, SLOT 6.", $80

save_to_disk:
	ldx #$02
	stx iob_cmd
	jsr prompt_and_call_dos
	bcc prepare_disk_save
	jsr dos_code_to_message
	jmp disk_error_retry

prepare_disk_save:
	jsr clear_hgr2
	jsr draw_view
	ldx #icmd_draw_inv
	stx zp0F_action
	jmp item_cmd

load_from_disk:
	ldx #$01
	stx iob_cmd
	jsr prompt_and_call_dos
	bcc check_signature
	jsr dos_code_to_message
	jmp disk_error_fatal

check_signature:
	ldy #$00
	lda signature,y
	cmp #'D'
	bne @fail
	iny
	lda signature,y
	cmp #'E'
	bne @fail
	iny
	lda signature,y
	cmp #'A'
	bne @fail
	iny
	lda signature,y
	cmp #'T'
	bne @fail
	iny
	lda signature,y
	cmp #'H'
	bne @fail
	pla
	pla
	jmp start_game

@fail:
	lda #error_bad_save
	jmp disk_error_fatal

prompt_and_call_dos:
	lda #char_newline
	jsr char_out
	ldx #<text_insert_disk
	stx zp_0C_string
	ldx #>text_insert_disk
	stx zp_0D
	jsr print_string
	lda #$0a     ;char_newline
	jsr char_out
	lda #$96     ;Press any key
	jsr print_display_string
	jsr input_char
	lda #>dos_iob
	ldy #<dos_iob
	jsr DOS_call_rwts
	rts

dos_code_to_message:
	lda iob_return_code
	cmp #$10
	bne :+
	lda #error_write_protect
	rts

:	cmp #$20
	bne :+
	lda #error_volume_mismatch
	rts

:	cmp #$40
	bne :+
	lda #error_unknown_cause
	rts

:	lda #error_reading
	rts

; 1-based indexing via 'A'
string_disk_error:
	.byte "DISKETTE WRITE PROTECTED!", $80, "VOLUME MISMATC"
	.byte "H!", $80, "DRIVE ERROR! CAUSE UNKNOWN!", $80, "READ ERRO"
	.byte "R! CHECK YOUR DISKETTE!", $80, "NOT A DEATHMAZE "
	.byte "FILE! INPUT REJECTED!", $80
disk_error_fatal:
	ldx #$00
	stx zp10_noun
	beq disk_error
disk_error_retry:
	ldx #$ff
	stx zp10_noun
disk_error:
	tay
	dey
	bne :+
	beq @print_message
:	dey
	bne :+
	ldy #$1a
	bne @print_message
:	dey
	bne :+
	ldy #$2b
	bne @print_message
:	dey
	bne :+
	ldy #$47
	bne @print_message
:	ldy #$68
@print_message:
	sty a19
	ldx #$00
	stx zp1A_item_place
	ldx #<string_disk_error
	stx zp_0C_string
	ldx #>string_disk_error
	stx zp_0D
	clc
	lda a19
	adc zp_0C_string
	sta zp_0C_string
	lda zp1A_item_place
	adc zp_0D
	sta zp_0D
	lda #char_newline
	jsr char_out
	jsr print_string
	jsr input_char
	lda zp10_noun
	beq :+
	jmp prepare_disk_save

:	pla
	pla
	jmp cold_start

	lda gs_special_mode
	bne b7E81
	ldx #$06
	stx gs_special_mode
	rts

b7E81:
	.byte $06
	lda #$04
	sta zp_row
	lda #$03
	ldy #$0d
	jsr s17A7
	lda #>p4211
	sta screen_ptr+1
	lda #<p4211
	sta screen_ptr
	ldy #$04
	jsr s1777
	lda #>p5C61
	sta screen_ptr+1
	lda #<p5C61
	sta screen_ptr
	ldy #$04
	jsr s1777
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #$03
	ldy #$15
	jsr s17A7
	jmp j16E8

	pla
	pha
	cmp #$01
	bne b7ECE
	lda #$12
	sta zp_col
	lda #$04
	sta zp_row
	lda #$03
	ldy #$0d
	jsr s17A7
b7ECE:
	lda #$15
	sta zp_col
	lda #$00
	sta zp_row
	ldy #$04
	jsr s177F
	lda #$12
	sta zp_col
	lda #$11
	sta zp_row
	ldy #$04
	jsr s1795
	pla
	cmp #$00
	beq b7F4C
	lda a6199
	and #$01
	bne b7F1B
	lda #$00
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$15
	jsr s17A7
	lda #>relocated
	sta screen_ptr+1
	lda #<relocated
	sta screen_ptr
	ldy #$01
	jsr s1777
	lda #>p5E4F
	sta screen_ptr+1
	lda #<p5E4F
	sta screen_ptr
	ldy #$01
	jsr s1777
b7F1B:
	lda a619A
	and #$01
	bne b7F4B
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #$03
	ldy #$15
	jsr s17A7
	lda #>p4015
	sta screen_ptr+1
	lda #<p4015
	sta screen_ptr
	ldy #$01
	jsr s1777
	lda #>p5E65
	sta screen_ptr+1
	lda #<p5E65
	sta screen_ptr
	ldy #$01
	jsr s1777
b7F4B:
	rts

b7F4C:
	lda a6199
	and #$01
	beq b7F60
	lda #$00
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$15
	jsr s17A7
b7F60:
	lda a619A
	and #$01
	beq b7F4B
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #$03
	ldy #$15
	jsr s17A7
	rts

	lda #$ff
b7F79:
	sta (screen_ptr),y
	dey
	bne b7F79
	rts

	tya
	sta zp1A_item_place
b7F82:
	jsr get_rowcol_addr
	lda #$02
	jsr char_out
	dec zp_col
	dec zp_col
	inc zp_row
	dec zp1A_item_place
	bne b7F82
	rts

	tya
	sta zp1A_item_place
b7F98:
	jsr get_rowcol_addr
	lda #$01
	jsr char_out
	inc zp_row
	dec zp1A_item_place
	bne b7F98
	rts

	pha
	tya
	sta zp1A_item_place
	pla
b7FAC:
	pha
	jsr get_rowcol_addr
	pla
	pha
	jsr print_char
	pla
	dec zp_col
	inc zp_row
	dec zp1A_item_place
	bne b7FAC
	rts

	ldy #$00
	lda #<p6000
	sta zp0A_text_ptr
	lda #>p6000
	sta text_ptr+1
	ldx gs_level
	lda #$00
	clc
	dex
	beq b7FD7
	adc #$21
	jmp j17CF

b7FD7:
	adc zp0A_text_ptr
	sta zp0A_text_ptr
	ldx gs_player_x
	dex
	beq b7FEA
	inc zp0A_text_ptr
	inc zp0A_text_ptr
	inc zp0A_text_ptr
	jmp j17DE

b7FEA:
	lda gs_player_y
	cmp #$05
	bmi b7FFF
	cmp #$09
	bmi b7FFA
	inc zp0A_text_ptr
	sec
	sbc #$04
b7FFA:
	inc zp0A_text_ptr
	sec
	sbc #$04
b7FFF:
	brk
