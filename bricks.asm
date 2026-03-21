BRICK_ROW: equ 0xe2aa
BRICK_COL: equ 0xe2ab ; First brick: 0, second brick: 1, ..., last brick: 10.

BRICK_HIT_Y_PIXEL: equ 0xe53c
BRICK_HIT_X_PIXEL: equ 0xe53d


BRICK_TILEMAP_OFFSET: equ 0xe486 ; Where to write in the tilemap 
BRICK_BIT_COUNT: equ 0xe489 ; This tracks which bit of the brick tilemap we're considering
BRICK_BLOCK: equ 0xe48a ; This tracks which 8-bit block of bricks (the bitmask) we're considering

; This controls how the screen is repainted with bricks
LEVEL_TRANSITION_TYPE: equ 0xe022
LEVEL_TRANSITION_NEXT: equ 0   ; set the initial configuration, all the bricks of the level
LEVEL_TRANSITION_NEXT2: equ 1  ; this goes exactly to the same action as LEVEL_TRANSITION_NEXT
LEVEL_TRANSITION_SAME: equ 2   ; stay in the same level (when a life is lost)

; The brick map in RAM, from 0xe027 to 0xe037 ==> 17 bytes
; Each byte encodes 8 bits in a row. A total of 17*8 = 136 bricks.
; However, the map is 12 cols. x 11 rows = 132 bricks total
BRICK_MAP: equ 0xe027
BRICK_MAP_LEN: equ 17
BRICK_COLS: equ 12
BRICK_ROWS: equ 11

; Number of bricks to break
BRICKS_LEFT: equ 0xe038

; This is a table that for each brick tells how many hits are
; still needed to break a hard brick. Assuming there's a
; hard brick in that position
HARD_BRICKS_REMAINING_HITS: equ 0xe039

HARD_BRICK_TABLE: equ 0xe20d
HARD_BRICK_TABLE_ENTRY_LEN: equ 8
HARD_BRICK_TABLE_NUM_ENTRIES: equ 8

HARD_BRICK_TABLE_IDX_ALREADY_HIT: equ 0
HARD_OR_UNBREAKABLE_BRICK: equ 1 ; Indicates if the brick is hard or unbreakable
HARD_BRICK_TABLE_IDX_VRAM1: equ 2
HARD_BRICK_TABLE_IDX_VRAM2: equ 3
HARD_BRICK_TABLE_IDX_TICKS1: equ 4
HARD_BRICK_TABLE_IDX_ANIM_STEP: equ 5
HARD_BRICK_TABLE_IDX_ROW: equ 6
HARD_BRICK_TABLE_IDX_COL: equ 7

; These variables are set, but never checked
BRICK_UNUSED_1: equ 0xe2ba
BRICK_UNUSED_2: equ 0xe2bb

BRICK_ACTION_TABLE_OFFSET: equ 0xe2bc

; Position of the ball in the brick coordinate space
; BRS = "brick space"
CURR_BRICK_Y: equ 0xe58a
CURR_BRICK_X: equ 0xe58b
PREV_BRICK_Y: equ 0xe58c
PREV_BRICK_X: equ 0xe58d

; These are assigned when the ball collides at something and
; it'll bounce. Depending on the speed of the ball it stores the
; value in a negative o positive variable.
HIY_Y_EDGE_A: equ 0xe2c4
HIY_Y_EDGE_B:     equ 0xe2c5
;
COMPUTED_HIT_X_NEG:  equ 0xe2c6
COMPUTED_HIT_X:      equ 0xe2c7


