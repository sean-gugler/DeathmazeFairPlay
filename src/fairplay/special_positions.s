	.export beheaded
	.export check_special_position
	.export pit

	.import wait_long
	.import wait_short
	.import get_rowcol_addr
	.import clear_maze_window
	.import push_special_mode
	.import game_over
	.import print_display_string
	.import clear_hgr2

	.include "game_design.i"
	.include "game_state.i"
	.include "special_modes.i"

zp_col = $06
zp_row = $07

zp19_pos_y = $19
zp1A_pos_x = $1A

	.segment "SPECIAL_POSITIONS"

check_special_position:
	lda gs_player_y
	sta zp19_pos_y
	lda gs_player_x
	sta zp1A_pos_x
	lda gs_level
	cmp #$03
	beq check_level_3
	bmi :+
	jmp check_levels_4_5
:	cmp #$02
	beq check_level_2

;check_level_1:
	lda zp1A_pos_x
	cmp #$06
	beq check_guillotine
	cmp #$03
	beq check_calculator
	bcc check_level_1_pit
	rts

check_calculator:
	lda zp19_pos_y
	cmp #$03
	beq at_calculator
	rts

at_calculator:
	jsr push_special_mode
	ldx #special_mode_calc_puzzle
	stx gs_special_mode
	rts

check_guillotine:
	lda zp19_pos_y
	cmp #$0a
	beq beheaded
	rts

beheaded:
	jsr clear_hgr2
	lda #$00
	sta zp_col
	lda #$09
	sta zp_row
	lda #$29     ;Invisible guillotine
	jsr print_display_string
	jmp game_over

check_level_1_pit:
	lda #$0a
	cmp zp19_pos_y
	bcs done
	ldx #$03
	stx gs_player_x
;	ldx #$03
	stx gs_player_y
	jmp pit
	;rts

check_level_3:
	lda zp19_pos_y
	cmp #$0a
	bne done
	lda zp1A_pos_x
	cmp #$01
	bne done
	jmp pit
	;rts

check_level_2:
	lda zp19_pos_y
	cmp #$05
	beq check_guarded_pit
check_dog_roaming:
	lda gs_level_moves_lo
	cmp #moves_until_dog1
	bcs :+
	lda gs_level_moves_hi
	beq done
:	lda gs_dog1_alive
	and #$01
	beq done
	jsr push_special_mode
	ldx #special_mode_dog1
	stx gs_special_mode
done:
	rts

check_guarded_pit:
	lda zp1A_pos_x
	cmp #$05
	beq at_guard_dog
	cmp #$08
	bne check_dog_roaming
	ldx #$08
	stx gs_player_x
	ldx #$05
	stx gs_player_y
	jsr pit
	rts

at_guard_dog:
	lda gs_dog2_alive
	and #$01
	beq :+
	jsr push_special_mode
	ldx #special_mode_dog2
	stx gs_special_mode
:	rts

check_levels_4_5:
	cmp #$04
	beq check_monster
	lda zp1A_pos_x
	cmp #$04
	beq check_bat
check_mother:
	lda gs_level_moves_lo
	cmp #moves_until_mother
	bcs :+
	lda gs_level_moves_hi
	beq @done
:	lda gs_mother_alive
	and #mother_flag_roaming
	beq @done
	lda gs_special_mode
	cmp #special_mode_mother
	beq @done
	jsr push_special_mode
	ldx #special_mode_mother
	stx gs_special_mode
@done:
	rts

check_bat:
	lda zp19_pos_y
	cmp #$04
	bne check_mother
	lda gs_bat_alive
	and #$02
	beq check_mother
	jsr push_special_mode
	ldx #special_mode_bat
	stx gs_special_mode
	rts

check_monster:
	lda gs_level_moves_lo
	cmp #moves_until_monster
	bcs :+
	lda gs_level_moves_hi
	beq @done
:	lda gs_monster_alive
	and #monster_flag_roaming
	beq @done
	lda gs_special_mode
	cmp #special_mode_monster
	beq @done
	jsr push_special_mode
	ldx #special_mode_monster
	stx gs_special_mode
@done:
	rts

	.segment "PIT"

pit:
	lda #action_level
	ora gs_action_flags
	sta gs_action_flags
	inc gs_level
	ldx #$00
	stx gs_level_moves_hi
	stx gs_level_moves_lo
	jsr clear_maze_window
	ldx #$05
	stx zp_col
	ldx #$08
	stx zp_row
	jsr get_rowcol_addr
	lda #$a7     ;Oh no! A pit!
	jsr print_display_string
	jsr wait_short
	ldx #$05
	stx zp_col
	inc zp_row
	jsr get_rowcol_addr
	lda #$2c     ;AAAAAAHH!
	jsr print_display_string
	jsr wait_long
	jsr clear_maze_window
	ldx #$09
	stx zp_col
	ldx #$08
	stx zp_row
	jsr get_rowcol_addr
	lda #$2d     ;WHAM!
	jsr print_display_string
	jmp wait_long

