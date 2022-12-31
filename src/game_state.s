	.export signature

	.include "string_noun_decl.i"

	.segment "SIGNATURE"

signature:
	.byte "DEATH"

	.res $8F


	.include "game_state.i"
	.import __GAME_STATE_RUN__
;	.import __GAME_STATE_SIZE__
__GAME_STATE_SIZE__  = $FF

	.segment "GAME_STATE"

game_save_begin = __GAME_STATE_RUN__

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
gs_rotate_direction:
gs_bomb_tick:  ;Deliberate. Two purposes for the same memory location.
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


	; Relate items to noun vocabulary
	.assert item_begin + items_unique = nouns_unique_end, error, "Miscounted unique items"


gs_size = * - game_save_begin


game_save_end = game_save_begin + __GAME_STATE_SIZE__
