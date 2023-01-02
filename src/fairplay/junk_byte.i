; Preserve junk bytes from original retail,
; but replace with 0s for BSS in fan releases.

.macro JUNK_BYTE value
	.if REVISION >= 100
		.res .tcount(value) / 2 + 1
	.else
		.byte value
	.endif
.endmacro
