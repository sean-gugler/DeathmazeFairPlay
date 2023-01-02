	.export draw_special

	.import wait_brief
	.import draw_down_left
	.import draw_down_right
	.import char_out
	.import draw_right
	.import draw_down
	.import print_char
	.import get_rowcol_addr

	.include "apple.i"
	.include "char.i"
	.include "draw.i"
	.include "game_state.i"

zp_col = $06
zp_row = $07

screen_ptr = $08 ;$09

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
zp1A_count_row   = $1A;
zp0F_action      = $0F;

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
	bne @draw_3_compactor

	lda #$03
	sta zp_row
	lda #$05
	sta zp_col
	lda #glyph_R
	ldy #$12
	jsr draw_down
	lda #$03
	sta zp_row
	lda #$0a
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
	jsr draw_right
	lda #$07
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
	lda #$20
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
	lda #$20
	jsr char_out
	inc zp_row
	jsr get_rowcol_addr
	lda #$20
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

	.segment "DATA_PIT_FLOOR"

@pit_floor_data:
	;--- distance 1 (0E = 0)
	.byte $11,$11,$04      ;X,Y,len
	.byte $05,$11,$04      ;X,Y,len
	.byte raster_hi $11,4,0
	.byte raster_lo $11,4,0
	.byte $0d              ;len
	.byte raster_hi $14,0,7
	.byte raster_lo $14,0,7
	.byte $15              ;len
	;--- distance 2 (0E > 0)
	.byte $0e,$0e,$03      ;X,Y,len
	.byte $08,$0e,$03      ;X,Y,len
	.byte raster_hi $0e,7,0
	.byte raster_lo $0e,7,0
	.byte $07              ;len
	.byte raster_hi $10,4,7
	.byte raster_lo $10,4,7
	.byte $0d              ;len

	.segment "DRAW_SPECIAL3"

@draw_4_pit_floor:
	dey
	bne @draw_5_pit_roof

	lda #<@pit_floor_data
	sta zp0A_data_ptr
	lda #>@pit_floor_data
	sta zp0A_data_ptr+1
	lda #$02
	sta zp19_count
	lda zp0E_draw_param
	beq @pit_walls
	ldy #$0c
@pit_walls:
	lda (zp0A_data_ptr),y
	sta zp_col
	iny
	lda (zp0A_data_ptr),y
	sta zp_row
	iny
	lda (zp0A_data_ptr),y
	iny
	sta zp1A_temp  ;GUG: sty/ldy instead of pha/pla? or tya/pha before lda(),y
	tya
	pha
	lda zp1A_temp
	tay
	lda #$02
	clc
	adc zp19_count
	jsr draw_down
	pla
	tay
	dec zp19_count
	bne @pit_walls

	lda #$02
	sta zp19_count
@pit_rim:
	lda (zp0A_data_ptr),y
	sta screen_ptr+1
	iny
	lda (zp0A_data_ptr),y
	sta screen_ptr
	iny
	lda (zp0A_data_ptr),y
	sta zp1A_temp
	iny
	tya
	pha
	lda zp1A_temp
	tay
	jsr draw_right
	pla
	tay
	dec zp19_count
	bne @pit_rim
	rts

;	.segment "DATA_PIT_ROOF"

@pit_roof_data:
	;--- distance 1
	.byte $11,$00,$04      ;X,Y,len
	.byte $05,$00,$04      ;X,Y,len
	.byte raster_hi $00,0,0
	.byte raster_lo $00,0,0
	.byte $15              ;len
	.byte raster_hi $04,4,0
	.byte raster_lo $04,4,0
	.byte $0d              ;len
	;--- distance 2
	.byte $0e,$04,$03      ;X,Y,len
	.byte $08,$04,$03      ;X,Y,len
	.byte raster_hi $04,4,0
	.byte raster_lo $04,4,0
	.byte $0d              ;len
	.byte raster_hi $07,7,0
	.byte raster_lo $07,7,0
	.byte $07              ;len
	;--- distance 3 (0E = 0)
	.byte $0c,$07,$02      ;X,Y,len
	.byte $0a,$07,$02      ;X,Y,len
	.byte raster_hi $07,7,0
	.byte raster_lo $07,7,0
	.byte $07              ;len
	.byte raster_hi $09,9,0
	.byte raster_lo $09,9,0
	.byte $03              ;len

;	.segment "DRAW_SPECIAL4"

@draw_5_pit_roof:
	dey
	bne @draw_6_boxes

	lda #<@pit_roof_data
	sta zp0A_data_ptr
	lda #>@pit_roof_data
	sta zp0A_data_ptr+1
	lda #$02
	sta zp19_count
	ldy zp0E_draw_param
	beq :+
	dey
	beq @pit_walls
	ldy #$0c
	jmp @pit_walls

:	ldy #$18
	jmp @pit_walls

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
	.byte $0b,$09
	.byte $09,$20
@square_data_right:
	.byte $20,$06
	.byte $06,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $0b,$0b
	.byte $08,$0b
	.byte $20,$08

	.segment "STRING_SQUARE"

@string_square:
	.byte "THEPERFECTSQUARE"

	.segment "DRAW_SPECIAL5"

; Input: 0E = 1 right, 2 front, 4 left
@draw_7_the_square:
	dey
	beq :+
	jmp @draw_8_doors

:	lda zp0E_draw_param
	cmp #$01
	beq @square_right
	cmp #$04
	bne @square_front
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
	ldy #$07
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
	lda #$08
	sta zp_col
	lda #$05
	sta zp_row
	jsr get_rowcol_addr
	lda #$07
	sta zp1A_count_loop
	jsr @print_square_row
	lda #$09
	sta zp_col
	lda #$06
	sta zp_row
	jsr get_rowcol_addr
	lda #$06
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
	sta zp_col
	lda #$07
	sta zp_row
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
	sta zp_col
	lda #$07
	sta zp_row
	sta zp1A_count_loop
	jmp @sq_next_row

@draw_8_doors:
	dey
	beq :+
	jmp @draw_9_keyholes

:	lda zp0E_draw_param
	cmp #$04
	bne @door_2_right
	jmp @door_1_left

@door_2_right:
	cmp #$02
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
	jmp draw_A_special

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

draw_A_special:
	lda #$0a
	sta zp_col
	lda #$03
	sta zp_row
;	lda #glyph_L  ;$03, redundant
	ldy #$12
	jsr draw_down
	lda #$0b
	sta zp_col
	lda #$03
	sta zp_row
	lda #glyph_R
	ldy #$12
	jsr draw_down
	lda #raster_hi 17,9,0
	sta screen_ptr+1
	lda #raster_lo 17,9,0
	sta screen_ptr
	ldy #$02
	jsr draw_right
	lda #$0a
	sta zp0C_col_left
	lda #$0b
	sta zp19_col_right
	lda #$04
	sta zp11_count_loop
	lda #$02
	sta zp10_length
@next_frame_opening:
	jsr wait_brief
	lda zp0C_col_left
	sta zp_col
	lda #$03
	sta zp_row
	lda #' '
	ldy #$12
	jsr draw_down
	lda zp19_col_right
	sta zp_col
	lda #$03
	sta zp_row
	lda #' '
	ldy #$12
	jsr draw_down
	dec zp0C_col_left
	inc zp19_col_right
	lda zp0C_col_left
	sta zp_col
	lda #$03
	sta zp_row
;	lda #glyph_L  ;$03, redundant
	ldy #$12
	jsr draw_down
	lda zp19_col_right
	sta zp_col
	lda #$03
	sta zp_row
	lda #glyph_R
	ldy #$12
	jsr draw_down
	lda #$11
	sta zp_row
	dec zp0C_col_left
	lda zp0C_col_left
	inc zp0C_col_left
	sta zp_col
	jsr get_rowcol_addr
	inc zp10_length
	inc zp10_length
	ldy zp10_length
	jsr draw_right
	dec zp11_count_loop
	bne @next_frame_opening
	rts

