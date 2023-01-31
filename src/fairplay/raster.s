	.export row8_table

	.segment "RASTER"

	; Table of memory addresses for the
	; start rasters of each 8-raster row
	; of font characters.

	; Stored big-endian, presumably because it felt more
	; natural to the original authors than the 6502-native
	; little-endian ordering.

row8_table:
	.byte $40,$00 ;  1 $00
	.byte $40,$80 ;  2 $01
	.byte $41,$00 ;  3 $02
	.byte $41,$80 ;  4 $03
	.byte $42,$00 ;  5 $04
	.byte $42,$80 ;  6 $05
	.byte $43,$00 ;  7 $06
	.byte $43,$80 ;  8 $07
	.byte $40,$28 ;  9 $08
	.byte $40,$a8 ; 10 $09
	.byte $41,$28 ; 11 $0a
	.byte $41,$a8 ; 12 $0b
	.byte $42,$28 ; 13 $0c
	.byte $42,$a8 ; 14 $0d
	.byte $43,$28 ; 15 $0e
	.byte $43,$a8 ; 16 $0f
	.byte $40,$50 ; 17 $10
	.byte $40,$d0 ; 18 $11
	.byte $41,$50 ; 19 $12
	.byte $41,$d0 ; 20 $13
	.byte $42,$50 ; 21 $14
	.byte $42,$d0 ; 22 $15
	.byte $43,$50 ; 23 $16
	.byte $43,$d0 ; 24 $17
