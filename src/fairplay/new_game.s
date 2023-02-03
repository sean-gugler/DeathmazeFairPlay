	.export data_new_game

	.include "game_design.i"

	.segment "NEW_GAME"

; Data copied into the Game State
; when a new game is started.

data_new_game:
	.byte $02		;player facing
	.byte $01		;player level
	.byte $0a		;player x
	.byte $06		;player y
	.byte $01		;torches lit
	.byte $00		;torches unlit
	.byte $07		;[---wwwww] walls on left (bits, lsb = nearest)
	.byte $bf		;[DDDwwwww] walls on right (bits, lsb = nearest) and Depth (value 0-5)
	.byte $00		;[----vvvv] boxes visible (bits, lsb = nearest)
	.byte $00		;parsed action
	.byte $00		;parsed object
	.byte $01		;room lit
	.byte $00,$a0	;food time (high,low)
	.byte $00		;active torch (0-based)
	.byte $00		;teleported with lit torch
	.byte $00,$00	;level turns (high,low)
	.byte $00		;special input mode
	.byte $00		;mode stack 1
	.byte $00		;mode stack 2
	.byte $00		;endgame step number
	.byte $00		;ring is glowing (lasts 1 turn)
	.byte $00		;staff is charged (lasts 1 turn)
	.byte $02		;bat alive (flag $02)
	.byte $02		;mother alive (flag $02)
	.byte $02		;monster alive (flag $02)
	.byte $01		;dog 1 alive
	.byte $01		;dog 2 alive
	.byte $00		;UNUSED
	.byte $00		;next hint
	.byte $00		;monster step
	.byte $00		;action flags
	.byte $00		;rotate puzzle: target count
	.byte $00		;rotate puzzle: current count
	.byte $00		;rotate puzzle: last direction - ALSO bomb timer, later in the game
	.byte $00		;rotate puzzle: total turns
	.byte $00		;lair raided
	.byte $00		;snake freed
	.byte $01		;jar full
; item locations: place (level), position XY
	.byte $01,$35	;ball
	.byte $03,$6a	;banana
	.byte $03,$a5	;brush
	.byte $01,$33	;calculator
	.byte $01,$46	;dagger
	.byte $02,$86	;flute
	.byte $01,$64	;frisbee
	.byte $01,$16	;hat
	.byte $02,$33	;horn
	.byte $04,$71	;jar
	.byte $05,$72	;key
	.byte $00,$00	;peel
	.byte $01,$23	;ring
	.byte $01,$72	;sneaker
	.byte $04,$58	;staff
	.byte $03,$2a	;sword
	.byte $04,$57	;yoyo
	.byte $03,$96	;bead
	.byte $05,$45	;hook
	.byte $02,$11	;loop
	.byte $05,$a2	;tube
	.byte $02,$39	;snake
	.byte $02,$26	;food
	.byte $03,$56	;food
	.byte $04,$72	;food
	.byte $05,$1b	;food  ;placement TBD
	.byte $07,$00	;torch
	.byte $02,$82	;torch
	.byte $03,$26	;torch
	.byte $04,$96	;torch
; torch lifespans - first is longer per original game design
	.byte $c8
	.byte torch_lifespan
	.byte torch_lifespan
	.byte torch_lifespan
