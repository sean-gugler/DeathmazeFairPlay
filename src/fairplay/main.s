	.export cmd_movement
	.export count_as_move
	.export game_over
	.export main_game_loop
	.export move_turn
	.export normal_input_handler
	.export not_carried
	.export noun_to_item
	.export play_again
	.export print_timers
	.export starved
	.export update_view
	.export vector_reset
	.export wait_brief
	.export wait_long
	.export wait_short

	.import get_player_input
	.import gs_parsed_action
	.import check_special_mode
	.import cmd_verbal
	.import clear_maze_window
	.import print_display_string
	.import check_special_position
	.import done_timer
	.import clear_hgr2
	.import print_to_line1
	.import print_to_line2
	.import probe_forward
	.import draw_maze
	.import draw_special
	.import clear_status_lines
	.import input_Y_or_N
	.import new_session
	.import maze_walls
	.import maze_features
	.importzp maze_features_end
	.import item_cmd
	.import push_special_mode
	.import lose_lit_torch
	.import get_rowcol_addr
	.import char_out

	.include "apple.i"
	.include "dos.i"
	.include "draw_commands.i"
	.include "game_design.i"
	.include "game_state.i"
	.include "item_commands.i"
	.include "special_modes.i"
	.include "string_noun_decl.i"

zp_col = $06
zp_row = $07

zp0E_ptr           = $0E;
zp0E_object        = $0E;
zp0F_action        = $0F;
zp1A_facing        = $1A;
zp1A_item_place    = $1A;
zp0E_draw_param    = $0E;
zp11_level_facing  = $11;
zp10_position      = $10;
zp19_count         = $19;
zp11_temp          = $11;
zp10_wait3         = $10;
zp0F_wait2         = $0F;
zp0E_wait1         = $0E;

	.segment "MAIN1"

main_game_loop:
	jsr get_player_input
	jsr normal_input_handler
;@count_move:
	lda gs_action_flags
	and #action_forward
	beq @update
	jsr count_as_move
@update:
	lda gs_action_flags
	and #(action_forward | action_turn)
	beq @special
	jsr update_view
	jsr print_timers
@special:
	jsr check_special_mode
	jmp main_game_loop

normal_input_handler:
	lda #$00
	sta gs_action_flags
	lda gs_parsed_action
	cmp #verb_movement_begin
	bmi :+
	jmp cmd_movement
:	jmp cmd_verbal

cmd_movement:
	ldx gs_facing
	stx zp1A_facing
	cmp #verb_forward
	beq move_forward

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
	lda #action_turn
	ora gs_action_flags
	sta gs_action_flags
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
	bmi :+
	dec gs_facing
	dec gs_facing
	bpl @turned
:	inc gs_facing
	inc gs_facing
	bpl @turned

move_forward:
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

;@south_4
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
	lda #action_forward
	ora gs_action_flags
	sta gs_action_flags
	jsr check_special_position
	rts


	.segment "MAIN2"

count_as_move:
	inc gs_level_moves_lo
	bne @consume
	inc gs_level_moves_hi
@consume:
	lda gs_room_lit
	beq @dec_food
	ldx gs_active_torch
	dec gs_torch_life,x
	bne @dec_food
;@douse_torch
	jsr lose_lit_torch
	sta zp0E_object
	lda #icmd_destroy1
	sta zp0F_action
	jsr item_cmd
	lda #icmd_draw_inv
	sta zp0F_action
	jsr item_cmd
@dec_food:
	dec gs_food_time_lo
	lda gs_food_time_lo
	cmp #$ff
	bne :+
	dec gs_food_time_hi
:	lda gs_food_time_hi
	ora gs_food_time_lo
	bne return
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
:	lda gs_room_lit
	beq return
	ldx gs_active_torch
	lda gs_torch_life,x
	beq return
	cmp #torch_low
	bcs return
	lda #$33     ;Torch is dying
	jsr print_to_line2
return:
	rts

noun_to_item:
	lda gs_parsed_object
	cmp #nouns_unique_end
	bpl multiples
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_unboxed
	bpl noun_return	
pop_not_carried:
	pla
	pla
not_carried:
	lda #$7b     ;Check your inventory!
print_return:
	jsr print_to_line2
noun_return:
	rts

multiples:
	cmp #noun_food
	beq @food
	cmp #noun_torch
	beq @torch
;@box:
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
	bne :+

	ldx #icmd_which_torch_lit
	stx zp0F_action
	jsr item_cmd
	cmp #$00
	beq pop_not_carried
:	rts


	.segment "MAIN3"

update_view:
	jsr clear_maze_window
	jsr @probe
	lda gs_room_lit
	beq @done
	jsr draw_maze
	jsr @get_feature
	lda zp0F_action
	ora zp0E_draw_param
	beq :+
	jsr draw_special
:	ldx #icmd_probe_boxes
	stx zp0F_action
	jsr item_cmd
	lda gs_box_visible
	beq @done
	sta zp0E_draw_param
	ldx #drawcmd06_boxes
	stx zp0F_action
	jsr draw_special
@done:
	rts

; Draw the flimsy wall if it hasn't been charged down yet.
@probe:
	lda #maze_flag_hat_used
	and gs_maze_flags
	beq :+
	jmp probe_forward

:	lda maze_walls + 2
	pha
	ora #%00001000
	sta maze_walls + 2
	jsr probe_forward
	pla
	sta maze_walls + 2
	rts

; Draw the pit if it has been exposed.
@get_feature:
	lda #$01
	cmp gs_level
	bne @normal
;	lda #$01
	cmp gs_player_x
	bne @normal
	lda #$02
	cmp gs_facing
	bne @normal
	lda #maze_flag_hat_used
	and gs_maze_flags
	beq @normal

	sec
	lda gs_player_y
	sbc #$06
	cmp #$05
	bcs @normal
	sta zp0E_draw_param
	dec zp0E_draw_param
	lda #drawcmd04_pit_floor
	sta zp0F_action
	rts
@normal:
	jmp get_maze_feature


	.segment "MAIN4"

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
.if REVISION >= 100
	bit hw_STROBE
	jmp DOS_warm_start
.else ;RETAIL
	jmp rom_MONITOR
.endif


	.segment "RESET"

vector_reset:
	bit hw_PAGE2
	bit hw_FULLSCREEN
	bit hw_HIRES
	bit hw_GRAPHICS
	jmp main_game_loop


	.segment "FEATURE_CODE"

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
	sta zp0F_action
	sta zp0E_draw_param
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


	.segment "WAIT_LONG"

wait_long:
	ldx #$05
	stx zp10_wait3
@dec16:
	lda zp10_wait3
	and #$01
	clc
	adc #$01
	jsr @print
	ldx #$00
	stx zp0F_wait2
:	dec zp0E_wait1
	bne :-
	dec zp0F_wait2
	bne :-
	dec zp10_wait3
	bne @dec16
	lda #' '
@print:
	ldx #$27
	stx zp_col
	ldx #$17
	stx zp_row
	pha
	jsr get_rowcol_addr
	pla
	jmp char_out

	.segment "WAIT_SHORT"

wait_short:
	ldx #$90
	stx zp0F_wait2
:	dec zp0E_wait1
	bne :-
	dec zp0F_wait2
	bne :-
	rts

	.segment "WAIT_BRIEF"

wait_brief:
	ldx #$28
	stx zp0F_wait2
:	dec zp0E_wait1
	bne :-
	dec zp0F_wait2
	bne :-
	rts

