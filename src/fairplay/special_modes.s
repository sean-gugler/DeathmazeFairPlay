	.export check_special_mode

	.import print_string
	.import char_out
	.import pit
	.import move_turn
	.import print_noun
	.import wait_short
	.import draw_maze
	.import flash_screen
	.import draw_special
	.import text_buffer_line2
	.import text_buffer_line1
	.import cmd_movement
	.import clear_hgr2
	.import print_thrown
	.import thrown
	.import item_cmd
	.import game_over
	.import clear_status_lines
	.import print_to_line2
	.import print_to_line1
	.import wait_long
	.import print_display_string
	.import clear_maze_window
	.import print_timers
	.import count_as_move
	.import cmd_verbal
	.import get_player_input
	.import update_view
	.import normal_input_handler
	.import check_special_position
	.import which_door
	.importzp door_final
	.import get_rowcol_addr
	.import print_char
	.importzp magic_word_length
	.import exit_game


	.include "apple.i"
	.include "char.i"
	.include "draw_commands.i"
	.include "game_design.i"
	.include "game_state.i"
	.include "item_commands.i"
	.include "special_modes.i"
;	.include "string_display_decl.i"
	.include "string_noun_decl.i"
	.include "string_verb_decl.i"

zp_col = $06
zp_row = $07

zp0C_string_ptr    = $0C;
zp1A_endgame_step  = $1A;
zp19_regular_climb = $19;
zp19_pos_y         = $19;
zp1A_pos_x         = $1A;
zp0E_draw_param    = $0E;
zp1A_facing        = $1A;
zp19_item_position = $19;
zp1A_temp          = $1A;
zp1A_item_place    = $1A;
zp0F_action        = $0F;
zp0E_object        = $0E;
zp1A_object        = $1A;
zp1A_hint_mode     = $1A;
zp11_count         = $11;

	.segment "SPECIAL_MODES"

check_special_mode:
	ldx gs_special_mode
	bne :+
	rts

:	dex
	dex
	beq special_calc_puzzle
	jmp special_bat


; First column yields a hint.
; Second column solves the puzzle.
rotate_table:
	.byte 0,0
	.byte 3,5
	.byte 1,4
	.byte 7,3

special_calc_puzzle:
	jsr update_view
	jsr @init_puzzle
	ldx #$01
	stx zp1A_hint_mode
	jsr @print_hint
@puzzle_loop:
	jsr get_player_input
	lda #$00
	sta gs_action_flags
	lda gs_parsed_action
	cmp #verb_movement_begin
	bpl @move
	jsr cmd_verbal
@continue_loop:
	jsr count_as_move
	jsr print_timers
	jsr @print_timed_hint
	jmp @puzzle_loop

@move:
	cmp #verb_forward
	beq @bump_into_wall
	cmp gs_rotate_direction
	bne @new_direction
	inc gs_rotate_count
	;  Match next target?
	lda gs_rotate_count
	ldx gs_rotate_target
	cmp rotate_table,x
	bne @rotate_done
	;  Is it the final target?
	txa
	lsr
	eor #%00000011
	bne @rotate_done
	bcs @solved
;@hint
	lda #$9e     ;A cruel laugh booms out
	jsr print_to_line1
	lda #$9f     ;Invert and telephone.
	jsr print_to_line2
	jsr wait_long
	jsr @reset_target
	jmp @rotate_done
@solved:
	ldx #$04
	stx gs_facing
	jsr update_view
	jsr @init_puzzle
	jmp pop_mode_continue

@new_direction:
	sta gs_rotate_direction
	;  Are we partway into a sequence already?
	lda gs_rotate_count
	ldx gs_rotate_target
	beq @no_target
	;  Should we advance the sequence?
	cmp rotate_table,x
	beq @next_target
	;  Mismatch, start over.
	ldx #%00000000
	stx gs_rotate_target
@no_target:
	;  Check start of HINT sequence
	ldx #%00000010
	cmp rotate_table,x
	beq @sequence_started
	;  Check start of SOLVE sequence
	inx
	cmp rotate_table,x
	bne @fresh_count
@sequence_started:
	stx gs_rotate_target
@next_target:
	inc gs_rotate_target
	inc gs_rotate_target
@fresh_count:
	ldx #$01
	stx gs_rotate_count

@rotate_done:
	jsr update_view
	inc gs_rotate_hint_counter
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
	lda gs_parsed_action
	cmp #verb_drop
	beq :+
	cmp #verb_movement_begin
	bpl :+
	jsr wait_long
:	lda #$bf     ;To everything
	jsr print_to_line1
	lda zp1A_hint_mode
	cmp #$01
	beq :+
	lda #$c1     ;Turn turn turn
	jsr print_display_string
:	lda #$c0     ;There is a season
	jsr print_to_line2
	lda zp1A_hint_mode
	cmp #$01
	beq @done
	lda #$c1     ;Turn turn turn
	jsr print_display_string
@done:
	rts

@init_puzzle:
	ldx #$00
	stx gs_rotate_hint_counter
@reset_target:
	ldx #$00
	stx gs_rotate_target
	stx gs_rotate_count
	stx gs_rotate_direction
	rts

@print_timed_hint:
	lda gs_rotate_hint_counter
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

:	lda #$31     ;A vampire bat attacks you!
	jsr print_to_line2
	jsr wait_long
@bat_loop:
	jsr get_player_input
	ldx gs_parsed_object
	stx zp1A_object
	lda gs_parsed_action
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
	lda gs_jar_full
	beq @dead
	lda gs_parsed_object
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
pop_mode_continue:
	lda gs_mode_stack1
	sta gs_special_mode
	ldx gs_mode_stack2
	stx gs_mode_stack1
	ldx #$00
	stx gs_mode_stack2
	jmp check_special_mode



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
	lda #$2e     ;A vicious dog attacks you!
	jsr print_to_line2
	jsr wait_long
@dog_input:
	jsr get_player_input
	lda gs_parsed_object
	sta zp1A_object
	lda gs_parsed_action
	cmp #verb_movement_begin
	bcs @dead

@look:
	cmp #verb_look
	bne @attack

	lda zp1A_object
	cmp #noun_dog
	bne @dead
	lda #$8c     ;It looks very dangerous!
	jsr print_to_line2
	jmp @dog_input

@attack:
	cmp #verb_attack
	bne @play

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

@dead:
	jsr clear_status_lines
	lda #$2f     ;He rips your throat out!
	jsr print_to_line2
	jmp game_over

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

@play:
	cmp #verb_play
	bne @throw

	lda zp1A_object
	cmp #noun_ball
	beq @have
	;bne @dead
	; save 2 bytes. Any other object will fail the
	; next cmp anyway, except frisbee (coincidentally
	; same value as throw), which will still fail
	; the subsequent noun check and end up @dead.

@throw:
	cmp #verb_throw
	bne @dead

	lda zp1A_object
	cmp #noun_ball
	beq @have
	cmp #noun_sneaker
	bne @dead
@have:
	pha
	sta zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	pla
	sta zp0E_object
	ldx #icmd_destroy1
	stx zp0F_action
	;item_cmd performed in jsr thrown below
	lda #carried_known
	cmp zp1A_item_place
	bne @dead
	jsr thrown
	jsr wait_long
	jsr clear_status_lines
	lda #$30     ;The dog chases the sneaker!
	jsr print_to_line1

	lda gs_monster_alive
	and #monster_flag_roaming
	bne @dog_eaten
	pla ;skip clearing "dog alive" flag
	pla ;and don't pop mode
	rts ;resume main loop

@dog_eaten:
	jsr wait_long
	jsr clear_status_lines
	lda #$5c     ;and is eaten by
	jsr print_to_line1
	lda #$5d     ;the monster!
	jsr print_to_line2
	rts



special_monster:
	dex
	beq @check_ignited
	jmp special_mother

@check_ignited:
	lda gs_action_flags
	and #action_ignited
	beq @check_level_change
@cancel:
	lda #$00
	sta gs_monster_step
	jmp pop_mode_continue
@check_level_change:
	lda gs_action_flags
	and #action_level
	beq @monster_shake
	lda gs_monster_alive
	and #monster_flag_dying
	bne @monster_shake
	lda gs_room_lit
	bne @cancel
	lda #$00
	sta gs_monster_step

@monster_shake:
	ldx gs_monster_step
	bne @monster_smell
	jsr wait_if_prior_text
	lda #$43     ;The ground beneath your feet
	jsr print_to_line1
	lda #$44     ;begins to shake!
	jsr print_to_line2
	jmp input_during_encounter

@monster_smell:
	dex
	bne @monster_here
	jsr wait_if_prior_text
	lda #$45     ;A disgusting odor permeates
	jsr print_to_line1
	lda #$46     ;the hallway
	jsr print_to_line2
	lda gs_room_lit
	beq :+
	lda #$47     ;as it darkens
	jsr print_display_string
:	lda #'!'
	jsr char_out
	jmp input_during_encounter

@monster_here:
	dex
	beq monster_kills_you
	jmp special_tripped
monster_kills_you:
	jsr wait_if_prior_text
	jsr clear_hgr2
	lda #$36     ;The monster attacks you and
	jsr print_to_line1
	lda #$37     ;you are his next meal!
	jsr print_to_line2
	lda #maze_flag_lair_raided
	and gs_maze_flags
	beq :+
	lda #$75     ;Never raid a monster's lair
	ldx #$00
	stx zp_col
	ldx #$15
	stx zp_row
	jsr print_display_string
:	jmp game_over

input_during_encounter:
	inc gs_monster_step
	jsr get_player_input
	jsr normal_input_handler

	lda gs_action_flags
	and #(action_forward | action_turn)
	beq @check_elevator
	jsr update_view
	jsr print_timers

; Hack to make sure "body vanishes" and "elevator is moving"
; are printed in that order.
@check_elevator:
	lda gs_monster_step
	cmp #$04
	bcc @continue
	lda gs_special_mode
	cmp #special_mode_elevator
	bne @continue
	; Swap stack so "monster" is on top of "elevator"
	ldx gs_mode_stack1
	stx gs_special_mode
	sta gs_mode_stack1
@continue:
	jmp check_special_mode


wait_if_prior_text:
	lda text_buffer_line2
	cmp #$80
	bne wait_text
wait_if_text_line1:
	lda text_buffer_line1
	cmp #$80
	beq wait_done
	cmp #' '
	beq wait_done
wait_text:
	jsr wait_long
	jsr clear_status_lines
wait_done:
	rts


special_mother:
	dex
	beq @check_ignited
	jmp special_dark

@check_ignited:
	lda gs_action_flags
	and #action_ignited
	beq @check_level_change
@cancel:
	lda #$00
	sta gs_monster_step
	jmp pop_mode_continue
@check_level_change:
	lda gs_action_flags
	and #action_level
	beq @mother_shake
	lda gs_level
	cmp #$05
	bne @cancel
	lda #$00
	sta gs_monster_step

@mother_shake:
	lda gs_monster_step
	bne @mother_smell
	jsr wait_if_prior_text
	lda #$43     ;The ground beneath your feet
	jsr print_to_line1
	lda #$44     ;begins to shake!
	jsr print_to_line2
	jmp input_during_encounter

@mother_smell:
	pha
	ldx #icmd_where
	stx zp0F_action
	ldx #noun_horn
	stx zp0E_object
	jsr item_cmd
	pla
	ldx #carried_active
	cpx zp1A_item_place
	php
	beq @mother_arrives
	cmp #$02
	bcs @mother_arrives

	plp
	jsr wait_if_prior_text
	lda #$45     ;A disgusting odor permeates
	jsr print_to_line1
	lda #$46     ;the hallway
	jsr print_to_line2
	lda gs_room_lit
	beq :+
	lda #$47     ;as it darkens
	jsr print_display_string
:	lda #'!'
	jsr char_out
	jmp input_during_encounter

@mother_arrives:
	jsr wait_if_prior_text
	lda #$48     ;It is the monster's mother!
	jsr print_to_line1
	plp
	beq @seduced
	lda #$ad     ;She screeches deafeningly!
	jsr print_to_line2
	jsr wait_long
	jsr clear_hgr2
	jmp @dead

@seduced:
	lda #$49     ;She has been seduced!
	jsr print_to_line2

@input_seduced:
	jsr get_player_input
	lda gs_parsed_object
	ldx gs_parsed_action
	cpx #verb_throw
	bne @last_chance
	cmp #noun_yoyo
	bne @dead_seduced

;	jsr noun_to_item
	sta zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_unboxed
	bcs @yoyo_hit
	lda #$7b     ;Check your inventory!
	bne @print_input_again
@yoyo_hit:
	lda #noun_yoyo
	sta zp0E_object
	lda #icmd_destroy1
	sta zp0F_action
	jsr item_cmd
	lda #icmd_draw_inv
	sta zp0F_action
	jsr item_cmd
	lsr gs_mother_alive
	lda #$ae     ;It hits her in the eye!
	jsr print_to_line1
	lda #$af     ;She is blinded!
@print_input_again:
	jsr print_to_line2
	jmp @input_seduced

@last_chance:
	cmp #noun_monster
	beq @look
	cmp #noun_mother
	beq @look
@dead_seduced:
	jsr clear_status_lines
	lda #$4a     ;She tiptoes up to you!
	jsr print_to_line1
	jsr wait_long
@dead:
	lda #$4b     ;She slashes you to bits!
	jsr print_to_line2
	jsr clear_maze_window
	jmp game_over

@look:
	cpx #verb_look
	bne @attack
	lda #$8c     ;It looks very dangerous!
	ldx gs_mother_alive
	cpx #mother_flag_blinded
	bne :+
	lda #$af     ;She is blinded!
:	jsr print_to_line2
	jmp @input_seduced

@attack:
	cpx #verb_attack
	bne @dead_seduced
	ldx #noun_sword
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #carried_known
	cmp zp1A_item_place
	bne @dead_seduced
	lda gs_room_lit
	bne @lit
	lda #$57     ;It's too dark. You miss.
	jsr print_to_line2
	jsr wait_long
	jmp @dead_seduced
@lit:
	ldx gs_mother_alive
	cpx #mother_flag_blinded
	beq @win
	lda #$b0     ;She sees you coming.
	jsr print_to_line1
	jsr wait_short
	jmp @dead
@win:
	lda #$4a     ;She tiptoes up to you!
	jsr print_to_line1
	jsr wait_long
	lda #$4c     ;You slash her to bits!
	jsr print_to_line2
	jsr wait_long
	jsr clear_status_lines
	lda #$78     ;The body has vanished!
	jsr print_to_line2
	ldx #$00
	stx gs_monster_step
	stx gs_mother_alive
	jmp pop_mode_continue



special_dark:
	dex
	beq :+
	jmp special_snake

:	lda #$00
	sta gs_room_lit
	jsr clear_maze_window

	ldy #special_mode_monster
	lda gs_monster_alive
	ldx gs_level
	cpx #$05
	bne :+
	ldy #special_mode_mother
	lda gs_mother_alive

:	and #monster_flag_roaming
	beq @cancel
	cpy gs_mode_stack1
	beq @cancel
	sty gs_special_mode
	jmp check_special_mode
@cancel:
	jmp pop_mode_continue



special_snake:
	dex
	bne special_bomb

dead_by_snake:
	jsr clear_status_lines
	lda gs_snake_freed
	cmp #$02
	bne :+
	lda #$b2     ;A snake is eating it!!!
	jsr print_to_line1
:	lda #$24     ;Snake bites you!
	jsr print_to_line2
	jmp game_over



special_bomb:
	dex
	beq :+
	jmp special_elevator

:	lda gs_parsed_action
	cmp #verb_movement_begin
	bcc :+
	jsr update_view
:	lda gs_bomb_tick
	beq @last_move
	dec gs_bomb_tick
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
	lda gs_parsed_action
	cmp #verb_open
	beq :+
	cmp #verb_unlock
	bne @boom
:	lda gs_parsed_object
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
	
	dec gs_player_x
	jsr update_view
	lda #$a0     ;Don't look back!
	jsr print_to_line1
	lda #special_mode_endgame
	sta gs_special_mode
	jmp check_special_mode

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
	jsr normal_input_handler
	jsr count_as_move
	jsr print_timers
	jmp check_special_mode



special_elevator:
	dex
	beq :+
	dex
	jmp special_climb

:	jsr get_player_input
	lda gs_parsed_action
	cmp #verb_forward
	beq enter_elevator
	cmp #verb_throw
	bne @pop_mode_do_cmd
	lda gs_parsed_object
	cmp #noun_ball
	bne @pop_mode_do_cmd
	jmp throw_ball
@pop_mode_do_cmd:
	lda gs_mode_stack1
	sta gs_special_mode
	lda gs_mode_stack2
	ldx #$00
	stx gs_mode_stack2
	sta gs_mode_stack1
	jsr normal_input_handler
	lda gs_special_mode
	beq @update
	cmp #special_mode_endgame
	bne @done
@update:
	jsr update_view
@done:
	jmp check_special_mode

ride_elevator:
	lda #action_level
	ora gs_action_flags
	sta gs_action_flags
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

@level2:
	dex
	bne @level3

	jsr clear_maze_window
	ldx #$03
	stx gs_walls_left
	ldx #$23
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
	dex
	bne @level4

	ldx gs_player_x
	cpx #$07
	beq @magic
	inc gs_level
	ldx #$01
	stx gs_player_x
	bne @clear_turns
@magic:
	; Y += (3 - facing)
	; 8,2 => 9
	; 9,4 => 8
	lda #$03
	sec
	sbc gs_facing
	clc
	adc gs_player_y
	sta gs_player_y
	jsr update_view
	jmp pop_mode_continue

@level4:
	dex
	bne @level5

	dec gs_level
	ldx #$04
	stx gs_player_x
@clear_turns:
	ldx #$00
	stx gs_level_moves_hi
	stx gs_level_moves_lo
	jmp ride_elevator

	beq @level2
	dex
	beq @level3
	dex
	beq @level4

@level5:
	lda gs_player_x
	cmp #$01
	bne @fake
	lda gs_broken_door
	bpl @spike
	inc gs_player_y
	jsr update_view
	jmp pop_mode_continue

@spike:
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

@fake:
	lda #$6d     ;You are trapped in a fake
	jsr print_to_line1
	lda #$6e     ;elevator. There is no escape!
	jsr print_to_line2
	jmp game_over

throw_ball:
	lda #$c6     ;The ball sails through the open door
	jsr print_to_line1
	jsr wait_short
	jsr wait_short
	jsr update_view
	jsr wait_short
	jsr flash_screen
	jsr clear_maze_window
	jsr wait_long

	ldx #icmd_destroy2
	stx zp0F_action
	.assert noun_ball = icmd_destroy2, error, "Need to revert register optimization in throw_ball"
;	ldx #noun_ball
	stx zp0E_object
	jsr item_cmd
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd

	jsr which_door
	sta gs_broken_door

	lda #$c7     ;The ceiling has collapsed,
	jsr print_to_line1
	lda #$c9     ;filling a hidden pit!
	ldx gs_mode_stack1
	cpx #special_mode_endgame
	beq :+
	jsr update_view
	lda #$c8     ;blocking the door.
:	jsr print_to_line2

	jmp pop_mode_continue



special_tripped:
	dex
	bne @lying_dead

@check_input:
	jsr get_player_input
	lda gs_parsed_object
	cmp #noun_monster
	beq @look
@dead:
	jsr clear_status_lines
	jmp monster_kills_you

@look:
	lda gs_parsed_action
	cmp #verb_look
	bne @attack
	lda #$8c     ;It looks very dangerous!
	jsr print_to_line2
	jmp @check_input

@attack:
	cmp #verb_attack
	bne @dead
	lda gs_room_lit
	bne @with_dagger
	lda #$57     ;It's too dark. You miss.
	jsr print_to_line2
	jmp monster_kills_you

@with_dagger:
	ldx #noun_dagger
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda #carried_known
	cmp zp1A_item_place
	bne @dead

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
	lda #$aa     ;The monster roars and chokes
	jsr print_to_line1
	lda #$ab     ;on blood as it dies!
	jsr print_to_line2
	lsr gs_monster_alive
	jmp input_during_encounter

@lying_dead:
	dex
	; throw frisbee will inc past this step
	; anything else forfeits opportunity
	beq @body_vanishes

;@blood_everywhere:
	dex
	bne @body_vanishes
	; opportunity to fill jar
	jmp input_during_encounter

@body_vanishes:
	jsr wait_if_text_line1
	lda #$78     ;The body has vanished!
	jsr print_to_line1
	lda #$00
	sta gs_monster_step
	lsr gs_monster_alive
	jmp pop_mode_continue



special_climb:
	dex
	beq :+
	jmp special_endgame

:	jsr get_player_input
	lda gs_parsed_action
	cmp #verb_movement_begin
	bcc @climb_snake
@dead:
	jmp dead_by_snake
@climb_snake:
	cmp #verb_climb
	bne @dead
	lda gs_parsed_object
	cmp #noun_snake
	bne @dead
	lda gs_player_x
	sta zp1A_pos_x
	lda gs_player_y
	sta zp19_pos_y

	lda gs_level
	cmp #$02
	beq @on_level_2
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
	lda #maze_flag_lair_raided
	ora gs_maze_flags
	sta gs_maze_flags
	bne @up_level
@on_level_3:
	lda zp1A_pos_x
	cmp #$08
	bne @ceiling
	lda zp19_pos_y
	cmp #$05
	beq @up_level
@on_level_2:
	lda #$03
	cmp zp1A_pos_x
	bne @ceiling
;	lda #$03
	cmp zp19_pos_y
	bne @ceiling
	lda #$01
	sta gs_player_x
	lda #$0b
	sta gs_player_y
	bne @up_level

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

@up_level:
	dec gs_level
	jsr update_view
	jsr get_player_input
	lda gs_parsed_action
	cmp #verb_movement_begin
	bcs :+
	jsr clear_status_lines
	lda #$54     ;You can't be serious!
	jsr print_to_line1
	jsr wait_long
	jmp dead_by_snake

:	jsr normal_input_handler
	lda gs_action_flags
	and #(action_forward | action_turn)
	beq :+
	jsr update_view

:	ldx #noun_snake
	stx zp0E_object
	ldx #icmd_destroy1
	stx zp0F_action
	jsr item_cmd

	lda #noun_banana
	sta zp0E_object
	pha
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_begin
	bcs @snake_eats

	pla
	lda #noun_peel
	sta zp0E_object
	pha
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_begin
	bcs @snake_eats

;@snake_fall:
	lda #$b4     ;The snake falls
	jsr print_to_line1
	pla
	bne @slither_away

@snake_eats:
	pla
	sta zp0E_object
	pha
	ldx #icmd_destroy1
	stx zp0F_action
	jsr item_cmd
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
	lda #$b3     ;The snake eats the 
	jsr print_to_line1
	pla
	jsr print_noun

@slither_away:
	lda #$b5     ;and slithers away.
	jsr print_to_line2

	lda gs_action_flags
	and #action_forward
	bne :+
	jsr wait_long

:	jsr check_special_position
	lda gs_action_flags
	and #action_level
	beq :+
	jsr update_view

:	jmp pop_mode_continue



special_endgame:
	lda gs_facing
	ldy gs_broken_door

; When final door is blown, change it to -1 here
; so it behaves like a regualar door again
; without making player fall on spikes.

;@check_door:
	bmi @check_riddle
	cpy #door_final
	bne @check_dead
	lda #$ff
	sta gs_broken_door
	jmp update_view
	;rts

@check_dead:
	cmp #$03  ;gs_facing
	bne @normal
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
@normal:
	rts

@check_riddle:
	ldy gs_player_y
	cpy #$0b
	bne @check_dead
	cmp #$02  ;gs_facing
	bne @normal
	jsr @check_word
	jmp @draw_riddle
	;rts

@draw_riddle:
	lda #$09
	sta zp_col
	ldx #$06
	stx zp_row
	lda #$cc     ;EXIT
	jsr print_display_string
	lda #$03
	sta zp_col
	ldx #$0a
	stx zp_row
	lda #$cd     ;SEALED BY ORDER
	jsr print_display_string
	lda #$03
	sta zp_col
	ldx #$0b
	stx zp_row
	lda #$ce     ;OF THE MONSTER,
	jsr print_display_string
	lda #$03
	sta zp_col
	ldx #$0c
	stx zp_row
	lda #$cf     ;WHOSE NAME MUST 
	jsr print_display_string
	lda #$03
	sta zp_col
	ldx #$0d
	stx zp_row
	lda #$d0     ;NEVER BE SPOKEN
	jsr print_display_string
	rts

@check_word:
	lda gs_parsed_action
	cmp #verb_say
	bne @normal
	lda zp11_count
	cmp #magic_word_length
	bne @normal

@win:
	jsr update_view
	jsr wait_long
	dec gs_facing
	jsr update_view
	jsr clear_status_lines
	lda #$43     ;The ground beneath your feet
	jsr print_to_line1
	lda #$44     ;begins to shake!
	jsr print_to_line2
	jsr wait_long
	lda #drawcmd0A_door_opening
	sta zp0F_action
	jsr draw_special

	lda #$38     ;The magic word works! You have escaped!
	jsr print_to_line1
	lda #$4d     ;(Press any key to exit.)
	jsr print_to_line2

	bit hw_STROBE
:	bit hw_KEYBOARD
	bpl :-
	bit hw_STROBE

	jsr clear_hgr2
	jmp exit_game
