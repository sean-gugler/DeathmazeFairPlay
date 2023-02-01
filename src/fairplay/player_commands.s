	.export cmd_verbal
	.export destroy_one_torch
	.export flash_screen
	.export lose_lit_torch
	.export lose_unlit_torch
	.export nonsense
	.export print_thrown
	.export push_special_mode
	.export save_to_tape
	.export thrown

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
	.import count_as_move
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


doormsg_lock_begin = text_You_unlock_the_door___ + 1

door_correct = text_and_the_key_begins_to_tick_ - doormsg_lock_begin


	.segment "COMMAND1"

nonsense:
	lda #$55     ;You are making little sense.
	jmp print_to_line2

	.segment "COMMAND2"

cmd_verbal:
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

	lda #noun_staff
	cmp zp0E_object
	beq @staff
@having_fun:
	lda #$8e     ;Having fun?
@print_line2:
	jmp print_to_line2

@staff:
	lda #$02
	sta gs_staff_charged
	lda #$73     ;Staff begins to quake
	bne @print_line2

@cmd_blow:
	dec zp0F_action
	bne cmd_break

	lda zp0E_object
	cmp #noun_flute
	beq @play
	cmp #noun_horn
	bne @having_fun
	lda gs_special_mode
	cmp #special_mode_mother
	bne :+
	lda #noun_horn
	sta zp0E_object
	lda #icmd_set_carried_active
	sta zp0F_action
	jsr item_cmd
:	lda #$7f     ;A deafening roar envelops
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
	cmp #noun_ball
	bne :+
	jmp throw_react
:	cmp #nouns_unique_end
	bmi @broken  ;zp0F_action already 0 (icmd_destroy1)

	ldx zp11_item
	cmp #noun_torch
	bne @set_object
@torch:
	jsr lose_one_torch
	tax
	lda #icmd_destroy1
	sta zp0F_action  ;was mutated by lose_one_torch
@set_object:
	stx zp0E_object

@broken:
	jsr item_cmd
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
	lda #$4e     ;You break the
	jsr print_to_line1
	lda #' '
	jsr char_out
	lda gd_parsed_object
	jsr print_noun
	lda #$4f     ;and it disappears!
	jmp print_to_line2

; Find a carried, unlit torch if possible, else the lit one.
; Decrement the relevant torch count.
; Output: A = zp0E = which torch item
lose_one_torch:
	lda gs_torches_unlit
	bne lose_unlit_torch
lose_lit_torch:
	dec gs_torches_lit
	lda #$8a     ;Awfully dark
	jsr print_to_line2
	jsr clear_maze_window
	lda #$00
;	sta gs_active_torch
	sta gs_room_lit
	jsr push_special_mode
	lda #special_mode_dark
	sta gs_special_mode
	lda #icmd_which_torch_lit
	bne query_item
lose_unlit_torch:
	dec gs_torches_unlit
	lda #icmd_which_torch_unlit
query_item:
	sta zp0F_action
	jmp item_cmd

destroy_one_torch:
	jsr lose_one_torch
	sta zp0E_object
	lda #icmd_destroy1
	sta zp0F_action
	jmp item_cmd

cmd_burn:
	dec zp0F_action
	bne cmd_eat

	lda zp0E_object
	ldx gs_torches_lit
	bne :+
	ldx gs_ring_glow
	beq @no_fire
	cmp #noun_ring
	bne :+
	jmp nonsense  ;ring can't burn itself
:	cmp #noun_ball
	bne :+
	jsr throw_react
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
	lda #icmd_draw_inv
	sta zp0F_action
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
	cmp #noun_ball
	bne :+
	jmp throw_react

:	cmp #noun_banana
	bne :+
	jsr item_cmd ;zp0F_action already 0 (icmd_destroy1)
	lda #noun_peel
	sta zp0E_object
	lda #icmd_set_carried_known
	sta zp0F_action
	jsr item_cmd
	lda #$b6     ;The banana is delicious!
	bne @print

:	cmp #nouns_unique_end
	bmi @eaten  ;zp0F_action already 0 (icmd_destroy1)

	.assert nouns_unique_end = noun_food, error, "Eat logic needs to change."
;	cmp #noun_food   ;optimized based on assertion
	beq @food
	ldx zp11_item
	cmp #noun_torch
	bne @set_object
@torch:
	jsr lose_one_torch
	tax
	lda #icmd_destroy1
	sta zp0F_action  ;was mutated by lose_one_torch
@set_object:
	stx zp0E_object

@eaten:
	jsr item_cmd
;	jsr update_view
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
	lda #$58     ;Food eaten
	bne @print

cmd_throw:
	dec zp0F_action
	beq :+
	jmp cmd_climb

:	lda zp0E_object
	cmp #noun_frisbee
	bne :+
	jmp throw_frisbee

:	cmp #noun_peel
	beq throw_peel
	cmp #noun_yoyo
	beq throw_yoyo
	cmp #nouns_unique_end
	bmi thrown  ;zp0F_action already 0 (icmd_destroy1)

	.assert nouns_unique_end = noun_food, error, "Throw logic needs to change."
;	cmp #noun_food   ;optimized based on assertion
	beq throw_food
	ldx zp11_item
	cmp #noun_torch
	bne @set_object
@torch:
	jsr lose_one_torch
	tax
	lda #icmd_destroy1
	sta zp0F_action  ;was mutated by lose_one_torch
@set_object:
	stx zp0E_object

thrown:
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

throw_peel:
; These zp variables are already set to these values upon entry.
;	lda #noun_peel
;	sta zp0E_object
;	lda #icmd_destroy1
;	sta zp0F_action
	jsr item_cmd
	lda #icmd_draw_inv
	sta zp0F_action
	jsr item_cmd
	; Trip the monster ONLY if it is about to attack
	; (disgusting odor) - whether it's dark or not.
	; Any other time, it is wasted.
	lda gs_monster_step
	cmp #$02
	beq @tripped
	lda #$a8     ;The peel slides on the floor
	jsr print_to_line1
	lda #$a9     ;and gets stuck in a corner.
	jmp print_to_line2
@tripped:
	inc gs_monster_step
	lda #$5e     ;The monster rounds the corner, slips on
	jsr print_to_line1
	lda #$5f     ;the peel, and loses its balance!
	jmp print_to_line2

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
	lda #$5a     ;magically sails
	jsr print_display_string
	lda #$5b     ;around a nearby corner
	jsr print_to_line2
	jsr wait_long
	jmp clear_status_lines

throw_frisbee:
; These zp variables are already set to these values upon entry.
;	lda #noun_frisbee
;	sta zp0E_object
;	lda #icmd_destroy1
;	sta zp0F_action

	lda gs_monster_alive
	and #monster_flag_dying
	beq :+
	jsr item_cmd
	lda #icmd_draw_inv
	sta zp0F_action
	jsr item_cmd
	inc gs_monster_step
	lda #$61     ;It saws the monster's head off!
	jsr print_to_line1
	lda #$62     ;Much blood is spilt!
	jmp print_to_line2

:	lda gs_monster_alive
	and #monster_flag_roaming
	bne :+
	jmp thrown

:	jsr item_cmd
	jsr print_thrown
;	jsr clear_status_lines
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
@dropped:
	lda #icmd_drop
	sta zp0F_action
	jsr item_cmd
	ldx #icmd_draw_inv
	stx zp0F_action
	jmp item_cmd

@multiples:
	cmp #noun_torch
	beq @torch
	lda zp11_item
	sta zp0E_object
	jmp @dropped

@torch:
	jsr lose_one_torch
	jmp @dropped

cmd_fill:
	dec zp0F_action
	bne cmd_light

	lda zp0E_object
	cmp #noun_jar
	beq :+
	jmp nonsense

	lda #icmd_where
	sta zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_active
	bne :+
	lda #$ac     ;It's already full.
	jmp print_to_line2

:	lda gs_monster_step
	cmp #$06
	bne :+
	lda #icmd_set_carried_active
	sta zp0F_action
	jsr item_cmd
	lda #$60     ;It is now full of blood.
	jmp print_to_line2

:	lda #$89     ;With what? Air?
	jmp print_to_line2

cmd_light:
	dec zp0F_action
	bne cmd_play

	lda zp0E_object
	cmp #noun_torch
	beq :+
	jmp nonsense

:	lda zp1A_item_place ;still known from noun_to_item
	cmp #carried_active
	bne @check_igniter
	jmp not_carried  ;only have an already-lit torch

@check_igniter:
	lda zp11_item  ;the unlit torch found by noun_to_item
	ldx gs_room_lit
	bne @have_fire
	ldx gs_ring_glow
	bne @have_ring
	lda #$88     ;You have no fire.
	jmp print_to_line2

@have_ring:
	pha
	lda #$71     ;The ring ignites it
	jsr print_to_line1
	inc gs_room_lit
	jsr update_view
	inc gs_torches_lit
	lda #action_ignited
	ora gs_action_flags
	sta gs_action_flags
	bne @finish

@have_fire:
	pha
	lda #icmd_which_torch_lit
	sta zp0F_action
	jsr item_cmd
	sta zp0E_object
	lda #icmd_destroy2
	sta zp0F_action
	jsr item_cmd
	lda #$65     ;The torch is lit and the
	jsr print_to_line1
	lda #$66     ;old torch dies and vanishes!
	jsr print_to_line2
@finish:
	dec gs_torches_unlit
	pla
	sta zp0E_object
	sec
	sbc #item_torch_begin
	sta gs_active_torch
	lda #icmd_set_carried_active
	sta zp0F_action
	jsr item_cmd
	lda #icmd_draw_inv
	sta zp0F_action
	jsr item_cmd
	rts


cmd_play:
	dec zp0F_action
	beq :+
	jmp cmd_strike

:	lda zp0E_object
	cmp #noun_flute
	beq play_flute
	cmp #noun_ball
	beq play_with_who
	cmp #noun_frisbee
	beq play_with_who
	cmp #noun_horn
	beq play_horn
	jmp nonsense

play_horn:
	lda #verb_blow
	sta gd_parsed_action
	jmp cmd_verbal

play_with_who:
	lda #$87     ;With who? The monster?
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
	jmp print_to_line2

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
	inc gs_snake_freed
	rts

cmd_strike:
	dec zp0F_action
	bne cmd_wear

	lda zp0E_object
	cmp #noun_staff
	beq :+
	jmp nonsense

:	jsr clear_status_lines
	lda gs_staff_charged
	bne :+
	lda #$4d     ;Sparks shoot out above you!
	jmp print_to_line2

:	lda #$21     ;Thunderbolts shoot out above you!
	jsr print_to_line1
	lda #$22     ;The staff thunders with useless energy!
	jmp print_to_line2

;	lda #$3c     ;They do not reach the lighting rod
;	lda #$3d     ;They blast the lighting rod above!
;	lda #$3e     ;The gold pieces fall, fused together!

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
	sbc #verb_look
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
	bne look_not_here
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
	cmp #noun_ball
	bne :+
	lda #$6a     ;it sparkles with energy
	bne look_print
:	cmp #noun_ring
	bne :+
	lda #$69     ;it is dusty
	bne look_print
:	cmp #noun_calculator
	bne :+
	lda #$27     ;The calculator displays 317.
	bne look_print
:	cmp #noun_dagger
	bne :+
	lda #$72     ;the handle seems flimsy.
	bne look_print
:	cmp #noun_frisbee
	bne :+
	lda #$b1     ;the rim is serrated and sharp!
	bne look_print
:	cmp #noun_peel
	bne :+
	lda #$b7     ;the banana peel is slippery.
	bne look_print
:	lda #$68     ;nothing of interest.
	bne look_print

look_not_here:
	lda #$90     ;I don't see that here.
look_print:
	jmp print_to_line2

cmd_rub:
	dec zp0F_action
	bne cmd_open

	jsr noun_to_item
	lda gd_parsed_object
	cmp #noun_ring
	beq :+
	lda #$7a     ;Ok, it is clean
	bne look_print
:	lda #$02
	sta gs_ring_glow
	lda #$28     ;Glows hot
	bne look_print

cmd_open:
	dec zp0F_action
	beq :+
	jmp cmd_unlock

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

	cmp #noun_banana
	beq :+
	cmp #noun_peel
	bne @check_snake
:	ldx gs_snake_freed
	beq @print_item_name
	inc gs_snake_freed
	bne @push_mode_snake

@check_snake:
	cmp #noun_snake
	beq @push_mode_snake
	.assert nouns_unique_end - 1 = noun_snake, error, "Snake is not last unique. Open Box logic needs to change."
;	cmp #nouns_unique_end - 1   ;optimized based on assertion
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
	lda #($03 + nouns_item_end)     ;Inside the box there is a
	jsr print_to_line1
	lda zp10_noun
	sta zp13_temp  ;preserve 'object'
	lda gs_special_mode
	cmp #special_mode_snake
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
	bne @done  ;opened box on floor
	inc gs_torches_unlit  ;opened box being carried
@done:
	lda #icmd_draw_inv
	sta zp0F_action
	jmp item_cmd

@push_mode_snake:
	jsr push_special_mode
	ldx #special_mode_snake
	stx gs_special_mode
	lda zp11_item
	bne @print_item_name

@open_door:
	jsr which_door
	cmp #$00
	bne :+
	jmp look_not_here

:	cmp #doors_locked_begin
	bcs locked_door
	jsr push_special_mode
	ldx #special_mode_elevator
	stx gs_special_mode
	jmp draw_doors_opening


cmd_unlock:
	dec zp0F_action
	beq :+
	jmp cmd_press

:	lda zp0E_object
	cmp #noun_door
	bne :+
	jsr which_door
	cmp #doors_locked_begin
	bcs locked_door
	;GUG: jsr noun_to_item ?
:	lda #$9d     ;It's not locked.
	jmp print_to_line2

locked_door:
	pha
	ldx #noun_key
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_unboxed
	bmi @no_key
	pla
	clc
	adc #doormsg_lock_begin - doors_locked_begin
	cmp #doormsg_lock_begin + door_correct
	beq @correct_lock
	jsr print_to_line2
	lda #doormsg_lock_begin - 1     ;You unlock the door...
	jsr print_to_line1
	jmp game_over

@no_key:
	pla
	lda #$92     ;But you have no key.
	jmp print_to_line2

@correct_lock:
	ldx #special_mode_bomb
	stx gs_special_mode
	jsr clear_status_lines
	lda #doormsg_lock_begin - 1     ;You unlock the door...
	jsr print_to_line1
	lda #doormsg_lock_begin + door_correct
	jmp print_to_line2

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
door_locked_begin:
	.byte $52,$4a
	.byte $52,$5a
	.byte $52,$6a
	.byte $52,$7a
	.byte $52,$8a
doors = (* - door_table) / 2
doors_locked = (* - door_locked_begin) / 2
doors_locked_begin = 1 + (doors - doors_locked)  ;one-based indexing

	.segment "COMMAND3"

cmd_press:
	dec zp0F_action
	beq @check_pressed_number
	jmp cmd_take

@check_pressed_number:
	lda zp0E_object
	cmp #noun_zero
	bpl @check_have_calculator
	jmp nonsense

@check_have_calculator:
	ldx #icmd_where
	stx zp0F_action
	ldx #noun_calculator
	stx zp0E_object
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_known
	beq @check_teleport_allowed
	jmp not_carried

@check_teleport_allowed:
	lda gs_special_mode
	cmp #special_mode_endgame
	beq @no_effect

;@lookup_location:
	lda gd_parsed_object
	sec
	sbc #noun_zero
	asl
	asl
	clc
	adc #<teleport_table
	sta zp0E_ptr
	ldx #>teleport_table
	stx zp0E_ptr+1

;@check_already_there:
	ldy #$01
	lda (zp0E_ptr),y
	cmp gs_level
	bne @teleport
	iny
	lda (zp0E_ptr),y
	cmp gs_player_x
	bne @teleport
	iny
	lda (zp0E_ptr),y
	cmp gs_player_y
	bne @teleport
@no_effect:
	lda #$85     ;Nothing happens.
	jmp print_to_line2

@teleport:
	ldy #$00
	lda (zp0E_ptr),y
	sta gs_facing
	iny
	lda (zp0E_ptr),y
	sta gs_level
	iny
	lda (zp0E_ptr),y
	sta gs_player_x
	iny
	lda (zp0E_ptr),y
	sta gs_player_y

	ldx #$00
	stx gs_level_moves_hi
	stx gs_level_moves_lo
	lda #action_level
	ora gs_action_flags
	sta gs_action_flags

	jsr clear_maze_window
	lda #$86     ;You have been teleported!
	jsr print_to_line1
	lda gs_monster_alive
	and #monster_flag_roaming
	beq @no_monster

;@with_monster:
	jsr wait_long
	lda #$74     ;The monster teleports with you and
	jsr print_to_line1
	lda #$37     ;you are his next meal!
	jsr print_to_line2
	jmp game_over

@no_monster:
	lda gs_level
	cmp #05
	beq @dark
	jsr wait_long
	jmp update_view

@dark:
	lda gs_room_lit
	bne @douse
	lda gs_mother_alive
	beq @done
	lda #special_mode_mother
	cmp gs_special_mode
	beq @done
	jsr push_special_mode
	ldx #special_mode_dark
	stx gs_special_mode
@done:
	rts

@douse:
	ldx #$00
	stx gs_teleported_dark
	inc gs_torches_unlit
	dec gs_torches_lit
	ldx #icmd_which_torch_lit
	stx zp0F_action
	jsr item_cmd
	ldx #icmd_set_carried_known
	stx zp0F_action
	sta zp0E_object
	jsr item_cmd
	lda #icmd_draw_inv
	sta zp0F_action
	jsr item_cmd
	jsr wait_short
	lda #$70     ;A draft blows your torch out.
	jsr print_to_line2
	jsr push_special_mode
	ldx #special_mode_dark
	stx gs_special_mode
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
.assert >* = >teleport_table, error, "Teleport table must fit in one page"

	.segment "COMMAND4"

cmd_take:
	dec zp0F_action
	beq :+
	jmp cmd_attack

:	ldx #icmd_which_box
	stx zp0F_action
	jsr item_cmd
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
	cmp #noun_snake
	beq @snake
	cmp #noun_banana
	beq :+
	cmp #noun_peel
	bne @done
:	ldx gs_snake_freed
	beq @done
	inc gs_snake_freed
@snake:
	jsr push_special_mode
	ldx #special_mode_snake
	stx gs_special_mode
@done:
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
	bne :+
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
	; Pop one call frame, do not return and continue.
	; (By design of "ensure_inv_space")
	pla
	pla
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
	ldx #items_food
	.assert items_food = items_torches, error, "Need to edit cmd_take for separate food,torch counts"
	stx zp11_count
@next:
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #carried_boxed
	cmp zp1A_item_place
	beq @found
	dec zp11_count
	bne @next
	jmp cannot_take

@found:
	lda gd_parsed_object
	cmp #noun_torch
	bne :+
	inc gs_torches_unlit
:	jmp take_and_reveal

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
	bne cmd_drink
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

cmd_drink:
	dec zp0F_action
	bne cmd_charge
	lda #$9a     ;It is currently impossible.
	jmp print_to_line2

cmd_charge:
	dec zp0F_action
	beq @propel_player
	jmp cmd_fart

@loop:
	jsr propel_next_step
	jsr update_view
@propel_player:
	jsr wait_short
	lda gs_walls_right_depth
	and #%11100000
	bne @loop
;@rammed:
	jsr flash_screen
	lda #$02
	cmp gs_facing
	bne @brained
	lda #$01
	cmp gs_level
	bne @brained
;	lda #$01
	cmp gs_player_x
	bne @brained
	lda #$0a
	cmp gs_player_y
	bne @brained
	ldx #noun_hat
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #carried_active
	cmp zp1A_item_place
	bne @brained
;@crash_into_pit:
	jsr pit
	ldx #$03
	stx gs_player_y
	stx gs_player_x
	inc gs_hat_used
	ldx #noun_hat
	stx zp0E_object
	ldx #icmd_destroy1
	stx zp0F_action
	jsr item_cmd
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
	lda #$b8     ;The hat breaks into pieces.
	jsr print_to_line1
	lda #$b9     ;One of the horns falls to the floor.
	jsr print_to_line2
	jmp update_view

@brained:
	jsr clear_hgr2
	lda #$2a     ;You have rammed your head into a steel
	jsr print_to_line1
	lda #$2b     ;wall and bashed your brains out!
	jsr print_to_line2
	jmp game_over

propel_next_step:
	ldx gs_facing
	dex
	beq @west_1
	dex
	beq @north_2
	dex
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
	jsr count_as_move
	jmp @next_propel

@guillotine:
	jsr wait_short
	jmp beheaded

; Deduct food amount (10). If already <=15, set to 5. If <=5, starve.
@wall:
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
	jsr check_special_position
	lda gs_action_flags
	and #action_level
	beq :+
	jsr update_view
:	rts

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
	.byte "A sewn label reads: WEAR THIS HAT AND   "
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

