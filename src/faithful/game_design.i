door_correct = $02  ;1-based

food_eat_amount = $00aa
food_fart_consume = $000a
food_fart_minimum = $05
food_hungry = $0a

inventory_max = $08

moves_until_mother = $32
moves_until_dog1 = $3c
moves_until_monster = $50
.if REVISION >= 100
moves_until_trippable = moves_until_monster
.else ;RETAIL - if you throw wool between these two times, instant death.
moves_until_trippable = $29
.endif

puzzle_step1 = $05

torch_low = $0a
torch_lifespan = $96

; Pseudo-verbs for navigation actions
verb_movement_begin = $5a
verb_forward    = $5b
verb_left       = $5c
verb_right      = $5d
verb_uturn      = $5e



textbuf_max_input = $1E

vocab_word_size = $04
