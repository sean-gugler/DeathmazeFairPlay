	.export display_string_table

	.segment "STRINGS"

display_string_table:
	.include "string_display_defs.inc"
	.byte $ff

