	.segment "DRAW_MAZE"

clear_maze_window:
	lda #$00
	sta zp_col
	lda #$14
	sta zp_row
@clear_row:
	jsr get_rowcol_addr
	clc
	lda #$08
	sta zp19_count_raster
@clear_raster:
	lda #$00
	ldy #$16
:	sta (screen_ptr),y
	dey
	bpl :-
	lda #$04
	adc screen_ptr+1
	sta screen_ptr+1
	dec zp19_count_raster
	bne @clear_raster
	dec zp_row
	bpl @clear_row
	rts

draw_maze:
	lda gs_walls_right_depth
	lsr
	lsr
	lsr
	lsr
	lsr
	pha          ;Top 3 bits = Depth
	cmp #$05
	bcc @draw_4_center
	lda #raster_lo 10,11,0
	sta screen_ptr
	lda #raster_hi 10,11,0
	sta screen_ptr+1
	lda #glyph_X
	jsr char_out
	jmp @draw_4_left

@draw_4_center:
	cmp #$04
	bne @draw_3_center
	lda #raster_lo 10,10,0
	sta screen_ptr
	lda #raster_hi 10,10,0
	sta screen_ptr+1
	ldy #$01
	jsr draw_right
	lda #raster_hi 10,10,7
	sta screen_ptr+1
	ldy #$01
	jsr draw_right
	jmp @draw_4_left

@draw_3_center:
	cmp #$03
	bne @draw_2_center
	lda #raster_hi 9,9,0
	sta screen_ptr+1
	lda #raster_lo 9,9,0
	sta screen_ptr
	ldy #$03
	jsr draw_right
	lda #raster_hi 11,9,7
	sta screen_ptr+1
	ldy #$03
	jsr draw_right
	jmp @draw_3_left

@draw_2_center:
	cmp #$02
	bne @draw_1_center
	lda #raster_hi 7,7,0
	sta screen_ptr+1
	lda #raster_lo 7,7,0
	sta screen_ptr
	ldy #$07
	jsr draw_right
	lda #raster_hi 13,7,7
	sta screen_ptr+1
	lda #raster_lo 13,7,7
	sta screen_ptr
	ldy #$07
	jsr draw_right
	jmp @draw_2_left

@draw_1_center:
	cmp #$01
	bne @draw_0_center
	lda #raster_hi 4,4,0
	sta screen_ptr+1
	lda #raster_lo 4,4,0
	sta screen_ptr
	ldy #$0d
	jsr draw_right
	lda #raster_hi 16,4,7
	sta screen_ptr+1
	lda #raster_lo 16,4,7
	sta screen_ptr
	ldy #$0d
	jsr draw_right
	jmp @draw_1_left

@draw_0_center:
	lda #raster_hi 0,0,0
	sta screen_ptr+1
	lda #raster_lo 0,0,0
	sta screen_ptr
	ldy #$15
	jsr draw_right
	lda #raster_hi 20,0,7
	sta screen_ptr+1
	lda #raster_lo 20,0,7
	sta screen_ptr
	ldy #$15
	jsr draw_right
	jmp @draw_0_left

@draw_4_left:
	lda gs_walls_left
	and #(1 << 4)
	bne @draw_4_left_wall
@draw_4_left_open:
	pla
	pha
	cmp #$04
	beq :+
	lda #raster_hi 10,10,0
	sta screen_ptr+1
	lda #raster_lo 10,10,0
	sta screen_ptr
	lda #glyph_R
	jsr char_out
:	lda #raster_hi 10,9,0
	sta screen_ptr+1
	lda #raster_lo 10,9,0
	sta screen_ptr
	ldy #$01
	jsr draw_right
	lda #raster_hi 10,9,7
	sta screen_ptr+1
	ldy #$01
	jsr draw_right
	lda #$09
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$03
	jsr draw_down
	jmp @draw_4_right

@draw_4_left_wall:
	pla
	pha
	cmp #$04
	bne :+
	lda #raster_hi 10,10,0
	sta screen_ptr+1
	lda #raster_lo 10,10,0
	sta screen_ptr
	lda #glyph_R
	jsr char_out
:	lda #$0a
	sta zp_col
	lda #$09
	sta zp_row
	ldy #$01
	jsr draw_down_right
	dec zp_col
	inc zp_row
	ldy #$01
	jsr draw_down_left
@draw_4_right:
	lda gs_walls_right_depth
	and #(1 << 4)
	bne @draw_4_right_wall
@draw_4_right_open:
	pla
	pha
	cmp #$04
	beq :+
	lda #raster_hi 10,12,0
	sta screen_ptr+1
	lda #raster_lo 10,12,0
	sta screen_ptr
	lda #glyph_L
	jsr char_out
:	lda #raster_hi 10,11,0
	sta screen_ptr+1
	lda #raster_lo 10,11,0
	sta screen_ptr
	ldy #$01
	jsr draw_right
	lda #raster_hi 10,11,7
	sta screen_ptr+1
	ldy #$01
	jsr draw_right
	lda #$0d
	sta zp_col
	lda #$09
	sta zp_row
	lda #glyph_L
	ldy #$03
	jsr draw_down
	jmp @draw_3_left

@draw_4_right_wall:
	pla
	pha
	cmp #$04
	bne :+
	lda #raster_hi 10,12,0
	sta screen_ptr+1
	lda #raster_lo 10,12,0
	sta screen_ptr
	lda #glyph_L
	jsr char_out
:	lda #$0c
	sta zp_col
	lda #$09
	sta zp_row
	ldy #$01
	jsr draw_down_left
	inc zp_col
	inc zp_row
	ldy #$01
	jsr draw_down_right
@draw_3_left:
	lda gs_walls_left
	and #(1 << 3)
	bne @draw_3_left_wall
@draw_3_left_open:
	pla
	pha
	cmp #$03
	beq :+
	lda #$09
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$03
	jsr draw_down
:	lda #raster_hi 9,7,0
	sta screen_ptr+1
	lda #raster_lo 9,7,0
	sta screen_ptr
	ldy #$02
	jsr draw_right
	lda #raster_hi 11,7,7
	sta screen_ptr+1
	lda #raster_lo 11,7,7
	sta screen_ptr
	ldy #$02
	jsr draw_right
	lda #$07
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$07
	jsr draw_down
	jmp @draw_3_right

@draw_3_left_wall:
	pla
	pha
	cmp #$03
	bne :+
	lda #$09
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$03
	jsr draw_down
:	lda #$08
	sta zp_col
	lda #$07
	sta zp_row
	ldy #$02
	jsr draw_down_right
	lda #$09
	sta zp_col
	lda #$0c
	sta zp_row
	ldy #$02
	jsr draw_down_left
@draw_3_right:
	lda gs_walls_right_depth
	and #(1 << 3)
	bne @draw_3_right_wall
@draw_3_right_open:
	pla
	pha
	cmp #$03
	beq :+
	lda #$0d
	sta zp_col
	lda #$09
	sta zp_row
	lda #glyph_L
	ldy #$03
	jsr draw_down
:	lda #raster_hi 9,12,0
	sta screen_ptr+1
	lda #raster_lo 9,12,0
	sta screen_ptr
	ldy #$02
	jsr draw_right
	lda #raster_hi 11,12,7
	sta screen_ptr+1
	lda #raster_lo 11,12,7
	sta screen_ptr
	ldy #$02
	jsr draw_right
	lda #$0f
	sta zp_col
	lda #$07
	sta zp_row
	lda #glyph_L
	ldy #$07
	jsr draw_down
	jmp @draw_2_left

@draw_3_right_wall:
	pla
	pha
	cmp #$03
	bne :+
	lda #$0d
	sta zp_col
	lda #$09
	sta zp_row
	lda #glyph_L
	ldy #$03
	jsr draw_down
:	lda #$0e
	sta zp_col
	lda #$07
	sta zp_row
	ldy #$02
	jsr draw_down_left
	lda #$0d
	sta zp_col
	lda #$0c
	sta zp_row
	ldy #$02
	jsr draw_down_right
@draw_2_left:
	lda gs_walls_left
	and #(1 << 2)
	bne @draw_2_left_wall
	pla
	pha
	cmp #$02
	beq :+
	lda #$07
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$07
	jsr draw_down
:	lda #raster_hi 7,4,0
	sta screen_ptr+1
	lda #raster_lo 7,4,0
	sta screen_ptr
	ldy #$03
	jsr draw_right
	lda #raster_hi 13,4,7
	sta screen_ptr+1
	lda #raster_lo 13,4,7
	sta screen_ptr
	ldy #$03
	jsr draw_right
	lda #$04
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$0d
	jsr draw_down
	jmp @draw_2_right

@draw_2_left_wall:
	pla
	pha
	cmp #$02
	bne :+
	lda #$07
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$07
	jsr draw_down
:	lda #$05
	sta zp_col
	lda #$04
	sta zp_row
	ldy #$03
	jsr draw_down_right
	lda #$07
	sta zp_col
	lda #$0e
	sta zp_row
	ldy #$03
	jsr draw_down_left
@draw_2_right:
	lda gs_walls_right_depth
	and #(1 << 2)
	bne @draw_2_right_wall
@draw_2_right_open:
	pla
	pha
	cmp #$02
	beq :+
	lda #$0f
	sta zp_col
	lda #$07
	sta zp_row
	lda #glyph_L
	ldy #$07
	jsr draw_down
:	lda #raster_hi 7,14,0
	sta screen_ptr+1
	lda #raster_lo 7,14,0
	sta screen_ptr
	ldy #$03
	jsr draw_right
	lda #raster_hi 13,14,7
	sta screen_ptr+1
	lda #raster_lo 13,14,7
	sta screen_ptr
	ldy #$03
	jsr draw_right
	lda #$12
	sta zp_col
	lda #$04
	sta zp_row
	lda #glyph_L
	ldy #$0d
	jsr draw_down
	jmp @draw_1_left

@draw_2_right_wall:
	pla
	pha
	cmp #$02
	bne :+
	lda #$0f
	sta zp_col
	lda #$07
	sta zp_row
	lda #glyph_L
	ldy #$07
	jsr draw_down
:	lda #$11
	sta zp_col
	lda #$04
	sta zp_row
	ldy #$03
	jsr draw_down_left
	lda #$0f
	sta zp_col
	lda #$0e
	sta zp_row
	ldy #$03
	jsr draw_down_right
@draw_1_left:
	lda gs_walls_left
	and #(1 << 1)
	bne @draw_1_left_wall
@draw_1_left_open:
	pla
	pha
	cmp #$01
	beq :+
	lda #$04
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$0d
	jsr draw_down
:	lda #raster_hi 4,0,0
	sta screen_ptr+1
	lda #raster_lo 4,0,0
	sta screen_ptr
	ldy #$04
	jsr draw_right
	lda #raster_hi 16,0,7
	sta screen_ptr+1
	lda #raster_lo 16,0,7
	sta screen_ptr
	ldy #$04
	jsr draw_right
	lda #$00
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$15
	jsr draw_down
	jmp @draw_1_right

@draw_1_left_wall:
	pla
	pha
	cmp #$01
	bne :+
	lda #$04
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$0d
	jsr draw_down
:	lda #$01
	sta zp_col
	lda #$00
	sta zp_row
	ldy #$04
	jsr draw_down_right
	lda #$04
	sta zp_col
	lda #$11
	sta zp_row
	ldy #$04
	jsr draw_down_left
@draw_1_right:
	lda gs_walls_right_depth
	and #(1 << 1)
	bne @draw_1_right_wall
@draw_1_right_open:
	pla
	pha
	cmp #$01
	beq :+
	lda #$12
	sta zp_col
	lda #$04
	sta zp_row
	lda #glyph_L
	ldy #$0d
	jsr draw_down
:	lda #raster_hi 4,17,0
	sta screen_ptr+1
	lda #raster_lo 4,17,0
	sta screen_ptr
	ldy #$04
	jsr draw_right
	lda #raster_hi 16,17,7
	sta screen_ptr+1
	lda #raster_lo 16,17,7
	sta screen_ptr
	ldy #$04
	jsr draw_right
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #glyph_L
	ldy #$15
	jsr draw_down
	jmp @draw_0_left

@draw_1_right_wall:
	pla
	pha
	cmp #$01
	bne :+
	lda #$12
	sta zp_col
	lda #$04
	sta zp_row
	lda #glyph_L
	ldy #$0d
	jsr draw_down
:	lda #$15
	sta zp_col
	lda #$00
	sta zp_row
	ldy #$04
	jsr draw_down_left
	lda #$12
	sta zp_col
	lda #$11
	sta zp_row
	ldy #$04
	jsr draw_down_right
@draw_0_left:
	pla
	cmp #$00
	beq @draw_0_left_wall
	lda gs_walls_left
	and #(1 << 0)
	bne @draw_0_right
@draw_0_left_open:
	lda #$00
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$15
	jsr draw_down
	lda #raster_hi 0,-1,0
	sta screen_ptr+1
	lda #raster_lo 0,-1,0
	sta screen_ptr
	ldy #$01
	jsr draw_right
	lda #raster_hi 20,-1,7
	sta screen_ptr+1
	lda #raster_lo 20,-1,7
	sta screen_ptr
	ldy #$01
	jsr draw_right
@draw_0_right:
	lda gs_walls_right_depth
	and #(1 << 0)
	bne @draw_0_done
@draw_0_right_open:
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #glyph_L
	ldy #$15
	jsr draw_down
	lda #raster_hi 0,21,0
	sta screen_ptr+1
	lda #raster_lo 0,21,0
	sta screen_ptr
	ldy #$01
	jsr draw_right
	lda #raster_hi 20,21,7
	sta screen_ptr+1
	lda #raster_lo 20,21,7
	sta screen_ptr
	ldy #$01
	jsr draw_right
@draw_0_done:
	rts

@draw_0_left_wall:
	lda gs_walls_left
	and #(1 << 0)
	beq @draw_0_right_wall
	lda #$00
	sta zp_col
	sta zp_row
	lda #glyph_R
	ldy #$15
	jsr draw_down
@draw_0_right_wall:
	lda gs_walls_right_depth
	and #(1 << 0)
	beq @draw_0_done
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #glyph_L
	ldy #$15
	jsr draw_down
	rts

draw_right:
	lda #$ff
:	sta (screen_ptr),y
	dey
	bne :-
	rts

; Input: Y=count
draw_down_left:
	tya
	sta zp1A_count_loop
:	jsr get_rowcol_addr
	lda #glyph_slash_up
	jsr char_out
	dec zp_col
	dec zp_col
	inc zp_row
	dec zp1A_count_loop
	bne :-
	rts

; Input: Y=count
draw_down_right:
	tya
	sta zp1A_count_loop
:	jsr get_rowcol_addr
	lda #glyph_slash_down
	jsr char_out
	inc zp_row
	dec zp1A_count_loop
	bne :-
	rts

; Input: A=char Y=count
draw_down:
	pha
	tya
	sta zp1A_count_loop
	pla
@next:
	pha
	jsr get_rowcol_addr
	pla
	pha
	jsr print_char
	pla
	dec zp_col
	inc zp_row
	dec zp1A_count_loop
	bne @next
	rts

probe_forward:
	ldy #$00
	lda #<maze_walls
	sta zp0A_walls_ptr
	lda #>maze_walls
	sta zp0A_walls_ptr+1
	ldx gs_level
	lda #$00
	clc
:	dex
	beq @find_x
	adc #$21
	jmp :-

@find_x:
	adc zp0A_walls_ptr
	sta zp0A_walls_ptr
	ldx gs_player_x
:	dex
	beq @find_y
	inc zp0A_walls_ptr
	inc zp0A_walls_ptr
	inc zp0A_walls_ptr
	jmp :-

@find_y:
	lda gs_player_y
	cmp #$05
	bmi @find_2bits  ;GUG: bcc preferred
	cmp #$09
	bmi @shift_1_byte  ;GUG: bcc preferred
@shift_2_bytes:
	inc zp0A_walls_ptr
	sec
	sbc #$04
@shift_1_byte:
	inc zp0A_walls_ptr
	sec
	sbc #$04
@find_2bits:
	tax
	lda #$80
:	dex
	beq @check_facing
	lsr
	lsr
	jmp :-

@check_facing:
	sta zp1A_wall_bit
	stx zp19_sight_depth
	stx zp11_count
	stx gs_walls_left
	stx gs_walls_right_depth
	ldx gs_facing
	dex
	bne :+
	jmp probe_west

:	dex
	bne :+
	jmp probe_north

:	dex
	beq probe_east

probe_south:
	lda (zp0A_walls_ptr),y
	and zp1A_wall_bit
	bne @S_sight_limit
	inc zp19_sight_depth
	lda zp19_sight_depth
	cmp #$05
	beq @S_sight_limit
	lda zp1A_wall_bit
	cmp #$80
	bne :+
	dec zp0A_walls_ptr
	lda #$02
	sta zp1A_wall_bit
	jmp probe_south

:	asl zp1A_wall_bit
	asl zp1A_wall_bit
	jmp probe_south

@S_sight_limit:
	lda zp19_sight_depth
	jsr swap_saved_A_2
	lsr zp1A_wall_bit
S_next_wall:
	lda (zp0A_walls_ptr),y
	and zp1A_wall_bit
	beq :+
	inc gs_walls_right_depth
:	ldy #$03
	lda (zp0A_walls_ptr),y
	ldy #$00
	and zp1A_wall_bit
	beq :+
	inc gs_walls_left
:	jsr swap_saved_A_2
	cmp zp11_count
	beq S_probe_done
	jsr swap_saved_A_2
	lda #$04
	cmp zp11_count
	beq S_probed_max
	asl gs_walls_left
	asl gs_walls_right_depth
	inc zp11_count
	lda zp1A_wall_bit
	cmp #$01
	beq :+
	lsr zp1A_wall_bit
	lsr zp1A_wall_bit
	jmp S_next_wall

:	lda #$40
	sta zp1A_wall_bit
	inc zp0A_walls_ptr
	jmp S_next_wall

S_probed_max:
	jsr swap_saved_A_2
S_probe_done:
	asl
	asl
	asl
	asl
	asl
	clc
	adc gs_walls_right_depth
	sta gs_walls_right_depth
	rts

probe_east:
	lsr zp1A_wall_bit
@next_depth:
	clc
	lda zp0A_walls_ptr
	adc #$03
	sta zp0A_walls_ptr
	lda (zp0A_walls_ptr),y
	and zp1A_wall_bit
	bne @E_sight_limit
	inc zp19_sight_depth
	lda zp19_sight_depth
	cmp #$05
	bne @next_depth
@E_sight_limit:
	lda zp19_sight_depth
	jsr swap_saved_A_2
	lda zp1A_wall_bit
	sta zp19_wall_opposite
	asl zp1A_wall_bit
	clc
	ror zp19_wall_opposite
	bcc E_next_wall
	ror zp19_wall_opposite
E_next_wall:
	dec zp0A_walls_ptr
	dec zp0A_walls_ptr
	dec zp0A_walls_ptr
	lda (zp0A_walls_ptr),y
	and zp1A_wall_bit
	beq :+
	inc gs_walls_right_depth
:	lda zp19_wall_opposite
	cmp #$80
	beq :+
	lda (zp0A_walls_ptr),y
	jmp @check_opposite

:	iny
	lda (zp0A_walls_ptr),y
	dey
@check_opposite:
	and zp19_wall_opposite
	beq :+
	inc gs_walls_left
:	lda zp11_count
	cmp #$04
E_probed_max:
	beq S_probed_max
	jsr swap_saved_A_2
	cmp zp11_count
E_probe_done:
	beq S_probe_done
	jsr swap_saved_A_2
	inc zp11_count
	asl gs_walls_left
	asl gs_walls_right_depth
	jmp E_next_wall

probe_west:
	lsr zp1A_wall_bit
@next_depth:
	lda (zp0A_walls_ptr),y
	and zp1A_wall_bit
	bne :+
	inc zp19_sight_depth
	lda zp19_sight_depth
	cmp #$05
	beq :+
	dec zp0A_walls_ptr
	dec zp0A_walls_ptr
	dec zp0A_walls_ptr
	jmp @next_depth

:	lda zp19_sight_depth
	jsr swap_saved_A_2
	lda zp1A_wall_bit
	sta zp19_wall_opposite
	asl zp1A_wall_bit
	clc
	ror zp19_wall_opposite
	bcc W_next_wall
	ror zp19_wall_opposite
W_next_wall:
	lda (zp0A_walls_ptr),y
	and zp1A_wall_bit
	beq :+
	inc gs_walls_left
:	lda zp19_wall_opposite
	cmp #$80
	bne :+
	inc zp0A_walls_ptr
:	lda (zp0A_walls_ptr),y
	and zp19_wall_opposite
	beq :+
	inc gs_walls_right_depth
:	lda zp19_wall_opposite
	cmp #$80
	beq :+
	inc zp0A_walls_ptr
:	inc zp0A_walls_ptr
	inc zp0A_walls_ptr
	jsr swap_saved_A_2
	cmp zp11_count
	beq E_probe_done
	jsr swap_saved_A_2
	lda #$04
	cmp zp11_count
W_probed_max:
	beq E_probed_max
	inc zp11_count
	asl gs_walls_left
	asl gs_walls_right_depth
	jmp W_next_wall

probe_north:
	lda zp1A_wall_bit
	cmp #$02
	bne :+
	lda #$80
	sta zp1A_wall_bit
	inc zp0A_walls_ptr
	jmp @next_depth

:	lsr zp1A_wall_bit
	lsr zp1A_wall_bit
@next_depth:
	lda (zp0A_walls_ptr),y
	and zp1A_wall_bit
	bne @sight_limit
	inc zp19_sight_depth
	lda zp19_sight_depth
	cmp #$05
	beq @sight_limit
	lda zp1A_wall_bit
	cmp #$02
	bne :+
	inc zp0A_walls_ptr
	lda #$80
	sta zp1A_wall_bit
	jmp @next_depth

:	lsr zp1A_wall_bit
	lsr zp1A_wall_bit
	jmp @next_depth

@sight_limit:
	lda zp1A_wall_bit
	cmp #$80
	beq :+
	asl zp1A_wall_bit
	jmp @save_depth

:	dec zp0A_walls_ptr
	lda #$01
	sta zp1A_wall_bit
@save_depth:
	lda zp19_sight_depth
	jsr swap_saved_A_2
N_next_wall:
	lda (zp0A_walls_ptr),y
	and zp1A_wall_bit
	beq :+
	inc gs_walls_left
:	ldy #$03
	lda (zp0A_walls_ptr),y
	ldy #$00
	and zp1A_wall_bit
	beq :+
	inc gs_walls_right_depth
:	lda #$04
	cmp zp11_count
	beq W_probed_max
	jsr swap_saved_A_2
	cmp zp11_count
	bne :+
	jmp S_probe_done

:	jsr swap_saved_A_2
	asl gs_walls_left
	inc zp11_count
	asl gs_walls_right_depth
	lda zp1A_wall_bit
	cmp #$40
	beq :+
	asl zp1A_wall_bit
	asl zp1A_wall_bit
	jmp N_next_wall

:	lda #$01
	sta zp1A_wall_bit
	dec zp0A_walls_ptr
	jmp N_next_wall

