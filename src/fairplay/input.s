	.export get_player_input
	.export input_Y_or_N
	.export input_char

	.import vocab_table
	.import print_display_string
	.importzp vocab_end
	.import print_char
	.import print_to_line2
	.import clear_cursor
	.import char_out
	.import blink_cursor
	.import get_rowcol_addr
	.import clear_status_lines
	.import memcpy
	.importzp textbuf_size
	.import text_buffer_prev
	.import text_buffer_line1

	.include "apple.i"
	.include "char.i"
	.include "game_design.i"
	.include "game_state.i"
	.include "string_verb_decl.i"

zp_col = $06
zp_row = $07

zp13_char_input   = $13;
zp0E_ptr          = $0E;
zp10_count_vocab  = $10;
zp13_raw_input    = $13;
zp0F_index        = $0F;
zp0E_count        = $0E;
zp19_input_ptr    = $19;
zp10_count_words  = $10;
zp11_count_chars  = $11;
zp0C_string_ptr   = $0C;
zp19_count        = $19;
zp10_dst          = $10;
zp0E_src          = $0E;

	.segment "INPUT1"

get_player_input:
	bit hw_STROBE
:	bit hw_KEYBOARD
	bpl :-
	lda hw_KEYBOARD
	and #$7f
	cmp #$40
	bmi :+  ;GUG: bcc preferred
	and #char_mask_upper
:	pha
	lda #>text_buffer_line1
	sta zp0E_src+1
	lda #<text_buffer_line1
	sta zp0E_src
	lda #>text_buffer_prev
	sta zp10_dst+1
	lda #<text_buffer_prev
	sta zp10_dst
	lda #$00
	sta zp19_count+1
	lda #textbuf_size
	sta zp19_count
	jsr memcpy
	jsr clear_status_lines
.if REVISION < 100 ;RETAIL
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
.endif
	dec zp_row
	jsr get_rowcol_addr
	lda #>(text_buffer_line1-1)
	sta a:zp0C_string_ptr+1
	lda #<(text_buffer_line1-1)
	sta a:zp0C_string_ptr
	lda #$80
	ldy #textbuf_size
:	sta (zp0C_string_ptr),y
	dey
	bne :-
	lda #$00
	sta zp11_count_chars
	sta zp10_count_words
	lda #>(text_buffer_line1-1)
	sta zp19_input_ptr+1
	lda #<(text_buffer_line1-1)
	sta zp19_input_ptr
	pla
	jmp process_input_char

input_blink_cursor:
	bit hw_STROBE
:	jsr blink_cursor
	bit hw_KEYBOARD
	bpl :-
	lda hw_KEYBOARD
	and #$7f
	cmp #$40
	bmi process_input_char  ;GUG: bcc preferred
	and #char_mask_upper
process_input_char:
	pha
	lda zp11_count_chars
	bne @check_backspace
	pla
	cmp #'Z'
	bne :+
	jmp @forward

:	cmp #'X'
	bne :+
	jmp @around

:	cmp #char_left
	bne :+
	jmp @left

:	cmp #char_right
	bne :+
	jmp @right

:	cmp #' '
	beq input_blink_cursor
	cmp #char_enter
	beq input_blink_cursor
	bne @check_enter
@check_backspace:
	pla
	cmp #char_left
	bne @check_enter
	jmp input_backspace

@check_enter:
	cmp #char_enter
	bne @check_esc
	jmp input_enter

; Cancel whatever is currently typed
@check_esc:
	cmp #char_esc
	bne @check_space
; Replace current buffer with previous
	lda #$00
	sta zp_col
	lda #$16
	sta zp_row
	jsr get_rowcol_addr
	lda #>(text_buffer_prev-1)
	sta zp0E_src+1
	lda #<(text_buffer_prev-1)
	sta zp0E_src
	ldy #textbuf_size
@next_char:
	lda (zp0E_src),y
	sta (zp19_input_ptr),y
	dey
	bne @next_char

; Re-display on screen
	ldy #textbuf_size
	sty zp0E_count
	ldy #$01
	sty zp0F_index
@repeat_display:
	lda (zp19_input_ptr),y
	cmp #$80
	bmi :+  ;GUG: bcc preferred
	lda #' '
:	jsr char_out
	inc zp0F_index
	ldy zp0F_index
	dec zp0E_count
	bne @repeat_display

; Start over with fresh input buffer from scratch
	jmp get_player_input

@check_space:
	cmp #' '
	beq input_space
	bcs input_letter
	jmp input_blink_cursor

@forward:
	lda #verb_forward
	bne @return_move
@right:
	lda #verb_right
	bne @return_move
@left:
	lda #verb_left
	bne @return_move
@around:
	lda #verb_uturn
@return_move:
	sta gd_parsed_action
	jmp clear_cursor

input_enter:
	jmp parse_input

input_backspace:
	jsr clear_cursor
	dec zp_col
	jsr get_rowcol_addr
	lda #' '
	jsr char_out
	dec zp_col
	jsr get_rowcol_addr
	ldy zp11_count_chars
	lda (zp19_input_ptr),y
	cmp #' '
	bne :+
	dec zp10_count_words
:	lda #$80
	sta (zp19_input_ptr),y
	dec zp11_count_chars
	jmp input_blink_cursor

input_letter:
	sta zp13_raw_input
	cmp #'A'
	bcc @no_modification
	ldy zp11_count_chars
	beq @no_modification
	lda (zp19_input_ptr),y ;Check previous character
	cmp #' '
	beq @no_modification
	lda zp13_raw_input
	ora #$20     ;Make lower-case
	bne :+
@no_modification:
	lda zp13_raw_input
:	pha
	jsr char_out
	pla
	inc zp11_count_chars
	ldy zp11_count_chars
	sta (zp19_input_ptr),y
	cpy #textbuf_max_input
	beq parse_input
	jmp input_blink_cursor

input_space:
	ldy zp11_count_chars
	; Prevent double-space.
.if REVISION >= 100
	;removed DEY to fix bug
.else ;RETAIL
	; This looks back too far by one char. It mistakenly prevents
	; space after first letter of second word, as in:  WORD_L_
	dey
.endif
	lda (zp19_input_ptr),y
	cmp #' '
	bne :+
	jmp input_blink_cursor

:	lda zp10_count_words
	bne parse_input
	inc zp10_count_words
	lda #' '
	bne input_letter

parse_input:
	jsr clear_cursor
	lda #' '
	inc zp11_count_chars
	ldy zp11_count_chars
	sta (zp19_input_ptr),y
	inc zp19_input_ptr
	bne @parse_verb
	inc zp19_input_ptr+1
@parse_verb:
	jsr get_vocab
	lda zp10_count_vocab
	sta gd_parsed_action
	ldy #$00
@skip_word:
	inc zp19_input_ptr
	bne :+
	inc zp19_input_ptr+1
:	lda (zp19_input_ptr),y
	cmp #' '
	bne @skip_word
	inc zp19_input_ptr
	bne :+
	inc zp19_input_ptr+1
:	lda (zp19_input_ptr),y
	cmp #$80
	beq @verb_only
	cmp #' '
	bne @parse_object
@verb_only:
	lda #$00
	sta gd_parsed_object
	beq @check_verb
@parse_object:
	jsr get_vocab
	lda zp10_count_vocab
	sta gd_parsed_object
@check_verb:
	lda gd_parsed_action
	cmp #verbs_end
	bcc @known_verb
	lda #$8d     ;I'm sorry, but I can't
	jsr print_to_line2
	lda #<text_buffer_line1
	sta zp19_input_ptr
	lda #>text_buffer_line1
	sta zp19_input_ptr+1
	ldy #$00
@echo_next_char:
	tya
	pha
	lda (zp19_input_ptr),y
	cmp #' '
	beq @echo_period
	jsr char_out
	pla
	tay
	iny
	bne @echo_next_char
@echo_period:
	pla
	lda #'.'
	jsr print_char
	jmp get_player_input

@known_verb:
	cmp #verb_intransitive
	bcs @verb_no_object
	lda gd_parsed_object
	beq @verb_no_object
	cmp #vocab_end
	beq @unknown_object
	cmp #verbs_end
	bcc @unknown_object
	sec
	sbc #verbs_end-1
	sta gd_parsed_object
@done_verb:
	rts

@unknown_object:
	lda #$8f     ;What in tarnation is a
	jsr print_to_line2
	lda #<text_buffer_line1
	sta zp19_input_ptr
	lda #>text_buffer_line1
	sta zp19_input_ptr+1
	ldy #$00
@find_word_end:
	lda (zp19_input_ptr),y
	cmp #$20
	beq @found_word_end
	inc zp19_input_ptr
	bne @find_word_end
	inc zp19_input_ptr+1
	bne @find_word_end
@found_word_end:
	inc zp19_input_ptr
	bne @obj_next_letter
	inc zp19_input_ptr+1
@obj_next_letter:
	tya
	pha
	lda (zp19_input_ptr),y
	cmp #$20
	beq @obj_word_end
	jsr char_out
	pla
	tay
	iny
	bne @obj_next_letter
@obj_word_end:
	lda #'?'
	jsr char_out
	pla
	jmp get_player_input

@verb_no_object:
	lda gd_parsed_action
	cmp #verb_intransitive
	bcs @done_verb
	cmp #verb_look
	beq @cmd_look
	lda #>text_buffer_line1
	sta zp19_input_ptr+1
	lda #<text_buffer_line1
	sta zp19_input_ptr
	lda #$00
	sta zp_col
	lda #$17
	sta zp_row
	jsr get_rowcol_addr
	lda #char_ClearLine
	jsr char_out
	ldy #$00
	sty zp11_count_chars
	lda (zp19_input_ptr),y
	and #char_mask_upper
	bne @echo
@next_verb_letter:
	lda (zp19_input_ptr),y
	cmp #$20
	beq @verb_word_end
@echo:
	jsr char_out
	inc zp11_count_chars
	ldy zp11_count_chars
	bne @next_verb_letter
@verb_word_end:
	lda #$56     ;what?
	jsr print_display_string
	jmp get_player_input

@cmd_look:
	lda gs_room_lit
	beq @dark
	lda #$8b     ;Look at your monitor.
	bne :+
@dark:
	lda #$8a     ;It's awfully dark.
:	jsr print_to_line2
	jmp get_player_input

get_vocab:
	lda zp19_input_ptr+1
	pha
	lda zp19_input_ptr
	pha
	lda #>vocab_table
	sta zp0E_ptr+1
	lda #<vocab_table
	sta zp0E_ptr
	lda #$00
	sta zp10_count_vocab
@next_word:
	ldy #$01
@find_string:
	lda (zp0E_ptr),y
	and #$80
	bne @found_start
	inc zp0E_ptr
	bne @find_string
	inc zp0E_ptr+1
	bne @find_string
@found_start:
	dey
	lda (zp0E_ptr),y
	cmp #'*'
	beq :+
	inc zp10_count_vocab
:	inc zp0E_ptr
	bne :+
	inc zp0E_ptr+1
:	lda #vocab_word_size
	sta zp11_count_chars
@compare_char:
	lda (zp0E_ptr),y
	and #char_mask_upper
	sta zp13_char_input
	lda (zp19_input_ptr),y
	and #char_mask_upper
	cmp zp13_char_input
	bne @mismatch
	inc zp19_input_ptr
	bne :+
	inc zp19_input_ptr+1
:	inc zp0E_ptr
	bne :+
	inc zp0E_ptr+1
:	dec zp11_count_chars
	bne @compare_char
@done:
	pla
	sta zp19_input_ptr
	pla
	sta zp19_input_ptr+1
	rts

@mismatch:
	lda zp10_count_vocab
	cmp #vocab_end-1
	beq @fail
	pla
	sta zp19_input_ptr
	pla
	sta zp19_input_ptr+1
	pha
	lda zp19_input_ptr
	pha
	jmp @next_word

@fail:
	inc zp10_count_vocab
	bne @done


	.segment "INPUT2"

input_char:
	bit hw_STROBE
:	jsr blink_cursor
	bit hw_KEYBOARD
	bpl :-
	jmp clear_cursor

input_Y_or_N:
	bit hw_STROBE
:	jsr blink_cursor
	bit hw_KEYBOARD
	bpl :-
	lda hw_KEYBOARD
	and #$7f
	cmp #'Y'
	beq :+
	cmp #'N'
	bne input_Y_or_N
:	pha
	jsr clear_cursor
	pla
	rts

