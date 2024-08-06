	.export check_signature
	.export load_game
	.export save_game

	.import cold_start
	.import input_char
	.import print_display_string
	.import char_out
	.import start_game
	.import signature
	.import game_save_begin
	.import relocate_data
	.import clear_cursor
	.import blink_cursor
	.import save_to_tape
	.import item_cmd
	.import update_view
	.import print_to_line1
	.import print_string
	.import clear_hgr2

	.include "apple.i"
	.include "char.i"
	.include "game_state.i"
	.include "item_commands.i"
	.include "msbstring.i"
	.include "prodos.i"
	.include "pstring.i"

error_write_protect = $01
error_volume_mismatch = $02
error_unknown_cause = $03
error_reading = $04
error_bad_save = $05

zp_col = $06
zp_row = $07

zp19_delta16        = $19;
zp0E_ptr            = $0E;
zp0F_action         = $0F;
zp0C_string_ptr     = $0C;

	.segment "SAVE_GAME"

text_game_number:
	.byte "Game number (0-9)?"
	.byte $80

save_filename:
	Pstring "DEATHMAZE.SAVE0"
save_number = * - 1

prodos_buffer = $9000

create_params:
	.byte 7
	.addr save_filename
	.byte P8_access_unlocked
	.byte P8_ftype_BIN
	.addr game_save_begin  ;for BIN, aux type = address
	.byte P8_stype_FILE
	.word 0  ;create time
	.word 0  ;mod time

open_params:
	.byte 3
	.addr save_filename
	.addr prodos_buffer
open_ref_num:
	.res 1

readwrite_params:
	.byte 4
readwrite_ref_num:
	.res 1
	.addr game_save_begin
	.word game_save_size
readwrite_count:
	.res 2

close_params:
	.byte 1
	.byte 0  ;level 0 = close all



save_game:
	jsr prompt_game_number
	beq resume_game

	jsr P8_MLI
	.byte P8_CREATE
	.addr create_params
	bcc @write
	cmp #P8E_DUP_FILENAME  ;ignore, ok to overwrite existing
	bne @error

@write:
	lda #P8_WRITE
	jsr do_file
	bcc resume_game
@error:
	jsr print_prodos_error

resume_game:
	jsr clear_hgr2
	jsr update_view
	ldx #icmd_draw_inv
	stx zp0F_action
	jmp item_cmd
	;rts

load_game:
	inc signature
	jsr prompt_game_number
	beq load_abort
	lda #P8_READ
	jsr do_file
	bcs load_failed

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
	jmp start_game
@fail:
	lda #P8E_EOF

load_failed:
	jsr print_prodos_error
load_abort:
	pla
	pla
	jmp cold_start

prompt_game_number:
	jsr clear_hgr2
	ldx #$00
	stx zp_col
	stx zp_row
	ldx #<text_game_number
	stx zp0C_string_ptr
	ldx #>text_game_number
	stx zp0C_string_ptr+1
	jsr print_string
	jsr input_char
	lda hw_KEYBOARD
	and #$7f
	cmp #$1b  ;ESC
	beq @done
	cmp #'0'
	bcc prompt_game_number
	cmp #'9' + 1
	bcs prompt_game_number
	sta save_number
@done:
	rts

do_file:
	sta @op_readwrite

	jsr P8_MLI
	.byte P8_OPEN
	.addr open_params
	bcs @done

	lda open_ref_num
	sta readwrite_ref_num

	jsr P8_MLI
@op_readwrite:
	.byte P8_READ
	.addr readwrite_params
	php
	pha

	jsr P8_MLI
	.byte P8_CLOSE
	.addr close_params
	tax
	ror
	tay

	; check READ/WRITE error
	pla
	plp
	bcs @done

	; check CLOSE error
	tya
	rol
	txa

@done:
	rts


	.segment "STRINGS_IO"

string_disk_error:
diskmsg_misc:
	.byte "DRIVE ERROR! CAUSE UNKNOWN!", $80
diskmsg_not_found:
	.byte "FILE NOT FOUND!", $80
diskmsg_access:
	.byte "FILE ACCESS DENIED!", $80
diskmsg_disk_full:
	.byte "NO ROOM FOR FILE!", $80
diskmsg_cannot_read:
	.byte "NO DEATHMAZE DATA FOUND!", $80

	.segment "SAVE_GAME"

.define offset(message) <(message - string_disk_error)
table_disk_error:
	.byte P8E_IO_ERR,         offset(diskmsg_misc)
	.byte P8E_WRITE_PROT,     offset(diskmsg_access)
	.byte P8E_DIR_NOT_FOUND,  offset(diskmsg_not_found)
	.byte P8E_VOL_NOT_FOUND,  offset(diskmsg_not_found)
	.byte P8E_FILE_NOT_FOUND, offset(diskmsg_not_found)
	.byte P8E_VOL_FULL,       offset(diskmsg_disk_full)
	.byte P8E_VOL_DIR_FULL,   offset(diskmsg_disk_full)
	.byte P8E_EOF,            offset(diskmsg_cannot_read)
	.byte P8E_INVALID_ACCESS, offset(diskmsg_access)
table_end = (* - table_disk_error)
.undef offset

print_prodos_error:
    ldx #table_end - 2
:   cmp table_disk_error,x
    beq @match
    dex
    dex
    bne :-
@match:
    inx
    lda table_disk_error,x

print_error_message:
	clc
	adc #<string_disk_error
	sta zp0C_string_ptr
	lda #$00
	adc #>string_disk_error
	sta zp0C_string_ptr+1

	lda #char_newline
	jsr char_out
	jsr print_string
	jmp input_char
	;rts


	.segment "DATA_PERSIST"
