	.export draw_special

	.import wait_brief
	.import draw_down_left
	.import draw_down_right
	.import char_out
	.import draw_right
	.import draw_down
	.import print_char
	.import get_rowcol_addr
	.import get_display_string
	.import memcpy
	.import which_door
	.import door_correct
	.importzp doors_locked_begin

	.include "apple.i"
	.include "char.i"
	.include "draw.i"
	.include "game_state.i"

zp_col = $06
zp_row = $07

screen_ptr = $08 ;$09

zp0E_src         = $0E;
zp10_dst         = $10;
zp10_length      = $10;
zp11_count_loop  = $11;
zp19_col_right   = $19;
zp0C_col_left    = $0C;
zp1A_temp        = $1A;
zp0E_draw_param  = $0E;
zp19_count       = $19;
zp0A_data_ptr    = $0A;
zp0C_col_animate = $0C;
zp1A_count_loop  = $1A;
zp19_count_col   = $19;
zp0A_text_ptr    = $0A;
zp0C_string_ptr  = $0C;
zp1A_count_row   = $1A;
zp0F_action      = $0F;
zp19_string      = $19;

	.segment "DATA_KEYHOLE"

	; glyphs for rendering at distance 0
keyhole_0:
	.byte $06,$0b,$0b,$07
	.byte $0b,$0b,$0b,$0b
	.byte $0b,$0b,$0b,$0b
	.byte $0b,$0b,$0b,$0b
	.byte $08,$0b,$0b,$09
	.byte $20,$0b,$0b,$20
	.byte $20,$0b,$0b,$20
	.byte $0b,$0b,$0b,$0b
	.byte $0b,$0b,$0b,$0b

	.segment "DRAW_SPECIAL1"

draw_special:
	ldy zp0F_action
	dey
	bne @draw_2_elevator

@draw_1_keyhole:
	jsr @draw_door_frame

	lda #$06
	sta zp_col
	lda #$0c
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_keyhole_R
	jsr print_char
	lda #glyph_keyhole_L
	jsr print_char

	lda #$09
	sta zp1A_count_row
	sta zp_col
	lda #$06
	sta zp_row
	jsr get_rowcol_addr
	lda #>keyhole_0
	sta zp0A_text_ptr+1
	lda #<keyhole_0
	sta zp0A_text_ptr
	ldy #$00
@next_row:
	lda #$04
	sta zp19_count_col
@next_glyph:
	tya
	pha
	lda (zp0A_text_ptr),y
	jsr print_char
	pla
	tay
	iny
	dec zp19_count_col
	bne @next_glyph
	dec zp1A_count_row
	beq @done
	tya
	pha
	inc zp_row
	dec zp_col
	dec zp_col
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	pla
	tay
	jmp @next_row

@done:
	rts

@draw_2_elevator:
	dey
	beq @draw_midline
	jmp @draw_3_compactor

@draw_door_frame:
	lda #$03
	sta zp_row
	lda #$05
	sta zp_col
	lda #glyph_R
	ldy #$12
	jsr draw_down
	lda #$03
	sta zp_row
	lda #$10
	sta zp_col
	lda #glyph_L
	ldy #$12
	jsr draw_down
	lda #raster_hi 20,0,7
	sta screen_ptr+1
	lda #raster_lo 20,0,7
	sta screen_ptr
	ldy #$14
	jsr draw_right
	lda #raster_lo 2,5,7
	sta screen_ptr
	lda #raster_hi 2,5,7
	sta screen_ptr+1
	ldy #$0a
	jmp draw_right
	;rts

@draw_midline:
	lda #$03
	sta zp_row
	lda #$0a
	sta zp_col
	lda #glyph_R
	ldy #$12
	jsr draw_down

	jsr @draw_door_frame
	lda zp0E_draw_param
	pha
	jsr which_door
	cmp gs_broken_door
	bne @draw_sign
	ldx #$00
@draw_broken:
	stx zp1A_count_row
	lda #$0a
	sta zp_col
	lda @broken_door,x
	sta zp_row
	jsr get_rowcol_addr
	lda @broken_door + 1,x
	jsr print_char
	ldx zp1A_count_row
	inx
	inx
	cpx #@broken_door_end
	bne @draw_broken

@draw_sign:
	pla
	bne :+
	rts
:	lda #$07
	sta zp_col
	lda #$01
	sta zp_row
	jsr get_rowcol_addr
	lda #>@string_elevator
	sta zp0A_text_ptr+1
	lda #<@string_elevator
	sta zp0A_text_ptr
	ldy #$00
	lda #$08
	sta zp1A_count_loop
:	tya
	pha
	lda (zp0A_text_ptr),y
	jsr print_char
	pla
	tay
	iny
	dec zp1A_count_loop
	bne :-
	rts

;	.segment "STRING_ELEVATOR"

@string_elevator:
	.byte "ELEVATOR"

@broken_door:
	.byte $03, glyph_slash_down
	.byte $08, glyph_slash_up
	.byte $09, glyph_slash_down
	.byte $12, glyph_slash_up
	.byte $13, glyph_LR
	.byte $14, glyph_slash_up
@broken_door_end = * - @broken_door

;	.segment "DRAW_SPECIAL2"

@draw_3_compactor:
	dey
	beq :+
	jmp @draw_4_pit_floor

:	lda #$06
	sta zp0C_col_animate
@next_frame_3:
	lda #$00
	sta zp_row
	lda #$06
	sec
	sbc zp0C_col_animate
	sta zp_col
	pha
	lda #' '
	ldy #$15
	jsr draw_down
	pla
	pha
	sta zp_col
	inc zp_col
	lda #$00
	sta zp_row
	lda #glyph_R
	ldy #$15
	jsr draw_down
	pla
	pha
	sta zp_col
	inc zp_col
	inc zp_col
	lda #$01
	sta zp_row
	jsr get_rowcol_addr
	lda #' '
	jsr char_out
	inc zp_row
	jsr get_rowcol_addr
	lda #' '
	jsr char_out
	pla
	sta zp_col
	inc zp_col
	inc zp_col
	lda #$00
	sta zp_row
	ldy #$04
	jsr draw_down_right
	dec zp_col
	dec zp_col
	lda zp_col
	pha
	lda zp_row
	pha
	dec zp_row
	lda #' '
	ldy #$0f
	jsr draw_down
	dec zp_col
	jsr get_rowcol_addr
	lda #' '
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #' '
	jsr char_out
	pla
	sta zp_row
	pla
	sta zp_col
	inc zp_col
	lda #glyph_R
	ldy #$0d
	jsr draw_down
	ldy #$04
	jsr draw_down_left
	lda #$00
	sta zp_row
	lda #$10
	clc
	adc zp0C_col_animate
	sta zp_col
	pha
	lda #' '
	ldy #$15
	jsr draw_down
	pla
	pha
	sta zp_col
	dec zp_col
	lda #$00
	sta zp_row
	lda #glyph_L
	ldy #$15
	jsr draw_down
	pla
	pha
	sta zp_col
	dec zp_col
	dec zp_col
	lda #$01
	sta zp_row
	jsr get_rowcol_addr
	lda #' '
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #' '
	jsr char_out
	pla
	sta zp_col
	dec zp_col
	dec zp_col
	lda #$00
	sta zp_row
	ldy #$04
	jsr draw_down_left
	inc zp_col
	inc zp_col
	lda zp_col
	pha
	lda zp_row
	pha
	dec zp_row
	lda #' '
	ldy #$0f
	jsr draw_down
	inc zp_col
	jsr get_rowcol_addr
	lda #' '
	jsr char_out
	inc zp_row
	jsr get_rowcol_addr
	lda #' '
	jsr char_out
	pla
	sta zp_row
	pla
	sta zp_col
	dec zp_col
	lda #glyph_L
	ldy #$0d
	jsr draw_down
	ldy #$04
	jsr draw_down_right
	dec zp0C_col_animate
	beq :+
	jsr wait_brief
	jmp @next_frame_3

:	rts

	.segment "DATA_PIT"

; Indexed by SIZE, inverse of DISTANCE.
@quadratic_dec:
	.byte $0a,$09,$07,$04,$00
@quadratic_inc:
	.byte $0b,$0c,$0e,$11,$15
@quadratic_len:
	.byte $01,$03,$07,$0d,$15

	.segment "DRAW_SPECIAL3"

@draw_4_pit_floor:
	clc
	dey
	beq @draw_pit

@draw_5_pit_roof:
	sec
	dey
	bne @draw_6_boxes

@draw_pit:
	; RIGHT wall
	ldy zp0E_draw_param
	bmi @tiny_pit
	lda @quadratic_inc,y
	sta zp_col
	iny
	bcc :+
	lda @quadratic_dec,y
:	php
	sta zp_row
	pha
	lda #glyph_R
	jsr draw_down

	; LEFT wall
	pla
	sta zp_row
	pha
	lda #glyph_L
	ldy zp0E_draw_param
	bne :+
	lda #glyph_LR
:	ldx @quadratic_dec,y
	inx
	stx zp_col
	iny
	jsr draw_down

	; UPPER rim
	pla
	sta zp_row
	plp
	php
	bcs :+
	ldx zp0E_draw_param
	lda @quadratic_dec,x
:	sta zp_col
	jsr get_rowcol_addr
	ldx zp0E_draw_param
	plp
	php
	bcc :+
	inx
:	ldy @quadratic_len,x
	jsr draw_right

	; LOWER rim
	plp
	bcs :+
	inc zp0E_draw_param
:	ldx zp0E_draw_param
	ldy @quadratic_dec,x
	sty zp_col
	bcs :+
	ldy @quadratic_inc,x
:	dey
	sty zp_row
	jsr get_rowcol_addr
	lda #$1c  ;raster 7 of this char row
	clc
	adc screen_ptr + 1
	sta screen_ptr + 1
	ldx zp0E_draw_param
	ldy @quadratic_len,x
	jsr draw_right
	
	rts

; Assigned to symbols instead of inline to avoid
; compiler errors with addressing mode,
; since macro expands wrapped in parentheses.
@tiny_roof  = raster $0a,$0b,0
@tiny_floor = raster $0a,$0b,7

@tiny_pit:
	lda #$ff
	bcc :+
	sta @tiny_roof
	rts
:	sta @tiny_floor
	rts


@draw_6_boxes:
	dey
	beq @draw_box_4
	jmp @draw_7_the_square

@draw_box_4:
	lda gs_box_visible
	and #(1 << 3)
	beq @draw_box_3
	lda #$0b
	sta zp_col
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_box
	jsr char_out
@draw_box_3:
	lda gs_box_visible
	and #(1 << 2)
	beq @draw_box_2
	lda #$0a
	sta zp_col
	lda #$0c
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_box_TL
	jsr char_out
	lda #glyph_box_T
	jsr char_out
	lda #glyph_box_TR
	jsr char_out
	lda #$0a
	sta zp_col
	lda #$0d
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_box_BL
	jsr char_out
	lda #glyph_box_B
	jsr char_out
	lda #glyph_box_BR
	jsr char_out
@draw_box_2:
	lda gs_box_visible
	and #(1 << 1)
	beq @draw_box_1
	lda #$09
	sta zp_col
	lda #$0e
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_box_TL
	jsr char_out
	lda #glyph_box_T
	jsr char_out
	lda #glyph_box_T
	jsr char_out
	lda #glyph_box_T
	jsr char_out
	lda #glyph_box_TR
	jsr char_out
	lda #$09
	sta zp_col
	lda #$0f
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_L
	jsr char_out
	inc zp_col
	inc zp_col
	inc zp_col
	jsr get_rowcol_addr
	lda #glyph_box_R
	jsr char_out
	dec zp_col
	inc zp_row
	jsr get_rowcol_addr
	lda #glyph_box_BR
	jsr char_out
	lda #$09
	sta zp_col
	jsr get_rowcol_addr
	lda #glyph_L
	jsr char_out
	lda #>raster $11,8,0
	sta screen_ptr+1
	lda #<raster $11,8,0
	sta screen_ptr
	ldy #$04
	jsr draw_right
@draw_box_1:
	lda gs_box_visible
	and #(1 << 0)
	beq @box_done
	lda #$0e
	sta zp_col
	lda #$11
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_slash_up
	jsr char_out
	lda #$07
	sta zp_col
	jsr get_rowcol_addr
	ldy #$07
	jsr draw_right
	lda #glyph_slash_up
	jsr char_out
	lda #$06
	sta zp_col
	lda #$12
	sta zp_row
	lda #glyph_R
	ldy #$03
	jsr draw_down
	lda #$0d
	sta zp_col
	lda #$12
	sta zp_row
	lda #glyph_R
	ldy #$03
	jsr draw_down
	dec zp_row
	inc zp_col
	jsr get_rowcol_addr
	lda #glyph_slash_up
	jsr char_out
	lda #raster_hi 18,6,0
	sta screen_ptr+1
	lda #raster_lo 18,6,0
	sta screen_ptr
	ldy #$07
	jsr draw_right
	lda #$0f
	sta zp_col
	lda #$11
	sta zp_row
	lda #glyph_L
	tay
	jsr draw_down
	ldx #raster_hi 20,6,7
	stx screen_ptr+1
	ldx #raster_lo 20,6,7
	stx screen_ptr
	ldy #$07
	jsr draw_right
@box_done:
	rts

	.segment "DATA_SQUARE"

	; glyphs for rendering on side walls at distance 1
@square_data_left:
	.byte $07,$20
	.byte $0b,$07
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$09
	.byte $09,$20
@square_data_right:
	.byte $20,$06
	.byte $06,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $08,$0b
	.byte $20,$08

	.segment "STRING_SQUARE"

@string_square:
	.byte "THEMAGICDOOR!"

	.segment "DRAW_SPECIAL5"

; Input: 0E = 0 front, 1 right(1), 2 right(2), 4 left(1)
@draw_7_the_square:
	dey
	beq @square_open
	jmp @draw_8_doors

@square_open:
	lda #maze_flag_door_painted
	and gs_maze_flags
	beq @square_closed
	iny
	lda zp0E_draw_param
	bne :+
	jmp @draw_2_elevator
:	jmp @draw_8_doors

@square_closed:
	lda zp0E_draw_param
	beq @square_front
	cmp #$01
	beq @square_right
;	cmp #$04
	jmp @square_left

@square_front:
	lda #$08
	sta zp_col
	pha
	lda #$07
	sta zp_row
	pha
@sq_next_col:
	lda #glyph_solid
	ldy #$0e
	jsr draw_down
	pla
	sta zp_row
	pla
	sta zp_col
	inc zp_col
	lda zp_col
	cmp #$0f
	beq @sq_sign
	pha
	lda zp_row
	pha
	jmp @sq_next_col

@sq_sign:
	lda #<@string_square
	sta zp0A_text_ptr
	lda #>@string_square
	sta zp0A_text_ptr+1
	lda #$0a
	sta zp_col
	lda #$04
	sta zp_row
	jsr get_rowcol_addr
	lda #$03
	sta zp1A_count_loop
	jsr @print_square_row
	lda #$09
	sta zp_col
	lda #$05
	sta zp_row
	jsr get_rowcol_addr
	lda #$05
	sta zp1A_count_loop
	jsr @print_square_row
	lda #$09
	sta zp_col
	lda #$06
	sta zp_row
	jsr get_rowcol_addr
	lda #$05
	sta zp1A_count_loop
@print_square_row:
	ldy #$00
	lda (zp0A_text_ptr),y
	jsr char_out
	inc zp0A_text_ptr
	bne :+
	inc zp0A_text_ptr+1
:	dec zp1A_count_loop
	bne @print_square_row
	rts

@square_right:
	lda #<@square_data_right
	sta zp0A_text_ptr
	lda #>@square_data_right
	sta zp0A_text_ptr+1
	lda #$13
@sq_side:
	sta zp_col
	lda #$07
	sta zp_row
	lda #$0d
	sta zp1A_count_loop
@sq_next_row:
	jsr get_rowcol_addr
	ldy #$00
	lda (zp0A_text_ptr),y
	jsr char_out
	inc zp0A_text_ptr
	bne :+
	inc zp0A_text_ptr+1
:	ldy #$00
	lda (zp0A_text_ptr),y
	jsr char_out
	inc zp0A_text_ptr
	bne :+
	inc zp0A_text_ptr+1
:	inc zp_row
	dec zp_col
	dec zp_col
	dec zp1A_count_loop
	bne @sq_next_row
	rts

@square_left:
	lda #<@square_data_left
	sta zp0A_text_ptr
	lda #>@square_data_left
	sta zp0A_text_ptr+1
	lda #$02
	jmp @sq_side


; Input: 0E = 1 right(1), 2 right(2), 4 left(1)
@draw_8_doors:
	dey
	beq :+
	jmp @draw_9_keyholes

:	lda zp0E_draw_param
	cmp #$04
	bne @door_2_right
	jmp @door_1_left

@door_2_right:
	cmp #$01
	beq @door_1_right
	lda #$10
	sta zp_col
	lda #$08
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_slash_up_C
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	lda #glyph_LR
	ldy #$05
	jsr draw_down
	jsr get_rowcol_addr
	lda #glyph_slash_down_R
	jsr char_out
	inc zp_row
	jsr get_rowcol_addr
	lda #glyph_slash_down_C
	jsr char_out
	lda #$10
	sta zp_col
	lda #$09
	sta zp_row
	lda #glyph_C
	ldy #$06
	jsr draw_down
	lda #$11
	sta zp_col
	lda #$08
	sta zp_row
	lda #glyph_L
	ldy #$08
	jsr draw_down
	rts

@door_1_right:
	lda #$14
	sta zp_col
	lda #$04
	sta zp_row
	ldy #$02
	jsr draw_down_left
	inc zp_col
	lda #glyph_L
	ldy #$0c
	jsr draw_down
	lda #$14
	sta zp_col
	lda #$05
	sta zp_row
	lda #glyph_L
	ldy #$0e
	jsr draw_down
	lda #$15
	sta zp_col
	lda #$04
	sta zp_row
	lda #glyph_L
	ldy #$10
	jsr draw_down
	rts

@door_1_left:
	lda #$02
	sta zp_col
	lda #$04
	sta zp_row
	ldy #$02
	jsr draw_down_right
	dec zp_col
	lda #glyph_R
	ldy #$0c
	jsr draw_down
	lda #$02
	sta zp_col
	lda #$05
	sta zp_row
	lda #glyph_R
	ldy #$0e
	jsr draw_down
	lda #$01
	sta zp_col
	lda #$04
	sta zp_row
;	lda #glyph_R  ;$04, redundant
	ldy #$10
	jsr draw_down
	rts

@draw_9_keyholes:
	dey
	beq :+
	jmp draw_A_door_opening

:	lda zp0E_draw_param
	and #$0f
	beq @keyhole_L_1
@keyhole_R_4:
	and #(1 << 3)
	beq @keyhole_R_3
	lda #$0c
	sta zp_col
	jsr draw_keyhole_4
@keyhole_R_3:
	lda zp0E_draw_param
	and #(1 << 2)
	beq @keyhole_R_2
	lda #$0d
	sta zp_col
	jsr draw_keyhole_3
@keyhole_R_2:
	lda zp0E_draw_param
	and #(1 << 1)
	beq @keyhole_R_1
	lda #$0f
	sta zp_col
	jsr draw_keyhole_2
@keyhole_R_1:
	lda zp0E_draw_param
	and #(1 << 0)
	beq @keyhole_R_done
	lda #$13
	sta zp_col
	jsr draw_keyhole_1
@keyhole_R_done:
	rts

@keyhole_L_1:
	lda zp0E_draw_param
	and #(1 << 4)
	beq @keyhole_L_2
	lda #$02
	sta zp_col
	jsr draw_keyhole_1
@keyhole_L_2:
	lda zp0E_draw_param
	and #(1 << 5)
	beq @keyhole_L_3
	lda #$05
	sta zp_col
	jsr draw_keyhole_2
@keyhole_L_3:
	lda zp0E_draw_param
	and #(1 << 6)
	beq @keyhole_L_4
	lda #$08
	sta zp_col
	jsr draw_keyhole_3
@keyhole_L_4:
	lda zp0E_draw_param
	and #(1 << 7)
	beq @keyhole_L_done
	lda #$0a
	sta zp_col
	jsr draw_keyhole_4
@keyhole_L_done:
	rts

draw_keyhole_1:
	lda #$08
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_solid_BR
	jsr char_out
	lda #glyph_solid_BL
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #glyph_solid
	jsr char_out
	lda #glyph_solid
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #glyph_solid_TR
	jsr char_out
	lda #glyph_solid_TL
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #glyph_angle_BR
	jsr char_out
	lda #glyph_angle_BL
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #glyph_solid
	jsr char_out
	lda #glyph_solid
	jsr char_out
	rts

draw_keyhole_2:
	lda #$09
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_R_notched
	jsr print_char
	lda #glyph_solid
	jsr char_out
	lda #glyph_L_notched
	jsr char_out
	inc zp_row
	dec zp_col
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #glyph_UR_triangle
	jsr print_char
	lda #glyph_solid
	jsr char_out
	lda #glyph_UL_triangle
	jsr print_char
	inc zp_row
	dec zp_col
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #glyph_R_solid
	jsr char_out
	lda #glyph_solid
	jsr char_out
	lda #glyph_L_solid
	jsr char_out
	rts

draw_keyhole_3:
	lda #$0a
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_keyhole_R
	jsr char_out
	lda #glyph_keyhole_L
	jsr char_out
	rts

draw_keyhole_4:
	lda #$0a
	sta zp_row
	jsr get_rowcol_addr
	lda #glyph_keyhole_C
	jsr char_out
	rts

draw_A_door_opening:
	dey
	beq :+
	jmp draw_B_rod

:	jsr prepare_reveal_buffer
	lda #$0a
	sta zp0C_col_left
	lda #$0b
	sta zp19_col_right
	lda #$06
	sta zp11_count_loop
	lda #$00
	sta zp10_length
	beq @start_frame_opening

@next_frame_opening:
	jsr wait_brief
	ldx zp0C_col_left
	jsr draw_down_reveal
	ldx zp19_col_right
	jsr draw_down_reveal
	dec zp0C_col_left
	inc zp19_col_right

@start_frame_opening:
	lda zp0C_col_left
	sta zp_col
	lda #$03
	sta zp_row
	lda #glyph_R
	ldy #$12
	jsr draw_down
	lda zp19_col_right
	sta zp_col
	lda #$03
	sta zp_row
;	lda #glyph_L  ;$03, redundant
	ldy #$12
	jsr draw_down
	lda #$11
	sta zp_row

	lda zp0C_col_left
	sta zp_col
	jsr get_rowcol_addr
	ldy zp10_length
	beq :+
	jsr draw_right
:	lda #$14
	sta zp_row

	lda zp0C_col_left
	sta zp_col
	dec zp_col
	jsr get_rowcol_addr

	lda screen_ptr+1
	clc
	adc #$1c
	sta screen_ptr+1

	inc zp10_length
	inc zp10_length
	ldy zp10_length
	jsr draw_right
	dec zp11_count_loop
;	bpl @next_frame_opening
	bne @next_frame_opening
@done:
	rts

draw_down_reveal:
	stx zp_col
	lda #$03
	sta zp_row
	lda #$12
	sta zp1A_count_loop
	clc
	lda #<(reveal_buffer - 6)
	adc zp_col
	sta zp0A_text_ptr
	lda #>reveal_buffer
	sta zp0A_text_ptr + 1
@next:
	jsr get_rowcol_addr
	ldy #$00
	lda (zp0A_text_ptr),y
	jsr print_char
	clc
	lda #$0a
	adc zp0A_text_ptr
	sta zp0A_text_ptr
	dec zp_col
	inc zp_row
	dec zp1A_count_loop
	bne @next
@done:
	rts

prepare_reveal_buffer:
	lda #' '
	ldy #$00
:	sta reveal_buffer,y
	iny
	bne :-

	lda gs_level
	cmp #$05
	beq :+
	rts
:	lda gs_player_y

reveal_key_hint:
	cmp #$05
	bne reveal_exit

	lda #<key_hint_text
	sta zp0C_string_ptr
	lda #>key_hint_text
	sta zp0C_string_ptr + 1
	lda #<reveal_buffer + 61 ;10*row+col
	sta zp0A_text_ptr
	lda #>reveal_buffer
	sta zp0A_text_ptr + 1

	ldx #$03
@next:
	ldy #$07
:	lda (zp0C_string_ptr),y
	sta (zp0A_text_ptr),y
	dey
	bpl :-
	clc
	lda zp0C_string_ptr
	adc #$08
	sta zp0C_string_ptr
	lda zp0A_text_ptr
	adc #$0a
	sta zp0A_text_ptr
	dex
	bne @next

	iny
	clc
	lda door_correct
	bne @mark_correct
	ldx zp_RND
:	txa
	ror
	tax
	and #$07
	cmp #$05
	bcs :-
	adc #doors_locked_begin
	sta door_correct
@mark_correct:
	adc #<(reveal_buffer + 82 - doors_locked_begin) ;10*row+col
	sta zp0A_text_ptr
	lda #'!'
	sta (zp0A_text_ptr),y
	rts

reveal_exit:
	cmp #$0a
	bne reveal_escape

	lda #>reveal_buffer
	sta zp0A_text_ptr + 1
	lda #<reveal_buffer + 63 ;10*row+col
	sta zp0A_text_ptr
	lda #$cc     ;EXIT

	sta zp19_string
	jsr get_display_string
	ldy #$03
:	lda (zp0C_string_ptr),y
	and #$7F
	sta (zp0A_text_ptr),y
	dey
	bpl :-

	lda #<reveal_buffer + 80 ;10*row+col
	sta zp0A_text_ptr
	lda #$04
	sta zp1A_count_loop

@next:
	inc zp19_string
	lda zp0A_text_ptr
	clc
	adc #$0a
	sta zp0A_text_ptr

	lda zp19_string
	jsr get_display_string
	inc zp0C_string_ptr
	inc zp0C_string_ptr
	inc zp0C_string_ptr
	ldy #$09
:	lda (zp0C_string_ptr),y
	sta (zp0A_text_ptr),y
	dey
	bpl :-

	dec zp1A_count_loop
	bne @next
reveal_done:
	rts

reveal_escape:
	cmp #$0b
	bne reveal_done

	lda #<escape_data
	sta zp0E_src
	lda #>escape_data
	sta zp0E_src + 1
	lda #<reveal_buffer
	sta zp10_dst
	lda #>reveal_buffer
	sta zp10_dst + 1
	lda #180
	sta zp19_count
	lda #$00
	sta zp19_count + 1
	jmp memcpy


draw_B_rod:
	lda #$0b
	sta zp_col
	lda #$01
	sta zp_row
	lda #glyph_box_R
	ldy #$04
	jsr draw_down
	jsr get_rowcol_addr
	lda #glyph_box_BR
	jsr char_out
	rts

	.segment "REVEAL_TEXT"

key_hint_text:
	.byte "WILL YOU"
	.byte "TRUST ME"
	.byte " ?????  "

escape_data:
	.byte $20,$20,$20,$20,$20,$20,$20,$0B,$0B,$0B
	.byte $01,$20,$20,$20,$20,$20,$20,$08,$0B,$7F
	.byte $20,$01,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$01,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$01,$20,$20,$20,$76,$20,$20,$20
	.byte $01,$20,$01,$01,$20,$20,$20,$76,$20,$20
	.byte $1B,$01,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $1B,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $1B,$20,$20,$20,$20,$20,$20,$20,$20,$02
	.byte $1B,$20,$20,$20,$20,$20,$02,$01,$02,$20
	.byte $1B,$20,$20,$20,$20,$02,$20,$20,$01,$20
	.byte $1B,$20,$20,$20,$02,$20,$20,$20,$20,$20
	.byte $1B,$20,$20,$02,$20,$20,$20,$20,$02,$01
	.byte $1B,$20,$02,$20,$20,$20,$20,$20,$20,$1B
	.byte $1B,$20,$20,$02,$20,$20,$01,$20,$20,$1B
	.byte $1B,$20,$02,$20,$20,$20,$20,$01,$20,$20
	.byte $20,$02,$20,$20,$20,$20,$20,$20,$01,$20
	.byte $02,$20,$20,$20,$20,$20,$20,$20,$20,$01

	.segment "DOOR_REVEAL_BUFFER"

reveal_buffer:
	.res $140
