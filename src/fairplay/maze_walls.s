;;; THIS FILE IS AUTO-GENERATED
;;; BY  ../../tools/build_maze.py
;;; FROM  ../../src/fairplay/maze.txt

	.export maze_walls

	.segment "MAZE"

maze_walls:
	;Each 3-byte sequence is one column, south to north (max 12 cells).
	;Columns are sequenced west to east.
	;Each pair of bits is whether there is a wall to South and West of each cell.
	; Level 1
	.byte %11010101,%01110101,%01010111 ; $d5,$75,$57
	.byte %10100110,%10010101,%11001111 ; $a6,$95,$cf
	.byte %10110110,%01010110,%10011111 ; $b6,$56,$9f
	.byte %10100101,%11011010,%01001111 ; $a5,$da,$4f
	.byte %10010110,%00010011,%01101111 ; $96,$13,$6f
	.byte %11001011,%10010100,%10101111 ; $cb,$94,$af
	.byte %10111000,%01010111,%00101111 ; $b8,$57,$2f
	.byte %10101001,%11011010,%01101111 ; $a9,$da,$6f
	.byte %10100011,%01001001,%00101111 ; $a3,$49,$2f
	.byte %10010100,%10010101,%00001111 ; $94,$95,$0f
	.byte %11111111,%11111111,%11111111 ; $ff,$ff,$ff
	; Level 2
	.byte %11011111,%01110111,%01011111 ; $df,$77,$5f
	.byte %11001000,%10101010,%11001111 ; $c8,$aa,$cf
	.byte %10011101,%00011010,%11011111 ; $9d,$1a,$df
	.byte %11001101,%01001010,%01101111 ; $cd,$4a,$6f
	.byte %10011011,%01101000,%10001111 ; $9b,$68,$8f
	.byte %10100010,%10100100,%11011111 ; $a2,$a4,$df
	.byte %10010110,%10010110,%10101111 ; $96,$96,$af
	.byte %11011000,%01001110,%11001111 ; $d8,$4e,$cf
	.byte %10110111,%01110110,%10011111 ; $b7,$76,$9f
	.byte %10001000,%10001000,%01001111 ; $88,$88,$4f
	.byte %11111111,%11111111,%11111111 ; $ff,$ff,$ff
	; Level 3
	.byte %11010101,%11010101,%01111111 ; $d5,$d5,$7f
	.byte %10011100,%10111101,%10101111 ; $9c,$bd,$af
	.byte %11001011,%10100010,%10011111 ; $cb,$a2,$9f
	.byte %10011001,%10110110,%00101111 ; $99,$b6,$2f
	.byte %11001101,%10011001,%01001111 ; $cd,$99,$4f
	.byte %10100010,%01010101,%10101111 ; $a2,$55,$af
	.byte %10110101,%01011010,%10111111 ; $b5,$5a,$bf
	.byte %10001101,%11100010,%01101111 ; $8d,$e2,$6f
	.byte %10100010,%00110111,%00101111 ; $a2,$37,$2f
	.byte %10010101,%01010100,%01001111 ; $95,$54,$4f
	.byte %11111111,%11111111,%11111111 ; $ff,$ff,$ff
	; Level 4
	.byte %11010111,%11110111,%01111111 ; $d7,$f7,$7f
	.byte %10110010,%01100110,%10101111 ; $b2,$66,$af
	.byte %10100101,%00101000,%10101111 ; $a5,$28,$af
	.byte %10010111,%00001100,%10001111 ; $97,$0c,$8f
	.byte %11001000,%10111011,%11011111 ; $c8,$bb,$df
	.byte %10011011,%00100010,%00101111 ; $9b,$22,$2f
	.byte %11101010,%11011001,%01101111 ; $ea,$d9,$6f
	.byte %10010010,%00101101,%10101111 ; $92,$2d,$af
	.byte %11010011,%00100010,%00101111 ; $d3,$22,$2f
	.byte %10010100,%01010101,%01001111 ; $94,$55,$4f
	.byte %11111111,%11111111,%11111111 ; $ff,$ff,$ff
	; Level 5
	.byte %11010111,%01010101,%11111111 ; $d7,$55,$ff
	.byte %10011010,%11001100,%00100111 ; $9a,$cc,$27
	.byte %11011010,%10111001,%01011011 ; $da,$b9,$5b
	.byte %10100000,%11110110,%01101011 ; $a0,$f6,$6b
	.byte %10110001,%10011011,%00101011 ; $b1,$9b,$2b
	.byte %10101100,%11100000,%01101011 ; $ac,$e0,$6b
	.byte %10111101,%10011101,%10101011 ; $bd,$9d,$ab
	.byte %10101010,%01001010,%10101011 ; $aa,$4a,$ab
	.byte %10100010,%01010010,%00101011 ; $a2,$52,$2b
	.byte %10011100,%10011101,%00000111 ; $9c,$9d,$07
	.byte %11111111,%11111111,%11111111 ; $ff,$ff,$ff

.assert >* = >maze_walls, error, "Maze must fit in one page"
