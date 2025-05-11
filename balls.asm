; Extra balls, apart from the current.
; For example, after getting the cyan brick, there are
; 3 balls = 2 EXTRA_BALLS.
EXTRA_BALLS: equ 0xe325

; Simply an index to iterate through the 3 balls
BALL_LOOP_INDEX: equ 0xe2ac

SPEEDUP_ALL_BALLS_COUNTER: equ 0xe529

; Ball table
BALL_TABLE_LEN: equ 20
BALL_TABLE1: equ 0xe24e + 0*BALL_TABLE_LEN
BALL_TABLE2: equ 0xe24e + 1*BALL_TABLE_LEN
BALL_TABLE3: equ 0xe24e + 2*BALL_TABLE_LEN
;
BALL_TABLE_IDX_ACTIVE: equ 0
;
; 0: ball is glued and moved to Vaus
; 1: ball is glued
; 2: ball moves normally
BALL_TABLE_IDX_GLUE: equ 1
;
; 01, 02: ball going down
; FF, FE: ball going up
BALL_TABLE_IDX_Y_SPEED:  equ 2

;BALL_TABLE_: equ 3
; 01, 02: ball going right
; FF, FE: ball going left
BALL_TABLE_IDX_X_SPEED: equ 3

; The ball moves then the counter BALL_TABLE_IDX_MOVE_COUNTER reaches its
; target BALL_TABLE_IDX_MOVE_TARGET.
BALL_TABLE_IDX_MOVE_COUNTER: equ 5
BALL_TABLE_IDX_MOVE_TARGET: equ 9
BALL_TABLE_IDX_SKEWNESS: equ 6
BALL_TABLE_IDX_SPEED_POS: equ 7
; The speed is added to the position BALL_TABLE_IDX_SPEED_MULTIPLIER+1 times
BALL_TABLE_IDX_SPEED_MULTIPLIER: equ 8
BALL_TABLE_IDX_SPEED_COUNTER: equ 13
BALL_TABLE_IDX_GLUE_COUNTER: equ 14
BALL_TABLE_IDX_VAUS_HIT_X: equ 16 ; X-position in Vaus on which it received the ball


;ToDo
; After each brick hit, this contains the new ball's X speed
COMPUTED_X_SPEED: equ 0xe542
COMPUTED_Y_SPEED: equ 0xe543


; When this counter reaches 40, the skewness of the balls change
BALL_BOUNCES_COUNTER: equ 0xe51c

; Counter to change the ball skewness
ACTION_SKEWNESS_COUNTER: equ 0xe5ac


; ToDO
; The games does
;	ld a,(ix+SPR_PARAMS_IDX_Y)		;9c64
;	sub (iy+BALL_TABLE_IDX_Y_SPEED)
;	ld (0e586h),a
BALL_Y_MINUS_SPEED: equ 0xe586
BALL_X_MINUS_SPEED: equ 0xe587
