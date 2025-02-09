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
BALL_TABLE_IDX_VERT:  equ 2

;BALL_TABLE_: equ 3
; 01, 02: ball going right
; FF, FE: ball going left
BALL_TABLE_IDX_HORIZ: equ 3

BALL_TABLE_IDX_SKEWNESS: equ 6


;
BALL_TABLE_IDX_SPEED_POS: equ 7
BALL_TABLE_IDX_SPEED_COUNTER: equ 13
BALL_TABLE_IDX_GLUE_COUNTER: equ 14
BALL_TABLE_IDX_VAUS_HIT_X: equ 16 ; X-position in Vaus on which it received the ball

