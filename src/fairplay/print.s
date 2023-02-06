	.export blink_cursor
	.export char_out
	.export clear_cursor
	.export clear_status_lines
	.export get_display_string
	.export get_rowcol_addr
	.export print_char
	.export print_display_string
	.export print_noun
	.export print_string
	.export print_to_line1
	.export print_to_line2

	.import text_buffer_line1
	.import text_buffer_line2
	.import display_string_table
	.import noun_table
	.import row8_table
	.import font

	.include "char.i"

clock = $17 ;$18
zp_col = $06
zp_row = $07

screen_ptr = $08 ;$09
zp0E_ptr = $0e ;$0f
zp0A_text_ptr     = $0A;
zp0C_string_ptr   = $0C;
zp11_count_string = $11;
zp13_char_input   = $13;
zp13_font_ptr     = $13;
zp15_line_count   = $15;
zp16_counter      = $16;

	.segment "PRINT_LINES"

print_to_line1:
	ldx #$00
	stx zp_col
	ldx #$16
	stx zp_row
	ldx #<text_buffer_line1
	stx zp0A_text_ptr
	ldx #>text_buffer_line1
	stx zp0A_text_ptr+1
	bne print_to_line

print_to_line2:
	ldx #$00
	stx zp_col
	ldx #$17
	stx zp_row
	ldx #<text_buffer_line2
	stx zp0A_text_ptr
	ldx #>text_buffer_line2
	stx zp0A_text_ptr+1

print_to_line:
	jsr get_display_string
	jsr get_rowcol_addr
	jsr clear_text_buf
	ldy #$00
	lda (zp0C_string_ptr),y
	and #$7f

@next_char:
	sta (zp0A_text_ptr),y
	jsr print_char
	inc zp0C_string_ptr
	bne :+
	inc zp0C_string_ptr+1
:	inc zp0A_text_ptr
	ldy #$00
	lda (zp0C_string_ptr),y
	bpl @next_char
	lda #char_ClearLine
	jsr char_out
	rts

	.segment "PRINT_MESSAGE"

print_display_string:
	jsr get_display_string
print_string:
	jsr get_rowcol_addr
	ldy #$00
	lda (zp0C_string_ptr),y
	and #$7f
@next_char:
	jsr print_char
	inc zp0C_string_ptr
	bne :+
	inc zp0C_string_ptr+1
:	ldy #$00
	lda (zp0C_string_ptr),y
	bpl @next_char
	rts

get_display_string:
	sta zp11_count_string
	ldx #<display_string_table
	stx zp0C_string_ptr
	ldx #>display_string_table
	stx zp0C_string_ptr+1
	ldy #$00
@scan:
	lda (zp0C_string_ptr),y
	bmi @found_string
@next_char:
	inc zp0C_string_ptr
	bne @scan
	inc zp0C_string_ptr+1
	bne @scan
@found_string:
	dec zp11_count_string
	bne @next_char
	rts


	.segment "PRINT_NOUN"

print_noun:
	sta zp13_char_input
	lda #<noun_table
	sta zp0C_string_ptr
	lda #>noun_table
	sta zp0C_string_ptr+1
	ldy #$00
@find_string:
	lda (zp0C_string_ptr),y
	bmi @found_start
@next_char:
	inc zp0C_string_ptr
	bne @find_string
	inc zp0C_string_ptr+1
	bne @find_string
@found_start:
	dec zp13_char_input
	bne @next_char
	lda (zp0C_string_ptr),y
	and #$7f
@print_char:
	jsr char_out
	inc zp0C_string_ptr
	bne :+
	inc zp0C_string_ptr+1
:	ldy #$00
	lda (zp0C_string_ptr),y
	bpl @print_char
	lda #' '
	jmp char_out


	.segment "PRINT_CLEAR_BUFFER"

clear_text_buf:
	ldy #$27
	lda #' '
:	sta (zp0A_text_ptr),y
	dey
	bpl :-
	rts


	.segment "PRINT_CLEAR_DISPLAY"

clear_status_lines:
	pha
	ldx #$00
	stx zp_col
	ldx #$16
	stx zp_row
	jsr get_rowcol_addr
	lda #char_ClearLine
	jsr char_out
	inc zp_row
	jsr get_rowcol_addr
	lda #char_ClearLine
	jsr char_out
	pla
	rts


	.segment "PRINT_CHAR"

; Input: A = char, zp_col, zp_row
; 'screen_ptr' must already be set up, manually or with 'get_rowcol_addr'
char_out:
	cmp #char_newline
	beq control_newline
	cmp #char_ClearLine
	bne :+
	jmp clear_to_end_line

:	cmp #$c0
	bcc print_char
	jmp clear_up_to_3F

print_char:
	sta zp13_font_ptr
	lda #$00
	sta zp13_font_ptr+1
	asl zp13_font_ptr
	rol zp13_font_ptr+1
	asl zp13_font_ptr
	rol zp13_font_ptr+1
	asl zp13_font_ptr
	rol zp13_font_ptr+1
	clc
	lda #<font
	adc zp13_font_ptr
	sta zp13_font_ptr
	lda #>font
	adc zp13_font_ptr+1
	sta zp13_font_ptr+1
	ldx #$00
	ldy #$00
	lda #$08
	sta zp15_line_count
	clc
@next_line:
	lda (zp13_font_ptr),y
	sta (screen_ptr,x)
	lda #$04
	adc screen_ptr+1
	sta screen_ptr+1
	iny
	dec zp15_line_count
	bne @next_line

	inc zp_col
	lda #$28
	cmp zp_col
	bne get_rowcol_addr
	lda #$00
	sta zp_col
	lda #$17
	cmp zp_row
	beq get_rowcol_addr
	inc zp_row
get_rowcol_addr:
	lda zp_row
	asl
	clc
	adc #<row8_table
	sta zp13_font_ptr
	lda #$00
	adc #>row8_table
	sta zp13_font_ptr+1
	ldy #$01
	clc
	lda (zp13_font_ptr),y
	adc zp_col
	sta screen_ptr
	dey
	lda (zp13_font_ptr),y
	sta screen_ptr+1
	rts

control_newline:
	jsr clear_cursor
	lda #$17
	cmp zp_row
	beq :+
	inc zp_row
:	lda #$00
	sta zp_col
	jmp get_rowcol_addr

clear_to_end_line:
	lda #$28
	sec
	sbc zp_col
	jmp clear_N

clear_up_to_3F:
	sec
	sbc #$c0
clear_N:
	sta zp16_counter
	lda zp_col
	pha
	lda zp_row
	pha
:	lda #' '
	jsr print_char
	dec zp16_counter
	bne :-
	pla
	sta zp_row
	pla
	sta zp_col
	jmp get_rowcol_addr

blink_cursor:
	inc clock
	bne :+
	inc clock+1
:	lda clock+1
	cmp #$18
	beq show_cursor
	cmp #$30
	beq clear_cursor
done_cursor:
	rts

show_cursor:
	lda #$00
	cmp clock
	bne done_cursor
	lda zp_col
	pha
	lda zp_row
	pha
	lda #char_cursor
render_cursor:
	jsr print_char
	pla
	sta zp_row
	pla
	sta zp_col
	jmp get_rowcol_addr

clear_cursor:
	lda zp_col
	pha
	lda zp_row
	pha
	lda #$00
	sta clock
	sta clock+1
	lda #' '
	bne render_cursor

