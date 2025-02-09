; BCD-encoded scores and heading
SCORE_BCD: equ 0xe015
HIGH_SCORE_BCD: equ 0xe007

; Target score to get a life
SCORE_LIFE_BCD: equ 0xe01e

SCORE_BCD_BUFFER: equ 0xe5a0
ZEROS_BCD_BUFFER: equ 0xe018

; Decoded scores and zeros
DECODED_ASCII_SCORE: equ 0xe58e
DECODED_ASCII_HIGH_SCORE: equ 0xe59a
DECODED_ZEROS: equ 0xe594

; Where to write the scores
; 0: up, 1: on the right
SCORE_POSITION: equ 0xe544
