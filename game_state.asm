GAME_TRANSITION_ACTION: equ 0xe00a
GAME_TRANSITION_ACTION_START_LEVEL: equ 0 ; start level
GAME_TRANSITION_ACTION_PLAY_LEVEL: equ  1 ; normal play
GAME_TRANSITION_ACTION_NEXT_LEVEL: equ  2 ; pause and go to the next level


; Game state
; 0: demo / in title screen
; 1: normal play
; 2: normal play, but without score updates
; (3: demo?)
GAME_STATE: equ 0xe00b


IN_DEMO: equ 0xe00d

; Pause in bit 6 and start in bit 4
; Bit 0: up
; Bit 1: down
; Bit 2: left
; Bit 3: right
; Bit 4: start
; Bit 6: pause
CONTROLS: equ 0xe0bf

DEMO_TIMEOUT: equ 0xe5ad

; Actions for the title's screen
TITLE_SCREEN_ACTION: equ 0xe53c
TITLE_SCREEN_ACTION_GOTO_TITLE_SCREEN: equ 0
TITLE_SCREEN_ACTION_WAIT_IN_TITLE_SCREEN: equ 1
TITLE_SCREEN_ACTION_START_GAME: equ 2
TITLE_SCREEN_ACTION_DEMO: equ 5
