	.export clear_hgr2
	.export cold_start
	.export new_session
	.export start_game

	.import check_signature
	.import update_view
;	.import tape_addr_end
	.import game_save_end
;	.import tape_addr_start
	.import game_save_begin
	.import main_game_loop
	.import cmd_verbal
	.import gs_parsed_action
	.import item_cmd
	.import input_char
	.import print_to_line2
	.import load_disk_or_tape
	.import input_Y_or_N
	.import print_display_string
	.import get_rowcol_addr
	.import clear_text_buffer
	.import relocate_data

	.include "apple.i"
	.include "char.i"
	.include "item_commands.i"
	.include "string_verb_decl.i"

clock = $17 ;$18
zp_col = $06
zp_row = $07

zp0E_ptr = $0e ;$0f
zp0F_action = $0f

	.segment "START"

cold_start:
	cli
	ldx #$00
	stx clock
	stx clock+1
new_session:
	jsr relocate_data
	stx zp_col
	bit hw_PAGE2
	bit hw_FULLSCREEN
	bit hw_HIRES
	bit hw_GRAPHICS
	jsr clear_hgr2
.if REVISION >= 100
	; Fix bug if ESC is pressed first thing
	; when game starts, displays garbage.
	jsr clear_text_buffer
.else ;RETAIL
	nop
.endif
	jsr get_rowcol_addr
	lda #$94     ;Continue a game?
	jsr print_display_string
	jsr input_Y_or_N
	cmp #'Y'
	bne new_game
	jsr load_disk_or_tape
	lda #$96     ;Press any key
.if REVISION < 100 ;RETAIL
	nop
	nop
.endif
	jsr print_to_line2
	jsr input_char
	jsr load_from_tape
	jmp start_game

new_game:
	ldx #icmd_reset_game
	stx zp0F_action
	jsr item_cmd
start_game:
.if REVISION >= 100
	; Clear stack. There's no turning back from 'start_game',
	; and it will only exit via JMP to system in 'exit_game'.
	; This way we can jump here from any stack level,
	; such as a 'game_over' inside any command or special mode,
	; or after loading a saved game.
	ldx #$ff
	txs
.endif

	ldx #verb_directions
	stx gs_parsed_action
	jsr cmd_verbal
	jmp main_game_loop

clear_hgr2:
	ldx #<screen_HGR2
	stx zp0E_ptr
	ldx #>screen_HGR2
	stx zp0E_ptr+1
	ldy #$00
@next_page:
	tya
:	sta (zp0E_ptr),y
	inc zp0E_ptr
	bne :-
	inc zp0E_ptr+1
	lda zp0E_ptr+1
	cmp #$60
	bne @next_page
	rts

.if REVISION < 100 ;RETAIL
	nop
	nop
	nop
.endif
load_from_tape:
	ldx #<game_save_begin
	stx tape_addr_start
	ldx #>game_save_begin
	stx tape_addr_start+1
	ldx #>game_save_end
	stx tape_addr_end+1
	ldx #<game_save_end
	stx tape_addr_end
	jsr rom_READ_TAPE
	jsr clear_hgr2
	jsr update_view
	jsr check_signature  ;NOTE: never returns, continues with PLA/PLA/JMP
.if REVISION < 100 ;RETAIL
	nop
.endif
	jmp item_cmd

