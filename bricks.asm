BRICK_ROW: equ 0xe2aa
BRICK_COL: equ 0xe2ab ; First brick: 0, second brick: 1, ..., last brick: 10.

BRICKS_LEFT: equ 0xe038

; This controls how the screen is repainted with bricks
BRICK_REPAINT_TYPE: equ 0xe022
BRICK_REPAINT_INITIAL: equ 0   ; set the initial configuration, all the bricks of the level
BRICK_REPAINT_UNKNOWN: equ 1   ; ???
BRICK_REPAINT_REMAINING: equ 2 ; only paint the non-destroyed bricks

BRICK_IS_FALLING: equ 0xe317
