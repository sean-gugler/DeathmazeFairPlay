; String delimited by most significant bit in first character.
  .macro msbstring str
	.byte .strat(str, 1) ^ $80
    .repeat (.strlen(str) - 1), I
	.byte .strat(str, I + 1)
    .endrepeat
  .endmacro

	.segment "MAIN"

	.include "strings_display.i"
