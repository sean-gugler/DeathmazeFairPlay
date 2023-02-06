	.export relocate_data
	.export relocated

	.import signature
	.import vector_reset
	.import memcpy

	.include "apple.i"
	.include "dos.i"

	.import __MAIN_LAST__
	.import __HIGH_START__
	.import __HIGH_LAST__
	.import __HIGH_SIZE__

zp_col = $06
zp_row = $07

zp0E_src   = $0E;
zp10_dst   = $10;
zp19_count = $19;

	; Compact memory without needing segment padding
	RELOCATE_SIZE = __HIGH_LAST__ - __HIGH_START__


	.segment "RELOCATOR"

relocate_data:
	lda relocated
	beq @write_DEATH

	; Relocate data that might overlap HGR2 ($4000-$5FFF) to above it ($6000-$7FFF)
	ldx #<__MAIN_LAST__
	stx zp0E_src
	ldx #<__HIGH_START__  ;no longer guaranteed 0
	stx zp10_dst
	stx relocated
	ldx #>__MAIN_LAST__
	stx zp0E_src+1
	ldx #>__HIGH_START__
	stx zp10_dst+1
	ldx #<(RELOCATE_SIZE - 1)
	stx zp19_count
	ldx #>(RELOCATE_SIZE - 1)
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

	.segment "RELOCATOR_FLAG"

relocated:
	.byte $ff
