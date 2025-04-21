VRAM_SPRITES_ATTRIB_TABLE: equ 0x1b00
VRAM_SPRITES_PATTERN_TABLE: equ 0x3800

; The last bit is used to control the sprite switching
SPRITE_SWITCH_FLAG: equ 0xe545

; This area is used to temporarily copy the
; sprite params,before switching
SPRITE_SWITCH_SCRATCH: equ 0xe546

LEN_SPRITE_PATTERN: equ 64 ; for sprites 16x16

TOTAL_SPRITES: equ 32
; Sprite attributes
; This is written to VRAM continuosly
SPRITE_ATTRIBS_AREA: equ 0xe18d


