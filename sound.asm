; Buffer of sound codes
SOUNDS_BUFFER: equ 0xe520

; The code for the SOUND being played
SOUND_NUMBER: equ 0xe5c0

; Period/volumen states 1 and 2
PERIOD_EFFECT_STATE_1: equ 0xe5de
VOLUME_EFFECT_STATE_1: equ 0xe5e1
PERIOD_EFFECT_STATE_2: equ 0xe5f4
VOLUME_EFFECT_STATE_2: equ 0xe5f7

DELAYED_EFFECT_STATE_A_STREAM1: equ 0xe5e6
;DELAYED_EFFECT_STATE_B_STREAM1: equ 0xe5e7
DELAYED_EFFECT_STATE_C_STREAM1: equ 0xe5e8

DELAYED_EFFECT_STATE_A_STREAM2: equ 0xe5fc



DELAYED_REPEAT_STATUS: equ 0xe5e7


; The sound is played only if zero
; The game nevers inhibits the sounds
SOUND_INHIBIT: equ 0xe5c1

; Bitmask indicating which voices to activate
SOUND_REG_MASK: equ 0xe5c3

; Actually unused
SOUND_PARALLEL: equ 0xe5d2

; Noise generation
SOUND_NOISE: equ 0xe5ca

SOUND_VOICE_CONTROL: equ 0xe5cb
SOUND_VOLUME_CONTROL: equ 0xe5cc
SOUND_PERIOD_CONTROL: equ 0xe5c6

SOUND_VOLUME: equ 0xe5ce



; SOUND_BUFFER_1 with pointer SOUND_PTR_1
; SOUND_BUFFER_2 with pointer SOUND_PTR_2

SOUND_BUFFER_1: equ 0xe5d3
SOUND_BUFFER_2: equ 0xe5e9

SOUND_PTR_1: equ 0xe5da
SOUND_PTR_2: equ 0xe5f0

; How many sounds are being played
SOUNDS_COUNT: equ 0xe51e

; We see a lot of activity from 0xe5c3 to 0xe5bf when music is played

; The values in this buffer are copied to the PSG registers
SOUNDS_REGS_BUFFER: equ 0xe5c4


CAN_ADD_SOUND: equ 0xe5c2

; For SOUND_BUFFER_:
AUDIO_TABLE_IDX_ACTIVE:           equ 0
;AUDIO_TABLE_IDX_NEXT_SOUND_ID    equ 1
;AUDIO_TABLE_IDX_FOLLOW_SOUND      equ 2
;AUDIO_TABLE_IDX_CHAIN_COUNT       equ 3
;AUDIO_TABLE_IDX_REPEAT_COUNT      equ 4
;AUDIO_TABLE_IDX_DESC_PTR_LO       equ 5
;AUDIO_TABLE_IDX_DESC_PTR_HI       equ 6
;AUDIO_TABLE_IDX_STREAM_PTR_LO     equ 7
;AUDIO_TABLE_IDX_STREAM_PTR_HI     equ 8
AUDIO_TABLE_IDX_TICKS_COUNTDOWN:  equ 9

SOUND_SEQUENCE_LEN: equ 8
