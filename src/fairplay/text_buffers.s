	.export text_buffer_prev
	.export text_buffer_line1
	.export text_buffer_line2
	.exportzp textbuf_size

	.segment "TEXT_BUFFERS"

textbuf_size = $28 * 2 ;40 columns, 2 lines

; uninitialized buffers contain
; cruft leftover from earlier build
text_buffer_prev:
	.byte $c9,$50,$90,$03,$20,$15,$10,$ad
	.byte $9e,$61,$f0,$08,$a2,$00,$8e,$b3
	.byte $61,$4c,$93,$34,$a2,$00,$8e,$a4
	.byte $61,$ad,$b3,$61,$d0,$29,$ad,$94
	.byte $61,$c9,$05,$f0,$0a,$ad,$ad,$61
	.byte $29,$02,$d0,$08,$4c,$93,$34,$ad
	.byte $ac,$61,$f0,$f8,$20,$26,$36,$a9
	.byte $43,$20,$92,$08,$a9,$44,$20,$a4
	.byte $08,$ee,$b3,$61,$4c,$08,$36,$c9
	.byte $01,$d0,$13,$20,$26,$36,$ee,$b3
text_buffer_line1:
	.byte $61,$a9,$45,$20,$92,$08,$a9,$47
	.byte $20,$a4,$08,$4c,$08,$36,$20,$26
	.byte $36,$ad,$94,$61,$c9,$05,$f0,$0d
	.byte $a9,$36,$20,$92,$08,$a9,$37,$20
	.byte $a4,$08,$4c,$b9,$10,$a9,$48,$20
	.assert * - text_buffer_line1 = textbuf_size / 2, error, "Mismatch text buffer size"
text_buffer_line2:
	.byte $92,$08,$a9,$4b,$20,$a4,$08,$4c
	.byte $b9,$10,$ca,$d0,$6f,$ad,$9d,$61
	.byte $c9,$11,$f0,$07,$20,$5f,$10,$a9
	.byte $20,$d0,$e9,$ad,$9c,$61,$c9,$0e
	.byte $f0,$52,$c9,$13,$d0,$ee,$a2,$04
	.assert * - text_buffer_line2 = textbuf_size / 2, error, "Mismatch text buffer size"
;
; cruft decoded:
;	cmp #$50
;	bcc b0C31
;	jsr s1015
;b0C31:
;	lda gs_room_lit
;	beq b0C3E
;	ldx #$00
;	stx a61B3
;	jmp $3493
;
;b0C3E:
;	ldx #$00
;	stx a61A4
;	lda a61B3
;	bne b0C71
;	lda a6194
;	cmp #$05
;	beq b0C59
;	lda a61AD
;	and #$02
;	bne b0C5E
;b0C56:
;	jmp $3493
;
;b0C59:
;	lda a61AC
;	beq b0C56
;b0C5E:
;	jsr s3626
;	lda #$43     ;The ground beneath your feet
;	jsr print_to_line1
;	lda #$44     ;begins to shake!
;	jsr print_to_line2
;	inc a61B3
;	jmp j3608
;
;b0C71:
;	cmp #$01
;	bne b0C88
;	jsr s3626
;	inc a61B3
;	lda #$45     ;A disgusting odor permeates
;	jsr print_to_line1
;	lda #$47     ;the hallway!
;	jsr print_to_line2
;	jmp j3608
;
;b0C88:
;	jsr s3626
;	lda a6194
;	cmp #$05
;	beq b0C9F
;	lda #$36     ;The monster attacks you and
;	jsr print_to_line1
;	lda #$37     ;you are his next meal!
;	jsr print_to_line2
;	jmp game_over
;
;b0C9F:
;	lda #$48     ;It is the monster's mother!
;	jsr print_to_line1
;	lda #$4b     ;She slashes you to bits!
;b0CA6:
;	jsr print_to_line2
;	jmp game_over
;
;	dex
;	bne b0D1E
;	lda gd_direct_object
;	cmp #$11
;	beq b0CBD
;b0CB6:
;	jsr clear_status_lines
;	lda #$20
;	bne b0CA6
;b0CBD:
;	lda a619C
;	cmp #$0e
;	beq b0D16
;	cmp #$13
;	bne b0CB6
;	ldx #$04
;
; (end cruft)

