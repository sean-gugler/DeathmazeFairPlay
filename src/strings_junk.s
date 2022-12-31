; This file contains data completely unused by the game.
; It's only purpose is to preserve the ability to build
; a program that exactly matches the retail binary.

	.segment "STRINGS"

;cruft
	.byte           "FE"
	.byte $D2, $85, "Y STA *"
	.byte $C8, $90, "   AIV DEYALPSID YLTNATSNOC SI NOI"
	.byte $08, $08                        ;reversed: ION IS CONSTANTLY DISPLAYED VIA
	.byte $08, $08, " NOITACO", $0C       ;reversed: [^L]OCATION
	.byte "              00005 EZ", $08
	.byte "XAMTAE", $04                   ;reversed: EATMAX
	.byte "          "
	.byte $20, $25, $60, "GREN DEC *"
	.byte $C8, $30, $60, " BNE GOON6"
	.byte $B8, $35, $60, " JMP UNCOM"
	.byte $D0, $40, $60, "GOON68 DEC *"
	.byte $C8, $45, $60

