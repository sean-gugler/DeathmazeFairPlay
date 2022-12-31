	.segment "SAVEGAME"

.if REVISION = 1

text_save_device:
	.byte "Save to DISK or TAPE (T or D)?"
	.byte $80
text_load_device:
	msbstring "Get from DISK or TAPE (T or D)?"
	.byte $80

.elseif REVISION = 2

text_save_device:
	.byte "SAVE TO DISK OR TAPE (T OR D)?", $80
text_load_device:
	.byte "GET FROM DISK OR TAPE (T OR D)?", $80

.endif
	.assert * = $7c3f, error, "Unexpected alignment"
load_disk_or_tape:
	jsr clear_hgr2
	ldx #$00
	stx zp_col
	stx zp_row
	ldx #<text_load_device
	stx zp0C_string_ptr
	ldx #>text_load_device
	stx zp0C_string_ptr+1
	jsr print_string
	jsr input_T_or_D
	cmp #'D'
	bne prompt_tape
	jmp load_from_disk

prompt_tape:
	jsr clear_hgr2
	lda #$95     ;Prepare your cassette
	jsr print_to_line1
	rts

save_disk_or_tape:
	jsr clear_hgr2
	ldx #$00
	stx zp_col
	stx zp_row
	ldx #<text_save_device
	stx zp0C_string_ptr
	ldx #>text_save_device
	stx zp0C_string_ptr+1
	jsr print_string
	jsr input_T_or_D
	cmp #'T'
	beq prepare_tape_save
	jmp save_to_disk

prepare_tape_save:
	jsr clear_hgr2
	jsr update_view
	ldx #icmd_draw_inv
	stx zp0F_action
	jsr item_cmd
	jmp save_to_tape

input_T_or_D:
	bit hw_STROBE
:	jsr blink_cursor
	bit hw_KEYBOARD
	bpl :-
	lda hw_KEYBOARD
	and #$7f
	cmp #'T'
	beq :+
	cmp #'D'
	bne input_T_or_D
:	pha
	jsr clear_cursor
	pla
	rts

dos_dct:
	.byte $00,$01
	.word $d8ef
dos_iob:
	.byte $01,$60,$01,$00,$03,$00
iob_dct:
	.word relocate_data
iob_buffer:
	.word game_save_begin
	.byte $00,$00
iob_cmd:
	.byte $01
iob_return_code:
	.byte $00
iob_last_volume:
	.byte $00,$60,$01

.if REVISION = 1

text_insert_disk:
	msbstring "Place data diskette in DRIVE 1, SLOT 6."
	.byte $80

.elseif REVISION = 2

text_insert_disk:
	.byte "PLACE DATA DISKETTE IN DRIVE 1, SLOT 6.", $80

.endif

save_to_disk:
	ldx #$02
	stx iob_cmd
	jsr prompt_and_call_dos
	bcc prepare_disk_save
	jsr dos_code_to_message
	jmp disk_error_retry

prepare_disk_save:
	jsr clear_hgr2
	jsr update_view
	ldx #icmd_draw_inv
	stx zp0F_action
	jmp item_cmd

load_from_disk:
	ldx #$01
	stx iob_cmd
	jsr prompt_and_call_dos
	bcc check_signature
	jsr dos_code_to_message
	jmp disk_error_fatal

check_signature:
	ldy #$00
	lda signature,y
	cmp #'D'
	bne @fail
	iny
	lda signature,y
	cmp #'E'
	bne @fail
	iny
	lda signature,y
	cmp #'A'
	bne @fail
	iny
	lda signature,y
	cmp #'T'
	bne @fail
	iny
	lda signature,y
	cmp #'H'
	bne @fail
	pla
	pla
	jmp start_game

@fail:
	lda #error_bad_save
	jmp disk_error_fatal

prompt_and_call_dos:
	lda #char_newline
	jsr char_out
	ldx #<text_insert_disk
	stx zp0C_string_ptr
	ldx #>text_insert_disk
	stx zp0C_string_ptr+1
	jsr print_string
	lda #$0a     ;char_newline
	jsr char_out
	lda #$96     ;Press any key
	jsr print_display_string
	jsr input_char
	lda #>dos_iob
	ldy #<dos_iob
	jsr DOS_call_rwts
	rts

dos_code_to_message:
	lda iob_return_code
	cmp #$10
	bne :+
	lda #error_write_protect
	rts

:	cmp #$20
	bne :+
	lda #error_volume_mismatch
	rts

:	cmp #$40
	bne :+
	lda #error_unknown_cause
	rts

:	lda #error_reading
	rts

; 1-based indexing via 'A'
string_disk_error:
	.byte "DISKETTE WRITE PROTECTED!", $80
	.byte "VOLUME MISMATCH!", $80
	.byte "DRIVE ERROR! CAUSE UNKNOWN!", $80
	.byte "READ ERROR! CHECK YOUR DISKETTE!", $80
	.byte "NOT A DEATHMAZE FILE! INPUT REJECTED!", $80

disk_error_fatal:
	ldx #$00
	stx zp10_retry
	beq disk_error
disk_error_retry:
	ldx #$ff
	stx zp10_retry
disk_error:
	tay
	dey
	bne :+
	beq @print_message
:	dey
	bne :+
	ldy #$1a
	bne @print_message
:	dey
	bne :+
	ldy #$2b
	bne @print_message
:	dey
	bne :+
	ldy #$47
	bne @print_message
:	ldy #$68
@print_message:
	sty zp19_delta16
	ldx #$00
	stx zp19_delta16+1
	ldx #<string_disk_error
	stx zp0C_string_ptr
	ldx #>string_disk_error
	stx zp0C_string_ptr+1
	clc
	lda zp19_delta16
	adc zp0C_string_ptr
	sta zp0C_string_ptr
	lda zp19_delta16+1
	adc zp0C_string_ptr+1
	sta zp0C_string_ptr+1
	lda #char_newline
	jsr char_out
	jsr print_string
	jsr input_char
	lda zp10_retry
	beq :+
	jmp prepare_disk_save

:	pla
	pla
	jmp cold_start
