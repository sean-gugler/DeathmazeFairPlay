	.export check_signature
	.export load_disk_or_tape
	.export save_disk_or_tape

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
	.include "dos.i"
	.include "item_commands.i"
	.include "msbstring.i"

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

text_save_device:
	.byte "Save to DISK or TAPE (T or D)?"
	.byte $80
text_load_device:
	msbstring "Get from DISK or TAPE (T or D)?"
	.byte $80

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

text_insert_disk:
	.byte "Place data diskette in the drive.", $80

save_to_disk:
	lda #<dos_cmd_prefix
	ldy #>dos_cmd_prefix
	jsr print_cout
	lda #<dos_cmd_save
	ldy #>dos_cmd_save
	jsr print_cout
	lda #<dos_cmd_filename
	ldy #>dos_cmd_filename
	jsr print_cout
	lda #<dos_cmd_length
	ldy #>dos_cmd_length
	jsr print_cout
	jsr prompt_and_call_dos
	bcs resume_game
	jsr dos_code_to_message
resume_game:
	jsr clear_hgr2
	jsr update_view
	ldx #icmd_draw_inv
	stx zp0F_action
	jmp item_cmd
	;rts

load_from_disk:
	inc signature
	lda #<dos_cmd_prefix
	ldy #>dos_cmd_prefix
	jsr print_cout
	lda #<dos_cmd_load
	ldy #>dos_cmd_load
	jsr print_cout
	lda #<dos_cmd_filename
	ldy #>dos_cmd_filename
	jsr print_cout
	jsr prompt_and_call_dos
	bcc load_failed

check_signature:
	lda #error_bad_save
	ldy #$00
	lda signature,y
	cmp #'D'
	bne load_failed
	iny
	lda signature,y
	cmp #'E'
	bne load_failed
	iny
	lda signature,y
	cmp #'A'
	bne load_failed
	iny
	lda signature,y
	cmp #'T'
	bne load_failed
	iny
	lda signature,y
	cmp #'H'
	bne load_failed
	jmp start_game

load_failed:
	jsr dos_code_to_message
	pla
	pla
	jmp cold_start

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

	jsr save_dos_handler
	jsr hook_dos_handler
	jsr call_dos
	jsr restore_dos_handler
	rts

call_dos:
	tsx
	stx dos_save_stack
	lda #$8d
	jsr rom_COUT

return_from_dos:
	; If there was an error, Carry is clear and X has error code.
	txa
	ldx dos_save_stack
	txs
	rts

print_cout:
	sta zp0C_string_ptr
	sty zp0C_string_ptr + 1
@next:
	ldy #$00
	lda (zp0C_string_ptr),y
	beq @done
	ora #$80
	jsr rom_COUT
	inc zp0C_string_ptr
	bne :+
	inc zp0C_string_ptr + 1
:	bne @next
@done:
	rts

	; Tried appending these strings to the
	; string memory, but turns out there's more
	; room below HGR2 than in the relocate region
	; above it. So they stay in the same segment.
	.segment "STRINGS_IO"
	.segment "SAVE_GAME"

dos_cmd_prefix:
	.byte $0d,$04,"B",$00
dos_cmd_load:
	.byte "LOAD",$00
dos_cmd_save:
	.byte "SAVE",$00
dos_cmd_filename:
	.byte " DM.SAVE,A$8300",$00
dos_cmd_length:
	.byte ",L$90",$00

string_disk_error:
diskmsg_write_protect:
	.byte "DISKETTE WRITE PROTECTED!", $80
diskmsg_disk_full:
	.byte "DISK FULL!", $80
diskmsg_misc:
	.byte "DRIVE ERROR! CAUSE UNKNOWN!", $80
diskmsg_file_locked:
	.byte "FILE LOCKED! CHECK YOUR DISKETTE!", $80
diskmsg_cannot_read:
	.byte "NO DEATHMAZE DATA FOUND!", $80

.define offset(message) <(message - string_disk_error)
table_disk_error = * - 4
	.byte offset(diskmsg_write_protect) ;$04 DOS_error_write_protected
	.byte offset(diskmsg_cannot_read)   ;$05 DOS_error_end_of_data
	.byte offset(diskmsg_cannot_read)   ;$06 DOS_error_file_not_found
	.byte offset(diskmsg_misc)          ;$07 DOS_error_volume_mismatch
	.byte offset(diskmsg_misc)          ;$08 DOS_error_io_error
	.byte offset(diskmsg_disk_full)     ;$09 DOS_error_disk_full
	.byte offset(diskmsg_file_locked)   ;$0a DOS_error_file_locked
.undef offset

	.segment "SAVE_GAME"

dos_code_to_message:
	tax
	lda table_disk_error,x
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

hook_dos_handler:
	; Force DOS to bypass error PRINT
	; and call BREAK handler.
	; (WARNING: relies on private address DOS_BREAK)
	lda #OnErr_Active
	sta APPLESOFT_OnErrMode
	lda #APPLESOFT_Running
	sta APPLESOFT_RunState
	lda #Prompt_None
	sta APPLESOFT_Prompt
	lda #<return_from_dos
	sta DOS_BREAK
	lda #>return_from_dos
	sta DOS_BREAK + 1
	rts

save_dos_handler:
	ldx DOS_BREAK
	stx dos_saved
	ldx DOS_BREAK + 1
	stx dos_saved + 1
	ldx APPLESOFT_OnErrMode
	stx dos_saved + 2
	ldx APPLESOFT_RunState
	stx dos_saved + 3
	ldx APPLESOFT_Prompt
	stx dos_saved + 4
	rts

restore_dos_handler:
	ldx dos_saved
	stx DOS_BREAK
	ldx dos_saved + 1
	stx DOS_BREAK + 1
	ldx dos_saved + 2
	stx APPLESOFT_OnErrMode
	ldx dos_saved + 3
	stx APPLESOFT_RunState
	ldx dos_saved + 4
	stx APPLESOFT_Prompt
	rts


	.segment "DATA_PERSIST"

dos_save_stack:
	.res 1

dos_saved:
	.res 5
