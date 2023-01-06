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
	.import player_cmd
	.import get_player_input
	.import update_view

;	.include "apple.i"
	.include "char.i"
	.include "draw_commands.i"
	.include "game_design.i"
	.include "game_state.i"
	.include "item_commands.i"
;	.include "special_modes.i"
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
zp1A_move_action   = $1A;
zp1A_hint_mode     = $1A;

	.segment "SPECIAL_MODES"

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
	lda gs_rotate_direction
	bne @check_repeat_turn
	ldx zp1A_move_action
	stx gs_rotate_direction  ;Set initial turn direction
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
@dog_input:
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
.if REVISION >= 100
	lda #$8c     ;It looks very dangerous!
.else ;RETAIL
	lda #$28     ;It displays 317.2!  (BUG)
.endif
	jsr print_to_line2
.if REVISION >= 100
	jmp @dog_input
.else ;RETAIL
	jmp @confront_dog ;BUG: no time to read the response
.endif

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
	lda zp1A_object
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
	stx gs_level_moves_lo ;GUG: careful, if I revise to allow re-lighting torch
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
	bpl @kill_snake
	ldx #noun_sword
	stx zp0E_object
	ldx #icmd_where
	stx zp0F_action
	jsr item_cmd
	lda zp1A_item_place
	cmp #carried_unboxed
	bmi dead_by_snake
	bpl @killed
@kill_snake:
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
	stx zp1A_facing
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



special_endgame:
	jsr clear_maze_window
	lda #$07
	sta gs_walls_left
	ldx #$47     ;GUG: depth 4? not 3?
	stx gs_walls_right_depth
	jsr draw_maze
	ldx #drawcmd08_doors
	stx zp0F_action
	ldx #$01
	stx zp0E_draw_param
	jsr draw_special
	ldx #$01
	stx gs_endgame_step
@endgame_input_loop:
	lda #$a0     ;Don't make unnecessary turns.
	jsr print_to_line1
	jsr get_player_input
	lda gs_endgame_step
	sta zp1A_endgame_step
	lda gd_parsed_action
	dec zp1A_endgame_step
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
	stx zp0F_action
	ldx #$02
	stx zp0E_draw_param
	jsr draw_special
	inc gs_endgame_step
	jmp @endgame_input_loop

@step2:
	dec zp1A_endgame_step
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
	dec zp1A_endgame_step
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
	stx zp0F_action
	jsr draw_special
	inc gs_endgame_step
	jmp @endgame_input_loop

@step4:
	dec zp1A_endgame_step
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
	stx zp0F_action
	jsr draw_special
	inc gs_endgame_step
	jmp @endgame_input_loop

@step5:
	dec zp1A_endgame_step
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
	stx zp0F_action
	ldx #noun_ball
	stx zp0E_object
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
	ldx #icmd_destroy2
	stx zp0F_action
;	ldx #noun_ball  ;optimized - same value as icmd_destroy2
	stx zp0E_object
	jsr item_cmd
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
	inc gs_endgame_step
	jmp @endgame_input_loop

@step6:
	dec zp1A_endgame_step
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
	stx zp0C_string_ptr
	ldx #>@text_congrats
	stx zp0C_string_ptr+1
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


