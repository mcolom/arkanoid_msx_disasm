; Alien table
; Each entry is 20 positions
ALIEN_TABLE: equ 0xe4c7
ALIEN_TABLE_LEN: equ 20
;
ALIEN_TABLE_IDX_COLOR: equ 0        ; 0xe4c7
ALIEN_TABLE_IDX_ACTIVE: equ 1       ; 0xe4c8
ALIEN_TABLE_IDX_EXPLODING: equ 2    ; 0xe4c9
ALIEN_TABLE_IDX_TICKS: equ 3        ; 0xe4ca
; [ToDo] Incomplete table



ALIEN_ACTIVE_EXPLODING: equ 2 ; Alien is active and exploding
ALIEN_EXPLODING_FLAG: equ 1   ; Alien is exploding

; <UNKNOWN>
; <Active>
; <ACTION>: 0=not exploding, 1=exploding
