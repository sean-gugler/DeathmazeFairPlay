; This file contains data completely unused by the game.
; It's only purpose is to preserve the ability to build
; a program that exactly matches the retail binary.

	.segment "STRINGS"

;cruft:
	.byte                 "RT"
	.byte $D3, $70, $64, "UN DEC IY"
	.byte $B2, $75, $64, " RT"
	.byte $D3, $80, $64, "DEUX INC IY"
	.byte $B3, $85, $64, " RT"
	.byte $D3, $90, $64, "TROIS INC IY"
	.byte $B2, $95, $64, " RT"
	.byte $D3, $00, $65, "JUKILL JSR DRA"
	.byte $D7, $05, $65, " JSR TIME"
	.byte $B1, $10, $65, " JSR WHIT"
	.byte $C5, $15, $65, " JSR CLRWN"
	.byte $C4, $20, $65, " LDA #4"
	.byte $B2, $25, $65, " JSR POIN"
	.byte $D4, $30, $65, " LDA #4"
	.byte $B3, $35, $65, " JSR POINT"
	.byte $B5, $40, $65, " JMP "

