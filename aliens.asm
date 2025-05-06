

; Alien table
; Each entry is 20 positions
ALIEN_TABLE: equ 0xe4c7
ALIEN_TABLE_LEN: equ 20
;
ALIEN_TABLE_IDX_COLOR: equ 0                        ; 0xe4c7
ALIEN_TABLE_IDX_ACTIVE: equ 1                       ; 0xe4c8
ALIEN_TABLE_IDX_EXPLODING: equ 2                    ; 0xe4c9
ALIEN_TABLE_IDX_TICKS: equ 3                        ; 0xe4ca
ALIEN_TABLE_IDX_EXPLOSION_ANIM_TICKS: equ 4         ; 0xe4cb
ALIEN_TABLE_IDX_EXPLOSION_ANIM_NUM: equ 5           ; 0xe4cc    Current pattern when the alien is exploding
ALIEN_TABLE_IDX_FROM_DOOR_HORIZ_SPEED: equ 6        ; 0xe4cd    Initial speed horiz. speed of the alien exiting from the door
ALIEN_TABLE_IDX_IN_DOOR: equ 7      ; 0xe4ce The alien is entering the playfield from the door

ALIEN_TABLE_IDX_VERT_SPEED: equ 8   ; 0xe4cf Vertical speed
ALIEN_TABLE_IDX_HORIZ_SPEED: equ 9  ; 0xe4da Horizontal speed

ALIEN_TABLE_IDX_FLYING_ANIM_NUM: equ 10 ;0xe4db Current pattern when the alien is flying

; ToDo
; ix+11 in 0xe4dc
; ix+12 in 0xe4dd
; ix+13 in 0xe4de
; ix+14 in 0xe4df
; ix+15 in 0xe4e0


ALIEN_TABLE_IDX_NEXT_ACTION: equ 16      ; 0xe4d7 Alien's next action
ALIEN_TABLE_NEXT_FRAME_COUNTER: equ 17   ; 0xe4d8 Counter to update the alien's animation frame
; 1: alien_inv_vert_speed
; 2: alien_inv_horiz_speed
; 3: set_alien_exploding

ALIEN_TABLE_IDX_CAN_CROSS_BRICKS: equ 19      ; 0xe4da The alien can travel through the bricks
; [ToDo] Incomplete table



ALIEN_ACTIVE_EXPLODING: equ 2 ; Alien is active and exploding
ALIEN_EXPLODING_FLAG: equ 1   ; Alien is exploding

; <UNKNOWN>
; <Active>
; <ACTION>: 0=not exploding, 1=exploding


ALIEN_DOOR_TICKS: equ 0xe515
