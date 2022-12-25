; Data copied into the Game State
; when a new game is started.

	.byte $02		;player facing
	.byte $01		;player level
	.byte $0a		;player x
	.byte $06		;player y
	.byte $01		;torches lit
	.byte $00		;torches unlit
	.byte $07		;99
	.byte $bf		;9A
	.byte $00		;9B
	.byte $00		;parsed action
	.byte $00		;parsed object
	.byte $01		;room lit
	.byte $00,$a0	;food time (high,low)
	.byte $c8		;torch time
	.byte $00		;teleported with lit torch
	.byte $00,$00	;level turns (high,low)
	.byte $00		;special input mode
	.byte $00		;mode stack 1
	.byte $00		;mode stack 2
	.byte $00		;gs_exit_turns
	.byte $00		;A9
	.byte $00		;AA
	.byte $02		;bat alive (flag $02)
	.byte $04		;AC
	.byte $02		;monster lurks (flag $02)
	.byte $01		;dog 1 alive
	.byte $01		;dog 2 alive
	.byte $00		;B0
	.byte $00		;next hint
	.byte $00		;monster proximity
	.byte $00		;mother proximity
	.byte $00		;rotate puzzle: target count
	.byte $00		;rotate puzzle: current count
	.byte $00		;rotate puzzle: last direction
	.byte $00		;rotate puzzle: total turns
	.byte $00		;lair raided
	.byte $00		;snake used (useless; written but never checked)
	.byte $00		;unused
; item locations: place (level), position XY
	.byte $01,$35	;ball
	.byte $03,$a5	;brush
	.byte $01,$33	;calculator
	.byte $01,$46	;dagger
	.byte $04,$58	;flute
	.byte $01,$64	;frisbee
	.byte $01,$1b	;hat
	.byte $04,$71	;horn
	.byte $02,$11	;jar
	.byte $05,$72	;key
	.byte $01,$23	;ring
	.byte $01,$72	;sneaker
	.byte $02,$86	;staff
	.byte $03,$2a	;sword
	.byte $03,$6a	;wool
	.byte $04,$57	;yoyo
	.byte $02,$39	;snake
	.byte $02,$26	;food
	.byte $03,$56	;food
	.byte $04,$72	;food
	.byte $02,$82	;torch
	.byte $03,$26	;torch
	.byte $04,$96	;torch