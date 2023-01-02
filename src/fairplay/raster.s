	.export row8_table

	.segment "RASTER"

	; Table of memory addresses for the
	; start rasters of each 8-raster row
	; of font characters.

	; Stored big-endian, presumably because it felt more
	; natural to the original authors than the 6502-native
	; little-endian ordering.

row8_table:
	.byte $40,$00 ;  1
	.byte $40,$80 ;  2
	.byte $41,$00 ;  3
	.byte $41,$80 ;  4
	.byte $42,$00 ;  5
	.byte $42,$80 ;  6
	.byte $43,$00 ;  7
	.byte $43,$80 ;  8
	.byte $40,$28 ;  9
	.byte $40,$a8 ; 10
	.byte $41,$28 ; 11
	.byte $41,$a8 ; 12
	.byte $42,$28 ; 13
	.byte $42,$a8 ; 14
	.byte $43,$28 ; 15
	.byte $43,$a8 ; 16
	.byte $40,$50 ; 17
	.byte $40,$d0 ; 18
	.byte $41,$50 ; 19
	.byte $41,$d0 ; 20
	.byte $42,$50 ; 21
	.byte $42,$d0 ; 22
	.byte $43,$50 ; 23
	.byte $43,$d0 ; 24
