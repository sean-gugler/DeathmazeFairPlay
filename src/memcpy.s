	.export memcpy
	
	.segment "MEMCPY"

memcpy:
	ldy #$00
@next_byte:
	lda (zp0E_src),y
	sta (zp10_dst),y
	inc zp0E_src
	bne :+
	inc zp0E_src+1
:	inc zp10_dst
	bne :+
	inc zp10_dst+1
:	dec zp19_count
	beq @check_done
	lda zp19_count
	cmp #$ff
	bne @next_byte
	dec zp19_count+1
	jmp @next_byte

@check_done:
	lda zp19_count+1
	ora zp19_count
	bne @next_byte
	rts
