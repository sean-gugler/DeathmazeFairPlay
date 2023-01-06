
;(1 << 0) = $01
;(1 << 1) = $02
;(1 << 2) = $04
;(1 << 3) = $08
;(1 << 4) = $10
;' ' = $20
;(1 << 5) = $20
;'*' = $2a
;'.' = $2e
;'0' = $30
;'?' = $3f
;(1 << 6) = $40
;'A' = $41
;'D' = $44
;'E' = $45
;'H' = $48
;'N' = $4e
;'T' = $54
;'X' = $58
;'Y' = $59
;'Z' = $5a
;>font = $62
;(1 << 7) = $80
;<font = $94
;raster 0,-1,0 = >relocated

;'0' - noun_zero = $16

;$zp_string_number = a11
;$zp_wall_opposite = a19

;$zp0C_string_ptr = a0C
;;$zp0C_string_ptr+1 = a0D

;$zp0F_action = a0F

;$zp10_count_words = a10

;$zp11_count_chars = a11

;$zp13_raw_input = a13

;$zp19_count = a19

;$zp1A_hint_mode = a1A
;$zp1A_item_place = a1A
;$zp1A_move_action = a1A
;$zp1A_object = a1A

;<(gs_item_location-2) = $b9

;<dos_iob = $b6

;<food_fart_consume = $0a
;<food_amount = $aa

;<game_save_begin = <gs_facing

;<gs_item_locs = $bb

;<row8_table = $62

;>(gs_item_location-2) = $61

;>dos_iob = $7c

;>food_amount = $00
;>food_fart_consume = $00

;>game_save_begin = >gs_facing

;>row8_table = $11

;>screen_GR2 = $08

carried_begin = $06
carried_boxed = $06
carried_active = $07
carried_unboxed = $07
carried_known = $08

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

;door_lock_begin - doors_elevators = $15
;door_lock_begin + door_correct = $1b

drawcmd01_keyhole = $01

drawcmd02_elevator = $02

drawcmd03_compactor = $03

drawcmd08_doors = $08

drawcmd09_keyholes = $09

drawcmd0A_door_opening = $0a

error_write_protect = $01
error_volume_mismatch = $02
error_unknown_cause = $03
error_reading = $04
error_bad_save = $05

execs_location_end = $07
execs_no_location = $07

facing_W = $01
facing_N = $02
facing_E = $03

food_fart_minimum = $05
food_low = $0a
;food_fart_minimum + food_fart_consume = $0f

game_save_begin = s_facing

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
icmd_where = $06
icmd_draw_inv = $07
icmd_count_inv = $08
icmd_reset_game = $09
icmd_0a = $0a
icmd_which_box = $0b
icmd_which_food = $0c
icmd_which_torch_lit = $0d
icmd_which_torch_unlit = $0e

inventory_max = $08

item_ball = $01
item_flute = $05
;item_food_begin - 1 = $11
item_food_begin = $12
;item_torch_begin - 1 = $14
item_food_begin = $15
item_food_end = $15
item_torch_begin = $15
item_torch_end = $18

items_food = $03
items_torches = $03
;items_food + items_torches = $06
items_unique = $12
;items_unique + items_food = $14
items_total = $17
;items_unique + items_food + items_torches = $17

max_input = $1e

maze_features_end = $26

mother_flag_roaming = $04

noun_ball = $01
noun_brush = $02
noun_calculator = $03
noun_dagger = $04
noun_flute = $05
noun_frisbee = $06
noun_hat = $07
noun_horn = $08
noun_jar = $09
;noun_play - noun_blow = $09
noun_key = $0a
noun_ring = $0b
noun_sneaker = $0c
noun_staff = $0d
noun_sword = $0e
noun_wool = $0f
;noun_snake-1 = $10
noun_yoyo = $10
noun_snake = $11
noun_food = $12
noun_torch = $13
noun_box = $14
noun_bat = $15
noun_dog = $16
noun_door = $17
noun_monster = $18
noun_mother = $19
;noun_zero-1 = $19
noun_zero = $1a
noun_two = $1c

nouns_unique_end = $12
nouns_item_end = $15

opcode_JMP = $4c

puzzle_step1 = $05

;raster_hi 10,10,7 = $5d
;raster_hi 10,11,7 = $5d
;raster_hi 10,9,7 = $5d
;raster_hi 11,9,7 = $5d

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

torch_low = $0a
torch_lifespan = $96

moves_until_trippable = $29
moves_until_mother = $32
moves_until_dog1 = $3c
moves_until_monster = $50

verb_break = $03
;verb_light - verb_burn = $06
verb_throw = $06
verb_climb = $07
verb_drop = $08
verb_fill = $09
verb_look = $0e
verb_open = $10
verb_press = $11
verb_take = $12
verb_attack = $13
verb_intransitive = $14
verb_grendel = $15
verb_movement_begin = $5a
verb_forward = $5b
;verb_movement_begin + 1 = $5b
verb_left = $5c
verb_right = $5d
verb_uturn = $5e

;verbs_end-1 = $1c
verbs_end = $1d

;vocab_end-1 = $3f
vocab_end = $40
