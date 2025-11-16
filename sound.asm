; Buffer of sound codes
SOUNDS_BUFFER: equ 0xe520

; The code for the SOUND being played
SOUND_NUMBER: equ 0xe5c0

; The sound is played only if zero
; The game nevers inhibits the sounds
SOUND_INHIBIT: equ 0xe5c1

SOUND_REG_MASK: equ 0xe5c3

; Noise generation
SOUND_NOISE: equ 0xe5ca

SOUND_VOICE_CONTROL: equ 0xe5cb



; Unknown sound ptr
; ToDo
SOUND_PTR: equ 0xe5da

; How many sounds are being played
SOUNDS_COUNT: equ 0xe51e

; We see a lot of activity from 0xe5c3 to 0xe5bf when music is played

; The values in this buffer are copied to the PSG registers
SOUNDS_REGS_BUFFER: equ 0xe5c4

; ToDo
SOUNDS_UNKNOWN_TYPE: equ 0xe5c4


CAN_ADD_SOUND: equ 0xe5c2
