	.export maze_features
	.export maze_features_end

	.segment "FEATURE_DATA"

; facing|level, X|Y, drawcmd, draw_param
maze_features:
	.byte $42,$34,$05,$01 ;pit roof
	.byte $42,$35,$05,$02 ;pit roof
	.byte $42,$36,$05,$00 ;pit roof
	.byte $22,$83,$04,$01 ;pit floor
	.byte $22,$84,$04,$00 ;pit floor
	.byte $42,$86,$04,$00 ;pit floor
	.byte $22,$75,$08,$01 ;elevator on right
	.byte $22,$76,$08,$02 ;elevator on right
	.byte $32,$77,$02,$00 ;elevator face-on
	.byte $23,$43,$08,$04 ;elevator on left
	.byte $13,$44,$02,$00 ;elevator face-on
	.byte $13,$95,$05,$01 ;pit roof
	.byte $33,$68,$07,$04 ;square left
	.byte $23,$78,$07,$02 ;square front
	.byte $13,$88,$07,$01 ;square right
	.byte $24,$14,$02,$00 ;elevator face-on
	.byte $14,$24,$08,$02 ;elevator on right
	.byte $14,$2a,$05,$01 ;pit roof
	.byte $14,$3a,$05,$02 ;pit roof
	.byte $14,$4a,$05,$00 ;pit roof
	.byte $35,$25,$08,$04 ;elevator on left
	.byte $25,$35,$02,$00 ;elevator face-on
	.byte $35,$3a,$09,$f0 ;keyholes on left
	.byte $35,$4a,$09,$f0 ;keyholes on left
	.byte $35,$5a,$09,$70 ;keyholes on left
	.byte $35,$6a,$09,$30 ;keyholes on left
	.byte $35,$7a,$09,$10 ;keyholes on left
	.byte $15,$5a,$09,$01 ;keyholes on right
	.byte $15,$6a,$09,$03 ;keyholes on right
	.byte $15,$7a,$09,$07 ;keyholes on right
	.byte $15,$8a,$09,$0f ;keyholes on right
	.byte $15,$9a,$09,$0f ;keyholes on right
	.byte $15,$aa,$09,$0e ;keyholes on right
	.byte $25,$4a,$01,$00 ;keyhole face-on
	.byte $25,$5a,$01,$00 ;keyhole face-on
	.byte $25,$6a,$01,$00 ;keyhole face-on
	.byte $25,$7a,$01,$00 ;keyhole face-on
	.byte $25,$8a,$01,$00 ;keyhole face-on
maze_features_end = <((* - maze_features) / 4)

	.assert * - maze_features <= $100, error, "Maze feature table is too large for indexing"
