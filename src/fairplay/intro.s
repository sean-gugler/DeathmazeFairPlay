	.export intro_text
	
	.segment "STRINGS"

intro_text:
	.include "string_intro_defs.inc"
	.byte $A0
	.byte $80

