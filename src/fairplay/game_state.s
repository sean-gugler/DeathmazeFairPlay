	.include "game_state.i"
	.include "junk_byte.i"
	.include "string_noun_decl.i"

	.segment "GAME_STATE"

game_save_begin = *
game_state_begin = *

gs_facing:
	JUNK_BYTE $02
gs_level:
	JUNK_BYTE $05
gs_player_x:
	JUNK_BYTE $04
gs_player_y:
	JUNK_BYTE $0a
gs_torches_lit:
	JUNK_BYTE $00
gs_torches_unlit:
	JUNK_BYTE $01
gs_walls_left:
	JUNK_BYTE $00
gs_walls_right_depth:
	JUNK_BYTE $00
gs_box_visible:
	JUNK_BYTE $00
gs_parsed_action:
	JUNK_BYTE $10
gs_parsed_object:
	JUNK_BYTE $17
gs_room_lit:
	JUNK_BYTE $01
gs_food_time_hi:
	JUNK_BYTE $00
gs_food_time_lo:
	JUNK_BYTE $80
gs_active_torch:
	JUNK_BYTE $80
gs_teleported_dark:
	JUNK_BYTE $00
gs_level_moves_hi:
	JUNK_BYTE $00
gs_level_moves_lo:
	JUNK_BYTE $29
gs_special_mode:
	JUNK_BYTE $00
gs_mode_stack1:
	JUNK_BYTE $00
gs_mode_stack2:
	JUNK_BYTE $00
gs_endgame_step:
	JUNK_BYTE $00
gs_ring_glow:
	JUNK_BYTE $00
gs_staff_charged:
	JUNK_BYTE $00
gs_bat_alive:
	JUNK_BYTE $00
gs_mother_alive:
	JUNK_BYTE $04
gs_monster_alive:
	JUNK_BYTE $00
gs_dog1_alive:
	JUNK_BYTE $00
gs_dog2_alive:
	JUNK_BYTE $01
gs_broken_door:
	JUNK_BYTE $00
gs_bomb_tick:
	JUNK_BYTE $00
gs_monster_step:
	JUNK_BYTE $0c
gs_action_flags:
	JUNK_BYTE $00
gs_rotate_target:
	JUNK_BYTE $05
gs_rotate_count:
	JUNK_BYTE $00
gs_rotate_direction:
	JUNK_BYTE $00
gs_rotate_hint_counter:
	JUNK_BYTE $00
gs_maze_flags:
	JUNK_BYTE $00
gs_snake_freed:
	JUNK_BYTE $01
gs_jar_full:
	JUNK_BYTE $00

gs_item_locs:
	JUNK_BYTE {$08,$00,$03,$a5,$00,$00,$04,$a9}
	JUNK_BYTE {$08,$00,$01,$64,$02,$33,$08,$00}
	JUNK_BYTE {$00,$00,$05,$72,$07,$00,$00,$00}
	JUNK_BYTE {$02,$86,$08,$00,$04,$a8,$04,$57}
	JUNK_BYTE {$00,$00,$00,$00,$00,$00,$00,$00}
	JUNK_BYTE {$00,$00,$00,$00}
	.assert * - gs_item_locs = items_unique * 2, error, "Miscount between data and definition"

gs_item_food:
	JUNK_BYTE {$00,$00,$00,$00,$00,$00,$00,$00}
	.assert * - gs_item_food = items_food * 2, error, "Miscount between data and definition"

gs_item_torch:
	JUNK_BYTE {$00,$00,$00,$00,$08,$00,$00,$00}
	JUNK_BYTE {$00,$00}
	.assert * - gs_item_torch = items_torches * 2, error, "Miscount between data and definition"

gs_torch_life:
	JUNK_BYTE {$00,$00,$00,$00,$00}
	.assert * - gs_torch_life = items_torches, error, "Miscount between data and definition"

; Relate items to noun vocabulary
	.assert nouns_unique_end = item_begin + items_unique, error, "Miscounted unique items"

gs_item_snake = gs_item_locs + (noun_snake - 1) * 2


game_state_end = *


	.export signature

	.segment "SIGNATURE"

signature:
	JUNK_BYTE "D"
	JUNK_BYTE "E"
	JUNK_BYTE "A"
	JUNK_BYTE "T"
	JUNK_BYTE "H"

game_save_end = *
