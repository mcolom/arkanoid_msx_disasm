BRICK_ROW: equ 0xe2aa
BRICK_COL: equ 0xe2ab ; First brick: 0, second brick: 1, ..., last brick: 10.

BRICK_HIT_ROW: equ 0xe53c
BRICK_HIT_COL: equ 0xe53d

; This controls how the screen is repainted with bricks
BRICK_REPAINT_TYPE: equ 0xe022
BRICK_REPAINT_INITIAL: equ 0   ; set the initial configuration, all the bricks of the level
BRICK_REPAINT_UNKNOWN: equ 1   ; ???
BRICK_REPAINT_REMAINING: equ 2 ; only paint the non-destroyed bricks

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
