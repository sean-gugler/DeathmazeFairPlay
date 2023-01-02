	.export flash_screen
	.export nonsense
	.export player_cmd
	.export print_thrown
	.export save_to_tape

	.import print_string
	.import draw_special
	.import clear_hgr2
	.import play_again
	.import input_char
	.import save_disk_or_tape
	.import input_Y_or_N
	.import check_special_position
	.import starved
	.import beheaded
	.import complete_turn
	.import pit
	.import wait_short
	.import print_char
	.import get_rowcol_addr
	.import not_carried
	.import swap_saved_vars
	.import game_over
	.import wait_long
	.import print_display_string
	.import clear_maze_window
	.import clear_status_lines
	.import print_noun
	.import char_out
	.import print_to_line1
	.import update_view
	.import item_cmd
	.import noun_to_item
	.import print_to_line2
	.import text_buffer_line1
	.import intro_text
.if REVISION < 100 ;RETAIL
	.import swap_saved_A_2
.else
	.import swap_saved_A
	swap_saved_A_2 = swap_saved_A
.endif

	.include "apple.i"
	.include "char.i"
	.include "draw_commands.i"
	.include "game_design.i"
	.include "game_state.i"
	.include "item_commands.i"
	.include "special_modes.i"
	.include "string_display_decl.i"
	.include "string_noun_decl.i"
	.include "string_verb_decl.i"

zp_col = $06
zp_row = $07

zp0C_string_ptr     = $0C;
zp0A_text_ptr       = $0A;
zp11_count          = $11;
zp19_count          = $19;
zp11_box_item       = $11;
zp11_position       = $11;
zp1A_count_loop     = $1A;
zp19_level_facing   = $19;
zp0E_ptr            = $0E;
zp10_noun           = $10;
zp10_wait2          = $10;
zp11_wait1          = $11;
zp19_item_position  = $19;
zp11_action         = $11;
zp0E_item           = $0E;
zp19_delta16        = $19;
zp0E_count16        = $0E;
zp10_temp           = $10;
zp13_temp           = $13;
zp1A_item_place     = $1A;
zp11_item           = $11;
zp0F_action         = $0F;
zp0E_object         = $0E;

	.segment "COMMAND1"

nonsense:
	lda #$55     ;You are making little sense.
	jmp print_to_line2

	.segment "COMMAND2"

player_cmd:
	lda gd_parsed_object
	sta zp0E_object
	lda gd_parsed_action
	sta zp0F_action
	cmp #verb_look
	bmi :+
	jmp cmd_look

:	lda zp0E_object
	cmp #nouns_item_end
	bmi :+
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
	cmp #$05  ;GUG: unnecessary. special_mother is sufficient.
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
	bmi @broken
	sta zp13_temp  ;preserve 'object' while protecting $10,$11
	lda zp10_temp  ;GUG: no need, $10 is neither assigned nor disturbed
	pha
	lda zp11_item
	pha
	lda zp13_temp  ;restore 'object'
	cmp #noun_torch
	bne :+
	jsr lose_one_torch
:	pla
	sta zp11_item
	pla
	sta zp10_temp
	lda zp11_item
	sta zp0E_object
@broken:
; implicit, already 0
;	lda #icmd_destroy1
;	sta zp0F_action
	jsr item_cmd
.if REVISION = 1
	jsr update_view
.elseif REVISION >= 2
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
.endif
	lda #$4e     ;You break the
	jsr print_to_line1
.if REVISION >= 2
	lda #$20
	jsr char_out
.endif
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
	bmi @burned
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
	bmi @eaten
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
	lda zp10_temp  ;GUG: no need, $10,$11 are neither assigned nor disturbed
	pha
	lda zp11_item
	pha
	jsr lose_one_torch
	pla
	sta zp11_item
	pla
	sta zp10_temp
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
	lda #noun_ring
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
	bmi thrown
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
.if REVISION < 100 ;RETAIL
	nop
	nop
.endif
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
.if REVISION < 100 ;RETAIL
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
.endif
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
	cmp #noun_horn
	beq play_horn
	jmp nonsense

play_horn:
	lda #verb_blow
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
	sta zp11_wait1
:	dec zp10_wait2
	bne :-
	dec zp11_wait1
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
	bmi @print_item_name
	cmp #item_torch_begin
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
:	sta zp13_temp  ;preserve 'object'
	cmp #noun_snake
	bne :+
	jsr wait_long
:	pla
	sta zp11_item
	pla
	sta zp10_noun
	lda zp13_temp  ;restore 'object'
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

:	jsr swap_saved_A_2
	ldx #noun_key
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_unboxed
	bmi @no_key
	jsr swap_saved_A_2
	clc
	adc #doormsg_lock_begin - doors_locked_begin
	cmp #doormsg_lock_begin + (door_correct - 1)
	beq @correct_lock
	jsr swap_saved_A_2
	jsr clear_status_lines
	lda #$19     ;You unlock the door...
	jsr print_to_line1
	jsr swap_saved_A_2
	jsr print_to_line2
	jmp game_over

@no_key:
	jsr swap_saved_A_2
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

	.segment "DATA_DOOR"

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

	.segment "COMMAND3"

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

	.segment "DATA_TELEPORT"

teleport_table:
	; facing, level, X position, Y position
	.byte $02,$02,$05,$04 ;button 0
	.byte $02,$02,$07,$09 ;button 1
	.byte $01,$05,$03,$03 ;button 2
	.byte $02,$03,$04,$06 ;button 3
	.byte $02,$01,$08,$05 ;button 4
	.byte $03,$02,$01,$03 ;button 5
	.byte $02,$01,$05,$05 ;button 6
	.byte $01,$01,$07,$0a ;button 7
	.byte $03,$04,$09,$0a ;button 8
	.byte $03,$03,$07,$0a ;button 9

	.segment "COMMAND4"

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
	bmi @unique_item
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
	bpl cannot_take
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
	bpl find_boxed_torch
	cmp #item_torch_begin
	bmi find_boxed_torch
	ldx zp11_box_item
	stx zp0E_object
	lda zp1A_item_place
	cmp #carried_boxed
.if REVISION >= 100
	bne :+   ;skip "ensure_inv_space" but do both INC and JMP
.else ;RETAIL
	beq take_and_reveal
	; BUG: "get box" then "get torch"
	; does not increment unlit count if it's the only box
.endif
	jsr ensure_inv_space
:	inc gs_torches_unlit
	jmp take_and_reveal

@food:
	lda zp11_box_item
	cmp #item_food_end
	bpl find_boxed_food
	cmp #item_food_begin
	bmi find_boxed_food
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
.if REVISION >= 100
	; Pop one call frame, do not return and continue.
	; (By design of "ensure_inv_space")
	pla
	pla
.else ;RETAIL
	; Authors got confused with purpose of PLA here.
	; Harmless, but unnecessary; these zp vars get
	; immediately wiped by restoring from
	; 'swap_saved_vars' anyway.
	pla
	sta zp0E_object
	pla
	sta zp0F_action
.endif
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
.if REVISION < 100 ;RETAIL
	; Leftover 16-bit increment from earlier design.
	; Pointless but harmless.
	lda zp0F_action
	pha
	lda zp0E_object
	pha
.endif
	ldx #items_food
	.assert items_food = items_torches, error, "Need to edit cmd_take for separate food,torch counts"
	stx zp11_count
@next:
.if REVISION < 100 ;RETAIL
	; 16-bit increment, presumably leftover from earlier design.
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
.endif
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #carried_boxed
	cmp zp1A_item_place
	beq @found
	dec zp11_count
	bne @next
.if REVISION < 100 ;RETAIL
	pla
	sta zp0E_object
	pla
	sta zp0F_action
.endif
	jmp cannot_take

@found:
.if REVISION < 100 ;RETAIL
	pla
	sta zp0E_object
	pla
	sta zp0F_action
.endif
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
.if REVISION >= 2
	lda gd_parsed_object
	bne :+
	jmp nonsense
.endif
:	lda #$76     ;OK...
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


	.segment "COMMAND5"

.if REVISION < 100 ;RETAIL
dec_item_ptr:
	pha
	dec zp0E_item
	lda zp0E_item
	cmp #$ff
	bne :+
	dec zp0E_item+1
:	pla
	rts
.endif

	.segment "STRING_HAT"

text_hat:
	.byte "AN INSCRIPTION READS: WEAR THIS HAT AND "
	.byte "CHARGE A WALL NEAR WHERE YOU FOUND IT!", $A0

	.segment "COMMAND6"

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

