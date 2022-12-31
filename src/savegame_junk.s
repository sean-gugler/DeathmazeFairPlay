	.segment "SAVEGAME"

; cruft leftover from earlier build
.if REVISION = 1
	lda gs_special_mode
.elseif REVISION = 2
	php
	lda #$61
.endif
	bne b7E81
	ldx #$06
	stx gs_special_mode
	rts

b7E81:
	.byte $06
	lda #$04
	sta zp_row
	lda #$03
	ldy #$0d
	jsr draw_down
	lda #raster_hi 4,17,0
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
	lda #$03
	ldy #$15
	jsr draw_down
	jmp $16e8 ;@draw_0_left

	pla
	pha
	cmp #$01
	bne b7ECE
	lda #$12
	sta zp_col
	lda #$04
	sta zp_row
	lda #$03
	ldy #$0d
	jsr draw_down
b7ECE:
	lda #$15
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
	pla
	cmp #$00
	beq b7F4C
	lda gs_walls_left
	and #$01
	bne b7F1B
	lda #$00
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$15
	jsr draw_down
	lda #>relocated
	sta screen_ptr+1
	lda #<relocated
	sta screen_ptr
	ldy #$01
	jsr draw_right
	lda #raster_hi 20,-1,7
	sta screen_ptr+1
	lda #raster_lo 20,-1,7
	sta screen_ptr
	ldy #$01
	jsr draw_right
b7F1B:
	lda gs_walls_right_depth
	and #$01
	bne b7F4B
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #$03
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
b7F4B:
	rts

b7F4C:
	lda gs_walls_left
	and #$01
	beq b7F60
	lda #$00
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$15
	jsr draw_down
b7F60:
	lda gs_walls_right_depth
	and #$01
	beq b7F4B
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #$03
	ldy #$15
	jsr draw_down
	rts

	lda #$ff
b7F79:
	sta (screen_ptr),y
	dey
	bne b7F79
	rts

	tya
	sta zp1A_count_loop
b7F82:
	jsr get_rowcol_addr
	lda #$02
	jsr char_out
	dec zp_col
	dec zp_col
	inc zp_row
	dec zp1A_count_loop
	bne b7F82
	rts

	tya
	sta zp1A_count_loop
b7F98:
	jsr get_rowcol_addr
	lda #$01
	jsr char_out
	inc zp_row
	dec zp1A_count_loop
	bne b7F98
	rts

	pha
	tya
	sta zp1A_count_loop
	pla
b7FAC:
	pha
	jsr get_rowcol_addr
	pla
	pha
	jsr print_char
	pla
	dec zp_col
	inc zp_row
	dec zp1A_count_loop
	bne b7FAC
	rts

	ldy #$00
	lda #<maze_walls
	sta zp0A_walls_ptr
	lda #>maze_walls
	sta zp0A_walls_ptr+1
	ldx gs_level
	lda #$00
	clc
	dex
	beq b7FD7
	adc #$21
	jmp $17CF

b7FD7:
	adc zp0A_walls_ptr
	sta zp0A_walls_ptr
	ldx gs_player_x
	dex
	beq b7FEA
	inc zp0A_walls_ptr
	inc zp0A_walls_ptr
	inc zp0A_walls_ptr
	jmp $17DE

b7FEA:
	lda gs_player_y
	cmp #$05
	bmi b7FFF
	cmp #$09
	bmi b7FFA
	inc zp0A_walls_ptr
	sec
	sbc #$04
b7FFA:
	inc zp0A_walls_ptr
	sec
	sbc #$04
	.assert * = $7fff, error, "Unexpected alignment"
b7FFF:
.if REVISION = 1
	brk
.endif
