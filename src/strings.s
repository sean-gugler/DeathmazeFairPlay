	.export display_string_table

	.include "msbstring.i"

	.segment "STRINGS"

display_string_table:
	.include "string_display_defs.inc"
	.byte $ff

