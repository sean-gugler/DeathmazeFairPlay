	.export find_which_multiple
	.export item_cmd

	.import data_new_game
	.import print_noun
	.import print_display_string
	.import char_out
	.import get_rowcol_addr

	.include "game_state.i"
	.include "item_commands.i"
	.include "string_noun_decl.i"

facing_W = $01
facing_N = $02
facing_E = $03
facing_S = $04

zp_col = $06
zp_row = $07

zp10_temp          = $10;
zp11_count_loop    = $11;
zp0E_ptr           = $0E;
zp0E_box_visible   = $0E;
zp0F_sight_depth   = $0F;
zp19_level         = $19;
zp10_pos_y         = $10;
zp11_pos_x         = $11;
zp10_which_place   = $10;
zp11_count_which   = $11;
zp13_level         = $13;
zp11_position      = $11;
zp10_dst           = $10;
zp0E_src           = $0E;
zp19_count         = $19;
zp1A_cmds_to_check = $1A;
zp13_temp          = $13;
zp1A_count_loop    = $1A;
zp19_item_position = $19;
zp1A_item_place    = $1A;
zp0E_item          = $0E;
zp0E_object        = $0E;
zp0F_action        = $0F;

	.segment "ITEM_COMMANDS"

; Perform an internal command upon items.
; Input:
;   $0E object
;   $0F action  ('icmd_' constant)
; Output for location-related commands:
;   ($0E) item location info (place, position)
; Output for icmd_where:
;   $19 position
;   $1A place (level or 'carried' value)
; Output for icmd_count_inv:
;   $19 count
; Output for all icmd_which:
;   A  item number
;
item_cmd:
	lda zp0F_action
	cmp #icmds_location_end
	bpl icmd07_draw_inv
; Convert object variable from 1-byte Index to 2-byte Pointer
	asl zp0E_object
	pha
	lda #$00
	sta zp0E_item+1
	clc
	lda #<(gs_item_locs-2)
	adc zp0E_item
	sta zp0E_item
	lda #>(gs_item_locs-2)
	adc zp0E_item+1
	sta zp0E_item+1
	pla
; Perform location-related action
	cmp #icmd_drop
	bpl icmd06_where_item
	cmp #$00
	beq @set_place	;icmd_destroy1
	sec
	sbc #$01
	beq @set_place	;icmd_destroy2
	clc
	adc #$05		;icmd 2,3,4 => carried 6,7,8
@set_place:
	ldy #$00
	sta (zp0E_item),y
	inc zp0E_item
	bne :+
	inc zp0E_item+1
:	lda #$00
	sta (zp0E_item),y
	rts

icmd06_where_item:
	cmp #icmd_drop
	beq icmd05_drop_item
	ldy #$00
	lda (zp0E_item),y
	sta zp1A_item_place
	iny
	lda (zp0E_item),y
	sta zp19_item_position
	rts

icmd05_drop_item:
	lda gs_level
	ldy #$00
	sta (zp0E_item),y
	lda gs_player_x
	asl
	asl
	asl
	asl
	ora gs_player_y
	iny
	sta (zp0E_item),y
	rts

icmd07_draw_inv:
	sec
	sbc #icmds_location_end
	beq @clear_window
	jmp icmd08_count_inv

@clear_window:
	lda #$0f
	sta zp1A_count_loop
	lda #$19
	sta zp_col
	lda #$03
	sta zp_row
:	jsr get_rowcol_addr
	lda #$1e     ;char_ClearLine
	jsr char_out
	inc zp_row
	dec zp1A_count_loop
	bne :-

; print inventory
	lda #items_unique + items_food
	sta zp1A_count_loop
	lda #<gs_item_locs
	sta zp0E_item
	lda #>gs_item_locs
	sta zp0E_item+1
	lda #$1a
	sta zp_col
	lda #$03
	sta zp_row
	jsr get_rowcol_addr
	lda #$01     ;Inventory:
	jsr print_display_string
	lda #$1b
	sta zp_col
	lda #$04
	sta zp_row
	jsr get_rowcol_addr
check_item_known:
	ldy #$00
	lda (zp0E_item),y
	cmp #$08
	bne :+
	jmp print_known_item
:	cmp #$07
	bne next_known_item
	jmp print_known_item
next_known_item:
	inc zp0E_item
	bne :+
	inc zp0E_item+1
:	inc zp0E_item
	bne :+
	inc zp0E_item+1
:	dec zp1A_count_loop
	bne check_item_known

	lda #<gs_item_locs
	sta zp0E_item
	lda #>gs_item_locs
	sta zp0E_item+1
	lda #items_total
	sta zp1A_count_loop
check_item_boxed:
	ldy #$00
	lda (zp0E_item),y
	cmp #carried_boxed
	bne next_boxed_item
	jmp print_boxed_item

next_boxed_item:
	inc zp0E_item
	bne :+
	inc zp0E_item+1
:	inc zp0E_item
	bne :+
	inc zp0E_item+1
:	dec zp1A_count_loop
	bne check_item_boxed

	lda #$1a
	sta zp_col
	lda #$10
	sta zp_row
	jsr get_rowcol_addr
	lda #$02     ;Torches:
	jsr print_display_string
	lda #$1b
	sta zp_col
	lda #$11
	sta zp_row
	jsr get_rowcol_addr
	lda #$03     ;Lit:
	jsr print_display_string
	inc zp_col
	inc zp_col
	inc zp_col
	jsr get_rowcol_addr
	lda gs_torches_lit
	clc
	adc #'0'
	jsr char_out
	lda #$1b
	sta zp_col
	lda #$12
	sta zp_row
	jsr get_rowcol_addr
	lda #$04     ;Unlit:
	jsr print_display_string
	lda #' '
	jsr char_out
	lda gs_torches_unlit
	clc
	adc #'0'
	jsr char_out
	rts

print_known_item:
	lda #item_food_end
	sec
	sbc zp1A_count_loop
	cmp #item_food_begin
	bmi :+
	lda #noun_food
:	sta zp13_temp
	lda zp_col
	pha
	lda zp_row
	pha
	lda zp13_temp
	jsr print_noun
	pla
	sta zp_row
	inc zp_row
	pla
	sta zp_col
	jsr get_rowcol_addr
	jmp next_known_item

print_boxed_item:
	lda zp_col
	pha
	lda zp_row
	pha
	lda #noun_box
	jsr print_noun
	pla
	sta zp_row
	inc zp_row
	pla
	sta zp_col
	jsr get_rowcol_addr
	jmp next_boxed_item

icmd08_count_inv:
	sta zp1A_cmds_to_check
	dec zp1A_cmds_to_check
	bne icmd09_new_game

	lda #>gs_item_locs
	sta zp0E_item+1
	lda #<gs_item_locs
	sta zp0E_item
	lda #items_unique + items_food
	sta zp1A_count_loop
	lda #$00
	sta zp19_count
	ldy #$00
@check_carried:
	lda (zp0E_item),y
	cmp #carried_begin
	bmi :+
	inc zp19_count
:	iny
	iny
	dec zp1A_count_loop
	bne @check_carried

.if REVISION >= 100
	lda #items_torches
	sta zp1A_count_loop
@check_boxed_torches:
	lda (zp0E_item),y
	cmp #carried_boxed
	bne :+
	inc zp19_count
:	iny
	iny
	dec zp1A_count_loop
	bne @check_boxed_torches
.endif

	lda gs_torch_time
	bne @add_one
	lda gs_torches_unlit
	beq @done
@add_one:
	inc zp19_count
@done:
	rts

icmd09_new_game:
	dec zp1A_cmds_to_check
	bne icmd0A

	ldy #game_state_size-1
	lda #>data_new_game
	sta zp0E_src+1
	lda #<data_new_game
	sta zp0E_src
	lda #<game_state_begin
	sta zp10_dst
	lda #>game_state_begin
	sta zp10_dst+1
:	lda (zp0E_src),y
	sta (zp10_dst),y
	dey
	bpl :-
	rts

icmd0A:
	dec zp1A_cmds_to_check
	bne icmd0B_which_box
	jmp icmd0A_probe_boxes

; Order of preference for boxes:
;   1) at feet
;   2) carried, in noun order (except snake)
;   3) carried snake
icmd0B_which_box:
	dec zp1A_cmds_to_check
	beq :+
	jmp icmd0C_which_food

:	lda gs_player_x
	asl
	asl
	asl
	asl
	clc
	adc gs_player_y
	sta zp11_position

; Check at feet
	lda #>(gs_item_locs+1)
	sta zp0E_item+1
	lda #<(gs_item_locs+1)
	sta zp0E_item
	lda #items_total
	sta zp1A_count_loop
	ldy #$00
	lda zp11_position
@check_is_here:
	cmp (zp0E_item),y
	beq @check_level
@not_here:
	iny
	iny
	dec zp1A_count_loop
	bne @check_is_here

; Check carried, skipping snake
.if REVISION >= 100  ;same effect but simpler
	dec zp0E_item
.else ;RETAIL
	lda #>gs_item_locs
	sta zp0E_item+1
	lda #<gs_item_locs
	sta zp0E_item
.endif
.if REVISION >= 100  ;single loop, skipping the snake
	lda #items_total
.else ;RETAIL used 2 blocks to loop below snake and above snake
	lda #noun_snake-1
.endif
	sta zp1A_count_loop
	lda #carried_boxed
	ldy #$00
@check_is_carried:
.if REVISION >= 100
	cpy #<(gs_item_snake - gs_item_locs)
	beq @next
.endif
	cmp (zp0E_item),y
	beq @return_item_num
@next:
	iny
	iny
	dec zp1A_count_loop
	bne @check_is_carried

.if REVISION < 100  ;RETAIL used 2 blocks to loop below snake and above snake
; Check carried above snake
	lda #>(gs_item_locs + noun_snake * 2)
	sta zp0E_item+1
	lda #<(gs_item_locs + noun_snake * 2)
	sta zp0E_item
	lda #items_total - noun_snake
	sta zp1A_count_loop
	.assert carried_boxed = items_total - noun_snake, error, "Need to revert register optimization in which_box"
;	lda #carried_boxed
	ldy #$00
@check_mult_carried:
	cmp (zp0E_item),y
	beq @return_item_num
	iny
	iny
	dec zp1A_count_loop
	bne @check_mult_carried
.endif

; Last, check for carrying boxed snake
.if REVISION >= 100  ;same effect but simpler
	ldy #<(gs_item_snake - gs_item_locs)
.else ;RETAIL
	ldx #>gs_item_snake
	stx zp0E_item+1
	ldx #<gs_item_snake
	stx zp0E_item
	ldy #$00
.endif
	cmp (zp0E_item),y
	beq @return_item_num

; Box not found
	lda #$00
	rts

@check_level:
	dec zp0E_item
	lda (zp0E_item),y
	sta zp13_level
	inc zp0E_item
	dey
	lda zp13_level
	cmp gs_level
	beq @return_item_num
	iny
	lda zp11_position
	jmp @not_here

@return_item_num:
.if REVISION >= 100
	iny
	iny
	iny
	tya
	lsr
.else ;RETAIL
	clc
	tya
	bpl :+
	lda #$00     ;clamp min 0
:	adc zp0E_item
	sta zp0E_item
	lda #$00
	adc zp0E_item+1
	sta zp0E_item+1
	sec
	lda zp0E_item
	sbc #<gs_item_locs
	clc
	ror
	clc
	adc #$01
.endif
	rts

icmd0C_which_food:
	dec zp1A_cmds_to_check
	bne icmd0D_which_torch_lit
	lda #items_food
	sta zp11_count_which
	lda #carried_known
	sta zp10_which_place
	lda #icmd_where
	sta zp0F_action
	lda #item_food_begin
	sta zp0E_object
find_which_multiple:
	lda zp0F_action
	pha
	lda zp0E_object
	pha
	jsr item_cmd
	lda zp10_which_place
	cmp zp1A_item_place
	beq @found
	pla
	sta zp0E_object
	pla
	sta zp0F_action
	inc zp0E_object
	dec zp11_count_which
	bne find_which_multiple
	lda #$00
	rts

@found:
	pla
	sta zp0E_object
	pla
	lda zp0E_object
	rts

icmd0D_which_torch_lit:
	dec zp1A_cmds_to_check
	bne icmd0E_which_torch_unlit
	lda #items_torches
	sta zp11_count_which
	lda #carried_active
	sta zp10_which_place
	bne set_action
icmd0E_which_torch_unlit:
	dec zp1A_cmds_to_check
	bne icmd_default
	lda #items_torches
	sta zp11_count_which
	lda #carried_known
	sta zp10_which_place
set_action:
	lda #icmd_where
	sta zp0F_action
	lda #item_torch_begin
	sta zp0E_object
	jsr find_which_multiple
icmd_default:
	rts

icmd0A_probe_boxes:
	lda gs_walls_right_depth
	and #%11100000
	lsr
	lsr
	lsr
	lsr
	lsr
	beq @none
	cmp #$05
	bne :+
	sec
	sbc #$01
:	sta zp1A_count_loop
	lda gs_player_x
	sta zp11_pos_x
	lda gs_player_y
	sta zp10_pos_y
	lda gs_level
	sta zp19_level
	jmp @begin_probe

@none:
	lda #$00
	sta gs_box_visible
	rts

@begin_probe:
	lda zp1A_count_loop
	sta zp0F_sight_depth
	lda #$00
	sta zp0E_box_visible
@next_pos:
	lda gs_facing
	jsr move_pos_facing
	jsr any_item_here
	dec zp1A_count_loop
	beq @shift_remainder
	lsr zp0E_box_visible
	jmp @next_pos

@shift_remainder:
	lda #$04
	sec
	sbc zp0F_sight_depth
	beq @done
:	lsr zp0E_box_visible
	sec
	sbc #$01
	bne :-
@done:
	lda zp0E_box_visible
	sta gs_box_visible
	rts

any_item_here:
	pha
	lda zp11_pos_x
	pha
	lda zp10_pos_y
	pha
	lda zp0F_sight_depth
	pha
	lda zp0E_box_visible
	pha
	lda zp11_pos_x
	asl
	asl
	asl
	asl
	clc
	adc zp10_pos_y
	pha
	lda #>(gs_item_locs+1)
	sta zp0E_ptr+1
	lda #<(gs_item_locs+1)
	sta zp0E_ptr
	lda #items_total
	sta zp11_count_loop
	pla
	ldy #$00
@next_item:
	cmp (zp0E_ptr),y
	beq @match_position
@continue:
	iny
	iny
	dec zp11_count_loop
	bne @next_item
	pla
	sta zp0E_box_visible
	pla
	sta zp0F_sight_depth
@done:
	pla
	sta zp10_pos_y
	pla
	sta zp11_pos_x
	pla
	rts

@match_position:
	sta zp10_temp
	dec zp0E_ptr
	lda (zp0E_ptr),y
	inc zp0E_ptr
	cmp zp19_level
	beq @match_level
	lda zp10_temp
	jmp @continue

@match_level:
	pla
	sta zp0E_box_visible
	pla
	sta zp0F_sight_depth
	lda zp0E_box_visible
	clc
	adc #$08
	sta zp0E_box_visible
	bne @done

move_pos_facing:
	cmp #facing_W
	beq @west
	cmp #facing_N
	beq @north
	cmp #facing_E
	beq @east
@south:
	dec zp10_pos_y
	rts

@west:
	dec zp11_pos_x
	rts

@north:
	inc zp10_pos_y
	rts

@east:
	inc zp11_pos_x
	rts

