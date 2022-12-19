;	.include "deathmaze_b.i"

	.include "msbstring.i"

;
; **** ZP FIELDS ****
;
f61 = $61
;
; **** ZP ABSOLUTE ADRESSES ****
;
zp_col = $06
zp_row = $07
screen_ptr = $08
;screen_ptr+1 = $09
a0A = $0a
a0B = $0b
string_ptr = $0c
;string_ptr+1 = $0d
src = $0e
;src+1 = $0f
dst = $10
;dst+1 = $11
row_ptr = $13
;row_ptr+1 = $14
line_count = $15
a16 = $16
clock = $17
;clock+1 = $18
count = $19
;count+1 = $1a
a3C = $3c
a3D = $3d
a3E = $3e
a3F = $3f
aBC = $bc
aBD = $bd
aBE = $be
aC3 = $c3
aE5 = $e5
aEE = $ee
aEF = $ef
;
; **** ZP POINTERS ****
;
;screen_ptr = $08
p0A = $0a
;string_ptr = $0c
;src = $0e
;dst = $10
;row_ptr = $13
;count = $19
p28 = $28
pC2 = $c2
;
; **** FIELDS ****
;
f0135 = $0135
;
; **** ABSOLUTE ADRESSES ****
;
a0108 = $0108
a0124 = $0124
a0125 = $0125
a0126 = $0126
a0127 = $0127
a018F = $018f
aC051 = $c051
aC054 = $c054
aC056 = $c056
;
; **** POINTERS ****
;
p01 = $0001
p04 = $0004
p05 = $0005
p50 = $0050
p68 = $0068
pAA = $00aa
p00F4 = $00f4
p00F6 = $00f6
p0103 = $0103
p0104 = $0104
p0150 = $0150
p0206 = $0206
p0307 = $0307
p0308 = $0308
p0309 = $0309
p030B = $030b
p0311 = $0311
p0400 = $0400
p0402 = $0402
p0500 = $0500
p0508 = $0508
p0601 = $0601
p0602 = $0602
p0603 = $0603
p0604 = $0604
p0607 = $0607
p0608 = $0608
p0609 = $0609
p060A = $060a
p060C = $060c
p060E = $060e
p0611 = $0611
p0612 = $0612
p0615 = $0615
p0801 = $0801
p0802 = $0802

p4015 = $4015
p40AF = $40AF
p40B1 = $40B1
p40B4 = $40B4
p40D8 = $40D8
p40D9 = $40D9
p4131 = $4131
p4132 = $4132
p4133 = $4133
p4134 = $4134
p4156 = $4156
p4200 = $4200
p4204 = $4204
p4211 = $4211
p4384 = $4384
p4387 = $4387
p438E = $438E
p4607 = $4607
p4707 = $4707
p5C50 = $5C50
p5C54 = $5C54
p5C61 = $5C61
p5D05 = $5D05
p5DAF = $5DAF
p5DB4 = $5DB4
p5E4F = $5E4F
p5E50 = $5E50
p5E56 = $5E56
p5E65 = $5E65
p5EAC = $5EAC
p5EAF = $5EAF
p5EB6 = $5EB6

;
; **** EXTERNAL JUMPS ****
;
e03D9 = $03d9
eFD35 = $fd35
eFDED = $fded
eFECD = $fecd
eFEFD = $fefd
eFF69 = $ff69
;
; **** USER LABELS ****
;

	.include "apple.i"
	.include "dos.i"

char_cursor = $00

zp_string_number = $11

	.segment "MAIN"

j0805:
	cli
	ldx #$00
	stx clock
	stx clock+1
j080C:
	jsr relocate_data
	stx zp_col
	bit hw_PAGE2
	bit hw_FULLSCREEN
	bit hw_HIRES
	bit hw_GRAPHICS
	jsr clear_hgr2
	nop
	jsr get_rowcol_addr
	lda #$94     ;Continue a game?
	jsr print_display_string
	jsr input_Y_or_N
	cmp #'Y'
	bne new_game
	jsr s7C3F
	lda #$96
	nop
	nop
	jsr s08A4
	jsr input_char
	jsr s0872
	jmp j084A

new_game:
	ldx #$09
	stx src+1
	jsr s1A34
j084A:
	ldx #$1b
	stx a619C
	jsr s2640
	jmp j092B

clear_hgr2:
	ldx #<screen_HGR2
	stx src
	ldx #>screen_HGR2
	stx src+1
	ldy #$00
@next_page:
	tya
:	sta (src),y
	inc src
	bne :-
	inc src+1
	lda src+1
	cmp #$60
	bne @next_page
	rts

	nop
	nop
	nop
s0872:
	ldx #<p6193
	stx a3C
	ldx #>p6193
	stx a3D
	ldx #>p6292
	stx a3F
	ldx #<p6292
	stx a3E
	jsr eFEFD
	jsr clear_hgr2
	jsr s1015
	jsr s7D1C
	nop
	jmp s1A34

s0892:
	ldx #<p1600
	stx zp_col
	ldx #>p1600
	stx zp_row
	ldx #<p0C7A
	stx a0A
	ldx #>p0C7A
	stx a0B
	bne b08B4
s08A4:
	ldx #<p1700
	stx zp_col
	ldx #>p1700
	stx zp_row
	ldx #<p0CA2
	stx a0A
	ldx #>p0CA2
	stx a0B
b08B4:
	jsr get_display_string
	jsr get_rowcol_addr
	jsr s0921
	ldy #$00
	lda (string_ptr),y
	and #$7f
b08C3:
	sta (p0A),y
	jsr print_char
	inc a:string_ptr
	bne b08D0
	inc a:string_ptr+1
b08D0:
	inc a0A
	bne b08D6
	inc a0B
b08D6:
	ldy #$00
	lda (string_ptr),y
	bpl b08C3
	lda #$1e
	jsr s1192
	rts

print_display_string:
	jsr get_display_string
print_string:
	jsr get_rowcol_addr
	ldy #$00
	lda (string_ptr),y
	and #$7f
@next_char:
	jsr print_char
	inc a:string_ptr
	bne :+
	inc a:string_ptr+1
:	ldy #$00
	lda (string_ptr),y
	bpl @next_char
	rts

get_display_string:
	sta zp_string_number
	ldx #<display_string_table
	stx a:string_ptr
	ldx #>display_string_table
	stx a:string_ptr+1
	ldy #$00
@scan:
	lda (string_ptr),y
	bmi @found_string
@next_char:
	inc a:string_ptr
	bne @scan
	inc a:string_ptr+1
	bne @scan
@found_string:
	dec zp_string_number
	bne @next_char
	rts

s0921:
	ldy #$27
	lda #$20
b0925:
	sta (p0A),y
	dey
	bpl b0925
	rts

j092B:
	jsr s0CCA
	lda a619C
	cmp #$5a
	bmi b0943
	jsr s0949
warm_start:
	lda a61A5
	beq j092B
	jsr s3347
	jmp j092B

b0943:
	jsr s2640
	jmp warm_start

s0949:
	ldx p6193
	stx count+1
	cmp #$5b
	beq b099D
	jsr s0956
	rts

s0956:
	cmp #$5c
	beq b0975
	cmp #$5e
	beq b0987
	lda count+1
	cmp #$04
	beq b0969
	inc p6193
	bne b096E
b0969:
	ldx #$01
	stx p6193
b096E:
	jsr s1015
	jsr s0B77
	rts

b0975:
	lda count+1
	cmp #$01
	beq b0980
	dec p6193
	bpl b096E
b0980:
	ldx #$04
	stx p6193
	bne b096E
b0987:
	lda count+1
	cmp #$03
	bmi b0995
	dec p6193
	dec p6193
	bpl b096E
b0995:
	inc p6193
	inc p6193
	bpl b096E
b099D:
	lda a6194
	cmp #$03
	bne b09C9
	lda a6195
	cmp #$07
	bne b09C9
	lda a6196
	ldx p6193
	stx count+1
	cmp #$08
	beq b09C3
	cmp #$09
	bne b09C9
	lda count+1
	cmp #$04
	bne b09C9
	beq b09DF
b09C3:
	lda count+1
	cmp #$02
	beq b09DF
b09C9:
	lda a619A
	and #$e0
	bne b09DF
	jsr s127E
	lda #$09
	sta zp_col
	sta zp_row
	lda #$7c
	jsr print_display_string
	rts

b09DF:
	ldx p6193
	dex
	beq b09FA
	dex
	beq b09F5
	dex
	beq b09F0
	dec a6196
	bpl b09FD
b09F0:
	inc a6195
	bpl b09FD
b09F5:
	inc a6196
	bpl b09FD
b09FA:
	dec a6195
b09FD:
	jsr s0A10
	lda a61A5
	beq b0A06
	rts

p0A08=*+$02
b0A06:
	jsr s0B19
p0A09:
	jsr s1015
	jsr s0B77
	rts

s0A10:
	lda a6196
	sta count
	lda a6195
	sta count+1
	lda a6194
	cmp #$03
	bne b0A22
	rts

b0A22:
	bmi b0A27
	jmp j0ABC

b0A27:
	cmp #$02
	beq b0A5D
	lda count+1
	cmp #$03
	beq b0A36
	cmp #$06
	beq b0A43
	rts

b0A36:
	lda count
	cmp #$03
	beq b0A3D
b0A3C:
	rts

b0A3D:
	ldx #$02
	stx a61A5
	rts

b0A43:
	lda count
	cmp #$0a
	beq b0A4A
	rts

b0A4A:
	jsr clear_hgr2
	lda #$00
	sta zp_col
	lda #$09
	sta zp_row
	lda #$29
	jsr print_display_string
	jmp j10B9

b0A5D:
	lda count
	cmp #$05
	beq b0A87
b0A63:
	lda a61A4
	cmp #$3c
	bcs b0A6F
	lda a61A3
	beq b0A3C
b0A6F:
	lda a61AE
	and #$01
	beq b0A3C
	lda a61A5
	bne b0A81
	ldx #$06
	stx a61A5
	rts

b0A81:
	ldx #$06
	stx a61A6
	rts

b0A87:
	lda count+1
	cmp #$05
	beq b0AAF
	cmp #$08
	bne b0A63
	ldx #$03
	stx p6193
	stx a6194
	ldx #<p0508
	stx a6195
	ldx #>p0508
	stx a6196
	ldx #$00
	stx a61A3
	stx a61A4
	jsr s107C
	rts

b0AAF:
	lda a61AF
	and #$01
	beq b0ABB
	ldx #$07
	stx a61A5
b0ABB:
	rts

j0ABC:
	cmp #$04
	beq b0B00
	lda count+1
	cmp #$04
	beq b0AEA
b0AC6:
	lda a61A4
	cmp #$32
	bcs b0AD2
	lda a61A3
	beq b0ABB
b0AD2:
	lda a61AC
	and #$04
	beq b0ABB
	lda a61A5
	bne b0AE4
	ldx #$09
	stx a61A5
	rts

b0AE4:
	ldx #$09
	stx a61A6
	rts

b0AEA:
	lda count
	cmp #$04
	bne b0AC6
	lda a61AB
	and #$02
	beq b0AC6
	jsr s10DC
	ldx #$04
	stx a61A5
	rts

b0B00:
	lda a61A4
	cmp #$50
	bcs b0B0C
	lda a61A3
	beq b0ABB
b0B0C:
	lda a61AD
	and #$02
	beq b0B18
	ldx #$08
	stx a61A5
b0B18:
	rts

s0B19:
	lda a61A4
	cmp #$ff
	beq b0B26
	inc a61A4
	jmp j0B2E

b0B26:
	ldx #$00
	stx a61A4
	inc a61A3
j0B2E:
	lda a6194
	cmp #$05
	beq b0B4F
	lda a61A1
	beq b0B4F
	dec a61A1
	bne b0B4F
	dec a6197
	ldx #$00
	stx a619E
	jsr s10DC
	ldx #$0a
	stx a61A5
b0B4F:
	dec a61A0
	lda a61A0
	cmp #$ff
	bne b0B5C
	dec a619F
b0B5C:
	lda a619F
	ora a61A0
	bne b0B18
j0B64:
	jsr clear_hgr2
	lda #$35
	ldx #$07
	stx zp_col
	ldx #$02
	stx zp_row
	jsr print_display_string
	jmp j10B9

s0B77:
	lda a619F
	bne b0B88
	lda a61A0
	cmp #$0a
	bcs b0B88
	lda #$32
	jsr s0892
b0B88:
	lda a61A1
	beq b0BB2
	cmp #$0a
	bcs b0BB2
	lda #$33
	jsr s08A4
	rts

s0B97:
	lda a619D
	cmp #$12
	bpl b0BB3
	ldx #$06
	stx src+1
	jsr s1A34
	lda count+1
	cmp #$07
	bpl b0BB2
b0BAB:
	pla
	pla
j0BAD:
	lda #$7b
b0BAF:
	jsr s08A4
b0BB2:
	rts

b0BB3:
	cmp #$12
	beq b0BC7
	cmp #$13
	beq b0BD3
	ldx #$0b
	stx src+1
	jsr s1A34
	cmp #$00
	beq b0BAB
	rts

b0BC7:
	ldx #$0c
	stx src+1
	jsr s1A34
	cmp #$00
	beq b0BAB
	rts

b0BD3:
	ldx #$0e
	stx src+1
	jsr s1A34
	cmp #$00
	bne b0BB2
	lda a6194
	cmp #$05
	beq b0BAB
	lda a619E
	beq b0BAB
	ldx #$0d
	stx src+1
	jsr s1A34
	cmp #$00
	bne b0BB2
	lda a6197
	cmp #$01
	bne b0BAB
	pla
	pla
	lda #$98
	bne b0BAF
memcpy:
	ldy #$00
@next_byte:
	lda (src),y
	sta (dst),y
	inc src
	bne :+
	inc src+1
:	inc dst
	bne :+
	inc dst+1
:	dec count
	beq @check_done
	lda count
	cmp #$ff
	bne @next_byte
	dec count+1
	jmp @next_byte

@check_done:
	lda count+1
	ora count
	bne @next_byte
p0C29:
	rts

p0C2A:
	cmp #$50
	bcc b0C31
	jsr s1015
b0C31:
	lda a619E
	beq b0C3E
	ldx #$00
	stx a61B3
	jmp j3493

b0C3E:
	ldx #$00
	stx a61A4
	lda a61B3
	bne b0C71
	lda a6194
	cmp #$05
	beq b0C59
	lda a61AD
	and #$02
	bne b0C5E
b0C56:
	jmp j3493

b0C59:
	lda a61AC
	beq b0C56
b0C5E:
	jsr s3626
	lda #$43
	jsr s0892
	lda #$44
	jsr s08A4
	inc a61B3
	jmp j3608

b0C71:
	cmp #$01
	bne b0C88
	jsr s3626
p0C79=*+$01
p0C7A=*+$02
	inc a61B3
	lda #$45
	jsr s0892
	lda #$47
	jsr s08A4
	jmp j3608

b0C88:
	jsr s3626
	lda a6194
	cmp #$05
	beq b0C9F
	lda #$36
	jsr s0892
	lda #$37
	jsr s08A4
	jmp j10B9

b0C9F:
	lda #$48
p0CA2=*+$01
	jsr s0892
	lda #$4b
b0CA6:
	jsr s08A4
	jmp j10B9

	dex
	bne b0D1E
	lda a619D
	cmp #$11
	beq b0CBD
b0CB6:
	jsr s105F
	lda #$20
	bne b0CA6
b0CBD:
	lda a619C
	cmp #$0e
	beq b0D16
	cmp #$13
	bne b0CB6
	ldx #$04
s0CCA:
	bit hw_STROBE
b0CCD:
	bit hw_KEYBOARD
	bpl b0CCD
	lda hw_KEYBOARD
	and #$7f
	cmp #$40
	bmi b0CDD
	and #$5f
b0CDD:
	pha
	lda #>p0C7A
	sta src+1
	lda #<p0C7A
	sta src
	lda #>p0C2A
	sta dst+1
	lda #<p0C2A
	sta dst
	lda #>p50
	sta count+1
	lda #<p50
	sta count
	jsr memcpy
	jsr s105F
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
	dec zp_row
	jsr get_rowcol_addr
	lda #>p0C79
b0D16:
	sta a:string_ptr+1
	lda #<p0C79
	sta a:string_ptr
b0D1E:
	lda #$80
	ldy #$50
b0D22:
	sta (string_ptr),y
	dey
	bne b0D22
	lda #$00
	sta dst+1
	sta dst
	lda #>p0C79
	sta count+1
	lda #<p0C79
	sta count
	pla
	jmp j0D4F

b0D39:
	bit hw_STROBE
b0D3C:
	jsr blink_cursor
	bit hw_KEYBOARD
	bpl b0D3C
	lda hw_KEYBOARD
	and #$7f
	cmp #$40
	bmi j0D4F
	and #$5f
j0D4F:
	pha
	lda dst+1
	bne b0D7B
	pla
	cmp #$5a
	bne b0D5C
	jmp j0DD1

b0D5C:
	cmp #$58
	bne b0D63
	jmp j0DDD

b0D63:
	cmp #$08
	bne b0D6A
	jmp j0DD9

b0D6A:
	cmp #$15
	bne b0D71
	jmp j0DD5

b0D71:
	cmp #$20
	beq b0D39
	cmp #$0d
	beq b0D39
	bne b0D83
b0D7B:
	pla
	cmp #$08
	bne b0D83
	jmp j0DE8

b0D83:
	cmp #$0d
	bne b0D8A
	jmp j0DE5

b0D8A:
	cmp #$1b
	bne b0DC8
	lda #$00
	sta zp_col
	lda #$16
	sta zp_row
	jsr get_rowcol_addr
	lda #>p0C29
	sta src+1
	lda #<p0C29
	sta src
	ldy #$50
b0DA3:
	lda (src),y
	sta (count),y
	dey
	bne b0DA3
	ldy #<p0150
	sty src
	ldy #>p0150
	sty src+1
b0DB2:
	lda (count),y
	cmp #$80
	bmi b0DBA
	lda #$20
b0DBA:
	jsr s1192
	inc src+1
	ldy src+1
	dec src
	bne b0DB2
	jmp s0CCA

b0DC8:
	cmp #$20
	beq b0E37
	bcs b0E0D
	jmp b0D39

j0DD1:
	lda #$5b
	bne b0DDF
j0DD5:
	lda #$5d
	bne b0DDF
j0DD9:
	lda #$5c
	bne b0DDF
j0DDD:
	lda #$5e
b0DDF:
	sta a619C
	jmp clear_cursor

j0DE5:
	jmp j0E4D

j0DE8:
	jsr clear_cursor
	dec zp_col
	jsr get_rowcol_addr
	lda #$20
	jsr s1192
	dec zp_col
	jsr get_rowcol_addr
	ldy dst+1
	lda (count),y
	cmp #$20
	bne b0E04
	dec dst
b0E04:
	lda #$80
	sta (count),y
	dec dst+1
	jmp b0D39

b0E0D:
	sta row_ptr
	cmp #$41
	bcc b0E23
	ldy dst+1
	beq b0E23
	lda (count),y
	cmp #$20
	beq b0E23
	lda row_ptr
	ora #$20
	bne b0E25
b0E23:
	lda row_ptr
b0E25:
	pha
	jsr s1192
	pla
	inc dst+1
	ldy dst+1
	sta (count),y
	cpy #$1e
	beq j0E4D
	jmp b0D39

b0E37:
	ldy dst+1
	dey
	lda (count),y
	cmp #$20
	bne b0E43
	jmp b0D39

b0E43:
	lda dst
	bne j0E4D
	inc dst
	lda #$20
	bne b0E0D
j0E4D:
	jsr clear_cursor
	lda #$20
	inc dst+1
	ldy dst+1
	sta (count),y
	inc count
	bne b0E5E
	inc count+1
b0E5E:
	jsr s0F6B
	lda dst
	sta a619C
	ldy #$00
b0E68:
	inc count
	bne b0E6E
	inc count+1
b0E6E:
	lda (count),y
	cmp #$20
	bne b0E68
	inc count
	bne b0E7A
	inc count+1
b0E7A:
	lda (count),y
	cmp #$80
	beq b0E84
	cmp #$20
	bne b0E8B
b0E84:
	lda #$00
	sta a619D
	beq b0E93
b0E8B:
	jsr s0F6B
	lda dst
	sta a619D
b0E93:
	lda a619C
	cmp #$1d
	bcc b0EC2
	lda #$8d
	jsr s08A4
	lda #<p0C7A
	sta count
	lda #>p0C7A
	sta count+1
	ldy #$00
b0EA9:
	tya
	pha
	lda (count),y
	cmp #$20
	beq b0EB9
	jsr s1192
	pla
	tay
	iny
	bne b0EA9
b0EB9:
	pla
	lda #$2e
	jsr print_char
	jmp s0CCA

b0EC2:
	cmp #$14
	bcs b0F16
	lda a619D
	beq b0F16
	cmp #$40
	beq b0EDA
	cmp #$1d
	bcc b0EDA
	sec
	sbc #$1c
	sta a619D
b0ED9:
	rts

b0EDA:
	lda #$8f
	jsr s08A4
	lda #<p0C7A
	sta count
	lda #>p0C7A
	sta count+1
	ldy #$00
b0EE9:
	lda (count),y
	cmp #$20
	beq b0EF7
	inc count
	bne b0EE9
	inc count+1
	bne b0EE9
b0EF7:
	inc count
	bne b0EFD
	inc count+1
b0EFD:
	tya
	pha
	lda (count),y
	cmp #$20
	beq b0F0D
	jsr s1192
	pla
	tay
	iny
	bne b0EFD
b0F0D:
	lda #$3f
	jsr s1192
	pla
	jmp s0CCA

b0F16:
	lda a619C
	cmp #$14
	bcs b0ED9
	cmp #$0e
	beq b0F5A
	lda #>p0C7A
	sta count+1
	lda #<p0C7A
	sta count
	lda #$00
	sta zp_col
	lda #$17
	sta zp_row
	jsr get_rowcol_addr
	lda #$1e
	jsr s1192
	ldy #$00
	sty dst+1
	lda (count),y
	and #$5f
	bne b0F49
b0F43:
	lda (count),y
	cmp #$20
	beq b0F52
b0F49:
	jsr s1192
	inc dst+1
	ldy dst+1
	bne b0F43
b0F52:
	lda #$56
	jsr print_display_string
	jmp s0CCA

b0F5A:
	lda a619E
	beq b0F63
	lda #$8b
	bne b0F65
b0F63:
	lda #$8a
b0F65:
	jsr s08A4
	jmp s0CCA

s0F6B:
	lda count+1
	pha
	lda count
	pha
	lda #>p6694
	sta src+1
	lda #<p6694
	sta src
	lda #$00
	sta dst
j0F7D:
	ldy #$01
b0F7F:
	lda (src),y
	and #$80
	bne b0F8D
	inc src
	bne b0F7F
	inc src+1
	bne b0F7F
b0F8D:
	dey
	lda (src),y
	cmp #$2a
	beq b0F96
	inc dst
b0F96:
	inc src
	bne b0F9C
	inc src+1
b0F9C:
	lda #$04
	sta dst+1
b0FA0:
	lda (src),y
	and #$5f
	sta row_ptr
	lda (count),y
	and #$5f
	cmp row_ptr
	bne b0FC5
	inc count
	bne b0FB4
	inc count+1
b0FB4:
	inc src
	bne b0FBA
	inc src+1
b0FBA:
	dec dst+1
	bne b0FA0
b0FBE:
	pla
	sta count
	pla
	sta count+1
	rts

b0FC5:
	lda dst
	cmp #$3f
	beq b0FD8
	pla
	sta count
	pla
	sta count+1
	pha
	lda count
	pha
	jmp j0F7D

b0FD8:
	inc dst
	bne b0FBE
s0FDC:
	ldx #$90
	stx src+1
b0FE0:
	dec src
	bne b0FE0
	dec src+1
	bne b0FE0
	rts

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

s1015:
	jsr s127E
	jsr s17BF
	lda a619E
	beq b1044
	jsr s12A6
	jsr s1DDF
	lda src+1
	ora src
	beq b102F
	jsr s1E5A
b102F:
	ldx #$0a
	stx src+1
	jsr s1A34
	lda a619B
	beq b1044
	sta src
	ldx #$06
	stx src+1
	jsr s1E5A
b1044:
	rts

s1045:
	ldx #>p0500
	stx dst
b1049:
	ldx #<p0500
	stx src+1
b104D:
	dec src
	bne b104D
	dec src+1
	bne b104D
	dec dst
	bne b1049
	rts

j105A:
	lda #$55
	jmp s08A4

s105F:
	pha
	ldx #$00
	stx zp_col
	ldx #$16
	stx zp_row
	jsr get_rowcol_addr
	lda #$1e
	jsr s1192
	inc zp_row
	jsr get_rowcol_addr
	lda #$1e
	jsr s1192
	pla
	rts

s107C:
	jsr s127E
	ldx #$05
	stx zp_col
	ldx #$08
	stx zp_row
	jsr get_rowcol_addr
	lda #$a7
	jsr print_display_string
	jsr s0FDC
	ldx #$05
	stx zp_col
	inc zp_row
	jsr get_rowcol_addr
	lda #$2c
	jsr print_display_string
	jsr s1045
	jsr s127E
	ldx #$09
	stx zp_col
	ldx #$08
	stx zp_row
	jsr get_rowcol_addr
	lda #$2d
	jsr print_display_string
	jmp s1045

j10B9:
	jsr s1045
	jsr s105F
	lda #$34
	jsr s0892
j10C4:
	lda #$39
	jsr s08A4
	jsr input_Y_or_N
	cmp #$59
	bne b10D3
	jmp j080C

b10D3:
	bit aC054
	bit aC051
	jmp eFF69

s10DC:
	lda a61A6
b10E1=*+$02
	sta a61A7
	lda a61A5
	sta a61A6
	rts

	sta f61,x
	jsr s107C
	jsr s1015
	jmp j3493

	rts

	stx src+1
	jsr s1A34
	lda #$06
	cmp count+1
	beq b110D
	dec dst+1
	bne b10E1
	pla
	sta src
	pla
	sta src+1
	jmp j2EFB

b110D:
	pla
	sta src
	pla
	sta src+1
	lda a619D
	cmp #$13
	beq b111D
	jmp j2E72

b111D:
	inc a6198
	jmp j2E72

	dec src+1
	bne b1148
	lda src
	cmp #$11
	beq b1142
	cmp #$15
	bpl b1134
	jmp j105A

b1134:
	cmp #$1a
	bmi b113B
	jmp j105A

b113B:
	cmp #$17
	bne b1142
	jmp j105A

b1142:
	lda #$90
	jsr s08A4
	rts

b1148:
	dec src+1
	bne b1164
	ldx #<p0602
	stx src
	ldx #>p0602
	stx src+1
	jsr s1A34
	lda count+1
	cmp #$08
b115C=*+$01
	beq b1160
	jmp j0BAD

b1160:
	lda #$6f
row8_table:
	.byte $40,$00
b1164:
	.byte $40,$80,$41,$00,$41,$80,$42,$00
	.byte $42,$80,$43,$00,$43,$80,$40,$28
	.byte $40,$a8,$41,$28,$41,$a8,$42,$28
	.byte $42,$a8,$43,$28,$43,$a8,$40,$50
	.byte $40,$d0,$41,$50,$41,$d0,$42,$50
	.byte $42,$d0,$43,$50,$43
s1192=*+$01
	bne b115C
	asl
	beq b120C
	cmp #$1e
	bne b119D
	jmp j121E

b119D:
	cmp #$c0
	bcc print_char
	jmp j1226

print_char:
	sta row_ptr
	lda #$00
	sta row_ptr+1
	asl row_ptr
	rol row_ptr+1
	asl row_ptr
	rol row_ptr+1
	asl row_ptr
	rol row_ptr+1
	clc
	lda #<font
	adc row_ptr
	sta row_ptr
	lda #>font
	adc row_ptr+1
	sta row_ptr+1
	ldx #$00
	ldy #$00
	lda #$08
	sta line_count
	clc
@next_line:
	lda (row_ptr),y
	sta (screen_ptr,x)
	lda #$04
	adc screen_ptr+1
	sta screen_ptr+1
	iny
	dec line_count
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
	sta row_ptr
	lda #$00
	adc #>row8_table
	sta row_ptr+1
	ldy #$01
	clc
	lda (row_ptr),y
	adc zp_col
	sta screen_ptr
	dey
	lda (row_ptr),y
	sta screen_ptr+1
	rts

b120C:
	jsr clear_cursor
	lda #$17
	cmp zp_row
	beq b1217
	inc zp_row
b1217:
	lda #$00
	sta zp_col
	jmp get_rowcol_addr

j121E:
	lda #$28
	sec
	sbc zp_col
	jmp j1229

j1226:
	sec
	sbc #$c0
j1229:
	sta a16
	lda zp_col
	pha
	lda zp_row
	pha
b1231:
	lda #$20
	jsr print_char
	dec a16
	bne b1231
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

s127E:
	lda #$00
	sta zp_col
	lda #$14
	sta zp_row
b1286:
	jsr get_rowcol_addr
	clc
	lda #$08
	sta count
b128E:
	lda #$00
	ldy #$16
b1292:
	sta (screen_ptr),y
	dey
	bpl b1292
	lda #$04
	adc screen_ptr+1
	sta screen_ptr+1
	dec count
	bne b128E
	dec zp_row
	bpl b1286
	rts

s12A6:
	lda a619A
	lsr
	lsr
	lsr
	lsr
	lsr
	pha
	cmp #$05
	bcc b12C3
	lda #<p4133
	sta screen_ptr
	lda #>p4133
	sta screen_ptr+1
	lda #$05
	jsr s1192
	jmp j135C

b12C3:
	cmp #$04
	bne b12E0
	lda #<p4132
	sta screen_ptr
	lda #>p4132
	sta screen_ptr+1
	ldy #$01
	jsr s1777
	lda #$5d
	sta screen_ptr+1
	ldy #$01
	jsr s1777
	jmp j135C

b12E0:
	cmp #$03
	bne b12FD
	lda #>p40B1
	sta screen_ptr+1
	lda #<p40B1
	sta screen_ptr
	ldy #$03
	jsr s1777
	lda #$5d
	sta screen_ptr+1
	ldy #$03
	jsr s1777
	jmp j1430

b12FD:
	cmp #$02
	bne b131E
	lda #>p4387
	sta screen_ptr+1
	lda #<p4387
	sta screen_ptr
	ldy #$07
	jsr s1777
	lda #>p5EAF
	sta screen_ptr+1
	lda #<p5EAF
	sta screen_ptr
	ldy #$07
	jsr s1777
	jmp j1518

b131E:
	cmp #$01
	bne b133F
	lda #>p4204
	sta screen_ptr+1
	lda #<p4204
	sta screen_ptr
	ldy #$0d
	jsr s1777
	lda #>p5C54
	sta screen_ptr+1
	lda #<p5C54
	sta screen_ptr
	ldy #$0d
	jsr s1777
	jmp p1600

b133F:
	lda #>screen_HGR2
	sta screen_ptr+1
	lda #<screen_HGR2
	sta screen_ptr
	ldy #$15
	jsr s1777
	lda #>p5E50
	sta screen_ptr+1
	lda #<p5E50
	sta screen_ptr
	ldy #$15
	jsr s1777
	jmp j16E8

j135C:
	lda a6199
	and #$10
	bne b139C
	pla
	pha
	cmp #$04
	beq b1376
	lda #>p4132
	sta screen_ptr+1
	lda #<p4132
	sta screen_ptr
	lda #$04
	jsr s1192
b1376:
	lda #>p4131
	sta screen_ptr+1
	lda #<p4131
	sta screen_ptr
	ldy #$01
	jsr s1777
	lda #$5d
	sta screen_ptr+1
	ldy #$01
	jsr s1777
	lda #$09
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$03
	jsr s17A7
	jmp j13C5

b139C:
	pla
	pha
	cmp #$04
	bne b13AF
	lda #>p4132
	sta screen_ptr+1
	lda #<p4132
	sta screen_ptr
	lda #$04
	jsr s1192
b13AF:
	lda #$0a
	sta zp_col
	lda #$09
	sta zp_row
	ldy #$01
	jsr s1795
	dec zp_col
	inc zp_row
	ldy #$01
	jsr s177F
j13C5:
	lda a619A
	and #$10
	bne b1407
	pla
	pha
	cmp #$04
	beq b13DF
	lda #>p4134
	sta screen_ptr+1
	lda #<p4134
	sta screen_ptr
	lda #$03
	jsr s1192
b13DF:
	lda #>p4133
	sta screen_ptr+1
	lda #<p4133
	sta screen_ptr
	ldy #$01
	jsr s1777
	lda #$5d
	sta screen_ptr+1
	ldy #$01
	jsr s1777
	lda #$0d
	sta zp_col
	lda #$09
	sta zp_row
	lda #$03
p1400=*+$01
	ldy #$03
	jsr s17A7
	jmp j1430

b1407:
	pla
	pha
	cmp #$04
	bne b141A
	lda #>p4134
	sta screen_ptr+1
	lda #<p4134
	sta screen_ptr
	lda #$03
	jsr s1192
b141A:
	lda #$0c
	sta zp_col
	lda #$09
	sta zp_row
	ldy #$01
	jsr s177F
	inc zp_col
	inc zp_row
	ldy #$01
	jsr s1795
j1430:
	lda a6199
	and #$08
	bne b1474
	pla
	pha
	cmp #$03
	beq b144A
	lda #$09
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$03
	jsr s17A7
b144A:
	lda #>p40AF
	sta screen_ptr+1
	lda #<p40AF
	sta screen_ptr
	ldy #$02
	jsr s1777
	lda #>p5DAF
	sta screen_ptr+1
	lda #<p5DAF
	sta screen_ptr
	ldy #$02
	jsr s1777
	lda #$07
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$07
	jsr s17A7
	jmp j14A1

b1474:
	pla
	pha
	cmp #$03
	bne b1487
	lda #$09
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$03
	jsr s17A7
b1487:
	lda #$08
	sta zp_col
	lda #$07
	sta zp_row
	ldy #$02
	jsr s1795
	lda #$09
	sta zp_col
	lda #$0c
	sta zp_row
	ldy #$02
	jsr s177F
j14A1:
	lda a619A
	and #$08
	bne b14E9
	pla
	pha
	cmp #$03
	beq b14BD
	lda #$0d
	sta zp_col
	lda #$09
	sta zp_row
	lda #$03
	ldy #$03
	jsr s17A7
b14BD:
	lda #>p40B4
	sta screen_ptr+1
	lda #<p40B4
	sta screen_ptr
	ldy #$02
	jsr s1777
	lda #>p5DB4
	sta screen_ptr+1
	lda #<p5DB4
	sta screen_ptr
	ldy #$02
	jsr s1777
	lda #$0f
	sta zp_col
	lda #$07
	sta zp_row
	lda #$03
	ldy #$07
	jsr s17A7
	jmp j1518

b14E9:
	pla
	pha
	cmp #$03
	bne b14FE
	lda #$0d
	sta zp_col
	lda #$09
	sta zp_row
	lda #$03
	ldy #$03
	jsr s17A7
b14FE:
	lda #$0e
p1500:
	sta zp_col
	lda #$07
	sta zp_row
	ldy #$02
	jsr s177F
	lda #$0d
	sta zp_col
	lda #$0c
	sta zp_row
	ldy #$02
	jsr s1795
j1518:
	lda a6199
	and #$04
	bne b155C
	pla
	pha
	cmp #$02
	beq b1532
	lda #$07
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$07
	jsr s17A7
b1532:
	lda #>p4384
	sta screen_ptr+1
	lda #<p4384
	sta screen_ptr
	ldy #$03
	jsr s1777
	lda #>p5EAC
	sta screen_ptr+1
	lda #<p5EAC
	sta screen_ptr
	ldy #$03
	jsr s1777
	lda #$04
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$0d
	jsr s17A7
	jmp j1589

b155C:
	pla
	pha
	cmp #$02
	bne b156F
	lda #$07
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$07
	jsr s17A7
b156F:
	lda #$05
	sta zp_col
	lda #$04
	sta zp_row
	ldy #$03
	jsr s1795
	lda #$07
	sta zp_col
	lda #$0e
	sta zp_row
	ldy #$03
	jsr s177F
j1589:
	lda a619A
	and #$04
	bne b15D1
	pla
	pha
	cmp #$02
	beq b15A5
	lda #$0f
	sta zp_col
	lda #$07
	sta zp_row
	lda #$03
	ldy #$07
	jsr s17A7
b15A5:
	lda #>p438E
	sta screen_ptr+1
	lda #<p438E
	sta screen_ptr
	ldy #$03
	jsr s1777
	lda #>p5EB6
	sta screen_ptr+1
	lda #<p5EB6
	sta screen_ptr
	ldy #$03
	jsr s1777
	lda #$12
	sta zp_col
	lda #$04
	sta zp_row
	lda #$03
	ldy #$0d
	jsr s17A7
	jmp p1600

b15D1:
	pla
	pha
	cmp #$02
	bne b15E6
	lda #$0f
	sta zp_col
	lda #$07
	sta zp_row
	lda #$03
	ldy #$07
	jsr s17A7
b15E6:
	lda #$11
	sta zp_col
	lda #$04
	sta zp_row
	ldy #$03
	jsr s177F
	lda #$0f
	sta zp_col
	lda #$0e
	sta zp_row
	ldy #$03
	jsr s1795
p1600:
	lda a6199
	and #$02
	bne b1644
	pla
	pha
	cmp #$01
	beq b161A
	lda #$04
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$0d
	jsr s17A7
b161A:
	lda #>p4200
	sta screen_ptr+1
	lda #<p4200
	sta screen_ptr
	ldy #$04
	jsr s1777
	lda #>p5C50
	sta screen_ptr+1
	lda #<p5C50
	sta screen_ptr
	ldy #$04
	jsr s1777
	lda #$00
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$15
	jsr s17A7
	jmp j1671

b1644:
	pla
	pha
	cmp #$01
	bne b1657
	lda #$04
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$0d
	jsr s17A7
b1657:
	lda #$01
	sta zp_col
	lda #$00
	sta zp_row
	ldy #$04
	jsr s1795
	lda #$04
	sta zp_col
	lda #$11
	sta zp_row
	ldy #$04
	jsr s177F
j1671:
	lda a619A
	and #$02
	bne b16B9
	pla
	pha
	cmp #$01
	beq b168D
	lda #$12
	sta zp_col
	lda #$04
	sta zp_row
	lda #$03
	ldy #$0d
	jsr s17A7
b168D:
	lda #>p4211
	sta screen_ptr+1
	lda #<p4211
	sta screen_ptr
	ldy #$04
	jsr s1777
	lda #>p5C61
	sta screen_ptr+1
	lda #<p5C61
	sta screen_ptr
	ldy #$04
	jsr s1777
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #$03
	ldy #$15
	jsr s17A7
	jmp j16E8

b16B9:
	pla
	pha
	cmp #$01
	bne b16CE
	lda #$12
	sta zp_col
	lda #$04
	sta zp_row
	lda #$03
	ldy #$0d
	jsr s17A7
b16CE:
	lda #$15
	sta zp_col
	lda #$00
	sta zp_row
	ldy #$04
	jsr s177F
	lda #$12
	sta zp_col
	lda #$11
	sta zp_row
	ldy #$04
	jsr s1795
j16E8:
	pla
	cmp #$00
	beq b174C
	lda a6199
	and #$01
	bne b171B
	lda #$00
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$15
p1700=*+$02
	jsr s17A7
	lda #>p3FFF
	sta screen_ptr+1
	lda #<p3FFF
	sta screen_ptr
	ldy #$01
	jsr s1777
	lda #>p5E4F
	sta screen_ptr+1
	lda #<p5E4F
	sta screen_ptr
	ldy #$01
	jsr s1777
b171B:
	lda a619A
	and #$01
	bne b174B
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #$03
	ldy #$15
	jsr s17A7
	lda #>p4015
	sta screen_ptr+1
	lda #<p4015
	sta screen_ptr
	ldy #$01
	jsr s1777
	lda #>p5E65
	sta screen_ptr+1
	lda #<p5E65
	sta screen_ptr
	ldy #$01
	jsr s1777
b174B:
	rts

b174C:
	lda a6199
	and #$01
	beq b1760
	lda #$00
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$15
	jsr s17A7
b1760:
	lda a619A
	and #$01
	beq b174B
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #$03
	ldy #$15
	jsr s17A7
	rts

s1777:
	lda #$ff
b1779:
	sta (screen_ptr),y
	dey
	bne b1779
	rts

s177F:
	tya
	sta count+1
b1782:
	jsr get_rowcol_addr
	lda #$02
	jsr s1192
	dec zp_col
	dec zp_col
	inc zp_row
	dec count+1
	bne b1782
	rts

s1795:
	tya
	sta count+1
b1798:
	jsr get_rowcol_addr
	lda #$01
	jsr s1192
	inc zp_row
	dec count+1
	bne b1798
	rts

s17A7:
	pha
	tya
	sta count+1
	pla
b17AC:
	pha
	jsr get_rowcol_addr
	pla
	pha
	jsr print_char
	pla
	dec zp_col
	inc zp_row
	dec count+1
	bne b17AC
	rts

s17BF:
	ldy #$00
	lda #<p6000
	sta a0A
	lda #>p6000
	sta a0B
	ldx a6194
	lda #$00
	clc
j17CF:
	dex
	beq b17D7
	adc #$21
	jmp j17CF

b17D7:
	adc a0A
	sta a0A
	ldx a6195
j17DE:
	dex
	beq b17EA
	inc a0A
	inc a0A
	inc a0A
	jmp j17DE

b17EA:
	lda a6196
	cmp #$05
	bmi b17FF
	cmp #$09
	bmi b17FA
	inc a0A
	sec
	sbc #$04
b17FA:
	inc a0A
	sec
	sbc #$04
b17FF:
	tax
	lda #$80
j1802:
	dex
	beq b180A
	lsr
	lsr
	jmp j1802

b180A:
	sta count+1
	stx count
	stx dst+1
	stx a6199
	stx a619A
	ldx p6193
	dex
	bne b181F
	jmp j1910

b181F:
	dex
	bne b1825
	jmp j197C

b1825:
	dex
	beq b18A7
j1828:
	lda (p0A),y
	and count+1
	bne b184C
	inc count
	lda count
	cmp #$05
	beq b184C
	lda count+1
	cmp #$80
	bne b1845
	dec a0A
	lda #$02
	sta count+1
	jmp j1828

b1845:
	asl count+1
	asl count+1
	jmp j1828

b184C:
	lda count
	jsr s1A10
	lsr count+1
j1853:
	lda (p0A),y
	and count+1
	beq b185C
	inc a619A
b185C:
	ldy #$03
	lda (p0A),y
	ldy #$00
	and count+1
	beq b1869
	inc a6199
b1869:
	jsr s1A10
	cmp dst+1
	beq b189A
	jsr s1A10
	lda #$04
	cmp dst+1
	beq b1897
	asl a6199
	asl a619A
	inc dst+1
	lda count+1
	cmp #$01
	beq b188E
	lsr count+1
	lsr count+1
	jmp j1853

b188E:
	lda #$40
	sta count+1
	inc a0A
	jmp j1853

b1897:
	jsr s1A10
b189A:
	asl
	asl
	asl
	asl
	asl
	clc
	adc a619A
	sta a619A
	rts

b18A7:
	lsr count+1
b18A9:
	clc
	lda a0A
	adc #$03
	sta a0A
	lda (p0A),y
	and count+1
	bne b18BE
	inc count
	lda count
	cmp #$05
	bne b18A9
b18BE:
	lda count
	jsr s1A10
	lda count+1
	sta count
	asl count+1
	clc
	ror count
	bcc b18D0
	ror count
b18D0:
	dec a0A
	dec a0A
	dec a0A
	lda (p0A),y
	and count+1
	beq b18DF
	inc a619A
b18DF:
	lda count
	cmp #$80
	beq b18EA
	lda (p0A),y
	jmp j18EE

b18EA:
	iny
	lda (p0A),y
	dey
j18EE:
	and count
	beq b18F5
	inc a6199
b18F5:
	lda dst+1
	cmp #$04
b18F9:
	beq b1897
	jsr s1A10
	cmp dst+1
b1900:
	beq b189A
	jsr s1A10
	inc dst+1
	asl a6199
	asl a619A
	jmp b18D0

j1910:
	lsr count+1
j1912:
	lda (p0A),y
	and count+1
	bne b1929
	inc count
	lda count
	cmp #$05
	beq b1929
	dec a0A
	dec a0A
	dec a0A
	jmp j1912

b1929:
	lda count
	jsr s1A10
	lda count+1
	sta count
	asl count+1
	clc
	ror count
	bcc b193B
	ror count
b193B:
	lda (p0A),y
	and count+1
	beq b1944
	inc a6199
b1944:
	lda count
	cmp #$80
	bne b194C
	inc a0A
b194C:
	lda (p0A),y
	and count
	beq b1955
	inc a619A
b1955:
	lda count
	cmp #$80
	beq b195D
	inc a0A
b195D:
	inc a0A
	inc a0A
	jsr s1A10
	cmp dst+1
	beq b1900
	jsr s1A10
	lda #$04
	cmp dst+1
b196F:
	beq b18F9
	inc dst+1
	asl a6199
	asl a619A
	jmp b193B

j197C:
	lda count+1
	cmp #$02
	bne b198B
	lda #$80
	sta count+1
	inc a0A
	jmp j198F

b198B:
	lsr count+1
	lsr count+1
j198F:
	lda (p0A),y
	and count+1
	bne b19B3
	inc count
	lda count
	cmp #$05
	beq b19B3
	lda count+1
	cmp #$02
	bne b19AC
	inc a0A
	lda #$80
	sta count+1
	jmp j198F

b19AC:
	lsr count+1
	lsr count+1
	jmp j198F

b19B3:
	lda count+1
	cmp #$80
	beq b19BE
	asl count+1
	jmp j19C4

b19BE:
	dec a0A
	lda #$01
	sta count+1
j19C4:
	lda count
	jsr s1A10
j19C9:
	lda (p0A),y
	and count+1
	beq b19D2
	inc a6199
b19D2:
	ldy #$03
	lda (p0A),y
	ldy #$00
	and count+1
	beq b19DF
	inc a619A
b19DF:
	lda #$04
	cmp dst+1
	beq b196F
	jsr s1A10
	cmp dst+1
	bne b19EF
	jmp b189A

b19EF:
	jsr s1A10
	asl a6199
	inc dst+1
	asl a619A
	lda count+1
	cmp #$40
	beq b1A07
	asl count+1
	asl count+1
	jmp j19C9

b1A07:
	lda #$01
	sta count+1
	dec a0A
	jmp j19C9

s1A10:
	sta row_ptr
	lda a61F7
	pha
	lda row_ptr
	sta a61F7
	pla
	rts

; junk
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00
s1A34:
	lda src+1
	cmp #$07
	bpl b1A93
	asl src
	pha
	lda #$00
	sta src+1
	clc
	lda #$b9
	adc src
	sta src
	lda #$61
	adc src+1
	sta src+1
	pla
	cmp #$05
	bpl b1A6E
	cmp #$00
	beq b1A5F
	sec
	sbc #$01
	beq b1A5F
	clc
	adc #$05
b1A5F:
	ldy #$00
	sta (src),y
	inc src
	bne b1A69
	inc src+1
b1A69:
	lda #$00
	sta (src),y
	rts

b1A6E:
	cmp #$05
	beq b1A7E
	ldy #$00
	lda (src),y
	sta count+1
	iny
	lda (src),y
	sta count
	rts

b1A7E:
	lda a6194
	ldy #$00
	sta (src),y
	lda a6195
	asl
	asl
	asl
	asl
	ora a6196
	iny
	sta (src),y
	rts

b1A93:
	sec
	sbc #$07
	beq b1A9B
	jmp j1BB5

b1A9B:
	lda #$0f
	sta count+1
	lda #$19
	sta zp_col
	lda #$03
	sta zp_row
b1AA7:
	jsr get_rowcol_addr
	lda #$1e
	jsr s1192
	inc zp_row
	dec count+1
	bne b1AA7
	lda #$14
	sta count+1
	lda #<p61BB
	sta src
	lda #>p61BB
	sta src+1
	lda #$1a
	sta zp_col
	lda #$03
	sta zp_row
	jsr get_rowcol_addr
	lda #$01
	jsr print_display_string
	lda #$1b
	sta zp_col
	lda #$04
	sta zp_row
	jsr get_rowcol_addr
b1ADC:
	ldy #$00
	lda (src),y
	cmp #$08
	bne b1AE7
	jmp j1B76

b1AE7:
	cmp #$07
	bne b1AEE
	jmp j1B76

b1AEE:
	inc src
	bne b1AF4
	inc src+1
b1AF4:
	inc src
	bne b1AFA
	inc src+1
b1AFA:
	dec count+1
	bne b1ADC
	lda #<p61BB
	sta src
	lda #>p61BB
	sta src+1
	lda #$17
	sta count+1
b1B0A:
	ldy #$00
	lda (src),y
	cmp #$06
	bne b1B15
	jmp j1B9C

b1B15:
	inc src
	bne b1B1B
	inc src+1
b1B1B:
	inc src
	bne b1B21
	inc src+1
b1B21:
	dec count+1
	bne b1B0A
	lda #$1a
	sta zp_col
	lda #$10
	sta zp_row
	jsr get_rowcol_addr
	lda #$02
	jsr print_display_string
	lda #$1b
	sta zp_col
	lda #$11
	sta zp_row
	jsr get_rowcol_addr
	lda #$03
	jsr print_display_string
	inc zp_col
	inc zp_col
	inc zp_col
	jsr get_rowcol_addr
	lda a6197
	clc
	adc #$30
	jsr s1192
	lda #$1b
	sta zp_col
	lda #$12
	sta zp_row
	jsr get_rowcol_addr
	lda #$04
	jsr print_display_string
	lda #$20
	jsr s1192
	lda a6198
	clc
	adc #$30
	jsr s1192
	rts

j1B76:
	lda #$15
	sec
	sbc count+1
	cmp #$12
	bmi b1B81
	lda #$12
b1B81:
	sta row_ptr
	lda zp_col
	pha
	lda zp_row
	pha
	lda row_ptr
	jsr s25E3
	pla
	sta zp_row
	inc zp_row
	pla
	sta zp_col
	jsr get_rowcol_addr
	jmp b1AEE

j1B9C:
	lda zp_col
	pha
	lda zp_row
	pha
	lda #$14
	jsr s25E3
	pla
	sta zp_row
	inc zp_row
	pla
	sta zp_col
	jsr get_rowcol_addr
	jmp b1B15

j1BB5:
	sta count+1
	dec count+1
	bne b1BE8
	lda #>p61BB
	sta src+1
	lda #<p61BB
	sta src
	lda #>p1400
	sta count+1
	lda #<p1400
	sta count
	ldy #$00
b1BCD:
	lda (src),y
	cmp #$06
	bmi b1BD5
	inc count
b1BD5:
	iny
	iny
	dec count+1
	bne b1BCD
	lda a61A1
	bne b1BE5
	lda a6198
	beq b1BE7
b1BE5:
	inc count
b1BE7:
	rts

b1BE8:
	dec count+1
	bne b1C06
	ldy #$55
	lda #>p613D
	sta src+1
	lda #<p613D
	sta src
	lda #<p6193
	sta dst
	lda #>p6193
	sta dst+1
b1BFE:
	lda (src),y
	sta (dst),y
	dey
	bpl b1BFE
	rts

b1C06:
	dec count+1
	bne b1C0D
	jmp j1D0E

b1C0D:
	dec count+1
	beq b1C14
	jmp j1CAF

b1C14:
	lda a6195
	asl
	asl
	asl
	asl
	clc
	adc a6196
	sta dst+1
	lda #>p61BC
	sta src+1
	lda #<p61BC
	sta src
	lda #$17
	sta count+1
	ldy #$00
	lda dst+1
b1C31:
	cmp (src),y
	beq b1C7E
j1C35:
	iny
	iny
	dec count+1
	bne b1C31
	lda #>p61BB
	sta src+1
	lda #<p61BB
	sta src
	lda #$10
	sta count+1
	lda #$06
	ldy #$00
b1C4B:
	cmp (src),y
	beq b1C94
	iny
	iny
	dec count+1
	bne b1C4B
	lda #>p61DD
	sta src+1
	lda #<p61DD
	sta src
	lda #$06
	sta count+1
	ldy #$00
b1C63:
	cmp (src),y
	beq b1C94
	iny
	iny
	dec count+1
	bne b1C63
	ldx #>p61DB
	stx src+1
	ldx #<p61DB
	stx src
	ldy #$00
	cmp (src),y
	beq b1C94
	lda #$00
	rts

b1C7E:
	dec src
	lda (src),y
	sta row_ptr
	inc src
	dey
	lda row_ptr
	cmp a6194
	beq b1C94
	iny
	lda dst+1
	jmp j1C35

b1C94:
	clc
	tya
	bpl b1C9A
	lda #$00
b1C9A:
	adc src
	sta src
	lda #$00
	adc src+1
	sta src+1
	sec
	lda src
	sbc #$bb
	clc
	ror
	clc
	adc #$01
	rts

j1CAF:
	dec count+1
	bne b1CE8
	lda #>p0308
	sta dst+1
	lda #<p0308
	sta dst
	lda #>p0612
	sta src+1
	lda #<p0612
	sta src
b1CC3:
	lda src+1
	pha
	lda src
	pha
	jsr s1A34
	lda dst
	cmp count+1
	beq b1CE1
	pla
	sta src
	pla
	sta src+1
	inc src
	dec dst+1
	bne b1CC3
	lda #$00
	rts

b1CE1:
	pla
	sta src
	pla
	lda src
	rts

b1CE8:
	dec count+1
	bne b1CF6
	lda #>p0307
	sta dst+1
	lda #<p0307
	sta dst
	bne b1D02
b1CF6:
	dec count+1
	bne b1D0D
	lda #>p0308
	sta dst+1
	lda #<p0308
	sta dst
b1D02:
	lda #>p0615
	sta src+1
	lda #<p0615
	sta src
	jsr b1CC3
b1D0D:
	rts

j1D0E:
	lda a619A
	and #$e0
	lsr
	lsr
	lsr
	lsr
	lsr
	beq b1D35
	cmp #$05
	bne b1D21
	sec
	sbc #$01
b1D21:
	sta count+1
	lda a6195
	sta dst+1
	lda a6196
	sta dst
	lda a6194
	sta count
	jmp j1D3B

b1D35:
	lda #$00
	sta a619B
	rts

j1D3B:
	lda count+1
	sta src+1
	lda #$00
	sta src
j1D43:
	lda p6193
	jsr s1DC7
	jsr s1D69
	dec count+1
	beq b1D55
	lsr src
	jmp j1D43

b1D55:
	lda #$04
	sec
	sbc src+1
	beq b1D63
b1D5C:
	lsr src
	sec
	sbc #$01
	bne b1D5C
b1D63:
	lda src
	sta a619B
	rts

s1D69:
	pha
	lda dst+1
	pha
	lda dst
	pha
	lda src+1
	pha
	lda src
	pha
	lda dst+1
	asl
	asl
	asl
	asl
	clc
	adc dst
	pha
	lda #>p61BC
	sta src+1
	lda #<p61BC
	sta src
	lda #$17
	sta dst+1
	pla
	ldy #$00
b1D8F:
	cmp (src),y
	beq b1DA7
j1D93:
	iny
	iny
	dec dst+1
	bne b1D8F
	pla
	sta src
	pla
	sta src+1
b1D9F:
	pla
	sta dst
	pla
	sta dst+1
	pla
	rts

b1DA7:
	sta dst
	dec src
	lda (src),y
	inc src
	cmp count
	beq b1DB8
	lda dst
	jmp j1D93

b1DB8:
	pla
	sta src
	pla
	sta src+1
	lda src
	clc
	adc #$08
	sta src
	bne b1D9F
s1DC7:
	cmp #$01
	beq b1DD6
	cmp #$02
	beq b1DD9
	cmp #$03
	beq b1DDC
	dec dst
	rts

b1DD6:
	dec dst+1
	rts

b1DD9:
	inc dst
	rts

b1DDC:
	inc dst+1
	rts

s1DDF:
	lda p6193
	asl
	asl
	asl
	asl
	clc
	adc a6194
	sta dst+1
	lda a6195
	asl
	asl
	asl
	asl
	clc
	adc a6196
	sta dst
	lda #>p60A5
	sta src+1
	lda #<p60A5
	sta src
	lda #$26
	sta count
	ldy #$00
	lda dst+1
b1E09:
	cmp (src),y
	beq b1E1C
	iny
b1E0E:
	iny
	iny
	iny
	dec count
	bne b1E09
	lda #$00
	sta src+1
	sta src
	rts

b1E1C:
	lda dst
	iny
	cmp (src),y
	beq b1E27
	lda dst+1
	bne b1E0E
b1E27:
	iny
	lda (src),y
	sta dst+1
	iny
	lda (src),y
	sta src
	lda dst+1
	sta src+1
	rts

p1E36:
	.byte $06,$0b,$0b,$07,$0b,$0b,$0b,$0b
	.byte $0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b
	.byte $08,$0b,$0b,$09,$20,$0b,$0b,$20
	.byte $20,$0b,$0b,$20,$0b,$0b,$0b,$0b
	.byte $0b,$0b,$0b,$0b
s1E5A:
	ldy src+1
	dey
	bne b1EA1
	lda #$09
	sta count+1
	sta zp_col
	lda #$06
	sta zp_row
	jsr get_rowcol_addr
	lda #>p1E36
	sta a0B
	lda #<p1E36
	sta a0A
	ldy #$00
j1E76:
	lda #$04
	sta count
b1E7A:
	tya
	pha
	lda (p0A),y
	jsr print_char
	pla
	tay
	iny
	dec count
	bne b1E7A
	dec count+1
	beq b1EA0
	tya
	pha
	inc zp_row
	dec zp_col
	dec zp_col
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	pla
	tay
	jmp j1E76

b1EA0:
	rts

b1EA1:
	dey
	bne b1F1B
	lda #$03
	sta zp_row
	lda #$05
	sta zp_col
	lda #$04
	ldy #$12
	jsr s17A7
	lda #$03
	sta zp_row
	lda #$0a
	sta zp_col
	lda #$04
	ldy #$12
	jsr s17A7
	lda #$03
	sta zp_row
	lda #$10
	sta zp_col
	lda #$03
	ldy #$12
	jsr s17A7
	lda #>p5E50
	sta screen_ptr+1
	lda #<p5E50
	sta screen_ptr
	ldy #$14
	jsr s1777
	lda #<p5D05
	sta screen_ptr
	lda #>p5D05
	sta screen_ptr+1
	ldy #$0a
	jsr s1777
	lda #$07
	sta zp_col
	lda #$01
	sta zp_row
	jsr get_rowcol_addr
	lda #>string_elevator
	sta a0B
	lda #<string_elevator
	sta a0A
	ldy #$00
	lda #$08
	sta count+1
b1F04:
	tya
	pha
	lda (p0A),y
	jsr print_char
	pla
	tay
	iny
	dec count+1
	bne b1F04
	rts

string_elevator:
	.byte "ELEVATOR"
b1F1B:
	dey
	beq b1F21
	jmp j206A

b1F21:
	lda #$06
	sta string_ptr
j1F25:
	lda #$00
	sta zp_row
	lda #$06
	sec
	sbc string_ptr
	sta zp_col
	pha
	lda #$20
	ldy #$15
	jsr s17A7
	pla
	pha
	sta zp_col
	inc zp_col
	lda #$00
	sta zp_row
	lda #$04
	ldy #$15
	jsr s17A7
	pla
	pha
	sta zp_col
	inc zp_col
	inc zp_col
	lda #$01
	sta zp_row
	jsr get_rowcol_addr
	lda #$20
	jsr s1192
	inc zp_row
	jsr get_rowcol_addr
	lda #$20
	jsr s1192
	pla
	sta zp_col
	inc zp_col
	inc zp_col
	lda #$00
	sta zp_row
	ldy #$04
	jsr s1795
	dec zp_col
	dec zp_col
	lda zp_col
	pha
	lda zp_row
	pha
	dec zp_row
	lda #$20
	ldy #$0f
	jsr s17A7
	dec zp_col
	jsr get_rowcol_addr
	lda #$20
	jsr s1192
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #$20
	jsr s1192
	pla
	sta zp_row
	pla
	sta zp_col
	inc zp_col
	lda #$04
	ldy #$0d
	jsr s17A7
	ldy #$04
	jsr s177F
	lda #$00
	sta zp_row
	lda #$10
	clc
	adc string_ptr
	sta zp_col
	pha
	lda #$20
	ldy #$15
	jsr s17A7
	pla
	pha
	sta zp_col
	dec zp_col
	lda #$00
	sta zp_row
	lda #$03
	ldy #$15
	jsr s17A7
	pla
	pha
	sta zp_col
	dec zp_col
	dec zp_col
	lda #$01
	sta zp_row
	jsr get_rowcol_addr
	lda #$20
	jsr s1192
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #$20
	jsr s1192
	pla
	sta zp_col
p1FFF:
	dec zp_col
	dec zp_col
	lda #$00
	sta zp_row
	ldy #$04
	jsr s177F
	inc zp_col
	inc zp_col
	lda zp_col
	pha
	lda zp_row
	pha
	dec zp_row
	lda #$20
	ldy #$0f
	jsr s17A7
	inc zp_col
	jsr get_rowcol_addr
	lda #$20
	jsr s1192
	inc zp_row
	jsr get_rowcol_addr
	lda #$20
	jsr s1192
	pla
	sta zp_row
	pla
	sta zp_col
	dec zp_col
	lda #$03
	ldy #$0d
	jsr s17A7
	ldy #$04
	jsr s1795
	dec string_ptr
	beq b2051
	jsr s2617
	jmp j1F25

b2051:
	rts

p2052:
	.byte $11,$11,$04,$05,$11,$04,$40,$d4
	.byte $0d,$5e,$50,$15,$0e,$0e,$03,$08
	.byte $0e,$03,$43,$2f,$07,$5c,$54,$0d
j206A:
	dey
	bne b20E7
	lda #<p2052
	sta a0A
	lda #>p2052
	sta a0B
	lda #$02
	sta count
	lda src
	beq b207F
	ldy #$0c
b207F:
	lda (p0A),y
	sta zp_col
	iny
	lda (p0A),y
	sta zp_row
	iny
	lda (p0A),y
	iny
	sta count+1
	tya
	pha
	lda count+1
	tay
	lda #$02
	clc
	adc count
	jsr s17A7
	pla
	tay
	dec count
	bne b207F
	lda #$02
	sta count
b20A5:
	lda (p0A),y
	sta screen_ptr+1
	iny
	lda (p0A),y
	sta screen_ptr
	iny
	lda (p0A),y
	sta count+1
	iny
	tya
	pha
	lda count+1
	tay
	jsr s1777
	pla
	tay
	dec count
	bne b20A5
	rts

p20C3:
	.byte $11,$00,$04,$05,$00,$04,$40,$00
	.byte $15,$42,$04,$0d,$0e,$04,$03,$08
	.byte $04,$03,$42,$04,$0d,$43,$87,$07
	.byte $0c,$07,$02,$0a,$07,$02,$43,$87
	.byte $07,$40,$b1,$03
b20E7:
	dey
	bne b2107
	lda #<p20C3
	sta a0A
	lda #>p20C3
	sta a0B
	lda #$02
	sta count
	ldy src
	beq b2102
	dey
	beq b207F
	ldy #$0c
	jmp b207F

b2102:
	ldy #$18
	jmp b207F

b2107:
	dey
	beq b210D
	jmp j2272

b210D:
	lda a619B
	and #$08
	beq b2122
	lda #$0b
	sta zp_col
	sta zp_row
	jsr get_rowcol_addr
	lda #$0c
	jsr s1192
b2122:
	lda a619B
	and #$04
	beq b215D
	lda #$0a
	sta zp_col
	lda #$0c
	sta zp_row
	jsr get_rowcol_addr
	lda #$0d
	jsr s1192
	lda #$10
	jsr s1192
	lda #$0e
	jsr s1192
	lda #$0a
	sta zp_col
	lda #$0d
	sta zp_row
	jsr get_rowcol_addr
	lda #$12
	jsr s1192
	lda #$13
	jsr s1192
	lda #$0f
	jsr s1192
b215D:
	lda a619B
	and #$02
	beq b21CB
	lda #$09
	sta zp_col
	lda #$0e
	sta zp_row
	jsr get_rowcol_addr
	lda #$0d
	jsr s1192
	lda #$10
	jsr s1192
	lda #$10
	jsr s1192
	lda #$10
	jsr s1192
	lda #$0e
	jsr s1192
	lda #$09
	sta zp_col
	lda #$0f
	sta zp_row
	jsr get_rowcol_addr
	lda #$03
	jsr s1192
	inc zp_col
	inc zp_col
	inc zp_col
	jsr get_rowcol_addr
	lda #$11
	jsr s1192
	dec zp_col
	inc zp_row
	jsr get_rowcol_addr
	lda #$0f
	jsr s1192
	lda #$09
	sta zp_col
	jsr get_rowcol_addr
	lda #$03
	jsr s1192
	lda #>p40D8
	sta screen_ptr+1
	lda #<p40D8
	sta screen_ptr
	ldy #$04
	jsr s1777
b21CB:
	lda a619B
	and #$01
	beq b2245
	lda #$0e
	sta zp_col
	lda #$11
	sta zp_row
	jsr get_rowcol_addr
	lda #$02
	jsr s1192
	lda #$07
	sta zp_col
	jsr get_rowcol_addr
	ldy #$07
	jsr s1777
	lda #$02
	jsr s1192
	lda #$06
	sta zp_col
	lda #$12
	sta zp_row
	lda #$04
	ldy #$03
	jsr s17A7
	lda #$0d
	sta zp_col
	lda #$12
	sta zp_row
	lda #$04
	ldy #$03
	jsr s17A7
	dec zp_row
	inc zp_col
	jsr get_rowcol_addr
	lda #$02
	jsr s1192
	lda #>p4156
	sta screen_ptr+1
	lda #<p4156
	sta screen_ptr
	ldy #$07
	jsr s1777
	lda #$0f
	sta zp_col
	lda #$11
	sta zp_row
	lda #$03
	tay
	jsr s17A7
	ldx #>p5E56
	stx screen_ptr+1
	ldx #<p5E56
	stx screen_ptr
	ldy #$07
	jsr s1777
b2245:
	rts

p2246:
	.byte $07,$20,$0b,$07,$0b,$0b,$0b,$0b
	.byte $0b,$0b,$0b,$09,$09,$20
p2254:
	.byte $20,$06,$06,$0b,$0b,$0b,$0b,$0b
	.byte $0b,$0b,$08,$0b,$20,$08
string_square:
	.byte "THEPERFECTSQUARE"
j2272:
	dey
	beq b2278
	jmp j2347

b2278:
	lda src
	cmp #$01
	beq b22F8
	cmp #$04
	bne b2285
	jmp j2332

b2285:
	lda #$08
	sta zp_col
	pha
	lda #$07
	sta zp_row
	pha
j228F:
	lda #$0b
	ldy #$07
	jsr s17A7
	pla
	sta zp_row
	pla
	sta zp_col
	inc zp_col
	lda zp_col
	cmp #$0f
	beq b22AB
	pha
	lda zp_row
	pha
	jmp j228F

b22AB:
	lda #<string_square
	sta a0A
	lda #>string_square
	sta a0B
	lda #$0a
	sta zp_col
	lda #$04
	sta zp_row
	jsr get_rowcol_addr
	lda #$03
	sta count+1
	jsr s22E6
	lda #$08
	sta zp_col
	lda #$05
	sta zp_row
	jsr get_rowcol_addr
	lda #$07
	sta count+1
	jsr s22E6
	lda #$09
	sta zp_col
	lda #$06
	sta zp_row
	jsr get_rowcol_addr
	lda #$06
	sta count+1
s22E6:
	ldy #$00
	lda (p0A),y
	jsr s1192
	inc a0A
	bne b22F3
	inc a0B
b22F3:
	dec count+1
	bne s22E6
	rts

b22F8:
	lda #<p2254
	sta a0A
	lda #>p2254
	sta a0B
	lda #$13
p2303=*+$01
	sta zp_col
	lda #$07
	sta zp_row
	sta count+1
b230A:
	jsr get_rowcol_addr
	ldy #$00
	lda (p0A),y
	jsr s1192
	inc a0A
	bne b231A
	inc a0B
b231A:
	ldy #$00
	lda (p0A),y
	jsr s1192
	inc a0A
	bne b2327
	inc a0B
b2327:
	inc zp_row
	dec zp_col
	dec zp_col
	dec count+1
	bne b230A
	rts

j2332:
	lda #<p2246
	sta a0A
	lda #>p2246
	sta a0B
	lda #$02
	sta zp_col
	lda #$07
	sta zp_row
	sta count+1
	jmp b230A

j2347:
	dey
	beq b234D
	jmp j2410

b234D:
	lda src
	cmp #$04
	bne b2356
	jmp j23DD

b2356:
	cmp #$02
	beq b23A8
	lda #$10
	sta zp_col
	lda #$08
	sta zp_row
	jsr get_rowcol_addr
	lda #$14
	jsr s1192
	inc zp_row
	dec zp_col
	dec zp_col
	lda #$0a
	ldy #$05
	jsr s17A7
	jsr get_rowcol_addr
	lda #$17
	jsr s1192
	inc zp_row
	jsr get_rowcol_addr
	lda #$15
	jsr s1192
	lda #$10
	sta zp_col
	lda #$09
	sta zp_row
	lda #$16
	ldy #$06
	jsr s17A7
	lda #$11
	sta zp_col
	lda #$08
	sta zp_row
	lda #$03
	ldy #$08
	jsr s17A7
	rts

b23A8:
	lda #$14
	sta zp_col
	lda #$04
	sta zp_row
	ldy #$02
	jsr s177F
	inc zp_col
	lda #$03
	ldy #$0c
	jsr s17A7
	lda #$14
	sta zp_col
	lda #$05
	sta zp_row
	lda #$03
	ldy #$0e
	jsr s17A7
	lda #$15
	sta zp_col
	lda #$04
	sta zp_row
	lda #$03
	ldy #$10
	jsr s17A7
	rts

j23DD:
	lda #$02
	sta zp_col
	lda #$04
	sta zp_row
	ldy #$02
	jsr s1795
	dec zp_col
	lda #$04
	ldy #$0c
	jsr s17A7
	lda #$02
	sta zp_col
	lda #$05
	sta zp_row
	lda #$04
	ldy #$0e
	jsr s17A7
	lda #$01
	sta zp_col
	lda #$04
	sta zp_row
	ldy #$10
	jsr s17A7
	rts

j2410:
	dey
	beq b2416
	jmp j254C

b2416:
	lda src
	and #$0f
	beq b244F
	and #$08
	beq b2427
	lda #$0c
	sta zp_col
	jsr s253F
b2427:
	lda src
	and #$04
	beq b2434
	lda #$0d
	sta zp_col
	jsr s252D
b2434:
	lda src
	and #$02
	beq b2441
	lda #$0f
	sta zp_col
	jsr s24E2
b2441:
	lda src
	and #$01
	beq b244E
	lda #$13
	sta zp_col
s244B:
	jsr s2484
b244E:
	rts

b244F:
	lda src
	and #$10
	beq b245C
	lda #$02
	sta zp_col
	jsr s2484
b245C:
	lda src
	and #$20
	beq b2469
	lda #$05
	sta zp_col
	jsr s24E2
b2469:
	lda src
	and #$40
	beq b2476
	lda #$08
	sta zp_col
	jsr s252D
b2476:
	lda src
	and #$80
	beq b2483
	lda #$0a
	sta zp_col
	jsr s253F
b2483:
	rts

s2484:
	lda #$08
	sta zp_row
	jsr get_rowcol_addr
	lda #$7c
	jsr s1192
	lda #$7d
	jsr s1192
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #$0b
	jsr s1192
	lda #$0b
	jsr s1192
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #$7e
	jsr s1192
	lda #$7f
	jsr s1192
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #$1f
	jsr s1192
	lda #$7b
	jsr s1192
	inc zp_row
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #$0b
	jsr s1192
	lda #$0b
	jsr s1192
	rts

s24E2:
	lda #$09
	sta zp_row
	jsr get_rowcol_addr
	lda #$1e
	jsr print_char
	lda #$0b
	jsr s1192
	lda #$1d
	jsr s1192
	inc zp_row
	dec zp_col
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #$5f
	jsr print_char
	lda #$0b
	jsr s1192
	lda #$60
s2510=*+$01
	jsr print_char
	inc zp_row
	dec zp_col
	dec zp_col
	dec zp_col
	jsr get_rowcol_addr
	lda #$1c
	jsr s1192
	lda #$0b
	jsr s1192
	lda #$1b
	jsr s1192
	rts

s252D:
	lda #$0a
	sta zp_row
	jsr get_rowcol_addr
	lda #$19
	jsr s1192
	lda #$1a
	jsr s1192
	rts

s253F:
	lda #$0a
	sta zp_row
	jsr get_rowcol_addr
	lda #$18
	jsr s1192
	rts

j254C:
	lda #$0a
	sta zp_col
	lda #$03
	sta zp_row
	ldy #$12
	jsr s17A7
	lda #$0b
	sta zp_col
	lda #$03
	sta zp_row
	lda #$04
	ldy #$12
	jsr s17A7
	lda #>p40D9
	sta screen_ptr+1
	lda #<p40D9
	sta screen_ptr
	ldy #$02
	jsr s1777
	lda #$0a
	sta string_ptr
	lda #$0b
	sta count
	lda #>p0402
	sta dst+1
	lda #<p0402
	sta dst
b2585:
	jsr s2617
	lda string_ptr
	sta zp_col
	lda #$03
	sta zp_row
	lda #$20
	ldy #$12
	jsr s17A7
	lda count
	sta zp_col
	lda #$03
	sta zp_row
	lda #$20
	ldy #$12
	jsr s17A7
	dec string_ptr
	inc count
	lda string_ptr
	sta zp_col
	lda #$03
	sta zp_row
	ldy #$12
	jsr s17A7
	lda count
	sta zp_col
	lda #$03
	sta zp_row
	lda #$04
	ldy #$12
	jsr s17A7
	lda #$11
	sta zp_row
	dec string_ptr
	lda string_ptr
	inc string_ptr
	sta zp_col
b25D3=*+$01
	jsr get_rowcol_addr
	inc dst
	inc dst
	ldy dst
	jsr s1777
	dec dst+1
	bne b2585
	rts

s25E3:
	sta row_ptr
	lda #<noun_table
	sta string_ptr
	lda #>noun_table
	sta string_ptr+1
	ldy #$00
b25EF:
	lda (string_ptr),y
	bmi b25FB
b25F3:
	inc string_ptr
	bne b25EF
	inc string_ptr+1
	bne b25EF
b25FB:
	dec row_ptr
	bne b25F3
	lda (string_ptr),y
	and #$7f
b2603:
	jsr s1192
	inc string_ptr
	bne b260C
	inc string_ptr+1
b260C:
	ldy #$00
	lda (string_ptr),y
	bpl b2603
	lda #$20
	jmp s1192

s2617:
	ldx #$28
	stx src+1
b261B:
	dec src
	bne b261B
	dec src+1
	bne b261B
	rts

	bpl b25D3
	ora #$01
	jsr s3402
	lda a0108
	jsr s3402
	rts

	.byte $a9,$00,$9d,$00,$01,$9d,$01,$01
	.byte $85,$df,$85,$e0,$20,$6e
s2640:
	lda a619D
	sta src
	lda a619C
	sta src+1
	cmp #$0e
	bmi b2651
	jmp j2B1B

b2651:
	lda src
	cmp #$15
	bmi b265A
	jmp j105A

b265A:
	jsr s0B97
	sta dst+1
	lda a619D
	sta src
	lda a619C
	sta src+1
	dec src+1
	bne b26AB
	lda #$0b
	cmp src
	beq b2682
	lda #$0d
	cmp src
	beq b267E
b2679:
	lda #$1f
b267B:
	jmp s08A4

b267E:
	lda #$73
	bne b267B
b2682:
	lda a6194
	cmp #$05
	bne b2679
	lda #$07
	cmp count+1
	beq b2679
	lda #<p030B
	sta src
	lda #>p030B
	sta src+1
	jsr s1A34
	lda #$01
	sta a619E
	jsr s1015
	lda #$71
	jsr s0892
	lda #$72
	bne b267B
b26AB:
	dec src+1
	bne b26E1
	lda src
	cmp #$05
	beq b26DD
	cmp #$08
	bne b2679
	lda a6194
	cmp #$05
	bne b26D2
	lda a61A5
	cmp #$09
	bne b26D2
	lda #<p0308
	sta src
	lda #>p0308
	sta src+1
	jsr s1A34
b26D2:
	lda #$7f
	jsr s0892
	lda #$80
	jsr s08A4
	rts

b26DD:
	lda #$09
	sta src+1
b26E1:
	dec src+1
	bne b2756
	lda src
	cmp #$0b
	bne b26EE
	jsr s281D
b26EE:
	cmp #$12
	bmi b270D
	sta row_ptr
	lda dst
	pha
	lda dst+1
	pha
	lda row_ptr
	cmp #$13
	bne b2703
	jsr s2723
b2703:
	pla
	sta dst+1
	pla
	sta dst
	lda dst+1
	sta src
b270D:
	jsr s1A34
	jsr s1015
	lda #$4e
	jsr s0892
	lda a619D
	jsr s25E3
	lda #$4f
	jmp s08A4

s2723:
	lda a6198
	bne b2743
	dec a6197
	lda a6194
	cmp #$05
	beq b2742
	lda #$00
	sta a61A1
	sta a619E
	jsr s2788
	lda #$0a
	sta a61A5
b2742:
	rts

b2743:
	dec a6198
	lda #$0e
	sta src+1
	jsr s1A34
	sta src
	lda #$00
	sta src+1
	jmp s1A34

b2756:
	dec src+1
	bne b2799
	lda a6197
	beq b2784
	lda src
	cmp #$0b
	bne b2768
	jsr s281D
b2768:
	cmp #$12
	bmi b2774
	cmp #$13
	beq b2795
	lda dst+1
	sta src
b2774:
	jsr s1A34
	jsr s105F
	lda #$52
	jsr s0892
	lda #$53
b2781:
	jmp s08A4

b2784:
	lda #$88
	bne b2781
s2788:
	lda a61A6
	sta a61A7
	lda a61A5
	sta a61A6
	rts

b2795:
	lda #$06
	sta src+1
b2799:
	dec src+1
	beq b27A0
	jmp j2839

b27A0:
	lda src
	cmp #$0b
	bne b27A9
	jsr s281D
b27A9:
	cmp #$12
	bmi b27B7
	beq b27EB
	cmp #$13
	beq b27D9
j27B3:
	lda dst+1
	sta src
b27B7:
	jsr s1A34
	jsr s1015
	lda #$7d
	jsr s0892
	lda #$20
	jsr s1192
	lda a619D
	jsr s25E3
	lda #$7e
b27CF:
	jsr s08A4
	lda #$07
	sta src+1
	jmp s1A34

b27D9:
	lda dst
	pha
	lda dst+1
	pha
	jsr s2723
	pla
	sta dst+1
	pla
	sta dst
	jmp j27B3

b27EB:
	lda dst+1
	sta src
	jsr s1A34
	lda a619F
	sta src+1
	lda a61A0
	sta src
	lda #<pAA
	sta count
	lda #>pAA
	sta count+1
	clc
	lda count
	adc src
	sta src
	lda count+1
	adc src+1
	sta src+1
	sta a619F
	lda src
	sta a61A0
	lda #$58
	bne b27CF
s281D:
	lda a6194
	cmp #$05
	bne b2836
	lda #$00
	sta a619E
	lda a61AC
	beq b2836
	lda #$0a
	sta a61A5
	jsr s127E
b2836:
	lda #$0b
	rts

j2839:
	dec src+1
	beq b2840
	jmp j293D

b2840:
	lda src
	cmp #$0b
	bne b2849
	jsr s281D
b2849:
	cmp #$06
	bne b2850
	jmp j2912

b2850:
	cmp #$0f
	beq b2885
	cmp #$10
	beq b28B9
	cmp #$12
	bmi b2869
	beq b28C6
	cmp #$13
	bne b2865
	jsr s2723
b2865:
	lda dst+1
	sta src
b2869:
	jsr s1A34
	jsr s28D9
	jsr s332F
	nop
	nop
	bne b287B
	lda #$97
	jmp s0892

b287B:
	lda #$5c
	jsr s0892
	lda #$5d
	jmp s08A4

b2885:
	lda a6194
	cmp #$04
	bne b2869
	lda a61A4
	cmp #$29
	bcc b2869
	jsr s2788
	lda #$0e
	sta a61A5
	lda #$0f
	sta src
	lda #$00
	sta src+1
	jsr s1A34
	jsr s28D9
	lda #$5e
	jsr s0892
	lda #$5f
	jsr s08A4
	lda #$00
	sta a61B2
	rts

b28B9:
	jsr s28D9
	lda #$6b
	jsr s0892
	lda #$6c
	jmp s08A4

b28C6:
	lda dst+1
	sta src
	jsr s1A34
	lda #$07
	sta src+1
	jsr s1A34
	lda #$81
	jmp s08A4

s28D9:
	lda #$07
	sta src+1
	jsr s1A34
	lda #$59
	jsr s0892
	lda a619D
	jsr s25E3
	jsr s32BD
	lda #$20
	ldy #$00
	cmp (src),y
	beq b28FC
	inc src
	bne b28FC
	inc src+1
b28FC:
	inc src
	bne b2902
	inc src+1
b2902:
	lda #$5a
	jsr print_display_string
	lda #$5b
	jsr s08A4
	jsr s1045
	jmp s105F

j2912:
	lda a61AD
	and #$02
	bne b291C
	jmp b2869

b291C:
	lda #<zp_col
	sta src
	lda #>zp_col
	sta src+1
	jsr s1A34
	jsr s28D9
	jsr s105F
	lda #$3f
	jsr s0892
	lda #$40
	jsr s08A4
	jsr s1045
	jmp j10B9

j293D:
	dec src+1
	bne b2944
	jmp j105A

b2944:
	dec src+1
	bne b29C7
	jsr s3274
	lda #$0b
	sta src+1
	jsr s1A34
	cmp #$00
	beq b296D
	sta src
	lda #$06
	sta src+1
	jsr s1A34
	lda count+1
	cmp #$06
	bcs b296D
	lda #$82
	jsr s08A4
	jmp s3274

b296D:
	jsr s3274
	lda src
	cmp #$12
	bpl b298B
	cmp #$0b
	bne b297D
	jsr s281D
b297D:
	lda #$05
	sta src+1
	jsr s1A34
	ldx #$07
	stx src+1
	jmp s1A34

b298B:
	cmp #$13
	beq b2996
	lda dst+1
	sta src
	jmp b297D

b2996:
	lda #$0e
	sta src+1
	jsr s1A34
	beq b29A5
	dec a6198
	jmp b297D

b29A5:
	lda #$0d
	sta src+1
	jsr s1A34
	sta src
	dec a6197
	jsr s2788
	lda #$00
	sta a619E
	sta a6197
	lda #$0a
	sta a61A5
	jsr s127E
	jmp b297D

b29C7:
	dec src+1
	bne b29D9
	lda src
	cmp #$09
	beq b29D4
	jmp j105A

b29D4:
	lda #$89
	jmp s08A4

b29D9:
	dec src+1
	bne b2A43
	sta dst+1
	lda src
	cmp #$13
	beq b29E8
	jmp j105A

b29E8:
	lda count+1
	cmp #$07
	bne b29F1
	jmp j0BAD

b29F1:
	lda a619E
	bne b2A02
	lda #$88
	jsr s08A4
	lda #$07
	sta src+1
	jmp s1A34

b2A02:
	lda #$0d
	sta src+1
	jsr s1A34
	cmp #$00
	beq b2A16
	sta src
	lda #$01
	sta src+1
	jsr s1A34
b2A16:
	lda #$0e
	sta src+1
	jsr s1A34
	sta src
	lda #$03
	sta src+1
	jsr s1A34
	jsr s105F
	lda #$65
	jsr s0892
	lda #$66
	jsr s08A4
	dec a6198
	lda #$07
	sta src+1
	jsr s1A34
	lda #$96
	sta a61A1
	rts

b2A43:
	dec src+1
	beq b2A4A
	jmp j2ADF

b2A4A:
	lda src
	cmp #$05
	beq b2A68
	cmp #$01
	beq b2A63
	cmp #$08
	beq b2A5B
	jmp j105A

b2A5B:
	lda #$02
	sta a619C
	jmp s2640

b2A63:
	lda #$87
j2A65:
	jmp s08A4

b2A68:
	lda #<p0611
	sta src
	lda #>p0611
	sta src+1
	jsr s1A34
	lda count+1
	cmp a6194
	bne b2A89
	lda a6195
	asl
	asl
	asl
	asl
	clc
	adc a6196
	cmp count
	beq b2A96
b2A89:
	jsr s105F
	lda #$83
	jsr s0892
	lda #$84
	jmp j2A65

b2A96:
	lda #$0a
	sta zp_col
	lda #$14
	sta zp_row
b2A9E:
	jsr get_rowcol_addr
	lda #$1c
	jsr print_char
	lda #$05
	jsr print_char
	lda #$1b
	jsr print_char
	lda #$30
	sta dst+1
b2AB4:
	dec dst
	bne b2AB4
	dec dst+1
	bne b2AB4
	dec zp_col
	dec zp_col
	dec zp_col
	dec zp_row
	bpl b2A9E
	lda #>p0311
	sta src+1
	lda #<p0311
	sta src
	jsr s1A34
	jsr s2788
	lda #$0f
	sta a61A5
	lda #$00
	sta a61B9
	rts

j2ADF:
	dec src+1
	bne b2AF9
	lda src
	cmp #$0d
	beq b2AEC
	jmp j105A

b2AEC:
	jsr s105F
	lda #$21
	jsr s0892
	lda #$22
	jmp s08A4

b2AF9:
	dec src+1
	beq b2AFE
	rts

b2AFE:
	lda src
	cmp #$07
	beq b2B11
j2B04:
	jsr s105F
	lda #$91
	jsr s0892
	lda #$23
	jmp s08A4

b2B11:
	lda #$03
	sta src+1
	jsr s1A34
	jmp j2B04

j2B1B:
	lda src+1
	sec
	sbc #$0e
	sta src+1
	bne b2B64
	lda src
	cmp #$07
	bne b2B2D
	jmp j3319

b2B2D:
	cmp #$15
	bmi b2B4A
	cmp #$1a
	bmi b2B38
	jmp j105A

b2B38:
	cmp #$17
	beq b2B41
b2B3C:
	lda #$90
b2B3E:
	jmp s08A4

b2B41:
	jsr s2C8E
	cmp #$00
	beq b2B3C
	bne b2B4D
b2B4A:
	jsr s0B97
b2B4D:
	jsr s105F
	lda #$67
	jsr s0892
	lda a619D
	cmp #$03
	beq b2B60
	lda #$68
	bne b2B3E
b2B60:
	lda #$69
	bne b2B3E
b2B64:
	dec src+1
	bne b2B7A
	jsr s0B97
	lda a619D
	cmp #$03
	beq b2B76
	lda #$7a
	bne b2B3E
b2B76:
	lda #$28
	bne b2B3E
b2B7A:
	dec src+1
	beq b2B81
	jmp j2CFA

b2B81:
	lda src
	cmp #$17
	bne b2B8A
	jmp j2C26

b2B8A:
	cmp #$14
	beq b2B91
	jmp j105A

b2B91:
	lda #$0b
	sta src+1
	jsr s1A34
	sta dst+1
	beq b2B3C
	lda dst
	pha
	lda dst+1
	pha
	sta src
	lda #$06
	sta src+1
	jsr s1A34
	lda count+1
	cmp #$06
	bcs b2BB4
	jmp j2BBF

b2BB4:
	lda dst+1
	sta src
	lda #$04
	sta src+1
	jsr s1A34
j2BBF:
	lda dst+1
	cmp #$11
	beq b2C1A
	bmi b2BD1
	cmp #$15
	bmi b2BCF
	lda #$13
	bne b2BD1
b2BCF:
	lda #$12
b2BD1:
	jsr s105F
	sta dst
	clc
	adc #$04
	jsr s08A4
	lda #$18
	jsr s0892
	lda dst
	cmp #$03
	bne b2BEA
	jsr s2EC2
b2BEA:
	sta row_ptr
	cmp #$11
	bne b2BF3
	jsr s1045
b2BF3:
	pla
	sta dst+1
	pla
	sta dst
	lda row_ptr
	cmp #$13
	bne b2C13
	lda #$06
	sta src+1
j2C04=*+$01
	lda dst+1
	sta src
	jsr s1A34
	lda #$08
	cmp count+1
	bne b2C13
	inc a6198
b2C13:
	lda #$07
	sta src+1
	jmp s1A34

b2C1A:
	jsr s2788
	ldx #$0b
	stx a61A5
	lda #$11
	bne b2BD1
j2C26:
	jsr s2C8E
	cmp #$00
	bne b2C30
	jmp b2B3C

b2C30:
	cmp #$05
	bcs b2C37
	jmp j2C83

b2C37:
	jsr s3267
	ldx #<p060A
	stx src
	ldx #>p060A
	stx src+1
	jsr s1A34
	lda count+1
	cmp #$07
	bmi b2C69
	jsr s3267
	clc
	adc #$15
	cmp #$1b
	beq b2C71
	jsr s3267
	jsr s105F
	lda #$19
	jsr s0892
	jsr s3267
	jsr s08A4
	jmp j10B9

b2C69:
	jsr s3267
	lda #$92
	jmp s08A4

b2C71:
	ldx #$0c
	stx a61A5
	jsr s105F
	lda #$19
	jsr s0892
	lda #$1b
	jmp s08A4

j2C83:
	jsr s2788
	ldx #$0d
	stx a61A5
	jmp j325D

s2C8E:
	ldx #<p2CE8
	stx src
	ldx #>p2CE8
	stx src+1
	ldx a6194
	stx count
	lda a6195
	ldx #$04
	stx count+1
b2CA2:
	asl
	asl count
	dec count+1
	bne b2CA2
	clc
	adc a6196
	sta dst+1
	lda count
	clc
	adc p6193
	sta count
	ldx #$09
	stx count+1
b2CBB:
	ldy #$00
	cmp (src),y
	bne b2CD3
	lda dst+1
	inc src
	bne b2CC9
	inc src+1
b2CC9:
	cmp (src),y
	bne b2CD9
	lda #$0a
	sec
	sbc count+1
	rts

b2CD3:
	inc src
	bne b2CD9
	inc src+1
b2CD9:
	inc src
	bne b2CDF
	inc src+1
b2CDF:
	lda count
	dec count+1
	bne b2CBB
	lda #$00
	rts

p2CE8:
	.byte $23,$77,$31,$44,$42,$14,$52,$35
	.byte $52,$4a,$52,$5a,$52,$6a,$52,$7a
	.byte $52,$8a
j2CFA:
	dec src+1
	beq b2D01
	jmp j2E2A

b2D01:
	lda src
	cmp #$1a
	bpl b2D0A
	jmp j105A

b2D0A:
	ldx #>p0603
	stx src+1
	ldx #<p0603
	stx src
	jsr s1A34
	lda count+1
	cmp #$08
	beq b2D1E
	jmp j0BAD

b2D1E:
	lda a61AD
	and #$02
	bne b2D2A
	lda a61A5
	beq b2D3D
b2D2A:
	lda #$85
	jsr s08A4
	lda #$20
	jsr s1192
	lda a619D
	clc
	adc #$16
	jmp s1192

b2D3D:
	lda a619D
	sec
	sbc #$19
	ldx #<p2E02
	stx src
	ldx #>p2E02
	stx src+1
j2D4B:
	sec
	sbc #$01
	beq b2D62
	clc
	pha
	lda #$04
	adc src
	sta src
	lda src+1
	adc #$00
	sta src+1
	pla
	jmp j2D4B

b2D62:
	ldy #$00
	lda (src),y
	sta p6193
	inc src
	bne b2D6F
	inc src+1
b2D6F:
	lda (src),y
	sta a6194
	inc src
	bne b2D7A
	inc src+1
b2D7A:
	lda (src),y
	sta a6195
	inc src
	bne b2D85
	inc src+1
b2D85:
	lda (src),y
	sta a6196
	ldx #$00
	stx a61A3
	stx a61A4
	lda a619D
	cmp #$1c
	bne b2DC3
	lda a619E
	bne b2DA5
	ldx #$01
	stx a61A2
	bne b2DC3
b2DA5:
	dec a619E
	ldx #$00
	stx a61A2
	inc a6198
	dec a6197
	ldx #$0d
	stx src+1
	jsr s1A34
	ldx #$04
	stx src+1
	sta src
	jsr s1A34
b2DC3:
	ldx #<p0103
	stx src
	ldx #>p0103
	stx src+1
	ldx #$0a
	stx a61A5
	jsr s1A34
	jsr s127E
	ldx #$07
	stx src+1
	jsr s1A34
	lda #$86
	jsr s0892
	lda #$74
	jsr s08A4
	lda a619D
	cmp #$1c
	bne b2E01
	lda a61A2
	bne b2E01
	jsr s1045
	jsr s105F
	lda #$70
	jsr s08A4
	jmp s0FDC

b2E01:
	rts

p2E02:
	.byte $02,$02,$05,$04,$02,$02,$07,$09
	.byte $01,$05,$03,$03,$02,$03,$04,$06
	.byte $02,$01,$08,$05,$03,$02,$01,$03
	.byte $02,$01,$05,$05,$01,$01,$07,$0a
	.byte $03,$04,$09,$0a,$03,$03,$07,$0a
j2E2A:
	dec src+1
	beq b2E31
	jmp j2F98

b2E31:
	ldx #$0b
	stx src+1
	jsr s1A34
	tax
	bne b2E3E
	jmp j2F30

b2E3E:
	sta dst+1
	sta src
	ldx #$06
	stx src+1
	jsr s1A34
	lda a619D
	cmp #$14
	bne b2E53
	jmp j2EDE

b2E53:
	cmp #$12
	bmi b2E5A
	jmp j2EF5

b2E5A:
	cmp dst+1
	bne b2E6A
	ldx dst+1
	stx src
	lda count+1
	cmp #$06
	bne b2E9A
	lda dst+1
b2E6A:
	sta src
	ldx #$06
	stx src+1
j2E72=*+$02
	jsr s1A34
	lda #$06
	cmp count+1
	beq b2E7C
	jmp j2F30

b2E7C:
	ldx a619D
	stx src
	jmp j2E9D

s2E84:
	jsr s3274
	ldx #$08
	stx src+1
	jsr s1A34
	lda count
	cmp #$08
	bcc b2E97
	jmp j2F35

b2E97:
	jmp s3274

b2E9A:
	jsr s2E84
j2E9D:
	ldx #$04
	stx src+1
	jsr s1A34
j2EA4:
	ldx #$07
	stx src+1
	jsr s1A34
	lda a619D
	cmp #$03
	bne b2EB5
	jsr s2EC2
b2EB5:
	cmp #$11
	bne b2EC1
	jsr s2788
	ldx #$0b
	stx a61A5
b2EC1:
	rts

s2EC2:
	lda a61A5
	cmp #$02
	bne b2EDB
	lda a619C
	cmp #$12
	beq b2ED3
	jsr s1045
b2ED3:
	jsr s105F
	lda #$27
	jsr s08A4
b2EDB:
	lda #$03
	rts

j2EDE:
	lda count+1
	cmp #$06
	bpl j2F30
	jsr s2E84
	ldx dst+1
	stx src
	ldx #$02
	stx src+1
	jsr s1A34
	jmp j2EA4

j2EF5:
	cmp #$12
	beq b2F16
	lda dst+1
j2EFB:
	cmp #$18
	bpl b2F42
	cmp #$15
	bmi b2F42
	ldx dst+1
	stx src
	lda count+1
	cmp #$06
	beq j2E9D
	jsr s2E84
	inc a6198
	jmp j2E9D

b2F16:
	lda dst+1
	cmp #$15
	bpl b2F48
	cmp #$12
	bmi b2F48
	ldx dst+1
	stx src
	lda count+1
	cmp #$06
	bne b2F2D
	jmp j2E9D

b2F2D:
	jmp b2E9A

j2F30:
	lda #$9a
b2F32:
	jmp s08A4

j2F35:
	pla
	sta src
	pla
	sta src+1
	jsr s3274
	lda #$99
	bne b2F32
b2F42:
	ldx #$14
	stx src
	bne b2F4C
b2F48:
	ldx #$11
	stx src
b2F4C:
	lda src+1
	pha
	lda src
	pha
	ldx #$03
	stx dst+1
b2F56:
	pla
	sta src
	pla
	sta src+1
	inc src
	bne b2F62
	inc src+1
b2F62:
	lda src+1
	pha
	lda src
	pha
	ldx #$06
	stx src+1
	jsr s1A34
	lda #$06
	cmp count+1
	beq b2F82
	dec dst+1
	bne b2F56
	pla
	sta src
	pla
	sta src+1
	jmp j2F30

b2F82:
	pla
	sta src
	pla
	sta src+1
	lda a619D
	cmp #$13
	beq b2F92
	jmp j2E9D

b2F92:
	inc a6198
	jmp j2E9D

j2F98:
	dec src+1
	bne b2FBD
	lda src
	cmp #$11
	beq b2FB7
	cmp #$15
	bpl b2FA9
	jmp j105A

b2FA9:
	cmp #$1a
	bmi b2FB0
	jmp j105A

b2FB0:
	cmp #$17
	bne b2FB7
	jmp j105A

b2FB7:
	lda #$90
b2FB9:
	jsr s08A4
	rts

b2FBD:
	dec src+1
	bne b2FD9
	ldx #<p0602
	stx src
	ldx #>p0602
	stx src+1
	jsr s1A34
	lda count+1
	cmp #$08
	beq b2FD5
	jmp j0BAD

b2FD5:
	lda #$6f
	bne b2FB9
b2FD9:
	dec src+1
	bne b2FE0
	jmp j105A

b2FE0:
	dec src+1
	bne b301D
	lda #$76
	jsr s08A4
	lda #<p0C7A
	sta src
	lda #>p0C7A
	sta src+1
	ldy #$00
	lda #$20
b2FF5:
	cmp (src),y
	beq b300E
	inc src
	bne b2FF5
	inc src+1
	bne b2FF5
b3001:
	ldy #$00
	lda (src),y
	cmp #$20
	beq b301C
	sta (p0A),y
	jsr print_char
b300E:
	inc a0A
	bne b3014
	inc a0B
b3014:
	inc src
	bne b3001
	inc src+1
	bne b3001
b301C:
	rts

b301D:
	dec src+1
	beq b3024
	jmp j30BE

b3024:
	lda #$02
	cmp p6193
	bne b3072
	tax
	dex
	txa
	cmp a6194
	bne b3072
	cmp a6195
	bne b3072
	lda #$0b
	cmp a6196
	bne b3072
	ldx #<p0607
	stx src
	ldx #>p0607
	stx src+1
	jsr s1A34
	lda #$07
	cmp count+1
	bne b30A5
	jsr s1015
	jsr s0FDC
	jsr s30C5
	jsr s107C
	inc a6194
	ldx #$03
	stx a6196
	stx a6195
	ldx #$00
	stx a61A3
	stx a61A4
	jmp s1015

b3072:
	lda a619A
	and #$e0
	beq b30A5
	jsr s3085
	jsr s0FDC
	jsr s1015
	jmp b3024

s3085:
	lda p6193
	tax
	dex
	txa
	beq b3099
	dex
	txa
	beq b309D
	dex
	txa
	beq b30A1
	dec a6196
	rts

b3099:
	dec a6195
	rts

b309D:
	inc a6196
	rts

b30A1:
	inc a6195
	rts

b30A5:
	jsr s1015
	jsr s0FDC
	jsr s30C5
	jsr s105F
	lda #$2a
	jsr s0892
	lda #$2b
	jsr s08A4
	jmp j10B9

j30BE:
	dec src+1
	beq b30FB
	jmp j3197

s30C5:
	ldx #<p0400
	stx src
	ldx #>p0400
	stx src+1
	ldy #$00
b30CF:
	lda #$dd
b30D1:
	sta (src),y
	inc src
	bne b30D1
	inc src+1
	lda src+1
	cmp #$08
	bne b30CF
	bit aC054
	bit hw_FULLSCREEN
	bit aC056
	bit hw_GRAPHICS
	jsr s0FDC
	bit hw_PAGE2
	bit hw_FULLSCREEN
	bit hw_HIRES
	bit hw_GRAPHICS
	rts

b30FB:
	lda a61A5
	beq b3105
	lda #$98
	jmp s0892

b3105:
	jsr s30C5
	jmp j3111

j310B:
	jsr s0FDC
	jsr s1015
j3111:
	lda a619A
	and #$e0
	beq b313F
	jsr s3085
	lda a6194
	cmp #$01
	bne b3130
	lda a6195
	cmp #$06
	bne b3130
	lda a6196
	cmp #$0a
	beq b3136
b3130:
	jsr s0B19
	jmp j310B

b3136:
	jsr s1015
	jsr s0FDC
	jmp b0A4A

b313F:
	jsr s1015
	ldx a619F
	stx src+1
	ldx a61A0
	stx src
	lda src+1
	bne b315D
	lda src
	cmp #$05
	bcs b3159
	jmp j0B64

b3159:
	cmp #$0f
	bcc b3190
b315D:
	lda #>p0A
	sta count+1
	lda #<p0A
	sta count
	lda src
	sec
	sbc count
	sta src
	lda src+1
	sbc count+1
	sta src+1
	sta a619F
	lda src
	sta a61A0
b317A:
	jsr s0FDC
	jsr s127E
	lda #$2d
	ldx #$08
	stx zp_col
	ldx #$0a
	stx zp_row
	jsr print_display_string
	jmp s0A10

b3190:
	ldx #$05
	stx a61A0
	bne b317A
j3197:
	dec src+1
	bne b31DF
	lda a61A5
	beq b31A5
	lda #$9a
	jmp s08A4

b31A5:
	jsr s105F
	lda #$93
	jsr s0892
	jsr input_Y_or_N
	and #$7f
	cmp #$59
	beq b31B9
	jmp s105F

b31B9:
	jmp j7C66

j31BC:
	lda #$95
	jsr s0892
	lda #$96
	jsr s08A4
	jsr input_char
	ldx #<p6193
	stx a3C
	ldx #>p6193
	stx a3D
	ldx #<p6292
	stx a3E
	ldx #>p6292
	stx a3F
	jsr eFECD
	jmp s105F

b31DF:
	dec src+1
	bne b31FB
	jsr s105F
	lda #$9c
	jsr s0892
	jsr input_Y_or_N
	cmp #$59
	beq b31F5
	jmp s105F

b31F5:
	jsr b31A5
	jmp j10C4

b31FB:
	dec src+1
	bne b3238
	jsr clear_hgr2
	lda #$00
	sta zp_col
	sta zp_row
	jsr get_rowcol_addr
	ldx #<p77BF
	stx src
	ldx #>p77BF
	stx src+1
b3213:
	inc src
	bne b3219
	inc src+1
b3219:
	ldy #$00
	lda (src),y
	and #$7f
	jsr s1192
	ldy #$00
	lda (src),y
	bpl b3213
	jsr input_char
	jsr clear_hgr2
	jsr s1015
	lda #$07
	sta src+1
	jmp s1A34

b3238:
	lda a61A5
	cmp #$02
	beq b3258
	lda a61B1
	beq b324F
	lda #$9d
	jsr s08A4
	ldx #$00
	stx a61B1
	rts

b324F:
	lda #$9e
	jsr s08A4
	inc a61B1
	rts

b3258:
	lda #$9f
	jmp s08A4

j325D:
	jsr s1015
	lda #$0a
	sta src+1
	jmp s1E5A

s3267:
	sta row_ptr
	lda a61F7
	pha
	lda row_ptr
	sta a61F7
	pla
	rts

s3274:
	lda src
	tax
	lda a61F8
	sta src
	txa
	sta a61F8
	lda src+1
	tax
	lda a61F9
	sta src+1
	txa
	sta a61F9
	lda dst
	tax
	lda a61FA
	sta dst
	txa
	sta a61FA
	lda dst+1
	tax
	lda a61FB
	sta dst+1
	txa
	sta a61FB
	lda count
	tax
	lda a61FC
	sta count
	txa
	sta a61FC
	lda a61FD
	tax
	lda count+1
	sta a61FD
	txa
	sta count+1
	rts

s32BD:
	pha
	dec src
	lda src
	cmp #$ff
	bne b32C8
	dec src+1
b32C8:
	pla
	rts

p32CA:
	.byte $41,$4e,$20,$49,$4e,$53,$43,$52
	.byte $49,$50,$54,$49,$4f,$4e,$20,$52
	.byte $45,$41,$44,$53,$3a,$20,$57,$45
	.byte $41,$52,$20,$54,$48,$49,$53,$20
	.byte $48,$41,$54,$20,$41,$4e,$44,$20
	.byte $43,$48,$41,$52,$47,$45,$20,$41
	.byte $20,$57,$41,$4c,$4c,$20,$4e,$45
	.byte $41,$52,$20,$57,$48,$45,$52,$45
	.byte $20,$59,$4f,$55,$20,$46,$4f,$55
	.byte $4e,$44,$20,$49,$54,$21,$a0
j3319:
	ldx #>p32CA
	stx string_ptr+1
	ldx #<p32CA
	stx string_ptr
	jsr s105F
	lda #$00
	sta zp_col
	lda #$16
	sta zp_row
	jmp print_string

s332F:
	lda a619D
	cmp #$01
	beq b333C
	lda a61AD
	and #$02
	rts

b333C:
	jsr s30C5
	jsr clear_hgr2
	jmp j10B9

	.byte $07,$ea
s3347:
	ldx a61A5
	bne b334D
	rts

b334D:
	dex
	dex
	beq b3354
	jmp j3457

b3354:
	jsr s1015
	jsr s3422
	ldx #$01
	stx count+1
	jsr s33F3
j3361:
	jsr s0CCA
	lda a619C
	cmp #$46
	bpl b337A
	jsr s2640
j336E:
	jsr s0B19
	jsr s0B77
	jsr s3435
	jmp j3361

b337A:
	cmp #$5b
	beq b33DD
	sta count+1
	lda a61B6
	bne b3390
	ldx count+1
	stx a61B6
	inc a61B5
	jmp j33D4

b3390:
	cmp count+1
	bne b33B1
	inc a61B5
	lda a61B4
	cmp #$03
	bne j33D4
	cmp a61B5
	bne j33D4
	ldx #$04
	stx p6193
	jsr s1015
	jsr s3422
	jmp j34D5

b33B1:
	ldx count+1
	stx a61B6
	lda a61B4
	cmp a61B5
	bne b33C9
	ldx #$01
	stx a61B5
	dec a61B4
	jmp j33D4

b33C9:
	jsr s3427
	inc a61B5
	ldx count+1
	stx a61B6
j33D4:
	jsr s1015
	inc a61B7
	jmp j336E

b33DD:
	jsr s127E
	ldx #$09
	stx zp_col
	ldx #$0a
	stx zp_row
	lda #$7c
	jsr print_display_string
	jsr s3427
	jmp j3361

s33F3:
	lda a619C
	cmp #$08
	beq b3401
	cmp #$5a
	bpl b3401
	jsr s1045
s3402=*+$01
b3401:
	lda #$24
	jsr s0892
	lda count+1
	cmp #$01
	beq b3411
	lda #$26
	jsr print_display_string
b3411:
	lda #$25
	jsr s08A4
	lda count+1
	cmp #$01
	beq b3421
	lda #$26
	jsr print_display_string
b3421:
	rts

s3422:
	ldx #$00
	stx a61B7
s3427:
	ldx #<p05
	stx a61B4
	ldx #>p05
	stx a61B5
	stx a61B6
	rts

s3435:
	lda a61B7
	cmp #$06
	bcc b3449
	cmp #$0f
	bcc b3421
	cmp #$15
	bcc b3449
	cmp #$1a
	bcc b3450
	rts

b3449:
	ldx #$01
	stx count+1
	jmp s33F3

b3450:
	ldx #$00
	stx count+1
	jmp s33F3

j3457:
	dex
	dex
	beq b345E
	jmp j34F0

b345E:
	jsr s1015
	lda #$31
	jsr s08A4
	jsr s1045
j3469:
	jsr s0CCA
	ldx a619D
	stx count+1
	lda a619C
	cmp #$0e
	beq b348B
	cmp #$06
	beq b3499
	cmp #$03
	beq b3499
b3480:
	jsr s105F
	lda #$9b
	jsr s0892
	jmp j10B9

b348B:
	lda count+1
	cmp #$15
	bne b3480
	lda #$8c
j3493:
	jsr s08A4
	jmp j3469

b3499:
	jsr s105F
	ldx #$09
	stx src
	ldx #$06
	stx src+1
	jsr s1A34
	lda count+1
	cmp #$07
	bne b3480
	lda a619D
	cmp #$09
	bne b3480
	lda #$50
	jsr s0892
	lda #$51
	jsr s08A4
	ldx #$00
	stx src+1
	ldx #$09
	stx src
	jsr s1A34
	ldx #$07
	stx src+1
	jsr s1A34
	ldx #$00
	stx a61AB
j34D5:
	lda a61A6
	sta count+1
	sta a61A5
	ldx a61A7
	stx a61A6
	ldx #$00
	stx a61A7
	lda count+1
	beq b34EF
	jmp s3347

b34EF:
	rts

j34F0:
	dex
	dex
	bne b34FF
	jsr s3510
	ldx #$00
	stx a61AE
	jmp j34D5

b34FF:
	dex
	beq b3505
	jmp j35EA

b3505:
	jsr s3510
	ldx #$00
	stx a61AF
	jmp j34D5

s3510:
	jsr s1015
	lda #$2e
	jsr s08A4
	jsr s1045
	jsr s0CCA
	lda a619D
	sta count+1
	lda a619C
	cmp #$59
	bcs b3536
	cmp #$06
	beq b359F
	cmp #$13
	beq b354F
	cmp #$0e
	beq b3541
b3536:
	jsr s105F
	lda #$2f
	jsr s08A4
	jmp j10B9

b3541:
	lda count+1
	cmp #$16
	bne b3536
	lda #$28
	jsr s08A4
	jmp s3510

b354F:
	lda count+1
	cmp #$16
	bne b3536
	ldx #<p0604
	stx src
	ldx #>p0604
	stx src+1
	jsr s1A34
	lda #$08
	cmp count+1
	beq b3585
	ldx #<p060E
	stx src
	ldx #>p060E
	stx src+1
	jsr s1A34
	lda #$08
	cmp count+1
	bne b3536
	jsr s105F
	lda #$97
	jsr s08A4
j357F:
	lda #$63
	jsr s0892
	rts

b3585:
	ldx #>p04
	stx src+1
	ldx #<p04
	stx src
	jsr s1A34
	ldx #$07
	stx src+1
	jsr s1A34
	lda #$64
	jsr s08A4
	jmp j357F

b359F:
	lda count+1
	cmp #$0c
	bne b3536
	ldx #<p060C
	stx src
	ldx #>p060C
	stx src+1
	jsr s1A34
	lda #$08
	cmp count+1
	bne b3536
	ldx #<string_ptr
	stx src
	ldx #>string_ptr
	stx src+1
	jsr s1A34
	jsr s28D9
	lda #$5c
	jsr s0892
	lda #$5d
	jsr s08A4
	jsr s1045
	jsr s105F
	lda #$30
	jsr s0892
	jsr s1045
	jsr s105F
	lda #$5c
	jsr s0892
	lda #$5d
	jsr s08A4
	rts

j35EA:
	dex
	beq b35F0
	jmp j3686

b35F0:
	lda a619C
	cmp #$50
	bcc b35FA
	jsr s1015
b35FA:
	lda a61B2
	bne b3612
	jsr s366C
	lda #$43
	jsr s0892
j3608=*+$01
	lda #$44
	jsr s08A4
	inc a61B2
	jmp j364E

b3612:
	lda a61B2
	cmp #$01
	bne b3629
	lda #$45
	jsr s0892
	lda #$46
	jsr s08A4
	inc a61B2
s3626:
	jmp j364E

b3629:
	jsr clear_hgr2
	lda #$36
	jsr s0892
	lda #$37
	jsr s08A4
	lda a61B8
	bne b363E
	jmp j10B9

b363E:
	lda #$75
	ldx #<p1500
	stx zp_col
	ldx #>p1500
	stx zp_row
	jsr print_display_string
	jmp j10B9

j364E:
	jsr s0CCA
	lda a619C
	cmp #$50
	bcc b365E
	jsr s0949
	jmp s3347

b365E:
	jsr s2640
	ldx #$0c
	stx a61B2
	jsr s366C
	jmp s3347

s366C:
	lda p0C7A
	cmp #$80
	beq b3677
	cmp #$20
	bne b367F
b3677:
	lda p0CA2
	cmp #$80
	bne b367F
	rts

b367F:
	jsr s1045
	jsr s105F
	rts

j3686:
	dex
	beq b368C
	jmp j3777

b368C:
	lda a619C
	cmp #$50
	bcc b3696
	jsr s1015
b3696:
	lda a61B3
	bne b36AE
	jsr s366C
	lda #$43
	jsr s0892
	lda #$44
	jsr s08A4
	inc a61B3
	jmp j364E

b36AE:
	tax
	dex
	bne b36D3
	ldx #>p0608
	stx src+1
	ldx #<p0608
	stx src
	jsr s1A34
	lda #$07
	cmp count+1
	beq b36D3
	lda #$45
	jsr s0892
	lda #$46
	jsr s08A4
	inc a61B3
	jmp j364E

b36D3:
	lda #$48
	jsr s0892
	ldx #<p0608
	stx src
	ldx #>p0608
	stx src+1
	jsr s1A34
	lda #$07
	cmp count+1
	bne b36EE
	lda #$49
	jsr s08A4
b36EE:
	lda count+1
	pha
	lda count
	pha
	jsr s0CCA
	jsr s105F
	lda a619D
	cmp #$18
	beq b371E
	cmp #$19
	beq b371E
b3705:
	pla
	sta count
	pla
	sta count+1
	lda #$07
	cmp count+1
	bne b3716
	lda #$4a
	jsr s0892
b3716:
	lda #$4b
	jsr s08A4
	jmp j10B9

b371E:
	lda a619C
	cmp #$0e
	bne b3735
	lda #$8c
	jsr s08A4
	tax
	pla
	sta count
	pla
	sta count+1
	txa
	jmp b36EE

b3735:
	cmp #$13
	bne b3705
	ldx #<p060E
	stx src
	ldx #>p060E
	stx src+1
	jsr s1A34
	lda #$08
	cmp count+1
	bne b3705
	pla
	sta count
	pla
	sta count+1
	lda #$07
	cmp count+1
	bne b3716
	lda #$4a
	jsr s0892
	lda #$4c
	jsr s08A4
	jsr s1045
	lda #$78
	jsr s08A4
	ldx #$00
	stx a61B3
	stx a61AC
	stx a61A5
	stx a61A6
	rts

j3777:
	dex
	beq b377D
	jmp j3802

b377D:
	lda a619C
	cmp #$50
	bcc b3787
	jsr s1015
b3787:
	lda a619E
	beq b3794
	ldx #$00
	stx a61B3
	jmp j34D5

b3794:
	ldx #$00
	stx a61A4
	lda a61B3
	bne b37C7
	lda a6194
	cmp #$05
	beq b37AF
	lda a61AD
	and #$02
	bne b37B4
b37AC:
	jmp j34D5

b37AF:
	lda a61AC
	beq b37AC
b37B4:
	jsr s366C
	lda #$43
	jsr s0892
	lda #$44
	jsr s08A4
	inc a61B3
	jmp j364E

b37C7:
	cmp #$01
	bne b37DE
	jsr s366C
	inc a61B3
	lda #$45
	jsr s0892
	lda #$47
	jsr s08A4
	jmp j364E

b37DE:
	jsr s366C
	lda a6194
	cmp #$05
	beq b37F5
	lda #$36
	jsr s0892
	lda #$37
	jsr s08A4
	jmp j10B9

b37F5:
	lda #$48
	jsr s0892
	lda #$4b
b37FC:
	jsr s08A4
	jmp j10B9

j3802:
	dex
	bne b3874
	lda a619D
	cmp #$11
	beq b3813
b380C:
	jsr s105F
	lda #$20
	bne b37FC
b3813:
	lda a619C
	cmp #$0e
	beq b386C
	cmp #$13
	bne b380C
	ldx #$04
	stx src
	ldx #$06
	stx src+1
	jsr s1A34
	lda count+1
	cmp #$07
	bpl b3842
	ldx #$0e
	stx src
	ldx #$06
	stx src+1
	jsr s1A34
	lda count+1
	cmp #$07
	bmi b380C
	bpl b3864
b3842:
	ldx #$04
	stx src
	ldx #$00
	stx src+1
	jsr s1A34
	ldx #$00
	stx src+1
	ldx #$11
	stx src
	jsr s1A34
	ldx #$07
	stx src+1
	jsr s1A34
	lda #$64
	jsr s08A4
b3864:
	lda #$63
	jsr s0892
	jmp j34D5

b386C:
	lda #$8c
	jsr s08A4
	jmp j364E

b3874:
	dex
	beq b387A
	jmp j396E

b387A:
	lda a619C
	cmp #$50
	bcc b3884
	jsr s1015
b3884:
	lda a61B6
	cmp #$09
	beq b38EA
	inc a61B6
	jsr s3894
	jmp j392C

s3894:
	lda p6193
	sta count+1
	lda a6195
	cmp #$0a
	bne b38DD
	lda a6196
	sec
	sbc #$09
	beq b38CC
	tax
	dex
	beq b38BB
	dex
	bne b38DD
	lda #$01
	cmp count+1
	bne b38DD
	ldx #$01
	stx src+1
	bne b38DA
b38BB:
	lda #$02
	cmp count+1
	bne b38DD
	ldx #$10
	stx src
	ldx #$09
	stx src+1
	jmp b38DA

b38CC:
	lda #$02
	cmp count+1
	bne b38DD
	ldx #$20
	stx src
	lda #$09
	stx src+1
b38DA:
	jsr s1E5A
b38DD:
	lda #$41
	ldx #<p0206
	stx zp_col
	ldx #>p0206
	stx zp_row
	jmp print_display_string

b38EA:
	jsr s3894
	jsr s0CCA
	lda a619C
	cmp #$10
	bne b3916
	lda a619D
	cmp #$17
	bne b3916
	lda p6193
	cmp #$01
	bne b3916
	lda a6195
	cmp #$0a
	bne b3916
	lda a6196
	cmp #$0b
	bne b3916
	jmp j3C86

b3916:
	jsr s30C5
	jsr clear_hgr2
	ldx #<p1500
	stx zp_col
	ldx #>p1500
	stx zp_row
	lda #$42
	jsr print_display_string
	jmp j10B9

j392C:
	jsr s0CCA
	lda a619C
	cmp #$59
	bcc b393C
	jsr s0949
	jmp s3347

b393C:
	lda a619C
	cmp #$10
	bne b3962
	lda a619D
	cmp #$17
	bne b3962
	lda p6193
	cmp #$01
	bne b3962
	lda a6195
	cmp #$0a
	bne b3962
	lda a6196
	cmp #$0b
	bne b3962
	jmp j3C86

b3962:
	jsr s0B19
	jsr s2640
	jsr s0B77
	jmp s3347

j396E:
	dex
	beq b3974
	jmp j3A20

b3974:
	jsr s0CCA
	lda a619C
	cmp #$5b
	beq b39B5
j397E:
	lda a61A6
	sta a61A5
	lda a61A7
	ldx #$00
	stx a61A7
	sta a61A6
	jsr s1015
	lda a619C
	cmp #$5b
	bcc b399C
	jmp s0949

b399C:
	jmp s2640

j399F:
	lda #$a3
	jsr s0892
	jsr s1045
	lda #$a4
	jsr s08A4
	jsr s1045
	jsr s1015
	jmp j34D5

b39B5:
	jsr s127E
	ldx a6194
	dex
	dex
	beq b39D2
	dex
	beq b3A03
	dex
	beq b3A0D
	lda #$6d
	jsr s0892
	lda #$6e
	jsr s08A4
	jmp j10B9

b39D2:
	jsr s127E
	ldx #$03
	stx src+1
	stx a6199
	ldx #$23
	stx src
	stx a619A
	jsr s12A6
	ldx #$03
	stx src+1
	jsr s1E5A
	jsr s0FDC
	jsr s127E
	lda #$79
	ldx #<p0A08
	stx zp_col
	ldx #>p0A08
	stx zp_row
	jsr print_display_string
	jmp j10B9

b3A03:
	inc a6194
	ldx #$01
	stx a6195
	bne b3A15
b3A0D:
	dec a6194
	ldx #$04
	stx a6195
b3A15:
	ldx #$00
	stx a61A3
	stx a61A4
	jmp j399F

j3A20:
	dex
	beq b3A26
	jmp j3AEA

b3A26:
	lda a61B2
	cmp #$0c
	bne b3A30
	jsr s0CCA
b3A30:
	ldx #$00
	stx a61B2
j3A35:
	lda a619D
	cmp #$18
	beq b3A3F
b3A3C:
	jmp b3629

b3A3F:
	lda a619C
	cmp #$0e
	bne b3A49
	jmp j3AD4

b3A49:
	cmp #$13
	bne b3A3C
	lda a619E
	beq b3A3C
	ldx #<p0604
	stx src
	ldx #>p0604
	stx src+1
	jsr s1A34
	lda #$08
	cmp count+1
	bne b3A3C
	jsr s105F
	ldx #<p0104
	stx src
	ldx #>p0104
	stx src+1
	jsr s1A34
	ldx #$07
	stx src+1
	jsr s1A34
	lda #$64
	jsr s0892
	jsr s1045
	lda #$61
	jsr s0892
	lda #$62
	jsr s08A4
	ldx #$00
	stx a61AD
	lda a61A6
	cmp #$08
	bne b3A9F
	lda a61A7
	sta a61A6
	stx a61A7
b3A9F:
	jsr s0CCA
	lda a619C
	cmp #$09
	bne b3ADF
	lda a619D
	cmp #$09
	bne b3ADF
	ldx #>p0609
	stx src+1
	ldx #<p0609
	stx src
	jsr s1A34
	lda #$08
	cmp count+1
	bne b3ADF
	ldx #<p0309
	stx src
	ldx #>p0309
	stx src+1
	jsr s1A34
	lda #$60
	jsr s08A4
	jmp j34D5

j3AD4:
	lda #$8c
	jsr s0892
	jsr s0CCA
	jmp j3A35

b3ADF:
	jsr s105F
	lda #$78
	jsr s0892
	jmp j397E

j3AEA:
	dex
	beq b3AF0
	jmp j3C86

b3AF0:
	jsr s0CCA
	lda a619C
	cmp #$5a
	bcc b3AFD
b3AFA:
	jmp b380C

b3AFD:
	cmp #$07
	bne b3AFA
	lda a619D
	cmp #$11
	bne b3AFA
	lda a6195
	sta count+1
	lda a6196
	sta count
	lda a6194
	cmp #$03
	beq b3B2C
	cmp #$04
	bne b3B38
	lda count+1
	cmp #$01
	bne b3B38
	lda count
	cmp #$0a
	bne b3B38
	jmp j3B61

b3B2C:
	lda count+1
	cmp #$08
	bne b3B38
	lda count
	cmp #$05
	beq b3B56
b3B38:
	jsr s30C5
	lda #$2d
	jsr s0892
	lda #$a5
	jsr s08A4
	jsr s1045
	jsr s105F
	lda #$a6
	jsr s0892
	jsr s1045
	jmp b380C

b3B56:
	ldx #$01
	stx count
	inx
	stx p6193
	jmp j3B6A

j3B61:
	ldx #$00
	stx count
	ldx #$03
	stx p6193
j3B6A:
	dec a6194
	lda count+1
	pha
	lda count
	pha
	jsr s1015
	jsr s0CCA
	lda a619C
	cmp #$5b
	beq b3B8E
	jsr s105F
	lda #$54
	jsr s0892
	jsr s1045
	jmp b380C

b3B8E:
	pla
	sta count
	pla
	sta count+1
	pha
	lda count
	pha
	cmp #$01
	beq b3BA2
	inc a6195
	jmp j3BA5

b3BA2:
	inc a6196
j3BA5:
	jsr s1015
	lda #$59
	jsr s0892
	lda #$11
	jsr s25E3
	lda #$77
	jsr print_display_string
	ldx #$11
	stx src
	ldx #$00
	stx src+1
	jsr s1A34
	ldx #$07
	stx src+1
	jsr s1A34
	pla
	sta count
	pla
	sta count+1
	lda count
	cmp #$01
	bne b3BD8
	jmp j34D5

b3BD8:
	lda a61AD
	beq b3C03
	lda #$59
	jsr s08A4
	lda #$0f
	jsr s25E3
	lda #$77
	jsr print_display_string
	ldx #$00
	stx src+1
	ldx #$0f
	stx src
	jsr s1A34
	ldx #$01
	stx a61B8
	ldx #$07
	stx src+1
	jsr s1A34
b3C03:
	ldx #$01
	stx a61B9
	ldx #$07
	stx src+1
	jsr s1A34
j3C0F:
	jsr s0CCA
	lda a619C
	cmp #$5a
	bcs b3C2B
	cmp #$11
	bne b3C25
	lda #$98
	jsr s08A4
	jmp j3C0F

b3C25:
	jsr s2640
	jmp j3C37

b3C2B:
	cmp #$5b
	beq b3C58
	ldx p6193
	stx count+1
	jsr s0956
j3C37:
	lda p6193
	ldx #<p0400
	stx src
	ldx #>p0400
	stx src+1
	cmp #$01
	bne b3C55
	lda a619E
	beq b3C55
	lda a619A
	and #$e0
	beq b3C55
	jsr s1E5A
b3C55:
	jmp j3C0F

b3C58:
	lda p6193
	cmp #$01
	beq b3C72
	jsr s127E
	ldx #<p0A09
	stx zp_col
	ldx #>p0A09
	stx zp_row
	lda #$7c
	jsr print_display_string
	jmp j3C0F

b3C72:
	inc a6194
	ldx #$03
	stx p6193
	dec a6195
	jsr s107C
	jsr s1015
	jmp j34D5

j3C86:
	jsr s127E
	lda #<p4707
	sta a6199
	ldx #>p4707
	stx a619A
	jsr s12A6
	ldx #>p0801
	stx src+1
	ldx #<p0801
	stx src
	jsr s1E5A
	ldx #$01
	stx a61A8
j3CA6:
	lda #$a0
	jsr s0892
	jsr s0CCA
	lda a61A8
	sta count+1
	lda a619C
	dec count+1
	bne b3CE9
	cmp #$5a
	bpl b3CC1
	jmp j3ECA

b3CC1:
	cmp #$5b
	beq b3CC8
	jmp j3EAA

b3CC8:
	jsr s127E
	ldx #<p2303
	stx a6199
	ldx #>p2303
	stx a619A
	jsr s12A6
	ldx #>p0802
	stx src+1
	ldx #<p0802
	stx src
	jsr s1E5A
	inc a61A8
	jmp j3CA6

b3CE9:
	dec count+1
	bne b3D11
	cmp #$5a
	bpl b3CF4
	jmp j3ECA

b3CF4:
	cmp #$5b
	beq b3CFB
	jmp j3EAA

b3CFB:
	jsr s127E
	ldx #<p01
	stx a6199
	ldx #>p01
	stx a619A
	jsr s12A6
	inc a61A8
	jmp j3CA6

b3D11:
	dec count+1
	bne b3D40
	cmp #$5a
	bpl b3D1C
	jmp j3ECA

b3D1C:
	cmp #$5d
	beq b3D23
	jmp j3EAA

b3D23:
	jsr s127E
	ldx #<p01
	stx a6199
	ldx #>p01
	stx a619A
	jsr s12A6
	ldx #$02
	stx src+1
	jsr s1E5A
	inc a61A8
	jmp j3CA6

b3D40:
	dec count+1
	bne b3D69
	cmp #$5a
	bmi b3D4B
	jmp j3EAA

b3D4B:
	cmp #$10
	beq b3D52
	jmp j3ECA

b3D52:
	lda a619D
	cmp #$17
	beq b3D5C
	jmp j3ECA

b3D5C:
	ldx #$0a
	stx src+1
	jsr s1E5A
	inc a61A8
	jmp j3CA6

b3D69:
	dec count+1
	bne b3DDD
	cmp #$5b
	bne b3D8E
	jsr s127E
	ldx #<p1400
	stx zp_col
	ldx #>p1400
	stx zp_row
	lda #$3a
	jsr print_display_string
	lda #$0a
	jsr s1192
	lda #$3b
	jsr print_display_string
	jmp j10B9

b3D8E:
	cmp #$5a
	bmi b3D95
	jmp j3EAA

b3D95:
	cmp #$06
	beq b3D9C
b3D99:
	jmp j3ECA

b3D9C:
	lda a619D
	cmp #$01
	bne b3D99
	ldx #>p0601
	stx src+1
	ldx #<p0601
	stx src
	jsr s1A34
	lda count+1
	cmp #$08
	bne b3D99
	jsr s127E
	jsr s30C5
	ldx #<p4607
	stx a6199
	ldx #>p4607
	stx a619A
	jsr s12A6
	ldx #$01
	stx src+1
	stx src
	jsr s1A34
	ldx #$07
	stx src+1
	jsr s1A34
	inc a61A8
	jmp j3CA6

b3DDD:
	dec count+1
	bne b3E05
	cmp #$5a
	bpl b3DE8
b3DE5:
	jmp j3ECA

b3DE8:
	cmp #$5b
	beq b3DEF
b3DEC:
	jmp j3EAA

b3DEF:
	jsr s127E
	ldx #<p2303
	stx a6199
	ldx #>p2303
	stx a619A
	jsr s12A6
	inc a61A8
	jmp j3CA6

b3E05:
	cmp #$5a
	bmi b3DE5
	cmp #$5b
	bne b3DEC
	jsr s127E
	ldx #$01
	stx a6199
	stx a619A
	jsr s12A6
j3E1B:
	lda #$3c
	jsr s0892
	lda #$3d
	jsr s08A4
	jsr s0CCA
	lda a619C
	cmp #$5a
	bpl b3DEC
	cmp #$15
	beq b3E89
	jmp j3E49

p3E36:
	.byte $42,$45,$4f,$57,$55,$4c,$46,$20
	.byte $44,$49,$53,$41,$47,$52,$45,$45
	.byte $53,$21,$80
j3E49:
	jsr s105F
	ldx #<p1600
	stx zp_col
	ldx #>p1600
	stx zp_row
	ldx #<p3E36
	stx string_ptr
	ldx #>p3E36
	stx string_ptr+1
	jsr print_string
	jsr s1045
	jmp j3E1B

p3E65:
	.byte $52,$45,$54,$55,$52,$4e,$20,$54
	.byte $4f,$20,$53,$41,$4e,$49,$54,$59
	.byte $20,$42,$59,$20,$50,$52,$45,$53
	.byte $53,$49,$4e,$47,$20,$52,$45,$53
	.byte $45,$54,$21,$80
b3E89:
	jsr clear_hgr2
	ldx #$00
	stx zp_col
	stx zp_row
	lda #$4d
	jsr print_display_string
	lda #$0a
	jsr s1192
	ldx #<p3E65
	stx string_ptr
	ldx #>p3E65
	stx string_ptr+1
	jsr print_string
j3EA7:
	jmp j3EA7

j3EAA:
	jsr s127E
	jsr s105F
	ldx #<p1400
	stx zp_col
	ldx #>p1400
	stx zp_row
	lda #$a1
	jsr print_display_string
	lda #$0a
	jsr s1192
	lda #$a2
	jsr print_display_string
	jmp j10B9

j3ECA:
	lda #$9a
	jsr s08A4
	jmp j3CA6

	.byte $86
	inc aC3
	bne b3EDC
	ldx #$2e
	jsr s244B
b3EDC:
	stx aBE
	stx aBD
	lda a018F
	beq b3F40
	lda f0135,y
	cmp #$28
	beq b3EF4
	ldx #$25
	jsr s244B
	jmp j3F56

b3EF4:
	stx aE5
	iny
	jsr s2510
	cmp #$3b
	beq b3F38
	cpy #$50
relocate_data:
	lda p3FFF
	beq @write_DEATH

; Relocate data above HGR2: ($4000-$5FFF) to ($6000-$7FFF)
	ldx #$00
	stx src
	stx dst
	stx p3FFF
	ldx #$40
	stx src+1
	ldx #$60
	stx dst+1
	ldx #<p1FFF
	stx count
	ldx #>p1FFF
	stx count+1
	jsr memcpy
	ldx #opcode_JMP
	stx DOS_hook_monitor
	ldx #<vector_reset
	stx DOS_hook_monitor+1
	ldx #>vector_reset
	stx DOS_hook_monitor+2
@write_DEATH:
	ldx #'D'
	stx a6200
	ldx #'E'
b3F38=*+$01
	stx a6201
	ldx #'A'
	stx a6202
b3F40=*+$01
	ldx #'T'
	stx a6203
	ldx #'H'
	stx a6204
	ldx #$00
	stx zp_row
	rts

vector_reset:
	bit hw_PAGE2
	bit hw_FULLSCREEN
j3F56=*+$02
	bit hw_HIRES
	bit hw_GRAPHICS
	jmp warm_start

	ldy #$00
	tya
	sta (pC2),y
	cmp #$ff
	bne b3F68
	dec aC3
b3F68:
	pla
	pla
	jmp j2C04

	stx aBC
	ldx #$2b
	jsr s244B
	jmp j2C04

s3F77:
	lda a0124
	sta a3C
	lda a0125
	sta a3D
	lda a0126
	sta a3E
	lda a0127
	sta a3F
	rts

	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	lda aEE
	beq b3FA3
	jsr s3FA0
	rts

s3FA0:
	jmp (p00F6)

b3FA3:
	jsr s3F77
	jsr eFEFD
	ldx #$00
	rts

	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	lda aEF
	beq b3FD3
	jsr s3FD0
	rts

s3FD0:
	jmp (p00F4)

b3FD3:
	jsr s3F77
	jsr eFECD
	rts

	jsr eFD35
	cmp #$95
	bne b3FE3
	lda (p28),y
b3FE3:
	rts

	ora #$80
	jmp eFDED

	.byte $00
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	php
	brk
p3FFF:
	.byte $ff


	.segment "HIGH"

	.assert * = $6000, error, "Unexpected alignment"
p6000:
	.byte $d5,$7d,$57,$a6,$95,$d3,$b6,$56
	.byte $9c,$a5,$da,$48,$96,$13,$6f,$cb
	.byte $94,$af,$b8,$57,$2f,$a9,$da,$6f
	.byte $a3,$49,$2f,$94,$95,$0f,$ff,$ff
	.byte $ff,$df,$77,$5f,$c8,$aa,$cf,$9d
	.byte $1a,$df,$cd,$4a,$6f,$9b,$68,$8f
	.byte $a2,$a4,$df,$96,$96,$af,$d8,$4e
	.byte $cf,$b7,$76,$9f,$88,$88,$4f,$ff
	.byte $ff,$ff,$d5,$d5,$7f,$9c,$bd,$af
	.byte $cb,$a2,$9f,$99,$b6,$2f,$cd,$99
	.byte $2f,$a2,$55,$af,$b5,$5a,$bf,$8d
	.byte $e2,$6f,$a2,$37,$2f,$95,$54,$4f
	.byte $ff,$ff,$ff,$d7,$f7,$7f,$b2,$66
	.byte $af,$a5,$28,$af,$97,$0c,$8f,$c8
	.byte $bb,$df,$9b,$22,$2f,$ea,$d9,$6f
	.byte $92,$2d,$af,$d3,$22,$2f,$94,$55
	.byte $4f,$ff,$ff,$ff,$d7,$55,$df,$9a
	.byte $cc,$4f,$da,$b9,$5f,$a0,$f6,$6f
	.byte $b1,$9b,$2f,$ac,$e0,$6f,$bd,$9d
	.byte $af,$aa,$4a,$af,$a2,$52,$2f,$9c
	.byte $9d,$07,$ff,$ff,$ff
p60A5:
	.byte $42,$34,$05,$01,$42,$35,$05,$02
	.byte $42,$36,$05,$00,$22,$83,$04,$01
	.byte $22,$84,$04,$00,$42,$86,$04,$00
	.byte $22,$75,$08,$01,$22,$76,$08,$02
	.byte $32,$77,$02,$00,$23,$43,$08,$04
	.byte $13,$44,$02,$00,$13,$95,$05,$01
	.byte $33,$68,$07,$04,$23,$78,$07,$02
	.byte $13,$88,$07,$01,$24,$14,$02,$00
	.byte $14,$24,$08,$02,$14,$2a,$05,$01
	.byte $14,$3a,$05,$02,$14,$4a,$05,$00
	.byte $35,$25,$08,$04,$25,$35,$02,$00
	.byte $35,$3a,$09,$f0,$35,$4a,$09,$f0
	.byte $35,$5a,$09,$70,$35,$6a,$09,$30
	.byte $35,$7a,$09,$10,$15,$5a,$09,$01
	.byte $15,$6a,$09,$03,$15,$7a,$09,$07
	.byte $15,$8a,$09,$0f,$15,$9a,$09,$0f
	.byte $15,$aa,$09,$0e,$25,$4a,$01,$00
	.byte $25,$5a,$01,$00,$25,$6a,$01,$00
	.byte $25,$7a,$01,$00,$25,$8a,$01,$00
p613D:
	.byte $02,$01,$0a,$06,$01,$00,$07,$bf
	.byte $00,$00,$00,$01,$00,$a0,$c8,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $02,$04,$02,$01,$01,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $01,$35,$03,$a5,$01,$33,$01,$46
	.byte $04,$58,$01,$64,$01,$1b,$04,$71
	.byte $02,$11,$05,$72,$01,$23,$01,$72
	.byte $02,$86,$03,$2a,$03,$6a,$04,$57
	.byte $02,$39,$02,$26,$03,$56,$04,$72
	.byte $02,$82,$03,$26,$04,$96
p6193:
	.byte $02
a6194:
	.byte $05
a6195:
	.byte $04
a6196:
	.byte $0a
a6197:
	.byte $00
a6198:
	.byte $01
a6199:
	.byte $00
a619A:
	.byte $00
a619B:
	.byte $00
a619C:
	.byte $10
a619D:
	.byte $17
a619E:
	.byte $01
a619F:
	.byte $00
a61A0:
	.byte $80
a61A1:
	.byte $80
a61A2:
	.byte $00
a61A3:
	.byte $00
a61A4:
	.byte $29
a61A5:
	.byte $00
a61A6:
	.byte $00
a61A7:
	.byte $00
a61A8:
	.byte $00,$00,$00
a61AB:
	.byte $00
a61AC:
	.byte $04
a61AD:
	.byte $00
a61AE:
	.byte $00
a61AF:
	.byte $01,$00
a61B1:
	.byte $00
a61B2:
	.byte $0c
a61B3:
	.byte $00
a61B4:
	.byte $05
a61B5:
	.byte $00
a61B6:
	.byte $00
a61B7:
	.byte $00
a61B8:
	.byte $00
a61B9:
	.byte $01,$00
p61BB:
	.byte $08
p61BC:
	.byte $00,$03,$a5,$00,$00,$04,$a9,$08
	.byte $00,$01,$64,$02,$33,$08,$00,$00
	.byte $00,$05,$72,$07,$00,$00,$00,$02
	.byte $86,$08,$00,$04,$a8,$04,$57
p61DB:
	.byte $00,$00
p61DD:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$08,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00
a61F7:
	.byte $44
a61F8:
	.byte $45
a61F9:
	.byte $41
a61FA:
	.byte $54
a61FB:
	.byte $48
a61FC:
	.byte $07
a61FD:
	.byte $00,$00,$00
a6200:
	.byte $44
a6201:
	.byte $45
a6202:
	.byte $41
a6203:
	.byte $54
a6204:
	.byte $48,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00
p6292:
	.byte $00,$00
font:
	.byte $10,$08,$3e,$7f,$ff,$ff,$be,$1c
	.byte $01,$02,$04,$08,$08,$10,$20,$40
	.byte $40,$20,$10,$08,$08,$04,$02,$01
	.byte $01,$01,$01,$01,$01,$01,$01,$01
	.byte $40,$40,$40,$40,$40,$40,$40,$40
	.byte $41,$22,$14,$08,$14,$22,$41,$41
	.byte $40,$60,$70,$78,$78,$7c,$7e,$7f
	.byte $01,$03,$07,$0f,$0f,$1f,$3f,$7f
	.byte $7f,$7e,$7c,$78,$78,$70,$60,$40
	.byte $7f,$3f,$1f,$0f,$0f,$07,$03,$01
	.byte $41,$41,$41,$41,$41,$41,$41,$41
	.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	.byte $00,$78,$64,$5e,$52,$32,$1e,$00
	.byte $00,$00,$00,$00,$78,$04,$02,$7f
	.byte $00,$00,$00,$00,$0f,$0c,$0a,$09
	.byte $09,$09,$09,$09,$09,$05,$03,$01
	.byte $00,$00,$00,$00,$7f,$00,$00,$7f
	.byte $09,$09,$09,$09,$09,$09,$09,$09
	.byte $01,$01,$01,$01,$01,$01,$01,$7f
	.byte $00,$00,$00,$00,$00,$00,$00,$7f
	.byte $40,$20,$10,$08,$08,$0c,$0a,$09
	.byte $09,$0a,$0c,$08,$08,$10,$20,$40
	.byte $08,$08,$08,$08,$08,$08,$08,$08
	.byte $41,$42,$44,$48,$48,$50,$60,$40
	.byte $00,$00,$00,$1c,$08,$1c,$00,$00
	.byte $60,$70,$70,$60,$60,$70,$70,$70
	.byte $03,$07,$07,$03,$03,$07,$07,$07
	.byte $07,$07,$07,$07,$07,$07,$07,$07
	.byte $70,$70,$70,$70,$70,$70,$70,$70
	.byte $01,$03,$07,$07,$07,$07,$07,$07
	.byte $40,$60,$70,$70,$70,$70,$70,$70
	.byte $78,$78,$78,$78,$7f,$7f,$7f,$7f
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $08,$08,$08,$08,$08,$00,$08,$00
	.byte $14,$14,$14,$00,$00,$00,$00,$00
	.byte $14,$14,$3e,$14,$3e,$14,$14,$00
	.byte $1c,$2a,$0a,$1c,$28,$2a,$1c,$00
	.byte $26,$26,$10,$08,$04,$32,$32,$00
	.byte $04,$0a,$0a,$04,$2a,$12,$2c,$00
	.byte $08,$08,$08,$00,$00,$00,$00,$00
	.byte $10,$08,$04,$04,$04,$08,$10,$00
	.byte $04,$08,$10,$10,$10,$08,$04,$00
	.byte $08,$2a,$1c,$08,$1c,$2a,$08,$00
	.byte $00,$08,$08,$3e,$08,$08,$00,$00
	.byte $00,$00,$00,$00,$10,$10,$08,$00
	.byte $00,$00,$00,$3e,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$0c,$0c,$00
	.byte $20,$20,$10,$08,$04,$02,$02,$00
	.byte $1c,$22,$32,$2a,$26,$22,$1c,$00
	.byte $08,$0c,$08,$08,$08,$08,$1c,$00
	.byte $1c,$22,$20,$1c,$02,$02,$3e,$00
	.byte $1e,$20,$20,$1c,$20,$20,$1e,$00
	.byte $10,$18,$14,$12,$3e,$10,$10,$00
	.byte $3e,$02,$1e,$20,$20,$20,$1e,$00
	.byte $18,$04,$02,$1e,$22,$22,$1c,$00
	.byte $3e,$20,$10,$08,$04,$04,$04,$00
	.byte $1c,$22,$22,$1c,$22,$22,$1c,$00
	.byte $1c,$22,$22,$3c,$20,$10,$0c,$00
	.byte $00,$0c,$0c,$00,$0c,$0c,$00,$00
	.byte $00,$0c,$0c,$00,$0c,$0c,$04,$00
	.byte $10,$08,$04,$02,$04,$08,$10,$00
	.byte $00,$00,$3e,$00,$3e,$00,$00,$00
	.byte $04,$08,$10,$20,$10,$08,$04,$00
	.byte $1c,$22,$10,$08,$08,$00,$08,$00
	.byte $1c,$22,$3a,$2a,$3a,$02,$3c,$00
	.byte $08,$14,$22,$22,$3e,$22,$22,$00
	.byte $1e,$24,$24,$1c,$24,$24,$1e,$00
	.byte $1c,$22,$02,$02,$02,$22,$1c,$00
	.byte $1e,$24,$24,$24,$24,$24,$1e,$00
	.byte $3e,$02,$02,$1e,$02,$02,$3e,$00
	.byte $3e,$02,$02,$1e,$02,$02,$02,$00
	.byte $3c,$02,$02,$02,$32,$22,$3c,$00
	.byte $22,$22,$22,$3e,$22,$22,$22,$00
	.byte $1c,$08,$08,$08,$08,$08,$1c,$00
	.byte $20,$20,$20,$20,$22,$22,$1c,$00
	.byte $22,$12,$0a,$06,$0a,$12,$22,$00
	.byte $02,$02,$02,$02,$02,$02,$7e,$00
	.byte $22,$36,$2a,$2a,$22,$22,$22,$00
	.byte $22,$26,$2a,$32,$22,$22,$22,$00
	.byte $1c,$22,$22,$22,$22,$22,$1c,$00
	.byte $1e,$22,$22,$1e,$02,$02,$02,$00
	.byte $1c,$22,$22,$22,$2a,$12,$2c,$00
	.byte $1e,$22,$22,$1e,$0a,$12,$22,$00
	.byte $1c,$22,$02,$1c,$20,$22,$1c,$00
	.byte $3e,$08,$08,$08,$08,$08,$08,$00
	.byte $22,$22,$22,$22,$22,$22,$1c,$00
	.byte $22,$22,$22,$14,$14,$08,$08,$00
	.byte $22,$22,$2a,$2a,$2a,$36,$22,$00
	.byte $22,$22,$14,$08,$14,$22,$22,$00
	.byte $22,$22,$22,$1c,$08,$08,$08,$00
	.byte $3e,$20,$10,$08,$04,$02,$3e,$00
	.byte $08,$1c,$2a,$08,$08,$08,$08,$00
	.byte $08,$08,$08,$08,$2a,$1c,$08,$00
	.byte $00,$04,$02,$7f,$02,$04,$00,$00
	.byte $00,$10,$20,$7f,$20,$10,$00,$00
	.byte $70,$60,$40,$00,$00,$00,$00,$00
	.byte $07,$03,$01,$00,$00,$00,$00,$00
	.byte $00,$00,$1c,$20,$3c,$22,$3c,$00
	.byte $02,$02,$1a,$26,$22,$22,$1e,$00
	.byte $00,$00,$1c,$22,$02,$22,$1c,$00
	.byte $20,$20,$2c,$32,$22,$22,$3c,$00
	.byte $00,$00,$1c,$22,$3e,$02,$1c,$00
	.byte $18,$24,$04,$0e,$04,$04,$04,$00
	.byte $00,$00,$2c,$32,$22,$3c,$20,$1e
	.byte $02,$02,$1a,$26,$22,$22,$22,$00
	.byte $08,$00,$0c,$08,$08,$08,$1c,$00
	.byte $20,$00,$20,$20,$20,$20,$22,$1c
	.byte $02,$02,$12,$0a,$06,$0a,$12,$00
	.byte $00,$0c,$08,$08,$08,$08,$1c,$00
	.byte $00,$00,$16,$2a,$2a,$2a,$2a,$00
	.byte $00,$00,$1a,$26,$22,$22,$22,$00
	.byte $00,$00,$1c,$22,$22,$22,$1c,$00
	.byte $00,$00,$1e,$22,$22,$1e,$02,$02
	.byte $00,$00,$3c,$22,$22,$3c,$20,$20
	.byte $00,$00,$1a,$26,$02,$02,$02,$00
	.byte $00,$00,$3c,$02,$1c,$20,$1e,$00
	.byte $04,$04,$1e,$04,$04,$24,$18,$00
	.byte $00,$00,$22,$22,$22,$32,$2c,$00
	.byte $00,$00,$22,$22,$14,$14,$08,$00
	.byte $00,$00,$2a,$2a,$2a,$2a,$14,$00
	.byte $00,$00,$22,$14,$08,$14,$22,$00
	.byte $00,$00,$22,$22,$22,$3c,$20,$1c
	.byte $00,$00,$3e,$10,$08,$04,$3e,$00
	.byte $0f,$0f,$0f,$0f,$7f,$7f,$7f,$7f
	.byte $70,$78,$7c,$7e,$7f,$7f,$7f,$7f
	.byte $07,$0f,$1f,$3f,$7f,$7f,$7f,$7f
	.byte $7f,$7f,$7f,$7f,$7e,$7c,$78,$70
	.byte $7f,$7f,$7f,$7f,$3f,$1f,$0f,$07
	.assert * = $6694, error, "Unexpected alignment"
p6694:
	.byte $ff
verb_table:
	.include "strings_verbs.i"
noun_table:
	.include "strings_nouns.i"
junk_string:
	.byte $ff,$ff,$00,$00,$ff,$ff,$00,$00
	.byte $ff
display_string_table:
	.include "strings_display.i"
	.byte $ff
	.byte "FE", $D2, $85, "Y STA *", $C8, $90, "   AIV DEYALPSID YLTNATSNOC"
	.byte " SI NOI", $08, $08, $08, $08, " NOITACO", $0C, "              00005 "
	.byte "EZ", $08, "XAMTAE", $04, "           %`GREN DEC *", $C8, "0` BNE"
	.byte " GOON6", $B8, "5` JMP UNCOM", $D0, "@`GOON68 DEC *", $C8, "E"
	.assert * = $77bf, error, "Unexpected alignment"
p77BF:
	.byte "`"
intro_text:
	.include "strings_intro.i"
	.byte $A0
junk_intro:
	.byte $80, "RT", $D3, "pdUN DEC IY", $B2, "ud RT", $D3, $80, "dDEUX INC IY", $B3, $85, "d R"
	.byte "T", $D3, $90, "dTROIS INC IY", $B2, $95, "d RT", $D3, $00, "eJUKILL JSR DRA", $D7
	.byte $05, "e JSR TIME", $B1, $10, "e JSR WHIT", $C5, $15, "e JSR CLRWN", $C4, " e "
	.byte "LDA #4", $B2, "%e JSR POIN", $D4, "0e LDA #4", $B3, "5e JSR POIN"
	.byte "T", $B5, "@e JMP "
text_savegame:
	.byte "Save to DISK or TAPE (T or D)?"
	.byte $80
text_loadgame:
	msbstring "Get from DISK or TAPE (T or D)?"
	.byte $80
	.assert * = $7c3f, error, "Unexpected alignment"
s7C3F:
	jsr clear_hgr2
	ldx #$00
	stx zp_col
	stx zp_row
	ldx #<text_loadgame
	stx string_ptr
	ldx #>text_loadgame
	stx string_ptr+1
	jsr print_string
	jsr s7C94
	cmp #$44
	bne b7C5D
	jmp j7D0C

b7C5D:
	jsr clear_hgr2
	lda #$95
	jsr s0892
	rts

j7C66:
	jsr clear_hgr2
	ldx #$00
	stx zp_col
	stx zp_row
	ldx #<text_savegame
	stx string_ptr
	ldx #>text_savegame
	stx string_ptr+1
	jsr print_string
	jsr s7C94
	cmp #$54
	beq b7C84
	jmp j7CEF

b7C84:
	jsr clear_hgr2
	jsr s1015
	ldx #$07
	stx src+1
	jsr s1A34
	jmp j31BC

s7C94:
	bit hw_STROBE
b7C97:
	jsr blink_cursor
	bit hw_KEYBOARD
	bpl b7C97
	lda hw_KEYBOARD
	and #$7f
	cmp #$54
	beq b7CAC
	cmp #$44
	bne s7C94
b7CAC:
	pha
	jsr clear_cursor
	pla
	rts

	.byte $00,$01,$ef,$d8,$01,$60,$01,$00
	.byte $03,$00,$00,$3f,$93,$61,$00,$00
a7CC2:
	.byte $01
a7CC3:
	.byte $00,$00,$60,$01
p7CC7:
	.byte $D0, "lace data diskette in DRIVE 1, SLOT 6.", $80
j7CEF:
	ldx #$02
	stx a7CC2
	jsr s7D4F
	bcc b7CFF
	jsr s7D74
	jmp j7E23

b7CFF:
	jsr clear_hgr2
	jsr s1015
	ldx #$07
	stx src+1
	jmp s1A34

j7D0C:
	ldx #$01
	stx a7CC2
	jsr s7D4F
	bcc s7D1C
	jsr s7D74
	jmp j7E1D

s7D1C:
	ldy #$00
	lda a6200,y
	cmp #$44
	bne b7D4A
	iny
	lda a6200,y
	cmp #$45
	bne b7D4A
	iny
	lda a6200,y
	cmp #$41
	bne b7D4A
	iny
	lda a6200,y
	cmp #$54
	bne b7D4A
	iny
	lda a6200,y
	cmp #$48
	bne b7D4A
	pla
	pla
	jmp j084A

b7D4A:
	lda #$05
	jmp j7E1D

s7D4F:
	lda #$0a
	jsr s1192
	ldx #<p7CC7
	stx string_ptr
	ldx #>p7CC7
	stx string_ptr+1
	jsr print_string
	lda #$0a
	jsr s1192
	lda #$96
	jsr print_display_string
	jsr input_char
	lda #$7c
	ldy #$b6
	jsr e03D9
	rts

s7D74:
	lda a7CC3
	cmp #$10
	bne b7D7E
	lda #$01
	rts

b7D7E:
	cmp #$20
	bne b7D85
	lda #$02
	rts

b7D85:
	cmp #$40
	bne b7D8C
	lda #$03
	rts

b7D8C:
	lda #$04
	rts

p7D8F:
	.byte "DISKETTE WRITE PROTECTED!", $80, "VOLUME MISMATC"
	.byte "H!", $80, "DRIVE ERROR! CAUSE UNKNOWN!", $80, "READ ERRO"
	.byte "R! CHECK YOUR DISKETTE!", $80, "NOT A DEATHMAZE "
	.byte "FILE! INPUT REJECTED!", $80
j7E1D:
	ldx #$00
	stx dst
	beq b7E27
j7E23:
	ldx #$ff
	stx dst
b7E27:
	tay
	dey
	bne b7E2D
	beq b7E44
b7E2D:
	dey
	bne b7E34
	ldy #$1a
	bne b7E44
b7E34:
	dey
	bne b7E3B
	ldy #$2b
	bne b7E44
b7E3B:
	dey
	bne b7E42
	ldy #$47
	bne b7E44
b7E42:
	ldy #<p68
b7E44:
	sty count
	ldx #>p68
	stx count+1
	ldx #<p7D8F
	stx string_ptr
	ldx #>p7D8F
	stx string_ptr+1
	clc
	lda count
	adc string_ptr
	sta string_ptr
	lda count+1
	adc string_ptr+1
	sta string_ptr+1
	lda #$0a
	jsr s1192
	jsr print_string
	jsr input_char
	lda dst
	beq b7E71
	jmp b7CFF

b7E71:
	pla
	pla
	jmp j0805

	lda a61A5
	bne b7E81
	ldx #$06
	stx a61A5
	rts

b7E81:
	.byte $06
	lda #$04
	sta zp_row
	lda #$03
	ldy #$0d
	jsr s17A7
	lda #>p4211
	sta screen_ptr+1
	lda #<p4211
	sta screen_ptr
	ldy #$04
	jsr s1777
	lda #>p5C61
	sta screen_ptr+1
	lda #<p5C61
	sta screen_ptr
	ldy #$04
	jsr s1777
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #$03
	ldy #$15
	jsr s17A7
	jmp j16E8

	pla
	pha
	cmp #$01
	bne b7ECE
	lda #$12
	sta zp_col
	lda #$04
	sta zp_row
	lda #$03
	ldy #$0d
	jsr s17A7
b7ECE:
	lda #$15
	sta zp_col
	lda #$00
	sta zp_row
	ldy #$04
	jsr s177F
	lda #$12
	sta zp_col
	lda #$11
	sta zp_row
	ldy #$04
	jsr s1795
	pla
	cmp #$00
	beq b7F4C
	lda a6199
	and #$01
	bne b7F1B
	lda #$00
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$15
	jsr s17A7
	lda #>p3FFF
	sta screen_ptr+1
	lda #<p3FFF
	sta screen_ptr
	ldy #$01
	jsr s1777
	lda #>p5E4F
	sta screen_ptr+1
	lda #<p5E4F
	sta screen_ptr
	ldy #$01
	jsr s1777
b7F1B:
	lda a619A
	and #$01
	bne b7F4B
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #$03
	ldy #$15
	jsr s17A7
	lda #>p4015
	sta screen_ptr+1
	lda #<p4015
	sta screen_ptr
	ldy #$01
	jsr s1777
	lda #>p5E65
	sta screen_ptr+1
	lda #<p5E65
	sta screen_ptr
	ldy #$01
	jsr s1777
b7F4B:
	rts

b7F4C:
	lda a6199
	and #$01
	beq b7F60
	lda #$00
	sta zp_col
	sta zp_row
	lda #$04
	ldy #$15
	jsr s17A7
b7F60:
	lda a619A
	and #$01
	beq b7F4B
	lda #$16
	sta zp_col
	lda #$00
	sta zp_row
	lda #$03
	ldy #$15
	jsr s17A7
	rts

	lda #$ff
b7F79:
	sta (screen_ptr),y
	dey
	bne b7F79
	rts

	tya
	sta count+1
b7F82:
	jsr get_rowcol_addr
	lda #$02
	jsr s1192
	dec zp_col
	dec zp_col
	inc zp_row
	dec count+1
	bne b7F82
	rts

	tya
	sta count+1
b7F98:
	jsr get_rowcol_addr
	lda #$01
	jsr s1192
	inc zp_row
	dec count+1
	bne b7F98
	rts

	pha
	tya
	sta count+1
	pla
b7FAC:
	pha
	jsr get_rowcol_addr
	pla
	pha
	jsr print_char
	pla
	dec zp_col
	inc zp_row
	dec count+1
	bne b7FAC
	rts

	ldy #$00
	lda #<p6000
	sta a0A
	lda #>p6000
	sta a0B
	ldx a6194
	lda #$00
	clc
	dex
	beq b7FD7
	adc #$21
	jmp j17CF

b7FD7:
	adc a0A
	sta a0A
	ldx a6195
	dex
	beq b7FEA
	inc a0A
	inc a0A
	inc a0A
	jmp j17DE

b7FEA:
	lda a6196
	cmp #$05
	bmi b7FFF
	cmp #$09
	bmi b7FFA
	inc a0A
	sec
	sbc #$04
b7FFA:
	inc a0A
	sec
	sbc #$04
	.assert * = $7fff, error, "Unexpected alignment"
b7FFF:
	brk
