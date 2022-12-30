;	.include "deathmaze_b.i"

	.include "msbstring.i"

	.include "apple.i"
	.include "dos.i"

	.include "string_verb_decl.i"
	.include "string_noun_decl.i"
	.include "string_display_decl.i"
	.include "string_intro_decl.i"

;	.feature string_escapes

; 0-based indexing for consistency with zp_row,zp_col convention
.define raster(row,col,line) (screen_HGR2 + ((row)/8 * 40) + (((row) - ((row)/8) * 8) * $80) + ((line) * $400) + (col))
.define raster_hi(row,col,line) .hibyte(raster row,col,line)
.define raster_lo(row,col,line) .lobyte(raster row,col,line)


; 8-bit variables
zp0E_wait1 = $0e
zp0F_wait2 = $0f
zp10_wait3 = $10

zp0C_col_animate = $0c
zp0C_col_left = $0c
zp0E_count = $0e
zp0E_item = $0e
zp0E_object = $0e
zp0E_draw_param = $0e
zp0F_action = $0f
zp0F_index = $0f
zp10_temp = $10
zp10_length = $10
zp10_count_vocab = $10
zp10_count_words = $10
zp10_which_place = $10
zp10_noun = $10
zp10_position = $10
zp11_level_facing = $11
zp11_temp = $11
zp11_action = $11
zp11_item = $11
zp11_box_item = $11
zp11_count = $11
zp11_count_chars = $11
zp11_count_string = $11
zp11_count_which = $11
zp11_position = $11
zp11_count_loop = $11
zp13_raw_input = $13
zp13_char_input = $13
zp13_level = $13
zp13_temp = $13
zp19_level_facing = $19
zp19_col_right = $19
zp19_regular_climb = $19
zp1A_move_action = $1a
zp1A_hint_mode = $1a
zp1A_object = $1a
zp1A_count_loop = $1a
zp1A_cmds_to_check = $1a
zp1A_facing = $1a
zp1A_temp = $1a

zp0E_box_visible = $0e
zp0F_sight_depth = $0f
zp10_pos_y = $10
zp11_pos_x = $11
zp19_level = $19

zp19_pos_y = $19
zp1A_pos_x = $1a

zp19_count_col = $19
zp1A_count_row = $1A

zp19_item_position = $19
zp1A_item_place = $1a

zp19_sight_depth = $19
zp19_wall_opposite = $19
zp1A_wall_bit = $1a

; 16-bit variables
zp0A_walls_ptr = $0a ;$0b
zp0A_text_ptr = $0a ;$0b
zp0A_data_ptr = $0a ;$0b
zp0C_string_ptr = $0c ;$0d
zp0E_count16 = $0e ;$0f
zp0E_ptr = $0e ;$0f
zp0E_src = $0e ;$0f
zp10_dst = $10 ;$11
zp13_row_ptr = $13 ;$14
zp13_font_ptr = $13 ;$14
zp19_input_ptr = $19 ;$1a
zp19_delta16 = $19 ;$1a
zp19_count = $19 ;$1a


; First byte in gs_item_locations is either
; maze level 1-5 or one of these values:
carried_boxed = $06
carried_active = $07
carried_known = $08
; for >= comparisons
carried_begin = $06
carried_unboxed = $07

char_cursor = $00
char_left = $08
char_newline = $0a
char_enter = $0d
char_right = $15
char_ESC = $1b
char_esc = $1b
char_ClearLine = $1e
char_mask_upper = $5f

cmd_blow = $02

drawcmd01_keyhole = $01
drawcmd02_elevator = $02
drawcmd03_compactor = $03
drawcmd04_pit_floor = $04
drawcmd05_pit_roof = $05
drawcmd06_boxes = $06
drawcmd07_the_square = $07
drawcmd08_doors = $08
drawcmd09_keyholes = $09
drawcmd0A_door_opening = $0a

error_write_protect = $01
error_volume_mismatch = $02
error_unknown_cause = $03
error_reading = $04
error_bad_save = $05

facing_W = $01
facing_N = $02
facing_E = $03
facing_S = $04

food_eat_amount = $00aa
food_fart_consume = $000a
food_fart_minimum = $05
food_hungry = $0a

glyph_slash_down = $01
glyph_slash_up = $02
glyph_L = $03
glyph_R = $04
glyph_X = $05
glyph_LR = $0a
glyph_solid = $0b
glyph_box = $0c
glyph_box_TL = $0d
glyph_box_TR = $0e
glyph_box_BR = $0f
glyph_box_T = $10
glyph_box_R = $11
glyph_box_BL = $12
glyph_box_B = $13
glyph_slash_up_C = $14
glyph_slash_down_C = $15
glyph_C = $16
glyph_slash_down_R = $17
glyph_keyhole_C = $18
glyph_keyhole_R = $19
glyph_keyhole_L = $1a
glyph_L_solid = $1b
glyph_R_solid = $1c
glyph_L_notched = $1d
glyph_R_notched = $1e
glyph_angle_BR = $1f
glyph_UR_triangle = $5f
glyph_UL_triangle = $60
glyph_angle_BL = $7b
glyph_solid_BR = $7c
glyph_solid_BL = $7d
glyph_solid_TR = $7e
glyph_solid_TL = $7f

;gs_size-1 = $55

icmd_destroy1 = $00
icmd_destroy2 = $01
icmd_set_carried_boxed = $02
icmd_set_carried_active = $03
icmd_set_carried_known = $04
icmd_drop = $05
icmd_where = $06  ;out $19:position $1a:level
	icmds_location_end = $07
icmd_draw_inv = $07
icmd_count_inv = $08
icmd_reset_game = $09
icmd_0A = $0a
icmd_which_box = $0b
icmd_which_food = $0c
icmd_which_torch_lit = $0d
icmd_which_torch_unlit = $0e

inventory_max = $08

monster_flag_roaming = $02
mother_flag_roaming = $04

puzzle_step1 = $05


; Values for gs_special_mode
special_mode_calc_puzzle = $02
special_mode_bat = $04
special_mode_dog1 = $06
special_mode_dog2 = $07
special_mode_monster = $08
special_mode_mother = $09
special_mode_dark = $0a
special_mode_snake = $0b
special_mode_bomb = $0c
special_mode_elevator = $0d
special_mode_tripped = $0e
special_mode_climb = $0f
special_mode_exit = $10


textbuf_max_input = $1E
textbuf_size = $28 * 2 ;40 columns, 2 lines

torch_low = $0a
torch_lifespan = $96

turns_until_trippable = $29
turns_until_mother = $32
turns_until_dog1 = $3c
turns_until_monster = $50


vocab_word_size = $04

; Pseudo-verbs for navigation actions
verb_movement_begin = $5a
verb_forward    = $5b
verb_left       = $5c
verb_right      = $5d
verb_uturn      = $5e


p4015 = $4015
p40AF = $40AF
p40B1 = $40B1
p40B4 = $40B4
p40D8 = $40D8
p40D9 = $40D9
p4131 = $4131
p4132 = $4132
p4133 = $4133
p4134 = $4134
p4156 = $4156
p4200 = $4200
p4204 = $4204
p4211 = $4211
p4384 = $4384
p4387 = $4387
p438E = $438E
p4607 = $4607
p4707 = $4707
p5C50 = $5C50
p5C54 = $5C54
p5C61 = $5C61
p5D05 = $5D05
p5DAF = $5DAF
p5DB4 = $5DB4
p5E4F = $5E4F
p5E50 = $5E50
p5E56 = $5E56
p5E65 = $5E65
p5EAC = $5EAC
p5EAF = $5EAF
p5EB6 = $5EB6


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
a0C = $0c
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
aBD = $bd
aBE = $be
aC3 = $c3
aE5 = $e5
aEE = $ee
aEF = $ef
;
; **** ZP POINTERS ****
;
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
	jsr check_signature ;NOTE: never returns, continues with PLA/PLA/JMP
	nop
	jmp item_cmd

print_to_line1:
	ldx #$00
	stx zp_col
	ldx #$16
	stx zp_row
	ldx #<text_buffer_line1
	stx zp0A_text_ptr
	ldx #>text_buffer_line1
	stx zp0A_text_ptr+1
	bne print_to_line
print_to_line2:
	ldx #$00
	stx zp_col
	ldx #$17
	stx zp_row
	ldx #<text_buffer_line2
	stx zp0A_text_ptr
	ldx #>text_buffer_line2
	stx zp0A_text_ptr+1
print_to_line:
	jsr get_display_string
	jsr get_rowcol_addr
	jsr clear_text_buf
	ldy #$00
	lda (zp0C_string_ptr),y
	and #$7f
@next_char:
	sta (zp0A_text_ptr),y
	jsr print_char
	inc a:zp0C_string_ptr
	bne :+
	inc a:zp0C_string_ptr+1
:	inc zp0A_text_ptr
	bne :+
	inc zp0A_text_ptr+1
:	ldy #$00
	lda (zp0C_string_ptr),y
	bpl @next_char
	lda #char_ClearLine
	jsr char_out
	rts

print_display_string:
	jsr get_display_string
print_string:
	jsr get_rowcol_addr
	ldy #$00
	lda (zp0C_string_ptr),y
	and #$7f
@next_char:
	jsr print_char
	inc a:zp0C_string_ptr
	bne :+
	inc a:zp0C_string_ptr+1
:	ldy #$00
	lda (zp0C_string_ptr),y
	bpl @next_char
	rts

get_display_string:
	sta zp11_count_string
	ldx #<display_string_table
	stx a:zp0C_string_ptr
	ldx #>display_string_table
	stx a:zp0C_string_ptr+1
	ldy #$00
@scan:
	lda (zp0C_string_ptr),y
	bmi @found_string
@next_char:
	inc a:zp0C_string_ptr
	bne @scan
	inc a:zp0C_string_ptr+1
	bne @scan
@found_string:
	dec zp11_count_string
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
	bmi cmd_verbal  ;GUG: bcc preferred
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
	stx zp1A_facing
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
	lda zp1A_facing
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
	lda zp1A_facing
	cmp #$01
	beq @wrap_counterwise
	dec gs_facing
	bpl @turned
@wrap_counterwise:
	ldx #$04
	stx gs_facing
	bne @turned
@turn_around:
	lda zp1A_facing
	cmp #$03
	bmi :+  ;GUG: bcc preferred
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
	stx zp1A_facing
	cmp #$08
	beq @perfect_square_N
	cmp #$09
	bne @normal
@perfect_square_S:
	lda zp1A_facing
	cmp #$04
	bne @normal
	beq @move_player
@perfect_square_N:
	lda zp1A_facing
	cmp #$02
	beq @move_player
@normal:
	lda gs_walls_right_depth
	and #%11100000
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

:	jsr complete_turn
	jsr update_view
	jsr print_timers
	rts

check_special_position:
	lda gs_player_y
	sta zp19_pos_y
	lda gs_player_x
	sta zp1A_pos_x
	lda gs_level
	cmp #$03
	bne :+
	rts

:	bmi :+  ;GUG: bcc preferred
	jmp check_levels_4_5

:	cmp #$02
	beq check_level_2
	lda zp1A_pos_x
	cmp #$03
	beq check_calculator
	cmp #$06
	beq check_guillotine
	rts

check_calculator:
	lda zp19_pos_y
	cmp #$03
	beq at_calculator
special_return:
	rts

at_calculator:
	ldx #special_mode_calc_puzzle
	stx gs_special_mode
	rts

check_guillotine:
	lda zp19_pos_y
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
	lda zp19_pos_y
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
	ldx #special_mode_dog1
	stx gs_special_mode
	rts

:	ldx #special_mode_dog1
	stx gs_mode_stack1
	rts

check_guarded_pit:
	lda zp1A_pos_x
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
	beq return_dog_monster
	ldx #special_mode_dog2
	stx gs_special_mode
return_dog_monster:
	rts

check_levels_4_5:
	cmp #$04
	beq check_monster
	lda zp1A_pos_x
	cmp #$04
	beq check_bat
check_mother:
	lda gs_level_turns_lo
	cmp #turns_until_mother
	bcs :+
	lda gs_level_turns_hi
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
	lda zp19_pos_y
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
	lda gs_level_turns_lo
	cmp #turns_until_monster
	bcs :+
	lda gs_level_turns_hi
	beq return_dog_monster
:	lda gs_monster_alive
	and #monster_flag_roaming
	beq done_timer
	ldx #special_mode_monster
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
	cmp #food_hungry
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
	bpl multiples  ;GUG: bcs preferred
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_unboxed
	bpl rts_bb2	 ;GUG: bcc preferred
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
	lda (zp0E_src),y
	sta (zp10_dst),y
	inc zp0E_src
	bne :+
	inc zp0E_src+1
:	inc zp10_dst
	bne :+
	inc zp10_dst+1
:	dec zp19_count
	beq @check_done
	lda zp19_count
	cmp #$ff
	bne @next_byte
	dec zp19_count+1
	jmp @next_byte

@check_done:
	lda zp19_count+1
	ora zp19_count
	bne @next_byte
	rts

; uninitialized buffers contain
; cruft leftover from earlier build
text_buffer_prev:
	.byte $c9,$50,$90,$03,$20,$15,$10,$ad
	.byte $9e,$61,$f0,$08,$a2,$00,$8e,$b3
	.byte $61,$4c,$93,$34,$a2,$00,$8e,$a4
	.byte $61,$ad,$b3,$61,$d0,$29,$ad,$94
	.byte $61,$c9,$05,$f0,$0a,$ad,$ad,$61
	.byte $29,$02,$d0,$08,$4c,$93,$34,$ad
	.byte $ac,$61,$f0,$f8,$20,$26,$36,$a9
	.byte $43,$20,$92,$08,$a9,$44,$20,$a4
	.byte $08,$ee,$b3,$61,$4c,$08,$36,$c9
	.byte $01,$d0,$13,$20,$26,$36,$ee,$b3
text_buffer_line1:
	.byte $61,$a9,$45,$20,$92,$08,$a9,$47
	.byte $20,$a4,$08,$4c,$08,$36,$20,$26
	.byte $36,$ad,$94,$61,$c9,$05,$f0,$0d
	.byte $a9,$36,$20,$92,$08,$a9,$37,$20
	.byte $a4,$08,$4c,$b9,$10,$a9,$48,$20
	.assert * - text_buffer_line1 = textbuf_size / 2, error, "Mismatch text buffer size"
text_buffer_line2:
	.byte $92,$08,$a9,$4b,$20,$a4,$08,$4c
	.byte $b9,$10,$ca,$d0,$6f,$ad,$9d,$61
	.byte $c9,$11,$f0,$07,$20,$5f,$10,$a9
	.byte $20,$d0,$e9,$ad,$9c,$61,$c9,$0e
	.byte $f0,$52,$c9,$13,$d0,$ee,$a2,$04
	.assert * - text_buffer_line2 = textbuf_size / 2, error, "Mismatch text buffer size"
;
; cruft decoded:
;	cmp #$50
;	bcc b0C31
;	jsr s1015
;b0C31:
;	lda gs_room_lit
;	beq b0C3E
;	ldx #$00
;	stx a61B3
;	jmp $3493
;
;b0C3E:
;	ldx #$00
;	stx a61A4
;	lda a61B3
;	bne b0C71
;	lda a6194
;	cmp #$05
;	beq b0C59
;	lda a61AD
;	and #$02
;	bne b0C5E
;b0C56:
;	jmp $3493
;
;b0C59:
;	lda a61AC
;	beq b0C56
;b0C5E:
;	jsr s3626
;	lda #$43     ;The ground beneath your feet
;	jsr print_to_line1
;	lda #$44     ;begins to shake!
;	jsr print_to_line2
;	inc a61B3
;	jmp j3608
;
;b0C71:
;	cmp #$01
;	bne b0C88
;	jsr s3626
;	inc a61B3
;	lda #$45     ;A disgusting odor permeates
;	jsr print_to_line1
;	lda #$47     ;the hallway!
;	jsr print_to_line2
;	jmp j3608
;
;b0C88:
;	jsr s3626
;	lda a6194
;	cmp #$05
;	beq b0C9F
;	lda #$36     ;The monster attacks you and
;	jsr print_to_line1
;	lda #$37     ;you are his next meal!
;	jsr print_to_line2
;	jmp game_over
;
;b0C9F:
;	lda #$48     ;It is the monster's mother!
;	jsr print_to_line1
;	lda #$4b     ;She slashes you to bits!
;b0CA6:
;	jsr print_to_line2
;	jmp game_over
;
;	dex
;	bne b0D1E
;	lda gd_direct_object
;	cmp #$11
;	beq b0CBD
;b0CB6:
;	jsr clear_status_lines
;	lda #$20
;	bne b0CA6
;b0CBD:
;	lda a619C
;	cmp #$0e
;	beq b0D16
;	cmp #$13
;	bne b0CB6
;	ldx #$04
;
; (end cruft)

get_player_input:
	bit hw_STROBE
:	bit hw_KEYBOARD
	bpl :-
	lda hw_KEYBOARD
	and #$7f
	cmp #$40
	bmi :+  ;GUG: bcc preferred
	and #char_mask_upper
:	pha
	lda #>text_buffer_line1
	sta zp0E_src+1
	lda #<text_buffer_line1
	sta zp0E_src
	lda #>text_buffer_prev
	sta zp10_dst+1
	lda #<text_buffer_prev
	sta zp10_dst
	lda #$00
	sta zp19_count+1
	lda #textbuf_size ;BUG? should this copy both buffers?
	sta zp19_count
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
	lda #>(text_buffer_line1-1)
	sta a:zp0C_string_ptr+1
	lda #<(text_buffer_line1-1)
	sta a:zp0C_string_ptr
	lda #$80
	ldy #textbuf_size
:	sta (zp0C_string_ptr),y
	dey
	bne :-
	lda #$00
	sta zp11_count_chars
	sta zp10_count_words
	lda #>(text_buffer_line1-1)
	sta zp19_input_ptr+1
	lda #<(text_buffer_line1-1)
	sta zp19_input_ptr
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
	bmi process_input_char  ;GUG: bcc preferred
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
; Replace current buffer with previous
	lda #$00
	sta zp_col
	lda #$16
	sta zp_row
	jsr get_rowcol_addr
	lda #>(text_buffer_prev-1)
	sta zp0E_src+1
	lda #<(text_buffer_prev-1)
	sta zp0E_src
	ldy #textbuf_size
@next_char:
	lda (zp0E_src),y
	sta (zp19_input_ptr),y
	dey
	bne @next_char

; Re-display on screen
	ldy #textbuf_size
	sty zp0E_count
	ldy #$01
	sty zp0F_index
@repeat_display:
	lda (zp19_input_ptr),y
	cmp #$80
	bmi :+  ;GUG: bcc preferred
	lda #' '
:	jsr char_out
	inc zp0F_index
	ldy zp0F_index
	dec zp0E_count
	bne @repeat_display

; Start over with fresh input buffer from scratch
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
	lda (zp19_input_ptr),y
	cmp #' '
	bne :+
	dec zp10_count_words
:	lda #$80
	sta (zp19_input_ptr),y
	dec zp11_count_chars
	jmp input_blink_cursor

input_letter:
	sta zp13_raw_input
	cmp #'A'
	bcc @no_modification
	ldy zp11_count_chars
	beq @no_modification
	lda (zp19_input_ptr),y ;Check previous character
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
	sta (zp19_input_ptr),y
	cpy #textbuf_max_input
	beq parse_input
	jmp input_blink_cursor

; BUG: meant to prevent double-space, but only prevents WORD_L_
input_space:
	ldy zp11_count_chars
	dey          ;BUG: remove to fix.
	lda (zp19_input_ptr),y
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
	sta (zp19_input_ptr),y
	inc zp19_input_ptr
	bne @parse_verb
	inc zp19_input_ptr+1
@parse_verb:
	jsr get_vocab
	lda zp10_count_vocab
	sta gd_parsed_action
	ldy #$00
@skip_word:
	inc zp19_input_ptr
	bne :+
	inc zp19_input_ptr+1
:	lda (zp19_input_ptr),y
	cmp #' '
	bne @skip_word
	inc zp19_input_ptr
	bne :+
	inc zp19_input_ptr+1
:	lda (zp19_input_ptr),y
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
	lda zp10_count_vocab
	sta gd_parsed_object
@check_verb:
	lda gd_parsed_action
	cmp #verbs_end
	bcc @known_verb
	lda #$8d     ;I'm sorry, but I can't
	jsr print_to_line2
	lda #<text_buffer_line1
	sta zp19_input_ptr
	lda #>text_buffer_line1
	sta zp19_input_ptr+1
	ldy #$00
@echo_next_char:
	tya
	pha
	lda (zp19_input_ptr),y
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
	sta zp19_input_ptr
	lda #>text_buffer_line1
	sta zp19_input_ptr+1
	ldy #$00
@find_word_end:
	lda (zp19_input_ptr),y
	cmp #$20
	beq @found_word_end
	inc zp19_input_ptr
	bne @find_word_end
	inc zp19_input_ptr+1
	bne @find_word_end
@found_word_end:
	inc zp19_input_ptr
	bne @obj_next_letter
	inc zp19_input_ptr+1
@obj_next_letter:
	tya
	pha
	lda (zp19_input_ptr),y
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
	sta zp19_input_ptr+1
	lda #<text_buffer_line1
	sta zp19_input_ptr
	lda #$00
	sta zp_col
	lda #$17
	sta zp_row
	jsr get_rowcol_addr
	lda #char_ClearLine
	jsr char_out
	ldy #$00
	sty a11
	lda (zp19_input_ptr),y
	and #char_mask_upper
	bne @echo
@next_verb_letter:
	lda (zp19_input_ptr),y
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
	lda zp19_input_ptr+1
	pha
	lda zp19_input_ptr
	pha
	lda #>vocab_table
	sta zp0E_ptr+1
	lda #<vocab_table
	sta zp0E_ptr
	lda #$00
	sta zp10_count_vocab
@next_word:
	ldy #$01
@find_string:
	lda (zp0E_ptr),y
	and #$80
	bne @found_start
	inc zp0E_ptr
	bne @find_string
	inc zp0E_ptr+1
	bne @find_string
@found_start:
	dey
	lda (zp0E_ptr),y
	cmp #'*'
	beq :+
	inc zp10_count_vocab
:	inc zp0E_ptr
	bne :+
	inc zp0E_ptr+1
:	lda #vocab_word_size
	sta zp11_count_chars
@compare_char:
	lda (zp0E_ptr),y
	and #char_mask_upper
	sta zp13_char_input
	lda (zp19_input_ptr),y
	and #char_mask_upper
	cmp zp13_char_input
	bne @mismatch
	inc zp19_input_ptr
	bne :+
	inc zp19_input_ptr+1
:	inc zp0E_ptr
	bne :+
	inc zp0E_ptr+1
:	dec zp11_count_chars
	bne @compare_char
@done:
	pla
	sta zp19_input_ptr
	pla
	sta zp19_input_ptr+1
	rts

@mismatch:
	lda zp10_count_vocab
	cmp #vocab_end-1
	beq @fail
	pla
	sta zp19_input_ptr
	pla
	sta zp19_input_ptr+1
	pha
	lda zp19_input_ptr
	pha
	jmp @next_word

@fail:
	inc zp10_count_vocab
	bne @done

wait_short:
	ldx #$90
	stx zp0F_wait2
:	dec zp0E_wait1
	bne :-
	dec zp0F_wait2
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
	lda zp0F_action
	ora zp0E_draw_param
	beq :+
	jsr draw_special
:	ldx #icmd_0A
	stx a0F
	jsr item_cmd
	lda gs_box_visible
	beq @done
	sta zp0E_draw_param
	ldx #drawcmd06_boxes
	stx zp0F_action
	jsr draw_special
@done:
	rts

wait_long:
	ldx #$05
	stx zp10_wait3
@dec16:
	ldx #$00
	stx zp0F_wait2
:	dec zp0E_wait1
	bne :-
	dec zp0F_wait2
	bne :-
	dec zp10_wait3
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
	sta gs_mode_stack2
	lda gs_special_mode
	sta gs_mode_stack1
	rts

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
	cmp a1A
	beq b110D
	dec a11
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

row8_table:
	.byte $40,$00 ;  1
	.byte $40,$80 ;  2
	.byte $41,$00 ;  3
	.byte $41,$80 ;  4
	.byte $42,$00 ;  5
	.byte $42,$80 ;  6
	.byte $43,$00 ;  7
	.byte $43,$80 ;  8
	.byte $40,$28 ;  9
	.byte $40,$a8 ; 10
	.byte $41,$28 ; 11
	.byte $41,$a8 ; 12
	.byte $42,$28 ; 13
	.byte $42,$a8 ; 14
	.byte $43,$28 ; 15
	.byte $43,$a8 ; 16
	.byte $40,$50 ; 17
	.byte $40,$d0 ; 18
	.byte $41,$50 ; 19
	.byte $41,$d0 ; 20
	.byte $42,$50 ; 21
	.byte $42,$d0 ; 22
	.byte $43,$50 ; 23
	.byte $43,$d0 ; 24
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
	sta zp13_font_ptr
	lda #$00
	sta zp13_font_ptr+1
	asl zp13_font_ptr
	rol zp13_font_ptr+1
	asl zp13_font_ptr
	rol zp13_font_ptr+1
	asl zp13_font_ptr
	rol zp13_font_ptr+1
	clc
	lda #<font
	adc zp13_font_ptr
	sta zp13_font_ptr
	lda #>font
	adc zp13_font_ptr+1
	sta zp13_font_ptr+1
	ldx #$00
	ldy #$00
	lda #$08
	sta line_count
	clc
@next_line:
	lda (zp13_font_ptr),y
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
	sta zp13_font_ptr
	lda #$00
	adc #>row8_table
	sta zp13_font_ptr+1
	ldy #$01
	clc
	lda (zp13_font_ptr),y
	adc zp_col
	sta screen_ptr
	dey
	lda (zp13_font_ptr),y
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
	lda #raster_lo 10,11,0
	sta screen_ptr
	lda #raster_hi 10,11,0
	sta screen_ptr+1
	lda #glyph_X
	jsr char_out
	jmp @draw_4_left

@draw_4_center:
	cmp #$04
	bne @draw_3_center
	lda #raster_lo 10,10,0
	sta screen_ptr
	lda #raster_hi 10,10,0
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
	lda #raster_hi 9,9,0
	sta screen_ptr+1
	lda #raster_lo 9,9,0
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
	lda #raster_hi 7,7,0
	sta screen_ptr+1
	lda #raster_lo 7,7,0
	sta screen_ptr
	ldy #$07
	jsr draw_right
	lda #raster_hi 13,7,7
	sta screen_ptr+1
	lda #raster_lo 13,7,7
	sta screen_ptr
	ldy #$07
	jsr draw_right
	jmp @draw_2_left

@draw_1_center:
	cmp #$01
	bne @draw_0_center
	lda #raster_hi 4,4,0
	sta screen_ptr+1
	lda #raster_lo 4,4,0
	sta screen_ptr
	ldy #$0d
	jsr draw_right
	lda #raster_hi 16,4,7
	sta screen_ptr+1
	lda #raster_lo 16,4,7
	sta screen_ptr
	ldy #$0d
	jsr draw_right
	jmp @draw_1_left

@draw_0_center:
	lda #raster_hi 0,0,0
	sta screen_ptr+1
	lda #raster_lo 0,0,0
	sta screen_ptr
	ldy #$15
	jsr draw_right
	lda #raster_hi 20,0,7
	sta screen_ptr+1
	lda #raster_lo 20,0,7
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
	lda #raster_hi 10,10,0
	sta screen_ptr+1
	lda #raster_lo 10,10,0
	sta screen_ptr
	lda #glyph_R
	jsr char_out
:	lda #raster_hi 10,9,0
	sta screen_ptr+1
	lda #raster_lo 10,9,0
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
	lda #raster_hi 10,10,0
	sta screen_ptr+1
	lda #raster_lo 10,10,0
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
	lda #raster_hi 10,12,0
	sta screen_ptr+1
	lda #raster_lo 10,12,0
	sta screen_ptr
	lda #glyph_L
	jsr char_out
:	lda #raster_hi 10,11,0
	sta screen_ptr+1
	lda #raster_lo 10,11,0
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
	lda #raster_hi 10,12,0
	sta screen_ptr+1
	lda #raster_lo 10,12,0
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
:	lda #raster_hi 9,7,0
	sta screen_ptr+1
	lda #raster_lo 9,7,0
	sta screen_ptr
	ldy #$02
	jsr draw_right
	lda #raster_hi 11,7,7
	sta screen_ptr+1
	lda #raster_lo 11,7,7
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
:	lda #raster_hi 9,12,0
	sta screen_ptr+1
	lda #raster_lo 9,12,0
	sta screen_ptr
	ldy #$02
	jsr draw_right
	lda #raster_hi 11,12,7
	sta screen_ptr+1
	lda #raster_lo 11,12,7
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
:	lda #raster_hi 7,4,0
	sta screen_ptr+1
	lda #raster_lo 7,4,0
	sta screen_ptr
	ldy #$03
	jsr draw_right
	lda #raster_hi 13,4,7
	sta screen_ptr+1
	lda #raster_lo 13,4,7
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
:	lda #raster_hi 7,14,0
	sta screen_ptr+1
	lda #raster_lo 7,14,0
	sta screen_ptr
	ldy #$03
	jsr draw_right
	lda #raster_hi 13,14,7
	sta screen_ptr+1
	lda #raster_lo 13,14,7
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
:	lda #raster_hi 4,0,0
	sta screen_ptr+1
	lda #raster_lo 4,0,0
	sta screen_ptr
	ldy #$04
	jsr draw_right
	lda #raster_hi 16,0,7
	sta screen_ptr+1
	lda #raster_lo 16,0,7
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
:	lda #raster_hi 4,17,0
	sta screen_ptr+1
	lda #raster_lo 4,17,0
	sta screen_ptr
	ldy #$04
	jsr draw_right
	lda #raster_hi 16,17,7
	sta screen_ptr+1
	lda #raster_lo 16,17,7
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
	lda #raster_hi 0,-1,0
	sta screen_ptr+1
	lda #raster_lo 0,-1,0
	sta screen_ptr
	ldy #$01
	jsr draw_right
	lda #raster_hi 20,-1,7
	sta screen_ptr+1
	lda #raster_lo 20,-1,7
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
	lda #raster_hi 0,21,0
	sta screen_ptr+1
	lda #raster_lo 0,21,0
	sta screen_ptr
	ldy #$01
	jsr draw_right
	lda #raster_hi 20,21,7
	sta screen_ptr+1
	lda #raster_lo 20,21,7
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
	sta zp1A_count_loop
:	jsr get_rowcol_addr
	lda #glyph_slash_up
	jsr char_out
	dec zp_col
	dec zp_col
	inc zp_row
	dec zp1A_count_loop
	bne :-
	rts

; Input: Y=count
draw_down_right:
	tya
	sta zp1A_count_loop
:	jsr get_rowcol_addr
	lda #glyph_slash_down
	jsr char_out
	inc zp_row
	dec zp1A_count_loop
	bne :-
	rts

; Input: A=char Y=count
draw_down:
	pha
	tya
	sta zp1A_count_loop
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
	dec zp1A_count_loop
	bne @next
	rts

probe_forward:
	ldy #$00
	lda #<maze_walls
	sta zp0A_walls_ptr
	lda #>maze_walls
	sta zp0A_walls_ptr+1
	ldx gs_level
	lda #$00
	clc
:	dex
	beq @find_x
	adc #$21
	jmp :-

@find_x:
	adc zp0A_walls_ptr
	sta zp0A_walls_ptr
	ldx gs_player_x
:	dex
	beq @find_y
	inc zp0A_walls_ptr
	inc zp0A_walls_ptr
	inc zp0A_walls_ptr
	jmp :-

@find_y:
	lda gs_player_y
	cmp #$05
	bmi @find_2bits  ;GUG: bcc preferred
	cmp #$09
	bmi @shift_1_byte  ;GUG: bcc preferred
@shift_2_bytes:
	inc zp0A_walls_ptr
	sec
	sbc #$04
@shift_1_byte:
	inc zp0A_walls_ptr
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
	sta zp1A_wall_bit
	stx zp19_sight_depth
	stx zp11_count
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
	lda (zp0A_walls_ptr),y
	and zp1A_wall_bit
	bne @S_sight_limit
	inc zp19_sight_depth
	lda zp19_sight_depth
	cmp #$05
	beq @S_sight_limit
	lda zp1A_wall_bit
	cmp #$80
	bne :+
	dec zp0A_walls_ptr
	lda #$02
	sta zp1A_wall_bit
	jmp probe_south

:	asl zp1A_wall_bit
	asl zp1A_wall_bit
	jmp probe_south

@S_sight_limit:
	lda zp19_sight_depth
	jsr swap_saved_A_2
	lsr zp1A_wall_bit
S_next_wall:
	lda (zp0A_walls_ptr),y
	and zp1A_wall_bit
	beq :+
	inc gs_walls_right_depth
:	ldy #$03
	lda (zp0A_walls_ptr),y
	ldy #$00
	and zp1A_wall_bit
	beq :+
	inc gs_walls_left
:	jsr swap_saved_A_2
	cmp zp11_count
	beq S_probe_done
	jsr swap_saved_A_2
	lda #$04
	cmp zp11_count
	beq S_probed_max
	asl gs_walls_left
	asl gs_walls_right_depth
	inc zp11_count
	lda zp1A_wall_bit
	cmp #$01
	beq :+
	lsr zp1A_wall_bit
	lsr zp1A_wall_bit
	jmp S_next_wall

:	lda #$40
	sta zp1A_wall_bit
	inc zp0A_walls_ptr
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
	lsr zp1A_wall_bit
@next_depth:
	clc
	lda zp0A_walls_ptr
	adc #$03
	sta zp0A_walls_ptr
	lda (zp0A_walls_ptr),y
	and zp1A_wall_bit
	bne @E_sight_limit
	inc zp19_sight_depth
	lda zp19_sight_depth
	cmp #$05
	bne @next_depth
@E_sight_limit:
	lda zp19_sight_depth
	jsr swap_saved_A_2
	lda zp1A_wall_bit
	sta zp19_wall_opposite
	asl zp1A_wall_bit
	clc
	ror zp19_wall_opposite
	bcc E_next_wall
	ror zp19_wall_opposite
E_next_wall:
	dec zp0A_walls_ptr
	dec zp0A_walls_ptr
	dec zp0A_walls_ptr
	lda (zp0A_walls_ptr),y
	and zp1A_wall_bit
	beq :+
	inc gs_walls_right_depth
:	lda zp19_wall_opposite
	cmp #$80
	beq :+
	lda (zp0A_walls_ptr),y
	jmp @check_opposite

:	iny
	lda (zp0A_walls_ptr),y
	dey
@check_opposite:
	and zp19_wall_opposite
	beq :+
	inc gs_walls_left
:	lda zp11_count
	cmp #$04
E_probed_max:
	beq S_probed_max
	jsr swap_saved_A_2
	cmp zp11_count
E_probe_done:
	beq S_probe_done
	jsr swap_saved_A_2
	inc zp11_count
	asl gs_walls_left
	asl gs_walls_right_depth
	jmp E_next_wall

probe_west:
	lsr zp1A_wall_bit
@next_depth:
	lda (zp0A_walls_ptr),y
	and zp1A_wall_bit
	bne :+
	inc zp19_sight_depth
	lda zp19_sight_depth
	cmp #$05
	beq :+
	dec zp0A_walls_ptr
	dec zp0A_walls_ptr
	dec zp0A_walls_ptr
	jmp @next_depth

:	lda zp19_sight_depth
	jsr swap_saved_A_2
	lda zp1A_wall_bit
	sta zp19_wall_opposite
	asl zp1A_wall_bit
	clc
	ror zp19_wall_opposite
	bcc W_next_wall
	ror zp19_wall_opposite
W_next_wall:
	lda (zp0A_walls_ptr),y
	and zp1A_wall_bit
	beq :+
	inc gs_walls_left
:	lda zp19_wall_opposite
	cmp #$80
	bne :+
	inc zp0A_walls_ptr
:	lda (zp0A_walls_ptr),y
	and zp19_wall_opposite
	beq :+
	inc gs_walls_right_depth
:	lda zp19_wall_opposite
	cmp #$80
	beq :+
	inc zp0A_walls_ptr
:	inc zp0A_walls_ptr
	inc zp0A_walls_ptr
	jsr swap_saved_A_2
	cmp zp11_count
	beq E_probe_done
	jsr swap_saved_A_2
	lda #$04
	cmp zp11_count
W_probed_max:
	beq E_probed_max
	inc zp11_count
	asl gs_walls_left
	asl gs_walls_right_depth
	jmp W_next_wall

probe_north:
	lda zp1A_wall_bit
	cmp #$02
	bne :+
	lda #$80
	sta zp1A_wall_bit
	inc zp0A_walls_ptr
	jmp @next_depth

:	lsr zp1A_wall_bit
	lsr zp1A_wall_bit
@next_depth:
	lda (zp0A_walls_ptr),y
	and zp1A_wall_bit
	bne @sight_limit
	inc zp19_sight_depth
	lda zp19_sight_depth
	cmp #$05
	beq @sight_limit
	lda zp1A_wall_bit
	cmp #$02
	bne :+
	inc zp0A_walls_ptr
	lda #$80
	sta zp1A_wall_bit
	jmp @next_depth

:	lsr zp1A_wall_bit
	lsr zp1A_wall_bit
	jmp @next_depth

@sight_limit:
	lda zp1A_wall_bit
	cmp #$80
	beq :+
	asl zp1A_wall_bit
	jmp @save_depth

:	dec zp0A_walls_ptr
	lda #$01
	sta zp1A_wall_bit
@save_depth:
	lda zp19_sight_depth
	jsr swap_saved_A_2
N_next_wall:
	lda (zp0A_walls_ptr),y
	and zp1A_wall_bit
	beq :+
	inc gs_walls_left
:	ldy #$03
	lda (zp0A_walls_ptr),y
	ldy #$00
	and zp1A_wall_bit
	beq :+
	inc gs_walls_right_depth
:	lda #$04
	cmp zp11_count
	beq W_probed_max
	jsr swap_saved_A_2
	cmp zp11_count
	bne :+
	jmp S_probe_done

:	jsr swap_saved_A_2
	asl gs_walls_left
	inc zp11_count
	asl gs_walls_right_depth
	lda zp1A_wall_bit
	cmp #$40
	beq :+
	asl zp1A_wall_bit
	asl zp1A_wall_bit
	jmp N_next_wall

:	lda #$01
	sta zp1A_wall_bit
	dec zp0A_walls_ptr
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

; Perform an internal command upon items.
; Input:
;   $0E object
;   $0F action  ('icmd_' constant)
; Output for location-related commands:
;   ($0E) item location info (place, position)
; Output for icmd_where:
;   $19 position
;   $1A place (level or 'carried' value)
; Output for icmd_count_inv:
;   $19 count
; Output for all icmd_which:
;   A  item number
;
item_cmd:
	lda zp0F_action
	cmp #icmds_location_end
	bpl icmd07_draw_inv  ;GUG: bcs preferred
; Convert object variable from 1-byte Index to 2-byte Pointer
	asl zp0E_object
	pha
	lda #$00
	sta zp0E_item+1
	clc
	lda #<(gs_item_locs-2)
	adc zp0E_item
	sta zp0E_item
	lda #>(gs_item_locs-2)
	adc zp0E_item+1
	sta zp0E_item+1
	pla
; Perform location-related action
	cmp #icmd_drop
	bpl icmd06_where_item  ;GUG: bcs preferred
	cmp #$00
	beq @set_place	;icmd_destroy1
	sec
	sbc #$01
	beq @set_place	;icmd_destroy2
	clc
	adc #$05		;icmd 2,3,4 => carried 6,7,8
@set_place:
	ldy #$00
	sta (zp0E_item),y
	inc zp0E_item
	bne :+
	inc zp0E_item+1
:	lda #$00
	sta (zp0E_item),y
	rts

icmd06_where_item:
	cmp #icmd_drop
	beq icmd05_drop_item
	ldy #$00
	lda (zp0E_item),y
	sta zp1A_item_place
	iny
	lda (zp0E_item),y
	sta zp19_item_position
	rts

icmd05_drop_item:
	lda gs_level
	ldy #$00
	sta (zp0E_item),y
	lda gs_player_x
	asl
	asl
	asl
	asl
	ora gs_player_y
	iny
	sta (zp0E_item),y
	rts

icmd07_draw_inv:
	sec
	sbc #icmds_location_end
	beq @clear_window
	jmp icmd08_count_inv

@clear_window:
	lda #$0f
	sta zp1A_count_loop
	lda #$19
	sta zp_col
	lda #$03
	sta zp_row
:	jsr get_rowcol_addr
	lda #$1e     ;char_ClearLine
	jsr char_out
	inc zp_row
	dec zp1A_count_loop
	bne :-

; print inventory
	lda #items_unique + items_food
	sta zp1A_count_loop
	lda #<gs_item_locs
	sta zp0E_item
	lda #>gs_item_locs
	sta zp0E_item+1
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
	lda (zp0E_item),y
	cmp #$08
	bne :+
	jmp print_known_item
:	cmp #$07
	bne next_known_item
	jmp print_known_item	;GUG: cleaner if this were JSR
next_known_item:
	inc zp0E_item
	bne :+
	inc zp0E_item+1
:	inc zp0E_item
	bne :+
	inc zp0E_item+1
:	dec zp1A_count_loop
	bne check_item_known

	lda #<gs_item_locs
	sta zp0E_item
	lda #>gs_item_locs
	sta zp0E_item+1
	lda #items_total
	sta zp1A_count_loop
check_item_boxed:
	ldy #$00
	lda (zp0E_item),y
	cmp #carried_boxed
	bne next_boxed_item
	jmp print_boxed_item	;GUG: cleaner if this were JSR

next_boxed_item:
	inc zp0E_item
	bne :+
	inc zp0E_item+1
:	inc zp0E_item
	bne :+
	inc zp0E_item+1
:	dec zp1A_count_loop
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
	lda #item_food_end
	sec
	sbc zp1A_count_loop
	cmp #item_food_begin
	bmi :+  ;GUG: bcc preferred
	lda #noun_food
:	sta zp13_temp
	lda zp_col
	pha
	lda zp_row
	pha
	lda zp13_temp
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
	sta zp1A_cmds_to_check
	dec zp1A_cmds_to_check
	bne icmd09_new_game

	lda #>gs_item_locs
	sta zp0E_item+1
	lda #<gs_item_locs
	sta zp0E_item
	lda #items_unique + items_food
	sta zp1A_count_loop
	lda #$00
	sta zp19_count
	ldy #$00
@check_carried:
	lda (zp0E_item),y
	cmp #$06
	bmi :+  ;GUG: bcc preferred
	inc zp19_count
:	iny
	iny
	dec zp1A_count_loop
	bne @check_carried
	lda gs_torch_time
	bne @add_one
	lda gs_torches_unlit
	beq @done
@add_one:
	inc zp19_count
@done:
	rts

icmd09_new_game:
	dec zp1A_cmds_to_check
	bne icmd0A

	ldy #gs_size-1
	lda #>data_new_game
	sta zp0E_src+1
	lda #<data_new_game
	sta zp0E_src
	lda #<gs_facing
	sta zp10_dst
	lda #>gs_facing
	sta zp10_dst+1
:	lda (zp0E_src),y
	sta (zp10_dst),y
	dey
	bpl :-
	rts

icmd0A:
	dec zp1A_cmds_to_check
	bne icmd0B_which_box
	jmp icmd0A_probe_boxes

; Order of preference for boxes:
;   1) at feet
;   2) carried, in noun order (except snake)
;   3) carried snake
icmd0B_which_box:
	dec zp1A_cmds_to_check
	beq :+
	jmp icmd0C_which_food

:	lda gs_player_x
	asl
	asl
	asl
	asl
	clc
	adc gs_player_y
	sta zp11_position
	lda #>(gs_item_locs+1)
	sta zp0E_item+1
	lda #<(gs_item_locs+1)
	sta zp0E_item
	lda #items_total
	sta zp1A_count_loop
	ldy #$00
	lda zp11_position
@check_is_here:
	cmp (zp0E_item),y
	beq @check_level
@not_here:
	iny
	iny
	dec zp1A_count_loop
	bne @check_is_here

	lda #>gs_item_locs
	sta zp0E_item+1
	lda #<gs_item_locs
	sta zp0E_item
	lda #noun_snake-1
	sta zp1A_count_loop
	lda #carried_boxed
	ldy #$00
@check_is_carried:
	cmp (zp0E_item),y
	beq @return_item_num
	iny
	iny
	dec zp1A_count_loop
	bne @check_is_carried

; Skip over snake
	lda #>gs_item_food_torch
	sta zp0E_item+1
	lda #<gs_item_food_torch
	sta zp0E_item
	lda #items_food + items_torches
	sta zp1A_count_loop
	ldy #$00
@next_other:
	cmp (zp0E_item),y
	beq @return_item_num
	iny
	iny
	dec zp1A_count_loop
	bne @next_other

; Last, check for carrying boxed snake
	ldx #>gs_item_snake
	stx zp0E_item+1
	ldx #<gs_item_snake
	stx zp0E_item
	ldy #$00
	cmp (zp0E_item),y
	beq @return_item_num
	lda #$00
	rts

@check_level:
	dec zp0E_item
	lda (zp0E_item),y
	sta zp13_level
	inc zp0E_item
	dey
	lda zp13_level
	cmp gs_level
	beq @return_item_num
	iny
	lda zp11_position
	jmp @not_here

@return_item_num:
	clc
	tya
	bpl :+
	lda #$00     ;clamp min 0
:	adc zp0E_item
	sta zp0E_item
	lda #$00
	adc zp0E_item+1
	sta zp0E_item+1
	sec
	lda zp0E_item
	sbc #<gs_item_locs
	clc
	ror
	clc
	adc #$01
	rts

icmd0C_which_food:
	dec zp1A_cmds_to_check
	bne icmd0D_which_torch_lit
	lda #items_food
	sta zp11_count_which
	lda #carried_known
	sta zp10_which_place
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
	lda zp10_which_place
	cmp zp1A_item_place
	beq @found
	pla
	sta zp0E_object
	pla
	sta zp0F_action
	inc zp0E_object
	dec zp11_count_which
	bne find_which_multiple
	lda #$00
	rts

@found:
	pla
	sta zp0E_object
	pla
	lda zp0E_object
	rts

icmd0D_which_torch_lit:
	dec zp1A_cmds_to_check
	bne icmd0E_which_torch_unlit
	lda #items_torches
	sta zp11_count_which
	lda #carried_active
	sta zp10_which_place
	bne set_action
icmd0E_which_torch_unlit:
	dec zp1A_cmds_to_check
	bne icmd_default
	lda #items_torches
	sta zp11_count_which
	lda #carried_known
	sta zp10_which_place
set_action:
	lda #icmd_where
	sta zp0F_action
	lda #item_torch_begin
	sta zp0E_object
	jsr find_which_multiple
icmd_default:
	rts

icmd0A_probe_boxes:
	lda gs_walls_right_depth
	and #%11100000
	lsr
	lsr
	lsr
	lsr
	lsr
	beq @none  ;GUG: inline to compact better
	cmp #$05
	bne :+
	sec
	sbc #$01
:	sta zp1A_count_loop
	lda gs_player_x
	sta zp11_pos_x
	lda gs_player_y
	sta zp10_pos_y
	lda gs_level
	sta zp19_level
	jmp @begin_probe

@none:
	lda #$00
	sta gs_box_visible
	rts

@begin_probe:
	lda zp1A_count_loop
	sta zp0F_sight_depth
	lda #$00
	sta zp0E_box_visible
@next_pos:
	lda gs_facing
	jsr move_pos_facing
	jsr any_item_here
	dec zp1A_count_loop
	beq @shift_remainder
	lsr zp0E_box_visible
	jmp @next_pos

@shift_remainder:
	lda #$04
	sec
	sbc zp0F_sight_depth
	beq @done
:	lsr zp0E_box_visible
	sec
	sbc #$01
	bne :-
@done:
	lda zp0E_box_visible
	sta gs_box_visible
	rts

any_item_here:
	pha
	lda zp11_pos_x
	pha
	lda zp10_pos_y
	pha
	lda zp0F_sight_depth
	pha
	lda zp0E_box_visible
	pha
	lda zp11_pos_x
	asl
	asl
	asl
	asl
	clc
	adc zp10_pos_y
	pha
	lda #>(gs_item_locs+1)
	sta zp0E_ptr+1
	lda #<(gs_item_locs+1)
	sta zp0E_ptr
	lda #items_total
	sta zp11_count_loop
	pla
	ldy #$00
@next_item:
	cmp (zp0E_ptr),y
	beq @match_position
@continue:
	iny
	iny
	dec zp11_count_loop
	bne @next_item
	pla
	sta zp0E_box_visible
	pla
	sta zp0F_sight_depth
@done:
	pla
	sta zp10_pos_y
	pla
	sta zp11_pos_x
	pla
	rts

@match_position:
	sta zp10_temp
	dec zp0E_ptr
	lda (zp0E_ptr),y
	inc zp0E_ptr
	cmp zp19_level
	beq @match_level
	lda zp10_temp
	jmp @continue

@match_level:
	pla
	sta zp0E_box_visible
	pla
	sta zp0F_sight_depth
	lda zp0E_box_visible
	clc
	adc #$08
	sta zp0E_box_visible
	bne @done

move_pos_facing:
	cmp #facing_W
	beq @west
	cmp #facing_N
	beq @north
	cmp #facing_E
	beq @east
@south:
	dec zp10_pos_y
	rts

@west:
	dec zp11_pos_x
	rts

@north:
	inc zp10_pos_y
	rts

@east:
	inc zp11_pos_x
	rts

; Output: $0F = action, $0E = param (input args for draw_special)
get_maze_feature:
	lda gs_facing
	asl
	asl
	asl
	asl
	clc
	adc gs_level
	sta zp11_level_facing
	lda gs_player_x
	asl
	asl
	asl
	asl
	clc
	adc gs_player_y
	sta zp10_position
	lda #>maze_features
	sta zp0E_ptr+1
	lda #<maze_features
	sta zp0E_ptr
	lda #maze_features_end
	sta zp19_count
	ldy #$00
	lda zp11_level_facing
@next:
	cmp (zp0E_ptr),y
	beq @check_position
	iny
@continue:
	iny
	iny
	iny
	dec zp19_count
	bne @next
	lda #$00
	sta zp0E_ptr+1
	sta zp0E_ptr
	rts

@check_position:
	lda zp10_position
	iny
	cmp (zp0E_ptr),y
	beq @match
	lda zp11_level_facing
	bne @continue
@match:
	iny
	lda (zp0E_ptr),y
	sta zp11_temp
	iny
	lda (zp0E_ptr),y
	sta zp0E_draw_param
	lda zp11_temp
	sta zp0F_action
	rts

keyhole_0:
	.byte $06,$0b,$0b,$07
	.byte $0b,$0b,$0b,$0b
	.byte $0b,$0b,$0b,$0b
	.byte $0b,$0b,$0b,$0b
	.byte $08,$0b,$0b,$09
	.byte $20,$0b,$0b,$20
	.byte $20,$0b,$0b,$20
	.byte $0b,$0b,$0b,$0b
	.byte $0b,$0b,$0b,$0b

draw_special:
	ldy zp0F_action
	dey
	bne @draw_2_elevator

@draw_1_keyhole:
	lda #$09
	sta zp1A_count_row
	sta zp_col
	lda #$06
	sta zp_row
	jsr get_rowcol_addr
	lda #>keyhole_0
	sta zp0A_text_ptr+1
	lda #<keyhole_0
	sta zp0A_text_ptr
	ldy #$00
@next_row:
	lda #$04
	sta zp19_count_col
@next_glyph:
	tya
	pha
	lda (zp0A_text_ptr),y
	jsr print_char
	pla
	tay
	iny
	dec zp19_count_col
	bne @next_glyph
	dec zp1A_count_row
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
	lda #raster_hi 20,0,7
	sta screen_ptr+1
	lda #raster_lo 20,0,7
	sta screen_ptr
	ldy #$14
	jsr draw_right
	lda #raster_lo 2,5,7
	sta screen_ptr
	lda #raster_hi 2,5,7
	sta screen_ptr+1
	ldy #$0a
	jsr draw_right
	lda #$07
	sta zp_col
	lda #$01
	sta zp_row
	jsr get_rowcol_addr
	lda #>@string_elevator
	sta zp0A_text_ptr+1
	lda #<@string_elevator
	sta zp0A_text_ptr
	ldy #$00
	lda #$08
	sta zp1A_count_loop
:	tya
	pha
	lda (zp0A_text_ptr),y
	jsr print_char
	pla
	tay
	iny
	dec zp1A_count_loop
	bne :-
	rts

@string_elevator:
	.byte "ELEVATOR"

@draw_3_compactor:
	dey
	beq :+
	jmp @draw_4_pit_floor

:	lda #$06
	sta zp0C_col_animate
@next_frame_3:
	lda #$00
	sta zp_row
	lda #$06
	sec
	sbc zp0C_col_animate
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
	adc zp0C_col_animate
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
	dec zp0C_col_animate
	beq :+
	jsr wait_brief
	jmp @next_frame_3

:	rts

@pit_floor_data:
	;--- distance 1 (0E = 0)
	.byte $11,$11,$04      ;X,Y,len
	.byte $05,$11,$04      ;X,Y,len
	.byte raster_hi $11,4,0
	.byte raster_lo $11,4,0
	.byte $0d              ;len
	.byte raster_hi $14,0,7
	.byte raster_lo $14,0,7
	.byte $15              ;len
	;--- distance 2 (0E > 0)
	.byte $0e,$0e,$03      ;X,Y,len
	.byte $08,$0e,$03      ;X,Y,len
	.byte raster_hi $0e,7,0
	.byte raster_lo $0e,7,0
	.byte $07              ;len
	.byte raster_hi $10,4,7
	.byte raster_lo $10,4,7
	.byte $0d              ;len

@draw_4_pit_floor:
	dey
	bne @draw_5_pit_roof

	lda #<@pit_floor_data
	sta zp0A_data_ptr
	lda #>@pit_floor_data
	sta zp0A_data_ptr+1
	lda #$02
	sta zp19_count
	lda zp0E_draw_param
	beq @pit_walls
	ldy #$0c
@pit_walls:
	lda (zp0A_data_ptr),y
	sta zp_col
	iny
	lda (zp0A_data_ptr),y
	sta zp_row
	iny
	lda (zp0A_data_ptr),y
	iny
	sta zp1A_temp  ;GUG: sty/ldy instead of pha/pla? or tya/pha before lda(),y
	tya
	pha
	lda zp1A_temp
	tay
	lda #$02
	clc
	adc zp19_count
	jsr draw_down
	pla
	tay
	dec zp19_count
	bne @pit_walls

	lda #$02
	sta zp19_count
@pit_rim:
	lda (zp0A_data_ptr),y
	sta screen_ptr+1
	iny
	lda (zp0A_data_ptr),y
	sta screen_ptr
	iny
	lda (zp0A_data_ptr),y
	sta zp1A_temp
	iny
	tya
	pha
	lda zp1A_temp
	tay
	jsr draw_right
	pla
	tay
	dec zp19_count
	bne @pit_rim
	rts

@pit_roof_data:
	;--- distance 1
	.byte $11,$00,$04      ;X,Y,len
	.byte $05,$00,$04      ;X,Y,len
	.byte raster_hi $00,0,0
	.byte raster_lo $00,0,0
	.byte $15              ;len
	.byte raster_hi $04,4,0
	.byte raster_lo $04,4,0
	.byte $0d              ;len
	;--- distance 2
	.byte $0e,$04,$03      ;X,Y,len
	.byte $08,$04,$03      ;X,Y,len
	.byte raster_hi $04,4,0
	.byte raster_lo $04,4,0
	.byte $0d              ;len
	.byte raster_hi $07,7,0
	.byte raster_lo $07,7,0
	.byte $07              ;len
	;--- distance 3 (0E = 0)
	.byte $0c,$07,$02      ;X,Y,len
	.byte $0a,$07,$02      ;X,Y,len
	.byte raster_hi $07,7,0
	.byte raster_lo $07,7,0
	.byte $07              ;len
	.byte raster_hi $09,9,0
	.byte raster_lo $09,9,0
	.byte $03              ;len

@draw_5_pit_roof:
	dey
	bne @draw_6_boxes

	lda #<@pit_roof_data
	sta zp0A_data_ptr
	lda #>@pit_roof_data
	sta zp0A_data_ptr+1
	lda #$02
	sta zp19_count
	ldy zp0E_draw_param
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
	lda #raster_hi 18,6,0
	sta screen_ptr+1
	lda #raster_lo 18,6,0
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
	ldx #raster_hi 20,6,7
	stx screen_ptr+1
	ldx #raster_lo 20,6,7
	stx screen_ptr
	ldy #$07
	jsr draw_right
@box_done:
	rts

@square_data_left:
	.byte $07,$20
	.byte $0b,$07
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$09
	.byte $09,$20
@square_data_right:
	.byte $20,$06
	.byte $06,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $08,$0b
	.byte $20,$08
@string_square:
	.byte "THEPERFECTSQUARE"

; Input: 0E = 1 right, 2 front, 4 left
@draw_7_the_square:
	dey
	beq :+
	jmp @draw_8_doors

:	lda zp0E_draw_param
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
	sta zp0A_text_ptr
	lda #>@string_square
	sta zp0A_text_ptr+1
	lda #$0a
	sta zp_col
	lda #$04
	sta zp_row
	jsr get_rowcol_addr
	lda #$03
	sta zp1A_count_loop
	jsr @print_square_row
	lda #$08
	sta zp_col
	lda #$05
	sta zp_row
	jsr get_rowcol_addr
	lda #$07
	sta zp1A_count_loop
	jsr @print_square_row
	lda #$09
	sta zp_col
	lda #$06
	sta zp_row
	jsr get_rowcol_addr
	lda #$06
	sta zp1A_count_loop
@print_square_row:
	ldy #$00
	lda (zp0A_text_ptr),y
	jsr char_out
	inc zp0A_text_ptr
	bne :+
	inc zp0A_text_ptr+1
:	dec zp1A_count_loop
	bne @print_square_row
	rts

@square_right:
	lda #<@square_data_right
	sta zp0A_text_ptr
	lda #>@square_data_right
	sta zp0A_text_ptr+1
	lda #$13
	sta zp_col
	lda #$07
	sta zp_row
	sta zp1A_count_loop
@sq_next_row:
	jsr get_rowcol_addr
	ldy #$00
	lda (zp0A_text_ptr),y
	jsr char_out
	inc zp0A_text_ptr
	bne :+
	inc zp0A_text_ptr+1
:	ldy #$00
	lda (zp0A_text_ptr),y
	jsr char_out
	inc zp0A_text_ptr
	bne :+
	inc zp0A_text_ptr+1
:	inc zp_row
	dec zp_col
	dec zp_col
	dec zp1A_count_loop
	bne @sq_next_row
	rts

@square_left:
	lda #<@square_data_left
	sta zp0A_text_ptr
	lda #>@square_data_left
	sta zp0A_text_ptr+1
	lda #$02
	sta zp_col
	lda #$07
	sta zp_row
	sta zp1A_count_loop
	jmp @sq_next_row

@draw_8_doors:
	dey
	beq :+
	jmp @draw_9_keyholes

:	lda zp0E_draw_param
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
	lda #$04
	sta zp_row
;	lda #glyph_R  ;$04, redundant
	ldy #$10
	jsr draw_down
	rts

@draw_9_keyholes:
	dey
	beq :+
	jmp draw_A_special

:	lda zp0E_draw_param
	and #$0f
	beq @keyhole_L_1
@keyhole_R_4:
	and #(1 << 3)
	beq @keyhole_R_3
	lda #$0c
	sta zp_col
	jsr draw_keyhole_4
@keyhole_R_3:
	lda zp0E_draw_param
	and #(1 << 2)
	beq @keyhole_R_2
	lda #$0d
	sta zp_col
	jsr draw_keyhole_3
@keyhole_R_2:
	lda zp0E_draw_param
	and #(1 << 1)
	beq @keyhole_R_1
	lda #$0f
	sta zp_col
	jsr draw_keyhole_2
@keyhole_R_1:
	lda zp0E_draw_param
	and #(1 << 0)
	beq @keyhole_R_done
	lda #$13
	sta zp_col
	jsr draw_keyhole_1
@keyhole_R_done:
	rts

@keyhole_L_1:
	lda zp0E_draw_param
	and #(1 << 4)
	beq @keyhole_L_2
	lda #$02
	sta zp_col
	jsr draw_keyhole_1
@keyhole_L_2:
	lda zp0E_draw_param
	and #(1 << 5)
	beq @keyhole_L_3
	lda #$05
	sta zp_col
	jsr draw_keyhole_2
@keyhole_L_3:
	lda zp0E_draw_param
	and #(1 << 6)
	beq @keyhole_L_4
	lda #$08
	sta zp_col
	jsr draw_keyhole_3
@keyhole_L_4:
	lda zp0E_draw_param
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

draw_A_special:
	lda #$0a
	sta zp_col
	lda #$03
	sta zp_row
;	lda #glyph_L  ;$03, redundant
	ldy #$12
	jsr draw_down
	lda #$0b
	sta zp_col
	lda #$03
	sta zp_row
	lda #glyph_R
	ldy #$12
	jsr draw_down
	lda #raster_hi 17,9,0
	sta screen_ptr+1
	lda #raster_lo 17,9,0
	sta screen_ptr
	ldy #$02
	jsr draw_right
	lda #$0a
	sta zp0C_col_left
	lda #$0b
	sta zp19_col_right
	lda #$04
	sta zp11_count_loop
	lda #$02
	sta zp10_length
@next_frame_opening:
	jsr wait_brief
	lda zp0C_col_left
	sta zp_col
	lda #$03
	sta zp_row
	lda #' '
	ldy #$12
	jsr draw_down
	lda zp19_col_right
	sta zp_col
	lda #$03
	sta zp_row
	lda #' '
	ldy #$12
	jsr draw_down
	dec zp0C_col_left
	inc zp19_col_right
	lda zp0C_col_left
	sta zp_col
	lda #$03
	sta zp_row
;	lda #glyph_L  ;$03, redundant
	ldy #$12
	jsr draw_down
	lda zp19_col_right
	sta zp_col
	lda #$03
	sta zp_row
	lda #glyph_R
	ldy #$12
	jsr draw_down
	lda #$11
	sta zp_row
	dec zp0C_col_left
	lda zp0C_col_left
	inc zp0C_col_left
	sta zp_col
	jsr get_rowcol_addr
	inc zp10_length
	inc zp10_length
	ldy zp10_length
	jsr draw_right
	dec zp11_count_loop
	bne @next_frame_opening
	rts

print_noun:
	sta zp13_char_input
	lda #<noun_table
	sta zp0C_string_ptr
	lda #>noun_table
	sta zp0C_string_ptr+1
	ldy #$00
@find_string:
	lda (zp0C_string_ptr),y
	bmi @found_start
@next_char:
	inc zp0C_string_ptr
	bne @find_string
	inc zp0C_string_ptr+1
	bne @find_string
@found_start:
	dec zp13_char_input
	bne @next_char
	lda (zp0C_string_ptr),y
	and #$7f
@print_char:
	jsr char_out
	inc zp0C_string_ptr
	bne :+
	inc zp0C_string_ptr+1
:	ldy #$00
	lda (zp0C_string_ptr),y
	bpl @print_char
	lda #' '
	jmp char_out

wait_brief:
	ldx #$28
	stx zp0F_wait2
:	dec zp0E_wait1
	bne :-
	dec zp0F_wait2
	bne :-
	rts

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

player_cmd:
	lda gd_parsed_object
	sta zp0E_object
	lda gd_parsed_action
	sta zp0F_action
	cmp #$0e
	bmi :+  ;GUG: bcc preferred
	jmp cmd_look

:	lda zp0E_object
	cmp #nouns_item_end
	bmi :+  ;GUG: bcc preferred
	jmp nonsense

:	jsr noun_to_item
	sta zp11_item
	lda gd_parsed_object
	sta zp0E_object
	lda gd_parsed_action
	sta zp0F_action

;cmd_raise:
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
	lda #carried_active
	cmp zp1A_item_place
	beq @having_fun
	lda #noun_ring
	sta zp0E_object
	lda #icmd_set_carried_active
	sta zp0F_action
	jsr item_cmd
	lda #$01
	sta gs_room_lit
	jsr update_view
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
	cmp #$05  ;unnecessary. special_mother is sufficient.
	bne :+
	lda gs_special_mode
	cmp #special_mode_mother
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
	lda #verb_play - verb_blow
	sta zp0F_action
cmd_break:
	dec zp0F_action
	bne cmd_burn

	lda zp0E_object
	cmp #noun_ring
	bne :+
	jsr lose_ring
:	cmp #nouns_unique_end
	bmi @broken  ;GUG: bcc preferred
	sta a13
	lda a10
	pha
	lda zp11_item
	pha
	lda a13
	cmp #noun_torch
	bne :+
	jsr lose_one_torch
:	pla
	sta zp11_item
	pla
	sta a10
	lda zp11_item
	sta zp0E_object
@broken:
; implicit, already 0
;	lda #icmd_destroy1
;	sta zp0F_action
	jsr item_cmd
	jsr update_view
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
	lda #special_mode_dark
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
	bmi @burned  ;GUG: bcc preferred
	cmp #noun_torch
	beq make_cmd_light
	lda zp11_item
	sta zp0E_object
@burned:
; implicit, already 0
;	lda #icmd_destroy1
;	sta zp0F_action
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
	bmi @eaten  ;GUG: bcc preferred
	beq @food
	cmp #noun_torch
	beq @torch
@torch_return:
	lda zp11_item
	sta zp0E_object
@eaten:
; implicit, already 0
;	lda #icmd_destroy1
;	sta zp0F_action
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
	sta zp0F_action
	jmp item_cmd

@torch:
	lda a10
	pha
	lda zp11_item
	pha
	jsr lose_one_torch
	pla
	sta zp11_item
	pla
	sta a10
	jmp @torch_return

@food:
	lda zp11_item
	sta zp0E_object
; implicit, already 0
;	lda #icmd_destroy1
;	sta zp0F_action
	jsr item_cmd
	lda gs_food_time_hi
	sta zp0E_count16+1
	lda gs_food_time_lo
	sta zp0E_count16
	lda #<food_eat_amount
	sta zp19_delta16
	lda #>food_eat_amount
	sta zp19_delta16+1
	clc
	lda zp19_delta16
	adc zp0E_count16
	sta zp0E_count16
	lda zp19_delta16+1
	adc zp0E_count16+1
	sta zp0E_count16+1
	sta gs_food_time_hi
	lda zp0E_count16
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
	dec zp0F_action
	beq :+
	jmp cmd_climb

:	lda zp0E_object
	cmp #noun_ring
	bne :+
	jsr lose_ring
:	cmp #noun_frisbee
	bne :+
	jmp throw_frisbee

:	cmp #noun_wool
	beq throw_wool
	cmp #noun_yoyo
	beq throw_yoyo
	cmp #noun_food
	bmi thrown  ;GUG: bcc preferred
	beq throw_food
	cmp #noun_torch
	bne :+
	jsr lose_one_torch
:	lda zp11_item
	sta zp0E_object
thrown:
; implicit, already 0
;	lda #icmd_destroy1
;	sta zp0F_action
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

throw_wool:
	lda gs_level
	cmp #$04
	bne thrown
	lda gs_level_turns_lo
	cmp #turns_until_trippable
	bcc thrown
	jsr push_special_mode
	lda #special_mode_tripped
	sta gs_special_mode
	lda #noun_wool
	sta zp0E_object
	lda #icmd_destroy1
	sta zp0F_action
	jsr item_cmd
	jsr print_thrown
	lda #$5e     ;and the monster grabs it,
	jsr print_to_line1
	lda #$5f     ;gets tangled, and topples over!
	jsr print_to_line2
	lda #$00
	sta gs_monster_proximity
	rts

throw_yoyo:
	jsr print_thrown
	lda #$6b     ;returns and hits you
	jsr print_to_line1
	lda #$6c     ;in the eye!
	jmp print_to_line2

throw_food:
	lda zp11_item
	sta zp0E_object
	jsr item_cmd
	lda #icmd_draw_inv
	sta zp0F_action
	jsr item_cmd
	lda #$81     ;Food fight!
	jmp print_to_line2

print_thrown:
	lda #icmd_draw_inv
	sta zp0F_action
	jsr item_cmd
	lda #$59     ;The
	jsr print_to_line1
	lda gd_parsed_object
	jsr print_noun
	;---------------------
	; This section has no effect.
	; Probably it used to conditionally
	; print a space, but zp0E points to
	; end of item list after icmd_draw_inv,
	; not text buffer.
	jsr dec_item_ptr
	lda #' '
	ldy #$00
	cmp (zp0E_item),y
	beq :+
	inc zp0E_item
	bne :+
	inc zp0E_item+1
:	inc zp0E_item
	bne :+
	inc zp0E_item+1
	;---------------------
:	lda #$5a     ;magically sails
	jsr print_display_string
	lda #$5b     ;around a nearby corner
	jsr print_to_line2
	jsr wait_long
	jmp clear_status_lines

throw_frisbee:
	lda gs_monster_alive
	and #monster_flag_roaming
	bne :+
	jmp thrown

:	lda #noun_frisbee
	sta zp0E_object
	lda #icmd_destroy1
	sta zp0F_action
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
	bpl @multiples  ;GUG: bcs preferred
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
	lda zp11_item
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
	lda #special_mode_dark
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

	sta zp11_action ;GUG: no effect.
		; Maybe earlier revision of cmd_light_impl used zp11
		; to distinguish "light torch" from "raise ring"?
	lda zp0E_object
	cmp #noun_torch
	beq :+
	jmp nonsense

:	lda zp1A_item_place ;still known from noun_to_item
	cmp #carried_active
	bne cmd_light_impl
	jmp not_carried  ;only have an already-lit torch

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
	cmp #noun_flute
	beq play_flute
	cmp #noun_ball
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
	cmp zp19_item_position
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
	sta zp0F_action
	lda #noun_snake
	sta zp0E_object
	jsr item_cmd
	jsr push_special_mode
	lda #special_mode_climb
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
	bmi look_item  ;GUG: bcc preferred
	cmp #noun_zero
	bmi :+  ;GUG: bcc preferred
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
	sta zp11_item
	beq look_not_here
	lda zp10_noun
	pha
	lda zp11_item
	pha
	sta zp0E_object
	lda #icmd_where
	sta zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_begin
	bcs :+
	jmp @check_contents

:	lda zp11_item
	sta zp0E_object
	lda #icmd_set_carried_known
	sta zp0F_action
	jsr item_cmd
@check_contents:
	lda zp11_item
	cmp #noun_snake
	beq @push_mode_snake
;	cmp #nouns_unique_end - 1   ;same as #noun_snake
	bmi @print_item_name  ;GUG: bcc preferred
	cmp #item_torch_begin
	bmi :+  ;GUG: bcc preferred
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
	sta zp11_item
	pla
	sta zp10_noun
	lda a13
	cmp #noun_torch
	bne @done
	lda #icmd_where
	sta zp0F_action
	lda zp11_item
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
	ldx #special_mode_snake
	stx gs_special_mode
	lda #noun_snake
	bne @print_item_name

@open_door:
	jsr which_door
	cmp #$00
	bne :+
	jmp look_not_here

:	cmp #doors_locked_begin
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
	bmi @no_key  ;GUG: bcc preferred
	jsr swap_saved_A
	clc
	adc #doormsg_lock_begin - doors_locked_begin
	cmp #doormsg_lock_begin + (door_correct - 1)
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
	lda #doormsg_lock_begin + (door_correct - 1)
	jmp print_to_line2

@push_mode_elevator:
	jsr push_special_mode
	ldx #special_mode_elevator
	stx gs_special_mode
	jmp draw_doors_opening

which_door:
	ldx #<door_table
	stx zp0E_ptr
	ldx #>door_table
	stx zp0E_ptr+1
	ldx gs_level
	stx zp19_level_facing
	lda gs_player_x
	ldx #$04
	stx zp1A_count_loop
:	asl
	asl zp19_level_facing
	dec zp1A_count_loop
	bne :-
	clc
	adc gs_player_y
	sta zp11_position
	lda zp19_level_facing
	clc
	adc gs_facing
	sta zp19_level_facing
	ldx #doors
	stx zp1A_count_loop
@find:
	ldy #$00
	cmp (zp0E_ptr),y
	bne @next2
	lda zp11_position
	inc zp0E_ptr
	bne :+
	inc zp0E_ptr+1
:	cmp (zp0E_ptr),y
	bne @next1
	lda #doors + 1
	sec
	sbc zp1A_count_loop
	rts

@next2:
	inc zp0E_ptr
	bne @next1
	inc zp0E_ptr+1
@next1:
	inc zp0E_ptr
	bne :+
	inc zp0E_ptr+1
:	lda zp19_level_facing
	dec zp1A_count_loop
	bne @find
	lda #$00
	rts

door_table:
	.byte $23,$77
	.byte $31,$44
	.byte $42,$14
	.byte $52,$35
	.byte $52,$4a
	.byte $52,$5a
	.byte $52,$6a
	.byte $52,$7a
	.byte $52,$8a
doors = (* - door_table) / 2
doors_locked_begin = 1 + (doors - doors_locked)  ;one-based indexing

cmd_press:
	dec zp0F_action
	beq :+
	jmp cmd_take

:	lda zp0E_object
	cmp #noun_zero
	bpl :+  ;GUG: bcs preferred
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

:	lda gs_monster_alive
	and #monster_flag_roaming
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
	stx zp0E_ptr
	ldx #>teleport_table
	stx zp0E_ptr+1
@find_location:
	sec
	sbc #$01
	beq @found
	clc
	pha
	lda #$04
	adc zp0E_ptr
	sta zp0E_ptr
	lda zp0E_ptr+1
	adc #$00
	sta zp0E_ptr+1
	pla
	jmp @find_location

@found:
	ldy #$00
	lda (zp0E_ptr),y
	sta gs_facing
	inc zp0E_ptr
	bne :+
	inc zp0E_ptr+1
:	lda (zp0E_ptr),y
	sta gs_level
	inc zp0E_ptr
	bne :+
	inc zp0E_ptr+1
:	lda (zp0E_ptr),y
	sta gs_player_x
	inc zp0E_ptr
	bne :+
	inc zp0E_ptr+1
:	lda (zp0E_ptr),y
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
	ldx #special_mode_dark
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
	tax  ;GUG: no effect
	bne :+
	jmp cannot_take

:	sta zp11_box_item
	sta zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda gd_parsed_object
	cmp #noun_box
	bne :+
	jmp take_box

:	cmp #nouns_unique_end
	bmi @unique_item  ;GUG: bcc preferred
	jmp take_multiple

@unique_item:
	cmp zp11_box_item
	bne @open_if_carried
	ldx zp11_box_item
	stx zp0E_object
	lda zp1A_item_place
	cmp #carried_boxed
	bne take_if_space ;at feet
	lda zp11_box_item
@open_if_carried:
	sta zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #carried_boxed
	cmp zp1A_item_place
	beq :+
	jmp cannot_take

:	ldx gd_parsed_object
	stx zp0E_object
	jmp take_and_reveal

ensure_inv_space:
	jsr swap_saved_vars
	ldx #icmd_count_inv
	stx zp0F_action
	jsr item_cmd
	lda zp19_count
	cmp #inventory_max
	bcc :+
	jmp inventory_full

:	jmp swap_saved_vars

take_if_space:
	jsr ensure_inv_space
take_and_reveal:
	ldx #icmd_set_carried_known
	stx zp0F_action
	jsr item_cmd
react_taken:
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

take_box:
	lda zp1A_item_place
	cmp #carried_begin
	bpl cannot_take  ;GUG: bcs preferred
	jsr ensure_inv_space
	ldx zp11_box_item
	stx zp0E_object
	ldx #icmd_set_carried_boxed
	stx zp0F_action
	jsr item_cmd
	jmp react_taken

take_multiple:
	cmp #noun_food
	beq @food

;@torch:
	lda zp11_box_item
	cmp #item_torch_end
	bpl find_boxed_torch  ;GUG: bcs preferred
	cmp #item_torch_begin
	bmi find_boxed_torch  ;GUG: bcc preferred
	ldx zp11_box_item
	stx zp0E_object
	lda zp1A_item_place
	cmp #carried_boxed
	beq take_and_reveal    ;BUG: get box > get torch: does not increment unlit count if it's the only box
	jsr ensure_inv_space
	inc gs_torches_unlit
	jmp take_and_reveal

@food:
	lda zp11_box_item
	cmp #item_food_end
	bpl find_boxed_food  ;GUG: bcs preferred
	cmp #item_food_begin
	bmi find_boxed_food  ;GUG: bcc preferred
	ldx zp11_box_item
	stx zp0E_object
	lda zp1A_item_place
	cmp #carried_boxed
	bne :+
	jmp take_and_reveal

:	jmp take_if_space

cannot_take:
	lda #$9a     ;It is currently impossible.
take_print_and_return:
	jmp print_to_line2

inventory_full:
	;BUG? suspicious. Stack leak?
	pla
	sta zp0E_object
	pla
	sta zp0F_action
	jsr swap_saved_vars
	lda #$99     ;Carrying the limit.
	bne take_print_and_return

find_boxed_torch:
	ldx #item_torch_begin - 1
	stx zp0E_object
	bne find_boxed
find_boxed_food:
	ldx #item_food_begin - 1
	stx zp0E_object
find_boxed:
	; Leftover 16-bit increment from earlier design.
	; Pointless but harmless.
	lda zp0F_action
	pha
	lda zp0E_object
	pha
	ldx #items_food
	.assert items_food = items_torches, error, "Need to edit cmd_take for separate food,torch counts"
	stx zp11_count
@next:
	; Leftover 16-bit increment from earlier design.
	; Pointless now but harmless.
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
	dec zp11_count
	bne @next
	pla
	sta zp0E_object
	pla
	sta zp0F_action
	jmp cannot_take

@found:
	pla
	sta zp0E_object
	pla
	sta zp0F_action
	lda gd_parsed_object
	cmp #noun_torch
	beq :+
	jmp take_and_reveal

:	inc gs_torches_unlit
	jmp take_and_reveal

cmd_attack:
	dec zp0F_action
	bne cmd_paint

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
print_line2_ap:
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
	bne print_line2_ap

cmd_grendel:
	dec zp0F_action
	bne cmd_say
	jmp nonsense ;GUG: maybe disguise this better

cmd_say:
	dec zp0F_action
	bne cmd_charge
	lda #$76     ;OK...
	jsr print_to_line2
	lda #<text_buffer_line1
	sta zp0E_ptr
	lda #>text_buffer_line1
	sta zp0E_ptr+1
	ldy #$00
	lda #' '
:	cmp (zp0E_ptr),y
	beq @next_char
	inc zp0E_ptr
	bne :-
	inc zp0E_ptr+1
	bne :-
@echo_word:
	ldy #$00
	lda (zp0E_ptr),y
	cmp #' '
	beq @done
	sta (zp0A_text_ptr),y
	jsr print_char
@next_char:
	inc zp0A_text_ptr
	bne :+
	inc zp0A_text_ptr+1
:	inc zp0E_ptr
	bne @echo_word
	inc zp0E_ptr+1
	bne @echo_word
@done:
	rts

cmd_charge:
	dec zp0F_action
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
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #carried_active
	cmp zp1A_item_place
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
	stx gs_level_turns_hi
	stx gs_level_turns_lo
	jmp update_view

@normal:
	lda gs_walls_right_depth
	and #%11100000
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
	dec zp0F_action
	beq check_fart
	jmp cmd_save

flash_screen:
	ldx #<screen_GR1
	stx zp0E_ptr
	ldx #>screen_GR1
	stx zp0E_ptr+1
	ldy #$00
@fill:
	lda #$dd     ;yellow
:	sta (zp0E_ptr),y
	inc zp0E_ptr
	bne :-
	inc zp0E_ptr+1
	lda zp0E_ptr+1
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
	and #%11100000
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
	jsr complete_turn
	jmp @next_propel

@guillotine:
	jsr update_view
	jsr wait_short
	jmp beheaded

; Deduct food amount (10). If already <=15, set to 5. If <=5, starve.
@wall:
	jsr update_view ;GUG: is this draw necessary?
	ldx gs_food_time_hi
	stx zp0E_count16+1
	ldx gs_food_time_lo
	stx zp0E_count16
	lda zp0E_count16+1
	bne @consume_food
	lda zp0E_count16
	cmp #food_fart_minimum
	bcs :+
	jmp starved

:	cmp #food_fart_minimum + food_fart_consume
	bcc @clamp_minimum
@consume_food:
	lda #>food_fart_consume
	sta zp19_delta16+1
	lda #<food_fart_consume
	sta zp19_delta16
	lda zp0E_count16
	sec
	sbc zp19_delta16
	sta zp0E_count16
	lda zp0E_count16+1
	sbc zp19_delta16+1
	sta zp0E_count16+1
	sta gs_food_time_hi
	lda zp0E_count16
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
	dec zp0F_action
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
	dec zp0F_action
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
	dec zp0F_action
	bne cmd_hint
	jsr clear_hgr2
	lda #$00
	sta zp_col
	sta zp_row
	jsr get_rowcol_addr
	ldx #<(intro_text-1)
	stx zp0E_ptr
	ldx #>(intro_text-1)
	stx zp0E_ptr+1
@next_char:
	inc zp0E_ptr
	bne :+
	inc zp0E_ptr+1
:	ldy #$00
	lda (zp0E_ptr),y
	and #$7f
	jsr char_out
	ldy #$00
	lda (zp0E_ptr),y
	bpl @next_char
	jsr input_char
	jsr clear_hgr2
	jsr update_view
	lda #icmd_draw_inv
	sta zp0F_action
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
	lda #drawcmd0A_door_opening
	sta zp0F_action
	jmp draw_special

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

dec_item_ptr:
	pha
	dec zp0E_item
	lda zp0E_item
	cmp #$ff
	bne :+
	dec zp0E_item+1
:	pla
	rts

text_hat:
	.byte "AN INSCRIPTION READS: WEAR THIS HAT AND "
	.byte "CHARGE A WALL NEAR WHERE YOU FOUND IT!", $A0
look_hat:
	ldx #>text_hat
	stx zp0C_string_ptr+1
	ldx #<text_hat
	stx zp0C_string_ptr
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
	and #monster_flag_roaming
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
	jsr update_view
	jsr @init_puzzle
	ldx #$01
	stx zp1A_hint_mode
	jsr @print_hint
@puzzle_loop:
	jsr get_player_input
	lda gd_parsed_action
	cmp #$46
	bpl @move  ;GUG: bcs preferred
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
	ldx a1A      ;Set initial turn direction
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
;@success
	ldx #$04
	stx gs_facing
	jsr update_view
	jsr @init_puzzle
	jmp pop_special_mode

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
	beq :+
	cmp #verb_movement_begin
	bpl :+  ;GUG: bcs preferred
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

:	jsr update_view
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
pop_special_mode:
	lda gs_mode_stack1
	sta zp1A_temp
	sta gs_special_mode
	ldx gs_mode_stack2
	stx gs_mode_stack1
	ldx #$00
	stx gs_mode_stack2
	lda zp1A_temp
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
	jmp pop_special_mode

@dog2:
	dex
	beq :+
	jmp special_monster

:	jsr @confront_dog
	ldx #$00
	stx gs_dog2_alive
	jmp pop_special_mode

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
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #carried_known
	cmp zp1A_item_place
	beq @with_dagger
	ldx #noun_sword
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #carried_known
	cmp zp1A_item_place
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
	stx zp0F_action
	ldx #noun_dagger
	stx zp0E_object
	jsr item_cmd
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
	lda #$64     ;The dagger disappears!
	jsr print_to_line2
	jmp @killed

@throw:
	lda a1A
	cmp #noun_sneaker
	bne @dead
	ldx #noun_sneaker
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #carried_known
	cmp zp1A_item_place
	bne @dead
	ldx #noun_sneaker
	stx zp0E_object
	ldx #icmd_destroy1
	stx zp0F_action
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
	lda #carried_active
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
	lda #carried_active
	cmp zp1A_item_place
	bne @input_near_mother
	lda #$49     ;She has been seduced!
	jsr print_to_line2
@input_near_mother:
	lda zp1A_item_place
	pha
	lda zp19_item_position
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
	sta zp19_item_position
	pla
	sta zp1A_item_place
	lda #carried_active
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
	sta zp19_item_position
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
	lda #carried_known
	cmp zp1A_item_place
	bne @dead_pop
	pla
	sta zp19_item_position
	pla
	sta zp1A_item_place
	lda #carried_active
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
	jmp pop_special_mode

@unlit:
	ldx #$00
	stx gs_level_turns_lo ;GUG: careful, if I revise to allow re-lighting torch
	lda gs_mother_proximity
	bne @monster_smell
	lda gs_level
	cmp #$05
	beq @check_mother
	lda gs_monster_alive
	and #monster_flag_roaming
	bne @tremble
@cancel:
	jmp pop_special_mode

@check_mother:
	lda gs_mother_alive
	beq @cancel
@tremble:
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
	cmp #carried_unboxed
	bpl @b3842  ;GUG: bcs preferred
	ldx #noun_sword
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_unboxed
	bmi dead_by_snake  ;GUG: bcc preferred
	bpl @killed  ;GUG: bcs preferred
@b3842:
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
	jmp pop_special_mode

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
	sta zp1A_facing
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
	cmp zp1A_facing
	bne @tick
	ldx #drawcmd01_keyhole
	stx zp0F_action
	bne @draw_keyhole
@distance_1:
	lda #$02
	cmp zp1A_facing
	bne @tick
	ldx #$10
	stx zp0E_draw_param
	ldx #drawcmd09_keyholes
	stx zp0F_action
	jmp @draw_keyhole

@distance_2:
	lda #$02
	cmp zp1A_facing
	bne @tick
	ldx #$20
	stx zp0E_draw_param
	lda #drawcmd09_keyholes
	stx zp0F_action
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
	jmp special_exit

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
	jmp special_exit

@continue:
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
	cmp #verb_forward
	beq enter_elevator
pop_mode_stack:
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
	jmp pop_special_mode

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
	stx zp0F_action  ;GUG: no effect
	stx gs_walls_left
	ldx #$23
	stx zp0E_draw_param  ;GUG: no effect
	stx gs_walls_right_depth
	jsr draw_maze
	ldx #drawcmd03_compactor
	stx zp0F_action
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
	stx gs_level_turns_hi
	stx gs_level_turns_lo
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
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #carried_known
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
	stx zp0F_action
	ldx #noun_jar
	stx zp0E_object
	jsr item_cmd
	lda #carried_known
	cmp zp1A_item_place
	bne @done
	ldx #noun_jar
	stx zp0E_object
	ldx #icmd_set_carried_active
	stx zp0F_action
	jsr item_cmd
	lda #$60     ;It is now full of blood.
	jsr print_to_line2
	jmp pop_special_mode

@look:
	lda #$8c     ;It looks very dangerous!
	jsr print_to_line1
	jsr get_player_input
	jmp @check_input

@done:
	jsr clear_status_lines
	lda #$78     ;The body has vanished!
	jsr print_to_line1
	jmp pop_mode_stack

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
	sta zp1A_pos_x
	lda gs_player_y
	sta zp19_pos_y
	lda gs_level
	cmp #$03
	beq @on_level_3
	cmp #$04
	bne @ceiling
@on_level_4:
	lda zp1A_pos_x
	cmp #$01
	bne @ceiling
	lda zp19_pos_y
	cmp #$0a
	bne @ceiling
	jmp @to_level_3

@on_level_3:
	lda zp1A_pos_x
	cmp #$08
	bne @ceiling
	lda zp19_pos_y
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
	stx zp19_regular_climb
	inx
	stx gs_facing
	jmp @up_level

@to_level_3:
	ldx #$00
	stx zp19_regular_climb
	ldx #$03
	stx gs_facing
@up_level:
	dec gs_level
	lda zp1A_pos_x
	pha
	lda zp19_regular_climb
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
	sta zp19_regular_climb
	pla
	sta zp1A_pos_x
	pha
	lda zp19_regular_climb
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
	stx zp0E_object
	ldx #icmd_destroy1
	stx zp0F_action
	jsr item_cmd
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
	pla
	sta zp19_regular_climb
	pla
	sta zp1A_pos_x
	lda zp19_regular_climb
	cmp #$01
	bne @in_lair
	jmp pop_special_mode

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
	stx zp0F_action
	ldx #noun_wool
	stx zp0E_object
	jsr item_cmd
	ldx #$01
	stx gs_lair_raided
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
:	ldx #$01
	stx gs_snake_used
	ldx #icmd_draw_inv
	stx zp0F_action
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
	ldx #$00 ;distance
	stx zp0E_draw_param
	ldx #drawcmd04_pit_floor
	stx zp0F_action
	cmp #$01
	bne :+
	lda gs_room_lit
	beq :+
	lda gs_walls_right_depth
	and #%11100000
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
	jmp pop_special_mode

special_exit:
	jsr clear_maze_window
	lda #$07
	sta gs_walls_left
	ldx #$47
	stx gs_walls_right_depth
	jsr draw_maze
	ldx #drawcmd08_doors
	stx zp0F_action
	ldx #$01
	stx zp0E_draw_param
	jsr draw_special
	ldx #$01
	stx gs_exit_turns
j3CA6:
	lda #$a0     ;Don't make unnecessary turns.
	jsr print_to_line1
	jsr get_player_input
	lda gs_exit_turns
	sta a1A
	lda gd_parsed_action
	dec a1A
	bne b3CE9
	cmp #$5a
	bpl b3CC1  ;GUG: bcs preferred
	jmp j3ECA

b3CC1:
	cmp #$5b
	beq b3CC8
	jmp j3EAA

b3CC8:
	jsr clear_maze_window
	ldx #$03
	stx gs_walls_left
	ldx #$23
	stx gs_walls_right_depth
	jsr draw_maze
	ldx #drawcmd08_doors
	stx zp0F_action
	ldx #$02
	stx zp0E_draw_param
	jsr draw_special
	inc gs_exit_turns
	jmp j3CA6

b3CE9:
	dec a1A
	bne b3D11
	cmp #$5a
	bpl b3CF4  ;GUG: bcs preferred
	jmp j3ECA

b3CF4:
	cmp #$5b
	beq b3CFB
	jmp j3EAA

b3CFB:
	jsr clear_maze_window
	ldx #<p01
	stx gs_walls_left
	ldx #>p01
	stx gs_walls_right_depth
	jsr draw_maze
	inc gs_exit_turns
	jmp j3CA6

b3D11:
	dec a1A
	bne b3D40
	cmp #$5a
	bpl b3D1C  ;GUG: bcs preferred
	jmp j3ECA

b3D1C:
	cmp #$5d
	beq b3D23
	jmp j3EAA

b3D23:
	jsr clear_maze_window
	ldx #<p01
	stx gs_walls_left
	ldx #>p01
	stx gs_walls_right_depth
	jsr draw_maze
	ldx #drawcmd02_elevator
	stx zp0F_action
	jsr draw_special
	inc gs_exit_turns
	jmp j3CA6

b3D40:
	dec a1A
	bne b3D69
	cmp #$5a
	bmi b3D4B  ;GUG: bcc preferred
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
	ldx #drawcmd0A_door_opening
	stx zp0F_action
	jsr draw_special
	inc gs_exit_turns
	jmp j3CA6

b3D69:
	dec a1A
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
	bmi b3D95  ;GUG: bcc preferred
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
	cmp #carried_known
	bne b3D99
	jsr clear_maze_window
	jsr flash_screen
	ldx #$07
	stx gs_walls_left
	ldx #$46
	stx gs_walls_right_depth
	jsr draw_maze
	ldx #icmd_destroy2
	stx zp0F_action
;	ldx #noun_ball  ;optimized - same value as icmd_destroy2
	stx zp0E_object
	jsr item_cmd
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
	inc gs_exit_turns
	jmp j3CA6

b3DDD:
	dec a1A
	bne b3E05
	cmp #$5a
	bpl b3DE8  ;GUG: bcs preferred
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
	stx gs_walls_left
	ldx #$23
	stx gs_walls_right_depth
	jsr draw_maze
	inc gs_exit_turns
	jmp j3CA6

b3E05:
	cmp #$5a
	bmi b3DE5  ;GUG: bcc preferred
	cmp #$5b
	bne b3DEC
	jsr clear_maze_window
	ldx #$01
	stx gs_walls_left
	stx gs_walls_right_depth
	jsr draw_maze
j3E1B:
	lda #$3c     ;Before I let you go free
	jsr print_to_line1
	lda #$3d     ;what was the name of the monster?
	jsr print_to_line2
	jsr get_player_input
	lda gd_parsed_action
	cmp #$5a
	bpl b3DEC  ;GUG: bcs preferred
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
	stx zp0C_string_ptr
	ldx #>p3E36
	stx zp0C_string_ptr+1
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
	stx zp0C_string_ptr
	ldx #>text_congrats
	stx zp0C_string_ptr+1
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


; cruft leftover from earlier build
	.byte $86
	inc aC3
	bne b3EDC
	ldx #$2e
	jsr $244B ;within keyhole
b3EDC:
	stx aBE
	stx aBD
	lda a018F
	beq b3F40
	lda f0135,y
	cmp #$28
	beq b3EF4
	ldx #$25
	jsr $244B ;within keyhole
	jmp j3F56

b3EF4:
	stx aE5
	iny
	jsr $2510 ;draw_keyhole somewhere
	cmp #$3b
	beq b3F38
	cpy #$50
; (end cruft)

relocate_data:
	lda relocated
	beq @write_DEATH

; Relocate data above HGR2: ($4000-$5FFF) to ($6000-$7FFF)
	ldx #<screen_HGR2
	stx zp0E_src
	stx zp10_dst
	stx relocated
	ldx #>screen_HGR2
	stx zp0E_src+1
	ldx #>(screen_HGR2 + screen_HGR_size)
	stx zp10_dst+1
	ldx #<(screen_HGR_size - 1)
	stx zp19_count
	ldx #>(screen_HGR_size - 1)
	stx zp19_count+1
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

; cruft leftover from earlier build
	ldy #$00
	tya
	sta (pC2),y
	cmp #$ff
	bne b3F68
	dec aC3
b3F68:
	pla
	pla
	jmp $2C04 ;within open_box

	stx aBC
	ldx #$2b
	jsr $244B ;within keyhole
	jmp $2C04 ;within open_box

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

	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00

; cruft leftover from earlier build
	lda aEE
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

	jsr $FD35
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


	.segment "HIGH"

	.assert * = $6000, error, "Unexpected alignment"
maze_walls:
	;Each 3-byte sequence is one column, south to north (max 12 cells)
	;Each pair of bits is whether there is a wall to South and West of each cell.
	; Level 1
	.byte %11010101,%01111101,%01010111 ; $d5,$7d,$57
	.byte %10100110,%10010101,%11010011 ; $a6,$95,$d3
	.byte %10110110,%01010110,%10011100 ; $b6,$56,$9c
	.byte %10100101,%11011010,%01001000 ; $a5,$da,$48
	.byte %10010110,%00010011,%01101111 ; $96,$13,$6f
	.byte %11001011,%10010100,%10101111 ; $cb,$94,$af
	.byte %10111000,%01010111,%00101111 ; $b8,$57,$2f
	.byte %10101001,%11011010,%01101111 ; $a9,$da,$6f
	.byte %10100011,%01001001,%00101111 ; $a3,$49,$2f
	.byte %10010100,%10010101,%00001111 ; $94,$95,$0f
	.byte %11111111,%11111111,%11111111 ; $ff,$ff,$ff
	; Level 2
	.byte %11011111,%01110111,%01011111 ; $df,$77,$5f
	.byte %11001000,%10101010,%11001111 ; $c8,$aa,$cf
	.byte %10011101,%00011010,%11011111 ; $9d,$1a,$df
	.byte %11001101,%01001010,%01101111 ; $cd,$4a,$6f
	.byte %10011011,%01101000,%10001111 ; $9b,$68,$8f
	.byte %10100010,%10100100,%11011111 ; $a2,$a4,$df
	.byte %10010110,%10010110,%10101111 ; $96,$96,$af
	.byte %11011000,%01001110,%11001111 ; $d8,$4e,$cf
	.byte %10110111,%01110110,%10011111 ; $b7,$76,$9f
	.byte %10001000,%10001000,%01001111 ; $88,$88,$4f
	.byte %11111111,%11111111,%11111111 ; $ff,$ff,$ff
	; Level 3
	.byte %11010101,%11010101,%01111111 ; $d5,$d5,$7f
	.byte %10011100,%10111101,%10101111 ; $9c,$bd,$af
	.byte %11001011,%10100010,%10011111 ; $cb,$a2,$9f
	.byte %10011001,%10110110,%00101111 ; $99,$b6,$2f
	.byte %11001101,%10011001,%00101111 ; $cd,$99,$2f
	.byte %10100010,%01010101,%10101111 ; $a2,$55,$af
	.byte %10110101,%01011010,%10111111 ; $b5,$5a,$bf
	.byte %10001101,%11100010,%01101111 ; $8d,$e2,$6f
	.byte %10100010,%00110111,%00101111 ; $a2,$37,$2f
	.byte %10010101,%01010100,%01001111 ; $95,$54,$4f
	.byte %11111111,%11111111,%11111111 ; $ff,$ff,$ff
	; Level 4
	.byte %11010111,%11110111,%01111111 ; $d7,$f7,$7f
	.byte %10110010,%01100110,%10101111 ; $b2,$66,$af
	.byte %10100101,%00101000,%10101111 ; $a5,$28,$af
	.byte %10010111,%00001100,%10001111 ; $97,$0c,$8f
	.byte %11001000,%10111011,%11011111 ; $c8,$bb,$df
	.byte %10011011,%00100010,%00101111 ; $9b,$22,$2f
	.byte %11101010,%11011001,%01101111 ; $ea,$d9,$6f
	.byte %10010010,%00101101,%10101111 ; $92,$2d,$af
	.byte %11010011,%00100010,%00101111 ; $d3,$22,$2f
	.byte %10010100,%01010101,%01001111 ; $94,$55,$4f
	.byte %11111111,%11111111,%11111111 ; $ff,$ff,$ff
	; Level 5
	.byte %11010111,%01010101,%11011111 ; $d7,$55,$df
	.byte %10011010,%11001100,%01001111 ; $9a,$cc,$4f
	.byte %11011010,%10111001,%01011111 ; $da,$b9,$5f
	.byte %10100000,%11110110,%01101111 ; $a0,$f6,$6f
	.byte %10110001,%10011011,%00101111 ; $b1,$9b,$2f
	.byte %10101100,%11100000,%01101111 ; $ac,$e0,$6f
	.byte %10111101,%10011101,%10101111 ; $bd,$9d,$af
	.byte %10101010,%01001010,%10101111 ; $aa,$4a,$af
	.byte %10100010,%01010010,%00101111 ; $a2,$52,$2f
	.byte %10011100,%10011101,%00000111 ; $9c,$9d,$07
	.byte %11111111,%11111111,%11111111 ; $ff,$ff,$ff

; facing|level, X|Y, drawcmd, draw_param
maze_features:
	.byte $42,$34,$05,$01 ;pit roof
	.byte $42,$35,$05,$02 ;pit roof
	.byte $42,$36,$05,$00 ;pit roof
	.byte $22,$83,$04,$01 ;pit floor
	.byte $22,$84,$04,$00 ;pit floor
	.byte $42,$86,$04,$00 ;pit floor
	.byte $22,$75,$08,$01 ;elevator on right
	.byte $22,$76,$08,$02 ;elevator on right
	.byte $32,$77,$02,$00 ;elevator face-on
	.byte $23,$43,$08,$04 ;elevator on left
	.byte $13,$44,$02,$00 ;elevator face-on
	.byte $13,$95,$05,$01 ;pit roof
	.byte $33,$68,$07,$04 ;square left
	.byte $23,$78,$07,$02 ;square front
	.byte $13,$88,$07,$01 ;square right
	.byte $24,$14,$02,$00 ;elevator face-on
	.byte $14,$24,$08,$02 ;elevator on right
	.byte $14,$2a,$05,$01 ;pit roof
	.byte $14,$3a,$05,$02 ;pit roof
	.byte $14,$4a,$05,$00 ;pit roof
	.byte $35,$25,$08,$04 ;elevator on left
	.byte $25,$35,$02,$00 ;elevator face-on
	.byte $35,$3a,$09,$f0 ;keyholes on left
	.byte $35,$4a,$09,$f0 ;keyholes on left
	.byte $35,$5a,$09,$70 ;keyholes on left
	.byte $35,$6a,$09,$30 ;keyholes on left
	.byte $35,$7a,$09,$10 ;keyholes on left
	.byte $15,$5a,$09,$01 ;keyholes on right
	.byte $15,$6a,$09,$03 ;keyholes on right
	.byte $15,$7a,$09,$07 ;keyholes on right
	.byte $15,$8a,$09,$0f ;keyholes on right
	.byte $15,$9a,$09,$0f ;keyholes on right
	.byte $15,$aa,$09,$0e ;keyholes on right
	.byte $25,$4a,$01,$00 ;keyhole face-on
	.byte $25,$5a,$01,$00 ;keyhole face-on
	.byte $25,$6a,$01,$00 ;keyhole face-on
	.byte $25,$7a,$01,$00 ;keyhole face-on
	.byte $25,$8a,$01,$00 ;keyhole face-on
maze_features_end = $26
	.assert (* - maze_features) / 4 = maze_features_end, error, "Miscount maze features"

data_new_game:
	.include "newgame.inc"
	.assert * = data_new_game + gs_size, error, "Mismatch game data size"

game_save_begin:
	game_save_end = game_save_begin + $FF
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
gs_rotate_direction:
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
	.assert * - gs_item_locs = items_unique * 2, error, "Miscount between data and definition"

gs_item_food_torch:
	.byte $00,$00,$00,$00,$00,$00
	.assert * - gs_item_locs = (item_food_end - item_begin) * 2, error, "Miscount between data and definition"

	.byte $00,$00,$00,$00,$08,$00
	.assert * - gs_item_locs = (item_torch_end - item_begin) * 2, error, "Miscount between data and definition"

	items_unique = $11
	items_food = 3
	items_torches = 3

	items_total = items_unique + items_food + items_torches

	item_begin        = 1   ;indexing is 1-based
	item_food_begin   = item_begin + items_unique
	item_torch_begin  = item_food_begin + items_food

	item_food_end = item_food_begin + items_food
	item_torch_end = item_torch_begin + items_torches

	; Relate items to noun vocabulary
	.assert item_begin + items_unique = nouns_unique_end, error, "Miscounted unique items"

gs_size = * - game_save_begin

;junk
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00
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
	.byte $00,$00
	.assert * > game_save_end, error, "Save game region overlaps font"
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
	.assert * = $6694, error, "Unexpected alignment"

vocab_table:
	.byte $ff
verb_table:
	.include "string_verb_defs.inc"
noun_table:
	.include "string_noun_defs.inc"

; 1-based indexing.
vocab_end = 1 + (verbs_end - 1) + (nouns_end - 1)

;cruft
	.byte $ff,$ff,$00,$00,$ff,$ff,$00,$00
	.byte $ff

display_string_table:
	.include "string_display_defs.inc"
	.byte $ff

;cruft
	.byte           "FE"
	.byte $D2, $85, "Y STA *"
	.byte $C8, $90, "   AIV DEYALPSID YLTNATSNOC SI NOI"
	.byte $08, $08                        ;reversed: ION IS CONSTANTLY DISPLAYED VIA
	.byte $08, $08, " NOITACO", $0C       ;reversed: [^L]OCATION
	.byte "              00005 EZ", $08
	.byte "XAMTAE", $04                   ;reversed: EATMAX
	.byte "          "
	.byte $20, $25, $60, "GREN DEC *"
	.byte $C8, $30, $60, " BNE GOON6"
	.byte $B8, $35, $60, " JMP UNCOM"
	.byte $D0, $40, $60, "GOON68 DEC *"
	.byte $C8, $45, $60

intro_text:
	.assert * = $77c0, error, "Unexpected alignment"
	.include "string_intro_defs.inc"
	.byte $A0
	.byte $80

;cruft:
	.byte                 "RT"
	.byte $D3, $70, $64, "UN DEC IY"
	.byte $B2, $75, $64, " RT"
	.byte $D3, $80, $64, "DEUX INC IY"
	.byte $B3, $85, $64, " RT"
	.byte $D3, $90, $64, "TROIS INC IY"
	.byte $B2, $95, $64, " RT"
	.byte $D3, $00, $65, "JUKILL JSR DRA"
	.byte $D7, $05, $65, " JSR TIME"
	.byte $B1, $10, $65, " JSR WHIT"
	.byte $C5, $15, $65, " JSR CLRWN"
	.byte $C4, $20, $65, " LDA #4"
	.byte $B2, $25, $65, " JSR POIN"
	.byte $D4, $30, $65, " LDA #4"
	.byte $B3, $35, $65, " JSR POINT"
	.byte $B5, $40, $65, " JMP "

text_save_device:
	.byte "Save to DISK or TAPE (T or D)?"
	.byte $80
text_load_device:
	msbstring "Get from DISK or TAPE (T or D)?"
	.byte $80
	.assert * = $7c3f, error, "Unexpected alignment"
load_disk_or_tape:
	jsr clear_hgr2
	ldx #$00
	stx zp_col
	stx zp_row
	ldx #<text_load_device
	stx zp0C_string_ptr
	ldx #>text_load_device
	stx zp0C_string_ptr+1
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
	stx zp0C_string_ptr
	ldx #>text_save_device
	stx zp0C_string_ptr+1
	jsr print_string
	jsr input_T_or_D
	cmp #'T'
	beq prepare_tape_save
	jmp save_to_disk

prepare_tape_save:
	jsr clear_hgr2
	jsr update_view
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
	.word game_save_begin
	.byte $00,$00
iob_cmd:
	.byte $01
iob_return_code:
	.byte $00
iob_last_volume:
	.byte $00,$60,$01

text_insert_disk:
	msbstring "Place data diskette in DRIVE 1, SLOT 6."
	.byte $80
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
	stx zp0C_string_ptr
	ldx #>text_insert_disk
	stx zp0C_string_ptr+1
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
	.byte "DISKETTE WRITE PROTECTED!", $80
	.byte "VOLUME MISMATCH!", $80
	.byte "DRIVE ERROR! CAUSE UNKNOWN!", $80
	.byte "READ ERROR! CHECK YOUR DISKETTE!", $80
	.byte "NOT A DEATHMAZE FILE! INPUT REJECTED!", $80

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
	sty zp19_delta16
	ldx #$00
	stx zp19_delta16+1
	ldx #<string_disk_error
	stx zp0C_string_ptr
	ldx #>string_disk_error
	stx zp0C_string_ptr+1
	clc
	lda zp19_delta16
	adc zp0C_string_ptr
	sta zp0C_string_ptr
	lda zp19_delta16+1
	adc zp0C_string_ptr+1
	sta zp0C_string_ptr+1
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


; From here to end of file,
; cruft leftover from earlier build
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
	jsr draw_down
	lda #raster_hi 4,17,0
	sta screen_ptr+1
	lda #raster_lo 4,17,0
	sta screen_ptr
	ldy #$04
	jsr draw_right
	lda #raster_hi 16,17,7
	sta screen_ptr+1
	lda #raster_lo 16,17,7
	sta screen_ptr
	ldy #$04
	jsr draw_right
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #$03
	ldy #$15
	jsr draw_down
	jmp $16e8 ;@draw_0_left

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
	lda #$04
	ldy #$15
	jsr draw_down
	lda #>relocated
	sta screen_ptr+1
	lda #<relocated
	sta screen_ptr
	ldy #$01
	jsr draw_right
	lda #raster_hi 20,-1,7
	sta screen_ptr+1
	lda #raster_lo 20,-1,7
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
	lda #$03
	ldy #$15
	jsr draw_down
	lda #raster_hi 0,21,0
	sta screen_ptr+1
	lda #raster_lo 0,21,0
	sta screen_ptr
	ldy #$01
	jsr draw_right
	lda #raster_hi 20,21,7
	sta screen_ptr+1
	lda #raster_lo 20,21,7
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
	lda #$04
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
	lda #$03
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
	sta zp1A_count_loop
b7F82:
	jsr get_rowcol_addr
	lda #$02
	jsr char_out
	dec zp_col
	dec zp_col
	inc zp_row
	dec zp1A_count_loop
	bne b7F82
	rts

	tya
	sta zp1A_count_loop
b7F98:
	jsr get_rowcol_addr
	lda #$01
	jsr char_out
	inc zp_row
	dec zp1A_count_loop
	bne b7F98
	rts

	pha
	tya
	sta zp1A_count_loop
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
	dec zp1A_count_loop
	bne b7FAC
	rts

	ldy #$00
	lda #<maze_walls
	sta zp0A_walls_ptr
	lda #>maze_walls
	sta zp0A_walls_ptr+1
	ldx gs_level
	lda #$00
	clc
	dex
	beq b7FD7
	adc #$21
	jmp $17CF

b7FD7:
	adc zp0A_walls_ptr
	sta zp0A_walls_ptr
	ldx gs_player_x
	dex
	beq b7FEA
	inc zp0A_walls_ptr
	inc zp0A_walls_ptr
	inc zp0A_walls_ptr
	jmp $17DE

b7FEA:
	lda gs_player_y
	cmp #$05
	bmi b7FFF  ;GUG: bcc preferred
	cmp #$09
	bmi b7FFA  ;GUG: bcc preferred
	inc zp0A_walls_ptr
	sec
	sbc #$04
b7FFA:
	inc zp0A_walls_ptr
	sec
	sbc #$04
	.assert * = $7fff, error, "Unexpected alignment"
b7FFF:
	brk

