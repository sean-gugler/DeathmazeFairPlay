	.export vocab_table
	.export verb_table
	.export noun_table

	.exportzp vocab_end

	.include "msbstring.i"
	.include "string_noun_decl.i"
	.include "string_verb_decl.i"

	.segment "STRINGS"

vocab_table:
	.byte $ff

verb_table:
	.include "string_verb_defs.inc"

noun_table:
	.include "string_noun_defs.inc"

; 1-based indexing.
vocab_end = 1 + (verbs_end - 1) + (nouns_end - 1)

