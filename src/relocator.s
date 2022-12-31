	.export relocate_data

	.import __MAIN_LAST__

	.segment "RELOCATOR"

relocate_data:
	lda relocated
	beq @write_DEATH

; Relocate data above HGR2: ($4000-$5FFF) to ($6000-$7FFF)
	ldx #<screen_HGR2
	stx zp0E_src
	stx zp10_dst
	stx relocated
	ldx #>screen_HGR2
	stx zp0E_src+1
	ldx #>(screen_HGR2 + screen_HGR_size)
	stx zp10_dst+1
	ldx #<(screen_HGR_size - 1)
	stx zp19_count
	ldx #>(screen_HGR_size - 1)
	stx zp19_count+1
	jsr memcpy
	ldx #opcode_JMP
	stx DOS_hook_monitor
	ldx #<vector_reset
	stx DOS_hook_monitor+1
	ldx #>vector_reset
	stx DOS_hook_monitor+2
@write_DEATH:
	ldx #'D'
	stx signature
	ldx #'E'
	stx signature+1
	ldx #'A'
	stx signature+2
	ldx #'T'
	stx signature+3
	ldx #'H'
	stx signature+4
	ldx #$00
	stx zp_row
	rts

relocated = __MAIN_LAST__ - 1
