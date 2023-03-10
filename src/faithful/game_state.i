	.global game_save_begin
	.global game_save_end

	.global gs_facing
	.global gs_level
	.global gs_player_x
	.global gs_player_y
	.global gs_torches_lit
	.global gs_torches_unlit
	.global gs_walls_left
	.global gs_walls_right_depth
	.global gs_box_visible
	.global gs_parsed_action
	.global gs_parsed_object
	.global gs_room_lit
	.global gs_food_time_hi
	.global gs_food_time_lo
	.global gs_torch_time
	.global gs_teleported_dark
	.global gs_level_moves_hi
	.global gs_level_moves_lo
	.global gs_special_mode
	.global gs_mode_stack1
	.global gs_mode_stack2
	.global gs_endgame_step
;	.global gs_UNUSED
;	.global gs_UNUSED
	.global gs_bat_alive
	.global gs_mother_alive
	.global gs_monster_alive
	.global gs_dog1_alive
	.global gs_dog2_alive
;	.global gs_UNUSED
	.global gs_next_hint
	.global gs_monster_step
	.global gs_mother_step
	.global gs_rotate_target
	.global gs_rotate_count
	.global gs_rotate_direction
	.global gs_bomb_tick
	.global gs_rotate_hint_counter
	.global gs_lair_raided
	.global gs_snake_freed
	.global gs_jar_full

	.global gs_item_locs
	.global gs_item_snake
	.global gs_item_food
	.global gs_item_torch

	.global game_save_begin
	.global game_save_end

	.global game_state_begin
	.global game_state_end

	.assert game_state_end - game_state_begin <= $100, error, "Game state is too large for indexing"

	game_state_size = <(game_state_end - game_state_begin)
	game_save_size = <(game_save_end - game_save_begin)


	items_unique    = $11
	items_food      = $03
	items_torches   = $03

	items_total = items_unique + items_food + items_torches

	item_begin        = 1   ;indexing is 1-based
	item_food_begin   = item_begin + items_unique
	item_torch_begin  = item_food_begin + items_food

	item_food_end  = item_food_begin  + items_food
	item_torch_end = item_torch_begin + items_torches


; First byte in gs_item_locations is either
; maze level 1-5 or one of these values:
carried_boxed = $06
carried_active = $07
carried_known = $08

; for >= comparisons
carried_begin = $06
carried_unboxed = $07

monster_flag_roaming = $02
mother_flag_roaming = $04

