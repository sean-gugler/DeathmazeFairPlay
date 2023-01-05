	.include "junk_byte.i"

	.export signature

	.segment "SIGNATURE"

signature:
	JUNK_BYTE "DEATH"

	.res $8F


	.include "game_state.i"
	.include "string_noun_decl.i"

	.import __GAME_STATE_RUN__
;	.import __GAME_STATE_SIZE__
__GAME_STATE_SIZE__  = $FF

	.segment "GAME_STATE"

game_save_begin = __GAME_STATE_RUN__

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
gd_parsed_action:
	JUNK_BYTE $10
gd_parsed_object:
	JUNK_BYTE $17
gs_room_lit:
	JUNK_BYTE $01
gs_food_time_hi:
	JUNK_BYTE $00
gs_food_time_lo:
	JUNK_BYTE $80
gs_torch_time:
	JUNK_BYTE $80
gs_teleported_dark:
	JUNK_BYTE $00
gs_level_turns_hi:
	JUNK_BYTE $00
gs_level_turns_lo:
	JUNK_BYTE $29
gs_special_mode:
	JUNK_BYTE $00
gs_mode_stack1:
	JUNK_BYTE $00
gs_mode_stack2:
	JUNK_BYTE $00
gs_endgame_step:
	JUNK_BYTE $00
gs_unused1:
	JUNK_BYTE $00
gs_unused2:
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
gs_unused3:
	JUNK_BYTE $00
gs_next_hint:
	JUNK_BYTE $00
gs_monster_proximity:
	JUNK_BYTE $0c
gs_mother_proximity:
	JUNK_BYTE $00
gs_rotate_target:
	JUNK_BYTE $05
gs_rotate_count:
	JUNK_BYTE $00
gs_rotate_direction:
gs_bomb_tick:  ;Deliberate. Two purposes for the same memory location.
	JUNK_BYTE $00
gs_rotate_total:
	JUNK_BYTE $00
gs_lair_raided:
	JUNK_BYTE $00
gs_snake_used:
	JUNK_BYTE $01
gs_unused4:
	JUNK_BYTE $00

gs_item_locs:
	JUNK_BYTE {$08,$00,$03,$a5,$00,$00,$04,$a9}
	JUNK_BYTE {$08,$00,$01,$64,$02,$33,$08,$00}
	JUNK_BYTE {$00,$00,$05,$72,$07,$00,$00,$00}
	JUNK_BYTE {$02,$86,$08,$00,$04,$a8,$04,$57}
gs_item_snake:
	JUNK_BYTE {$00,$00}
	.assert * - gs_item_locs = items_unique * 2, error, "Miscount between data and definition"

gs_item_food_torch:
	JUNK_BYTE {$00,$00,$00,$00,$00,$00}
	.assert * - gs_item_locs = (item_food_end - item_begin) * 2, error, "Miscount between data and definition"

	JUNK_BYTE {$00,$00,$00,$00,$08,$00}
	.assert * - gs_item_locs = (item_torch_end - item_begin) * 2, error, "Miscount between data and definition"


	; Relate items to noun vocabulary
	.assert item_begin + items_unique = nouns_unique_end, error, "Miscounted unique items"


game_state_end = * - game_save_begin
	.assert >game_state_end = 0, error, "Game state data larger than one page"

game_save_end = game_save_begin + __GAME_STATE_SIZE__
