	.include "deathmaze_a.i"

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
a0A = $0a
a0B = $0b
a0C = $0c
a0D = $0d
a0E = $0e
a0F = $0f
a10 = $10
a11 = $11
a13 = $13
a14 = $14
line_count = $15
zp_counter = $16
clock = $17
;clock+1 = $18
a19 = $19
a1A = $1a
tape_addr_start = $3c
;tape_addr_start+1 = $3d
tape_addr_end = $3e
;tape_addr_end+1 = $3f
aBC = $bc
aC3 = $c3
aEE = $ee
aEF = $ef
;
; **** ZP POINTERS ****
;
;screen_ptr = $08
p0A = $0a
p0C = $0c
p0E = $0e
p10 = $10
p13 = $13
p19 = $19
p28 = $28
pC2 = $c2
;
; **** ABSOLUTE ADRESSES ****
;
a000C = $000c
a000D = $000d
a0124 = $0124
a0125 = $0125
a0126 = $0126
a0127 = $0127
;
; **** POINTERS ****
;
p00F4 = $00f4
p00F6 = $00f6
;
; **** EXTERNAL JUMPS ****
;
e7FFF = $7fff
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
	stx a0F
	jsr item_cmd
start_game:
	ldx #char_ESC
	stx gd_parsed_action
	jsr player_cmd
	jmp main_game_loop

clear_hgr2:
	ldx #<screen_HGR2
	stx a0E
	ldx #>screen_HGR2
	stx a0F
	ldy #$00
@next_page:
	tya
:	sta (p0E),y
	inc a0E
	bne :-
	inc a0F
	lda a0F
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
	jsr check_signature ;NOTE: never returns, continues with PLA/PLA/JMP
	nop
	jmp item_cmd

print_to_line1:
	ldx #$00
	stx zp_col
	ldx #$16
	stx zp_row
	ldx #<text_buffer_line1
	stx a0A
	ldx #>text_buffer_line1
	stx a0B
	bne print_to_line
print_to_line2:
	ldx #$00
	stx zp_col
	ldx #$17
	stx zp_row
	ldx #<text_buffer_line2
	stx a0A
	ldx #>text_buffer_line2
	stx a0B
print_to_line:
	jsr get_display_string
	jsr get_rowcol_addr
	jsr clear_text_buf
	ldy #$00
	lda (p0C),y
	and #$7f
@next_char:
	sta (p0A),y
	jsr print_char
	inc a000C
	bne :+
	inc a000D
:	inc a0A
	bne :+
	inc a0B
:	ldy #$00
	lda (p0C),y
	bpl @next_char
	lda #char_ClearLine
	jsr char_out
	rts

print_display_string:
	jsr get_display_string
print_string:
	jsr get_rowcol_addr
	ldy #$00
	lda (p0C),y
	and #$7f
@next_char:
	jsr print_char
	inc a000C
	bne :+
	inc a000D
:	ldy #$00
	lda (p0C),y
	bpl @next_char
	rts

get_display_string:
	sta zp_string_number
	ldx #<display_string_table
	stx a000C
	ldx #>display_string_table
	stx a000D
	ldy #$00
@scan:
	lda (p0C),y
	bmi @found_string
@next_char:
	inc a000C
	bne @scan
	inc a000D
	bne @scan
@found_string:
	dec zp_string_number
	bne @next_char
	rts

clear_text_buf:
	ldy #$27
	lda #' '
:	sta (p0A),y
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
	stx a1A
	cmp #verb_forward
	beq move_forward
	jsr move_turn
	rts

move_turn:
	cmp #verb_left
	beq @turn_left
	cmp #verb_uturn
	beq @turn_around
@turn_right:
	lda a1A
	cmp #$04
	beq @wrap_clockwise
	inc gs_facing
	bne @turned
@wrap_clockwise:
	ldx #$01
	stx gs_facing
@turned:
	jsr update_view
	jsr print_timers
	rts

@turn_left:
	lda a1A
	cmp #$01
	beq @wrap_counterwise
	dec gs_facing
	bpl @turned
@wrap_counterwise:
	ldx #$04
	stx gs_facing
	bne @turned
@turn_around:
	lda a1A
	cmp #$03
	bmi :+
	dec gs_facing
	dec gs_facing
	bpl @turned
:	inc gs_facing
	inc gs_facing
	bpl @turned

; First check: move through The Perfect Square
move_forward:
	lda gs_level
	cmp #$03
	bne @normal
	lda gs_player_x
	cmp #$07
	bne @normal
	lda gs_player_y
	ldx gs_facing
	stx a1A
	cmp #$08
	beq @perfect_square_N
	cmp #$09
	bne @normal
@perfect_square_S:
	lda a1A
	cmp #$04
	bne @normal
	beq @move_player
@perfect_square_N:
	lda a1A
	cmp #$02
	beq @move_player
@normal:
	lda gs_walls_right_depth
	and #$e0
	bne @move_player
	jsr clear_maze_window
	lda #$09
	sta zp_col
	sta zp_row
	lda #$7c     ;Splat!
	jsr print_display_string
	rts

@move_player:
	ldx gs_facing
	dex
	beq @west_1
	dex
	beq @north_2
	dex
	beq @east_3

; south_4
	dec gs_player_y
	bpl @check_special
@east_3:
	inc gs_player_x
	bpl @check_special
@north_2:
	inc gs_player_y
	bpl @check_special
@west_1:
	dec gs_player_x
@check_special:
	jsr check_special_position
	lda gs_special_mode
	beq :+
	rts

:	jsr count_as_move
	jsr update_view
	jsr print_timers
	rts

check_special_position:
	lda gs_player_y
	sta a19
	lda gs_player_x
	sta a1A
	lda gs_level
	cmp #$03
	bne :+
	rts

:	bmi :+
	jmp check_levels_4_5

:	cmp #$02
	beq check_level_2
	lda a1A
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
	ldx #special_mode_calc_puzzle
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
	lda gs_level_moves_lo
	cmp #moves_until_dog1
	bcs :+
	lda gs_level_moves_hi
	beq special_return
:	lda gs_dog1_alive
	and #$01
	beq special_return
	lda gs_special_mode
	bne :+
	ldx #special_mode_dog1
	stx gs_special_mode
	rts

:	ldx #special_mode_dog1
	stx gs_mode_stack1
	rts

check_guarded_pit:
	lda a1A
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
	stx gs_level_moves_hi
	stx gs_level_moves_lo
	jsr pit
	rts

at_guard_dog:
	lda gs_dog2_alive
	and #$01
	beq return_dog_monster
	ldx #special_mode_dog2
	stx gs_special_mode
return_dog_monster:
	rts

check_levels_4_5:
	cmp #$04
	beq check_monster
	lda a1A
	cmp #$04
	beq check_bat
check_mother:
	lda gs_level_moves_lo
	cmp #moves_until_mother
	bcs :+
	lda gs_level_moves_hi
	beq return_dog_monster
:	lda gs_mother_alive
	and #mother_flag_roaming
	beq return_dog_monster
	lda gs_special_mode
	bne :+
	ldx #special_mode_mother
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
	ldx #special_mode_bat
	stx gs_special_mode
	rts

check_monster:
	lda gs_level_moves_lo
	cmp #moves_until_monster
	bcs :+
	lda gs_level_moves_hi
	beq return_dog_monster
:	lda gs_monster_alive
	and #$02
	beq done_timer
	ldx #special_mode_monster
	stx gs_special_mode
done_timer:
	rts

count_as_move:
	lda gs_level_moves_lo
	cmp #$ff
	beq :+
	inc gs_level_moves_lo
	jmp @consume

:	ldx #$00
	stx gs_level_moves_lo
	inc gs_level_moves_hi
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
	ldx #special_mode_dark
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
	stx a0F
	jsr item_cmd
	lda a1A
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
	stx a0F
	jsr item_cmd
	cmp #$00
	beq pop_not_carried
	rts

@food:
	ldx #icmd_which_food
	stx a0F
	jsr item_cmd
	cmp #$00
	beq pop_not_carried
	rts

@torch:
	ldx #icmd_which_torch_unlit
	stx a0F
	jsr item_cmd
	cmp #$00
	bne rts_bb2
	lda gs_level
	cmp #$05
	beq pop_not_carried
	lda gs_room_lit
	beq pop_not_carried
	ldx #icmd_which_torch_lit
	stx a0F
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
	lda (p0E),y
	sta (p10),y
	inc a0E
	bne :+
	inc a0F
:	inc a10
	bne :+
	inc a11
:	dec a19
	beq @check_done
	lda a19
	cmp #$ff
	bne @next_byte
	dec a1A
	jmp @next_byte

@check_done:
	lda a1A
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
text_buffer_line1:
	.byte $61,$a9,$45,$20,$92,$08,$a9,$47
	.byte $20,$a4,$08,$4c,$08,$36,$20,$26
	.byte $36,$ad,$94,$61,$c9,$05,$f0,$0d
	.byte $a9,$36,$20,$92,$08,$a9,$37,$20 ;The monster attacks you and
	.byte $a4,$08,$4c,$b9,$10,$a9,$48,$20
text_buffer_line2:
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
	lda #>text_buffer_line1
	sta a0F
	lda #<text_buffer_line1
	sta a0E
	lda #>textbuf_prev_input
	sta a11
	lda #<textbuf_prev_input
	sta a10
	lda #$00
	sta a1A
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
	sta a000D
	lda #<p0C79
	sta a000C
	lda #$80
	ldy #$50
:	sta (p0C),y
	dey
	bne :-
	lda #$00
	sta zp11_count_chars
	sta zp10_count_words
	lda #>p0C79
	sta a1A
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
	sta a0F
	lda #<textbuf_prev_input-1
	sta a0E
	ldy #$50
@next_char:
	lda (p0E),y
	sta (p19),y
	dey
	bne @next_char

	ldy #$50
	sty a0E
	ldy #$01
	sty a0F
@repeat_display:
	lda (p19),y
	cmp #$80
	bmi :+
	lda #' '
:	jsr char_out
	inc a0F
	ldy a0F
	dec a0E
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
	inc a1A
@parse_verb:
	jsr get_vocab
	lda a10
	sta gd_parsed_action
	ldy #$00
@skip_word:
	inc a19
	bne :+
	inc a1A
:	lda (p19),y
	cmp #' '
	bne @skip_word
	inc a19
	bne :+
	inc a1A
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
	lda a10
	sta gd_parsed_object
@check_verb:
	lda gd_parsed_action
	cmp #verbs_end
	bcc @known_verb
	lda #$8d     ;I'm sorry, but I can't
	jsr print_to_line2
	lda #<text_buffer_line1
	sta a19
	lda #>text_buffer_line1
	sta a1A
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
	lda #<text_buffer_line1
	sta a19
	lda #>text_buffer_line1
	sta a1A
	ldy #$00
@find_word_end:
	lda (p19),y
	cmp #$20
	beq @found_word_end
	inc a19
	bne @find_word_end
	inc a1A
	bne @find_word_end
@found_word_end:
	inc a19
	bne @obj_next_letter
	inc a1A
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
	lda #>text_buffer_line1
	sta a1A
	lda #<text_buffer_line1
	sta a19
	lda #$00
	sta zp_col
	lda #$17
	sta zp_row
	jsr get_rowcol_addr
	lda #char_ClearLine
	jsr char_out
	ldy #$00
	sty a11
	lda (p19),y
	and #char_mask_upper
	bne @echo
@next_verb_letter:
	lda (p19),y
	cmp #$20
	beq @verb_word_end
@echo:
	jsr char_out
	inc a11
	ldy a11
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
	lda a1A
	pha
	lda a19
	pha
	lda #>vocab_table
	sta a0F
	lda #<vocab_table
	sta a0E
	lda #$00
	sta a10
@next_word:
	ldy #$01
@find_string:
	lda (p0E),y
	and #$80
	bne @found_start
	inc a0E
	bne @find_string
	inc a0F
	bne @find_string
@found_start:
	dey
	lda (p0E),y
	cmp #'*'
	beq :+
	inc a10
:	inc a0E
	bne :+
	inc a0F
:	lda #$04
	sta a11
@compare_char:
	lda (p0E),y
	and #char_mask_upper
	sta a13
	lda (p19),y
	and #char_mask_upper
	cmp a13
	bne @mismatch
	inc a19
	bne :+
	inc a1A
:	inc a0E
	bne :+
	inc a0F
:	dec a11
	bne @compare_char
@done:
	pla
	sta a19
	pla
	sta a1A
	rts

@mismatch:
	lda a10
	cmp #vocab_end-1
	beq @fail
	pla
	sta a19
	pla
	sta a1A
	pha
	lda a19
	pha
	jmp @next_word

@fail:
	inc a10
	bne @done

wait_short:
	ldx #$90
	stx a0F
:	dec a0E
	bne :-
	dec a0F
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

update_view:
	jsr clear_maze_window
	jsr probe_forward
	lda gs_room_lit
	beq @done
	jsr draw_maze
	jsr get_maze_feature
	lda a0F
	ora a0E
	beq :+
	jsr draw_special
:	ldx #icmd_0a
	stx a0F
	jsr item_cmd
	lda gs_box_visible
	beq @done
	sta a0E
	ldx #$06
	stx a0F
	jsr draw_special
@done:
	rts

wait_long:
	ldx #$05
	stx a10
@dec16:
	ldx #$00
	stx a0F
:	dec a0E
	bne :-
	dec a0F
	bne :-
	dec a10
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
	jsr update_view
	jmp j3493

	rts

	stx a0F
	jsr item_cmd
	lda #$06
	cmp a1A
	beq b110D
	dec a11
	bne b10E1
	pla
	sta a0E
	pla
	sta a0F
	jmp j2EFB

b110D:
	pla
	sta a0E
	pla
	sta a0F
	lda gd_parsed_object
	cmp #noun_torch
	beq :+
	jmp j2E72

:	inc gs_torches_unlit
	jmp j2E72

; cruft leftover from even earlier build
	dec a0F
	bne cruft_cmd_paint
	lda a0E
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
	dec a0F
	bne cruft_cmd
	ldx #noun_brush
	stx a0E
	ldx #icmd_where
	stx a0F
	jsr item_cmd
	lda a1A
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

draw_maze:
	lda gs_walls_right_depth
	lsr
	lsr
	lsr
	lsr
	lsr
	pha          ;Top 3 bits = Depth
	cmp #$05
	bcc @draw_4_center
	lda #<raster 10,11,0
	sta screen_ptr
	lda #>raster 10,11,0
	sta screen_ptr+1
	lda #glyph_X
	jsr char_out
	jmp @draw_4_left

@draw_4_center:
	cmp #$04
	bne @draw_3_center
	lda #<raster 10,10,0
	sta screen_ptr
	lda #>raster 10,10,0
	sta screen_ptr+1
	ldy #$01
	jsr draw_right
	lda #raster_hi 10,10,7
	sta screen_ptr+1
	ldy #$01
	jsr draw_right
	jmp @draw_4_left

@draw_3_center:
	cmp #$03
	bne @draw_2_center
	lda #>raster 9,9,0
	sta screen_ptr+1
	lda #<raster 9,9,0
	sta screen_ptr
	ldy #$03
	jsr draw_right
	lda #raster_hi 11,9,7
	sta screen_ptr+1
	ldy #$03
	jsr draw_right
	jmp @draw_3_left

@draw_2_center:
	cmp #$02
	bne @draw_1_center
	lda #>raster 7,7,0
	sta screen_ptr+1
	lda #<raster 7,7,0
	sta screen_ptr
	ldy #$07
	jsr draw_right
	lda #>raster 13,7,7
	sta screen_ptr+1
	lda #<raster 13,7,7
	sta screen_ptr
	ldy #$07
	jsr draw_right
	jmp @draw_2_left

@draw_1_center:
	cmp #$01
	bne @draw_0_center
	lda #>raster 4,4,0
	sta screen_ptr+1
	lda #<raster 4,4,0
	sta screen_ptr
	ldy #$0d
	jsr draw_right
	lda #>raster 16,4,7
	sta screen_ptr+1
	lda #<raster 16,4,7
	sta screen_ptr
	ldy #$0d
	jsr draw_right
	jmp @draw_1_left

@draw_0_center:
	lda #>screen_HGR2 ;raster 0,0,0
	sta screen_ptr+1
	lda #<screen_HGR2
	sta screen_ptr
	ldy #$15
	jsr draw_right
	lda #>raster 20,0,7
	sta screen_ptr+1
	lda #<raster 20,0,7
	sta screen_ptr
	ldy #$15
	jsr draw_right
	jmp @draw_0_left

@draw_4_left:
	lda gs_walls_left
	and #(1 << 4)
	bne @draw_4_left_wall
@draw_4_left_open:
	pla
	pha
	cmp #$04
	beq :+
	lda #>raster 10,10,0
	sta screen_ptr+1
	lda #<raster 10,10,0
	sta screen_ptr
	lda #glyph_R
	jsr char_out
:	lda #>raster 10,9,0
	sta screen_ptr+1
	lda #<raster 10,9,0
	sta screen_ptr
	ldy #$01
	jsr draw_right
	lda #raster_hi 10,9,7
	sta screen_ptr+1
	ldy #$01
	jsr draw_right
	lda #$09
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$03
	jsr draw_down
	jmp @draw_4_right

@draw_4_left_wall:
	pla
	pha
	cmp #$04
	bne :+
	lda #>raster 10,10,0
	sta screen_ptr+1
	lda #<raster 10,10,0
	sta screen_ptr
	lda #glyph_R
	jsr char_out
:	lda #$0a
	sta zp_col
	lda #$09
	sta zp_row
	ldy #$01
	jsr draw_down_right
	dec zp_col
	inc zp_row
	ldy #$01
	jsr draw_down_left
@draw_4_right:
	lda gs_walls_right_depth
	and #(1 << 4)
	bne @draw_4_right_wall
@draw_4_right_open:
	pla
	pha
	cmp #$04
	beq :+
	lda #>raster 10,12,0
	sta screen_ptr+1
	lda #<raster 10,12,0
	sta screen_ptr
	lda #glyph_L
	jsr char_out
:	lda #>raster 10,11,0
	sta screen_ptr+1
	lda #<raster 10,11,0
	sta screen_ptr
	ldy #$01
	jsr draw_right
	lda #raster_hi 10,11,7
	sta screen_ptr+1
	ldy #$01
	jsr draw_right
	lda #$0d
	sta zp_col
	lda #$09
	sta zp_row
	lda #glyph_L
	ldy #$03
	jsr draw_down
	jmp @draw_3_left

@draw_4_right_wall:
	pla
	pha
	cmp #$04
	bne :+
	lda #>raster 10,12,0
	sta screen_ptr+1
	lda #<raster 10,12,0
	sta screen_ptr
	lda #glyph_L
	jsr char_out
:	lda #$0c
	sta zp_col
	lda #$09
	sta zp_row
	ldy #$01
	jsr draw_down_left
	inc zp_col
	inc zp_row
	ldy #$01
	jsr draw_down_right
@draw_3_left:
	lda gs_walls_left
	and #(1 << 3)
	bne @draw_3_left_wall
@draw_3_left_open:
	pla
	pha
	cmp #$03
	beq :+
	lda #$09
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$03
	jsr draw_down
:	lda #>raster 9,7,0
	sta screen_ptr+1
	lda #<raster 9,7,0
	sta screen_ptr
	ldy #$02
	jsr draw_right
	lda #>raster 11,7,7
	sta screen_ptr+1
	lda #<raster 11,7,7
	sta screen_ptr
	ldy #$02
	jsr draw_right
	lda #$07
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$07
	jsr draw_down
	jmp @draw_3_right

@draw_3_left_wall:
	pla
	pha
	cmp #$03
	bne :+
	lda #$09
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$03
	jsr draw_down
:	lda #$08
	sta zp_col
	lda #$07
	sta zp_row
	ldy #$02
	jsr draw_down_right
	lda #$09
	sta zp_col
	lda #$0c
	sta zp_row
	ldy #$02
	jsr draw_down_left
@draw_3_right:
	lda gs_walls_right_depth
	and #(1 << 3)
	bne @draw_3_right_wall
@draw_3_right_open:
	pla
	pha
	cmp #$03
	beq :+
	lda #$0d
	sta zp_col
	lda #$09
	sta zp_row
	lda #glyph_L
	ldy #$03
	jsr draw_down
:	lda #>raster 9,12,0
	sta screen_ptr+1
	lda #<raster 9,12,0
	sta screen_ptr
	ldy #$02
	jsr draw_right
	lda #>raster 11,12,7
	sta screen_ptr+1
	lda #<raster 11,12,7
	sta screen_ptr
	ldy #$02
	jsr draw_right
	lda #$0f
	sta zp_col
	lda #$07
	sta zp_row
	lda #glyph_L
	ldy #$07
	jsr draw_down
	jmp @draw_2_left

@draw_3_right_wall:
	pla
	pha
	cmp #$03
	bne :+
	lda #$0d
	sta zp_col
	lda #$09
	sta zp_row
	lda #glyph_L
	ldy #$03
	jsr draw_down
:	lda #$0e
	sta zp_col
	lda #$07
	sta zp_row
	ldy #$02
	jsr draw_down_left
	lda #$0d
	sta zp_col
	lda #$0c
	sta zp_row
	ldy #$02
	jsr draw_down_right
@draw_2_left:
	lda gs_walls_left
	and #(1 << 2)
	bne @draw_2_left_wall
	pla
	pha
	cmp #$02
	beq :+
	lda #$07
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$07
	jsr draw_down
:	lda #>raster 7,4,0
	sta screen_ptr+1
	lda #<raster 7,4,0
	sta screen_ptr
	ldy #$03
	jsr draw_right
	lda #>raster 13,4,7
	sta screen_ptr+1
	lda #<raster 13,4,7
	sta screen_ptr
	ldy #$03
	jsr draw_right
	lda #$04
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$0d
	jsr draw_down
	jmp @draw_2_right

@draw_2_left_wall:
	pla
	pha
	cmp #$02
	bne :+
	lda #$07
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$07
	jsr draw_down
:	lda #$05
	sta zp_col
	lda #$04
	sta zp_row
	ldy #$03
	jsr draw_down_right
	lda #$07
	sta zp_col
	lda #$0e
	sta zp_row
	ldy #$03
	jsr draw_down_left
@draw_2_right:
	lda gs_walls_right_depth
	and #(1 << 2)
	bne @draw_2_right_wall
@draw_2_right_open:
	pla
	pha
	cmp #$02
	beq :+
	lda #$0f
	sta zp_col
	lda #$07
	sta zp_row
	lda #glyph_L
	ldy #$07
	jsr draw_down
:	lda #>raster 7,14,0
	sta screen_ptr+1
	lda #<raster 7,14,0
	sta screen_ptr
	ldy #$03
	jsr draw_right
	lda #>raster 13,14,7
	sta screen_ptr+1
	lda #<raster 13,14,7
	sta screen_ptr
	ldy #$03
	jsr draw_right
	lda #$12
	sta zp_col
	lda #$04
	sta zp_row
	lda #glyph_L
	ldy #$0d
	jsr draw_down
	jmp @draw_1_left

@draw_2_right_wall:
	pla
	pha
	cmp #$02
	bne :+
	lda #$0f
	sta zp_col
	lda #$07
	sta zp_row
	lda #glyph_L
	ldy #$07
	jsr draw_down
:	lda #$11
	sta zp_col
	lda #$04
	sta zp_row
	ldy #$03
	jsr draw_down_left
	lda #$0f
	sta zp_col
	lda #$0e
	sta zp_row
	ldy #$03
	jsr draw_down_right
@draw_1_left:
	lda gs_walls_left
	and #(1 << 1)
	bne @draw_1_left_wall
@draw_1_left_open:
	pla
	pha
	cmp #$01
	beq :+
	lda #$04
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$0d
	jsr draw_down
:	lda #>raster 4,0,0
	sta screen_ptr+1
	lda #<raster 4,0,0
	sta screen_ptr
	ldy #$04
	jsr draw_right
	lda #>raster 16,0,7
	sta screen_ptr+1
	lda #<raster 16,0,7
	sta screen_ptr
	ldy #$04
	jsr draw_right
	lda #$00
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$15
	jsr draw_down
	jmp @draw_1_right

@draw_1_left_wall:
	pla
	pha
	cmp #$01
	bne :+
	lda #$04
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$0d
	jsr draw_down
:	lda #$01
	sta zp_col
	lda #$00
	sta zp_row
	ldy #$04
	jsr draw_down_right
	lda #$04
	sta zp_col
	lda #$11
	sta zp_row
	ldy #$04
	jsr draw_down_left
@draw_1_right:
	lda gs_walls_right_depth
	and #(1 << 1)
	bne @draw_1_right_wall
@draw_1_right_open:
	pla
	pha
	cmp #$01
	beq :+
	lda #$12
	sta zp_col
	lda #$04
	sta zp_row
	lda #glyph_L
	ldy #$0d
	jsr draw_down
:	lda #>raster 4,17,0
	sta screen_ptr+1
	lda #<raster 4,17,0
	sta screen_ptr
	ldy #$04
	jsr draw_right
	lda #>raster 16,17,7
	sta screen_ptr+1
	lda #<raster 16,17,7
	sta screen_ptr
	ldy #$04
	jsr draw_right
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #glyph_L
	ldy #$15
	jsr draw_down
	jmp @draw_0_left

@draw_1_right_wall:
	pla
	pha
	cmp #$01
	bne :+
	lda #$12
	sta zp_col
	lda #$04
	sta zp_row
	lda #glyph_L
	ldy #$0d
	jsr draw_down
:	lda #$15
	sta zp_col
	lda #$00
	sta zp_row
	ldy #$04
	jsr draw_down_left
	lda #$12
	sta zp_col
	lda #$11
	sta zp_row
	ldy #$04
	jsr draw_down_right
@draw_0_left:
	pla
	cmp #$00
	beq @draw_0_left_wall
	lda gs_walls_left
	and #(1 << 0)
	bne @draw_0_right
@draw_0_left_open:
	lda #$00
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$15
	jsr draw_down
	lda #raster 0,-1,0
	sta screen_ptr+1
	lda #<relocated
	sta screen_ptr
	ldy #$01
	jsr draw_right
	lda #>raster 20,-1,7
	sta screen_ptr+1
	lda #<raster 20,-1,7
	sta screen_ptr
	ldy #$01
	jsr draw_right
@draw_0_right:
	lda gs_walls_right_depth
	and #(1 << 0)
	bne @draw_0_done
@draw_0_right_open:
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #glyph_L
	ldy #$15
	jsr draw_down
	lda #>raster 0,21,0
	sta screen_ptr+1
	lda #<raster 0,21,0
	sta screen_ptr
	ldy #$01
	jsr draw_right
	lda #>raster 20,21,7
	sta screen_ptr+1
	lda #<raster 20,21,7
	sta screen_ptr
	ldy #$01
	jsr draw_right
@draw_0_done:
	rts

@draw_0_left_wall:
	lda gs_walls_left
	and #(1 << 0)
	beq @draw_0_right_wall
	lda #$00
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$15
	jsr draw_down
@draw_0_right_wall:
	lda gs_walls_right_depth
	and #(1 << 0)
	beq @draw_0_done
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #glyph_L
	ldy #$15
	jsr draw_down
	rts

draw_right:
	lda #$ff
:	sta (screen_ptr),y
	dey
	bne :-
	rts

; Input: Y=count
draw_down_left:
	tya
	sta a1A
:	jsr get_rowcol_addr
	lda #glyph_slash_up
	jsr char_out
	dec zp_col
	dec zp_col
	inc zp_row
	dec a1A
	bne :-
	rts

; Input: Y=count
draw_down_right:
	tya
	sta a1A
:	jsr get_rowcol_addr
	lda #glyph_slash_down
	jsr char_out
	inc zp_row
	dec a1A
	bne :-
	rts

; Input: A=char Y=count
draw_down:
	pha
	tya
	sta a1A
	pla
@next:
	pha
	jsr get_rowcol_addr
	pla
	pha
	jsr print_char
	pla
	dec zp_col
	inc zp_row
	dec a1A
	bne @next
	rts

probe_forward:
	ldy #$00
	lda #<maze_walls
	sta a0A
	lda #>maze_walls
	sta a0B
	ldx gs_level
	lda #$00
	clc
:	dex
	beq @find_x
	adc #$21
	jmp :-

@find_x:
	adc a0A
	sta a0A
	ldx gs_player_x
:	dex
	beq @find_y
	inc a0A
	inc a0A
	inc a0A
	jmp :-

@find_y:
	lda gs_player_y
	cmp #$05
	bmi @find_2bits
	cmp #$09
	bmi @shift_1_byte
@shift_2_bytes:
	inc a0A
	sec
	sbc #$04
@shift_1_byte:
	inc a0A
	sec
	sbc #$04
@find_2bits:
	tax
	lda #$80
:	dex
	beq @check_facing
	lsr
	lsr
	jmp :-

@check_facing:
	sta a1A
	stx a19
	stx a11
	stx gs_walls_left
	stx gs_walls_right_depth
	ldx gs_facing
	dex
	bne :+
	jmp probe_west

:	dex
	bne :+
	jmp probe_north

:	dex
	beq probe_east

probe_south:
	lda (p0A),y
	and a1A
	bne @S_sight_limit
	inc a19
	lda a19
	cmp #$05
	beq @S_sight_limit
	lda a1A
	cmp #$80
	bne :+
	dec a0A
	lda #$02
	sta a1A
	jmp probe_south

:	asl a1A
	asl a1A
	jmp probe_south

@S_sight_limit:
	lda a19
	jsr swap_saved_A_2
	lsr a1A
S_next_wall:
	lda (p0A),y
	and a1A
	beq :+
	inc gs_walls_right_depth
:	ldy #$03
	lda (p0A),y
	ldy #$00
	and a1A
	beq :+
	inc gs_walls_left
:	jsr swap_saved_A_2
	cmp a11
	beq S_probe_done
	jsr swap_saved_A_2
	lda #$04
	cmp a11
	beq S_probed_max
	asl gs_walls_left
	asl gs_walls_right_depth
	inc a11
	lda a1A
	cmp #$01
	beq :+
	lsr a1A
	lsr a1A
	jmp S_next_wall

:	lda #$40
	sta a1A
	inc a0A
	jmp S_next_wall

S_probed_max:
	jsr swap_saved_A_2
S_probe_done:
	asl
	asl
	asl
	asl
	asl
	clc
	adc gs_walls_right_depth
	sta gs_walls_right_depth
	rts

probe_east:
	lsr a1A
@next_depth:
	clc
	lda a0A
	adc #$03
	sta a0A
	lda (p0A),y
	and a1A
	bne @E_sight_limit
	inc a19
	lda a19
	cmp #$05
	bne @next_depth
@E_sight_limit:
	lda a19
	jsr swap_saved_A_2
	lda a1A
	sta zp_wall_opposite
	asl a1A
	clc
	ror a19
	bcc E_next_wall
	ror a19
E_next_wall:
	dec a0A
	dec a0A
	dec a0A
	lda (p0A),y
	and a1A
	beq :+
	inc gs_walls_right_depth
:	lda a19
	cmp #$80
	beq :+
	lda (p0A),y
	jmp @check_opposite

:	iny
	lda (p0A),y
	dey
@check_opposite:
	and a19
	beq :+
	inc gs_walls_left
:	lda a11
	cmp #$04
E_probed_max:
	beq S_probed_max
	jsr swap_saved_A_2
	cmp a11
E_probe_done:
	beq S_probe_done
	jsr swap_saved_A_2
	inc a11
	asl gs_walls_left
	asl gs_walls_right_depth
	jmp E_next_wall

probe_west:
	lsr a1A
@next_depth:
	lda (p0A),y
	and a1A
	bne :+
	inc a19
	lda a19
	cmp #$05
	beq :+
	dec a0A
	dec a0A
	dec a0A
	jmp @next_depth

:	lda a19
	jsr swap_saved_A_2
	lda a1A
	sta a19
	asl a1A
	clc
	ror zp_wall_opposite
	bcc W_next_wall
	ror a19
W_next_wall:
	lda (p0A),y
	and a1A
	beq :+
	inc gs_walls_left
:	lda a19
	cmp #$80
	bne :+
	inc a0A
:	lda (p0A),y
	and a19
	beq :+
	inc gs_walls_right_depth
:	lda a19
	cmp #$80
	beq :+
	inc a0A
:	inc a0A
	inc a0A
	jsr swap_saved_A_2
	cmp a11
	beq E_probe_done
	jsr swap_saved_A_2
	lda #$04
	cmp a11
W_probed_max:
	beq E_probed_max
	inc a11
	asl gs_walls_left
	asl gs_walls_right_depth
	jmp W_next_wall

probe_north:
	lda a1A
	cmp #$02
	bne :+
	lda #$80
	sta a1A
	inc a0A
	jmp @next_depth

:	lsr a1A
	lsr a1A
@next_depth:
	lda (p0A),y
	and a1A
	bne @sight_limit
	inc a19
	lda a19
	cmp #$05
	beq @sight_limit
	lda a1A
	cmp #$02
	bne :+
	inc a0A
	lda #$80
	sta a1A
	jmp @next_depth

:	lsr a1A
	lsr a1A
	jmp @next_depth

@sight_limit:
	lda a1A
	cmp #$80
	beq :+
	asl a1A
	jmp @save_depth

:	dec a0A
	lda #$01
	sta a1A
@save_depth:
	lda a19
	jsr swap_saved_A_2
N_next_wall:
	lda (p0A),y
	and a1A
	beq :+
	inc gs_walls_left
:	ldy #$03
	lda (p0A),y
	ldy #$00
	and a1A
	beq :+
	inc gs_walls_right_depth
:	lda #$04
	cmp a11
	beq W_probed_max
	jsr swap_saved_A_2
	cmp a11
	bne :+
	jmp S_probe_done

:	jsr swap_saved_A_2
	asl gs_walls_left
	inc a11
	asl gs_walls_right_depth
	lda a1A
	cmp #$40
	beq :+
	asl a1A
	asl a1A
	jmp N_next_wall

:	lda #$01
	sta a1A
	dec a0A
	jmp N_next_wall

swap_saved_A_2:
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
	lda a0F
	cmp #execs_no_location
	bpl icmd07_draw_inv
	asl a0E
	pha
	lda #$00
	sta a0F
	clc
	lda #<(gs_item_location-2)
	adc a0E
	sta a0E
	lda #>(gs_item_location-2)
	adc a0F
	sta a0F
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
	sta (p0E),y
	inc a0E
	bne :+
	inc a0F
:	lda #$00
	sta (p0E),y
	rts

icmd06_where_item:
	cmp #icmd_drop
	beq icmd05_drop_item
	ldy #$00
	lda (p0E),y
	sta a1A
	iny
	lda (p0E),y
	sta a19
	rts

icmd05_drop_item:
	lda gs_level
	ldy #$00
	sta (p0E),y
	lda gs_player_x
	asl
	asl
	asl
	asl
	ora gs_player_y
	iny
	sta (p0E),y
	rts

icmd07_draw_inv:
	sec
	sbc #execs_location_end
	beq @clear_window
	jmp icmd08_count_inv

@clear_window:
	lda #$0f
	sta a1A
	lda #$19
	sta zp_col
	lda #$03
	sta zp_row
:	jsr get_rowcol_addr
	lda #$1e     ;char_ClearLine
	jsr char_out
	inc zp_row
	dec a1A
	bne :-

; print inventory
	lda #items_unique + items_food
	sta a1A
	lda #<gs_item_locs
	sta a0E      ;zp_FIXME
	lda #>gs_item_locs
	sta a0F
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
	lda (p0E),y
	cmp #$08
	bne :+
	jmp print_known_item

:	cmp #$07
	bne next_known_item
	jmp print_known_item

next_known_item:
	inc a0E
	bne :+
	inc a0F
:	inc a0E
	bne :+
	inc a0F
:	dec a1A
	bne check_item_known

	lda #<gs_item_locs
	sta a0E
	lda #>gs_item_locs
	sta a0F
	lda #items_unique + items_food + items_torches
	sta a1A
check_item_boxed:
	ldy #$00
	lda (p0E),y
	cmp #carried_boxed
	bne next_boxed_item
	jmp print_boxed_item

next_boxed_item:
	inc a0E
	bne :+
	inc a0F
:	inc a0E
	bne :+
	inc a0F
:	dec a1A
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
	sbc a1A
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
	sta a1A
	dec a1A
	bne icmd09_new_game

	lda #>gs_item_locs
	sta a0F      ;zp_FIXME
	lda #<gs_item_locs
	sta a0E
	lda #items_unique + items_food
	sta a1A
	lda #$00
	sta a19
	ldy #$00
@check_carried:
	lda (p0E),y
	cmp #$06
	bmi :+
	inc a19
:	iny
	iny
	dec a1A
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
	dec a1A
	bne icmd0A

	ldy #gs_size-1
	lda #>data_new_game
	sta a0F
	lda #<data_new_game
	sta a0E
	lda #<gs_facing
	sta a10
	lda #>gs_facing
	sta a11
:	lda (p0E),y
	sta (p10),y
	dey
	bpl :-
	rts

icmd0A:
	dec a1A
	bne icmd0B_which_box
	jmp icmd0A_probe_boxes

icmd0B_which_box:
	dec a1A
	beq :+
	jmp icmd0C_which_food

:	lda gs_player_x
	asl
	asl
	asl
	asl
	clc
	adc gs_player_y
	sta a11
	lda #>(gs_item_locs+1)
	sta a0F
	lda #<(gs_item_locs+1)
	sta a0E
	lda #items_unique + items_food + items_torches
	sta a1A
	ldy #$00
	lda a11
@check_is_here:
	cmp (p0E),y
	beq @check_level
@not_here:
	iny
	iny
	dec a1A
	bne @check_is_here

	lda #>gs_item_locs
	sta a0F
	lda #<gs_item_locs
	sta a0E
	lda #noun_snake-1
	sta a1A
	lda #carried_boxed
	ldy #$00
@check_is_carried:
	cmp (p0E),y
	beq @return_item_num
	iny
	iny
	dec a1A
	bne @check_is_carried

; Skip over snake
	lda #>gs_item_food_torch
	sta a0F
	lda #<gs_item_food_torch
	sta a0E
	lda #items_food + items_torches
	sta a1A
	ldy #$00
@next_other:
	cmp (p0E),y
	beq @return_item_num
	iny
	iny
	dec a1A
	bne @next_other

; Last, check for carrying boxed snake
	ldx #>gs_item_snake
	stx a0F
	ldx #<gs_item_snake
	stx a0E
	ldy #$00
	cmp (p0E),y
	beq @return_item_num
	lda #$00
	rts

@check_level:
	dec a0E
	lda (p0E),y
	sta a13
	inc a0E
	dey
	lda a13
	cmp gs_level
	beq @return_item_num
	iny
	lda a11
	jmp @not_here

@return_item_num:
	clc
	tya
	bpl :+
	lda #$00     ;clamp min 0
:	adc a0E
	sta a0E
	lda #$00
	adc a0F
	sta a0F
	sec
	lda a0E
	sbc #<gs_item_locs
	clc
	ror
	clc
	adc #$01
	rts

icmd0C_which_food:
	dec a1A
	bne icmd0D_which_torch
	lda #items_food
	sta a11
	lda #carried_known
	sta a10
	lda #icmd_where
	sta a0F
	lda #item_food_begin
	sta a0E
find_which_multiple:
	lda a0F
	pha
	lda a0E
	pha
	jsr item_cmd
	lda a10
	cmp a1A
	beq @found
	pla
	sta a0E
	pla
	sta a0F
	inc a0E
	dec a11
	bne find_which_multiple
	lda #$00
	rts

@found:
	pla
	sta a0E
	pla
	lda a0E
	rts

icmd0D_which_torch:
	dec a1A
	bne icmd0E_which_torch
	lda #items_torches
	sta a11
	lda #carried_active
	sta a10
	bne set_action
icmd0E_which_torch:
	dec a1A
	bne icmd_default
	lda #items_torches
	sta a11
	lda #carried_known
	sta a10
set_action:
	lda #icmd_where
	sta a0F
	lda #item_torch_begin
	sta a0E
	jsr find_which_multiple
icmd_default:
	rts

icmd0A_probe_boxes:
	lda gs_walls_right_depth
	and #$e0
	lsr
	lsr
	lsr
	lsr
	lsr
	beq @none
	cmp #$05
	bne :+
	sec
	sbc #$01
:	sta a1A
	lda gs_player_x
	sta a11
	lda gs_player_y
	sta a10
	lda gs_level
	sta a19
	jmp @begin_probe

@none:
	lda #$00
	sta gs_box_visible
	rts

@begin_probe:
	lda a1A
	sta a0F
	lda #$00
	sta a0E
@next_pos:
	lda gs_facing
	jsr move_pos_facing
	jsr any_item_here
	dec a1A
	beq @shift_remainder
	lsr a0E
	jmp @next_pos

@shift_remainder:
	lda #$04
	sec
	sbc a0F
	beq @done
:	lsr a0E
	sec
	sbc #$01
	bne :-
@done:
	lda a0E
	sta gs_box_visible
	rts

any_item_here:
	pha
	lda a11
	pha
	lda a10
	pha
	lda a0F
	pha
	lda a0E
	pha
	lda a11
	asl
	asl
	asl
	asl
	clc
	adc a10
	pha
	lda #>(gs_item_locs+1)
	sta a0F
	lda #<(gs_item_locs+1)
	sta a0E
	lda #items_total
	sta a11
	pla
	ldy #$00
@next_item:
	cmp (p0E),y
	beq @match_position
@continue:
	iny
	iny
	dec a11
	bne @next_item
	pla
	sta a0E
	pla
	sta a0F
@done:
	pla
	sta a10
	pla
	sta a11
	pla
	rts

@match_position:
	sta a10
	dec a0E
	lda (p0E),y
	inc a0E
	cmp a19
	beq @match_level
	lda a10
	jmp @continue

@match_level:
	pla
	sta a0E
	pla
	sta a0F
	lda a0E
	clc
	adc #$08
	sta a0E
	bne @done

move_pos_facing:
	cmp #facing_W
	beq @west
	cmp #facing_N
	beq @north
	cmp #facing_E
	beq @east
@south:
	dec a10
	rts

@west:
	dec a11
	rts

@north:
	inc a10
	rts

@east:
	inc a11
	rts

get_maze_feature:
	lda gs_facing
	asl
	asl
	asl
	asl
	clc
	adc gs_level
	sta a11
	lda gs_player_x
	asl
	asl
	asl
	asl
	clc
	adc gs_player_y
	sta a10
	lda #>maze_features
	sta a0F
	lda #<maze_features
	sta a0E
	lda #maze_features_end
	sta a19
	ldy #$00
	lda a11
@next:
	cmp (p0E),y
	beq @check_position
	iny
@continue:
	iny
	iny
	iny
	dec a19
	bne @next
	lda #$00
	sta a0F
	sta a0E
	rts

@check_position:
	lda a10
	iny
	cmp (p0E),y
	beq @match
	lda a11
	bne @continue
@match:
	iny
	lda (p0E),y
	sta a11
	iny
	lda (p0E),y
	sta a0E
	lda a11
	sta a0F
	rts

keyhole_0:
	.byte $06,$0b,$0b,$07,$0b,$0b,$0b,$0b
	.byte $0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b
	.byte $08,$0b,$0b,$09,$20,$0b,$0b,$20
	.byte $20,$0b,$0b,$20,$0b,$0b,$0b,$0b
	.byte $0b,$0b,$0b,$0b

draw_special:
	ldy a0F
	dey
	bne @draw_2_elevator
@draw_1_keyhole:
	lda #$09
	sta a1A
	sta zp_col
	lda #$06
	sta zp_row
	jsr get_rowcol_addr
	lda #>keyhole_0
	sta a0B
	lda #<keyhole_0
	sta a0A
	ldy #$00
@next_row:
	lda #$04
	sta a19
@next_glyph:
	tya
	pha
	lda (p0A),y
	jsr print_char
	pla
	tay
	iny
	dec a19
	bne @next_glyph
	dec a1A
	beq @done
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
	jmp @next_row

@done:
	rts

@draw_2_elevator:
	dey
	bne @draw_3_compactor

	lda #$03
	sta zp_row
	lda #$05
	sta zp_col
	lda #glyph_R
	ldy #$12
	jsr draw_down
	lda #$03
	sta zp_row
	lda #$0a
	sta zp_col
	lda #glyph_R
	ldy #$12
	jsr draw_down
	lda #$03
	sta zp_row
	lda #$10
	sta zp_col
	lda #glyph_L
	ldy #$12
	jsr draw_down
	lda #>raster 20,0,7
	sta screen_ptr+1
	lda #<raster 20,0,7
	sta screen_ptr
	ldy #$14
	jsr draw_right
	lda #<raster 2,5,7
	sta screen_ptr
	lda #>raster 2,5,7
	sta screen_ptr+1
	ldy #$0a
	jsr draw_right
	lda #$07
	sta zp_col
	lda #$01
	sta zp_row
	jsr get_rowcol_addr
	lda #>@string_elevator
	sta a0B
	lda #<@string_elevator
	sta a0A
	ldy #$00
	lda #$08
	sta a1A
:	tya
	pha
	lda (p0A),y
	jsr print_char
	pla
	tay
	iny
	dec a1A
	bne :-
	rts

@string_elevator:
	.byte "ELEVATOR"

@draw_3_compactor:
	dey
	beq :+
	jmp @draw_4_pit_floor

:	lda #$06
	sta a0C
@next_frame_3:
	lda #$00
	sta zp_row
	lda #$06
	sec
	sbc a0C
	sta zp_col
	pha
	lda #' '
	ldy #$15
	jsr draw_down
	pla
	pha
	sta zp_col
	inc zp_col
	lda #$00
	sta zp_row
	lda #glyph_R
	ldy #$15
	jsr draw_down
	pla
	pha
	sta zp_col
	inc zp_col
	inc zp_col
	lda #$01
	sta zp_row
	jsr get_rowcol_addr
	lda #' '
	jsr char_out
	inc zp_row
	jsr get_rowcol_addr
	lda #' '
	jsr char_out
	pla
	sta zp_col
	inc zp_col
	inc zp_col
	lda #$00
	sta zp_row
	ldy #$04
	jsr draw_down_right
	dec zp_col
	dec zp_col
	lda zp_col
	pha
	lda zp_row
	pha
	dec zp_row
	lda #' '
	ldy #$0f
	jsr draw_down
	dec zp_col
	jsr get_rowcol_addr
	lda #' '
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #' '
	jsr char_out
	pla
	sta zp_row
	pla
	sta zp_col
	inc zp_col
	lda #glyph_R
	ldy #$0d
	jsr draw_down
	ldy #$04
	jsr draw_down_left
	lda #$00
	sta zp_row
	lda #$10
	clc
	adc a0C
	sta zp_col
	pha
	lda #' '
	ldy #$15
	jsr draw_down
	pla
	pha
	sta zp_col
	dec zp_col
	lda #$00
	sta zp_row
	lda #glyph_L
	ldy #$15
	jsr draw_down
	pla
	pha
	sta zp_col
	dec zp_col
	dec zp_col
	lda #$01
	sta zp_row
	jsr get_rowcol_addr
	lda #' '
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
	jsr draw_down_left
	inc zp_col
	inc zp_col
	lda zp_col
	pha
	lda zp_row
	pha
	dec zp_row
	lda #' '
	ldy #$0f
	jsr draw_down
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
	lda #glyph_L
	ldy #$0d
	jsr draw_down
	ldy #$04
	jsr draw_down_right
	dec a0C
	beq :+
	jsr wait_brief
	jmp @next_frame_3

:	rts

@pit_floor_data:
	.byte $11,$11,$04,$05,$11,$04,$40,$d4
	.byte $0d,$5e,$50,$15,$0e,$0e,$03,$08
	.byte $0e,$03,$43,$2f,$07,$5c,$54,$0d

; Input: $0E = distance (0,1)
@draw_4_pit_floor:
	dey
	bne @draw_5_pit_roof

	lda #<@pit_floor_data
	sta a0A
	lda #>@pit_floor_data
	sta a0B
	lda #$02
	sta a19
	lda a0E
	beq @pit_walls
	ldy #$0c
@pit_walls:
	lda (p0A),y
	sta zp_col
	iny
	lda (p0A),y
	sta zp_row
	iny
	lda (p0A),y
	iny
	sta a1A
	tya
	pha
	lda a1A
	tay
	lda #$02     ;glyph_R, then glyph_L
	clc
	adc a19
	jsr draw_down
	pla
	tay
	dec a19
	bne @pit_walls
	lda #$02
	sta a19
@pit_rim:
	lda (p0A),y
	sta screen_ptr+1
	iny
	lda (p0A),y
	sta screen_ptr
	iny
	lda (p0A),y
	sta a1A
	iny
	tya
	pha
	lda a1A
	tay
	jsr draw_right
	pla
	tay
	dec a19
	bne @pit_rim
	rts

@pit_roof_data:
	.byte $11,$00,$04,$05,$00,$04,$40,$00
	.byte $15,$42,$04,$0d,$0e,$04,$03,$08
	.byte $04,$03,$42,$04,$0d,$43,$87,$07
	.byte $0c,$07,$02,$0a,$07,$02,$43,$87
	.byte $07,$40,$b1,$03

@draw_5_pit_roof:
	dey
	bne @draw_6_boxes

	lda #<@pit_roof_data
	sta a0A
	lda #>@pit_roof_data
	sta a0B
	lda #$02
	sta a19
	ldy a0E
	beq :+
	dey
	beq @pit_walls
	ldy #$0c
	jmp @pit_walls

:	ldy #$18
	jmp @pit_walls

@draw_6_boxes:
	dey
	beq @draw_box_4
	jmp @draw_7_the_square

@draw_box_4:
	lda gs_box_visible
	and #(1 << 3)
	beq @draw_box_3
	lda #$0b
	sta zp_col
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_box
	jsr char_out
@draw_box_3:
	lda gs_box_visible
	and #(1 << 2)
	beq @draw_box_2
	lda #$0a
	sta zp_col
	lda #$0c
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_box_TL
	jsr char_out
	lda #glyph_box_T
	jsr char_out
	lda #glyph_box_TR
	jsr char_out
	lda #$0a
	sta zp_col
	lda #$0d
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_box_BL
	jsr char_out
	lda #glyph_box_B
	jsr char_out
	lda #glyph_box_BR
	jsr char_out
@draw_box_2:
	lda gs_box_visible
	and #(1 << 1)
	beq @draw_box_1
	lda #$09
	sta zp_col
	lda #$0e
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_box_TL
	jsr char_out
	lda #glyph_box_T
	jsr char_out
	lda #glyph_box_T
	jsr char_out
	lda #glyph_box_T
	jsr char_out
	lda #glyph_box_TR
	jsr char_out
	lda #$09
	sta zp_col
	lda #$0f
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_L
	jsr char_out
	inc zp_col
	inc zp_col
	inc zp_col
	jsr get_rowcol_addr
	lda #glyph_box_R
	jsr char_out
	dec zp_col
	inc zp_row
	jsr get_rowcol_addr
	lda #glyph_box_BR
	jsr char_out
	lda #$09
	sta zp_col
	jsr get_rowcol_addr
	lda #glyph_L
	jsr char_out
	lda #>raster $11,8,0
	sta screen_ptr+1
	lda #<raster $11,8,0
	sta screen_ptr
	ldy #$04
	jsr draw_right
@draw_box_1:
	lda gs_box_visible
	and #(1 << 0)
	beq @box_done
	lda #$0e
	sta zp_col
	lda #$11
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_slash_up
	jsr char_out
	lda #$07
	sta zp_col
	jsr get_rowcol_addr
	ldy #$07
	jsr draw_right
	lda #glyph_slash_up
	jsr char_out
	lda #$06
	sta zp_col
	lda #$12
	sta zp_row
	lda #glyph_R
	ldy #$03
	jsr draw_down
	lda #$0d
	sta zp_col
	lda #$12
	sta zp_row
	lda #glyph_R
	ldy #$03
	jsr draw_down
	dec zp_row
	inc zp_col
	jsr get_rowcol_addr
	lda #glyph_slash_up
	jsr char_out
	lda #>raster 18,6,0
	sta screen_ptr+1
	lda #<raster 18,6,0
	sta screen_ptr
	ldy #$07
	jsr draw_right
	lda #$0f
	sta zp_col
	lda #$11
	sta zp_row
	lda #glyph_L
	tay
	jsr draw_down
	ldx #>raster 20,6,7
	stx screen_ptr+1
	ldx #<raster 20,6,7
	stx screen_ptr
	ldy #$07
	jsr draw_right
@box_done:
	rts

@square_data_left:
	.byte $07,$20,$0b,$07,$0b,$0b,$0b,$0b
	.byte $0b,$0b,$0b,$09,$09,$20
@square_data_right:
	.byte $20,$06,$06,$0b,$0b,$0b,$0b,$0b
	.byte $0b,$0b,$08,$0b,$20,$08
@string_square:
	.byte "THEPERFECTSQUARE"

; Input: 0E = 1 right, 2 front, 4 left
@draw_7_the_square:
	dey
	beq :+
	jmp @draw_8_doors

:	lda a0E
	cmp #$01
	beq @square_right
	cmp #$04
	bne @square_front
	jmp @square_left

@square_front:
	lda #$08
	sta zp_col
	pha
	lda #$07
	sta zp_row
	pha
@sq_next_col:
	lda #glyph_solid
	ldy #$07
	jsr draw_down
	pla
	sta zp_row
	pla
	sta zp_col
	inc zp_col
	lda zp_col
	cmp #$0f
	beq @sq_sign
	pha
	lda zp_row
	pha
	jmp @sq_next_col

@sq_sign:
	lda #<@string_square
	sta a0A
	lda #>@string_square
	sta a0B
	lda #$0a
	sta zp_col
	lda #$04
	sta zp_row
	jsr get_rowcol_addr
	lda #$03
	sta a1A
	jsr @print_square_row
	lda #$08
	sta zp_col
	lda #$05
	sta zp_row
	jsr get_rowcol_addr
	lda #$07
	sta a1A
	jsr @print_square_row
	lda #$09
	sta zp_col
	lda #$06
	sta zp_row
	jsr get_rowcol_addr
	lda #$06
	sta a1A
@print_square_row:
	ldy #$00
	lda (p0A),y
	jsr char_out
	inc a0A
	bne :+
	inc a0B
:	dec a1A
	bne @print_square_row
	rts

@square_right:
	lda #<@square_data_right
	sta a0A
	lda #>@square_data_right
	sta a0B
	lda #$13
	sta zp_col
	lda #$07
	sta zp_row
	sta a1A
@sq_next_row:
	jsr get_rowcol_addr
	ldy #$00
	lda (p0A),y
	jsr char_out
	inc a0A
	bne :+
	inc a0B
:	ldy #$00
	lda (p0A),y
	jsr char_out
	inc a0A
	bne :+
	inc a0B
:	inc zp_row
	dec zp_col
	dec zp_col
	dec a1A
	bne @sq_next_row
	rts

@square_left:
	lda #<@square_data_left
	sta a0A
	lda #>@square_data_left
	sta a0B
	lda #$02
	sta zp_col
	lda #$07
	sta zp_row
	sta a1A
	jmp @sq_next_row

@draw_8_doors:
	dey
	beq :+
	jmp @draw_9_keyholes

:	lda a0E
	cmp #$04
	bne @door_2_right
	jmp @door_1_left

@door_2_right:
	cmp #$02
	beq @door_1_right
	lda #$10
	sta zp_col
	lda #$08
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_slash_up_C
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	lda #glyph_LR
	ldy #$05
	jsr draw_down
	jsr get_rowcol_addr
	lda #glyph_slash_down_R
	jsr char_out
	inc zp_row
	jsr get_rowcol_addr
	lda #glyph_slash_down_C
	jsr char_out
	lda #$10
	sta zp_col
	lda #$09
	sta zp_row
	lda #glyph_C
	ldy #$06
	jsr draw_down
	lda #$11
	sta zp_col
	lda #$08
	sta zp_row
	lda #glyph_L
	ldy #$08
	jsr draw_down
	rts

@door_1_right:
	lda #$14
	sta zp_col
	lda #$04
	sta zp_row
	ldy #$02
	jsr draw_down_left
	inc zp_col
	lda #glyph_L
	ldy #$0c
	jsr draw_down
	lda #$14
	sta zp_col
	lda #$05
	sta zp_row
	lda #glyph_L
	ldy #$0e
	jsr draw_down
	lda #$15
	sta zp_col
	lda #$04
	sta zp_row
	lda #glyph_L
	ldy #$10
	jsr draw_down
	rts

@door_1_left:
	lda #$02
	sta zp_col
	lda #$04
	sta zp_row
	ldy #$02
	jsr draw_down_right
	dec zp_col
	lda #glyph_R
	ldy #$0c
	jsr draw_down
	lda #$02
	sta zp_col
	lda #$05
	sta zp_row
	lda #glyph_R
	ldy #$0e
	jsr draw_down
	lda #$01
	sta zp_col
	lda #$04     ;also glyph_R
	sta zp_row
	ldy #$10
	jsr draw_down
	rts

@draw_9_keyholes:
	dey
	beq :+
	jmp @draw_A_special

:	lda a0E
	and #$0f
	beq @keyhole_L_1
@keyhole_R_4:
	and #(1 << 3)
	beq @keyhole_R_3
	lda #$0c
	sta zp_col
	jsr draw_keyhole_4
@keyhole_R_3:
	lda a0E
	and #(1 << 2)
	beq @keyhole_R_2
	lda #$0d
	sta zp_col
	jsr draw_keyhole_3
@keyhole_R_2:
	lda a0E
	and #(1 << 1)
	beq @keyhole_R_1
	lda #$0f
	sta zp_col
	jsr draw_keyhole_2
@keyhole_R_1:
	lda a0E
	and #(1 << 0)
	beq @keyhole_R_done
	lda #$13
	sta zp_col
s244B:
	jsr draw_keyhole_1
@keyhole_R_done:
	rts

@keyhole_L_1:
	lda a0E
	and #(1 << 4)
	beq @keyhole_L_2
	lda #$02
	sta zp_col
	jsr draw_keyhole_1
@keyhole_L_2:
	lda a0E
	and #(1 << 5)
	beq @keyhole_L_3
	lda #$05
	sta zp_col
	jsr draw_keyhole_2
@keyhole_L_3:
	lda a0E
	and #(1 << 6)
	beq @keyhole_L_4
	lda #$08
	sta zp_col
	jsr draw_keyhole_3
@keyhole_L_4:
	lda a0E
	and #(1 << 7)
	beq @keyhole_L_done
	lda #$0a
	sta zp_col
	jsr draw_keyhole_4
@keyhole_L_done:
	rts

draw_keyhole_1:
	lda #$08
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_solid_BR
	jsr char_out
	lda #glyph_solid_BL
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #glyph_solid
	jsr char_out
	lda #glyph_solid
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #glyph_solid_TR
	jsr char_out
	lda #glyph_solid_TL
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #glyph_angle_BR
	jsr char_out
	lda #glyph_angle_BL
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #glyph_solid
	jsr char_out
	lda #glyph_solid
	jsr char_out
	rts

draw_keyhole_2:
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

draw_keyhole_3:
	lda #$0a
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_keyhole_R
	jsr char_out
	lda #glyph_keyhole_L
	jsr char_out
	rts

draw_keyhole_4:
	lda #$0a
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_keyhole_C
	jsr char_out
	rts

@draw_A_special:
	lda #$0a
	sta zp_col
	lda #$03     ;also glyph_L
	sta zp_row
	ldy #$12
	jsr draw_down
	lda #$0b
	sta zp_col
	lda #$03
	sta zp_row
	lda #glyph_R
	ldy #$12
	jsr draw_down
	lda #>raster 17,9,0
	sta screen_ptr+1
	lda #<raster 17,9,0
	sta screen_ptr
	ldy #$02
	jsr draw_right
	lda #$0a
	sta a0C
	lda #$0b
	sta a19
	lda #$04
	sta a11
	lda #$02
	sta a10
@next_frame_opening:
	jsr wait_brief
	lda a0C
	sta zp_col
	lda #$03
	sta zp_row
	lda #' '
	ldy #$12
	jsr draw_down
	lda a19
	sta zp_col
	lda #$03
	sta zp_row
	lda #' '
	ldy #$12
	jsr draw_down
	dec a0C
	inc a19
	lda a0C
	sta zp_col
	lda #$03     ;also glyph_L
	sta zp_row
	ldy #$12
	jsr draw_down
	lda a19
	sta zp_col
	lda #$03
	sta zp_row
	lda #glyph_R
	ldy #$12
	jsr draw_down
	lda #$11
	sta zp_row
	dec a0C
	lda a0C
	inc a0C
	sta zp_col
	jsr get_rowcol_addr
	inc a10
	inc a10
	ldy a10
	jsr draw_right
	dec a11
	bne @next_frame_opening
	rts

print_noun:
	sta a13
	lda #<noun_table
	sta a0C
	lda #>noun_table
	sta a0D
	ldy #$00
@find_string:
	lda (p0C),y
	bmi @found_start
@next_char:
	inc a0C
	bne @find_string
	inc a0D
	bne @find_string
@found_start:
	dec a13
	bne @next_char
	lda (p0C),y
	and #$7f
@print_char:
	jsr char_out
	inc a0C
	bne :+
	inc a0D
:	ldy #$00
	lda (p0C),y
	bpl @print_char
	lda #' '
	jmp char_out

wait_brief:
	ldx #$28
	stx a0F
:	dec a0E
	bne :-
	dec a0F
	bne :-
	rts

; junk
	.byte $10,$ad,$09,$01,$20,$02,$34,$ad
	.byte $08,$01,$20,$02,$34,$60,$a9,$00
	.byte $9d,$00,$01,$9d,$01,$01,$85,$df
	.byte $85,$e0,$20,$6e

player_cmd:
	lda gd_parsed_object
	sta a0E
	lda gd_parsed_action
	sta a0F
	cmp #$0e
	bmi :+
	jmp cmd_look

:	lda a0E
	cmp #nouns_item_end
	bmi :+
	jmp nonsense

:	jsr noun_to_item
	sta a11
	lda gd_parsed_object
	sta a0E
	lda gd_parsed_action
	sta a0F

cmd_raise:
	dec a0F
	bne @cmd_blow

	lda #noun_ring
	cmp a0E
	beq @ring
	lda #noun_staff
	cmp a0E
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
	cmp a1A
	beq @having_fun
	lda #noun_ring
	sta a0E
	lda #icmd_set_carried_active
	sta a0F
	jsr item_cmd
	lda #$01
	sta gs_room_lit
	jsr update_view
	lda #$71     ;The ring is activated and
	jsr print_to_line1
	lda #$72     ;shines light everywhere!
	bne @print_line2

@cmd_blow:
	dec a0F
	bne cmd_break

	lda a0E
	cmp #noun_flute
	beq @play
	cmp #noun_horn
	bne @having_fun
	lda gs_level
	cmp #$05
	bne :+
	lda gs_special_mode
	cmp #special_mode_mother
	bne :+
	lda #noun_horn
	sta a0E
	lda #icmd_set_carried_active
	sta a0F
	jsr item_cmd
:	lda #$7f     ;A deafening roar envelopes
	jsr print_to_line1
	lda #$80     ;you. Your ears are ringing!
	jsr print_to_line2
	rts

@play:
	lda #noun_play - noun_blow
	sta a0F
cmd_break:
	dec a0F
	bne cmd_burn

	lda a0E
	cmp #noun_ring
	bne :+
	jsr lose_ring
:	cmp #nouns_unique_end
	bmi @broken
	sta a13
	lda a10
	pha
	lda a11
	pha
	lda a13
	cmp #noun_torch
	bne :+
	jsr lose_one_torch
:	pla
	sta a11
	pla
	sta a10
	lda a11
	sta a0E
@broken:
	jsr item_cmd
	ldx #$07
	stx a0F
	jsr item_cmd
	lda #$4e     ;You break the
	jsr print_to_line1
	lda #$20
	jsr char_out
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
	lda #special_mode_dark
	sta gs_special_mode
@done:
	rts

@unlit:
	dec gs_torches_unlit
	lda #icmd_which_torch_unlit
	sta a0F
	jsr item_cmd
	sta a0E
	lda #icmd_destroy1
	sta a0F
	jmp item_cmd

cmd_burn:
	dec a0F
	bne cmd_eat

	lda gs_torches_lit
	beq @no_fire
	lda a0E
	cmp #noun_ring
	bne :+
	jsr lose_ring
:	cmp #nouns_unique_end
	bmi @burned
	cmp #noun_torch
	beq make_cmd_light
	lda a11
	sta a0E
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
	sta a0F
cmd_eat:
	dec a0F
	beq :+
	jmp cmd_throw

:	lda a0E
	cmp #noun_ring
	bne :+
	jsr lose_ring
:	cmp #nouns_unique_end
	bmi @eaten
	beq @food
	cmp #noun_torch
	beq @torch
@torch_return:
	lda a11
	sta a0E
@eaten:
	jsr item_cmd
	jsr update_view
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
	sta a0F
	jmp item_cmd

@torch:
	lda a10
	pha
	lda a11
	pha
	jsr lose_one_torch
	pla
	sta a11
	pla
	sta a10
	jmp @torch_return

@food:
	lda a11
	sta a0E
	jsr item_cmd
	lda gs_food_time_hi
	sta a0F
	lda gs_food_time_lo
	sta a0E
	lda #<food_amount
	sta a19
	lda #>food_amount
	sta a1A
	clc
	lda a19
	adc a0E
	sta a0E
	lda a1A
	adc a0F
	sta a0F
	sta gs_food_time_hi
	lda a0E
	sta gs_food_time_lo
	lda #$58     ;Digested
	bne @print

lose_ring:
	lda gs_level
	cmp #$05
	bne @done
	lda #$00
	sta gs_room_lit
	lda gs_mother_alive
	beq @done
	lda #special_mode_dark
	sta gs_special_mode
	jsr clear_maze_window
@done:
	lda #$0b
	rts

cmd_throw:
	dec a0F
	beq :+
	jmp cmd_climb

:	lda a0E
	cmp #noun_ring
	bne :+
	jsr lose_ring
:	cmp #noun_frisbee
	bne :+
	jmp throw_frisbee

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
:	lda a11
	sta a0E
@thrown:
	jsr item_cmd
	jsr print_thrown
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
	lda gs_level_moves_lo
	cmp #moves_until_trippable
	bcc @thrown
	jsr push_special_mode
	lda #special_mode_tripped
	sta gs_special_mode
	lda #noun_wool
	sta a0E
	lda #icmd_destroy1
	sta a0F
	jsr item_cmd
	jsr print_thrown
	lda #$5e     ;and the monster grabs it,
	jsr print_to_line1
	lda #$5f     ;gets tangled, and topples over!
	jsr print_to_line2
	lda #$00
	sta gs_monster_proximity
	rts

@throw_yoyo:
	jsr print_thrown
	lda #$6b     ;returns and hits you
	jsr print_to_line1
	lda #$6c     ;in the eye!
	jmp print_to_line2

@throw_food:
	lda a11
	sta a0E
	jsr item_cmd
	lda #icmd_draw_inv
	sta a0F
	jsr item_cmd
	lda #$81     ;Food fight!
	jmp print_to_line2

print_thrown:
	lda #icmd_draw_inv
	sta a0F
	jsr item_cmd
	lda #$59     ;The
	jsr print_to_line1
	lda gd_parsed_object
	jsr print_noun
	jsr dec_item_ptr
	lda #' '
	ldy #$00
	cmp (p0E),y
	beq :+
	inc a0E
	bne :+
	inc a0F
:	inc a0E
	bne :+
	inc a0F
:	lda #$5a     ;magically sails
	jsr print_display_string
	lda #$5b     ;around a nearby corner
	jsr print_to_line2
	jsr wait_long
	jmp clear_status_lines

throw_frisbee:
	lda gs_monster_alive
	and #$02
	bne :+
	jmp @thrown

:	lda #noun_frisbee
	sta a0E
	lda #icmd_destroy1
	sta a0F
	jsr item_cmd
	jsr print_thrown
	jsr clear_status_lines
	lda #$3f     ;The monster grabs the frisbee, throws
	jsr print_to_line1
	lda #$40     ;it back, and it saws your head off!
	jsr print_to_line2
	jsr wait_long
	jmp game_over

cmd_climb:
	dec a0F
	bne cmd_drop
	jmp nonsense ;Climbing only possible during special_climb

cmd_drop:
	dec a0F
	bne cmd_fill

	jsr swap_saved_vars
	lda #icmd_which_box
	sta a0F
	jsr item_cmd
	cmp #$00
	beq @vacant_at_feet
	sta a0E
	lda #icmd_where
	sta a0F
	jsr item_cmd
	lda a1A
	cmp #carried_begin
	bcs @vacant_at_feet
	lda #$82     ;The hallway is too crowded.
	jsr print_to_line2
	jmp swap_saved_vars

@vacant_at_feet:
	jsr swap_saved_vars
	lda a0E
	cmp #nouns_unique_end
	bpl @multiples
	cmp #noun_ring
	bne @dropped
	jsr lose_ring
@dropped:
	lda #icmd_drop
	sta a0F
	jsr item_cmd
	ldx #icmd_draw_inv
	stx a0F
	jmp item_cmd

@multiples:
	cmp #noun_torch
	beq @torch_unlit
	lda a11
	sta a0E
	jmp @dropped

@torch_unlit:
	lda #icmd_which_torch_unlit
	sta a0F
	jsr item_cmd
	beq @torch_lit
	dec gs_torches_unlit
	jmp @dropped

@torch_lit:
	lda #icmd_which_torch_lit
	sta a0F
	jsr item_cmd
	sta a0E
	dec gs_torches_lit
	jsr push_special_mode
	lda #$00
	sta gs_room_lit
	sta gs_torches_lit
	lda #special_mode_dark
	sta gs_special_mode
	jsr clear_maze_window
	jmp @dropped

cmd_fill:
	dec a0F
	bne cmd_light

	lda a0E
	cmp #noun_jar
	beq :+
	jmp nonsense

:	lda #$89     ;With what? Air?
	jmp print_to_line2

cmd_light:
	dec a0F
	bne cmd_play

	sta a11
	lda a0E
	cmp #noun_torch
	beq :+
	jmp nonsense

:	lda a1A
	cmp #carried_active
	bne cmd_light_impl
	jmp not_carried

cmd_light_impl:
	lda gs_room_lit
	bne @have_fire
	lda #$88     ;You have no fire.
	jsr print_to_line2
	lda #icmd_draw_inv
	sta a0F
	jmp item_cmd

@have_fire:
	lda #icmd_which_torch_lit
	sta a0F
	jsr item_cmd
	cmp #$00
	beq @light_torch
	sta a0E
	lda #icmd_destroy2
	sta a0F
	jsr item_cmd
@light_torch:
	lda #icmd_which_torch_unlit
	sta a0F
	jsr item_cmd
	sta a0E
	lda #icmd_set_carried_active
	sta a0F
	jsr item_cmd
	jsr clear_status_lines
	lda #$65     ;The torch is lit and the
	jsr print_to_line1
	lda #$66     ;old torch dies and vanishes!
	jsr print_to_line2
	dec gs_torches_unlit
	lda #icmd_draw_inv
	sta a0F
	jsr item_cmd
	lda #torch_lifespan
	sta gs_torch_time
	rts

cmd_play:
	dec a0F
	beq :+
	jmp cmd_strike

:	lda a0E
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
	sta a0E
	lda #icmd_where
	sta a0F
	jsr item_cmd
	lda a1A
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
	sta a11
:	dec a10
	bne :-
	dec a11
	bne :-
	dec zp_col
	dec zp_col
	dec zp_col
	dec zp_row
	bpl @draw_snake
	lda #icmd_set_carried_active
	sta a0F
	lda #noun_snake
	sta a0E
	jsr item_cmd
	jsr push_special_mode
	lda #special_mode_climb
	sta gs_special_mode
	lda #$00
	sta gs_snake_used
	rts

cmd_strike:
	dec a0F
	bne cmd_wear

	lda a0E
	cmp #noun_staff
	beq :+
	jmp nonsense

:	jsr clear_status_lines
	lda #$21     ;Thunderbolts shoot out above you!
	jsr print_to_line1
	lda #$22     ;The staff thunders with uselss energy!
	jmp print_to_line2

cmd_wear:
	dec a0F
	beq :+
	rts

:	lda a0E
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
	sta a0F
	jsr item_cmd
	jmp @print

cmd_look:
	lda a0F
	sec
	sbc #$0e
	sta a0F
	bne cmd_rub

	lda a0E
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
	dec a0F
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
	dec a0F
	beq :+
	jmp cmd_press

:	lda a0E
	cmp #noun_door
	bne :+
	jmp @open_door

:	cmp #noun_box
	beq @open_box
	jmp nonsense

@open_box:
	lda #icmd_which_box
	sta a0F
	jsr item_cmd
	sta a11
	beq look_not_here
	lda a10
	pha
	lda a11
	pha
	sta a0E
	lda #icmd_where
	sta a0F
	jsr item_cmd
	lda a1A
	cmp #carried_begin
	bcs :+
	jmp @check_contents

:	lda a11
	sta a0E
	lda #icmd_set_carried_known
	sta a0F
	jsr item_cmd
@check_contents:
	lda a11
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
	sta a10
	clc
	adc #$04
	jsr print_to_line2
	lda #$18     ;Inside the box there is a
	jsr print_to_line1
	lda a10
	cmp #noun_calculator
	bne :+
	jsr on_reveal_calc
:	sta a13
	cmp #noun_snake
	bne :+
	jsr wait_long
:	pla
	sta a11
	pla
	sta a10
	lda a13
j2C04:
	cmp #noun_torch
	bne @done
	lda #icmd_where
	sta a0F
	lda a11
	sta a0E
	jsr item_cmd
	lda #carried_known
	cmp a1A
	bne @done
	inc gs_torches_unlit
@done:
	lda #icmd_draw_inv
	sta a0F
	jmp item_cmd

@push_mode_snake:
	jsr push_special_mode
	ldx #special_mode_snake
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
	stx a0E
	ldx #icmd_where
	stx a0F
	jsr item_cmd
	lda a1A
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
	ldx #special_mode_bomb
	stx gs_special_mode
	jsr clear_status_lines
	lda #$19     ;You unlock the door...
	jsr print_to_line1
	lda #door_lock_begin + door_correct
	jmp print_to_line2

@push_mode_elevator:
	jsr push_special_mode
	ldx #special_mode_elevator
	stx gs_special_mode
	jmp draw_doors_opening

which_door:
	ldx #$f1
	stx a0E
	ldx #$2c
	stx a0F
	ldx gs_level
	stx a19
	lda gs_player_x
	ldx #$04
	stx a1A
:	asl
	asl a19
	dec a1A
	bne :-
	clc
	adc gs_player_y
	sta a11
	lda a19
	clc
	adc gs_facing
	sta a19
	ldx #$09
	stx a1A
@find:
	ldy #$00
	cmp (p0E),y
	bne @next2
	lda a11
	inc a0E
	bne :+
	inc a0F
:	cmp (p0E),y
	bne @next1
	lda #$0a
	sec
	sbc a1A
	rts

@next2:
	inc a0E
	bne @next1
	inc a0F
@next1:
	inc a0E
	bne :+
	inc a0F
:	lda a19
	dec a1A
	bne @find
	lda #$00
	rts

	.byte $23,$77,$31,$44,$42,$14,$52,$35
	.byte $52,$4a,$52,$5a,$52,$6a,$52,$7a
	.byte $52,$8a

cmd_press:
	dec a0F
	beq :+
	jmp cmd_take

:	lda a0E
	cmp #noun_zero
	bpl :+
	jmp nonsense

:	ldx #icmd_where
	stx a0F
	ldx #noun_calculator
	stx a0E
	jsr item_cmd
	lda a1A
	cmp #carried_known
	beq :+
	jmp not_carried

:	lda gs_monster_alive
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
	adc #'0' - noun_zero
	jmp char_out

@teleport:
	lda gd_parsed_object
	sec
	sbc #noun_zero-1
	ldx #<teleport_table
	stx a0E
	ldx #>teleport_table
	stx a0F
@find_location:
	sec
	sbc #$01
	beq @found
	clc
	pha
	lda #$04
	adc a0E
	sta a0E
	lda a0F
	adc #$00
	sta a0F
	pla
	jmp @find_location

@found:
	ldy #$00
	lda (p0E),y
	sta gs_facing
	inc a0E
	bne :+
	inc a0F
:	lda (p0E),y
	sta gs_level
	inc a0E
	bne :+
	inc a0F
:	lda (p0E),y
	sta gs_player_x
	inc a0E
	bne :+
	inc a0F
:	lda (p0E),y
	sta gs_player_y
	ldx #$00
	stx gs_level_moves_hi
	stx gs_level_moves_lo
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
	stx a0F
	jsr item_cmd
	ldx #icmd_set_carried_known
	stx a0F
	sta a0E
	jsr item_cmd
@teleported:
	ldx #noun_calculator
	stx a0E
	ldx #icmd_destroy2
	stx a0F
	ldx #special_mode_dark
	stx gs_special_mode
	jsr item_cmd
	jsr clear_maze_window
	ldx #icmd_draw_inv
	stx a0F
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
	dec a0F
	beq :+
	jmp cmd_attack

:	ldx #icmd_which_box
	stx a0F
	jsr item_cmd
	tax
	bne :+
	jmp @cannot

:	sta a11
	sta a0E
	ldx #icmd_where
	stx a0F
	jsr item_cmd
	lda gd_parsed_object
	cmp #noun_box
	bne :+
	jmp @take_box

:	cmp #nouns_unique_end
	bmi @unique_item
	jmp @multiple

@unique_item:
	cmp a11
	bne @open_if_carried
	ldx a11
	stx a0E
	lda a1A
	cmp #carried_boxed
	bne @take_if_space ;at feet
j2E72=*+$01
	lda a11
@open_if_carried:
	sta a0E
	ldx #icmd_where
	stx a0F
	jsr item_cmd
	lda #carried_boxed
	cmp a1A
	beq :+
	jmp @cannot

:	ldx gd_parsed_object
	stx a0E
	jmp @take

@ensure_inv_space:
	jsr swap_saved_vars
	ldx #icmd_count_inv
	stx a0F
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
	stx a0F
	jsr item_cmd
@react_taken:
	ldx #icmd_draw_inv
	stx a0F
	jsr item_cmd
	lda gd_parsed_object
	cmp #noun_calculator
	bne :+
	jsr on_reveal_calc
:	cmp #noun_snake
	bne @done
	jsr push_special_mode
	ldx #special_mode_snake
	stx gs_special_mode
@done:
	rts

on_reveal_calc:
	lda gs_special_mode
	cmp #special_mode_calc_puzzle
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
	lda a1A
	cmp #carried_begin
	bpl @cannot
	jsr @ensure_inv_space
	ldx a11
	stx a0E
	ldx #icmd_set_carried_boxed
	stx a0F
	jsr item_cmd
j2EFB:
	jmp @react_taken

@multiple:
	cmp #noun_food
	beq @food

	lda a11
	cmp #item_torch_end
	bpl @find_boxed_torch
	cmp #item_torch_begin
	bmi @find_boxed_torch
	ldx a11
	stx a0E
	lda a1A
	cmp #carried_boxed
	beq @take    ;BUG: get box > get torch: does not increment unlit count if it's the only box
	jsr @ensure_inv_space
	inc gs_torches_unlit
	jmp @take

@food:
	lda a11
	cmp #item_food_end
	bpl @find_boxed_food
	cmp #item_food_begin
	bmi @find_boxed_food
	ldx a11
	stx a0E
	lda a1A
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
	sta a0E
	pla
	sta a0F
	jsr swap_saved_vars
	lda #$99     ;Carrying the limit.
	bne @print_rts

@find_boxed_torch:
	ldx #item_torch_begin - 1
	stx a0E
	bne @begin_search
@find_boxed_food:
	ldx #item_food_begin - 1
	stx a0E
@begin_search:
	lda a0F
	pha
	lda a0E
	pha
	ldx #items_food

; .assert items_food = items_torch, error, "Need to edit cmd_take for separate food,torch counts"
	stx a11      ;count
@next:
	pla
	sta a0E
	pla
	sta a0F
	inc a0E
	bne :+
	inc a0F
:	lda a0F
	pha
	lda a0E
	pha
	ldx #icmd_where
	stx a0F
	jsr item_cmd
	lda #carried_boxed
	cmp a1A
	beq @found
	dec a11
	bne @next
	pla
	sta a0E
	pla
	sta a0F
	jmp @cannot

@found:
	pla
	sta a0E
	pla
	sta a0F
	lda gd_parsed_object
	cmp #noun_torch
	beq :+
	jmp @take

:	inc gs_torches_unlit
	jmp @take

cmd_attack:
	dec a0F
	bne cmd_paint

	lda a0E
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
	dec a0F
	bne cmd_grendel
	ldx #noun_brush
	stx a0E
	ldx #icmd_where
	stx a0F
	jsr item_cmd
	lda a1A
	cmp #carried_known
	beq :+
	jmp not_carried

:	lda #$6f     ;With what? Toenail polish?
	bne @print

cmd_grendel:
	dec a0F
	bne cmd_say
	jmp nonsense ;GUG: maybe disguise this better

cmd_say:
	dec a0F
	bne cmd_charge
	lda gd_parsed_object
	bne b2FF5
	jmp nonsense


b2FF5:
	lda #$76     ;OK...
	jsr print_to_line2
	lda #<text_buffer_line1
	sta a0E
	lda #>text_buffer_line1
	sta a0F
	ldy #$00
	lda #' '
:	cmp (p0E),y
	beq @next_char
	inc a0E
	bne :-
	inc a0F
	bne :-
@echo_word:
	ldy #$00
	lda (p0E),y
	cmp #' '
	beq @done
	sta (p0A),y
	jsr print_char
@next_char:
	inc a0A
	bne :+
	inc a0B
:	inc a0E
	bne @echo_word
	inc a0F
	bne @echo_word
@done:
	rts

cmd_charge:
	dec a0F
	beq @propel_player
	jmp cmd_fart

@propel_player:
	lda #$02
	cmp gs_facing
	bne @normal
	tax          ;GUG: or just "lda #$01"
	dex
	txa
	cmp gs_level
	bne @normal
	cmp gs_player_x
	bne @normal
	lda #$0b
	cmp gs_player_y
	bne @normal
	ldx #noun_hat
	stx a0E
	ldx #icmd_where
	stx a0F
	jsr item_cmd
	lda #carried_active
	cmp a1A
	bne brained
	jsr update_view
	jsr wait_short
	jsr flash_screen
	jsr pit
	inc gs_level
	ldx #$03
	stx gs_player_y
	stx gs_player_x
	ldx #$00
	stx gs_level_moves_hi
	stx gs_level_moves_lo
	jmp update_view

@normal:
	lda gs_walls_right_depth
	and #$e0
	beq brained
	jsr propel_next_step
	jsr wait_short
	jsr update_view
	jmp @propel_player

propel_next_step:
	lda gs_facing ;GUG: no need to use A, just ldx, dex, beq
	tax
	dex
	txa
	beq @west_1
	dex
	txa
	beq @north_2
	dex
	txa
	beq @east_3
@south_4:
	dec gs_player_y
	rts

@west_1:
	dec gs_player_x
	rts

@north_2:
	inc gs_player_y
	rts

@east_3:
	inc gs_player_x
	rts

brained:
	jsr update_view
	jsr wait_short
	jsr flash_screen
	jsr clear_status_lines
	lda #$2a     ;You have rammed your head into a steel
	jsr print_to_line1
	lda #$2b     ;wall and bashed your brains out!
	jsr print_to_line2
	jmp game_over

cmd_fart:
	dec a0F
	beq check_fart
	jmp cmd_save

flash_screen:
	ldx #<screen_GR1
	stx a0E
	ldx #>screen_GR1
	stx a0F
	ldy #$00
@fill:
	lda #$dd     ;yellow
:	sta (p0E),y
	inc a0E
	bne :-
	inc a0F
	lda a0F
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
	jsr update_view
@propel_player:
	lda gs_walls_right_depth
	and #$e0
	beq @wall
	jsr propel_next_step
	lda gs_level
	cmp #$01
	bne @normal
	lda gs_player_x
	cmp #$06
	bne @normal
	lda gs_player_y
	cmp #$0a
	beq @guillotine
@normal:
	jsr count_as_move
	jmp @next_propel

@guillotine:
	jsr update_view
	jsr wait_short
	jmp beheaded

; Deduct food amount (10). If already <=15, set to 5. If <=5, starve.
@wall:
	jsr update_view ;GUG: is this draw necessary?
	ldx gs_food_time_hi
	stx a0F
	ldx gs_food_time_lo
	stx a0E
	lda a0F
	bne @consume_food
	lda a0E
	cmp #food_fart_minimum
	bcs :+
	jmp starved

:	cmp #food_fart_minimum + food_fart_consume
	bcc @clamp_minimum
@consume_food:
	lda #>food_fart_consume
	sta a1A
	lda #<food_fart_consume
	sta a19
	lda a0E
	sec
	sbc a19
	sta a0E
	lda a0F
	sbc a1A
	sta a0F
	sta gs_food_time_hi
	lda a0E
	sta gs_food_time_lo
@wham:
	jsr wait_short
	jsr clear_maze_window
	lda #$2d     ;WHAM!
	ldx #$08
	stx zp_col
	ldx #$0a
	stx zp_row
	jsr print_display_string
	jmp check_special_position

@clamp_minimum:
	ldx #food_fart_minimum
	stx gs_food_time_lo
	bne @wham

cmd_save:
	dec a0F
	bne cmd_quit
	lda gs_special_mode
	beq ask_save_game
	lda #$9a     ;It is currently impossible.
	jmp print_to_line2

ask_save_game:
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
	dec a0F
	bne cmd_directions
	jsr clear_status_lines
	lda #$9c     ;Are you sure you want to quit?
	jsr print_to_line1
	jsr input_Y_or_N
	cmp #$59
	beq :+
	jmp clear_status_lines

:	jsr ask_save_game
	jmp play_again

cmd_directions:
	dec a0F
	bne cmd_hint
	jsr clear_hgr2
	lda #$00
	sta zp_col
	sta zp_row
	jsr get_rowcol_addr
	ldx #<(intro_text-1)
	stx a0E
	ldx #>(intro_text-1)
	stx a0F
@next_char:
	inc a0E
	bne :+
	inc a0F
:	ldy #$00
	lda (p0E),y
	and #$7f
	jsr char_out
	ldy #$00
	lda (p0E),y
	bpl @next_char
	jsr input_char
	jsr clear_hgr2
	jsr update_view
	lda #icmd_draw_inv
	sta a0F
	jmp item_cmd

cmd_hint:
	lda gs_special_mode
	cmp #special_mode_calc_puzzle
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

draw_doors_opening:
	jsr update_view
	lda #$0a
	sta a0F
	jmp draw_special

swap_saved_A:
	sta a13
	lda saved_A
	pha
	lda a13
	sta saved_A
	pla
	rts

swap_saved_vars:
	lda a0E
	tax
	lda saved_zp0E
	sta a0E
	txa
	sta saved_zp0E
	lda a0F
	tax
	lda saved_zp0F
	sta a0F
	txa
	sta saved_zp0F
	lda a10
	tax
	lda saved_zp10
	sta a10
	txa
	sta saved_zp10
	lda a11
	tax
	lda saved_zp11
	sta a11
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
	lda a1A
	sta saved_zp1A
	txa
	sta a1A
	rts

dec_item_ptr:
	pha
	dec a0E
	lda a0E
	cmp #$ff
	bne :+
	dec a0F
:	pla
	rts

text_hat:
	.byte "AN INSCRIPTION READS: WEAR THIS HAT AND "
	.byte "CHARGE A WALL NEAR WHERE YOU FOUND IT!", $A0
look_hat:
	ldx #>text_hat
	stx a0D
	ldx #<text_hat
	stx a0C
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
	lda gs_monster_alive
	and #$02
	rts

:	jsr flash_screen
	jsr clear_hgr2
	jmp game_over

	.byte $95
	jsr s3422
	ldx #$01
	stx a1A
	jsr s33F3
	jsr get_player_input
	lda gd_parsed_action
	cmp #$46
	bpl b337A
	jsr player_cmd
	.byte $20,$19
check_special_mode:
	ldx gs_special_mode
	bne :+
	rts

:	dex
	dex
	beq special_calc_puzzle
b337A:
	jmp special_bat

special_calc_puzzle:
	jsr update_view
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
	jsr count_as_move
	jsr print_timers
	jsr @print_timed_hint
	jmp @puzzle_loop

@move:
	cmp #verb_forward
	beq @bump_into_wall
	sta zp1A_move_action
	lda gs_bomb_tick
	bne @check_repeat_turn
	ldx a1A      ;Set initial turn direction
	stx gs_bomb_tick
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
	jsr update_view
	jsr @init_puzzle
	jmp pop_mode_continue

@new_direction:
	ldx zp1A_move_action
	stx gs_bomb_tick
	lda gs_rotate_target
	cmp gs_rotate_count
	bne :+
	ldx #$01
	stx gs_rotate_count
	dec gs_rotate_target
	jmp @update_display

s33F3=*+$01
:	jsr @reset_target
	inc gs_rotate_count
	ldx zp1A_move_action
	stx gs_bomb_tick
@update_display:
	jsr update_view
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
s3422=*+$01
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
	stx gs_bomb_tick
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

:	jsr update_view
	lda #$31     ;A vampire bat attacks you!
	jsr print_to_line2
	jsr wait_long
j3493=*+$01
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
	jsr print_to_line2
	jmp @bat_loop

@try_action:
	jsr clear_status_lines
	ldx #noun_jar
	stx a0E
	ldx #icmd_where
	stx a0F
	jsr item_cmd
	lda a1A
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
	stx a0F
	ldx #noun_jar
	stx a0E
	jsr item_cmd
	ldx #icmd_draw_inv
	stx a0F
	jsr item_cmd
	ldx #$00
	stx gs_bat_alive
pop_mode_continue:
	lda gs_mode_stack1
	sta a1A
	sta gs_special_mode
	ldx gs_mode_stack2
	stx gs_mode_stack1
	ldx #$00
	stx gs_mode_stack2
	lda a1A
	beq :+
	jmp check_special_mode

:	rts

special_dog:
	dex
	dex
	bne @dog2
	jsr @confront_dog
	ldx #$00
	stx gs_dog1_alive
	jmp pop_mode_continue

@dog2:
	dex
	beq :+
	jmp special_monster

:	jsr @confront_dog
	ldx #$00
	stx gs_dog2_alive
	jmp pop_mode_continue

@confront_dog:
	jsr update_view
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
	stx a0E
	ldx #icmd_where
	stx a0F
	jsr item_cmd
	lda #$08
	cmp a1A
	beq @with_dagger
	ldx #noun_sword
	stx a0E
	ldx #icmd_where
	stx a0F
	jsr item_cmd
	lda #$08
	cmp a1A
	bne @dead
	jsr clear_status_lines
	lda #$97     ;and it vanishes!
	jsr print_to_line2
@killed:
	lda #$63     ;You have killed it.
	jsr print_to_line1
	rts

@with_dagger:
	ldx #icmd_destroy1
	stx a0F
	ldx #noun_dagger
	stx a0E
	jsr item_cmd
	ldx #icmd_draw_inv
	stx a0F
	jsr item_cmd
	lda #$64     ;The dagger disappears!
	jsr print_to_line2
	jmp @killed

@throw:
	lda a1A
	cmp #noun_sneaker
	bne @dead
	ldx #noun_sneaker
	stx a0E
	ldx #icmd_where
	stx a0F
	jsr item_cmd
	lda #$08
	cmp a1A
	bne @dead
	ldx #noun_sneaker
	stx a0E
	ldx #icmd_destroy1
	stx a0F
	jsr item_cmd
	jsr print_thrown
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
	jsr update_view
:	lda gs_monster_proximity
	bne @monster_smell
	jsr wait_if_prior_text
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
	jsr wait_if_prior_text
	jmp check_special_mode

wait_if_prior_text:
	lda text_buffer_line1
	cmp #$80
	beq :+
	cmp #$20
	bne @wait
:	lda text_buffer_line2
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
	jsr update_view
:	lda gs_mother_proximity
	bne @mother_smell
	jsr wait_if_prior_text
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
	stx a0F
	ldx #noun_horn
	stx a0E
	jsr item_cmd
	lda #$07
	cmp a1A
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
	stx a0E
	ldx #icmd_where
	stx a0F
	jsr item_cmd
	lda #$07
	cmp a1A
	bne @input_near_mother
	lda #$49     ;She has been seduced!
	jsr print_to_line2
@input_near_mother:
	lda a1A
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
	sta a1A
	lda #$07
	cmp a1A
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
	sta a1A
	txa
	jmp @input_near_mother

@attack:
	cmp #verb_attack
	bne @dead_pop
	ldx #noun_sword
	stx a0E
	ldx #icmd_where
	stx a0F
	jsr item_cmd
	lda #$08
	cmp a1A
	bne @dead_pop
	pla
	sta a19
	pla
	sta a1A
	lda #$07
	cmp a1A
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
	stx gs_mother_alive
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
	jsr update_view
:	lda gs_room_lit
	beq @unlit
	ldx #$00
	stx gs_mother_proximity
	jmp pop_mode_continue

@unlit:
	ldx #$00
	stx gs_level_moves_lo ;GUG: careful, if I revise to allow re-lighting torch
	lda gs_mother_proximity
	bne @monster_smell
	lda gs_level
	cmp #$05
	beq @check_mother
	lda gs_monster_alive
	and #$02
	bne @tremble
@cancel:
	jmp pop_mode_continue

@check_mother:
	lda gs_mother_alive
	beq @cancel
@tremble:
	jsr wait_if_prior_text
	lda #$43     ;The ground beneath your feet
	jsr print_to_line1
	lda #$44     ;begins to shake!
	jsr print_to_line2
	inc gs_mother_proximity
	jmp input_near_danger

@monster_smell:
	cmp #$01
	bne @monster_attacks
	jsr wait_if_prior_text
	inc gs_mother_proximity
	lda #$45     ;A disgusting odor permeates
	jsr print_to_line1
	lda #$47     ;the hallway!
	jsr print_to_line2
	jmp input_near_danger

@monster_attacks:
	jsr wait_if_prior_text
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
	stx a0E
	ldx #icmd_where
	stx a0F
	jsr item_cmd
	lda a1A
	cmp #$07
	bpl @kill_snake
	ldx #noun_sword
	stx a0E
	ldx #icmd_where
	stx a0F
	jsr item_cmd
	lda a1A
	cmp #$07
	bmi dead_by_snake
	bpl @killed
@kill_snake:
	ldx #noun_dagger
	stx a0E
	ldx #icmd_destroy1
	stx a0F
	jsr item_cmd
	ldx #icmd_destroy1
	stx a0F
	ldx #noun_snake
	stx a0E
	jsr item_cmd
	ldx #icmd_draw_inv
	stx a0F
	jsr item_cmd
	lda #$64     ;The dagger disappears!
	jsr print_to_line2
@killed:
	lda #$63     ;You have killed it.
	jsr print_to_line1
	jmp pop_mode_continue

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
	jsr update_view
:	lda gs_bomb_tick
	cmp #$09
	beq @last_move
	inc gs_bomb_tick
	jsr @draw_new_keyhole
	jmp @regular_move

@draw_new_keyhole:
	lda gs_facing
	sta a1A
	lda gs_player_x
	cmp #$0a
	bne @tick
	lda gs_player_y
	sec
	sbc #$09
	beq @distance_2
	tax
	dex
	beq @distance_1
	dex
	bne @tick
	lda #$01
	cmp a1A
	bne @tick
	ldx #drawcmd01_keyhole
	stx zp0F_action
	bne @draw_keyhole
@distance_1:
	lda #$02
	cmp a1A
	bne @tick
	ldx #$10
	stx a0E
	ldx #drawcmd09_keyholes
	stx a0F
	jmp @draw_keyhole

@distance_2:
	lda #$02
	cmp a1A
	bne @tick
	ldx #$20
	stx a0E
	lda #drawcmd09_keyholes
	stx a0F
@draw_keyhole:
	jsr draw_special
@tick:
	lda #$41     ;Tick tick
	ldx #$06
	stx zp_col
	ldx #$02
	stx zp_row
	jmp print_display_string

@last_move:
	jsr @draw_new_keyhole
	jsr get_player_input
	lda gd_parsed_action
	cmp #verb_open
	bne @boom
	lda gd_parsed_object
	cmp #noun_door
	bne @boom
	lda gs_facing
	cmp #$01
	bne @boom
	lda gs_player_x
	cmp #$0a
	bne @boom
	lda gs_player_y
	cmp #$0b
	bne @boom
	jmp special_endgame

@boom:
	jsr flash_screen
	jsr clear_hgr2
	ldx #$00
	stx zp_col
	ldx #$15
	stx zp_row
	lda #$42     ;The key blows up the whole maze!
	jsr print_display_string
	jmp game_over

@regular_move:
	jsr get_player_input
	lda gd_parsed_action
	cmp #$59
	bcc :+
	jsr cmd_movement
	jmp check_special_mode

:	lda gd_parsed_action
	cmp #verb_open
	bne @continue
	lda gd_parsed_object
	cmp #noun_door
	bne @continue
	lda gs_facing
	cmp #$01
	bne @continue
	lda gs_player_x
	cmp #$0a
	bne @continue
	lda gs_player_y
	cmp #$0b
	bne @continue
	jmp special_endgame

@continue:
	jsr count_as_move
	jsr player_cmd
	jsr print_timers
	jmp check_special_mode

special_elevator:
	dex
	beq :+
	jmp special_tripped

:	jsr get_player_input
	lda gd_parsed_action
	cmp #verb_forward
	beq enter_elevator
pop_mode_do_cmd:
	lda gs_mode_stack1
	sta gs_special_mode
	lda gs_mode_stack2
	ldx #$00
	stx gs_mode_stack2
	sta gs_mode_stack1
	jsr update_view
	lda gd_parsed_action
	cmp #verb_movement_begin + 1
	bcc :+
	jmp cmd_movement

:	jmp player_cmd

ride_elevator:
	lda #$a3     ;The elevator is moving!
	jsr print_to_line1
	jsr wait_long
	lda #$a4     ;You are deposited at the next level.
	jsr print_to_line2
	jsr wait_long
	jsr update_view
	jmp pop_mode_continue

enter_elevator:
	jsr clear_maze_window
	ldx gs_level
	dex
	dex
	beq @level2
	dex
	beq @level3
	dex
	beq @level4
@level5:
	lda #$6d     ;You are trapped in a fake
	jsr print_to_line1
	lda #$6e     ;elevator. There is no escape!
	jsr print_to_line2
	jmp game_over

@level2:
	jsr clear_maze_window
	ldx #$03
	stx a0F
	stx gs_walls_left
	ldx #$23
	stx a0E
	stx gs_walls_right_depth
	jsr draw_maze
	ldx #drawcmd03_compactor
	stx a0F
	jsr draw_special
	jsr wait_short
	jsr clear_maze_window
	lda #$79     ;Glitch!
	ldx #$08
	stx zp_col
	ldx #$0a
	stx zp_row
	jsr print_display_string
	jmp game_over

@level3:
	inc gs_level
	ldx #$01
	stx gs_player_x
	bne @clear_turns
@level4:
	dec gs_level
	ldx #$04
	stx gs_player_x
@clear_turns:
	ldx #$00
	stx gs_level_moves_hi
	stx gs_level_moves_lo
	jmp ride_elevator

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
	stx a0E
	ldx #icmd_where
	stx a0F
	jsr item_cmd
	lda #$08
	cmp a1A
	bne @dead
	jsr clear_status_lines
	ldx #noun_dagger
	stx a0E
	ldx #icmd_destroy2
	stx a0F
	jsr item_cmd
	ldx #icmd_draw_inv
	stx a0F
	jsr item_cmd
	lda #$64     ;The dagger disappears!
	jsr print_to_line1
	jsr wait_long
	lda #$61     ;The monster is dead and
	jsr print_to_line1
	lda #$62     ;much blood is spilt!
	jsr print_to_line2
	ldx #$00
	stx gs_monster_alive
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
	stx a0F
	ldx #noun_jar
	stx a0E
	jsr item_cmd
	lda #$08
	cmp a1A
	bne @done
	ldx #noun_jar
	stx a0E
	ldx #icmd_set_carried_active
	stx a0F
	jsr item_cmd
	lda #$60     ;It is now full of blood.
	jsr print_to_line2
	jmp pop_mode_continue

@look:
	lda #$8c     ;It looks very dangerous!
	jsr print_to_line1
	jsr get_player_input
	jmp @check_input

@done:
	jsr clear_status_lines
	lda #$78     ;The body has vanished!
	jsr print_to_line1
	jmp pop_mode_do_cmd

special_climb:
	dex
	beq :+
	jmp special_endgame

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
	sta a1A
	lda gs_player_y
	sta a19
	lda gs_level
	cmp #$03
	beq @on_level_3
	cmp #$04
	bne @ceiling
@on_level_4:
	lda a1A
	cmp #$01
	bne @ceiling
	lda a19
	cmp #$0a
	bne @ceiling
	jmp @to_level_3

@on_level_3:
	lda a1A
	cmp #$08
	bne @ceiling
	lda a19
	cmp #$05
	beq @to_level_2
@ceiling:
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

@to_level_2:
	ldx #$01
	stx a19
	inx
	stx gs_facing
	jmp @up_level

@to_level_3:
	ldx #$00
	stx a19
	ldx #$03
	stx gs_facing
@up_level:
	dec gs_level
	lda a1A
	pha
	lda a19
	pha
	jsr update_view
	jsr get_player_input
	lda gd_parsed_action
	cmp #verb_forward
	beq :+
	jsr clear_status_lines
	lda #$54     ;You can't be serious!
	jsr print_to_line1
	jsr wait_long
	jmp dead_by_snake

:	pla
	sta a19
	pla
	sta a1A
	pha
	lda a19
	pha
	cmp #$01
	beq :+
	inc gs_player_x
	jmp @moved_forward

:	inc gs_player_y
@moved_forward:
	jsr update_view
	lda #$59     ;The
	jsr print_to_line1
	lda #$11     ;snake
	jsr print_noun
	lda #$77     ;has vanished
	jsr print_display_string
	ldx #noun_snake
	stx a0E
	ldx #icmd_destroy1
	stx a0F
	jsr item_cmd
	ldx #icmd_draw_inv
	stx a0F
	jsr item_cmd
	pla
	sta a19
	pla
	sta a1A
	lda a19
	cmp #$01
	bne @in_lair
	jmp pop_mode_continue

@in_lair:
	lda gs_monster_alive
	beq :+
	lda #$59     ;The
	jsr print_to_line2
	lda #$0f     ;wool
	jsr print_noun
	lda #$77     ;has vanished
	jsr print_display_string
	ldx #icmd_destroy1
	stx a0F
	ldx #noun_wool
	stx a0E
	jsr item_cmd
	ldx #$01
	stx gs_lair_raided
	ldx #icmd_draw_inv
	stx a0F
	jsr item_cmd
:	ldx #$01
	stx gs_snake_used
	ldx #icmd_draw_inv
	stx a0F
	jsr item_cmd
lair_input_loop:
	jsr get_player_input
	lda gd_parsed_action
	cmp #$5a
	bcs @move
	cmp #verb_press
	bne @command_allowed
	lda #$98     ;You will do no such thing!
	jsr print_to_line2
	jmp lair_input_loop

@command_allowed:
	jsr player_cmd
	jmp @update_view

@move:
	cmp #verb_forward
	beq @forward
	ldx gs_facing
	stx a1A
	jsr move_turn
@update_view:
	lda gs_facing
	ldx #$00
	stx a0E
	ldx #$04
	stx a0F
	cmp #$01
	bne :+
	lda gs_room_lit
	beq :+
	lda gs_walls_right_depth
	and #$e0
	beq :+
	jsr draw_special
:	jmp lair_input_loop

@forward:
	lda gs_facing
	cmp #$01
	beq @into_pit
	jsr clear_maze_window
	ldx #$09
	stx zp_col
	ldx #$0a
	stx zp_row
	lda #$7c     ;Splat!
	jsr print_display_string
	jmp lair_input_loop

@into_pit:
	inc gs_level
	ldx #$03
	stx gs_facing
	dec gs_player_x
	jsr pit
	jsr update_view
	jmp pop_mode_continue

special_endgame:
	jsr clear_maze_window
	lda #$07
	sta gs_walls_left
	ldx #$47     ;GUG: depth 4? not 3?
	stx gs_walls_right_depth
	jsr draw_maze
	ldx #drawcmd08_doors
	stx a0F
	ldx #$01
	stx a0E
	jsr draw_special
	ldx #$01
	stx gs_endgame_step
@endgame_input_loop:
	lda #$a0     ;Don't make unnecessary turns.
	jsr print_to_line1
	jsr get_player_input
	lda gs_endgame_step
	sta a1A
	lda gd_parsed_action
	dec a1A
	bne @step2
@step1:
	cmp #$5a
	bpl :+
	jmp @nope

:	cmp #verb_forward
	beq :+
	jmp @dead_salt

:	jsr clear_maze_window
	ldx #$03
	stx gs_walls_left
	ldx #$23
	stx gs_walls_right_depth
	jsr draw_maze
	ldx #drawcmd08_doors
	stx a0F
	ldx #$02
	stx a0E
	jsr draw_special
	inc gs_endgame_step
	jmp @endgame_input_loop

@step2:
	dec a1A
	bne @step3
	cmp #$5a
	bpl :+
	jmp @nope

:	cmp #verb_forward
	beq :+
	jmp @dead_salt

:	jsr clear_maze_window
	ldx #$01
	stx gs_walls_left
	ldx #$00
	stx gs_walls_right_depth
	jsr draw_maze
	inc gs_endgame_step
	jmp @endgame_input_loop

@step3:
	dec a1A
	bne @step4
	cmp #$5a
	bpl :+
	jmp @nope

:	cmp #verb_right
	beq :+
	jmp @dead_salt

:	jsr clear_maze_window
	ldx #$01
	stx gs_walls_left
	ldx #$00
	stx gs_walls_right_depth
	jsr draw_maze
	ldx #drawcmd02_elevator
	stx a0F
	jsr draw_special
	inc gs_endgame_step
	jmp @endgame_input_loop

@step4:
	dec a1A
	bne @step5
	cmp #$5a
	bmi :+
	jmp @dead_salt

:	cmp #verb_open
	beq :+
	jmp @nope

:	lda gd_parsed_object
	cmp #noun_door
	beq :+
	jmp @nope

:	ldx #drawcmd0A_door_opening
	stx a0F
	jsr draw_special
	inc gs_endgame_step
	jmp @endgame_input_loop

@step5:
	dec a1A
	bne @step6
	cmp #verb_forward
	bne :+
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

:	cmp #$5a
	bmi :+
	jmp @dead_salt

:	cmp #verb_throw
	beq :+
@nope5:
	jmp @nope

:	lda gd_parsed_object
	cmp #noun_ball
	bne @nope5
	ldx #icmd_where
	stx a0F
	ldx #noun_ball
	stx a0E
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_known
	bne @nope5
	jsr clear_maze_window
	jsr flash_screen
	ldx #$07
	stx gs_walls_left
	ldx #$46
	stx gs_walls_right_depth
	jsr draw_maze
	ldx #icmd_destroy2  ;and #noun_ball
	stx a0F
	stx a0E
	jsr item_cmd
	ldx #icmd_draw_inv
	stx a0F
	jsr item_cmd
	inc gs_endgame_step
	jmp @endgame_input_loop

@step6:
	dec a1A
	bne @step7
	cmp #$5a
	bpl :+
@nope6:
	jmp @nope

:	cmp #verb_forward
	beq :+
@dead6:
	jmp @dead_salt

:	jsr clear_maze_window
	ldx #$03
	stx gs_walls_left
	ldx #$23
	stx gs_walls_right_depth
	jsr draw_maze
	inc gs_endgame_step
	jmp @endgame_input_loop

@step7:
	cmp #$5a
	bmi @nope6
	cmp #verb_forward
	bne @dead6
	jsr clear_maze_window
	ldx #$01
	stx gs_walls_left
	stx gs_walls_right_depth
	jsr draw_maze
@final_quiz:
	lda #$3c     ;Before I let you go free
	jsr print_to_line1
	lda #$3d     ;what was the name of the monster?
	jsr print_to_line2
	jsr get_player_input
	lda gd_parsed_action
	cmp #$5a
	bpl @dead6
	cmp #verb_grendel
	beq @win
	jmp @print_hint

@text_hint:
	.byte "BEOWULF DISAGREES!", $80
@print_hint:
	jsr clear_status_lines
	ldx #$00
	stx zp_col
	ldx #$16
	stx zp_row
	ldx #<@text_hint
	stx zp0C_string_ptr
	ldx #>@text_hint
	stx zp0C_string_ptr+1
	jsr print_string
	jsr wait_long
	jmp @final_quiz

@text_congrats:
	.byte "RETURN TO SANITY BY PRESSING RESET!", $80
@win:
	jsr clear_hgr2
	ldx #$00
	stx zp_col
	stx zp_row
	lda #$4d     ;Correct! You have survived!
	jsr print_display_string
	lda #char_newline
	jsr char_out
	ldx #<@text_congrats
	stx a0C
	ldx #>@text_congrats
	stx a0D
	jsr print_string
@infinite_loop:
	jmp @infinite_loop

@dead_salt:
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

@nope:
	lda #$9a     ;It is currently impossible.
	jsr print_to_line2
	jmp @endgame_input_loop

; junk
	.byte $66
	beq b3F38
	cpy #$50

relocate_data:
	lda relocated
	beq @write_DEATH

; Relocate data above HGR2: ($4000-$5FFF) to ($6000-$7FFF)
	ldx #$00
	stx a0E
	stx a10
	stx relocated
	ldx #$40
	stx a0F
	ldx #$60
	stx a11
	ldx #<p1FFF
	stx a19
	ldx #>p1FFF
	stx a1A
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
raster 0,21,0:
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
raster 9,7,0:
	.byte $05,$00
raster 9,9,0:
	.byte $22,$83,$04
raster 9,12,0:
	.byte $01,$22,$84,$04,$00,$42,$86,$04
	.byte $00,$22,$75,$08,$01,$22,$76,$08
	.byte $02,$32,$77,$02,$00,$23,$43,$08
	.byte $04,$13,$44,$02,$00,$13,$95,$05
	.byte $01,$33,$68,$07
raster $11,8,0:
	.byte $04
raster 17,9,0:
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
raster 10,9,0:
	.byte $25
raster 10,10,0:
	.byte $6a
raster 10,11,0:
	.byte $01
raster 10,12,0:
	.byte $00,$25,$7a,$01,$00,$25,$8a,$01
	.byte $00,$02,$01,$0a,$06,$01,$00,$07
	.byte $bf,$00,$00,$00,$01,$00,$a0,$c8
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$02
raster 18,6,0:
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
raster 4,0,0:
	.byte $44,$45,$41,$54
raster 4,4,0:
	.byte $48,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00
raster 4,17,0:
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
raster 7,4,0:
	.byte $40,$60,$70
raster 7,7,0:
	.byte $70,$70,$70,$70,$70,$78,$78
raster 7,14,0:
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
	.byte $50,$20,$53,$41,$56,$45,$20,$54
	.byte $4f,$20,$44,$49,$53,$4b,$20,$4f
	.byte $52,$20,$54,$41,$50,$45,$20,$28
	.byte $54,$20,$4f,$52,$20,$44,$29,$3f
	.byte $80,$47,$45,$54,$20,$46,$52,$4f
	.byte $4d,$20,$44,$49,$53,$4b,$20,$4f
	.byte $52,$20,$54,$41,$50,$45,$20,$28
	.byte $54,$20,$4f,$52,$20,$44,$29,$3f
	.byte $80,$20,$55,$08,$a2,$00,$86,$06
	.byte $86,$07,$a2,$1f,$86,$0c,$a2,$7c
	.byte $86,$0d
raster 16,0,7:
	.byte $20,$e5,$08,$20
raster 16,4,7:
	.byte $94,$7c,$c9,$44,$d0,$03,$4c,$0c
	.byte $7d,$20,$55,$08,$a9
raster 16,17,7:
	.byte $95,$20,$92,$08,$60,$20,$55,$08
	.byte $a2,$00,$86,$06,$86,$07,$a2,$00
	.byte $86,$0c,$a2,$7c,$86,$0d,$20,$e5
	.byte $08,$20,$94,$7c,$c9,$54,$f0,$03
	.byte $4c,$ef,$7c,$20,$55,$08,$20,$15
	.byte $10,$a2,$07,$86,$0f,$20,$34,$1a
	.byte $4c,$cd,$31,$2c,$10,$c0,$20,$43
	.byte $12,$2c,$00,$c0,$10,$f8,$ad,$00
	.byte $c0,$29,$7f,$c9,$54,$f0,$04,$c9
	.byte $44,$d0,$e8,$48,$20,$6e,$12,$68
	.byte $60,$00,$01,$ef,$d8,$01,$60,$01
	.byte $00,$03,$00,$00,$3f,$93,$61,$00
	.byte $00,$01,$00,$00,$60,$01,$50,$4c
	.byte $41,$43,$45,$20,$44,$41,$54,$41
	.byte $20,$44,$49,$53,$4b,$45,$54,$54
	.byte $45,$20,$49,$4e,$20,$44,$52,$49
	.byte $56,$45,$20,$31,$2c,$20,$53,$4c
	.byte $4f,$54,$20,$36,$2e,$80,$a2,$02
	.byte $8e,$c2,$7c,$20,$4f,$7d,$90,$06
	.byte $20,$74,$7d,$4c,$23,$7e,$20,$55
	.byte $08,$20,$15,$10
raster 2,5,7:
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
raster 11,7,7:
	.byte $20,$4d,$49,$53,$4d
raster 11,12,7:
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
raster 20,-1,7:
	.byte $7d
raster 20,0,7:
	.byte $86,$0d,$18,$a5,$19,$65
raster 20,6,7:
	.byte $0c,$85,$0c,$a5,$1a,$65,$0d,$85
	.byte $0d,$a9,$0a,$20,$92,$11,$20
raster 20,21,7:
	.byte $e5,$08,$20,$e9,$0f,$a5,$10,$f0
	.byte $03,$4c,$ff,$7c,$68,$68,$4c,$05
	.byte $08,$08,$a9,$61,$d0,$06,$a2,$06
	.byte $8e,$a5,$61,$60,$06,$a9,$04,$85
	.byte $07,$a9,$03,$a0,$0d,$20,$a7,$17
	.byte $a9,$42,$85,$09,$a9,$11,$85,$08
	.byte $a0,$04,$20,$77,$17,$a9,$5c,$85
	.byte $09,$a9,$61,$85,$08,$a0,$04,$20
	.byte $77,$17,$a9,$16,$85,$06,$a9
raster 13,4,7:
	.byte $00,$85,$07
raster 13,7,7:
	.byte $a9,$03,$a0,$15,$20,$a7,$17
raster 13,14,7:
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
	.byte $04,$ff
maze_walls:
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
maze_features:
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
gs_walls_left:
	.byte $00
gs_walls_right_depth:
	.byte $00
gs_box_visible:
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
gs_level_moves_hi:
	.byte $00
gs_level_moves_lo:
	.byte $29
gs_special_mode:
	.byte $00
gs_mode_stack1:
	.byte $00
gs_mode_stack2:
	.byte $00
gs_endgame_step:
	.byte $00,$00,$00
gs_bat_alive:
	.byte $00
gs_mother_alive:
	.byte $04
gs_monster_alive:
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
gs_bomb_tick:
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
(intro_text-1):
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
	.byte "SAVE TO DISK OR TAPE (T OR D)?", $80
text_load_device:
	.byte "GET FROM DISK OR TAPE (T OR D)?", $80
load_disk_or_tape:
	jsr clear_hgr2
	ldx #$00
	stx zp_col
	stx zp_row
	ldx #<text_load_device
	stx a0C
	ldx #>text_load_device
	stx a0D
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
	stx a0C
	ldx #>text_save_device
	stx a0D
	jsr print_string
	jsr input_T_or_D
	cmp #'T'
	beq prepare_tape_save
	jmp save_to_disk

prepare_tape_save:
	jsr clear_hgr2
	jsr update_view
	ldx #icmd_draw_inv
	stx a0F
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
	.byte "PLACE DATA DISKETTE IN DRIVE 1, SLOT 6.", $80

save_to_disk:
	ldx #$02
	stx iob_cmd
	jsr prompt_and_call_dos
	bcc prepare_disk_save
	jsr dos_code_to_message
	jmp disk_error_retry

prepare_disk_save:
	jsr clear_hgr2
	jsr update_view
	ldx #icmd_draw_inv
	stx a0F
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
	stx a0C
	ldx #>text_insert_disk
	stx a0D
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
	stx a10
	beq disk_error
disk_error_retry:
	ldx #$ff
	stx a10
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
	stx a1A
	ldx #<string_disk_error
	stx a0C
	ldx #>string_disk_error
	stx a0D
	clc
	lda a19
	adc a0C
	sta a0C
	lda a1A
	adc a0D
	sta a0D
	lda #char_newline
	jsr char_out
	jsr print_string
	jsr input_char
	lda a10
	beq :+
	jmp prepare_disk_save

:	pla
	pla
	jmp cold_start

; cruft from here to end of file
	php
	lda #$61
	bne b7E81
	ldx #$06
	stx gs_special_mode
	rts

b7E81:
	.byte $06
	lda #$04
	sta zp_row
	lda #glyph_L
	ldy #$0d
	jsr draw_down
	lda #>raster 4,17,0
	sta screen_ptr+1
	lda #<raster 4,17,0
	sta screen_ptr
	ldy #$04
	jsr draw_right
	lda #>raster 16,17,7
	sta screen_ptr+1
	lda #<raster 16,17,7
	sta screen_ptr
	ldy #$04
	jsr draw_right
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #glyph_L
	ldy #$15
	jsr draw_down
	jmp @draw_0_left

	pla
	pha
	cmp #$01
	bne b7ECE
	lda #$12
	sta zp_col
	lda #$04
	sta zp_row
	lda #glyph_L
	ldy #$0d
	jsr draw_down
b7ECE:
	lda #$15
	sta zp_col
	lda #$00
	sta zp_row
	ldy #$04
	jsr draw_down_left
	lda #$12
	sta zp_col
	lda #$11
	sta zp_row
	ldy #$04
	jsr draw_down_right
	pla
	cmp #$00
	beq b7F4C
	lda gs_walls_left
	and #$01
	bne b7F1B
	lda #$00
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$15
	jsr draw_down
	lda #>relocated
	sta screen_ptr+1
	lda #<relocated
	sta screen_ptr
	ldy #$01
	jsr draw_right
	lda #>raster 20,-1,7
	sta screen_ptr+1
	lda #<raster 20,-1,7
	sta screen_ptr
	ldy #$01
	jsr draw_right
b7F1B:
	lda gs_walls_right_depth
	and #$01
	bne b7F4B
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #glyph_L
	ldy #$15
	jsr draw_down
	lda #>raster 0,21,0
	sta screen_ptr+1
	lda #<raster 0,21,0
	sta screen_ptr
	ldy #$01
	jsr draw_right
	lda #>raster 20,21,7
	sta screen_ptr+1
	lda #<raster 20,21,7
	sta screen_ptr
	ldy #$01
	jsr draw_right
b7F4B:
	rts

b7F4C:
	lda gs_walls_left
	and #$01
	beq b7F60
	lda #$00
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$15
	jsr draw_down
b7F60:
	lda gs_walls_right_depth
	and #$01
	beq b7F4B
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #glyph_L
	ldy #$15
	jsr draw_down
	rts

	lda #$ff
b7F79:
	sta (screen_ptr),y
	dey
	bne b7F79
	rts

	tya
	sta a1A
b7F82:
	jsr get_rowcol_addr
	lda #$02
	jsr char_out
	dec zp_col
	dec zp_col
	inc zp_row
	dec a1A
	bne b7F82
	rts

	tya
	sta a1A
b7F98:
	jsr get_rowcol_addr
	lda #$01
	jsr char_out
	inc zp_row
	dec a1A
	bne b7F98
	rts

	pha
	tya
	sta a1A
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
	dec a1A
	bne b7FAC
	rts

	ldy #$00
	lda #<maze_walls
	sta a0A
	lda #>maze_walls
	sta a0B
	ldx gs_level
	lda #$00
	clc
	dex
	beq b7FD7
	adc #$21
	jmp :-

b7FD7:
	adc a0A
	sta a0A
	ldx gs_player_x
	dex
	beq b7FEA
	inc a0A
	inc a0A
	inc a0A
	jmp :-

b7FEA:
	lda gs_player_y
	cmp #$05
	bmi e7FFF
	cmp #$09
	bmi b7FFA
	inc a0A
	sec
	sbc #$04
b7FFA:
	inc a0A
	sec
	sbc #$04
