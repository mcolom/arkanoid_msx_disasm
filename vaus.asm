;VAUS_TABLE_ACTION_STATE: equ 0xe54b
VAUS_TABLE: equ 0xe54b

; State of wait (waiting to be ready, doing nothing, enlarging, exploding, ...)
VAUS_TABLE_IDX_ACTION_STATE: equ 0
;
VAUS_ACTION_STATE_WAIT_READY: equ 0
VAUS_ACTION_STATE_KEEP: equ 1
VAUS_ACTION_STATE_ENLARGING: equ 2
VAUS_ACTION_STATE_SHRINKING: equ 3
VAUS_ACTION_STATE_LASER: equ 4
VAUS_ACTION_STATE_UNLASER: equ 5
VAUS_ACTION_STATE_EXPLODING: equ 6
VAUS_ACTION_STATE_THROUGH_PORTAL: equ 7

; Vaus changes its size in 3 steps
VAUS_TABLE_IDX_SIZING_STEP: equ 1

; Vaus changes to laser in 10 steps
VAUS_TABLE_IDX_LASERING_STEP: equ 2

; Vaus destruction steps are controled by these two counters
VAUS_TABLE_IDX_DESTRUCTION_STEP1: equ 3
VAUS_TABLE_IDX_DESTRUCTION_STEP2: equ 4

VAUS_TABLE_IDX_SIZING: equ 5
; It can be VAUS_ACTION_STATE_ENLARGING or VAUS_ACTION_STATE_SHRINKING

VAUS_TABLE_IDX_HAS_LASER: equ 6

VAUS_TABLE_IDX_LASER_TRANSFORMATION_STEP: equ 7

; This two variables control Vaus entering the portal
VAUS_TABLE_IDX_VAUS_PORTALING_STEP1: equ 8
VAUS_TABLE_IDX_VAUS_PORTALING_STEP2: equ 9


VAUS_X:  equ 0xe0ce
VAUS_X2: equ 0xe53e

; Vaus is enlarged, because of the blue capsule
VAUS_IS_ENLARGED: equ 0xe321

; Flag to reset the sprite of Vaus to the center initial position
RESET_VAUS_SPR_POSITION: equ 0xe5a9
