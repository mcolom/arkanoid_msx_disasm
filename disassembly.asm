; z80dasm 1.1.6
; command line: z80dasm -g0x4000 -l -t arkanoid.rom
;
; $ z80asm disassembly.asm && shasum a.bin 
; 2183f07fa3ba87360100b2fa21fda0f55c0f8814  a.bin

include 'headers/bios.asm'
include 'sounds.asm'

SPRITES_ATTRIB_TABLE: equ 0x1b00

; Game state
; 0: in title screen
; 1: normal play
; 2: normal play, with score updates
; 3: normal play, but without score updates
GAME_STATE: equ 0xe00b

DEMO_LEVEL: equ 0xe000

; The two cheats :)
CHEAT1_ACTIVATED: equ 0xe001
CHEAT1_KEY_COUNTER: equ 0xe002
;
CHEAT2_ACTIVATED: equ 0xe003
CHEAT2_KEY_COUNTER: equ 0xe004
CHEAT2_LEVEL: equ 0xe005

; Ball sprite parameters: (Y, X) position, sprite pattern number, and color
BALL1_SPR_PARAMS: equ 0xe0f5
BALL_SPR_PARAMS_LEN: equ 4
BALL2_SPR_PARAMS: equ BALL1_SPR_PARAMS + BALL_SPR_PARAMS_LEN
BALL3_SPR_PARAMS: equ BALL2_SPR_PARAMS + BALL_SPR_PARAMS_LEN
;
BALL_SPR_PARAMS_IDX_Y: equ 0
BALL_SPR_PARAMS_IDX_X: equ 1
BALL_SPR_PARAMS_IDX_PATTERN_NUM: equ 2
BALL_SPR_PARAMS_IDX_COLOR: equ 3


; The game reads the keyboard and writes a mask of bits of the
; relevant keys here
KEYBOARD_INPUT: equ 0xe0c0

VAUS_X:  equ 0xe0ce
VAUS_X2: equ 0xe53e

; The code for the SOUND being played
SOUND_NUMBER: equ 0xe5c0

BRICK_ROW: equ 0xe2aa
BRICK_COL: equ 0xe2ab ; First brick: 0, second brick: 1, ..., last brick: 10.

; Simply an index to iterate through the 3 balls
BALL_LOOP_INDEX: equ 0xe2ac


; BCD-encoded scores and heading
SCORE_BCD: equ 0xe015
HIGH_SCORE_BCD: equ 0xe007

SCORE_BCD_BUFFER: equ 0xe5a0
ZEROS_BCD_BUFFER: equ 0xe018

; Decoded scores and zeros
DECODED_ASCII_SCORE: equ 0xe58e
DECODED_ASCII_HIGH_SCORE: equ 0xe59a
DECODED_ZEROS: equ 0xe594



; Where to write the scores
; 0: up, 1: on the right
SCORE_POSITION: equ 0xe544

; Counts how many ticks the title screen is displayed
TITLE_TICKS: equ 0xe53f

TICKS_240: equ 0xe515

DOH_HITS: equ 0xe5b3

; Extra balls, apart from the current.
; For example, after getting the cyan brick, there are
; 3 balls = 2 EXTRA_BALLS.
EXTRA_BALLS: equ 0xe325
PORTAL_OPEN: equ 0xe326 ; The portal to the next level is open (1) or closed (0)

SPEEDUP_ALL_BALLS_COUNTER: equ 0xe529

; First level is zero
LEVEL: equ 0xe01b
LEVEL_DISP: equ 0xe01c ; Displayed level, in the texts

LIVES: equ 0xe01d
BRICKS_LEFT: equ 0xe038

; This controls how the screen is repainted with bricks
; 0: set the initial configuration, all the bricks of the level
; 1: ???
; 2: only paint the non-destroyed bricks
BRICK_REPAINT_TYPE: equ 0xe022

CAPSULES_LEFT: equ 0xe023
CAPSULES_RANDOM_NUM: equ 0xe024
FINAL_LEVEL: equ 32


; Alien table
; Each entry is 20 positions
ALIEN_TABLE: equ 0xe4c7
ALIEN_TABLE_LEN: equ 20
ALIEN_TABLE_IDX_ACTIVE: equ 1
; [ToDo] Incomplete table

; <UNKNOWN>
; <Active>
; <ACTION>: 0=not exploding, 1=exploding

;This table controls the doors
DOOR_TABLE: equ 0xe570
DOOR_TABLE_LEN: equ 6
;
DOOR_TABLE_IDX_ACTIVE: equ 0
DOOR_TABLE_IDX_DOOR: equ 1
DOOR_TABLE_IDX_COUNTER: equ 3
DOOR_TABLE_IDX_DOOR_OPEN_COUNTER: equ 4

BALL_TABLE_LEN: equ 20
BALL_TABLE1: equ 0xe24e + 0*BALL_TABLE_LEN
BALL_TABLE2: equ 0xe24e + 1*BALL_TABLE_LEN
BALL_TABLE3: equ 0xe24e + 2*BALL_TABLE_LEN
;
BALL_TABLE_IDX_ACTIVE: equ 0
;
; 0: ball is glued and moved to Vaus
; 1: ball is glued
; 2: ball moves normally
BALL_TABLE_IDX_GLUE: equ 1
;
; 01, 02: ball going down
; FF, FE: ball going up
BALL_TABLE_IDX_VERT:  equ 2

;BALL_TABLE_: equ 3
; 01, 02: ball going right
; FF, FE: ball going left
BALL_TABLE_IDX_HORIZ: equ 3

BALL_TABLE_IDX_SKEWNESS: equ 6


;
BALL_TABLE_IDX_SPEED_POS: equ 7
BALL_TABLE_IDX_SPEED_COUNTER: equ 13
BALL_TABLE_IDX_GLUE_COUNTER: equ 14

TABLE_UNKNOWN_1: equ 0xe101

	org	04000h

    ; MSX ROM header
	db "AB"             ; ROM SIGNATURE
    dw ROM_START        ; INIT
    dw 0                ; STATEMENT
    dw 0                ; DEVICE
    dw 0                ; TEXT
    db 0, 0, 0, 0, 0, 0 ; RESERVED

sub_4010h:
    ; Reads the primary slot register
	call RSLREG		;4010	cd 38 01

	rrca			;4013	0f 	. 
	rrca			;4014	0f 	. 
	and 003h		;4015	e6 03 	. . 
	ld c,a			;4017	4f 	O 
	ld b,000h		;4018	06 00 	. . 
	ld hl,0fcc1h		;401a	21 c1 fc 	! . . 
	add hl,bc			;401d	09 	. 
	or (hl)			;401e	b6 	. 
	ret p			;401f	f0 	. 
	ld c,a			;4020	4f 	O 
	inc hl			;4021	23 	# 
	inc hl			;4022	23 	# 
	inc hl			;4023	23 	# 
	inc hl			;4024	23 	# 
	ld a,(hl)			;4025	7e 	~ 
	and 00ch		;4026	e6 0c 	. . 
	or c			;4028	b1 	. 
	ret			;4029	c9 	.
    
ROM_START:
	di			;402a	f3
	im 1		;402b	ed 56

	ld sp,0f370h		;402d	31 70 f3
	call sub_4010h		;4030	cd 10 40
	ld h,080h		;4033	26 80 	& . 
    
    ;Switches indicated slot at indicated page on perpetually
    ; A - Slot ID
    ; H - Bit 6 and 7 must contain the page number (00-11)
	call ENASLT		;4035	cd 24 00
    
	; Clear memory from 0xe000 to 0xe5b3
    ld hl,DEMO_LEVEL		;4038	21 00
	ld de,CHEAT1_ACTIVATED		;403b	11 01
	ld bc,005b3h		;403e	01 b3
	ld (hl),0		    ;4041	36 00
	ldir		        ;4043	ed b0
    
    ; Clear memory from 0xe5c0 to 0xe6bf
	ld hl,SOUND_NUMBER		;4045	21 c0 e5
	ld de,0e5c1h		;4048	11 c1 e5
	ld bc,000feh		;404b	01 fe 00
	ld (hl),000h		;404e	36 00
	ldir		        ;4050	ed b0
    
	ld hl,00050h		;4052	21 50 00
	ld (0e008h),hl		;4055	22 08 e0

    ; Turn off CAPS lamp
	ld a,001h		    ;4058	3e 01
	call CHGCAP		    ;405a	cd 32 01
    
    
	ld a,0ffh		;405d	3e ff 	> . 
	ld (0e5c3h),a		;405f	32 c3 e5 	2 . . 
	ld a,0bfh		;4062	3e bf 	> . 
	ld (0e5cbh),a		;4064	32 cb e5 	2 . . 
	ld hl,l4376h		;4067	21 76 43 	! v C 
	ld de,0f3c7h		;406a	11 c7 f3 	. . . 
	ld bc,0000ah		;406d	01 0a 00 	. . . 
	ldir		;4070	ed b0 	. . 
	ld hl,0f3e0h		;4072	21 e0 f3 	! . . 
	set 1,(hl)		;4075	cb ce 	. . 
	ld a,001h		;4077	3e 01 	> . 
	ld (0f3ebh),a	;4079	32 eb f3 	2 . . 
    
	; Switches to SCREEN 2 (high resolution screen with 256×192 pixels)
    call INIGRP		;407c	cd 72 00
    
    ; Inhibits the screen display
	call DISSCR		;407f	cd 41 00

    ; Clear VRAM name table
    ld hl,01800h		;4082	21 00 18
	ld bc,00300h		;4085	01 00 03
	xor a			    ;4088	af
	call FILVRM		    ;4089	cd 56 00
    
    ; Clear VRAM sprite attribute table
	ld hl,SPRITES_ATTRIB_TABLE		;408c	21 00 1b
	ld bc, 128		                ;408f	01 80 00
	xor a			                ;4092	af
	call FILVRM		                ;4093	cd 56 00
    
    ; Fill pattern table (1/3)
	ld hl,l9024h		    ;4096	21 24 90
	ld de, 0 * 8*32*24/3	;4099	11 00 00
	call LDIRVM_32x24_THIRD		    ;409c	cd 20 42

    ; Fill pattern table (2/3)
	ld hl,l9024h		    ;409f	21 24 90
	ld de, 1 * 8*32*24/3	;40a2	11 00 08
	call LDIRVM_32x24_THIRD		    ;40a5	cd 20 42

    ; Fill pattern table (3/3)
	ld hl,l9024h		    ;40a8	21 24 90
	ld de, 2 * 8*32*24/3	;40ab	11 00 10
	call LDIRVM_32x24_THIRD		    ;40ae	cd 20 42

    ; Fill color table
	call sub_41ffh		;40b1	cd ff 41 	. . A 

	ld hl,l8684h		;40b4	21 84 86 	! . . 
	ld de,03800h		;40b7	11 00 38 	. . 8 
	ld bc,00800h		;40ba	01 00 08 	. . . 
	call LDIRVM		;40bd	cd 5c 00 	. \ . 

	call sub_43ffh		;40c0	cd ff 43 	. . C 

	ld a,0f8h		;40c3	3e f8 	> . 
	ld (SOUND_NUMBER),a		;40c5	32 c0 e5 	2 . . 
	call PLAY_SOUND		;40c8	cd e8 b4 	. . . 

	ld a,0c3h		;40cb	3e c3 	> . 
	ld (0fd9ah),a		;40cd	32 9a fd 	2 . . 
	ld hl,l424ah		;40d0	21 4a 42 	! J B 
	ld (0fd9bh),hl		;40d3	22 9b fd 	" . . 
	ei			;40d6	fb 	. 
l40d7h:
	halt			;40d7	76 	v 
	ld a,(0e0bfh)		;40d8	3a bf e0 	: . . 
	bit 6,a		;40db	cb 77 	. w 
	jr z,l4103h		;40dd	28 24 	( $ 

    ; Jump if state is title screen
	ld a,(GAME_STATE)		;40df	3a 0b e0 	: . . 
	or a			;40e2	b7 	. 
	jp z,l4103h		;40e3	ca 03 41 	. . A 

	ld a,SOUND_PAUSE		;40e6	3e 05 	> . 
	ld (SOUND_NUMBER),a		;40e8	32 c0 e5 	2 . . 
	call PLAY_SOUND		;40eb	cd e8 b4 	. . . 

	ei			    ;40ee

    ; Print "PAUSE"
	ld hl,PAUSE_STR		;40ef	21 1b 42
	ld de,01a3ah		;40f2	11 3a 1a
	ld bc,5 		    ;40f5	01 05 00    len("PAUSE")=5
	call LDIRVM		    ;40f8	cd 5c 00

l40fbh:
	halt			;40fb	76 	v 
	ld a,(0e0bfh)		;40fc	3a bf e0 	: . . 
	bit 6,a		;40ff	cb 77 	. w 
l4101h:
	jr z,l40fbh		;4101	28 f8 	( . 
l4103h:
	ld hl,01a3ah		;4103	21 3a 1a 	! : . 
	ld bc,00005h		;4106	01 05 00 	. . . 
	ld a,000h		;4109	3e 00 	> . 
	call FILVRM		;410b	cd 56 00 	. V . 
	ld hl,0e18dh		;410e	21 8d e1 	! . . 
l4111h:
	ld b,020h		;4111	06 20 	.   
	ld de,00004h		;4113	11 04 00 	. . . 
l4116h:
	ld (hl),0c0h		;4116	36 c0 	6 . 
	add hl,de			;4118	19 	. 
	djnz l4116h		;4119	10 fb 	. . 
	ld b,020h		;411b	06 20 	.   
	ld ix,0e0c9h		;411d	dd 21 c9 e0 	. ! . . 
l4121h:
	ld iy,0e18dh		;4121	fd 21 8d e1 	. ! . . 
	ld de,00004h		;4125	11 04 00 	. . . 
l4128h:
	ld a,(ix+002h)		;4128	dd 7e 02 	. ~ . 
	or a			;412b	b7 	. 
	jp z,l4158h		;412c	ca 58 41 	. X A 
	ld a,(ix+000h)		;412f	dd 7e 00 	. ~ . 
	cp 0c0h		;4132	fe c0 	. . 
	jp z,l4158h		;4134	ca 58 41 	. X A 
	ld a,(ix+003h)		;4137	dd 7e 03 	. ~ . 
	or a			;413a	b7 	. 
	jp z,l4158h		;413b	ca 58 41 	. X A 
	ld a,(ix+000h)		;413e	dd 7e 00 	. ~ . 
	ld (iy+000h),a		;4141	fd 77 00 	. w . 
	ld a,(ix+001h)		;4144	dd 7e 01 	. ~ . 
	ld (iy+001h),a		;4147	fd 77 01 	. w . 
l414ah:
	ld a,(ix+002h)		;414a	dd 7e 02 	. ~ . 
	ld (iy+002h),a		;414d	fd 77 02 	. w . 
	ld a,(ix+003h)		;4150	dd 7e 03 	. ~ . 
	ld (iy+003h),a		;4153	fd 77 03 	. w . 
	add iy,de		;4156	fd 19 	. . 
l4158h:
	add ix,de		;4158	dd 19 	. . 
	djnz l4128h		;415a	10 cc 	. . 
	ld a,(0e317h)		;415c	3a 17 e3 	: . . 
	or a			;415f	b7 	. 
	jp z,l418eh		;4160	ca 8e 41 	. . A 
	ld hl,0e545h		;4163	21 45 e5 	! E . 
	inc (hl)			;4166	34 	4 
	ld a,(hl)			;4167	7e 	~ 
	and 001h		;4168	e6 01 	. . 
	jp z,l418eh		;416a	ca 8e 41 	. . A 
	ld hl,0e18dh		;416d	21 8d e1 	! . . 
	ld de,0e546h		;4170	11 46 e5 	. F . 
	ld bc,00004h		;4173	01 04 00 	. . . 
	ldir		;4176	ed b0 	. . 
	ld hl,0e19dh		;4178	21 9d e1 	! . . 
	ld de,0e18dh		;417b	11 8d e1 	. . . 
	ld bc,00004h		;417e	01 04 00 	. . . 
	ldir		;4181	ed b0 	. . 
	ld hl,0e546h		;4183	21 46 e5 	! F . 
	ld de,0e19dh		;4186	11 9d e1 	. . . 
	ld bc,00004h		;4189	01 04 00 	. . . 
	ldir		;418c	ed b0 	. . 
l418eh:
	ld hl,SPRITES_ATTRIB_TABLE		;418e	21 00 1b 	! . . 
	call SETWRT		;4191	cd 53 00 	. S . 
	ld hl,0e18dh		;4194	21 8d e1 	! . . 
	ld a,(VDP_WRITE)		;4197	3a 07 00 	: . . 
	ld c,a			;419a	4f 	O 
	ld b,080h		;419b	06 80 	. . 
l419dh:
	outi		;419d	ed a3 	. . 
	jr nz,l419dh		;419f	20 fc 	  . 
	ld a,(0e00ah)		;41a1	3a 0a e0 	: . . 
	ld l,a			;41a4	6f 	o 
	ld h,000h		;41a5	26 00 	& . 
	add hl,hl			;41a7	29 	) 
	ld de,l41b1h		;41a8	11 b1 41 	. . A 
	add hl,de			;41ab	19 	. 
	ld e,(hl)			;41ac	5e 	^ 
	inc hl			;41ad	23 	# 
	ld d,(hl)			;41ae	56 	V 
	ex de,hl			;41af	eb 	. 
	jp (hl)			;41b0	e9 	. 
l41b1h:
	or a			;41b1	b7 	. 
	ld b,c			;41b2	41 	A 
	ret nz			;41b3	c0 	. 
	ld b,c			;41b4	41 	A 
	call nc,0cd41h		;41b5	d4 41 cd 	. A . 
	ld b,h			;41b8	44 	D 
	nop			;41b9	00 	. 
	call sub_4b8ah		;41ba	cd 8a 4b 	. . K 
    
	jp l41dah		;41bd	c3 da 41 	. . A 
    
    ; Dead code?
	call sub_6835h		;41c0	cd 35 68 	. 5 h 
	call sub_95f4h		;41c3	cd f4 95 	. . . 
	call sub_7241h		;41c6	cd 41 72 	. A r 
	
    ; Scores of the right
    ld a, 1 		            ;41c9	3e 01
	ld (SCORE_POSITION),a		;41cb	32 44 e5

	call DRAW_SCORE_NUMBERS		;41ce	cd b9 53 	. . S 
	jp l41dah		;41d1	c3 da 41 	. . A 
	call sub_7b94h		;41d4	cd 94 7b 	. . { 
	jp l41dah		;41d7	c3 da 41 	. . A 
l41dah:
	ld hl,0e520h		;41da	21 20 e5 	!   . 
	ld a,(hl)			;41dd	7e 	~ 
	or a			;41de	b7 	. 
	jp z,l40d7h		;41df	ca d7 40 	. . @ 
	ld (SOUND_NUMBER),a		;41e2	32 c0 e5 	2 . . 
	call PLAY_SOUND		;41e5	cd e8 b4 	. . . 
	ei			;41e8	fb 	. 
	ld (hl),000h		;41e9	36 00 	6 . 
	inc hl			;41eb	23 	# 
	ld b,007h		;41ec	06 07 	. . 
l41eeh:
	ld a,(hl)			;41ee	7e 	~ 
	dec hl			;41ef	2b 	+ 
	ld (hl),a			;41f0	77 	w 
	inc hl			;41f1	23 	# 
	inc hl			;41f2	23 	# 
	djnz l41eeh		;41f3	10 f9 	. . 
	dec hl			;41f5	2b 	+ 
	ld (hl),000h		;41f6	36 00 	6 . 
	ld hl,0e51eh		;41f8	21 1e e5 	! . . 
	dec (hl)			;41fb	35 	5 
	jp l40d7h		;41fc	c3 d7 40 	. . @ 
sub_41ffh:
	ld de,l93f4h		;41ff	11 f4 93 	. . . 
	ld hl,02000h		;4202	21 00 20 	! .   
l4205h:
	call sub_4389h		;4205	cd 89 43 	. . C 
	ld de,l93f4h		;4208	11 f4 93 	. . . 
	ld hl,02800h		;420b	21 00 28 	! . ( 
	call sub_4389h		;420e	cd 89 43 	. . C 
	ld de,l93f4h		;4211	11 f4 93 	. . . 
	ld hl,03000h		;4214	21 00 30 	! . 0 
	call sub_4389h		;4217	cd 89 43 	. . C 
	ret			;421a	c9 	. 

PAUSE_STR:
    db "PAUSE"

; Perform a LDIRVM of one third of 32x24 chars
LDIRVM_32x24_THIRD:
	ld bc, 32*24*8/3	;4220	01 00 08
	call LDIRVM		    ;4223	cd 5c 00
	ret			        ;4226	c9

; Clear the screen and the area in 0e0c9h
CLEAR_SCREEN:
    ; Clear name table
	ld hl,01800h		;4227	21 00 18
	ld bc,00300h		;422a	01 00 03
	xor a			    ;422d	af
	call FILVRM		    ;422e	cd 56 00

    ; Clear sprites attribute table
	ld hl,SPRITES_ATTRIB_TABLE		;4231	21 00 1b
	ld bc, 128		                ;4234	01 80 00
	ld a,192		                ;4237	3e c0
	call FILVRM		                ;4239	cd 56 00

    ; Clear memory
	ld hl,0e0c9h		;423c	21 c9 e0
	ld de,0e0cah		;423f	11 ca e0
	ld bc,128		    ;4242	01 80 00
	ld (hl),192		    ;4245	36 c0
	ldir		        ;4247	ed b0
	ret			        ;4249	c9

l424ah:
	call RDVDP		;424a	cd 3e 01 	. > . 
	call sub_b594h		;424d	cd 94 b5 	. . . 
	ld a,006h		;4250	3e 06 	> . 
	call SNSMAT		;4252	cd 41 01 	. A . 
	and 004h		;4255	e6 04 	. . 
	rra			;4257	1f 	. 
	ld e,a			;4258	5f 	_ 
	ld a,008h		;4259	3e 08 	> . 
	call SNSMAT		;425b	cd 41 01 	. A . 
	and 0f1h		;425e	e6 f1 	. . 
	or e			;4260	b3 	. 
	ld e,a			;4261	5f 	_ 
	sra a		;4262	cb 2f 	. / 
	and 0b8h		;4264	e6 b8 	. . 
	ld d,a			;4266	57 	W 
	rla			;4267	17 	. 
	rla			;4268	17 	. 
	rla			;4269	17 	. 
	and 040h		;426a	e6 40 	. @ 
	or d			;426c	b2 	. 
	ld d,a			;426d	57 	W 
	ld a,e			;426e	7b 	{ 
	and 003h		;426f	e6 03 	. . 
	or d			;4271	b2 	. 
	rrca			;4272	0f 	. 
	rrca			;4273	0f 	. 
	rrca			;4274	0f 	. 
	rrca			;4275	0f 	. 
	cpl			;4276	2f 	/ 
	and 03fh		;4277	e6 3f 	. ? 
	jp l427ch		;4279	c3 7c 42 	. | B 
l427ch:
	ld e,a			;427c	5f 	_ 
	ld a,007h		;427d	3e 07 	> . 
	call SNSMAT		;427f	cd 41 01 	. A . 
	rla			;4282	17 	. 
	rla			;4283	17 	. 
	cpl			;4284	2f 	/ 
	and 040h		;4285	e6 40 	. @ 
	or e			;4287	b3 	. 
	ld e,a			;4288	5f 	_ 
	ld hl,KEYBOARD_INPUT		;4289	21 c0 e0 	! . . 
	ld a,(hl)			;428c	7e 	~ 
	ld (hl),e			;428d	73 	s 
	and 0f0h		;428e	e6 f0 	. . 
	and e			;4290	a3 	. 
	xor e			;4291	ab 	. 
	ld (0e0bfh),a		;4292	32 bf e0 	2 . . 
	ld b,a			;4295	47 	G 

    ; Keep going if we're in the title screen
	ld a,(GAME_STATE)		;4296	3a 0b e0 	: . . 
	or a			;4299	b7 	. 
	jp nz,l42fch		;429a	c2 fc 42 	. . B 

    ; Check cheat...

    ; Check if UP key is pressed...
	bit 0,b		    ;429d	cb 40
	jp z,l42bbh		;429f	ca bb 42
    ; Check if DOWN key is pressed...
	bit 1,b		;42a2	cb 48
	jp z,l42bbh		;42a4	ca bb 42
    ; Check if GRAPH key is pressed...
	bit 5,b		;42a7	cb 68
	jp z,l42bbh		;42a9	ca bb 42
    
    ; Increment the number of key presses, for the cheat
	ld hl,CHEAT1_KEY_COUNTER	;42ac	21 02 e0
	inc (hl)			        ;42af	34 	4 
    
	ld a,(hl)			        ;42b0	7e
	cp 4		                ;42b1	fe 04 Cheat: 4 key presses
	jp c,l42bbh		            ;42b3	da bb 42
    
    ; We have already 4 key presses for the cheat!
	ld (hl), 0		            ;42b6	36 00   Reset keys counter

    ; Point to CHEAT1_ACTIVATED and activate the cheat :)
	dec hl			        ;42b8	2b
	ld (hl),1   		    ;42b9	36 01

; The second cheat: hold LEFT and RIGHT and press GRAPH 4 times to continue from the last level
l42bbh:
    ; Check if LEFT key is pressed...
	bit 2,b		    ;42bb	cb 50
	jp z,l42d9h		;42bd	ca d9 42
    ; Check if RIGHT key is pressed...
	bit 3,b		    ;42c0	cb 58
	jp z,l42d9h		;42c2	ca d9 42
    ; Check if GRAPH key is pressed...
	bit 5,b		    ;42c5	cb 68
	jp z,l42d9h		;42c7	ca d9 42
    
    ; Increment and check the key-press counter for cheat #2
	ld hl,CHEAT2_KEY_COUNTER		;42ca	21 04 e0
	inc (hl)			            ;42cd	34 	4 
	ld a,(hl)			            ;42ce	7e
	cp 4		                    ;42cf	fe 04
	jp c,l42d9h		                ;42d1	da d9 42

    ; Reset counter and activate cheat #2
	ld (hl),0		;42d4	36 00
	dec hl			;42d6	2b
	ld (hl),1	    ;42d7	36 01
l42d9h:
	bit 4,b		;42d9	cb 60 	. ` 
	jp z,l42fch		;42db	ca fc 42 	. . B 
	ld a,(0e00ah)		;42de	3a 0a e0 	: . . 
	or a			;42e1	b7 	. 
	jp z,l42f6h		;42e2	ca f6 42 	. . B 
	xor a			;42e5	af 	. 
	ld (0e00ah),a		;42e6	32 0a e0 	2 . . 
	ld hl,0e53ch		;42e9	21 3c e5 	! < . 
	ld de,0e53dh		;42ec	11 3d e5 	. = . 
	ld (hl),000h		;42ef	36 00 	6 . 
	ld bc,00007h		;42f1	01 07 00 	. . . 
	ldir		;42f4	ed b0 	. . 
l42f6h:
	ld a,000h		;42f6	3e 00 	> . 
	ld (0e00ch),a		;42f8	32 0c e0 	2 . . 
	ret			;42fb	c9 	. 

l42fch:
	ld a,00eh		;42fc	3e 0e 	> . 
	out (0a0h),a		;42fe	d3 a0 	. . 
	in a,(0a2h)		;4300	db a2 	. . 
	ld h,a			;4302	67 	g 
	ld b,008h		;4303	06 08 	. . 
	ld c,000h		;4305	0e 00 	. . 
	ld e,000h		;4307	1e 00 	. . 
l4309h:
	ld a,00fh		;4309	3e 0f 	> . 
	out (0a0h),a		;430b	d3 a0 	. . 
	ld a,01eh		;430d	3e 1e 	> . 
	out (0a1h),a		;430f	d3 a1 	. . 
l4311h:
	ld a,01fh		;4311	3e 1f 	> . 
	out (0a1h),a		;4313	d3 a1 	. . 
	ld a,00eh		;4315	3e 0e 	> . 
	out (0a0h),a		;4317	d3 a0 	. . 
	in a,(0a2h)		;4319	db a2 	. . 
	ld e,a			;431b	5f 	_ 
	srl a		;431c	cb 3f 	. ? 
	rl c		;431e	cb 11 	. . 
	djnz l4309h		;4320	10 e7 	. . 
l4322h:
	ld a,c			;4322	79 	y 
	ld (0e0c1h),a		;4323	32 c1 e0 	2 . . 
	ld a,h			;4326	7c 	| 
	and 001h		;4327	e6 01 	. . 
	ld (0e0c2h),a		;4329	32 c2 e0 	2 . . 
	ld a,00fh		;432c	3e 0f 	> . 
	out (0a0h),a		;432e	d3 a0 	. . 
	ld a,01fh		;4330	3e 1f 	> . 
	out (0a1h),a		;4332	d3 a1 	. . 
	ld a,00fh		;4334	3e 0f 	> . 
	out (0a1h),a		;4336	d3 a1 	. . 
	ld a,01fh		;4338	3e 1f 	> . 
	out (0a1h),a		;433a	d3 a1 	. . 
	ld a,00eh		;433c	3e 0e 	> . 
	out (0a0h),a		;433e	d3 a0 	. . 
	in a,(0a2h)		;4340	db a2 	. . 
	ld e,a			;4342	5f 	_ 
	ld hl,0e0c4h		;4343	21 c4 e0 	! . . 
	ld a,(hl)			;4346	7e 	~ 
	ld (hl),e			;4347	73 	s 
	and 00fh		;4348	e6 0f 	. . 
	and e			;434a	a3 	. 
	xor e			;434b	ab 	. 
	ld (0e0c5h),a		;434c	32 c5 e0 	2 . . 
	ld b,a			;434f	47 	G 

    ; Exit if we're not in the title screen
	ld a,(GAME_STATE)		;4350	3a 0b e0
	or a			        ;4353	b7
	ret nz			        ;4354	c0

	bit 1,b		;4355	cb 48 	. H 
	ret z			;4357	c8 	. 
	ld a,(0e00ah)		;4358	3a 0a e0 	: . . 
	or a			;435b	b7 	. 
	jp z,l4370h		;435c	ca 70 43 	. p C 
	xor a			;435f	af 	. 
	ld (0e00ah),a		;4360	32 0a e0 	2 . . 
	ld hl,0e53ch		;4363	21 3c e5 	! < . 
	ld de,0e53dh		;4366	11 3d e5 	. = . 
	ld (hl),000h		;4369	36 00 	6 . 
	ld bc,00007h		;436b	01 07 00 	. . . 
	ldir		;436e	ed b0 	. . 
l4370h:
	ld a,001h		;4370	3e 01 	> . 
	ld (0e00ch),a		;4372	32 0c e0 	2 . . 
	ret			;4375	c9 	. 

l4376h:
	nop			;4376	00 	. 
	jr l4379h		;4377	18 00 	. . 
l4379h:
	jr nz,l437bh		;4379	20 00 	  . 
l437bh:
	nop			;437b	00 	. 
	nop			;437c	00 	. 
	dec de			;437d	1b 	. 
	nop			;437e	00 	. 
    db 0x38

; Wait HL ints
DELAY_HL_TICKS:
    push af         ;4380   f5
l4381h:    
	halt			;4381	76
	dec hl			;4382	2b
	ld a,l			;4383	7d
	or h			;4384	b4
	jr nz,l4381h	;4385	20 fa
	pop af			;4387	f1
	ret			    ;4388	c9

sub_4389h:
	ld a,h			;4389	7c 	| 
	add a,008h		;438a	c6 08 	. . 
	ld b,a			;438c	47 	G 
	ld c,l			;438d	4d 	M 
l438eh:
	ld a,h			;438e	7c 	| 
	cp b			;438f	b8 	. 
	ret z			;4390	c8 	. 
	ld a,(de)			;4391	1a 	. 
	and 0f0h		;4392	e6 f0 	. . 
	cp 000h		;4394	fe 00 	. . 
	jr z,l43a0h		;4396	28 08 	( . 
	ld a,(de)			;4398	1a 	. 
	call WRTVRM		;4399	cd 4d 00 	. M . 
	inc hl			;439c	23 	# 
	inc de			;439d	13 	. 
	jr l438eh		;439e	18 ee 	. . 
l43a0h:
	push bc			;43a0	c5 	. 
	ld a,(de)			;43a1	1a 	. 
	and 00fh		;43a2	e6 0f 	. . 
	ld c,a			;43a4	4f 	O 
	inc de			;43a5	13 	. 
	ld a,(de)			;43a6	1a 	. 
	ld b,a			;43a7	47 	G 
	inc de			;43a8	13 	. 
	ld a,(de)			;43a9	1a 	. 
	ex af,af'			;43aa	08 	. 
	inc de			;43ab	13 	. 
	ld a,(de)			;43ac	1a 	. 
	inc de			;43ad	13 	. 
	ex af,af'			;43ae	08 	. 
	inc b			;43af	04 	. 
	dec b			;43b0	05 	. 
	jr nz,l43b4h		;43b1	20 01 	  . 
	dec c			;43b3	0d 	. 
l43b4h:
	call WRTVRM		;43b4	cd 4d 00 	. M . 
	inc hl			;43b7	23 	# 
	ex af,af'			;43b8	08 	. 
	call WRTVRM		;43b9	cd 4d 00 	. M . 
	inc hl			;43bc	23 	# 
	ex af,af'			;43bd	08 	. 
	djnz l43b4h		;43be	10 f4 	. . 
	dec c			;43c0	0d 	. 
	jp p,l43b4h		;43c1	f2 b4 43 	. . C 
	pop bc			;43c4	c1 	. 
	jr l438eh		;43c5	18 c7 	. . 
	ld a,h			;43c7	7c 	| 
	add a,008h		;43c8	c6 08 	. . 
	ld b,a			;43ca	47 	G 
	ld c,l			;43cb	4d 	M 
l43cch:
	ld a,h			;43cc	7c 	| 
	cp b			;43cd	b8 	. 
	ret z			;43ce	c8 	. 
	ld a,(de)			;43cf	1a 	. 
	and 0f0h		;43d0	e6 f0 	. . 
	cp 000h		;43d2	fe 00 	. . 
	jr z,l43dch		;43d4	28 06 	( . 
	ld a,(de)			;43d6	1a 	. 
	ld (hl),a			;43d7	77 	w 
	inc hl			;43d8	23 	# 
	inc de			;43d9	13 	. 
	jr l43cch		;43da	18 f0 	. . 
l43dch:
	push bc			;43dc	c5 	. 
	ld a,(de)			;43dd	1a 	. 
	and 00fh		;43de	e6 0f 	. . 
	ld c,a			;43e0	4f 	O 
	inc de			;43e1	13 	. 
	ld a,(de)			;43e2	1a 	. 
	ld b,a			;43e3	47 	G 
	inc de			;43e4	13 	. 
	ld a,(de)			;43e5	1a 	. 
	ex af,af'			;43e6	08 	. 
	inc de			;43e7	13 	. 
	ld a,(de)			;43e8	1a 	. 
	inc de			;43e9	13 	. 
	ex af,af'			;43ea	08 	. 
	inc b			;43eb	04 	. 
	dec b			;43ec	05 	. 
	jr nz,l43f0h		;43ed	20 01 	  . 
	dec c			;43ef	0d 	. 
l43f0h:
	ld (hl),a			;43f0	77 	w 
	inc hl			;43f1	23 	# 
	ex af,af'			;43f2	08 	. 
	ld (hl),a			;43f3	77 	w 
	inc hl			;43f4	23 	# 
	ex af,af'			;43f5	08 	. 
	djnz l43f0h		;43f6	10 f8 	. . 
	dec c			;43f8	0d 	. 
	jp p,l43f0h		;43f9	f2 f0 43 	. . C 
	pop bc			;43fc	c1 	. 
	jr l43cch		;43fd	18 cd 	. . 
sub_43ffh:
	xor a			;43ff	af 	. 
	ld (0e53ch),a		;4400	32 3c e5 	2 < . 
l4403h:
	ld a,(0e53ch)		;4403	3a 3c e5 	: < . 
l4406h:
	ld l,a			;4406	6f 	o 
	ld h,000h		;4407	26 00 	& . 
	add hl,hl			;4409	29 	) 
	push hl			;440a	e5 	. 
	ld de,l4445h		;440b	11 45 44 	. E D 
	add hl,de			;440e	19 	. 
	ld e,(hl)			;440f	5e 	^ 
	inc hl			;4410	23 	# 
l4411h:
	ld d,(hl)			;4411	56 	V 
	pop hl			;4412	e1 	. 
	ld bc,04485h		;4413	01 85 44 	. . D 
	add hl,bc			;4416	09 	. 
	ld c,(hl)			;4417	4e 	N 
	inc hl			;4418	23 	# 
	ld b,(hl)			;4419	46 	F 
	push bc			;441a	c5 	. 
	pop hl			;441b	e1 	. 
l441ch:
	ld a,(hl)			;441c	7e 	~ 
	and 00fh		;441d	e6 0f 	. . 
	ld b,a			;441f	47 	G 
	ld a,(hl)			;4420	7e 	~ 
	and 0f0h		;4421	e6 f0 	. . 
	srl a		;4423	cb 3f 	. ? 
l4425h:
	srl a		;4425	cb 3f 	. ? 
	srl a		;4427	cb 3f 	. ? 
	srl a		;4429	cb 3f 	. ? 
l442bh:
	ld (de),a			;442b	12 	. 
	inc de			;442c	13 	. 
	djnz l442bh		;442d	10 fc 	. . 
	inc hl			;442f	23 	# 
	ld a,(hl)			;4430	7e 	~ 
	cp 0ffh		;4431	fe ff 	. . 
	jp nz,l441ch		;4433	c2 1c 44 	. . D 
	ld hl,0e53ch		;4436	21 3c e5 	! < . 
	inc (hl)			;4439	34 	4 
	ld a,(hl)			;443a	7e 	~ 
	cp 020h		;443b	fe 20 	.   
	jp nz,l4403h		;443d	c2 03 44 	. . D 
	xor a			;4440	af 	. 
	ld (0e53ch),a		;4441	32 3c e5 	2 < . 
	ret			;4444	c9 	. 
l4445h:
	nop			;4445	00 	. 
	ret nz			;4446	c0 	. 
	add a,h			;4447	84 	. 
	ret nz			;4448	c0 	. 
	ex af,af'			;4449	08 	. 
	pop bc			;444a	c1 	. 
	adc a,h			;444b	8c 	. 
	pop bc			;444c	c1 	. 
	djnz l4411h		;444d	10 c2 	. . 
	sub h			;444f	94 	. 
	jp nz,0c318h		;4450	c2 18 c3 	. . . 
	sbc a,h			;4453	9c 	. 
	jp 0c420h		;4454	c3 20 c4 	.   . 
	and h			;4457	a4 	. 
	call nz,0c528h		;4458	c4 28 c5 	. ( . 
	xor h			;445b	ac 	. 
	push bc			;445c	c5 	. 
	jr nc,l4425h		;445d	30 c6 	0 . 
	or h			;445f	b4 	. 
	add a,038h		;4460	c6 38 	. 8 
	rst 0			;4462	c7 	. 
	cp h			;4463	bc 	. 
	rst 0			;4464	c7 	. 
	ld b,b			;4465	40 	@ 
	ret z			;4466	c8 	. 
	call nz,048c8h		;4467	c4 c8 48 	. . H 
	ret			;446a	c9 	. 
	call z,0x50c9		;446b	cc c9 50 	. . P 
	jp z,0cad4h		;446e	ca d4 ca 	. . . 
	ld e,b			;4471	58 	X 
	set 3,h		;4472	cb dc 	. . 
	bit 4,b		;4474	cb 60 	. ` 
	call z,0cce4h		;4476	cc e4 cc 	. . . 
	ld l,b			;4479	68 	h 
	call 0cdech		;447a	cd ec cd 	. . . 
	ld (hl),b			;447d	70 	p 
	adc a,0f4h		;447e	ce f4 	. . 
	adc a,078h		;4480	ce 78 	. x 
	rst 8			;4482	cf 	. 
	call m,0c5cfh		;4483	fc cf c5 	. . . 
	ld b,h			;4486	44 	D 
	jp nc,0f144h		;4487	d2 44 f1 	. D . 
	ld b,h			;448a	44 	D 
	ld (de),a			;448b	12 	. 
	ld b,l			;448c	45 	E 
	ld d,(hl)			;448d	56 	V 
	ld b,l			;448e	45 	E 
	adc a,(hl)			;448f	8e 	. 
	ld b,l			;4490	45 	E 
	rst 28h			;4491	ef 	. 
	ld b,l			;4492	45 	E 
	ld d,046h		;4493	16 46 	. F 
	ld c,d			;4495	4a 	J 
	ld b,(hl)			;4496	46 	F 
	ld (hl),l			;4497	75 	u 
	ld b,(hl)			;4498	46 	F 
	sbc a,e			;4499	9b 	. 
	ld b,(hl)			;449a	46 	F 
	ret nc			;449b	d0 	. 
	ld b,(hl)			;449c	46 	F 
	dec d			;449d	15 	. 
	ld b,a			;449e	47 	G 
	ld d,c			;449f	51 	Q 
	ld b,a			;44a0	47 	G 
	ld (hl),b			;44a1	70 	p 
	ld b,a			;44a2	47 	G 
	or b			;44a3	b0 	. 
	ld b,a			;44a4	47 	G 
	rst 30h			;44a5	f7 	. 
	ld b,a			;44a6	47 	G 
	dec a			;44a7	3d 	= 
	ld c,b			;44a8	48 	H 
	sbc a,e			;44a9	9b 	. 
	ld c,b			;44aa	48 	H 
	ret c			;44ab	d8 	. 
	ld c,b			;44ac	48 	H 
	jr z,l44f8h		;44ad	28 49 	( I 
	ld l,(hl)			;44af	6e 	n 
	ld c,c			;44b0	49 	I 
	sbc a,h			;44b1	9c 	. 
	ld c,c			;44b2	49 	I 
	adc a,049h		;44b3	ce 49 	. I 
	rst 20h			;44b5	e7 	. 
	ld c,c			;44b6	49 	I 
	ld de,0364ah		;44b7	11 4a 36 	. J 6 
	ld c,d			;44ba	4a 	J 
	ld b,e			;44bb	43 	C 
	ld c,d			;44bc	4a 	J 
	ld a,h			;44bd	7c 	| 
	ld c,d			;44be	4a 	J 
	or d			;44bf	b2 	. 
	ld c,d			;44c0	4a 	J 
	jp nc,l414ah		;44c1	d2 4a 41 	. J A 
	ld c,e			;44c4	4b 	K 
	ld c,e			;44c5	4b 	K 
	ld c,e			;44c6	4b 	K 
	dec hl			;44c7	2b 	+ 
	dec de			;44c8	1b 	. 
	dec bc			;44c9	0b 	. 
	dec de			;44ca	1b 	. 
	dec bc			;44cb	0b 	. 
	dec de			;44cc	1b 	. 
	ld c,e			;44cd	4b 	K 
	ld c,e			;44ce	4b 	K 
	ld c,e			;44cf	4b 	K 
	ld c,e			;44d0	4b 	K 
	rst 38h			;44d1	ff 	. 
	ld bc,0024ah		;44d2	01 4a 02 	. J . 
	ld c,c			;44d5	49 	I 
	ld (bc),a			;44d6	02 	. 
	ld de,00448h		;44d7	11 48 04 	. H . 
	ld b,a			;44da	47 	G 
	dec b			;44db	05 	. 
	ld b,(hl)			;44dc	46 	F 
	dec b			;44dd	05 	. 
	ld de,00145h		;44de	11 45 01 	. E . 
	ld de,l4403h+2		;44e1	11 05 44 	. . D 
	rlca			;44e4	07 	. 
	ld de,00343h		;44e5	11 43 03 	. C . 
	ld de,l4205h		;44e8	11 05 42 	. . B 
	ld a,(bc)			;44eb	0a 	. 
	ld b,c			;44ec	41 	A 
	ld hl,(l4b11h)		;44ed	2a 11 4b 	* . K 
	rst 38h			;44f0	ff 	. 
	ld c,e			;44f1	4b 	K 
	dec b			;44f2	05 	. 
	ld de,01102h		;44f3	11 02 11 	. . . 
	ld (bc),a			;44f6	02 	. 
	ld c,e			;44f7	4b 	K 
l44f8h:
	jr c,$+19		;44f8	38 11 	8 . 
	ld (bc),a			;44fa	02 	. 
	ld c,e			;44fb	4b 	K 
	ld bc,00311h		;44fc	01 11 03 	. . . 
	ld de,01102h		;44ff	11 02 11 	. . . 
	ld (bc),a			;4502	02 	. 
l4503h:
	ld c,e			;4503	4b 	K 
	inc bc			;4504	03 	. 
	jr c,l4552h		;4505	38 4b 	8 K 
	ld b,011h		;4507	06 11 	. . 
	ld (bc),a			;4509	02 	. 
	ld de,l4affh+2		;450a	11 01 4b 	. . K 
	jr c,$+3		;450d	38 01 	8 . 
	ld de,0ff01h		;450f	11 01 ff 	. . . 
	ld c,e			;4512	4b 	K 
	ld c,h			;4513	4c 	L 
	ld hl,l4103h		;4514	21 03 41 	! . A 
	ld de,01101h		;4517	11 01 11 	. . . 
	ld hl,00442h		;451a	21 42 04 	! B . 
	ld b,c			;451d	41 	A 
	ld (bc),a			;451e	02 	. 
	ld hl,sub_41ffh+2		;451f	21 01 42 	! . B 
	inc b			;4522	04 	. 
	ld b,c			;4523	41 	A 
	ld bc,00221h		;4524	01 21 02 	. ! . 
	ld b,d			;4527	42 	B 
	ld de,l4103h		;4528	11 03 41 	. . A 
	ld hl,04203h		;452b	21 03 42 	! . B 
	inc b			;452e	04 	. 
	ld b,c			;452f	41 	A 
	ld bc,00211h		;4530	01 11 02 	. . . 
	ld b,d			;4533	42 	B 
	ld (bc),a			;4534	02 	. 
	ld de,l4121h		;4535	11 21 41 	. ! A 
	inc b			;4538	04 	. 
	ld b,d			;4539	42 	B 
	ld (bc),a			;453a	02 	. 
	ld hl,l4101h		;453b	21 01 41 	! . A 
	inc bc			;453e	03 	. 
	ld de,00142h		;453f	11 42 01 	. B . 
	ld hl,01101h		;4542	21 01 11 	! . . 
	ld b,c			;4545	41 	A 
	inc b			;4546	04 	. 
	ld b,d			;4547	42 	B 
	ld hl,l4103h		;4548	21 03 41 	! . A 
	ld de,02102h		;454b	11 02 21 	. . ! 
	ld b,d			;454e	42 	B 
	inc b			;454f	04 	. 
	ld b,c			;4550	41 	A 
	ld (bc),a			;4551	02 	. 
l4552h:
	ld hl,l4111h		;4552	21 11 41 	! . A 
	rst 38h			;4555	ff 	. 
	ld b,e			;4556	43 	C 
	ld de,01143h		;4557	11 43 11 	. C . 
	ld b,a			;455a	47 	G 
	ld de,01141h		;455b	11 41 11 	. A . 
	ld b,a			;455e	47 	G 
	dec h			;455f	25 	% 
	ld b,(hl)			;4560	46 	F 
	dec h			;4561	25 	% 
	ld b,l			;4562	45 	E 
	ld (02111h),hl		;4563	22 11 21 	" . ! 
	ld de,04422h		;4566	11 22 44 	. " D 
	ld (02111h),hl		;4569	22 11 21 	" . ! 
	ld de,l4322h		;456c	11 22 43 	. " C 
	add hl,hl			;456f	29 	) 
	ld b,d			;4570	42 	B 
	add hl,hl			;4571	29 	) 
	ld b,d			;4572	42 	B 
	ld hl,02541h		;4573	21 41 25 	! A % 
	ld b,c			;4576	41 	A 
	ld hl,02142h		;4577	21 42 21 	! B ! 
	ld b,c			;457a	41 	A 
	ld hl,02143h		;457b	21 43 21 	! C ! 
	ld b,c			;457e	41 	A 
	ld hl,02142h		;457f	21 42 21 	! B ! 
	ld b,c			;4582	41 	A 
	ld hl,02143h		;4583	21 43 21 	! C ! 
	ld b,c			;4586	41 	A 
	ld hl,02145h		;4587	21 45 21 	! E ! 
	ld b,c			;458a	41 	A 
	ld hl,0ff44h		;458b	21 44 ff 	! D . 
	ld c,e			;458e	4b 	K 
	ld bc,00141h		;458f	01 41 01 	. A . 
	ld b,c			;4592	41 	A 
	ld bc,00141h		;4593	01 41 01 	. A . 
	ld b,c			;4596	41 	A 
	ld bc,00241h		;4597	01 41 02 	. A . 
	ld b,c			;459a	41 	A 
	ld bc,00141h		;459b	01 41 01 	. A . 
	ld b,c			;459e	41 	A 
	ld bc,00141h		;459f	01 41 01 	. A . 
	ld b,c			;45a2	41 	A 
	ld (bc),a			;45a3	02 	. 
	ld b,c			;45a4	41 	A 
	ld bc,00141h		;45a5	01 41 01 	. A . 
	ld b,c			;45a8	41 	A 
	ld bc,00141h		;45a9	01 41 01 	. A . 
	ld b,c			;45ac	41 	A 
	ld (bc),a			;45ad	02 	. 
	ld b,c			;45ae	41 	A 
	ld sp,03111h		;45af	31 11 31 	1 . 1 
	ld de,01131h		;45b2	11 31 11 	. 1 . 
	ld sp,00241h		;45b5	31 41 02 	1 A . 
	ld b,c			;45b8	41 	A 
	ld bc,00141h		;45b9	01 41 01 	. A . 
	ld b,c			;45bc	41 	A 
	ld bc,00141h		;45bd	01 41 01 	. A . 
	ld b,c			;45c0	41 	A 
	ld (bc),a			;45c1	02 	. 
	ld b,c			;45c2	41 	A 
	ld bc,00141h		;45c3	01 41 01 	. A . 
	ld b,c			;45c6	41 	A 
	ld bc,00141h		;45c7	01 41 01 	. A . 
	ld b,c			;45ca	41 	A 
	ld (bc),a			;45cb	02 	. 
	ld b,c			;45cc	41 	A 
	ld bc,00141h		;45cd	01 41 01 	. A . 
	ld b,c			;45d0	41 	A 
	ld bc,00141h		;45d1	01 41 01 	. A . 
	ld b,c			;45d4	41 	A 
	ld bc,l4111h		;45d5	01 11 41 	. . A 
	ld de,03141h		;45d8	11 41 31 	. A 1 
	ld b,c			;45db	41 	A 
	ld sp,01141h		;45dc	31 41 11 	1 A . 
	ld b,c			;45df	41 	A 
	ld de,l4101h		;45e0	11 01 41 	. . A 
	ld bc,00141h		;45e3	01 41 01 	. A . 
	ld b,c			;45e6	41 	A 
	ld bc,00141h		;45e7	01 41 01 	. A . 
	ld b,c			;45ea	41 	A 
	ld bc,l474fh		;45eb	01 4f 47 	. O G 
	rst 38h			;45ee	ff 	. 
	ld c,a			;45ef	4f 	O 
	ld c,e			;45f0	4b 	K 
	inc bc			;45f1	03 	. 
	ld b,a			;45f2	47 	G 
	ld (bc),a			;45f3	02 	. 
	ld de,l4602h		;45f4	11 02 46 	. . F 
	ld bc,00111h		;45f7	01 11 01 	. . . 
	ld de,04501h		;45fa	11 01 45 	. . E 
	inc bc			;45fd	03 	. 
	ld de,l4403h		;45fe	11 03 44 	. . D 
l4601h:
	rlca			;4601	07 	. 
l4602h:
	ld b,h			;4602	44 	D 
	rlca			;4603	07 	. 
	ld b,h			;4604	44 	D 
	inc bc			;4605	03 	. 
	ld de,l4503h		;4606	11 03 45 	. . E 
	ld bc,00111h		;4609	01 11 01 	. . . 
	ld de,l4601h		;460c	11 01 46 	. . F 
	ld (bc),a			;460f	02 	. 
	ld de,l4702h		;4610	11 02 47 	. . G 
	inc bc			;4613	03 	. 
	ld b,h			;4614	44 	D 
	rst 38h			;4615	ff 	. 
	ld c,h			;4616	4c 	L 
	ld sp,03142h		;4617	31 42 31 	1 B 1 
	ld b,c			;461a	41 	A 
	ld sp,03142h		;461b	31 42 31 	1 B 1 
	ld b,d			;461e	42 	B 
	ld (03245h),a		;461f	32 45 32 	2 E 2 
	ld b,(hl)			;4622	46 	F 
	ld de,03149h		;4623	11 49 31 	. I 1 
	ld de,l4631h		;4626	11 31 46 	. 1 F 
	ld sp,01142h		;4629	31 42 11 	1 B . 
	ld b,d			;462c	42 	B 
	ld sp,01147h		;462d	31 47 11 	1 G . 
	ld b,a			;4630	47 	G 
l4631h:
	ld sp,01142h		;4631	31 42 11 	1 B . 
	ld b,d			;4634	42 	B 
	ld sp,03146h		;4635	31 46 31 	1 F 1 
	ld de,l4931h		;4638	11 31 49 	. 1 I 
	ld de,03246h		;463b	11 46 32 	. F 2 
	ld b,l			;463e	45 	E 
	ld (03142h),a		;463f	32 42 31 	2 B 1 
	ld b,d			;4642	42 	B 
	ld sp,03141h		;4643	31 41 31 	1 A 1 
	ld b,d			;4646	42 	B 
	ld sp,0ff41h		;4647	31 41 ff 	1 A . 
	ld b,c			;464a	41 	A 
	ld sp,03141h		;464b	31 41 31 	1 A 1 
	ld b,e			;464e	43 	C 
	ld sp,03141h		;464f	31 41 31 	1 A 1 
	ld b,d			;4652	42 	B 
	ld sp,03111h		;4653	31 11 31 	1 . 1 
	ld b,e			;4656	43 	C 
	ld sp,03111h		;4657	31 11 31 	1 . 1 
	ld b,d			;465a	42 	B 
	ld sp,03111h		;465b	31 11 31 	1 . 1 
	ld b,e			;465e	43 	C 
	ld sp,03111h		;465f	31 11 31 	1 . 1 
	ld b,d			;4662	42 	B 
	inc sp			;4663	33 	3 
	ld b,e			;4664	43 	C 
	inc sp			;4665	33 	3 
	ld c,a			;4666	4f 	O 
	ld b,c			;4667	41 	A 
	inc de			;4668	13 	. 
	ld c,b			;4669	48 	H 
	inc de			;466a	13 	. 
	ld c,b			;466b	48 	H 
	inc de			;466c	13 	. 
	ld c,b			;466d	48 	H 
	inc de			;466e	13 	. 
	ld c,b			;466f	48 	H 
	inc de			;4670	13 	. 
	ld c,b			;4671	48 	H 
	inc de			;4672	13 	. 
	ld c,a			;4673	4f 	O 
	rst 38h			;4674	ff 	. 
	ld b,c			;4675	41 	A 
	ld a,(0314ch)		;4676	3a 4c 31 	: L 1 
	ld b,h			;4679	44 	D 
	ld de,03145h		;467a	11 45 31 	. E 1 
	ld b,e			;467d	43 	C 
	inc de			;467e	13 	. 
	ld b,h			;467f	44 	D 
	ld sp,01542h		;4680	31 42 15 	1 B . 
	ld b,e			;4683	43 	C 
	ld sp,01341h		;4684	31 41 13 	1 A . 
	ld hl,04213h		;4687	21 13 42 	! . B 
	ld sp,01542h		;468a	31 42 15 	1 B . 
	ld b,e			;468d	43 	C 
	ld sp,01343h		;468e	31 43 13 	1 C . 
	ld b,h			;4691	44 	D 
	ld sp,01144h		;4692	31 44 11 	1 D . 
	ld b,l			;4695	45 	E 
	ld sp,03a4ah		;4696	31 4a 3a 	1 J : 
	ld c,e			;4699	4b 	K 
	rst 38h			;469a	ff 	. 
	ld c,a			;469b	4f 	O 
	ld c,b			;469c	48 	H 
	add hl,hl			;469d	29 	) 
	ld b,d			;469e	42 	B 
	ld hl,02147h		;469f	21 47 21 	! G ! 
	ld b,d			;46a2	42 	B 
	ld hl,02541h		;46a3	21 41 25 	! A % 
	ld b,c			;46a6	41 	A 
	ld hl,02142h		;46a7	21 42 21 	! B ! 
	ld b,c			;46aa	41 	A 
	ld hl,02143h		;46ab	21 43 21 	! C ! 
	ld b,c			;46ae	41 	A 
	ld hl,02142h		;46af	21 42 21 	! B ! 
	ld b,c			;46b2	41 	A 
	ld hl,02141h		;46b3	21 41 21 	! A ! 
	ld b,c			;46b6	41 	A 
	ld hl,02141h		;46b7	21 41 21 	! A ! 
	ld b,d			;46ba	42 	B 
	ld hl,02141h		;46bb	21 41 21 	! A ! 
	ld b,e			;46be	43 	C 
	ld hl,02141h		;46bf	21 41 21 	! A ! 
	ld b,d			;46c2	42 	B 
	ld hl,02541h		;46c3	21 41 25 	! A % 
	ld b,c			;46c6	41 	A 
	ld hl,02142h		;46c7	21 42 21 	! B ! 
	ld b,a			;46ca	47 	G 
	ld hl,02942h		;46cb	21 42 29 	! B ) 
	ld c,h			;46ce	4c 	L 
	rst 38h			;46cf	ff 	. 
	ld c,e			;46d0	4b 	K 
	dec sp			;46d1	3b 	; 
	ld b,h			;46d2	44 	D 
	ld sp,03143h		;46d3	31 43 31 	1 C 1 
	ld de,03142h		;46d6	11 42 31 	. B 1 
	ld de,03141h		;46d9	11 41 31 	. A 1 
	ld b,e			;46dc	43 	C 
	ld sp,03143h		;46dd	31 43 31 	1 C 1 
	ld b,d			;46e0	42 	B 
	ld sp,03141h		;46e1	31 41 31 	1 A 1 
	ld b,c			;46e4	41 	A 
	ld sp,03143h		;46e5	31 43 31 	1 C 1 
	ld b,d			;46e8	42 	B 
	ld sp,03111h		;46e9	31 11 31 	1 . 1 
	ld b,c			;46ec	41 	A 
	ld sp,03143h		;46ed	31 43 31 	1 C 1 
	ld b,c			;46f0	41 	A 
	ld de,04131h		;46f1	11 31 41 	. 1 A 
	ld sp,03111h		;46f4	31 11 31 	1 . 1 
	ld b,e			;46f7	43 	C 
	ld sp,03142h		;46f8	31 42 31 	1 B 1 
	ld de,04131h		;46fb	11 31 41 	. 1 A 
	ld sp,03143h		;46fe	31 43 31 	1 C 1 
	ld b,d			;4701	42 	B 
l4702h:
	ld sp,03141h		;4702	31 41 31 	1 A 1 
	ld b,c			;4705	41 	A 
	ld sp,03143h		;4706	31 43 31 	1 C 1 
	ld de,03143h		;4709	11 43 31 	. C 1 
	ld b,l			;470c	45 	E 
	ld sp,03144h		;470d	31 44 31 	1 D 1 
	ld b,e			;4710	43 	C 
	ld de,03a41h		;4711	11 41 3a 	. A : 
	rst 38h			;4714	ff 	. 
	ld c,a			;4715	4f 	O 
	ld c,b			;4716	48 	H 
	ld (bc),a			;4717	02 	. 
	ld b,c			;4718	41 	A 
	inc bc			;4719	03 	. 
	ld b,c			;471a	41 	A 
	ld (bc),a			;471b	02 	. 
	ld b,d			;471c	42 	B 
	ld (bc),a			;471d	02 	. 
	ld b,c			;471e	41 	A 
	inc bc			;471f	03 	. 
	ld b,c			;4720	41 	A 
	ld (bc),a			;4721	02 	. 
	ld b,d			;4722	42 	B 
	ld (bc),a			;4723	02 	. 
	ld b,c			;4724	41 	A 
	ld bc,00111h		;4725	01 11 01 	. . . 
	ld b,c			;4728	41 	A 
	ld (bc),a			;4729	02 	. 
	ld b,d			;472a	42 	B 
	ld (bc),a			;472b	02 	. 
	ld b,c			;472c	41 	A 
	inc bc			;472d	03 	. 
	ld b,c			;472e	41 	A 
	ld (bc),a			;472f	02 	. 
	ld b,d			;4730	42 	B 
	ld bc,l4111h		;4731	01 11 41 	. . A 
	ld bc,00111h		;4734	01 11 01 	. . . 
	ld b,c			;4737	41 	A 
	ld de,sub_41ffh+2		;4738	11 01 42 	. . B 
	ld (bc),a			;473b	02 	. 
	ld b,c			;473c	41 	A 
	inc bc			;473d	03 	. 
	ld b,c			;473e	41 	A 
	ld (bc),a			;473f	02 	. 
	ld b,d			;4740	42 	B 
	ld (bc),a			;4741	02 	. 
	ld b,c			;4742	41 	A 
	inc bc			;4743	03 	. 
	ld b,c			;4744	41 	A 
	ld (bc),a			;4745	02 	. 
	ld b,d			;4746	42 	B 
	ld bc,l4111h		;4747	01 11 41 	. . A 
	inc bc			;474a	03 	. 
	ld b,c			;474b	41 	A 
	ld de,l4effh+2		;474c	11 01 4f 	. . O 
l474fh:
	ld c,b			;474f	48 	H 
	rst 38h			;4750	ff 	. 
	ld c,e			;4751	4b 	K 
	ld de,01129h		;4752	11 29 11 	. ) . 
	ld sp,03149h		;4755	31 49 31 	1 I 1 
	ld de,01109h		;4758	11 09 11 	. . . 
	ld c,e			;475b	4b 	K 
	ld de,01129h		;475c	11 29 11 	. ) . 
	ld sp,03149h		;475f	31 49 31 	1 I 1 
	ld de,01109h		;4762	11 09 11 	. . . 
	ld c,e			;4765	4b 	K 
	ld de,01129h		;4766	11 29 11 	. ) . 
	ld sp,03149h		;4769	31 49 31 	1 I 1 
	ld de,01109h		;476c	11 09 11 	. . . 
	rst 38h			;476f	ff 	. 
	ld c,e			;4770	4b 	K 
	ld bc,00331h		;4771	01 31 03 	. 1 . 
	ld de,03103h		;4774	11 03 31 	. . 1 
	inc bc			;4777	03 	. 
	ld sp,01301h		;4778	31 01 13 	1 . . 
	ld bc,00531h		;477b	01 31 05 	. 1 . 
	ld sp,01101h		;477e	31 01 11 	1 . . 
	ld bc,00731h		;4781	01 31 07 	. 1 . 
	ld sp,03111h		;4784	31 11 31 	1 . 1 
	rrca			;4787	0f 	. 
	ld (bc),a			;4788	02 	. 
	ld de,01105h		;4789	11 05 11 	. . . 
	inc b			;478c	04 	. 
	ld de,01102h		;478d	11 02 11 	. . . 
	ld (bc),a			;4790	02 	. 
	ld de,02103h		;4791	11 03 21 	. . ! 
	ld de,01102h		;4794	11 02 11 	. . . 
	ld (bc),a			;4797	02 	. 
	ld de,00121h		;4798	11 21 01 	. ! . 
	ld (de),a			;479b	12 	. 
	ld hl,00111h		;479c	21 11 01 	! . . 
	ld de,01101h		;479f	11 01 11 	. . . 
	ld hl,00312h		;47a2	21 12 03 	! . . 
	ld hl,01101h		;47a5	21 01 11 	! . . 
	ld bc,00721h		;47a8	01 21 07 	. ! . 
	ld hl,02111h		;47ab	21 11 21 	! . ! 
	inc b			;47ae	04 	. 
	rst 38h			;47af	ff 	. 
	ld b,l			;47b0	45 	E 
	ld sp,01248h		;47b1	31 48 12 	1 H . 
	ld b,c			;47b4	41 	A 
	ld (de),a			;47b5	12 	. 
	ld b,h			;47b6	44 	D 
	ld (de),a			;47b7	12 	. 
	ld b,d			;47b8	42 	B 
	ld sp,01242h		;47b9	31 42 12 	1 B . 
	ld b,c			;47bc	41 	A 
	ld de,01242h		;47bd	11 42 12 	. B . 
	ld b,c			;47c0	41 	A 
	ld (de),a			;47c1	12 	. 
	ld b,d			;47c2	42 	B 
	ld de,01241h		;47c3	11 41 12 	. A . 
	ld b,d			;47c6	42 	B 
	ld sp,01242h		;47c7	31 42 12 	1 B . 
	ld b,c			;47ca	41 	A 
	ld de,01242h		;47cb	11 42 12 	. B . 
	ld b,c			;47ce	41 	A 
	ld (de),a			;47cf	12 	. 
	ld b,d			;47d0	42 	B 
	ld de,01241h		;47d1	11 41 12 	. A . 
	ld b,d			;47d4	42 	B 
	ld sp,01242h		;47d5	31 42 12 	1 B . 
	ld b,c			;47d8	41 	A 
	ld de,01242h		;47d9	11 42 12 	. B . 
	ld b,c			;47dc	41 	A 
	ld (de),a			;47dd	12 	. 
	ld b,d			;47de	42 	B 
	ld de,01241h		;47df	11 41 12 	. A . 
	ld b,d			;47e2	42 	B 
	ld sp,01242h		;47e3	31 42 12 	1 B . 
	ld b,c			;47e6	41 	A 
	ld de,01242h		;47e7	11 42 12 	. B . 
	ld b,c			;47ea	41 	A 
	ld (de),a			;47eb	12 	. 
	ld b,d			;47ec	42 	B 
	ld de,01241h		;47ed	11 41 12 	. A . 
	ld b,l			;47f0	45 	E 
	ld (de),a			;47f1	12 	. 
	ld b,c			;47f2	41 	A 
	ld de,01149h		;47f3	11 49 11 	. I . 
	rst 38h			;47f6	ff 	. 
	ld b,l			;47f7	45 	E 
	ld hl,01148h		;47f8	21 48 11 	! H . 
	ld bc,00121h		;47fb	01 21 01 	. ! . 
	ld de,01145h		;47fe	11 45 11 	. E . 
	ld bc,00111h		;4801	01 11 01 	. . . 
	ld de,01101h		;4804	11 01 11 	. . . 
	ld b,e			;4807	43 	C 
	ld de,01101h		;4808	11 01 11 	. . . 
	ld bc,00111h		;480b	01 11 01 	. . . 
	ld de,01101h		;480e	11 01 11 	. . . 
	ld b,d			;4811	42 	B 
	ld bc,00111h		;4812	01 11 01 	. . . 
	ld de,01101h		;4815	11 01 11 	. . . 
	ld bc,00111h		;4818	01 11 01 	. . . 
	ld b,d			;481b	42 	B 
	ld de,01101h		;481c	11 01 11 	. . . 
	ld bc,00111h		;481f	01 11 01 	. . . 
	ld de,01101h		;4822	11 01 11 	. . . 
	ld b,d			;4825	42 	B 
	ld hl,02141h		;4826	21 41 21 	! A ! 
	ld b,c			;4829	41 	A 
	ld hl,02141h		;482a	21 41 21 	! A ! 
	ld b,c			;482d	41 	A 
	ld hl,02146h		;482e	21 46 21 	! F ! 
	ld c,d			;4831	4a 	J 
	ld hl,03148h		;4832	21 48 31 	! H 1 
	ld b,c			;4835	41 	A 
	ld sp,03348h		;4836	31 48 33 	1 H 3 
	ld c,c			;4839	49 	I 
	ld sp,0ff46h		;483a	31 46 ff 	1 F . 
	ld bc,03141h		;483d	01 41 31 	. A 1 
	dec d			;4840	15 	. 
	ld sp,00241h		;4841	31 41 02 	1 A . 
	ld b,c			;4844	41 	A 
	ld (03203h),a		;4845	32 03 32 	2 . 2 
sub_4848h:
	ld b,c			;4848	41 	A 
	ld bc,l4111h		;4849	01 11 41 	. . A 
	ld sp,03141h		;484c	31 41 31 	1 A 1 
	ld de,04131h		;484f	11 31 41 	. 1 A 
	ld sp,01241h		;4852	31 41 12 	1 A . 
	ld b,c			;4855	41 	A 
	ld sp,00141h		;4856	31 41 01 	1 A . 
	ld hl,l4101h		;4859	21 01 41 	! . A 
	ld sp,01241h		;485c	31 41 12 	1 A . 
	ld b,c			;485f	41 	A 
	ld sp,01141h		;4860	31 41 11 	1 A . 
	ld b,c			;4863	41 	A 
	ld de,03141h		;4864	11 41 31 	. A 1 
	ld b,c			;4867	41 	A 
	ld (de),a			;4868	12 	. 
	ld b,c			;4869	41 	A 
	ld sp,00141h		;486a	31 41 01 	1 A . 
	ld b,c			;486d	41 	A 
	ld bc,03141h		;486e	01 41 31 	. A 1 
	ld b,c			;4871	41 	A 
	ld (de),a			;4872	12 	. 
	ld b,c			;4873	41 	A 
	ld sp,01141h		;4874	31 41 11 	1 A . 
	ld b,c			;4877	41 	A 
	ld de,03141h		;4878	11 41 31 	. A 1 
	ld b,c			;487b	41 	A 
	ld (de),a			;487c	12 	. 
	ld b,c			;487d	41 	A 
	ld sp,00141h		;487e	31 41 01 	1 A . 
	ld b,c			;4881	41 	A 
	ld bc,03141h		;4882	01 41 31 	. A 1 
	ld b,c			;4885	41 	A 
	ld (de),a			;4886	12 	. 
	ld b,c			;4887	41 	A 
	ld sp,01141h		;4888	31 41 11 	1 A . 
	ld b,c			;488b	41 	A 
	ld de,03141h		;488c	11 41 31 	. A 1 
	ld b,c			;488f	41 	A 
	ld de,03301h		;4890	11 01 33 	. . 3 
	ld bc,00141h		;4893	01 41 01 	. A . 
	inc sp			;4896	33 	3 
	ld bc,l474fh		;4897	01 4f 47 	. O G 
	rst 38h			;489a	ff 	. 
	ld c,l			;489b	4d 	M 
	scf			;489c	37 	7 
	ld b,h			;489d	44 	D 
	ld de,01101h		;489e	11 01 11 	. . . 
	ld sp,00111h		;48a1	31 11 01 	1 . . 
	ld de,01144h		;48a4	11 44 11 	. D . 
	ld bc,03111h		;48a7	01 11 31 	. . 1 
	ld de,01101h		;48aa	11 01 11 	. . . 
	ld b,h			;48ad	44 	D 
	ld de,01101h		;48ae	11 01 11 	. . . 
	ld sp,00111h		;48b1	31 11 01 	1 . . 
	ld de,01144h		;48b4	11 44 11 	. D . 
	ld bc,00113h		;48b7	01 13 01 	. . . 
	ld de,01144h		;48ba	11 44 11 	. D . 
	ld bc,03111h		;48bd	01 11 31 	. . 1 
	ld de,01101h		;48c0	11 01 11 	. . . 
	ld b,h			;48c3	44 	D 
	ld de,01101h		;48c4	11 01 11 	. . . 
	ld sp,00111h		;48c7	31 11 01 	1 . . 
	ld de,01144h		;48ca	11 44 11 	. D . 
	ld bc,03111h		;48cd	01 11 31 	. . 1 
	ld de,01101h		;48d0	11 01 11 	. . . 
	ld b,h			;48d3	44 	D 
	scf			;48d4	37 	7 
	ld c,a			;48d5	4f 	O 
	ld c,c			;48d6	49 	I 
	rst 38h			;48d7	ff 	. 
	ld c,a			;48d8	4f 	O 
	ld b,a			;48d9	47 	G 
	ld de,01131h		;48da	11 31 11 	. 1 . 
	ld sp,03111h		;48dd	31 11 31 	1 . 1 
	ld de,01131h		;48e0	11 31 11 	. 1 . 
	ld sp,03112h		;48e3	31 12 31 	1 . 1 
	ld hl,02131h		;48e6	21 31 21 	! 1 ! 
	ld sp,03121h		;48e9	31 21 31 	1 ! 1 
	ld hl,01131h		;48ec	21 31 11 	! 1 . 
	ld b,d			;48ef	42 	B 
	ld de,03149h		;48f0	11 49 31 	. I 1 
	ld b,c			;48f3	41 	A 
	ld sp,03111h		;48f4	31 11 31 	1 . 1 
	ld b,c			;48f7	41 	A 
	ld sp,03141h		;48f8	31 41 31 	1 A 1 
	ld b,d			;48fb	42 	B 
	ld sp,03141h		;48fc	31 41 31 	1 A 1 
	ld b,c			;48ff	41 	A 
	ld sp,03111h		;4900	31 11 31 	1 . 1 
	ld b,c			;4903	41 	A 
	ld sp,03142h		;4904	31 42 31 	1 B 1 
	ld b,c			;4907	41 	A 
	ld sp,03141h		;4908	31 41 31 	1 A 1 
	ld b,c			;490b	41 	A 
	ld sp,03111h		;490c	31 11 31 	1 . 1 
	ld b,a			;490f	47 	G 
	ld de,03145h		;4910	11 45 31 	. E 1 
	ld b,c			;4913	41 	A 
	ld sp,03111h		;4914	31 11 31 	1 . 1 
	ld b,c			;4917	41 	A 
	ld sp,03141h		;4918	31 41 31 	1 A 1 
	ld b,e			;491b	43 	C 
	ld de,04131h		;491c	11 31 41 	. 1 A 
	ld sp,03141h		;491f	31 41 31 	1 A 1 
	ld b,e			;4922	43 	C 
	ld de,03144h		;4923	11 44 31 	. D 1 
	ld b,l			;4926	45 	E 
	rst 38h			;4927	ff 	. 
	ld c,h			;4928	4c 	L 
	ld sp,03117h		;4929	31 17 31 	1 . 1 
	ld b,d			;492c	42 	B 
	ld sp,03147h		;492d	31 47 31 	1 G 1 
	ld b,d			;4930	42 	B 
l4931h:
	ld sp,03541h		;4931	31 41 35 	1 A 5 
	ld b,c			;4934	41 	A 
	ld sp,03142h		;4935	31 42 31 	1 B 1 
	ld b,c			;4938	41 	A 
	ld sp,03143h		;4939	31 43 31 	1 C 1 
	ld b,c			;493c	41 	A 
	ld sp,03142h		;493d	31 42 31 	1 B 1 
	ld b,c			;4940	41 	A 
	ld sp,01141h		;4941	31 41 11 	1 A . 
	ld b,c			;4944	41 	A 
	ld sp,03141h		;4945	31 41 31 	1 A 1 
	ld b,d			;4948	42 	B 
	ld sp,03141h		;4949	31 41 31 	1 A 1 
	ld b,c			;494c	41 	A 
	ld de,03141h		;494d	11 41 31 	. A 1 
	ld b,c			;4950	41 	A 
	ld sp,03142h		;4951	31 42 31 	1 B 1 
	ld b,c			;4954	41 	A 
	ld sp,03143h		;4955	31 43 31 	1 C 1 
	ld b,c			;4958	41 	A 
	ld sp,03142h		;4959	31 42 31 	1 B 1 
	ld b,c			;495c	41 	A 
	ld sp,03113h		;495d	31 13 31 	1 . 1 
	ld b,c			;4960	41 	A 
	ld sp,03142h		;4961	31 42 31 	1 B 1 
	ld b,a			;4964	47 	G 
	ld sp,03142h		;4965	31 42 31 	1 B 1 
	ld b,a			;4968	47 	G 
	ld sp,03942h		;4969	31 42 39 	1 B 9 
	ld b,c			;496c	41 	A 
	rst 38h			;496d	ff 	. 
	ld c,e			;496e	4b 	K 
	dec bc			;496f	0b 	. 
	dec de			;4970	1b 	. 
	ld c,e			;4971	4b 	K 
	ld de,04131h		;4972	11 31 41 	. 1 A 
	ld sp,00111h		;4975	31 11 01 	1 . . 
	ld de,04131h		;4978	11 31 41 	. 1 A 
	ld sp,03112h		;497b	31 12 31 	1 . 1 
	ld b,c			;497e	41 	A 
	ld sp,03113h		;497f	31 13 31 	1 . 1 
	ld b,c			;4982	41 	A 
	ld sp,03112h		;4983	31 12 31 	1 . 1 
	ld b,c			;4986	41 	A 
	ld sp,03113h		;4987	31 13 31 	1 . 1 
	ld b,c			;498a	41 	A 
	ld sp,03112h		;498b	31 12 31 	1 . 1 
	ld b,c			;498e	41 	A 
	ld sp,00111h		;498f	31 11 01 	1 . . 
	ld de,04131h		;4992	11 31 41 	. 1 A 
	ld sp,l4b11h		;4995	31 11 4b 	1 . K 
	rrca			;4998	0f 	. 
	rlca			;4999	07 	. 
	ld c,e			;499a	4b 	K 
	rst 38h			;499b	ff 	. 
	ld c,a			;499c	4f 	O 
	ld b,a			;499d	47 	G 
	dec de			;499e	1b 	. 
	ld c,l			;499f	4d 	M 
	ld hl,l4111h		;49a0	21 11 41 	! . A 
	ld hl,l4111h		;49a3	21 11 41 	! . A 
	ld hl,l4311h		;49a6	21 11 43 	! . C 
	ld (02241h),hl		;49a9	22 41 22 	" A " 
	ld b,c			;49ac	41 	A 
	ld (0214dh),hl		;49ad	22 4d 21 	" M ! 
	ld de,02141h		;49b0	11 41 21 	. A ! 
	ld de,02141h		;49b3	11 41 21 	. A ! 
	ld de,02243h		;49b6	11 43 22 	. C " 
	ld b,c			;49b9	41 	A 
	ld (02241h),hl		;49ba	22 41 22 	" A " 
	ld c,l			;49bd	4d 	M 
	ld hl,l4111h		;49be	21 11 41 	! . A 
	ld hl,l4111h		;49c1	21 11 41 	! . A 
	ld hl,l4311h		;49c4	21 11 43 	! . C 
	ld (02241h),hl		;49c7	22 41 22 	" A " 
	ld b,c			;49ca	41 	A 
	ld (0ff43h),hl		;49cb	22 43 ff 	" C . 
	ld c,a			;49ce	4f 	O 
	ld c,a			;49cf	4f 	O 
	ld b,a			;49d0	47 	G 
	inc de			;49d1	13 	. 
	ld c,b			;49d2	48 	H 
	inc de			;49d3	13 	. 
	ld c,b			;49d4	48 	H 
	inc de			;49d5	13 	. 
	ld b,a			;49d6	47 	G 
	ld de,01101h		;49d7	11 01 11 	. . . 
	ld bc,04611h		;49da	01 11 46 	. . F 
	dec b			;49dd	05 	. 
	ld b,l			;49de	45 	E 
	rlca			;49df	07 	. 
	ld b,h			;49e0	44 	D 
	rlca			;49e1	07 	. 
	ld b,e			;49e2	43 	C 
	add hl,bc			;49e3	09 	. 
	ld b,c			;49e4	41 	A 
	dec bc			;49e5	0b 	. 
	rst 38h			;49e6	ff 	. 
	ld c,a			;49e7	4f 	O 
	ld c,a			;49e8	4f 	O 
	ld b,e			;49e9	43 	C 
	ld bc,00212h		;49ea	01 12 02 	. . . 
	ld de,01202h		;49ed	11 02 12 	. . . 
	ld (bc),a			;49f0	02 	. 
	ld (de),a			;49f1	12 	. 
	ld (bc),a			;49f2	02 	. 
	ld de,01202h		;49f3	11 02 12 	. . . 
	ld bc,02334h		;49f6	01 34 23 	. 4 # 
	dec (hl)			;49f9	35 	5 
	ld (bc),a			;49fa	02 	. 
	ld sp,03143h		;49fb	31 43 31 	1 C 1 
	ld (bc),a			;49fe	02 	. 
	ld (03249h),a		;49ff	32 49 32 	2 I 2 
	ld c,c			;4a02	49 	I 
	ld (03249h),a		;4a03	32 49 32 	2 I 2 
	ld b,d			;4a06	42 	B 
	ld sp,03103h		;4a07	31 03 31 	1 . 1 
	ld b,d			;4a0a	42 	B 
	ld (03522h),a		;4a0b	32 22 35 	2 " 5 
	ld (0ff31h),hl		;4a0e	22 31 ff 	" 1 . 
	ld c,a			;4a11	4f 	O 
	ld c,c			;4a12	49 	I 
	ld sp,03122h		;4a13	31 22 31 	1 " 1 
	ld b,(hl)			;4a16	46 	F 
	ld sp,03144h		;4a17	31 44 31 	1 D 1 
	ld b,h			;4a1a	44 	D 
	ld sp,01242h		;4a1b	31 42 12 	1 B . 
	ld b,d			;4a1e	42 	B 
	ld sp,03143h		;4a1f	31 43 31 	1 C 1 
	ld b,c			;4a22	41 	A 
	inc d			;4a23	14 	. 
	ld b,c			;4a24	41 	A 
	ld sp,03143h		;4a25	31 43 31 	1 C 1 
	ld b,d			;4a28	42 	B 
	ld (de),a			;4a29	12 	. 
	ld b,d			;4a2a	42 	B 
	ld sp,03144h		;4a2b	31 44 31 	1 D 1 
	ld b,h			;4a2e	44 	D 
	ld sp,03446h		;4a2f	31 46 34 	1 F 4 
	ld c,a			;4a32	4f 	O 
	ld c,a			;4a33	4f 	O 
	ld c,b			;4a34	48 	H 
	rst 38h			;4a35	ff 	. 
	ld c,a			;4a36	4f 	O 
	ld c,a			;4a37	4f 	O 
	ld c,a			;4a38	4f 	O 
	ld c,d			;4a39	4a 	J 
	dec hl			;4a3a	2b 	+ 
	ld de,02b0ah		;4a3b	11 0a 2b 	. . + 
	ld c,e			;4a3e	4b 	K 
	dec hl			;4a3f	2b 	+ 
	dec de			;4a40	1b 	. 
	dec hl			;4a41	2b 	+ 
	rst 38h			;4a42	ff 	. 
	ld c,e			;4a43	4b 	K 
	ld b,011h		;4a44	06 11 	. . 
	dec b			;4a46	05 	. 
	inc sp			;4a47	33 	3 
	ld bc,00131h		;4a48	01 31 01 	. 1 . 
	inc sp			;4a4b	33 	3 
	ld (bc),a			;4a4c	02 	. 
	ld sp,03147h		;4a4d	31 47 31 	1 G 1 
	ld (bc),a			;4a50	02 	. 
	ld sp,04501h		;4a51	31 01 45 	1 . E 
	ld bc,00231h		;4a54	01 31 02 	. 1 . 
	ld sp,l4311h+1		;4a57	31 12 43 	1 . C 
	ld (de),a			;4a5a	12 	. 
	ld sp,l4101h		;4a5b	31 01 41 	1 . A 
	ld bc,01231h		;4a5e	01 31 12 	. 1 . 
	ld b,c			;4a61	41 	A 
	ld (de),a			;4a62	12 	. 
	ld sp,04301h		;4a63	31 01 43 	1 . C 
	ld bc,01131h		;4a66	01 31 11 	. 1 . 
	ld bc,03111h		;4a69	01 11 31 	. . 1 
	ld bc,00145h		;4a6c	01 45 01 	. E . 
	ld sp,03101h		;4a6f	31 01 31 	1 . 1 
	ld bc,00147h		;4a72	01 47 01 	. G . 
	ld de,04901h		;4a75	11 01 49 	. . I 
	ld bc,0414fh		;4a78	01 4f 41 	. O A 
	rst 38h			;4a7b	ff 	. 
	ld c,a			;4a7c	4f 	O 
	ld b,a			;4a7d	47 	G 
	inc b			;4a7e	04 	. 
	ld sp,03141h		;4a7f	31 41 31 	1 A 1 
	ex af,af'			;4a82	08 	. 
	ld sp,03141h		;4a83	31 41 31 	1 A 1 
	ex af,af'			;4a86	08 	. 
	ld sp,03141h		;4a87	31 41 31 	1 A 1 
	inc b			;4a8a	04 	. 
	ld sp,03212h		;4a8b	31 12 32 	1 . 2 
	ld b,c			;4a8e	41 	A 
	ld (03112h),a		;4a8f	32 12 31 	2 . 1 
	inc b			;4a92	04 	. 
	ld sp,03141h		;4a93	31 41 31 	1 A 1 
	ex af,af'			;4a96	08 	. 
	ld sp,03141h		;4a97	31 41 31 	1 A 1 
	inc b			;4a9a	04 	. 
	ld hl,02112h		;4a9b	21 12 21 	! . ! 
	ld sp,03141h		;4a9e	31 41 31 	1 A 1 
	ld hl,02112h		;4aa1	21 12 21 	! . ! 
	inc b			;4aa4	04 	. 
	ld sp,03141h		;4aa5	31 41 31 	1 A 1 
	ex af,af'			;4aa8	08 	. 
	ld sp,03141h		;4aa9	31 41 31 	1 A 1 
	ex af,af'			;4aac	08 	. 
	ld sp,03141h		;4aad	31 41 31 	1 A 1 
	inc b			;4ab0	04 	. 
	rst 38h			;4ab1	ff 	. 
	ld c,a			;4ab2	4f 	O 
	ld b,a			;4ab3	47 	G 
	ld (de),a			;4ab4	12 	. 
	ld c,c			;4ab5	49 	I 
	inc d			;4ab6	14 	. 
	ld b,a			;4ab7	47 	G 
	ld d,045h		;4ab8	16 45 	. E 
	jr l4affh		;4aba	18 43 	. C 
	ld hl,04219h		;4abc	21 19 42 	! . B 
	ld sp,01821h		;4abf	31 21 18 	1 ! . 
	ld b,e			;4ac2	43 	C 
	ld sp,01621h		;4ac3	31 21 16 	1 ! . 
	ld b,l			;4ac6	45 	E 
	ld sp,01421h		;4ac7	31 21 14 	1 ! . 
	ld b,a			;4aca	47 	G 
	ld sp,01221h		;4acb	31 21 12 	1 ! . 
	ld c,c			;4ace	49 	I 
	ld sp,0ff21h		;4acf	31 21 ff 	1 ! . 
	ld c,a			;4ad2	4f 	O 
	ld b,a			;4ad3	47 	G 
	ld de,01141h		;4ad4	11 41 11 	. A . 
	ld b,c			;4ad7	41 	A 
	ld de,01141h		;4ad8	11 41 11 	. A . 
	ld b,c			;4adb	41 	A 
	ld de,01141h		;4adc	11 41 11 	. A . 
	ld hl,02141h		;4adf	21 41 21 	! A ! 
	ld b,c			;4ae2	41 	A 
	ld hl,02141h		;4ae3	21 41 21 	! A ! 
	ld b,c			;4ae6	41 	A 
	ld hl,02141h		;4ae7	21 41 21 	! A ! 
	ld b,c			;4aea	41 	A 
	ld de,01141h		;4aeb	11 41 11 	. A . 
	ld b,c			;4aee	41 	A 
	ld de,01141h		;4aef	11 41 11 	. A . 
	ld b,c			;4af2	41 	A 
	ld de,02142h		;4af3	11 42 21 	. B ! 
	ld b,c			;4af6	41 	A 
	ld hl,02141h		;4af7	21 41 21 	! A ! 
	ld b,c			;4afa	41 	A 
	ld hl,02141h		;4afb	21 41 21 	! A ! 
	ld b,c			;4afe	41 	A 
l4affh:
	ld de,01141h		;4aff	11 41 11 	. A . 
	ld b,c			;4b02	41 	A 
	ld de,01141h		;4b03	11 41 11 	. A . 
	ld b,c			;4b06	41 	A 
	ld de,01141h		;4b07	11 41 11 	. A . 
	ld hl,02141h		;4b0a	21 41 21 	! A ! 
	ld b,c			;4b0d	41 	A 
	ld hl,02141h		;4b0e	21 41 21 	! A ! 
l4b11h:
	ld b,c			;4b11	41 	A 
	ld hl,02141h		;4b12	21 41 21 	! A ! 
	ld b,c			;4b15	41 	A 
	ld de,01141h		;4b16	11 41 11 	. A . 
	ld b,c			;4b19	41 	A 
	ld de,01141h		;4b1a	11 41 11 	. A . 
	ld b,c			;4b1d	41 	A 
	ld de,02142h		;4b1e	11 42 21 	. B ! 
	ld b,c			;4b21	41 	A 
	ld hl,02141h		;4b22	21 41 21 	! A ! 
	ld b,c			;4b25	41 	A 
	ld hl,02141h		;4b26	21 41 21 	! A ! 
	ld b,c			;4b29	41 	A 
	ld de,01141h		;4b2a	11 41 11 	. A . 
	ld b,c			;4b2d	41 	A 
	ld de,01141h		;4b2e	11 41 11 	. A . 
	ld b,c			;4b31	41 	A 
	ld de,01141h		;4b32	11 41 11 	. A . 
	ld hl,02141h		;4b35	21 41 21 	! A ! 
	ld b,c			;4b38	41 	A 
	ld hl,02141h		;4b39	21 41 21 	! A ! 
	ld b,c			;4b3c	41 	A 
	ld hl,02141h		;4b3d	21 41 21 	! A ! 
	rst 38h			;4b40	ff 	. 
	ld c,l			;4b41	4d 	M 
	ld sp,03141h		;4b42	31 41 31 	1 A 1 
	ld b,c			;4b45	41 	A 
	ld sp,03141h		;4b46	31 41 31 	1 A 1 
	ld b,h			;4b49	44 	D 
	ld sp,03141h		;4b4a	31 41 31 	1 A 1 
	ld b,c			;4b4d	41 	A 
	ld sp,03141h		;4b4e	31 41 31 	1 A 1 
	ld b,h			;4b51	44 	D 
	ld sp,03141h		;4b52	31 41 31 	1 A 1 
	ld b,c			;4b55	41 	A 
	ld sp,03141h		;4b56	31 41 31 	1 A 1 
	ld b,h			;4b59	44 	D 
	ld sp,03141h		;4b5a	31 41 31 	1 A 1 
	ld b,c			;4b5d	41 	A 
	ld sp,00111h		;4b5e	31 11 01 	1 . . 
	ld b,h			;4b61	44 	D 
	ld sp,03141h		;4b62	31 41 31 	1 A 1 
	ld b,c			;4b65	41 	A 
	ld sp,03141h		;4b66	31 41 31 	1 A 1 
	ld b,h			;4b69	44 	D 
	ld sp,03141h		;4b6a	31 41 31 	1 A 1 
	ld de,l4403h		;4b6d	11 03 44 	. . D 
	ld sp,03141h		;4b70	31 41 31 	1 A 1 
	ld b,c			;4b73	41 	A 
	ld sp,03141h		;4b74	31 41 31 	1 A 1 
	ld b,h			;4b77	44 	D 
	ld sp,00511h		;4b78	31 11 05 	1 . . 
	ld b,h			;4b7b	44 	D 
	ld sp,03141h		;4b7c	31 41 31 	1 A 1 
	ld b,c			;4b7f	41 	A 
	ld sp,03141h		;4b80	31 41 31 	1 A 1 
	ld b,h			;4b83	44 	D 
	ld de,l4406h		;4b84	11 06 44 	. . D 
	daa			;4b87	27 	' 
	ld b,d			;4b88	42 	B 
	rst 38h			;4b89	ff 	. 
sub_4b8ah:
    ; Go on if we're at the title screen
	ld a,(GAME_STATE)		;4b8a	3a 0b e0
	or a			        ;4b8d	b7
	jp nz,l4d09h		    ;4b8e	c2 09 4d

	ld a,(0e00dh)		;4b91	3a 0d e0 	: . . 
	or a			;4b94	b7 	. 
	jp nz,l4eddh		;4b95	c2 dd 4e 	. . N 
    
    
    ; [ToDo] This is a switch according to 0e53ch
	ld a,(0e53ch)		;4b98	3a 3c e5 	: < . 
	cp 001h		;4b9b	fe 01 	. . 
	jp z,l4c48h		;4b9d	ca 48 4c 	. H L 
	cp 002h		;4ba0	fe 02 	. . 
	jp z,l4cc6h		;4ba2	ca c6 4c 	. . L 
	cp 005h		;4ba5	fe 05 	. . 
	jp z,l4ca2h		;4ba7	ca a2 4c 	. . L 
	ld a,000h		;4baa	3e 00 	> . 
	ld (0f3ebh),a		;4bac	32 eb f3 	2 . . 
	call CHGCLR		;4baf	cd 62 00 	. b . 
	call CLEAR_SCREEN		;4bb2	cd 27 42 	. ' B 

    ; Fill pattern table (1/3)
	ld hl,l9024h		        ;4bb5	21 24 90
	ld de, 0 * 8*32*24/3		;4bb8	11 00 00
	call LDIRVM_32x24_THIRD		;4bbb	cd 20 42

	; Fill pattern table (2/3)
    ld hl,l9024h		        ;4bbe	21 24 90
	ld de, 1 * 8*32*24/3		;4bc1	11 00 08
	call LDIRVM_32x24_THIRD		;4bc4	cd 20 42

	; Fill pattern table (3/3)
    ld hl,l9024h		        ;4bc7	21 24 90
	ld de, 2 * 8*32*24/3		;4bca	11 00 10
	call LDIRVM_32x24_THIRD		;4bcd	cd 20 42

	call sub_41ffh		;4bd0	cd ff 41 	. . A 

	ld hl,01800h		;4bd3	21 00 18 	! . . 
	ld a,000h		;4bd6	3e 00 	> . 
	ld bc,00300h		;4bd8	01 00 03 	. . . 
	call FILVRM		;4bdb	cd 56 00 	. V . 

    call DRAW_UP_SCORES		;4bde	cd e0 4f 	. . O 

	ld hl,l543eh		;4be1	21 3e 54 	! > T 
	ld de,018c0h		;4be4	11 c0 18 	. . . 
	ld bc,00060h		;4be7	01 60 00 	. ` . 
	call LDIRVM		;4bea	cd 5c 00 	. \ . 

	ld ix,0e0cdh		;4bed	dd 21 cd e0 	. ! . . 
	ld (ix+000h),034h		;4bf1	dd 36 00 34 	. 6 . 4 
	ld (ix+001h),094h		;4bf5	dd 36 01 94 	. 6 . . 
	ld (ix+002h),0a0h		;4bf9	dd 36 02 a0 	. 6 . . 
	ld (ix+003h),00ah		;4bfd	dd 36 03 0a 	. 6 . . 
	ld a,001h		;4c01	3e 01 	> . 
	ld (0e53ch),a		;4c03	32 3c e5 	2 < . 

    ; Write "PRESS START BUTTON"
	ld hl,PUSH_START_BUTTON_STR		;4c06	21 b3 54
	ld de,019a8h		            ;4c09	11 a8 19
	ld bc, 17		                ;4c0c	01 11 00  len("PUSH START BUTTON")
	call LDIRVM		                ;4c0f	cd 5c 00

    ; Print TAITO's (c) string
	ld hl,TAITO_CORP_STR		;4c12	21 de 54
	ld de,01a84h		        ;4c15	11 84 1a
	ld bc,00018h		        ;4c18	01 18 00
	call LDIRVM		            ;4c1b	cd 5c 00

    ; Print "ALL RIGHTS RESERVED"
	ld hl,ALL_RIGHTS_RESERVED_STR		;4c1e	21 f6 54
	ld de,01ac6h		                ;4c21	11 c6 1a
	ld bc,00013h		                ;4c24	01 13 00
	call LDIRVM		                    ;4c27	cd 5c 00

    ; Draw upper half of Taito's logo
	ld hl,l5509h		;4c2a	21 09 55
	ld de,01a2bh		;4c2d	11 2b 1a
	ld bc,0000bh		;4c30	01 0b 00
	call LDIRVM		    ;4c33	cd 5c 00

    ; Draw lower half of Taito's logo
	ld hl,l5514h		;4c36	21 14 55
	ld de,01a4bh		;4c39	11 4b 1a
	ld bc,0000bh		;4c3c	01 0b 00
	call LDIRVM		    ;4c3f	cd 5c 00

    ; Reset the title ticks
	ld a,000h		;4c42	3e 00 	> . 
	ld (TITLE_TICKS),a		;4c44	32 3f e5 	2 ? . 
	ret			;4c47	c9 	. 
l4c48h:
	ld a,(0e00ch)		;4c48	3a 0c e0 	: . . 
	or a			;4c4b	b7 	. 
	jp z,l4c5ah		;4c4c	ca 5a 4c 	. Z L 
	ld a,(0e0c5h)		;4c4f	3a c5 e0 	: . . 
	bit 1,a		;4c52	cb 4f 	. O 
	jp nz,l4c73h		;4c54	c2 73 4c 	. s L 
	jp l4c62h		;4c57	c3 62 4c 	. b L 
l4c5ah:
	ld a,(0e0bfh)		;4c5a	3a bf e0 	: . . 
	bit 4,a		;4c5d	cb 67 	. g 
	jp nz,l4c73h		;4c5f	c2 73 4c 	. s L 
l4c62h:
    ; Increment the title's ticks
	ld hl,(TITLE_TICKS)		;4c62	2a 3f e5
	inc hl			        ;4c65	23
	ld (TITLE_TICKS),hl		;4c66	22 3f e5
	xor a			        ;4c69	af
	ld de, 480		        ;4c6a	11 e0 01
	sbc hl,de		        ;4c6d	ed 52
    
    ; If we have 480 ticks, show the intro's text
    ; Otherwise, return
	jp z,l4c94h		        ;4c6f	ca 94 4c
	ret			            ;4c72	c9

l4c73h:
	ld a,002h		;4c73	3e 02 	> . 
	ld (0e53ch),a		;4c75	32 3c e5 	2 < . 

    ; Print "GAME START"
	ld hl,GAME_START_STR	;4c78	21 cc 54
	ld de,019a8h		    ;4c7b	11 a8 19
	ld bc,00011h		    ;4c7e	01 11 00
	call LDIRVM		        ;4c81	cd 5c 00

	ld a,SOUND_START_MUSIC		;4c84	3e c3 	> . 
	ld (SOUND_NUMBER),a		;4c86	32 c0 e5 	2 . . 
	call PLAY_SOUND		;4c89	cd e8 b4 	. . . 

    ; Wait 256 ticks
	ei			            ;4c8c	fb
	ld hl, 256  		    ;4c8d	21 00 01
	call DELAY_HL_TICKS		;4c90	cd 80 43
	ret			            ;4c93	c9

l4c94h:
	ld a,005h		;4c94	3e 05 	> . 
	ld (0e53ch),a		;4c96	32 3c e5 	2 < . 
	ld a,001h		;4c99	3e 01 	> . 
	ld (0e00dh),a		;4c9b	32 0d e0 	2 . . 
	call CLEAR_SCREEN		;4c9e	cd 27 42 	. ' B 
	ret			;4ca1	c9 	. 

l4ca2h:
    ; Set we're at the title screen
	ld a, 0		            ;4ca2	3e 00   No "xor a" optimization here :)
	ld (GAME_STATE),a		;4ca4	32 0b e0

    ; Choose next demo level
    
    ; A = [DEMO_LEVEL]++ AND 3
	ld a,(DEMO_LEVEL)		;4ca7	3a 00 e0
	inc a			        ;4caa	3c
	and 3		            ;4cab	e6 03
	ld (DEMO_LEVEL),a		;4cad	32 00 e0

    ; HL = DEMO_LEVELS_TABLE + [DEMO_LEVEL]++ AND 3
	ld l,a			            ;4cb0	6f
	ld h, 0		                ;4cb1	26 00
	ld de,DEMO_LEVELS_TABLE		;4cb3	11 c2 4c
	add hl,de			        ;4cb6	19

    ; LEVEL = DEMO_LEVELS_TABLE[[DEMO_LEVEL]++ AND 3]
    ; According to the 4 values of the table, the level can be 12, 3, 6, or 1.
	ld a,(hl)			;4cb7	7e
	ld (LEVEL),a		;4cb8	32 1b e0

    ; Bricks in the initial configuration
	xor a			            ;4cbb	af
	ld (BRICK_REPAINT_TYPE),a	;4cbc	32 22 e0
	jp l4d09h		;4cbf	c3 09 4d
DEMO_LEVELS_TABLE:
    db 12, 3, 6, 1

l4cc6h:
    ; Set we're in normal play
	ld a, 1		            ;4cc6	3e 01
	ld (GAME_STATE),a		;4cc8	32 0b e0

	ld hl,SCORE_BCD		;4ccb	21 15 e0 	! . . 
	ld de,0e016h		;4cce	11 16 e0 	. . . 
	ld bc,0059fh		;4cd1	01 9f 05 	. . . 
	dec bc			;4cd4	0b 	. 
	ld (hl),000h		;4cd5	36 00 	6 . 
	ldir		;4cd7	ed b0 	. . 
	ld a,020h		;4cd9	3e 20 	>   
	ld (0e01fh),a		;4cdb	32 1f e0 	2 . . 
	ld c,002h		;4cde	0e 02 	. . 

    ; Check if the cheat has been activated
    ; If so, give the 240 lives. Otherwise, don't!
	ld a,(CHEAT1_ACTIVATED)		;4ce0	3a 01 e0
	or a			            ;4ce3	b7
	jp z,l4ce9h		            ;4ce4	ca e9 4c
    
    ; Cheat
    ; To get 240 lives, at the title screen, hold Up + Down, press the Graph key 4 times and then
    ; press Space to start the game.
    ; https://gamefaqs.gamespot.com/msx/932003-arkanoid/cheats
	ld c, 240   		;4ce7	0e f0
l4ce9h:
	ld a,c			    ;4ce9	79
	ld (LIVES),a		;4cea	32 1d e0

    ; Deactivate cheat #1
	ld hl, 0		            ;4ced	21 00 00
	ld (CHEAT1_ACTIVATED),hl	;4cf0	22 01 e0
    
    ; Check cheat #2
	ld a,(CHEAT2_ACTIVATED)		;4cf3	3a 03 e0
	or a			            ;4cf6	b7
	jp z,l4d00h		            ;4cf7	ca 00 4d
    
    ; If cheat #2 is active, start at the last played level
	ld hl,(CHEAT2_LEVEL)		;4cfa	2a 05 e0
	ld (LEVEL),hl		;4cfd	22 1b e0
l4d00h:
    ; Deactivate cheat #2
	ld hl, 0		            ;4d00	21 00 00
	ld (CHEAT2_ACTIVATED),hl	;4d03	22 03 e0
	jp l4d09h		            ;4d06	c3 09 4d    Quite a redundant instruction!
l4d09h:
    ; Skip initialization to zero if there's no need to reset the brick config
	ld a,(BRICK_REPAINT_TYPE)		;4d09	3a 22 e0
	cp 2		                    ;4d0c	fe 02
	jp z,l4d22h		                ;4d0e	ca 22 4d

    ; ToDo: what is this structure?
	ld hl,0e027h		;4d11	21 27 e0 	! ' . 
	ld de,0e028h		;4d14	11 28 e0 	. ( . 
	ld bc,0058dh		;4d17	01 8d 05 	. . . 
	dec bc			;4d1a	0b 	. 
	ld (hl),000h		;4d1b	36 00 	6 . 
	ldir		;4d1d	ed b0 	. . 

	jp l4d30h		;4d1f	c3 30 4d 	. 0 M 
l4d22h:
    ; ToDo: what is this structure?
	ld hl,0e0bfh		;4d22	21 bf e0 	! . . 
	ld de,KEYBOARD_INPUT		;4d25	11 c0 e0 	. . . 
	ld bc,004f5h		;4d28	01 f5 04 	. . . 
	dec bc			;4d2b	0b 	. 
	ld (hl),000h		;4d2c	36 00 	6 . 
	ldir		;4d2e	ed b0 	. . 
l4d30h:
	call CLEAR_SCREEN		;4d30	cd 27 42 	. ' B 
    
    ; Skip drawing scores and waiting if we're at the title screen
	ld a,(GAME_STATE)		;4d33	3a 0b e0
	or a			        ;4d36	b7
	jp z,l4d46h		        ;4d37	ca 46 4d
	
    call DRAW_UP_SCORES		;4d3a	cd e0 4f 	. . O 
    ; Write "ROUND 1"
	call DRAW_ROUND_MESSAGE		;4d3d	cd 01 51 	. . Q 

    ; Wait 48 ticks
	ld hl, 48		        ;4d40	21 30 00
	call DELAY_HL_TICKS		;4d43	cd 80 43
l4d46h:
	ld a,001h		;4d46	3e 01 	> . 
	ld (0e00ah),a		;4d48	32 0a e0 	2 . . 

    ; Fill pattern table (1/3)
	ld hl,l7d84h		    ;4d4b	21 84 7d
	ld de, 0 * 8*32*24/3	;4d4e	11 00 00
	call LDIRVM_32x24_THIRD	;4d51	cd 20 42

	; Fill pattern table (21/3)
    ld hl,l7d84h		    ;4d54	21 84 7d
	ld de, 1 * 8*32*24/3	;4d57	11 00 08
	call LDIRVM_32x24_THIRD	;4d5a	cd 20 42

	; Fill pattern table (3/3)
    ld hl,l7d84h		        ;4d5d	21 84 7d
	ld de, 2 * 8*32*24/3		;4d60	11 00 10
	call LDIRVM_32x24_THIRD		;4d63	cd 20 42

	ld de,l8584h		;4d66	11 84 85 	. . . 
	ld hl,02000h		;4d69	21 00 20 	! .   
	call sub_4389h		;4d6c	cd 89 43 	. . C 

	ld de,l8584h		;4d6f	11 84 85 	. . . 
	ld hl,02800h		;4d72	21 00 28 	! . ( 
	call sub_4389h		;4d75	cd 89 43 	. . C 

	ld de,l8584h		;4d78	11 84 85 	. . . 
	ld hl,03000h		;4d7b	21 00 30 	! . 0 
	call sub_4389h		;4d7e	cd 89 43 	. . C 

	ld hl,01800h		;4d81	21 00 18 	! . . 
	ld a,000h		;4d84	3e 00 	> . 
	ld bc,00300h		;4d86	01 00 03 	. . . 
	call FILVRM		;4d89	cd 56 00 	. V . 

    ; Draw score numbers on the right
	ld a, 1 		            ;4d8c	3e 01
	ld (SCORE_POSITION),a       ;4d8e	32 44 e5
	call DRAW_SCORE_NUMBERS		;4d91	cd b9 53

    ; Write "HIGH"
	ld hl,HIGH_LETTERS		    ;4d94	21 1f 55
	ld de,01839h		        ;4d97	11 39 18
	ld bc,00004h		        ;4d9a	01 04 00
	call LDIRVM		            ;4d9d	cd 5c 00

    ; Write "SCORE"
	ld hl,SCORE_LETTERS		    ;4da0	21 23 55
	ld de,0185bh		        ;4da3	11 5b 18
	ld bc,00005h		        ;4da6	01 05 00
	call LDIRVM		            ;4da9	cd 5c 00

    ; Write "SCORE"
    ; It uses a duplicated string: it could have used the same SCORE_LETTERS!
	ld hl, SCORE_LETTERS_DUP		;4dac	21 28 55
	ld de,018dbh		            ;4daf	11 db 18
	ld bc,00005h		            ;4db2	01 05 00
	call LDIRVM		                ;4db5	cd 5c 00

    ; Draw the game's frame
	call DRAW_FRAME		            ;4db8	cd 30 52

    ; Draw a trailing "0" in the HIGH SCORE
	ld hl,0187fh    ;4dbb	21 7f 18
	ld a, "0"		;4dbe	3e 30
	call WRTVRM		;4dc0	cd 4d 00

	; Draw a trailing "0" in the SCORE
    ld hl,018ffh	;4dc3	21 ff 18
	ld a,030h		;4dc6	3e 30
	call WRTVRM		;4dc8	cd 4d 00

	ld a,000h		;4dcb	3e 00 	> . 
	ld (0e56fh),a		;4dcd	32 6f e5 	2 o . 
	ld b,017h		;4dd0	06 17 	. . 
	ld iy,01822h		;4dd2	fd 21 22 18 	. ! " . 
l4dd6h:
	ld e,a			;4dd6	5f 	_ 
	sla e		;4dd7	cb 23 	. # 
	ld d,000h		;4dd9	16 00 	. . 
	ld hl,l57b5h		;4ddb	21 b5 57 	! . W 
	add hl,de			;4dde	19 	. 
	ld e,(hl)			;4ddf	5e 	^ 
	inc hl			;4de0	23 	# 
	ld d,(hl)			;4de1	56 	V 
	ex de,hl			;4de2	eb 	. 
	push iy		;4de3	fd e5 	. . 
	pop de			;4de5	d1 	. 
	push bc			;4de6	c5 	. 
	ld bc,00016h		;4de7	01 16 00 	. . . 
	call LDIRVM		;4dea	cd 5c 00 	. \ . 
	ld a,(0e56fh)		;4ded	3a 6f e5 	: o . 
	inc a			;4df0	3c 	< 
	cp 004h		;4df1	fe 04 	. . 
	jr nz,l4df7h		;4df3	20 02 	  . 
	ld a,000h		;4df5	3e 00 	> . 
l4df7h:
	ld (0e56fh),a		;4df7	32 6f e5 	2 o . 
	ld de,00020h		;4dfa	11 20 00 	.   . 
	add iy,de		;4dfd	fd 19 	. . 
	pop bc			;4dff	c1 	. 
	djnz l4dd6h		;4e00	10 d4 	. . 
	ld b,003h		;4e02	06 03 	. . 
	ld iy,00380h		;4e04	fd 21 80 03 	. ! . . 
l4e08h:
	ld hl,l5735h		;4e08	21 35 57 	! 5 W 
	ld a,(LEVEL)		;4e0b	3a 1b e0 	: . . 
	cp FINAL_LEVEL		;4e0e	fe 20 	.   
	jp z,l4e22h		;4e10	ca 22 4e 	. " N 
	and 003h		;4e13	e6 03 	. . 
	ld e,a			;4e15	5f 	_ 
	ld d,000h		;4e16	16 00 	. . 
	sla e		;4e18	cb 23 	. # 
	ld hl,0x552d		;4e1a	21 2d 55 	! - U 
	add hl,de			;4e1d	19 	. 
	ld e,(hl)			;4e1e	5e 	^ 
	inc hl			;4e1f	23 	# 
	ld d,(hl)			;4e20	56 	V 
	ex de,hl			;4e21	eb 	. 
l4e22h:
	push iy		;4e22	fd e5 	. . 
	pop de			;4e24	d1 	. 
	push bc			;4e25	c5 	. 
	ld bc,00080h		;4e26	01 80 00 	. . . 
	call LDIRVM		;4e29	cd 5c 00 	. \ . 
	pop bc			;4e2c	c1 	. 
	ld de,00800h		;4e2d	11 00 08 	. . . 
	add iy,de		;4e30	fd 19 	. . 
	djnz l4e08h		;4e32	10 d4 	. . 
    
    ; Draw the background
	call DRAW_BACKGROUND		;4e34	cd bd 5b

    call WRITE_ROUND_MSG		;4e37	cd 04 72 	. . r 
	call DRAW_LIVES		;4e3a	cd b9 71 	. . q 
	ld a,(LEVEL)		;4e3d	3a 1b e0 	: . . 
	cp FINAL_LEVEL		;4e40	fe 20
	jp z,l4e71h		;4e42	ca 71 4e 	. q N 
	ld hl,l5defh		;4e45	21 ef 5d 	! . ] 

    ; Skip the following if we're not doing a full brick repaint
	ld a,(BRICK_REPAINT_TYPE)	;4e48	3a 22 e0
	cp 2		                ;4e4b	fe 02
	jp z,l4e65h		            ;4e4d	ca 65 4e
    
	ld a,(LEVEL)		;4e50	3a 1b e0 	: . . 
	ld e,a			;4e53	5f 	_ 
	sla e		;4e54	cb 23 	. # 
	ld d,000h		;4e56	16 00 	. . 
	add hl,de			;4e58	19 	. 
	ld e,(hl)			;4e59	5e 	^ 
	inc hl			;4e5a	23 	# 
	ld d,(hl)			;4e5b	56 	V 
	ex de,hl			;4e5c	eb 	. 
	ld de,0e027h		;4e5d	11 27 e0 	. ' . 
	ld bc,00011h		;4e60	01 11 00 	. . . 
	ldir		;4e63	ed b0 	. . 
l4e65h:
	call sub_5c15h		;4e65	cd 15 5c 	. . \ 
	call sub_5d79h		;4e68	cd 79 5d 	. y ] 
	call sub_5165h		;4e6b	cd 65 51 	. e Q 
	jp l4e74h		;4e6e	c3 74 4e 	. t N 
l4e71h:
	call sub_5180h		;4e71	cd 80 51 	. . Q 
l4e74h:
    ; Full brick repaint
	xor a			                ;4e74	af
	ld (BRICK_REPAINT_TYPE),a		;4e75	32 22 e0

    ; Vaus and the READY string as sprites
	ld hl,VAUS_AND_READY_SPRITE_TABLE		;4e78	21 49 51
	ld de,SPRITES_ATTRIB_TABLE		        ;4e7b	11 00 1b
	ld bc, 7 * 4		                    ;4e7e	01 1c 00 	7 sprites
	call LDIRVM		                        ;4e81	cd 5c 00
    
    ; Skip the following if we're at the title screen
	ld a,(GAME_STATE)		;4e84	3a 0b e0
	or a			        ;4e87	b7
	jp z,l4eb4h		        ;4e88	ca b4 4e
	
    ld a,(LEVEL)		;4e8b	3a 1b e0
	cp FINAL_LEVEL		;4e8e	fe 20
	jp z,l4ea5h		;4e90	ca a5 4e 	. . N 
	ld a,SOUND_LEVEL_START		;4e93	3e c4 	> . 
	ld (SOUND_NUMBER),a		;4e95	32 c0 e5 	2 . . 
	call PLAY_SOUND		;4e98	cd e8 b4 	. . . 

    ; Wait 144 ticks
	ei			            ;4e9b	fb
	ld hl, 144		        ;4e9c	21 90 00
	call DELAY_HL_TICKS		;4e9f	cd 80 43
	jp l4eb4h		        ;4ea2	c3 b4 4e
l4ea5h:
	ld a,SOUND_DOH_APPEARS		;4ea5	3e c8 	> . 
	ld (SOUND_NUMBER),a		;4ea7	32 c0 e5 	2 . . 
	call PLAY_SOUND		;4eaa	cd e8 b4 	. . . 

    ; Wait 256 ticks
	ei			            ;4ead	fb
	ld hl,256   		    ;4eae	21 00 01
	call DELAY_HL_TICKS		;4eb1	cd 80 43
l4eb4h:
    ; Set ball active
	ld a,001h		                                ;4eb4	3e 01
	ld (BALL_TABLE1 + BALL_TABLE_IDX_ACTIVE),a		;4eb6	32 4e e2

	ld a,068h		;4eb9	3e 68 	> h 
	ld (0e0f6h),a		;4ebb	32 f6 e0 	2 . . 
	ld hl,00000h		;4ebe	21 00 00 	! . . 
	ld (0e00dh),hl		;4ec1	22 0d e0 	" . . 
	ld (0e00fh),hl		;4ec4	22 0f e0 	" . . 
	ld (0e011h),hl		;4ec7	22 11 e0 	" . . 
	ld (0e013h),hl		;4eca	22 13 e0 	" . . 
	ld a,000h		;4ecd	3e 00 	> . 
	ld (SOUND_NUMBER),a		;4ecf	32 c0 e5 	2 . . 
	call PLAY_SOUND		;4ed2	cd e8 b4 	. . . 

    ; Wait 1 tick
	ei			            ;4ed5	fb
	ld hl, 1    		    ;4ed6	21 01 00
	call DELAY_HL_TICKS		;4ed9	cd 80 43
	ret			            ;4edc	c9

l4eddh:
	ld iy,STORY_STR		;4edd	fd 21 05 50 	. ! . P 
	ld ix,l50efh		;4ee1	dd 21 ef 50 	. ! . P 
	ld a,(0e00ch)		;4ee5	3a 0c e0 	: . . 
	or a			;4ee8	b7 	. 
	jp z,l4ef7h		;4ee9	ca f7 4e 	. . N 
	ld a,(0e0c5h)		;4eec	3a c5 e0 	: . . 
	bit 1,a		;4eef	cb 4f 	. O 
	jp nz,l4f6bh		;4ef1	c2 6b 4f 	. k O 
	jp l4effh		;4ef4	c3 ff 4e 	. . N 
l4ef7h:
	ld a,(0e0bfh)		;4ef7	3a bf e0 	: . . 
	bit 4,a		;4efa	cb 67 	. g 
	jp nz,l4f6bh		;4efc	c2 6b 4f 	. k O 
l4effh:
	ld hl,0e013h		;4eff	21 13 e0 	! . . 
	ld a,(hl)			;4f02	7e 	~ 
	or a			;4f03	b7 	. 
	jp nz,l4f60h		;4f04	c2 60 4f 	. ` O 
	ld hl,0e00eh		;4f07	21 0e e0 	! . . 
	inc (hl)			;4f0a	34 	4 
	ld a,(hl)			;4f0b	7e 	~ 
	cp 002h		;4f0c	fe 02 	. . 
	ret nz			;4f0e	c0 	. 
	ld (hl),000h		;4f0f	36 00 	6 . 
	ld a,(0e00fh)		;4f11	3a 0f e0 	: . . 
	ld e,a			;4f14	5f 	_ 
	sla e		;4f15	cb 23 	. # 
	ld d,000h		;4f17	16 00 	. . 
	add ix,de		;4f19	dd 19 	. . 
	ld e,(ix+000h)		;4f1b	dd 5e 00 	. ^ . 
	ld d,(ix+001h)		;4f1e	dd 56 01 	. V . 
	ex de,hl			;4f21	eb 	. 
	ld a,(0e010h)		;4f22	3a 10 e0 	: . . 
	ld e,a			;4f25	5f 	_ 
	ld d,000h		;4f26	16 00 	. . 
	add hl,de			;4f28	19 	. 
	ld a,(0e011h)		;4f29	3a 11 e0 	: . . 
	ld e,a			;4f2c	5f 	_ 
	ld d,000h		;4f2d	16 00 	. . 
	add iy,de		;4f2f	fd 19 	. . 
	ld a,(iy+000h)		;4f31	fd 7e 00 	. ~ . 
	cp 020h		;4f34	fe 20 	.   
	jp z,l4f3ch		;4f36	ca 3c 4f 	. < O 
	call WRTVRM		;4f39	cd 4d 00 	. M . 
l4f3ch:
	ld hl,0e011h		;4f3c	21 11 e0 	! . . 
	inc (hl)			;4f3f	34 	4 
	ld hl,0e010h		;4f40	21 10 e0 	! . . 
	inc (hl)			;4f43	34 	4 
l4f44h:
	ld hl,0e012h		;4f44	21 12 e0 	! . . 
	inc (hl)			;4f47	34 	4 
	ld a,(hl)			;4f48	7e 	~ 
	cp 01ah		;4f49	fe 1a 	. . 
	ret nz			;4f4b	c0 	. 
	ld (hl),000h		;4f4c	36 00 	6 . 
	xor a			;4f4e	af 	. 
	ld (0e010h),a		;4f4f	32 10 e0 	2 . . 
	ld hl,0e00fh		;4f52	21 0f e0 	! . . 
	inc (hl)			;4f55	34 	4 
	ld a,(hl)			;4f56	7e 	~ 
	cp 009h		;4f57	fe 09 	. . 
	ret nz			;4f59	c0 	. 
	ld hl,0e013h		;4f5a	21 13 e0 	! . . 
	ld (hl),001h		;4f5d	36 01 	6 . 
	ret			;4f5f	c9 	. 
l4f60h:
	ld hl,0e014h		;4f60	21 14 e0 	! . . 
	inc (hl)			;4f63	34 	4 
	ld a,(hl)			;4f64	7e 	~ 
	cp 078h		;4f65	fe 78 	. x 
	ret nz			;4f67	c0 	. 
	jp l4f7ah		;4f68	c3 7a 4f 	. z O 
l4f6bh:
	ld hl,00000h		;4f6b	21 00 00 	! . . 
	ld (0e53ch),hl		;4f6e	22 3c e5 	" < . 
	ld (VAUS_X2),hl		;4f71	22 3e e5 	" > . 
	ld (0e540h),hl		;4f74	22 40 e5 	" @ . 
	ld (0e542h),hl		;4f77	22 42 e5 	" B . 
l4f7ah:
	ld hl,00000h		;4f7a	21 00 00 	! . . 
	ld (0e00dh),hl		;4f7d	22 0d e0 	" . . 
	ld (0e00fh),hl		;4f80	22 0f e0 	" . . 
	ld (0e011h),hl		;4f83	22 11 e0 	" . . 
	ld (0e013h),hl		;4f86	22 13 e0 	" . . 
	ret			;4f89	c9 	. 

ENDING_TEXT_ANIMATION:
	call CLEAR_SCREEN		;4f8a	cd 27 42 	. ' B 
	xor a			;4f8d	af 	. 
	ld (0e53ch),a		;4f8e	32 3c e5 	2 < . 
l4f91h:
	push ix		;4f91	dd e5 	. . 
	xor a			;4f93	af 	. 
	ld (0e53dh),a		;4f94	32 3d e5 	2 = . 
	ld a,(0e53ch)		;4f97	3a 3c e5 	: < . 
	ld e,a			;4f9a	5f 	_ 
	sla e		;4f9b	cb 23 	. # 
	ld d,000h		;4f9d	16 00 	. . 
	add ix,de		;4f9f	dd 19 	. . 
	ld e,(ix+000h)		;4fa1	dd 5e 00 	. ^ . 
	ld d,(ix+001h)		;4fa4	dd 56 01 	. V . 
	ex de,hl			;4fa7	eb 	. 
l4fa8h:
	ld a,(iy+000h)		;4fa8	fd 7e 00 	. ~ . 
	cp 020h		;4fab	fe 20 	.   
	jp z,l4fbbh		;4fad	ca bb 4f 	. . O 
	push hl			;4fb0	e5 	. 
	call WRTVRM		;4fb1	cd 4d 00 	. M . 

    ; Wait 3 ticks
	ld hl,00003h		    ;4fb4	21 03 00
	call DELAY_HL_TICKS		;4fb7	cd 80 43

	pop hl			        ;4fba	e1
l4fbbh:
	inc hl			;4fbb	23 	# 
	inc iy		;4fbc	fd 23 	. # 
	ld a,(0e53dh)		;4fbe	3a 3d e5 	: = . 
	inc a			;4fc1	3c 	< 
	cp 01ah		;4fc2	fe 1a 	. . 
	ld (0e53dh),a		;4fc4	32 3d e5 	2 = . 
	jp nz,l4fa8h		;4fc7	c2 a8 4f 	. . O 
	pop ix		;4fca	dd e1 	. . 
	ld hl,0e53ch		;4fcc	21 3c e5 	! < . 
	inc (hl)			;4fcf	34 	4 
	ld a,(hl)			;4fd0	7e 	~ 
	cp 009h		;4fd1	fe 09 	. . 
	jp nz,l4f91h		;4fd3	c2 91 4f 	. . O 

    ; Wait 1472 ticks
	ld hl, 1472		        ;4fd6	21 c0 05
	call DELAY_HL_TICKS		;4fd9	cd 80 43

	call CLEAR_SCREEN		;4fdc	cd 27 42 	. ' B 
	ret			;4fdf	c9 	. 

DRAW_UP_SCORES:
    ; Draw "SCORE    HIGH SCORE" at the top of the screen
	ld hl,SCORE_HI_SCORE_STR		;4fe0	21 9e 54
	ld de,01800h		;4fe3	11 00 18 Locate at [0, 0]
	ld bc, 21   		;4fe6	01 15 00
	call LDIRVM		    ;4fe9	cd 5c 00

	; Write "0" below "SCORE"
    ld hl, 0x1800 + 7 + 1*32		;4fec	21 27 18  Locate at [7, 1]
	ld a, '0'		                ;4fef	3e 30
	call WRTVRM		                ;4ff1	cd 4d 00
    
    ; Write "0" below "HIGH SCORE"
	ld hl, 0x1800 + 18 + 1*32		;4ff4	21 32 18  Locate at [18, 1]
	ld a, '0'		                ;4ff7	3e 30
	call WRTVRM		                ;4ff9	cd 4d 00
    
    ; Draw score up
	ld a, 0		                    ;4ffc	3e 00
	ld (SCORE_POSITION),a		    ;4ffe	32 44 e5

    ; Write the score number.
    ; For example, "160    50000"
	call DRAW_SCORE_NUMBERS		    ;5001	cd b9 53
	ret			                    ;5004	c9

STORY_STR:
    db "THE ERA AND TIME OF       THIS STORY IS UNKNOWN.    AFTER THE MOTHERSHIP      \"ARKANOID\" WAS DESTROYED, A SPACECRAFT \"VAUS\"       SCRAMBLED AWAY FROM IT.   BUT ONLY TO BE            TRAPPED IN SPACE WARPED   BY SOMEONE......          "

l50efh:
	ld b,e			;50ef	43 	C 
l50f0h:
	jr 0x5075		;50f0	18 83 	. . 
	jr 0x50d7		;50f2	18 e3 	. . 
l50f4h:
	jr l5119h		;50f4	18 23 	. # 
	add hl,de			;50f6	19 	. 
	ld h,e			;50f7	63 	c 
	add hl,de			;50f8	19 	. 
	and e			;50f9	a3 	. 
	add hl,de			;50fa	19 	. 
	inc bc			;50fb	03 	. 
	ld a,(de)			;50fc	1a 	. 
	ld b,e			;50fd	43 	C 
	ld a,(de)			;50fe	1a 	. 
l50ffh:
	add a,e			;50ff	83 	. 
	ld a,(de)			;5100	1a 	. 

; Draws the "ROUND x" message
DRAW_ROUND_MESSAGE:
    ; Write "ROUND "
	ld hl,l5144h		;5101	21 44 51
	ld de,0194ch		;5104	11 4c 19
	ld bc,00005h		;5107	01 05 00
	call LDIRVM		    ;510a	cd 5c 00
l510dh:
	ld a,(LEVEL_DISP)		;510d	3a 1c e0
	add a,001h		        ;5110	c6 01
	daa			            ;5112	27
	ld e,a			        ;5113	5f
	push de			        ;5114	d5
	srl a		            ;5115	cb 3f
	srl a		;5117	cb 3f 	. ? 
l5119h:
	srl a		;5119	cb 3f 	. ? 
	srl a		;511b	cb 3f 	. ? 
	add a,030h		;511d	c6 30 	. 0 
	cp 030h		;511f	fe 30 	. 0 
	jp nz,l5131h		;5121	c2 31 51 	. 1 Q 
l5124h:
	pop de			;5124	d1 	. 
	ld a,e			;5125	7b 	{ 
	and 00fh		;5126	e6 0f 	. . 
	add a,030h		;5128	c6 30 	. 0 
	ld hl,01952h		;512a	21 52 19 	! R . 
	call WRTVRM		;512d	cd 4d 00 	. M . 
	ret			;5130	c9 	. 
l5131h:
	ld hl,01952h		;5131	21 52 19 	! R . 
	call WRTVRM		;5134	cd 4d 00 	. M . 
	pop de			;5137	d1 	. 
	ld a,e			;5138	7b 	{ 
	and 00fh		;5139	e6 0f 	. . 
	add a,030h		;513b	c6 30 	. 0 
	ld hl,01953h		;513d	21 53 19 	! S . 
	call WRTVRM		;5140	cd 4d 00 	. M . 
	ret			;5143	c9 	. 

l5144h:
	ld d,d			;5144	52 	R 
	ld c,a			;5145	4f 	O 
	ld d,l			;5146	55 	U 
	ld c,(hl)			;5147	4e 	N 
	ld b,h			;5148	44 	D 


; Table with the Vaus sprite and sprites to write "READY"
VAUS_AND_READY_SPRITE_TABLE:
    ; V H P (EC, 0, 0, 0, C)

    ; Vaus
    db 0xae, 0x50, 0x08, 0x08
    db 0xae, 0x60, 0x04, 0x0e
    db 0xae, 0x70, 0x0c, 0x08
    db 0xae, 0x80, 0x01, 0x00

    ; READY
    db 0x80, 0x54, 0x64, 0x0f; "RE"
    db 0x80, 0x64, 0x68, 0x0f; "AD"
    db 0x80, 0x74, 0x6c, 0x0f; "Y "
    
sub_5165h:
	ld a,(LEVEL)		;5165	3a 1b e0 	: . . 
	and 003h		;5168	e6 03 	. . 
	ld l,a			;516a	6f 	o 
	ld h,000h		;516b	26 00 	& . 
	add hl,hl			;516d	29 	) 
	ld de,l5815h		;516e	11 15 58 	. . X 
	add hl,de			;5171	19 	. 
	ld e,(hl)			;5172	5e 	^ 
	inc hl			;5173	23 	# 
	ld d,(hl)			;5174	56 	V 
	ex de,hl			;5175	eb 	. 
	ld de,03e00h		;5176	11 00 3e 	. . > 
	ld bc,00100h		;5179	01 00 01 	. . . 
	call LDIRVM		;517c	cd 5c 00 	. \ . 
	ret			;517f	c9 	. 
sub_5180h:
	ld a,000h		;5180	3e 00 	> . 
	ld (0e56fh),a		;5182	32 6f e5 	2 o . 
	ld b,00ch		;5185	06 0c 	. . 
	ld iy,01869h		;5187	fd 21 69 18 	. ! i . 
l518bh:
	ld e,a			;518b	5f 	_ 
	sla e		;518c	cb 23 	. # 
	ld d,000h		;518e	16 00 	. . 
	ld hl,l51b8h		;5190	21 b8 51 	! . Q 
	add hl,de			;5193	19 	. 
	ld e,(hl)			;5194	5e 	^ 
	inc hl			;5195	23 	# 
	ld d,(hl)			;5196	56 	V 
	ex de,hl			;5197	eb 	. 
	push iy		;5198	fd e5 	. . 
	pop de			;519a	d1 	. 
	push bc			;519b	c5 	. 
	ld bc,00008h		;519c	01 08 00 	. . . 
	call LDIRVM		;519f	cd 5c 00 	. \ . 
	ld a,(0e56fh)		;51a2	3a 6f e5 	: o . 
	inc a			;51a5	3c 	< 
	cp 00ch		;51a6	fe 0c 	. . 
	jr nz,l51ach		;51a8	20 02 	  . 
	ld a,000h		;51aa	3e 00 	> . 
l51ach:
	ld (0e56fh),a		;51ac	32 6f e5 	2 o . 
	ld de,00020h		;51af	11 20 00 	.   . 
	add iy,de		;51b2	fd 19 	. . 
	pop bc			;51b4	c1 	. 
	djnz l518bh		;51b5	10 d4 	. . 
	ret			;51b7	c9 	. 
l51b8h:
	ret nc			;51b8	d0 	. 
	ld d,c			;51b9	51 	Q 
	ret c			;51ba	d8 	. 
	ld d,c			;51bb	51 	Q 
	ret po			;51bc	e0 	. 
	ld d,c			;51bd	51 	Q 
	ret pe			;51be	e8 	. 
	ld d,c			;51bf	51 	Q 
	ret p			;51c0	f0 	. 
	ld d,c			;51c1	51 	Q 
	ret m			;51c2	f8 	. 
	ld d,c			;51c3	51 	Q 
	nop			;51c4	00 	. 
	ld d,d			;51c5	52 	R 
	ex af,af'			;51c6	08 	. 
	ld d,d			;51c7	52 	R 
	djnz $+84		;51c8	10 52 	. R 
	jr $+84		;51ca	18 52 	. R 
	jr nz,l5220h		;51cc	20 52 	  R 
	jr z,l5222h		;51ce	28 52 	( R 
	sub b			;51d0	90 	. 
	sub c			;51d1	91 	. 
	sub d			;51d2	92 	. 
	sub e			;51d3	93 	. 
	sub h			;51d4	94 	. 
	sub l			;51d5	95 	. 
	sub (hl)			;51d6	96 	. 
	sub a			;51d7	97 	. 
	sbc a,b			;51d8	98 	. 
	sbc a,c			;51d9	99 	. 
	sbc a,d			;51da	9a 	. 
	sbc a,e			;51db	9b 	. 
	sbc a,h			;51dc	9c 	. 
	sbc a,l			;51dd	9d 	. 
	sbc a,(hl)			;51de	9e 	. 
	sbc a,a			;51df	9f 	. 
	and b			;51e0	a0 	. 
	and c			;51e1	a1 	. 
	and d			;51e2	a2 	. 
	and e			;51e3	a3 	. 
	and h			;51e4	a4 	. 
	and l			;51e5	a5 	. 
	and (hl)			;51e6	a6 	. 
	and a			;51e7	a7 	. 
	xor b			;51e8	a8 	. 
	xor c			;51e9	a9 	. 
	xor d			;51ea	aa 	. 
	xor e			;51eb	ab 	. 
	xor h			;51ec	ac 	. 
	xor l			;51ed	ad 	. 
	xor (hl)			;51ee	ae 	. 
	xor a			;51ef	af 	. 
	or b			;51f0	b0 	. 
	or c			;51f1	b1 	. 
	or d			;51f2	b2 	. 
	or e			;51f3	b3 	. 
	or h			;51f4	b4 	. 
	or l			;51f5	b5 	. 
	or (hl)			;51f6	b6 	. 
	or a			;51f7	b7 	. 
	cp b			;51f8	b8 	. 
	cp c			;51f9	b9 	. 
	cp d			;51fa	ba 	. 
	cp e			;51fb	bb 	. 
	cp h			;51fc	bc 	. 
	cp l			;51fd	bd 	. 
	cp (hl)			;51fe	be 	. 
	cp a			;51ff	bf 	. 
	ret nz			;5200	c0 	. 
	pop bc			;5201	c1 	. 
	jp nz,0c4c3h		;5202	c2 c3 c4 	. . . 
	push bc			;5205	c5 	. 
	add a,0c7h		;5206	c6 c7 	. . 
	ret z			;5208	c8 	. 
	ret			;5209	c9 	. 
	jp z,0cccbh		;520a	ca cb cc 	. . . 
	call 0cfceh		;520d	cd ce cf 	. . . 
	ret nc			;5210	d0 	. 
	pop de			;5211	d1 	. 
	jp nc,0d4d3h		;5212	d2 d3 d4 	. . . 
	push de			;5215	d5 	. 
	sub 0d7h		;5216	d6 d7 	. . 
	ret c			;5218	d8 	. 
	exx			;5219	d9 	. 
	jp c,0dcdbh		;521a	da db dc 	. . . 
	defb 0ddh,0deh,0dfh	;illegal sequence		;521d	dd de df 	. . . 
l5220h:
	ret po			;5220	e0 	. 
	pop hl			;5221	e1 	. 
l5222h:
	jp po,0e4e3h		;5222	e2 e3 e4 	. . . 
	push hl			;5225	e5 	. 
	and 0e7h		;5226	e6 e7 	. . 
	ret pe			;5228	e8 	. 
	jp (hl)			;5229	e9 	. 
	jp pe,0ecebh		;522a	ea eb ec 	. . . 
	defb 0edh;next byte illegal after ed		;522d	ed 	. 
	xor 0efh		;522e	ee ef 	. . 

; Draw the game's frame
DRAW_FRAME:
	ld hl,l5271h		;5230	21 71 52 	! q R 
	ld bc,00018h		;5233	01 18 00 	. . . 
	ld de,01801h		;5236	11 01 18 	. . . 
	call LDIRVM		;5239	cd 5c 00 	. \ . 
	ld b,017h		;523c	06 17 	. . 
	ld de,00020h		;523e	11 20 00 	.   . 
l5241h:
	ld hl,01821h		;5241	21 21 18 	! ! . 
	ld ix,l5289h		;5244	dd 21 89 52 	. ! . R 
	ld a,(ix+000h)		;5248	dd 7e 00 	. ~ . 
l524bh:
	call WRTVRM		;524b	cd 4d 00 	. M . 
	add hl,de			;524e	19 	. 
	inc ix		;524f	dd 23 	. # 
	ld a,(ix+000h)		;5251	dd 7e 00 	. ~ . 
	djnz l524bh		;5254	10 f5 	. . 
	ld b,017h		;5256	06 17 	. . 
	ld de,00020h		;5258	11 20 00 	.   . 
	ld hl,01838h		;525b	21 38 18 	! 8 . 
	ld ix,l5289h		;525e	dd 21 89 52 	. ! . R 
	ld a,(ix+000h)		;5262	dd 7e 00 	. ~ . 
l5265h:
	call WRTVRM		;5265	cd 4d 00 	. M . 
	add hl,de			;5268	19 	. 
	inc ix		;5269	dd 23 	. # 
	ld a,(ix+000h)		;526b	dd 7e 00 	. ~ . 
	djnz l5265h		;526e	10 f5 	. . 
	ret			;5270	c9 	. 

l5271h:
	ld (bc),a			;5271	02 	. 
	inc c			;5272	0c 	. 
	inc c			;5273	0c 	. 
	inc c			;5274	0c 	. 
	ex af,af'			;5275	08 	. 
	add hl,bc			;5276	09 	. 
	ld a,(bc)			;5277	0a 	. 
	dec bc			;5278	0b 	. 
	inc c			;5279	0c 	. 
	inc c			;527a	0c 	. 
	inc c			;527b	0c 	. 
	inc c			;527c	0c 	. 
	inc c			;527d	0c 	. 
	inc c			;527e	0c 	. 
	inc c			;527f	0c 	. 
	inc c			;5280	0c 	. 
	ex af,af'			;5281	08 	. 
	add hl,bc			;5282	09 	. 
	ld a,(bc)			;5283	0a 	. 
	dec bc			;5284	0b 	. 
	inc c			;5285	0c 	. 
	inc c			;5286	0c 	. 
	inc c			;5287	0c 	. 
	dec c			;5288	0d 	. 
l5289h:
	inc bc			;5289	03 	. 
	inc b			;528a	04 	. 
	dec b			;528b	05 	. 
	ld b,007h		;528c	06 07 	. . 
	inc bc			;528e	03 	. 
	inc b			;528f	04 	. 
	dec b			;5290	05 	. 
	ld b,007h		;5291	06 07 	. . 
	inc bc			;5293	03 	. 
	inc b			;5294	04 	. 
	dec b			;5295	05 	. 
	ld b,007h		;5296	06 07 	. . 
	inc bc			;5298	03 	. 
	inc b			;5299	04 	. 
	dec b			;529a	05 	. 
	ld b,007h		;529b	06 07 	. . 
	inc bc			;529d	03 	. 
	inc b			;529e	04 	. 
	dec b			;529f	05 	. 

sub_52a0h:
	push hl			;52a0	e5 	. 
	push bc			;52a1	c5 	. 
	push de			;52a2	d5 	. 
	push af			;52a3	f5 	. 
	push ix		;52a4	dd e5 	. . 
	push iy		;52a6	fd e5 	. . 
	ld hl,00000h		;52a8	21 00 00 	! . . 
	ld e,a			;52ab	5f 	_ 
	ld d,000h		;52ac	16 00 	. . 
	add hl,de			;52ae	19 	. 
	add hl,de			;52af	19 	. 
	add hl,de			;52b0	19 	. 
	ld de,l5363h		;52b1	11 63 53 	. c S 
	add hl,de			;52b4	19 	. 
	push hl			;52b5	e5 	. 
	pop ix		;52b6	dd e1 	. . 
    
	; Jump if we're at the title screen
    ld a,(GAME_STATE)		;52b8	3a 0b e0
	cp 0		            ;52bb	fe 00
	jp z,l5310h		        ;52bd	ca 10 53
	
    ; Jump if we're at state "normal play, but without score updates"
    ; [ToDo]: what is this state? The final Boss Doh?
    cp 3		            ;52c0	fe 03
	jp z,l52ceh		        ;52c2	ca ce 52
	
    ld hl,SCORE_BCD		;52c5	21 15 e0 	! . . 
	call BCD_ENCODE_SCORE		;52c8	cd 8a 53 	. . S 
	jp l52d7h		;52cb	c3 d7 52 	. . R 
l52ceh:
	ld hl,ZEROS_BCD_BUFFER		;52ce	21 18 e0 	! . . 
	call BCD_ENCODE_SCORE		;52d1	cd 8a 53 	. . S 
	jp l52d7h		;52d4	c3 d7 52 	. . R 
l52d7h:
	ld iy,HIGH_SCORE_BCD		;52d7	fd 21 07 e0 	. ! . . 
	ld a,(SCORE_BCD_BUFFER + 2)		;52db	3a a2 e5 	: . . 
	cp (iy+002h)		;52de	fd be 02 	. . . 
	jp z,l52eah		;52e1	ca ea 52 	. . R 
	jp c,l530dh		;52e4	da 0d 53 	. . S 
	jp l5302h		;52e7	c3 02 53 	. . S 
l52eah:
	ld a,(SCORE_BCD_BUFFER + 1)		;52ea	3a a1 e5 	: . . 
	cp (iy+001h)		;52ed	fd be 01 	. . . 
	jp z,l52f9h		;52f0	ca f9 52 	. . R 
	jp c,l530dh		;52f3	da 0d 53 	. . S 
	jp l5302h		;52f6	c3 02 53 	. . S 
l52f9h:
	ld a,(SCORE_BCD_BUFFER)		;52f9	3a a0 e5 	: . . 
	cp (iy+000h)		;52fc	fd be 00 	. . . 
	jp c,l530dh		;52ff	da 0d 53 	. . S 
l5302h:
	ld de,HIGH_SCORE_BCD		;5302	11 07 e0 	. . . 
	ld hl,SCORE_BCD_BUFFER		;5305	21 a0 e5 	! . . 
	ld bc,00003h		;5308	01 03 00 	. . . 
	ldir		;530b	ed b0 	. . 
l530dh:
	call sub_5319h		;530d	cd 19 53 	. . S 
l5310h:
	pop iy		;5310	fd e1 	. . 
	pop ix		;5312	dd e1 	. . 
	pop af			;5314	f1 	. 
	pop de			;5315	d1 	. 
	pop bc			;5316	c1 	. 
	pop hl			;5317	e1 	. 
	ret			;5318	c9 	. 
sub_5319h:
	ld hl,0e017h		;5319	21 17 e0 	! . . 
	ld a,(0e020h)		;531c	3a 20 e0 	:   . 
	cp (hl)			;531f	be 	. 
	jp c,l5336h		;5320	da 36 53 	. 6 S 
	ret nz			;5323	c0 	. 
	dec hl			;5324	2b 	+ 
	ld a,(0e01fh)		;5325	3a 1f e0 	: . . 
	cp (hl)			;5328	be 	. 
	jp c,l5336h		;5329	da 36 53 	. 6 S 
	ret nz			;532c	c0 	. 
	dec hl			;532d	2b 	+ 
	ld a,(0e01eh)		;532e	3a 1e e0 	: . . 
	cp (hl)			;5331	be 	. 
	jp c,l5336h		;5332	da 36 53 	. 6 S 
	ret nz			;5335	c0 	. 
l5336h:
	ld hl,LIVES		    ;5336	21 1d e0
	inc (hl)			;5339	34 	4
	call DRAW_LIVES		;533a	cd b9 71 	. . q 
	ld a,0c5h		;533d	3e c5 	> . 
	call sub_5befh		;533f	cd ef 5b 	. . [ 
	ld hl,0e021h		;5342	21 21 e0 	! ! . 
	inc (hl)			;5345	34 	4 
	ld e,040h		;5346	1e 40 	. @ 
	ld a,(hl)			;5348	7e 	~ 
	cp 001h		;5349	fe 01 	. . 
	jp z,l5350h		;534b	ca 50 53 	. P S 
	ld e,060h		;534e	1e 60 	. ` 
l5350h:
	ld a,(0e01fh)		;5350	3a 1f e0 	: . . 
	add a,e			;5353	83 	. 
	daa			;5354	27 	' 
	ld (0e01fh),a		;5355	32 1f e0 	2 . . 
	ret nc			;5358	d0 	. 
	ld a,(0e020h)		;5359	3a 20 e0 	:   . 
	add a,001h		;535c	c6 01 	. . 
	daa			;535e	27 	' 
	ld (0e020h),a		;535f	32 20 e0 	2   . 
	ret			;5362	c9 	. 
l5363h:
	dec b			;5363	05 	. 
	nop			;5364	00 	. 
	nop			;5365	00 	. 
	ld b,000h		;5366	06 00 	. . 
	nop			;5368	00 	. 
	rlca			;5369	07 	. 
	nop			;536a	00 	. 
	nop			;536b	00 	. 
	ex af,af'			;536c	08 	. 
	nop			;536d	00 	. 
	nop			;536e	00 	. 
	add hl,bc			;536f	09 	. 
	nop			;5370	00 	. 
	nop			;5371	00 	. 
	djnz l5374h		;5372	10 00 	. . 
l5374h:
	nop			;5374	00 	. 
	ld de,00000h		;5375	11 00 00 	. . . 
	ld (de),a			;5378	12 	. 
	nop			;5379	00 	. 
	nop			;537a	00 	. 
	ld b,b			;537b	40 	@ 
	nop			;537c	00 	. 
	nop			;537d	00 	. 
	ld h,b			;537e	60 	` 
	nop			;537f	00 	. 
	nop			;5380	00 	. 
	add a,b			;5381	80 	. 
	nop			;5382	00 	. 
	nop			;5383	00 	. 
	nop			;5384	00 	. 
	ld bc,00000h		;5385	01 00 00 	. . . 
    db 0x10, 0

; BDC-encode a score from HL
BCD_ENCODE_SCORE:
    ; Copy binary score to BCD buffer
	ld de,SCORE_BCD_BUFFER		    ;538a	11 a0 e5
	ld bc, 3		        ;538d	01 03 00
	ldir		            ;5390	ed b0

    ; Decode SCORE_BCD_BUFFER in BCD
	ld a,(SCORE_BCD_BUFFER)		;5392	3a a0 e5
	add a,(ix+0)		    ;5395	dd 86 00
	daa			            ;5398	27
	ld (SCORE_BCD_BUFFER),a		;5399	32 a0 e5

	; Decode SCORE_BCD_BUFFER + 1 in BCD
    ld a,(SCORE_BCD_BUFFER + 1)	;539c	3a a1 e5
	adc a,(ix+1)		    ;539f	dd 8e 01
	daa			            ;53a2	27
	ld (SCORE_BCD_BUFFER + 1),a	;53a3	32 a1 e5

	; Decode SCORE_BCD_BUFFER + 2 in BCD
    ld a,(SCORE_BCD_BUFFER + 2)	;53a6	3a a2 e5
	adc a,(ix+2)		    ;53a9	dd 8e 02
	daa			            ;53ac	27
	ld (SCORE_BCD_BUFFER + 2),a	;53ad	32 a2 e5

	ex de,hl			    ;53b0	eb
    ; HL = SCORE_BCD_BUFFER
    ; DE = SCORE_BCD or 0xe018
    
	dec hl			        ;53b1	2b
	dec de			        ;53b2	1b

    ; Copy BCD-encoded score
    ; Repeat 3 times (DE--) <-- (HL--) 
	ld bc, 3		        ;53b3	01 03 00
	lddr		            ;53b6	ed b8
	ret			            ;53b8	c9

; Draws the score and the high score
DRAW_SCORE_NUMBERS:
	ld hl,DECODED_ASCII_SCORE		;53b9	21 8e e5
	ld de,SCORE_BCD		            ;53bc	11 15 e0
	call DECODE_BCD_TO_ASCII		;53bf	cd 20 54
    ;
	ld hl,DECODED_ASCII_SCORE		;53c2	21 8e e5
	call REMOVE_HEADING_ZEROS		;53c5	cd 31 54

    ; Move to the end and remove heading zeros
	ld hl,DECODED_ZEROS 	        ;53c8	21 94 e5
	ld de,ZEROS_BCD_BUFFER		    ;53cb	11 18 e0
	call DECODE_BCD_TO_ASCII		;53ce	cd 20 54
    ;
	ld hl,DECODED_ZEROS		        ;53d1	21 94 e5
	call REMOVE_HEADING_ZEROS		;53d4	cd 31 54

	ld hl,DECODED_ASCII_HIGH_SCORE	;53d7	21 9a e5
	ld de,HIGH_SCORE_BCD		    ;53da	11 07 e0
	call DECODE_BCD_TO_ASCII		;53dd	cd 20 54
    ;
	ld hl,DECODED_ASCII_HIGH_SCORE	;53e0	21 9a e5
	call REMOVE_HEADING_ZEROS		;53e3	cd 31 54

    ; Check in which position draw the scores
	ld a,(SCORE_POSITION)	    ;53e6	3a 44 e5
	cp 1		                ;53e9	fe 01 Score on the right?
	jp z,l5407h		            ;53eb	ca 07 54
    
    ; Draw scores up
	ld hl,DECODED_ASCII_SCORE       ;53ee	21 8e e5
	ld de,0x1800 + 1 + 1*32		    ;53f1	11 21 18 	Locate at [1, 1]
	ld bc, 6		                ;53f4	01 06 00    6 chars
	call LDIRVM		                ;53f7	cd 5c 00

	ld hl,DECODED_ASCII_HIGH_SCORE	;53fa	21 9a e5
	ld de,0x1800 + 12 + 1*32	    ;53fd	11 2c 18 	Locate at [12, 1]
	ld bc, 6    		            ;5400	01 06 00    6 chars
	call LDIRVM		                ;5403	cd 5c 00
	ret			                    ;5406	c9

l5407h:
    ; Draw scores on the right
	ld hl,DECODED_ASCII_SCORE		        ;5407	21 8e e5
	ld de,0x1800 + 25 + 7*32    ;540a	11 f9 18    Locate at [25, 7]
	ld bc, 6		            ;540d	01 06 00    6 chars
	call LDIRVM		            ;5410	cd 5c 00
    
	ld hl,DECODED_ASCII_HIGH_SCORE		        ;5413	21 9a e5
	ld de,0x1800 + 25 + 3*32	;5416	11 79 18    Locate at [25, 3]
	ld bc,00006h		        ;5419	01 06 00
	call LDIRVM		            ;541c	cd 5c 00
	ret			                ;541f	c9

; Decode a BCD-encoded score into separate ASCII characters.
; This is used to print the scores.
DECODE_BCD_TO_ASCII:
    ; DE = SCORE_BCD
    ; HL = buffer

    ; Three BCD digits
	ld b,3		                ;5420	06 03
    
    ; Point to the most significant BCD in SCORE_BCD.
    ; For example, if the score is 22280, in memory it's
    ; stored backwards as  28 22 00. We'll point to 00.
	inc de			;5422	13
	inc de			;5423	13
l5424h:
    ; (hl) <-- (de)
	ld a,(de)			;5424	1a
	ld (hl),a			;5425	77
    
	ld a,033h		    ;5426	3e 33   0011.0011

    ; Performs a 4-bit rightward rotation of the 12-bit number whose 4 most
    ; significant bits are the 4 least significant bits of A, and its 8 least
    ; significant bits are in (HL).
    ; ............
    ; 0011|SSSSSSSS
    ; SSSS|0011SSSS
    ;
    ; The number 0011SSSS represents the ASCII digit of one half of the
    ; BCD-encoded number. 0011000 is 0x30 = '0'.
	rrd		            ;5428	ed 67
    
    ; Store digit
    inc hl			    ;542a	23
	ld (hl),a			;542b	77
    
	; Next BCD-digit
    inc hl			    ;542c	23
	dec de			    ;542d	1b
	
    djnz l5424h		    ;542e	10 f4
	ret			        ;5430	c9

; Substitute heading zeros from the BCD string pointed by HL
REMOVE_HEADING_ZEROS:
    ; 
	ld b, 5		        ;5431	06 05

l5433h:
    ; Get the character pointed by HL
	ld a,(hl)			;5433	7e
    
    ; Exit if it's not a zero
	cp '0'		        ;5434	fe 30
	ret nz			    ;5436	c0
    
    ; Yes, it's a heading zero
    ; Replace it with a blank space
	ld a, ' '		    ;5437	3e 20
    
    ; Next character
	ld (hl),a			;5439	77
	inc hl			    ;543a	23
	djnz l5433h		    ;543b	10 f6
	ret			        ;543d	c9

l543eh:
	nop			;543e	00 	. 
	nop			;543f	00 	. 
	nop			;5440	00 	. 
	nop			;5441	00 	. 
	nop			;5442	00 	. 
	nop			;5443	00 	. 
	nop			;5444	00 	. 
	nop			;5445	00 	. 
	nop			;5446	00 	. 
	inc b			;5447	04 	. 
	rlca			;5448	07 	. 
	ld a,(bc)			;5449	0a 	. 
	dec c			;544a	0d 	. 
	djnz l5460h		;544b	10 13 	. . 
	ld d,019h		;544d	16 19 	. . 
	inc e			;544f	1c 	. 
	rra			;5450	1f 	. 
	inc hl			;5451	23 	# 
	ld h,029h		;5452	26 29 	& ) 
	ld e,h			;5454	5c 	\ 
	ld h,b			;5455	60 	` 
	nop			;5456	00 	. 
	nop			;5457	00 	. 
	nop			;5458	00 	. 
	nop			;5459	00 	. 
	nop			;545a	00 	. 
	nop			;545b	00 	. 
	nop			;545c	00 	. 
	nop			;545d	00 	. 
	nop			;545e	00 	. 
	nop			;545f	00 	. 
l5460h:
	nop			;5460	00 	. 
	nop			;5461	00 	. 
	nop			;5462	00 	. 
	nop			;5463	00 	. 
	nop			;5464	00 	. 
	nop			;5465	00 	. 
	ld (bc),a			;5466	02 	. 
	dec b			;5467	05 	. 
	ex af,af'			;5468	08 	. 
	dec bc			;5469	0b 	. 
	ld c,011h		;546a	0e 11 	. . 
	inc d			;546c	14 	. 
	rla			;546d	17 	. 
	ld a,(de)			;546e	1a 	. 
	dec e			;546f	1d 	. 
	ld bc,02724h		;5470	01 24 27 	. $ ' 
	ld hl,(l615dh)		;5473	2a 5d 61 	* ] a 
	nop			;5476	00 	. 
	nop			;5477	00 	. 
	nop			;5478	00 	. 
	nop			;5479	00 	. 
	nop			;547a	00 	. 
	nop			;547b	00 	. 
	nop			;547c	00 	. 
	nop			;547d	00 	. 
	nop			;547e	00 	. 
	nop			;547f	00 	. 
	nop			;5480	00 	. 
	nop			;5481	00 	. 
	nop			;5482	00 	. 
	nop			;5483	00 	. 
	nop			;5484	00 	. 
	nop			;5485	00 	. 
	inc bc			;5486	03 	. 
	ld b,009h		;5487	06 09 	. . 
	inc c			;5489	0c 	. 
	rrca			;548a	0f 	. 
	ld (de),a			;548b	12 	. 
	dec d			;548c	15 	. 
	jr 0x54aa		;548d	18 1b 	. . 
	ld e,021h		;548f	1e 21 	. ! 
	dec h			;5491	25 	% 
	jr z,0x54ef		;5492	28 5b 	( [ 
	ld e,(hl)			;5494	5e 	^ 
	ld h,d			;5495	62 	b 
	nop			;5496	00 	. 
	nop			;5497	00 	. 
	nop			;5498	00 	. 
	nop			;5499	00 	. 
	nop			;549a	00 	. 
	nop			;549b	00 	. 
	nop			;549c	00 	. 
	nop			;549d	00 	. 



SCORE_HI_SCORE_STR:
    db "   ", 0x3a, 0x3b, 0x3c, 0x3d, 0x3e
    ;          S     C     O     R     E
    db "   "
    db 0x2b, 0x2f, 0x3f, 0x2b, " ", 0x3a, 0x3b, 0x3c, 0x3d, 0x3e
    ;   H     I     G     H          S     C     O     R     E
    
PUSH_START_BUTTON_STR:  ;54b3
    db "PUSH START BUTTON"

    ; Unused?
    db "1 PLAYER"     ;54c4

GAME_START_STR:
    db "   GAME START     "
    
TAITO_CORP_STR:
    db "@ TAITO CORPORATION 1986" 

ALL_RIGHTS_RESERVED_STR:
    db "ALL RIGHTS RESERVED"

l5509h:
	ld h,e			;5509	63 	c 
	ld h,l			;550a	65 	e 
	ld h,a			;550b	67 	g 
l550ch:
	ld l,c			;550c	69 	i 
	ld l,e			;550d	6b 	k 
	ld l,l			;550e	6d 	m 
	ld l,a			;550f	6f 	o 
	ld (hl),c			;5510	71 	q 
	ld (hl),e			;5511	73 	s 
	ld (hl),l			;5512	75 	u 
	ld (hl),a			;5513	77 	w 
l5514h:
	ld h,h			;5514	64 	d 
	ld h,(hl)			;5515	66 	f 
	ld l,b			;5516	68 	h 
l5517h:
	ld l,d			;5517	6a 	j 
	ld l,h			;5518	6c 	l 
	ld l,(hl)			;5519	6e 	n 
	ld (hl),b			;551a	70 	p 
	ld (hl),d			;551b	72 	r 
	ld (hl),h			;551c	74 	t 
	halt			;551d	76 	v 
	ld a,b			;551e	78 	x 

; Red characters for "HIGH" and "SCORE"
HIGH_LETTERS:
    db 0x2b, 0x2f, 0x3f, 0x2b
SCORE_LETTERS:
    db 0x3a, 0x3b, 0x3c, 0x3d, 0x3e
SCORE_LETTERS_DUP:
    db 0x3a, 0x3b, 0x3c, 0x3d, 0x3e
    
    
    db 0x35
	ld d,l			;552e	55 	U 
	or l			;552f	b5 	. 
	ld d,l			;5530	55 	U 
	dec (hl)			;5531	35 	5 
	ld d,(hl)			;5532	56 	V 
	or l			;5533	b5 	. 
	ld d,(hl)			;5534	56 	V 
l5535h:
	ret po			;5535	e0 	. 
	adc a,a			;5536	8f 	. 
	rrca			;5537	0f 	. 
	ld e,01eh		;5538	1e 1e 	. . 
	dec a			;553a	3d 	= 
	jr nc,$+127		;553b	30 7d 	0 } 
	dec a			;553d	3d 	= 
	ld c,l			;553e	4d 	M 
	ld (hl),b			;553f	70 	p 
	cp b			;5540	b8 	. 
	or b			;5541	b0 	. 
	ret nc			;5542	d0 	. 
	ld b,b			;5543	40 	@ 
	add a,b			;5544	80 	. 
	ret po			;5545	e0 	. 
	adc a,a			;5546	8f 	. 
	rrca			;5547	0f 	. 
	ld e,01eh		;5548	1e 1e 	. . 
	dec a			;554a	3d 	= 
	jr nc,l55cah		;554b	30 7d 	0 } 
l554dh:
	dec a			;554d	3d 	= 
	ld c,l			;554e	4d 	M 
	ld (hl),b			;554f	70 	p 
	cp b			;5550	b8 	. 
	or b			;5551	b0 	. 
	ret nc			;5552	d0 	. 
	ld b,b			;5553	40 	@ 
l5554h:
	add a,b			;5554	80 	. 
	ld a,l			;5555	7d 	} 
	ld a,l			;5556	7d 	} 
	ld (hl),b			;5557	70 	p 
	cp b			;5558	b8 	. 
	or b			;5559	b0 	. 
	ret nc			;555a	d0 	. 
	ld b,b			;555b	40 	@ 
	add a,b			;555c	80 	. 
	ret po			;555d	e0 	. 
	adc a,a			;555e	8f 	. 
	rrca			;555f	0f 	. 
	ld e,01eh		;5560	1e 1e 	. . 
	dec a			;5562	3d 	= 
	jr nc,l55b2h		;5563	30 4d 	0 M 
	ld a,l			;5565	7d 	} 
	ld a,l			;5566	7d 	} 
	ld (hl),b			;5567	70 	p 
	cp b			;5568	b8 	. 
	or b			;5569	b0 	. 
	ret nc			;556a	d0 	. 
	ld b,b			;556b	40 	@ 
	add a,b			;556c	80 	. 
	ret po			;556d	e0 	. 
	adc a,a			;556e	8f 	. 
	rrca			;556f	0f 	. 
	ld e,01eh		;5570	1e 1e 	. . 
	dec a			;5572	3d 	= 
	jr nc,l55c2h		;5573	30 4d 	0 M 
	ret po			;5575	e0 	. 
	adc a,a			;5576	8f 	. 
	rrca			;5577	0f 	. 
	ld e,01eh		;5578	1e 1e 	. . 
	dec a			;557a	3d 	= 
	jr nc,l55fah		;557b	30 7d 	0 } 
	dec a			;557d	3d 	= 
	ld c,l			;557e	4d 	M 
	ld (hl),b			;557f	70 	p 
	cp b			;5580	b8 	. 
	or b			;5581	b0 	. 
	ret nc			;5582	d0 	. 
	ld b,b			;5583	40 	@ 
	add a,b			;5584	80 	. 
	ret po			;5585	e0 	. 
	adc a,a			;5586	8f 	. 
	rrca			;5587	0f 	. 
	ld e,01eh		;5588	1e 1e 	. . 
	dec a			;558a	3d 	= 
	jr nc,l560ah		;558b	30 7d 	0 } 
	dec a			;558d	3d 	= 
	ld c,l			;558e	4d 	M 
	ld (hl),b			;558f	70 	p 
	cp b			;5590	b8 	. 
	or b			;5591	b0 	. 
	ret nc			;5592	d0 	. 
	ld b,b			;5593	40 	@ 
	add a,b			;5594	80 	. 
	ld a,l			;5595	7d 	} 
	ld a,l			;5596	7d 	} 
	ld (hl),b			;5597	70 	p 
	cp b			;5598	b8 	. 
	or b			;5599	b0 	. 
	ret nc			;559a	d0 	. 
	ld b,b			;559b	40 	@ 
	add a,b			;559c	80 	. 
	ret po			;559d	e0 	. 
	adc a,a			;559e	8f 	. 
	rrca			;559f	0f 	. 
	ld e,01eh		;55a0	1e 1e 	. . 
	dec a			;55a2	3d 	= 
	jr nc,$+79		;55a3	30 4d 	0 M 
	ld a,l			;55a5	7d 	} 
	ld a,l			;55a6	7d 	} 
	ld (hl),b			;55a7	70 	p 
	cp b			;55a8	b8 	. 
	or b			;55a9	b0 	. 
	ret nc			;55aa	d0 	. 
	ld b,b			;55ab	40 	@ 
	add a,b			;55ac	80 	. 
	ret po			;55ad	e0 	. 
	adc a,a			;55ae	8f 	. 
	rrca			;55af	0f 	. 
	ld e,01eh		;55b0	1e 1e 	. . 
l55b2h:
	dec a			;55b2	3d 	= 
	jr nc,l5602h		;55b3	30 4d 	0 M 
	call po,01324h		;55b5	e4 24 13 	. $ . 
	ld de,03361h		;55b8	11 61 33 	. a 3 
	rrca			;55bb	0f 	. 
	ret z			;55bc	c8 	. 
	rst 0			;55bd	c7 	. 
	rst 8			;55be	cf 	. 
	add a,c			;55bf	81 	. 
	jr c,l55feh		;55c0	38 3c 	8 < 
l55c2h:
	sbc a,b			;55c2	98 	. 
	pop bc			;55c3	c1 	. 
	ld b,e			;55c4	43 	C 
	add hl,bc			;55c5	09 	. 
	pop hl			;55c6	e1 	. 
	sbc a,b			;55c7	98 	. 
	add a,h			;55c8	84 	. 
	rst 20h			;55c9	e7 	. 
l55cah:
	sbc a,h			;55ca	9c 	. 
	djnz l55f0h		;55cb	10 23 	. # 
	sub e			;55cd	93 	. 
	sub b			;55ce	90 	. 
	ret po			;55cf	e0 	. 
	ld b,018h		;55d0	06 18 	. . 
	add hl,bc			;55d2	09 	. 
	inc bc			;55d3	03 	. 
	pop hl			;55d4	e1 	. 
	jr nc,l55eah		;55d5	30 13 	0 . 
	dec e			;55d7	1d 	. 
	adc a,b			;55d8	88 	. 
	adc a,0c8h		;55d9	ce c8 	. . 
	ret z			;55db	c8 	. 
	adc a,(hl)			;55dc	8e 	. 
	rrca			;55dd	0f 	. 
	inc c			;55de	0c 	. 
	add a,b			;55df	80 	. 
	rst 20h			;55e0	e7 	. 
	inc h			;55e1	24 	$ 
	inc h			;55e2	24 	$ 
	jp po,0c431h		;55e3	e2 31 c4 	. 1 . 
	ret z			;55e6	c8 	. 
	sub b			;55e7	90 	. 
	sub b			;55e8	90 	. 
	sub e			;55e9	93 	. 
l55eah:
	ld c,h			;55ea	4c 	L 
	ld c,b			;55eb	48 	H 
	sbc a,b			;55ec	98 	. 
	jr l55f3h		;55ed	18 04 	. . 
	ld h,d			;55ef	62 	b 
l55f0h:
	ld de,04889h		;55f0	11 89 48 	. . H 
l55f3h:
	ld c,b			;55f3	48 	H 
	rst 8			;55f4	cf 	. 
	djnz $+27		;55f5	10 19 	. . 
	add a,(hl)			;55f7	86 	. 
	ld b,h			;55f8	44 	D 
	add hl,sp			;55f9	39 	9 
l55fah:
	inc h			;55fa	24 	$ 
	call nz,01048h		;55fb	c4 48 10 	. H . 
l55feh:
	adc a,b			;55fe	88 	. 
	ld c,b			;55ff	48 	H 
	ld e,h			;5600	5c 	\ 
	ex (sp),hl			;5601	e3 	. 
l5602h:
	jp po,04772h		;5602	e2 72 47 	. r G 
	add a,(hl)			;5605	86 	. 
	sbc a,(hl)			;5606	9e 	. 
	ld h,d			;5607	62 	b 
	ld h,e			;5608	63 	c 
	sub (hl)			;5609	96 	. 
l560ah:
	jr l562ch		;560a	18 20 	.   
	ld b,e			;560c	43 	C 
	ld (hl),d			;560d	72 	r 
	ld (0fc27h),hl		;560e	22 27 fc 	" ' . 
	inc b			;5611	04 	. 
	ld (bc),a			;5612	02 	. 
	di			;5613	f3 	. 
	inc e			;5614	1c 	. 
	jr z,l5648h		;5615	28 31 	( 1 
	ld hl,0cc22h		;5617	21 22 cc 	! " . 
	inc b			;561a	04 	. 
	inc b			;561b	04 	. 
	call po,024c4h		;561c	e4 c4 24 	. . $ 
	jr z,l5655h		;561f	28 34 	( 4 
	inc hl			;5621	23 	# 
	ld (0cc44h),hl		;5622	22 44 cc 	" D . 
	call nz,sub_9188h		;5625	c4 88 91 	. . . 
	ex (sp),hl			;5628	e3 	. 
	call nz,07848h		;5629	c4 48 78 	. H x 
l562ch:
	adc a,c			;562c	89 	. 
	ex af,af'			;562d	08 	. 
	cp 003h		;562e	fe 03 	. . 
	ld bc,04e89h		;5630	01 89 4e 	. . N 
	sub d			;5633	92 	. 
	sub e			;5634	93 	. 
	add a,d			;5635	82 	. 
	sbc a,(hl)			;5636	9e 	. 
	sub b			;5637	90 	. 
	sub d			;5638	92 	. 
	sub d			;5639	92 	. 
	sub b			;563a	90 	. 
	sbc a,a			;563b	9f 	. 
	add a,b			;563c	80 	. 
	dec d			;563d	15 	. 
	dec d			;563e	15 	. 
	dec (hl)			;563f	35 	5 
	dec d			;5640	15 	. 
	dec d			;5641	15 	. 
	dec d			;5642	15 	. 
	call m,0ff00h		;5643	fc 00 ff 	. . . 
	nop			;5646	00 	. 
	nop			;5647	00 	. 
l5648h:
	nop			;5648	00 	. 
	nop			;5649	00 	. 
	rst 38h			;564a	ff 	. 
	nop			;564b	00 	. 
	nop			;564c	00 	. 
	rst 38h			;564d	ff 	. 
	nop			;564e	00 	. 
	nop			;564f	00 	. 
	nop			;5650	00 	. 
	nop			;5651	00 	. 
	ret p			;5652	f0 	. 
	djnz l5665h		;5653	10 10 	. . 
l5655h:
	sbc a,a			;5655	9f 	. 
	sub b			;5656	90 	. 
	sub a			;5657	97 	. 
	sub h			;5658	94 	. 
	sub h			;5659	94 	. 
	sub a			;565a	97 	. 
	sub b			;565b	90 	. 
	sbc a,a			;565c	9f 	. 
	rst 38h			;565d	ff 	. 
	nop			;565e	00 	. 
	add a,b			;565f	80 	. 
	add a,b			;5660	80 	. 
	add a,b			;5661	80 	. 
	add a,b			;5662	80 	. 
	nop			;5663	00 	. 
	add a,b			;5664	80 	. 
l5665h:
	rst 38h			;5665	ff 	. 
	ld bc,00101h		;5666	01 01 01 	. . . 
	ld bc,00101h		;5669	01 01 01 	. . . 
	ld (hl),c			;566c	71 	q 
	djnz l567fh		;566d	10 10 	. . 
	djnz l5681h		;566f	10 10 	. . 
	djnz l5683h		;5671	10 10 	. . 
	djnz l5694h		;5673	10 1f 	. . 
	nop			;5675	00 	. 
	nop			;5676	00 	. 
	cp 002h		;5677	fe 02 	. . 
	ld (bc),a			;5679	02 	. 
	ld (bc),a			;567a	02 	. 
	ld (bc),a			;567b	02 	. 
	cp 080h		;567c	fe 80 	. . 
	add a,c			;567e	81 	. 
l567fh:
	add a,c			;567f	81 	. 
	add a,c			;5680	81 	. 
l5681h:
	sub h			;5681	94 	. 
	sub h			;5682	94 	. 
l5683h:
	add a,b			;5683	80 	. 
	rst 38h			;5684	ff 	. 
	adc a,c			;5685	89 	. 
	dec b			;5686	05 	. 
l5687h:
	dec b			;5687	05 	. 
	dec b			;5688	05 	. 
	adc a,c			;5689	89 	. 
	ld (hl),c			;568a	71 	q 
	ld bc,000ffh		;568b	01 ff 00 	. . . 
	nop			;568e	00 	. 
	rra			;568f	1f 	. 
	djnz l56a2h		;5690	10 10 	. . 
	djnz $+18		;5692	10 10 	. . 
l5694h:
	rra			;5694	1f 	. 
	nop			;5695	00 	. 
	rst 38h			;5696	ff 	. 
l5697h:
	nop			;5697	00 	. 
	nop			;5698	00 	. 
	nop			;5699	00 	. 
	nop			;569a	00 	. 
	rst 38h			;569b	ff 	. 
	ld (bc),a			;569c	02 	. 
	nop			;569d	00 	. 
	cp 002h		;569e	fe 02 	. . 
	ld (bc),a			;56a0	02 	. 
	ld (bc),a			;56a1	02 	. 
l56a2h:
	ld (bc),a			;56a2	02 	. 
	cp 014h		;56a3	fe 14 	. . 
	nop			;56a5	00 	. 
	rst 38h			;56a6	ff 	. 
	add a,c			;56a7	81 	. 
	rst 38h			;56a8	ff 	. 
	djnz l56bbh		;56a9	10 10 	. . 
	rra			;56ab	1f 	. 
	nop			;56ac	00 	. 
	nop			;56ad	00 	. 
	rra			;56ae	1f 	. 
	djnz l56c1h		;56af	10 10 	. . 
	djnz $+18		;56b1	10 10 	. . 
	rst 38h			;56b3	ff 	. 
	nop			;56b4	00 	. 
	dec b			;56b5	05 	. 
	dec b			;56b6	05 	. 
	dec b			;56b7	05 	. 
	dec b			;56b8	05 	. 
	dec b			;56b9	05 	. 
	dec b			;56ba	05 	. 
l56bbh:
	inc b			;56bb	04 	. 
	dec b			;56bc	05 	. 
	inc b			;56bd	04 	. 
	rlca			;56be	07 	. 
	inc b			;56bf	04 	. 
	inc b			;56c0	04 	. 
l56c1h:
	inc b			;56c1	04 	. 
	call m,0a800h		;56c2	fc 00 a8 	. . . 
	djnz l5697h		;56c5	10 d0 	. . 
	rra			;56c7	1f 	. 
	nop			;56c8	00 	. 
	nop			;56c9	00 	. 
	nop			;56ca	00 	. 
	rra			;56cb	1f 	. 
	nop			;56cc	00 	. 
	ld d,b			;56cd	50 	P 
	ld d,b			;56ce	50 	P 
	ret nc			;56cf	d0 	. 
	ld d,b			;56d0	50 	P 
	ld d,b			;56d1	50 	P 
	ld d,b			;56d2	50 	P 
	ret nc			;56d3	d0 	. 
	ld d,b			;56d4	50 	P 
	dec b			;56d5	05 	. 
	dec b			;56d6	05 	. 
	inc b			;56d7	04 	. 
	call m,0b600h		;56d8	fc 00 b6 	. . . 
	nop			;56db	00 	. 
	rst 38h			;56dc	ff 	. 
	jr c,l5687h		;56dd	38 a8 	8 . 
	nop			;56df	00 	. 
	nop			;56e0	00 	. 
	inc bc			;56e1	03 	. 
	ex af,af'			;56e2	08 	. 
	nop			;56e3	00 	. 
	sub b			;56e4	90 	. 
	nop			;56e5	00 	. 
	rra			;56e6	1f 	. 
	nop			;56e7	00 	. 
	nop			;56e8	00 	. 
	add a,b			;56e9	80 	. 
	jr nz,l56ech		;56ea	20 00 	  . 
l56ech:
	inc de			;56ec	13 	. 
	ld d,b			;56ed	50 	P 
	ret nc			;56ee	d0 	. 
	djnz l5710h		;56ef	10 1f 	. . 
	nop			;56f1	00 	. 
	dec e			;56f2	1d 	. 
	inc d			;56f3	14 	. 
	sub a			;56f4	97 	. 
	nop			;56f5	00 	. 
	nop			;56f6	00 	. 
	rlca			;56f7	07 	. 
	dec b			;56f8	05 	. 
	inc b			;56f9	04 	. 
	inc b			;56fa	04 	. 
	inc b			;56fb	04 	. 
	inc b			;56fc	04 	. 
	sub b			;56fd	90 	. 
	ld b,b			;56fe	40 	@ 
	ld c,b			;56ff	48 	H 
	inc hl			;5700	23 	# 
	sbc a,b			;5701	98 	. 
	ld b,l			;5702	45 	E 
	ld sp,0120dh		;5703	31 0d 12 	1 . . 
	inc b			;5706	04 	. 
	dec h			;5707	25 	% 
	adc a,c			;5708	89 	. 
	ld (018c4h),a		;5709	32 c4 18 	2 . . 
	ret po			;570c	e0 	. 
	sub h			;570d	94 	. 
	sbc a,h			;570e	9c 	. 
	nop			;570f	00 	. 
l5710h:
	ld e,h			;5710	5c 	\ 
	ld d,h			;5711	54 	T 
l5712h:
    db 0xd4, 0x54, 0x5c 	;5712	d4 54 5c
	inc b			;5715	04 	. 
	inc b			;5716	04 	. 
	inc b			;5717	04 	. 
	call m,01f00h		;5718	fc 00 1f 	. . . 
	ld de,0041fh		;571b	11 1f 04 	. . . 
	dec b			;571e	05 	. 
	dec b			;571f	05 	. 
l5720h:
	dec b			;5720	05 	. 
	ld bc,00407h		;5721	01 07 04 	. . . 
	rlca			;5724	07 	. 
	dec b			;5725	05 	. 
	defb 0ddh,055h	;ld d,ixl		;5726	dd 55 	. U 
	ld (hl),a			;5728	77 	w 
	nop			;5729	00 	. 
	ret nz			;572a	c0 	. 
	ld b,b			;572b	40 	@ 
	ret nz			;572c	c0 	. 
	ld b,b			;572d	40 	@ 
	ld e,h			;572e	5c 	\ 
	ld b,b			;572f	40 	@ 
	ld e,a			;5730	5f 	_ 
	ld d,b			;5731	50 	P 
	ld d,b			;5732	50 	P 
	ld d,b			;5733	50 	P 
	ld d,b			;5734	50 	P 
l5735h:
	rla			;5735	17 	. 
	rst 38h			;5736	ff 	. 
	and b			;5737	a0 	. 
	cpl			;5738	2f 	/ 
	rst 38h			;5739	ff 	. 
l573ah:
	ex af,af'			;573a	08 	. 
	ld a,a			;573b	7f 	 
	ld h,c			;573c	61 	a 
	ld b,b			;573d	40 	@ 
	ld (hl),b			;573e	70 	p 
	ld d,b			;573f	50 	P 
	ret nc			;5740	d0 	. 
	pop de			;5741	d1 	. 
l5742h:
	djnz l5735h		;5742	10 f1 	. . 
	ld d,c			;5744	51 	Q 
	ld a,(de)			;5745	1a 	. 
	ld (hl),h			;5746	74 	t 
	and h			;5747	a4 	. 
	nop			;5748	00 	. 
	rst 38h			;5749	ff 	. 
	nop			;574a	00 	. 
	ld l,l			;574b	6d 	m 
	ld l,l			;574c	6d 	m 
	xor h			;574d	ac 	. 
	sub a			;574e	97 	. 
	sub d			;574f	92 	. 
	nop			;5750	00 	. 
	rst 38h			;5751	ff 	. 
	nop			;5752	00 	. 
	in a,(0dbh)		;5753	db db 	. . 
	ld l,a			;5755	6f 	o 
	ccf			;5756	3f 	? 
	ret z			;5757	c8 	. 
l5758h:
	rrca			;5758	0f 	. 
	nop			;5759	00 	. 
	ld a,(bc)			;575a	0a 	. 
	nop			;575b	00 	. 
	ret nz			;575c	c0 	. 
	pop de			;575d	d1 	. 
	ld d,b			;575e	50 	P 
	ld d,c			;575f	51 	Q 
	ret nz			;5760	c0 	. 
	nop			;5761	00 	. 
	add a,b			;5762	80 	. 
	ld bc,06d02h		;5763	01 02 6d 	. . m 
	nop			;5766	00 	. 
	xor a			;5767	af 	. 
	jr nz,l5799h		;5768	20 2f 	  / 
	and b			;576a	a0 	. 
	cpl			;576b	2f 	/ 
	cpl			;576c	2f 	/ 
	in a,(000h)		;576d	db 00 	. . 
	xor a			;576f	af 	. 
	jr nz,l5712h		;5770	20 a0 	  . 
	jr nz,$-94		;5772	20 a0 	  . 
	xor a			;5774	af 	. 
	nop			;5775	00 	. 
	ld b,a			;5776	47 	G 
	ld b,b			;5777	40 	@ 
	ld b,a			;5778	47 	G 
	rlca			;5779	07 	. 
	ret nz			;577a	c0 	. 
	rlca			;577b	07 	. 
	add a,a			;577c	87 	. 
	inc b			;577d	04 	. 
	out (014h),a		;577e	d3 14 	. . 
	ret nc			;5780	d0 	. 
	rst 10h			;5781	d7 	. 
	djnz l5758h		;5782	10 d4 	. . 
	out (0a0h),a		;5784	d3 a0 	. . 
	cpl			;5786	2f 	/ 
	cpl			;5787	2f 	/ 
	cpl			;5788	2f 	/ 
	and b			;5789	a0 	. 
	cpl			;578a	2f 	/ 
	cpl			;578b	2f 	/ 
	cpl			;578c	2f 	/ 
	jr nz,l573ah		;578d	20 ab 	  . 
	xor e			;578f	ab 	. 
	xor e			;5790	ab 	. 
	jr nz,l5742h		;5791	20 af 	  . 
	and b			;5793	a0 	. 
	and d			;5794	a2 	. 
	nop			;5795	00 	. 
	push af			;5796	f5 	. 
	dec d			;5797	15 	. 
	rst 30h			;5798	f7 	. 
l5799h:
	nop			;5799	00 	. 
	scf			;579a	37 	7 
	dec b			;579b	05 	. 
	push af			;579c	f5 	. 
	inc d			;579d	14 	. 
	ld b,d			;579e	42 	B 
	ld d,c			;579f	51 	Q 
	ld e,b			;57a0	58 	X 
	ld c,b			;57a1	48 	H 
	ld c,d			;57a2	4a 	J 
	ld a,d			;57a3	7a 	z 
	ret nz			;57a4	c0 	. 
	and b			;57a5	a0 	. 
	cpl			;57a6	2f 	/ 
	cpl			;57a7	2f 	/ 
	and b			;57a8	a0 	. 
	cpl			;57a9	2f 	/ 
	jr nz,l57dbh		;57aa	20 2f 	  / 
	nop			;57ac	00 	. 
	daa			;57ad	27 	' 
	xor h			;57ae	ac 	. 
	and d			;57af	a2 	. 
	dec hl			;57b0	2b 	+ 
	xor b			;57b1	a8 	. 
	inc hl			;57b2	23 	# 
	xor b			;57b3	a8 	. 
	inc bc			;57b4	03 	. 
l57b5h:
	cp l			;57b5	bd 	. 
	ld d,a			;57b6	57 	W 
	out (057h),a		;57b7	d3 57 	. W 
	jp (hl)			;57b9	e9 	. 
	ld d,a			;57ba	57 	W 
	rst 38h			;57bb	ff 	. 
	ld d,a			;57bc	57 	W 
	ld (hl),d			;57bd	72 	r 
	ld (hl),e			;57be	73 	s 
	ld (hl),b			;57bf	70 	p 
	ld (hl),c			;57c0	71 	q 
	ld (hl),d			;57c1	72 	r 
	ld (hl),e			;57c2	73 	s 
	ld (hl),b			;57c3	70 	p 
	ld (hl),c			;57c4	71 	q 
	ld (hl),d			;57c5	72 	r 
	ld (hl),e			;57c6	73 	s 
	ld (hl),b			;57c7	70 	p 
	ld (hl),c			;57c8	71 	q 
	ld (hl),d			;57c9	72 	r 
	ld (hl),e			;57ca	73 	s 
	ld (hl),b			;57cb	70 	p 
	ld (hl),c			;57cc	71 	q 
	ld (hl),d			;57cd	72 	r 
	ld (hl),e			;57ce	73 	s 
	ld (hl),b			;57cf	70 	p 
	ld (hl),c			;57d0	71 	q 
	ld (hl),d			;57d1	72 	r 
	ld (hl),e			;57d2	73 	s 
	halt			;57d3	76 	v 
	ld (hl),a			;57d4	77 	w 
	ld (hl),h			;57d5	74 	t 
	ld (hl),l			;57d6	75 	u 
	halt			;57d7	76 	v 
	ld (hl),a			;57d8	77 	w 
	ld (hl),h			;57d9	74 	t 
	ld (hl),l			;57da	75 	u 
l57dbh:
	halt			;57db	76 	v 
	ld (hl),a			;57dc	77 	w 
	ld (hl),h			;57dd	74 	t 
	ld (hl),l			;57de	75 	u 
	halt			;57df	76 	v 
	ld (hl),a			;57e0	77 	w 
	ld (hl),h			;57e1	74 	t 
	ld (hl),l			;57e2	75 	u 
	halt			;57e3	76 	v 
	ld (hl),a			;57e4	77 	w 
	ld (hl),h			;57e5	74 	t 
	ld (hl),l			;57e6	75 	u 
	halt			;57e7	76 	v 
	ld (hl),a			;57e8	77 	w 
	ld a,d			;57e9	7a 	z 
	ld a,e			;57ea	7b 	{ 
	ld a,b			;57eb	78 	x 
	ld a,c			;57ec	79 	y 
	ld a,d			;57ed	7a 	z 
	ld a,e			;57ee	7b 	{ 
	ld a,b			;57ef	78 	x 
	ld a,c			;57f0	79 	y 
	ld a,d			;57f1	7a 	z 
	ld a,e			;57f2	7b 	{ 
	ld a,b			;57f3	78 	x 
	ld a,c			;57f4	79 	y 
	ld a,d			;57f5	7a 	z 
	ld a,e			;57f6	7b 	{ 
	ld a,b			;57f7	78 	x 
	ld a,c			;57f8	79 	y 
	ld a,d			;57f9	7a 	z 
	ld a,e			;57fa	7b 	{ 
	ld a,b			;57fb	78 	x 
	ld a,c			;57fc	79 	y 
	ld a,d			;57fd	7a 	z 
	ld a,e			;57fe	7b 	{ 
	ld a,(hl)			;57ff	7e 	~ 
	ld a,a			;5800	7f 	 
	ld a,h			;5801	7c 	| 
	ld a,l			;5802	7d 	} 
	ld a,(hl)			;5803	7e 	~ 
	ld a,a			;5804	7f 	 
	ld a,h			;5805	7c 	| 
	ld a,l			;5806	7d 	} 
	ld a,(hl)			;5807	7e 	~ 
	ld a,a			;5808	7f 	 
	ld a,h			;5809	7c 	| 
	ld a,l			;580a	7d 	} 
	ld a,(hl)			;580b	7e 	~ 
	ld a,a			;580c	7f 	 
	ld a,h			;580d	7c 	| 
	ld a,l			;580e	7d 	} 
	ld a,(hl)			;580f	7e 	~ 
	ld a,a			;5810	7f 	 
	ld a,h			;5811	7c 	| 
	ld a,l			;5812	7d 	} 
	ld a,(hl)			;5813	7e 	~ 
	ld a,a			;5814	7f 	 
l5815h:
	dec e			;5815	1d 	. 
	ld e,b			;5816	58 	X 
	dec e			;5817	1d 	. 
	ld e,c			;5818	59 	Y 
	defb 0fdh,059h,0bdh	;illegal sequence		;5819	fd 59 bd 	. Y . 
	ld e,d			;581c	5a 	Z 
	ld bc,00303h		;581d	01 03 03 	. . . 
	rlca			;5820	07 	. 
	rlca			;5821	07 	. 
	rrca			;5822	0f 	. 
	rrca			;5823	0f 	. 
	rlca			;5824	07 	. 
	jr l5846h		;5825	18 1f 	. . 
l5827h:
	cpl			;5827	2f 	/ 
	ld (hl),b			;5828	70 	p 
	ld a,a			;5829	7f 	 
	ccf			;582a	3f 	? 
	rrca			;582b	0f 	. 
	nop			;582c	00 	. 
	nop			;582d	00 	. 
	add a,b			;582e	80 	. 
	add a,b			;582f	80 	. 
	ret nz			;5830	c0 	. 
	ret nz			;5831	c0 	. 
	ret po			;5832	e0 	. 
	ret po			;5833	e0 	. 
	ret nz			;5834	c0 	. 
	jr nc,l5827h		;5835	30 f0 	0 . 
	ret pe			;5837	e8 	. 
	inc e			;5838	1c 	. 
	call m,0e0f8h		;5839	fc f8 e0 	. . . 
	nop			;583c	00 	. 
	ld b,007h		;583d	06 07 	. . 
	rlca			;583f	07 	. 
	rlca			;5840	07 	. 
	rlca			;5841	07 	. 
	rlca			;5842	07 	. 
	rlca			;5843	07 	. 
	inc bc			;5844	03 	. 
	inc e			;5845	1c 	. 
l5846h:
	ccf			;5846	3f 	? 
	ld a,a			;5847	7f 	 
	inc a			;5848	3c 	< 
	ld b,e			;5849	43 	C 
	ld a,a			;584a	7f 	 
	ccf			;584b	3f 	? 
	nop			;584c	00 	. 
	nop			;584d	00 	. 
	nop			;584e	00 	. 
	add a,b			;584f	80 	. 
	ret nz			;5850	c0 	. 
	ret po			;5851	e0 	. 
	ret po			;5852	e0 	. 
	ret po			;5853	e0 	. 
	add a,b			;5854	80 	. 
l5855h:
	ld h,b			;5855	60 	` 
	ret c			;5856	d8 	. 
	cp h			;5857	bc 	. 
	ld a,h			;5858	7c 	| 
	ret m			;5859	f8 	. 
	ret po			;585a	e0 	. 
	nop			;585b	00 	. 
	nop			;585c	00 	. 
	jr l587dh		;585d	18 1e 	. . 
	rra			;585f	1f 	. 
	rrca			;5860	0f 	. 
	rrca			;5861	0f 	. 
	rrca			;5862	0f 	. 
	rlca			;5863	07 	. 
	ld b,000h		;5864	06 00 	. . 
	inc bc			;5866	03 	. 
	rra			;5867	1f 	. 
	ld a,a			;5868	7f 	 
	ld a,a			;5869	7f 	 
	ld a,h			;586a	7c 	| 
	ld h,b			;586b	60 	` 
	nop			;586c	00 	. 
	nop			;586d	00 	. 
	nop			;586e	00 	. 
	add a,b			;586f	80 	. 
	ret nz			;5870	c0 	. 
	ret p			;5871	f0 	. 
	ret po			;5872	e0 	. 
	add a,b			;5873	80 	. 
	nop			;5874	00 	. 
	ld (hl),b			;5875	70 	p 
	ret m			;5876	f8 	. 
	call m,sub_80f0h		;5877	fc f0 80 	. . . 
	nop			;587a	00 	. 
	nop			;587b	00 	. 
	nop			;587c	00 	. 
l587dh:
	ld b,007h		;587d	06 07 	. . 
	rlca			;587f	07 	. 
	rlca			;5880	07 	. 
	rlca			;5881	07 	. 
	inc b			;5882	04 	. 
	nop			;5883	00 	. 
	inc bc			;5884	03 	. 
	rra			;5885	1f 	. 
	ld a,071h		;5886	3e 71 	> q 
	ld c,a			;5888	4f 	O 
	ccf			;5889	3f 	? 
	ld a,a			;588a	7f 	 
	ccf			;588b	3f 	? 
	nop			;588c	00 	. 
	nop			;588d	00 	. 
	nop			;588e	00 	. 
	add a,b			;588f	80 	. 
	ret nz			;5890	c0 	. 
	nop			;5891	00 	. 
	ret po			;5892	e0 	. 
	jr nz,l5855h		;5893	20 c0 	  . 
	ret p			;5895	f0 	. 
	nop			;5896	00 	. 
l5897h:
	ret m			;5897	f8 	. 
	call m,0e0f8h		;5898	fc f8 e0 	. . . 
	nop			;589b	00 	. 
	nop			;589c	00 	. 
	ld bc,00303h		;589d	01 03 03 	. . . 
	rlca			;58a0	07 	. 
	nop			;58a1	00 	. 
	rlca			;58a2	07 	. 
	nop			;58a3	00 	. 
	rrca			;58a4	0f 	. 
	djnz $+17		;58a5	10 0f 	. . 
	ccf			;58a7	3f 	? 
	ld a,a			;58a8	7f 	 
	ld a,a			;58a9	7f 	 
	ccf			;58aa	3f 	? 
	rrca			;58ab	0f 	. 
	nop			;58ac	00 	. 
	nop			;58ad	00 	. 
	add a,b			;58ae	80 	. 
	add a,b			;58af	80 	. 
	ret nz			;58b0	c0 	. 
	nop			;58b1	00 	. 
	ret nz			;58b2	c0 	. 
	nop			;58b3	00 	. 
	ret po			;58b4	e0 	. 
	djnz l5897h		;58b5	10 e0 	. . 
	ret m			;58b7	f8 	. 
	call m,0f8fch		;58b8	fc fc f8 	. . . 
	ret po			;58bb	e0 	. 
	nop			;58bc	00 	. 
	nop			;58bd	00 	. 
	nop			;58be	00 	. 
	ld bc,00003h		;58bf	01 03 00 	. . . 
	rlca			;58c2	07 	. 
	inc b			;58c3	04 	. 
	inc bc			;58c4	03 	. 
	rrca			;58c5	0f 	. 
	nop			;58c6	00 	. 
	rra			;58c7	1f 	. 
	ccf			;58c8	3f 	? 
	rra			;58c9	1f 	. 
	rlca			;58ca	07 	. 
	nop			;58cb	00 	. 
	nop			;58cc	00 	. 
	ld h,b			;58cd	60 	` 
	ret po			;58ce	e0 	. 
	ret po			;58cf	e0 	. 
	ret po			;58d0	e0 	. 
	ret po			;58d1	e0 	. 
	jr nz,l58d4h		;58d2	20 00 	  . 
l58d4h:
	ret nz			;58d4	c0 	. 
	ret m			;58d5	f8 	. 
	ld a,h			;58d6	7c 	| 
	adc a,(hl)			;58d7	8e 	. 
	jp p,0fefch		;58d8	f2 fc fe 	. . . 
	call m,00000h		;58db	fc 00 00 	. . . 
	nop			;58de	00 	. 
	ld bc,00f03h		;58df	01 03 0f 	. . . 
	rlca			;58e2	07 	. 
	ld bc,00e00h		;58e3	01 00 0e 	. . . 
	rra			;58e6	1f 	. 
	ccf			;58e7	3f 	? 
	rrca			;58e8	0f 	. 
	ld bc,00000h		;58e9	01 00 00 	. . . 
	nop			;58ec	00 	. 
	jr l5967h		;58ed	18 78 	. x 
	ret m			;58ef	f8 	. 
	ret p			;58f0	f0 	. 
	ret p			;58f1	f0 	. 
	ret p			;58f2	f0 	. 
	ret po			;58f3	e0 	. 
	ld h,b			;58f4	60 	` 
	nop			;58f5	00 	. 
	ret nz			;58f6	c0 	. 
	ret m			;58f7	f8 	. 
	cp 0feh		;58f8	fe fe 	. . 
	ld a,006h		;58fa	3e 06 	> . 
	nop			;58fc	00 	. 
	nop			;58fd	00 	. 
	nop			;58fe	00 	. 
	ld bc,00703h		;58ff	01 03 07 	. . . 
	rlca			;5902	07 	. 
	rlca			;5903	07 	. 
	ld bc,01b06h		;5904	01 06 1b 	. . . 
	dec a			;5907	3d 	= 
	ld a,01fh		;5908	3e 1f 	> . 
	rlca			;590a	07 	. 
	nop			;590b	00 	. 
	nop			;590c	00 	. 
	ld h,b			;590d	60 	` 
	ret po			;590e	e0 	. 
	ret po			;590f	e0 	. 
	ret po			;5910	e0 	. 
	ret po			;5911	e0 	. 
	ret po			;5912	e0 	. 
l5913h:
	ret po			;5913	e0 	. 
	ret nz			;5914	c0 	. 
	jr c,l5913h		;5915	38 fc 	8 . 
	cp 03ch		;5917	fe 3c 	. < 
	jp nz,0fcfeh		;5919	c2 fe fc 	. . . 
	nop			;591c	00 	. 
	ld bc,00301h		;591d	01 01 03 	. . . 
	ld (bc),a			;5920	02 	. 
	ld b,004h		;5921	06 04 	. . 
	dec c			;5923	0d 	. 
	add hl,bc			;5924	09 	. 
	jr l593ah		;5925	18 13 	. . 
	inc a			;5927	3c 	< 
	inc sp			;5928	33 	3 
	nop			;5929	00 	. 
	nop			;592a	00 	. 
	nop			;592b	00 	. 
	nop			;592c	00 	. 
	nop			;592d	00 	. 
	nop			;592e	00 	. 
	add a,b			;592f	80 	. 
	ret nz			;5930	c0 	. 
	ld d,b			;5931	50 	P 
	ld l,b			;5932	68 	h 
	xor h			;5933	ac 	. 
	or (hl)			;5934	b6 	. 
	jp 0f01ch		;5935	c3 1c f0 	. . . 
	nop			;5938	00 	. 
	nop			;5939	00 	. 
l593ah:
	nop			;593a	00 	. 
	nop			;593b	00 	. 
	nop			;593c	00 	. 
	nop			;593d	00 	. 
	nop			;593e	00 	. 
	nop			;593f	00 	. 
	inc bc			;5940	03 	. 
	ld c,038h		;5941	0e 38 	. 8 
	pop hl			;5943	e1 	. 
	ld h,c			;5944	61 	a 
	jr c,l5953h		;5945	38 0c 	8 . 
	rlca			;5947	07 	. 
	ld bc,00000h		;5948	01 00 00 	. . . 
	nop			;594b	00 	. 
	nop			;594c	00 	. 
	nop			;594d	00 	. 
	nop			;594e	00 	. 
	ret nz			;594f	c0 	. 
	ret c			;5950	d8 	. 
	ld e,h			;5951	5c 	\ 
	ld c,h			;5952	4c 	L 
l5953h:
	ret z			;5953	c8 	. 
	ret c			;5954	d8 	. 
	ld d,b			;5955	50 	P 
	ld d,b			;5956	50 	P 
	ld b,b			;5957	40 	@ 
	ret nz			;5958	c0 	. 
	ret nz			;5959	c0 	. 
	nop			;595a	00 	. 
	nop			;595b	00 	. 
	nop			;595c	00 	. 
	nop			;595d	00 	. 
	nop			;595e	00 	. 
	jr c,l5990h		;595f	38 2f 	8 / 
	ld sp,01110h		;5961	31 10 11 	1 . . 
l5964h:
	ld de,00918h		;5964	11 18 09 	. . . 
l5967h:
	dec bc			;5967	0b 	. 
	inc c			;5968	0c 	. 
	ld a,(bc)			;5969	0a 	. 
	nop			;596a	00 	. 
	nop			;596b	00 	. 
	nop			;596c	00 	. 
	nop			;596d	00 	. 
	nop			;596e	00 	. 
	nop			;596f	00 	. 
	nop			;5970	00 	. 
	ret po			;5971	e0 	. 
	inc a			;5972	3c 	< 
	adc a,(hl)			;5973	8e 	. 
	cp b			;5974	b8 	. 
	ld h,e			;5975	63 	c 
	rst 0			;5976	c7 	. 
	inc a			;5977	3c 	< 
	ret po			;5978	e0 	. 
	nop			;5979	00 	. 
	nop			;597a	00 	. 
	nop			;597b	00 	. 
	nop			;597c	00 	. 
	ld bc,00301h		;597d	01 01 03 	. . . 
	ld b,004h		;5980	06 04 	. . 
	inc c			;5982	0c 	. 
	add hl,de			;5983	19 	. 
	ld de,l6030h		;5984	11 30 60 	. 0 ` 
l5987h:
	ld a,a			;5987	7f 	 
	nop			;5988	00 	. 
	nop			;5989	00 	. 
	nop			;598a	00 	. 
	nop			;598b	00 	. 
	nop			;598c	00 	. 
	nop			;598d	00 	. 
	nop			;598e	00 	. 
	add a,b			;598f	80 	. 
l5990h:
	ret nz			;5990	c0 	. 
	ld b,b			;5991	40 	@ 
	ld h,b			;5992	60 	` 
	or b			;5993	b0 	. 
	sub b			;5994	90 	. 
	jr $+14		;5995	18 0c 	. . 
	call m,00000h		;5997	fc 00 00 	. . . 
	nop			;599a	00 	. 
	nop			;599b	00 	. 
	nop			;599c	00 	. 
	nop			;599d	00 	. 
	nop			;599e	00 	. 
	ld bc,00a03h		;599f	01 03 0a 	. . . 
	ld d,035h		;59a2	16 35 	. 5 
	ld l,l			;59a4	6d 	m 
	jp 00f38h		;59a5	c3 38 0f 	. 8 . 
	nop			;59a8	00 	. 
	nop			;59a9	00 	. 
	nop			;59aa	00 	. 
	nop			;59ab	00 	. 
	nop			;59ac	00 	. 
	add a,b			;59ad	80 	. 
	add a,b			;59ae	80 	. 
	ret nz			;59af	c0 	. 
	ld b,b			;59b0	40 	@ 
	ld h,b			;59b1	60 	` 
	jr nz,l5964h		;59b2	20 b0 	  . 
	sub b			;59b4	90 	. 
	jr $-54		;59b5	18 c8 	. . 
	inc a			;59b7	3c 	< 
l59b8h:
	call z,00000h		;59b8	cc 00 00 	. . . 
	nop			;59bb	00 	. 
	nop			;59bc	00 	. 
	nop			;59bd	00 	. 
	nop			;59be	00 	. 
	inc bc			;59bf	03 	. 
	dec de			;59c0	1b 	. 
	ld a,(01332h)		;59c1	3a 32 13 	: 2 . 
	dec de			;59c4	1b 	. 
	ld a,(bc)			;59c5	0a 	. 
	ld a,(bc)			;59c6	0a 	. 
	ld (bc),a			;59c7	02 	. 
	inc bc			;59c8	03 	. 
	inc bc			;59c9	03 	. 
	nop			;59ca	00 	. 
	nop			;59cb	00 	. 
	nop			;59cc	00 	. 
	nop			;59cd	00 	. 
	nop			;59ce	00 	. 
	nop			;59cf	00 	. 
	ret nz			;59d0	c0 	. 
	ld (hl),b			;59d1	70 	p 
	inc e			;59d2	1c 	. 
	add a,a			;59d3	87 	. 
	add a,(hl)			;59d4	86 	. 
	inc e			;59d5	1c 	. 
l59d6h:
	jr nc,l59b8h		;59d6	30 e0 	0 . 
	add a,b			;59d8	80 	. 
	nop			;59d9	00 	. 
	nop			;59da	00 	. 
	nop			;59db	00 	. 
	nop			;59dc	00 	. 
	nop			;59dd	00 	. 
	nop			;59de	00 	. 
	nop			;59df	00 	. 
	nop			;59e0	00 	. 
	rlca			;59e1	07 	. 
	inc a			;59e2	3c 	< 
	ld (hl),c			;59e3	71 	q 
	dec e			;59e4	1d 	. 
	add a,0e3h		;59e5	c6 e3 	. . 
	inc a			;59e7	3c 	< 
	rlca			;59e8	07 	. 
	nop			;59e9	00 	. 
	nop			;59ea	00 	. 
	nop			;59eb	00 	. 
	nop			;59ec	00 	. 
	nop			;59ed	00 	. 
	nop			;59ee	00 	. 
	inc e			;59ef	1c 	. 
	call p,0088ch		;59f0	f4 8c 08 	. . . 
	adc a,b			;59f3	88 	. 
	adc a,b			;59f4	88 	. 
	jr l5987h		;59f5	18 90 	. . 
	ret nc			;59f7	d0 	. 
	jr nc,l5a4ah		;59f8	30 50 	0 P 
	nop			;59fa	00 	. 
	nop			;59fb	00 	. 
	nop			;59fc	00 	. 
	nop			;59fd	00 	. 
	inc bc			;59fe	03 	. 
	rlca			;59ff	07 	. 
	rrca			;5a00	0f 	. 
	rrca			;5a01	0f 	. 
	ld bc,03f1eh		;5a02	01 1e 3f 	. . ? 
	ld a,a			;5a05	7f 	 
	ld a,(hl)			;5a06	7e 	~ 
	ld a,h			;5a07	7c 	| 
	ld hl,0001eh		;5a08	21 1e 00 	! . . 
	nop			;5a0b	00 	. 
	nop			;5a0c	00 	. 
	nop			;5a0d	00 	. 
	ret nz			;5a0e	c0 	. 
	ret po			;5a0f	e0 	. 
	ret p			;5a10	f0 	. 
	ret nc			;5a11	d0 	. 
	sub b			;5a12	90 	. 
	jr z,l5a71h		;5a13	28 5c 	( \ 
	cp (hl)			;5a15	be 	. 
	cp d			;5a16	ba 	. 
	or d			;5a17	b2 	. 
	inc b			;5a18	04 	. 
	ld a,b			;5a19	78 	x 
	nop			;5a1a	00 	. 
	nop			;5a1b	00 	. 
l5a1ch:
	nop			;5a1c	00 	. 
	nop			;5a1d	00 	. 
	nop			;5a1e	00 	. 
	ld bc,00703h		;5a1f	01 03 07 	. . . 
	rlca			;5a22	07 	. 
	nop			;5a23	00 	. 
	rrca			;5a24	0f 	. 
	rra			;5a25	1f 	. 
	ccf			;5a26	3f 	? 
	ccf			;5a27	3f 	? 
	ld a,010h		;5a28	3e 10 	> . 
	rrca			;5a2a	0f 	. 
	nop			;5a2b	00 	. 
	nop			;5a2c	00 	. 
	nop			;5a2d	00 	. 
	nop			;5a2e	00 	. 
	ret po			;5a2f	e0 	. 
	ret p			;5a30	f0 	. 
	ret m			;5a31	f8 	. 
	ret pe			;5a32	e8 	. 
	ret z			;5a33	c8 	. 
	djnz l59d6h		;5a34	10 a0 	. . 
	ret nz			;5a36	c0 	. 
	ld b,b			;5a37	40 	@ 
	ld b,b			;5a38	40 	@ 
	add a,b			;5a39	80 	. 
	nop			;5a3a	00 	. 
	nop			;5a3b	00 	. 
l5a3ch:
	nop			;5a3c	00 	. 
	nop			;5a3d	00 	. 
	nop			;5a3e	00 	. 
	nop			;5a3f	00 	. 
	ld e,03eh		;5a40	1e 3e 	. > 
	ld a,l			;5a42	7d 	} 
	ld a,l			;5a43	7d 	} 
	ld a,h			;5a44	7c 	| 
	inc hl			;5a45	23 	# 
	rla			;5a46	17 	. 
	rrca			;5a47	0f 	. 
	rrca			;5a48	0f 	. 
	rrca			;5a49	0f 	. 
l5a4ah:
	inc b			;5a4a	04 	. 
	inc bc			;5a4b	03 	. 
	nop			;5a4c	00 	. 
	nop			;5a4d	00 	. 
	nop			;5a4e	00 	. 
	nop			;5a4f	00 	. 
	ld a,b			;5a50	78 	x 
	call m,0fafeh		;5a51	fc fe fa 	. . . 
	ld (0e8c4h),a		;5a54	32 c4 e8 	2 . . 
	ret p			;5a57	f0 	. 
	ret nc			;5a58	d0 	. 
	sub b			;5a59	90 	. 
	jr nz,l5a1ch		;5a5a	20 c0 	  . 
	nop			;5a5c	00 	. 
	nop			;5a5d	00 	. 
	nop			;5a5e	00 	. 
	nop			;5a5f	00 	. 
	ld e,03fh		;5a60	1e 3f 	. ? 
	ld a,a			;5a62	7f 	 
	ld a,(hl)			;5a63	7e 	~ 
	ld a,h			;5a64	7c 	| 
	ld hl,0011eh		;5a65	21 1e 01 	! . . 
	rrca			;5a68	0f 	. 
	rrca			;5a69	0f 	. 
	inc b			;5a6a	04 	. 
	inc bc			;5a6b	03 	. 
	nop			;5a6c	00 	. 
	nop			;5a6d	00 	. 
	nop			;5a6e	00 	. 
	nop			;5a6f	00 	. 
	ld a,b			;5a70	78 	x 
l5a71h:
	ld a,h			;5a71	7c 	| 
	cp (hl)			;5a72	be 	. 
	cp d			;5a73	ba 	. 
	or d			;5a74	b2 	. 
	inc b			;5a75	04 	. 
	ret pe			;5a76	e8 	. 
	ret p			;5a77	f0 	. 
	ret nc			;5a78	d0 	. 
	sub b			;5a79	90 	. 
	jr nz,l5a3ch		;5a7a	20 c0 	  . 
	nop			;5a7c	00 	. 
	nop			;5a7d	00 	. 
	nop			;5a7e	00 	. 
	rrca			;5a7f	0f 	. 
	rra			;5a80	1f 	. 
	ccf			;5a81	3f 	? 
	ccf			;5a82	3f 	? 
	ld a,010h		;5a83	3e 10 	> . 
	rrca			;5a85	0f 	. 
	nop			;5a86	00 	. 
	rlca			;5a87	07 	. 
	rlca			;5a88	07 	. 
	ld (bc),a			;5a89	02 	. 
	ld bc,00000h		;5a8a	01 00 00 	. . . 
	nop			;5a8d	00 	. 
	nop			;5a8e	00 	. 
	nop			;5a8f	00 	. 
	add a,b			;5a90	80 	. 
l5a91h:
	ret nz			;5a91	c0 	. 
	ld b,b			;5a92	40 	@ 
	ld b,b			;5a93	40 	@ 
	and b			;5a94	a0 	. 
	ld (hl),b			;5a95	70 	p 
	ret m			;5a96	f8 	. 
	ret pe			;5a97	e8 	. 
	ret z			;5a98	c8 	. 
	djnz $-30		;5a99	10 e0 	. . 
	nop			;5a9b	00 	. 
	nop			;5a9c	00 	. 
	nop			;5a9d	00 	. 
	inc bc			;5a9e	03 	. 
	rlca			;5a9f	07 	. 
	rrca			;5aa0	0f 	. 
	rrca			;5aa1	0f 	. 
	rrca			;5aa2	0f 	. 
	inc d			;5aa3	14 	. 
	dec sp			;5aa4	3b 	; 
	ld a,h			;5aa5	7c 	| 
	ld a,l			;5aa6	7d 	} 
	ld a,l			;5aa7	7d 	} 
	jr nz,l5ac8h		;5aa8	20 1e 	  . 
	nop			;5aaa	00 	. 
	nop			;5aab	00 	. 
	nop			;5aac	00 	. 
	nop			;5aad	00 	. 
	ret nz			;5aae	c0 	. 
	ret po			;5aaf	e0 	. 
	ret p			;5ab0	f0 	. 
	ret nc			;5ab1	d0 	. 
	sub b			;5ab2	90 	. 
	jr z,l5a91h		;5ab3	28 dc 	( . 
	ld a,0fah		;5ab5	3e fa 	> . 
	jp p,07884h		;5ab7	f2 84 78 	. . x 
	nop			;5aba	00 	. 
	nop			;5abb	00 	. 
	nop			;5abc	00 	. 
	ld (bc),a			;5abd	02 	. 
	rlca			;5abe	07 	. 
	rrca			;5abf	0f 	. 
	rra			;5ac0	1f 	. 
	ccf			;5ac1	3f 	? 
	ld a,a			;5ac2	7f 	 
	rst 38h			;5ac3	ff 	. 
	rst 38h			;5ac4	ff 	. 
	ccf			;5ac5	3f 	? 
	rra			;5ac6	1f 	. 
	rlca			;5ac7	07 	. 
l5ac8h:
	inc bc			;5ac8	03 	. 
	nop			;5ac9	00 	. 
	nop			;5aca	00 	. 
	nop			;5acb	00 	. 
	nop			;5acc	00 	. 
	nop			;5acd	00 	. 
l5aceh:
	add a,b			;5ace	80 	. 
	ret nz			;5acf	c0 	. 
	ret p			;5ad0	f0 	. 
	ret m			;5ad1	f8 	. 
	cp 0feh		;5ad2	fe fe 	. . 
	call m,0f0f8h		;5ad4	fc f8 f0 	. . . 
	ret po			;5ad7	e0 	. 
	ret nz			;5ad8	c0 	. 
	add a,b			;5ad9	80 	. 
	nop			;5ada	00 	. 
	nop			;5adb	00 	. 
	nop			;5adc	00 	. 
	nop			;5add	00 	. 
	inc bc			;5ade	03 	. 
	rrca			;5adf	0f 	. 
	ccf			;5ae0	3f 	? 
	ld a,h			;5ae1	7c 	| 
	ld (hl),e			;5ae2	73 	s 
	ld c,a			;5ae3	4f 	O 
	ccf			;5ae4	3f 	? 
	ld a,a			;5ae5	7f 	 
	ccf			;5ae6	3f 	? 
	rra			;5ae7	1f 	. 
	rrca			;5ae8	0f 	. 
	rlca			;5ae9	07 	. 
	ld (bc),a			;5aea	02 	. 
	nop			;5aeb	00 	. 
	nop			;5aec	00 	. 
	add a,b			;5aed	80 	. 
	and b			;5aee	a0 	. 
	or b			;5aef	b0 	. 
	jr c,l5aceh		;5af0	38 dc 	8 . 
	xor 0f6h		;5af2	ee f6 	. . 
	jp m,0fefch		;5af4	fa fc fe 	. . . 
	ret m			;5af7	f8 	. 
	ret po			;5af8	e0 	. 
	add a,b			;5af9	80 	. 
	nop			;5afa	00 	. 
	nop			;5afb	00 	. 
	nop			;5afc	00 	. 
	nop			;5afd	00 	. 
	rlca			;5afe	07 	. 
	rrca			;5aff	0f 	. 
	rra			;5b00	1f 	. 
	ccf			;5b01	3f 	? 
	ld a,(hl)			;5b02	7e 	~ 
	ld bc,03f7eh		;5b03	01 7e 3f 	. ~ ? 
	rra			;5b06	1f 	. 
	rrca			;5b07	0f 	. 
	rlca			;5b08	07 	. 
	nop			;5b09	00 	. 
	nop			;5b0a	00 	. 
	nop			;5b0b	00 	. 
	nop			;5b0c	00 	. 
	nop			;5b0d	00 	. 
	ret po			;5b0e	e0 	. 
	ret nc			;5b0f	d0 	. 
	cp b			;5b10	b8 	. 
	ld a,h			;5b11	7c 	| 
	cp 0ffh		;5b12	fe ff 	. . 
	cp 07ch		;5b14	fe 7c 	. | 
	cp b			;5b16	b8 	. 
	ret nc			;5b17	d0 	. 
	ret po			;5b18	e0 	. 
	nop			;5b19	00 	. 
	nop			;5b1a	00 	. 
	nop			;5b1b	00 	. 
	nop			;5b1c	00 	. 
	ld (bc),a			;5b1d	02 	. 
	rlca			;5b1e	07 	. 
	rrca			;5b1f	0f 	. 
	rra			;5b20	1f 	. 
	ccf			;5b21	3f 	? 
	ld a,a			;5b22	7f 	 
	cp 0fdh		;5b23	fe fd 	. . 
	dec sp			;5b25	3b 	; 
	rla			;5b26	17 	. 
	rlca			;5b27	07 	. 
	inc bc			;5b28	03 	. 
	nop			;5b29	00 	. 
	nop			;5b2a	00 	. 
	nop			;5b2b	00 	. 
	nop			;5b2c	00 	. 
	nop			;5b2d	00 	. 
	add a,b			;5b2e	80 	. 
	ret nz			;5b2f	c0 	. 
	ret nc			;5b30	d0 	. 
	cp b			;5b31	b8 	. 
	ld a,(hl)			;5b32	7e 	~ 
	cp 0fch		;5b33	fe fc 	. . 
	ret m			;5b35	f8 	. 
	ret p			;5b36	f0 	. 
	ret po			;5b37	e0 	. 
	ret nz			;5b38	c0 	. 
	add a,b			;5b39	80 	. 
	nop			;5b3a	00 	. 
	nop			;5b3b	00 	. 
	nop			;5b3c	00 	. 
	ld (bc),a			;5b3d	02 	. 
	rlca			;5b3e	07 	. 
	rrca			;5b3f	0f 	. 
	rra			;5b40	1f 	. 
	ccf			;5b41	3f 	? 
	ld a,a			;5b42	7f 	 
	ccf			;5b43	3f 	? 
	ld c,a			;5b44	4f 	O 
	ld (hl),e			;5b45	73 	s 
	ld a,h			;5b46	7c 	| 
	ccf			;5b47	3f 	? 
	rrca			;5b48	0f 	. 
	inc bc			;5b49	03 	. 
	nop			;5b4a	00 	. 
	nop			;5b4b	00 	. 
	nop			;5b4c	00 	. 
	nop			;5b4d	00 	. 
	add a,b			;5b4e	80 	. 
	ret po			;5b4f	e0 	. 
	ret m			;5b50	f8 	. 
	cp 0fch		;5b51	fe fc 	. . 
	jp m,0eef6h		;5b53	fa f6 ee 	. . . 
	call c,0b038h		;5b56	dc 38 b0 	. 8 . 
	and b			;5b59	a0 	. 
	add a,b			;5b5a	80 	. 
	nop			;5b5b	00 	. 
	nop			;5b5c	00 	. 
	nop			;5b5d	00 	. 
	inc bc			;5b5e	03 	. 
	rrca			;5b5f	0f 	. 
	rra			;5b60	1f 	. 
	ccf			;5b61	3f 	? 
	ccf			;5b62	3f 	? 
	ld a,a			;5b63	7f 	 
	ld a,a			;5b64	7f 	 
	ld a,a			;5b65	7f 	 
	inc a			;5b66	3c 	< 
	rra			;5b67	1f 	. 
	rrca			;5b68	0f 	. 
	ld bc,00000h		;5b69	01 00 00 	. . . 
	nop			;5b6c	00 	. 
	nop			;5b6d	00 	. 
	add a,b			;5b6e	80 	. 
	ret po			;5b6f	e0 	. 
	ret m			;5b70	f8 	. 
	call m,0fafch		;5b71	fc fc fa 	. . . 
	or 0ceh		;5b74	f6 ce 	. . 
	inc a			;5b76	3c 	< 
	ret m			;5b77	f8 	. 
	ret p			;5b78	f0 	. 
	ret nz			;5b79	c0 	. 
	nop			;5b7a	00 	. 
	nop			;5b7b	00 	. 
	nop			;5b7c	00 	. 
	nop			;5b7d	00 	. 
	rlca			;5b7e	07 	. 
	rra			;5b7f	1f 	. 
	ccf			;5b80	3f 	? 
	ccf			;5b81	3f 	? 
	ld a,a			;5b82	7f 	 
	ld a,a			;5b83	7f 	 
	ld a,a			;5b84	7f 	 
	ccf			;5b85	3f 	? 
	ccf			;5b86	3f 	? 
	jr l5b90h		;5b87	18 07 	. . 
	nop			;5b89	00 	. 
	nop			;5b8a	00 	. 
	nop			;5b8b	00 	. 
	nop			;5b8c	00 	. 
	nop			;5b8d	00 	. 
	ret po			;5b8e	e0 	. 
	ret p			;5b8f	f0 	. 
l5b90h:
	ret m			;5b90	f8 	. 
	ret m			;5b91	f8 	. 
	call m,0e4f4h		;5b92	fc f4 e4 	. . . 
	ret z			;5b95	c8 	. 
	jr l5bc8h		;5b96	18 30 	. 0 
	ret nz			;5b98	c0 	. 
	nop			;5b99	00 	. 
	nop			;5b9a	00 	. 
	nop			;5b9b	00 	. 
	nop			;5b9c	00 	. 
	nop			;5b9d	00 	. 
	rlca			;5b9e	07 	. 
	dec bc			;5b9f	0b 	. 
	dec e			;5ba0	1d 	. 
	ld a,07fh		;5ba1	3e 7f 	>  
	rst 38h			;5ba3	ff 	. 
	ld a,a			;5ba4	7f 	 
	ld a,01dh		;5ba5	3e 1d 	> . 
	dec bc			;5ba7	0b 	. 
	rlca			;5ba8	07 	. 
	nop			;5ba9	00 	. 
	nop			;5baa	00 	. 
	nop			;5bab	00 	. 
	nop			;5bac	00 	. 
	nop			;5bad	00 	. 
	ret po			;5bae	e0 	. 
	ret p			;5baf	f0 	. 
	ret m			;5bb0	f8 	. 
	call m,sub_807eh		;5bb1	fc 7e 80 	. ~ . 
	ld a,(hl)			;5bb4	7e 	~ 
	call m,0f0f8h		;5bb5	fc f8 f0 	. . . 
	ret po			;5bb8	e0 	. 
	nop			;5bb9	00 	. 
	nop			;5bba	00 	. 
	nop			;5bbb	00 	. 
	nop			;5bbc	00 	. 

; Draw the background
DRAW_BACKGROUND:
	ld b,003h		;5bbd	06 03 	. . 
	ld iy,02380h		;5bbf	fd 21 80 23 	. ! . # 
l5bc3h:
	ld c,081h		;5bc3	0e 81 	. . 
	ld a,(LEVEL)		;5bc5	3a 1b e0
l5bc8h:
	cp FINAL_LEVEL		;5bc8	fe 20
	jp z,l5bd7h		;5bca	ca d7 5b 	. . [ 
	and 003h		;5bcd	e6 03 	. . 
	ld e,a			;5bcf	5f 	_ 
	ld d,000h		;5bd0	16 00 	. . 
	ld hl,l5bebh		;5bd2	21 eb 5b 	! . [ 
	add hl,de			;5bd5	19 	. 
	ld c,(hl)			;5bd6	4e 	N 
l5bd7h:
	ld a,c			;5bd7	79 	y 
	push iy		;5bd8	fd e5 	. . 
	pop hl			;5bda	e1 	. 
	push bc			;5bdb	c5 	. 
	ld bc,00080h		;5bdc	01 80 00 	. . . 
	call FILVRM		;5bdf	cd 56 00 	. V . 
	pop bc			;5be2	c1 	. 
	ld de,00800h		;5be3	11 00 08 	. . . 
	add iy,de		;5be6	fd 19 	. . 
	djnz l5bc3h		;5be8	10 d9 	. . 
	ret			;5bea	c9 	. 
l5bebh:
	ld b,c			;5beb	41 	A 
	jp nz,l8141h		;5bec	c2 41 81 	. A . 
sub_5befh:
	push hl			;5bef	e5 	. 
	push de			;5bf0	d5 	. 
	push bc			;5bf1	c5 	. 
	ld c,a			;5bf2	4f 	O 
	ld a,(0e519h)		;5bf3	3a 19 e5 	: . . 
	or a			;5bf6	b7 	. 
	jp nz,l5c11h		;5bf7	c2 11 5c 	. . \ 
	ld a,(0e51eh)		;5bfa	3a 1e e5 	: . . 
	ld e,a			;5bfd	5f 	_ 
	ld d,000h		;5bfe	16 00 	. . 
	ld hl,0e520h		;5c00	21 20 e5 	!   . 
	add hl,de			;5c03	19 	. 
	ld (hl),c			;5c04	71 	q 
	ld hl,0e51eh		;5c05	21 1e e5 	! . . 
	inc (hl)			;5c08	34 	4 
	ld a,(hl)			;5c09	7e 	~ 
	cp 008h		;5c0a	fe 08 	. . 
	jp nz,l5c11h		;5c0c	c2 11 5c 	. . \ 
	ld (hl),007h		;5c0f	36 07 	6 . 
l5c11h:
	pop bc			;5c11	c1 	. 
	pop de			;5c12	d1 	. 
	pop hl			;5c13	e1 	. 
	ret			;5c14	c9 	. 

; SEGUIR
sub_5c15h:
	call sub_5d9dh		;5c15	cd 9d 5d 	. . ] 
    
    ; Skip the following if we're not doing a full brick repaint
	ld a,(BRICK_REPAINT_TYPE)	;5c18	3a 22 e0
	cp 2		                ;5c1b	fe 02
	jp z,l5c45h		;5c1d	ca 45 5c 	. E \ 

	ld hl,BRICKS_PER_LEVEL		;5c20	21 00 5d 	! . ] 
    
    ; A = LEVEL
	ld a,(LEVEL)		;5c23	3a 1b e0
    ; DE = LEVEL
	ld e,a			    ;5c26	5f
	ld d, 0 		    ;5c27	16 00
    ; HL += LEVEL
	add hl,de			;5c29	19

    ; Read the number of bricks in this level
    ; A = BRICKS_PER_LEVEL[LEVEL]
	ld a,(hl)			;5c2a	7e
	ld (BRICKS_LEFT),a	;5c2b	32 38 e0


	ld hl,0e039h		;5c2e	21 39 e0 	! 9 . 
	ld de,0e03ah		;5c31	11 3a e0 	. : . 
    
    ; A = LEVEL/8 + 2
    ; Fill 0e039h with 131 values of A = LEVEL/8 + 2
	ld a,(LEVEL)		;5c34	3a 1b e0 	: . . 
	srl a		;5c37	cb 3f 	. ? 
	srl a		;5c39	cb 3f 	. ? 
	srl a		;5c3b	cb 3f 	. ? 
	inc a			;5c3d	3c 	< 
	inc a			;5c3e	3c 	< 
    
	ld (hl),a			;5c3f	77 	w 

	ld bc, 131		;5c40	01 83 00 	. . . 
	ldir		;5c43	ed b0 	. . 

l5c45h:
	ld ix,0e36eh		;5c45	dd 21 6e e3 	. ! n . 

	ld de,l5e2fh		;5c49	11 2f 5e 	. / ^ 

    ; HL = LEVEL
	ld a,(LEVEL)		;5c4c	3a 1b e0
	ld l,a			    ;5c4f	6f
	ld h, 0 		    ;5c50	26 00

    ; HL = 2*LEVEL
	add hl,hl			;5c52	29
    
    ; HL = 2*LEVEL + l5e2fh
	add hl,de			;5c53	19

    ; Point to the start of the level (the bricks)
    ; DE = l5e2fh[2*LEVEL]
	ld e,(hl)			;5c54	5e
	inc hl			    ;5c55	23
	ld d,(hl)			;5c56	56

    ; IY = start of the level
	push de			    ;5c57	d5
	pop iy		        ;5c58	fd e1

	ld de,l5defh		;5c5a	11 ef 5d 	. . ] 
    
    ; HL = LEVEL
	ld a,(LEVEL)		;5c5d	3a 1b e0 	: . . 
	ld l,a			;5c60	6f 	o 
	ld h,000h		;5c61	26 00 	& . 
    
    ; HL = 2*LEVEL
	add hl,hl			;5c63	29 	) 
    
    ; HL = 2*LEVEL + l5defh
	add hl,de			;5c64	19 	. 
    
    ; DE = l5defh[2*LEVEL]
	ld e,(hl)			;5c65	5e 	^ 
	inc hl			;5c66	23 	# 
	ld d,(hl)			;5c67	56 	V 
	
    ; HL = l5defh[2*LEVEL]
    ex de,hl			;5c68	eb 	. 

    ; Set HL=0xe027 if we're not doing a full brick repaint
	ld a,(BRICK_REPAINT_TYPE)		;5c69	3a 22 e0
	cp 2		                    ;5c6c	fe 02
	jp nz,l5c74h		            ;5c6e	c2 74 5c

	ld hl,0e027h		            ;5c71	21 27 e0
l5c74h:
	ld b, 17		;5c74	06 11 	. . 
	xor a			;5c76	af 	. 
	ld (0e489h),a		;5c77	32 89 e4 	2 . . 
	xor a			;5c7a	af 	. 
	ld (0e48ah),a		;5c7b	32 8a e4 	2 . . 

l5c7eh:
	ld c,008h		;5c7e	0e 08 	. . 
	ld a,(hl)			;5c80	7e 	~ 
l5c81h:
	rlca			;5c81	07 	. 
	ld de,(0e486h)		;5c82	ed 5b 86 e4 	. [ . . 
	jr nc,l5c8dh		;5c86	30 05 	0 . 
	call sub_5d58h		;5c88	cd 58 5d 	. X ] 
	jr l5cc6h		;5c8b	18 39 	. 9 
l5c8dh:
	push hl			;5c8d	e5 	. 
	push af			;5c8e	f5 	. 
	inc ix		;5c8f	dd 23 	. # 
	push ix		;5c91	dd e5 	. . 
	push de			;5c93	d5 	. 

    ; DE = l5defh[2*LEVEL]
	ld de,l5defh		;5c94	11 ef 5d 	. . ] 
	ld a,(LEVEL)		;5c97	3a 1b e0 	: . . 
	ld l,a			;5c9a	6f 	o 
	ld h,000h		;5c9b	26 00 	& . 
	add hl,hl			;5c9d	29 	) 
	add hl,de			;5c9e	19 	. 
	ld e,(hl)			;5c9f	5e 	^ 
	inc hl			;5ca0	23 	# 
	ld d,(hl)			;5ca1	56 	V 


	push de			;5ca2	d5 	. 
	pop ix		;5ca3	dd e1 	. . 
	ld a,(0e48ah)		;5ca5	3a 8a e4 	: . . 
	ld e,a			;5ca8	5f 	_ 
	ld d,000h		;5ca9	16 00 	. . 
	add ix,de		;5cab	dd 19 	. . 
	ld a,(0e489h)		;5cad	3a 89 e4 	: . . 
	rlca			;5cb0	07 	. 
	ld e,a			;5cb1	5f 	_ 
	ld d,000h		;5cb2	16 00 	. . 
	ld hl,l5cf0h		;5cb4	21 f0 5c 	! . \ 
	add hl,de			;5cb7	19 	. 
	ld e,(hl)			;5cb8	5e 	^ 
	inc hl			;5cb9	23 	# 
	ld d,(hl)			;5cba	56 	V 
	ex de,hl			;5cbb	eb 	. 
	jp (hl)			;5cbc	e9 	. 
l5cbdh:
	jr z,l5cc1h		;5cbd	28 02 	( . 
	inc iy		;5cbf	fd 23 	. # 
l5cc1h:
	pop de			;5cc1	d1 	. 
	pop ix		;5cc2	dd e1 	. . 
	pop af			;5cc4	f1 	. 
	pop hl			;5cc5	e1 	. 
l5cc6h:
	inc de			;5cc6	13 	. 
	inc de			;5cc7	13 	. 
	ld (0e486h),de		;5cc8	ed 53 86 e4 	. S . . 
	inc ix		;5ccc	dd 23 	. # 
	dec c			;5cce	0d 	. 
	push af			;5ccf	f5 	. 
	ld a,(0e489h)		;5cd0	3a 89 e4 	: . . 
	inc a			;5cd3	3c 	< 
	and 007h		;5cd4	e6 07 	. . 
	ld (0e489h),a		;5cd6	32 89 e4 	2 . . 
	pop af			;5cd9	f1 	. 
	jr nz,l5c81h		;5cda	20 a5 	  . 
	inc hl			;5cdc	23 	# 
	push af			;5cdd	f5 	. 
	ld a,(0e48ah)		;5cde	3a 8a e4 	: . . 
	inc a			;5ce1	3c 	< 
	ld (0e48ah),a		;5ce2	32 8a e4 	2 . . 
	pop af			;5ce5	f1 	. 
	djnz l5c7eh		;5ce6	10 96 	. . 
	ld de,00000h		;5ce8	11 00 00 	. . . 
	ld (0e486h),de		;5ceb	ed 53 86 e4 	. S . . 
	ret			;5cef	c9 	. 

l5cf0h:
	jr nz,$+95		;5cf0	20 5d 	  ] 
	daa			;5cf2	27 	' 
	ld e,l			;5cf3	5d 	] 
	ld l,05dh		;5cf4	2e 5d 	. ] 
	dec (hl)			;5cf6	35 	5 
	ld e,l			;5cf7	5d 	] 
	inc a			;5cf8	3c 	< 
	ld e,l			;5cf9	5d 	] 
	ld b,e			;5cfa	43 	C 
	ld e,l			;5cfb	5d 	] 
	ld c,d			;5cfc	4a 	J 
	ld e,l			;5cfd	5d 	] 
	ld d,c			;5cfe	51 	Q 
	ld e,l			;5cff	5d 	] 

BRICKS_PER_LEVEL:
    ;  L1  L2  L3  L4  L5  L6  L7 L8  L9  L10
    db 66, 66, 42, 80, 63, 51, 54, 7, 22, 25
    ; L11  L12 L13  L14, L15  L16  L17 L18  L19 L20
    db 49, 8,   56, 66,  113, 50,  47,  44, 43,  20
    ; L21 L22 L23 L24 L25 L26 L27 L28 L29 L30 L31 L32
    db 12, 64, 47, 53, 36, 10, 66, 45, 76, 55, 56, 26

	bit 7,(ix+000h)		;5d20	dd cb 00 7e 	. . . ~ 
	jp l5cbdh		;5d24	c3 bd 5c 	. . \ 
	bit 6,(ix+000h)		;5d27	dd cb 00 76 	. . . v 
	jp l5cbdh		;5d2b	c3 bd 5c 	. . \ 
	bit 5,(ix+000h)		;5d2e	dd cb 00 6e 	. . . n 
	jp l5cbdh		;5d32	c3 bd 5c 	. . \ 
	bit 4,(ix+000h)		;5d35	dd cb 00 66 	. . . f 
	jp l5cbdh		;5d39	c3 bd 5c 	. . \ 
	bit 3,(ix+000h)		;5d3c	dd cb 00 5e 	. . . ^ 
	jp l5cbdh		;5d40	c3 bd 5c 	. . \ 
	bit 2,(ix+000h)		;5d43	dd cb 00 56 	. . . V 
	jp l5cbdh		;5d47	c3 bd 5c 	. . \ 
	bit 1,(ix+000h)		;5d4a	dd cb 00 4e 	. . . N 
	jp l5cbdh		;5d4e	c3 bd 5c 	. . \ 
	bit 0,(ix+000h)		;5d51	dd cb 00 46 	. . . F 
	jp l5cbdh		;5d55	c3 bd 5c 	. . \ 

; ToDo
sub_5d58h:
	push af			;5d58	f5 	. 
	push bc			;5d59	c5 	. 
	push de			;5d5a	d5 	. 
	push hl			;5d5b	e5 	. 
	
    ; HL = 2*IY[0]
    ld a,(iy+000h)		;5d5c	fd 7e 00 	. ~ . 
	ld l,a			;5d5f	6f 	o 
	ld h,000h		;5d60	26 00 	& . 
	add hl,hl			;5d62	29 	) 
    
	; HL = l5ddbh + 2*IY[0]
    ld de,l5ddbh		;5d63	11 db 5d 	. . ] 
	add hl,de			;5d66	19 	. 
    ;
	; A =  l5ddbh[2*IY[0]]
    ld a,(hl)			;5d67	7e 	~ 
    
	; IX[0] = l5ddbh[2*IY[0]] *** WRITE ***
    ld (ix+000h),a		;5d68	dd 77 00 	. w . 
    
    ; Increment pointers
	inc hl			;5d6b	23 	# 
	inc ix		;5d6c	dd 23 	. # 
	
    ; Write again, after incrementing the pointers
    ld a,(hl)			;5d6e	7e 	~ 
	ld (ix+000h),a		;5d6f	dd 77 00 	. w . 
    
    ; IY++
	inc iy		;5d72	fd 23 	. # 

	pop hl			;5d74	e1 	. 
	pop de			;5d75	d1 	. 
	pop bc			;5d76	c1 	. 
	pop af			;5d77	f1 	. 
	ret			;5d78	c9 	. 

sub_5d79h:
	ld hl,0e36eh		;5d79	21 6e e3 	! n . 
	ld de,01862h		;5d7c	11 62 18 	. b . 
	defb 0ddh,02eh,00ch	;ld ixl,00ch		;5d7f	dd 2e 0c 	. . . 
l5d82h:
	ld iy,00020h		;5d82	fd 21 20 00 	. !   . 
	ld bc,00016h		;5d86	01 16 00 	. . . 
	push de			;5d89	d5 	. 
	push hl			;5d8a	e5 	. 
	push bc			;5d8b	c5 	. 
	call LDIRVM		;5d8c	cd 5c 00 	. \ . 
	pop bc			;5d8f	c1 	. 
	pop hl			;5d90	e1 	. 
	add hl,bc			;5d91	09 	. 
	pop de			;5d92	d1 	. 
	add iy,de		;5d93	fd 19 	. . 
	push iy		;5d95	fd e5 	. . 
	pop de			;5d97	d1 	. 
	defb 0ddh,02dh	;dec ixl		;5d98	dd 2d 	. - 
	jr nz,l5d82h		;5d9a	20 e6 	  . 
	ret			;5d9c	c9 	. 

sub_5d9dh:
	xor a			;5d9d	af 	. 
	ld (0e53ch),a		;5d9e	32 3c e5 	2 < . 
	ld ix,0e36eh		;5da1	dd 21 6e e3 	. ! n . 
l5da5h:
	xor a			;5da5	af 	. 
	ld (0e53dh),a		;5da6	32 3d e5 	2 = . 
l5da9h:
	ld a,(0e53ch)		;5da9	3a 3c e5 	: < . 
	and 003h		;5dac	e6 03 	. . 
	ld l,a			;5dae	6f 	o 
	ld h,000h		;5daf	26 00 	& . 
	add hl,hl			;5db1	29 	) 
	add hl,hl			;5db2	29 	) 
	ld de,lad98h		;5db3	11 98 ad 	. . . 
	add hl,de			;5db6	19 	. 
	ld a,(0e53dh)		;5db7	3a 3d e5 	: = . 
	and 003h		;5dba	e6 03 	. . 
	ld e,a			;5dbc	5f 	_ 
	ld d,000h		;5dbd	16 00 	. . 
	add hl,de			;5dbf	19 	. 
	ld a,(hl)			;5dc0	7e 	~ 
	ld (ix+000h),a		;5dc1	dd 77 00 	. w . 
	inc ix		;5dc4	dd 23 	. # 
	ld hl,0e53dh		;5dc6	21 3d e5 	! = . 
	inc (hl)			;5dc9	34 	4 
	ld a,(hl)			;5dca	7e 	~ 
	cp 016h		;5dcb	fe 16 	. . 
	jp nz,l5da9h		;5dcd	c2 a9 5d 	. . ] 
	ld hl,0e53ch		;5dd0	21 3c e5 	! < . 
	inc (hl)			;5dd3	34 	4 
	ld a,(hl)			;5dd4	7e 	~ 
	cp 00ch		;5dd5	fe 0c 	. . 
	jp nz,l5da5h		;5dd7	c2 a5 5d 	. . ] 
	ret			;5dda	c9 	. 

l5ddbh:
	inc hl			;5ddb	23 	# 
	inc h			;5ddc	24 	$ 
	dec h			;5ddd	25 	% 
	ld h,027h		;5dde	26 27 	& ' 
	jr z,$+43		;5de0	28 29 	( ) 
	ld e,e			;5de2	5b 	[ 
	ld e,h			;5de3	5c 	\ 
	ld e,l			;5de4	5d 	] 
	ld e,(hl)			;5de5	5e 	^ 
	ld h,b			;5de6	60 	` 
	ld h,c			;5de7	61 	a 
	ld h,d			;5de8	62 	b 
	ld h,e			;5de9	63 	c 
	ld h,h			;5dea	64 	d 
	ld h,l			;5deb	65 	e 
	ld h,(hl)			;5dec	66 	f 
	ld h,a			;5ded	67 	g 
	ld l,b			;5dee	68 	h 
l5defh:
	dec d			;5def	15 	. 
	ld h,(hl)			;5df0	66 	f 
	ld h,066h		;5df1	26 66 	& f 
	scf			;5df3	37 	7 
	ld h,(hl)			;5df4	66 	f 
	ld c,b			;5df5	48 	H 
	ld h,(hl)			;5df6	66 	f 
	ld e,c			;5df7	59 	Y 
	ld h,(hl)			;5df8	66 	f 
	ld l,d			;5df9	6a 	j 
	ld h,(hl)			;5dfa	66 	f 
	ld a,e			;5dfb	7b 	{ 
	ld h,(hl)			;5dfc	66 	f 
	adc a,h			;5dfd	8c 	. 
	ld h,(hl)			;5dfe	66 	f 
	sbc a,l			;5dff	9d 	. 
	ld h,(hl)			;5e00	66 	f 
	xor (hl)			;5e01	ae 	. 
	ld h,(hl)			;5e02	66 	f 
	cp a			;5e03	bf 	. 
	ld h,(hl)			;5e04	66 	f 
	ret nc			;5e05	d0 	. 
	ld h,(hl)			;5e06	66 	f 
	pop hl			;5e07	e1 	. 
	ld h,(hl)			;5e08	66 	f 
	jp p,00366h		;5e09	f2 66 03 	. f . 
	ld h,a			;5e0c	67 	g 
	inc d			;5e0d	14 	. 
	ld h,a			;5e0e	67 	g 
	dec h			;5e0f	25 	% 
	ld h,a			;5e10	67 	g 
	ld (hl),067h		;5e11	36 67 	6 g 
	ld b,a			;5e13	47 	G 
	ld h,a			;5e14	67 	g 
	ld e,b			;5e15	58 	X 
	ld h,a			;5e16	67 	g 
	ld l,c			;5e17	69 	i 
	ld h,a			;5e18	67 	g 
	ld a,d			;5e19	7a 	z 
	ld h,a			;5e1a	67 	g 
	adc a,e			;5e1b	8b 	. 
	ld h,a			;5e1c	67 	g 
	sbc a,h			;5e1d	9c 	. 
	ld h,a			;5e1e	67 	g 
	xor l			;5e1f	ad 	. 
	ld h,a			;5e20	67 	g 
	cp (hl)			;5e21	be 	. 
	ld h,a			;5e22	67 	g 
	rst 8			;5e23	cf 	. 
	ld h,a			;5e24	67 	g 
	ret po			;5e25	e0 	. 
	ld h,a			;5e26	67 	g 
	pop af			;5e27	f1 	. 
	ld h,a			;5e28	67 	g 
	ld (bc),a			;5e29	02 	. 
	ld l,b			;5e2a	68 	h 
	inc de			;5e2b	13 	. 
	ld l,b			;5e2c	68 	h 
	inc h			;5e2d	24 	$ 
	ld l,b			;5e2e	68 	h 
l5e2fh:
	ld l,a			;5e2f	6f 	o 
	ld e,(hl)			;5e30	5e 	^ 
	or c			;5e31	b1 	. 
	ld e,(hl)			;5e32	5e 	^ 
	di			;5e33	f3 	. 
	ld e,(hl)			;5e34	5e 	^ 
	dec (hl)			;5e35	35 	5 
	ld e,a			;5e36	5f 	_ 
	add a,l			;5e37	85 	. 
	ld e,a			;5e38	5f 	_ 
	call nz,0fd5fh		;5e39	c4 5f fd 	. _ . 
	ld e,a			;5e3c	5f 	_ 
	inc sp			;5e3d	33 	3 
	ld h,b			;5e3e	60 	` 
	ld d,d			;5e3f	52 	R 
	ld h,b			;5e40	60 	` 
	ld a,d			;5e41	7a 	z 
	ld h,b			;5e42	60 	` 
	xor a			;5e43	af 	. 
	ld h,b			;5e44	60 	` 
	ret po			;5e45	e0 	. 
	ld h,b			;5e46	60 	` 
	ld a,(de)			;5e47	1a 	. 
	ld h,c			;5e48	61 	a 
	ld d,d			;5e49	52 	R 
	ld h,c			;5e4a	61 	a 
	sbc a,d			;5e4b	9a 	. 
	ld h,c			;5e4c	61 	a 
	inc de			;5e4d	13 	. 
	ld h,d			;5e4e	62 	b 
	ld c,d			;5e4f	4a 	J 
	ld h,d			;5e50	62 	b 
	ld a,a			;5e51	7f 	 
	ld h,d			;5e52	62 	b 
	rst 0			;5e53	c7 	. 
	ld h,d			;5e54	62 	b 
	ld b,063h		;5e55	06 63 	. c 
	inc a			;5e57	3c 	< 
	ld h,e			;5e58	63 	c 
	ld (hl),h			;5e59	74 	t 
	ld h,e			;5e5a	63 	c 
	call nz,0f363h		;5e5b	c4 63 f3 	. c . 
	ld h,e			;5e5e	63 	c 
	jr z,l5ec5h		;5e5f	28 64 	( d 
	ld l,c			;5e61	69 	i 
	ld h,h			;5e62	64 	d 
	add a,e			;5e63	83 	. 
	ld h,h			;5e64	64 	d 
	push bc			;5e65	c5 	. 
	ld h,h			;5e66	64 	d 
	dec b			;5e67	05 	. 
	ld h,l			;5e68	65 	e 
	ld l,c			;5e69	69 	i 
	ld h,l			;5e6a	65 	e 
	and l			;5e6b	a5 	. 
	ld h,l			;5e6c	65 	e 
	defb 0ddh,065h	;ld ixh,ixl		;5e6d	dd 65 	. e 

    ;include 'bricks_levels.asm'
    ; LEVEL 1
	ex af,af'			;5e6f	08 	. 
	ex af,af'			;5e70	08 	. 
	ex af,af'			;5e71	08 	. 
	ex af,af'			;5e72	08 	. 
	ex af,af'			;5e73	08 	. 
	ex af,af'			;5e74	08 	. 
	ex af,af'			;5e75	08 	. 
	ex af,af'			;5e76	08 	. 
	ex af,af'			;5e77	08 	. 
	ex af,af'			;5e78	08 	. 
	ex af,af'			;5e79	08 	. 

	inc b			;5e7a	04 	. 
	inc b			;5e7b	04 	. 
	inc b			;5e7c	04 	. 
	inc b			;5e7d	04 	. 
	inc b			;5e7e	04 	. 
	inc b			;5e7f	04 	. 
	inc b			;5e80	04 	. 
	inc b			;5e81	04 	. 
	inc b			;5e82	04 	. 
	inc b			;5e83	04 	. 
	inc b			;5e84	04 	. 

	rlca			;5e85	07 	. 
	rlca			;5e86	07 	. 
	rlca			;5e87	07 	. 
	rlca			;5e88	07 	. 
	rlca			;5e89	07 	. 
	rlca			;5e8a	07 	. 
	rlca			;5e8b	07 	. 
	rlca			;5e8c	07 	. 
	rlca			;5e8d	07 	. 
	rlca			;5e8e	07 	. 
	rlca			;5e8f	07 	. 

	dec b			;5e90	05 	. 
	dec b			;5e91	05 	. 
	dec b			;5e92	05 	. 
	dec b			;5e93	05 	. 
	dec b			;5e94	05 	. 
	dec b			;5e95	05 	. 
	dec b			;5e96	05 	. 
	dec b			;5e97	05 	. 
	dec b			;5e98	05 	. 
	dec b			;5e99	05 	. 
	dec b			;5e9a	05 	. 

	ld b,006h		;5e9b	06 06 	. . 
	ld b,006h		;5e9d	06 06 	. . 
	ld b,006h		;5e9f	06 06 	. . 
	ld b,006h		;5ea1	06 06 	. . 
	ld b,006h		;5ea3	06 06 	. . 
    db 6
    
    db 3
	inc bc			;5ea7	03 	. 
	inc bc			;5ea8	03 	. 
	inc bc			;5ea9	03 	. 
	inc bc			;5eaa	03 	. 
	inc bc			;5eab	03 	. 
	inc bc			;5eac	03 	. 
	inc bc			;5ead	03 	. 
	inc bc			;5eae	03 	. 
	inc bc			;5eaf	03 	. 
	inc bc			;5eb0	03 	. 
    
    ; LEVEL 2
	nop			;5eb1	00 	. 
	nop			;5eb2	00 	. 
	ld bc,00100h		;5eb3	01 00 01 	. . . 
	ld (bc),a			;5eb6	02 	. 
	nop			;5eb7	00 	. 
	ld bc,00302h		;5eb8	01 02 03 	. . . 
	nop			;5ebb	00 	. 
	ld bc,00302h		;5ebc	01 02 03 	. . . 
	inc b			;5ebf	04 	. 
	nop			;5ec0	00 	. 
	ld bc,00302h		;5ec1	01 02 03 	. . . 
	inc b			;5ec4	04 	. 
l5ec5h:
	dec b			;5ec5	05 	. 
	nop			;5ec6	00 	. 
	ld bc,00302h		;5ec7	01 02 03 	. . . 
	inc b			;5eca	04 	. 
	dec b			;5ecb	05 	. 
	ld b,000h		;5ecc	06 00 	. . 
	ld bc,00302h		;5ece	01 02 03 	. . . 
	inc b			;5ed1	04 	. 
	dec b			;5ed2	05 	. 
	ld b,007h		;5ed3	06 07 	. . 
	nop			;5ed5	00 	. 
	ld bc,00302h		;5ed6	01 02 03 	. . . 
	inc b			;5ed9	04 	. 
	dec b			;5eda	05 	. 
	ld b,007h		;5edb	06 07 	. . 
	nop			;5edd	00 	. 
	nop			;5ede	00 	. 
	ld bc,00302h		;5edf	01 02 03 	. . . 
	inc b			;5ee2	04 	. 
	dec b			;5ee3	05 	. 
	ld b,007h		;5ee4	06 07 	. . 
	nop			;5ee6	00 	. 
	ld bc,00808h		;5ee7	01 08 08 	. . . 
	ex af,af'			;5eea	08 	. 
	ex af,af'			;5eeb	08 	. 
	ex af,af'			;5eec	08 	. 
	ex af,af'			;5eed	08 	. 
	ex af,af'			;5eee	08 	. 
	ex af,af'			;5eef	08 	. 
	ex af,af'			;5ef0	08 	. 
	ex af,af'			;5ef1	08 	. 
	ld (bc),a			;5ef2	02 	. 
    
    ; LEVEL 3
	inc b			;5ef3	04 	. 
	inc b			;5ef4	04 	. 
	inc b			;5ef5	04 	. 
	inc b			;5ef6	04 	. 
	inc b			;5ef7	04 	. 
	inc b			;5ef8	04 	. 
	inc b			;5ef9	04 	. 
	inc b			;5efa	04 	. 
	inc b			;5efb	04 	. 
	inc b			;5efc	04 	. 
	inc b			;5efd	04 	. 
    ;
	add hl,bc			;5efe	09 	. 
	add hl,bc			;5eff	09 	. 
	add hl,bc			;5f00	09 	. 
	add hl,bc			;5f01	09 	. 
	add hl,bc			;5f02	09 	. 
	add hl,bc			;5f03	09 	. 
	add hl,bc			;5f04	09 	. 
	add hl,bc			;5f05	09 	. 
	nop			;5f06	00 	. 
	nop			;5f07	00 	. 
	nop			;5f08	00 	. 
    ;
	ld b,006h		;5f09	06 06 	. . 
	ld b,006h		;5f0b	06 06 	. . 
	ld b,006h		;5f0d	06 06 	. . 
	ld b,006h		;5f0f	06 06 	. . 
	ld b,006h		;5f11	06 06 	. . 
	ld b,005h		;5f13	06 05 	. . 
	dec b			;5f15	05 	. 
	dec b			;5f16	05 	. 
	add hl,bc			;5f17	09 	. 
	add hl,bc			;5f18	09 	. 
	add hl,bc			;5f19	09 	. 
	add hl,bc			;5f1a	09 	. 
	add hl,bc			;5f1b	09 	. 
	add hl,bc			;5f1c	09 	. 
	add hl,bc			;5f1d	09 	. 
	add hl,bc			;5f1e	09 	. 
	ld (bc),a			;5f1f	02 	. 
	ld (bc),a			;5f20	02 	. 
	ld (bc),a			;5f21	02 	. 
	ld (bc),a			;5f22	02 	. 
	ld (bc),a			;5f23	02 	. 
	ld (bc),a			;5f24	02 	. 
	ld (bc),a			;5f25	02 	. 
	ld (bc),a			;5f26	02 	. 
	ld (bc),a			;5f27	02 	. 
	ld (bc),a			;5f28	02 	. 
	ld (bc),a			;5f29	02 	. 
	add hl,bc			;5f2a	09 	. 
	add hl,bc			;5f2b	09 	. 
	add hl,bc			;5f2c	09 	. 
	add hl,bc			;5f2d	09 	. 
	add hl,bc			;5f2e	09 	. 
	add hl,bc			;5f2f	09 	. 
	add hl,bc			;5f30	09 	. 
	add hl,bc			;5f31	09 	. 
	ld (bc),a			;5f32	02 	. 
	ld (bc),a			;5f33	02 	. 
	ld (bc),a			;5f34	02 	. 
    
    ; LEVEL 4
	ex af,af'			;5f35	08 	. 
	dec b			;5f36	05 	. 
	ld b,007h		;5f37	06 07 	. . 
	ld bc,00302h		;5f39	01 02 03 	. . . 
	ex af,af'			;5f3c	08 	. 
	dec b			;5f3d	05 	. 
	ld b,007h		;5f3e	06 07 	. . 
	nop			;5f40	00 	. 
	ld (bc),a			;5f41	02 	. 
	inc bc			;5f42	03 	. 
	ex af,af'			;5f43	08 	. 
	dec b			;5f44	05 	. 
	ld b,007h		;5f45	06 07 	. . 
	nop			;5f47	00 	. 
	ld bc,00803h		;5f48	01 03 08 	. . . 
	dec b			;5f4b	05 	. 
	ld b,007h		;5f4c	06 07 	. . 
	nop			;5f4e	00 	. 
	ld bc,00802h		;5f4f	01 02 08 	. . . 
	dec b			;5f52	05 	. 
	ld b,007h		;5f53	06 07 	. . 
	nop			;5f55	00 	. 
	ld bc,00302h		;5f56	01 02 03 	. . . 
	dec b			;5f59	05 	. 
	ld b,007h		;5f5a	06 07 	. . 
	nop			;5f5c	00 	. 
	ld bc,00302h		;5f5d	01 02 03 	. . . 
	ex af,af'			;5f60	08 	. 
	ld b,007h		;5f61	06 07 	. . 
	nop			;5f63	00 	. 
	ld bc,00302h		;5f64	01 02 03 	. . . 
	ex af,af'			;5f67	08 	. 
	dec b			;5f68	05 	. 
	rlca			;5f69	07 	. 
	nop			;5f6a	00 	. 
	ld bc,00302h		;5f6b	01 02 03 	. . . 
	ex af,af'			;5f6e	08 	. 
	dec b			;5f6f	05 	. 
	ld b,000h		;5f70	06 00 	. . 
	ld bc,00302h		;5f72	01 02 03 	. . . 
	ex af,af'			;5f75	08 	. 
	dec b			;5f76	05 	. 
	ld b,007h		;5f77	06 07 	. . 
	ld bc,00302h		;5f79	01 02 03 	. . . 
	ex af,af'			;5f7c	08 	. 
	dec b			;5f7d	05 	. 
	ld b,007h		;5f7e	06 07 	. . 
	nop			;5f80	00 	. 
	ld (bc),a			;5f81	02 	. 
	inc bc			;5f82	03 	. 
	ex af,af'			;5f83	08 	. 
	dec b			;5f84	05 	. 
	rlca			;5f85	07 	. 
	rlca			;5f86	07 	. 
	rlca			;5f87	07 	. 
	rlca			;5f88	07 	. 
	ex af,af'			;5f89	08 	. 
	ex af,af'			;5f8a	08 	. 
	ex af,af'			;5f8b	08 	. 
	ex af,af'			;5f8c	08 	. 
	ex af,af'			;5f8d	08 	. 
	ex af,af'			;5f8e	08 	. 
	ex af,af'			;5f8f	08 	. 
	ex af,af'			;5f90	08 	. 
	ex af,af'			;5f91	08 	. 
	ex af,af'			;5f92	08 	. 
	ex af,af'			;5f93	08 	. 
	ex af,af'			;5f94	08 	. 
	inc b			;5f95	04 	. 
	ex af,af'			;5f96	08 	. 
	inc b			;5f97	04 	. 
	ex af,af'			;5f98	08 	. 
	ex af,af'			;5f99	08 	. 
	ex af,af'			;5f9a	08 	. 
	ex af,af'			;5f9b	08 	. 
	inc b			;5f9c	04 	. 
	ex af,af'			;5f9d	08 	. 
	inc b			;5f9e	04 	. 
	ex af,af'			;5f9f	08 	. 
	ex af,af'			;5fa0	08 	. 
	ex af,af'			;5fa1	08 	. 
	ex af,af'			;5fa2	08 	. 
	ex af,af'			;5fa3	08 	. 
	ex af,af'			;5fa4	08 	. 
	ex af,af'			;5fa5	08 	. 
	ex af,af'			;5fa6	08 	. 
	ex af,af'			;5fa7	08 	. 
	ex af,af'			;5fa8	08 	. 
	ex af,af'			;5fa9	08 	. 
	ex af,af'			;5faa	08 	. 
	ex af,af'			;5fab	08 	. 
	ex af,af'			;5fac	08 	. 
	ex af,af'			;5fad	08 	. 
	ex af,af'			;5fae	08 	. 
	ex af,af'			;5faf	08 	. 
	ex af,af'			;5fb0	08 	. 
	ex af,af'			;5fb1	08 	. 
	ex af,af'			;5fb2	08 	. 
	ex af,af'			;5fb3	08 	. 
	ex af,af'			;5fb4	08 	. 
	ex af,af'			;5fb5	08 	. 
	ex af,af'			;5fb6	08 	. 
	ex af,af'			;5fb7	08 	. 
	ex af,af'			;5fb8	08 	. 
	ex af,af'			;5fb9	08 	. 
	ex af,af'			;5fba	08 	. 
	ex af,af'			;5fbb	08 	. 
	ex af,af'			;5fbc	08 	. 
	ex af,af'			;5fbd	08 	. 
	ex af,af'			;5fbe	08 	. 
	ex af,af'			;5fbf	08 	. 
	ex af,af'			;5fc0	08 	. 
	ex af,af'			;5fc1	08 	. 
	ex af,af'			;5fc2	08 	. 
	ex af,af'			;5fc3	08 	. 
	dec b			;5fc4	05 	. 
	inc b			;5fc5	04 	. 
	inc bc			;5fc6	03 	. 
	inc bc			;5fc7	03 	. 
	inc b			;5fc8	04 	. 
	dec b			;5fc9	05 	. 
	dec b			;5fca	05 	. 
	inc b			;5fcb	04 	. 
	inc bc			;5fcc	03 	. 
	inc bc			;5fcd	03 	. 
	inc b			;5fce	04 	. 
	dec b			;5fcf	05 	. 
	dec b			;5fd0	05 	. 
	inc b			;5fd1	04 	. 
	inc bc			;5fd2	03 	. 
	inc bc			;5fd3	03 	. 
	inc b			;5fd4	04 	. 
	dec b			;5fd5	05 	. 
	dec b			;5fd6	05 	. 
	add hl,bc			;5fd7	09 	. 
	ld bc,00109h		;5fd8	01 09 01 	. . . 
	add hl,bc			;5fdb	09 	. 
	ld bc,00509h		;5fdc	01 09 05 	. . . 
	dec b			;5fdf	05 	. 
	inc b			;5fe0	04 	. 
	inc bc			;5fe1	03 	. 
	inc bc			;5fe2	03 	. 
	inc b			;5fe3	04 	. 
	dec b			;5fe4	05 	. 
	dec b			;5fe5	05 	. 
	inc b			;5fe6	04 	. 
	inc bc			;5fe7	03 	. 
	inc bc			;5fe8	03 	. 
	inc b			;5fe9	04 	. 
	dec b			;5fea	05 	. 
	dec b			;5feb	05 	. 
	inc b			;5fec	04 	. 
	inc bc			;5fed	03 	. 
	inc bc			;5fee	03 	. 
	inc b			;5fef	04 	. 
	dec b			;5ff0	05 	. 
	ld bc,00901h		;5ff1	01 01 09 	. . . 
	add hl,bc			;5ff4	09 	. 
	ld bc,00501h		;5ff5	01 01 05 	. . . 
	inc b			;5ff8	04 	. 
	inc bc			;5ff9	03 	. 
	inc bc			;5ffa	03 	. 
	inc b			;5ffb	04 	. 
	dec b			;5ffc	05 	. 
	dec b			;5ffd	05 	. 
	ld b,000h		;5ffe	06 00 	. . 
	dec b			;6000	05 	. 
	ld b,000h		;6001	06 00 	. . 
	rlca			;6003	07 	. 
	ld b,006h		;6004	06 06 	. . 
	nop			;6006	00 	. 
	rlca			;6007	07 	. 
	ld b,005h		;6008	06 05 	. . 
	ld b,000h		;600a	06 00 	. . 
	rlca			;600c	07 	. 
	ld b,005h		;600d	06 05 	. . 
	inc b			;600f	04 	. 
	inc bc			;6010	03 	. 
	nop			;6011	00 	. 
	rlca			;6012	07 	. 
	ld b,005h		;6013	06 05 	. . 
	inc b			;6015	04 	. 
	inc bc			;6016	03 	. 
	ld (bc),a			;6017	02 	. 
	rlca			;6018	07 	. 
	ld b,005h		;6019	06 05 	. . 
	inc b			;601b	04 	. 
	inc bc			;601c	03 	. 
	ld (bc),a			;601d	02 	. 
	ld bc,00506h		;601e	01 06 05 	. . . 
	inc b			;6021	04 	. 
	inc bc			;6022	03 	. 
	ld (bc),a			;6023	02 	. 
	ld bc,00400h		;6024	01 00 04 	. . . 
	inc bc			;6027	03 	. 
	ld (bc),a			;6028	02 	. 
	ld bc,00300h		;6029	01 00 03 	. . . 
	ld (bc),a			;602c	02 	. 
	ld bc,00700h		;602d	01 00 07 	. . . 
l6030h:
	ld bc,00700h		;6030	01 00 07 	. . . 
	add hl,bc			;6033	09 	. 
	add hl,bc			;6034	09 	. 
	add hl,bc			;6035	09 	. 
	add hl,bc			;6036	09 	. 
	add hl,bc			;6037	09 	. 
	add hl,bc			;6038	09 	. 
	add hl,bc			;6039	09 	. 
	add hl,bc			;603a	09 	. 
	nop			;603b	00 	. 
	add hl,bc			;603c	09 	. 
	ld bc,00909h		;603d	01 09 09 	. . . 
	ld (bc),a			;6040	02 	. 
	add hl,bc			;6041	09 	. 
	inc bc			;6042	03 	. 
	add hl,bc			;6043	09 	. 
	inc b			;6044	04 	. 
	add hl,bc			;6045	09 	. 
	add hl,bc			;6046	09 	. 
	dec b			;6047	05 	. 
	add hl,bc			;6048	09 	. 
	ld b,009h		;6049	06 09 	. . 
	add hl,bc			;604b	09 	. 
	add hl,bc			;604c	09 	. 
	add hl,bc			;604d	09 	. 
	add hl,bc			;604e	09 	. 
	add hl,bc			;604f	09 	. 
	add hl,bc			;6050	09 	. 
	add hl,bc			;6051	09 	. 
	add hl,bc			;6052	09 	. 
	add hl,bc			;6053	09 	. 
	add hl,bc			;6054	09 	. 
	add hl,bc			;6055	09 	. 
	add hl,bc			;6056	09 	. 
	inc bc			;6057	03 	. 
	add hl,bc			;6058	09 	. 
	add hl,bc			;6059	09 	. 
	inc bc			;605a	03 	. 
	add hl,bc			;605b	09 	. 
	add hl,bc			;605c	09 	. 
	ld (bc),a			;605d	02 	. 
	add hl,bc			;605e	09 	. 
	add hl,bc			;605f	09 	. 
	ld (bc),a			;6060	02 	. 
	add hl,bc			;6061	09 	. 
	add hl,bc			;6062	09 	. 
	add hl,bc			;6063	09 	. 
	add hl,bc			;6064	09 	. 
	add hl,bc			;6065	09 	. 
	add hl,bc			;6066	09 	. 
	add hl,bc			;6067	09 	. 
	ld b,000h		;6068	06 00 	. . 
	rlca			;606a	07 	. 
	ld b,001h		;606b	06 01 	. . 
	rlca			;606d	07 	. 
	ld b,002h		;606e	06 02 	. . 
	rlca			;6070	07 	. 
	ld b,003h		;6071	06 03 	. . 
	rlca			;6073	07 	. 
	ld b,004h		;6074	06 04 	. . 
	rlca			;6076	07 	. 
	ld b,005h		;6077	06 05 	. . 
	rlca			;6079	07 	. 
	add hl,bc			;607a	09 	. 
	add hl,bc			;607b	09 	. 
	add hl,bc			;607c	09 	. 
	add hl,bc			;607d	09 	. 
	add hl,bc			;607e	09 	. 
	add hl,bc			;607f	09 	. 
	add hl,bc			;6080	09 	. 
	add hl,bc			;6081	09 	. 
	add hl,bc			;6082	09 	. 
	add hl,bc			;6083	09 	. 
	add hl,bc			;6084	09 	. 
	dec b			;6085	05 	. 
	add hl,bc			;6086	09 	. 
	dec b			;6087	05 	. 
	ld (bc),a			;6088	02 	. 
	dec b			;6089	05 	. 
	add hl,bc			;608a	09 	. 
	dec b			;608b	05 	. 
	ld (bc),a			;608c	02 	. 
	nop			;608d	00 	. 
	ld (bc),a			;608e	02 	. 
	dec b			;608f	05 	. 
	add hl,bc			;6090	09 	. 
	dec b			;6091	05 	. 
	ld (bc),a			;6092	02 	. 
	nop			;6093	00 	. 
	ex af,af'			;6094	08 	. 
	nop			;6095	00 	. 
	ld (bc),a			;6096	02 	. 
	dec b			;6097	05 	. 
	add hl,bc			;6098	09 	. 
	dec b			;6099	05 	. 
	ld (bc),a			;609a	02 	. 
	nop			;609b	00 	. 
	ld (bc),a			;609c	02 	. 
	dec b			;609d	05 	. 
	add hl,bc			;609e	09 	. 
	dec b			;609f	05 	. 
	ld (bc),a			;60a0	02 	. 
	dec b			;60a1	05 	. 
	add hl,bc			;60a2	09 	. 
	dec b			;60a3	05 	. 
	add hl,bc			;60a4	09 	. 
	add hl,bc			;60a5	09 	. 
	add hl,bc			;60a6	09 	. 
	add hl,bc			;60a7	09 	. 
	add hl,bc			;60a8	09 	. 
	add hl,bc			;60a9	09 	. 
	add hl,bc			;60aa	09 	. 
	add hl,bc			;60ab	09 	. 
	add hl,bc			;60ac	09 	. 
	add hl,bc			;60ad	09 	. 
	add hl,bc			;60ae	09 	. 
	ex af,af'			;60af	08 	. 
	ex af,af'			;60b0	08 	. 
	ex af,af'			;60b1	08 	. 
	ex af,af'			;60b2	08 	. 
	ex af,af'			;60b3	08 	. 
	ex af,af'			;60b4	08 	. 
	ex af,af'			;60b5	08 	. 
	ex af,af'			;60b6	08 	. 
	ex af,af'			;60b7	08 	. 
	ex af,af'			;60b8	08 	. 
	ex af,af'			;60b9	08 	. 
	ex af,af'			;60ba	08 	. 
	ex af,af'			;60bb	08 	. 
	ex af,af'			;60bc	08 	. 
	ex af,af'			;60bd	08 	. 
	ex af,af'			;60be	08 	. 
	ex af,af'			;60bf	08 	. 
	ex af,af'			;60c0	08 	. 
	ex af,af'			;60c1	08 	. 
	ex af,af'			;60c2	08 	. 
	ex af,af'			;60c3	08 	. 
	ex af,af'			;60c4	08 	. 
	ex af,af'			;60c5	08 	. 
	ex af,af'			;60c6	08 	. 
	ex af,af'			;60c7	08 	. 
	ex af,af'			;60c8	08 	. 
	ex af,af'			;60c9	08 	. 
	ex af,af'			;60ca	08 	. 
	ex af,af'			;60cb	08 	. 
	ex af,af'			;60cc	08 	. 
	ex af,af'			;60cd	08 	. 
	ex af,af'			;60ce	08 	. 
	ex af,af'			;60cf	08 	. 
	ex af,af'			;60d0	08 	. 
	ex af,af'			;60d1	08 	. 
	ex af,af'			;60d2	08 	. 
	ex af,af'			;60d3	08 	. 
	ex af,af'			;60d4	08 	. 
	ex af,af'			;60d5	08 	. 
	ex af,af'			;60d6	08 	. 
	ex af,af'			;60d7	08 	. 
	ex af,af'			;60d8	08 	. 
	ex af,af'			;60d9	08 	. 
	ex af,af'			;60da	08 	. 
	ex af,af'			;60db	08 	. 
	ex af,af'			;60dc	08 	. 
	ex af,af'			;60dd	08 	. 
	ex af,af'			;60de	08 	. 
	ex af,af'			;60df	08 	. 
	add hl,bc			;60e0	09 	. 
	add hl,bc			;60e1	09 	. 
	add hl,bc			;60e2	09 	. 
sub_60e3h:
	add hl,bc			;60e3	09 	. 
	add hl,bc			;60e4	09 	. 
	add hl,bc			;60e5	09 	. 
	add hl,bc			;60e6	09 	. 
	add hl,bc			;60e7	09 	. 
	add hl,bc			;60e8	09 	. 
	add hl,bc			;60e9	09 	. 
	add hl,bc			;60ea	09 	. 
	add hl,bc			;60eb	09 	. 
	add hl,bc			;60ec	09 	. 
	ld b,009h		;60ed	06 09 	. . 
	nop			;60ef	00 	. 
	add hl,bc			;60f0	09 	. 
	add hl,bc			;60f1	09 	. 
	add hl,bc			;60f2	09 	. 
	add hl,bc			;60f3	09 	. 
	add hl,bc			;60f4	09 	. 
	add hl,bc			;60f5	09 	. 
	add hl,bc			;60f6	09 	. 
	add hl,bc			;60f7	09 	. 
	inc bc			;60f8	03 	. 
	add hl,bc			;60f9	09 	. 
	add hl,bc			;60fa	09 	. 
	add hl,bc			;60fb	09 	. 
	ld bc,00909h		;60fc	01 09 09 	. . . 
	dec b			;60ff	05 	. 
	add hl,bc			;6100	09 	. 
	add hl,bc			;6101	09 	. 
	add hl,bc			;6102	09 	. 
	inc b			;6103	04 	. 
	add hl,bc			;6104	09 	. 
	add hl,bc			;6105	09 	. 
	add hl,bc			;6106	09 	. 
	add hl,bc			;6107	09 	. 
	add hl,bc			;6108	09 	. 
	add hl,bc			;6109	09 	. 
	add hl,bc			;610a	09 	. 
	ld (bc),a			;610b	02 	. 
	add hl,bc			;610c	09 	. 
	add hl,bc			;610d	09 	. 
	add hl,bc			;610e	09 	. 
	rlca			;610f	07 	. 
	add hl,bc			;6110	09 	. 
	add hl,bc			;6111	09 	. 
	add hl,bc			;6112	09 	. 
	add hl,bc			;6113	09 	. 
	add hl,bc			;6114	09 	. 
	add hl,bc			;6115	09 	. 
	add hl,bc			;6116	09 	. 
	add hl,bc			;6117	09 	. 
	add hl,bc			;6118	09 	. 
	add hl,bc			;6119	09 	. 
	rlca			;611a	07 	. 
	rlca			;611b	07 	. 
	nop			;611c	00 	. 
	nop			;611d	00 	. 
	nop			;611e	00 	. 
	rlca			;611f	07 	. 
	rlca			;6120	07 	. 
	ld b,006h		;6121	06 06 	. . 
	ld bc,00101h		;6123	01 01 01 	. . . 
	ld b,006h		;6126	06 06 	. . 
	dec b			;6128	05 	. 
	dec b			;6129	05 	. 
	ld (bc),a			;612a	02 	. 
	ld (bc),a			;612b	02 	. 
	ld (bc),a			;612c	02 	. 
	dec b			;612d	05 	. 
	dec b			;612e	05 	. 
	inc b			;612f	04 	. 
	inc b			;6130	04 	. 
	inc bc			;6131	03 	. 
	inc bc			;6132	03 	. 
	inc bc			;6133	03 	. 
	inc b			;6134	04 	. 
	inc b			;6135	04 	. 
	inc bc			;6136	03 	. 
	inc bc			;6137	03 	. 
	inc b			;6138	04 	. 
	inc b			;6139	04 	. 
	inc b			;613a	04 	. 
	inc bc			;613b	03 	. 
	inc bc			;613c	03 	. 
	ld (bc),a			;613d	02 	. 
	ld (bc),a			;613e	02 	. 
	dec b			;613f	05 	. 
	dec b			;6140	05 	. 
	dec b			;6141	05 	. 
	ld (bc),a			;6142	02 	. 
	ld (bc),a			;6143	02 	. 
	ld bc,00601h		;6144	01 01 06 	. . . 
	ld b,006h		;6147	06 06 	. . 
	ld bc,00001h		;6149	01 01 00 	. . . 
	nop			;614c	00 	. 
	rlca			;614d	07 	. 
	rlca			;614e	07 	. 
	rlca			;614f	07 	. 
	nop			;6150	00 	. 
	nop			;6151	00 	. 
	ld (bc),a			;6152	02 	. 
	ex af,af'			;6153	08 	. 
	ex af,af'			;6154	08 	. 
	ex af,af'			;6155	08 	. 
	ex af,af'			;6156	08 	. 
	ex af,af'			;6157	08 	. 
	ex af,af'			;6158	08 	. 
	ex af,af'			;6159	08 	. 
	ex af,af'			;615a	08 	. 
	ex af,af'			;615b	08 	. 
	ld (bc),a			;615c	02 	. 
l615dh:
	add hl,bc			;615d	09 	. 
	add hl,bc			;615e	09 	. 
	dec b			;615f	05 	. 
	dec b			;6160	05 	. 
	dec b			;6161	05 	. 
	dec b			;6162	05 	. 
	dec b			;6163	05 	. 
	dec b			;6164	05 	. 
	dec b			;6165	05 	. 
	dec b			;6166	05 	. 
	dec b			;6167	05 	. 
	dec b			;6168	05 	. 
	dec b			;6169	05 	. 
	ld bc,00808h		;616a	01 08 08 	. . . 
	ex af,af'			;616d	08 	. 
	ex af,af'			;616e	08 	. 
	ex af,af'			;616f	08 	. 
	ex af,af'			;6170	08 	. 
	ex af,af'			;6171	08 	. 
	ex af,af'			;6172	08 	. 
	ex af,af'			;6173	08 	. 
	ld bc,00909h		;6174	01 09 09 	. . . 
	nop			;6177	00 	. 
	nop			;6178	00 	. 
	nop			;6179	00 	. 
	nop			;617a	00 	. 
	nop			;617b	00 	. 
	nop			;617c	00 	. 
	nop			;617d	00 	. 
	nop			;617e	00 	. 
	nop			;617f	00 	. 
	nop			;6180	00 	. 
	nop			;6181	00 	. 
	ld (bc),a			;6182	02 	. 
	ex af,af'			;6183	08 	. 
	ex af,af'			;6184	08 	. 
	ex af,af'			;6185	08 	. 
	ex af,af'			;6186	08 	. 
	ex af,af'			;6187	08 	. 
	ex af,af'			;6188	08 	. 
	ex af,af'			;6189	08 	. 
	ex af,af'			;618a	08 	. 
	ex af,af'			;618b	08 	. 
	ld (bc),a			;618c	02 	. 
	add hl,bc			;618d	09 	. 
	add hl,bc			;618e	09 	. 
	inc b			;618f	04 	. 
	inc b			;6190	04 	. 
	inc b			;6191	04 	. 
	inc b			;6192	04 	. 
	inc b			;6193	04 	. 
	inc b			;6194	04 	. 
	inc b			;6195	04 	. 
	inc b			;6196	04 	. 
	inc b			;6197	04 	. 
	inc b			;6198	04 	. 
	inc b			;6199	04 	. 
	ld (bc),a			;619a	02 	. 
	add hl,bc			;619b	09 	. 
	ld (bc),a			;619c	02 	. 
	ld (bc),a			;619d	02 	. 
	ld (bc),a			;619e	02 	. 
	ld (bc),a			;619f	02 	. 
	ld (bc),a			;61a0	02 	. 
	ld (bc),a			;61a1	02 	. 
	ld (bc),a			;61a2	02 	. 
	add hl,bc			;61a3	09 	. 
	ld (bc),a			;61a4	02 	. 
	ld (bc),a			;61a5	02 	. 
	nop			;61a6	00 	. 
	add hl,bc			;61a7	09 	. 
	ld (bc),a			;61a8	02 	. 
	ld (bc),a			;61a9	02 	. 
	ld (bc),a			;61aa	02 	. 
	ld (bc),a			;61ab	02 	. 
	ld (bc),a			;61ac	02 	. 
	add hl,bc			;61ad	09 	. 
	nop			;61ae	00 	. 
	ld (bc),a			;61af	02 	. 
	ld (bc),a			;61b0	02 	. 
	nop			;61b1	00 	. 
	rlca			;61b2	07 	. 
	add hl,bc			;61b3	09 	. 
	ld (bc),a			;61b4	02 	. 
	nop			;61b5	00 	. 
	ld (bc),a			;61b6	02 	. 
	add hl,bc			;61b7	09 	. 
	inc bc			;61b8	03 	. 
	nop			;61b9	00 	. 
	ld (bc),a			;61ba	02 	. 
	ld (bc),a			;61bb	02 	. 
	nop			;61bc	00 	. 
	rlca			;61bd	07 	. 
	rlca			;61be	07 	. 
	add hl,bc			;61bf	09 	. 
	nop			;61c0	00 	. 
	add hl,bc			;61c1	09 	. 
	inc bc			;61c2	03 	. 
	inc bc			;61c3	03 	. 
	nop			;61c4	00 	. 
	ld (bc),a			;61c5	02 	. 
	ld (bc),a			;61c6	02 	. 
	nop			;61c7	00 	. 
	rlca			;61c8	07 	. 
	rlca			;61c9	07 	. 
	rlca			;61ca	07 	. 
	nop			;61cb	00 	. 
	inc bc			;61cc	03 	. 
	inc bc			;61cd	03 	. 
	inc bc			;61ce	03 	. 
	nop			;61cf	00 	. 
	ld (bc),a			;61d0	02 	. 
	ld (bc),a			;61d1	02 	. 
	nop			;61d2	00 	. 
	rlca			;61d3	07 	. 
	rlca			;61d4	07 	. 
	rlca			;61d5	07 	. 
	nop			;61d6	00 	. 
	inc bc			;61d7	03 	. 
	inc bc			;61d8	03 	. 
	inc bc			;61d9	03 	. 
	nop			;61da	00 	. 
	ld (bc),a			;61db	02 	. 
	ld (bc),a			;61dc	02 	. 
	nop			;61dd	00 	. 
	rlca			;61de	07 	. 
	rlca			;61df	07 	. 
	rlca			;61e0	07 	. 
	nop			;61e1	00 	. 
	inc bc			;61e2	03 	. 
	inc bc			;61e3	03 	. 
	inc bc			;61e4	03 	. 
	nop			;61e5	00 	. 
	ld (bc),a			;61e6	02 	. 
	ld (bc),a			;61e7	02 	. 
	ex af,af'			;61e8	08 	. 
	rlca			;61e9	07 	. 
	rlca			;61ea	07 	. 
	rlca			;61eb	07 	. 
	nop			;61ec	00 	. 
	inc bc			;61ed	03 	. 
	inc bc			;61ee	03 	. 
	inc bc			;61ef	03 	. 
	ex af,af'			;61f0	08 	. 
	ld (bc),a			;61f1	02 	. 
	ld (bc),a			;61f2	02 	. 
	ld (bc),a			;61f3	02 	. 
	ex af,af'			;61f4	08 	. 
	rlca			;61f5	07 	. 
	rlca			;61f6	07 	. 
	nop			;61f7	00 	. 
	inc bc			;61f8	03 	. 
	inc bc			;61f9	03 	. 
	ex af,af'			;61fa	08 	. 
	ld (bc),a			;61fb	02 	. 
	ld (bc),a			;61fc	02 	. 
	ld (bc),a			;61fd	02 	. 
	ld (bc),a			;61fe	02 	. 
	ld (bc),a			;61ff	02 	. 
	ex af,af'			;6200	08 	. 
	rlca			;6201	07 	. 
	nop			;6202	00 	. 
	inc bc			;6203	03 	. 
	ex af,af'			;6204	08 	. 
	ld (bc),a			;6205	02 	. 
	ld (bc),a			;6206	02 	. 
	ld (bc),a			;6207	02 	. 
	ld (bc),a			;6208	02 	. 
	ld (bc),a			;6209	02 	. 
	ld (bc),a			;620a	02 	. 
	ld (bc),a			;620b	02 	. 
	ex af,af'			;620c	08 	. 
	nop			;620d	00 	. 
	ex af,af'			;620e	08 	. 
	ld (bc),a			;620f	02 	. 
	ld (bc),a			;6210	02 	. 
	ld (bc),a			;6211	02 	. 
	ld (bc),a			;6212	02 	. 
	add hl,bc			;6213	09 	. 
	ld bc,00101h		;6214	01 01 01 	. . . 
	ld bc,00101h		;6217	01 01 01 	. . . 
	add hl,bc			;621a	09 	. 
	ld bc,00101h		;621b	01 01 01 	. . . 
	rlca			;621e	07 	. 
	rlca			;621f	07 	. 
	rlca			;6220	07 	. 
	rlca			;6221	07 	. 
	ld bc,00707h		;6222	01 07 07 	. . . 
	add hl,bc			;6225	09 	. 
	rlca			;6226	07 	. 
	rlca			;6227	07 	. 
	rlca			;6228	07 	. 
	inc bc			;6229	03 	. 
	inc bc			;622a	03 	. 
	inc bc			;622b	03 	. 
	inc bc			;622c	03 	. 
	rlca			;622d	07 	. 
	inc bc			;622e	03 	. 
	inc bc			;622f	03 	. 
	add hl,bc			;6230	09 	. 
	inc bc			;6231	03 	. 
	inc bc			;6232	03 	. 
	inc bc			;6233	03 	. 
	inc b			;6234	04 	. 
	inc b			;6235	04 	. 
	inc b			;6236	04 	. 
	inc b			;6237	04 	. 
	inc bc			;6238	03 	. 
	inc b			;6239	04 	. 
	inc b			;623a	04 	. 
	add hl,bc			;623b	09 	. 
	inc b			;623c	04 	. 
	inc b			;623d	04 	. 
	inc b			;623e	04 	. 
	dec b			;623f	05 	. 
	dec b			;6240	05 	. 
	dec b			;6241	05 	. 
	dec b			;6242	05 	. 
	inc b			;6243	04 	. 
	dec b			;6244	05 	. 
	dec b			;6245	05 	. 
	dec b			;6246	05 	. 
	dec b			;6247	05 	. 
	dec b			;6248	05 	. 
	dec b			;6249	05 	. 
	ex af,af'			;624a	08 	. 
	dec b			;624b	05 	. 
	dec b			;624c	05 	. 
	ex af,af'			;624d	08 	. 
	inc bc			;624e	03 	. 
	inc bc			;624f	03 	. 
	dec b			;6250	05 	. 
	dec b			;6251	05 	. 
	nop			;6252	00 	. 
	nop			;6253	00 	. 
	nop			;6254	00 	. 
	inc bc			;6255	03 	. 
	inc bc			;6256	03 	. 
	dec b			;6257	05 	. 
	dec b			;6258	05 	. 
	nop			;6259	00 	. 
	nop			;625a	00 	. 
	nop			;625b	00 	. 
	nop			;625c	00 	. 
	nop			;625d	00 	. 
	inc bc			;625e	03 	. 
	inc bc			;625f	03 	. 
	dec b			;6260	05 	. 
	dec b			;6261	05 	. 
	nop			;6262	00 	. 
	nop			;6263	00 	. 
	nop			;6264	00 	. 
	nop			;6265	00 	. 
	nop			;6266	00 	. 
	inc bc			;6267	03 	. 
	inc bc			;6268	03 	. 
	dec b			;6269	05 	. 
	dec b			;626a	05 	. 
	nop			;626b	00 	. 
	nop			;626c	00 	. 
	nop			;626d	00 	. 
	nop			;626e	00 	. 
	nop			;626f	00 	. 
	inc bc			;6270	03 	. 
	inc bc			;6271	03 	. 
	ex af,af'			;6272	08 	. 
	ex af,af'			;6273	08 	. 
	ex af,af'			;6274	08 	. 
	ex af,af'			;6275	08 	. 
	ex af,af'			;6276	08 	. 
	ex af,af'			;6277	08 	. 
	ex af,af'			;6278	08 	. 
	add hl,bc			;6279	09 	. 
	add hl,bc			;627a	09 	. 
	add hl,bc			;627b	09 	. 
	add hl,bc			;627c	09 	. 
	add hl,bc			;627d	09 	. 
	add hl,bc			;627e	09 	. 
	ld bc,00709h		;627f	01 09 07 	. . . 
	rlca			;6282	07 	. 
	rlca			;6283	07 	. 
	rlca			;6284	07 	. 
	rlca			;6285	07 	. 
	add hl,bc			;6286	09 	. 
	ld bc,00901h		;6287	01 01 09 	. . . 
	add hl,bc			;628a	09 	. 
	rlca			;628b	07 	. 
	rlca			;628c	07 	. 
	rlca			;628d	07 	. 
	add hl,bc			;628e	09 	. 
	add hl,bc			;628f	09 	. 
	ld bc,00901h		;6290	01 01 09 	. . . 
	add hl,bc			;6293	09 	. 
	rlca			;6294	07 	. 
	add hl,bc			;6295	09 	. 
	add hl,bc			;6296	09 	. 
	ld bc,00901h		;6297	01 01 09 	. . . 
	inc bc			;629a	03 	. 
	ex af,af'			;629b	08 	. 
	inc bc			;629c	03 	. 
	add hl,bc			;629d	09 	. 
	ld bc,00901h		;629e	01 01 09 	. . . 
	inc bc			;62a1	03 	. 
	inc bc			;62a2	03 	. 
	add hl,bc			;62a3	09 	. 
	ld bc,00901h		;62a4	01 01 09 	. . . 
	inc bc			;62a7	03 	. 
	inc bc			;62a8	03 	. 
	add hl,bc			;62a9	09 	. 
	ld bc,00901h		;62aa	01 01 09 	. . . 
	inc bc			;62ad	03 	. 
	inc bc			;62ae	03 	. 
	add hl,bc			;62af	09 	. 
	ld bc,00901h		;62b0	01 01 09 	. . . 
	inc bc			;62b3	03 	. 
	inc bc			;62b4	03 	. 
	add hl,bc			;62b5	09 	. 
	ld bc,00901h		;62b6	01 01 09 	. . . 
	inc bc			;62b9	03 	. 
	inc bc			;62ba	03 	. 
	add hl,bc			;62bb	09 	. 
	ld bc,00901h		;62bc	01 01 09 	. . . 
	add hl,bc			;62bf	09 	. 
	add hl,bc			;62c0	09 	. 
	inc bc			;62c1	03 	. 
	inc bc			;62c2	03 	. 
	add hl,bc			;62c3	09 	. 
	add hl,bc			;62c4	09 	. 
	add hl,bc			;62c5	09 	. 
	ld bc,00909h		;62c6	01 09 09 	. . . 
	add hl,bc			;62c9	09 	. 
	add hl,bc			;62ca	09 	. 
	add hl,bc			;62cb	09 	. 
	add hl,bc			;62cc	09 	. 
	add hl,bc			;62cd	09 	. 
	inc bc			;62ce	03 	. 
	inc b			;62cf	04 	. 
	dec b			;62d0	05 	. 
	add hl,bc			;62d1	09 	. 
	dec b			;62d2	05 	. 
	inc b			;62d3	04 	. 
	inc bc			;62d4	03 	. 
	inc bc			;62d5	03 	. 
	inc b			;62d6	04 	. 
	dec b			;62d7	05 	. 
	add hl,bc			;62d8	09 	. 
	dec b			;62d9	05 	. 
	inc b			;62da	04 	. 
	inc bc			;62db	03 	. 
	inc bc			;62dc	03 	. 
	inc b			;62dd	04 	. 
	dec b			;62de	05 	. 
	add hl,bc			;62df	09 	. 
	dec b			;62e0	05 	. 
	inc b			;62e1	04 	. 
	inc bc			;62e2	03 	. 
	inc bc			;62e3	03 	. 
	inc b			;62e4	04 	. 
	dec b			;62e5	05 	. 
	rlca			;62e6	07 	. 
	dec b			;62e7	05 	. 
	inc b			;62e8	04 	. 
	inc bc			;62e9	03 	. 
	inc bc			;62ea	03 	. 
	inc b			;62eb	04 	. 
	dec b			;62ec	05 	. 
	add hl,bc			;62ed	09 	. 
	dec b			;62ee	05 	. 
	inc b			;62ef	04 	. 
	inc bc			;62f0	03 	. 
	inc bc			;62f1	03 	. 
	inc b			;62f2	04 	. 
	dec b			;62f3	05 	. 
	add hl,bc			;62f4	09 	. 
	dec b			;62f5	05 	. 
	inc b			;62f6	04 	. 
	inc bc			;62f7	03 	. 
	inc bc			;62f8	03 	. 
	inc b			;62f9	04 	. 
	dec b			;62fa	05 	. 
	add hl,bc			;62fb	09 	. 
	dec b			;62fc	05 	. 
	inc b			;62fd	04 	. 
	inc bc			;62fe	03 	. 
	add hl,bc			;62ff	09 	. 
	add hl,bc			;6300	09 	. 
	add hl,bc			;6301	09 	. 
	add hl,bc			;6302	09 	. 
	add hl,bc			;6303	09 	. 
	add hl,bc			;6304	09 	. 
	add hl,bc			;6305	09 	. 
	nop			;6306	00 	. 
	add hl,bc			;6307	09 	. 
	ld bc,00209h		;6308	01 09 02 	. . . 
	add hl,bc			;630b	09 	. 
	inc bc			;630c	03 	. 
	add hl,bc			;630d	09 	. 
	inc b			;630e	04 	. 
	add hl,bc			;630f	09 	. 
	dec b			;6310	05 	. 
	ld b,009h		;6311	06 09 	. . 
	ex af,af'			;6313	08 	. 
	add hl,bc			;6314	09 	. 
	ex af,af'			;6315	08 	. 
	add hl,bc			;6316	09 	. 
	ex af,af'			;6317	08 	. 
	add hl,bc			;6318	09 	. 
	ex af,af'			;6319	08 	. 
	add hl,bc			;631a	09 	. 
	rlca			;631b	07 	. 
	ld b,009h		;631c	06 09 	. . 
	add hl,bc			;631e	09 	. 
	ld b,009h		;631f	06 09 	. . 
	add hl,bc			;6321	09 	. 
	add hl,bc			;6322	09 	. 
	add hl,bc			;6323	09 	. 
	add hl,bc			;6324	09 	. 
	add hl,bc			;6325	09 	. 
	ld b,009h		;6326	06 09 	. . 
	add hl,bc			;6328	09 	. 
	add hl,bc			;6329	09 	. 
	add hl,bc			;632a	09 	. 
	add hl,bc			;632b	09 	. 
	add hl,bc			;632c	09 	. 
	ld b,009h		;632d	06 09 	. . 
	ld b,009h		;632f	06 09 	. . 
	add hl,bc			;6331	09 	. 
	ld b,009h		;6332	06 09 	. . 
	add hl,bc			;6334	09 	. 
	add hl,bc			;6335	09 	. 
	ld b,009h		;6336	06 09 	. . 
	add hl,bc			;6338	09 	. 
	add hl,bc			;6339	09 	. 
	ld b,009h		;633a	06 09 	. . 
	add hl,bc			;633c	09 	. 
	ld bc,00101h		;633d	01 01 01 	. . . 
	ld bc,00101h		;6340	01 01 01 	. . . 
	ld bc,00909h		;6343	01 09 09 	. . . 
	add hl,bc			;6346	09 	. 
	add hl,bc			;6347	09 	. 
	add hl,bc			;6348	09 	. 
	add hl,bc			;6349	09 	. 
	add hl,bc			;634a	09 	. 
	add hl,bc			;634b	09 	. 
	add hl,bc			;634c	09 	. 
	add hl,bc			;634d	09 	. 
	add hl,bc			;634e	09 	. 
	add hl,bc			;634f	09 	. 
	add hl,bc			;6350	09 	. 
	add hl,bc			;6351	09 	. 
	add hl,bc			;6352	09 	. 
	add hl,bc			;6353	09 	. 
	inc bc			;6354	03 	. 
	add hl,bc			;6355	09 	. 
	add hl,bc			;6356	09 	. 
	add hl,bc			;6357	09 	. 
	add hl,bc			;6358	09 	. 
	dec b			;6359	05 	. 
	add hl,bc			;635a	09 	. 
	add hl,bc			;635b	09 	. 
	add hl,bc			;635c	09 	. 
	add hl,bc			;635d	09 	. 
	add hl,bc			;635e	09 	. 
	add hl,bc			;635f	09 	. 
	add hl,bc			;6360	09 	. 
	add hl,bc			;6361	09 	. 
	ld (bc),a			;6362	02 	. 
	ld (bc),a			;6363	02 	. 
	ld (bc),a			;6364	02 	. 
	add hl,bc			;6365	09 	. 
	add hl,bc			;6366	09 	. 
	add hl,bc			;6367	09 	. 
	add hl,bc			;6368	09 	. 
	add hl,bc			;6369	09 	. 
	add hl,bc			;636a	09 	. 
	add hl,bc			;636b	09 	. 
	add hl,bc			;636c	09 	. 
	add hl,bc			;636d	09 	. 
	add hl,bc			;636e	09 	. 
	add hl,bc			;636f	09 	. 
	add hl,bc			;6370	09 	. 
	add hl,bc			;6371	09 	. 
	add hl,bc			;6372	09 	. 
	add hl,bc			;6373	09 	. 
	rlca			;6374	07 	. 
	rlca			;6375	07 	. 
	rlca			;6376	07 	. 
	rlca			;6377	07 	. 
	rlca			;6378	07 	. 
	rlca			;6379	07 	. 
	rlca			;637a	07 	. 
	rlca			;637b	07 	. 
	rlca			;637c	07 	. 
	rlca			;637d	07 	. 
	rlca			;637e	07 	. 
	rlca			;637f	07 	. 
	rlca			;6380	07 	. 
	rlca			;6381	07 	. 
	rlca			;6382	07 	. 
	rlca			;6383	07 	. 
	rlca			;6384	07 	. 
	rlca			;6385	07 	. 
	rlca			;6386	07 	. 
	rlca			;6387	07 	. 
	rlca			;6388	07 	. 
	rlca			;6389	07 	. 
	inc b			;638a	04 	. 
	add hl,bc			;638b	09 	. 
	add hl,bc			;638c	09 	. 
	inc b			;638d	04 	. 
	inc b			;638e	04 	. 
	inc b			;638f	04 	. 
	add hl,bc			;6390	09 	. 
	add hl,bc			;6391	09 	. 
	inc b			;6392	04 	. 
	inc b			;6393	04 	. 
	add hl,bc			;6394	09 	. 
	add hl,bc			;6395	09 	. 
	inc b			;6396	04 	. 
	inc b			;6397	04 	. 
	inc b			;6398	04 	. 
	add hl,bc			;6399	09 	. 
	add hl,bc			;639a	09 	. 
	inc b			;639b	04 	. 
	inc b			;639c	04 	. 
	add hl,bc			;639d	09 	. 
	add hl,bc			;639e	09 	. 
	inc b			;639f	04 	. 
	inc b			;63a0	04 	. 
	inc b			;63a1	04 	. 
	add hl,bc			;63a2	09 	. 
	add hl,bc			;63a3	09 	. 
	inc b			;63a4	04 	. 
	inc b			;63a5	04 	. 
	add hl,bc			;63a6	09 	. 
	add hl,bc			;63a7	09 	. 
	inc b			;63a8	04 	. 
	inc b			;63a9	04 	. 
	inc b			;63aa	04 	. 
	add hl,bc			;63ab	09 	. 
	add hl,bc			;63ac	09 	. 
	inc b			;63ad	04 	. 
	nop			;63ae	00 	. 
	nop			;63af	00 	. 
	nop			;63b0	00 	. 
	nop			;63b1	00 	. 
	nop			;63b2	00 	. 
	nop			;63b3	00 	. 
	nop			;63b4	00 	. 
	nop			;63b5	00 	. 
	nop			;63b6	00 	. 
	nop			;63b7	00 	. 
	nop			;63b8	00 	. 
	nop			;63b9	00 	. 
	nop			;63ba	00 	. 
	nop			;63bb	00 	. 
	nop			;63bc	00 	. 
	nop			;63bd	00 	. 
	nop			;63be	00 	. 
	nop			;63bf	00 	. 
	nop			;63c0	00 	. 
	nop			;63c1	00 	. 
	nop			;63c2	00 	. 
	nop			;63c3	00 	. 
	ld (bc),a			;63c4	02 	. 
	ld (bc),a			;63c5	02 	. 
	ld (bc),a			;63c6	02 	. 
	ld (bc),a			;63c7	02 	. 
	ld (bc),a			;63c8	02 	. 
	ld (bc),a			;63c9	02 	. 
	ld (bc),a			;63ca	02 	. 
	ld (bc),a			;63cb	02 	. 
	ld (bc),a			;63cc	02 	. 
	ld (bc),a			;63cd	02 	. 
	ld (bc),a			;63ce	02 	. 
	ex af,af'			;63cf	08 	. 
	inc bc			;63d0	03 	. 
	ex af,af'			;63d1	08 	. 
	inc bc			;63d2	03 	. 
	ex af,af'			;63d3	08 	. 
	inc bc			;63d4	03 	. 
	ex af,af'			;63d5	08 	. 
	ex af,af'			;63d6	08 	. 
	ex af,af'			;63d7	08 	. 
	ex af,af'			;63d8	08 	. 
	ex af,af'			;63d9	08 	. 
	ex af,af'			;63da	08 	. 
	ex af,af'			;63db	08 	. 
	inc b			;63dc	04 	. 
	ex af,af'			;63dd	08 	. 
	inc b			;63de	04 	. 
	ex af,af'			;63df	08 	. 
	inc b			;63e0	04 	. 
	ex af,af'			;63e1	08 	. 
	ex af,af'			;63e2	08 	. 
	ex af,af'			;63e3	08 	. 
	ex af,af'			;63e4	08 	. 
	ex af,af'			;63e5	08 	. 
	ex af,af'			;63e6	08 	. 
	ex af,af'			;63e7	08 	. 
	dec b			;63e8	05 	. 
	ex af,af'			;63e9	08 	. 
	dec b			;63ea	05 	. 
	ex af,af'			;63eb	08 	. 
	dec b			;63ec	05 	. 
	ex af,af'			;63ed	08 	. 
	ex af,af'			;63ee	08 	. 
	ex af,af'			;63ef	08 	. 
	ex af,af'			;63f0	08 	. 
	ex af,af'			;63f1	08 	. 
	ex af,af'			;63f2	08 	. 
	nop			;63f3	00 	. 
	nop			;63f4	00 	. 
	nop			;63f5	00 	. 
	nop			;63f6	00 	. 
	nop			;63f7	00 	. 
	nop			;63f8	00 	. 
	nop			;63f9	00 	. 
	nop			;63fa	00 	. 
	nop			;63fb	00 	. 
	nop			;63fc	00 	. 
	dec b			;63fd	05 	. 
	nop			;63fe	00 	. 
	dec b			;63ff	05 	. 
	nop			;6400	00 	. 
	dec b			;6401	05 	. 
	dec b			;6402	05 	. 
	dec b			;6403	05 	. 
	dec b			;6404	05 	. 
	dec b			;6405	05 	. 
	dec b			;6406	05 	. 
	dec b			;6407	05 	. 
	dec b			;6408	05 	. 
	dec b			;6409	05 	. 
	dec b			;640a	05 	. 
	dec b			;640b	05 	. 
	dec b			;640c	05 	. 
	dec b			;640d	05 	. 
	dec b			;640e	05 	. 
	dec b			;640f	05 	. 
	dec b			;6410	05 	. 
	dec b			;6411	05 	. 
	dec b			;6412	05 	. 
	dec b			;6413	05 	. 
	dec b			;6414	05 	. 
	dec b			;6415	05 	. 
	dec b			;6416	05 	. 
	dec b			;6417	05 	. 
	dec b			;6418	05 	. 
	dec b			;6419	05 	. 
	dec b			;641a	05 	. 
	dec b			;641b	05 	. 
	dec b			;641c	05 	. 
	dec b			;641d	05 	. 
	dec b			;641e	05 	. 
	dec b			;641f	05 	. 
	dec b			;6420	05 	. 
	dec b			;6421	05 	. 
	dec b			;6422	05 	. 
	dec b			;6423	05 	. 
	dec b			;6424	05 	. 
	dec b			;6425	05 	. 
	dec b			;6426	05 	. 
	dec b			;6427	05 	. 
	inc bc			;6428	03 	. 
	inc bc			;6429	03 	. 
	inc bc			;642a	03 	. 
	inc bc			;642b	03 	. 
	inc bc			;642c	03 	. 
	inc bc			;642d	03 	. 
	inc bc			;642e	03 	. 
	inc bc			;642f	03 	. 
	inc bc			;6430	03 	. 
	inc bc			;6431	03 	. 
	inc bc			;6432	03 	. 
	dec b			;6433	05 	. 
	dec b			;6434	05 	. 
	dec b			;6435	05 	. 
	dec b			;6436	05 	. 
	dec b			;6437	05 	. 
	dec b			;6438	05 	. 
	dec b			;6439	05 	. 
	dec b			;643a	05 	. 
	dec b			;643b	05 	. 
	dec b			;643c	05 	. 
	dec b			;643d	05 	. 
	add hl,bc			;643e	09 	. 
	add hl,bc			;643f	09 	. 
	add hl,bc			;6440	09 	. 
	add hl,bc			;6441	09 	. 
	ex af,af'			;6442	08 	. 
	ex af,af'			;6443	08 	. 
	ex af,af'			;6444	08 	. 
	add hl,bc			;6445	09 	. 
	add hl,bc			;6446	09 	. 
	add hl,bc			;6447	09 	. 
	add hl,bc			;6448	09 	. 
	add hl,bc			;6449	09 	. 
	inc b			;644a	04 	. 
	inc b			;644b	04 	. 
	add hl,bc			;644c	09 	. 
	add hl,bc			;644d	09 	. 
	dec b			;644e	05 	. 
	dec b			;644f	05 	. 
	add hl,bc			;6450	09 	. 
	add hl,bc			;6451	09 	. 
	add hl,bc			;6452	09 	. 
	add hl,bc			;6453	09 	. 
	add hl,bc			;6454	09 	. 
	add hl,bc			;6455	09 	. 
	add hl,bc			;6456	09 	. 
	add hl,bc			;6457	09 	. 
	add hl,bc			;6458	09 	. 
	inc bc			;6459	03 	. 
	inc bc			;645a	03 	. 
	inc bc			;645b	03 	. 
	add hl,bc			;645c	09 	. 
	add hl,bc			;645d	09 	. 
	add hl,bc			;645e	09 	. 
	ex af,af'			;645f	08 	. 
	ex af,af'			;6460	08 	. 
	add hl,bc			;6461	09 	. 
	add hl,bc			;6462	09 	. 
	add hl,bc			;6463	09 	. 
	add hl,bc			;6464	09 	. 
	add hl,bc			;6465	09 	. 
	ex af,af'			;6466	08 	. 
	ex af,af'			;6467	08 	. 
	add hl,bc			;6468	09 	. 
	add hl,bc			;6469	09 	. 
	ex af,af'			;646a	08 	. 
	ex af,af'			;646b	08 	. 
	add hl,bc			;646c	09 	. 
	add hl,bc			;646d	09 	. 
	add hl,bc			;646e	09 	. 
	add hl,bc			;646f	09 	. 
	ld (bc),a			;6470	02 	. 
	ld (bc),a			;6471	02 	. 
	add hl,bc			;6472	09 	. 
	add hl,bc			;6473	09 	. 
	dec b			;6474	05 	. 
	dec b			;6475	05 	. 
	dec b			;6476	05 	. 
	dec b			;6477	05 	. 
	add hl,bc			;6478	09 	. 
	add hl,bc			;6479	09 	. 
	ld b,006h		;647a	06 06 	. . 
	add hl,bc			;647c	09 	. 
	add hl,bc			;647d	09 	. 
	add hl,bc			;647e	09 	. 
	add hl,bc			;647f	09 	. 
	add hl,bc			;6480	09 	. 
	add hl,bc			;6481	09 	. 
	add hl,bc			;6482	09 	. 
	ex af,af'			;6483	08 	. 
	ex af,af'			;6484	08 	. 
	ex af,af'			;6485	08 	. 
	ex af,af'			;6486	08 	. 
	ex af,af'			;6487	08 	. 
	ex af,af'			;6488	08 	. 
	ex af,af'			;6489	08 	. 
	ex af,af'			;648a	08 	. 
	ex af,af'			;648b	08 	. 
	ex af,af'			;648c	08 	. 
	ex af,af'			;648d	08 	. 
	rlca			;648e	07 	. 
	rlca			;648f	07 	. 
	rlca			;6490	07 	. 
	rlca			;6491	07 	. 
	rlca			;6492	07 	. 
	rlca			;6493	07 	. 
	rlca			;6494	07 	. 
	rlca			;6495	07 	. 
	rlca			;6496	07 	. 
	rlca			;6497	07 	. 
	rlca			;6498	07 	. 
	ex af,af'			;6499	08 	. 
	ex af,af'			;649a	08 	. 
	ex af,af'			;649b	08 	. 
	ex af,af'			;649c	08 	. 
	ex af,af'			;649d	08 	. 
	ex af,af'			;649e	08 	. 
	ex af,af'			;649f	08 	. 
	ex af,af'			;64a0	08 	. 
	ex af,af'			;64a1	08 	. 
	ex af,af'			;64a2	08 	. 
	ex af,af'			;64a3	08 	. 
	ex af,af'			;64a4	08 	. 
	ex af,af'			;64a5	08 	. 
	ex af,af'			;64a6	08 	. 
	ex af,af'			;64a7	08 	. 
	ex af,af'			;64a8	08 	. 
	ex af,af'			;64a9	08 	. 
	ex af,af'			;64aa	08 	. 
	ex af,af'			;64ab	08 	. 
	ex af,af'			;64ac	08 	. 
	ex af,af'			;64ad	08 	. 
	ex af,af'			;64ae	08 	. 
	inc b			;64af	04 	. 
	inc b			;64b0	04 	. 
	inc b			;64b1	04 	. 
	inc b			;64b2	04 	. 
	inc b			;64b3	04 	. 
	inc b			;64b4	04 	. 
	inc b			;64b5	04 	. 
	inc b			;64b6	04 	. 
	inc b			;64b7	04 	. 
	inc b			;64b8	04 	. 
	inc b			;64b9	04 	. 
	ex af,af'			;64ba	08 	. 
	ex af,af'			;64bb	08 	. 
	ex af,af'			;64bc	08 	. 
	ex af,af'			;64bd	08 	. 
	ex af,af'			;64be	08 	. 
	ex af,af'			;64bf	08 	. 
	ex af,af'			;64c0	08 	. 
	ex af,af'			;64c1	08 	. 
	ex af,af'			;64c2	08 	. 
	ex af,af'			;64c3	08 	. 
	ex af,af'			;64c4	08 	. 
	dec b			;64c5	05 	. 
	dec b			;64c6	05 	. 
	dec b			;64c7	05 	. 
	dec b			;64c8	05 	. 
	dec b			;64c9	05 	. 
	dec b			;64ca	05 	. 
	dec b			;64cb	05 	. 
	dec b			;64cc	05 	. 
	dec b			;64cd	05 	. 
	dec b			;64ce	05 	. 
	dec b			;64cf	05 	. 
	dec b			;64d0	05 	. 
	add hl,bc			;64d1	09 	. 
	add hl,bc			;64d2	09 	. 
	add hl,bc			;64d3	09 	. 
	ld b,009h		;64d4	06 09 	. . 
	ld b,009h		;64d6	06 09 	. . 
	add hl,bc			;64d8	09 	. 
	add hl,bc			;64d9	09 	. 
	dec b			;64da	05 	. 
	dec b			;64db	05 	. 
	add hl,bc			;64dc	09 	. 
	add hl,bc			;64dd	09 	. 
	dec b			;64de	05 	. 
	dec b			;64df	05 	. 
	add hl,bc			;64e0	09 	. 
	ld b,006h		;64e1	06 06 	. . 
	add hl,bc			;64e3	09 	. 
	dec b			;64e4	05 	. 
	dec b			;64e5	05 	. 
	add hl,bc			;64e6	09 	. 
	ld b,006h		;64e7	06 06 	. . 
	ld b,006h		;64e9	06 06 	. . 
	add hl,bc			;64eb	09 	. 
	dec b			;64ec	05 	. 
	dec b			;64ed	05 	. 
	add hl,bc			;64ee	09 	. 
	ld b,006h		;64ef	06 06 	. . 
	ld b,006h		;64f1	06 06 	. . 
	add hl,bc			;64f3	09 	. 
	dec b			;64f4	05 	. 
	dec b			;64f5	05 	. 
	add hl,bc			;64f6	09 	. 
	ld b,006h		;64f7	06 06 	. . 
	ld b,009h		;64f9	06 09 	. . 
	dec b			;64fb	05 	. 
	dec b			;64fc	05 	. 
	add hl,bc			;64fd	09 	. 
	ld b,009h		;64fe	06 09 	. . 
	dec b			;6500	05 	. 
	dec b			;6501	05 	. 
	ld b,005h		;6502	06 05 	. . 
	dec b			;6504	05 	. 
	rlca			;6505	07 	. 
	rlca			;6506	07 	. 
	rlca			;6507	07 	. 
	rlca			;6508	07 	. 
	add hl,bc			;6509	09 	. 
	add hl,bc			;650a	09 	. 
	rlca			;650b	07 	. 
	rlca			;650c	07 	. 
	rlca			;650d	07 	. 
	rlca			;650e	07 	. 
	ld b,006h		;650f	06 06 	. . 
	ld b,006h		;6511	06 06 	. . 
	add hl,bc			;6513	09 	. 
	add hl,bc			;6514	09 	. 
	ld b,006h		;6515	06 06 	. . 
	ld b,006h		;6517	06 06 	. . 
	dec b			;6519	05 	. 
	dec b			;651a	05 	. 
	dec b			;651b	05 	. 
	dec b			;651c	05 	. 
	add hl,bc			;651d	09 	. 
	add hl,bc			;651e	09 	. 
	dec b			;651f	05 	. 
	dec b			;6520	05 	. 
	dec b			;6521	05 	. 
	dec b			;6522	05 	. 
	add hl,bc			;6523	09 	. 
	nop			;6524	00 	. 
	nop			;6525	00 	. 
	add hl,bc			;6526	09 	. 
	add hl,bc			;6527	09 	. 
	add hl,bc			;6528	09 	. 
	add hl,bc			;6529	09 	. 
	nop			;652a	00 	. 
	nop			;652b	00 	. 
	add hl,bc			;652c	09 	. 
	inc b			;652d	04 	. 
	inc b			;652e	04 	. 
	inc b			;652f	04 	. 
	inc b			;6530	04 	. 
	add hl,bc			;6531	09 	. 
	add hl,bc			;6532	09 	. 
	inc b			;6533	04 	. 
	inc b			;6534	04 	. 
	inc b			;6535	04 	. 
	inc b			;6536	04 	. 
	inc bc			;6537	03 	. 
	inc bc			;6538	03 	. 
	inc bc			;6539	03 	. 
	inc bc			;653a	03 	. 
	add hl,bc			;653b	09 	. 
	add hl,bc			;653c	09 	. 
	inc bc			;653d	03 	. 
	inc bc			;653e	03 	. 
	inc bc			;653f	03 	. 
	inc bc			;6540	03 	. 
	ex af,af'			;6541	08 	. 
	nop			;6542	00 	. 
	nop			;6543	00 	. 
	ex af,af'			;6544	08 	. 
	add hl,bc			;6545	09 	. 
	add hl,bc			;6546	09 	. 
	ex af,af'			;6547	08 	. 
	nop			;6548	00 	. 
	nop			;6549	00 	. 
	ex af,af'			;654a	08 	. 
	ld (bc),a			;654b	02 	. 
	ld (bc),a			;654c	02 	. 
	ld (bc),a			;654d	02 	. 
	ld (bc),a			;654e	02 	. 
	add hl,bc			;654f	09 	. 
	add hl,bc			;6550	09 	. 
	ld (bc),a			;6551	02 	. 
	ld (bc),a			;6552	02 	. 
	ld (bc),a			;6553	02 	. 
	ld (bc),a			;6554	02 	. 
	ld bc,00101h		;6555	01 01 01 	. . . 
	ld bc,00909h		;6558	01 09 09 	. . . 
	ld bc,00101h		;655b	01 01 01 	. . . 
	ld bc,00000h		;655e	01 00 00 	. . . 
	nop			;6561	00 	. 
	nop			;6562	00 	. 
	add hl,bc			;6563	09 	. 
	add hl,bc			;6564	09 	. 
	nop			;6565	00 	. 
	nop			;6566	00 	. 
	nop			;6567	00 	. 
	nop			;6568	00 	. 
	dec b			;6569	05 	. 
	inc b			;656a	04 	. 
	dec b			;656b	05 	. 
	inc b			;656c	04 	. 
	inc bc			;656d	03 	. 
	ld (bc),a			;656e	02 	. 
	dec b			;656f	05 	. 
	inc b			;6570	04 	. 
	inc bc			;6571	03 	. 
	ld (bc),a			;6572	02 	. 
	ld bc,00500h		;6573	01 00 05 	. . . 
	inc b			;6576	04 	. 
	inc bc			;6577	03 	. 
	ld (bc),a			;6578	02 	. 
	ld bc,00700h		;6579	01 00 07 	. . . 
	ld b,008h		;657c	06 08 	. . 
	inc b			;657e	04 	. 
	inc bc			;657f	03 	. 
	ld (bc),a			;6580	02 	. 
	ld bc,00700h		;6581	01 00 07 	. . . 
	ld b,005h		;6584	06 05 	. . 
	inc b			;6586	04 	. 
	add hl,bc			;6587	09 	. 
	ex af,af'			;6588	08 	. 
	ld (bc),a			;6589	02 	. 
	ld bc,00700h		;658a	01 00 07 	. . . 
	ld b,005h		;658d	06 05 	. . 
	inc b			;658f	04 	. 
	inc bc			;6590	03 	. 
	add hl,bc			;6591	09 	. 
	ex af,af'			;6592	08 	. 
	nop			;6593	00 	. 
	rlca			;6594	07 	. 
	ld b,005h		;6595	06 05 	. . 
	inc b			;6597	04 	. 
	inc bc			;6598	03 	. 
	add hl,bc			;6599	09 	. 
	ex af,af'			;659a	08 	. 
	ld b,005h		;659b	06 05 	. . 
	inc b			;659d	04 	. 
	inc bc			;659e	03 	. 
	add hl,bc			;659f	09 	. 
	ex af,af'			;65a0	08 	. 
	inc b			;65a1	04 	. 
	inc bc			;65a2	03 	. 
	add hl,bc			;65a3	09 	. 
	ex af,af'			;65a4	08 	. 
	ld (bc),a			;65a5	02 	. 
	inc bc			;65a6	03 	. 
	inc b			;65a7	04 	. 
	dec b			;65a8	05 	. 
	ld b,007h		;65a9	06 07 	. . 
	ex af,af'			;65ab	08 	. 
	ex af,af'			;65ac	08 	. 
	ex af,af'			;65ad	08 	. 
	ex af,af'			;65ae	08 	. 
	ex af,af'			;65af	08 	. 
	ex af,af'			;65b0	08 	. 
	ld b,005h		;65b1	06 05 	. . 
	inc b			;65b3	04 	. 
	inc bc			;65b4	03 	. 
	ld (bc),a			;65b5	02 	. 
	ex af,af'			;65b6	08 	. 
	ex af,af'			;65b7	08 	. 
	ex af,af'			;65b8	08 	. 
	ex af,af'			;65b9	08 	. 
	ex af,af'			;65ba	08 	. 
	ld bc,00302h		;65bb	01 02 03 	. . . 
	inc b			;65be	04 	. 
	dec b			;65bf	05 	. 
	ld b,008h		;65c0	06 08 	. . 
	ex af,af'			;65c2	08 	. 
	ex af,af'			;65c3	08 	. 
	ex af,af'			;65c4	08 	. 
	ex af,af'			;65c5	08 	. 
	ex af,af'			;65c6	08 	. 
	rlca			;65c7	07 	. 
	ld b,005h		;65c8	06 05 	. . 
	inc b			;65ca	04 	. 
	inc bc			;65cb	03 	. 
	ex af,af'			;65cc	08 	. 
	ex af,af'			;65cd	08 	. 
	ex af,af'			;65ce	08 	. 
	ex af,af'			;65cf	08 	. 
	ex af,af'			;65d0	08 	. 
	nop			;65d1	00 	. 
	ld bc,00302h		;65d2	01 02 03 	. . . 
	inc b			;65d5	04 	. 
	dec b			;65d6	05 	. 
	ex af,af'			;65d7	08 	. 
	ex af,af'			;65d8	08 	. 
	ex af,af'			;65d9	08 	. 
	ex af,af'			;65da	08 	. 
	ex af,af'			;65db	08 	. 
	ex af,af'			;65dc	08 	. 
	add hl,bc			;65dd	09 	. 
	add hl,bc			;65de	09 	. 
	add hl,bc			;65df	09 	. 
	add hl,bc			;65e0	09 	. 
	add hl,bc			;65e1	09 	. 
	add hl,bc			;65e2	09 	. 
	add hl,bc			;65e3	09 	. 
	add hl,bc			;65e4	09 	. 
	add hl,bc			;65e5	09 	. 
	add hl,bc			;65e6	09 	. 
	add hl,bc			;65e7	09 	. 
	add hl,bc			;65e8	09 	. 
	add hl,bc			;65e9	09 	. 
	add hl,bc			;65ea	09 	. 
	add hl,bc			;65eb	09 	. 
	inc b			;65ec	04 	. 
	inc b			;65ed	04 	. 
	add hl,bc			;65ee	09 	. 
	add hl,bc			;65ef	09 	. 
	add hl,bc			;65f0	09 	. 
	add hl,bc			;65f1	09 	. 
	add hl,bc			;65f2	09 	. 
	add hl,bc			;65f3	09 	. 
	dec b			;65f4	05 	. 
	dec b			;65f5	05 	. 
	dec b			;65f6	05 	. 
	dec b			;65f7	05 	. 
	add hl,bc			;65f8	09 	. 
	add hl,bc			;65f9	09 	. 
	add hl,bc			;65fa	09 	. 
	add hl,bc			;65fb	09 	. 
	add hl,bc			;65fc	09 	. 
	ld b,006h		;65fd	06 06 	. . 
	ld b,006h		;65ff	06 06 	. . 
	ld b,006h		;6601	06 06 	. . 
	add hl,bc			;6603	09 	. 
	add hl,bc			;6604	09 	. 
	add hl,bc			;6605	09 	. 
	add hl,bc			;6606	09 	. 
	rlca			;6607	07 	. 
	rlca			;6608	07 	. 
	rlca			;6609	07 	. 
	rlca			;660a	07 	. 
	rlca			;660b	07 	. 
	rlca			;660c	07 	. 
	rlca			;660d	07 	. 
	ex af,af'			;660e	08 	. 
	ex af,af'			;660f	08 	. 
	ex af,af'			;6610	08 	. 
	ex af,af'			;6611	08 	. 
	ex af,af'			;6612	08 	. 
	ex af,af'			;6613	08 	. 
	ex af,af'			;6614	08 	. 
	nop			;6615	00 	. 
	nop			;6616	00 	. 
	inc bc			;6617	03 	. 
	rst 38h			;6618	ff 	. 
	rst 38h			;6619	ff 	. 
	rst 38h			;661a	ff 	. 
	rst 38h			;661b	ff 	. 
	rst 38h			;661c	ff 	. 
	rst 38h			;661d	ff 	. 
	rst 38h			;661e	ff 	. 
	rst 38h			;661f	ff 	. 
	nop			;6620	00 	. 
	nop			;6621	00 	. 
	nop			;6622	00 	. 
	nop			;6623	00 	. 
	nop			;6624	00 	. 
	nop			;6625	00 	. 
	add a,b			;6626	80 	. 
	jr l662ch		;6627	18 03 	. . 
	add a,b			;6629	80 	. 
	ld a,b			;662a	78 	x 
	rrca			;662b	0f 	. 
l662ch:
	add a,c			;662c	81 	. 
	ret m			;662d	f8 	. 
	ccf			;662e	3f 	? 
	add a,a			;662f	87 	. 
	ret m			;6630	f8 	. 
	rst 38h			;6631	ff 	. 
	sbc a,a			;6632	9f 	. 
	ei			;6633	fb 	. 
	rst 38h			;6634	ff 	. 
	add a,b			;6635	80 	. 
	nop			;6636	00 	. 
	nop			;6637	00 	. 
	rra			;6638	1f 	. 
	call m,sub_7f00h		;6639	fc 00 7f 	. .  
	ret p			;663c	f0 	. 
	ld bc,0c0ffh		;663d	01 ff c0 	. . . 
	rlca			;6640	07 	. 
	rst 38h			;6641	ff 	. 
	nop			;6642	00 	. 
	rra			;6643	1f 	. 
	call m,sub_7f00h		;6644	fc 00 7f 	. .  
	ret p			;6647	f0 	. 
	nop			;6648	00 	. 
	nop			;6649	00 	. 
	ld bc,03defh		;664a	01 ef 3d 	. . = 
	rst 20h			;664d	e7 	. 
	cp h			;664e	bc 	. 
	rst 30h			;664f	f7 	. 
	sbc a,(hl)			;6650	9e 	. 
	di			;6651	f3 	. 
	sbc a,07bh		;6652	de 7b 	. { 
	rst 8			;6654	cf 	. 
	ld a,c			;6655	79 	y 
	rst 28h			;6656	ef 	. 
	dec a			;6657	3d 	= 
	ret po			;6658	e0 	. 
	ld de,0x4001		;6659	11 01 40 	. . @ 
	ld a,h			;665c	7c 	| 
	rrca			;665d	0f 	. 
	add a,e			;665e	83 	. 
	ret m			;665f	f8 	. 
	ld a,a			;6660	7f 	 
	rra			;6661	1f 	. 
	di			;6662	f3 	. 
	cp 05fh		;6663	fe 5f 	. _ 
	ld c,d			;6665	4a 	J 
	add hl,hl			;6666	29 	) 
	ld b,l			;6667	45 	E 
	dec b			;6668	05 	. 
	nop			;6669	00 	. 
	nop			;666a	00 	. 
	dec d			;666b	15 	. 
	ld d,(hl)			;666c	56 	V 
	xor d			;666d	aa 	. 
	push de			;666e	d5 	. 
	ld e,e			;666f	5b 	[ 
	ei			;6670	fb 	. 
	ld d,l			;6671	55 	U 
	ld l,d			;6672	6a 	j 
	xor l			;6673	ad 	. 
	ld d,l			;6674	55 	U 
	xor d			;6675	aa 	. 
	or l			;6676	b5 	. 
	ld d,h			;6677	54 	T 
	nop			;6678	00 	. 
	nop			;6679	00 	. 
	nop			;667a	00 	. 
	nop			;667b	00 	. 
	nop			;667c	00 	. 
	nop			;667d	00 	. 
	jr c,l668fh		;667e	38 0f 	8 . 
	add a,c			;6680	81 	. 
	ret p			;6681	f0 	. 
	ld a,a			;6682	7f 	 
l6683h:
	rrca			;6683	0f 	. 
	pop hl			;6684	e1 	. 
	call m,sub_833fh		;6685	fc 3f 83 	. ? . 
	ret po			;6688	e0 	. 
	ld a,h			;6689	7c 	| 
	rlca			;668a	07 	. 
	nop			;668b	00 	. 
	nop			;668c	00 	. 
	add hl,bc			;668d	09 	. 
	ld c,c			;668e	49 	I 
l668fh:
	add a,e			;668f	83 	. 
	ld (bc),a			;6690	02 	. 
	nop			;6691	00 	. 
	ret po			;6692	e0 	. 
	ld c,c			;6693	49 	I 
	ld bc,02401h		;6694	01 01 24 	. . $ 
	ld c,000h		;6697	0e 00 	. . 
	add a,c			;6699	81 	. 
	add a,e			;669a	83 	. 
	dec h			;669b	25 	% 
	jr nz,$+83		;669c	20 51 	  Q 
	ld c,(hl)			;669e	4e 	N 
	add hl,sp			;669f	39 	9 
	rst 0			;66a0	c7 	. 
	jr c,l6683h		;66a1	38 e0 	8 . 
	nop			;66a3	00 	. 
	inc e			;66a4	1c 	. 
	inc bc			;66a5	03 	. 
	add a,b			;66a6	80 	. 
	ld (hl),b			;66a7	70 	p 
	ld c,001h		;66a8	0e 01 	. . 
	ret nz			;66aa	c0 	. 
	jr c,l66adh		;66ab	38 00 	8 . 
l66adh:
	nop			;66ad	00 	. 
	ld a,a			;66ae	7f 	 
	ret po			;66af	e0 	. 
	ld bc,02308h		;66b0	01 08 23 	. . # 
	add a,h			;66b3	84 	. 
	ret m			;66b4	f8 	. 
	cp a			;66b5	bf 	. 
	sub e			;66b6	93 	. 
	jp po,04238h		;66b7	e2 38 42 	. 8 B 
	ex af,af'			;66ba	08 	. 
	ld bc,l80ffh		;66bb	01 ff 80 	. . . 
	nop			;66be	00 	. 
	nop			;66bf	00 	. 
	nop			;66c0	00 	. 
	ld bc,020ffh		;66c1	01 ff 20 	. .   
	dec h			;66c4	25 	% 
	call p,sub_95a2h		;66c5	f4 a2 95 	. . . 
	ld d,d			;66c8	52 	R 
	adc a,d			;66c9	8a 	. 
	ld e,a			;66ca	5f 	_ 
	ld c,b			;66cb	48 	H 
	add hl,bc			;66cc	09 	. 
	rst 38h			;66cd	ff 	. 
	nop			;66ce	00 	. 
	nop			;66cf	00 	. 
	nop			;66d0	00 	. 
	rra			;66d1	1f 	. 
	call m,03423h		;66d2	fc 23 34 	. # 4 
	ld b,h			;66d5	44 	D 
	xor b			;66d6	a8 	. 
	sbc a,l			;66d7	9d 	. 
	ld d,0e2h		;66d8	16 e2 	. . 
	ld (hl),h			;66da	74 	t 
	ld c,d			;66db	4a 	J 
	adc a,h			;66dc	8c 	. 
	ld b,c			;66dd	41 	A 
	ex af,af'			;66de	08 	. 
	cp a			;66df	bf 	. 
	ret p			;66e0	f0 	. 
	nop			;66e1	00 	. 
	nop			;66e2	00 	. 
	ld bc,037bbh		;66e3	01 bb 37 	. . 7 
	ld h,(hl)			;66e6	66 	f 
	call pe,09bddh		;66e7	ec dd 9b 	. . . 
	or e			;66ea	b3 	. 
	halt			;66eb	76 	v 
	ld l,(hl)			;66ec	6e 	n 
	call GTTRIG		;66ed	cd d8 00 	. . . 
	nop			;66f0	00 	. 
	nop			;66f1	00 	. 
	nop			;66f2	00 	. 
	rra			;66f3	1f 	. 
	cp 000h		;66f4	fe 00 	. . 
	rst 38h			;66f6	ff 	. 
	ret p			;66f7	f0 	. 
	ld bc,0e0ffh		;66f8	01 ff e0 	. . . 
	rrca			;66fb	0f 	. 
	rst 38h			;66fc	ff 	. 
	nop			;66fd	00 	. 
	rra			;66fe	1f 	. 
	cp 000h		;66ff	fe 00 	. . 
	rst 38h			;6701	ff 	. 
	ret p			;6702	f0 	. 
	nop			;6703	00 	. 
	rra			;6704	1f 	. 
	rst 38h			;6705	ff 	. 
	rst 38h			;6706	ff 	. 
	rst 38h			;6707	ff 	. 
	rst 38h			;6708	ff 	. 
	rst 38h			;6709	ff 	. 
	rst 38h			;670a	ff 	. 
	rst 38h			;670b	ff 	. 
	rst 38h			;670c	ff 	. 
	rst 38h			;670d	ff 	. 
	rst 38h			;670e	ff 	. 
	rst 38h			;670f	ff 	. 
	rst 38h			;6710	ff 	. 
	rst 38h			;6711	ff 	. 
	rst 38h			;6712	ff 	. 
	ret p			;6713	f0 	. 
	inc b			;6714	04 	. 
	inc bc			;6715	03 	. 
	ld h,c			;6716	61 	a 
	sub e			;6717	93 	. 
	ld c,l			;6718	4d 	M 
	sub (hl)			;6719	96 	. 
	ld c,l			;671a	4d 	M 
	ld (hl),059h		;671b	36 59 	6 Y 
	inc (hl)			;671d	34 	4 
	exx			;671e	d9 	. 
	ld h,h			;671f	64 	d 
	out (065h),a		;6720	d3 65 	. e 
	add a,e			;6722	83 	. 
	ld b,b			;6723	40 	@ 
	djnz l672ah		;6724	10 04 	. . 
	inc bc			;6726	03 	. 
	ret po			;6727	e0 	. 
	cp 03fh		;6728	fe 3f 	. ? 
l672ah:
	rst 20h			;672a	e7 	. 
	call m,095ffh		;672b	fc ff 95 	. . . 
	ld d,b			;672e	50 	P 
	jr nz,l6735h		;672f	20 04 	  . 
	ld (bc),a			;6731	02 	. 
	add a,b			;6732	80 	. 
	ld (hl),b			;6733	70 	p 
	inc b			;6734	04 	. 
l6735h:
	nop			;6735	00 	. 
	cp a			;6736	bf 	. 
	or a			;6737	b7 	. 
	or 0bah		;6738	f6 ba 	. . 
	rst 10h			;673a	d7 	. 
	ld e,d			;673b	5a 	Z 
	xor e			;673c	ab 	. 
	ld d,l			;673d	55 	U 
	ld l,d			;673e	6a 	j 
	xor l			;673f	ad 	. 
	ld d,l			;6740	55 	U 
	xor d			;6741	aa 	. 
	cp a			;6742	bf 	. 
	ld a,h			;6743	7c 	| 
	nop			;6744	00 	. 
	nop			;6745	00 	. 
	nop			;6746	00 	. 
	nop			;6747	00 	. 
	rlca			;6748	07 	. 
	ret p			;6749	f0 	. 
	cp 01fh		;674a	fe 1f 	. . 
	jp l7ff8h		;674c	c3 f8 7f 	. .  
	rrca			;674f	0f 	. 
	pop hl			;6750	e1 	. 
	call m,sub_873fh		;6751	fc 3f 87 	. ? . 
	ret p			;6754	f0 	. 
	nop			;6755	00 	. 
	nop			;6756	00 	. 
	nop			;6757	00 	. 
	nop			;6758	00 	. 
	nop			;6759	00 	. 
	inc bc			;675a	03 	. 
	rst 38h			;675b	ff 	. 
	rst 38h			;675c	ff 	. 
	jp p,lba00h		;675d	f2 00 ba 	. . . 
	sub l			;6760	95 	. 
	jp nc,002aeh		;6761	d2 ae 02 	. . . 
	dec bc			;6764	0b 	. 
	xor b			;6765	a8 	. 
	call nc,00042h		;6766	d4 42 00 	. B . 
	nop			;6769	00 	. 
	rrca			;676a	0f 	. 
	ld sp,hl			;676b	f9 	. 
	ld bc,la52fh		;676c	01 2f a5 	. / . 
	inc d			;676f	14 	. 
	xor d			;6770	aa 	. 
	sub l			;6771	95 	. 
	ld d,d			;6772	52 	R 
	adc a,d			;6773	8a 	. 
	ld e,a			;6774	5f 	_ 
	ld c,b			;6775	48 	H 
	add hl,bc			;6776	09 	. 
	ld bc,0e03fh		;6777	01 3f e0 	. ? . 
	nop			;677a	00 	. 
	rra			;677b	1f 	. 
	rst 38h			;677c	ff 	. 
	rst 38h			;677d	ff 	. 
	add a,b			;677e	80 	. 
	dec c			;677f	0d 	. 
	rst 30h			;6780	f7 	. 
	cp (hl)			;6781	be 	. 
	rst 30h			;6782	f7 	. 
	sbc a,0fbh		;6783	de fb 	. . 
	nop			;6785	00 	. 
	rra			;6786	1f 	. 
	rst 38h			;6787	ff 	. 
	rst 38h			;6788	ff 	. 
	add a,b			;6789	80 	. 
	nop			;678a	00 	. 
	nop			;678b	00 	. 
	nop			;678c	00 	. 
	inc bc			;678d	03 	. 
	rst 38h			;678e	ff 	. 
	add a,b			;678f	80 	. 
	inc bc			;6790	03 	. 
	ld l,h			;6791	6c 	l 
	ld l,l			;6792	6d 	m 
	add a,b			;6793	80 	. 
	inc bc			;6794	03 	. 
	ld l,h			;6795	6c 	l 
	ld l,l			;6796	6d 	m 
	add a,b			;6797	80 	. 
	inc bc			;6798	03 	. 
	ld l,h			;6799	6c 	l 
	ld l,l			;679a	6d 	m 
	add a,b			;679b	80 	. 
	nop			;679c	00 	. 
	nop			;679d	00 	. 
	nop			;679e	00 	. 
	nop			;679f	00 	. 
	rlca			;67a0	07 	. 
	nop			;67a1	00 	. 
	ret po			;67a2	e0 	. 
	inc e			;67a3	1c 	. 
	rlca			;67a4	07 	. 
	ret nz			;67a5	c0 	. 
	ret m			;67a6	f8 	. 
	ccf			;67a7	3f 	? 
	add a,a			;67a8	87 	. 
	pop af			;67a9	f1 	. 
	rst 38h			;67aa	ff 	. 
	ld a,a			;67ab	7f 	 
	ret p			;67ac	f0 	. 
	nop			;67ad	00 	. 
	nop			;67ae	00 	. 
	nop			;67af	00 	. 
	nop			;67b0	00 	. 
	ld a,a			;67b1	7f 	 
	rst 38h			;67b2	ff 	. 
	rst 38h			;67b3	ff 	. 
	rst 38h			;67b4	ff 	. 
	call m,0017ch		;67b5	fc 7c 01 	. | . 
	add a,b			;67b8	80 	. 
	jr nc,l67c1h		;67b9	30 06 	0 . 
	ld a,h			;67bb	7c 	| 
	rst 38h			;67bc	ff 	. 
	ret p			;67bd	f0 	. 
	nop			;67be	00 	. 
	nop			;67bf	00 	. 
	nop			;67c0	00 	. 
l67c1h:
	ret p			;67c1	f0 	. 
	ld hl,l9109h		;67c2	21 09 91 	! . . 
	ld a,d			;67c5	7a 	z 
	ld h,042h		;67c6	26 42 	& B 
	djnz l6806h		;67c8	10 3c 	. < 
	nop			;67ca	00 	. 
	nop			;67cb	00 	. 
	nop			;67cc	00 	. 
	nop			;67cd	00 	. 
	nop			;67ce	00 	. 
	nop			;67cf	00 	. 
	nop			;67d0	00 	. 
	nop			;67d1	00 	. 
	nop			;67d2	00 	. 
	nop			;67d3	00 	. 
	nop			;67d4	00 	. 
	ld bc,0ffffh		;67d5	01 ff ff 	. . . 
	rst 38h			;67d8	ff 	. 
	rst 38h			;67d9	ff 	. 
	nop			;67da	00 	. 
	rra			;67db	1f 	. 
	rst 38h			;67dc	ff 	. 
	rst 38h			;67dd	ff 	. 
	rst 38h			;67de	ff 	. 
	ret p			;67df	f0 	. 
	nop			;67e0	00 	. 
	rra			;67e1	1f 	. 
	rst 38h			;67e2	ff 	. 
	rst 38h			;67e3	ff 	. 
	ret po			;67e4	e0 	. 
	ld a,00fh		;67e5	3e 0f 	> . 
	ex (sp),hl			;67e7	e3 	. 
	sbc a,0f1h		;67e8	de f1 	. . 
	call m,0011fh		;67ea	fc 1f 01 	. . . 
	ret nz			;67ed	c0 	. 
	djnz l67f0h		;67ee	10 00 	. . 
l67f0h:
	nop			;67f0	00 	. 
	nop			;67f1	00 	. 
	nop			;67f2	00 	. 
	inc bc			;67f3	03 	. 
	rst 28h			;67f4	ef 	. 
	defb 0fdh,0ffh,0bfh	;illegal sequence		;67f5	fd ff bf 	. . . 
	rst 30h			;67f8	f7 	. 
	cp 0ffh		;67f9	fe ff 	. . 
	rst 18h			;67fb	df 	. 
	ei			;67fc	fb 	. 
	rst 38h			;67fd	ff 	. 
	ld a,a			;67fe	7f 	 
	rst 28h			;67ff	ef 	. 
	defb 0fdh,0f0h,000h	;illegal sequence		;6800	fd f0 00 	. . . 
	nop			;6803	00 	. 
	inc bc			;6804	03 	. 
	nop			;6805	00 	. 
l6806h:
	ld a,b			;6806	78 	x 
	rrca			;6807	0f 	. 
	pop bc			;6808	c1 	. 
	cp 03fh		;6809	fe 3f 	. ? 
	di			;680b	f3 	. 
	rst 38h			;680c	ff 	. 
	rra			;680d	1f 	. 
	ret po			;680e	e0 	. 
	call m,sub_8007h		;680f	fc 07 80 	. . . 
	jr nc,l6814h		;6812	30 00 	0 . 
l6814h:
	nop			;6814	00 	. 
	ld (bc),a			;6815	02 	. 
	xor d			;6816	aa 	. 
	push de			;6817	d5 	. 
	ld d,l			;6818	55 	U 
	ld d,h			;6819	54 	T 
	xor d			;681a	aa 	. 
	xor d			;681b	aa 	. 
	xor l			;681c	ad 	. 
	ld d,l			;681d	55 	U 
	ld d,l			;681e	55 	U 
	ld c,d			;681f	4a 	J 
	xor d			;6820	aa 	. 
	xor d			;6821	aa 	. 
	push de			;6822	d5 	. 
	ld d,b			;6823	50 	P 
	nop			;6824	00 	. 
	dec b			;6825	05 	. 
	ld d,b			;6826	50 	P 
	xor d			;6827	aa 	. 
	dec d			;6828	15 	. 
	ld b,d			;6829	42 	B 
	cp b			;682a	b8 	. 
	ld d,l			;682b	55 	U 
	dec bc			;682c	0b 	. 
	pop hl			;682d	e1 	. 
	ld d,h			;682e	54 	T 
	ccf			;682f	3f 	? 
	add a,l			;6830	85 	. 
	ld d,b			;6831	50 	P 
	cp 01fh		;6832	fe 1f 	. . 
	ret nz			;6834	c0 	. 
sub_6835h:
	call 068c4h		;6835	cd c4 68 	. . h 
	call sub_7039h		;6838	cd 39 70 	. 9 p 
	call sub_683fh		;683b	cd 3f 68 	. ? h 
	ret			;683e	c9 	. 

sub_683fh:
    ; If the portal is closed, exit
	ld a,(PORTAL_OPEN)		;683f	3a 26 e3
	or a			        ;6842	b7
	ret z			        ;6843	c8

	ld a,(0e57ch)		;6844	3a 7c e5 	: | . 
	cp 001h		;6847	fe 01 	. . 
	jp z,l686fh		;6849	ca 6f 68 	. o h 
	ld b,004h		;684c	06 04 	. . 
	ld hl,l68b8h		;684e	21 b8 68 	! . h 
	ld iy,01a98h		;6851	fd 21 98 1a 	. ! . . 
l6855h:
	push iy		;6855	fd e5 	. . 
	pop de			;6857	d1 	. 
	push bc			;6858	c5 	. 
	push hl			;6859	e5 	. 
	ld bc,00001h		;685a	01 01 00 	. . . 
	call LDIRVM		;685d	cd 5c 00 	. \ . 
	pop hl			;6860	e1 	. 
	pop bc			;6861	c1 	. 
	ld de,00020h		;6862	11 20 00 	.   . 
	add iy,de		;6865	fd 19 	. . 
	inc hl			;6867	23 	# 
	djnz l6855h		;6868	10 eb 	. . 
	ld a,001h		;686a	3e 01 	> . 
	ld (0e57ch),a		;686c	32 7c e5 	2 | . 
l686fh:
	ld a,(0e57bh)		;686f	3a 7b e5 	: { . 
	cp 009h		;6872	fe 09 	. . 
	jr c,l687ah		;6874	38 04 	8 . 
	ld a,000h		;6876	3e 00 	> . 
	jr l687fh		;6878	18 05 	. . 
l687ah:
	inc a			;687a	3c 	< 
	ld (0e57bh),a		;687b	32 7b e5 	2 { . 
	ret			;687e	c9 	. 
l687fh:
	ld (0e57bh),a		;687f	32 7b e5 	2 { . 
	ld a,(0e576h)		;6882	3a 76 e5 	: v . 
	cp 000h		;6885	fe 00 	. . 
	jp z,l688fh		;6887	ca 8f 68 	. . h 
	ld a,000h		;688a	3e 00 	> . 
	jp l6891h		;688c	c3 91 68 	. . h 
l688fh:
	ld a,001h		;688f	3e 01 	> . 
l6891h:
	ld (0e576h),a		;6891	32 76 e5 	2 v . 
	sla a		;6894	cb 27 	. ' 
	sla a		;6896	cb 27 	. ' 
	ld l,a			;6898	6f 	o 
	ld h,000h		;6899	26 00 	& . 
	ld de,l68bch		;689b	11 bc 68 	. . h 
	add hl,de			;689e	19 	. 
	push hl			;689f	e5 	. 
	pop ix		;68a0	dd e1 	. . 
    
    
    ; Animation of Vaus entering the portal.
    ; The portal opens as Vaus enters.
	ld b, 4 		                                  ;68a2	06 04 Four steps
    ld hl, 0x1800 + 24 + 20*32; Locate VRAM [24, 20]  ;68a4	21 98 1a
l68a7h:
	push hl			    ;68a7	e5
    ; Load and VRAM write portal pattern
	ld a,(ix+000h)		;68a8	dd 7e 00
	call WRTVRM		    ;68ab	cd 4d 00
	pop hl			    ;68ae	e1

    ; HL += 32, next line
	ld de, 32		    ;68af	11 20 00
	add hl,de			;68b2	19
    
    ; Next pattern in the animation
    ; Patterns 30, 31, 32, and 33 are the animation of the door opening
	inc ix		        ;68b3	dd 23
	djnz l68a7h		    ;68b5	10 f0
	ret			        ;68b7	c9

l68b8h:
	ld d,017h		;68b8	16 17 	. . 
	jr l68d5h		;68ba	18 19 	. . 
l68bch:
	ld a,(de)			;68bc	1a 	. 
	dec de			;68bd	1b 	. 
	inc e			;68be	1c 	. 
	dec e			;68bf	1d 	. 
	ld e,01fh		;68c0	1e 1f 	. . 
	ld l,l			;68c2	6d 	m 
	ld hl,la93ah		;68c3	21 3a a9 	! : . 
	push hl			;68c6	e5 	. 
	cp 001h		;68c7	fe 01 	. . 
	jp z,l68dch		;68c9	ca dc 68 	. . h 
	ld hl,l6fe7h		;68cc	21 e7 6f 	! . o 
	ld de,0e0cdh		;68cf	11 cd e0 	. . . 
	ld bc,00010h		;68d2	01 10 00 	. . . 
l68d5h:
	ldir		;68d5	ed b0 	. . 
	ld a,001h		;68d7	3e 01 	> . 
	ld (0e5a9h),a		;68d9	32 a9 e5 	2 . . 
l68dch:
	ld ix,0e54bh		;68dc	dd 21 4b e5 	. ! K . 
	ld iy,0e0cdh		;68e0	fd 21 cd e0 	. ! . . 
	ld a,(ix+000h)		;68e4	dd 7e 00 	. ~ . 
	cp 001h		;68e7	fe 01 	. . 
	jp z,l690fh		;68e9	ca 0f 69 	. . i 
	cp 002h		;68ec	fe 02 	. . 
	jp z,l6c3eh		;68ee	ca 3e 6c 	. > l 
	cp 003h		;68f1	fe 03 	. . 
	jp z,l6d78h		;68f3	ca 78 6d 	. x m 
	cp 004h		;68f6	fe 04 	. . 
	jp z,l6f31h		;68f8	ca 31 6f 	. 1 o 
	cp 005h		;68fb	fe 05 	. . 
	jp z,l6cceh		;68fd	ca ce 6c 	. . l 
	cp 006h		;6900	fe 06 	. . 
	jp z,l6e0eh		;6902	ca 0e 6e 	. . n 
	cp 007h		;6905	fe 07 	. . 
	jp z,l6adbh		;6907	ca db 6a 	. . j 
	ld (ix+000h),001h		;690a	dd 36 00 01 	. 6 . . 
	ret nz			;690e	c0 	. 
l690fh:
    ; Keep going if we're at the title screen
	ld a,(GAME_STATE)		;690f	3a 0b e0 	: . . 
	or a			;6912	b7 	. 
	jp nz,l6924h		;6913	c2 24 69 	. $ i 
    
	ld a,(0e0f6h)		;6916	3a f6 e0 	: . . 
	sub 010h		;6919	d6 10 	. . 
	ld (iy+001h),a		;691b	fd 77 01 	. w . 
	ld (VAUS_X2),a		;691e	32 3e e5 	2 > . 
	jp l6972h		;6921	c3 72 69 	. r i 
l6924h:
	ld a,(0e00ch)		;6924	3a 0c e0 	: . . 
	or a			;6927	b7 	. 
	jp nz,l6946h		;6928	c2 46 69 	. F i 
	ld a,(0e0bfh)		;692b	3a bf e0 	: . . 
	and 00fh		;692e	e6 0f 	. . 
	ld l,a			;6930	6f 	o 
	ld h,000h		;6931	26 00 	& . 
	add hl,hl			;6933	29 	) 
	ld de,06ff7h		;6934	11 f7 6f 	. . o 
	add hl,de			;6937	19 	. 
	inc hl			;6938	23 	# 
	ld a,(hl)			;6939	7e 	~ 
	add a,(iy+001h)		;693a	fd 86 01 	. . . 
	ld (iy+001h),a		;693d	fd 77 01 	. w . 
	ld (VAUS_X2),a		;6940	32 3e e5 	2 > . 
	jp l6972h		;6943	c3 72 69 	. r i 
l6946h:
	ld b,008h		;6946	06 08 	. . 
	ld hl,(0e0c1h)		;6948	2a c1 e0 	* . . 
	ld de,000a0h		;694b	11 a0 00 	. . . 
	xor a			;694e	af 	. 
	sbc hl,de		;694f	ed 52 	. R 
	jp c,l6965h		;6951	da 65 69 	. e i 
	ld b,0b0h		;6954	06 b0 	. . 
	ld de,00004h		;6956	11 04 00 	. . . 
	add hl,de			;6959	19 	. 
	ld c,l			;695a	4d 	M 
	ld de,000b0h		;695b	11 b0 00 	. . . 
	xor a			;695e	af 	. 
	sbc hl,de		;695f	ed 52 	. R 
	jp nc,l6965h		;6961	d2 65 69 	. e i 
	ld b,c			;6964	41 	A 
l6965h:
	ld a,(iy+001h)		;6965	fd 7e 01 	. ~ . 
	ld (0e54ah),a		;6968	32 4a e5 	2 J . 
	ld a,b			;696b	78 	x 
	ld (iy+001h),a		;696c	fd 77 01 	. w . 
	ld (VAUS_X2),a		;696f	32 3e e5 	2 > . 
l6972h:
	ld a,(ix+005h)		;6972	dd 7e 05 	. ~ . 
	cp 001h		;6975	fe 01 	. . 
	jp z,l6a17h		;6977	ca 17 6a 	. . j 
	cp 002h		;697a	fe 02 	. . 
	jp z,l69eah		;697c	ca ea 69 	. . i 
	ld a,(VAUS_X2)		;697f	3a 3e e5 	: > . 
	cp 099h		;6982	fe 99 	. . 
	jp c,l69abh		;6984	da ab 69 	. . i 
	cp 0e6h		;6987	fe e6 	. . 
	jr nc,l69abh		;6989	30 20 	0   
	ld a,098h		;698b	3e 98 	> . 
	ld (VAUS_X2),a		;698d	32 3e e5 	2 > . 

    ; Skip the following if the portal is closed
	ld a,(PORTAL_OPEN)		;6990	3a 26 e3
	or a			        ;6993	b7
	jp z,l69abh		        ;6994	ca ab 69

	ld (ix+000h),007h		;6997	dd 36 00 07 	. 6 . . 
	ld a,0c1h		;699b	3e c1 	> . 
	call sub_5befh		;699d	cd ef 5b 	. . [ 
	ld a,00ch		;69a0	3e 0c 	> . 
	call sub_52a0h		;69a2	cd a0 52 	. . R 
	call DEACTIVE_ALL_BALLS		;69a5	cd 10 97 	. . . 
	jp l69bch		;69a8	c3 bc 69 	. . i 
l69abh:
	ld a,(VAUS_X2)		;69ab	3a 3e e5 	: > . 
	cp 0f0h		;69ae	fe f0 	. . 
	jp nc,l69b7h		;69b0	d2 b7 69 	. . i 
	cp 009h		;69b3	fe 09 	. . 
	jr nc,l69bch		;69b5	30 05 	0 . 
l69b7h:
	ld a,008h		;69b7	3e 08 	> . 
	ld (VAUS_X2),a		;69b9	32 3e e5 	2 > . 
l69bch:
	ld a,(ix+006h)		;69bc	dd 7e 06 	. ~ . 
	cp 001h		;69bf	fe 01 	. . 
	jp z,l69d6h		;69c1	ca d6 69 	. . i 
	ld a,(VAUS_X2)		;69c4	3a 3e e5 	: > . 
	ld b,004h		;69c7	06 04 	. . 
l69c9h:
	ld (iy+001h),a		;69c9	fd 77 01 	. w . 
	add a,010h		;69cc	c6 10 	. . 
	ld de,00004h		;69ce	11 04 00 	. . . 
	add iy,de		;69d1	fd 19 	. . 
	djnz l69c9h		;69d3	10 f4 	. . 
	ret			;69d5	c9 	. 
l69d6h:
	ld a,(VAUS_X2)		;69d6	3a 3e e5 	: > . 
	ld (iy+001h),a		;69d9	fd 77 01 	. w . 
	add a,010h		;69dc	c6 10 	. . 
	ld (iy+005h),a		;69de	fd 77 05 	. w . 
	ld (iy+009h),a		;69e1	fd 77 09 	. w . 
	add a,010h		;69e4	c6 10 	. . 
	ld (iy+00dh),a		;69e6	fd 77 0d 	. w . 
	ret			;69e9	c9 	. 
l69eah:
	ld a,(VAUS_X2)		;69ea	3a 3e e5 	: > . 
	cp 088h		;69ed	fe 88 	. . 
	jp c,l69abh		;69ef	da ab 69 	. . i 
	cp 0e6h		;69f2	fe e6 	. . 
	jp nc,l69abh		;69f4	d2 ab 69 	. . i 
	ld a,088h		;69f7	3e 88 	> . 
	ld (VAUS_X2),a		;69f9	32 3e e5 	2 > . 
    
    ; Check if the portal is closed and jump if so
	ld a,(PORTAL_OPEN)		;69fc	3a 26 e3
	or a			        ;69ff	b7
	jp z,l69abh		        ;6a00	ca ab 69

	ld (ix+000h),007h		;6a03	dd 36 00 07 	. 6 . . 
	ld a,0c1h		;6a07	3e c1 	> . 
	call sub_5befh		;6a09	cd ef 5b 	. . [ 
	ld a,00ch		;6a0c	3e 0c 	> . 
	call sub_52a0h		;6a0e	cd a0 52 	. . R 
	call DEACTIVE_ALL_BALLS		;6a11	cd 10 97 	. . . 
	jp l69bch		;6a14	c3 bc 69 	. . i 
l6a17h:
	ld a,(ix+006h)		;6a17	dd 7e 06 	. ~ . 
	or a			;6a1a	b7 	. 
	jp nz,l6a5dh		;6a1b	c2 5d 6a 	. ] j 
	ld a,(VAUS_X2)		;6a1e	3a 3e e5 	: > . 
	cp 083h		;6a21	fe 83 	. . 
	jp c,l6a30h		;6a23	da 30 6a 	. 0 j 
	cp 09eh		;6a26	fe 9e 	. . 
	jp nc,l6a30h		;6a28	d2 30 6a 	. 0 j 
	ld a,082h		;6a2b	3e 82 	> . 
	ld (VAUS_X2),a		;6a2d	32 3e e5 	2 > . 
l6a30h:
	cp 0fah		;6a30	fe fa 	. . 
	jp nc,l6a3fh		;6a32	d2 3f 6a 	. ? j 
	cp 009h		;6a35	fe 09 	. . 
	jp nc,l6a3fh		;6a37	d2 3f 6a 	. ? j 
	ld a,008h		;6a3a	3e 08 	> . 
	ld (VAUS_X2),a		;6a3c	32 3e e5 	2 > . 
l6a3fh:
	ld a,(ix+006h)		;6a3f	dd 7e 06 	. ~ . 
	cp 001h		;6a42	fe 01 	. . 
	jp z,l6a72h		;6a44	ca 72 6a 	. r j 
	ld a,(VAUS_X2)		;6a47	3a 3e e5 	: > . 
	ld (iy+001h),a		;6a4a	fd 77 01 	. w . 
	add a,010h		;6a4d	c6 10 	. . 
	ld (iy+005h),a		;6a4f	fd 77 05 	. w . 
	add a,008h		;6a52	c6 08 	. . 
	ld (iy+009h),a		;6a54	fd 77 09 	. w . 
	add a,008h		;6a57	c6 08 	. . 
	ld (iy+00dh),a		;6a59	fd 77 0d 	. w . 
	ret			;6a5c	c9 	. 
l6a5dh:
	ld a,(VAUS_X2)		;6a5d	3a 3e e5 	: > . 
	cp 092h		;6a60	fe 92 	. . 
	jp c,l6a30h		;6a62	da 30 6a 	. 0 j 
	cp 0c8h		;6a65	fe c8 	. . 
	jp nc,l6a30h		;6a67	d2 30 6a 	. 0 j 
	ld a,0a0h		;6a6a	3e a0 	> . 
	ld (VAUS_X2),a		;6a6c	32 3e e5 	2 > . 
	jp l6a30h		;6a6f	c3 30 6a 	. 0 j 
l6a72h:
	ld a,(ix+007h)		;6a72	dd 7e 07 	. ~ . 
	cp 002h		;6a75	fe 02 	. . 
	jp z,l6a9fh		;6a77	ca 9f 6a 	. . j 
	cp 003h		;6a7a	fe 03 	. . 
	jp z,l6ab3h		;6a7c	ca b3 6a 	. . j 
	cp 004h		;6a7f	fe 04 	. . 
	jp z,l6ac7h		;6a81	ca c7 6a 	. . j 
	cp 005h		;6a84	fe 05 	. . 
	jp z,l6a9eh		;6a86	ca 9e 6a 	. . j 
	ld a,(VAUS_X2)		;6a89	3a 3e e5 	: > . 
	ld (iy+001h),a		;6a8c	fd 77 01 	. w . 
	add a,00ch		;6a8f	c6 0c 	. . 
	ld (iy+005h),a		;6a91	fd 77 05 	. w . 
	add a,00ch		;6a94	c6 0c 	. . 
	ld (iy+009h),a		;6a96	fd 77 09 	. w . 
	add a,0fch		;6a99	c6 fc 	. . 
	ld (iy+00dh),a		;6a9b	fd 77 0d 	. w . 
l6a9eh:
	ret			;6a9e	c9 	. 
l6a9fh:
	ld a,(VAUS_X2)		;6a9f	3a 3e e5 	: > . 
	ld (iy+001h),a		;6aa2	fd 77 01 	. w . 
	add a,006h		;6aa5	c6 06 	. . 
	ld (iy+005h),a		;6aa7	fd 77 05 	. w . 
	ld (iy+009h),a		;6aaa	fd 77 09 	. w . 
	add a,006h		;6aad	c6 06 	. . 
	ld (iy+00dh),a		;6aaf	fd 77 0d 	. w . 
	ret			;6ab2	c9 	. 
l6ab3h:
	ld a,(VAUS_X2)		;6ab3	3a 3e e5 	: > . 
	ld (iy+001h),a		;6ab6	fd 77 01 	. w . 
	add a,00ch		;6ab9	c6 0c 	. . 
	ld (iy+005h),a		;6abb	fd 77 05 	. w . 
	ld (iy+009h),a		;6abe	fd 77 09 	. w . 
	add a,00ch		;6ac1	c6 0c 	. . 
	ld (iy+00dh),a		;6ac3	fd 77 0d 	. w . 
	ret			;6ac6	c9 	. 
l6ac7h:
	ld a,(VAUS_X2)		;6ac7	3a 3e e5 	: > . 
	ld (iy+001h),a		;6aca	fd 77 01 	. w . 
	add a,008h		;6acd	c6 08 	. . 
	ld (iy+005h),a		;6acf	fd 77 05 	. w . 
	ld (iy+009h),a		;6ad2	fd 77 09 	. w . 
	add a,008h		;6ad5	c6 08 	. . 
	ld (iy+00dh),a		;6ad7	fd 77 0d 	. w . 
	ret			;6ada	c9 	. 
l6adbh:
	ld ix,0e553h		;6adb	dd 21 53 e5 	. ! S . 
	inc (ix+000h)		;6adf	dd 34 00 	. 4 . 
	ld a,(ix+000h)		;6ae2	dd 7e 00 	. ~ . 
	cp 00ah		;6ae5	fe 0a 	. . 
	ret nz			;6ae7	c0 	. 
	ld (ix+000h),000h		;6ae8	dd 36 00 00 	. 6 . . 
	ld e,(ix+001h)		;6aec	dd 5e 01 	. ^ . 
	sla e		;6aef	cb 23 	. # 
	ld d,000h		;6af1	16 00 	. . 
	ld a,(0e551h)		;6af3	3a 51 e5 	: Q . 
	cp 001h		;6af6	fe 01 	. . 
	jp z,l6b48h		;6af8	ca 48 6b 	. H k 
	ld a,(0e550h)		;6afb	3a 50 e5 	: P . 
	cp 000h		;6afe	fe 00 	. . 
	jp nz,l6b2ch		;6b00	c2 2c 6b 	. , k 
	ld hl,l6b64h		;6b03	21 64 6b 	! d k 
	add hl,de			;6b06	19 	. 
	ld e,(hl)			;6b07	5e 	^ 
	inc hl			;6b08	23 	# 
	ld d,(hl)			;6b09	56 	V 
	ex de,hl			;6b0a	eb 	. 
	ld de,0e0cdh		;6b0b	11 cd e0 	. . . 
	ld bc,0000ch		;6b0e	01 0c 00 	. . . 
	ldir		;6b11	ed b0 	. . 
	inc (ix+001h)		;6b13	dd 34 01 	. 4 . 
	ld a,(ix+001h)		;6b16	dd 7e 01 	. ~ . 
	cp 004h		;6b19	fe 04 	. . 
	ret nz			;6b1b	c0 	. 
l6b1ch:
	ld a,000h		;6b1c	3e 00 	> . 
	ld (0e54bh),a		;6b1e	32 4b e5 	2 K . 
	ld a,002h		;6b21	3e 02 	> . 
	ld (0e00ah),a		;6b23	32 0a e0 	2 . . 
	ld a,001h		;6b26	3e 01 	> . 
	ld (BRICK_REPAINT_TYPE),a		;6b28	32 22 e0 	2 " . 
	ret			;6b2b	c9 	. 
l6b2ch:
	ld hl,l6b9ch		;6b2c	21 9c 6b 	! . k 
	add hl,de			;6b2f	19 	. 
	ld e,(hl)			;6b30	5e 	^ 
	inc hl			;6b31	23 	# 
	ld d,(hl)			;6b32	56 	V 
	ex de,hl			;6b33	eb 	. 
	ld de,0e0cdh		;6b34	11 cd e0 	. . . 
	ld bc,00010h		;6b37	01 10 00 	. . . 
	ldir		;6b3a	ed b0 	. . 
	inc (ix+001h)		;6b3c	dd 34 01 	. 4 . 
	ld a,(ix+001h)		;6b3f	dd 7e 01 	. ~ . 
	cp 005h		;6b42	fe 05 	. . 
	ret nz			;6b44	c0 	. 
	jp l6b1ch		;6b45	c3 1c 6b 	. . k 
l6b48h:
	ld hl,l6bf6h		;6b48	21 f6 6b 	! . k 
	add hl,de			;6b4b	19 	. 
	ld e,(hl)			;6b4c	5e 	^ 
	inc hl			;6b4d	23 	# 
	ld d,(hl)			;6b4e	56 	V 
	ex de,hl			;6b4f	eb 	. 
	ld de,0e0cdh		;6b50	11 cd e0 	. . . 
	ld bc,00010h		;6b53	01 10 00 	. . . 
	ldir		;6b56	ed b0 	. . 
	inc (ix+001h)		;6b58	dd 34 01 	. 4 . 
	ld a,(ix+001h)		;6b5b	dd 7e 01 	. ~ . 
	cp 004h		;6b5e	fe 04 	. . 
	ret nz			;6b60	c0 	. 
	jp l6b1ch		;6b61	c3 1c 6b 	. . k 
l6b64h:
	ld l,h			;6b64	6c 	l 
	ld l,e			;6b65	6b 	k 
	ld a,b			;6b66	78 	x 
	ld l,e			;6b67	6b 	k 
	add a,h			;6b68	84 	. 
	ld l,e			;6b69	6b 	k 
	sub b			;6b6a	90 	. 
	ld l,e			;6b6b	6b 	k 
	xor (hl)			;6b6c	ae 	. 
	and b			;6b6d	a0 	. 
	ex af,af'			;6b6e	08 	. 
	ex af,af'			;6b6f	08 	. 
	xor (hl)			;6b70	ae 	. 
	or b			;6b71	b0 	. 
	inc b			;6b72	04 	. 
	ld c,0aeh		;6b73	0e ae 	. . 
	ret nz			;6b75	c0 	. 
	inc c			;6b76	0c 	. 
	ex af,af'			;6b77	08 	. 
	xor (hl)			;6b78	ae 	. 
	xor b			;6b79	a8 	. 
	ex af,af'			;6b7a	08 	. 
	ex af,af'			;6b7b	08 	. 
	xor (hl)			;6b7c	ae 	. 
	cp b			;6b7d	b8 	. 
	inc b			;6b7e	04 	. 
	ld c,000h		;6b7f	0e 00 	. . 
	nop			;6b81	00 	. 
	nop			;6b82	00 	. 
	nop			;6b83	00 	. 
	xor (hl)			;6b84	ae 	. 
	cp b			;6b85	b8 	. 
	ex af,af'			;6b86	08 	. 
	ex af,af'			;6b87	08 	. 
	nop			;6b88	00 	. 
	nop			;6b89	00 	. 
	nop			;6b8a	00 	. 
	nop			;6b8b	00 	. 
	nop			;6b8c	00 	. 
	nop			;6b8d	00 	. 
	nop			;6b8e	00 	. 
	nop			;6b8f	00 	. 
	nop			;6b90	00 	. 
	nop			;6b91	00 	. 
	nop			;6b92	00 	. 
	nop			;6b93	00 	. 
	nop			;6b94	00 	. 
	nop			;6b95	00 	. 
	nop			;6b96	00 	. 
	nop			;6b97	00 	. 
	nop			;6b98	00 	. 
	nop			;6b99	00 	. 
	nop			;6b9a	00 	. 
	nop			;6b9b	00 	. 
l6b9ch:
	and (hl)			;6b9c	a6 	. 
	ld l,e			;6b9d	6b 	k 
	or (hl)			;6b9e	b6 	. 
	ld l,e			;6b9f	6b 	k 
	add a,06bh		;6ba0	c6 6b 	. k 
	sub 06bh		;6ba2	d6 6b 	. k 
	and 06bh		;6ba4	e6 6b 	. k 
	xor (hl)			;6ba6	ae 	. 
	sub b			;6ba7	90 	. 
	ex af,af'			;6ba8	08 	. 
	ex af,af'			;6ba9	08 	. 
	xor (hl)			;6baa	ae 	. 
	and b			;6bab	a0 	. 
	inc b			;6bac	04 	. 
	ld c,0aeh		;6bad	0e ae 	. . 
	or b			;6baf	b0 	. 
	inc b			;6bb0	04 	. 
	ld c,0aeh		;6bb1	0e ae 	. . 
	ret nz			;6bb3	c0 	. 
	inc c			;6bb4	0c 	. 
	ex af,af'			;6bb5	08 	. 
	xor (hl)			;6bb6	ae 	. 
	sbc a,b			;6bb7	98 	. 
	ex af,af'			;6bb8	08 	. 
	ex af,af'			;6bb9	08 	. 
	xor (hl)			;6bba	ae 	. 
	xor b			;6bbb	a8 	. 
	inc b			;6bbc	04 	. 
	ld c,0aeh		;6bbd	0e ae 	. . 
	cp b			;6bbf	b8 	. 
	inc b			;6bc0	04 	. 
	ld c,000h		;6bc1	0e 00 	. . 
	nop			;6bc3	00 	. 
	nop			;6bc4	00 	. 
	nop			;6bc5	00 	. 
	xor (hl)			;6bc6	ae 	. 
	xor b			;6bc7	a8 	. 
	ex af,af'			;6bc8	08 	. 
	ex af,af'			;6bc9	08 	. 
	xor (hl)			;6bca	ae 	. 
	cp b			;6bcb	b8 	. 
	inc b			;6bcc	04 	. 
	ld c,000h		;6bcd	0e 00 	. . 
	nop			;6bcf	00 	. 
	nop			;6bd0	00 	. 
	nop			;6bd1	00 	. 
	nop			;6bd2	00 	. 
	nop			;6bd3	00 	. 
	nop			;6bd4	00 	. 
	nop			;6bd5	00 	. 
	xor (hl)			;6bd6	ae 	. 
	cp b			;6bd7	b8 	. 
	ex af,af'			;6bd8	08 	. 
	ex af,af'			;6bd9	08 	. 
	nop			;6bda	00 	. 
	nop			;6bdb	00 	. 
	nop			;6bdc	00 	. 
	nop			;6bdd	00 	. 
	nop			;6bde	00 	. 
	nop			;6bdf	00 	. 
	nop			;6be0	00 	. 
	nop			;6be1	00 	. 
	nop			;6be2	00 	. 
	nop			;6be3	00 	. 
	nop			;6be4	00 	. 
	nop			;6be5	00 	. 
	nop			;6be6	00 	. 
	nop			;6be7	00 	. 
	nop			;6be8	00 	. 
	nop			;6be9	00 	. 
	nop			;6bea	00 	. 
	nop			;6beb	00 	. 
	nop			;6bec	00 	. 
	nop			;6bed	00 	. 
	nop			;6bee	00 	. 
	nop			;6bef	00 	. 
	nop			;6bf0	00 	. 
	nop			;6bf1	00 	. 
	nop			;6bf2	00 	. 
	nop			;6bf3	00 	. 
	nop			;6bf4	00 	. 
	nop			;6bf5	00 	. 
l6bf6h:
	cp 06bh		;6bf6	fe 6b 	. k 
	ld c,06ch		;6bf8	0e 6c 	. l 
	ld e,06ch		;6bfa	1e 6c 	. l 
	ld l,06ch		;6bfc	2e 6c 	. l 
	xor (hl)			;6bfe	ae 	. 
	and b			;6bff	a0 	. 
	inc d			;6c00	14 	. 
	ld c,0aeh		;6c01	0e ae 	. . 
	or b			;6c03	b0 	. 
	djnz l6c14h		;6c04	10 0e 	. . 
	xor (hl)			;6c06	ae 	. 
	or b			;6c07	b0 	. 
	inc e			;6c08	1c 	. 
	ex af,af'			;6c09	08 	. 
	xor (hl)			;6c0a	ae 	. 
	ret nz			;6c0b	c0 	. 
	jr l6c1ch		;6c0c	18 0e 	. . 
	xor (hl)			;6c0e	ae 	. 
	xor b			;6c0f	a8 	. 
	inc d			;6c10	14 	. 
	ld c,0aeh		;6c11	0e ae 	. . 
	cp b			;6c13	b8 	. 
l6c14h:
	djnz l6c24h		;6c14	10 0e 	. . 
	xor (hl)			;6c16	ae 	. 
	cp b			;6c17	b8 	. 
	inc e			;6c18	1c 	. 
	ex af,af'			;6c19	08 	. 
	nop			;6c1a	00 	. 
	nop			;6c1b	00 	. 
l6c1ch:
	nop			;6c1c	00 	. 
	nop			;6c1d	00 	. 
	xor (hl)			;6c1e	ae 	. 
	cp b			;6c1f	b8 	. 
	inc d			;6c20	14 	. 
	ld c,000h		;6c21	0e 00 	. . 
	nop			;6c23	00 	. 
l6c24h:
	nop			;6c24	00 	. 
	nop			;6c25	00 	. 
	nop			;6c26	00 	. 
	nop			;6c27	00 	. 
	nop			;6c28	00 	. 
	nop			;6c29	00 	. 
	nop			;6c2a	00 	. 
	nop			;6c2b	00 	. 
	nop			;6c2c	00 	. 
	nop			;6c2d	00 	. 
	nop			;6c2e	00 	. 
	nop			;6c2f	00 	. 
	nop			;6c30	00 	. 
	nop			;6c31	00 	. 
	nop			;6c32	00 	. 
	nop			;6c33	00 	. 
	nop			;6c34	00 	. 
	nop			;6c35	00 	. 
	nop			;6c36	00 	. 
	nop			;6c37	00 	. 
	nop			;6c38	00 	. 
	nop			;6c39	00 	. 
	nop			;6c3a	00 	. 
	nop			;6c3b	00 	. 
	nop			;6c3c	00 	. 
	nop			;6c3d	00 	. 
l6c3eh:
	ld a,(ix+006h)		;6c3e	dd 7e 06 	. ~ . 
	cp 001h		;6c41	fe 01 	. . 
	jp z,l6cceh		;6c43	ca ce 6c 	. . l 
	inc (ix+002h)		;6c46	dd 34 02 	. 4 . 
	ld a,(ix+002h)		;6c49	dd 7e 02 	. ~ . 
	cp 005h		;6c4c	fe 05 	. . 
	jp nz,l690fh		;6c4e	c2 0f 69 	. . i 
	ld (ix+002h),000h		;6c51	dd 36 02 00 	. 6 . . 
	ld a,(ix+001h)		;6c55	dd 7e 01 	. ~ . 
	cp 001h		;6c58	fe 01 	. . 
	jp z,l6c94h		;6c5a	ca 94 6c 	. . l 
	ld (iy+00ah),004h		;6c5d	fd 36 0a 04 	. 6 . . 
	ld (iy+00eh),00ch		;6c61	fd 36 0e 0c 	. 6 . . 
	ld (iy+00bh),00eh		;6c65	fd 36 0b 0e 	. 6 . . 
	ld (iy+00fh),008h		;6c69	fd 36 0f 08 	. 6 . . 
	ld a,0fch		;6c6d	3e fc 	> . 
	add a,(iy+001h)		;6c6f	fd 86 01 	. . . 
	ld (iy+001h),a		;6c72	fd 77 01 	. w . 
	ld a,0fch		;6c75	3e fc 	> . 
	add a,(iy+005h)		;6c77	fd 86 05 	. . . 
	ld (iy+005h),a		;6c7a	fd 77 05 	. w . 
	ld a,0f4h		;6c7d	3e f4 	> . 
	add a,(iy+009h)		;6c7f	fd 86 09 	. . . 
	ld (iy+009h),a		;6c82	fd 77 09 	. w . 
	ld a,0f4h		;6c85	3e f4 	> . 
	add a,(iy+00dh)		;6c87	fd 86 0d 	. . . 
	ld (iy+00dh),a		;6c8a	fd 77 0d 	. w . 
	ld (ix+005h),001h		;6c8d	dd 36 05 01 	. 6 . . 
	jp l6cb8h		;6c91	c3 b8 6c 	. . l 
l6c94h:
	ld a,0fch		;6c94	3e fc 	> . 
	add a,(iy+001h)		;6c96	fd 86 01 	. . . 
	ld (iy+001h),a		;6c99	fd 77 01 	. w . 
	ld a,0fch		;6c9c	3e fc 	> . 
	add a,(iy+005h)		;6c9e	fd 86 05 	. . . 
	ld (iy+005h),a		;6ca1	fd 77 05 	. w . 
	ld a,004h		;6ca4	3e 04 	> . 
	ld a,(iy+009h)		;6ca6	fd 7e 09 	. ~ . 
	ld (iy+009h),a		;6ca9	fd 77 09 	. w . 
	ld a,004h		;6cac	3e 04 	> . 
	add a,(iy+00dh)		;6cae	fd 86 0d 	. . . 
	ld (iy+00dh),a		;6cb1	fd 77 0d 	. w . 
	ld (ix+005h),002h		;6cb4	dd 36 05 02 	. 6 . . 
l6cb8h:
	inc (ix+001h)		;6cb8	dd 34 01 	. 4 . 
	ld a,(ix+001h)		;6cbb	dd 7e 01 	. ~ . 
	cp 002h		;6cbe	fe 02 	. . 
	jp nz,l690fh		;6cc0	c2 0f 69 	. . i 
	ld (ix+000h),001h		;6cc3	dd 36 00 01 	. 6 . . 
	ld (ix+001h),000h		;6cc7	dd 36 01 00 	. 6 . . 
	jp l690fh		;6ccb	c3 0f 69 	. . i 
l6cceh:
	inc (ix+002h)		;6cce	dd 34 02 	. 4 . 
	ld a,(ix+002h)		;6cd1	dd 7e 02 	. ~ . 
	cp 005h		;6cd4	fe 05 	. . 
	jp nz,l690fh		;6cd6	c2 0f 69 	. . i 
	ld (ix+002h),000h		;6cd9	dd 36 02 00 	. 6 . . 
	ld a,(ix+007h)		;6cdd	dd 7e 07 	. ~ . 
	cp 002h		;6ce0	fe 02 	. . 
	jp z,l6d2ch		;6ce2	ca 2c 6d 	. , m 
	cp 003h		;6ce5	fe 03 	. . 
	jp z,l6d42h		;6ce7	ca 42 6d 	. B m 
	ld a,004h		;6cea	3e 04 	> . 
	add a,(iy+001h)		;6cec	fd 86 01 	. . . 
	ld (iy+001h),a		;6cef	fd 77 01 	. w . 
	ld a,0fch		;6cf2	3e fc 	> . 
	add a,(iy+00dh)		;6cf4	fd 86 0d 	. . . 
	ld (iy+00dh),a		;6cf7	fd 77 0d 	. w . 
	ld (ix+005h),001h		;6cfa	dd 36 05 01 	. 6 . . 
	inc (ix+007h)		;6cfe	dd 34 07 	. 4 . 
	ld a,(ix+007h)		;6d01	dd 7e 07 	. ~ . 
	cp 002h		;6d04	fe 02 	. . 
	jp nz,l690fh		;6d06	c2 0f 69 	. . i 
	ld (iy+003h),008h		;6d09	fd 36 03 08 	. 6 . . 
	ld (iy+007h),00eh		;6d0d	fd 36 07 0e 	. 6 . . 
	ld (iy+00bh),008h		;6d11	fd 36 0b 08 	. 6 . . 
	ld (iy+00fh),000h		;6d15	fd 36 0f 00 	. 6 . . 
	ld (iy+002h),008h		;6d19	fd 36 02 08 	. 6 . . 
	ld (iy+006h),004h		;6d1d	fd 36 06 04 	. 6 . . 
	ld (iy+00ah),00ch		;6d21	fd 36 0a 0c 	. 6 . . 
	ld (iy+00eh),001h		;6d25	fd 36 0e 01 	. 6 . . 
	jp l690fh		;6d29	c3 0f 69 	. . i 
l6d2ch:
	ld a,0fch		;6d2c	3e fc 	> . 
	add a,(iy+001h)		;6d2e	fd 86 01 	. . . 
	ld (iy+001h),a		;6d31	fd 77 01 	. w . 
	ld a,00ch		;6d34	3e 0c 	> . 
	add a,(iy+009h)		;6d36	fd 86 09 	. . . 
	ld (iy+009h),a		;6d39	fd 77 09 	. w . 
	inc (ix+007h)		;6d3c	dd 34 07 	. 4 . 
	jp l690fh		;6d3f	c3 0f 69 	. . i 
l6d42h:
	ld a,0fch		;6d42	3e fc 	> . 
	add a,(iy+001h)		;6d44	fd 86 01 	. . . 
	ld (iy+001h),a		;6d47	fd 77 01 	. w . 
	ld a,004h		;6d4a	3e 04 	> . 
	add a,(iy+009h)		;6d4c	fd 86 09 	. . . 
	ld (iy+009h),a		;6d4f	fd 77 09 	. w . 
	ld a,018h		;6d52	3e 18 	> . 
	add a,(iy+00dh)		;6d54	fd 86 0d 	. . . 
	ld (iy+00dh),a		;6d57	fd 77 0d 	. w . 
	ld (ix+005h),000h		;6d5a	dd 36 05 00 	. 6 . . 
	ld (ix+006h),000h		;6d5e	dd 36 06 00 	. 6 . . 
	ld (ix+007h),000h		;6d62	dd 36 07 00 	. 6 . . 
	ld a,(ix+000h)		;6d66	dd 7e 00 	. ~ . 
	cp 002h		;6d69	fe 02 	. . 
	jp nz,l6d71h		;6d6b	c2 71 6d 	. q m 
	jp l690fh		;6d6e	c3 0f 69 	. . i 
l6d71h:
	ld (ix+000h),001h		;6d71	dd 36 00 01 	. 6 . . 
	jp l690fh		;6d75	c3 0f 69 	. . i 
l6d78h:
	inc (ix+002h)		;6d78	dd 34 02 	. 4 . 
	ld a,(ix+002h)		;6d7b	dd 7e 02 	. ~ . 
	cp 005h		;6d7e	fe 05 	. . 
	jp nz,l690fh		;6d80	c2 0f 69 	. . i 
	ld (ix+002h),000h		;6d83	dd 36 02 00 	. 6 . . 
	ld a,(ix+001h)		;6d87	dd 7e 01 	. ~ . 
	cp 001h		;6d8a	fe 01 	. . 
	jp z,l6db6h		;6d8c	ca b6 6d 	. . m 
	ld a,004h		;6d8f	3e 04 	> . 
	add a,(iy+001h)		;6d91	fd 86 01 	. . . 
	ld (iy+001h),a		;6d94	fd 77 01 	. w . 
	ld a,004h		;6d97	3e 04 	> . 
	add a,(iy+005h)		;6d99	fd 86 05 	. . . 
	ld (iy+005h),a		;6d9c	fd 77 05 	. w . 
	ld a,0fch		;6d9f	3e fc 	> . 
	add a,(iy+009h)		;6da1	fd 86 09 	. . . 
	ld (iy+009h),a		;6da4	fd 77 09 	. w . 
	ld a,0fch		;6da7	3e fc 	> . 
	add a,(iy+00dh)		;6da9	fd 86 0d 	. . . 
	ld (iy+00dh),a		;6dac	fd 77 0d 	. w . 
	ld (ix+005h),001h		;6daf	dd 36 05 01 	. 6 . . 
	jp l6de1h		;6db3	c3 e1 6d 	. . m 
l6db6h:
	ld (iy+00ah),00ch		;6db6	fd 36 0a 0c 	. 6 . . 
	ld (iy+00eh),001h		;6dba	fd 36 0e 01 	. 6 . . 
	ld (iy+00bh),008h		;6dbe	fd 36 0b 08 	. 6 . . 
	ld (iy+00fh),000h		;6dc2	fd 36 0f 00 	. 6 . . 
	ld a,0fch		;6dc6	3e fc 	> . 
	add a,(iy+001h)		;6dc8	fd 86 01 	. . . 
	ld (iy+001h),a		;6dcb	fd 77 01 	. w . 
	add a,0fch		;6dce	c6 fc 	. . 
	ld (iy+005h),a		;6dd0	fd 77 05 	. w . 
	add a,004h		;6dd3	c6 04 	. . 
	ld (iy+009h),a		;6dd5	fd 77 09 	. w . 
	add a,004h		;6dd8	c6 04 	. . 
	ld (iy+00dh),a		;6dda	fd 77 0d 	. w . 
	ld (ix+005h),000h		;6ddd	dd 36 05 00 	. 6 . . 
l6de1h:
	inc (ix+001h)		;6de1	dd 34 01 	. 4 . 
	ld a,(ix+001h)		;6de4	dd 7e 01 	. ~ . 
	cp 002h		;6de7	fe 02 	. . 
	jp nz,l690fh		;6de9	c2 0f 69 	. . i 
	ld a,(ix+006h)		;6dec	dd 7e 06 	. ~ . 
	cp 001h		;6def	fe 01 	. . 
	jp z,l6dffh		;6df1	ca ff 6d 	. . m 
	ld (ix+000h),001h		;6df4	dd 36 00 01 	. 6 . . 
	ld (ix+001h),000h		;6df8	dd 36 01 00 	. 6 . . 
	jp l690fh		;6dfc	c3 0f 69 	. . i 
l6dffh:
	ld (ix+000h),004h		;6dff	dd 36 00 04 	. 6 . . 
	ld (ix+001h),000h		;6e03	dd 36 01 00 	. 6 . . 
	ld (ix+007h),000h		;6e07	dd 36 07 00 	. 6 . . 
	jp l690fh		;6e0b	c3 0f 69 	. . i 
l6e0eh:
	ld (ix+006h),000h		;6e0e	dd 36 06 00 	. 6 . . 
	inc (ix+003h)		;6e12	dd 34 03 	. 4 . 
	ld a,(ix+003h)		;6e15	dd 7e 03 	. ~ . 
	cp 00ch		;6e18	fe 0c 	. . 
	ret nz			;6e1a	c0 	. 
	ld (ix+003h),000h		;6e1b	dd 36 03 00 	. 6 . . 
	inc (ix+004h)		;6e1f	dd 34 04 	. 4 . 
	ld a,(ix+004h)		;6e22	dd 7e 04 	. ~ . 
	cp 001h		;6e25	fe 01 	. . 
	jp nz,l6e64h		;6e27	c2 64 6e 	. d n 
	ld a,(iy+005h)		;6e2a	fd 7e 05 	. ~ . 
	add a,010h		;6e2d	c6 10 	. . 
	ld (iy+009h),a		;6e2f	fd 77 09 	. w . 
	add a,010h		;6e32	c6 10 	. . 
	ld (iy+00dh),a		;6e34	fd 77 0d 	. w . 
	ld (iy+003h),008h		;6e37	fd 36 03 08 	. 6 . . 
	ld (iy+007h),00eh		;6e3b	fd 36 07 0e 	. 6 . . 
	ld (iy+00bh),008h		;6e3f	fd 36 0b 08 	. 6 . . 
	ld (iy+00fh),000h		;6e43	fd 36 0f 00 	. 6 . . 
	ld (iy+002h),020h		;6e47	fd 36 02 20 	. 6 .   
	ld (iy+006h),024h		;6e4b	fd 36 06 24 	. 6 . $ 
	ld (iy+00ah),028h		;6e4f	fd 36 0a 28 	. 6 . ( 
	ld (iy+00eh),001h		;6e53	fd 36 0e 01 	. 6 . . 
	ld (iy+00bh),008h		;6e57	fd 36 0b 08 	. 6 . . 
	ld (iy+00fh),000h		;6e5b	fd 36 0f 00 	. 6 . . 
	ld (iy+003h),008h		;6e5f	fd 36 03 08 	. 6 . . 
	ret			;6e63	c9 	. 
l6e64h:
	ld a,(ix+004h)		;6e64	dd 7e 04 	. ~ . 
	cp 003h		;6e67	fe 03 	. . 
	jp nc,l6ee0h		;6e69	d2 e0 6e 	. . n 
	ld a,0f8h		;6e6c	3e f8 	> . 
	add a,(iy+005h)		;6e6e	fd 86 05 	. . . 
	ld (iy+005h),a		;6e71	fd 77 05 	. w . 
	ld a,0f8h		;6e74	3e f8 	> . 
	add a,(iy+009h)		;6e76	fd 86 09 	. . . 
	ld (iy+009h),a		;6e79	fd 77 09 	. w . 
	ld a,0f8h		;6e7c	3e f8 	> . 
	add a,(iy+00dh)		;6e7e	fd 86 0d 	. . . 
	ld (iy+00dh),a		;6e81	fd 77 0d 	. w . 
	ld (iy+00fh),008h		;6e84	fd 36 0f 08 	. 6 . . 
	ld a,(iy+001h)		;6e88	fd 7e 01 	. ~ . 
	ld (iy+011h),a		;6e8b	fd 77 11 	. w . 
	ld (iy+015h),a		;6e8e	fd 77 15 	. w . 
	ld (iy+019h),a		;6e91	fd 77 19 	. w . 
	ld a,(iy+000h)		;6e94	fd 7e 00 	. ~ . 
	ld (iy+010h),a		;6e97	fd 77 10 	. w . 
	ld (iy+014h),a		;6e9a	fd 77 14 	. w . 
	ld (iy+018h),a		;6e9d	fd 77 18 	. w . 
	ld a,008h		;6ea0	3e 08 	> . 
	add a,(iy+011h)		;6ea2	fd 86 11 	. . . 
	ld (iy+011h),a		;6ea5	fd 77 11 	. w . 
	ld a,0f0h		;6ea8	3e f0 	> . 
	add a,(iy+010h)		;6eaa	fd 86 10 	. . . 
	ld (iy+010h),a		;6ead	fd 77 10 	. w . 
	ld a,018h		;6eb0	3e 18 	> . 
	add a,(iy+015h)		;6eb2	fd 86 15 	. . . 
	ld (iy+015h),a		;6eb5	fd 77 15 	. w . 
	ld a,0f0h		;6eb8	3e f0 	> . 
	add a,(iy+014h)		;6eba	fd 86 14 	. . . 
	ld (iy+014h),a		;6ebd	fd 77 14 	. w . 
	ld a,020h		;6ec0	3e 20 	>   
	add a,(iy+019h)		;6ec2	fd 86 19 	. . . 
	ld (iy+019h),a		;6ec5	fd 77 19 	. w . 
	ld a,0f0h		;6ec8	3e f0 	> . 
	add a,(iy+018h)		;6eca	fd 86 18 	. . . 
	ld (iy+018h),a		;6ecd	fd 77 18 	. w . 
	ld (iy+00bh),00eh		;6ed0	fd 36 0b 0e 	. 6 . . 
	ld (iy+013h),00eh		;6ed4	fd 36 13 0e 	. 6 . . 
	ld (iy+017h),00eh		;6ed8	fd 36 17 0e 	. 6 . . 
	ld (iy+01bh),008h		;6edc	fd 36 1b 08 	. 6 . . 
l6ee0h:
	ld l,(ix+004h)		;6ee0	dd 6e 04 	. n . 
	ld h,000h		;6ee3	26 00 	& . 
	add hl,hl			;6ee5	29 	) 
	ld de,l7019h		;6ee6	11 19 70 	. . p 
	add hl,de			;6ee9	19 	. 
	ld e,(hl)			;6eea	5e 	^ 
	inc hl			;6eeb	23 	# 
	ld d,(hl)			;6eec	56 	V 
	ex de,hl			;6eed	eb 	. 
	push iy		;6eee	fd e5 	. . 
	ld b,007h		;6ef0	06 07 	. . 
l6ef2h:
	ld a,(hl)			;6ef2	7e 	~ 
	ld (iy+002h),a		;6ef3	fd 77 02 	. w . 
	inc hl			;6ef6	23 	# 
	ld de,00004h		;6ef7	11 04 00 	. . . 
	add iy,de		;6efa	fd 19 	. . 
	djnz l6ef2h		;6efc	10 f4 	. . 
	pop iy		;6efe	fd e1 	. . 
	ld a,(ix+004h)		;6f00	dd 7e 04 	. ~ . 
	cp 004h		;6f03	fe 04 	. . 
	ret nz			;6f05	c0 	. 
	ld (ix+004h),000h		;6f06	dd 36 04 00 	. 6 . . 
	ld (ix+000h),000h		;6f0a	dd 36 00 00 	. 6 . . 
	push iy		;6f0e	fd e5 	. . 
	ld b,007h		;6f10	06 07 	. . 
l6f12h:
	ld (iy+003h),000h		;6f12	fd 36 03 00 	. 6 . . 
	ld de,00004h		;6f16	11 04 00 	. . . 
	add iy,de		;6f19	fd 19 	. . 
	djnz l6f12h		;6f1b	10 f5 	. . 
	pop iy		;6f1d	fd e1 	. . 
	ld a,000h		;6f1f	3e 00 	> . 
	ld (VAUS_X2),a		;6f21	32 3e e5 	2 > . 
	ld (ix+006h),000h		;6f24	dd 36 06 00 	. 6 . . 
	ld a,002h		;6f28	3e 02 	> . 
	ld (BRICK_REPAINT_TYPE),a		;6f2a	32 22 e0 	2 " . 
	ld (0e00ah),a		;6f2d	32 0a e0 	2 . . 
	ret			;6f30	c9 	. 
l6f31h:
	ld (ix+006h),001h		;6f31	dd 36 06 01 	. 6 . . 
	ld a,(ix+005h)		;6f35	dd 7e 05 	. ~ . 
	cp 002h		;6f38	fe 02 	. . 
	jp z,l6fe0h		;6f3a	ca e0 6f 	. . o 
	inc (ix+002h)		;6f3d	dd 34 02 	. 4 . 
	ld a,(ix+002h)		;6f40	dd 7e 02 	. ~ . 
	cp 00ah		;6f43	fe 0a 	. . 
	jp nz,l690fh		;6f45	c2 0f 69 	. . i 
	ld (ix+002h),000h		;6f48	dd 36 02 00 	. 6 . . 
	ld a,(ix+007h)		;6f4c	dd 7e 07 	. ~ . 
	cp 001h		;6f4f	fe 01 	. . 
	jp z,l6f80h		;6f51	ca 80 6f 	. . o 
	cp 002h		;6f54	fe 02 	. . 
	jp z,l6fb6h		;6f56	ca b6 6f 	. . o 
	cp 003h		;6f59	fe 03 	. . 
	jp z,l6fb6h		;6f5b	ca b6 6f 	. . o 
	ld a,004h		;6f5e	3e 04 	> . 
	add a,(iy+001h)		;6f60	fd 86 01 	. . . 
	ld (iy+001h),a		;6f63	fd 77 01 	. w . 
	ld a,0fch		;6f66	3e fc 	> . 
	add a,(iy+009h)		;6f68	fd 86 09 	. . . 
	ld (iy+009h),a		;6f6b	fd 77 09 	. w . 
	ld a,0e8h		;6f6e	3e e8 	> . 
	add a,(iy+00dh)		;6f70	fd 86 0d 	. . . 
	ld (iy+00dh),a		;6f73	fd 77 0d 	. w . 
	inc (ix+007h)		;6f76	dd 34 07 	. 4 . 
	ld (ix+005h),001h		;6f79	dd 36 05 01 	. 6 . . 
	jp l690fh		;6f7d	c3 0f 69 	. . i 
l6f80h:
	ld a,004h		;6f80	3e 04 	> . 
	add a,(iy+001h)		;6f82	fd 86 01 	. . . 
	ld (iy+001h),a		;6f85	fd 77 01 	. w . 
	ld a,0f4h		;6f88	3e f4 	> . 
	add a,(iy+009h)		;6f8a	fd 86 09 	. . . 
	ld (iy+009h),a		;6f8d	fd 77 09 	. w . 
	ld (iy+002h),014h		;6f90	fd 36 02 14 	. 6 . . 
	ld (iy+006h),010h		;6f94	fd 36 06 10 	. 6 . . 
	ld (iy+00ah),01ch		;6f98	fd 36 0a 1c 	. 6 . . 
	ld (iy+00eh),018h		;6f9c	fd 36 0e 18 	. 6 . . 
	ld (iy+003h),00eh		;6fa0	fd 36 03 0e 	. 6 . . 
	ld (iy+007h),00eh		;6fa4	fd 36 07 0e 	. 6 . . 
	ld (iy+00bh),008h		;6fa8	fd 36 0b 08 	. 6 . . 
	ld (iy+00fh),00eh		;6fac	fd 36 0f 0e 	. 6 . . 
	inc (ix+007h)		;6fb0	dd 34 07 	. 4 . 
	jp l690fh		;6fb3	c3 0f 69 	. . i 
l6fb6h:
	ld a,0fch		;6fb6	3e fc 	> . 
	add a,(iy+001h)		;6fb8	fd 86 01 	. . . 
	ld (iy+001h),a		;6fbb	fd 77 01 	. w . 
	ld a,004h		;6fbe	3e 04 	> . 
	add a,(iy+00dh)		;6fc0	fd 86 0d 	. . . 
	ld (iy+00dh),a		;6fc3	fd 77 0d 	. w . 
	inc (ix+007h)		;6fc6	dd 34 07 	. 4 . 
	ld a,(ix+007h)		;6fc9	dd 7e 07 	. ~ . 
	cp 004h		;6fcc	fe 04 	. . 
	jp nz,l690fh		;6fce	c2 0f 69 	. . i 
	ld (ix+005h),000h		;6fd1	dd 36 05 00 	. 6 . . 
	ld (ix+007h),000h		;6fd5	dd 36 07 00 	. 6 . . 
	ld (ix+000h),001h		;6fd9	dd 36 00 01 	. 6 . . 
	jp l690fh		;6fdd	c3 0f 69 	. . i 
l6fe0h:
	ld (ix+000h),003h		;6fe0	dd 36 00 03 	. 6 . . 
	jp l690fh		;6fe4	c3 0f 69 	. . i 
l6fe7h:
	xor (hl)			;6fe7	ae 	. 
	ld d,b			;6fe8	50 	P 
	ex af,af'			;6fe9	08 	. 
	ex af,af'			;6fea	08 	. 
	xor (hl)			;6feb	ae 	. 
	ld h,b			;6fec	60 	` 
	inc b			;6fed	04 	. 
	ld c,0aeh		;6fee	0e ae 	. . 
	ld (hl),b			;6ff0	70 	p 
	inc c			;6ff1	0c 	. 
	ex af,af'			;6ff2	08 	. 
	xor (hl)			;6ff3	ae 	. 
	add a,b			;6ff4	80 	. 
	ld bc,00000h		;6ff5	01 00 00 	. . . 
	nop			;6ff8	00 	. 
	nop			;6ff9	00 	. 
	nop			;6ffa	00 	. 
	nop			;6ffb	00 	. 
	nop			;6ffc	00 	. 
	nop			;6ffd	00 	. 
	nop			;6ffe	00 	. 
	nop			;6fff	00 	. 
	call m,0fc00h		;7000	fc 00 fc 	. . . 
	nop			;7003	00 	. 
	call m,00000h		;7004	fc 00 00 	. . . 
	nop			;7007	00 	. 
	inc b			;7008	04 	. 
	nop			;7009	00 	. 
	inc b			;700a	04 	. 
	nop			;700b	00 	. 
	inc b			;700c	04 	. 
	nop			;700d	00 	. 
	nop			;700e	00 	. 
	nop			;700f	00 	. 
	nop			;7010	00 	. 
	nop			;7011	00 	. 
	nop			;7012	00 	. 
	nop			;7013	00 	. 
	nop			;7014	00 	. 
	nop			;7015	00 	. 
	nop			;7016	00 	. 
	nop			;7017	00 	. 
	nop			;7018	00 	. 
l7019h:
	nop			;7019	00 	. 
	nop			;701a	00 	. 
	nop			;701b	00 	. 
	nop			;701c	00 	. 
	dec hl			;701d	2b 	+ 
	ld (hl),b			;701e	70 	p 
	ld (02b70h),a		;701f	32 70 2b 	2 p + 
	ld (hl),b			;7022	70 	p 
	ld (02b70h),a		;7023	32 70 2b 	2 p + 
	ld (hl),b			;7026	70 	p 
	ld (02b70h),a		;7027	32 70 2b 	2 p + 
	ld (hl),b			;702a	70 	p 
	jr c,$+62		;702b	38 3c 	8 < 
	ld b,b			;702d	40 	@ 
	ld b,h			;702e	44 	D 
	inc l			;702f	2c 	, 
	jr nc,$+54		;7030	30 34 	0 4 
	ld d,h			;7032	54 	T 
	ld e,b			;7033	58 	X 
	ld e,h			;7034	5c 	\ 
	ld h,b			;7035	60 	` 
	ld c,b			;7036	48 	H 
	ld c,h			;7037	4c 	L 
	ld d,b			;7038	50 	P 
sub_7039h:
	call sub_7040h		;7039	cd 40 70 	. @ p 
	call sub_70b0h		;703c	cd b0 70 	. . p 
	ret			;703f	c9 	. 
sub_7040h:
	ld ix,0e54bh		;7040	dd 21 4b e5 	. ! K . 
	ld a,(ix+006h)		;7044	dd 7e 06 	. ~ . 
	or a			;7047	b7 	. 
	ret z			;7048	c8 	. 
	ld a,(ix+000h)		;7049	dd 7e 00 	. ~ . 
	cp 007h		;704c	fe 07 	. . 
	ret z			;704e	c8 	. 
	ld b,001h		;704f	06 01 	. . 
    
    ; Skip the following if we're at the title screen
	ld a,(GAME_STATE)		;7051	3a 0b e0
	or a			        ;7054	b7
	jp z,l7074h		        ;7055	ca 74 70
	
    ld a,(0e00ch)		;7058	3a 0c e0 	: . . 
	or a			;705b	b7 	. 
	jp z,l706ah		;705c	ca 6a 70 	. j p 
	ld a,(0e0c5h)		;705f	3a c5 e0 	: . . 
	bit 1,a		;7062	cb 4f 	. O 
	jp z,l70afh		;7064	ca af 70 	. . p 
	jp l7072h		;7067	c3 72 70 	. r p 
l706ah:
	ld a,(0e0bfh)		;706a	3a bf e0 	: . . 
	bit 4,a		;706d	cb 67 	. g 
	jp z,l70afh		;706f	ca af 70 	. . p 
l7072h:
	ld b,002h		;7072	06 02 	. . 
l7074h:
	ld ix,0e557h		;7074	dd 21 57 e5 	. ! W . 
	ld iy,0e0e9h		;7078	fd 21 e9 e0 	. ! . . 
l707ch:
	ld a,(ix+000h)		;707c	dd 7e 00 	. ~ . 
	or a			;707f	b7 	. 
	jp nz,l70a6h		;7080	c2 a6 70 	. . p 
	ld (ix+000h),001h		;7083	dd 36 00 01 	. 6 . . 
	ld a,(VAUS_X)		;7087	3a ce e0 	: . . 
	add a,010h		;708a	c6 10 	. . 
	ld (iy+000h),0aeh		;708c	fd 36 00 ae 	. 6 . . 
	ld (iy+001h),a		;7090	fd 77 01 	. w . 
	ld (iy+002h),084h		;7093	fd 36 02 84 	. 6 . . 
	ld (iy+003h),005h		;7097	fd 36 03 05 	. 6 . . 
	ld a,006h		;709b	3e 06 	> . 
	call sub_5befh		;709d	cd ef 5b 	. . [ 
	call UPDATE_SPEED_ALL_BALLS		;70a0	cd 6e 71 	. n q 
	jp l70afh		;70a3	c3 af 70 	. . p 
l70a6h:
	ld de,00004h		;70a6	11 04 00 	. . . 
	add iy,de		;70a9	fd 19 	. . 
	add ix,de		;70ab	dd 19 	. . 
	djnz l707ch		;70ad	10 cd 	. . 
l70afh:
	ret			;70af	c9 	. 
sub_70b0h:
	ld a,001h		;70b0	3e 01 	> . 
	ld (0e519h),a		;70b2	32 19 e5 	2 . . 
	ld ix,0e0e9h		;70b5	dd 21 e9 e0 	. ! . . 
	ld iy,0e557h		;70b9	fd 21 57 e5 	. ! W . 
	ld b,003h		;70bd	06 03 	. . 
l70bfh:
	push bc			;70bf	c5 	. 
	xor a			;70c0	af 	. 
	ld (0e53ch),a		;70c1	32 3c e5 	2 < . 
	ld a,(iy+000h)		;70c4	fd 7e 00 	. ~ . 
	or a			;70c7	b7 	. 
	jp z,l715dh		;70c8	ca 5d 71 	. ] q 
	ld a,0fbh		;70cb	3e fb 	> . 
	add a,(ix+000h)		;70cd	dd 86 00 	. . . 
	ld (ix+000h),a		;70d0	dd 77 00 	. w . 
	cp 008h		;70d3	fe 08 	. . 
	jp c,l7155h		;70d5	da 55 71 	. U q 
	ld a,(ix+000h)		;70d8	dd 7e 00 	. ~ . 
	cp 017h		;70db	fe 17 	. . 
	jp c,l715dh		;70dd	da 5d 71 	. ] q 
	cp 077h		;70e0	fe 77 	. w 
	jp nc,l715dh		;70e2	d2 5d 71 	. ] q 
	sub 017h		;70e5	d6 17 	. . 
	srl a		;70e7	cb 3f 	. ? 
	srl a		;70e9	cb 3f 	. ? 
	srl a		;70eb	cb 3f 	. ? 
	ld (BRICK_ROW),a		;70ed	32 aa e2 	2 . . 
	ld a,(ix+001h)		;70f0	dd 7e 01 	. ~ . 
	cp 010h		;70f3	fe 10 	. . 
	jp c,l7118h		;70f5	da 18 71 	. . q 
	cp 0bfh		;70f8	fe bf 	. . 
	jp nc,l7118h		;70fa	d2 18 71 	. . q 
	sub 010h		;70fd	d6 10 	. . 
	srl a		;70ff	cb 3f 	. ? 
	srl a		;7101	cb 3f 	. ? 
	srl a		;7103	cb 3f 	. ? 
	srl a		;7105	cb 3f 	. ? 
	ld (BRICK_COL),a		;7107	32 ab e2 	2 . . 
	call sub_ada8h		;710a	cd a8 ad 	. . . 
	jp nc,l7118h		;710d	d2 18 71 	. . q 
	ld a,001h		;7110	3e 01 	> . 
	ld (0e53ch),a		;7112	32 3c e5 	2 < . 
	call sub_aa05h		;7115	cd 05 aa 	. . . 
l7118h:
	ld a,(ix+001h)		;7118	dd 7e 01 	. ~ . 
	add a,00eh		;711b	c6 0e 	. . 
	cp 010h		;711d	fe 10 	. . 
	jp c,l7142h		;711f	da 42 71 	. B q 
	cp 0bfh		;7122	fe bf 	. . 
	jp nc,l7142h		;7124	d2 42 71 	. B q 
	sub 010h		;7127	d6 10 	. . 
	srl a		;7129	cb 3f 	. ? 
	srl a		;712b	cb 3f 	. ? 
	srl a		;712d	cb 3f 	. ? 
	srl a		;712f	cb 3f 	. ? 
	ld (BRICK_COL),a		;7131	32 ab e2 	2 . . 
	call sub_ada8h		;7134	cd a8 ad 	. . . 
	jp nc,l7142h		;7137	d2 42 71 	. B q 
	ld a,001h		;713a	3e 01 	> . 
	ld (0e53ch),a		;713c	32 3c e5 	2 < . 
	call sub_aa05h		;713f	cd 05 aa 	. . . 
l7142h:
	ld a,(0e53ch)		;7142	3a 3c e5 	: < . 
	or a			;7145	b7 	. 
	jp z,l715dh		;7146	ca 5d 71 	. ] q 
	ld (ix+000h),0c0h		;7149	dd 36 00 c0 	. 6 . . 
	ld (ix+002h),000h		;714d	dd 36 02 00 	. 6 . . 
	ld (iy+000h),000h		;7151	fd 36 00 00 	. 6 . . 
l7155h:
	ld (ix+000h),0c0h		;7155	dd 36 00 c0 	. 6 . . 
	ld (iy+000h),000h		;7159	fd 36 00 00 	. 6 . . 
l715dh:
	pop bc			;715d	c1 	. 
	ld de,00004h		;715e	11 04 00 	. . . 
	add ix,de		;7161	dd 19 	. . 
	add iy,de		;7163	fd 19 	. . 
	dec b			;7165	05 	. 
	jp nz,l70bfh		;7166	c2 bf 70 	. . p 
	xor a			;7169	af 	. 
	ld (0e519h),a		;716a	32 19 e5 	2 . . 
	ret			;716d	c9 	. 

; Speed up all active balls if the counter has reached its maximum
UPDATE_SPEED_ALL_BALLS:
	; It seems they decided not to implement this.
    ret			;716e	c9

	push ix		;716f	dd e5 	. . 
	push bc			;7171	c5 	. 

    ; Increase the counter
	ld hl,SPEEDUP_ALL_BALLS_COUNTER		;7172	21 29 e5 	! ) . 
	inc (hl)			;7175	34 	4 
	ld a,(hl)			;7176	7e 	~ 
	cp 008h		;7177	fe 08 	. . 
    ; If less than 8, get out
	jp c,l71a1h		;7179	da a1 71 	. . q 
    ; Reset counter
	ld (hl),000h		;717c	36 00 	6 . 

    ; Now a loop to increase the speed of all balls
	ld ix,BALL_TABLE1		;717e	dd 21 4e e2 	. ! N . 
	ld de, BALL_TABLE_LEN	;7182	11 14 00
	ld b, 3		            ;7185	06 03 Three balls
l7187h:
	ld a,(ix + BALL_TABLE_IDX_ACTIVE)		;7187	dd 7e 00
	or a			                        ;718a	b7
    ; If the ball is not active, go on
	jr z,l719dh		                        ;718b	28 10
    
    ; Increase the speed of the ball
	ld a,(ix + BALL_TABLE_IDX_SPEED_POS)		;718d	dd 7e 07
	inc a			                            ;7190	3c
	ld (ix + BALL_TABLE_IDX_SPEED_POS),a		    ;7191	dd 77 07
	cp 16		                                ;7194	fe 10
	jp nz,l719dh		                        ;7196	c2 9d 71
    ; If the speed is over 15, set it to 15
	ld (ix+BALL_TABLE_IDX_SPEED_POS), 15        ;7199	dd 36 07 0f
l719dh:
    ; Next ball
	add ix,de		;719d	dd 19
	djnz l7187h		;719f	10 e6
l71a1h:
	pop bc		;71a1	c1
	pop ix		;71a2	dd e1
	ret			;71a4	c9

	jr $+26		;71a5	18 18 	. . 
	jr l71c1h		;71a7	18 18 	. . 
	jr l71e7h		;71a9	18 3c 	. < 
	ld l,d			;71ab	6a 	j 
	sbc a,c			;71ac	99 	. 
	ld a,(hl)			;71ad	7e 	~ 
	adc a,h			;71ae	8c 	. 
	nop			;71af	00 	. 
	dec b			;71b0	05 	. 
	ld a,(hl)			;71b1	7e 	~ 
	adc a,h			;71b2	8c 	. 
	ld bc,07e05h		;71b3	01 05 7e 	. . ~ 
	adc a,h			;71b6	8c 	. 
	ld (bc),a			;71b7	02 	. 
	dec b			;71b8	05 	. 

; Draw the lives
DRAW_LIVES:
	ld a,(LIVES)		;71b9	3a 1d e0 	: . . 
	or a			;71bc	b7 	. 
	ret z			;71bd	c8 	. 
	ld a,(LIVES)		;71be	3a 1d e0 	: . . 
l71c1h:
    ; Display only up to 6 lives
	cp 6		    ;71c1	fe 06
	jp c,l71c8h		;71c3	da c8 71
	ld a, 6		    ;71c6	3e 06
l71c8h:
	ld (0e53ch),a		;71c8	32 3c e5 	2 < . 
	xor a			;71cb	af 	. 
	ld (0e53dh),a		;71cc	32 3d e5 	2 = . 
	ld iy,0197ah		;71cf	fd 21 7a 19 	. ! z . 
l71d3h:
	ld a,(0e53dh)		;71d3	3a 3d e5 	: = . 
	ld l,a			;71d6	6f 	o 
	ld h,000h		;71d7	26 00 	& . 
	add hl,hl			;71d9	29 	) 
	ld de,l71f8h		;71da	11 f8 71 	. . q 
	add hl,de			;71dd	19 	. 
	ld e,(hl)			;71de	5e 	^ 
	inc hl			;71df	23 	# 
	ld d,(hl)			;71e0	56 	V 
	ld hl,l71f6h		;71e1	21 f6 71 	! . q 
	ld bc,00002h		;71e4	01 02 00 	. . . 
l71e7h:
	call LDIRVM		;71e7	cd 5c 00 	. \ . 
	ld hl,0e53dh		;71ea	21 3d e5 	! = . 
	inc (hl)			;71ed	34 	4 
	ld hl,0e53ch		;71ee	21 3c e5 	! < . 
	dec (hl)			;71f1	35 	5 
	jp nz,l71d3h		;71f2	c2 d3 71 	. . q 
	ret			;71f5	c9 	. 

l71f6h:
	ld l,c			;71f6	69 	i 
	ld l,d			;71f7	6a 	j 
l71f8h:
	ld a,d			;71f8	7a 	z 
	add hl,de			;71f9	19 	. 
	ld a,h			;71fa	7c 	| 
	add hl,de			;71fb	19 	. 
	ld a,(hl)			;71fc	7e 	~ 
	add hl,de			;71fd	19 	. 
	sbc a,d			;71fe	9a 	. 
	add hl,de			;71ff	19 	. 
	sbc a,h			;7200	9c 	. 
	add hl,de			;7201	19 	. 
	sbc a,(hl)			;7202	9e 	. 
	add hl,de			;7203	19 	. 

; Write "ROUND x"
WRITE_ROUND_MSG:
	ld hl,l723ch		;7204	21 3c 72 	! < r 
	ld de,01adah		;7207	11 da 1a 	. . . 
	ld bc,00005h		;720a	01 05 00 	. . . 
	call LDIRVM		;720d	cd 5c 00 	. \ . 
	ld a,(LEVEL_DISP)		;7210	3a 1c e0 	: . . 
	add a,001h		;7213	c6 01 	. . 
	daa			;7215	27 	' 
	ld e,a			;7216	5f 	_ 
	push de			;7217	d5 	. 
	srl a		;7218	cb 3f 	. ? 
	srl a		;721a	cb 3f 	. ? 
	srl a		;721c	cb 3f 	. ? 
	srl a		;721e	cb 3f 	. ? 
	add a,030h		;7220	c6 30 	. 0 
	cp 030h		;7222	fe 30 	. 0 
	jp nz,l7229h		;7224	c2 29 72 	. ) r 
	ld a,020h		;7227	3e 20 	>   
l7229h:
	ld hl,01afdh		;7229	21 fd 1a 	! . . 
	call WRTVRM		;722c	cd 4d 00 	. M . 
	pop de			;722f	d1 	. 
	ld a,e			;7230	7b 	{ 
	and 00fh		;7231	e6 0f 	. . 
	add a,030h		;7233	c6 30 	. 0 
	ld hl,01afeh		;7235	21 fe 1a 	! . . 
	call WRTVRM		;7238	cd 4d 00 	. M . 
	ret			;723b	c9 	. 

l723ch:
	ld d,d			;723c	52 	R 
	ld c,a			;723d	4f 	O 
	ld d,l			;723e	55 	U 
	ld c,(hl)			;723f	4e 	N 
	ld b,h			;7240	44 	D 

sub_7241h:
    ; Skip the following and jump if we're not at the title screen
	ld a,(GAME_STATE)		;7241	3a 0b e0
	or a			        ;7244	b7
	jp nz,l726eh		    ;7245	c2 6e 72
    
	ld hl,(0e5adh)		;7248	2a ad e5 	* . . 
	inc hl			;724b	23 	# 
	ld (0e5adh),hl		;724c	22 ad e5 	" . . 
	ld a,l			;724f	7d 	} 
	cp 040h		;7250	fe 40 	. @ 
	jp nz,l726eh		;7252	c2 6e 72 	. n r 
	ld a,h			;7255	7c 	| 
	cp 00bh		;7256	fe 0b 	. . 
	jp nz,l726eh		;7258	c2 6e 72 	. n r 
	ld a,000h		;725b	3e 00 	> . 
	ld (0e00ah),a		;725d	32 0a e0 	2 . . 
	ld hl,0e53ch		;7260	21 3c e5 	! < . 
	ld de,0e53dh		;7263	11 3d e5 	. = . 
	ld bc,00007h		;7266	01 07 00 	. . . 
	ld (hl),000h		;7269	36 00 	6 . 
	ldir		;726b	ed b0 	. . 
	ret			;726d	c9 	. 

l726eh:
	ld a,(LEVEL)		;726e	3a 1b e0
	cp FINAL_LEVEL		;7271	fe 20
	jp z,l7286h		;7273	ca 86 72 	. . r 
	call sub_7605h		;7276	cd 05 76 	. . v 
	call sub_7888h		;7279	cd 88 78 	. . x 
	call sub_7942h		;727c	cd 42 79 	. B y 
	call UPDATE_ALIEN_APPEAR_FROM_DOOR		;727f	cd 0c 73 	. . s 
	call UPDATE_DOORS		;7282	cd a0 72 	. . r 
	ret			;7285	c9 	. 
l7286h:
	ld a,(0e50dh)		;7286	3a 0d e5 	: . . 
	or a			;7289	b7 	. 
	jp nz,l7296h		;728a	c2 96 72 	. . r 
	call sub_7594h		;728d	cd 94 75 	. . u 
	call sub_7469h		;7290	cd 69 74 	. i t 
	call sub_7a68h		;7293	cd 68 7a 	. h z 
l7296h:
	call sub_74c7h		;7296	cd c7 74 	. . t 
	call sub_73aah		;7299	cd aa 73 	. . s 
	call sub_73f0h		;729c	cd f0 73 	. . s 
	ret			;729f	c9 	. 

; Draw the doors according to their state, if active
UPDATE_DOORS:
	ld ix,DOOR_TABLE		                ;72a0	dd 21 70 e5

    ; Return if not active
	ld a,(ix + DOOR_TABLE_IDX_ACTIVE)		;72a4	dd 7e 00
	or a			                                ;72a7	b7
	ret z			                                ;72a8	c8
	
    ; Increment counter and exit if it hasn't reached 18
    inc (ix+DOOR_TABLE_IDX_COUNTER)		    ;72a9	dd 34 03
	ld a,(ix+DOOR_TABLE_IDX_COUNTER)		;72ac	dd 7e 03
	cp 18		                            ;72af	fe 12
	ret nz			                        ;72b1	c0

    ; Reset counter
	ld (ix+DOOR_TABLE_IDX_COUNTER), 0		;72b2	dd 36 03 00
    
	; HL = 4 * (ix+DOOR_TABLE_IDX_DOOR_OPEN_COUNTER)
    ; Each door is 4 chars
    ld l,(ix+DOOR_TABLE_IDX_DOOR_OPEN_COUNTER)		        ;72b6	dd 6e 04
	ld h, 0 		                                        ;72b9	26 00
	add hl,hl			                                    ;72bb	29
	add hl,hl			                                    ;72bc	29
    
    ; HL = 4 * (ix+DOOR_TABLE_IDX_DOOR_OPEN_COUNTER) + DOOR_CHARS
    ; HL = DOOR_CHARS[3 * DOOR_TABLE[DOOR_TABLE_IDX_DOOR_OPEN_COUNTER]]
	ld de, DOOR_CHARS		                                ;72bd	11 f4 72
	add hl,de			                                    ;72c0	19
    
    ; Choose the VRAM position of the door on the left or on the right
	ld de, 0x1800 + 5 + 0*32		    ;72c1	11 05 18 Locate [5, 0]
	ld a,(ix+DOOR_TABLE_IDX_DOOR)		;72c4	dd 7e 01
	or a			                    ;72c7	b7
	jp nz,l72ceh		                ;72c8	c2 ce 72
	ld de, 0x1800 + 17 + 0*32           ;72cb	11 11 18 Locate [17, 0]
l72ceh:
    ; Update door in VRAM
	ld bc, 4		    ;72ce	01 04 00 The door is 4 tiles
	call LDIRVM		    ;72d1	cd 5c 00

    ; Increment X = (ix+004h).
    ; If X = 0 THEN call sub_7377h and exit
    ; If X != 6 THEN exit
    ; Clear the DOOR_TABLE
    
	inc (ix+DOOR_TABLE_IDX_DOOR_OPEN_COUNTER)		;72d4	dd 34 04
	ld a,(ix+DOOR_TABLE_IDX_DOOR_OPEN_COUNTER)		;72d7	dd 7e 04
	cp 3		                                    ;72da	fe 03
	jp nz,l72e3h		;72dc	c2 e3 72 	. . r 
	call sub_7377h		;72df	cd 77 73 	. w s 
	ret			;72e2	c9 	. 

l72e3h:
    ; The door is open for 6 cycles.
    ; If we haven't reached 6, then exit. Other wise, clear the whole table.
	cp 6		    ;72e3	fe 06
	ret nz			;72e5	c0
    
    ; Clear DOOR_TABLE
	ld hl,DOOR_TABLE		;72e6	21 70 e5
	ld de,DOOR_TABLE + 1	;72e9	11 71 e5
	ld bc,DOOR_TABLE_LEN   ;72ec	01 06 00
	ld (hl), 0  		            ;72ef	36 00
	ldir		                    ;72f1	ed b0
	ret			                    ;72f3	c9

; Chars corresponding to the states door closed, opening, open, opening, closed.
DOOR_CHARS:
    ; Door closed
    db 8, 9, 10, 11

    ; Door opening
    db 14, 15, 16, 17

    ; Door open
    db 18, 19, 20, 21

    ; Door open
    db 18, 19, 20, 21

	; Door opening
    db 14, 15, 16, 17

    ; Door closed
    db 8, 9, 10, 11

; Check ticks and update alien's appearing from the left or
; right, depending on Vaus' position.
UPDATE_ALIEN_APPEAR_FROM_DOOR:
    ; Increment number of ticks and return if it's not 240
	ld ix,TICKS_240		;730c	dd 21 15 e5
	inc (ix+0)		;7310	dd 34 00
	ld a,(ix+0)		;7313	dd 7e 00
	cp 240		    ;7316	fe f0
	ret nz			;7318	c0
l7319h:
    ; Reset ticks
	ld (ix), 0		    ;7319	dd 36 00 00
    
    ; DE = level
	ld a,(LEVEL)		;731d	3a 1b e0
	ld e,a			    ;7320	5f
	ld d, 0 		    ;7321	16 00
    
    ; HL = TABLE_ALIENS_PER_LEVEL + level
	ld hl,TABLE_ALIENS_PER_LEVEL		;7323	21 53 73
	add hl,de			                ;7326	19
    
    ; B = TABLE_ALIENS_PER_LEVEL[level] = number of aliens in this level
	ld b,(hl)			        ;7327	46

	ld iy,ALIEN_TABLE		    ;7328	fd 21 c7 e4
    ; Loop 
l732ch:
    ; Skip if the alien is not active
	ld a,(iy + ALIEN_TABLE_IDX_ACTIVE)		;732c	fd 7e 01
	or a			                        ;732f	b7
	jp nz,l734bh		                    ;7330	c2 4b 73

    ; Set doors active
	ld a,001h		                        ;7333	3e 01
	ld (DOOR_TABLE),a		                ;7335	32 70 e5

    ; Alien will appear on the right
	ld c, 0		        ;7338	0e 00

    ; A = VAUS_X + 16
	ld a,(VAUS_X)		;733a	3a ce e0        0x70
	add a, 16		    ;733d	c6 10           0x80
    
    ; C = 0 (right) if VAUS_X + 16 < 81 else 1 (left)
    ; C = VAUS_X + 16 >= 81
	cp 81		        ;733f	fe 51           C=0
	jp c,l7346h		    ;7341	da 46 73
    
    ; Alien will appear on the left
	ld c, 1 		    ;7344	0e 01
l7346h:
    ; Set alien's door
	ld a,c			    ;7346	79
	ld (DOOR_TABLE + DOOR_TABLE_IDX_DOOR),a	;7347	32 71 e5
	ret			        ;734a	c9

l734bh:
    ; Next alien entry
	ld de, ALIEN_TABLE_LEN		;734b	11 14 00
	add iy,de		            ;734e	fd 19
	djnz l732ch		            ;7350	10 da
	ret			;7352	c9 	. 

; Number of aliens per level
TABLE_ALIENS_PER_LEVEL:
    db 1, 2, 3
    db 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
    db 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
    db 3, 3, 3, 3, 3, 3, 3, 3, 3

TABLE_0123:
    db 0, 1, 2, 3

sub_7377h:
	ld a,(LEVEL)		;7377	3a 1b e0 	: . . 
	ld e,a			;737a	5f 	_ 
	ld d,000h		;737b	16 00 	. . 
	ld hl,TABLE_ALIENS_PER_LEVEL		;737d	21 53 73 	! S s 
	add hl,de			;7380	19 	. 
	ld b,(hl)			;7381	46 	F 
	ld iy,ALIEN_TABLE		;7382	fd 21 c7 e4 	. ! . . 
l7386h:
	ld a,(iy+001h)		;7386	fd 7e 01 	. ~ . 
	or a			;7389	b7 	. 
	jp nz,l73a2h		;738a	c2 a2 73 	. . s 
	ld (iy+001h),001h		;738d	fd 36 01 01 	. 6 . . 
	ld a,(LEVEL)		;7391	3a 1b e0 	: . . 
	and 003h		;7394	e6 03 	. . 
	ld e,a			;7396	5f 	_ 
	ld d,000h		;7397	16 00 	. . 
	ld hl,TABLE_0123		;7399	21 73 73 	! s s 
	add hl,de			;739c	19 	. 
	ld a,(hl)			;739d	7e 	~ 
	ld (iy+000h),a		;739e	fd 77 00 	. w . 
	ret			;73a1	c9 	. 
l73a2h:
	ld de,00014h		;73a2	11 14 00 	. . . 
	add iy,de		;73a5	fd 19 	. . 
	djnz l7386h		;73a7	10 dd 	. . 
	ret			;73a9	c9 	. 
sub_73aah:
	ld ix,0e50dh		;73aa	dd 21 0d e5 	. ! . . 
	ld a,(ix+000h)		;73ae	dd 7e 00 	. ~ . 
	or a			;73b1	b7 	. 
	ret nz			;73b2	c0 	. 
	ld ix,0e505h		;73b3	dd 21 05 e5 	. ! . . 
	ld a,(ix+000h)		;73b7	dd 7e 00 	. ~ . 
	or a			;73ba	b7 	. 
	ret z			;73bb	c8 	. 
	inc (ix+001h)		;73bc	dd 34 01 	. 4 . 
	ld a,(ix+001h)		;73bf	dd 7e 01 	. ~ . 
	cp 003h		;73c2	fe 03 	. . 
	ret nz			;73c4	c0 	. 
	ld (ix+001h),000h		;73c5	dd 36 01 00 	. 6 . . 
	ld e,(ix+002h)		;73c9	dd 5e 02 	. ^ . 
	ld d,000h		;73cc	16 00 	. . 
	ld hl,l7450h		;73ce	21 50 74 	! P t 
	add hl,de			;73d1	19 	. 
	ld a,(hl)			;73d2	7e 	~ 
	call sub_7452h		;73d3	cd 52 74 	. R t 
	inc (ix+002h)		;73d6	dd 34 02 	. 4 . 
	ld a,(ix+002h)		;73d9	dd 7e 02 	. ~ . 
	cp 002h		;73dc	fe 02 	. . 
	ret nz			;73de	c0 	. 
	ld (ix+000h),000h		;73df	dd 36 00 00 	. 6 . . 
	ld (ix+001h),000h		;73e3	dd 36 01 00 	. 6 . . 
	ld (ix+002h),000h		;73e7	dd 36 02 00 	. 6 . . 
	ld (ix+003h),000h		;73eb	dd 36 03 00 	. 6 . . 
	ret			;73ef	c9 	. 
sub_73f0h:
	ld ix,0e50dh		;73f0	dd 21 0d e5 	. ! . . 
	ld a,(ix+000h)		;73f4	dd 7e 00 	. ~ . 
	or a			;73f7	b7 	. 
	ret z			;73f8	c8 	. 
	ld a,(ix+001h)		;73f9	dd 7e 01 	. ~ . 
	cp 001h		;73fc	fe 01 	. . 
	jp z,l7410h		;73fe	ca 10 74 	. . t 
	cp 002h		;7401	fe 02 	. . 
	jp z,l7441h		;7403	ca 41 74 	. A t 
	ld a,0e1h		;7406	3e e1 	> . 
	call sub_7452h		;7408	cd 52 74 	. R t 
	ld (ix+001h),001h		;740b	dd 36 01 01 	. 6 . . 
	ret			;740f	c9 	. 
l7410h:
	inc (ix+002h)		;7410	dd 34 02 	. 4 . 
	ld a,(ix+002h)		;7413	dd 7e 02 	. ~ . 
	cp 016h		;7416	fe 16 	. . 
	ret nz			;7418	c0 	. 
	ld (ix+002h),000h		;7419	dd 36 02 00 	. 6 . . 
	ld l,(ix+003h)		;741d	dd 6e 03 	. n . 
	ld h,000h		;7420	26 00 	& . 
	add hl,hl			;7422	29 	) 
	add hl,hl			;7423	29 	) 
	add hl,hl			;7424	29 	) 
	add hl,hl			;7425	29 	) 
	add hl,hl			;7426	29 	) 
	ld de,01869h		;7427	11 69 18 	. i . 
	add hl,de			;742a	19 	. 
	ld bc,00008h		;742b	01 08 00 	. . . 
	ld a,000h		;742e	3e 00 	> . 
	call FILVRM		;7430	cd 56 00 	. V . 
	inc (ix+003h)		;7433	dd 34 03 	. 4 . 
	ld a,(ix+003h)		;7436	dd 7e 03 	. ~ . 
	cp 00ch		;7439	fe 0c 	. . 
	ret nz			;743b	c0 	. 
	ld (ix+001h),002h		;743c	dd 36 01 02 	. 6 . . 
	ret			;7440	c9 	. 
l7441h:
	inc (ix+004h)		;7441	dd 34 04 	. 4 . 
	ld a,(ix+004h)		;7444	dd 7e 04 	. ~ . 
	cp 078h		;7447	fe 78 	. x 
	ret nz			;7449	c0 	. 
	ld a,002h		;744a	3e 02 	> . 
	ld (0e00ah),a		;744c	32 0a e0 	2 . . 
	ret			;744f	c9 	. 
l7450h:
	pop af			;7450	f1 	. 
	add a,c			;7451	81 	. 
sub_7452h:
	push af			;7452	f5 	. 
	ld hl,02480h		;7453	21 80 24 	! . $ 
	ld bc,00380h		;7456	01 80 03 	. . . 
	call FILVRM		;7459	cd 56 00 	. V . 
	pop af			;745c	f1 	. 
	push af			;745d	f5 	. 
	ld hl,02c80h		;745e	21 80 2c 	! . , 
	ld bc,00380h		;7461	01 80 03 	. . . 
	call FILVRM		;7464	cd 56 00 	. V . 
	pop af			;7467	f1 	. 
	ret			;7468	c9 	. 
sub_7469h:
	ld a,(0e51ah)		;7469	3a 1a e5 	: . . 
	cp 003h		;746c	fe 03 	. . 
	ret z			;746e	c8 	. 
	ld hl,0e578h		;746f	21 78 e5 	! x . 
	ld a,(hl)			;7472	7e 	~ 
	or a			;7473	b7 	. 
	jp z,l7483h		;7474	ca 83 74 	. . t 
	inc hl			;7477	23 	# 
	inc (hl)			;7478	34 	4 
	ld a,(hl)			;7479	7e 	~ 
	cp 078h		;747a	fe 78 	. x 
	ret nz			;747c	c0 	. 
	ld (hl),000h		;747d	36 00 	6 . 
	dec hl			;747f	2b 	+ 
	ld (hl),000h		;7480	36 00 	6 . 
	ret			;7482	c9 	. 
l7483h:
	ld a,(0e581h)		;7483	3a 81 e5 	: . . 
	add a,001h		;7486	c6 01 	. . 
	ld (0e581h),a		;7488	32 81 e5 	2 . . 
	cp 00ch		;748b	fe 0c 	. . 
	ret c			;748d	d8 	. 
	ld a,000h		;748e	3e 00 	> . 
	ld (0e581h),a		;7490	32 81 e5 	2 . . 
	ld b,003h		;7493	06 03 	. . 
	ld ix,0e563h		;7495	dd 21 63 e5 	. ! c . 
	ld iy,0e10dh		;7499	fd 21 0d e1 	. ! . . 
l749dh:
	ld a,(ix+000h)		;749d	dd 7e 00 	. ~ . 
	or a			;74a0	b7 	. 
	jp nz,l74bdh		;74a1	c2 bd 74 	. . t 
	ld (ix+000h),001h		;74a4	dd 36 00 01 	. 6 . . 
	ld (iy+000h),050h		;74a8	fd 36 00 50 	. 6 . P 
	ld (iy+001h),064h		;74ac	fd 36 01 64 	. 6 . d 
	ld (iy+002h),08ch		;74b0	fd 36 02 8c 	. 6 . . 
	ld (iy+003h),00eh		;74b4	fd 36 03 0e 	. 6 . . 
	ld hl,0e51ah		;74b8	21 1a e5 	! . . 
	inc (hl)			;74bb	34 	4 
	ret			;74bc	c9 	. 
l74bdh:
	ld de,00004h		;74bd	11 04 00 	. . . 
	add iy,de		;74c0	fd 19 	. . 
	add ix,de		;74c2	dd 19 	. . 
	djnz l749dh		;74c4	10 d7 	. . 
	ret			;74c6	c9 	. 
sub_74c7h:
	ld b,003h		;74c7	06 03 	. . 
	ld ix,0e563h		;74c9	dd 21 63 e5 	. ! c . 
	ld iy,0e10dh		;74cd	fd 21 0d e1 	. ! . . 
l74d1h:
	push bc			;74d1	c5 	. 
	ld a,(ix+000h)		;74d2	dd 7e 00 	. ~ . 
	or a			;74d5	b7 	. 
	jp z,l7566h		;74d6	ca 66 75 	. f u 
	ld a,(ix+001h)		;74d9	dd 7e 01 	. ~ . 
	or a			;74dc	b7 	. 
	jp nz,l7501h		;74dd	c2 01 75 	. . u 
	ld (ix+001h),001h		;74e0	dd 36 01 01 	. 6 . . 
	ld hl,0e0cdh		;74e4	21 cd e0 	! . . 
	inc hl			;74e7	23 	# 
	ld a,(hl)			;74e8	7e 	~ 
	sub 008h		;74e9	d6 08 	. . 
	and 0f8h		;74eb	e6 f8 	. . 
	srl a		;74ed	cb 3f 	. ? 
	srl a		;74ef	cb 3f 	. ? 
	srl a		;74f1	cb 3f 	. ? 
	ld hl,l7573h		;74f3	21 73 75 	! s u 
	ld e,a			;74f6	5f 	_ 
	ld d,000h		;74f7	16 00 	. . 
	add hl,de			;74f9	19 	. 
	ld a,(hl)			;74fa	7e 	~ 
	ld (ix+002h),a		;74fb	dd 77 02 	. w . 
	ld (0e582h),a		;74fe	32 82 e5 	2 . . 
l7501h:
	ld a,(ix+003h)		;7501	dd 7e 03 	. ~ . 
	inc a			;7504	3c 	< 
	ld (ix+003h),a		;7505	dd 77 03 	. w . 
	cp 003h		;7508	fe 03 	. . 
	jp c,l7566h		;750a	da 66 75 	. f u 
	ld (ix+003h),000h		;750d	dd 36 03 00 	. 6 . . 
	ld a,001h		;7511	3e 01 	> . 
	ld (ix+003h),a		;7513	dd 77 03 	. w . 
	ld a,(ix+002h)		;7516	dd 7e 02 	. ~ . 
	ld l,a			;7519	6f 	o 
	ld h,000h		;751a	26 00 	& . 
	add hl,hl			;751c	29 	) 
	ld de,07586h		;751d	11 86 75 	. . u 
	add hl,de			;7520	19 	. 
	ld a,(hl)			;7521	7e 	~ 
	ld b,a			;7522	47 	G 
	ld a,(iy+001h)		;7523	fd 7e 01 	. ~ . 
	add a,b			;7526	80 	. 
	ld (iy+001h),a		;7527	fd 77 01 	. w . 
	ld a,(ix+002h)		;752a	dd 7e 02 	. ~ . 
	ld l,a			;752d	6f 	o 
	ld h,000h		;752e	26 00 	& . 
	add hl,hl			;7530	29 	) 
	ld de,l7587h		;7531	11 87 75 	. . u 
	add hl,de			;7534	19 	. 
	ld a,(hl)			;7535	7e 	~ 
	ld b,a			;7536	47 	G 
	ld a,(iy+000h)		;7537	fd 7e 00 	. ~ . 
	add a,b			;753a	80 	. 
	ld (iy+000h),a		;753b	fd 77 00 	. w . 
	cp 0b4h		;753e	fe b4 	. . 
	jp c,l7566h		;7540	da 66 75 	. f u 
	ld (ix+000h),000h		;7543	dd 36 00 00 	. 6 . . 
	ld (ix+001h),000h		;7547	dd 36 01 00 	. 6 . . 
	ld (ix+002h),000h		;754b	dd 36 02 00 	. 6 . . 
	ld (iy+003h),000h		;754f	fd 36 03 00 	. 6 . . 
	ld hl,0e577h		;7553	21 77 e5 	! w . 
	inc (hl)			;7556	34 	4 
	ld a,(hl)			;7557	7e 	~ 
	cp 003h		;7558	fe 03 	. . 
	jp nz,l7566h		;755a	c2 66 75 	. f u 
	ld (hl),000h		;755d	36 00 	6 . 
	inc hl			;755f	23 	# 
	ld (hl),001h		;7560	36 01 	6 . 
	xor a			;7562	af 	. 
	ld (0e51ah),a		;7563	32 1a e5 	2 . . 
l7566h:
	pop bc			;7566	c1 	. 
	ld de,00004h		;7567	11 04 00 	. . . 
	add ix,de		;756a	dd 19 	. . 
	add iy,de		;756c	fd 19 	. . 
	dec b			;756e	05 	. 
	jp nz,l74d1h		;756f	c2 d1 74 	. . t 
	ret			;7572	c9 	. 
l7573h:
	nop			;7573	00 	. 
	ld bc,00101h		;7574	01 01 01 	. . . 
	ld (bc),a			;7577	02 	. 
	ld (bc),a			;7578	02 	. 
	ld (bc),a			;7579	02 	. 
	inc bc			;757a	03 	. 
	inc bc			;757b	03 	. 
	inc bc			;757c	03 	. 
	inc b			;757d	04 	. 
	inc b			;757e	04 	. 
	inc b			;757f	04 	. 
	dec b			;7580	05 	. 
	dec b			;7581	05 	. 
	dec b			;7582	05 	. 
	ld b,006h		;7583	06 06 	. . 
	ld b,0fdh		;7585	06 fd 	. . 
l7587h:
	inc b			;7587	04 	. 
	cp 004h		;7588	fe 04 	. . 
	rst 38h			;758a	ff 	. 
	inc b			;758b	04 	. 
	nop			;758c	00 	. 
	inc b			;758d	04 	. 
	ld bc,00204h		;758e	01 04 02 	. . . 
	inc b			;7591	04 	. 
	inc bc			;7592	03 	. 
	inc b			;7593	04 	. 
sub_7594h:
	ld ix,0e563h		;7594	dd 21 63 e5 	. ! c . 
	ld a,(ix+000h)		;7598	dd 7e 00 	. ~ . 
	or a			;759b	b7 	. 
	jr nz,l75c8h		;759c	20 2a 	  * 
	ld a,(ix+008h)		;759e	dd 7e 08 	. ~ . 
	or a			;75a1	b7 	. 
	ret z			;75a2	c8 	. 
	ld b,003h		;75a3	06 03 	. . 
	ld ix,075f9h		;75a5	dd 21 f9 75 	. ! . u 
	ld iy,0190bh		;75a9	fd 21 0b 19 	. ! . . 
l75adh:
	push ix		;75ad	dd e5 	. . 
	push iy		;75af	fd e5 	. . 
	pop de			;75b1	d1 	. 
	pop hl			;75b2	e1 	. 
	push bc			;75b3	c5 	. 
	ld bc,00004h		;75b4	01 04 00 	. . . 
	call LDIRVM		;75b7	cd 5c 00 	. \ . 
	pop bc			;75ba	c1 	. 
	ld de,00004h		;75bb	11 04 00 	. . . 
	add ix,de		;75be	dd 19 	. . 
	ld de,00020h		;75c0	11 20 00 	.   . 
	add iy,de		;75c3	fd 19 	. . 
	djnz l75adh		;75c5	10 e6 	. . 
	ret			;75c7	c9 	. 
l75c8h:
	ld b,003h		;75c8	06 03 	. . 
	ld ix,l75edh		;75ca	dd 21 ed 75 	. ! . u 
	ld iy,0190bh		;75ce	fd 21 0b 19 	. ! . . 
l75d2h:
	push ix		;75d2	dd e5 	. . 
	push iy		;75d4	fd e5 	. . 
	pop de			;75d6	d1 	. 
	pop hl			;75d7	e1 	. 
	push bc			;75d8	c5 	. 
	ld bc,00004h		;75d9	01 04 00 	. . . 
	call LDIRVM		;75dc	cd 5c 00 	. \ . 
	pop bc			;75df	c1 	. 
	ld de,00004h		;75e0	11 04 00 	. . . 
	add ix,de		;75e3	dd 19 	. . 
	ld de,00020h		;75e5	11 20 00 	.   . 
	add iy,de		;75e8	fd 19 	. . 
	djnz l75d2h		;75ea	10 e6 	. . 
	ret			;75ec	c9 	. 
l75edh:
	ret p			;75ed	f0 	. 
	pop af			;75ee	f1 	. 
	jp p,0f4f3h		;75ef	f2 f3 f4 	. . . 
	push af			;75f2	f5 	. 
	or 0f7h		;75f3	f6 f7 	. . 
	ret m			;75f5	f8 	. 
	ld sp,hl			;75f6	f9 	. 
	jp m,lbafbh		;75f7	fa fb ba 	. . . 
	cp e			;75fa	bb 	. 
	cp h			;75fb	bc 	. 
	cp l			;75fc	bd 	. 
	jp nz,0c4c3h		;75fd	c2 c3 c4 	. . . 
	push bc			;7600	c5 	. 
	jp z,0cccbh		;7601	ca cb cc 	. . . 
    db 0xcd          ;7604

sub_7605h:
    ld ix, ALIEN_TABLE
    ld iy, TABLE_UNKNOWN_1
    ld b, 3
l760fh:
	push bc			;760f	c5 	. 
	ld a,(ix+002h)		;7610	dd 7e 02 	. ~ . 
	cp 001h		;7613	fe 01 	. . 
	jp z,l7722h		;7615	ca 22 77 	. " w 
	inc (ix+003h)		;7618	dd 34 03 	. 4 . 
	ld a,(ix+003h)		;761b	dd 7e 03 	. ~ . 
	cp 005h		;761e	fe 05 	. . 
	jp nz,l786dh		;7620	c2 6d 78 	. m x 
	ld (ix+003h),000h		;7623	dd 36 03 00 	. 6 . . 
	ld a,(ix+001h)		;7627	dd 7e 01 	. ~ . 
	or a			;762a	b7 	. 
	jp z,l786dh		;762b	ca 6d 78 	. m x 
	ld a,(ix+007h)		;762e	dd 7e 07 	. ~ . 
	cp 000h		;7631	fe 00 	. . 
	jp nz,l7695h		;7633	c2 95 76 	. . v 
	ld (ix+007h),001h		;7636	dd 36 07 01 	. 6 . . 
	ld de,l7b64h		;763a	11 64 7b 	. d { 
	ld a,(DOOR_TABLE + DOOR_TABLE_IDX_DOOR)		;763d	3a 71 e5 	: q . 
	or a			;7640	b7 	. 
	jp z,l7647h		;7641	ca 47 76 	. G v 
	ld de,l7b7ch		;7644	11 7c 7b 	. | { 
l7647h:
	ld a,(ix+000h)		;7647	dd 7e 00 	. ~ . 
	ld l,a			;764a	6f 	o 
	ld h,000h		;764b	26 00 	& . 
	add hl,hl			;764d	29 	) 
	add hl,de			;764e	19 	. 
	ld e,(hl)			;764f	5e 	^ 
	inc hl			;7650	23 	# 
	ld d,(hl)			;7651	56 	V 
	ex de,hl			;7652	eb 	. 
	push iy		;7653	fd e5 	. . 
	pop de			;7655	d1 	. 
	ld bc,00004h		;7656	01 04 00 	. . . 
	ldir		;7659	ed b0 	. . 
	ld a,(VAUS_X)		;765b	3a ce e0 	: . . 
	sub 008h		;765e	d6 08 	. . 
	and 0f0h		;7660	e6 f0 	. . 
	srl a		;7662	cb 3f 	. ? 
	srl a		;7664	cb 3f 	. ? 
	srl a		;7666	cb 3f 	. ? 
	srl a		;7668	cb 3f 	. ? 
	ld l,a			;766a	6f 	o 
	ld h,000h		;766b	26 00 	& . 
	ld de,07aech		;766d	11 ec 7a 	. . z 
	ld a,(iy+001h)		;7670	fd 7e 01 	. ~ . 
	cp 028h		;7673	fe 28 	. ( 
	jr z,l767ah		;7675	28 03 	( . 
	ld de,l7af9h		;7677	11 f9 7a 	. . z 
l767ah:
	add hl,de			;767a	19 	. 
	ld a,(hl)			;767b	7e 	~ 
	ld (ix+006h),a		;767c	dd 77 06 	. w . 
	ld a,(ix+006h)		;767f	dd 7e 06 	. ~ . 
	and 003h		;7682	e6 03 	. . 
	ld l,a			;7684	6f 	o 
	ld h,000h		;7685	26 00 	& . 
	add hl,hl			;7687	29 	) 
	ld de,l7b06h		;7688	11 06 7b 	. . { 
	add hl,de			;768b	19 	. 
	ld a,(hl)			;768c	7e 	~ 
	ld (ix+008h),a		;768d	dd 77 08 	. w . 
	inc hl			;7690	23 	# 
	ld a,(hl)			;7691	7e 	~ 
	ld (ix+009h),a		;7692	dd 77 09 	. w . 
l7695h:
	ld a,(iy+000h)		;7695	fd 7e 00 	. ~ . 
	cp 040h		;7698	fe 40 	. @ 
	jp nc,l77aeh		;769a	d2 ae 77 	. . w 
	ld a,(ix+008h)		;769d	dd 7e 08 	. ~ . 
	add a,(iy+000h)		;76a0	fd 86 00 	. . . 
	ld (iy+000h),a		;76a3	fd 77 00 	. w . 
	ld a,(ix+009h)		;76a6	dd 7e 09 	. ~ . 
	add a,(iy+001h)		;76a9	fd 86 01 	. . . 
	ld (iy+001h),a		;76ac	fd 77 01 	. w . 
	ld a,(ix+010h)		;76af	dd 7e 10 	. ~ . 
	cp 001h		;76b2	fe 01 	. . 
	jp z,l7705h		;76b4	ca 05 77 	. . w 
	cp 002h		;76b7	fe 02 	. . 
	jp z,l7710h		;76b9	ca 10 77 	. . w 
	cp 003h		;76bc	fe 03 	. . 
	jp z,l771bh		;76be	ca 1b 77 	. . w 
	ld a,(iy+000h)		;76c1	fd 7e 00 	. ~ . 
	cp 007h		;76c4	fe 07 	. . 
	jp nc,l76d6h		;76c6	d2 d6 76 	. . v 
	ld a,(ix+008h)		;76c9	dd 7e 08 	. ~ . 
	bit 7,a		;76cc	cb 7f 	.  
	jp z,l76d6h		;76ce	ca d6 76 	. . v 
	neg		;76d1	ed 44 	. D 
	ld (ix+008h),a		;76d3	dd 77 08 	. w . 
l76d6h:
	bit 7,(ix+009h)		;76d6	dd cb 09 7e 	. . . ~ 
	jr z,l76ech		;76da	28 10 	( . 
	ld a,(iy+001h)		;76dc	fd 7e 01 	. ~ . 
	cp 010h		;76df	fe 10 	. . 
	jp nc,l76ech		;76e1	d2 ec 76 	. . v 
	ld a,(ix+009h)		;76e4	dd 7e 09 	. ~ . 
	neg		;76e7	ed 44 	. D 
	ld (ix+009h),a		;76e9	dd 77 09 	. w . 
l76ech:
	bit 7,(ix+009h)		;76ec	dd cb 09 7e 	. . . ~ 
	jr nz,l7763h		;76f0	20 71 	  q 
	ld a,(iy+001h)		;76f2	fd 7e 01 	. ~ . 
	cp 0b0h		;76f5	fe b0 	. . 
	jp c,l7763h		;76f7	da 63 77 	. c w 
	ld a,(ix+009h)		;76fa	dd 7e 09 	. ~ . 
	neg		;76fd	ed 44 	. D 
	ld (ix+009h),a		;76ff	dd 77 09 	. w . 
	jp l7763h		;7702	c3 63 77 	. c w 
l7705h:
	ld a,(ix+008h)		;7705	dd 7e 08 	. ~ . 
	neg		;7708	ed 44 	. D 
	ld (ix+008h),a		;770a	dd 77 08 	. w . 
	jp l7763h		;770d	c3 63 77 	. c w 
l7710h:
	ld a,(ix+009h)		;7710	dd 7e 09 	. ~ . 
	neg		;7713	ed 44 	. D 
	ld (ix+009h),a		;7715	dd 77 09 	. w . 
	jp l7763h		;7718	c3 63 77 	. c w 
l771bh:
	ld (ix+002h),001h		;771b	dd 36 02 01 	. 6 . . 
	jp l7763h		;771f	c3 63 77 	. c w 
l7722h:
	inc (ix+004h)		;7722	dd 34 04 	. 4 . 
	ld a,(ix+004h)		;7725	dd 7e 04 	. ~ . 
	cp 00ah		;7728	fe 0a 	. . 
	jp nz,l786dh		;772a	c2 6d 78 	. m x 
	ld (ix+004h),000h		;772d	dd 36 04 00 	. 6 . . 
	ld a,(ix+005h)		;7731	dd 7e 05 	. ~ . 
	ld l,a			;7734	6f 	o 
	ld h,000h		;7735	26 00 	& . 
	ld de,07b0ch		;7737	11 0c 7b 	. . { 
	add hl,de			;773a	19 	. 
	ld a,(hl)			;773b	7e 	~ 
	ld (iy+002h),a		;773c	fd 77 02 	. w . 
	ld (iy+003h),008h		;773f	fd 36 03 08 	. 6 . . 
	inc (ix+005h)		;7743	dd 34 05 	. 4 . 
	ld a,(ix+005h)		;7746	dd 7e 05 	. ~ . 
	cp 004h		;7749	fe 04 	. . 
	jp nz,l786dh		;774b	c2 6d 78 	. m x 
	ld (iy+000h),0c0h		;774e	fd 36 00 c0 	. 6 . . 
	push ix		;7752	dd e5 	. . 
	push ix		;7754	dd e5 	. . 
	pop hl			;7756	e1 	. 
	pop de			;7757	d1 	. 
	inc de			;7758	13 	. 
	ld (hl),000h		;7759	36 00 	6 . 
	ld bc,00013h		;775b	01 13 00 	. . . 
	ldir		;775e	ed b0 	. . 
	jp l786dh		;7760	c3 6d 78 	. m x 
l7763h:
	inc (ix+011h)		;7763	dd 34 11 	. 4 . 
	ld a,(ix+011h)		;7766	dd 7e 11 	. ~ . 
	cp 004h		;7769	fe 04 	. . 
	jp nz,l786dh		;776b	c2 6d 78 	. m x 
	ld (ix+011h),000h		;776e	dd 36 11 00 	. 6 . . 
	ld a,(LEVEL)		;7772	3a 1b e0 	: . . 
	and 003h		;7775	e6 03 	. . 
	ld l,a			;7777	6f 	o 
	ld h,000h		;7778	26 00 	& . 
	add hl,hl			;777a	29 	) 
	ld de,l7abdh		;777b	11 bd 7a 	. . z 
	add hl,de			;777e	19 	. 
	ld e,(hl)			;777f	5e 	^ 
	inc hl			;7780	23 	# 
	ld d,(hl)			;7781	56 	V 
	ld a,(ix+00ah)		;7782	dd 7e 0a 	. ~ . 
	ld l,a			;7785	6f 	o 
	ld h,000h		;7786	26 00 	& . 
	add hl,de			;7788	19 	. 
	ld a,(hl)			;7789	7e 	~ 
	ld (iy+002h),a		;778a	fd 77 02 	. w . 
	inc (ix+00ah)		;778d	dd 34 0a 	. 4 . 
	ld a,(LEVEL)		;7790	3a 1b e0 	: . . 
	and 003h		;7793	e6 03 	. . 
	ld l,a			;7795	6f 	o 
	ld h,000h		;7796	26 00 	& . 
	ld de,l77aah		;7798	11 aa 77 	. . w 
	add hl,de			;779b	19 	. 
	ld a,(hl)			;779c	7e 	~ 
	cp (ix+00ah)		;779d	dd be 0a 	. . . 
	jp nz,l786dh		;77a0	c2 6d 78 	. m x 
	ld (ix+00ah),000h		;77a3	dd 36 0a 00 	. 6 . . 
	jp l786dh		;77a7	c3 6d 78 	. m x 
l77aah:
	ex af,af'			;77aa	08 	. 
	ex af,af'			;77ab	08 	. 
	ld b,011h		;77ac	06 11 	. . 
l77aeh:
	ld a,(ix+00bh)		;77ae	dd 7e 0b 	. ~ . 
	cp 001h		;77b1	fe 01 	. . 
	jp z,l77f1h		;77b3	ca f1 77 	. . w 
	ld (ix+00bh),001h		;77b6	dd 36 0b 01 	. 6 . . 
	ld a,(ix+00ch)		;77ba	dd 7e 0c 	. ~ . 
	sla a		;77bd	cb 27 	. ' 
	sla a		;77bf	cb 27 	. ' 
	ld l,a			;77c1	6f 	o 
	ld h,000h		;77c2	26 00 	& . 
	ld a,(ix+000h)		;77c4	dd 7e 00 	. ~ . 
	ld de,l7b10h		;77c7	11 10 7b 	. . { 
	cp 000h		;77ca	fe 00 	. . 
	jp z,l77e2h		;77cc	ca e2 77 	. . w 
	ld de,l7b24h		;77cf	11 24 7b 	. $ { 
	cp 001h		;77d2	fe 01 	. . 
	jp z,l77e2h		;77d4	ca e2 77 	. . w 
	ld de,l7b38h		;77d7	11 38 7b 	. 8 { 
	cp 002h		;77da	fe 02 	. . 
	jp z,l77e2h		;77dc	ca e2 77 	. . w 
	ld de,l7b50h		;77df	11 50 7b 	. P { 
l77e2h:
	add hl,de			;77e2	19 	. 
	ld a,(hl)			;77e3	7e 	~ 
	ld (ix+008h),a		;77e4	dd 77 08 	. w . 
	inc hl			;77e7	23 	# 
	ld a,(hl)			;77e8	7e 	~ 
	ld (ix+009h),a		;77e9	dd 77 09 	. w . 
	inc hl			;77ec	23 	# 
	ld a,(hl)			;77ed	7e 	~ 
	ld (ix+00fh),a		;77ee	dd 77 0f 	. w . 
l77f1h:
	ld a,(ix+008h)		;77f1	dd 7e 08 	. ~ . 
	add a,(iy+000h)		;77f4	fd 86 00 	. . . 
	ld (iy+000h),a		;77f7	fd 77 00 	. w . 
	ld a,(ix+009h)		;77fa	dd 7e 09 	. ~ . 
	add a,(iy+001h)		;77fd	fd 86 01 	. . . 
	ld (iy+001h),a		;7800	fd 77 01 	. w . 
	ld a,(iy+001h)		;7803	fd 7e 01 	. ~ . 
	cp 011h		;7806	fe 11 	. . 
	jr nc,l7817h		;7808	30 0d 	0 . 
	ld a,(ix+009h)		;780a	dd 7e 09 	. ~ . 
	bit 7,a		;780d	cb 7f 	.  
	jp z,l7817h		;780f	ca 17 78 	. . x 
	neg		;7812	ed 44 	. D 
	ld (ix+009h),a		;7814	dd 77 09 	. w . 
l7817h:
	ld a,(iy+001h)		;7817	fd 7e 01 	. ~ . 
	cp 0afh		;781a	fe af 	. . 
	jr c,l782bh		;781c	38 0d 	8 . 
	ld a,(ix+009h)		;781e	dd 7e 09 	. ~ . 
	bit 7,a		;7821	cb 7f 	.  
	jp nz,l782bh		;7823	c2 2b 78 	. + x 
	neg		;7826	ed 44 	. D 
	ld (ix+009h),a		;7828	dd 77 09 	. w . 
l782bh:
	ld a,(ix+00fh)		;782b	dd 7e 0f 	. ~ . 
	dec a			;782e	3d 	= 
	ld (ix+00fh),a		;782f	dd 77 0f 	. w . 
	jp nz,l7763h		;7832	c2 63 77 	. c w 
	ld (ix+00bh),000h		;7835	dd 36 0b 00 	. 6 . . 
	ld a,(iy+000h)		;7839	fd 7e 00 	. ~ . 
	cp 0aeh		;783c	fe ae 	. . 
	jp nc,l785bh		;783e	d2 5b 78 	. [ x 
	ld a,(ix+000h)		;7841	dd 7e 00 	. ~ . 
	cp 002h		;7844	fe 02 	. . 
	jp z,l787dh		;7846	ca 7d 78 	. } x 
	inc (ix+00ch)		;7849	dd 34 0c 	. 4 . 
	ld a,(ix+00ch)		;784c	dd 7e 0c 	. ~ . 
	cp 005h		;784f	fe 05 	. . 
l7851h:
	jp nz,l7763h		;7851	c2 63 77 	. c w 
	ld (ix+00ch),000h		;7854	dd 36 0c 00 	. 6 . . 
	jp l786dh		;7858	c3 6d 78 	. m x 
l785bh:
	ld (iy+000h),0c0h		;785b	fd 36 00 c0 	. 6 . . 
	push ix		;785f	dd e5 	. . 
	push ix		;7861	dd e5 	. . 
	pop hl			;7863	e1 	. 
	pop de			;7864	d1 	. 
	inc de			;7865	13 	. 
	ld (hl),000h		;7866	36 00 	6 . 
	ld bc,00013h		;7868	01 13 00 	. . . 
	ldir		;786b	ed b0 	. . 
l786dh:
	pop bc			;786d	c1 	. 
	ld de,00014h		;786e	11 14 00 	. . . 
	add ix,de		;7871	dd 19 	. . 
	ld de,00004h		;7873	11 04 00 	. . . 
	add iy,de		;7876	fd 19 	. . 
	dec b			;7878	05 	. 
	jp nz,l760fh		;7879	c2 0f 76 	. . v 
	ret			;787c	c9 	. 

l787dh:
	inc (ix+00ch)		;787d	dd 34 0c 	. 4 . 
	ld a,(ix+00ch)		;7880	dd 7e 0c 	. ~ . 
	cp 006h		;7883	fe 06 	. . 
	jp l7851h		;7885	c3 51 78 	. Q x 
sub_7888h:
	ld ix,0e0e9h		;7888	dd 21 e9 e0 	. ! . . 
	ld a,(0e557h)		;788c	3a 57 e5 	: W . 
	or a			;788f	b7 	. 
	jp z,l78a1h		;7890	ca a1 78 	. . x 
	call sub_78d4h		;7893	cd d4 78 	. . x 
	jp c,l78a1h		;7896	da a1 78 	. . x 
	xor a			;7899	af 	. 
	ld (0e557h),a		;789a	32 57 e5 	2 W . 
	ld (ix+000h),0c0h		;789d	dd 36 00 c0 	. 6 . . 
l78a1h:
	ld ix,0e0edh		;78a1	dd 21 ed e0 	. ! . . 
	ld a,(0e55bh)		;78a5	3a 5b e5 	: [ . 
	or a			;78a8	b7 	. 
	jp z,l78bah		;78a9	ca ba 78 	. . x 
	call sub_78d4h		;78ac	cd d4 78 	. . x 
	jp c,l78bah		;78af	da ba 78 	. . x 
	xor a			;78b2	af 	. 
	ld (0e55bh),a		;78b3	32 5b e5 	2 [ . 
	ld (ix+000h),0c0h		;78b6	dd 36 00 c0 	. 6 . . 
l78bah:
	ld ix,0e0f1h		;78ba	dd 21 f1 e0 	. ! . . 
	ld a,(0e55fh)		;78be	3a 5f e5 	: _ . 
	or a			;78c1	b7 	. 
	jp z,l78d3h		;78c2	ca d3 78 	. . x 
	call sub_78d4h		;78c5	cd d4 78 	. . x 
	jp c,l78d3h		;78c8	da d3 78 	. . x 
	xor a			;78cb	af 	. 
	ld (0e55fh),a		;78cc	32 5f e5 	2 _ . 
	ld (ix+000h),0c0h		;78cf	dd 36 00 c0 	. 6 . . 
l78d3h:
	ret			;78d3	c9 	. 

sub_78d4h:
	ld iy,TABLE_UNKNOWN_1		;78d4	fd 21 01 e1
	ld hl,ALIEN_TABLE + 1		;78d8	21 c8 e4
	ld b,003h		            ;78db	06 03
l78ddh:
	ld a,(hl)			;78dd	7e 	~ 
	or a			;78de	b7 	. 
	jp z,l7935h		;78df	ca 35 79 	. 5 y 
	push hl			;78e2	e5 	. 
	inc hl			;78e3	23 	# 
	ld a,(hl)			;78e4	7e 	~ 
	or a			;78e5	b7 	. 
	pop hl			;78e6	e1 	. 
	jp nz,l7935h		;78e7	c2 35 79 	. 5 y 
	ld a,(ix+000h)		;78ea	dd 7e 00 	. ~ . 
	sub 010h		;78ed	d6 10 	. . 
	ld e,a			;78ef	5f 	_ 
	ld a,(iy+000h)		;78f0	fd 7e 00 	. ~ . 
	ld d,a			;78f3	57 	W 
	ld a,e			;78f4	7b 	{ 
	cp d			;78f5	ba 	. 
	jp nc,l7935h		;78f6	d2 35 79 	. 5 y 
	ld a,(ix+000h)		;78f9	dd 7e 00 	. ~ . 
	add a,010h		;78fc	c6 10 	. . 
	ld e,a			;78fe	5f 	_ 
	ld a,(iy+000h)		;78ff	fd 7e 00 	. ~ . 
	ld d,a			;7902	57 	W 
	ld a,e			;7903	7b 	{ 
	cp d			;7904	ba 	. 
	jp c,l7935h		;7905	da 35 79 	. 5 y 
	ld a,(ix+001h)		;7908	dd 7e 01 	. ~ . 
	sub 010h		;790b	d6 10 	. . 
	ld e,a			;790d	5f 	_ 
	ld a,(iy+001h)		;790e	fd 7e 01 	. ~ . 
	ld d,a			;7911	57 	W 
	ld a,e			;7912	7b 	{ 
	cp d			;7913	ba 	. 
	jp nc,l7935h		;7914	d2 35 79 	. 5 y 
	ld a,(ix+001h)		;7917	dd 7e 01 	. ~ . 
	add a,010h		;791a	c6 10 	. . 
	ld e,a			;791c	5f 	_ 
	ld a,(iy+001h)		;791d	fd 7e 01 	. ~ . 
	ld d,a			;7920	57 	W 
	ld a,e			;7921	7b 	{ 
	cp d			;7922	ba 	. 
	jp c,l7935h		;7923	da 35 79 	. 5 y 
	ld a,0c2h		;7926	3e c2 	> . 
	call sub_5befh		;7928	cd ef 5b 	. . [ 
	ld a,005h		;792b	3e 05 	> . 
	call sub_52a0h		;792d	cd a0 52 	. . R 
	inc hl			;7930	23 	# 
	ld (hl),001h		;7931	36 01 	6 . 
	xor a			;7933	af 	. 
	ret			;7934	c9 	. 
l7935h:
	ld de,00004h		;7935	11 04 00 	. . . 
	add iy,de		;7938	fd 19 	. . 
	ld de,00014h		;793a	11 14 00 	. . . 
	add hl,de			;793d	19 	. 
	djnz l78ddh		;793e	10 9d 	. . 
	scf			;7940	37 	7 
	ret			;7941	c9 	. 

sub_7942h:
	ld ix,0e0cdh		        ;7942	dd 21 cd e0
	ld iy,TABLE_UNKNOWN_1		;7946	fd 21 01 e1
	ld hl,ALIEN_TABLE + 1		;794a	21 c8 e4
	ld b,003h		;794d	06 03 	. . 
l794fh:
	ld a,(0e54bh)		;794f	3a 4b e5 	: K . 
	cp 006h		;7952	fe 06 	. . 
	ret z			;7954	c8 	. 
	ld a,(hl)			;7955	7e 	~ 
	cp 001h		;7956	fe 01 	. . 
	jp nz,l7999h		;7958	c2 99 79 	. . y 
	ld a,(iy+000h)		;795b	fd 7e 00 	. ~ . 
	cp 0a0h		;795e	fe a0 	. . 
	jp c,l7999h		;7960	da 99 79 	. . y 
	cp 0b8h		;7963	fe b8 	. . 
	jp nc,l7999h		;7965	d2 99 79 	. . y 
	ld a,(ix+001h)		;7968	dd 7e 01 	. ~ . 
	add a,008h		;796b	c6 08 	. . 
	cp (iy+001h)		;796d	fd be 01 	. . . 
	jp nc,l7999h		;7970	d2 99 79 	. . y 
	ld c,028h		;7973	0e 28 	. ( 
	ld a,(0e321h)		;7975	3a 21 e3 	: ! . 
	or a			;7978	b7 	. 
	jp z,l797eh		;7979	ca 7e 79 	. ~ y 
	ld c,038h		;797c	0e 38 	. 8 
l797eh:
	ld a,(ix+001h)		;797e	dd 7e 01 	. ~ . 
	add a,c			;7981	81 	. 
	cp (iy+001h)		;7982	fd be 01 	. . . 
	jp c,l7999h		;7985	da 99 79 	. . y 
	ld a,0c2h		;7988	3e c2 	> . 
	call sub_5befh		;798a	cd ef 5b 	. . [ 
	ld a,005h		;798d	3e 05 	> . 
	call sub_52a0h		;798f	cd a0 52 	. . R 
	push hl			;7992	e5 	. 
	ld (hl),002h		;7993	36 02 	6 . 
	inc hl			;7995	23 	# 
	ld (hl),001h		;7996	36 01 	6 . 
	pop hl			;7998	e1 	. 
l7999h:
	ld de,00004h		;7999	11 04 00 	. . . 
	add iy,de		;799c	fd 19 	. . 
	ld de,00014h		;799e	11 14 00 	. . . 
	add hl,de			;79a1	19 	. 
	djnz l794fh		;79a2	10 ab 	. . 
	ret			;79a4	c9 	.

sub_79a5h:
	ld ix,BALL1_SPR_PARAMS		                        ;79a5	dd 21 f5 e0
    
    ; Skip the following part if the ball is not active
	ld a,(BALL_TABLE1 + BALL_TABLE_IDX_ACTIVE)	;79a9	3a 4e e2
	or a			                            ;79ac	b7
	jp z,l79c2h		                            ;79ad	ca c2 79

	call sub_79fdh		;79b0	cd fd 79 	. . y 
	jp c,l79c2h		;79b3	da c2 79 	. . y 
	ld iy,BALL_TABLE1		;79b6	fd 21 4e e2 	. ! N . 
	call sub_9b8ah		;79ba	cd 8a 9b 	. . . 
	ld a,0c2h		;79bd	3e c2 	> . 
	call sub_5befh		;79bf	cd ef 5b 	. . [ 
l79c2h:
	ld ix,BALL2_SPR_PARAMS		;79c2	dd 21 f9 e0 	. ! . . 
	ld a,(BALL_TABLE2)		;79c6	3a 62 e2 	: b . 
	or a			;79c9	b7 	. 
	jp z,l79dfh		;79ca	ca df 79 	. . y 
	call sub_79fdh		;79cd	cd fd 79 	. . y 
	jp c,l79dfh		;79d0	da df 79 	. . y 
	ld iy,BALL_TABLE2		;79d3	fd 21 62 e2 	. ! b . 
	call sub_9b8ah		;79d7	cd 8a 9b 	. . . 
	ld a,0c2h		;79da	3e c2 	> . 
	call sub_5befh		;79dc	cd ef 5b 	. . [ 
l79dfh:
	ld ix,BALL3_SPR_PARAMS		;79df	dd 21 fd e0 	. ! . . 
	ld a,(BALL_TABLE3)		;79e3	3a 76 e2 	: v . 
	or a			;79e6	b7 	. 
	jp z,l79fch		;79e7	ca fc 79 	. . y 
	call sub_79fdh		;79ea	cd fd 79 	. . y 
	jp c,l79fch		;79ed	da fc 79 	. . y 
	ld iy,BALL_TABLE3		;79f0	fd 21 76 e2 	. ! v . 
	call sub_9b8ah		;79f4	cd 8a 9b 	. . . 
	ld a,0c2h		;79f7	3e c2 	> . 
	call sub_5befh		;79f9	cd ef 5b 	. . [ 
l79fch:
	ret			;79fc	c9 	. 

sub_79fdh:
    ; IX = BALL(i)_SPR_PARAMS
	ld iy,TABLE_UNKNOWN_1		;79fd	fd 21 01 e1
	ld hl,ALIEN_TABLE + 1		;7a01	21 c8 e4
	ld b, 3		                ;7a04	06 03
l7a06h:
	ld a,(hl)			;7a06	7e 	~ 
	cp 001h		;7a07	fe 01 	. . 
	jp nz,l7a5bh		;7a09	c2 5b 7a 	. [ z 
	ld a,(iy+003h)		;7a0c	fd 7e 03 	. ~ . 
	or a			;7a0f	b7 	. 
	jp z,l7a5bh		;7a10	ca 5b 7a 	. [ z 
	ld a,(ix+BALL_SPR_PARAMS_IDX_Y)		;7a13	dd 7e 00
	sub 16		                        ;7a16	d6 10
	ld e,a			;7a18	5f 	_ 
	ld a,(iy+000h)		;7a19	fd 7e 00 	. ~ . 
	ld d,a			;7a1c	57 	W 
	ld a,e			;7a1d	7b 	{ 
	cp d			;7a1e	ba 	. 
	jp nc,l7a5bh		;7a1f	d2 5b 7a 	. [ z 
	ld a,(ix+BALL_SPR_PARAMS_IDX_Y)		;7a22	dd 7e 00
	add a,004h		;7a25	c6 04 	. . 
	ld e,a			;7a27	5f 	_ 
	ld a,(iy+000h)		;7a28	fd 7e 00 	. ~ . 
	ld d,a			;7a2b	57 	W 
	ld a,e			;7a2c	7b 	{ 
	cp d			;7a2d	ba 	. 
	jp c,l7a5bh		;7a2e	da 5b 7a 	. [ z 
	ld a,(ix+BALL_SPR_PARAMS_IDX_X)		;7a31	dd 7e 01
	sub 16		                        ;7a34	d6 10
	ld e,a			;7a36	5f 	_ 
	ld a,(iy+001h)		;7a37	fd 7e 01 	. ~ . 
	ld d,a			;7a3a	57 	W 
	ld a,e			;7a3b	7b 	{ 
	cp d			;7a3c	ba 	. 
	jp nc,l7a5bh		;7a3d	d2 5b 7a 	. [ z 
	ld a,(ix+BALL_SPR_PARAMS_IDX_X)		;7a40	dd 7e 01
	add a,004h		;7a43	c6 04 	. . 
	ld e,a			;7a45	5f 	_ 
	ld a,(iy+001h)		;7a46	fd 7e 01 	. ~ . 
	ld d,a			;7a49	57 	W 
	ld a,e			;7a4a	7b 	{ 
	cp d			;7a4b	ba 	. 
	jp c,l7a5bh		;7a4c	da 5b 7a 	. [ z 
	ld a,005h		;7a4f	3e 05 	> . 
	call sub_52a0h		;7a51	cd a0 52 	. . R 
	ld (hl),002h		;7a54	36 02 	6 . 
	inc hl			;7a56	23 	# 
	ld (hl),001h		;7a57	36 01 	6 . 
	xor a			;7a59	af 	. 
	ret			;7a5a	c9 	. 

l7a5bh:
	ld de,00004h		;7a5b	11 04 00 	. . . 
	add iy,de		;7a5e	fd 19 	. . 
	ld de,00014h		;7a60	11 14 00 	. . . 
	add hl,de			;7a63	19 	. 
	djnz l7a06h		;7a64	10 a0 	. . 
	scf			;7a66	37 	7 
	ret			;7a67	c9 	. 
sub_7a68h:
	ld a,(0e54bh)		;7a68	3a 4b e5 	: K . 
	cp 006h		;7a6b	fe 06 	. . 
	ret z			;7a6d	c8 	. 
	ld ix,0e0cdh		;7a6e	dd 21 cd e0 	. ! . . 
	ld iy,0e10dh		;7a72	fd 21 0d e1 	. ! . . 
	ld hl,0e563h		;7a76	21 63 e5 	! c . 
	ld b,003h		;7a79	06 03 	. . 
l7a7bh:
	ld a,(hl)			;7a7b	7e 	~ 
	or a			;7a7c	b7 	. 
	jp z,l7ab4h		;7a7d	ca b4 7a 	. . z 
	ld a,(iy+000h)		;7a80	fd 7e 00 	. ~ . 
	cp 0a7h		;7a83	fe a7 	. . 
	jp c,l7ab4h		;7a85	da b4 7a 	. . z 
	cp 0b8h		;7a88	fe b8 	. . 
	jp nc,l7ab4h		;7a8a	d2 b4 7a 	. . z 
	ld a,(ix+001h)		;7a8d	dd 7e 01 	. ~ . 
	add a,008h		;7a90	c6 08 	. . 
	cp (iy+001h)		;7a92	fd be 01 	. . . 
	jp nc,l7ab4h		;7a95	d2 b4 7a 	. . z 
	ld a,(ix+001h)		;7a98	dd 7e 01 	. ~ . 
	add a,020h		;7a9b	c6 20 	.   
	cp (iy+001h)		;7a9d	fd be 01 	. . . 
	jp c,l7ab4h		;7aa0	da b4 7a 	. . z 
	ld a,006h		;7aa3	3e 06 	> . 
	ld (0e54bh),a		;7aa5	32 4b e5 	2 K . 
	ld (iy+000h),0c0h		;7aa8	fd 36 00 c0 	. 6 . . 
	ld a,007h		;7aac	3e 07 	> . 
	call sub_5befh		;7aae	cd ef 5b 	. . [ 
	call DEACTIVE_ALL_BALLS		;7ab1	cd 10 97 	. . . 
l7ab4h:
	ld de,00004h		;7ab4	11 04 00 	. . . 
	add iy,de		;7ab7	fd 19 	. . 
	add hl,de			;7ab9	19 	. 
	djnz l7a7bh		;7aba	10 bf 	. . 
	ret			;7abc	c9 	. 
l7abdh:
	push bc			;7abd	c5 	. 
	ld a,d			;7abe	7a 	z 
	call 0d57ah		;7abf	cd 7a d5 	. z . 
	ld a,d			;7ac2	7a 	z 
	in a,(07ah)		;7ac3	db 7a 	. z 
	ret nz			;7ac5	c0 	. 
	call nz,0ccc8h		;7ac6	c4 c8 cc 	. . . 
	ret nc			;7ac9	d0 	. 
	call nc,0dcd8h		;7aca	d4 d8 dc 	. . . 
	ret nz			;7acd	c0 	. 
	call nz,0ccc8h		;7ace	c4 c8 cc 	. . . 
	ret nc			;7ad1	d0 	. 
	call nc,0ccd8h		;7ad2	d4 d8 cc 	. . . 
	ret nz			;7ad5	c0 	. 
	call nz,0ccc8h		;7ad6	c4 c8 cc 	. . . 
	ret nc			;7ad9	d0 	. 
	call nc,0c4c0h		;7ada	d4 c0 c4 	. . . 
	ret z			;7add	c8 	. 
	call z,0dcd0h		;7ade	cc d0 dc 	. . . 
	ret nz			;7ae1	c0 	. 
	call nz,0ccc8h		;7ae2	c4 c8 cc 	. . . 
	ret nc			;7ae5	d0 	. 
	call c,0d8d4h		;7ae6	dc d4 d8 	. . . 
	ret c			;7ae9	d8 	. 
	call nc,000d0h		;7aea	d4 d0 00 	. . . 
	nop			;7aed	00 	. 
	ld bc,00201h		;7aee	01 01 02 	. . . 
	ld (bc),a			;7af1	02 	. 
	ld (bc),a			;7af2	02 	. 
	ld (bc),a			;7af3	02 	. 
	ld (bc),a			;7af4	02 	. 
	ld (bc),a			;7af5	02 	. 
	ld (bc),a			;7af6	02 	. 
	ld (bc),a			;7af7	02 	. 
	ld (bc),a			;7af8	02 	. 
l7af9h:
	nop			;7af9	00 	. 
	nop			;7afa	00 	. 
	nop			;7afb	00 	. 
	nop			;7afc	00 	. 
	nop			;7afd	00 	. 
	nop			;7afe	00 	. 
	ld bc,00101h		;7aff	01 01 01 	. . . 
	ld (bc),a			;7b02	02 	. 
	ld (bc),a			;7b03	02 	. 
	ld (bc),a			;7b04	02 	. 
	ld (bc),a			;7b05	02 	. 
l7b06h:
	ld bc,001ffh		;7b06	01 ff 01 	. . . 
	nop			;7b09	00 	. 
	ld bc,l9001h		;7b0a	01 01 90 	. . . 
	sub h			;7b0d	94 	. 
	sbc a,b			;7b0e	98 	. 
	sbc a,h			;7b0f	9c 	. 
l7b10h:
	ld bc,02800h		;7b10	01 00 28 	. . ( 
	nop			;7b13	00 	. 
	ld bc,01802h		;7b14	01 02 18 	. . . 
	nop			;7b17	00 	. 
	rst 38h			;7b18	ff 	. 
	ld (bc),a			;7b19	02 	. 
	jr l7b1ch		;7b1a	18 00 	. . 
l7b1ch:
	rst 38h			;7b1c	ff 	. 
	cp 018h		;7b1d	fe 18 	. . 
	nop			;7b1f	00 	. 
	ld bc,018feh		;7b20	01 fe 18 	. . . 
	nop			;7b23	00 	. 
l7b24h:
	ld bc,03800h		;7b24	01 00 38 	. . 8 
	nop			;7b27	00 	. 
	ld (bc),a			;7b28	02 	. 
	inc bc			;7b29	03 	. 
	ld e,000h		;7b2a	1e 00 	. . 
	cp 003h		;7b2c	fe 03 	. . 
	ld e,000h		;7b2e	1e 00 	. . 
	cp 0fdh		;7b30	fe fd 	. . 
	jr l7b34h		;7b32	18 00 	. . 
l7b34h:
	ld (bc),a			;7b34	02 	. 
	defb 0fdh,018h,000h	;illegal sequence		;7b35	fd 18 00 	. . . 
l7b38h:
	ld bc,02000h		;7b38	01 00 20 	. .   
	nop			;7b3b	00 	. 
	ld bc,00802h		;7b3c	01 02 08 	. . . 
	nop			;7b3f	00 	. 
	rst 38h			;7b40	ff 	. 
	ld (bc),a			;7b41	02 	. 
	ex af,af'			;7b42	08 	. 
	nop			;7b43	00 	. 
	rst 38h			;7b44	ff 	. 
	nop			;7b45	00 	. 
	ex af,af'			;7b46	08 	. 
l7b47h:
	nop			;7b47	00 	. 
	rst 38h			;7b48	ff 	. 
	ld (bc),a			;7b49	02 	. 
	jr l7b4ch		;7b4a	18 00 	. . 
l7b4ch:
	ld bc,01802h		;7b4c	01 02 18 	. . . 
l7b4fh:
	nop			;7b4f	00 	. 
l7b50h:
	ld bc,02800h		;7b50	01 00 28 	. . ( 
l7b53h:
	nop			;7b53	00 	. 
	ld bc,018feh		;7b54	01 fe 18 	. . . 
	nop			;7b57	00 	. 
	rst 38h			;7b58	ff 	. 
	cp 018h		;7b59	fe 18 	. . 
	nop			;7b5b	00 	. 
	rst 38h			;7b5c	ff 	. 
	ld (bc),a			;7b5d	02 	. 
	jr l7b60h		;7b5e	18 00 	. . 
l7b60h:
	ld bc,01802h		;7b60	01 02 18 	. . . 
	nop			;7b63	00 	. 
l7b64h:
	ld l,h			;7b64	6c 	l 
	ld a,e			;7b65	7b 	{ 
	ld (hl),b			;7b66	70 	p 
	ld a,e			;7b67	7b 	{ 
	ld (hl),h			;7b68	74 	t 
	ld a,e			;7b69	7b 	{ 
	ld a,b			;7b6a	78 	x 
	ld a,e			;7b6b	7b 	{ 
	ex af,af'			;7b6c	08 	. 
	adc a,b			;7b6d	88 	. 
	ret nz			;7b6e	c0 	. 
	dec b			;7b6f	05 	. 
	ex af,af'			;7b70	08 	. 
	adc a,b			;7b71	88 	. 
	ret nz			;7b72	c0 	. 
	inc bc			;7b73	03 	. 
	ex af,af'			;7b74	08 	. 
	adc a,b			;7b75	88 	. 
	ret nz			;7b76	c0 	. 
	rlca			;7b77	07 	. 
	ex af,af'			;7b78	08 	. 
	adc a,b			;7b79	88 	. 
	ret nz			;7b7a	c0 	. 
	ex af,af'			;7b7b	08 	. 
l7b7ch:
	add a,h			;7b7c	84 	. 
	ld a,e			;7b7d	7b 	{ 
	adc a,b			;7b7e	88 	. 
	ld a,e			;7b7f	7b 	{ 
	adc a,h			;7b80	8c 	. 
	ld a,e			;7b81	7b 	{ 
	sub b			;7b82	90 	. 
	ld a,e			;7b83	7b 	{ 
	ex af,af'			;7b84	08 	. 
	jr z,l7b47h		;7b85	28 c0 	( . 
	dec b			;7b87	05 	. 
	ex af,af'			;7b88	08 	. 
	jr z,$-62		;7b89	28 c0 	( . 
	inc bc			;7b8b	03 	. 
	ex af,af'			;7b8c	08 	. 
	jr z,l7b4fh		;7b8d	28 c0 	( . 
	rlca			;7b8f	07 	. 
	ex af,af'			;7b90	08 	. 
	jr z,l7b53h		;7b91	28 c0 	( . 
	ex af,af'			;7b93	08 	. 

sub_7b94h:
    ; Skip the following if we're at the title screen
	ld a,(GAME_STATE)		;7b94	3a 0b e0
	or a			        ;7b97	b7
	jp z,l7c44h		        ;7b98	ca 44 7c

	ld a,(BRICK_REPAINT_TYPE)		;7b9b	3a 22 e0 	: " . 
	ld l,a			;7b9e	6f 	o 
	ld h,000h		;7b9f	26 00 	& . 
	add hl,hl			;7ba1	29 	) 
	ld de,l7babh		;7ba2	11 ab 7b 	. . { 
	add hl,de			;7ba5	19 	. 
	ld e,(hl)			;7ba6	5e 	^ 
	inc hl			;7ba7	23 	# 
	ld d,(hl)			;7ba8	56 	V 
	ex de,hl			;7ba9	eb 	. 
	jp (hl)			;7baa	e9 	. 
l7babh:
	or c			;7bab	b1 	. 
	ld a,e			;7bac	7b 	{ 
	or c			;7bad	b1 	. 
	ld a,e			;7bae	7b 	{ 
	rlca			;7baf	07 	. 
	ld a,h			;7bb0	7c 	| 
	ld a,(LEVEL_DISP)		;7bb1	3a 1c e0 	: . . 
	add a,001h		;7bb4	c6 01 	. . 
	daa			;7bb6	27 	' 
	ld (LEVEL_DISP),a		;7bb7	32 1c e0 	2 . . 
	ld hl,LEVEL		;7bba	21 1b e0 	! . . 
	inc (hl)			;7bbd	34 	4 
	ld a,(hl)			;7bbe	7e
	cp FINAL_LEVEL+1	;7bbf	fe 21
	jp nz,l7c7dh		;7bc1	c2 7d 7c 	. } | 
	ld (hl),000h		;7bc4	36 00 	6 . 
	inc hl			;7bc6	23 	# 
	ld (hl),000h		;7bc7	36 00 	6 . 

    ; Wait 60 ticks
	ld hl, 60		        ;7bc9	21 3c 00
	call DELAY_HL_TICKS		;7bcc	cd 80 43

	ld a,SOUND_GAME_ENDING		;7bcf	3e c7 	> . 
	ld (SOUND_NUMBER),a		;7bd1	32 c0 e5 	2 . . 
	call PLAY_SOUND		;7bd4	cd e8 b4 	. . . 

	ei			                    ;7bd7	fb

	ld iy,ENDING_STR		        ;7bd8	fd 21 88 7c
	ld ix,0x7d72		            ;7bdc	dd 21 72 7d
	call ENDING_TEXT_ANIMATION		;7be0	cd 8a 4f

    ; Wait 30 ticks
	ld hl, 30		        ;7be3	21 1e 00
	call DELAY_HL_TICKS		;7be6	cd 80 43

	call CLEAR_SCREEN		;7be9	cd 27 42 	. ' B 
    
    ; Doh if defeated here
	call DRAW_UP_SCORES		;7bec	cd e0 4f 	. . O 

    ; Draw GAME OVER with sprites.
    ; That's a very nice way to show the text over the
    ; patterns with trasparency.
	ld hl,GAME_OVER_SPRITE_TABLE		;7bef	21 6d 7c
	ld de,SPRITES_ATTRIB_TABLE		    ;7bf2	11 00 1b
	ld bc, 4*4		                    ;7bf5	01 10 00    4 sprites
	call LDIRVM		                    ;7bf8	cd 5c 00

    ; Wait 240 ticks
	ld hl, 240  		    ;7bfb	21 f0 00
	call DELAY_HL_TICKS		;7bfe	cd 80 43

	call CLEAR_SCREEN		;7c01	cd 27 42 	. ' B 
	jp l7c44h		;7c04	c3 44 7c 	. D | 

    ; Wait 48 ticks
	ld hl,00030h		    ;7c07	21 30 00
	call DELAY_HL_TICKS		;7c0a	cd 80 43

	ld hl,LIVES		;7c0d	21 1d e0 	! . . 
	dec (hl)			;7c10	35 	5 
	ld a,(hl)			;7c11	7e 	~ 
	cp 0ffh		;7c12	fe ff 	. . 
	jp nz,l7c7dh		;7c14	c2 7d 7c 	. } | 
	ld hl,(LEVEL)		;7c17	2a 1b e0 	* . . 
	ld a,l			    ;7c1a	7d
	cp FINAL_LEVEL		;7c1b	fe 20
	jp nz,l7c23h		;7c1d	c2 23 7c
	ld hl,0321fh		;7c20	21 1f 32 	A weird code for Doh's level!
l7c23h:
    ; Save current level, for cheat #2
	ld (CHEAT2_LEVEL),hl		;7c23	22 05 e0
    
	ld a,SOUND_GAME_OVER		;7c26	3e c6 	> . 
	ld (SOUND_NUMBER),a		;7c28	32 c0 e5 	2 . . 
	call PLAY_SOUND		;7c2b	cd e8 b4 	. . . 
	ei			;7c2e	fb 	. 

	ld hl,l7c5dh		            ;7c2f	21 5d 7c
	ld de,SPRITES_ATTRIB_TABLE		;7c32	11 00 1b
	ld bc, 4*4		                ;7c35	01 10 00 4 sprites
	call LDIRVM		                ;7c38	cd 5c 00

    ; Wait 240 ticks
	ld hl, 240		        ;7c3b	21 f0 00
	call DELAY_HL_TICKS		;7c3e	cd 80 43

	call CLEAR_SCREEN		;7c41	cd 27 42 	. ' B 
l7c44h:
	ld hl,0e027h		;7c44	21 27 e0 	! ' . 
	ld de,0e028h		;7c47	11 28 e0 	. ( . 
	ld bc,0058dh		;7c4a	01 8d 05 	. . . 
	dec bc			;7c4d	0b 	. 
	ld (hl),000h		;7c4e	36 00 	6 . 
	ldir		;7c50	ed b0 	. . 

    ; Reset states
	xor a			        ;7c52	af
	ld (0e00ah),a		    ;7c53	32 0a e0
    ; Set we're in the title screen
	ld (GAME_STATE),a		;7c56	32 0b e0
    ; Reset Doh hits
	ld (DOH_HITS),a		    ;7c59	32 b3 e5
	ret			            ;7c5c	c9

l7c5dh:
	adc a,b			;7c5d	88 	. 
	ld b,h			;7c5e	44 	D 
	ld (hl),b			;7c5f	70 	p 
	rrca			;7c60	0f 	. 
	adc a,b			;7c61	88 	. 
	ld d,h			;7c62	54 	T 
	ld (hl),h			;7c63	74 	t 
	rrca			;7c64	0f 	. 
	adc a,b			;7c65	88 	. 
	ld l,h			;7c66	6c 	l 
	ld a,b			;7c67	78 	x 
	rrca			;7c68	0f 	. 
	adc a,b			;7c69	88 	. 
	ld a,h			;7c6a	7c 	| 
	ld a,h			;7c6b	7c 	| 
	rrca			;7c6c	0f 	. 

; Table to write "GAME OVER" with sprites
GAME_OVER_SPRITE_TABLE:
    ; V H P (EC, 0, 0, 0, C)
    db 0x4c, 0x5c, 0x70, 0x0f; "GA"
    db 0x4c, 0x6c, 0x74, 0x0f; "ME"
    ;
	db 0x4c, 0x84, 0x78, 0x0f; "OV"
    db 0x4c, 0x94, 0x7c, 0x0f; "ER"
    
l7c7dh:
	xor a			;7c7d	af 	. 
	ld (0e00ah),a		;7c7e	32 0a e0 	2 . . 

    ; Wait 60 ticks
	ld hl, 60   		    ;7c81	21 3c 00
	call DELAY_HL_TICKS		;7c84	cd 80 43
	ret			            ;7c87	c9

ENDING_STR:
    db "DIMENSION-CONTROLLING FORT\"DOH\" HAS NOW BEEN        DEMOLISHED, AND TIME      STARTED FLOWING REVERSELY.\"VAUS\" MANAGED TO ESCAPE  FROM THE DISTORTED SPACE. BUT THE REAL VOYAGE OF    \"ARKANOID\" IN THE GALAXY  HAS ONLY STARTED......    "

0x7d72:
	ld b,e			;7d72	43 	C 
    db 0x18, 0x83
    db 0x18, 0xc3
	jr l7d7ch		;7d77	18 03 	. . 
	add hl,de			;7d79	19 	. 
	ld h,e			;7d7a	63 	c 
	add hl,de			;7d7b	19 	. 
l7d7ch:
	and e			;7d7c	a3 	. 
l7d7dh:
	add hl,de			;7d7d	19 	. 
	inc bc			;7d7e	03 	. 
l7d7fh:
	ld a,(de)			;7d7f	1a 	. 
	ld b,e			;7d80	43 	C 
	ld a,(de)			;7d81	1a 	. 
	add a,e			;7d82	83 	. 
	ld a,(de)			;7d83	1a 	. 
l7d84h:
	nop			;7d84	00 	. 
	nop			;7d85	00 	. 
	nop			;7d86	00 	. 
	nop			;7d87	00 	. 
l7d88h:
	nop			;7d88	00 	. 
	nop			;7d89	00 	. 
	nop			;7d8a	00 	. 
	nop			;7d8b	00 	. 
	nop			;7d8c	00 	. 
	nop			;7d8d	00 	. 
	nop			;7d8e	00 	. 
	nop			;7d8f	00 	. 
l7d90h:
	nop			;7d90	00 	. 
	nop			;7d91	00 	. 
l7d92h:
	nop			;7d92	00 	. 
	nop			;7d93	00 	. 
	nop			;7d94	00 	. 
	ccf			;7d95	3f 	? 
	ld a,a			;7d96	7f 	 
	ld a,a			;7d97	7f 	 
l7d98h:
	ld a,a			;7d98	7f 	 
	ld a,h			;7d99	7c 	| 
	ld a,e			;7d9a	7b 	{ 
	ld a,d			;7d9b	7a 	z 
	nop			;7d9c	00 	. 
	ld a,(hl)			;7d9d	7e 	~ 
	cp a			;7d9e	bf 	. 
	cp a			;7d9f	bf 	. 
	cp a			;7da0	bf 	. 
l7da1h:
	cp a			;7da1	bf 	. 
	cp a			;7da2	bf 	. 
	cp a			;7da3	bf 	. 
	cp a			;7da4	bf 	. 
	nop			;7da5	00 	. 
	cp a			;7da6	bf 	. 
	nop			;7da7	00 	. 
	cp a			;7da8	bf 	. 
	nop			;7da9	00 	. 
	cp a			;7daa	bf 	. 
	nop			;7dab	00 	. 
l7dach:
	cp a			;7dac	bf 	. 
	cp a			;7dad	bf 	. 
	cp a			;7dae	bf 	. 
	cp a			;7daf	bf 	. 
	cp a			;7db0	bf 	. 
	cp a			;7db1	bf 	. 
	cp a			;7db2	bf 	. 
	ld a,(hl)			;7db3	7e 	~ 
	nop			;7db4	00 	. 
l7db5h:
	ld a,d			;7db5	7a 	z 
	ld a,d			;7db6	7a 	z 
	ld a,d			;7db7	7a 	z 
	ld a,d			;7db8	7a 	z 
	ld a,d			;7db9	7a 	z 
	ld a,d			;7dba	7a 	z 
	ld a,d			;7dbb	7a 	z 
	ld a,d			;7dbc	7a 	z 
	ld a,d			;7dbd	7a 	z 
	ld a,d			;7dbe	7a 	z 
	ld a,d			;7dbf	7a 	z 
	ld a,d			;7dc0	7a 	z 
	ld a,d			;7dc1	7a 	z 
	ld a,d			;7dc2	7a 	z 
	ld a,d			;7dc3	7a 	z 
	inc bc			;7dc4	03 	. 
	rst 30h			;7dc5	f7 	. 
	rst 30h			;7dc6	f7 	. 
	rst 30h			;7dc7	f7 	. 
	rst 30h			;7dc8	f7 	. 
	inc bc			;7dc9	03 	. 
	call p,0fa03h		;7dca	f4 03 fa 	. . . 
	jp m,0fafah		;7dcd	fa fa fa 	. . . 
	jp m,000fah		;7dd0	fa fa 00 	. . . 
	jp m,lafach+3		;7dd3	fa af af 	. . . 
	xor a			;7dd6	af 	. 
	xor a			;7dd7	af 	. 
	xor a			;7dd8	af 	. 
	xor a			;7dd9	af 	. 
	nop			;7dda	00 	. 
	xor a			;7ddb	af 	. 
	ret po			;7ddc	e0 	. 
	rst 30h			;7ddd	f7 	. 
	rst 30h			;7dde	f7 	. 
	rst 30h			;7ddf	f7 	. 
	rst 30h			;7de0	f7 	. 
	ret po			;7de1	e0 	. 
	rla			;7de2	17 	. 
	ret po			;7de3	e0 	. 
	nop			;7de4	00 	. 
	rst 38h			;7de5	ff 	. 
	rst 38h			;7de6	ff 	. 
	rst 38h			;7de7	ff 	. 
	rst 38h			;7de8	ff 	. 
	nop			;7de9	00 	. 
	rst 38h			;7dea	ff 	. 
	nop			;7deb	00 	. 
	nop			;7dec	00 	. 
	call m,0f6feh		;7ded	fc fe f6 	. . . 
	jp m,0ba7ah		;7df0	fa 7a ba 	. z . 
	ld a,d			;7df3	7a 	z 
	inc bc			;7df4	03 	. 
	call p,0f000h		;7df5	f4 00 f0 	. . . 
	ret p			;7df8	f0 	. 
	nop			;7df9	00 	. 
	call p,0fa03h		;7dfa	f4 03 fa 	. . . 
	nop			;7dfd	00 	. 
	nop			;7dfe	00 	. 
	nop			;7dff	00 	. 
	nop			;7e00	00 	. 
	nop			;7e01	00 	. 
	nop			;7e02	00 	. 
	jp m,000afh		;7e03	fa af 00 	. . . 
	nop			;7e06	00 	. 
	nop			;7e07	00 	. 
	nop			;7e08	00 	. 
	nop			;7e09	00 	. 
	nop			;7e0a	00 	. 
	xor a			;7e0b	af 	. 
	ret po			;7e0c	e0 	. 
	rla			;7e0d	17 	. 
	nop			;7e0e	00 	. 
	rlca			;7e0f	07 	. 
	rlca			;7e10	07 	. 
	nop			;7e11	00 	. 
	rla			;7e12	17 	. 
	ret po			;7e13	e0 	. 
	nop			;7e14	00 	. 
	ret p			;7e15	f0 	. 
	nop			;7e16	00 	. 
	ret p			;7e17	f0 	. 
	ret p			;7e18	f0 	. 
	nop			;7e19	00 	. 
	ret p			;7e1a	f0 	. 
	nop			;7e1b	00 	. 
	nop			;7e1c	00 	. 
	nop			;7e1d	00 	. 
	nop			;7e1e	00 	. 
	nop			;7e1f	00 	. 
	nop			;7e20	00 	. 
	nop			;7e21	00 	. 
	nop			;7e22	00 	. 
	nop			;7e23	00 	. 
	nop			;7e24	00 	. 
	nop			;7e25	00 	. 
	nop			;7e26	00 	. 
	nop			;7e27	00 	. 
	nop			;7e28	00 	. 
	nop			;7e29	00 	. 
	nop			;7e2a	00 	. 
	nop			;7e2b	00 	. 
	nop			;7e2c	00 	. 
	rlca			;7e2d	07 	. 
	nop			;7e2e	00 	. 
	rlca			;7e2f	07 	. 
	rlca			;7e30	07 	. 
	nop			;7e31	00 	. 
	rlca			;7e32	07 	. 
	nop			;7e33	00 	. 
	ld a,d			;7e34	7a 	z 
	ld a,d			;7e35	7a 	z 
	ld a,d			;7e36	7a 	z 
	ld a,d			;7e37	7a 	z 
	ld a,d			;7e38	7a 	z 
	ld a,d			;7e39	7a 	z 
	nop			;7e3a	00 	. 
	ld a,(hl)			;7e3b	7e 	~ 
	cp a			;7e3c	bf 	. 
	cp a			;7e3d	bf 	. 
	cp a			;7e3e	bf 	. 
	cp a			;7e3f	bf 	. 
	cp a			;7e40	bf 	. 
	cp a			;7e41	bf 	. 
	cp a			;7e42	bf 	. 
	nop			;7e43	00 	. 
	cp a			;7e44	bf 	. 
	nop			;7e45	00 	. 
	nop			;7e46	00 	. 
	nop			;7e47	00 	. 
	nop			;7e48	00 	. 
	nop			;7e49	00 	. 
	nop			;7e4a	00 	. 
	nop			;7e4b	00 	. 
	cp a			;7e4c	bf 	. 
	nop			;7e4d	00 	. 
	cp a			;7e4e	bf 	. 
	cp a			;7e4f	bf 	. 
	cp a			;7e50	bf 	. 
	cp a			;7e51	bf 	. 
	cp a			;7e52	bf 	. 
	cp a			;7e53	bf 	. 
	ld a,d			;7e54	7a 	z 
	nop			;7e55	00 	. 
	ld a,(hl)			;7e56	7e 	~ 
	cp a			;7e57	bf 	. 
	cp a			;7e58	bf 	. 
	cp a			;7e59	bf 	. 
	cp a			;7e5a	bf 	. 
	cp a			;7e5b	bf 	. 
	cp a			;7e5c	bf 	. 
	cp a			;7e5d	bf 	. 
	nop			;7e5e	00 	. 
	cp a			;7e5f	bf 	. 
	nop			;7e60	00 	. 
	jr nz,l7e83h		;7e61	20 20 	    
	djnz l7e6dh		;7e63	10 08 	. . 
	inc b			;7e65	04 	. 
	inc b			;7e66	04 	. 
	ex af,af'			;7e67	08 	. 
	djnz l7e8ah		;7e68	10 20 	.   
	jr nz,l7e7ch		;7e6a	20 10 	  . 
	ex af,af'			;7e6c	08 	. 
l7e6dh:
	inc b			;7e6d	04 	. 
	inc b			;7e6e	04 	. 
	ex af,af'			;7e6f	08 	. 
	nop			;7e70	00 	. 
	cp a			;7e71	bf 	. 
	nop			;7e72	00 	. 
	cp a			;7e73	bf 	. 
	ld a,d			;7e74	7a 	z 
	nop			;7e75	00 	. 
	ld a,(hl)			;7e76	7e 	~ 
	cp a			;7e77	bf 	. 
	cp a			;7e78	bf 	. 
	cp a			;7e79	bf 	. 
	cp a			;7e7a	bf 	. 
	cp a			;7e7b	bf 	. 
l7e7ch:
	cp a			;7e7c	bf 	. 
	cp a			;7e7d	bf 	. 
	nop			;7e7e	00 	. 
	cp a			;7e7f	bf 	. 
	nop			;7e80	00 	. 
	inc b			;7e81	04 	. 
	inc b			;7e82	04 	. 
l7e83h:
	ex af,af'			;7e83	08 	. 
	nop			;7e84	00 	. 
	nop			;7e85	00 	. 
	nop			;7e86	00 	. 
	nop			;7e87	00 	. 
	nop			;7e88	00 	. 
	nop			;7e89	00 	. 
l7e8ah:
	nop			;7e8a	00 	. 
	nop			;7e8b	00 	. 
	djnz l7eaeh		;7e8c	10 20 	.   
	jr nz,l7ea0h		;7e8e	20 10 	  . 
	nop			;7e90	00 	. 
	cp a			;7e91	bf 	. 
	nop			;7e92	00 	. 
	cp a			;7e93	bf 	. 
	ld (hl),036h		;7e94	36 36 	6 6 
	inc h			;7e96	24 	$ 
	nop			;7e97	00 	. 
	nop			;7e98	00 	. 
	nop			;7e99	00 	. 
	nop			;7e9a	00 	. 
	nop			;7e9b	00 	. 
	rst 38h			;7e9c	ff 	. 
	rst 38h			;7e9d	ff 	. 
	rst 38h			;7e9e	ff 	. 
	rst 38h			;7e9f	ff 	. 
l7ea0h:
	rst 38h			;7ea0	ff 	. 
	rst 38h			;7ea1	ff 	. 
	rst 38h			;7ea2	ff 	. 
	nop			;7ea3	00 	. 
	cp 0feh		;7ea4	fe fe 	. . 
	cp 0feh		;7ea6	fe fe 	. . 
	cp 0feh		;7ea8	fe fe 	. . 
	cp 000h		;7eaa	fe 00 	. . 
	rst 38h			;7eac	ff 	. 
	rst 38h			;7ead	ff 	. 
l7eaeh:
	rst 38h			;7eae	ff 	. 
	rst 38h			;7eaf	ff 	. 
	rst 38h			;7eb0	ff 	. 
	rst 38h			;7eb1	ff 	. 
	rst 38h			;7eb2	ff 	. 
	nop			;7eb3	00 	. 
	cp 0feh		;7eb4	fe fe 	. . 
	cp 0feh		;7eb6	fe fe 	. . 
	cp 0feh		;7eb8	fe fe 	. . 
	cp 000h		;7eba	fe 00 	. . 
	rst 38h			;7ebc	ff 	. 
	rst 38h			;7ebd	ff 	. 
	rst 38h			;7ebe	ff 	. 
	rst 38h			;7ebf	ff 	. 
	rst 38h			;7ec0	ff 	. 
	rst 38h			;7ec1	ff 	. 
	rst 38h			;7ec2	ff 	. 
	nop			;7ec3	00 	. 
	cp 0feh		;7ec4	fe fe 	. . 
	cp 0feh		;7ec6	fe fe 	. . 
	cp 0feh		;7ec8	fe fe 	. . 
	cp 000h		;7eca	fe 00 	. . 
	rst 38h			;7ecc	ff 	. 
	rst 38h			;7ecd	ff 	. 
	rst 38h			;7ece	ff 	. 
	rst 38h			;7ecf	ff 	. 
	rst 38h			;7ed0	ff 	. 
	rst 38h			;7ed1	ff 	. 
	rst 38h			;7ed2	ff 	. 
	nop			;7ed3	00 	. 
	nop			;7ed4	00 	. 
	nop			;7ed5	00 	. 
	nop			;7ed6	00 	. 
	ld a,000h		;7ed7	3e 00 	> . 
	nop			;7ed9	00 	. 
	nop			;7eda	00 	. 
	nop			;7edb	00 	. 
	ld h,e			;7edc	63 	c 
	ld h,e			;7edd	63 	c 
	ld h,e			;7ede	63 	c 
	ld a,a			;7edf	7f 	 
	ld h,e			;7ee0	63 	c 
	ld h,e			;7ee1	63 	c 
	ld h,e			;7ee2	63 	c 
	nop			;7ee3	00 	. 
	nop			;7ee4	00 	. 
	nop			;7ee5	00 	. 
	nop			;7ee6	00 	. 
	nop			;7ee7	00 	. 
	jr l7f02h		;7ee8	18 18 	. . 
	jr nc,l7eech		;7eea	30 00 	0 . 
l7eech:
	nop			;7eec	00 	. 
	nop			;7eed	00 	. 
	nop			;7eee	00 	. 
	ld a,000h		;7eef	3e 00 	> . 
	nop			;7ef1	00 	. 
	nop			;7ef2	00 	. 
	nop			;7ef3	00 	. 
	nop			;7ef4	00 	. 
	nop			;7ef5	00 	. 
	nop			;7ef6	00 	. 
	nop			;7ef7	00 	. 
	nop			;7ef8	00 	. 
	jr l7f13h		;7ef9	18 18 	. . 
	nop			;7efb	00 	. 
	ccf			;7efc	3f 	? 
	inc c			;7efd	0c 	. 
	inc c			;7efe	0c 	. 
	inc c			;7eff	0c 	. 
sub_7f00h:
	inc c			;7f00	0c 	. 
	inc c			;7f01	0c 	. 
l7f02h:
	ccf			;7f02	3f 	? 
	nop			;7f03	00 	. 
	inc e			;7f04	1c 	. 
	ld h,063h		;7f05	26 63 	& c 
	ld h,e			;7f07	63 	c 
	ld h,e			;7f08	63 	c 
	ld (0001ch),a		;7f09	32 1c 00 	2 . . 
	inc c			;7f0c	0c 	. 
	inc e			;7f0d	1c 	. 
	inc c			;7f0e	0c 	. 
	inc c			;7f0f	0c 	. 
	inc c			;7f10	0c 	. 
	inc c			;7f11	0c 	. 
	ccf			;7f12	3f 	? 
l7f13h:
	nop			;7f13	00 	. 
	ld a,063h		;7f14	3e 63 	> c 
	rlca			;7f16	07 	. 
	ld e,03ch		;7f17	1e 3c 	. < 
	ld (hl),b			;7f19	70 	p 
	ld a,a			;7f1a	7f 	 
	nop			;7f1b	00 	. 
	ccf			;7f1c	3f 	? 
	ld b,00ch		;7f1d	06 0c 	. . 
	ld e,003h		;7f1f	1e 03 	. . 
	ld h,e			;7f21	63 	c 
	ld a,000h		;7f22	3e 00 	> . 
	ld c,01eh		;7f24	0e 1e 	. . 
	ld (hl),066h		;7f26	36 66 	6 f 
	ld a,a			;7f28	7f 	 
	ld b,006h		;7f29	06 06 	. . 
	nop			;7f2b	00 	. 
	ld a,(hl)			;7f2c	7e 	~ 
	ld h,b			;7f2d	60 	` 
	ld a,(hl)			;7f2e	7e 	~ 
	inc bc			;7f2f	03 	. 
	inc bc			;7f30	03 	. 
	ld h,e			;7f31	63 	c 
	ld a,000h		;7f32	3e 00 	> . 
	ld e,030h		;7f34	1e 30 	. 0 
	ld h,b			;7f36	60 	` 
	ld a,(hl)			;7f37	7e 	~ 
	ld h,e			;7f38	63 	c 
	ld h,e			;7f39	63 	c 
	ld a,000h		;7f3a	3e 00 	> . 
	ld a,a			;7f3c	7f 	 
	ld h,e			;7f3d	63 	c 
	ld b,00ch		;7f3e	06 0c 	. . 
	jr l7f5ah		;7f40	18 18 	. . 
	jr l7f44h		;7f42	18 00 	. . 
l7f44h:
	inc a			;7f44	3c 	< 
	ld h,d			;7f45	62 	b 
	ld (hl),d			;7f46	72 	r 
	inc a			;7f47	3c 	< 
	ld c,a			;7f48	4f 	O 
	ld b,e			;7f49	43 	C 
	ld a,000h		;7f4a	3e 00 	> . 
	ld a,063h		;7f4c	3e 63 	> c 
	ld h,e			;7f4e	63 	c 
	ccf			;7f4f	3f 	? 
	inc bc			;7f50	03 	. 
	ld b,03ch		;7f51	06 3c 	. < 
	nop			;7f53	00 	. 
	inc a			;7f54	3c 	< 
	ld h,(hl)			;7f55	66 	f 
	ld h,b			;7f56	60 	` 
	ld a,003h		;7f57	3e 03 	> . 
	ld h,e			;7f59	63 	c 
l7f5ah:
	ld a,000h		;7f5a	3e 00 	> . 
	ld e,033h		;7f5c	1e 33 	. 3 
	ld h,b			;7f5e	60 	` 
	ld h,b			;7f5f	60 	` 
	ld h,b			;7f60	60 	` 
	inc sp			;7f61	33 	3 
	ld e,000h		;7f62	1e 00 	. . 
	ld a,063h		;7f64	3e 63 	> c 
	ld h,e			;7f66	63 	c 
	ld h,e			;7f67	63 	c 
	ld h,e			;7f68	63 	c 
	ld h,e			;7f69	63 	c 
	ld a,000h		;7f6a	3e 00 	> . 
	ld a,(hl)			;7f6c	7e 	~ 
	ld h,e			;7f6d	63 	c 
	ld h,e			;7f6e	63 	c 
	ld h,a			;7f6f	67 	g 
	ld a,h			;7f70	7c 	| 
	ld l,(hl)			;7f71	6e 	n 
	ld h,a			;7f72	67 	g 
	nop			;7f73	00 	. 
	ld a,a			;7f74	7f 	 
	ld h,b			;7f75	60 	` 
	ld h,b			;7f76	60 	` 
	ld a,(hl)			;7f77	7e 	~ 
	ld h,b			;7f78	60 	` 
	ld h,b			;7f79	60 	` 
	ld a,a			;7f7a	7f 	 
	nop			;7f7b	00 	. 
	rra			;7f7c	1f 	. 
	jr nc,l7fdfh		;7f7d	30 60 	0 ` 
	ld h,a			;7f7f	67 	g 
	ld h,e			;7f80	63 	c 
	inc sp			;7f81	33 	3 
	rra			;7f82	1f 	. 
	nop			;7f83	00 	. 
	inc a			;7f84	3c 	< 
	ld b,d			;7f85	42 	B 
	sbc a,c			;7f86	99 	. 
	and c			;7f87	a1 	. 
	and c			;7f88	a1 	. 
	sbc a,c			;7f89	99 	. 
	ld b,d			;7f8a	42 	B 
	inc a			;7f8b	3c 	< 
	inc e			;7f8c	1c 	. 
	ld (hl),063h		;7f8d	36 63 	6 c 
	ld h,e			;7f8f	63 	c 
	ld a,a			;7f90	7f 	 
	ld h,e			;7f91	63 	c 
	ld h,e			;7f92	63 	c 
	nop			;7f93	00 	. 
	ld a,(hl)			;7f94	7e 	~ 
	ld h,e			;7f95	63 	c 
	ld h,e			;7f96	63 	c 
	ld a,(hl)			;7f97	7e 	~ 
	ld h,e			;7f98	63 	c 
	ld h,e			;7f99	63 	c 
	ld a,(hl)			;7f9a	7e 	~ 
	nop			;7f9b	00 	. 
	ld e,033h		;7f9c	1e 33 	. 3 
	ld h,b			;7f9e	60 	` 
	ld h,b			;7f9f	60 	` 
	ld h,b			;7fa0	60 	` 
	inc sp			;7fa1	33 	3 
	ld e,000h		;7fa2	1e 00 	. . 
	ld a,h			;7fa4	7c 	| 
	ld h,(hl)			;7fa5	66 	f 
	ld h,e			;7fa6	63 	c 
	ld h,e			;7fa7	63 	c 
	ld h,e			;7fa8	63 	c 
	ld h,(hl)			;7fa9	66 	f 
	ld a,h			;7faa	7c 	| 
	nop			;7fab	00 	. 
	ld a,a			;7fac	7f 	 
	ld h,b			;7fad	60 	` 
	ld h,b			;7fae	60 	` 
	ld a,(hl)			;7faf	7e 	~ 
	ld h,b			;7fb0	60 	` 
	ld h,b			;7fb1	60 	` 
	ld a,a			;7fb2	7f 	 
	nop			;7fb3	00 	. 
	ld a,a			;7fb4	7f 	 
	ld h,b			;7fb5	60 	` 
	ld h,b			;7fb6	60 	` 
	ld a,(hl)			;7fb7	7e 	~ 
	ld h,b			;7fb8	60 	` 
	ld h,b			;7fb9	60 	` 
	ld h,b			;7fba	60 	` 
	nop			;7fbb	00 	. 
	rra			;7fbc	1f 	. 
	jr nc,l801fh		;7fbd	30 60 	0 ` 
	ld h,a			;7fbf	67 	g 
	ld h,e			;7fc0	63 	c 
	inc sp			;7fc1	33 	3 
	rra			;7fc2	1f 	. 
	nop			;7fc3	00 	. 
	ld h,e			;7fc4	63 	c 
	ld h,e			;7fc5	63 	c 
	ld h,e			;7fc6	63 	c 
	ld a,a			;7fc7	7f 	 
	ld h,e			;7fc8	63 	c 
	ld h,e			;7fc9	63 	c 
	ld h,e			;7fca	63 	c 
	nop			;7fcb	00 	. 
	ccf			;7fcc	3f 	? 
	inc c			;7fcd	0c 	. 
	inc c			;7fce	0c 	. 
	inc c			;7fcf	0c 	. 
	inc c			;7fd0	0c 	. 
	inc c			;7fd1	0c 	. 
	ccf			;7fd2	3f 	? 
	nop			;7fd3	00 	. 
	inc bc			;7fd4	03 	. 
	inc bc			;7fd5	03 	. 
	inc bc			;7fd6	03 	. 
	inc bc			;7fd7	03 	. 
	inc bc			;7fd8	03 	. 
	ld h,e			;7fd9	63 	c 
	ld a,000h		;7fda	3e 00 	> . 
	ld h,e			;7fdc	63 	c 
	ld h,(hl)			;7fdd	66 	f 
	ld l,h			;7fde	6c 	l 
l7fdfh:
	ld a,b			;7fdf	78 	x 
	ld a,h			;7fe0	7c 	| 
	ld l,(hl)			;7fe1	6e 	n 
	ld h,a			;7fe2	67 	g 
	nop			;7fe3	00 	. 
	ld h,b			;7fe4	60 	` 
	ld h,b			;7fe5	60 	` 
	ld h,b			;7fe6	60 	` 
	ld h,b			;7fe7	60 	` 
	ld h,b			;7fe8	60 	` 
	ld h,b			;7fe9	60 	` 
	ld a,a			;7fea	7f 	 
	nop			;7feb	00 	. 
	ld h,e			;7fec	63 	c 
	ld (hl),a			;7fed	77 	w 
	ld a,a			;7fee	7f 	 
	ld a,a			;7fef	7f 	 
	ld l,e			;7ff0	6b 	k 
	ld h,e			;7ff1	63 	c 
	ld h,e			;7ff2	63 	c 
	nop			;7ff3	00 	. 
	ld h,e			;7ff4	63 	c 
	ld (hl),e			;7ff5	73 	s 
	ld a,e			;7ff6	7b 	{ 
	ld a,a			;7ff7	7f 	 
l7ff8h:
	ld l,a			;7ff8	6f 	o 
	ld h,a			;7ff9	67 	g 
	ld h,e			;7ffa	63 	c 
	nop			;7ffb	00 	. 
	ld a,063h		;7ffc	3e 63 	> c 
	ld h,e			;7ffe	63 	c 
	ld h,e			;7fff	63 	c 
l8000h:
	ld h,e			;8000	63 	c 
	ld h,e			;8001	63 	c 
	ld a,000h		;8002	3e 00 	> . 
	ld a,(hl)			;8004	7e 	~ 
	ld h,e			;8005	63 	c 
	ld h,e			;8006	63 	c 
sub_8007h:
	ld h,e			;8007	63 	c 
sub_8008h:
	ld a,(hl)			;8008	7e 	~ 
	ld h,b			;8009	60 	` 
	ld h,b			;800a	60 	` 
	nop			;800b	00 	. 
	ld a,063h		;800c	3e 63 	> c 
	ld h,e			;800e	63 	c 
	ld h,e			;800f	63 	c 
sub_8010h:
	ld l,a			;8010	6f 	o 
	ld h,(hl)			;8011	66 	f 
	dec a			;8012	3d 	= 
	nop			;8013	00 	. 
	ld a,(hl)			;8014	7e 	~ 
	ld h,e			;8015	63 	c 
	ld h,e			;8016	63 	c 
	ld h,a			;8017	67 	g 
	ld a,h			;8018	7c 	| 
	ld l,(hl)			;8019	6e 	n 
	ld h,a			;801a	67 	g 
	nop			;801b	00 	. 
	inc a			;801c	3c 	< 
	ld h,(hl)			;801d	66 	f 
	ld h,b			;801e	60 	` 
l801fh:
	ld a,003h		;801f	3e 03 	> . 
	ld h,e			;8021	63 	c 
	ld a,000h		;8022	3e 00 	> . 
	ccf			;8024	3f 	? 
	inc c			;8025	0c 	. 
	inc c			;8026	0c 	. 
	inc c			;8027	0c 	. 
	inc c			;8028	0c 	. 
	inc c			;8029	0c 	. 
	inc c			;802a	0c 	. 
	nop			;802b	00 	. 
	ld h,e			;802c	63 	c 
	ld h,e			;802d	63 	c 
	ld h,e			;802e	63 	c 
	ld h,e			;802f	63 	c 
	ld h,e			;8030	63 	c 
	ld h,e			;8031	63 	c 
	ld a,000h		;8032	3e 00 	> . 
	ld h,e			;8034	63 	c 
	ld h,e			;8035	63 	c 
	ld h,e			;8036	63 	c 
	ld h,e			;8037	63 	c 
	ld (hl),01ch		;8038	36 1c 	6 . 
	ex af,af'			;803a	08 	. 
	nop			;803b	00 	. 
	ld h,e			;803c	63 	c 
	ld h,e			;803d	63 	c 
	ld l,e			;803e	6b 	k 
	ld a,a			;803f	7f 	 
	ld a,a			;8040	7f 	 
	ld (hl),a			;8041	77 	w 
	ld h,e			;8042	63 	c 
	nop			;8043	00 	. 
	ld h,e			;8044	63 	c 
	ld (hl),a			;8045	77 	w 
	ld a,01ch		;8046	3e 1c 	> . 
	ld a,077h		;8048	3e 77 	> w 
	ld h,e			;804a	63 	c 
	nop			;804b	00 	. 
	inc sp			;804c	33 	3 
	inc sp			;804d	33 	3 
	inc sp			;804e	33 	3 
	ld e,00ch		;804f	1e 0c 	. . 
	inc c			;8051	0c 	. 
	inc c			;8052	0c 	. 
	nop			;8053	00 	. 
	ld a,a			;8054	7f 	 
	rlca			;8055	07 	. 
	ld c,01ch		;8056	0e 1c 	. . 
	jr c,$+114		;8058	38 70 	8 p 
	ld a,a			;805a	7f 	 
	nop			;805b	00 	. 
	cp 0feh		;805c	fe fe 	. . 
	cp 0feh		;805e	fe fe 	. . 
	cp 0feh		;8060	fe fe 	. . 
	cp 000h		;8062	fe 00 	. . 
	rst 38h			;8064	ff 	. 
	rst 38h			;8065	ff 	. 
	rst 38h			;8066	ff 	. 
	rst 38h			;8067	ff 	. 
	rst 38h			;8068	ff 	. 
	rst 38h			;8069	ff 	. 
	rst 38h			;806a	ff 	. 
	nop			;806b	00 	. 
	cp 0feh		;806c	fe fe 	. . 
	cp 0feh		;806e	fe fe 	. . 
	cp 0feh		;8070	fe fe 	. . 
	cp 000h		;8072	fe 00 	. . 
	rst 38h			;8074	ff 	. 
	rst 38h			;8075	ff 	. 
	rst 38h			;8076	ff 	. 
	rst 38h			;8077	ff 	. 
	rst 38h			;8078	ff 	. 
	rst 38h			;8079	ff 	. 
	rst 38h			;807a	ff 	. 
	nop			;807b	00 	. 
	ld (hl),036h		;807c	36 36 	6 6 
sub_807eh:
	ld (de),a			;807e	12 	. 
	nop			;807f	00 	. 
	nop			;8080	00 	. 
	nop			;8081	00 	. 
	nop			;8082	00 	. 
	nop			;8083	00 	. 
	cp 0feh		;8084	fe fe 	. . 
	cp 0feh		;8086	fe fe 	. . 
	cp 0feh		;8088	fe fe 	. . 
	cp 000h		;808a	fe 00 	. . 
	rst 38h			;808c	ff 	. 
	rst 38h			;808d	ff 	. 
	rst 38h			;808e	ff 	. 
	rst 38h			;808f	ff 	. 
	rst 38h			;8090	ff 	. 
	rst 38h			;8091	ff 	. 
	rst 38h			;8092	ff 	. 
	nop			;8093	00 	. 
	cp 0feh		;8094	fe fe 	. . 
	cp 0feh		;8096	fe fe 	. . 
	cp 0feh		;8098	fe fe 	. . 
	cp 000h		;809a	fe 00 	. . 
	rst 38h			;809c	ff 	. 
	rst 38h			;809d	ff 	. 
	rst 38h			;809e	ff 	. 
	rst 38h			;809f	ff 	. 
	rst 38h			;80a0	ff 	. 
	rst 38h			;80a1	ff 	. 
	rst 38h			;80a2	ff 	. 
	nop			;80a3	00 	. 
	cp 0feh		;80a4	fe fe 	. . 
	cp 0feh		;80a6	fe fe 	. . 
	cp 0feh		;80a8	fe fe 	. . 
	cp 000h		;80aa	fe 00 	. . 
	nop			;80ac	00 	. 
	ld a,a			;80ad	7f 	 
	ld a,a			;80ae	7f 	 
	ld a,a			;80af	7f 	 
	ld a,a			;80b0	7f 	 
	ld a,a			;80b1	7f 	 
	add a,b			;80b2	80 	. 
	nop			;80b3	00 	. 
	cp 0fch		;80b4	fe fc 	. . 
	call m,0fcfch		;80b6	fc fc fc 	. . . 
	call m,00000h		;80b9	fc 00 00 	. . . 
	nop			;80bc	00 	. 
	ld a,a			;80bd	7f 	 
	ld a,a			;80be	7f 	 
	ld a,a			;80bf	7f 	 
	ld a,a			;80c0	7f 	 
	ld a,a			;80c1	7f 	 
	add a,b			;80c2	80 	. 
	nop			;80c3	00 	. 
	cp 0fch		;80c4	fe fc 	. . 
	call m,0fcfch		;80c6	fc fc fc 	. . . 
	call m,00000h		;80c9	fc 00 00 	. . . 
	ld (hl),a			;80cc	77 	w 
	ld (hl),a			;80cd	77 	w 
	rst 30h			;80ce	f7 	. 
	ld (hl),a			;80cf	77 	w 
	ld (hl),b			;80d0	70 	p 
	nop			;80d1	00 	. 
	nop			;80d2	00 	. 
	nop			;80d3	00 	. 
	call c,0dedch		;80d4	dc dc de 	. . . 
	call c,0001ch		;80d7	dc 1c 00 	. . . 
	nop			;80da	00 	. 
	nop			;80db	00 	. 
	rst 38h			;80dc	ff 	. 
	rst 38h			;80dd	ff 	. 
	rst 38h			;80de	ff 	. 
	rst 38h			;80df	ff 	. 
	rst 38h			;80e0	ff 	. 
	rst 38h			;80e1	ff 	. 
	add a,b			;80e2	80 	. 
	nop			;80e3	00 	. 
	cp 0fch		;80e4	fe fc 	. . 
	call m,0fcfch		;80e6	fc fc fc 	. . . 
	call m,00000h		;80e9	fc 00 00 	. . . 
	djnz l810eh		;80ec	10 20 	.   
	jr nz,l8100h		;80ee	20 10 	  . 
sub_80f0h:
	ex af,af'			;80f0	08 	. 
	inc b			;80f1	04 	. 
	inc b			;80f2	04 	. 
	ex af,af'			;80f3	08 	. 
	nop			;80f4	00 	. 
	nop			;80f5	00 	. 
	nop			;80f6	00 	. 
	nop			;80f7	00 	. 
	nop			;80f8	00 	. 
	nop			;80f9	00 	. 
	nop			;80fa	00 	. 
	nop			;80fb	00 	. 
	nop			;80fc	00 	. 
	nop			;80fd	00 	. 
	nop			;80fe	00 	. 
l80ffh:
	nop			;80ff	00 	. 
l8100h:
	nop			;8100	00 	. 
	nop			;8101	00 	. 
	nop			;8102	00 	. 
	nop			;8103	00 	. 
	nop			;8104	00 	. 
sub_8105h:
	nop			;8105	00 	. 
	nop			;8106	00 	. 
	nop			;8107	00 	. 
	nop			;8108	00 	. 
	nop			;8109	00 	. 
	nop			;810a	00 	. 
	nop			;810b	00 	. 
	nop			;810c	00 	. 
	nop			;810d	00 	. 
l810eh:
	nop			;810e	00 	. 
	nop			;810f	00 	. 
	nop			;8110	00 	. 
	nop			;8111	00 	. 
	nop			;8112	00 	. 
	nop			;8113	00 	. 
	nop			;8114	00 	. 
	nop			;8115	00 	. 
	nop			;8116	00 	. 
	nop			;8117	00 	. 
	nop			;8118	00 	. 
	nop			;8119	00 	. 
	nop			;811a	00 	. 
	nop			;811b	00 	. 
	nop			;811c	00 	. 
	nop			;811d	00 	. 
	nop			;811e	00 	. 
	nop			;811f	00 	. 
	nop			;8120	00 	. 
	nop			;8121	00 	. 
	nop			;8122	00 	. 
	nop			;8123	00 	. 
	nop			;8124	00 	. 
	nop			;8125	00 	. 
	nop			;8126	00 	. 
	nop			;8127	00 	. 
	nop			;8128	00 	. 
	nop			;8129	00 	. 
	nop			;812a	00 	. 
	nop			;812b	00 	. 
	nop			;812c	00 	. 
	nop			;812d	00 	. 
	nop			;812e	00 	. 
	nop			;812f	00 	. 
	nop			;8130	00 	. 
	nop			;8131	00 	. 
	nop			;8132	00 	. 
	nop			;8133	00 	. 
	nop			;8134	00 	. 
	nop			;8135	00 	. 
	nop			;8136	00 	. 
	nop			;8137	00 	. 
	nop			;8138	00 	. 
	nop			;8139	00 	. 
	nop			;813a	00 	. 
	nop			;813b	00 	. 
	nop			;813c	00 	. 
	nop			;813d	00 	. 
	nop			;813e	00 	. 
	nop			;813f	00 	. 
	nop			;8140	00 	. 
l8141h:
	nop			;8141	00 	. 
	nop			;8142	00 	. 
	nop			;8143	00 	. 
	nop			;8144	00 	. 
	nop			;8145	00 	. 
	nop			;8146	00 	. 
	nop			;8147	00 	. 
	nop			;8148	00 	. 
	nop			;8149	00 	. 
	nop			;814a	00 	. 
	nop			;814b	00 	. 
	nop			;814c	00 	. 
	nop			;814d	00 	. 
	nop			;814e	00 	. 
	nop			;814f	00 	. 
	nop			;8150	00 	. 
	nop			;8151	00 	. 
	nop			;8152	00 	. 
	nop			;8153	00 	. 
	nop			;8154	00 	. 
	nop			;8155	00 	. 
	nop			;8156	00 	. 
	nop			;8157	00 	. 
	nop			;8158	00 	. 
	nop			;8159	00 	. 
	nop			;815a	00 	. 
	nop			;815b	00 	. 
	nop			;815c	00 	. 
	nop			;815d	00 	. 
	nop			;815e	00 	. 
	nop			;815f	00 	. 
	nop			;8160	00 	. 
	nop			;8161	00 	. 
	nop			;8162	00 	. 
	nop			;8163	00 	. 
	nop			;8164	00 	. 
	nop			;8165	00 	. 
	nop			;8166	00 	. 
	nop			;8167	00 	. 
	nop			;8168	00 	. 
	nop			;8169	00 	. 
	nop			;816a	00 	. 
	nop			;816b	00 	. 
	nop			;816c	00 	. 
	nop			;816d	00 	. 
	nop			;816e	00 	. 
	nop			;816f	00 	. 
	nop			;8170	00 	. 
	nop			;8171	00 	. 
	nop			;8172	00 	. 
	nop			;8173	00 	. 
	nop			;8174	00 	. 
	nop			;8175	00 	. 
	nop			;8176	00 	. 
	nop			;8177	00 	. 
	nop			;8178	00 	. 
	nop			;8179	00 	. 
	nop			;817a	00 	. 
	nop			;817b	00 	. 
	nop			;817c	00 	. 
	nop			;817d	00 	. 
	nop			;817e	00 	. 
	nop			;817f	00 	. 
	nop			;8180	00 	. 
	nop			;8181	00 	. 
	nop			;8182	00 	. 
	nop			;8183	00 	. 
	nop			;8184	00 	. 
	nop			;8185	00 	. 
	nop			;8186	00 	. 
	nop			;8187	00 	. 
	nop			;8188	00 	. 
	nop			;8189	00 	. 
	nop			;818a	00 	. 
	nop			;818b	00 	. 
	nop			;818c	00 	. 
	nop			;818d	00 	. 
	nop			;818e	00 	. 
	nop			;818f	00 	. 
	nop			;8190	00 	. 
	nop			;8191	00 	. 
	nop			;8192	00 	. 
	nop			;8193	00 	. 
	nop			;8194	00 	. 
	nop			;8195	00 	. 
	nop			;8196	00 	. 
	nop			;8197	00 	. 
	nop			;8198	00 	. 
	nop			;8199	00 	. 
	nop			;819a	00 	. 
	nop			;819b	00 	. 
	nop			;819c	00 	. 
	nop			;819d	00 	. 
	nop			;819e	00 	. 
	nop			;819f	00 	. 
	nop			;81a0	00 	. 
	nop			;81a1	00 	. 
	nop			;81a2	00 	. 
	nop			;81a3	00 	. 
	nop			;81a4	00 	. 
	nop			;81a5	00 	. 
	nop			;81a6	00 	. 
	nop			;81a7	00 	. 
	nop			;81a8	00 	. 
	nop			;81a9	00 	. 
	nop			;81aa	00 	. 
	nop			;81ab	00 	. 
	nop			;81ac	00 	. 
	nop			;81ad	00 	. 
	nop			;81ae	00 	. 
l81afh:
	nop			;81af	00 	. 
l81b0h:
	nop			;81b0	00 	. 
	nop			;81b1	00 	. 
	nop			;81b2	00 	. 
	nop			;81b3	00 	. 
	nop			;81b4	00 	. 
	nop			;81b5	00 	. 
	nop			;81b6	00 	. 
	nop			;81b7	00 	. 
	nop			;81b8	00 	. 
	nop			;81b9	00 	. 
	nop			;81ba	00 	. 
	nop			;81bb	00 	. 
	nop			;81bc	00 	. 
	nop			;81bd	00 	. 
	nop			;81be	00 	. 
	nop			;81bf	00 	. 
	nop			;81c0	00 	. 
	nop			;81c1	00 	. 
	nop			;81c2	00 	. 
	nop			;81c3	00 	. 
	nop			;81c4	00 	. 
	nop			;81c5	00 	. 
	nop			;81c6	00 	. 
	nop			;81c7	00 	. 
	nop			;81c8	00 	. 
	nop			;81c9	00 	. 
	nop			;81ca	00 	. 
	nop			;81cb	00 	. 
	nop			;81cc	00 	. 
	nop			;81cd	00 	. 
	nop			;81ce	00 	. 
	nop			;81cf	00 	. 
	nop			;81d0	00 	. 
	nop			;81d1	00 	. 
	nop			;81d2	00 	. 
	nop			;81d3	00 	. 
	nop			;81d4	00 	. 
	nop			;81d5	00 	. 
	nop			;81d6	00 	. 
	nop			;81d7	00 	. 
	nop			;81d8	00 	. 
	nop			;81d9	00 	. 
	nop			;81da	00 	. 
	nop			;81db	00 	. 
	nop			;81dc	00 	. 
	nop			;81dd	00 	. 
	nop			;81de	00 	. 
	nop			;81df	00 	. 
	nop			;81e0	00 	. 
	nop			;81e1	00 	. 
	nop			;81e2	00 	. 
	nop			;81e3	00 	. 
	nop			;81e4	00 	. 
	nop			;81e5	00 	. 
	nop			;81e6	00 	. 
	nop			;81e7	00 	. 
	nop			;81e8	00 	. 
	nop			;81e9	00 	. 
	nop			;81ea	00 	. 
	nop			;81eb	00 	. 
	nop			;81ec	00 	. 
	nop			;81ed	00 	. 
	nop			;81ee	00 	. 
	nop			;81ef	00 	. 
	nop			;81f0	00 	. 
	nop			;81f1	00 	. 
	nop			;81f2	00 	. 
	nop			;81f3	00 	. 
	nop			;81f4	00 	. 
	nop			;81f5	00 	. 
	nop			;81f6	00 	. 
	nop			;81f7	00 	. 
	nop			;81f8	00 	. 
	nop			;81f9	00 	. 
	nop			;81fa	00 	. 
	nop			;81fb	00 	. 
	nop			;81fc	00 	. 
	nop			;81fd	00 	. 
	nop			;81fe	00 	. 
	nop			;81ff	00 	. 
	nop			;8200	00 	. 
	nop			;8201	00 	. 
	nop			;8202	00 	. 
	nop			;8203	00 	. 
	nop			;8204	00 	. 
sub_8205h:
	nop			;8205	00 	. 
	nop			;8206	00 	. 
	nop			;8207	00 	. 
	nop			;8208	00 	. 
	nop			;8209	00 	. 
	nop			;820a	00 	. 
	nop			;820b	00 	. 
	nop			;820c	00 	. 
	nop			;820d	00 	. 
	ld bc,00e07h		;820e	01 07 0e 	. . . 
	add hl,de			;8211	19 	. 
	ld d,026h		;8212	16 26 	. & 
	rlca			;8214	07 	. 
	ei			;8215	fb 	. 
	and b			;8216	a0 	. 
	dec bc			;8217	0b 	. 
	scf			;8218	37 	7 
	ld l,h			;8219	6c 	l 
	ex (sp),hl			;821a	e3 	. 
	ld e,0ffh		;821b	1e ff 	. . 
	ld l,l			;821d	6d 	m 
	nop			;821e	00 	. 
	cp e			;821f	bb 	. 
	ld a,e			;8220	7b 	{ 
	nop			;8221	00 	. 
	ld (hl),a			;8222	77 	w 
	rst 30h			;8223	f7 	. 
	rst 38h			;8224	ff 	. 
	or (hl)			;8225	b6 	. 
	nop			;8226	00 	. 
	defb 0ddh,0deh,000h	;illegal sequence		;8227	dd de 00 	. . . 
	xor 0efh		;822a	ee ef 	. . 
	ret po			;822c	e0 	. 
	rst 18h			;822d	df 	. 
	dec b			;822e	05 	. 
	ret nc			;822f	d0 	. 
	call pe,0c736h		;8230	ec 36 c7 	. 6 . 
	ld a,b			;8233	78 	x 
	nop			;8234	00 	. 
	nop			;8235	00 	. 
	add a,b			;8236	80 	. 
	ret po			;8237	e0 	. 
	ld (hl),b			;8238	70 	p 
	sbc a,b			;8239	98 	. 
	ld l,b			;823a	68 	h 
	ld h,h			;823b	64 	d 
	nop			;823c	00 	. 
	nop			;823d	00 	. 
	nop			;823e	00 	. 
	nop			;823f	00 	. 
	nop			;8240	00 	. 
	nop			;8241	00 	. 
	nop			;8242	00 	. 
	nop			;8243	00 	. 
	nop			;8244	00 	. 
	nop			;8245	00 	. 
	nop			;8246	00 	. 
	nop			;8247	00 	. 
	nop			;8248	00 	. 
	nop			;8249	00 	. 
	nop			;824a	00 	. 
	nop			;824b	00 	. 
	inc (hl)			;824c	34 	4 
	ld sp,04d6dh		;824d	31 6d 4d 	1 m M 
	ld l,h			;8250	6c 	l 
	and c			;8251	a1 	. 
	xor l			;8252	ad 	. 
	adc a,(hl)			;8253	8e 	. 
	sbc a,0deh		;8254	de de 	. . 
	ret nz			;8256	c0 	. 
	ld e,0deh		;8257	1e de 	. . 
	rst 18h			;8259	df 	. 
	xor 0c0h		;825a	ee c0 	. . 
	rst 30h			;825c	f7 	. 
	nop			;825d	00 	. 
	rst 30h			;825e	f7 	. 
	rst 30h			;825f	f7 	. 
	ei			;8260	fb 	. 
	ld a,e			;8261	7b 	{ 
	nop			;8262	00 	. 
	nop			;8263	00 	. 
	rst 28h			;8264	ef 	. 
	nop			;8265	00 	. 
	rst 28h			;8266	ef 	. 
	rst 28h			;8267	ef 	. 
	rst 18h			;8268	df 	. 
	sbc a,000h		;8269	de 00 	. . 
	nop			;826b	00 	. 
	ld a,e			;826c	7b 	{ 
	ld a,e			;826d	7b 	{ 
	inc bc			;826e	03 	. 
	ld a,b			;826f	78 	x 
	ld a,e			;8270	7b 	{ 
	ei			;8271	fb 	. 
	ld (hl),a			;8272	77 	w 
	inc bc			;8273	03 	. 
	inc l			;8274	2c 	, 
	adc a,h			;8275	8c 	. 
	or (hl)			;8276	b6 	. 
	or d			;8277	b2 	. 
	ld (hl),085h		;8278	36 85 	6 . 
	or l			;827a	b5 	. 
	ld (hl),c			;827b	71 	q 
	nop			;827c	00 	. 
	nop			;827d	00 	. 
	nop			;827e	00 	. 
	nop			;827f	00 	. 
	nop			;8280	00 	. 
	nop			;8281	00 	. 
	nop			;8282	00 	. 
	nop			;8283	00 	. 
	nop			;8284	00 	. 
	nop			;8285	00 	. 
	nop			;8286	00 	. 
	nop			;8287	00 	. 
	nop			;8288	00 	. 
	nop			;8289	00 	. 
	nop			;828a	00 	. 
	nop			;828b	00 	. 
	or (hl)			;828c	b6 	. 
	cp b			;828d	b8 	. 
	ret nc			;828e	d0 	. 
	ret po			;828f	e0 	. 
	add a,b			;8290	80 	. 
	ret nz			;8291	c0 	. 
	add a,b			;8292	80 	. 
	add a,b			;8293	80 	. 
	nop			;8294	00 	. 
	nop			;8295	00 	. 
	nop			;8296	00 	. 
	nop			;8297	00 	. 
	nop			;8298	00 	. 
	nop			;8299	00 	. 
	nop			;829a	00 	. 
	nop			;829b	00 	. 
	nop			;829c	00 	. 
	nop			;829d	00 	. 
	nop			;829e	00 	. 
	nop			;829f	00 	. 
	dec b			;82a0	05 	. 
	inc b			;82a1	04 	. 
	ld bc,00005h		;82a2	01 05 00 	. . . 
	nop			;82a5	00 	. 
	nop			;82a6	00 	. 
	nop			;82a7	00 	. 
	and b			;82a8	a0 	. 
	jr nz,$-126		;82a9	20 80 	  . 
l82abh:
	and b			;82ab	a0 	. 
	nop			;82ac	00 	. 
	nop			;82ad	00 	. 
	nop			;82ae	00 	. 
	nop			;82af	00 	. 
	nop			;82b0	00 	. 
	nop			;82b1	00 	. 
	nop			;82b2	00 	. 
	nop			;82b3	00 	. 
	ld l,l			;82b4	6d 	m 
	dec e			;82b5	1d 	. 
	dec bc			;82b6	0b 	. 
	rlca			;82b7	07 	. 
	ld bc,00103h		;82b8	01 03 01 	. . . 
	ld bc,00000h		;82bb	01 00 00 	. . . 
	nop			;82be	00 	. 
	nop			;82bf	00 	. 
	nop			;82c0	00 	. 
	nop			;82c1	00 	. 
	nop			;82c2	00 	. 
	nop			;82c3	00 	. 
	nop			;82c4	00 	. 
	nop			;82c5	00 	. 
	nop			;82c6	00 	. 
	nop			;82c7	00 	. 
	ld bc,00203h		;82c8	01 03 02 	. . . 
	ld b,080h		;82cb	06 80 	. . 
	add a,b			;82cd	80 	. 
	sub l			;82ce	95 	. 
	xor b			;82cf	a8 	. 
	ld b,e			;82d0	43 	C 
	ld d,0b1h		;82d1	16 b1 	. . 
	add a,a			;82d3	87 	. 
	nop			;82d4	00 	. 
	jp c,lbb00h		;82d5	da 00 bb 	. . . 
	add a,b			;82d8	80 	. 
	dec sp			;82d9	3b 	; 
	ld a,e			;82da	7b 	{ 
	nop			;82db	00 	. 
	djnz l82abh		;82dc	10 cd 	. . 
	ld c,l			;82de	4d 	M 
	adc a,b			;82df	88 	. 
	inc hl			;82e0	23 	# 
l82e1h:
	sbc a,e			;82e1	9b 	. 
	sbc a,e			;82e2	9b 	. 
l82e3h:
	jr l82edh		;82e3	18 08 	. . 
	or e			;82e5	b3 	. 
	or d			;82e6	b2 	. 
	ld de,0d9c4h		;82e7	11 c4 d9 	. . . 
	exx			;82ea	d9 	. 
	jr l82edh		;82eb	18 00 	. . 
l82edh:
	ld e,e			;82ed	5b 	[ 
	nop			;82ee	00 	. 
	defb 0ddh,001h,0dch	;illegal sequence		;82ef	dd 01 dc 	. . . 
	sbc a,000h		;82f2	de 00 	. . 
	ld bc,la901h		;82f4	01 01 a9 	. . . 
	dec d			;82f7	15 	. 
	jp nz,08d68h		;82f8	c2 68 8d 	. h . 
	pop hl			;82fb	e1 	. 
	nop			;82fc	00 	. 
	nop			;82fd	00 	. 
	nop			;82fe	00 	. 
	nop			;82ff	00 	. 
	add a,b			;8300	80 	. 
	ret nz			;8301	c0 	. 
	ld b,b			;8302	40 	@ 
	ld h,b			;8303	60 	` 
	inc b			;8304	04 	. 
	ld b,005h		;8305	06 05 	. . 
	inc b			;8307	04 	. 
	dec b			;8308	05 	. 
	inc b			;8309	04 	. 
	dec b			;830a	05 	. 
	inc b			;830b	04 	. 
	jr nc,$+121		;830c	30 77 	0 w 
	rrca			;830e	0f 	. 
	ld l,(hl)			;830f	6e 	n 
	ld h,b			;8310	60 	` 
	ld c,06eh		;8311	0e 6e 	. n 
	ld l,(hl)			;8313	6e 	n 
	ld (hl),a			;8314	77 	w 
	ld (hl),a			;8315	77 	w 
	ld (hl),a			;8316	77 	w 
	nop			;8317	00 	. 
	di			;8318	f3 	. 
	rst 30h			;8319	f7 	. 
	di			;831a	f3 	. 
	call pe,03b47h		;831b	ec 47 3b 	. G ; 
	ld (hl),l			;831e	75 	u 
l831fh:
	xor 05fh		;831f	ee 5f 	. _ 
l8321h:
	add a,b			;8321	80 	. 
	nop			;8322	00 	. 
	nop			;8323	00 	. 
	jp po,laedch		;8324	e2 dc ae 	. . . 
	ld (hl),a			;8327	77 	w 
	jp m,00001h		;8328	fa 01 00 	. . . 
	nop			;832b	00 	. 
	xor 0eeh		;832c	ee ee 	. . 
	xor 000h		;832e	ee 00 	. . 
	rst 8			;8330	cf 	. 
	rst 28h			;8331	ef 	. 
	rst 8			;8332	cf 	. 
	scf			;8333	37 	7 
	inc c			;8334	0c 	. 
	xor 0f0h		;8335	ee f0 	. . 
	halt			;8337	76 	v 
	ld b,070h		;8338	06 70 	. p 
	halt			;833a	76 	v 
	halt			;833b	76 	v 
	jr nz,l839eh		;833c	20 60 	  ` 
	and b			;833e	a0 	. 
sub_833fh:
	jr nz,l82e1h		;833f	20 a0 	  . 
	jr nz,l82e3h		;8341	20 a0 	  . 
	jr nz,$+7		;8343	20 05 	  . 
	inc b			;8345	04 	. 
	dec b			;8346	05 	. 
	inc b			;8347	04 	. 
	dec b			;8348	05 	. 
	ld b,002h		;8349	06 02 	. . 
	inc bc			;834b	03 	. 
	nop			;834c	00 	. 
	or a			;834d	b7 	. 
	scf			;834e	37 	7 
	add a,e			;834f	83 	. 
	jr c,$-115		;8350	38 8b 	8 . 
	pop de			;8352	d1 	. 
	ld h,b			;8353	60 	` 
	ex af,af'			;8354	08 	. 
	ld h,b			;8355	60 	` 
	ld h,b			;8356	60 	` 
	ld h,b			;8357	60 	` 
	nop			;8358	00 	. 
	or b			;8359	b0 	. 
	cp b			;835a	b8 	. 
	ld b,000h		;835b	06 00 	. . 
	nop			;835d	00 	. 
	nop			;835e	00 	. 
	nop			;835f	00 	. 
	nop			;8360	00 	. 
	nop			;8361	00 	. 
	dec e			;8362	1d 	. 
	dec sp			;8363	3b 	; 
	nop			;8364	00 	. 
	nop			;8365	00 	. 
	nop			;8366	00 	. 
	nop			;8367	00 	. 
l8368h:
	nop			;8368	00 	. 
	nop			;8369	00 	. 
	cp b			;836a	b8 	. 
	call c,00610h		;836b	dc 10 06 	. . . 
	ld b,006h		;836e	06 06 	. . 
	nop			;8370	00 	. 
	dec c			;8371	0d 	. 
	dec e			;8372	1d 	. 
	ld h,b			;8373	60 	` 
	nop			;8374	00 	. 
	defb 0edh;next byte illegal after ed		;8375	ed 	. 
	call pe,01cc1h		;8376	ec c1 1c 	. . . 
	pop de			;8379	d1 	. 
	adc a,e			;837a	8b 	. 
	ld b,0a0h		;837b	06 a0 	. . 
	jr nz,l831fh		;837d	20 a0 	  . 
	jr nz,l8321h		;837f	20 a0 	  . 
	ld h,b			;8381	60 	` 
	ld b,b			;8382	40 	@ 
	ret nz			;8383	c0 	. 
	ld bc,00101h		;8384	01 01 01 	. . . 
	nop			;8387	00 	. 
	nop			;8388	00 	. 
	nop			;8389	00 	. 
	nop			;838a	00 	. 
	nop			;838b	00 	. 
	xor l			;838c	ad 	. 
	ld b,0b0h		;838d	06 b0 	. . 
	sub 0d6h		;838f	d6 d6 	. . 
	add a,(hl)			;8391	86 	. 
	ret nc			;8392	d0 	. 
	sub 0d9h		;8393	d6 d9 	. . 
	rst 0			;8395	c7 	. 
	jr z,l8368h		;8396	28 d0 	( . 
	ret po			;8398	e0 	. 
	di			;8399	f3 	. 
	in h,(c)		;839a	ed 60 	. ` 
	rst 10h			;839c	d7 	. 
	nop			;839d	00 	. 
l839eh:
	nop			;839e	00 	. 
	nop			;839f	00 	. 
	ld a,e			;83a0	7b 	{ 
	cp l			;83a1	bd 	. 
	add a,b			;83a2	80 	. 
	ld e,l			;83a3	5d 	] 
	ex de,hl			;83a4	eb 	. 
	nop			;83a5	00 	. 
	nop			;83a6	00 	. 
	nop			;83a7	00 	. 
	sbc a,0bdh		;83a8	de bd 	. . 
	ld bc,09bbah		;83aa	01 ba 9b 	. . . 
	ex (sp),hl			;83ad	e3 	. 
	inc d			;83ae	14 	. 
	dec bc			;83af	0b 	. 
	rlca			;83b0	07 	. 
	rst 8			;83b1	cf 	. 
	or a			;83b2	b7 	. 
	ld b,0b5h		;83b3	06 b5 	. . 
	ld h,b			;83b5	60 	` 
	dec c			;83b6	0d 	. 
	ld l,e			;83b7	6b 	k 
	ld l,e			;83b8	6b 	k 
	ld h,c			;83b9	61 	a 
	dec bc			;83ba	0b 	. 
	ld l,e			;83bb	6b 	k 
	add a,b			;83bc	80 	. 
	add a,b			;83bd	80 	. 
	add a,b			;83be	80 	. 
	nop			;83bf	00 	. 
	nop			;83c0	00 	. 
	nop			;83c1	00 	. 
	nop			;83c2	00 	. 
	nop			;83c3	00 	. 
	nop			;83c4	00 	. 
	ld bc,00101h		;83c5	01 01 01 	. . . 
	ld bc,00101h		;83c8	01 01 01 	. . . 
	inc bc			;83cb	03 	. 
	sub 006h		;83cc	d6 06 	. . 
	xor b			;83ce	a8 	. 
	xor (hl)			;83cf	ae 	. 
	dec l			;83d0	2d 	- 
	add a,l			;83d1	85 	. 
	xor c			;83d2	a9 	. 
	xor h			;83d3	ac 	. 
	adc a,h			;83d4	8c 	. 
	rst 28h			;83d5	ef 	. 
	rst 20h			;83d6	e7 	. 
	ret pe			;83d7	e8 	. 
	ld l,0ceh		;83d8	2e ce 	. . 
	add a,0d8h		;83da	c6 d8 	. . 
	ex de,hl			;83dc	eb 	. 
	rla			;83dd	17 	. 
	ld h,b			;83de	60 	` 
	rst 30h			;83df	f7 	. 
	scf			;83e0	37 	7 
	ret nz			;83e1	c0 	. 
	rst 30h			;83e2	f7 	. 
	rst 30h			;83e3	f7 	. 
	rst 10h			;83e4	d7 	. 
	ret pe			;83e5	e8 	. 
	ld b,0efh		;83e6	06 ef 	. . 
	call pe,0ef03h		;83e8	ec 03 ef 	. . . 
	rst 28h			;83eb	ef 	. 
	ld sp,0e7f7h		;83ec	31 f7 e7 	1 . . 
	rla			;83ef	17 	. 
	ld (hl),h			;83f0	74 	t 
	ld (hl),e			;83f1	73 	s 
	ld h,e			;83f2	63 	c 
	dec de			;83f3	1b 	. 
	ld l,e			;83f4	6b 	k 
	ld h,b			;83f5	60 	` 
	dec d			;83f6	15 	. 
	ld (hl),l			;83f7	75 	u 
	or h			;83f8	b4 	. 
	and c			;83f9	a1 	. 
	sub l			;83fa	95 	. 
	dec (hl)			;83fb	35 	5 
	nop			;83fc	00 	. 
	add a,b			;83fd	80 	. 
	add a,b			;83fe	80 	. 
	add a,b			;83ff	80 	. 
	add a,b			;8400	80 	. 
	add a,b			;8401	80 	. 
	add a,b			;8402	80 	. 
	ret nz			;8403	c0 	. 
	inc bc			;8404	03 	. 
	inc bc			;8405	03 	. 
	inc bc			;8406	03 	. 
	ld (bc),a			;8407	02 	. 
	rlca			;8408	07 	. 
	inc b			;8409	04 	. 
	ld b,005h		;840a	06 05 	. . 
	xor l			;840c	ad 	. 
	ld l,l			;840d	6d 	m 
	ld e,l			;840e	5d 	] 
	ld e,l			;840f	5d 	] 
	dec de			;8410	1b 	. 
	res 6,b		;8411	cb b0 	. . 
	rla			;8413	17 	. 
	ld e,(hl)			;8414	5e 	^ 
	sbc a,(hl)			;8415	9e 	. 
	call sub_bcd1h		;8416	cd d1 bc 	. . . 
	cp l			;8419	bd 	. 
	dec a			;841a	3d 	= 
	ld b,b			;841b	40 	@ 
	rlca			;841c	07 	. 
	ret p			;841d	f0 	. 
	rst 30h			;841e	f7 	. 
	rst 28h			;841f	ef 	. 
	rrca			;8420	0f 	. 
	ret po			;8421	e0 	. 
	rst 28h			;8422	ef 	. 
	rst 28h			;8423	ef 	. 
	ret po			;8424	e0 	. 
	rrca			;8425	0f 	. 
	rst 28h			;8426	ef 	. 
	rst 30h			;8427	f7 	. 
	ret p			;8428	f0 	. 
	rlca			;8429	07 	. 
	rst 30h			;842a	f7 	. 
	rst 30h			;842b	f7 	. 
	ld a,d			;842c	7a 	z 
	ld a,c			;842d	79 	y 
	or e			;842e	b3 	. 
	adc a,e			;842f	8b 	. 
	dec a			;8430	3d 	= 
	cp l			;8431	bd 	. 
	cp h			;8432	bc 	. 
	ld (bc),a			;8433	02 	. 
	or l			;8434	b5 	. 
	or (hl)			;8435	b6 	. 
	cp d			;8436	ba 	. 
	cp d			;8437	ba 	. 
	ret c			;8438	d8 	. 
	out (00dh),a		;8439	d3 0d 	. . 
	ret pe			;843b	e8 	. 
	ret nz			;843c	c0 	. 
	ret nz			;843d	c0 	. 
	ret nz			;843e	c0 	. 
	ld b,b			;843f	40 	@ 
	ret po			;8440	e0 	. 
	jr nz,l84a3h		;8441	20 60 	  ` 
	and b			;8443	a0 	. 
	ld (bc),a			;8444	02 	. 
	ld bc,00000h		;8445	01 00 00 	. . . 
	nop			;8448	00 	. 
	ld bc,00702h		;8449	01 02 07 	. . . 
	and b			;844c	a0 	. 
	rla			;844d	17 	. 
	add a,c			;844e	81 	. 
	ld b,d			;844f	42 	B 
	ret c			;8450	d8 	. 
	sub a			;8451	97 	. 
	ld h,(hl)			;8452	66 	f 
	ld l,b			;8453	68 	h 
	ld a,e			;8454	7b 	{ 
	inc bc			;8455	03 	. 
	ld a,b			;8456	78 	x 
	dec e			;8457	1d 	. 
	and b			;8458	a0 	. 
	ld b,0f0h		;8459	06 f0 	. . 
	rst 28h			;845b	ef 	. 
	nop			;845c	00 	. 
	rst 28h			;845d	ef 	. 
	nop			;845e	00 	. 
	rst 28h			;845f	ef 	. 
	nop			;8460	00 	. 
	rst 30h			;8461	f7 	. 
	nop			;8462	00 	. 
	ld a,e			;8463	7b 	{ 
	nop			;8464	00 	. 
	rst 30h			;8465	f7 	. 
	nop			;8466	00 	. 
	rst 30h			;8467	f7 	. 
	nop			;8468	00 	. 
	rst 28h			;8469	ef 	. 
	nop			;846a	00 	. 
	sbc a,0deh		;846b	de de 	. . 
	ret nz			;846d	c0 	. 
	ld e,0b8h		;846e	1e b8 	. . 
	dec b			;8470	05 	. 
	ld h,b			;8471	60 	` 
	rrca			;8472	0f 	. 
	rst 30h			;8473	f7 	. 
	dec b			;8474	05 	. 
	ret pe			;8475	e8 	. 
	add a,c			;8476	81 	. 
	ld b,d			;8477	42 	B 
	dec de			;8478	1b 	. 
	jp (hl)			;8479	e9 	. 
	ld h,(hl)			;847a	66 	f 
	ld d,040h		;847b	16 40 	. @ 
	add a,b			;847d	80 	. 
	nop			;847e	00 	. 
	nop			;847f	00 	. 
	nop			;8480	00 	. 
	add a,b			;8481	80 	. 
	ld b,b			;8482	40 	@ 
	ret po			;8483	e0 	. 
	ld b,00eh		;8484	06 0e 	. . 
	dec c			;8486	0d 	. 
	inc de			;8487	13 	. 
	add hl,de			;8488	19 	. 
	ld a,(03636h)		;8489	3a 36 36 	: 6 6 
	sbc a,l			;848c	9d 	. 
	in a,(0a3h)		;848d	db a3 	. . 
	or b			;848f	b0 	. 
	ld (hl),a			;8490	77 	w 
	ld (hl),a			;8491	77 	w 
	cpl			;8492	2f 	/ 
	rst 0			;8493	c7 	. 
	ld c,0d0h		;8494	0e d0 	. . 
	cp l			;8496	bd 	. 
	cp l			;8497	bd 	. 
	dec e			;8498	1d 	. 
	ld h,b			;8499	60 	` 
	ld a,e			;849a	7b 	{ 
	ld a,e			;849b	7b 	{ 
	ei			;849c	fb 	. 
	nop			;849d	00 	. 
	rst 30h			;849e	f7 	. 
	rst 30h			;849f	f7 	. 
	rst 30h			;84a0	f7 	. 
	nop			;84a1	00 	. 
	rst 30h			;84a2	f7 	. 
l84a3h:
	rst 28h			;84a3	ef 	. 
	rst 18h			;84a4	df 	. 
	nop			;84a5	00 	. 
	rst 28h			;84a6	ef 	. 
	rst 28h			;84a7	ef 	. 
	rst 28h			;84a8	ef 	. 
	nop			;84a9	00 	. 
	rst 28h			;84aa	ef 	. 
	rst 30h			;84ab	f7 	. 
	ld (hl),b			;84ac	70 	p 
	dec bc			;84ad	0b 	. 
	cp l			;84ae	bd 	. 
	cp l			;84af	bd 	. 
	cp b			;84b0	b8 	. 
	ld b,0deh		;84b1	06 de 	. . 
	sbc a,0b9h		;84b3	de b9 	. . 
	in a,(0c5h)		;84b5	db c5 	. . 
	dec c			;84b7	0d 	. 
	xor 0eeh		;84b8	ee ee 	. . 
	call p,sub_60e3h		;84ba	f4 e3 60 	. . ` 
	ld (hl),b			;84bd	70 	p 
	or b			;84be	b0 	. 
	ret z			;84bf	c8 	. 
	sbc a,b			;84c0	98 	. 
	ld e,h			;84c1	5c 	\ 
	ld l,h			;84c2	6c 	l 
	ld l,h			;84c3	6c 	l 
	halt			;84c4	76 	v 
	ld l,l			;84c5	6d 	m 
	dec e			;84c6	1d 	. 
	rlca			;84c7	07 	. 
	ld bc,00000h		;84c8	01 00 00 	. . . 
	nop			;84cb	00 	. 
	ret pe			;84cc	e8 	. 
	sbc a,0deh		;84cd	de de 	. . 
	sbc a,0fdh		;84cf	de fd 	. . 
	dec e			;84d1	1d 	. 
	inc bc			;84d2	03 	. 
	nop			;84d3	00 	. 
	dec sp			;84d4	3b 	; 
	pop bc			;84d5	c1 	. 
	or 0f7h		;84d6	f6 f7 	. . 
	rst 30h			;84d8	f7 	. 
	rst 30h			;84d9	f7 	. 
	rst 30h			;84da	f7 	. 
	rrca			;84db	0f 	. 
	rst 28h			;84dc	ef 	. 
	rst 28h			;84dd	ef 	. 
	nop			;84de	00 	. 
	rst 28h			;84df	ef 	. 
	rst 28h			;84e0	ef 	. 
	rst 28h			;84e1	ef 	. 
	rst 28h			;84e2	ef 	. 
	rst 38h			;84e3	ff 	. 
	rst 30h			;84e4	f7 	. 
	rst 30h			;84e5	f7 	. 
	nop			;84e6	00 	. 
	rst 30h			;84e7	f7 	. 
	rst 30h			;84e8	f7 	. 
	rst 30h			;84e9	f7 	. 
	rst 30h			;84ea	f7 	. 
	rst 38h			;84eb	ff 	. 
	call c,06f83h		;84ec	dc 83 6f 	. . o 
	rst 28h			;84ef	ef 	. 
	rst 28h			;84f0	ef 	. 
	rst 28h			;84f1	ef 	. 
	rst 28h			;84f2	ef 	. 
	ret p			;84f3	f0 	. 
	rla			;84f4	17 	. 
	ld a,e			;84f5	7b 	{ 
	ld a,e			;84f6	7b 	{ 
	ld a,e			;84f7	7b 	{ 
	cp a			;84f8	bf 	. 
	cp b			;84f9	b8 	. 
	ret nz			;84fa	c0 	. 
	nop			;84fb	00 	. 
	ld l,(hl)			;84fc	6e 	n 
	or (hl)			;84fd	b6 	. 
	cp b			;84fe	b8 	. 
	ret po			;84ff	e0 	. 
	add a,b			;8500	80 	. 
	nop			;8501	00 	. 
	nop			;8502	00 	. 
	nop			;8503	00 	. 
	ex af,af'			;8504	08 	. 
	ld h,b			;8505	60 	` 
	ld h,b			;8506	60 	` 
	ld h,b			;8507	60 	` 
	nop			;8508	00 	. 
	or b			;8509	b0 	. 
	cp b			;850a	b8 	. 
	dec b			;850b	05 	. 
	nop			;850c	00 	. 
	nop			;850d	00 	. 
	nop			;850e	00 	. 
	nop			;850f	00 	. 
	nop			;8510	00 	. 
	nop			;8511	00 	. 
	dec de			;8512	1b 	. 
	ld (hl),a			;8513	77 	w 
	nop			;8514	00 	. 
	nop			;8515	00 	. 
	nop			;8516	00 	. 
	nop			;8517	00 	. 
	nop			;8518	00 	. 
	nop			;8519	00 	. 
	ret c			;851a	d8 	. 
	xor 010h		;851b	ee 10 	. . 
	ld b,006h		;851d	06 06 	. . 
	ld b,000h		;851f	06 00 	. . 
	dec c			;8521	0d 	. 
	dec e			;8522	1d 	. 
	and b			;8523	a0 	. 
	in a,(0c7h)		;8524	db c7 	. . 
	ld (0d4c4h),hl		;8526	22 c4 d4 	" . . 
	xor 0e6h		;8529	ee e6 	. . 
	ld h,a			;852b	67 	g 
	xor a			;852c	af 	. 
	ret p			;852d	f0 	. 
	nop			;852e	00 	. 
	nop			;852f	00 	. 
	nop			;8530	00 	. 
	nop			;8531	00 	. 
	nop			;8532	00 	. 
	nop			;8533	00 	. 
	push af			;8534	f5 	. 
	rrca			;8535	0f 	. 
	nop			;8536	00 	. 
	nop			;8537	00 	. 
	nop			;8538	00 	. 
	nop			;8539	00 	. 
	nop			;853a	00 	. 
	nop			;853b	00 	. 
	in a,(0e3h)		;853c	db e3 	. . 
	ld b,h			;853e	44 	D 
	inc hl			;853f	23 	# 
	dec hl			;8540	2b 	+ 
	ld (hl),a			;8541	77 	w 
	ld h,a			;8542	67 	g 
	and 08bh		;8543	e6 8b 	. . 
	defb 0edh;next byte illegal after ed		;8545	ed 	. 
	and 0e8h		;8546	e6 e8 	. . 
	ld l,0ceh		;8548	2e ce 	. . 
	add a,0d8h		;854a	c6 d8 	. . 
	add a,b			;854c	80 	. 
	ld h,b			;854d	60 	` 
	ret c			;854e	d8 	. 
	ld l,a			;854f	6f 	o 
	scf			;8550	37 	7 
	set 6,b		;8551	cb f0 	. . 
	rst 30h			;8553	f7 	. 
	ld bc,01b06h		;8554	01 06 1b 	. . . 
	or 0ech		;8557	f6 ec 	. . 
	out (00fh),a		;8559	d3 0f 	. . 
	rst 28h			;855b	ef 	. 
	pop de			;855c	d1 	. 
	or a			;855d	b7 	. 
	ld h,a			;855e	67 	g 
	rla			;855f	17 	. 
	ld (hl),h			;8560	74 	t 
	ld (hl),e			;8561	73 	s 
	ld h,e			;8562	63 	c 
	dec de			;8563	1b 	. 
	nop			;8564	00 	. 
	nop			;8565	00 	. 
	nop			;8566	00 	. 
	nop			;8567	00 	. 
	nop			;8568	00 	. 
	nop			;8569	00 	. 
	nop			;856a	00 	. 
	nop			;856b	00 	. 
	nop			;856c	00 	. 
	nop			;856d	00 	. 
	nop			;856e	00 	. 
	nop			;856f	00 	. 
	nop			;8570	00 	. 
	nop			;8571	00 	. 
	nop			;8572	00 	. 
	nop			;8573	00 	. 
	nop			;8574	00 	. 
	nop			;8575	00 	. 
	nop			;8576	00 	. 
	nop			;8577	00 	. 
	nop			;8578	00 	. 
	nop			;8579	00 	. 
	nop			;857a	00 	. 
	nop			;857b	00 	. 
	nop			;857c	00 	. 
	nop			;857d	00 	. 
	nop			;857e	00 	. 
	nop			;857f	00 	. 
	nop			;8580	00 	. 
	nop			;8581	00 	. 
	nop			;8582	00 	. 
	nop			;8583	00 	. 
l8584h:
	nop			;8584	00 	. 
	inc b			;8585	04 	. 
	nop			;8586	00 	. 
	nop			;8587	00 	. 
	nop			;8588	00 	. 
	inc b			;8589	04 	. 
	ld de,0e111h		;858a	11 11 e1 	. . . 
	pop hl			;858d	e1 	. 
	pop af			;858e	f1 	. 
	nop			;858f	00 	. 
	inc bc			;8590	03 	. 
	pop hl			;8591	e1 	. 
	pop hl			;8592	e1 	. 
	pop hl			;8593	e1 	. 
	nop			;8594	00 	. 
	inc bc			;8595	03 	. 
	rst 28h			;8596	ef 	. 
	rst 28h			;8597	ef 	. 
	nop			;8598	00 	. 
	inc b			;8599	04 	. 
	rst 28h			;859a	ef 	. 
	pop hl			;859b	e1 	. 
	nop			;859c	00 	. 
	inc bc			;859d	03 	. 
	rst 28h			;859e	ef 	. 
	rst 28h			;859f	ef 	. 
	rst 28h			;85a0	ef 	. 
	nop			;85a1	00 	. 
	add hl,bc			;85a2	09 	. 
	pop hl			;85a3	e1 	. 
	pop hl			;85a4	e1 	. 
	pop hl			;85a5	e1 	. 
	pop af			;85a6	f1 	. 
	nop			;85a7	00 	. 
	inc bc			;85a8	03 	. 
	pop hl			;85a9	e1 	. 
	pop hl			;85aa	e1 	. 
	pop hl			;85ab	e1 	. 
l85ach:
	pop af			;85ac	f1 	. 
	nop			;85ad	00 	. 
	inc bc			;85ae	03 	. 
	pop hl			;85af	e1 	. 
	pop hl			;85b0	e1 	. 
	pop hl			;85b1	e1 	. 
	pop af			;85b2	f1 	. 
	nop			;85b3	00 	. 
	inc bc			;85b4	03 	. 
	pop hl			;85b5	e1 	. 
	pop hl			;85b6	e1 	. 
	pop hl			;85b7	e1 	. 
	pop af			;85b8	f1 	. 
	nop			;85b9	00 	. 
	inc bc			;85ba	03 	. 
	pop hl			;85bb	e1 	. 
	pop hl			;85bc	e1 	. 
	pop hl			;85bd	e1 	. 
	pop af			;85be	f1 	. 
	nop			;85bf	00 	. 
	inc bc			;85c0	03 	. 
	pop hl			;85c1	e1 	. 
	pop hl			;85c2	e1 	. 
	pop hl			;85c3	e1 	. 
	pop af			;85c4	f1 	. 
	nop			;85c5	00 	. 
	ld h,0e1h		;85c6	26 e1 	& . 
	pop hl			;85c8	e1 	. 
	pop hl			;85c9	e1 	. 
	nop			;85ca	00 	. 
	inc bc			;85cb	03 	. 
	rst 28h			;85cc	ef 	. 
	rst 28h			;85cd	ef 	. 
	nop			;85ce	00 	. 
	ld (bc),a			;85cf	02 	. 
	rst 28h			;85d0	ef 	. 
	pop hl			;85d1	e1 	. 
	nop			;85d2	00 	. 
	inc bc			;85d3	03 	. 
	pop hl			;85d4	e1 	. 
	pop hl			;85d5	e1 	. 
	rst 28h			;85d6	ef 	. 
	pop hl			;85d7	e1 	. 
	nop			;85d8	00 	. 
	inc bc			;85d9	03 	. 
	rst 28h			;85da	ef 	. 
	rst 28h			;85db	ef 	. 
	pop hl			;85dc	e1 	. 
	pop hl			;85dd	e1 	. 
	pop hl			;85de	e1 	. 
	nop			;85df	00 	. 
	inc bc			;85e0	03 	. 
	rst 28h			;85e1	ef 	. 
	rst 28h			;85e2	ef 	. 
	nop			;85e3	00 	. 
	ld (bc),a			;85e4	02 	. 
	rst 28h			;85e5	ef 	. 
	pop hl			;85e6	e1 	. 
	nop			;85e7	00 	. 
	ex af,af'			;85e8	08 	. 
	pop af			;85e9	f1 	. 
	pop af			;85ea	f1 	. 
	nop			;85eb	00 	. 
	ld (bc),a			;85ec	02 	. 
	rst 28h			;85ed	ef 	. 
	pop hl			;85ee	e1 	. 
	pop hl			;85ef	e1 	. 
	pop hl			;85f0	e1 	. 
	nop			;85f1	00 	. 
	inc bc			;85f2	03 	. 
	rst 28h			;85f3	ef 	. 
	rst 28h			;85f4	ef 	. 
	rst 28h			;85f5	ef 	. 
	pop hl			;85f6	e1 	. 
	rst 28h			;85f7	ef 	. 
	nop			;85f8	00 	. 
	ld (bc),a			;85f9	02 	. 
	pop af			;85fa	f1 	. 
	pop af			;85fb	f1 	. 
	nop			;85fc	00 	. 
	inc b			;85fd	04 	. 
	nop			;85fe	00 	. 
	nop			;85ff	00 	. 
	nop			;8600	00 	. 
	ld (bc),a			;8601	02 	. 
	pop af			;8602	f1 	. 
	pop af			;8603	f1 	. 
	pop af			;8604	f1 	. 
	rst 28h			;8605	ef 	. 
	pop hl			;8606	e1 	. 
	rst 28h			;8607	ef 	. 
	nop			;8608	00 	. 
	inc c			;8609	0c 	. 
	pop af			;860a	f1 	. 
	pop af			;860b	f1 	. 
	nop			;860c	00 	. 
	ex af,af'			;860d	08 	. 
	sub c			;860e	91 	. 
	sub c			;860f	91 	. 
	nop			;8610	00 	. 
	ex af,af'			;8611	08 	. 
	ld (hl),c			;8612	71 	q 
	ld (hl),c			;8613	71 	q 
	nop			;8614	00 	. 
	inc b			;8615	04 	. 
	ld sp,00031h		;8616	31 31 00 	1 1 . 
	ex af,af'			;8619	08 	. 
	add a,c			;861a	81 	. 
	add a,c			;861b	81 	. 
	nop			;861c	00 	. 
	inc c			;861d	0c 	. 
	pop af			;861e	f1 	. 
	pop af			;861f	f1 	. 
	nop			;8620	00 	. 
	inc b			;8621	04 	. 
	add a,c			;8622	81 	. 
	add a,c			;8623	81 	. 
	nop			;8624	00 	. 
	jr z,$-13		;8625	28 f1 	( . 
	pop af			;8627	f1 	. 
	nop			;8628	00 	. 
	jr l85ach		;8629	18 81 	. . 
	add a,c			;862b	81 	. 
	nop			;862c	00 	. 
	ld l,h			;862d	6c 	l 
	pop af			;862e	f1 	. 
	pop af			;862f	f1 	. 
	nop			;8630	00 	. 
	inc b			;8631	04 	. 
	ld sp,00031h		;8632	31 31 00 	1 1 . 
	ex af,af'			;8635	08 	. 
	add a,c			;8636	81 	. 
	add a,c			;8637	81 	. 
	nop			;8638	00 	. 
	inc b			;8639	04 	. 
	ld d,c			;863a	51 	Q 
	ld d,c			;863b	51 	Q 
	nop			;863c	00 	. 
	inc b			;863d	04 	. 
	pop af			;863e	f1 	. 
	pop af			;863f	f1 	. 
	nop			;8640	00 	. 
	inc b			;8641	04 	. 
	ld d,c			;8642	51 	Q 
	ld d,c			;8643	51 	Q 
	nop			;8644	00 	. 
	ex af,af'			;8645	08 	. 
	pop de			;8646	d1 	. 
	pop de			;8647	d1 	. 
	nop			;8648	00 	. 
	ex af,af'			;8649	08 	. 
	or c			;864a	b1 	. 
	or c			;864b	b1 	. 
	nop			;864c	00 	. 
	inc bc			;864d	03 	. 
	rst 28h			;864e	ef 	. 
	rst 28h			;864f	ef 	. 
	pop af			;8650	f1 	. 
	pop af			;8651	f1 	. 
	pop af			;8652	f1 	. 
	nop			;8653	00 	. 
	inc bc			;8654	03 	. 
	pop hl			;8655	e1 	. 
	pop hl			;8656	e1 	. 
	pop hl			;8657	e1 	. 
	nop			;8658	00 	. 
	inc bc			;8659	03 	. 
	xor a			;865a	af 	. 
	xor a			;865b	af 	. 
	pop af			;865c	f1 	. 
	pop af			;865d	f1 	. 
	pop af			;865e	f1 	. 
	nop			;865f	00 	. 
	inc bc			;8660	03 	. 
	and c			;8661	a1 	. 
	and c			;8662	a1 	. 
	and c			;8663	a1 	. 
	pop hl			;8664	e1 	. 
	pop af			;8665	f1 	. 
	nop			;8666	00 	. 
	inc bc			;8667	03 	. 
	pop hl			;8668	e1 	. 
	pop hl			;8669	e1 	. 
	pop hl			;866a	e1 	. 
	pop af			;866b	f1 	. 
	nop			;866c	00 	. 
	inc bc			;866d	03 	. 
	pop hl			;866e	e1 	. 
	pop hl			;866f	e1 	. 
	nop			;8670	00 	. 
	inc c			;8671	0c 	. 
	pop af			;8672	f1 	. 
	pop af			;8673	f1 	. 
	nop			;8674	00 	. 
	adc a,b			;8675	88 	. 
	nop			;8676	00 	. 
	nop			;8677	00 	. 
	ld bc,l81b0h		;8678	01 b0 81 	. . . 
	add a,c			;867b	81 	. 
	nop			;867c	00 	. 
	ld de,00000h		;867d	11 00 00 	. . . 
	nop			;8680	00 	. 
	rst 38h			;8681	ff 	. 
	rst 38h			;8682	ff 	. 
	inc de			;8683	13 	. 
l8684h:
	nop			;8684	00 	. 
	nop			;8685	00 	. 
	nop			;8686	00 	. 
	nop			;8687	00 	. 
	nop			;8688	00 	. 
	nop			;8689	00 	. 
	nop			;868a	00 	. 
	nop			;868b	00 	. 
	nop			;868c	00 	. 
	nop			;868d	00 	. 
	nop			;868e	00 	. 
	nop			;868f	00 	. 
	nop			;8690	00 	. 
	nop			;8691	00 	. 
	nop			;8692	00 	. 
	nop			;8693	00 	. 
	nop			;8694	00 	. 
	nop			;8695	00 	. 
	nop			;8696	00 	. 
	nop			;8697	00 	. 
	nop			;8698	00 	. 
	nop			;8699	00 	. 
	nop			;869a	00 	. 
	nop			;869b	00 	. 
	nop			;869c	00 	. 
	nop			;869d	00 	. 
	nop			;869e	00 	. 
	nop			;869f	00 	. 
	nop			;86a0	00 	. 
	nop			;86a1	00 	. 
	nop			;86a2	00 	. 
	nop			;86a3	00 	. 
	rst 38h			;86a4	ff 	. 
	rst 38h			;86a5	ff 	. 
	rst 38h			;86a6	ff 	. 
	rst 38h			;86a7	ff 	. 
	rst 38h			;86a8	ff 	. 
	nop			;86a9	00 	. 
	rst 38h			;86aa	ff 	. 
	nop			;86ab	00 	. 
	nop			;86ac	00 	. 
	nop			;86ad	00 	. 
	nop			;86ae	00 	. 
	nop			;86af	00 	. 
	nop			;86b0	00 	. 
	nop			;86b1	00 	. 
	nop			;86b2	00 	. 
	nop			;86b3	00 	. 
	rst 38h			;86b4	ff 	. 
	rst 38h			;86b5	ff 	. 
	rst 38h			;86b6	ff 	. 
	rst 38h			;86b7	ff 	. 
	rst 38h			;86b8	ff 	. 
	nop			;86b9	00 	. 
	rst 38h			;86ba	ff 	. 
	nop			;86bb	00 	. 
	nop			;86bc	00 	. 
	nop			;86bd	00 	. 
	nop			;86be	00 	. 
	nop			;86bf	00 	. 
	nop			;86c0	00 	. 
	nop			;86c1	00 	. 
	nop			;86c2	00 	. 
	nop			;86c3	00 	. 
	nop			;86c4	00 	. 
	nop			;86c5	00 	. 
	nop			;86c6	00 	. 
	nop			;86c7	00 	. 
	nop			;86c8	00 	. 
	nop			;86c9	00 	. 
	nop			;86ca	00 	. 
	nop			;86cb	00 	. 
	nop			;86cc	00 	. 
	nop			;86cd	00 	. 
	nop			;86ce	00 	. 
	nop			;86cf	00 	. 
	nop			;86d0	00 	. 
	nop			;86d1	00 	. 
	nop			;86d2	00 	. 
	nop			;86d3	00 	. 
	ld e,03eh		;86d4	1e 3e 	. > 
	ld a,(hl)			;86d6	7e 	~ 
	cp (hl)			;86d7	be 	. 
	cp (hl)			;86d8	be 	. 
	ld a,(hl)			;86d9	7e 	~ 
	ld a,01eh		;86da	3e 1e 	> . 
	nop			;86dc	00 	. 
	nop			;86dd	00 	. 
	nop			;86de	00 	. 
	nop			;86df	00 	. 
	nop			;86e0	00 	. 
	nop			;86e1	00 	. 
	nop			;86e2	00 	. 
	nop			;86e3	00 	. 
	ld a,b			;86e4	78 	x 
	ld a,h			;86e5	7c 	| 
	ld a,(hl)			;86e6	7e 	~ 
	ld a,l			;86e7	7d 	} 
	ld a,l			;86e8	7d 	} 
	ld a,(hl)			;86e9	7e 	~ 
	ld a,h			;86ea	7c 	| 
	ld a,b			;86eb	78 	x 
	nop			;86ec	00 	. 
	nop			;86ed	00 	. 
	nop			;86ee	00 	. 
	nop			;86ef	00 	. 
	nop			;86f0	00 	. 
	nop			;86f1	00 	. 
	nop			;86f2	00 	. 
	nop			;86f3	00 	. 
	nop			;86f4	00 	. 
	nop			;86f5	00 	. 
	nop			;86f6	00 	. 
	nop			;86f7	00 	. 
	nop			;86f8	00 	. 
	nop			;86f9	00 	. 
	nop			;86fa	00 	. 
	nop			;86fb	00 	. 
	nop			;86fc	00 	. 
	nop			;86fd	00 	. 
	nop			;86fe	00 	. 
	nop			;86ff	00 	. 
	nop			;8700	00 	. 
	nop			;8701	00 	. 
	nop			;8702	00 	. 
	nop			;8703	00 	. 
	rst 38h			;8704	ff 	. 
	rst 38h			;8705	ff 	. 
	rst 38h			;8706	ff 	. 
	rst 38h			;8707	ff 	. 
	rlca			;8708	07 	. 
	nop			;8709	00 	. 
	rst 30h			;870a	f7 	. 
	nop			;870b	00 	. 
	nop			;870c	00 	. 
	nop			;870d	00 	. 
	nop			;870e	00 	. 
	nop			;870f	00 	. 
	nop			;8710	00 	. 
	nop			;8711	00 	. 
	nop			;8712	00 	. 
	nop			;8713	00 	. 
	rst 38h			;8714	ff 	. 
	rst 38h			;8715	ff 	. 
	rst 38h			;8716	ff 	. 
	rst 38h			;8717	ff 	. 
	ret po			;8718	e0 	. 
	nop			;8719	00 	. 
	rst 28h			;871a	ef 	. 
	nop			;871b	00 	. 
	nop			;871c	00 	. 
	nop			;871d	00 	. 
	nop			;871e	00 	. 
	nop			;871f	00 	. 
	nop			;8720	00 	. 
	nop			;8721	00 	. 
	nop			;8722	00 	. 
	nop			;8723	00 	. 
	nop			;8724	00 	. 
	nop			;8725	00 	. 
	nop			;8726	00 	. 
	nop			;8727	00 	. 
	nop			;8728	00 	. 
	nop			;8729	00 	. 
	nop			;872a	00 	. 
	nop			;872b	00 	. 
	nop			;872c	00 	. 
	nop			;872d	00 	. 
	nop			;872e	00 	. 
	nop			;872f	00 	. 
	nop			;8730	00 	. 
	nop			;8731	00 	. 
	nop			;8732	00 	. 
	nop			;8733	00 	. 
	ld c,016h		;8734	0e 16 	. . 
	ld l,07eh		;8736	2e 7e 	. ~ 
	ret p			;8738	f0 	. 
	and 04eh		;8739	e6 4e 	. N 
	ld e,000h		;873b	1e 00 	. . 
	nop			;873d	00 	. 
	nop			;873e	00 	. 
sub_873fh:
	nop			;873f	00 	. 
	nop			;8740	00 	. 
	nop			;8741	00 	. 
	nop			;8742	00 	. 
	nop			;8743	00 	. 
	ld (hl),b			;8744	70 	p 
	ld l,b			;8745	68 	h 
	ld (hl),h			;8746	74 	t 
	ld a,(hl)			;8747	7e 	~ 
	rrca			;8748	0f 	. 
	ld h,a			;8749	67 	g 
	ld (hl),d			;874a	72 	r 
	ld a,b			;874b	78 	x 
	nop			;874c	00 	. 
	nop			;874d	00 	. 
	nop			;874e	00 	. 
	nop			;874f	00 	. 
	nop			;8750	00 	. 
	nop			;8751	00 	. 
	nop			;8752	00 	. 
	nop			;8753	00 	. 
	nop			;8754	00 	. 
	nop			;8755	00 	. 
	nop			;8756	00 	. 
	nop			;8757	00 	. 
	nop			;8758	00 	. 
	nop			;8759	00 	. 
	nop			;875a	00 	. 
	nop			;875b	00 	. 
	nop			;875c	00 	. 
	nop			;875d	00 	. 
	nop			;875e	00 	. 
	nop			;875f	00 	. 
	nop			;8760	00 	. 
	nop			;8761	00 	. 
	nop			;8762	00 	. 
	nop			;8763	00 	. 
	nop			;8764	00 	. 
	nop			;8765	00 	. 
	nop			;8766	00 	. 
	nop			;8767	00 	. 
	ret m			;8768	f8 	. 
	ex af,af'			;8769	08 	. 
	ex af,af'			;876a	08 	. 
	nop			;876b	00 	. 
	nop			;876c	00 	. 
	nop			;876d	00 	. 
	nop			;876e	00 	. 
	nop			;876f	00 	. 
	nop			;8770	00 	. 
	nop			;8771	00 	. 
	nop			;8772	00 	. 
	nop			;8773	00 	. 
	nop			;8774	00 	. 
	nop			;8775	00 	. 
	nop			;8776	00 	. 
	nop			;8777	00 	. 
	rra			;8778	1f 	. 
	djnz l878bh		;8779	10 10 	. . 
	nop			;877b	00 	. 
	nop			;877c	00 	. 
	nop			;877d	00 	. 
	nop			;877e	00 	. 
	nop			;877f	00 	. 
	nop			;8780	00 	. 
	nop			;8781	00 	. 
	nop			;8782	00 	. 
	nop			;8783	00 	. 
	nop			;8784	00 	. 
	nop			;8785	00 	. 
	nop			;8786	00 	. 
	nop			;8787	00 	. 
	nop			;8788	00 	. 
	nop			;8789	00 	. 
	nop			;878a	00 	. 
l878bh:
	nop			;878b	00 	. 
	nop			;878c	00 	. 
	nop			;878d	00 	. 
	nop			;878e	00 	. 
	nop			;878f	00 	. 
	nop			;8790	00 	. 
	nop			;8791	00 	. 
	nop			;8792	00 	. 
	nop			;8793	00 	. 
	ld e,02eh		;8794	1e 2e 	. . 
	ld (hl),d			;8796	72 	r 
	adc a,h			;8797	8c 	. 
	or (hl)			;8798	b6 	. 
	ld a,b			;8799	78 	x 
	ld (hl),00eh		;879a	36 0e 	6 . 
	nop			;879c	00 	. 
	nop			;879d	00 	. 
	nop			;879e	00 	. 
	nop			;879f	00 	. 
	nop			;87a0	00 	. 
	nop			;87a1	00 	. 
	nop			;87a2	00 	. 
	nop			;87a3	00 	. 
	rst 30h			;87a4	f7 	. 
	rst 30h			;87a5	f7 	. 
	ex de,hl			;87a6	eb 	. 
	call c,000bdh		;87a7	dc bd 00 	. . . 
	ei			;87aa	fb 	. 
	nop			;87ab	00 	. 
	nop			;87ac	00 	. 
	nop			;87ad	00 	. 
	nop			;87ae	00 	. 
	nop			;87af	00 	. 
	nop			;87b0	00 	. 
	nop			;87b1	00 	. 
	nop			;87b2	00 	. 
	nop			;87b3	00 	. 
	rst 18h			;87b4	df 	. 
	jp (hl)			;87b5	e9 	. 
	or 077h		;87b6	f6 77 	. w 
	or a			;87b8	b7 	. 
	nop			;87b9	00 	. 
	rst 18h			;87ba	df 	. 
	nop			;87bb	00 	. 
	nop			;87bc	00 	. 
	nop			;87bd	00 	. 
	nop			;87be	00 	. 
	nop			;87bf	00 	. 
	nop			;87c0	00 	. 
	nop			;87c1	00 	. 
	nop			;87c2	00 	. 
	nop			;87c3	00 	. 
	ld a,b			;87c4	78 	x 
	inc c			;87c5	0c 	. 
	ld (hl),d			;87c6	72 	r 
	dec e			;87c7	1d 	. 
	ld l,l			;87c8	6d 	m 
	ld (hl),d			;87c9	72 	r 
	ld l,h			;87ca	6c 	l 
	ld e,b			;87cb	58 	X 
	nop			;87cc	00 	. 
	nop			;87cd	00 	. 
	nop			;87ce	00 	. 
	nop			;87cf	00 	. 
	nop			;87d0	00 	. 
	nop			;87d1	00 	. 
	nop			;87d2	00 	. 
	nop			;87d3	00 	. 
	nop			;87d4	00 	. 
	nop			;87d5	00 	. 
	nop			;87d6	00 	. 
	nop			;87d7	00 	. 
	nop			;87d8	00 	. 
	nop			;87d9	00 	. 
	nop			;87da	00 	. 
	nop			;87db	00 	. 
	nop			;87dc	00 	. 
	nop			;87dd	00 	. 
	nop			;87de	00 	. 
	nop			;87df	00 	. 
	nop			;87e0	00 	. 
	nop			;87e1	00 	. 
	nop			;87e2	00 	. 
	nop			;87e3	00 	. 
	nop			;87e4	00 	. 
	nop			;87e5	00 	. 
	nop			;87e6	00 	. 
	nop			;87e7	00 	. 
	nop			;87e8	00 	. 
	nop			;87e9	00 	. 
	nop			;87ea	00 	. 
	nop			;87eb	00 	. 
	nop			;87ec	00 	. 
	nop			;87ed	00 	. 
	nop			;87ee	00 	. 
	ld (bc),a			;87ef	02 	. 
	rlca			;87f0	07 	. 
	ld c,00ch		;87f1	0e 0c 	. . 
	nop			;87f3	00 	. 
	nop			;87f4	00 	. 
	nop			;87f5	00 	. 
	nop			;87f6	00 	. 
	nop			;87f7	00 	. 
	nop			;87f8	00 	. 
	nop			;87f9	00 	. 
	nop			;87fa	00 	. 
	nop			;87fb	00 	. 
	nop			;87fc	00 	. 
	nop			;87fd	00 	. 
	nop			;87fe	00 	. 
	rlca			;87ff	07 	. 
	rlca			;8800	07 	. 
	nop			;8801	00 	. 
	nop			;8802	00 	. 
	nop			;8803	00 	. 
	nop			;8804	00 	. 
	nop			;8805	00 	. 
	nop			;8806	00 	. 
	nop			;8807	00 	. 
	nop			;8808	00 	. 
	nop			;8809	00 	. 
	nop			;880a	00 	. 
	nop			;880b	00 	. 
	nop			;880c	00 	. 
	nop			;880d	00 	. 
	nop			;880e	00 	. 
	add a,b			;880f	80 	. 
	add a,(hl)			;8810	86 	. 
	inc bc			;8811	03 	. 
	ld bc,00000h		;8812	01 00 00 	. . . 
	nop			;8815	00 	. 
	nop			;8816	00 	. 
	nop			;8817	00 	. 
	nop			;8818	00 	. 
	nop			;8819	00 	. 
	nop			;881a	00 	. 
	nop			;881b	00 	. 
	nop			;881c	00 	. 
	nop			;881d	00 	. 
	nop			;881e	00 	. 
	nop			;881f	00 	. 
	nop			;8820	00 	. 
	nop			;8821	00 	. 
	nop			;8822	00 	. 
	nop			;8823	00 	. 
	nop			;8824	00 	. 
	nop			;8825	00 	. 
	nop			;8826	00 	. 
	nop			;8827	00 	. 
	nop			;8828	00 	. 
	nop			;8829	00 	. 
	nop			;882a	00 	. 
	nop			;882b	00 	. 
	nop			;882c	00 	. 
	nop			;882d	00 	. 
	nop			;882e	00 	. 
	ld bc,00103h		;882f	01 03 01 	. . . 
	nop			;8832	00 	. 
	nop			;8833	00 	. 
	nop			;8834	00 	. 
	nop			;8835	00 	. 
	nop			;8836	00 	. 
	nop			;8837	00 	. 
	nop			;8838	00 	. 
	nop			;8839	00 	. 
	nop			;883a	00 	. 
	nop			;883b	00 	. 
	nop			;883c	00 	. 
	nop			;883d	00 	. 
	nop			;883e	00 	. 
	nop			;883f	00 	. 
	add a,b			;8840	80 	. 
	ret nz			;8841	c0 	. 
	add a,b			;8842	80 	. 
	nop			;8843	00 	. 
	ld bc,00603h		;8844	01 03 06 	. . . 
	nop			;8847	00 	. 
	nop			;8848	00 	. 
	nop			;8849	00 	. 
	nop			;884a	00 	. 
	ld bc,00103h		;884b	01 03 01 	. . . 
	nop			;884e	00 	. 
	nop			;884f	00 	. 
	nop			;8850	00 	. 
	nop			;8851	00 	. 
	nop			;8852	00 	. 
	nop			;8853	00 	. 
	add a,b			;8854	80 	. 
	nop			;8855	00 	. 
	nop			;8856	00 	. 
	nop			;8857	00 	. 
	nop			;8858	00 	. 
	nop			;8859	00 	. 
	nop			;885a	00 	. 
	nop			;885b	00 	. 
	add a,b			;885c	80 	. 
	nop			;885d	00 	. 
	nop			;885e	00 	. 
	nop			;885f	00 	. 
	nop			;8860	00 	. 
	nop			;8861	00 	. 
	nop			;8862	00 	. 
	nop			;8863	00 	. 
	nop			;8864	00 	. 
	nop			;8865	00 	. 
	ld bc,00103h		;8866	01 03 01 	. . . 
	jr l8877h		;8869	18 0c 	. . 
	inc b			;886b	04 	. 
	nop			;886c	00 	. 
	nop			;886d	00 	. 
	nop			;886e	00 	. 
	nop			;886f	00 	. 
	nop			;8870	00 	. 
	nop			;8871	00 	. 
	nop			;8872	00 	. 
	nop			;8873	00 	. 
	nop			;8874	00 	. 
	nop			;8875	00 	. 
	add a,b			;8876	80 	. 
l8877h:
	ret nz			;8877	c0 	. 
	add a,b			;8878	80 	. 
	nop			;8879	00 	. 
	nop			;887a	00 	. 
	nop			;887b	00 	. 
	nop			;887c	00 	. 
	jr nz,l88efh		;887d	20 70 	  p 
	ld (hl),b			;887f	70 	p 
	jr nz,l8882h		;8880	20 00 	  . 
l8882h:
	nop			;8882	00 	. 
	nop			;8883	00 	. 
	nop			;8884	00 	. 
	nop			;8885	00 	. 
	ld bc,00303h		;8886	01 03 03 	. . . 
	ld bc,02000h		;8889	01 00 20 	. .   
	ld (hl),b			;888c	70 	p 
	ld (hl),c			;888d	71 	q 
	ld hl,00000h		;888e	21 00 00 	! . . 
	nop			;8891	00 	. 
	nop			;8892	00 	. 
	nop			;8893	00 	. 
	nop			;8894	00 	. 
	nop			;8895	00 	. 
	nop			;8896	00 	. 
	nop			;8897	00 	. 
	nop			;8898	00 	. 
	nop			;8899	00 	. 
	nop			;889a	00 	. 
	nop			;889b	00 	. 
	nop			;889c	00 	. 
	nop			;889d	00 	. 
	add a,b			;889e	80 	. 
	add a,b			;889f	80 	. 
	nop			;88a0	00 	. 
	nop			;88a1	00 	. 
	nop			;88a2	00 	. 
	nop			;88a3	00 	. 
	nop			;88a4	00 	. 
	nop			;88a5	00 	. 
	nop			;88a6	00 	. 
	ld bc,00001h		;88a7	01 01 00 	. . . 
	nop			;88aa	00 	. 
	nop			;88ab	00 	. 
	inc b			;88ac	04 	. 
	inc c			;88ad	0c 	. 
	jr l88b1h		;88ae	18 01 	. . 
	nop			;88b0	00 	. 
l88b1h:
	nop			;88b1	00 	. 
	nop			;88b2	00 	. 
	nop			;88b3	00 	. 
	nop			;88b4	00 	. 
	nop			;88b5	00 	. 
	nop			;88b6	00 	. 
	ret nz			;88b7	c0 	. 
	ret nz			;88b8	c0 	. 
	nop			;88b9	00 	. 
	nop			;88ba	00 	. 
	nop			;88bb	00 	. 
	nop			;88bc	00 	. 
	ld b,b			;88bd	40 	@ 
	ret nz			;88be	c0 	. 
	add a,b			;88bf	80 	. 
	nop			;88c0	00 	. 
	nop			;88c1	00 	. 
	nop			;88c2	00 	. 
	nop			;88c3	00 	. 
	nop			;88c4	00 	. 
	nop			;88c5	00 	. 
	nop			;88c6	00 	. 
	nop			;88c7	00 	. 
	nop			;88c8	00 	. 
	nop			;88c9	00 	. 
	nop			;88ca	00 	. 
	nop			;88cb	00 	. 
	nop			;88cc	00 	. 
	jr l88ffh		;88cd	18 30 	. 0 
	jr nz,l88d1h		;88cf	20 00 	  . 
l88d1h:
	nop			;88d1	00 	. 
	nop			;88d2	00 	. 
	nop			;88d3	00 	. 
	nop			;88d4	00 	. 
	nop			;88d5	00 	. 
	nop			;88d6	00 	. 
	nop			;88d7	00 	. 
	nop			;88d8	00 	. 
	nop			;88d9	00 	. 
	nop			;88da	00 	. 
	nop			;88db	00 	. 
	rlca			;88dc	07 	. 
	nop			;88dd	00 	. 
	nop			;88de	00 	. 
	nop			;88df	00 	. 
	nop			;88e0	00 	. 
	nop			;88e1	00 	. 
	nop			;88e2	00 	. 
	nop			;88e3	00 	. 
	nop			;88e4	00 	. 
	nop			;88e5	00 	. 
	nop			;88e6	00 	. 
	nop			;88e7	00 	. 
	nop			;88e8	00 	. 
	nop			;88e9	00 	. 
	nop			;88ea	00 	. 
	nop			;88eb	00 	. 
	nop			;88ec	00 	. 
	nop			;88ed	00 	. 
	nop			;88ee	00 	. 
l88efh:
	nop			;88ef	00 	. 
	nop			;88f0	00 	. 
	nop			;88f1	00 	. 
	nop			;88f2	00 	. 
	nop			;88f3	00 	. 
	nop			;88f4	00 	. 
	nop			;88f5	00 	. 
	nop			;88f6	00 	. 
	nop			;88f7	00 	. 
	nop			;88f8	00 	. 
	nop			;88f9	00 	. 
	nop			;88fa	00 	. 
	nop			;88fb	00 	. 
	nop			;88fc	00 	. 
	jr nz,l890fh		;88fd	20 10 	  . 
l88ffh:
	nop			;88ff	00 	. 
	nop			;8900	00 	. 
	nop			;8901	00 	. 
	nop			;8902	00 	. 
	nop			;8903	00 	. 
	nop			;8904	00 	. 
	nop			;8905	00 	. 
	nop			;8906	00 	. 
	nop			;8907	00 	. 
	nop			;8908	00 	. 
	nop			;8909	00 	. 
	nop			;890a	00 	. 
	nop			;890b	00 	. 
	nop			;890c	00 	. 
	nop			;890d	00 	. 
	nop			;890e	00 	. 
l890fh:
	nop			;890f	00 	. 
	nop			;8910	00 	. 
	nop			;8911	00 	. 
	nop			;8912	00 	. 
	nop			;8913	00 	. 
	nop			;8914	00 	. 
	nop			;8915	00 	. 
	nop			;8916	00 	. 
	nop			;8917	00 	. 
	nop			;8918	00 	. 
	nop			;8919	00 	. 
	nop			;891a	00 	. 
	nop			;891b	00 	. 
	nop			;891c	00 	. 
	ex af,af'			;891d	08 	. 
	inc e			;891e	1c 	. 
	ex af,af'			;891f	08 	. 
	nop			;8920	00 	. 
	nop			;8921	00 	. 
	nop			;8922	00 	. 
	nop			;8923	00 	. 
	nop			;8924	00 	. 
	nop			;8925	00 	. 
	nop			;8926	00 	. 
	jr l8941h		;8927	18 18 	. . 
	nop			;8929	00 	. 
	nop			;892a	00 	. 
	nop			;892b	00 	. 
	nop			;892c	00 	. 
	nop			;892d	00 	. 
	nop			;892e	00 	. 
	ld bc,00000h		;892f	01 00 00 	. . . 
	nop			;8932	00 	. 
	nop			;8933	00 	. 
	nop			;8934	00 	. 
	nop			;8935	00 	. 
	nop			;8936	00 	. 
	nop			;8937	00 	. 
	nop			;8938	00 	. 
	nop			;8939	00 	. 
	nop			;893a	00 	. 
	nop			;893b	00 	. 
	nop			;893c	00 	. 
	nop			;893d	00 	. 
	nop			;893e	00 	. 
	add a,b			;893f	80 	. 
	ret nz			;8940	c0 	. 
l8941h:
	nop			;8941	00 	. 
	nop			;8942	00 	. 
	nop			;8943	00 	. 
	nop			;8944	00 	. 
	nop			;8945	00 	. 
	nop			;8946	00 	. 
	nop			;8947	00 	. 
	add a,b			;8948	80 	. 
	nop			;8949	00 	. 
	nop			;894a	00 	. 
	nop			;894b	00 	. 
	nop			;894c	00 	. 
	nop			;894d	00 	. 
	nop			;894e	00 	. 
	nop			;894f	00 	. 
	nop			;8950	00 	. 
	nop			;8951	00 	. 
	nop			;8952	00 	. 
	nop			;8953	00 	. 
	nop			;8954	00 	. 
	nop			;8955	00 	. 
	nop			;8956	00 	. 
	nop			;8957	00 	. 
	nop			;8958	00 	. 
	nop			;8959	00 	. 
	nop			;895a	00 	. 
	nop			;895b	00 	. 
	nop			;895c	00 	. 
	nop			;895d	00 	. 
	nop			;895e	00 	. 
	nop			;895f	00 	. 
	nop			;8960	00 	. 
	add a,b			;8961	80 	. 
	nop			;8962	00 	. 
	nop			;8963	00 	. 
	nop			;8964	00 	. 
	nop			;8965	00 	. 
	nop			;8966	00 	. 
	nop			;8967	00 	. 
	nop			;8968	00 	. 
	nop			;8969	00 	. 
	nop			;896a	00 	. 
	nop			;896b	00 	. 
	nop			;896c	00 	. 
	nop			;896d	00 	. 
	nop			;896e	00 	. 
	nop			;896f	00 	. 
	nop			;8970	00 	. 
	nop			;8971	00 	. 
	jr nc,l89a4h		;8972	30 30 	0 0 
	nop			;8974	00 	. 
	nop			;8975	00 	. 
	nop			;8976	00 	. 
	nop			;8977	00 	. 
	nop			;8978	00 	. 
	nop			;8979	00 	. 
	inc bc			;897a	03 	. 
	inc bc			;897b	03 	. 
	nop			;897c	00 	. 
	nop			;897d	00 	. 
	nop			;897e	00 	. 
	nop			;897f	00 	. 
	nop			;8980	00 	. 
	nop			;8981	00 	. 
	jr nz,l8984h		;8982	20 00 	  . 
l8984h:
	nop			;8984	00 	. 
	nop			;8985	00 	. 
	nop			;8986	00 	. 
	nop			;8987	00 	. 
	nop			;8988	00 	. 
	nop			;8989	00 	. 
	nop			;898a	00 	. 
	nop			;898b	00 	. 
	nop			;898c	00 	. 
	nop			;898d	00 	. 
	nop			;898e	00 	. 
	nop			;898f	00 	. 
	nop			;8990	00 	. 
	nop			;8991	00 	. 
	nop			;8992	00 	. 
	nop			;8993	00 	. 
	nop			;8994	00 	. 
	nop			;8995	00 	. 
	nop			;8996	00 	. 
	nop			;8997	00 	. 
	nop			;8998	00 	. 
	ld b,006h		;8999	06 06 	. . 
	nop			;899b	00 	. 
	nop			;899c	00 	. 
	nop			;899d	00 	. 
	nop			;899e	00 	. 
	nop			;899f	00 	. 
	nop			;89a0	00 	. 
	ld b,b			;89a1	40 	@ 
	ret nz			;89a2	c0 	. 
	add a,b			;89a3	80 	. 
l89a4h:
	ld a,(hl)			;89a4	7e 	~ 
	ld h,e			;89a5	63 	c 
	ld h,e			;89a6	63 	c 
	ld h,a			;89a7	67 	g 
	ld a,h			;89a8	7c 	| 
	ld l,(hl)			;89a9	6e 	n 
	ld h,a			;89aa	67 	g 
	nop			;89ab	00 	. 
	nop			;89ac	00 	. 
	nop			;89ad	00 	. 
	nop			;89ae	00 	. 
	nop			;89af	00 	. 
	nop			;89b0	00 	. 
	nop			;89b1	00 	. 
	nop			;89b2	00 	. 
	nop			;89b3	00 	. 
	ld a,a			;89b4	7f 	 
	ld h,b			;89b5	60 	` 
	ld h,b			;89b6	60 	` 
	ld a,(hl)			;89b7	7e 	~ 
	ld h,b			;89b8	60 	` 
	ld h,b			;89b9	60 	` 
	ld a,a			;89ba	7f 	 
	nop			;89bb	00 	. 
	nop			;89bc	00 	. 
	nop			;89bd	00 	. 
	nop			;89be	00 	. 
	nop			;89bf	00 	. 
	nop			;89c0	00 	. 
	nop			;89c1	00 	. 
	nop			;89c2	00 	. 
	nop			;89c3	00 	. 
	inc e			;89c4	1c 	. 
	ld (hl),063h		;89c5	36 63 	6 c 
	ld h,e			;89c7	63 	c 
	ld a,a			;89c8	7f 	 
	ld h,e			;89c9	63 	c 
	ld h,e			;89ca	63 	c 
	nop			;89cb	00 	. 
	nop			;89cc	00 	. 
	nop			;89cd	00 	. 
	nop			;89ce	00 	. 
	nop			;89cf	00 	. 
	nop			;89d0	00 	. 
	nop			;89d1	00 	. 
	nop			;89d2	00 	. 
	nop			;89d3	00 	. 
	ld a,h			;89d4	7c 	| 
	ld h,(hl)			;89d5	66 	f 
	ld h,e			;89d6	63 	c 
	ld h,e			;89d7	63 	c 
	ld h,e			;89d8	63 	c 
	ld h,(hl)			;89d9	66 	f 
	ld a,h			;89da	7c 	| 
	nop			;89db	00 	. 
	nop			;89dc	00 	. 
	nop			;89dd	00 	. 
	nop			;89de	00 	. 
	nop			;89df	00 	. 
	nop			;89e0	00 	. 
	nop			;89e1	00 	. 
	nop			;89e2	00 	. 
	nop			;89e3	00 	. 
	inc sp			;89e4	33 	3 
	inc sp			;89e5	33 	3 
	inc sp			;89e6	33 	3 
	ld e,00ch		;89e7	1e 0c 	. . 
	inc c			;89e9	0c 	. 
	inc c			;89ea	0c 	. 
	nop			;89eb	00 	. 
	nop			;89ec	00 	. 
	nop			;89ed	00 	. 
	nop			;89ee	00 	. 
	nop			;89ef	00 	. 
	nop			;89f0	00 	. 
	nop			;89f1	00 	. 
	nop			;89f2	00 	. 
	nop			;89f3	00 	. 
	nop			;89f4	00 	. 
	nop			;89f5	00 	. 
	nop			;89f6	00 	. 
	nop			;89f7	00 	. 
	nop			;89f8	00 	. 
	nop			;89f9	00 	. 
	nop			;89fa	00 	. 
	nop			;89fb	00 	. 
	nop			;89fc	00 	. 
	nop			;89fd	00 	. 
	nop			;89fe	00 	. 
	nop			;89ff	00 	. 
	nop			;8a00	00 	. 
	nop			;8a01	00 	. 
	nop			;8a02	00 	. 
	nop			;8a03	00 	. 
	rra			;8a04	1f 	. 
	jr nc,l8a67h		;8a05	30 60 	0 ` 
	ld h,a			;8a07	67 	g 
	ld h,e			;8a08	63 	c 
	inc sp			;8a09	33 	3 
	rra			;8a0a	1f 	. 
	nop			;8a0b	00 	. 
	nop			;8a0c	00 	. 
	nop			;8a0d	00 	. 
	nop			;8a0e	00 	. 
	nop			;8a0f	00 	. 
	nop			;8a10	00 	. 
	nop			;8a11	00 	. 
	nop			;8a12	00 	. 
	nop			;8a13	00 	. 
	inc e			;8a14	1c 	. 
	ld (hl),063h		;8a15	36 63 	6 c 
	ld h,e			;8a17	63 	c 
	ld a,a			;8a18	7f 	 
	ld h,e			;8a19	63 	c 
	ld h,e			;8a1a	63 	c 
	nop			;8a1b	00 	. 
	nop			;8a1c	00 	. 
	nop			;8a1d	00 	. 
	nop			;8a1e	00 	. 
	nop			;8a1f	00 	. 
	nop			;8a20	00 	. 
	nop			;8a21	00 	. 
	nop			;8a22	00 	. 
	nop			;8a23	00 	. 
	ld h,e			;8a24	63 	c 
	ld (hl),a			;8a25	77 	w 
	ld a,a			;8a26	7f 	 
	ld a,a			;8a27	7f 	 
	ld l,e			;8a28	6b 	k 
	ld h,e			;8a29	63 	c 
	ld h,e			;8a2a	63 	c 
	nop			;8a2b	00 	. 
	nop			;8a2c	00 	. 
	nop			;8a2d	00 	. 
	nop			;8a2e	00 	. 
	nop			;8a2f	00 	. 
	nop			;8a30	00 	. 
	nop			;8a31	00 	. 
	nop			;8a32	00 	. 
	nop			;8a33	00 	. 
	ld a,a			;8a34	7f 	 
	ld h,b			;8a35	60 	` 
	ld h,b			;8a36	60 	` 
	ld a,(hl)			;8a37	7e 	~ 
	ld h,b			;8a38	60 	` 
	ld h,b			;8a39	60 	` 
	ld a,a			;8a3a	7f 	 
	nop			;8a3b	00 	. 
	nop			;8a3c	00 	. 
	nop			;8a3d	00 	. 
	nop			;8a3e	00 	. 
	nop			;8a3f	00 	. 
	nop			;8a40	00 	. 
	nop			;8a41	00 	. 
	nop			;8a42	00 	. 
	nop			;8a43	00 	. 
	ld a,063h		;8a44	3e 63 	> c 
	ld h,e			;8a46	63 	c 
	ld h,e			;8a47	63 	c 
	ld h,e			;8a48	63 	c 
	ld h,e			;8a49	63 	c 
	ld a,000h		;8a4a	3e 00 	> . 
	nop			;8a4c	00 	. 
	nop			;8a4d	00 	. 
	nop			;8a4e	00 	. 
	nop			;8a4f	00 	. 
	nop			;8a50	00 	. 
	nop			;8a51	00 	. 
	nop			;8a52	00 	. 
	nop			;8a53	00 	. 
	ld h,e			;8a54	63 	c 
	ld h,e			;8a55	63 	c 
	ld h,e			;8a56	63 	c 
	ld (hl),a			;8a57	77 	w 
	ld a,01ch		;8a58	3e 1c 	> . 
	ex af,af'			;8a5a	08 	. 
	nop			;8a5b	00 	. 
	nop			;8a5c	00 	. 
	nop			;8a5d	00 	. 
	nop			;8a5e	00 	. 
	nop			;8a5f	00 	. 
	nop			;8a60	00 	. 
	nop			;8a61	00 	. 
	nop			;8a62	00 	. 
	nop			;8a63	00 	. 
	ld a,a			;8a64	7f 	 
	ld h,b			;8a65	60 	` 
	ld h,b			;8a66	60 	` 
l8a67h:
	ld a,(hl)			;8a67	7e 	~ 
	ld h,b			;8a68	60 	` 
	ld h,b			;8a69	60 	` 
	ld a,a			;8a6a	7f 	 
	nop			;8a6b	00 	. 
	nop			;8a6c	00 	. 
	nop			;8a6d	00 	. 
	nop			;8a6e	00 	. 
	nop			;8a6f	00 	. 
	nop			;8a70	00 	. 
	nop			;8a71	00 	. 
	nop			;8a72	00 	. 
	nop			;8a73	00 	. 
	ld a,(hl)			;8a74	7e 	~ 
	ld h,e			;8a75	63 	c 
	ld h,e			;8a76	63 	c 
	ld h,a			;8a77	67 	g 
	ld a,h			;8a78	7c 	| 
	ld l,(hl)			;8a79	6e 	n 
	ld h,a			;8a7a	67 	g 
	nop			;8a7b	00 	. 
	nop			;8a7c	00 	. 
	nop			;8a7d	00 	. 
	nop			;8a7e	00 	. 
	nop			;8a7f	00 	. 
	nop			;8a80	00 	. 
	nop			;8a81	00 	. 
	nop			;8a82	00 	. 
	nop			;8a83	00 	. 
	ld (hl),b			;8a84	70 	p 
	ret m			;8a85	f8 	. 
	ret m			;8a86	f8 	. 
	ld (hl),b			;8a87	70 	p 
	nop			;8a88	00 	. 
	nop			;8a89	00 	. 
	nop			;8a8a	00 	. 
	nop			;8a8b	00 	. 
	nop			;8a8c	00 	. 
	nop			;8a8d	00 	. 
	nop			;8a8e	00 	. 
	nop			;8a8f	00 	. 
	nop			;8a90	00 	. 
	nop			;8a91	00 	. 
	nop			;8a92	00 	. 
	nop			;8a93	00 	. 
	nop			;8a94	00 	. 
	nop			;8a95	00 	. 
	nop			;8a96	00 	. 
	nop			;8a97	00 	. 
	nop			;8a98	00 	. 
	nop			;8a99	00 	. 
	nop			;8a9a	00 	. 
	nop			;8a9b	00 	. 
	nop			;8a9c	00 	. 
	nop			;8a9d	00 	. 
	nop			;8a9e	00 	. 
	nop			;8a9f	00 	. 
	nop			;8aa0	00 	. 
	nop			;8aa1	00 	. 
	nop			;8aa2	00 	. 
	nop			;8aa3	00 	. 
	ld b,b			;8aa4	40 	@ 
	ret po			;8aa5	e0 	. 
	ret po			;8aa6	e0 	. 
	ret po			;8aa7	e0 	. 
	ret po			;8aa8	e0 	. 
	ret po			;8aa9	e0 	. 
	ret po			;8aaa	e0 	. 
	ld b,b			;8aab	40 	@ 
	nop			;8aac	00 	. 
	nop			;8aad	00 	. 
	nop			;8aae	00 	. 
	nop			;8aaf	00 	. 
	nop			;8ab0	00 	. 
	nop			;8ab1	00 	. 
	nop			;8ab2	00 	. 
	nop			;8ab3	00 	. 
	ld (bc),a			;8ab4	02 	. 
	rlca			;8ab5	07 	. 
	rlca			;8ab6	07 	. 
	rlca			;8ab7	07 	. 
	rlca			;8ab8	07 	. 
	rlca			;8ab9	07 	. 
	rlca			;8aba	07 	. 
	ld (bc),a			;8abb	02 	. 
	nop			;8abc	00 	. 
	nop			;8abd	00 	. 
	nop			;8abe	00 	. 
	nop			;8abf	00 	. 
	nop			;8ac0	00 	. 
	nop			;8ac1	00 	. 
	nop			;8ac2	00 	. 
	nop			;8ac3	00 	. 
	ld a,a			;8ac4	7f 	 
	rst 38h			;8ac5	ff 	. 
	rst 38h			;8ac6	ff 	. 
	rst 38h			;8ac7	ff 	. 
	rst 38h			;8ac8	ff 	. 
	rst 38h			;8ac9	ff 	. 
	ld a,a			;8aca	7f 	 
	nop			;8acb	00 	. 
	nop			;8acc	00 	. 
	nop			;8acd	00 	. 
	nop			;8ace	00 	. 
	nop			;8acf	00 	. 
	nop			;8ad0	00 	. 
	nop			;8ad1	00 	. 
	nop			;8ad2	00 	. 
	nop			;8ad3	00 	. 
	cp 0ffh		;8ad4	fe ff 	. . 
	rst 38h			;8ad6	ff 	. 
	rst 38h			;8ad7	ff 	. 
	rst 38h			;8ad8	ff 	. 
	rst 38h			;8ad9	ff 	. 
	cp 000h		;8ada	fe 00 	. . 
	nop			;8adc	00 	. 
	nop			;8add	00 	. 
	nop			;8ade	00 	. 
	nop			;8adf	00 	. 
	nop			;8ae0	00 	. 
	nop			;8ae1	00 	. 
	nop			;8ae2	00 	. 
	nop			;8ae3	00 	. 
	nop			;8ae4	00 	. 
	jr l8b23h		;8ae5	18 3c 	. < 
	ld a,(hl)			;8ae7	7e 	~ 
	rst 38h			;8ae8	ff 	. 
	ld a,(hl)			;8ae9	7e 	~ 
	inc a			;8aea	3c 	< 
	jr l8aedh		;8aeb	18 00 	. . 
l8aedh:
	nop			;8aed	00 	. 
	nop			;8aee	00 	. 
	nop			;8aef	00 	. 
	nop			;8af0	00 	. 
	nop			;8af1	00 	. 
	nop			;8af2	00 	. 
	nop			;8af3	00 	. 
	nop			;8af4	00 	. 
	nop			;8af5	00 	. 
	nop			;8af6	00 	. 
	nop			;8af7	00 	. 
	nop			;8af8	00 	. 
	nop			;8af9	00 	. 
	nop			;8afa	00 	. 
	nop			;8afb	00 	. 
	nop			;8afc	00 	. 
	nop			;8afd	00 	. 
	nop			;8afe	00 	. 
	nop			;8aff	00 	. 
	nop			;8b00	00 	. 
l8b01h:
	nop			;8b01	00 	. 
	nop			;8b02	00 	. 
	nop			;8b03	00 	. 
	nop			;8b04	00 	. 
	nop			;8b05	00 	. 
	rlca			;8b06	07 	. 
	add hl,de			;8b07	19 	. 
	jr z,l8b75h		;8b08	28 6b 	( k 
	ld a,a			;8b0a	7f 	 
	ld l,e			;8b0b	6b 	k 
	ld h,(hl)			;8b0c	66 	f 
	scf			;8b0d	37 	7 
	inc a			;8b0e	3c 	< 
	ld e,007h		;8b0f	1e 07 	. . 
	nop			;8b11	00 	. 
	nop			;8b12	00 	. 
	nop			;8b13	00 	. 
	nop			;8b14	00 	. 
	nop			;8b15	00 	. 
	ret po			;8b16	e0 	. 
	cp h			;8b17	bc 	. 
	call po,0fe36h		;8b18	e4 36 fe 	. 6 . 
	sbc a,0b6h		;8b1b	de b6 	. . 
	and 07ch		;8b1d	e6 7c 	. | 
	jr c,l8b01h		;8b1f	38 e0 	8 . 
	nop			;8b21	00 	. 
	nop			;8b22	00 	. 
l8b23h:
	nop			;8b23	00 	. 
	nop			;8b24	00 	. 
	ret nz			;8b25	c0 	. 
	ld (hl),c			;8b26	71 	q 
	ld e,a			;8b27	5f 	_ 
	jr nz,l8b5dh		;8b28	20 33 	  3 
	dec (hl)			;8b2a	35 	5 
	ld h,a			;8b2b	67 	g 
	pop bc			;8b2c	c1 	. 
	ld h,(hl)			;8b2d	66 	f 
	dec (hl)			;8b2e	35 	5 
	jr nz,l8b5fh		;8b2f	20 2e 	  . 
	ld a,e			;8b31	7b 	{ 
	ld b,c			;8b32	41 	A 
	add a,c			;8b33	81 	. 
	add a,c			;8b34	81 	. 
	add a,d			;8b35	82 	. 
	sbc a,074h		;8b36	de 74 	. t 
	inc b			;8b38	04 	. 
	inc b			;8b39	04 	. 
	ld (hl),0d3h		;8b3a	36 d3 	6 . 
	ld b,0ach		;8b3c	06 ac 	. . 
	call z,0fa04h		;8b3e	cc 04 fa 	. . . 
	adc a,(hl)			;8b41	8e 	. 
	inc bc			;8b42	03 	. 
	nop			;8b43	00 	. 
	nop			;8b44	00 	. 
	rlca			;8b45	07 	. 
	rra			;8b46	1f 	. 
	rra			;8b47	1f 	. 
	inc sp			;8b48	33 	3 
	ld h,a			;8b49	67 	g 
	cp 0fch		;8b4a	fe fc 	. . 
	ld a,a			;8b4c	7f 	 
	ld a,03fh		;8b4d	3e 3f 	> ? 
	ld h,a			;8b4f	67 	g 
	add hl,sp			;8b50	39 	9 
	rra			;8b51	1f 	. 
	rlca			;8b52	07 	. 
	nop			;8b53	00 	. 
	nop			;8b54	00 	. 
	ret nz			;8b55	c0 	. 
	ret p			;8b56	f0 	. 
	cp 0eeh		;8b57	fe ee 	. . 
	rst 20h			;8b59	e7 	. 
	rst 30h			;8b5a	f7 	. 
	rst 38h			;8b5b	ff 	. 
	cp a			;8b5c	bf 	. 
l8b5dh:
	rra			;8b5d	1f 	. 
	dec sp			;8b5e	3b 	; 
l8b5fh:
	or 0e6h		;8b5f	f6 e6 	. . 
	call m,000f0h		;8b61	fc f0 00 	. . . 
	nop			;8b64	00 	. 
	ld b,000h		;8b65	06 00 	. . 
	ex af,af'			;8b67	08 	. 
	nop			;8b68	00 	. 
	ld b,b			;8b69	40 	@ 
	add a,b			;8b6a	80 	. 
	add a,b			;8b6b	80 	. 
	nop			;8b6c	00 	. 
	jr nz,l8b7fh		;8b6d	20 10 	  . 
	nop			;8b6f	00 	. 
	djnz l8b7eh		;8b70	10 0c 	. . 
	nop			;8b72	00 	. 
	nop			;8b73	00 	. 
	nop			;8b74	00 	. 
l8b75h:
	jr nc,l8b7fh		;8b75	30 08 	0 . 
	nop			;8b77	00 	. 
	ex af,af'			;8b78	08 	. 
	inc b			;8b79	04 	. 
	dec b			;8b7a	05 	. 
	ld bc,00100h		;8b7b	01 00 01 	. . . 
l8b7eh:
	nop			;8b7e	00 	. 
l8b7fh:
	nop			;8b7f	00 	. 
	ret z			;8b80	c8 	. 
	djnz l8b83h		;8b81	10 00 	. . 
l8b83h:
	nop			;8b83	00 	. 
	nop			;8b84	00 	. 
	nop			;8b85	00 	. 
	nop			;8b86	00 	. 
	ld (bc),a			;8b87	02 	. 
	rrca			;8b88	0f 	. 
	ld (de),a			;8b89	12 	. 
	ld (de),a			;8b8a	12 	. 
	ccf			;8b8b	3f 	? 
	ld (de),a			;8b8c	12 	. 
	ld (de),a			;8b8d	12 	. 
	rrca			;8b8e	0f 	. 
	ld (bc),a			;8b8f	02 	. 
	nop			;8b90	00 	. 
	nop			;8b91	00 	. 
	nop			;8b92	00 	. 
	nop			;8b93	00 	. 
	nop			;8b94	00 	. 
	nop			;8b95	00 	. 
	nop			;8b96	00 	. 
	ld b,b			;8b97	40 	@ 
	ret p			;8b98	f0 	. 
	ld c,b			;8b99	48 	H 
	ld c,b			;8b9a	48 	H 
	call m,sub_4848h		;8b9b	fc 48 48 	. H H 
	ret p			;8b9e	f0 	. 
	ld b,b			;8b9f	40 	@ 
	nop			;8ba0	00 	. 
	nop			;8ba1	00 	. 
	nop			;8ba2	00 	. 
	nop			;8ba3	00 	. 
	nop			;8ba4	00 	. 
	nop			;8ba5	00 	. 
	nop			;8ba6	00 	. 
	nop			;8ba7	00 	. 
	nop			;8ba8	00 	. 
	nop			;8ba9	00 	. 
	nop			;8baa	00 	. 
	nop			;8bab	00 	. 
	nop			;8bac	00 	. 
	nop			;8bad	00 	. 
	nop			;8bae	00 	. 
	nop			;8baf	00 	. 
	nop			;8bb0	00 	. 
	nop			;8bb1	00 	. 
	nop			;8bb2	00 	. 
	nop			;8bb3	00 	. 
	nop			;8bb4	00 	. 
	nop			;8bb5	00 	. 
	nop			;8bb6	00 	. 
	nop			;8bb7	00 	. 
	nop			;8bb8	00 	. 
	nop			;8bb9	00 	. 
	nop			;8bba	00 	. 
	nop			;8bbb	00 	. 
	nop			;8bbc	00 	. 
	nop			;8bbd	00 	. 
	nop			;8bbe	00 	. 
	nop			;8bbf	00 	. 
	nop			;8bc0	00 	. 
	nop			;8bc1	00 	. 
	nop			;8bc2	00 	. 
	nop			;8bc3	00 	. 
	nop			;8bc4	00 	. 
	nop			;8bc5	00 	. 
	nop			;8bc6	00 	. 
	nop			;8bc7	00 	. 
	nop			;8bc8	00 	. 
	nop			;8bc9	00 	. 
	nop			;8bca	00 	. 
	nop			;8bcb	00 	. 
	nop			;8bcc	00 	. 
	nop			;8bcd	00 	. 
	nop			;8bce	00 	. 
	nop			;8bcf	00 	. 
	nop			;8bd0	00 	. 
	nop			;8bd1	00 	. 
	nop			;8bd2	00 	. 
	nop			;8bd3	00 	. 
	nop			;8bd4	00 	. 
	nop			;8bd5	00 	. 
	nop			;8bd6	00 	. 
	nop			;8bd7	00 	. 
	nop			;8bd8	00 	. 
	nop			;8bd9	00 	. 
	nop			;8bda	00 	. 
	nop			;8bdb	00 	. 
	nop			;8bdc	00 	. 
	nop			;8bdd	00 	. 
	nop			;8bde	00 	. 
	nop			;8bdf	00 	. 
	nop			;8be0	00 	. 
	nop			;8be1	00 	. 
	nop			;8be2	00 	. 
	nop			;8be3	00 	. 
	nop			;8be4	00 	. 
	nop			;8be5	00 	. 
	nop			;8be6	00 	. 
	nop			;8be7	00 	. 
	nop			;8be8	00 	. 
	nop			;8be9	00 	. 
	nop			;8bea	00 	. 
	nop			;8beb	00 	. 
	nop			;8bec	00 	. 
	nop			;8bed	00 	. 
	nop			;8bee	00 	. 
	nop			;8bef	00 	. 
	nop			;8bf0	00 	. 
	nop			;8bf1	00 	. 
	nop			;8bf2	00 	. 
	nop			;8bf3	00 	. 
	nop			;8bf4	00 	. 
	nop			;8bf5	00 	. 
	nop			;8bf6	00 	. 
	nop			;8bf7	00 	. 
	nop			;8bf8	00 	. 
	nop			;8bf9	00 	. 
	nop			;8bfa	00 	. 
	nop			;8bfb	00 	. 
	nop			;8bfc	00 	. 
	nop			;8bfd	00 	. 
	nop			;8bfe	00 	. 
	nop			;8bff	00 	. 
	nop			;8c00	00 	. 
	nop			;8c01	00 	. 
	nop			;8c02	00 	. 
	nop			;8c03	00 	. 
	nop			;8c04	00 	. 
	nop			;8c05	00 	. 
	nop			;8c06	00 	. 
	nop			;8c07	00 	. 
	nop			;8c08	00 	. 
	nop			;8c09	00 	. 
	nop			;8c0a	00 	. 
	nop			;8c0b	00 	. 
	nop			;8c0c	00 	. 
	nop			;8c0d	00 	. 
	nop			;8c0e	00 	. 
	nop			;8c0f	00 	. 
	nop			;8c10	00 	. 
	nop			;8c11	00 	. 
	nop			;8c12	00 	. 
	nop			;8c13	00 	. 
	nop			;8c14	00 	. 
	nop			;8c15	00 	. 
	nop			;8c16	00 	. 
	nop			;8c17	00 	. 
	nop			;8c18	00 	. 
	nop			;8c19	00 	. 
	nop			;8c1a	00 	. 
	nop			;8c1b	00 	. 
	nop			;8c1c	00 	. 
	nop			;8c1d	00 	. 
	nop			;8c1e	00 	. 
	nop			;8c1f	00 	. 
	nop			;8c20	00 	. 
	nop			;8c21	00 	. 
	nop			;8c22	00 	. 
	nop			;8c23	00 	. 
	nop			;8c24	00 	. 
	nop			;8c25	00 	. 
	nop			;8c26	00 	. 
	nop			;8c27	00 	. 
	nop			;8c28	00 	. 
	nop			;8c29	00 	. 
	nop			;8c2a	00 	. 
	nop			;8c2b	00 	. 
	nop			;8c2c	00 	. 
	nop			;8c2d	00 	. 
	nop			;8c2e	00 	. 
	nop			;8c2f	00 	. 
	nop			;8c30	00 	. 
	nop			;8c31	00 	. 
	nop			;8c32	00 	. 
	nop			;8c33	00 	. 
	nop			;8c34	00 	. 
	nop			;8c35	00 	. 
	nop			;8c36	00 	. 
	nop			;8c37	00 	. 
	nop			;8c38	00 	. 
	nop			;8c39	00 	. 
	nop			;8c3a	00 	. 
	nop			;8c3b	00 	. 
	nop			;8c3c	00 	. 
	nop			;8c3d	00 	. 
	nop			;8c3e	00 	. 
	nop			;8c3f	00 	. 
	nop			;8c40	00 	. 
	nop			;8c41	00 	. 
	nop			;8c42	00 	. 
	nop			;8c43	00 	. 
	nop			;8c44	00 	. 
	nop			;8c45	00 	. 
	nop			;8c46	00 	. 
	nop			;8c47	00 	. 
	nop			;8c48	00 	. 
	nop			;8c49	00 	. 
	nop			;8c4a	00 	. 
	nop			;8c4b	00 	. 
	nop			;8c4c	00 	. 
	nop			;8c4d	00 	. 
	nop			;8c4e	00 	. 
	nop			;8c4f	00 	. 
	nop			;8c50	00 	. 
	nop			;8c51	00 	. 
	nop			;8c52	00 	. 
	nop			;8c53	00 	. 
	nop			;8c54	00 	. 
	nop			;8c55	00 	. 
	nop			;8c56	00 	. 
	nop			;8c57	00 	. 
	nop			;8c58	00 	. 
	nop			;8c59	00 	. 
	nop			;8c5a	00 	. 
	nop			;8c5b	00 	. 
	nop			;8c5c	00 	. 
	nop			;8c5d	00 	. 
	nop			;8c5e	00 	. 
	nop			;8c5f	00 	. 
	nop			;8c60	00 	. 
	nop			;8c61	00 	. 
	nop			;8c62	00 	. 
	nop			;8c63	00 	. 
	nop			;8c64	00 	. 
	nop			;8c65	00 	. 
	nop			;8c66	00 	. 
	nop			;8c67	00 	. 
	nop			;8c68	00 	. 
	nop			;8c69	00 	. 
	nop			;8c6a	00 	. 
	nop			;8c6b	00 	. 
	nop			;8c6c	00 	. 
	nop			;8c6d	00 	. 
	nop			;8c6e	00 	. 
	nop			;8c6f	00 	. 
	nop			;8c70	00 	. 
	nop			;8c71	00 	. 
	nop			;8c72	00 	. 
	nop			;8c73	00 	. 
	nop			;8c74	00 	. 
	nop			;8c75	00 	. 
	nop			;8c76	00 	. 
	nop			;8c77	00 	. 
	nop			;8c78	00 	. 
	nop			;8c79	00 	. 
	nop			;8c7a	00 	. 
	nop			;8c7b	00 	. 
	nop			;8c7c	00 	. 
	nop			;8c7d	00 	. 
	nop			;8c7e	00 	. 
	nop			;8c7f	00 	. 
	nop			;8c80	00 	. 
	nop			;8c81	00 	. 
	nop			;8c82	00 	. 
	nop			;8c83	00 	. 
	ld bc,00303h		;8c84	01 03 03 	. . . 
	rlca			;8c87	07 	. 
	rlca			;8c88	07 	. 
	rrca			;8c89	0f 	. 
	rrca			;8c8a	0f 	. 
	rlca			;8c8b	07 	. 
	jr l8cadh		;8c8c	18 1f 	. . 
l8c8eh:
	cpl			;8c8e	2f 	/ 
	ld (hl),b			;8c8f	70 	p 
	ld a,a			;8c90	7f 	 
	ccf			;8c91	3f 	? 
	rrca			;8c92	0f 	. 
	nop			;8c93	00 	. 
	nop			;8c94	00 	. 
	add a,b			;8c95	80 	. 
	add a,b			;8c96	80 	. 
	ret nz			;8c97	c0 	. 
	ret nz			;8c98	c0 	. 
	ret po			;8c99	e0 	. 
	ret po			;8c9a	e0 	. 
	ret nz			;8c9b	c0 	. 
	jr nc,l8c8eh		;8c9c	30 f0 	0 . 
	ret pe			;8c9e	e8 	. 
	inc e			;8c9f	1c 	. 
	call m,0e0f8h		;8ca0	fc f8 e0 	. . . 
	nop			;8ca3	00 	. 
	ld b,007h		;8ca4	06 07 	. . 
	rlca			;8ca6	07 	. 
	rlca			;8ca7	07 	. 
	rlca			;8ca8	07 	. 
	rlca			;8ca9	07 	. 
	rlca			;8caa	07 	. 
	inc bc			;8cab	03 	. 
	inc e			;8cac	1c 	. 
l8cadh:
	ccf			;8cad	3f 	? 
	ld a,a			;8cae	7f 	 
	inc a			;8caf	3c 	< 
	ld b,e			;8cb0	43 	C 
	ld a,a			;8cb1	7f 	 
	ccf			;8cb2	3f 	? 
	nop			;8cb3	00 	. 
	nop			;8cb4	00 	. 
	nop			;8cb5	00 	. 
	add a,b			;8cb6	80 	. 
	ret nz			;8cb7	c0 	. 
	ret po			;8cb8	e0 	. 
	ret po			;8cb9	e0 	. 
	ret po			;8cba	e0 	. 
	add a,b			;8cbb	80 	. 
l8cbch:
	ld h,b			;8cbc	60 	` 
	ret c			;8cbd	d8 	. 
	cp h			;8cbe	bc 	. 
	ld a,h			;8cbf	7c 	| 
	ret m			;8cc0	f8 	. 
	ret po			;8cc1	e0 	. 
	nop			;8cc2	00 	. 
	nop			;8cc3	00 	. 
	jr l8ce4h		;8cc4	18 1e 	. . 
	rra			;8cc6	1f 	. 
	rrca			;8cc7	0f 	. 
	rrca			;8cc8	0f 	. 
	rrca			;8cc9	0f 	. 
	rlca			;8cca	07 	. 
	ld b,000h		;8ccb	06 00 	. . 
	inc bc			;8ccd	03 	. 
	rra			;8cce	1f 	. 
	ld a,a			;8ccf	7f 	 
	ld a,a			;8cd0	7f 	 
	ld a,h			;8cd1	7c 	| 
	ld h,b			;8cd2	60 	` 
	nop			;8cd3	00 	. 
	nop			;8cd4	00 	. 
	nop			;8cd5	00 	. 
	add a,b			;8cd6	80 	. 
	ret nz			;8cd7	c0 	. 
	ret p			;8cd8	f0 	. 
	ret po			;8cd9	e0 	. 
	add a,b			;8cda	80 	. 
	nop			;8cdb	00 	. 
	ld (hl),b			;8cdc	70 	p 
	ret m			;8cdd	f8 	. 
	call m,sub_80f0h		;8cde	fc f0 80 	. . . 
	nop			;8ce1	00 	. 
	nop			;8ce2	00 	. 
	nop			;8ce3	00 	. 
l8ce4h:
	ld b,007h		;8ce4	06 07 	. . 
	rlca			;8ce6	07 	. 
	rlca			;8ce7	07 	. 
	rlca			;8ce8	07 	. 
	inc b			;8ce9	04 	. 
	nop			;8cea	00 	. 
	inc bc			;8ceb	03 	. 
	rra			;8cec	1f 	. 
	ld a,071h		;8ced	3e 71 	> q 
	ld c,a			;8cef	4f 	O 
	ccf			;8cf0	3f 	? 
	ld a,a			;8cf1	7f 	 
	ccf			;8cf2	3f 	? 
	nop			;8cf3	00 	. 
	nop			;8cf4	00 	. 
	nop			;8cf5	00 	. 
	add a,b			;8cf6	80 	. 
	ret nz			;8cf7	c0 	. 
	nop			;8cf8	00 	. 
	ret po			;8cf9	e0 	. 
	jr nz,l8cbch		;8cfa	20 c0 	  . 
	ret p			;8cfc	f0 	. 
	nop			;8cfd	00 	. 
l8cfeh:
	ret m			;8cfe	f8 	. 
	call m,0e0f8h		;8cff	fc f8 e0 	. . . 
	nop			;8d02	00 	. 
	nop			;8d03	00 	. 
	ld bc,00303h		;8d04	01 03 03 	. . . 
	rlca			;8d07	07 	. 
	nop			;8d08	00 	. 
	rlca			;8d09	07 	. 
	nop			;8d0a	00 	. 
	rrca			;8d0b	0f 	. 
	djnz $+17		;8d0c	10 0f 	. . 
	ccf			;8d0e	3f 	? 
	ld a,a			;8d0f	7f 	 
	ld a,a			;8d10	7f 	 
	ccf			;8d11	3f 	? 
	rrca			;8d12	0f 	. 
	nop			;8d13	00 	. 
	nop			;8d14	00 	. 
	add a,b			;8d15	80 	. 
	add a,b			;8d16	80 	. 
	ret nz			;8d17	c0 	. 
	nop			;8d18	00 	. 
	ret nz			;8d19	c0 	. 
	nop			;8d1a	00 	. 
	ret po			;8d1b	e0 	. 
	djnz l8cfeh		;8d1c	10 e0 	. . 
	ret m			;8d1e	f8 	. 
	call m,0f8fch		;8d1f	fc fc f8 	. . . 
	ret po			;8d22	e0 	. 
	nop			;8d23	00 	. 
	nop			;8d24	00 	. 
	nop			;8d25	00 	. 
	ld bc,00003h		;8d26	01 03 00 	. . . 
	rlca			;8d29	07 	. 
	inc b			;8d2a	04 	. 
	inc bc			;8d2b	03 	. 
	rrca			;8d2c	0f 	. 
	nop			;8d2d	00 	. 
	rra			;8d2e	1f 	. 
	ccf			;8d2f	3f 	? 
	rra			;8d30	1f 	. 
	rlca			;8d31	07 	. 
	nop			;8d32	00 	. 
	nop			;8d33	00 	. 
	ld h,b			;8d34	60 	` 
	ret po			;8d35	e0 	. 
	ret po			;8d36	e0 	. 
	ret po			;8d37	e0 	. 
	ret po			;8d38	e0 	. 
	jr nz,l8d3bh		;8d39	20 00 	  . 
l8d3bh:
	ret nz			;8d3b	c0 	. 
	ret m			;8d3c	f8 	. 
	ld a,h			;8d3d	7c 	| 
	adc a,(hl)			;8d3e	8e 	. 
	jp p,0fefch		;8d3f	f2 fc fe 	. . . 
	call m,00000h		;8d42	fc 00 00 	. . . 
	nop			;8d45	00 	. 
	ld bc,00f03h		;8d46	01 03 0f 	. . . 
	rlca			;8d49	07 	. 
	ld bc,00e00h		;8d4a	01 00 0e 	. . . 
	rra			;8d4d	1f 	. 
	ccf			;8d4e	3f 	? 
	rrca			;8d4f	0f 	. 
	ld bc,00000h		;8d50	01 00 00 	. . . 
	nop			;8d53	00 	. 
	jr l8dceh		;8d54	18 78 	. x 
	ret m			;8d56	f8 	. 
	ret p			;8d57	f0 	. 
	ret p			;8d58	f0 	. 
	ret p			;8d59	f0 	. 
	ret po			;8d5a	e0 	. 
	ld h,b			;8d5b	60 	` 
	nop			;8d5c	00 	. 
	ret nz			;8d5d	c0 	. 
	ret m			;8d5e	f8 	. 
	cp 0feh		;8d5f	fe fe 	. . 
	ld a,006h		;8d61	3e 06 	> . 
	nop			;8d63	00 	. 
	nop			;8d64	00 	. 
	nop			;8d65	00 	. 
	ld bc,00703h		;8d66	01 03 07 	. . . 
	rlca			;8d69	07 	. 
	rlca			;8d6a	07 	. 
	ld bc,01b06h		;8d6b	01 06 1b 	. . . 
	dec a			;8d6e	3d 	= 
	ld a,01fh		;8d6f	3e 1f 	> . 
	rlca			;8d71	07 	. 
	nop			;8d72	00 	. 
	nop			;8d73	00 	. 
	ld h,b			;8d74	60 	` 
	ret po			;8d75	e0 	. 
	ret po			;8d76	e0 	. 
	ret po			;8d77	e0 	. 
	ret po			;8d78	e0 	. 
	ret po			;8d79	e0 	. 
l8d7ah:
	ret po			;8d7a	e0 	. 
	ret nz			;8d7b	c0 	. 
	jr c,l8d7ah		;8d7c	38 fc 	8 . 
	cp 03ch		;8d7e	fe 3c 	. < 
	jp nz,0fcfeh		;8d80	c2 fe fc 	. . . 
	nop			;8d83	00 	. 
	ld bc,00301h		;8d84	01 01 03 	. . . 
	ld (bc),a			;8d87	02 	. 
	ld b,004h		;8d88	06 04 	. . 
	dec c			;8d8a	0d 	. 
	add hl,bc			;8d8b	09 	. 
	jr l8da1h		;8d8c	18 13 	. . 
	inc a			;8d8e	3c 	< 
	inc sp			;8d8f	33 	3 
	nop			;8d90	00 	. 
	nop			;8d91	00 	. 
	nop			;8d92	00 	. 
	nop			;8d93	00 	. 
	nop			;8d94	00 	. 
	nop			;8d95	00 	. 
	add a,b			;8d96	80 	. 
	ret nz			;8d97	c0 	. 
	ld d,b			;8d98	50 	P 
	ld l,b			;8d99	68 	h 
	xor h			;8d9a	ac 	. 
	or (hl)			;8d9b	b6 	. 
	jp 0f01ch		;8d9c	c3 1c f0 	. . . 
	nop			;8d9f	00 	. 
	nop			;8da0	00 	. 
l8da1h:
	nop			;8da1	00 	. 
	nop			;8da2	00 	. 
	nop			;8da3	00 	. 
	nop			;8da4	00 	. 
	nop			;8da5	00 	. 
	nop			;8da6	00 	. 
	inc bc			;8da7	03 	. 
	ld c,038h		;8da8	0e 38 	. 8 
	pop hl			;8daa	e1 	. 
	ld h,c			;8dab	61 	a 
	jr c,l8dbah		;8dac	38 0c 	8 . 
	rlca			;8dae	07 	. 
	ld bc,00000h		;8daf	01 00 00 	. . . 
	nop			;8db2	00 	. 
	nop			;8db3	00 	. 
	nop			;8db4	00 	. 
	nop			;8db5	00 	. 
	ret nz			;8db6	c0 	. 
	ret c			;8db7	d8 	. 
	ld e,h			;8db8	5c 	\ 
	ld c,h			;8db9	4c 	L 
l8dbah:
	ret z			;8dba	c8 	. 
	ret c			;8dbb	d8 	. 
	ld d,b			;8dbc	50 	P 
	ld d,b			;8dbd	50 	P 
	ld b,b			;8dbe	40 	@ 
	ret nz			;8dbf	c0 	. 
	ret nz			;8dc0	c0 	. 
	nop			;8dc1	00 	. 
	nop			;8dc2	00 	. 
	nop			;8dc3	00 	. 
	nop			;8dc4	00 	. 
	nop			;8dc5	00 	. 
	jr c,l8df7h		;8dc6	38 2f 	8 / 
	ld sp,01110h		;8dc8	31 10 11 	1 . . 
l8dcbh:
	ld de,00918h		;8dcb	11 18 09 	. . . 
l8dceh:
	dec bc			;8dce	0b 	. 
	inc c			;8dcf	0c 	. 
	ld a,(bc)			;8dd0	0a 	. 
	nop			;8dd1	00 	. 
	nop			;8dd2	00 	. 
	nop			;8dd3	00 	. 
	nop			;8dd4	00 	. 
	nop			;8dd5	00 	. 
	nop			;8dd6	00 	. 
	nop			;8dd7	00 	. 
	ret po			;8dd8	e0 	. 
	inc a			;8dd9	3c 	< 
	adc a,(hl)			;8dda	8e 	. 
	cp b			;8ddb	b8 	. 
	ld h,e			;8ddc	63 	c 
	rst 0			;8ddd	c7 	. 
	inc a			;8dde	3c 	< 
	ret po			;8ddf	e0 	. 
	nop			;8de0	00 	. 
	nop			;8de1	00 	. 
	nop			;8de2	00 	. 
	nop			;8de3	00 	. 
	ld bc,00301h		;8de4	01 01 03 	. . . 
	ld b,004h		;8de7	06 04 	. . 
	inc c			;8de9	0c 	. 
	add hl,de			;8dea	19 	. 
	ld de,l6030h		;8deb	11 30 60 	. 0 ` 
l8deeh:
	ld a,a			;8dee	7f 	 
	nop			;8def	00 	. 
	nop			;8df0	00 	. 
	nop			;8df1	00 	. 
	nop			;8df2	00 	. 
	nop			;8df3	00 	. 
	nop			;8df4	00 	. 
	nop			;8df5	00 	. 
	add a,b			;8df6	80 	. 
l8df7h:
	ret nz			;8df7	c0 	. 
	ld b,b			;8df8	40 	@ 
	ld h,b			;8df9	60 	` 
	or b			;8dfa	b0 	. 
	sub b			;8dfb	90 	. 
	jr $+14		;8dfc	18 0c 	. . 
	call m,00000h		;8dfe	fc 00 00 	. . . 
	nop			;8e01	00 	. 
	nop			;8e02	00 	. 
	nop			;8e03	00 	. 
	nop			;8e04	00 	. 
	nop			;8e05	00 	. 
	ld bc,00a03h		;8e06	01 03 0a 	. . . 
	ld d,035h		;8e09	16 35 	. 5 
	ld l,l			;8e0b	6d 	m 
	jp 00f38h		;8e0c	c3 38 0f 	. 8 . 
	nop			;8e0f	00 	. 
	nop			;8e10	00 	. 
	nop			;8e11	00 	. 
	nop			;8e12	00 	. 
	nop			;8e13	00 	. 
	add a,b			;8e14	80 	. 
	add a,b			;8e15	80 	. 
	ret nz			;8e16	c0 	. 
	ld b,b			;8e17	40 	@ 
	ld h,b			;8e18	60 	` 
	jr nz,l8dcbh		;8e19	20 b0 	  . 
	sub b			;8e1b	90 	. 
	jr $-54		;8e1c	18 c8 	. . 
	inc a			;8e1e	3c 	< 
l8e1fh:
	call z,00000h		;8e1f	cc 00 00 	. . . 
	nop			;8e22	00 	. 
	nop			;8e23	00 	. 
	nop			;8e24	00 	. 
	nop			;8e25	00 	. 
	inc bc			;8e26	03 	. 
	dec de			;8e27	1b 	. 
	ld a,(01332h)		;8e28	3a 32 13 	: 2 . 
	dec de			;8e2b	1b 	. 
	ld a,(bc)			;8e2c	0a 	. 
	ld a,(bc)			;8e2d	0a 	. 
	ld (bc),a			;8e2e	02 	. 
	inc bc			;8e2f	03 	. 
	inc bc			;8e30	03 	. 
	nop			;8e31	00 	. 
	nop			;8e32	00 	. 
	nop			;8e33	00 	. 
	nop			;8e34	00 	. 
	nop			;8e35	00 	. 
	nop			;8e36	00 	. 
	ret nz			;8e37	c0 	. 
	ld (hl),b			;8e38	70 	p 
	inc e			;8e39	1c 	. 
	add a,a			;8e3a	87 	. 
	add a,(hl)			;8e3b	86 	. 
	inc e			;8e3c	1c 	. 
l8e3dh:
	jr nc,l8e1fh		;8e3d	30 e0 	0 . 
	add a,b			;8e3f	80 	. 
	nop			;8e40	00 	. 
	nop			;8e41	00 	. 
	nop			;8e42	00 	. 
	nop			;8e43	00 	. 
	nop			;8e44	00 	. 
	nop			;8e45	00 	. 
	nop			;8e46	00 	. 
	nop			;8e47	00 	. 
	rlca			;8e48	07 	. 
	inc a			;8e49	3c 	< 
	ld (hl),c			;8e4a	71 	q 
	dec e			;8e4b	1d 	. 
	add a,0e3h		;8e4c	c6 e3 	. . 
	inc a			;8e4e	3c 	< 
	rlca			;8e4f	07 	. 
	nop			;8e50	00 	. 
	nop			;8e51	00 	. 
	nop			;8e52	00 	. 
	nop			;8e53	00 	. 
	nop			;8e54	00 	. 
	nop			;8e55	00 	. 
	inc e			;8e56	1c 	. 
	call p,0088ch		;8e57	f4 8c 08 	. . . 
	adc a,b			;8e5a	88 	. 
	adc a,b			;8e5b	88 	. 
	jr l8deeh		;8e5c	18 90 	. . 
	ret nc			;8e5e	d0 	. 
	jr nc,l8eb1h		;8e5f	30 50 	0 P 
	nop			;8e61	00 	. 
	nop			;8e62	00 	. 
	nop			;8e63	00 	. 
	nop			;8e64	00 	. 
	inc bc			;8e65	03 	. 
	rlca			;8e66	07 	. 
	rrca			;8e67	0f 	. 
	rrca			;8e68	0f 	. 
	ld bc,03f1eh		;8e69	01 1e 3f 	. . ? 
	ld a,a			;8e6c	7f 	 
	ld a,(hl)			;8e6d	7e 	~ 
	ld a,h			;8e6e	7c 	| 
	ld hl,0001eh		;8e6f	21 1e 00 	! . . 
	nop			;8e72	00 	. 
	nop			;8e73	00 	. 
	nop			;8e74	00 	. 
	ret nz			;8e75	c0 	. 
	ret po			;8e76	e0 	. 
	ret p			;8e77	f0 	. 
	ret nc			;8e78	d0 	. 
	sub b			;8e79	90 	. 
	jr z,l8ed8h		;8e7a	28 5c 	( \ 
	cp (hl)			;8e7c	be 	. 
	cp d			;8e7d	ba 	. 
	or d			;8e7e	b2 	. 
	inc b			;8e7f	04 	. 
	ld a,b			;8e80	78 	x 
	nop			;8e81	00 	. 
	nop			;8e82	00 	. 
l8e83h:
	nop			;8e83	00 	. 
	nop			;8e84	00 	. 
	nop			;8e85	00 	. 
	ld bc,00703h		;8e86	01 03 07 	. . . 
	rlca			;8e89	07 	. 
	nop			;8e8a	00 	. 
	rrca			;8e8b	0f 	. 
	rra			;8e8c	1f 	. 
	ccf			;8e8d	3f 	? 
	ccf			;8e8e	3f 	? 
	ld a,010h		;8e8f	3e 10 	> . 
	rrca			;8e91	0f 	. 
	nop			;8e92	00 	. 
	nop			;8e93	00 	. 
	nop			;8e94	00 	. 
	nop			;8e95	00 	. 
	ret po			;8e96	e0 	. 
	ret p			;8e97	f0 	. 
	ret m			;8e98	f8 	. 
	ret pe			;8e99	e8 	. 
	ret z			;8e9a	c8 	. 
	djnz l8e3dh		;8e9b	10 a0 	. . 
	ret nz			;8e9d	c0 	. 
	ld b,b			;8e9e	40 	@ 
	ld b,b			;8e9f	40 	@ 
	add a,b			;8ea0	80 	. 
	nop			;8ea1	00 	. 
	nop			;8ea2	00 	. 
l8ea3h:
	nop			;8ea3	00 	. 
	nop			;8ea4	00 	. 
	nop			;8ea5	00 	. 
	nop			;8ea6	00 	. 
	ld e,03eh		;8ea7	1e 3e 	. > 
	ld a,l			;8ea9	7d 	} 
	ld a,l			;8eaa	7d 	} 
	ld a,h			;8eab	7c 	| 
	inc hl			;8eac	23 	# 
	rla			;8ead	17 	. 
	rrca			;8eae	0f 	. 
	rrca			;8eaf	0f 	. 
	rrca			;8eb0	0f 	. 
l8eb1h:
	inc b			;8eb1	04 	. 
	inc bc			;8eb2	03 	. 
	nop			;8eb3	00 	. 
	nop			;8eb4	00 	. 
	nop			;8eb5	00 	. 
	nop			;8eb6	00 	. 
	ld a,b			;8eb7	78 	x 
	call m,0fafeh		;8eb8	fc fe fa 	. . . 
	ld (0e8c4h),a		;8ebb	32 c4 e8 	2 . . 
	ret p			;8ebe	f0 	. 
	ret nc			;8ebf	d0 	. 
	sub b			;8ec0	90 	. 
	jr nz,l8e83h		;8ec1	20 c0 	  . 
	nop			;8ec3	00 	. 
	nop			;8ec4	00 	. 
	nop			;8ec5	00 	. 
	nop			;8ec6	00 	. 
	ld e,03fh		;8ec7	1e 3f 	. ? 
	ld a,a			;8ec9	7f 	 
	ld a,(hl)			;8eca	7e 	~ 
	ld a,h			;8ecb	7c 	| 
	ld hl,0011eh		;8ecc	21 1e 01 	! . . 
	rrca			;8ecf	0f 	. 
	rrca			;8ed0	0f 	. 
	inc b			;8ed1	04 	. 
	inc bc			;8ed2	03 	. 
	nop			;8ed3	00 	. 
	nop			;8ed4	00 	. 
	nop			;8ed5	00 	. 
	nop			;8ed6	00 	. 
	ld a,b			;8ed7	78 	x 
l8ed8h:
	ld a,h			;8ed8	7c 	| 
	cp (hl)			;8ed9	be 	. 
	cp d			;8eda	ba 	. 
	or d			;8edb	b2 	. 
	inc b			;8edc	04 	. 
	ret pe			;8edd	e8 	. 
	ret p			;8ede	f0 	. 
	ret nc			;8edf	d0 	. 
	sub b			;8ee0	90 	. 
	jr nz,l8ea3h		;8ee1	20 c0 	  . 
	nop			;8ee3	00 	. 
	nop			;8ee4	00 	. 
	nop			;8ee5	00 	. 
	rrca			;8ee6	0f 	. 
	rra			;8ee7	1f 	. 
	ccf			;8ee8	3f 	? 
	ccf			;8ee9	3f 	? 
	ld a,010h		;8eea	3e 10 	> . 
	rrca			;8eec	0f 	. 
	nop			;8eed	00 	. 
	rlca			;8eee	07 	. 
	rlca			;8eef	07 	. 
	ld (bc),a			;8ef0	02 	. 
	ld bc,00000h		;8ef1	01 00 00 	. . . 
	nop			;8ef4	00 	. 
	nop			;8ef5	00 	. 
	nop			;8ef6	00 	. 
	add a,b			;8ef7	80 	. 
l8ef8h:
	ret nz			;8ef8	c0 	. 
	ld b,b			;8ef9	40 	@ 
	ld b,b			;8efa	40 	@ 
	and b			;8efb	a0 	. 
	ld (hl),b			;8efc	70 	p 
	ret m			;8efd	f8 	. 
	ret pe			;8efe	e8 	. 
	ret z			;8eff	c8 	. 
	djnz $-30		;8f00	10 e0 	. . 
	nop			;8f02	00 	. 
	nop			;8f03	00 	. 
	nop			;8f04	00 	. 
	inc bc			;8f05	03 	. 
	rlca			;8f06	07 	. 
	rrca			;8f07	0f 	. 
	rrca			;8f08	0f 	. 
	rrca			;8f09	0f 	. 
	inc d			;8f0a	14 	. 
	dec sp			;8f0b	3b 	; 
	ld a,h			;8f0c	7c 	| 
	ld a,l			;8f0d	7d 	} 
	ld a,l			;8f0e	7d 	} 
	jr nz,l8f2fh		;8f0f	20 1e 	  . 
	nop			;8f11	00 	. 
	nop			;8f12	00 	. 
	nop			;8f13	00 	. 
	nop			;8f14	00 	. 
	ret nz			;8f15	c0 	. 
	ret po			;8f16	e0 	. 
	ret p			;8f17	f0 	. 
	ret nc			;8f18	d0 	. 
	sub b			;8f19	90 	. 
	jr z,l8ef8h		;8f1a	28 dc 	( . 
	ld a,0fah		;8f1c	3e fa 	> . 
	jp p,07884h		;8f1e	f2 84 78 	. . x 
	nop			;8f21	00 	. 
	nop			;8f22	00 	. 
	nop			;8f23	00 	. 
	ld (bc),a			;8f24	02 	. 
	rlca			;8f25	07 	. 
	rrca			;8f26	0f 	. 
	rra			;8f27	1f 	. 
	ccf			;8f28	3f 	? 
	ld a,a			;8f29	7f 	 
	rst 38h			;8f2a	ff 	. 
	rst 38h			;8f2b	ff 	. 
	ccf			;8f2c	3f 	? 
	rra			;8f2d	1f 	. 
	rlca			;8f2e	07 	. 
l8f2fh:
	inc bc			;8f2f	03 	. 
	nop			;8f30	00 	. 
	nop			;8f31	00 	. 
	nop			;8f32	00 	. 
	nop			;8f33	00 	. 
	nop			;8f34	00 	. 
l8f35h:
	add a,b			;8f35	80 	. 
	ret nz			;8f36	c0 	. 
	ret p			;8f37	f0 	. 
	ret m			;8f38	f8 	. 
	cp 0feh		;8f39	fe fe 	. . 
	call m,0f0f8h		;8f3b	fc f8 f0 	. . . 
	ret po			;8f3e	e0 	. 
	ret nz			;8f3f	c0 	. 
	add a,b			;8f40	80 	. 
	nop			;8f41	00 	. 
	nop			;8f42	00 	. 
	nop			;8f43	00 	. 
	nop			;8f44	00 	. 
	inc bc			;8f45	03 	. 
	rrca			;8f46	0f 	. 
	ccf			;8f47	3f 	? 
	ld a,h			;8f48	7c 	| 
	ld (hl),e			;8f49	73 	s 
	ld c,a			;8f4a	4f 	O 
	ccf			;8f4b	3f 	? 
	ld a,a			;8f4c	7f 	 
	ccf			;8f4d	3f 	? 
	rra			;8f4e	1f 	. 
	rrca			;8f4f	0f 	. 
	rlca			;8f50	07 	. 
	ld (bc),a			;8f51	02 	. 
	nop			;8f52	00 	. 
	nop			;8f53	00 	. 
	add a,b			;8f54	80 	. 
	and b			;8f55	a0 	. 
	or b			;8f56	b0 	. 
	jr c,l8f35h		;8f57	38 dc 	8 . 
	xor 0f6h		;8f59	ee f6 	. . 
	jp m,0fefch		;8f5b	fa fc fe 	. . . 
	ret m			;8f5e	f8 	. 
	ret po			;8f5f	e0 	. 
	add a,b			;8f60	80 	. 
	nop			;8f61	00 	. 
	nop			;8f62	00 	. 
	nop			;8f63	00 	. 
	nop			;8f64	00 	. 
	rlca			;8f65	07 	. 
	rrca			;8f66	0f 	. 
	rra			;8f67	1f 	. 
	ccf			;8f68	3f 	? 
	ld a,(hl)			;8f69	7e 	~ 
	ld bc,03f7eh		;8f6a	01 7e 3f 	. ~ ? 
	rra			;8f6d	1f 	. 
	rrca			;8f6e	0f 	. 
	rlca			;8f6f	07 	. 
	nop			;8f70	00 	. 
	nop			;8f71	00 	. 
	nop			;8f72	00 	. 
	nop			;8f73	00 	. 
	nop			;8f74	00 	. 
	ret po			;8f75	e0 	. 
	ret nc			;8f76	d0 	. 
	cp b			;8f77	b8 	. 
	ld a,h			;8f78	7c 	| 
	cp 0ffh		;8f79	fe ff 	. . 
	cp 07ch		;8f7b	fe 7c 	. | 
	cp b			;8f7d	b8 	. 
	ret nc			;8f7e	d0 	. 
	ret po			;8f7f	e0 	. 
	nop			;8f80	00 	. 
	nop			;8f81	00 	. 
	nop			;8f82	00 	. 
	nop			;8f83	00 	. 
	ld (bc),a			;8f84	02 	. 
	rlca			;8f85	07 	. 
	rrca			;8f86	0f 	. 
	rra			;8f87	1f 	. 
	ccf			;8f88	3f 	? 
	ld a,a			;8f89	7f 	 
	cp 0fdh		;8f8a	fe fd 	. . 
	dec sp			;8f8c	3b 	; 
	rla			;8f8d	17 	. 
	rlca			;8f8e	07 	. 
	inc bc			;8f8f	03 	. 
	nop			;8f90	00 	. 
	nop			;8f91	00 	. 
	nop			;8f92	00 	. 
	nop			;8f93	00 	. 
	nop			;8f94	00 	. 
	add a,b			;8f95	80 	. 
	ret nz			;8f96	c0 	. 
	ret nc			;8f97	d0 	. 
	cp b			;8f98	b8 	. 
	ld a,(hl)			;8f99	7e 	~ 
	cp 0fch		;8f9a	fe fc 	. . 
	ret m			;8f9c	f8 	. 
	ret p			;8f9d	f0 	. 
	ret po			;8f9e	e0 	. 
	ret nz			;8f9f	c0 	. 
	add a,b			;8fa0	80 	. 
	nop			;8fa1	00 	. 
	nop			;8fa2	00 	. 
	nop			;8fa3	00 	. 
	ld (bc),a			;8fa4	02 	. 
	rlca			;8fa5	07 	. 
	rrca			;8fa6	0f 	. 
	rra			;8fa7	1f 	. 
	ccf			;8fa8	3f 	? 
	ld a,a			;8fa9	7f 	 
	ccf			;8faa	3f 	? 
	ld c,a			;8fab	4f 	O 
	ld (hl),e			;8fac	73 	s 
	ld a,h			;8fad	7c 	| 
	ccf			;8fae	3f 	? 
	rrca			;8faf	0f 	. 
	inc bc			;8fb0	03 	. 
	nop			;8fb1	00 	. 
	nop			;8fb2	00 	. 
	nop			;8fb3	00 	. 
	nop			;8fb4	00 	. 
	add a,b			;8fb5	80 	. 
	ret po			;8fb6	e0 	. 
	ret m			;8fb7	f8 	. 
	cp 0fch		;8fb8	fe fc 	. . 
	jp m,0eef6h		;8fba	fa f6 ee 	. . . 
	call c,0b038h		;8fbd	dc 38 b0 	. 8 . 
	and b			;8fc0	a0 	. 
	add a,b			;8fc1	80 	. 
	nop			;8fc2	00 	. 
	nop			;8fc3	00 	. 
	nop			;8fc4	00 	. 
	inc bc			;8fc5	03 	. 
	rrca			;8fc6	0f 	. 
	rra			;8fc7	1f 	. 
	ccf			;8fc8	3f 	? 
	ccf			;8fc9	3f 	? 
	ld a,a			;8fca	7f 	 
	ld a,a			;8fcb	7f 	 
	ld a,a			;8fcc	7f 	 
	inc a			;8fcd	3c 	< 
	rra			;8fce	1f 	. 
	rrca			;8fcf	0f 	. 
	ld bc,00000h		;8fd0	01 00 00 	. . . 
	nop			;8fd3	00 	. 
	nop			;8fd4	00 	. 
	add a,b			;8fd5	80 	. 
	ret po			;8fd6	e0 	. 
	ret m			;8fd7	f8 	. 
	call m,0fafch		;8fd8	fc fc fa 	. . . 
	or 0ceh		;8fdb	f6 ce 	. . 
	inc a			;8fdd	3c 	< 
	ret m			;8fde	f8 	. 
	ret p			;8fdf	f0 	. 
	ret nz			;8fe0	c0 	. 
	nop			;8fe1	00 	. 
	nop			;8fe2	00 	. 
	nop			;8fe3	00 	. 
	nop			;8fe4	00 	. 
	rlca			;8fe5	07 	. 
	rra			;8fe6	1f 	. 
	ccf			;8fe7	3f 	? 
	ccf			;8fe8	3f 	? 
	ld a,a			;8fe9	7f 	 
	ld a,a			;8fea	7f 	 
	ld a,a			;8feb	7f 	 
	ccf			;8fec	3f 	? 
	ccf			;8fed	3f 	? 
	jr l8ff7h		;8fee	18 07 	. . 
	nop			;8ff0	00 	. 
	nop			;8ff1	00 	. 
	nop			;8ff2	00 	. 
	nop			;8ff3	00 	. 
	nop			;8ff4	00 	. 
	ret po			;8ff5	e0 	. 
	ret p			;8ff6	f0 	. 
l8ff7h:
	ret m			;8ff7	f8 	. 
	ret m			;8ff8	f8 	. 
	call m,0e4f4h		;8ff9	fc f4 e4 	. . . 
	ret z			;8ffc	c8 	. 
	jr $+50		;8ffd	18 30 	. 0 
	ret nz			;8fff	c0 	. 
	nop			;9000	00 	. 
l9001h:
	nop			;9001	00 	. 
	nop			;9002	00 	. 
	nop			;9003	00 	. 
l9004h:
	nop			;9004	00 	. 
	rlca			;9005	07 	. 
	dec bc			;9006	0b 	. 
	dec e			;9007	1d 	. 
l9008h:
	ld a,07fh		;9008	3e 7f 	>  
	rst 38h			;900a	ff 	. 
	ld a,a			;900b	7f 	 
	ld a,01dh		;900c	3e 1d 	> . 
	dec bc			;900e	0b 	. 
	rlca			;900f	07 	. 
	nop			;9010	00 	. 
	nop			;9011	00 	. 
	nop			;9012	00 	. 
	nop			;9013	00 	. 
	nop			;9014	00 	. 
	ret po			;9015	e0 	. 
	ret p			;9016	f0 	. 
	ret m			;9017	f8 	. 
	call m,sub_807eh		;9018	fc 7e 80 	. ~ . 
	ld a,(hl)			;901b	7e 	~ 
	call m,0f0f8h		;901c	fc f8 f0 	. . . 
	ret po			;901f	e0 	. 
	nop			;9020	00 	. 
	nop			;9021	00 	. 
	nop			;9022	00 	. 
	nop			;9023	00 	. 
l9024h:
	nop			;9024	00 	. 
	nop			;9025	00 	. 
	nop			;9026	00 	. 
	nop			;9027	00 	. 
	nop			;9028	00 	. 
	nop			;9029	00 	. 
	nop			;902a	00 	. 
	nop			;902b	00 	. 
	ld a,(hl)			;902c	7e 	~ 
	ld a,h			;902d	7c 	| 
	call m,0f8f8h		;902e	fc f8 f8 	. . . 
	ret m			;9031	f8 	. 
	call m,0007ch		;9032	fc 7c 00 	. | . 
	nop			;9035	00 	. 
	nop			;9036	00 	. 
	nop			;9037	00 	. 
	nop			;9038	00 	. 
	ld bc,00703h		;9039	01 03 07 	. . . 
	rrca			;903c	0f 	. 
	rra			;903d	1f 	. 
	rrca			;903e	0f 	. 
	rlca			;903f	07 	. 
	inc bc			;9040	03 	. 
	ld bc,00000h		;9041	01 00 00 	. . . 
	nop			;9044	00 	. 
	nop			;9045	00 	. 
	nop			;9046	00 	. 
	nop			;9047	00 	. 
	nop			;9048	00 	. 
	ld bc,00703h		;9049	01 03 07 	. . . 
	rrca			;904c	0f 	. 
	rra			;904d	1f 	. 
	ccf			;904e	3f 	? 
	ld a,a			;904f	7f 	 
	rst 38h			;9050	ff 	. 
	rst 38h			;9051	ff 	. 
	rst 30h			;9052	f7 	. 
	rst 20h			;9053	e7 	. 
	rst 0			;9054	c7 	. 
	add a,a			;9055	87 	. 
	rst 0			;9056	c7 	. 
	rst 20h			;9057	e7 	. 
	rst 30h			;9058	f7 	. 
	rst 38h			;9059	ff 	. 
	ret p			;905a	f0 	. 
	ld h,b			;905b	60 	` 
	nop			;905c	00 	. 
	nop			;905d	00 	. 
	nop			;905e	00 	. 
	ld e,a			;905f	5f 	_ 
	rst 18h			;9060	df 	. 
	rst 18h			;9061	df 	. 
	rst 18h			;9062	df 	. 
	rst 18h			;9063	df 	. 
	rst 18h			;9064	df 	. 
	rst 18h			;9065	df 	. 
	rst 18h			;9066	df 	. 
	rst 18h			;9067	df 	. 
	rst 18h			;9068	df 	. 
	rst 18h			;9069	df 	. 
	rst 18h			;906a	df 	. 
	rst 18h			;906b	df 	. 
	rst 18h			;906c	df 	. 
	rst 18h			;906d	df 	. 
	sbc a,0dch		;906e	de dc 	. . 
	ret c			;9070	d8 	. 
	ret nc			;9071	d0 	. 
	nop			;9072	00 	. 
	nop			;9073	00 	. 
	nop			;9074	00 	. 
	nop			;9075	00 	. 
	nop			;9076	00 	. 
	jr nz,l90e9h		;9077	20 70 	  p 
	ret m			;9079	f8 	. 
	call m,03f7eh		;907a	fc 7e 3f 	. ~ ? 
	ccf			;907d	3f 	? 
	ld a,(hl)			;907e	7e 	~ 
	call m,0f0f8h		;907f	fc f8 f0 	. . . 
	ret p			;9082	f0 	. 
	ret m			;9083	f8 	. 
	call m,03f7eh		;9084	fc 7e 3f 	. ~ ? 
	rra			;9087	1f 	. 
	ld c,004h		;9088	0e 04 	. . 
	nop			;908a	00 	. 
	nop			;908b	00 	. 
	nop			;908c	00 	. 
	nop			;908d	00 	. 
	nop			;908e	00 	. 
	ld a,h			;908f	7c 	| 
	ld a,h			;9090	7c 	| 
	ld a,h			;9091	7c 	| 
	ld a,h			;9092	7c 	| 
	ld a,h			;9093	7c 	| 
	ld a,h			;9094	7c 	| 
	ld a,h			;9095	7c 	| 
	ld a,l			;9096	7d 	} 
	ld a,a			;9097	7f 	 
	ld a,a			;9098	7f 	 
	ld a,a			;9099	7f 	 
	ld a,a			;909a	7f 	 
	ld a,a			;909b	7f 	 
	ld a,a			;909c	7f 	 
	ld a,l			;909d	7d 	} 
	ld a,b			;909e	78 	x 
	ld (hl),b			;909f	70 	p 
l90a0h:
	ld h,b			;90a0	60 	` 
	ld b,b			;90a1	40 	@ 
	nop			;90a2	00 	. 
	nop			;90a3	00 	. 
	nop			;90a4	00 	. 
	nop			;90a5	00 	. 
	nop			;90a6	00 	. 
	nop			;90a7	00 	. 
l90a8h:
	nop			;90a8	00 	. 
	nop			;90a9	00 	. 
	djnz l90e4h		;90aa	10 38 	. 8 
	ld a,h			;90ac	7c 	| 
	call m,0f0f8h		;90ad	fc f8 f0 	. . . 
	ret po			;90b0	e0 	. 
	ret nz			;90b1	c0 	. 
	ret nz			;90b2	c0 	. 
	ret po			;90b3	e0 	. 
	pop af			;90b4	f1 	. 
	ei			;90b5	fb 	. 
	defb 0fdh,07ch	;ld a,iyh		;90b6	fd 7c 	. | 
	jr c,l90cah		;90b8	38 10 	8 . 
	nop			;90ba	00 	. 
	nop			;90bb	00 	. 
	nop			;90bc	00 	. 
	nop			;90bd	00 	. 
	nop			;90be	00 	. 
	nop			;90bf	00 	. 
	nop			;90c0	00 	. 
	nop			;90c1	00 	. 
	nop			;90c2	00 	. 
	nop			;90c3	00 	. 
	ld bc,00703h		;90c4	01 03 07 	. . . 
	rrca			;90c7	0f 	. 
	rra			;90c8	1f 	. 
	ccf			;90c9	3f 	? 
l90cah:
	ld a,(hl)			;90ca	7e 	~ 
	call m,0f0f8h		;90cb	fc f8 f0 	. . . 
	ret m			;90ce	f8 	. 
	call m,03f7eh		;90cf	fc 7e 3f 	. ~ ? 
	ld e,00ch		;90d2	1e 0c 	. . 
	nop			;90d4	00 	. 
	nop			;90d5	00 	. 
	nop			;90d6	00 	. 
	ld a,(bc)			;90d7	0a 	. 
	dec de			;90d8	1b 	. 
	dec sp			;90d9	3b 	; 
	ld a,e			;90da	7b 	{ 
	ei			;90db	fb 	. 
	ei			;90dc	fb 	. 
	ei			;90dd	fb 	. 
	ei			;90de	fb 	. 
	ei			;90df	fb 	. 
	ei			;90e0	fb 	. 
	ei			;90e1	fb 	. 
	ei			;90e2	fb 	. 
	ei			;90e3	fb 	. 
l90e4h:
	ei			;90e4	fb 	. 
	ei			;90e5	fb 	. 
	ei			;90e6	fb 	. 
	ei			;90e7	fb 	. 
	ei			;90e8	fb 	. 
l90e9h:
	ei			;90e9	fb 	. 
	nop			;90ea	00 	. 
	nop			;90eb	00 	. 
	nop			;90ec	00 	. 
	nop			;90ed	00 	. 
	nop			;90ee	00 	. 
	nop			;90ef	00 	. 
	nop			;90f0	00 	. 
	add a,b			;90f1	80 	. 
	ret nz			;90f2	c0 	. 
	ret po			;90f3	e0 	. 
	ret p			;90f4	f0 	. 
	ret m			;90f5	f8 	. 
	call m,0fffeh		;90f6	fc fe ff 	. . . 
	rst 38h			;90f9	ff 	. 
	rst 28h			;90fa	ef 	. 
	rst 20h			;90fb	e7 	. 
	ex (sp),hl			;90fc	e3 	. 
	pop hl			;90fd	e1 	. 
	ret po			;90fe	e0 	. 
	ret po			;90ff	e0 	. 
	ret po			;9100	e0 	. 
	ret po			;9101	e0 	. 
	nop			;9102	00 	. 
	nop			;9103	00 	. 
	nop			;9104	00 	. 
	nop			;9105	00 	. 
	nop			;9106	00 	. 
	ld a,03eh		;9107	3e 3e 	> > 
l9109h:
	ld a,03eh		;9109	3e 3e 	> > 
	ld a,03eh		;910b	3e 3e 	> > 
	ld a,03eh		;910d	3e 3e 	> > 
	ld a,03eh		;910f	3e 3e 	> > 
	cp (hl)			;9111	be 	. 
	cp 0feh		;9112	fe fe 	. . 
	cp 0feh		;9114	fe fe 	. . 
	cp 07ch		;9116	fe 7c 	. | 
	jr c,l912ah		;9118	38 10 	8 . 
	nop			;911a	00 	. 
	nop			;911b	00 	. 
	nop			;911c	00 	. 
	nop			;911d	00 	. 
	nop			;911e	00 	. 
	nop			;911f	00 	. 
	inc bc			;9120	03 	. 
	rrca			;9121	0f 	. 
	rra			;9122	1f 	. 
	ccf			;9123	3f 	? 
	nop			;9124	00 	. 
	nop			;9125	00 	. 
	nop			;9126	00 	. 
	nop			;9127	00 	. 
	nop			;9128	00 	. 
	nop			;9129	00 	. 
l912ah:
	nop			;912a	00 	. 
	nop			;912b	00 	. 
	ld a,(hl)			;912c	7e 	~ 
	ccf			;912d	3f 	? 
	rra			;912e	1f 	. 
	rrca			;912f	0f 	. 
	inc bc			;9130	03 	. 
	nop			;9131	00 	. 
	nop			;9132	00 	. 
	nop			;9133	00 	. 
	ld (hl),036h		;9134	36 36 	6 6 
	inc h			;9136	24 	$ 
	nop			;9137	00 	. 
	nop			;9138	00 	. 
	nop			;9139	00 	. 
	nop			;913a	00 	. 
	nop			;913b	00 	. 
	nop			;913c	00 	. 
	nop			;913d	00 	. 
	nop			;913e	00 	. 
	ld a,(hl)			;913f	7e 	~ 
	rst 38h			;9140	ff 	. 
	rst 38h			;9141	ff 	. 
	rst 38h			;9142	ff 	. 
	add a,c			;9143	81 	. 
	nop			;9144	00 	. 
	nop			;9145	00 	. 
	nop			;9146	00 	. 
	nop			;9147	00 	. 
	nop			;9148	00 	. 
	nop			;9149	00 	. 
	nop			;914a	00 	. 
	nop			;914b	00 	. 
	nop			;914c	00 	. 
	add a,c			;914d	81 	. 
	rst 38h			;914e	ff 	. 
	rst 38h			;914f	ff 	. 
	rst 38h			;9150	ff 	. 
	ld a,(hl)			;9151	7e 	~ 
	nop			;9152	00 	. 
	nop			;9153	00 	. 
	nop			;9154	00 	. 
	nop			;9155	00 	. 
	nop			;9156	00 	. 
	nop			;9157	00 	. 
	ret nz			;9158	c0 	. 
	ret p			;9159	f0 	. 
	ret m			;915a	f8 	. 
	call m,03e7eh		;915b	fc 7e 3e 	. ~ > 
	ccf			;915e	3f 	? 
	rra			;915f	1f 	. 
	rra			;9160	1f 	. 
	rra			;9161	1f 	. 
	ccf			;9162	3f 	? 
	ld a,07eh		;9163	3e 7e 	> ~ 
	call m,0f0f8h		;9165	fc f8 f0 	. . . 
	ret nz			;9168	c0 	. 
	nop			;9169	00 	. 
	nop			;916a	00 	. 
	nop			;916b	00 	. 
	nop			;916c	00 	. 
	nop			;916d	00 	. 
	nop			;916e	00 	. 
	ld a,l			;916f	7d 	} 
	ld a,l			;9170	7d 	} 
	ld a,l			;9171	7d 	} 
	ld a,l			;9172	7d 	} 
	ld a,l			;9173	7d 	} 
	ld a,l			;9174	7d 	} 
	ld a,l			;9175	7d 	} 
	ld a,l			;9176	7d 	} 
	ld a,l			;9177	7d 	} 
	ld a,l			;9178	7d 	} 
	ld a,l			;9179	7d 	} 
	ld a,l			;917a	7d 	} 
	ld a,l			;917b	7d 	} 
	ld h,e			;917c	63 	c 
	ld h,e			;917d	63 	c 
	ld h,e			;917e	63 	c 
	ld a,a			;917f	7f 	 
	ld h,e			;9180	63 	c 
	ld h,e			;9181	63 	c 
	ld h,e			;9182	63 	c 
	nop			;9183	00 	. 
	nop			;9184	00 	. 
	nop			;9185	00 	. 
	nop			;9186	00 	. 
	nop			;9187	00 	. 
sub_9188h:
	jr l91a2h		;9188	18 18 	. . 
	jr nc,l918ch		;918a	30 00 	0 . 
l918ch:
	nop			;918c	00 	. 
	nop			;918d	00 	. 
	nop			;918e	00 	. 
	ld a,000h		;918f	3e 00 	> . 
	nop			;9191	00 	. 
	nop			;9192	00 	. 
	nop			;9193	00 	. 
	nop			;9194	00 	. 
	nop			;9195	00 	. 
	nop			;9196	00 	. 
	nop			;9197	00 	. 
	nop			;9198	00 	. 
	jr l91b3h		;9199	18 18 	. . 
	nop			;919b	00 	. 
	ccf			;919c	3f 	? 
	inc c			;919d	0c 	. 
	inc c			;919e	0c 	. 
	inc c			;919f	0c 	. 
	inc c			;91a0	0c 	. 
	inc c			;91a1	0c 	. 
l91a2h:
	ccf			;91a2	3f 	? 
	nop			;91a3	00 	. 
	inc e			;91a4	1c 	. 
	ld h,063h		;91a5	26 63 	& c 
	ld h,e			;91a7	63 	c 
	ld h,e			;91a8	63 	c 
	ld (0001ch),a		;91a9	32 1c 00 	2 . . 
	inc c			;91ac	0c 	. 
	inc e			;91ad	1c 	. 
	inc c			;91ae	0c 	. 
	inc c			;91af	0c 	. 
	inc c			;91b0	0c 	. 
	inc c			;91b1	0c 	. 
	ccf			;91b2	3f 	? 
l91b3h:
	nop			;91b3	00 	. 
	ld a,043h		;91b4	3e 43 	> C 
	rlca			;91b6	07 	. 
	ld e,03ch		;91b7	1e 3c 	. < 
	ld (hl),b			;91b9	70 	p 
	ld a,a			;91ba	7f 	 
	nop			;91bb	00 	. 
	ccf			;91bc	3f 	? 
	ld b,00ch		;91bd	06 0c 	. . 
	ld e,003h		;91bf	1e 03 	. . 
	ld h,e			;91c1	63 	c 
	ld a,000h		;91c2	3e 00 	> . 
	ld c,01eh		;91c4	0e 1e 	. . 
	ld (hl),066h		;91c6	36 66 	6 f 
	ld a,a			;91c8	7f 	 
	ld b,006h		;91c9	06 06 	. . 
	nop			;91cb	00 	. 
	ld a,a			;91cc	7f 	 
	ld h,b			;91cd	60 	` 
	ld a,(hl)			;91ce	7e 	~ 
	inc bc			;91cf	03 	. 
	inc bc			;91d0	03 	. 
	ld h,e			;91d1	63 	c 
	ld a,000h		;91d2	3e 00 	> . 
	ld e,030h		;91d4	1e 30 	. 0 
	ld h,b			;91d6	60 	` 
	ld a,(hl)			;91d7	7e 	~ 
	ld h,e			;91d8	63 	c 
	ld h,e			;91d9	63 	c 
	ld a,000h		;91da	3e 00 	> . 
	ld a,a			;91dc	7f 	 
	ld h,e			;91dd	63 	c 
	ld b,00ch		;91de	06 0c 	. . 
	jr l91fah		;91e0	18 18 	. . 
	jr l91e4h		;91e2	18 00 	. . 
l91e4h:
	inc a			;91e4	3c 	< 
	ld h,d			;91e5	62 	b 
	ld (hl),d			;91e6	72 	r 
	inc a			;91e7	3c 	< 
	ld c,a			;91e8	4f 	O 
	ld b,e			;91e9	43 	C 
	ld a,000h		;91ea	3e 00 	> . 
	ld a,063h		;91ec	3e 63 	> c 
	ld h,e			;91ee	63 	c 
	ccf			;91ef	3f 	? 
	inc bc			;91f0	03 	. 
	ld b,03ch		;91f1	06 3c 	. < 
	nop			;91f3	00 	. 
	inc a			;91f4	3c 	< 
	ld h,(hl)			;91f5	66 	f 
	ld h,b			;91f6	60 	` 
	ld a,003h		;91f7	3e 03 	> . 
	ld h,e			;91f9	63 	c 
l91fah:
	ld a,000h		;91fa	3e 00 	> . 
	ld e,033h		;91fc	1e 33 	. 3 
	ld h,b			;91fe	60 	` 
	ld h,b			;91ff	60 	` 
	ld h,b			;9200	60 	` 
	inc sp			;9201	33 	3 
	ld e,000h		;9202	1e 00 	. . 
	ld a,063h		;9204	3e 63 	> c 
	ld h,e			;9206	63 	c 
	ld h,e			;9207	63 	c 
	ld h,e			;9208	63 	c 
	ld h,e			;9209	63 	c 
	ld a,000h		;920a	3e 00 	> . 
	ld a,(hl)			;920c	7e 	~ 
	ld h,e			;920d	63 	c 
	ld h,e			;920e	63 	c 
	ld h,a			;920f	67 	g 
	ld a,h			;9210	7c 	| 
	ld l,(hl)			;9211	6e 	n 
	ld h,a			;9212	67 	g 
	nop			;9213	00 	. 
	ld a,a			;9214	7f 	 
	ld h,b			;9215	60 	` 
	ld h,b			;9216	60 	` 
	ld a,(hl)			;9217	7e 	~ 
	ld h,b			;9218	60 	` 
	ld h,b			;9219	60 	` 
	ld a,a			;921a	7f 	 
	nop			;921b	00 	. 
	rra			;921c	1f 	. 
	jr nc,l927fh		;921d	30 60 	0 ` 
	ld h,a			;921f	67 	g 
	ld h,e			;9220	63 	c 
	inc sp			;9221	33 	3 
	rra			;9222	1f 	. 
	nop			;9223	00 	. 
	inc a			;9224	3c 	< 
	ld b,d			;9225	42 	B 
	sbc a,c			;9226	99 	. 
	and c			;9227	a1 	. 
	sbc a,c			;9228	99 	. 
	ld b,d			;9229	42 	B 
	inc a			;922a	3c 	< 
	nop			;922b	00 	. 
	inc e			;922c	1c 	. 
	ld (hl),063h		;922d	36 63 	6 c 
	ld h,e			;922f	63 	c 
	ld a,a			;9230	7f 	 
	ld h,e			;9231	63 	c 
	ld h,e			;9232	63 	c 
	nop			;9233	00 	. 
	ld a,(hl)			;9234	7e 	~ 
	ld h,e			;9235	63 	c 
	ld h,e			;9236	63 	c 
	ld a,(hl)			;9237	7e 	~ 
	ld h,e			;9238	63 	c 
	ld h,e			;9239	63 	c 
	ld a,(hl)			;923a	7e 	~ 
	nop			;923b	00 	. 
	ld e,033h		;923c	1e 33 	. 3 
	ld h,b			;923e	60 	` 
	ld h,b			;923f	60 	` 
	ld h,b			;9240	60 	` 
	inc sp			;9241	33 	3 
	ld e,000h		;9242	1e 00 	. . 
	ld a,h			;9244	7c 	| 
	ld h,(hl)			;9245	66 	f 
	ld h,e			;9246	63 	c 
	ld h,e			;9247	63 	c 
	ld h,e			;9248	63 	c 
	ld h,(hl)			;9249	66 	f 
	ld a,h			;924a	7c 	| 
	nop			;924b	00 	. 
	ld a,a			;924c	7f 	 
	ld h,b			;924d	60 	` 
	ld h,b			;924e	60 	` 
	ld a,(hl)			;924f	7e 	~ 
	ld h,b			;9250	60 	` 
	ld h,b			;9251	60 	` 
	ld a,a			;9252	7f 	 
	nop			;9253	00 	. 
	ld a,a			;9254	7f 	 
	ld h,b			;9255	60 	` 
	ld h,b			;9256	60 	` 
	ld a,(hl)			;9257	7e 	~ 
	ld h,b			;9258	60 	` 
	ld h,b			;9259	60 	` 
	ld h,b			;925a	60 	` 
	nop			;925b	00 	. 
	rra			;925c	1f 	. 
	jr nc,l92bfh		;925d	30 60 	0 ` 
	ld h,a			;925f	67 	g 
	ld h,e			;9260	63 	c 
	inc sp			;9261	33 	3 
	rra			;9262	1f 	. 
	nop			;9263	00 	. 
	ld h,e			;9264	63 	c 
	ld h,e			;9265	63 	c 
	ld h,e			;9266	63 	c 
	ld a,a			;9267	7f 	 
	ld h,e			;9268	63 	c 
	ld h,e			;9269	63 	c 
	ld h,e			;926a	63 	c 
	nop			;926b	00 	. 
	ccf			;926c	3f 	? 
	inc c			;926d	0c 	. 
	inc c			;926e	0c 	. 
	inc c			;926f	0c 	. 
	inc c			;9270	0c 	. 
	inc c			;9271	0c 	. 
	ccf			;9272	3f 	? 
	nop			;9273	00 	. 
	inc bc			;9274	03 	. 
	inc bc			;9275	03 	. 
	inc bc			;9276	03 	. 
	inc bc			;9277	03 	. 
	inc bc			;9278	03 	. 
	ld h,e			;9279	63 	c 
	ld a,000h		;927a	3e 00 	> . 
	ld h,e			;927c	63 	c 
	ld h,(hl)			;927d	66 	f 
	ld l,h			;927e	6c 	l 
l927fh:
	ld a,b			;927f	78 	x 
	ld a,h			;9280	7c 	| 
	ld l,(hl)			;9281	6e 	n 
	ld h,a			;9282	67 	g 
	nop			;9283	00 	. 
	ld h,b			;9284	60 	` 
	ld h,b			;9285	60 	` 
	ld h,b			;9286	60 	` 
	ld h,b			;9287	60 	` 
	ld h,b			;9288	60 	` 
	ld h,b			;9289	60 	` 
	ld a,a			;928a	7f 	 
	nop			;928b	00 	. 
	ld h,e			;928c	63 	c 
	ld (hl),a			;928d	77 	w 
	ld a,a			;928e	7f 	 
	ld a,a			;928f	7f 	 
	ld l,e			;9290	6b 	k 
	ld h,e			;9291	63 	c 
	ld h,e			;9292	63 	c 
	nop			;9293	00 	. 
	ld h,e			;9294	63 	c 
	ld (hl),e			;9295	73 	s 
	ld a,e			;9296	7b 	{ 
	ld a,a			;9297	7f 	 
	ld l,a			;9298	6f 	o 
	ld h,a			;9299	67 	g 
	ld h,e			;929a	63 	c 
	nop			;929b	00 	. 
	ld a,063h		;929c	3e 63 	> c 
	ld h,e			;929e	63 	c 
	ld h,e			;929f	63 	c 
	ld h,e			;92a0	63 	c 
	ld h,e			;92a1	63 	c 
	ld a,000h		;92a2	3e 00 	> . 
	ld a,(hl)			;92a4	7e 	~ 
	ld h,e			;92a5	63 	c 
	ld h,e			;92a6	63 	c 
	ld h,e			;92a7	63 	c 
	ld a,(hl)			;92a8	7e 	~ 
	ld h,b			;92a9	60 	` 
	ld h,b			;92aa	60 	` 
	nop			;92ab	00 	. 
	ld a,063h		;92ac	3e 63 	> c 
	ld h,e			;92ae	63 	c 
	ld h,e			;92af	63 	c 
	ld l,a			;92b0	6f 	o 
	ld h,(hl)			;92b1	66 	f 
	dec a			;92b2	3d 	= 
	nop			;92b3	00 	. 
	ld a,(hl)			;92b4	7e 	~ 
	ld h,e			;92b5	63 	c 
	ld h,e			;92b6	63 	c 
	ld h,a			;92b7	67 	g 
	ld a,h			;92b8	7c 	| 
	ld l,(hl)			;92b9	6e 	n 
	ld h,a			;92ba	67 	g 
	nop			;92bb	00 	. 
	inc a			;92bc	3c 	< 
	ld h,(hl)			;92bd	66 	f 
	ld h,b			;92be	60 	` 
l92bfh:
	ld a,003h		;92bf	3e 03 	> . 
	ld h,e			;92c1	63 	c 
	ld a,000h		;92c2	3e 00 	> . 
	ccf			;92c4	3f 	? 
	inc c			;92c5	0c 	. 
	inc c			;92c6	0c 	. 
	inc c			;92c7	0c 	. 
	inc c			;92c8	0c 	. 
	inc c			;92c9	0c 	. 
	inc c			;92ca	0c 	. 
	nop			;92cb	00 	. 
	ld h,e			;92cc	63 	c 
	ld h,e			;92cd	63 	c 
	ld h,e			;92ce	63 	c 
	ld h,e			;92cf	63 	c 
	ld h,e			;92d0	63 	c 
	ld h,e			;92d1	63 	c 
	ld a,000h		;92d2	3e 00 	> . 
	ld h,e			;92d4	63 	c 
	ld h,e			;92d5	63 	c 
	ld h,e			;92d6	63 	c 
	ld h,e			;92d7	63 	c 
	ld (hl),01ch		;92d8	36 1c 	6 . 
	ex af,af'			;92da	08 	. 
	nop			;92db	00 	. 
	ld h,e			;92dc	63 	c 
	ld h,e			;92dd	63 	c 
	ld l,e			;92de	6b 	k 
	ld a,a			;92df	7f 	 
	ld a,a			;92e0	7f 	 
	ld (hl),a			;92e1	77 	w 
	ld h,e			;92e2	63 	c 
	nop			;92e3	00 	. 
	ld h,e			;92e4	63 	c 
	ld (hl),a			;92e5	77 	w 
	ld a,01ch		;92e6	3e 1c 	> . 
	ld a,077h		;92e8	3e 77 	> w 
	ld h,e			;92ea	63 	c 
	nop			;92eb	00 	. 
	inc sp			;92ec	33 	3 
	inc sp			;92ed	33 	3 
	inc sp			;92ee	33 	3 
	ld e,00ch		;92ef	1e 0c 	. . 
	inc c			;92f1	0c 	. 
	inc c			;92f2	0c 	. 
	nop			;92f3	00 	. 
	ld a,a			;92f4	7f 	 
	rlca			;92f5	07 	. 
	ld c,01ch		;92f6	0e 1c 	. . 
	jr c,l936ah		;92f8	38 70 	8 p 
	ld a,a			;92fa	7f 	 
	nop			;92fb	00 	. 
	ld a,l			;92fc	7d 	} 
	ld a,l			;92fd	7d 	} 
	ld a,c			;92fe	79 	y 
	ld (hl),c			;92ff	71 	q 
	ld h,c			;9300	61 	a 
	ld b,c			;9301	41 	A 
	nop			;9302	00 	. 
	nop			;9303	00 	. 
	nop			;9304	00 	. 
	inc bc			;9305	03 	. 
	rlca			;9306	07 	. 
	rst 38h			;9307	ff 	. 
	rst 30h			;9308	f7 	. 
	di			;9309	f3 	. 
	pop af			;930a	f1 	. 
	ret p			;930b	f0 	. 
	pop af			;930c	f1 	. 
	di			;930d	f3 	. 
	rst 30h			;930e	f7 	. 
	rst 38h			;930f	ff 	. 
	rst 38h			;9310	ff 	. 
	rst 38h			;9311	ff 	. 
	cp 0fch		;9312	fe fc 	. . 
	ret m			;9314	f8 	. 
	ret p			;9315	f0 	. 
	ret po			;9316	e0 	. 
	ret nz			;9317	c0 	. 
	add a,b			;9318	80 	. 
	nop			;9319	00 	. 
	nop			;931a	00 	. 
	nop			;931b	00 	. 
	ld (hl),036h		;931c	36 36 	6 6 
	ld (de),a			;931e	12 	. 
	nop			;931f	00 	. 
	nop			;9320	00 	. 
	nop			;9321	00 	. 
	nop			;9322	00 	. 
	nop			;9323	00 	. 
	nop			;9324	00 	. 
	nop			;9325	00 	. 
	add a,b			;9326	80 	. 
	ret nz			;9327	c0 	. 
	ret po			;9328	e0 	. 
	ret p			;9329	f0 	. 
	ret m			;932a	f8 	. 
	call m,0f0f8h		;932b	fc f8 f0 	. . . 
	ret po			;932e	e0 	. 
	ret nz			;932f	c0 	. 
	add a,b			;9330	80 	. 
	nop			;9331	00 	. 
	nop			;9332	00 	. 
	nop			;9333	00 	. 
	nop			;9334	00 	. 
	nop			;9335	00 	. 
	nop			;9336	00 	. 
	nop			;9337	00 	. 
	nop			;9338	00 	. 
	nop			;9339	00 	. 
	nop			;933a	00 	. 
	nop			;933b	00 	. 
	rst 38h			;933c	ff 	. 
	rst 38h			;933d	ff 	. 
	rst 38h			;933e	ff 	. 
	add a,a			;933f	87 	. 
	rlca			;9340	07 	. 
	rlca			;9341	07 	. 
	rlca			;9342	07 	. 
	rlca			;9343	07 	. 
	rlca			;9344	07 	. 
	rlca			;9345	07 	. 
	rlca			;9346	07 	. 
	rlca			;9347	07 	. 
	rlca			;9348	07 	. 
	rlca			;9349	07 	. 
	rlca			;934a	07 	. 
	rrca			;934b	0f 	. 
	rst 38h			;934c	ff 	. 
	rst 38h			;934d	ff 	. 
	rst 38h			;934e	ff 	. 
	pop hl			;934f	e1 	. 
	ret po			;9350	e0 	. 
	ret po			;9351	e0 	. 
	ret po			;9352	e0 	. 
	ret po			;9353	e0 	. 
	ret po			;9354	e0 	. 
	ret po			;9355	e0 	. 
	ret po			;9356	e0 	. 
	ret po			;9357	e0 	. 
	ret po			;9358	e0 	. 
	pop hl			;9359	e1 	. 
	pop hl			;935a	e1 	. 
	di			;935b	f3 	. 
	rrca			;935c	0f 	. 
	rlca			;935d	07 	. 
	rrca			;935e	0f 	. 
	rrca			;935f	0f 	. 
	rra			;9360	1f 	. 
	rra			;9361	1f 	. 
	ld e,03eh		;9362	1e 3e 	. > 
	ld a,07ch		;9364	3e 7c 	> | 
	ld a,h			;9366	7c 	| 
	rst 38h			;9367	ff 	. 
	rst 38h			;9368	ff 	. 
	rst 38h			;9369	ff 	. 
l936ah:
	ret m			;936a	f8 	. 
	call m,0e0f0h		;936b	fc f0 e0 	. . . 
	ret p			;936e	f0 	. 
	ret p			;936f	f0 	. 
	ret m			;9370	f8 	. 
	ret m			;9371	f8 	. 
	ld a,b			;9372	78 	x 
	ld a,h			;9373	7c 	| 
	ld a,h			;9374	7c 	| 
	ld a,03eh		;9375	3e 3e 	> > 
	rst 38h			;9377	ff 	. 
	rst 38h			;9378	ff 	. 
	rst 38h			;9379	ff 	. 
	rra			;937a	1f 	. 
	ccf			;937b	3f 	? 
	rrca			;937c	0f 	. 
	rlca			;937d	07 	. 
	rlca			;937e	07 	. 
	rlca			;937f	07 	. 
	rlca			;9380	07 	. 
	rlca			;9381	07 	. 
	rlca			;9382	07 	. 
	rlca			;9383	07 	. 
	rlca			;9384	07 	. 
	rlca			;9385	07 	. 
	rlca			;9386	07 	. 
	rlca			;9387	07 	. 
	rlca			;9388	07 	. 
	add a,a			;9389	87 	. 
	add a,a			;938a	87 	. 
	rst 8			;938b	cf 	. 
	ret p			;938c	f0 	. 
	ret po			;938d	e0 	. 
	ret po			;938e	e0 	. 
	ret po			;938f	e0 	. 
	ret po			;9390	e0 	. 
	ret po			;9391	e0 	. 
	ret po			;9392	e0 	. 
	ret po			;9393	e0 	. 
	ret po			;9394	e0 	. 
	ret po			;9395	e0 	. 
	ret po			;9396	e0 	. 
	ret po			;9397	e0 	. 
	ret po			;9398	e0 	. 
	ret po			;9399	e0 	. 
	ret po			;939a	e0 	. 
	ret p			;939b	f0 	. 
	rst 38h			;939c	ff 	. 
	rst 38h			;939d	ff 	. 
	rst 38h			;939e	ff 	. 
	add a,a			;939f	87 	. 
	rlca			;93a0	07 	. 
	rlca			;93a1	07 	. 
	rlca			;93a2	07 	. 
	rlca			;93a3	07 	. 
	rlca			;93a4	07 	. 
	rlca			;93a5	07 	. 
	rlca			;93a6	07 	. 
	rlca			;93a7	07 	. 
	rlca			;93a8	07 	. 
	rlca			;93a9	07 	. 
	rlca			;93aa	07 	. 
	rrca			;93ab	0f 	. 
	rst 38h			;93ac	ff 	. 
	rst 38h			;93ad	ff 	. 
	rst 38h			;93ae	ff 	. 
	pop hl			;93af	e1 	. 
	ret po			;93b0	e0 	. 
	ret po			;93b1	e0 	. 
	ret po			;93b2	e0 	. 
	ret po			;93b3	e0 	. 
	ret po			;93b4	e0 	. 
	ret po			;93b5	e0 	. 
	ret po			;93b6	e0 	. 
	ret po			;93b7	e0 	. 
	ret po			;93b8	e0 	. 
	ret po			;93b9	e0 	. 
	ret po			;93ba	e0 	. 
	ret p			;93bb	f0 	. 
	nop			;93bc	00 	. 
	inc bc			;93bd	03 	. 
	rlca			;93be	07 	. 
	rrca			;93bf	0f 	. 
	rrca			;93c0	0f 	. 
	rra			;93c1	1f 	. 
	rra			;93c2	1f 	. 
	rra			;93c3	1f 	. 
	rra			;93c4	1f 	. 
	rra			;93c5	1f 	. 
	rra			;93c6	1f 	. 
	rrca			;93c7	0f 	. 
	rrca			;93c8	0f 	. 
	rlca			;93c9	07 	. 
	inc bc			;93ca	03 	. 
	nop			;93cb	00 	. 
	rst 38h			;93cc	ff 	. 
	rst 38h			;93cd	ff 	. 
	rst 38h			;93ce	ff 	. 
	jp 00081h		;93cf	c3 81 00 	. . . 
	nop			;93d2	00 	. 
	nop			;93d3	00 	. 
	nop			;93d4	00 	. 
	nop			;93d5	00 	. 
	nop			;93d6	00 	. 
	add a,c			;93d7	81 	. 
	jp 0ffffh		;93d8	c3 ff ff 	. . . 
	rst 38h			;93db	ff 	. 
	nop			;93dc	00 	. 
	ret nz			;93dd	c0 	. 
	ret po			;93de	e0 	. 
	ret p			;93df	f0 	. 
	ret p			;93e0	f0 	. 
	ret m			;93e1	f8 	. 
	ret m			;93e2	f8 	. 
	ret m			;93e3	f8 	. 
	ret m			;93e4	f8 	. 
	ret m			;93e5	f8 	. 
	ret m			;93e6	f8 	. 
	ret p			;93e7	f0 	. 
	ret p			;93e8	f0 	. 
	ret po			;93e9	e0 	. 
	ret nz			;93ea	c0 	. 
	nop			;93eb	00 	. 
	rst 38h			;93ec	ff 	. 
	rst 38h			;93ed	ff 	. 
	rst 38h			;93ee	ff 	. 
	rst 38h			;93ef	ff 	. 
	rst 38h			;93f0	ff 	. 
	rst 38h			;93f1	ff 	. 
	rst 38h			;93f2	ff 	. 
	rst 38h			;93f3	ff 	. 
l93f4h:
	nop			;93f4	00 	. 
	inc b			;93f5	04 	. 
	ld de,00011h		;93f6	11 11 00 	. . . 
	inc bc			;93f9	03 	. 
	ld b,c			;93fa	41 	A 
	ld b,c			;93fb	41 	A 
	pop af			;93fc	f1 	. 
	pop af			;93fd	f1 	. 
	nop			;93fe	00 	. 
	inc bc			;93ff	03 	. 
	ld b,c			;9400	41 	A 
	ld b,c			;9401	41 	A 
	nop			;9402	00 	. 
	dec b			;9403	05 	. 
l9404h:
	pop af			;9404	f1 	. 
	pop af			;9405	f1 	. 
	nop			;9406	00 	. 
	rlca			;9407	07 	. 
	ld b,c			;9408	41 	A 
	ld b,c			;9409	41 	A 
	nop			;940a	00 	. 
	dec b			;940b	05 	. 
	pop af			;940c	f1 	. 
	pop af			;940d	f1 	. 
	nop			;940e	00 	. 
	rlca			;940f	07 	. 
	ld b,c			;9410	41 	A 
	ld b,c			;9411	41 	A 
	nop			;9412	00 	. 
	dec b			;9413	05 	. 
	pop af			;9414	f1 	. 
	pop af			;9415	f1 	. 
	nop			;9416	00 	. 
	rlca			;9417	07 	. 
	ld b,c			;9418	41 	A 
	ld b,c			;9419	41 	A 
	nop			;941a	00 	. 
	dec b			;941b	05 	. 
	pop af			;941c	f1 	. 
	pop af			;941d	f1 	. 
	nop			;941e	00 	. 
	rlca			;941f	07 	. 
	ld b,c			;9420	41 	A 
	ld b,c			;9421	41 	A 
	nop			;9422	00 	. 
	dec b			;9423	05 	. 
	pop af			;9424	f1 	. 
	pop af			;9425	f1 	. 
	nop			;9426	00 	. 
	rlca			;9427	07 	. 
	ld b,c			;9428	41 	A 
	ld b,c			;9429	41 	A 
	nop			;942a	00 	. 
	dec b			;942b	05 	. 
	pop af			;942c	f1 	. 
	pop af			;942d	f1 	. 
	nop			;942e	00 	. 
	rlca			;942f	07 	. 
	ld b,c			;9430	41 	A 
	ld b,c			;9431	41 	A 
	nop			;9432	00 	. 
	dec b			;9433	05 	. 
	pop af			;9434	f1 	. 
	pop af			;9435	f1 	. 
	nop			;9436	00 	. 
	rlca			;9437	07 	. 
	ld b,c			;9438	41 	A 
	ld b,c			;9439	41 	A 
	nop			;943a	00 	. 
	dec b			;943b	05 	. 
	pop af			;943c	f1 	. 
	pop af			;943d	f1 	. 
	nop			;943e	00 	. 
	rlca			;943f	07 	. 
	ld b,c			;9440	41 	A 
	ld b,c			;9441	41 	A 
	nop			;9442	00 	. 
	dec b			;9443	05 	. 
	pop af			;9444	f1 	. 
	pop af			;9445	f1 	. 
	nop			;9446	00 	. 
	rlca			;9447	07 	. 
	ld b,c			;9448	41 	A 
	ld b,c			;9449	41 	A 
	nop			;944a	00 	. 
	dec b			;944b	05 	. 
	pop af			;944c	f1 	. 
	pop af			;944d	f1 	. 
	nop			;944e	00 	. 
	inc b			;944f	04 	. 
	ld b,c			;9450	41 	A 
	ld b,c			;9451	41 	A 
	nop			;9452	00 	. 
	inc b			;9453	04 	. 
	ld de,00011h		;9454	11 11 00 	. . . 
	ex af,af'			;9457	08 	. 
	pop af			;9458	f1 	. 
	pop af			;9459	f1 	. 
	nop			;945a	00 	. 
	ex af,af'			;945b	08 	. 
	ld b,c			;945c	41 	A 
	ld b,c			;945d	41 	A 
	nop			;945e	00 	. 
	inc b			;945f	04 	. 
	pop af			;9460	f1 	. 
	pop af			;9461	f1 	. 
	nop			;9462	00 	. 
	rlca			;9463	07 	. 
	ld b,c			;9464	41 	A 
	ld b,c			;9465	41 	A 
	nop			;9466	00 	. 
	dec b			;9467	05 	. 
	pop af			;9468	f1 	. 
	pop af			;9469	f1 	. 
	nop			;946a	00 	. 
	rlca			;946b	07 	. 
	ld b,c			;946c	41 	A 
	ld b,c			;946d	41 	A 
	pop af			;946e	f1 	. 
	pop af			;946f	f1 	. 
l9470h:
	nop			;9470	00 	. 
	inc b			;9471	04 	. 
	add a,c			;9472	81 	. 
	add a,c			;9473	81 	. 
	nop			;9474	00 	. 
	inc c			;9475	0c 	. 
	pop af			;9476	f1 	. 
	pop af			;9477	f1 	. 
	nop			;9478	00 	. 
	inc b			;9479	04 	. 
	add a,c			;947a	81 	. 
	add a,c			;947b	81 	. 
	nop			;947c	00 	. 
	jr z,l9470h		;947d	28 f1 	( . 
	pop af			;947f	f1 	. 
	nop			;9480	00 	. 
	jr l9404h		;9481	18 81 	. . 
	add a,c			;9483	81 	. 
	nop			;9484	00 	. 
	ld (hl),b			;9485	70 	p 
	pop af			;9486	f1 	. 
	pop af			;9487	f1 	. 
	nop			;9488	00 	. 
	rlca			;9489	07 	. 
	ld b,c			;948a	41 	A 
	ld b,c			;948b	41 	A 
	nop			;948c	00 	. 
	add hl,bc			;948d	09 	. 
	pop af			;948e	f1 	. 
	pop af			;948f	f1 	. 
	nop			;9490	00 	. 
	rlca			;9491	07 	. 
	ld b,c			;9492	41 	A 
	ld b,c			;9493	41 	A 
	pop af			;9494	f1 	. 
	pop af			;9495	f1 	. 
	nop			;9496	00 	. 
	inc b			;9497	04 	. 
	ld b,c			;9498	41 	A 
	ld b,c			;9499	41 	A 
	nop			;949a	00 	. 
	ld e,b			;949b	58 	X 
	pop af			;949c	f1 	. 
	pop af			;949d	f1 	. 
	nop			;949e	00 	. 
	inc b			;949f	04 	. 
	rst 38h			;94a0	ff 	. 
	rst 38h			;94a1	ff 	. 
	nop			;94a2	00 	. 
	ex af,af'			;94a3	08 	. 
	nop			;94a4	00 	. 
	nop			;94a5	00 	. 
	nop			;94a6	00 	. 
	ex af,af'			;94a7	08 	. 
	rst 38h			;94a8	ff 	. 
	rst 38h			;94a9	ff 	. 
	nop			;94aa	00 	. 
	djnz l94adh		;94ab	10 00 	. . 
l94adh:
	nop			;94ad	00 	. 
	nop			;94ae	00 	. 
	ex af,af'			;94af	08 	. 
	rst 38h			;94b0	ff 	. 
	rst 38h			;94b1	ff 	. 
	nop			;94b2	00 	. 
	ex af,af'			;94b3	08 	. 
	nop			;94b4	00 	. 
	nop			;94b5	00 	. 
	nop			;94b6	00 	. 
	djnz $+1		;94b7	10 ff 	. . 
	rst 38h			;94b9	ff 	. 
	nop			;94ba	00 	. 
	ex af,af'			;94bb	08 	. 
	nop			;94bc	00 	. 
	nop			;94bd	00 	. 
	nop			;94be	00 	. 
	ex af,af'			;94bf	08 	. 
	rst 38h			;94c0	ff 	. 
	rst 38h			;94c1	ff 	. 
	nop			;94c2	00 	. 
	ex af,af'			;94c3	08 	. 
	nop			;94c4	00 	. 
	nop			;94c5	00 	. 
	nop			;94c6	00 	. 
	ex af,af'			;94c7	08 	. 
	rst 38h			;94c8	ff 	. 
	rst 38h			;94c9	ff 	. 
	nop			;94ca	00 	. 
	ex af,af'			;94cb	08 	. 
	nop			;94cc	00 	. 
	nop			;94cd	00 	. 
	nop			;94ce	00 	. 
	ex af,af'			;94cf	08 	. 
	rst 38h			;94d0	ff 	. 
	rst 38h			;94d1	ff 	. 
	nop			;94d2	00 	. 
	djnz l94d5h		;94d3	10 00 	. . 
l94d5h:
	nop			;94d5	00 	. 
	nop			;94d6	00 	. 
	ex af,af'			;94d7	08 	. 
	rst 38h			;94d8	ff 	. 
	rst 38h			;94d9	ff 	. 
	nop			;94da	00 	. 
	ex af,af'			;94db	08 	. 
	nop			;94dc	00 	. 
	nop			;94dd	00 	. 
	nop			;94de	00 	. 
	djnz $+1		;94df	10 ff 	. . 
	rst 38h			;94e1	ff 	. 
	nop			;94e2	00 	. 
	ex af,af'			;94e3	08 	. 
	nop			;94e4	00 	. 
	nop			;94e5	00 	. 
	nop			;94e6	00 	. 
	ex af,af'			;94e7	08 	. 
	rst 38h			;94e8	ff 	. 
	rst 38h			;94e9	ff 	. 
	nop			;94ea	00 	. 
	djnz l94edh		;94eb	10 00 	. . 
l94edh:
	nop			;94ed	00 	. 
	nop			;94ee	00 	. 
	ex af,af'			;94ef	08 	. 
	rst 38h			;94f0	ff 	. 
	rst 38h			;94f1	ff 	. 
	nop			;94f2	00 	. 
	ex af,af'			;94f3	08 	. 
	nop			;94f4	00 	. 
	nop			;94f5	00 	. 
	nop			;94f6	00 	. 
	djnz $+1		;94f7	10 ff 	. . 
	rst 38h			;94f9	ff 	. 
	nop			;94fa	00 	. 
	ex af,af'			;94fb	08 	. 
	nop			;94fc	00 	. 
	nop			;94fd	00 	. 
	nop			;94fe	00 	. 
	ex af,af'			;94ff	08 	. 
	rst 38h			;9500	ff 	. 
	rst 38h			;9501	ff 	. 
	nop			;9502	00 	. 
	djnz l9505h		;9503	10 00 	. . 
l9505h:
	nop			;9505	00 	. 
	nop			;9506	00 	. 
	ex af,af'			;9507	08 	. 
	rst 38h			;9508	ff 	. 
	rst 38h			;9509	ff 	. 
	nop			;950a	00 	. 
	ex af,af'			;950b	08 	. 
	nop			;950c	00 	. 
	nop			;950d	00 	. 
	nop			;950e	00 	. 
	djnz $+1		;950f	10 ff 	. . 
	rst 38h			;9511	ff 	. 
	nop			;9512	00 	. 
	ex af,af'			;9513	08 	. 
	nop			;9514	00 	. 
	nop			;9515	00 	. 
	nop			;9516	00 	. 
	ex af,af'			;9517	08 	. 
	rst 38h			;9518	ff 	. 
	rst 38h			;9519	ff 	. 
	nop			;951a	00 	. 
	djnz l951dh		;951b	10 00 	. . 
l951dh:
	nop			;951d	00 	. 
	nop			;951e	00 	. 
	ex af,af'			;951f	08 	. 
	rst 38h			;9520	ff 	. 
	rst 38h			;9521	ff 	. 
	nop			;9522	00 	. 
	ex af,af'			;9523	08 	. 
	nop			;9524	00 	. 
	nop			;9525	00 	. 
	nop			;9526	00 	. 
	djnz $+1		;9527	10 ff 	. . 
	rst 38h			;9529	ff 	. 
	nop			;952a	00 	. 
	ex af,af'			;952b	08 	. 
	nop			;952c	00 	. 
	nop			;952d	00 	. 
	nop			;952e	00 	. 
	ex af,af'			;952f	08 	. 
	rst 38h			;9530	ff 	. 
	rst 38h			;9531	ff 	. 
	nop			;9532	00 	. 
	djnz l9535h		;9533	10 00 	. . 
l9535h:
	nop			;9535	00 	. 
	nop			;9536	00 	. 
	ex af,af'			;9537	08 	. 
	rst 38h			;9538	ff 	. 
	rst 38h			;9539	ff 	. 
	nop			;953a	00 	. 
	ex af,af'			;953b	08 	. 
	nop			;953c	00 	. 
	nop			;953d	00 	. 
	nop			;953e	00 	. 
	djnz $+1		;953f	10 ff 	. . 
	rst 38h			;9541	ff 	. 
	nop			;9542	00 	. 
	ex af,af'			;9543	08 	. 
	nop			;9544	00 	. 
	nop			;9545	00 	. 
	nop			;9546	00 	. 
	ex af,af'			;9547	08 	. 
	rst 38h			;9548	ff 	. 
	rst 38h			;9549	ff 	. 
	nop			;954a	00 	. 
	djnz l954dh		;954b	10 00 	. . 
l954dh:
	nop			;954d	00 	. 
	nop			;954e	00 	. 
	ex af,af'			;954f	08 	. 
	rst 38h			;9550	ff 	. 
	rst 38h			;9551	ff 	. 
	nop			;9552	00 	. 
	ex af,af'			;9553	08 	. 
	nop			;9554	00 	. 
	nop			;9555	00 	. 
	nop			;9556	00 	. 
	djnz $+1		;9557	10 ff 	. . 
	rst 38h			;9559	ff 	. 
	nop			;955a	00 	. 
	ex af,af'			;955b	08 	. 
	nop			;955c	00 	. 
	nop			;955d	00 	. 
	nop			;955e	00 	. 
	ex af,af'			;955f	08 	. 
	rst 38h			;9560	ff 	. 
	rst 38h			;9561	ff 	. 
	nop			;9562	00 	. 
	djnz l9565h		;9563	10 00 	. . 
l9565h:
	nop			;9565	00 	. 
	nop			;9566	00 	. 
	ex af,af'			;9567	08 	. 
	rst 38h			;9568	ff 	. 
	rst 38h			;9569	ff 	. 
	nop			;956a	00 	. 
	ex af,af'			;956b	08 	. 
	nop			;956c	00 	. 
	nop			;956d	00 	. 
	nop			;956e	00 	. 
	ex af,af'			;956f	08 	. 
	rst 38h			;9570	ff 	. 
	rst 38h			;9571	ff 	. 
	nop			;9572	00 	. 
	rst 38h			;9573	ff 	. 
	rst 38h			;9574	ff 	. 
	rst 38h			;9575	ff 	. 
	rst 38h			;9576	ff 	. 
	rst 38h			;9577	ff 	. 
	rst 38h			;9578	ff 	. 
	rst 38h			;9579	ff 	. 
	rst 38h			;957a	ff 	. 
	nop			;957b	00 	. 
	nop			;957c	00 	. 
	nop			;957d	00 	. 
	nop			;957e	00 	. 
	nop			;957f	00 	. 
	nop			;9580	00 	. 
	nop			;9581	00 	. 
	nop			;9582	00 	. 
	nop			;9583	00 	. 
	nop			;9584	00 	. 
	nop			;9585	00 	. 
	nop			;9586	00 	. 
	nop			;9587	00 	. 
	nop			;9588	00 	. 
	nop			;9589	00 	. 
	nop			;958a	00 	. 
	nop			;958b	00 	. 
	nop			;958c	00 	. 
	nop			;958d	00 	. 
	nop			;958e	00 	. 
	nop			;958f	00 	. 
	nop			;9590	00 	. 
	nop			;9591	00 	. 
	nop			;9592	00 	. 
	nop			;9593	00 	. 
	nop			;9594	00 	. 
	nop			;9595	00 	. 
	nop			;9596	00 	. 
	nop			;9597	00 	. 
	nop			;9598	00 	. 
	nop			;9599	00 	. 
	nop			;959a	00 	. 
	ld d,b			;959b	50 	P 
	ld d,l			;959c	55 	U 
	ld d,e			;959d	53 	S 
	ld c,b			;959e	48 	H 
	nop			;959f	00 	. 
	ld d,e			;95a0	53 	S 
	ld d,b			;95a1	50 	P 
sub_95a2h:
	ld b,c			;95a2	41 	A 
	ld b,e			;95a3	43 	C 
	ld b,l			;95a4	45 	E 
	nop			;95a5	00 	. 
	ld c,e			;95a6	4b 	K 
	ld b,l			;95a7	45 	E 
	ld e,c			;95a8	59 	Y 
	nop			;95a9	00 	. 
	nop			;95aa	00 	. 
	nop			;95ab	00 	. 
	nop			;95ac	00 	. 
	nop			;95ad	00 	. 
	nop			;95ae	00 	. 
	nop			;95af	00 	. 
	nop			;95b0	00 	. 
	nop			;95b1	00 	. 
	nop			;95b2	00 	. 
	nop			;95b3	00 	. 
	nop			;95b4	00 	. 
	nop			;95b5	00 	. 
	nop			;95b6	00 	. 
	nop			;95b7	00 	. 
	nop			;95b8	00 	. 
	nop			;95b9	00 	. 
	nop			;95ba	00 	. 
	nop			;95bb	00 	. 
	nop			;95bc	00 	. 
	nop			;95bd	00 	. 
	nop			;95be	00 	. 
	nop			;95bf	00 	. 
	nop			;95c0	00 	. 
	nop			;95c1	00 	. 
	nop			;95c2	00 	. 
	nop			;95c3	00 	. 
	nop			;95c4	00 	. 
	nop			;95c5	00 	. 
	nop			;95c6	00 	. 
	nop			;95c7	00 	. 
	nop			;95c8	00 	. 
	nop			;95c9	00 	. 
	nop			;95ca	00 	. 
	nop			;95cb	00 	. 
	nop			;95cc	00 	. 
	nop			;95cd	00 	. 
	nop			;95ce	00 	. 
	nop			;95cf	00 	. 
	nop			;95d0	00 	. 
	nop			;95d1	00 	. 
	nop			;95d2	00 	. 
	nop			;95d3	00 	. 
	nop			;95d4	00 	. 
	nop			;95d5	00 	. 
	nop			;95d6	00 	. 
	nop			;95d7	00 	. 
	nop			;95d8	00 	. 
	nop			;95d9	00 	. 
	nop			;95da	00 	. 
	nop			;95db	00 	. 
	nop			;95dc	00 	. 
	nop			;95dd	00 	. 
	nop			;95de	00 	. 
	nop			;95df	00 	. 
	nop			;95e0	00 	. 
	nop			;95e1	00 	. 
	nop			;95e2	00 	. 
	nop			;95e3	00 	. 
	nop			;95e4	00 	. 
	nop			;95e5	00 	. 
	nop			;95e6	00 	. 
	nop			;95e7	00 	. 
	nop			;95e8	00 	. 
	nop			;95e9	00 	. 
	nop			;95ea	00 	. 
	nop			;95eb	00 	. 
	nop			;95ec	00 	. 
	nop			;95ed	00 	. 
	nop			;95ee	00 	. 
	nop			;95ef	00 	. 
	nop			;95f0	00 	. 
	nop			;95f1	00 	. 
	or a			;95f2	b7 	. 
	nop			;95f3	00 	. 
sub_95f4h:
	call sub_b137h		;95f4	cd 37 b1 	. 7 . 
	call sub_b15ch		;95f7	cd 5c b1 	. \ . 
	call BALL_MOVEMENT_STEP		;95fa	cd 72 98 	. r . 
	call sub_97eah		;95fd	cd ea 97 	. . . 
	call sub_9726h		;9600	cd 26 97 	. & . 
	ret			;9603	c9 	. 
	ld hl,0e36eh		;9604	21 6e e3 	! n . 
	ld a,(BRICK_ROW)		;9607	3a aa e2 	: . . 
	or a			;960a	b7 	. 
	jr z,l9622h		;960b	28 15 	( . 
	ld l,a			;960d	6f 	o 
	ld h,000h		;960e	26 00 	& . 
	add hl,hl			;9610	29 	) 
	add hl,hl			;9611	29 	) 
	add hl,hl			;9612	29 	) 
	ld c,a			;9613	4f 	O 
	sla c		;9614	cb 21 	. ! 
	ld b,000h		;9616	06 00 	. . 
	add hl,bc			;9618	09 	. 
	ld e,a			;9619	5f 	_ 
	ld d,000h		;961a	16 00 	. . 
	add hl,de			;961c	19 	. 
	add hl,hl			;961d	29 	) 
	ld de,0e36eh		;961e	11 6e e3 	. n . 
	add hl,de			;9621	19 	. 
l9622h:
	ld a,(BRICK_COL)		;9622	3a ab e2 	: . . 
	ld e,a			;9625	5f 	_ 
	sla e		;9626	cb 23 	. # 
	ld d,000h		;9628	16 00 	. . 
	add hl,de			;962a	19 	. 
	ld a,(hl)			;962b	7e 	~ 
	ld c,000h		;962c	0e 00 	. . 
	cp 023h		;962e	fe 23 	. # 
	jr z,l9672h		;9630	28 40 	( @ 
	ld c,006h		;9632	0e 06 	. . 
	cp 025h		;9634	fe 25 	. % 
	jr z,l9672h		;9636	28 3a 	( : 
	ld c,002h		;9638	0e 02 	. . 
	cp 027h		;963a	fe 27 	. ' 
	jr z,l9672h		;963c	28 34 	( 4 
	ld c,003h		;963e	0e 03 	. . 
	cp 029h		;9640	fe 29 	. ) 
	jr z,l9672h		;9642	28 2e 	( . 
	ld c,004h		;9644	0e 04 	. . 
	cp 05ch		;9646	fe 5c 	. \ 
	jr z,l9672h		;9648	28 28 	( ( 
	ld c,005h		;964a	0e 05 	. . 
	cp 05eh		;964c	fe 5e 	. ^ 
	jr z,l9672h		;964e	28 22 	( " 
	ld c,001h		;9650	0e 01 	. . 
	cp 061h		;9652	fe 61 	. a 
	jr z,l9672h		;9654	28 1c 	( . 
	ld c,007h		;9656	0e 07 	. . 
	cp 063h		;9658	fe 63 	. c 
	jr z,l9672h		;965a	28 16 	( . 
	cp 065h		;965c	fe 65 	. e 
	ret nz			;965e	c0 	. 
	ld a,(LEVEL)		;965f	3a 1b e0 	: . . 
	and 0f8h		;9662	e6 f8 	. . 
	srl a		;9664	cb 3f 	. ? 
	srl a		;9666	cb 3f 	. ? 
	srl a		;9668	cb 3f 	. ? 
	ld l,a			;966a	6f 	o 
	ld h,000h		;966b	26 00 	& . 
	ld de,l9677h		;966d	11 77 96 	. w . 
	add hl,de			;9670	19 	. 
	ld c,(hl)			;9671	4e 	N 
l9672h:
	ld a,c			;9672	79 	y 
	call sub_52a0h		;9673	cd a0 52 	. . R 
	ret			;9676	c9 	. 
l9677h:
	ex af,af'			;9677	08 	. 
	add hl,bc			;9678	09 	. 
	ld a,(bc)			;9679	0a 	. 
	dec bc			;967a	0b 	. 
sub_967bh:
	ld a,(iy+000h)		;967b	fd 7e 00 	. ~ . 
	or a			;967e	b7 	. 
	ret z			;967f	c8 	. 
	ld a,(ix+000h)		;9680	dd 7e 00 	. ~ . 
	cp 013h		;9683	fe 13 	. . 
	ret c			;9685	d8 	. 
	cp 078h		;9686	fe 78 	. x 
	ret nc			;9688	d0 	. 
	ld a,(ix+001h)		;9689	dd 7e 01 	. ~ . 
	cp 04ch		;968c	fe 4c 	. L 
	ret c			;968e	d8 	. 
	cp 081h		;968f	fe 81 	. . 
	ret nc			;9691	d0 	. 
	ld a,(ix+001h)		;9692	dd 7e 01 	. ~ . 
	sub (iy+003h)		;9695	fd 96 03 	. . . 
	cp 04dh		;9698	fe 4d 	. M 
	jr c,l96b9h		;969a	38 1d 	8 . 
	cp 080h		;969c	fe 80 	. . 
	jr nc,l96c8h		;969e	30 28 	0 ( 
	ld a,(ix+000h)		;96a0	dd 7e 00 	. ~ . 
	sub (iy+002h)		;96a3	fd 96 02 	. . . 
	cp 013h		;96a6	fe 13 	. . 
	jr c,l96d7h		;96a8	38 2d 	8 - 
	ld a,(iy+002h)		;96aa	fd 7e 02 	. ~ . 
	bit 7,a		;96ad	cb 7f 	.  
	ret z			;96af	c8 	. 
	call sub_9b5bh		;96b0	cd 5b 9b 	. [ . 
	ld (ix+000h),077h		;96b3	dd 36 00 77 	. 6 . w 
	jr l96e4h		;96b7	18 2b 	. + 
l96b9h:
	ld a,(iy+003h)		;96b9	fd 7e 03 	. ~ . 
	bit 7,a		;96bc	cb 7f 	.  
	ret nz			;96be	c0 	. 
	call sub_9b80h		;96bf	cd 80 9b 	. . . 
	ld (ix+001h),04bh		;96c2	dd 36 01 4b 	. 6 . K 
	jr l96e4h		;96c6	18 1c 	. . 
l96c8h:
	ld a,(iy+003h)		;96c8	fd 7e 03 	. ~ . 
	bit 7,a		;96cb	cb 7f 	.  
	ret z			;96cd	c8 	. 
	call sub_9b80h		;96ce	cd 80 9b 	. . . 
	ld (ix+001h),081h		;96d1	dd 36 01 81 	. 6 . . 
	jr l96e4h		;96d5	18 0d 	. . 
l96d7h:
	ld a,(iy+002h)		;96d7	fd 7e 02 	. ~ . 
	bit 7,a		;96da	cb 7f 	.  
	ret nz			;96dc	c0 	. 
	call sub_9b5bh		;96dd	cd 5b 9b 	. [ . 
	ld (ix+000h),012h		;96e0	dd 36 00 12 	. 6 . . 
l96e4h:
	ld a,008h		;96e4	3e 08 	> . 
	call sub_5befh		;96e6	cd ef 5b 	. . [ 
	ld a,001h		;96e9	3e 01 	> . 
	ld (0e2b9h),a		;96eb	32 b9 e2 	2 . . 

    ; Increment Doh hits
    ; Doh is defeated if hit 16 times
	ld ix,DOH_HITS		;96ee	dd 21 b3 e5
	inc (ix+000h)		;96f2	dd 34 00
	ld a,(ix+000h)		;96f5	dd 7e 00
	cp 16		        ;96f8	fe 10
	jr nz,l970ah		;96fa	20 0e

    ; Doh has been defeated!
	ld a,001h		;96fc	3e 01 	> . 
	ld (0e50dh),a		;96fe	32 0d e5 	2 . . 
	call DEACTIVE_ALL_BALLS		;9701	cd 10 97 	. . . 
	ld a,009h		;9704	3e 09 	> . 
	call sub_5befh		;9706	cd ef 5b 	. . [ 
	ret			;9709	c9 	. 
l970ah:
	ld a,001h		;970a	3e 01 	> . 
	ld (0e505h),a		;970c	32 05 e5 	2 . . 
	ret			;970f	c9 	. 

; Deactivate all the balls and set the sprites invisible
DEACTIVE_ALL_BALLS:
    ; Set all three balls inactive
	xor a			        ;9710	af
	ld (BALL_TABLE1),a		;9711	32 4e e2
	ld (BALL_TABLE2),a		;9714	32 62 e2
	ld (BALL_TABLE3),a		;9717	32 76 e2

    ; Set the three sprites invisible (Y position 192)
	ld a, 192		    ;971a	3e c0
	ld (BALL1_SPR_PARAMS),a		;971c	32 f5 e0
	ld (BALL2_SPR_PARAMS),a		;971f	32 f9 e0
	ld (BALL3_SPR_PARAMS),a		;9722	32 fd e0
	ret			        ;9725	c9

sub_9726h:
	ld a,(LEVEL)		;9726	3a 1b e0
	cp FINAL_LEVEL		;9729	fe 20
	ret z			    ;972b	c8
	xor a			;972c	af 	. 
	ld (0e53ch),a		;972d	32 3c e5 	2 < . 
	ld iy,ALIEN_TABLE		;9730	fd 21 c7 e4 	. ! . . 
	ld ix,TABLE_UNKNOWN_1		;9734	dd 21 01 e1 	. ! . . 
l9738h:
	ld a,(iy+001h)		;9738	fd 7e 01 	. ~ . 
	or a			;973b	b7 	. 
	jr z,l979bh		;973c	28 5d 	( ] 
	ld a,(iy+002h)		;973e	fd 7e 02 	. ~ . 
	cp 001h		;9741	fe 01 	. . 
	jr z,l979bh		;9743	28 56 	( V 
	ld a,(iy+013h)		;9745	fd 7e 13 	. ~ . 
	cp 001h		;9748	fe 01 	. . 
	jr z,l979bh		;974a	28 4f 	( O 
	ld e,008h		;974c	1e 08 	. . 
	bit 7,(iy+008h)		;974e	fd cb 08 7e 	. . . ~ 
	jr z,l9756h		;9752	28 02 	( . 
	ld e,020h		;9754	1e 20 	.   
l9756h:
	ld a,(ix+000h)		;9756	dd 7e 00 	. ~ . 
	sub e			;9759	93 	. 
	srl a		;975a	cb 3f 	. ? 
	srl a		;975c	cb 3f 	. ? 
	srl a		;975e	cb 3f 	. ? 
	cp 00ch		;9760	fe 0c 	. . 
	jr nc,l979bh		;9762	30 37 	0 7 
	ld (BRICK_ROW),a		;9764	32 aa e2 	2 . . 
	ld a,(ix+001h)		;9767	dd 7e 01 	. ~ . 
	sub 010h		;976a	d6 10 	. . 
	srl a		;976c	cb 3f 	. ? 
	srl a		;976e	cb 3f 	. ? 
	srl a		;9770	cb 3f 	. ? 
	srl a		;9772	cb 3f 	. ? 
	cp 00bh		;9774	fe 0b 	. . 
	jr nc,l979bh		;9776	30 23 	0 # 
	ld (BRICK_COL),a		;9778	32 ab e2 	2 . . 
	ld a,(ix+000h)		;977b	dd 7e 00 	. ~ . 
	cp 064h		;977e	fe 64 	. d 
	jr c,l9786h		;9780	38 04 	8 . 
	ld (iy+013h),001h		;9782	fd 36 13 01 	. 6 . . 
l9786h:
	push iy		;9786	fd e5 	. . 
	push ix		;9788	dd e5 	. . 
	call sub_ada8h		;978a	cd a8 ad 	. . . 
	pop ix		;978d	dd e1 	. . 
	pop iy		;978f	fd e1 	. . 
	jr nc,l979bh		;9791	30 08 	0 . 
	ld a,(iy+008h)		;9793	fd 7e 08 	. ~ . 
	neg		;9796	ed 44 	. D 
	ld (iy+008h),a		;9798	fd 77 08 	. w . 
l979bh:
	ld de,00014h		;979b	11 14 00 	. . . 
	add iy,de		;979e	fd 19 	. . 
	ld de,00004h		;97a0	11 04 00 	. . . 
	add ix,de		;97a3	dd 19 	. . 
	ld hl,0e53ch		;97a5	21 3c e5 	! < . 
	inc (hl)			;97a8	34 	4 
	ld a,(hl)			;97a9	7e 	~ 
	cp 003h		;97aa	fe 03 	. . 
	jr nz,l9738h		;97ac	20 8a 	  . 
	ret			;97ae	c9 	. 
sub_97afh:
	push ix		;97af	dd e5 	. . 
	ld b,008h		;97b1	06 08 	. . 
	ld de,00008h		;97b3	11 08 00 	. . . 
	ld ix,0e20dh		;97b6	dd 21 0d e2 	. ! . . 
l97bah:
	ld a,(ix+000h)		;97ba	dd 7e 00 	. ~ . 
	or a			;97bd	b7 	. 
	jr z,l97c6h		;97be	28 06 	( . 
	add ix,de		;97c0	dd 19 	. . 
	djnz l97bah		;97c2	10 f6 	. . 
	jr l97e7h		;97c4	18 21 	. ! 
l97c6h:
	ld (ix+000h),001h		;97c6	dd 36 00 01 	. 6 . . 
	ld (ix+001h),c		;97ca	dd 71 01 	. q . 
	ld (ix+002h),l		;97cd	dd 75 02 	. u . 
	ld (ix+003h),h		;97d0	dd 74 03 	. t . 
	ld (ix+004h),000h		;97d3	dd 36 04 00 	. 6 . . 
	ld (ix+005h),000h		;97d7	dd 36 05 00 	. 6 . . 
	ld a,(0e53ch)		;97db	3a 3c e5 	: < . 
	ld (ix+006h),a		;97de	dd 77 06 	. w . 
	ld a,(0e53dh)		;97e1	3a 3d e5 	: = . 
	ld (ix+007h),a		;97e4	dd 77 07 	. w . 
l97e7h:
	pop ix		;97e7	dd e1 	. . 
	ret			;97e9	c9 	. 
sub_97eah:
	ld a,(LEVEL)		;97ea	3a 1b e0
	cp FINAL_LEVEL		;97ed	fe 20
	ret z			;97ef	c8 	. 
	ld b,008h		;97f0	06 08 	. . 
	ld de,00008h		;97f2	11 08 00 	. . . 
	ld ix,0e20dh		;97f5	dd 21 0d e2 	. ! . . 
l97f9h:
	push bc			;97f9	c5 	. 
	ld a,(ix+000h)		;97fa	dd 7e 00 	. ~ . 
	or a			;97fd	b7 	. 
	jr z,l9859h		;97fe	28 59 	( Y 
	inc (ix+004h)		;9800	dd 34 04 	. 4 . 
	ld a,(ix+004h)		;9803	dd 7e 04 	. ~ . 
	cp 002h		;9806	fe 02 	. . 
	jr nz,l9859h		;9808	20 4f 	  O 
	ld (ix+004h),000h		;980a	dd 36 04 00 	. 6 . . 
	ld de,l986ah		;980e	11 6a 98 	. j . 
	bit 0,(ix+001h)		;9811	dd cb 01 46 	. . . F 
	jr nz,l981ah		;9815	20 03 	  . 
	ld de,l9862h		;9817	11 62 98 	. b . 
l981ah:
	ld l,(ix+005h)		;981a	dd 6e 05 	. n . 
	ld h,000h		;981d	26 00 	& . 
	add hl,hl			;981f	29 	) 
	add hl,de			;9820	19 	. 
	ld e,(ix+002h)		;9821	dd 5e 02 	. ^ . 
	ld d,(ix+003h)		;9824	dd 56 03 	. V . 
	ld bc,00002h		;9827	01 02 00 	. . . 
	call LDIRVM		;982a	cd 5c 00 	. \ . 
	inc (ix+005h)		;982d	dd 34 05 	. 4 . 
	ld a,(ix+005h)		;9830	dd 7e 05 	. ~ . 
	cp 004h		;9833	fe 04 	. . 
	jr nz,l9859h		;9835	20 22 	  " 
	ld a,(ix+006h)		;9837	dd 7e 06 	. ~ . 
	ld (BRICK_ROW),a		;983a	32 aa e2 	2 . . 
	ld a,(ix+007h)		;983d	dd 7e 07 	. ~ . 
	ld (BRICK_COL),a		;9840	32 ab e2 	2 . . 
	call sub_ada8h		;9843	cd a8 ad 	. . . 
	jr c,l984bh		;9846	38 03 	8 . 
	call ERASE_BRICK		;9848	cd 8f ab 	. . . 
l984bh:
	push ix		;984b	dd e5 	. . 
	push ix		;984d	dd e5 	. . 
	pop hl			;984f	e1 	. 
	pop de			;9850	d1 	. 
	inc de			;9851	13 	. 
	ld bc,00007h		;9852	01 07 00 	. . . 
	ld (hl),000h		;9855	36 00 	6 . 
	ldir		;9857	ed b0 	. . 
l9859h:
	pop bc			;9859	c1 	. 
	ld de,00008h		;985a	11 08 00 	. . . 
	add ix,de		;985d	dd 19 	. . 
	djnz l97f9h		;985f	10 98 	. . 
	ret			;9861	c9 	. 
l9862h:
	ld h,l			;9862	65 	e 
	ld l,h			;9863	6c 	l 
	ld l,e			;9864	6b 	k 
	ld l,h			;9865	6c 	l 
	ld l,e			;9866	6b 	k 
	ld h,(hl)			;9867	66 	f 
	ld h,l			;9868	65 	e 
	ld h,(hl)			;9869	66 	f 
l986ah:
	ld h,a			;986a	67 	g 
	ld l,h			;986b	6c 	l 
	ld l,e			;986c	6b 	k 
	ld l,h			;986d	6c 	l 
	ld l,e			;986e	6b 	k 
	ld l,b			;986f	68 	h 
	ld h,a			;9870	67 	g 
	ld l,b			;9871	68 	h

; Perform one step of the ball movement
BALL_MOVEMENT_STEP:
	xor a			;9872	af 	. 
	ld (BALL_LOOP_INDEX),a		;9873	32 ac e2 	2 . . 

	ld ix,BALL1_SPR_PARAMS		;9876	dd 21 f5 e0 	. ! . . 
	ld iy,BALL_TABLE1		;987a	fd 21 4e e2 	. ! N . 
l987eh:
	push ix		        ;987e	dd e5
	push iy		        ;9880	fd e5

    ; Skip if the ball is not active
	ld a,(iy+BALL_TABLE_IDX_ACTIVE)		;9882	fd 7e 00
	or a			                    ;9885	b7
	jp z,l99b8h		                    ;9886	ca b8 99

    ; HL = 2*BALL_X
	ld l,(iy+BALL_SPR_PARAMS_IDX_X)		;9889	fd 6e 01
	ld h, 0		                        ;988c	26 00
	add hl,hl			                ;988e	29

	; HL = ACTION_TABLE + 2*BALL_X
    ld de,ACTION_TABLE		                ;988f	11 98 98
	add hl,de			                ;9892	19
    
    ;  DE = ACTION_TABLE[2*BALL_X]
	ld e,(hl)			;9893	5e
	inc hl			    ;9894	23
	ld d,(hl)			;9895	56
    
    ; HL = ACTION_TABLE[2*BALL_X]
	ex de,hl			;9896	eb
    
    ; Jump to ACTION_TABLE[2*BALL_X]
	jp (hl)			    ;9897	e9
ACTION_TABLE:
    dw ACTION_989E
    dw ACTION_98F8
    dw ACTION_9941

; Initialize ball for the level start
ACTION_989E:
    ; iy = BALL_TABLE1
    ; ix = BALL_SPR_PARAMS_IDX_Y
	ld (ix+BALL_SPR_PARAMS_IDX_Y), 169		;                    989e	dd 36 00 a9
    ; The other two balls are invisible at row 192
	ld (ix+BALL_SPR_PARAMS_IDX_Y + 1*BALL_SPR_PARAMS_LEN), 192  ;98a2	dd 36 04 c0
	ld (ix+BALL_SPR_PARAMS_IDX_Y + 2*BALL_SPR_PARAMS_LEN), 192  ;98a6	dd 36 08 c0

	ld (iy+16),  26  ;98aa	fd 36 10 1a

    ; Configure sprite of the ball
	ld (ix+BALL_SPR_PARAMS_IDX_PATTERN_NUM), 0x80   ;98ae	dd 36 02 80
	ld (ix+BALL_SPR_PARAMS_IDX_COLOR), 15	        ;98b2	dd 36 03 0f     White color

	ld (iy+BALL_TABLE_IDX_GLUE),1	                ;98b6	fd 36 01 01     Ball is glued
	
    ; Initialize glue timer
    ld (iy+BALL_TABLE_IDX_GLUE_COUNTER), 120	    ;98ba	fd 36 0e 78
    
    ; Set direction
	ld (iy+BALL_TABLE_IDX_SKEWNESS),3              ;98be	fd 36 06 03
	ld (iy+BALL_TABLE_IDX_VERT), 0xff		        ;98c2	fd 36 02 ff Ball moves UP

    ; A = SPEED_TABLE_POSITIONS[LEVEL]
	ld a,(LEVEL)		            ;98c6	3a 1b e0
	ld l,a			                ;98c9	6f
	ld h, 0		                    ;98ca	26 00
	ld de,SPEED_TABLE_POSITIONS		;98cc	11 d7 98
	add hl,de			            ;98cf	19
	ld a,(hl)			            ;98d0	7e
    
    ; Set the position for the speed table
    ; It's slightly faster for the second half of the levels!
	ld (iy+BALL_TABLE_IDX_SPEED_POS),a		;98d1	fd 77 07
	jp l99b8h		                        ;98d4	c3 b8 99
SPEED_TABLE_POSITIONS:
    db 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12
    db 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13

; This one deals with the glue state
ACTION_98F8:
    ; Skip the following if we're at the title screen
	ld a,(GAME_STATE)		;98f8	3a 0b e0
	or a			        ;98fb	b7
	jp z,l9935h		        ;98fc	ca 35 99

	ld a,(0e00ch)		;98ff	3a 0c e0 	: . . 
	or a			;9902	b7 	. 
	jp z,l9910h		;9903	ca 10 99 	. . . 
	ld a,(0e0c5h)		;9906	3a c5 e0 	: . . 
	bit 1,a		;9909	cb 4f 	. O 
	jr nz,l9935h		;990b	20 28 	  ( 
	jp l9917h		;990d	c3 17 99 	. . . 
l9910h:
	ld a,(0e0bfh)		;9910	3a bf e0 	: . . 
	bit 4,a		;9913	cb 67 	. g 
	jr nz,l9935h		;9915	20 1e 	  . 
l9917h:
    ; Decrement the glue timer
	dec (iy+BALL_TABLE_IDX_GLUE_COUNTER)	;9917	fd 35 0e
	jr z,l9935h		                        ;991a	28 19

	ld hl,0e324h		;991c	21 24 e3 	! $ . 
	bit 1,(hl)		;991f	cb 4e 	. N 
	jp nz,l9930h		;9921	c2 30 99 	. 0 . 
	ld a,(VAUS_X)		;9924	3a ce e0 	: . . 
	add a,(iy+010h)		;9927	fd 86 10 	. . . 
	ld (ix+001h),a		;992a	dd 77 01 	. w . 
	jp l99b8h		;992d	c3 b8 99 	. . . 
l9930h:
	ld a,000h		;9930	3e 00 	> . 
	ld (0e324h),a		;9932	32 24 e3 	2 $ . 
l9935h:
	ld (iy+BALL_TABLE_IDX_GLUE), 2		;9935	fd 36 01 02     Ball moves normally

	ld a,001h		;9939	3e 01 	> . 
	call sub_5befh		;993b	cd ef 5b 	. . [ 
	jp l99b8h		;993e	c3 b8 99 	. . . 

; And this one with bouncing when reaching the limits of the playfield
ACTION_9941:
    ; iy = BALL_TABLE1
    ; ix = BALL_SPR_PARAMS_IDX_Y

	call sub_99dfh		;9941	cd df 99 	. . . 

    ; Go on if the ball is active
	ld a,(iy+BALL_TABLE_IDX_ACTIVE)		;9944	fd 7e 00
	or a			                    ;9947	b7
	jp z,l99b8h		                    ;9948	ca b8 99

	ld a,(ix+BALL_SPR_PARAMS_IDX_X)		;994b	dd 7e 01
    
    ; Check if it's moving right
	bit 7,(iy+BALL_TABLE_IDX_HORIZ)		;994e	fd cb 03 7e     Z if RIGHT
	jp nz,l996bh		            ;9952	c2 6b 99 Moving left, skip
    
    ; It's moving right, compare with 186 (right border)
	cp 186		                    ;9955	fe ba
	jp c,l996bh		                ;9957	da 6b 99    It's less than 186, jump
    
    ; It's moving right with X > 186
	call UPDATE_BALL_SPEED		;995a	cd f0 9a
	call sub_9b80h		        ;995d	cd 80 9b
    
    ; Set the position to 185
	ld a, 185		            ;9960	3e b9
	ld (ix+BALL_SPR_PARAMS_IDX_X),a		;9962	dd 77 01

	call sub_99d1h		;9965	cd d1 99 	. . . 
	jp l9985h		;9968	c3 85 99 	. . . 

l996bh:
    ; Check if the ball is moving right
	bit 7,(iy+BALL_TABLE_IDX_HORIZ)		;996b	fd cb 03 7e     Z if RIGHT
	jp z,l9985h		                ;996f	ca 85 99    Jump if it's moving RIGHT
    
    ; It's moving left
    ; Compare with 18 (left border)
	cp 18		        ;9972	fe 1
	jp nc,l9985h		;9974	d2 85 99    It's more than 18, skip
    
    ; It's touched the left border
	call UPDATE_BALL_SPEED		;9977	cd f0 9a
	call sub_9b80h		        ;997a	cd 80 9b

    ; Set the position to 18
	ld a, 18		            ;997d	3e 12
	ld (ix+BALL_SPR_PARAMS_IDX_X),a  ;997f	dd 77 01

	call sub_99d1h		        ;9982	cd d1 99
l9985h:
	ld a,(ix+BALL_SPR_PARAMS_IDX_Y)		;9985	dd 7e 00

	bit 7,(iy+BALL_TABLE_IDX_VERT)		    ;9988	fd cb 02 7e     Z if moving DOWN
	jp z,l99a2h		                    ;998c	ca a2 99        Moving down, skip
    
    ; Moving up
    cp 9		        ;998f	fe 09
	jp nc,l99a2h		;9991	d2 a2 99    More than 9, skip
    
    ; Has touched the ceiling
	call UPDATE_BALL_SPEED		;9994	cd f0 9a
	call sub_9b5bh		        ;9997	cd 5b 9b
    
    ; Set position to 9
	ld a,9		                ;999a	3e 09
	ld (ix+BALL_SPR_PARAMS_IDX_Y),a		;999c	dd 77 00

	call sub_99d1h		                ;999f	cd d1 99
l99a2h:
	push ix		;99a2	dd e5 	. . 
	push iy		;99a4	fd e5 	. . 
	call sub_9ba8h		;99a6	cd a8 9b 	. . . 
	pop iy		;99a9	fd e1 	. . 
	pop ix		;99ab	dd e1 	. . 

	ld a,(ix+BALL_SPR_PARAMS_IDX_Y)		;99ad	dd 7e 00
	cp 184		                        ;99b0	fe b8
	jp c,l99b8h		                    ;99b2	da b8 99 Jump if Y < 184
    
    ; Y > 184: ball lost!
	call sub_9b2ah		;99b5	cd 2a 9b 	. * . 
l99b8h:
	pop iy		                    ;99b8	fd e1
	pop ix		                    ;99ba	dd e1

    ; Next ball (spr)
	ld de,BALL_SPR_PARAMS_LEN		;99bc	11 04 00
	add ix,de		                ;99bf	dd 19

    ; Next ball
	ld de,BALL_TABLE_LEN		    ;99c1	11 14 00
	add iy,de		                ;99c4	fd 19

    ; Ball done
	ld hl,BALL_LOOP_INDEX		    ;99c6	21 ac e2
	inc (hl)			            ;99c9	34 	4 

    ; All 3 balls done?
	ld a,(hl)			            ;99ca	7e
	cp 3		                    ;99cb	fe 03
	jp nz,l987eh		            ;99cd	c2 7e 98 No, do next one
    ; Yes, all done
	ret			                    ;99d0	c9

sub_99d1h:
	ld hl,0e51ch		;99d1	21 1c e5 	! . . 
	inc (hl)			;99d4	34 	4 
	ld a,(hl)			;99d5	7e 	~ 
	cp 028h		;99d6	fe 28 	. ( 
	ret nz			;99d8	c0 	. 
	ld (hl),000h		;99d9	36 00 	6 . 
	call sub_ab38h		;99db	cd 38 ab 	. 8 . 
	ret			;99de	c9 	. 
sub_99dfh:
	ld hl,l9a98h		;99df	21 98 9a 	! . . 
	ld a,(iy+006h)		;99e2	fd 7e 06 	. ~ . 
	bit 7,a		;99e5	cb 7f 	.  
	jr z,l99ebh		;99e7	28 02 	( . 
	neg		;99e9	ed 44 	. D 
l99ebh:
	sla a		;99eb	cb 27 	. ' 
	ld e,a			;99ed	5f 	_ 
	ld d,000h		;99ee	16 00 	. . 
	add hl,de			;99f0	19 	. 
	ld e,(hl)			;99f1	5e 	^ 
	inc hl			;99f2	23 	# 
	ld d,(hl)			;99f3	56 	V 
	ld l,(iy+007h)		;99f4	fd 6e 07 	. n . 
	ld h,000h		;99f7	26 00 	& . 
	add hl,hl			;99f9	29 	) 
	add hl,de			;99fa	19 	. 
	ld a,(hl)			;99fb	7e 	~ 
	ld (iy+008h),a		;99fc	fd 77 08 	. w . 
	inc hl			;99ff	23 	# 
	ld a,(hl)			;9a00	7e 	~ 
	ld (iy+009h),a		;9a01	fd 77 09 	. w . 
	inc (iy+005h)		;9a04	fd 34 05 	. 4 . 
	ld a,(iy+005h)		;9a07	fd 7e 05 	. ~ . 
	cp (iy+009h)		;9a0a	fd be 09 	. . . 
	ret c			;9a0d	d8 	. 
	ld (iy+005h),000h		;9a0e	fd 36 05 00 	. 6 . . 
	ld hl,l9a78h		;9a12	21 78 9a 	! x . 
	ld a,(iy+006h)		;9a15	fd 7e 06 	. ~ . 
	bit 7,a		;9a18	cb 7f 	.  
	jp z,l9a22h		;9a1a	ca 22 9a 	. " . 
	neg		;9a1d	ed 44 	. D 
	ld hl,09a88h		;9a1f	21 88 9a 	! . . 
l9a22h:
	dec a			;9a22	3d 	= 
	sla a		;9a23	cb 27 	. ' 
	ld e,a			;9a25	5f 	_ 
	ld d,000h		;9a26	16 00 	. . 
	add hl,de			;9a28	19 	. 
	ld a,(hl)			;9a29	7e 	~ 
	ld (iy+002h),a		;9a2a	fd 77 02 	. w . 
	inc hl			;9a2d	23 	# 
	ld a,(hl)			;9a2e	7e 	~ 
	ld (iy+003h),a		;9a2f	fd 77 03 	. w . 
	ld b,(iy+008h)		;9a32	fd 46 08 	. F . 
	inc b			;9a35	04 	. 
l9a36h:
	ld a,(iy+002h)		;9a36	fd 7e 02 	. ~ . 
	add a,(ix+000h)		;9a39	dd 86 00 	. . . 
	ld (ix+000h),a		;9a3c	dd 77 00 	. w . 
	ld a,(iy+003h)		;9a3f	fd 7e 03 	. ~ . 
	add a,(ix+001h)		;9a42	dd 86 01 	. . . 
	ld (ix+001h),a		;9a45	dd 77 01 	. w . 
	xor a			;9a48	af 	. 
	ld (0e2b9h),a		;9a49	32 b9 e2 	2 . . 
	push bc			;9a4c	c5 	. 
	push ix		;9a4d	dd e5 	. . 
	push iy		;9a4f	fd e5 	. . 
	ld a,(LEVEL)		;9a51	3a 1b e0
	cp FINAL_LEVEL		;9a54	fe 20
	jr nz,l9a5dh		;9a56	20 05 	  . 
	call sub_967bh		;9a58	cd 7b 96 	. { . 
	jr l9a60h		;9a5b	18 03 	. . 
l9a5dh:
	call sub_9c2dh		;9a5d	cd 2d 9c 	. - . 
l9a60h:
	pop iy		;9a60	fd e1 	. . 
	pop ix		;9a62	dd e1 	. . 
	pop bc			;9a64	c1 	. 
	ld a,(0e2b9h)		;9a65	3a b9 e2 	: . . 
	or a			;9a68	b7 	. 
	ret nz			;9a69	c0 	. 
	djnz l9a36h		;9a6a	10 ca 	. . 
	push iy		;9a6c	fd e5 	. . 
	push ix		;9a6e	dd e5 	. . 
	call sub_79a5h		;9a70	cd a5 79 	. . y 
	pop ix		;9a73	dd e1 	. . 
	pop iy		;9a75	fd e1 	. . 
	ret			;9a77	c9 	. 
l9a78h:
	rst 38h			;9a78	ff 	. 
	ld (bc),a			;9a79	02 	. 
	rst 38h			;9a7a	ff 	. 
	ld (bc),a			;9a7b	02 	. 
	rst 38h			;9a7c	ff 	. 
	ld bc,001feh		;9a7d	01 fe 01 	. . . 
	cp 0ffh		;9a80	fe ff 	. . 
	rst 38h			;9a82	ff 	. 
	rst 38h			;9a83	ff 	. 
	rst 38h			;9a84	ff 	. 
	cp 0ffh		;9a85	fe ff 	. . 
	cp 001h		;9a87	fe 01 	. . 
	cp 001h		;9a89	fe 01 	. . 
	cp 001h		;9a8b	fe 01 	. . 
	rst 38h			;9a8d	ff 	. 
	ld (bc),a			;9a8e	02 	. 
	rst 38h			;9a8f	ff 	. 
	ld (bc),a			;9a90	02 	. 
	ld bc,00101h		;9a91	01 01 01 	. . . 
	ld bc,00102h		;9a94	01 02 01 	. . . 
	ld (bc),a			;9a97	02 	. 
l9a98h:
	ret nc			;9a98	d0 	. 
	sbc a,d			;9a99	9a 	. 
	ret nc			;9a9a	d0 	. 
	sbc a,d			;9a9b	9a 	. 
	ret nc			;9a9c	d0 	. 
	sbc a,d			;9a9d	9a 	. 
	or b			;9a9e	b0 	. 
	sbc a,d			;9a9f	9a 	. 
	ret nc			;9aa0	d0 	. 
	sbc a,d			;9aa1	9a 	. 
	ret nc			;9aa2	d0 	. 
	sbc a,d			;9aa3	9a 	. 
	or b			;9aa4	b0 	. 
	sbc a,d			;9aa5	9a 	. 
	ret nc			;9aa6	d0 	. 
	sbc a,d			;9aa7	9a 	. 
	ret nc			;9aa8	d0 	. 
	sbc a,d			;9aa9	9a 	. 
	ret nc			;9aaa	d0 	. 
	sbc a,d			;9aab	9a 	. 
	ret nc			;9aac	d0 	. 
	sbc a,d			;9aad	9a 	. 
	ret nc			;9aae	d0 	. 
	sbc a,d			;9aaf	9a 	. 
	nop			;9ab0	00 	. 
	rrca			;9ab1	0f 	. 
	nop			;9ab2	00 	. 
	ld c,000h		;9ab3	0e 00 	. . 
	dec c			;9ab5	0d 	. 
	nop			;9ab6	00 	. 
	inc c			;9ab7	0c 	. 
	ld bc,0010fh		;9ab8	01 0f 01 	. . . 
	ld c,001h		;9abb	0e 01 	. . 
	dec c			;9abd	0d 	. 
	ld bc,0000ch		;9abe	01 0c 00 	. . . 
	inc b			;9ac1	04 	. 
	ld (bc),a			;9ac2	02 	. 
	ex af,af'			;9ac3	08 	. 
	nop			;9ac4	00 	. 
	ld (bc),a			;9ac5	02 	. 
	ld (bc),a			;9ac6	02 	. 
	inc b			;9ac7	04 	. 
	nop			;9ac8	00 	. 
	ld bc,00202h		;9ac9	01 02 02 	. . . 
	ld bc,00201h		;9acc	01 01 02 	. . . 
	ld bc,01700h		;9acf	01 00 17 	. . . 
	nop			;9ad2	00 	. 
	dec d			;9ad3	15 	. 
	nop			;9ad4	00 	. 
	inc d			;9ad5	14 	. 
	nop			;9ad6	00 	. 
	ld (de),a			;9ad7	12 	. 
	ld bc,00117h		;9ad8	01 17 01 	. . . 
	dec d			;9adb	15 	. 
	ld bc,00114h		;9adc	01 14 01 	. . . 
	ld (de),a			;9adf	12 	. 
	nop			;9ae0	00 	. 
	ld b,002h		;9ae1	06 02 	. . 
	inc c			;9ae3	0c 	. 
	nop			;9ae4	00 	. 
	inc bc			;9ae5	03 	. 
	ld bc,00104h		;9ae6	01 04 01 	. . . 
	inc bc			;9ae9	03 	. 
	ld bc,00002h		;9aea	01 02 00 	. . . 
	ld bc,00101h		;9aed	01 01 01 	. . . 

; Update the speed of the ball according to counter and the values in BALL_TABLE1
UPDATE_BALL_SPEED:
    ; iy = BALL_TABLE1
	push af			    ;9af0	f5
    ; Increase ball speed counter
	inc (iy + BALL_TABLE_IDX_SPEED_COUNTER)		    ;9af1	fd 34 0d
    
	; HL = BALL_SPEED_TABLE + ball_speed_pos
    ld l,(iy + BALL_TABLE_IDX_SPEED_POS)	;9af4	fd 6e 07
	ld h, 0		                            ;9af7	26 00
	ld de,BALL_SPEED_TABLE		            ;9af9	11 1a 9b
	add hl,de			                    ;9afc	19
    
    ; A = BALL_SPEED_TABLE[ball_speed_pos]
	ld a,(hl)			        ;9afd	7e
    
    ; Check if the counter has reached the current objective
    ; If BALL_SPEED_TABLE[ball_speed_pos] <= BALL_SPEED_TABLE[BALL_TABLE_IDX_SPEED_COUNTER] then return
	cp (iy + BALL_TABLE_IDX_SPEED_COUNTER)		;9afe	fd be 0d
	jp nc,l9b18h		                        ;9b01	d2 18 9b

    ; Yes, we have reached the objective

    ; Reset ball speed counter
	ld (iy + BALL_TABLE_IDX_SPEED_COUNTER), 0	;9b04	fd 36 0d 00
    
	; Set ball_speed_pos to the next objective
    ld a,(iy + BALL_TABLE_IDX_SPEED_POS)		    ;9b08	fd 7e 07
	inc a			                                ;9b0b	3c
	ld (iy + BALL_TABLE_IDX_SPEED_POS),a		    ;9b0c	fd 77 07

    ; If the index is out of bounds (16), set it to 15
	cp 16		            ;9b0f	fe 10
	jp nz,l9b18h		    ;9b11	c2 18 9b
	ld (iy + BALL_TABLE_IDX_SPEED_POS), 15  		;9b14	fd 36 07 0f
l9b18h:
	pop af			        ;9b18	f1
	ret			            ;9b19	c9

; This table determines for how long the ball stays at its current
; speed before incrementing it.
BALL_SPEED_TABLE:
    db 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 4, 8, 16, 24, 31

sub_9b2ah:
	push iy		;9b2a	fd e5 	. . 
	push iy		;9b2c	fd e5 	. . 
	pop hl			;9b2e	e1 	. 
	pop de			;9b2f	d1 	. 
	inc de			;9b30	13 	. 
	ld (hl),000h		;9b31	36 00 	6 . 
	ld bc,00013h		;9b33	01 13 00 	. . . 
	ldir		;9b36	ed b0 	. . 
	ld (ix+000h),0c0h		;9b38	dd 36 00 c0 	. 6 . . 
	ld (ix+003h),000h		;9b3c	dd 36 03 00 	. 6 . . 
	ld hl,EXTRA_BALLS		;9b40	21 25 e3 	! % . 
	ld a,(hl)			;9b43	7e 	~ 
	or a			;9b44	b7 	. 
	jp z,l9b4ah		;9b45	ca 4a 9b 	. J . 
	dec (hl)			;9b48	35 	5 
	ret			;9b49	c9 	. 
l9b4ah:
	ld a,(0e54bh)		;9b4a	3a 4b e5 	: K . 
	cp 007h		;9b4d	fe 07 	. . 
	ret z			;9b4f	c8 	. 
	ld a,006h		;9b50	3e 06 	> . 
	ld (0e54bh),a		;9b52	32 4b e5 	2 K . 
	ld a,007h		;9b55	3e 07 	> . 
	call sub_5befh		;9b57	cd ef 5b 	. . [ 
	ret			;9b5a	c9 	. 

sub_9b5bh:
	push af			;9b5b	f5 	. 
	ld a,(iy+BALL_TABLE_IDX_VERT)		;9b5c	fd 7e 02 	. ~ . 
	neg		;9b5f	ed 44 	. D 
	ld (iy+BALL_TABLE_IDX_VERT),a		;9b61	fd 77 02 	. w . 
	pop af			;9b64	f1 	. 
	push af			;9b65	f5 	. 
	ld a,(iy+BALL_TABLE_IDX_SKEWNESS)		;9b66	fd 7e 06 	. ~ . 
	bit 7,a		;9b69	cb 7f 	.  
	jp z,l9b70h		;9b6b	ca 70 9b 	. p . 
	neg		;9b6e	ed 44 	. D 
l9b70h:
	sub 009h		;9b70	d6 09 	. . 
	bit 7,(iy+BALL_TABLE_IDX_SKEWNESS)		;9b72	fd cb 06 7e 	. . . ~ 
	jp z,l9b7bh		;9b76	ca 7b 9b 	. { . 
	neg		;9b79	ed 44 	. D 
l9b7bh:
	ld (iy+BALL_TABLE_IDX_SKEWNESS),a		;9b7b	fd 77 06
	pop af			;9b7e	f1 	. 
	ret			;9b7f	c9 	. 

sub_9b80h:
	push af			;9b80	f5 	. 
	ld a,(iy+BALL_TABLE_IDX_HORIZ)		;9b81	fd 7e 03
	neg		;9b84	ed 44 	. D 
	ld (iy+BALL_TABLE_IDX_HORIZ),a		;9b86	fd 77 03
	pop af			;9b89	f1 	. 
sub_9b8ah:
	push af			;9b8a	f5 	. 
	ld a,(iy+BALL_TABLE_IDX_SKEWNESS)		;9b8b	fd 7e 06
	bit 7,a		;9b8e	cb 7f 	.  
	jp z,l9b95h		;9b90	ca 95 9b 	. . . 
	neg		;9b93	ed 44 	. D 
l9b95h:
	ld c,a			;9b95	4f 	O 
	ld a,009h		;9b96	3e 09 	> . 
	sub c			;9b98	91 	. 
	ld c,(iy+BALL_TABLE_IDX_SKEWNESS)		;9b99	fd 4e 06
	bit 7,c		;9b9c	cb 79 	. y 
	jp z,l9ba3h		;9b9e	ca a3 9b 	. . . 
	neg		;9ba1	ed 44 	. D 
l9ba3h:
	ld (iy+BALL_TABLE_IDX_SKEWNESS),a		;9ba3	fd 77 06
	pop af			;9ba6	f1 	. 
	ret			;9ba7	c9 	. 

sub_9ba8h:
	ld a,(ix+BALL_SPR_PARAMS_IDX_Y)		;9ba8	dd 7e 00 	. ~ . 
	bit 7,(iy+BALL_TABLE_IDX_VERT)		;9bab	fd cb 02 7e 	. . . ~ 
	ret nz			;9baf	c0 	. 
	cp 0a7h		;9bb0	fe a7 	. . 
	ret c			;9bb2	d8 	. 
	cp 0adh		;9bb3	fe ad 	. . 
	ret nc			;9bb5	d0 	. 
	ld a,(VAUS_X)		;9bb6	3a ce e0 	: . . 
	add a,001h		;9bb9	c6 01 	. . 
	cp (ix+BALL_SPR_PARAMS_IDX_X)		;9bbb	dd be 01 	. . . 
	ret nc			;9bbe	d0 	. 
	ld c,007h		;9bbf	0e 07 	. . 
	ld b,029h		;9bc1	06 29 	. ) 
	ld a,(0e550h)		;9bc3	3a 50 e5 	: P . 
	cp 002h		;9bc6	fe 02 	. . 
	jp nz,l9bcfh		;9bc8	c2 cf 9b 	. . . 
	ld c,00ah		;9bcb	0e 0a 	. . 
	ld b,039h		;9bcd	06 39 	. 9 
l9bcfh:
	ld a,(VAUS_X)		;9bcf	3a ce e0 	: . . 
	add a,b			;9bd2	80 	. 
	cp (ix+BALL_SPR_PARAMS_IDX_X)		;9bd3	dd be 01 	. . . 
	ret c			;9bd6	d8 	. 
	ld (ix+BALL_SPR_PARAMS_IDX_Y),169		;9bd7	dd 36 00 a9 	. 6 . . 
	ld a,(0e324h)		;9bdb	3a 24 e3 	: $ . 
	cp 001h		;9bde	fe 01 	. . 
	jp z,l9bebh		;9be0	ca eb 9b 	. . . 
	ld a,001h		;9be3	3e 01 	> . 
	call sub_5befh		;9be5	cd ef 5b 	. . [ 
	jp l9c05h		;9be8	c3 05 9c 	. . . 
l9bebh:
	push bc			;9beb	c5 	. 
    
    ; Initialize BALL_TABLE_IDX_GLUE_COUNTER
	ld (iy+BALL_TABLE_IDX_GLUE_COUNTER), 240		;9bec	fd 36 0e f0

	; Ball is glued
    ld (iy+BALL_TABLE_IDX_GLUE), 1		;9bf0	fd 36 01 01

	ld a,(VAUS_X)		;9bf4	3a ce e0 	: . . 
	ld c,a			;9bf7	4f 	O 
	ld a,(ix+BALL_SPR_PARAMS_IDX_X)		;9bf8	dd 7e 01 	. ~ . 
	sub c			;9bfb	91 	. 
	ld (iy+010h),a		;9bfc	fd 77 10 	. w . 
	pop bc			;9bff	c1 	. 
	ld a,004h		;9c00	3e 04 	> . 
	call sub_5befh		;9c02	cd ef 5b 	. . [ 
l9c05h:
	ld a,(iy+BALL_TABLE_IDX_VERT)		;9c05	fd 7e 02 	. ~ . 
	neg		;9c08	ed 44 	. D 
	ld (iy+BALL_TABLE_IDX_VERT),a		;9c0a	fd 77 02 	. w . 

	ld a,(VAUS_X)		;9c0d	3a ce e0 	: . . 
	ld b,a			;9c10	47 	G 
	ld a,(ix+BALL_SPR_PARAMS_IDX_X)		;9c11	dd 7e 01 	. ~ . 
	sub b			;9c14	90 	. 
	ld l,a			;9c15	6f 	o 
	ld h,0  		;9c16	26 00 	& . 
	call sub_b39ah	;9c18	cd 9a b3 	. . . 

	; A = BALL_DIRECTION_TABLE[l]
    ld e,l			;9c1b	5d 	] 
	ld d,000h		;9c1c	16 00 	. . 
	ld hl,BALL_SKEWNESS_TABLE		;9c1e	21 27 9c 	! ' . 
	add hl,de			;9c21	19 	. 
	ld a,(hl)			;9c22	7e 	~ 
    
	ld (iy+BALL_TABLE_IDX_SKEWNESS),a		;9c23	fd 77 06
	ret			;9c26	c9 	. 

BALL_SKEWNESS_TABLE:
    ; 7: most skewed, moving left
    ; 6: a little bit skewed, moving left
    ; 5: less skewed, moving left
    ;
    ; 4: not very skewed, moving right
    ; 3: a little skewed, moving right
    ; 2: most skewed, moving right
    db 7, 6, 5, 4, 3, 2

sub_9c2dh:
	ld a,(LEVEL)		;9c2d	3a 1b e0
	cp FINAL_LEVEL		;9c30	fe 20
	ret nc			;9c32	d0 	. 
	bit 7,(iy+002h)		;9c33	fd cb 02 7e 	. . . ~ 
	jp z,l9dcfh		;9c37	ca cf 9d 	. . . 
	bit 7,(iy+003h)		;9c3a	fd cb 03 7e 	. . . ~ 
	jp nz,l9dcfh		;9c3e	c2 cf 9d 	. . . 
	ld a,(ix+000h)		;9c41	dd 7e 00 	. ~ . 
	sub 018h		;9c44	d6 18 	. . 
	srl a		;9c46	cb 3f 	. ? 
	srl a		;9c48	cb 3f 	. ? 
	srl a		;9c4a	cb 3f 	. ? 
	cp 00ch		;9c4c	fe 0c 	. . 
	jp nc,l9dcfh		;9c4e	d2 cf 9d 	. . . 
	ld (0e58ah),a		;9c51	32 8a e5 	2 . . 
	ld a,(ix+001h)		;9c54	dd 7e 01 	. ~ . 
	sub 00ch		;9c57	d6 0c 	. . 
	srl a		;9c59	cb 3f 	. ? 
	srl a		;9c5b	cb 3f 	. ? 
	srl a		;9c5d	cb 3f 	. ? 
	srl a		;9c5f	cb 3f 	. ? 
	ld (0e58bh),a		;9c61	32 8b e5 	2 . . 
	ld a,(ix+000h)		;9c64	dd 7e 00 	. ~ . 
	sub (iy+002h)		;9c67	fd 96 02 	. . . 
	ld (0e586h),a		;9c6a	32 86 e5 	2 . . 
	sub 018h		;9c6d	d6 18 	. . 
	srl a		;9c6f	cb 3f 	. ? 
	srl a		;9c71	cb 3f 	. ? 
	srl a		;9c73	cb 3f 	. ? 
	cp 00dh		;9c75	fe 0d 	. . 
	jp nc,l9dcfh		;9c77	d2 cf 9d 	. . . 
	ld (0e58ch),a		;9c7a	32 8c e5 	2 . . 
	ld a,(ix+001h)		;9c7d	dd 7e 01 	. ~ . 
	sub (iy+003h)		;9c80	fd 96 03 	. . . 
	ld (0e587h),a		;9c83	32 87 e5 	2 . . 
	sub 00ch		;9c86	d6 0c 	. . 
	srl a		;9c88	cb 3f 	. ? 
	srl a		;9c8a	cb 3f 	. ? 
	srl a		;9c8c	cb 3f 	. ? 
	srl a		;9c8e	cb 3f 	. ? 
	cp 00bh		;9c90	fe 0b 	. . 
	jp nc,l9dcfh		;9c92	d2 cf 9d 	. . . 
	ld (0e58dh),a		;9c95	32 8d e5 	2 . . 
	call sub_a29ah		;9c98	cd 9a a2 	. . . 
	jp c,la299h		;9c9b	da 99 a2 	. . . 
	ld a,(0e58bh)		;9c9e	3a 8b e5 	: . . 
	cp 00bh		;9ca1	fe 0b 	. . 
	jp nc,la299h		;9ca3	d2 99 a2 	. . . 
	ld a,(0e58ah)		;9ca6	3a 8a e5 	: . . 
	cp 00bh		;9ca9	fe 0b 	. . 
	jp nz,l9cbch		;9cab	c2 bc 9c 	. . . 
	ld a,(0e58ch)		;9cae	3a 8c e5 	: . . 
	cp 00ch		;9cb1	fe 0c 	. . 
	jp nz,l9cbch		;9cb3	c2 bc 9c 	. . . 
	call sub_a328h		;9cb6	cd 28 a3 	. ( . 
	jp la299h		;9cb9	c3 99 a2 	. . . 
l9cbch:
	ld a,(0e58ch)		;9cbc	3a 8c e5 	: . . 
	cp 00ch		;9cbf	fe 0c 	. . 
	jp nc,la299h		;9cc1	d2 99 a2 	. . . 
	ld a,(0e58ch)		;9cc4	3a 8c e5 	: . . 
	ld c,a			;9cc7	4f 	O 
	ld a,(0e58ah)		;9cc8	3a 8a e5 	: . . 
	cp c			;9ccb	b9 	. 
	jp z,l9cd7h		;9ccc	ca d7 9c 	. . . 
	dec c			;9ccf	0d 	. 
	cp c			;9cd0	b9 	. 
	jp z,l9ceah		;9cd1	ca ea 9c 	. . . 
	jp la299h		;9cd4	c3 99 a2 	. . . 
l9cd7h:
	ld a,(0e58dh)		;9cd7	3a 8d e5 	: . . 
	ld c,a			;9cda	4f 	O 
	ld a,(0e58bh)		;9cdb	3a 8b e5 	: . . 
	cp c			;9cde	b9 	. 
	jp z,l9cfdh		;9cdf	ca fd 9c 	. . . 
	inc c			;9ce2	0c 	. 
	cp c			;9ce3	b9 	. 
	jp z,l9d18h		;9ce4	ca 18 9d 	. . . 
	jp la299h		;9ce7	c3 99 a2 	. . . 
l9ceah:
	ld a,(0e58dh)		;9cea	3a 8d e5 	: . . 
	ld c,a			;9ced	4f 	O 
	ld a,(0e58bh)		;9cee	3a 8b e5 	: . . 
	cp c			;9cf1	b9 	. 
	jp z,l9d36h		;9cf2	ca 36 9d 	. 6 . 
	inc c			;9cf5	0c 	. 
	cp c			;9cf6	b9 	. 
	jp z,l9d54h		;9cf7	ca 54 9d 	. T . 
	jp la299h		;9cfa	c3 99 a2 	. . . 
l9cfdh:
	ld a,(0e58ch)		;9cfd	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;9d00	32 aa e2 	2 . . 
	ld a,(0e58bh)		;9d03	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;9d06	32 ab e2 	2 . . 
	call sub_ada8h		;9d09	cd a8 ad 	. . . 
	jp nc,la299h		;9d0c	d2 99 a2 	. . . 
	call sub_9b5bh		;9d0f	cd 5b 9b 	. [ . 
	call sub_aa05h		;9d12	cd 05 aa 	. . . 
	jp la299h		;9d15	c3 99 a2 	. . . 
l9d18h:
	ld a,(0e58ch)		;9d18	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;9d1b	32 aa e2 	2 . . 
	ld a,(0e58bh)		;9d1e	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;9d21	32 ab e2 	2 . . 
	call sub_ada8h		;9d24	cd a8 ad 	. . . 
	jp nc,la299h		;9d27	d2 99 a2 	. . . 
	call la901h		;9d2a	cd 01 a9 	. . . 
	call sub_9b80h		;9d2d	cd 80 9b 	. . . 
	call sub_aa05h		;9d30	cd 05 aa 	. . . 
	jp la299h		;9d33	c3 99 a2 	. . . 
l9d36h:
	ld a,(0e58ah)		;9d36	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;9d39	32 aa e2 	2 . . 
	ld a,(0e58dh)		;9d3c	3a 8d e5 	: . . 
	ld (BRICK_COL),a		;9d3f	32 ab e2 	2 . . 
	call sub_ada8h		;9d42	cd a8 ad 	. . . 
	jp nc,la299h		;9d45	d2 99 a2 	. . . 
	call sub_a810h		;9d48	cd 10 a8 	. . . 
	call sub_9b5bh		;9d4b	cd 5b 9b 	. [ . 
	call sub_aa05h		;9d4e	cd 05 aa 	. . . 
	jp la299h		;9d51	c3 99 a2 	. . . 
l9d54h:
	ld a,(0e58ah)		;9d54	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;9d57	32 aa e2 	2 . . 
	ld a,(0e58dh)		;9d5a	3a 8d e5 	: . . 
	ld (BRICK_COL),a		;9d5d	32 ab e2 	2 . . 
	call sub_a670h		;9d60	cd 70 a6 	. p . 
	jp nc,l9d99h		;9d63	d2 99 9d 	. . . 
	call sub_ada8h		;9d66	cd a8 ad 	. . . 
	jp nc,l9d81h		;9d69	d2 81 9d 	. . . 
	ld a,(0e53ch)		;9d6c	3a 3c e5 	: < . 
	ld (ix+000h),a		;9d6f	dd 77 00 	. w . 
	ld a,(0e53dh)		;9d72	3a 3d e5 	: = . 
	ld (ix+001h),a		;9d75	dd 77 01 	. w . 
	call sub_9b5bh		;9d78	cd 5b 9b 	. [ . 
	call sub_aa05h		;9d7b	cd 05 aa 	. . . 
	jp la299h		;9d7e	c3 99 a2 	. . . 
l9d81h:
	ld a,(0e58bh)		;9d81	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;9d84	32 ab e2 	2 . . 
	call sub_ada8h		;9d87	cd a8 ad 	. . . 
	jp nc,la299h		;9d8a	d2 99 a2 	. . . 
	call la901h		;9d8d	cd 01 a9 	. . . 
	call sub_9b80h		;9d90	cd 80 9b 	. . . 
	call sub_aa05h		;9d93	cd 05 aa 	. . . 
	jp la299h		;9d96	c3 99 a2 	. . . 
l9d99h:
	ld a,(0e58ch)		;9d99	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;9d9c	32 aa e2 	2 . . 
	ld a,(0e58bh)		;9d9f	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;9da2	32 ab e2 	2 . . 
	call sub_ada8h		;9da5	cd a8 ad 	. . . 
	jp nc,l9db7h		;9da8	d2 b7 9d 	. . . 
	call la901h		;9dab	cd 01 a9 	. . . 
	call sub_9b80h		;9dae	cd 80 9b 	. . . 
	call sub_aa05h		;9db1	cd 05 aa 	. . . 
	jp la299h		;9db4	c3 99 a2 	. . . 
l9db7h:
	ld a,(0e58ah)		;9db7	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;9dba	32 aa e2 	2 . . 
	call sub_ada8h		;9dbd	cd a8 ad 	. . . 
	jp nc,la299h		;9dc0	d2 99 a2 	. . . 
	call sub_a810h		;9dc3	cd 10 a8 	. . . 
	call sub_9b5bh		;9dc6	cd 5b 9b 	. [ . 
	call sub_aa05h		;9dc9	cd 05 aa 	. . . 
	jp la299h		;9dcc	c3 99 a2 	. . . 
l9dcfh:
	bit 7,(iy+002h)		;9dcf	fd cb 02 7e 	. . . ~ 
	jp z,l9f6bh		;9dd3	ca 6b 9f 	. k . 
	bit 7,(iy+003h)		;9dd6	fd cb 03 7e 	. . . ~ 
	jp z,l9f6bh		;9dda	ca 6b 9f 	. k . 
	ld a,(ix+000h)		;9ddd	dd 7e 00 	. ~ . 
	sub 018h		;9de0	d6 18 	. . 
	srl a		;9de2	cb 3f 	. ? 
	srl a		;9de4	cb 3f 	. ? 
	srl a		;9de6	cb 3f 	. ? 
	cp 00ch		;9de8	fe 0c 	. . 
	jp nc,l9f6bh		;9dea	d2 6b 9f 	. k . 
	ld (0e58ah),a		;9ded	32 8a e5 	2 . . 
	ld a,(ix+001h)		;9df0	dd 7e 01 	. ~ . 
	sub 011h		;9df3	d6 11 	. . 
	srl a		;9df5	cb 3f 	. ? 
	srl a		;9df7	cb 3f 	. ? 
	srl a		;9df9	cb 3f 	. ? 
	srl a		;9dfb	cb 3f 	. ? 
	ld (0e58bh),a		;9dfd	32 8b e5 	2 . . 
	ld a,(ix+000h)		;9e00	dd 7e 00 	. ~ . 
	sub (iy+002h)		;9e03	fd 96 02 	. . . 
	ld (0e586h),a		;9e06	32 86 e5 	2 . . 
	sub 018h		;9e09	d6 18 	. . 
	srl a		;9e0b	cb 3f 	. ? 
	srl a		;9e0d	cb 3f 	. ? 
	srl a		;9e0f	cb 3f 	. ? 
	cp 00dh		;9e11	fe 0d 	. . 
	jp nc,l9f6bh		;9e13	d2 6b 9f 	. k . 
	ld (0e58ch),a		;9e16	32 8c e5 	2 . . 
	ld a,(ix+001h)		;9e19	dd 7e 01 	. ~ . 
	sub (iy+003h)		;9e1c	fd 96 03 	. . . 
	ld (0e587h),a		;9e1f	32 87 e5 	2 . . 
	sub 011h		;9e22	d6 11 	. . 
	srl a		;9e24	cb 3f 	. ? 
	srl a		;9e26	cb 3f 	. ? 
	srl a		;9e28	cb 3f 	. ? 
	srl a		;9e2a	cb 3f 	. ? 
	cp 00bh		;9e2c	fe 0b 	. . 
	jp nc,l9f6bh		;9e2e	d2 6b 9f 	. k . 
	ld (0e58dh),a		;9e31	32 8d e5 	2 . . 
	call sub_a2adh		;9e34	cd ad a2 	. . . 
	jp c,la299h		;9e37	da 99 a2 	. . . 
	ld a,(0e58bh)		;9e3a	3a 8b e5 	: . . 
	cp 00bh		;9e3d	fe 0b 	. . 
	jp nc,la299h		;9e3f	d2 99 a2 	. . . 
	ld a,(0e58ah)		;9e42	3a 8a e5 	: . . 
	cp 00bh		;9e45	fe 0b 	. . 
	jp nz,l9e58h		;9e47	c2 58 9e 	. X . 
	ld a,(0e58ch)		;9e4a	3a 8c e5 	: . . 
	cp 00ch		;9e4d	fe 0c 	. . 
	jp nz,l9e58h		;9e4f	c2 58 9e 	. X . 
	call sub_a328h		;9e52	cd 28 a3 	. ( . 
	jp la299h		;9e55	c3 99 a2 	. . . 
l9e58h:
	ld a,(0e58ch)		;9e58	3a 8c e5 	: . . 
	cp 00ch		;9e5b	fe 0c 	. . 
	jp nc,la299h		;9e5d	d2 99 a2 	. . . 
	ld a,(0e58ch)		;9e60	3a 8c e5 	: . . 
	ld c,a			;9e63	4f 	O 
	ld a,(0e58ah)		;9e64	3a 8a e5 	: . . 
	cp c			;9e67	b9 	. 
	jp z,l9e73h		;9e68	ca 73 9e 	. s . 
	dec c			;9e6b	0d 	. 
	cp c			;9e6c	b9 	. 
	jp z,l9e86h		;9e6d	ca 86 9e 	. . . 
	jp la299h		;9e70	c3 99 a2 	. . . 
l9e73h:
	ld a,(0e58dh)		;9e73	3a 8d e5 	: . . 
	ld c,a			;9e76	4f 	O 
	ld a,(0e58bh)		;9e77	3a 8b e5 	: . . 
	cp c			;9e7a	b9 	. 
	jp z,l9e99h		;9e7b	ca 99 9e 	. . . 
	dec c			;9e7e	0d 	. 
	cp c			;9e7f	b9 	. 
	jp z,l9eb4h		;9e80	ca b4 9e 	. . . 
	jp la299h		;9e83	c3 99 a2 	. . . 
l9e86h:
	ld a,(0e58dh)		;9e86	3a 8d e5 	: . . 
	ld c,a			;9e89	4f 	O 
	ld a,(0e58bh)		;9e8a	3a 8b e5 	: . . 
	cp c			;9e8d	b9 	. 
	jp z,l9ed2h		;9e8e	ca d2 9e 	. . . 
	dec c			;9e91	0d 	. 
	cp c			;9e92	b9 	. 
	jp z,l9ef0h		;9e93	ca f0 9e 	. . . 
	jp la299h		;9e96	c3 99 a2 	. . . 
l9e99h:
	ld a,(0e58ch)		;9e99	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;9e9c	32 aa e2 	2 . . 
	ld a,(0e58bh)		;9e9f	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;9ea2	32 ab e2 	2 . . 
	call sub_ada8h		;9ea5	cd a8 ad 	. . . 
	jp nc,la299h		;9ea8	d2 99 a2 	. . . 
	call sub_9b5bh		;9eab	cd 5b 9b 	. [ . 
	call sub_aa05h		;9eae	cd 05 aa 	. . . 
	jp la299h		;9eb1	c3 99 a2 	. . . 
l9eb4h:
	ld a,(0e58ch)		;9eb4	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;9eb7	32 aa e2 	2 . . 
	ld a,(0e58bh)		;9eba	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;9ebd	32 ab e2 	2 . . 
	call sub_ada8h		;9ec0	cd a8 ad 	. . . 
	jp nc,la299h		;9ec3	d2 99 a2 	. . . 
	call la901h		;9ec6	cd 01 a9 	. . . 
	call sub_9b80h		;9ec9	cd 80 9b 	. . . 
	call sub_aa05h		;9ecc	cd 05 aa 	. . . 
	jp la299h		;9ecf	c3 99 a2 	. . . 
l9ed2h:
	ld a,(0e58ah)		;9ed2	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;9ed5	32 aa e2 	2 . . 
	ld a,(0e58dh)		;9ed8	3a 8d e5 	: . . 
	ld (BRICK_COL),a		;9edb	32 ab e2 	2 . . 
	call sub_ada8h		;9ede	cd a8 ad 	. . . 
	jp nc,la299h		;9ee1	d2 99 a2 	. . . 
	call sub_a810h		;9ee4	cd 10 a8 	. . . 
	call sub_9b5bh		;9ee7	cd 5b 9b 	. [ . 
	call sub_aa05h		;9eea	cd 05 aa 	. . . 
	jp la299h		;9eed	c3 99 a2 	. . . 
l9ef0h:
	ld a,(0e58ah)		;9ef0	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;9ef3	32 aa e2 	2 . . 
	ld a,(0e58dh)		;9ef6	3a 8d e5 	: . . 
	ld (BRICK_COL),a		;9ef9	32 ab e2 	2 . . 
	call sub_a670h		;9efc	cd 70 a6 	. p . 
	jp nc,l9f35h		;9eff	d2 35 9f 	. 5 . 
	call sub_ada8h		;9f02	cd a8 ad 	. . . 
	jp nc,l9f1dh		;9f05	d2 1d 9f 	. . . 
	ld a,(0e53ch)		;9f08	3a 3c e5 	: < . 
	ld (ix+000h),a		;9f0b	dd 77 00 	. w . 
	ld a,(0e53dh)		;9f0e	3a 3d e5 	: = . 
	ld (ix+001h),a		;9f11	dd 77 01 	. w . 
	call sub_9b5bh		;9f14	cd 5b 9b 	. [ . 
	call sub_aa05h		;9f17	cd 05 aa 	. . . 
	jp la299h		;9f1a	c3 99 a2 	. . . 
l9f1dh:
	ld a,(0e58bh)		;9f1d	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;9f20	32 ab e2 	2 . . 
	call sub_ada8h		;9f23	cd a8 ad 	. . . 
	jp nc,la299h		;9f26	d2 99 a2 	. . . 
	call la901h		;9f29	cd 01 a9 	. . . 
	call sub_9b80h		;9f2c	cd 80 9b 	. . . 
	call sub_aa05h		;9f2f	cd 05 aa 	. . . 
	jp la299h		;9f32	c3 99 a2 	. . . 
l9f35h:
	ld a,(0e58ch)		;9f35	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;9f38	32 aa e2 	2 . . 
	ld a,(0e58bh)		;9f3b	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;9f3e	32 ab e2 	2 . . 
	call sub_ada8h		;9f41	cd a8 ad 	. . . 
	jp nc,l9f53h		;9f44	d2 53 9f 	. S . 
	call la901h		;9f47	cd 01 a9 	. . . 
	call sub_9b80h		;9f4a	cd 80 9b 	. . . 
	call sub_aa05h		;9f4d	cd 05 aa 	. . . 
	jp la299h		;9f50	c3 99 a2 	. . . 
l9f53h:
	ld a,(0e58ah)		;9f53	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;9f56	32 aa e2 	2 . . 
	call sub_ada8h		;9f59	cd a8 ad 	. . . 
	jp nc,la299h		;9f5c	d2 99 a2 	. . . 
	call sub_a810h		;9f5f	cd 10 a8 	. . . 
	call sub_9b5bh		;9f62	cd 5b 9b 	. [ . 
	call sub_aa05h		;9f65	cd 05 aa 	. . . 
	jp la299h		;9f68	c3 99 a2 	. . . 
l9f6bh:
	bit 7,(iy+002h)		;9f6b	fd cb 02 7e 	. . . ~ 
	jp nz,la102h		;9f6f	c2 02 a1 	. . . 
	bit 7,(iy+003h)		;9f72	fd cb 03 7e 	. . . ~ 
	jp nz,la102h		;9f76	c2 02 a1 	. . . 
	ld a,(ix+000h)		;9f79	dd 7e 00 	. ~ . 
	sub 013h		;9f7c	d6 13 	. . 
	srl a		;9f7e	cb 3f 	. ? 
	srl a		;9f80	cb 3f 	. ? 
	srl a		;9f82	cb 3f 	. ? 
	cp 00ch		;9f84	fe 0c 	. . 
	jp nc,la102h		;9f86	d2 02 a1 	. . . 
	ld (0e58ah),a		;9f89	32 8a e5 	2 . . 
	ld a,(ix+001h)		;9f8c	dd 7e 01 	. ~ . 
	sub 00ch		;9f8f	d6 0c 	. . 
	srl a		;9f91	cb 3f 	. ? 
	srl a		;9f93	cb 3f 	. ? 
	srl a		;9f95	cb 3f 	. ? 
	srl a		;9f97	cb 3f 	. ? 
	ld (0e58bh),a		;9f99	32 8b e5 	2 . . 
	ld a,(ix+000h)		;9f9c	dd 7e 00 	. ~ . 
	sub (iy+002h)		;9f9f	fd 96 02 	. . . 
	ld (0e586h),a		;9fa2	32 86 e5 	2 . . 
	sub 013h		;9fa5	d6 13 	. . 
	srl a		;9fa7	cb 3f 	. ? 
	srl a		;9fa9	cb 3f 	. ? 
	srl a		;9fab	cb 3f 	. ? 
	ld (0e58ch),a		;9fad	32 8c e5 	2 . . 
	ld a,(ix+001h)		;9fb0	dd 7e 01 	. ~ . 
	sub (iy+003h)		;9fb3	fd 96 03 	. . . 
	ld (0e587h),a		;9fb6	32 87 e5 	2 . . 
	sub 00ch		;9fb9	d6 0c 	. . 
	srl a		;9fbb	cb 3f 	. ? 
	srl a		;9fbd	cb 3f 	. ? 
	srl a		;9fbf	cb 3f 	. ? 
	srl a		;9fc1	cb 3f 	. ? 
	cp 00bh		;9fc3	fe 0b 	. . 
	jp nc,la102h		;9fc5	d2 02 a1 	. . . 
	ld (0e58dh),a		;9fc8	32 8d e5 	2 . . 
	call sub_a29ah		;9fcb	cd 9a a2 	. . . 
	jp c,la299h		;9fce	da 99 a2 	. . . 
	ld a,(0e58bh)		;9fd1	3a 8b e5 	: . . 
	cp 00bh		;9fd4	fe 0b 	. . 
	jp nc,la299h		;9fd6	d2 99 a2 	. . . 
	ld a,(0e58ah)		;9fd9	3a 8a e5 	: . . 
	cp 000h		;9fdc	fe 00 	. . 
	jp nz,l9fefh		;9fde	c2 ef 9f 	. . . 
	ld a,(0e58ch)		;9fe1	3a 8c e5 	: . . 
	cp 01fh		;9fe4	fe 1f 	. . 
	jp nz,l9fefh		;9fe6	c2 ef 9f 	. . . 
	call sub_a328h		;9fe9	cd 28 a3 	. ( . 
	jp la299h		;9fec	c3 99 a2 	. . . 
l9fefh:
	ld a,(0e58ch)		;9fef	3a 8c e5 	: . . 
	cp 00ch		;9ff2	fe 0c 	. . 
	jp nc,la299h		;9ff4	d2 99 a2 	. . . 
	ld a,(0e58ch)		;9ff7	3a 8c e5 	: . . 
	ld c,a			;9ffa	4f 	O 
	ld a,(0e58ah)		;9ffb	3a 8a e5 	: . . 
	cp c			;9ffe	b9 	. 
	jp z,la00ah		;9fff	ca 0a a0 	. . . 
	inc c			;a002	0c 	. 
	cp c			;a003	b9 	. 
	jp z,la01dh		;a004	ca 1d a0 	. . . 
	jp la299h		;a007	c3 99 a2 	. . . 
la00ah:
	ld a,(0e58dh)		;a00a	3a 8d e5 	: . . 
	ld c,a			;a00d	4f 	O 
	ld a,(0e58bh)		;a00e	3a 8b e5 	: . . 
	cp c			;a011	b9 	. 
	jp z,la030h		;a012	ca 30 a0 	. 0 . 
	inc c			;a015	0c 	. 
	cp c			;a016	b9 	. 
	jp z,la04bh		;a017	ca 4b a0 	. K . 
	jp la299h		;a01a	c3 99 a2 	. . . 
la01dh:
	ld a,(0e58dh)		;a01d	3a 8d e5 	: . . 
	ld c,a			;a020	4f 	O 
	ld a,(0e58bh)		;a021	3a 8b e5 	: . . 
	cp c			;a024	b9 	. 
	jp z,la069h		;a025	ca 69 a0 	. i . 
	inc c			;a028	0c 	. 
	cp c			;a029	b9 	. 
	jp z,la087h		;a02a	ca 87 a0 	. . . 
	jp la299h		;a02d	c3 99 a2 	. . . 
la030h:
	ld a,(0e58ch)		;a030	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;a033	32 aa e2 	2 . . 
	ld a,(0e58bh)		;a036	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a039	32 ab e2 	2 . . 
	call sub_ada8h		;a03c	cd a8 ad 	. . . 
	jp nc,la299h		;a03f	d2 99 a2 	. . . 
	call sub_9b5bh		;a042	cd 5b 9b 	. [ . 
	call sub_aa05h		;a045	cd 05 aa 	. . . 
	jp la299h		;a048	c3 99 a2 	. . . 
la04bh:
	ld a,(0e58ch)		;a04b	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;a04e	32 aa e2 	2 . . 
	ld a,(0e58bh)		;a051	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a054	32 ab e2 	2 . . 
	call sub_ada8h		;a057	cd a8 ad 	. . . 
	jp nc,la299h		;a05a	d2 99 a2 	. . . 
	call la901h		;a05d	cd 01 a9 	. . . 
	call sub_9b80h		;a060	cd 80 9b 	. . . 
	call sub_aa05h		;a063	cd 05 aa 	. . . 
	jp la299h		;a066	c3 99 a2 	. . . 
la069h:
	ld a,(0e58ah)		;a069	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a06c	32 aa e2 	2 . . 
	ld a,(0e58dh)		;a06f	3a 8d e5 	: . . 
	ld (BRICK_COL),a		;a072	32 ab e2 	2 . . 
	call sub_ada8h		;a075	cd a8 ad 	. . . 
	jp nc,la299h		;a078	d2 99 a2 	. . . 
	call sub_a810h		;a07b	cd 10 a8 	. . . 
	call sub_9b5bh		;a07e	cd 5b 9b 	. [ . 
	call sub_aa05h		;a081	cd 05 aa 	. . . 
	jp la299h		;a084	c3 99 a2 	. . . 
la087h:
	ld a,(0e58ah)		;a087	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a08a	32 aa e2 	2 . . 
	ld a,(0e58dh)		;a08d	3a 8d e5 	: . . 
la090h:
	ld (BRICK_COL),a		;a090	32 ab e2 	2 . . 
	call sub_a670h		;a093	cd 70 a6 	. p . 
	jp nc,la0cch		;a096	d2 cc a0 	. . . 
	call sub_ada8h		;a099	cd a8 ad 	. . . 
	jp nc,la0b4h		;a09c	d2 b4 a0 	. . . 
	ld a,(0e53ch)		;a09f	3a 3c e5 	: < . 
	ld (ix+000h),a		;a0a2	dd 77 00 	. w . 
	ld a,(0e53dh)		;a0a5	3a 3d e5 	: = . 
	ld (ix+001h),a		;a0a8	dd 77 01 	. w . 
	call sub_9b5bh		;a0ab	cd 5b 9b 	. [ . 
	call sub_aa05h		;a0ae	cd 05 aa 	. . . 
	jp la299h		;a0b1	c3 99 a2 	. . . 
la0b4h:
	ld a,(0e58bh)		;a0b4	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a0b7	32 ab e2 	2 . . 
	call sub_ada8h		;a0ba	cd a8 ad 	. . . 
	jp nc,la299h		;a0bd	d2 99 a2 	. . . 
la0c0h:
	call la901h		;a0c0	cd 01 a9 	. . . 
	call sub_9b80h		;a0c3	cd 80 9b 	. . . 
	call sub_aa05h		;a0c6	cd 05 aa 	. . . 
	jp la299h		;a0c9	c3 99 a2 	. . . 
la0cch:
	ld a,(0e58ch)		;a0cc	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;a0cf	32 aa e2 	2 . . 
	ld a,(0e58bh)		;a0d2	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a0d5	32 ab e2 	2 . . 
	call sub_ada8h		;a0d8	cd a8 ad 	. . . 
	jp nc,la0eah		;a0db	d2 ea a0 	. . . 
	call la901h		;a0de	cd 01 a9 	. . . 
	call sub_9b80h		;a0e1	cd 80 9b 	. . . 
	call sub_aa05h		;a0e4	cd 05 aa 	. . . 
	jp la299h		;a0e7	c3 99 a2 	. . . 
la0eah:
	ld a,(0e58ah)		;a0ea	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a0ed	32 aa e2 	2 . . 
	call sub_ada8h		;a0f0	cd a8 ad 	. . . 
	jp nc,la299h		;a0f3	d2 99 a2 	. . . 
	call sub_a810h		;a0f6	cd 10 a8 	. . . 
	call sub_9b5bh		;a0f9	cd 5b 9b 	. [ . 
	call sub_aa05h		;a0fc	cd 05 aa 	. . . 
	jp la299h		;a0ff	c3 99 a2 	. . . 
la102h:
	bit 7,(iy+002h)		;a102	fd cb 02 7e 	. . . ~ 
	jp nz,la299h		;a106	c2 99 a2 	. . . 
	bit 7,(iy+003h)		;a109	fd cb 03 7e 	. . . ~ 
	jp z,la299h		;a10d	ca 99 a2 	. . . 
	ld a,(ix+000h)		;a110	dd 7e 00 	. ~ . 
	sub 013h		;a113	d6 13 	. . 
	srl a		;a115	cb 3f 	. ? 
	srl a		;a117	cb 3f 	. ? 
	srl a		;a119	cb 3f 	. ? 
	cp 00ch		;a11b	fe 0c 	. . 
	jp nc,la299h		;a11d	d2 99 a2 	. . . 
	ld (0e58ah),a		;a120	32 8a e5 	2 . . 
	ld a,(ix+001h)		;a123	dd 7e 01 	. ~ . 
	sub 011h		;a126	d6 11 	. . 
	srl a		;a128	cb 3f 	. ? 
	srl a		;a12a	cb 3f 	. ? 
	srl a		;a12c	cb 3f 	. ? 
	srl a		;a12e	cb 3f 	. ? 
	ld (0e58bh),a		;a130	32 8b e5 	2 . . 
	ld a,(ix+000h)		;a133	dd 7e 00 	. ~ . 
	sub (iy+002h)		;a136	fd 96 02 	. . . 
	ld (0e586h),a		;a139	32 86 e5 	2 . . 
	sub 013h		;a13c	d6 13 	. . 
	srl a		;a13e	cb 3f 	. ? 
	srl a		;a140	cb 3f 	. ? 
	srl a		;a142	cb 3f 	. ? 
	ld (0e58ch),a		;a144	32 8c e5 	2 . . 
	ld a,(ix+001h)		;a147	dd 7e 01 	. ~ . 
	sub (iy+003h)		;a14a	fd 96 03 	. . . 
	ld (0e587h),a		;a14d	32 87 e5 	2 . . 
	sub 011h		;a150	d6 11 	. . 
	srl a		;a152	cb 3f 	. ? 
	srl a		;a154	cb 3f 	. ? 
	srl a		;a156	cb 3f 	. ? 
	srl a		;a158	cb 3f 	. ? 
	cp 00bh		;a15a	fe 0b 	. . 
	jp nc,la299h		;a15c	d2 99 a2 	. . . 
	ld (0e58dh),a		;a15f	32 8d e5 	2 . . 
	call sub_a2adh		;a162	cd ad a2 	. . . 
	jp c,la299h		;a165	da 99 a2 	. . . 
	ld a,(0e58bh)		;a168	3a 8b e5 	: . . 
	cp 00bh		;a16b	fe 0b 	. . 
	jp nc,la299h		;a16d	d2 99 a2 	. . . 
	ld a,(0e58ah)		;a170	3a 8a e5 	: . . 
	cp 000h		;a173	fe 00 	. . 
	jp nz,la186h		;a175	c2 86 a1 	. . . 
	ld a,(0e58ch)		;a178	3a 8c e5 	: . . 
	cp 01fh		;a17b	fe 1f 	. . 
	jp nz,la186h		;a17d	c2 86 a1 	. . . 
	call sub_a328h		;a180	cd 28 a3 	. ( . 
	jp la299h		;a183	c3 99 a2 	. . . 
la186h:
	ld a,(0e58ch)		;a186	3a 8c e5 	: . . 
	cp 00ch		;a189	fe 0c 	. . 
	jp nc,la299h		;a18b	d2 99 a2 	. . . 
	ld a,(0e58ch)		;a18e	3a 8c e5 	: . . 
	ld c,a			;a191	4f 	O 
	ld a,(0e58ah)		;a192	3a 8a e5 	: . . 
	cp c			;a195	b9 	. 
	jp z,la1a1h		;a196	ca a1 a1 	. . . 
	inc c			;a199	0c 	. 
	cp c			;a19a	b9 	. 
	jp z,la1b4h		;a19b	ca b4 a1 	. . . 
	jp la299h		;a19e	c3 99 a2 	. . . 
la1a1h:
	ld a,(0e58dh)		;a1a1	3a 8d e5 	: . . 
	ld c,a			;a1a4	4f 	O 
	ld a,(0e58bh)		;a1a5	3a 8b e5 	: . . 
	cp c			;a1a8	b9 	. 
	jp z,la1c7h		;a1a9	ca c7 a1 	. . . 
	dec c			;a1ac	0d 	. 
	cp c			;a1ad	b9 	. 
	jp z,la1e2h		;a1ae	ca e2 a1 	. . . 
	jp la299h		;a1b1	c3 99 a2 	. . . 
la1b4h:
	ld a,(0e58dh)		;a1b4	3a 8d e5 	: . . 
	ld c,a			;a1b7	4f 	O 
	ld a,(0e58bh)		;a1b8	3a 8b e5 	: . . 
	cp c			;a1bb	b9 	. 
	jp z,la200h		;a1bc	ca 00 a2 	. . . 
	dec c			;a1bf	0d 	. 
	cp c			;a1c0	b9 	. 
	jp z,la21eh		;a1c1	ca 1e a2 	. . . 
	jp la299h		;a1c4	c3 99 a2 	. . . 
la1c7h:
	ld a,(0e58ch)		;a1c7	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;a1ca	32 aa e2 	2 . . 
	ld a,(0e58bh)		;a1cd	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a1d0	32 ab e2 	2 . . 
	call sub_ada8h		;a1d3	cd a8 ad 	. . . 
	jp nc,la299h		;a1d6	d2 99 a2 	. . . 
	call sub_9b5bh		;a1d9	cd 5b 9b 	. [ . 
	call sub_aa05h		;a1dc	cd 05 aa 	. . . 
	jp la299h		;a1df	c3 99 a2 	. . . 
la1e2h:
	ld a,(0e58ch)		;a1e2	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;a1e5	32 aa e2 	2 . . 
	ld a,(0e58bh)		;a1e8	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a1eb	32 ab e2 	2 . . 
	call sub_ada8h		;a1ee	cd a8 ad 	. . . 
	jp nc,la299h		;a1f1	d2 99 a2 	. . . 
	call la901h		;a1f4	cd 01 a9 	. . . 
	call sub_9b80h		;a1f7	cd 80 9b 	. . . 
	call sub_aa05h		;a1fa	cd 05 aa 	. . . 
	jp la299h		;a1fd	c3 99 a2 	. . . 
la200h:
	ld a,(0e58ah)		;a200	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a203	32 aa e2 	2 . . 
	ld a,(0e58dh)		;a206	3a 8d e5 	: . . 
	ld (BRICK_COL),a		;a209	32 ab e2 	2 . . 
	call sub_ada8h		;a20c	cd a8 ad 	. . . 
	jp nc,la299h		;a20f	d2 99 a2 	. . . 
	call sub_a810h		;a212	cd 10 a8 	. . . 
	call sub_9b5bh		;a215	cd 5b 9b 	. [ . 
	call sub_aa05h		;a218	cd 05 aa 	. . . 
	jp la299h		;a21b	c3 99 a2 	. . . 
la21eh:
	ld a,(0e58ah)		;a21e	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a221	32 aa e2 	2 . . 
	ld a,(0e58dh)		;a224	3a 8d e5 	: . . 
	ld (BRICK_COL),a		;a227	32 ab e2 	2 . . 
	call sub_a670h		;a22a	cd 70 a6 	. p . 
	jp nc,la263h		;a22d	d2 63 a2 	. c . 
	call sub_ada8h		;a230	cd a8 ad 	. . . 
	jp nc,la24bh		;a233	d2 4b a2 	. K . 
	ld a,(0e53ch)		;a236	3a 3c e5 	: < . 
	ld (ix+000h),a		;a239	dd 77 00 	. w . 
	ld a,(0e53dh)		;a23c	3a 3d e5 	: = . 
	ld (ix+001h),a		;a23f	dd 77 01 	. w . 
	call sub_9b5bh		;a242	cd 5b 9b 	. [ . 
	call sub_aa05h		;a245	cd 05 aa 	. . . 
	jp la299h		;a248	c3 99 a2 	. . . 
la24bh:
	ld a,(0e58bh)		;a24b	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a24e	32 ab e2 	2 . . 
	call sub_ada8h		;a251	cd a8 ad 	. . . 
	jp nc,la299h		;a254	d2 99 a2 	. . . 
	call la901h		;a257	cd 01 a9 	. . . 
	call sub_9b80h		;a25a	cd 80 9b 	. . . 
	call sub_aa05h		;a25d	cd 05 aa 	. . . 
	jp la299h		;a260	c3 99 a2 	. . . 
la263h:
	ld a,(0e58ch)		;a263	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;a266	32 aa e2 	2 . . 
	ld a,(0e58bh)		;a269	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a26c	32 ab e2 	2 . . 
	call sub_ada8h		;a26f	cd a8 ad 	. . . 
	jp nc,la281h		;a272	d2 81 a2 	. . . 
	call la901h		;a275	cd 01 a9 	. . . 
	call sub_9b80h		;a278	cd 80 9b 	. . . 
	call sub_aa05h		;a27b	cd 05 aa 	. . . 
	jp la299h		;a27e	c3 99 a2 	. . . 
la281h:
	ld a,(0e58ah)		;a281	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a284	32 aa e2 	2 . . 
	call sub_ada8h		;a287	cd a8 ad 	. . . 
	jp nc,la299h		;a28a	d2 99 a2 	. . . 
	call sub_a810h		;a28d	cd 10 a8 	. . . 
	call sub_9b5bh		;a290	cd 5b 9b 	. [ . 
	call sub_aa05h		;a293	cd 05 aa 	. . . 
	jp la299h		;a296	c3 99 a2 	. . . 
la299h:
	ret			;a299	c9 	. 
sub_a29ah:
	ld a,(0e58bh)		;a29a	3a 8b e5 	: . . 
	cp 00bh		;a29d	fe 0b 	. . 
	jp nz,la324h		;a29f	c2 24 a3 	. $ . 
	ld a,(0e58dh)		;a2a2	3a 8d e5 	: . . 
	cp 00ah		;a2a5	fe 0a 	. . 
	jp nz,la324h		;a2a7	c2 24 a3 	. $ . 
	jp la2bdh		;a2aa	c3 bd a2 	. . . 
sub_a2adh:
	ld a,(0e58bh)		;a2ad	3a 8b e5 	: . . 
	cp 00fh		;a2b0	fe 0f 	. . 
	jp nz,la324h		;a2b2	c2 24 a3 	. $ . 
	ld a,(0e58dh)		;a2b5	3a 8d e5 	: . . 
	cp 000h		;a2b8	fe 00 	. . 
	jp nz,la324h		;a2ba	c2 24 a3 	. $ . 
la2bdh:
	ld a,(0e58ch)		;a2bd	3a 8c e5 	: . . 
	ld c,a			;a2c0	4f 	O 
	ld a,(0e58ah)		;a2c1	3a 8a e5 	: . . 
	cp c			;a2c4	b9 	. 
	jp z,la2dfh		;a2c5	ca df a2 	. . . 
	bit 7,(iy+002h)		;a2c8	fd cb 02 7e 	. . . ~ 
	jp nz,la2d7h		;a2cc	c2 d7 a2 	. . . 
	inc c			;a2cf	0c 	. 
	cp c			;a2d0	b9 	. 
	jp z,la2eeh		;a2d1	ca ee a2 	. . . 
	jp la326h		;a2d4	c3 26 a3 	. & . 
la2d7h:
	dec c			;a2d7	0d 	. 
	cp c			;a2d8	b9 	. 
	jp z,la2eeh		;a2d9	ca ee a2 	. . . 
	jp la326h		;a2dc	c3 26 a3 	. & . 
la2dfh:
	ld a,(0e58ch)		;a2df	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;a2e2	32 aa e2 	2 . . 
	call sub_a3d1h		;a2e5	cd d1 a3 	. . . 
	call sub_9b80h		;a2e8	cd 80 9b 	. . . 
	jp la326h		;a2eb	c3 26 a3 	. & . 
la2eeh:
	ld a,(0e58ah)		;a2ee	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a2f1	32 aa e2 	2 . . 
	call sub_a591h		;a2f4	cd 91 a5 	. . . 
	jp nc,la2dfh		;a2f7	d2 df a2 	. . . 
	ld a,(0e58dh)		;a2fa	3a 8d e5 	: . . 
	ld (BRICK_COL),a		;a2fd	32 ab e2 	2 . . 
	call sub_ada8h		;a300	cd a8 ad 	. . . 
	jp nc,la31bh		;a303	d2 1b a3 	. . . 
	ld a,(0e53ch)		;a306	3a 3c e5 	: < . 
	ld (ix+000h),a		;a309	dd 77 00 	. w . 
	ld a,(0e53dh)		;a30c	3a 3d e5 	: = . 
	ld (ix+001h),a		;a30f	dd 77 01 	. w . 
	call sub_9b5bh		;a312	cd 5b 9b 	. [ . 
	call sub_aa05h		;a315	cd 05 aa 	. . . 
	jp la326h		;a318	c3 26 a3 	. & . 
la31bh:
	call sub_a3d1h		;a31b	cd d1 a3 	. . . 
	call sub_9b80h		;a31e	cd 80 9b 	. . . 
	jp la326h		;a321	c3 26 a3 	. & . 
la324h:
	xor a			;a324	af 	. 
	ret			;a325	c9 	. 
la326h:
	scf			;a326	37 	7 
	ret			;a327	c9 	. 
sub_a328h:
	ld a,(0e58bh)		;a328	3a 8b e5 	: . . 
	ld b,a			;a32b	47 	G 
	ld a,(BRICK_COL)		;a32c	3a ab e2 	: . . 
	cp b			;a32f	b8 	. 
	jp nz,la354h		;a330	c2 54 a3 	. T . 
	ld a,(0e58ah)		;a333	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a336	32 aa e2 	2 . . 
	ld a,(0e58bh)		;a339	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a33c	32 ab e2 	2 . . 
	call sub_ada8h		;a33f	cd a8 ad 	. . . 
	jp nc,la351h		;a342	d2 51 a3 	. Q . 
	call sub_a810h		;a345	cd 10 a8 	. . . 
	call sub_9b5bh		;a348	cd 5b 9b 	. [ . 
	call sub_aa05h		;a34b	cd 05 aa 	. . . 
	jp la3d0h		;a34e	c3 d0 a3 	. . . 
la351h:
	jp la3d0h		;a351	c3 d0 a3 	. . . 
la354h:
	ld a,(0e58ah)		;a354	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a357	32 aa e2 	2 . . 
	ld a,(0e58dh)		;a35a	3a 8d e5 	: . . 
	bit 7,(iy+003h)		;a35d	fd cb 03 7e 	. . . ~ 
	jp z,la367h		;a361	ca 67 a3 	. g . 
	ld a,(0e58bh)		;a364	3a 8b e5 	: . . 
la367h:
	ld (BRICK_COL),a		;a367	32 ab e2 	2 . . 
	call sub_a670h		;a36a	cd 70 a6 	. p . 
	jp nc,la3afh		;a36d	d2 af a3 	. . . 
	ld a,(0e58ah)		;a370	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a373	32 aa e2 	2 . . 
	ld a,(0e58dh)		;a376	3a 8d e5 	: . . 
	ld (BRICK_COL),a		;a379	32 ab e2 	2 . . 
	call sub_ada8h		;a37c	cd a8 ad 	. . . 
	jp nc,la38eh		;a37f	d2 8e a3 	. . . 
	call sub_a810h		;a382	cd 10 a8 	. . . 
	call sub_9b5bh		;a385	cd 5b 9b 	. [ . 
	call sub_aa05h		;a388	cd 05 aa 	. . . 
	jp la3d0h		;a38b	c3 d0 a3 	. . . 
la38eh:
	ld a,(0e58ah)		;a38e	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a391	32 aa e2 	2 . . 
	ld a,(0e58bh)		;a394	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a397	32 ab e2 	2 . . 
	call sub_ada8h		;a39a	cd a8 ad 	. . . 
	jp nc,la3ach		;a39d	d2 ac a3 	. . . 
	call la901h		;a3a0	cd 01 a9 	. . . 
	call sub_9b80h		;a3a3	cd 80 9b 	. . . 
	call sub_aa05h		;a3a6	cd 05 aa 	. . . 
	jp la3d0h		;a3a9	c3 d0 a3 	. . . 
la3ach:
	jp la3d0h		;a3ac	c3 d0 a3 	. . . 
la3afh:
	ld a,(0e58ah)		;a3af	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a3b2	32 aa e2 	2 . . 
	ld a,(0e58bh)		;a3b5	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a3b8	32 ab e2 	2 . . 
	call sub_ada8h		;a3bb	cd a8 ad 	. . . 
	jp nc,la3cdh		;a3be	d2 cd a3 	. . . 
	call sub_a810h		;a3c1	cd 10 a8 	. . . 
	call sub_9b5bh		;a3c4	cd 5b 9b 	. [ . 
	call sub_aa05h		;a3c7	cd 05 aa 	. . . 
	jp la3d0h		;a3ca	c3 d0 a3 	. . . 
la3cdh:
	jp la3d0h		;a3cd	c3 d0 a3 	. . . 
la3d0h:
	ret			;a3d0	c9 	. 
sub_a3d1h:
	ld hl,0e541h		;a3d1	21 41 e5 	! A . 
	ld (hl),000h		;a3d4	36 00 	6 . 
	ld de,0e542h		;a3d6	11 42 e5 	. B . 
	ld bc,00002h		;a3d9	01 02 00 	. . . 
	ldir		;a3dc	ed b0 	. . 
	ld a,(BRICK_COL)		;a3de	3a ab e2 	: . . 
	sla a		;a3e1	cb 27 	. ' 
	sla a		;a3e3	cb 27 	. ' 
	sla a		;a3e5	cb 27 	. ' 
	sla a		;a3e7	cb 27 	. ' 
	ld b,010h		;a3e9	06 10 	. . 
	bit 7,(iy+003h)		;a3eb	fd cb 03 7e 	. . . ~ 
	jp nz,la3f4h		;a3ef	c2 f4 a3 	. . . 
	ld b,00ch		;a3f2	06 0c 	. . 
la3f4h:
	add a,b			;a3f4	80 	. 
	ld (0e2c7h),a		;a3f5	32 c7 e2 	2 . . 
	add a,00fh		;a3f8	c6 0f 	. . 
	ld (0e2c6h),a		;a3fa	32 c6 e2 	2 . . 
	ld a,(iy+006h)		;a3fd	fd 7e 06 	. ~ . 
	bit 7,a		;a400	cb 7f 	.  
	jp z,la407h		;a402	ca 07 a4 	. . . 
	neg		;a405	ed 44 	. D 
la407h:
	dec a			;a407	3d 	= 
	sla a		;a408	cb 27 	. ' 
	ld l,a			;a40a	6f 	o 
	ld h,000h		;a40b	26 00 	& . 
	ld de,la86ch		;a40d	11 6c a8 	. l . 
	add hl,de			;a410	19 	. 
	ld a,(hl)			;a411	7e 	~ 
	bit 7,(iy+002h)		;a412	fd cb 02 7e 	. . . ~ 
	jp nz,la41bh		;a416	c2 1b a4 	. . . 
	neg		;a419	ed 44 	. D 
la41bh:
	ld (0e542h),a		;a41b	32 42 e5 	2 B . 
	inc hl			;a41e	23 	# 
	ld a,(hl)			;a41f	7e 	~ 
	bit 7,(iy+002h)		;a420	fd cb 02 7e 	. . . ~ 
	jp nz,la429h		;a424	c2 29 a4 	. ) . 
	neg		;a427	ed 44 	. D 
la429h:
	ld (0e543h),a		;a429	32 43 e5 	2 C . 
	ld a,(0e542h)		;a42c	3a 42 e5 	: B . 
	ld b,a			;a42f	47 	G 
	ld a,(0e587h)		;a430	3a 87 e5 	: . . 
	ld hl,0e2c6h		;a433	21 c6 e2 	! . . 
	bit 7,(iy+003h)		;a436	fd cb 03 7e 	. . . ~ 
	jp nz,la452h		;a43a	c2 52 a4 	. R . 
	ld hl,0e2c7h		;a43d	21 c7 e2 	! . . 
	inc (hl)			;a440	34 	4 
la441h:
	push af			;a441	f5 	. 
	ld a,(0e541h)		;a442	3a 41 e5 	: A . 
	inc a			;a445	3c 	< 
	ld (0e541h),a		;a446	32 41 e5 	2 A . 
	pop af			;a449	f1 	. 
	add a,b			;a44a	80 	. 
	cp (hl)			;a44b	be 	. 
	jp nc,la463h		;a44c	d2 63 a4 	. c . 
	jp la441h		;a44f	c3 41 a4 	. A . 
la452h:
	push af			;a452	f5 	. 
	ld a,(0e541h)		;a453	3a 41 e5 	: A . 
	inc a			;a456	3c 	< 
	ld (0e541h),a		;a457	32 41 e5 	2 A . 
	pop af			;a45a	f1 	. 
	add a,b			;a45b	80 	. 
	cp (hl)			;a45c	be 	. 
	jp c,la464h		;a45d	da 64 a4 	. d . 
	jp la452h		;a460	c3 52 a4 	. R . 
la463h:
	dec (hl)			;a463	35 	5 
la464h:
	ld a,(0e541h)		;a464	3a 41 e5 	: A . 
	ld b,a			;a467	47 	G 
	ld a,(0e543h)		;a468	3a 43 e5 	: C . 
	ld c,a			;a46b	4f 	O 
	neg		;a46c	ed 44 	. D 
la46eh:
	add a,c			;a46e	81 	. 
	djnz la46eh		;a46f	10 fd 	. . 
	ld b,a			;a471	47 	G 
	ld a,(0e586h)		;a472	3a 86 e5 	: . . 
	add a,b			;a475	80 	. 
	ld b,a			;a476	47 	G 
	bit 7,(iy+002h)		;a477	fd cb 02 7e 	. . . ~ 
	jp nz,la49ch		;a47b	c2 9c a4 	. . . 
	ld a,(BRICK_ROW)		;a47e	3a aa e2 	: . . 
	sla a		;a481	cb 27 	. ' 
	sla a		;a483	cb 27 	. ' 
	sla a		;a485	cb 27 	. ' 
	add a,012h		;a487	c6 12 	. . 
	cp b			;a489	b8 	. 
	jp c,la492h		;a48a	da 92 a4 	. . . 
	inc a			;a48d	3c 	< 
	ld b,a			;a48e	47 	G 
	jp la4bbh		;a48f	c3 bb a4 	. . . 
la492h:
	add a,008h		;a492	c6 08 	. . 
	cp b			;a494	b8 	. 
	jp nc,la4bbh		;a495	d2 bb a4 	. . . 
	ld b,a			;a498	47 	G 
	jp la4bbh		;a499	c3 bb a4 	. . . 
la49ch:
	ld a,(BRICK_ROW)		;a49c	3a aa e2 	: . . 
	sla a		;a49f	cb 27 	. ' 
	sla a		;a4a1	cb 27 	. ' 
	sla a		;a4a3	cb 27 	. ' 
	add a,01fh		;a4a5	c6 1f 	. . 
	cp b			;a4a7	b8 	. 
	jp nc,la4afh		;a4a8	d2 af a4 	. . . 
	ld b,a			;a4ab	47 	G 
	jp la4bbh		;a4ac	c3 bb a4 	. . . 
la4afh:
	sub 008h		;a4af	d6 08 	. . 
	cp b			;a4b1	b8 	. 
	jp c,la4bah		;a4b2	da ba a4 	. . . 
	inc a			;a4b5	3c 	< 
	ld b,a			;a4b6	47 	G 
	jp la4bbh		;a4b7	c3 bb a4 	. . . 
la4bah:
	inc a			;a4ba	3c 	< 
la4bbh:
	ld b,a			;a4bb	47 	G 
	ld (VAUS_X2),a		;a4bc	32 3e e5 	2 > . 
	ld a,(0e2c7h)		;a4bf	3a c7 e2 	: . . 
	bit 7,(iy+003h)		;a4c2	fd cb 03 7e 	. . . ~ 
	jp z,la4cch		;a4c6	ca cc a4 	. . . 
	ld a,(0e2c6h)		;a4c9	3a c6 e2 	: . . 
la4cch:
	ld (0e53dh),a		;a4cc	32 3d e5 	2 = . 
	ld hl,0e541h		;a4cf	21 41 e5 	! A . 
	ld (hl),000h		;a4d2	36 00 	6 . 
	ld de,0e542h		;a4d4	11 42 e5 	. B . 
	ld bc,00002h		;a4d7	01 02 00 	. . . 
	ldir		;a4da	ed b0 	. . 
	ld a,(BRICK_ROW)		;a4dc	3a aa e2 	: . . 
	sla a		;a4df	cb 27 	. ' 
	sla a		;a4e1	cb 27 	. ' 
	sla a		;a4e3	cb 27 	. ' 
	ld b,018h		;a4e5	06 18 	. . 
	bit 7,(iy+002h)		;a4e7	fd cb 02 7e 	. . . ~ 
	jp nz,la4f0h		;a4eb	c2 f0 a4 	. . . 
	ld b,013h		;a4ee	06 13 	. . 
la4f0h:
	add a,b			;a4f0	80 	. 
	ld (0e2c4h),a		;a4f1	32 c4 e2 	2 . . 
	add a,007h		;a4f4	c6 07 	. . 
	ld (0e2c5h),a		;a4f6	32 c5 e2 	2 . . 
	ld a,(iy+006h)		;a4f9	fd 7e 06 	. ~ . 
	bit 7,a		;a4fc	cb 7f 	.  
	jp z,la503h		;a4fe	ca 03 a5 	. . . 
	neg		;a501	ed 44 	. D 
la503h:
	dec a			;a503	3d 	= 
	sla a		;a504	cb 27 	. ' 
	ld l,a			;a506	6f 	o 
	ld h,000h		;a507	26 00 	& . 
	ld de,la86ch		;a509	11 6c a8 	. l . 
	add hl,de			;a50c	19 	. 
	ld a,(hl)			;a50d	7e 	~ 
	bit 7,(iy+002h)		;a50e	fd cb 02 7e 	. . . ~ 
	jp nz,la517h		;a512	c2 17 a5 	. . . 
	neg		;a515	ed 44 	. D 
la517h:
	ld (0e542h),a		;a517	32 42 e5 	2 B . 
	inc hl			;a51a	23 	# 
	ld a,(hl)			;a51b	7e 	~ 
	bit 7,(iy+002h)		;a51c	fd cb 02 7e 	. . . ~ 
	jp nz,la525h		;a520	c2 25 a5 	. % . 
	neg		;a523	ed 44 	. D 
la525h:
	ld (0e543h),a		;a525	32 43 e5 	2 C . 
	ld a,(0e543h)		;a528	3a 43 e5 	: C . 
	ld b,a			;a52b	47 	G 
	ld a,(0e586h)		;a52c	3a 86 e5 	: . . 
la52fh:
	ld hl,0e2c5h		;a52f	21 c5 e2 	! . . 
	bit 7,(iy+002h)		;a532	fd cb 02 7e 	. . . ~ 
	jp nz,la54eh		;a536	c2 4e a5 	. N . 
	ld hl,0e2c4h		;a539	21 c4 e2 	! . . 
	inc (hl)			;a53c	34 	4 
la53dh:
	push af			;a53d	f5 	. 
	ld a,(0e541h)		;a53e	3a 41 e5 	: A . 
	inc a			;a541	3c 	< 
	ld (0e541h),a		;a542	32 41 e5 	2 A . 
	pop af			;a545	f1 	. 
	add a,b			;a546	80 	. 
	cp (hl)			;a547	be 	. 
	jp nc,la55fh		;a548	d2 5f a5 	. _ . 
	jp la53dh		;a54b	c3 3d a5 	. = . 
la54eh:
	push af			;a54e	f5 	. 
	ld a,(0e541h)		;a54f	3a 41 e5 	: A . 
	inc a			;a552	3c 	< 
	ld (0e541h),a		;a553	32 41 e5 	2 A . 
	pop af			;a556	f1 	. 
	add a,b			;a557	80 	. 
	cp (hl)			;a558	be 	. 
	jp c,la560h		;a559	da 60 a5 	. ` . 
	jp la54eh		;a55c	c3 4e a5 	. N . 
la55fh:
	dec (hl)			;a55f	35 	5 
la560h:
	ld a,(0e541h)		;a560	3a 41 e5 	: A . 
	ld b,a			;a563	47 	G 
	ld a,(0e542h)		;a564	3a 42 e5 	: B . 
	ld c,a			;a567	4f 	O 
	neg		;a568	ed 44 	. D 
la56ah:
	add a,c			;a56a	81 	. 
	djnz la56ah		;a56b	10 fd 	. . 
	ld b,a			;a56d	47 	G 
	ld a,(0e587h)		;a56e	3a 87 e5 	: . . 
	add a,b			;a571	80 	. 
	ld (0e53ch),a		;a572	32 3c e5 	2 < . 
	ld b,a			;a575	47 	G 
	ld a,0bch		;a576	3e bc 	> . 
	bit 7,(iy+003h)		;a578	fd cb 03 7e 	. . . ~ 
	jp z,la589h		;a57c	ca 89 a5 	. . . 
	ld a,00fh		;a57f	3e 0f 	> . 
	cp b			;a581	b8 	. 
	jp c,la587h		;a582	da 87 a5 	. . . 
	or a			;a585	b7 	. 
	ret			;a586	c9 	. 
la587h:
	scf			;a587	37 	7 
	ret			;a588	c9 	. 
la589h:
	cp b			;a589	b8 	. 
	jp c,la58fh		;a58a	da 8f a5 	. . . 
	scf			;a58d	37 	7 
	ret			;a58e	c9 	.
la58fh:
	or a			;a58f	b7 	. 
	ret			;a590	c9 	. 
sub_a591h:
	ld hl,0e541h		;a591	21 41 e5 	! A . 
	ld (hl),000h		;a594	36 00 	6 . 
	ld de,0e542h		;a596	11 42 e5 	. B . 
	ld bc,00002h		;a599	01 02 00 	. . . 
	ldir		;a59c	ed b0 	. . 
	ld a,(BRICK_ROW)		;a59e	3a aa e2 	: . . 
	sla a		;a5a1	cb 27 	. ' 
	sla a		;a5a3	cb 27 	. ' 
	sla a		;a5a5	cb 27 	. ' 
	ld b,018h		;a5a7	06 18 	. . 
	bit 7,(iy+002h)		;a5a9	fd cb 02 7e 	. . . ~ 
	jp nz,la5b2h		;a5ad	c2 b2 a5 	. . . 
	ld b,013h		;a5b0	06 13 	. . 
la5b2h:
	add a,b			;a5b2	80 	. 
	ld (0e2c4h),a		;a5b3	32 c4 e2 	2 . . 
	add a,007h		;a5b6	c6 07 	. . 
	ld (0e2c5h),a		;a5b8	32 c5 e2 	2 . . 
	ld a,(iy+006h)		;a5bb	fd 7e 06 	. ~ . 
	bit 7,a		;a5be	cb 7f 	.  
	jp z,la5c5h		;a5c0	ca c5 a5 	. . . 
	neg		;a5c3	ed 44 	. D 
la5c5h:
	dec a			;a5c5	3d 	= 
	sla a		;a5c6	cb 27 	. ' 
	ld l,a			;a5c8	6f 	o 
	ld h,000h		;a5c9	26 00 	& . 
	ld de,la86ch		;a5cb	11 6c a8 	. l . 
	add hl,de			;a5ce	19 	. 
	ld a,(hl)			;a5cf	7e 	~ 
	bit 7,(iy+002h)		;a5d0	fd cb 02 7e 	. . . ~ 
	jp nz,la5d9h		;a5d4	c2 d9 a5 	. . . 
	neg		;a5d7	ed 44 	. D 
la5d9h:
	ld (0e542h),a		;a5d9	32 42 e5 	2 B . 
	inc hl			;a5dc	23 	# 
	ld a,(hl)			;a5dd	7e 	~ 
	bit 7,(iy+002h)		;a5de	fd cb 02 7e 	. . . ~ 
	jp nz,la5e7h		;a5e2	c2 e7 a5 	. . . 
	neg		;a5e5	ed 44 	. D 
la5e7h:
	ld (0e543h),a		;a5e7	32 43 e5 	2 C . 
	ld a,(0e543h)		;a5ea	3a 43 e5 	: C . 
	ld b,a			;a5ed	47 	G 
	ld a,(0e586h)		;a5ee	3a 86 e5 	: . . 
	ld hl,0e2c5h		;a5f1	21 c5 e2 	! . . 
	bit 7,(iy+002h)		;a5f4	fd cb 02 7e 	. . . ~ 
	jp nz,la610h		;a5f8	c2 10 a6 	. . . 
	ld hl,0e2c4h		;a5fb	21 c4 e2 	! . . 
	inc (hl)			;a5fe	34 	4 
la5ffh:
	push af			;a5ff	f5 	. 
	ld a,(0e541h)		;a600	3a 41 e5 	: A . 
	inc a			;a603	3c 	< 
	ld (0e541h),a		;a604	32 41 e5 	2 A . 
	pop af			;a607	f1 	. 
	add a,b			;a608	80 	. 
	cp (hl)			;a609	be 	. 
	jp nc,la621h		;a60a	d2 21 a6 	. ! . 
	jp la5ffh		;a60d	c3 ff a5 	. . . 
la610h:
	push af			;a610	f5 	. 
	ld a,(0e541h)		;a611	3a 41 e5 	: A . 
	inc a			;a614	3c 	< 
	ld (0e541h),a		;a615	32 41 e5 	2 A . 
	pop af			;a618	f1 	. 
	add a,b			;a619	80 	. 
	cp (hl)			;a61a	be 	. 
	jp c,la622h		;a61b	da 22 a6 	. " . 
	jp la610h		;a61e	c3 10 a6 	. . . 
la621h:
	dec (hl)			;a621	35 	5 
la622h:
	ld a,(0e541h)		;a622	3a 41 e5 	: A . 
	ld b,a			;a625	47 	G 
	ld a,(0e542h)		;a626	3a 42 e5 	: B . 
	ld c,a			;a629	4f 	O 
	neg		;a62a	ed 44 	. D 
la62ch:
	add a,c			;a62c	81 	. 
	djnz la62ch		;a62d	10 fd 	. . 
	ld b,a			;a62f	47 	G 
	ld a,(0e587h)		;a630	3a 87 e5 	: . . 
	add a,b			;a633	80 	. 
	ld b,a			;a634	47 	G 
	ld a,0bch		;a635	3e bc 	> . 
	bit 7,(iy+003h)		;a637	fd cb 03 7e 	. . . ~ 
	jp z,la64eh		;a63b	ca 4e a6 	. N . 
	ld a,00fh		;a63e	3e 0f 	> . 
	cp b			;a640	b8 	. 
	jp c,la64ah		;a641	da 4a a6 	. J . 
	or a			;a644	b7 	. 
	ld b,a			;a645	47 	G 
	inc b			;a646	04 	. 
	jp la65bh		;a647	c3 5b a6 	. [ . 
la64ah:
	scf			;a64a	37 	7 
	jp la65bh		;a64b	c3 5b a6 	. [ . 
la64eh:
	cp b			;a64e	b8 	. 
	jp c,la656h		;a64f	da 56 a6 	. V . 
	scf			;a652	37 	7 
	jp la65bh		;a653	c3 5b a6 	. [ . 
la656h:
	ld b,a			;a656	47 	G 
	or a			;a657	b7 	. 
	jp la65bh		;a658	c3 5b a6 	. [ . 
la65bh:
	ld a,b			;a65b	78 	x 
	ld (0e53dh),a		;a65c	32 3d e5 	2 = . 
	ld a,(0e2c4h)		;a65f	3a c4 e2 	: . . 
	bit 7,(iy+002h)		;a662	fd cb 02 7e 	. . . ~ 
	jp z,la66ch		;a666	ca 6c a6 	. l . 
	ld a,(0e2c5h)		;a669	3a c5 e2 	: . . 
la66ch:
	ld (0e53ch),a		;a66c	32 3c e5 	2 < . 
	ret			;a66f	c9 	. 
sub_a670h:
	ld hl,0e541h		;a670	21 41 e5 	! A . 
	ld (hl),000h		;a673	36 00 	6 . 
	ld de,0e542h		;a675	11 42 e5 	. B . 
	ld bc,00002h		;a678	01 02 00 	. . . 
	ldir		;a67b	ed b0 	. . 
	ld a,(BRICK_ROW)		;a67d	3a aa e2 	: . . 
	sla a		;a680	cb 27 	. ' 
	sla a		;a682	cb 27 	. ' 
	sla a		;a684	cb 27 	. ' 
	ld b,013h		;a686	06 13 	. . 
	bit 7,(iy+002h)		;a688	fd cb 02 7e 	. . . ~ 
	jp z,la691h		;a68c	ca 91 a6 	. . . 
	ld b,018h		;a68f	06 18 	. . 
la691h:
	add a,b			;a691	80 	. 
	ld (0e2c4h),a		;a692	32 c4 e2 	2 . . 
	add a,007h		;a695	c6 07 	. . 
	ld (0e2c5h),a		;a697	32 c5 e2 	2 . . 
	ld a,(iy+006h)		;a69a	fd 7e 06 	. ~ . 
	bit 7,a		;a69d	cb 7f 	.  
	jp z,la6a4h		;a69f	ca a4 a6 	. . . 
	neg		;a6a2	ed 44 	. D 
la6a4h:
	dec a			;a6a4	3d 	= 
	sla a		;a6a5	cb 27 	. ' 
	ld l,a			;a6a7	6f 	o 
	ld h,000h		;a6a8	26 00 	& . 
	ld de,la86ch		;a6aa	11 6c a8 	. l . 
	add hl,de			;a6ad	19 	. 
	ld a,(hl)			;a6ae	7e 	~ 
	bit 7,(iy+002h)		;a6af	fd cb 02 7e 	. . . ~ 
	jp nz,la6b8h		;a6b3	c2 b8 a6 	. . . 
	neg		;a6b6	ed 44 	. D 
la6b8h:
	ld (0e542h),a		;a6b8	32 42 e5 	2 B . 
	inc hl			;a6bb	23 	# 
	ld a,(hl)			;a6bc	7e 	~ 
	bit 7,(iy+002h)		;a6bd	fd cb 02 7e 	. . . ~ 
	jp nz,la6c6h		;a6c1	c2 c6 a6 	. . . 
	neg		;a6c4	ed 44 	. D 
la6c6h:
	ld (0e543h),a		;a6c6	32 43 e5 	2 C . 
	jp la6cch		;a6c9	c3 cc a6 	. . . 
la6cch:
	ld a,(0e543h)		;a6cc	3a 43 e5 	: C . 
	ld b,a			;a6cf	47 	G 
	ld a,(0e586h)		;a6d0	3a 86 e5 	: . . 
	ld hl,0e2c5h		;a6d3	21 c5 e2 	! . . 
	bit 7,(iy+002h)		;a6d6	fd cb 02 7e 	. . . ~ 
	jp nz,la6f2h		;a6da	c2 f2 a6 	. . . 
	ld hl,0e2c4h		;a6dd	21 c4 e2 	! . . 
	inc (hl)			;a6e0	34 	4 
la6e1h:
	push af			;a6e1	f5 	. 
	ld a,(0e541h)		;a6e2	3a 41 e5 	: A . 
	inc a			;a6e5	3c 	< 
	ld (0e541h),a		;a6e6	32 41 e5 	2 A . 
	pop af			;a6e9	f1 	. 
	add a,b			;a6ea	80 	. 
	cp (hl)			;a6eb	be 	. 
	jp nc,la703h		;a6ec	d2 03 a7 	. . . 
	jp la6e1h		;a6ef	c3 e1 a6 	. . . 
la6f2h:
	push af			;a6f2	f5 	. 
	ld a,(0e541h)		;a6f3	3a 41 e5 	: A . 
	inc a			;a6f6	3c 	< 
	ld (0e541h),a		;a6f7	32 41 e5 	2 A . 
	pop af			;a6fa	f1 	. 
	add a,b			;a6fb	80 	. 
	cp (hl)			;a6fc	be 	. 
	jp c,la704h		;a6fd	da 04 a7 	. . . 
	jp la6f2h		;a700	c3 f2 a6 	. . . 
la703h:
	dec (hl)			;a703	35 	5 
la704h:
	ld a,(0e541h)		;a704	3a 41 e5 	: A . 
	ld b,a			;a707	47 	G 
	ld a,(0e542h)		;a708	3a 42 e5 	: B . 
	ld c,a			;a70b	4f 	O 
	neg		;a70c	ed 44 	. D 
la70eh:
	add a,c			;a70e	81 	. 
	djnz la70eh		;a70f	10 fd 	. . 
	ld b,a			;a711	47 	G 
	ld a,(0e587h)		;a712	3a 87 e5 	: . . 
	add a,b			;a715	80 	. 
	ld b,a			;a716	47 	G 
	bit 7,(iy+002h)		;a717	fd cb 02 7e 	. . . ~ 
	jp nz,la797h		;a71b	c2 97 a7 	. . . 
	bit 7,(iy+003h)		;a71e	fd cb 03 7e 	. . . ~ 
	jp nz,la75eh		;a722	c2 5e a7 	. ^ . 
	ld a,(BRICK_COL)		;a725	3a ab e2 	: . . 
	sla a		;a728	cb 27 	. ' 
	sla a		;a72a	cb 27 	. ' 
	sla a		;a72c	cb 27 	. ' 
	sla a		;a72e	cb 27 	. ' 
	add a,00ch		;a730	c6 0c 	. . 
	cp b			;a732	b8 	. 
	jp c,la73bh		;a733	da 3b a7 	. ; . 
	ld b,a			;a736	47 	G 
	scf			;a737	37 	7 
	jp la751h		;a738	c3 51 a7 	. Q . 
la73bh:
	add a,01fh		;a73b	c6 1f 	. . 
	cp b			;a73d	b8 	. 
	jp nc,la746h		;a73e	d2 46 a7 	. F . 
	ld b,a			;a741	47 	G 
	or a			;a742	b7 	. 
	jp la751h		;a743	c3 51 a7 	. Q . 
la746h:
	sub 010h		;a746	d6 10 	. . 
	cp b			;a748	b8 	. 
	jp c,la750h		;a749	da 50 a7 	. P . 
	scf			;a74c	37 	7 
	jp la751h		;a74d	c3 51 a7 	. Q . 
la750h:
	or a			;a750	b7 	. 
la751h:
	push af			;a751	f5 	. 
	ld a,(0e2c4h)		;a752	3a c4 e2 	: . . 
	ld (0e53ch),a		;a755	32 3c e5 	2 < . 
	ld a,b			;a758	78 	x 
	ld (0e53dh),a		;a759	32 3d e5 	2 = . 
	pop af			;a75c	f1 	. 
	ret			;a75d	c9 	. 
la75eh:
	ld a,(BRICK_COL)		;a75e	3a ab e2 	: . . 
	sla a		;a761	cb 27 	. ' 
	sla a		;a763	cb 27 	. ' 
	sla a		;a765	cb 27 	. ' 
	sla a		;a767	cb 27 	. ' 
	add a,010h		;a769	c6 10 	. . 
	cp b			;a76b	b8 	. 
	jp c,la774h		;a76c	da 74 a7 	. t . 
	ld b,a			;a76f	47 	G 
	or a			;a770	b7 	. 
	jp la78ah		;a771	c3 8a a7 	. . . 
la774h:
	add a,01fh		;a774	c6 1f 	. . 
	cp b			;a776	b8 	. 
	jp nc,la77fh		;a777	d2 7f a7 	.  . 
	ld b,a			;a77a	47 	G 
	scf			;a77b	37 	7 
	jp la78ah		;a77c	c3 8a a7 	. . . 
la77fh:
	sub 010h		;a77f	d6 10 	. . 
	cp b			;a781	b8 	. 
	jp c,la789h		;a782	da 89 a7 	. . . 
	scf			;a785	37 	7 
	jp la78ah		;a786	c3 8a a7 	. . . 
la789h:
	or a			;a789	b7 	. 
la78ah:
	push af			;a78a	f5 	. 
	ld a,(0e2c4h)		;a78b	3a c4 e2 	: . . 
	ld (0e53ch),a		;a78e	32 3c e5 	2 < . 
	ld a,b			;a791	78 	x 
	ld (0e53dh),a		;a792	32 3d e5 	2 = . 
	pop af			;a795	f1 	. 
	ret			;a796	c9 	. 
la797h:
	bit 7,(iy+003h)		;a797	fd cb 03 7e 	. . . ~ 
	jp nz,la7d7h		;a79b	c2 d7 a7 	. . . 
	ld a,(BRICK_COL)		;a79e	3a ab e2 	: . . 
	sla a		;a7a1	cb 27 	. ' 
	sla a		;a7a3	cb 27 	. ' 
	sla a		;a7a5	cb 27 	. ' 
	sla a		;a7a7	cb 27 	. ' 
	add a,00ch		;a7a9	c6 0c 	. . 
	cp b			;a7ab	b8 	. 
	jp c,la7b4h		;a7ac	da b4 a7 	. . . 
	ld b,a			;a7af	47 	G 
	scf			;a7b0	37 	7 
	jp la7cah		;a7b1	c3 ca a7 	. . . 
la7b4h:
	add a,01fh		;a7b4	c6 1f 	. . 
	cp b			;a7b6	b8 	. 
	jp nc,la7bfh		;a7b7	d2 bf a7 	. . . 
	ld b,a			;a7ba	47 	G 
	or a			;a7bb	b7 	. 
	jp la7cah		;a7bc	c3 ca a7 	. . . 
la7bfh:
	sub 010h		;a7bf	d6 10 	. . 
	cp b			;a7c1	b8 	. 
	jp c,la7c9h		;a7c2	da c9 a7 	. . . 
	scf			;a7c5	37 	7 
	jp la7cah		;a7c6	c3 ca a7 	. . . 
la7c9h:
	or a			;a7c9	b7 	. 
la7cah:
	push af			;a7ca	f5 	. 
	ld a,(0e2c5h)		;a7cb	3a c5 e2 	: . . 
	ld (0e53ch),a		;a7ce	32 3c e5 	2 < . 
	ld a,b			;a7d1	78 	x 
	ld (0e53dh),a		;a7d2	32 3d e5 	2 = . 
	pop af			;a7d5	f1 	. 
	ret			;a7d6	c9 	. 
la7d7h:
	ld a,(BRICK_COL)		;a7d7	3a ab e2 	: . . 
	sla a		;a7da	cb 27 	. ' 
	sla a		;a7dc	cb 27 	. ' 
	sla a		;a7de	cb 27 	. ' 
	sla a		;a7e0	cb 27 	. ' 
	add a,010h		;a7e2	c6 10 	. . 
	cp b			;a7e4	b8 	. 
	jp c,la7edh		;a7e5	da ed a7 	. . . 
	ld b,a			;a7e8	47 	G 
	or a			;a7e9	b7 	. 
	jp la803h		;a7ea	c3 03 a8 	. . . 
la7edh:
	add a,01fh		;a7ed	c6 1f 	. . 
	cp b			;a7ef	b8 	. 
	jp nc,la7f8h		;a7f0	d2 f8 a7 	. . . 
	ld b,a			;a7f3	47 	G 
	scf			;a7f4	37 	7 
	jp la803h		;a7f5	c3 03 a8 	. . . 
la7f8h:
	sub 010h		;a7f8	d6 10 	. . 
	cp b			;a7fa	b8 	. 
	jp c,la802h		;a7fb	da 02 a8 	. . . 
	scf			;a7fe	37 	7 
	jp la803h		;a7ff	c3 03 a8 	. . . 
la802h:
	or a			;a802	b7 	. 
la803h:
	push af			;a803	f5 	. 
	ld a,(0e2c5h)		;a804	3a c5 e2 	: . . 
	ld (0e53ch),a		;a807	32 3c e5 	2 < . 
	ld a,b			;a80a	78 	x 
	ld (0e53dh),a		;a80b	32 3d e5 	2 = . 
	pop af			;a80e	f1 	. 
	ret			;a80f	c9 	. 
sub_a810h:
	ld hl,0e541h		;a810	21 41 e5 	! A . 
	ld (hl),000h		;a813	36 00 	6 . 
	ld de,0e542h		;a815	11 42 e5 	. B . 
	ld bc,00002h		;a818	01 02 00 	. . . 
	ldir		;a81b	ed b0 	. . 
	ld a,(BRICK_ROW)		;a81d	3a aa e2 	: . . 
	sla a		;a820	cb 27 	. ' 
	sla a		;a822	cb 27 	. ' 
	sla a		;a824	cb 27 	. ' 
	ld b,018h		;a826	06 18 	. . 
	bit 7,(iy+002h)		;a828	fd cb 02 7e 	. . . ~ 
	jp nz,la831h		;a82c	c2 31 a8 	. 1 . 
	ld b,013h		;a82f	06 13 	. . 
la831h:
	add a,b			;a831	80 	. 
	ld (0e2c4h),a		;a832	32 c4 e2 	2 . . 
	add a,007h		;a835	c6 07 	. . 
	ld (0e2c5h),a		;a837	32 c5 e2 	2 . . 
	ld a,(iy+006h)		;a83a	fd 7e 06 	. ~ . 
	bit 7,a		;a83d	cb 7f 	.  
	jp z,la844h		;a83f	ca 44 a8 	. D . 
	neg		;a842	ed 44 	. D 
la844h:
	dec a			;a844	3d 	= 
	sla a		;a845	cb 27 	. ' 
	ld l,a			;a847	6f 	o 
	ld h,000h		;a848	26 00 	& . 
	ld de,la86ch		;a84a	11 6c a8 	. l . 
	add hl,de			;a84d	19 	. 
	ld a,(hl)			;a84e	7e 	~ 
	bit 7,(iy+002h)		;a84f	fd cb 02 7e 	. . . ~ 
	jp nz,la858h		;a853	c2 58 a8 	. X . 
	neg		;a856	ed 44 	. D 
la858h:
	ld (0e542h),a		;a858	32 42 e5 	2 B . 
	inc hl			;a85b	23 	# 
	ld a,(hl)			;a85c	7e 	~ 
	bit 7,(iy+002h)		;a85d	fd cb 02 7e 	. . . ~ 
	jp nz,la866h		;a861	c2 66 a8 	. f . 
	neg		;a864	ed 44 	. D 
la866h:
	ld (0e543h),a		;a866	32 43 e5 	2 C . 
	jp 0a87ch		;a869	c3 7c a8 	. | . 
la86ch:
	inc b			;a86c	04 	. 
	rst 38h			;a86d	ff 	. 
	ld (bc),a			;a86e	02 	. 
	rst 38h			;a86f	ff 	. 
	ld bc,001ffh		;a870	01 ff 01 	. . . 
	cp 0ffh		;a873	fe ff 	. . 
	cp 0ffh		;a875	fe ff 	. . 
	rst 38h			;a877	ff 	. 
	cp 0ffh		;a878	fe ff 	. . 
	call m,03affh		;a87a	fc ff 3a 	. . : 
	ld b,e			;a87d	43 	C 
	push hl			;a87e	e5 	. 
	ld b,a			;a87f	47 	G 
	ld a,(0e586h)		;a880	3a 86 e5 	: . . 
	ld hl,0e2c5h		;a883	21 c5 e2 	! . . 
	bit 7,(iy+002h)		;a886	fd cb 02 7e 	. . . ~ 
	jp nz,la8a2h		;a88a	c2 a2 a8 	. . . 
	ld hl,0e2c4h		;a88d	21 c4 e2 	! . . 
	inc (hl)			;a890	34 	4 
la891h:
	push af			;a891	f5 	. 
	ld a,(0e541h)		;a892	3a 41 e5 	: A . 
	inc a			;a895	3c 	< 
	ld (0e541h),a		;a896	32 41 e5 	2 A . 
	pop af			;a899	f1 	. 
	add a,b			;a89a	80 	. 
	cp (hl)			;a89b	be 	. 
	jp nc,la8b3h		;a89c	d2 b3 a8 	. . . 
	jp la891h		;a89f	c3 91 a8 	. . . 
la8a2h:
	push af			;a8a2	f5 	. 
	ld a,(0e541h)		;a8a3	3a 41 e5 	: A . 
	inc a			;a8a6	3c 	< 
	ld (0e541h),a		;a8a7	32 41 e5 	2 A . 
	pop af			;a8aa	f1 	. 
	add a,b			;a8ab	80 	. 
	cp (hl)			;a8ac	be 	. 
	jp c,la8b4h		;a8ad	da b4 a8 	. . . 
	jp la8a2h		;a8b0	c3 a2 a8 	. . . 
la8b3h:
	dec (hl)			;a8b3	35 	5 
la8b4h:
	ld a,(0e541h)		;a8b4	3a 41 e5 	: A . 
	ld b,a			;a8b7	47 	G 
	ld a,(0e542h)		;a8b8	3a 42 e5 	: B . 
	ld c,a			;a8bb	4f 	O 
	neg		;a8bc	ed 44 	. D 
la8beh:
	add a,c			;a8be	81 	. 
	djnz la8beh		;a8bf	10 fd 	. . 
	ld b,a			;a8c1	47 	G 
	ld a,(0e587h)		;a8c2	3a 87 e5 	: . . 
	add a,b			;a8c5	80 	. 
	ld b,a			;a8c6	47 	G 
	ld a,(BRICK_COL)		;a8c7	3a ab e2 	: . . 
	sla a		;a8ca	cb 27 	. ' 
	sla a		;a8cc	cb 27 	. ' 
	sla a		;a8ce	cb 27 	. ' 
	sla a		;a8d0	cb 27 	. ' 
	ld c,011h		;a8d2	0e 11 	. . 
	bit 7,(iy+003h)		;a8d4	fd cb 03 7e 	. . . ~ 
	jp nz,la8ddh		;a8d8	c2 dd a8 	. . . 
	ld c,00ch		;a8db	0e 0c 	. . 
la8ddh:
	add a,c			;a8dd	81 	. 
	cp b			;a8de	b8 	. 
	jp c,la8e6h		;a8df	da e6 a8 	. . . 
	ld b,a			;a8e2	47 	G 
	jp la8edh		;a8e3	c3 ed a8 	. . . 
la8e6h:
	add a,00fh		;a8e6	c6 0f 	. . 
	cp b			;a8e8	b8 	. 
	jp nc,la8edh		;a8e9	d2 ed a8 	. . . 
	ld b,a			;a8ec	47 	G 
la8edh:
	ld (ix+001h),b		;a8ed	dd 70 01 	. p . 
	ld a,(0e2c4h)		;a8f0	3a c4 e2 	: . . 
	bit 7,(iy+002h)		;a8f3	fd cb 02 7e 	. . . ~ 
	jp z,la8fdh		;a8f7	ca fd a8 	. . . 
	ld a,(0e2c5h)		;a8fa	3a c5 e2 	: . . 
la8fdh:
	ld (ix+000h),a		;a8fd	dd 77 00 	. w . 
	ret			;a900	c9 	. 
la901h:
	ld hl,0e541h		;a901	21 41 e5 	! A . 
	ld (hl),000h		;a904	36 00 	6 . 
	ld de,0e542h		;a906	11 42 e5 	. B . 
	ld bc,00002h		;a909	01 02 00 	. . . 
	ldir		;a90c	ed b0 	. . 
	ld a,(BRICK_COL)		;a90e	3a ab e2 	: . . 
	sla a		;a911	cb 27 	. ' 
	sla a		;a913	cb 27 	. ' 
	sla a		;a915	cb 27 	. ' 
	sla a		;a917	cb 27 	. ' 
	ld b,010h		;a919	06 10 	. . 
	bit 7,(iy+003h)		;a91b	fd cb 03 7e 	. . . ~ 
	jp nz,la924h		;a91f	c2 24 a9 	. $ . 
	ld b,00ch		;a922	06 0c 	. . 
la924h:
	add a,b			;a924	80 	. 
	ld (0e2c7h),a		;a925	32 c7 e2 	2 . . 
	add a,00fh		;a928	c6 0f 	. . 
	ld (0e2c6h),a		;a92a	32 c6 e2 	2 . . 
	ld a,(iy+006h)		;a92d	fd 7e 06 	. ~ . 
	bit 7,a		;a930	cb 7f 	.  
	jp z,la937h		;a932	ca 37 a9 	. 7 . 
	neg		;a935	ed 44 	. D 
la937h:
	dec a			;a937	3d 	= 
	sla a		;a938	cb 27 	. ' 
la93ah:
	ld l,a			;a93a	6f 	o 
	ld h,000h		;a93b	26 00 	& . 
	ld de,la86ch		;a93d	11 6c a8 	. l . 
	add hl,de			;a940	19 	. 
	ld a,(hl)			;a941	7e 	~ 
	bit 7,(iy+002h)		;a942	fd cb 02 7e 	. . . ~ 
	jp nz,la94bh		;a946	c2 4b a9 	. K . 
	neg		;a949	ed 44 	. D 
la94bh:
	ld (0e542h),a		;a94b	32 42 e5 	2 B . 
	inc hl			;a94e	23 	# 
	ld a,(hl)			;a94f	7e 	~ 
	bit 7,(iy+002h)		;a950	fd cb 02 7e 	. . . ~ 
	jp nz,la959h		;a954	c2 59 a9 	. Y . 
	neg		;a957	ed 44 	. D 
la959h:
	ld (0e543h),a		;a959	32 43 e5 	2 C . 
	ld a,(0e542h)		;a95c	3a 42 e5 	: B . 
	ld b,a			;a95f	47 	G 
	ld a,(0e587h)		;a960	3a 87 e5 	: . . 
	ld hl,0e2c6h		;a963	21 c6 e2 	! . . 
	bit 7,(iy+003h)		;a966	fd cb 03 7e 	. . . ~ 
	jp nz,la982h		;a96a	c2 82 a9 	. . . 
	ld hl,0e2c7h		;a96d	21 c7 e2 	! . . 
	inc (hl)			;a970	34 	4 
la971h:
	push af			;a971	f5 	. 
	ld a,(0e541h)		;a972	3a 41 e5 	: A . 
	inc a			;a975	3c 	< 
	ld (0e541h),a		;a976	32 41 e5 	2 A . 
	pop af			;a979	f1 	. 
	add a,b			;a97a	80 	. 
	cp (hl)			;a97b	be 	. 
	jp nc,la993h		;a97c	d2 93 a9 	. . . 
	jp la971h		;a97f	c3 71 a9 	. q . 
la982h:
	push af			;a982	f5 	. 
	ld a,(0e541h)		;a983	3a 41 e5 	: A . 
	inc a			;a986	3c 	< 
	ld (0e541h),a		;a987	32 41 e5 	2 A . 
	pop af			;a98a	f1 	. 
	add a,b			;a98b	80 	. 
	cp (hl)			;a98c	be 	. 
	jp c,la994h		;a98d	da 94 a9 	. . . 
	jp la982h		;a990	c3 82 a9 	. . . 
la993h:
	dec (hl)			;a993	35 	5 
la994h:
	ld a,(0e541h)		;a994	3a 41 e5 	: A . 
	ld b,a			;a997	47 	G 
	ld a,(0e543h)		;a998	3a 43 e5 	: C . 
	ld c,a			;a99b	4f 	O 
	neg		;a99c	ed 44 	. D 
la99eh:
	add a,c			;a99e	81 	. 
	djnz la99eh		;a99f	10 fd 	. . 
	ld b,a			;a9a1	47 	G 
	ld a,(0e586h)		;a9a2	3a 86 e5 	: . . 
	add a,b			;a9a5	80 	. 
	ld b,a			;a9a6	47 	G 
	bit 7,(iy+002h)		;a9a7	fd cb 02 7e 	. . . ~ 
	jp nz,la9cch		;a9ab	c2 cc a9 	. . . 
	ld a,(BRICK_ROW)		;a9ae	3a aa e2 	: . . 
	sla a		;a9b1	cb 27 	. ' 
	sla a		;a9b3	cb 27 	. ' 
	sla a		;a9b5	cb 27 	. ' 
	add a,014h		;a9b7	c6 14 	. . 
	cp b			;a9b9	b8 	. 
	jp c,la9c1h		;a9ba	da c1 a9 	. . . 
	ld b,a			;a9bd	47 	G 
	jp la9f1h		;a9be	c3 f1 a9 	. . . 
la9c1h:
	add a,008h		;a9c1	c6 08 	. . 
	cp b			;a9c3	b8 	. 
	ld b,a			;a9c4	47 	G 
	jp nc,la9f1h		;a9c5	d2 f1 a9 	. . . 
	ld b,a			;a9c8	47 	G 
	jp la9f1h		;a9c9	c3 f1 a9 	. . . 
la9cch:
	ld a,(BRICK_ROW)		;a9cc	3a aa e2 	: . . 
	sla a		;a9cf	cb 27 	. ' 
	sla a		;a9d1	cb 27 	. ' 
	sla a		;a9d3	cb 27 	. ' 
	add a,01fh		;a9d5	c6 1f 	. . 
	cp b			;a9d7	b8 	. 
	jp nc,la9e0h		;a9d8	d2 e0 a9 	. . . 
	inc a			;a9db	3c 	< 
	ld b,a			;a9dc	47 	G 
	jp la9f1h		;a9dd	c3 f1 a9 	. . . 
la9e0h:
	sub 008h		;a9e0	d6 08 	. . 
	cp b			;a9e2	b8 	. 
	jp c,la9ebh		;a9e3	da eb a9 	. . . 
	inc a			;a9e6	3c 	< 
	ld b,a			;a9e7	47 	G 
	jp la9f1h		;a9e8	c3 f1 a9 	. . . 
la9ebh:
	inc a			;a9eb	3c 	< 
	jp la9f0h		;a9ec	c3 f0 a9 	. . . 
	dec a			;a9ef	3d 	= 
la9f0h:
	ld b,a			;a9f0	47 	G 
la9f1h:
	ld (ix+000h),b		;a9f1	dd 70 00 	. p . 
	ld a,(0e2c7h)		;a9f4	3a c7 e2 	: . . 
	bit 7,(iy+003h)		;a9f7	fd cb 03 7e 	. . . ~ 
	jp z,laa01h		;a9fb	ca 01 aa 	. . . 
	ld a,(0e2c6h)		;a9fe	3a c6 e2 	: . . 
laa01h:
	ld (ix+001h),a		;aa01	dd 77 01 	. w . 
	ret			;aa04	c9 	. 
sub_aa05h:
	call UPDATE_BALL_SPEED		;aa05	cd f0 9a 	. . . 
	ld a,(LEVEL)		;aa08	3a 1b e0 	: . . 
	sla a		;aa0b	cb 27 	. ' 
	ld e,a			;aa0d	5f 	_ 
	ld d,000h		;aa0e	16 00 	. . 
	ld hl,laa5ch		;aa10	21 5c aa 	! \ . 
	add hl,de			;aa13	19 	. 
	ld e,(hl)			;aa14	5e 	^ 
	inc hl			;aa15	23 	# 
	ld d,(hl)			;aa16	56 	V 
	ex de,hl			;aa17	eb 	. 
	ld (0e2bch),hl		;aa18	22 bc e2 	" . . 
	ld a,(BRICK_ROW)		;aa1b	3a aa e2 	: . . 
	cp 00ch		;aa1e	fe 0c 	. . 
	jp c,laa25h		;aa20	da 25 aa 	. % . 
	ld a,00bh		;aa23	3e 0b 	> . 
laa25h:
	ld l,a			;aa25	6f 	o 
	ld h,000h		;aa26	26 00 	& . 
laa28h:
	push hl			;aa28	e5 	. 
	pop bc			;aa29	c1 	. 
	add hl,hl			;aa2a	29 	) 
	push hl			;aa2b	e5 	. 
	pop de			;aa2c	d1 	. 
	add hl,hl			;aa2d	29 	) 
	add hl,hl			;aa2e	29 	) 
	add hl,bc			;aa2f	09 	. 
	add hl,de			;aa30	19 	. 
	ld a,(BRICK_COL)		;aa31	3a ab e2 	: . . 
	cp 00bh		;aa34	fe 0b 	. . 
	jp c,laa3bh		;aa36	da 3b aa 	. ; . 
	ld a,00ah		;aa39	3e 0a 	> . 
laa3bh:
	ld e,a			;aa3b	5f 	_ 
laa3ch:
	ld d,000h		;aa3c	16 00 	. . 
	add hl,de			;aa3e	19 	. 
	ld de,(0e2bch)		;aa3f	ed 5b bc e2 	. [ . . 
	add hl,de			;aa43	19 	. 
	ld e,(hl)			;aa44	5e 	^ 
	sla e		;aa45	cb 23 	. # 
	ld d,000h		;aa47	16 00 	. . 
	ld hl,laa52h		;aa49	21 52 aa 	! R . 
	add hl,de			;aa4c	19 	. 
	ld e,(hl)			;aa4d	5e 	^ 
	inc hl			;aa4e	23 	# 
	ld d,(hl)			;aa4f	56 	V 
	ex de,hl			;aa50	eb 	. 
	jp (hl)			;aa51	e9 	. 
laa52h:
	rst 28h			;aa52	ef 	. 
	xor d			;aa53	aa 	. 
	pop bc			;aa54	c1 	. 
	xor d			;aa55	aa 	. 
	rst 0			;aa56	c7 	. 
	xor d			;aa57	aa 	. 
	and h			;aa58	a4 	. 
	xor d			;aa59	aa 	. 
	sbc a,h			;aa5a	9c 	. 
	xor d			;aa5b	aa 	. 
laa5ch:
	nop			;aa5c	00 	. 
	ret nz			;aa5d	c0 	. 
	add a,h			;aa5e	84 	. 
	ret nz			;aa5f	c0 	. 
	ex af,af'			;aa60	08 	. 
	pop bc			;aa61	c1 	. 
	adc a,h			;aa62	8c 	. 
	pop bc			;aa63	c1 	. 
	djnz laa28h		;aa64	10 c2 	. . 
	sub h			;aa66	94 	. 
	jp nz,0c318h		;aa67	c2 18 c3 	. . . 
	sbc a,h			;aa6a	9c 	. 
	jp 0c420h		;aa6b	c3 20 c4 	.   . 
	and h			;aa6e	a4 	. 
	call nz,0c528h		;aa6f	c4 28 c5 	. ( . 
	xor h			;aa72	ac 	. 
	push bc			;aa73	c5 	. 
	jr nc,laa3ch		;aa74	30 c6 	0 . 
	or h			;aa76	b4 	. 
	add a,038h		;aa77	c6 38 	. 8 
	rst 0			;aa79	c7 	. 
	cp h			;aa7a	bc 	. 
	rst 0			;aa7b	c7 	. 
	ld b,b			;aa7c	40 	@ 
	ret z			;aa7d	c8 	. 
	call nz,048c8h		;aa7e	c4 c8 48 	. . H 
	ret			;aa81	c9 	. 
	call z,0x50c9		;aa82	cc c9 50 	. . P 
	jp z,0cad4h		;aa85	ca d4 ca 	. . . 
	ld e,b			;aa88	58 	X 
	set 3,h		;aa89	cb dc 	. . 
	bit 4,b		;aa8b	cb 60 	. ` 
	call z,0cce4h		;aa8d	cc e4 cc 	. . . 
	ld l,b			;aa90	68 	h 
	call 0cdech		;aa91	cd ec cd 	. . . 
	ld (hl),b			;aa94	70 	p 
	adc a,0f4h		;aa95	ce f4 	. . 
	adc a,078h		;aa97	ce 78 	. x 
	rst 8			;aa99	cf 	. 
	call m,lafcch+3		;aa9a	fc cf af 	. . . 
	ld (0e2bah),a		;aa9d	32 ba e2 	2 . . 
	ld (0e2bbh),a		;aaa0	32 bb e2 	2 . . 
	ret			;aaa3	c9 	. 
	xor a			;aaa4	af 	. 
	ld (0e2bbh),a		;aaa5	32 bb e2 	2 . . 
	ld a,001h		;aaa8	3e 01 	> . 
	ld (0e2bah),a		;aaaa	32 ba e2 	2 . . 
	ld hl,0e5ach		;aaad	21 ac e5 	! . . 
	inc (hl)			;aab0	34 	4 
	ld a,(hl)			;aab1	7e 	~ 
	cp 014h		;aab2	fe 14 	. . 
	jp nz,laabch		;aab4	c2 bc aa 	. . . 
	ld (hl),000h		;aab7	36 00 	6 . 
	call sub_ab38h		;aab9	cd 38 ab 	. 8 . 
laabch:
	ld c,001h		;aabc	0e 01 	. . 
	jp lab06h		;aabe	c3 06 ab 	. . . 
	call sub_b00fh		;aac1	cd 0f b0 	. . . 
	jp laaefh		;aac4	c3 ef aa 	. . . 
	xor a			;aac7	af 	. 
	ld (0e2bah),a		;aac8	32 ba e2 	2 . . 
	ld a,001h		;aacb	3e 01 	> . 
	ld (0e2bbh),a		;aacd	32 bb e2 	2 . . 
	ld a,(BRICK_ROW)		;aad0	3a aa e2 	: . . 
	ld l,a			;aad3	6f 	o 
	ld h,000h		;aad4	26 00 	& . 
	push hl			;aad6	e5 	. 
	pop bc			;aad7	c1 	. 
	add hl,hl			;aad8	29 	) 
	push hl			;aad9	e5 	. 
	pop de			;aada	d1 	. 
	add hl,hl			;aadb	29 	) 
	add hl,hl			;aadc	29 	) 
	add hl,bc			;aadd	09 	. 
	add hl,de			;aade	19 	. 
	ld a,(BRICK_COL)		;aadf	3a ab e2 	: . . 
	ld e,a			;aae2	5f 	_ 
	ld d,000h		;aae3	16 00 	. . 
	add hl,de			;aae5	19 	. 
	ld de,0e039h		;aae6	11 39 e0 	. 9 . 
	add hl,de			;aae9	19 	. 
	dec (hl)			;aaea	35 	5 
	ld c,000h		;aaeb	0e 00 	. . 
	jr nz,lab06h		;aaed	20 17 	  . 
laaefh:
	xor a			;aaef	af 	. 
	ld (0e2bah),a		;aaf0	32 ba e2 	2 . . 
	ld (0e2bbh),a		;aaf3	32 bb e2 	2 . . 
	push iy		;aaf6	fd e5 	. . 
	call sub_abd3h		;aaf8	cd d3 ab 	. . . 
	pop iy		;aafb	fd e1 	. . 
	call 0ab7ah		;aafd	cd 7a ab 	. z . 
	ld a,002h		;ab00	3e 02 	> . 
	call sub_5befh		;ab02	cd ef 5b 	. . [ 
	ret			;ab05	c9 	. 
lab06h:
	ld a,(BRICK_ROW)		;ab06	3a aa e2 	: . . 
	inc a			;ab09	3c 	< 
	ld hl,00000h		;ab0a	21 00 00 	! . . 
	ld de,00020h		;ab0d	11 20 00 	.   . 
lab10h:
	add hl,de			;ab10	19 	. 
	dec a			;ab11	3d 	= 
	jp nz,lab10h		;ab12	c2 10 ab 	. . . 
	ld de,01842h		;ab15	11 42 18 	. B . 
	add hl,de			;ab18	19 	. 
	ld a,(BRICK_COL)		;ab19	3a ab e2 	: . . 
	ld e,a			;ab1c	5f 	_ 
	sla e		;ab1d	cb 23 	. # 
	ld d,000h		;ab1f	16 00 	. . 
	add hl,de			;ab21	19 	. 
	ld a,(BRICK_ROW)		;ab22	3a aa e2 	: . . 
	ld (0e53ch),a		;ab25	32 3c e5 	2 < . 
	ld a,(BRICK_COL)		;ab28	3a ab e2 	: . . 
	ld (0e53dh),a		;ab2b	32 3d e5 	2 = . 
	call sub_97afh		;ab2e	cd af 97 	. . . 
	ld a,003h		;ab31	3e 03 	> . 
	call sub_5befh		;ab33	cd ef 5b 	. . [ 
	xor a			;ab36	af 	. 
	ret			;ab37	c9 	. 
sub_ab38h:
	push iy		;ab38	fd e5 	. . 
	ld iy,BALL_TABLE1		;ab3a	fd 21 4e e2 	. ! N . 
	ld b,003h		;ab3e	06 03 	. . 
lab40h:
    ; Skip if ball is inactive
	ld a,(iy+BALL_TABLE_IDX_ACTIVE)		;ab40	fd 7e 00
	cp 1		                        ;ab43	fe 01
	jp nz,lab60h		;ab45	c2 60 ab
    
	ld a,(iy+006h)		;ab48	fd 7e 06 	. ~ . 
	bit 7,a		;ab4b	cb 7f 	.  
	jp z,lab54h		;ab4d	ca 54 ab 	. T . 
	neg		;ab50	ed 44 	. D 
	add a,008h		;ab52	c6 08 	. . 
lab54h:
	dec a			;ab54	3d 	= 
	ld l,a			;ab55	6f 	o 
	ld h,000h		;ab56	26 00 	& . 
	ld de,lab6ah		;ab58	11 6a ab 	. j . 
	add hl,de			;ab5b	19 	. 
	ld a,(hl)			;ab5c	7e 	~ 
	ld (iy+006h),a		;ab5d	fd 77 06 	. w . 
lab60h:
	ld de,00014h		;ab60	11 14 00 	. . . 
	add iy,de		;ab63	fd 19 	. . 
	djnz lab40h		;ab65	10 d9 	. . 
	pop iy		;ab67	fd e1 	. . 
	ret			;ab69	c9 	. 
lab6ah:
	ld (bc),a			;ab6a	02 	. 
	inc bc			;ab6b	03 	. 
	inc b			;ab6c	04 	. 
	inc bc			;ab6d	03 	. 
	ld b,005h		;ab6e	06 05 	. . 
	ld b,007h		;ab70	06 07 	. . 
	cp 0fdh		;ab72	fe fd 	. . 
	call m,0fafdh		;ab74	fc fd fa 	. . . 
	ei			;ab77	fb 	. 
	jp m,0cdf9h		;ab78	fa f9 cd 	. . . 
	inc b			;ab7b	04 	. 
	sub (hl)			;ab7c	96 	. 

	ld a,(BRICKS_LEFT)		;ab7d	3a 38 e0
	dec a			        ;ab80	3d
	ld (BRICKS_LEFT),a		;ab81	32 38 e0
	jr nz,ERASE_BRICK		    ;ab84	20 09

	xor a			;ab86	af 	. 
	ld (BRICK_REPAINT_TYPE),a		;ab87	32 22 e0 	2 " . 
	ld a,002h		;ab8a	3e 02 	> . 
	ld (0e00ah),a		;ab8c	32 0a e0 	2 . . 
    
; Erase a brick and overwritte its chars with the
; proper background patterns.
ERASE_BRICK:
    ; A = BRICK_ROW + 1
	ld a,(BRICK_ROW)		;ab8f	3a aa e2
	inc a			        ;ab92	3c
	ld hl, 0    		    ;ab93	21 00 00
	ld de, 32   		    ;ab96	11 20 00
    ; Compute HL = 32 * (BRICK_ROW + 1)
lab99h:
	add hl,de			    ;ab99	19
	dec a			        ;ab9a	3d
	jr nz,lab99h		    ;ab9b	20 fc

    ; Locate HL to the beginning of the corresponding row
	; HL located at VRAM [2,2] + 32 * (BRICK_ROW + 1) ==> [2, 3 + BRICK_ROW]
    ld de,0x1800 + 2 + 2*32		;ab9d	11 42 18    VRAM [2, 2]
	add hl,de			        ;aba0	19

	; E = 2 * BRICK_COL
    ; This is because each brick is 2 chars long
    ld a,(BRICK_COL)		    ;aba1	3a ab e2
	ld e,a			            ;aba4	5f
	sla e		                ;aba5	cb 23
    
    ; Locate at address [2 + 2*BRICK_COL, 3 + BRICK_ROW]
	ld d, 0		                ;aba7	16 00
	add hl,de			        ;aba9	19
	call SETWRT		            ;abaa	cd 53 00

    ; Now compute compute on which position of the
    ; 2x2 background patter we are, to get then the two characters of
    ; the background which will replace the erased brick.
    
    ; HL = BRICK_ROW & 3
	ld a,(BRICK_ROW)		    ;abad	3a aa e2
	and 003h		            ;abb0	e6 03
	ld l,a			            ;abb2	6f
	ld h,000h		            ;abb3	26 00
    
    ; HL = 2 * (BRICK_ROW & 3)
	add hl,hl			        ;abb5	29

    ; HL = TABLE_BACKGROUND_ERASE + 2 * (BRICK_ROW & 3)
    ld de,TABLE_BACKGROUND_ERASE		;abb6	11 90 ad
	add hl,de			                ;abb9	19

    ; E = TABLE_BACKGROUND_ERASE[2 * (BRICK_ROW & 3)]
	ld e,(hl)			                ;abba	5e

	; D = TABLE_BACKGROUND_ERASE[2 * (BRICK_ROW & 3) + 1]
    inc hl			                    ;abbb	23
	ld d,(hl)			                ;abbc	56
    ; Ex:   DE = 0xada4

    ; A = BRICK_COL & 1
	ld a,(BRICK_COL)		            ;abbd	3a ab e2
	and 1           		            ;abc0	e6 01

    ; L = 2 * (BRICK_COL & 1)
	ld l,a			                    ;abc2	6f
	sla l		                        ;abc3	cb 25
    
	; HL += DE
    ; HL = HL + DE
    ; HL = 2 * (BRICK_COL & 1) + (word)TABLE_BACKGROUND_ERASE[2 * (BRICK_ROW & 3)]
    ld h, 0		            ;abc5	26 00
	add hl,de			    ;abc7	19
    
    ; C = VDP_WRITE port
	ld a,(VDP_WRITE)		;abc8	3a 07 00
	ld c,a			        ;abcb	4f

    ; Write 2 chars of background to the VRAM, to delete the
    ; brick with the background.
	ld b, 2 		        ;abcc	06 02
labceh:
	outi		            ;abce	ed a3
	jr nz,labceh		    ;abd0	20 fc
	ret			            ;abd2	c9

sub_abd3h:
	ld a,(BRICK_ROW)		;abd3	3a aa e2 	: . . 
	ld l,a			;abd6	6f 	o 
	ld h,000h		;abd7	26 00 	& . 
	add hl,hl			;abd9	29 	) 
	add hl,hl			;abda	29 	) 
	add hl,hl			;abdb	29 	) 
	add hl,hl			;abdc	29 	) 
	add hl,hl			;abdd	29 	) 
	ld de,lac10h		;abde	11 10 ac 	. . . 
	add hl,de			;abe1	19 	. 
	ld a,(BRICK_COL)		;abe2	3a ab e2 	: . . 
	sla a		;abe5	cb 27 	. ' 
	ld e,a			;abe7	5f 	_ 
	ld d,000h		;abe8	16 00 	. . 
	add hl,de			;abea	19 	. 
	ld e,(hl)			;abeb	5e 	^ 
	inc hl			;abec	23 	# 
	ld d,(hl)			;abed	56 	V 
	push de			;abee	d5 	. 
	pop iy		;abef	fd e1 	. . 
	ld a,(BRICK_ROW)		;abf1	3a aa e2 	: . . 
	ld l,a			;abf4	6f 	o 
	ld h,000h		;abf5	26 00 	& . 
	add hl,hl			;abf7	29 	) 
	add hl,hl			;abf8	29 	) 
	add hl,hl			;abf9	29 	) 
	add hl,hl			;abfa	29 	) 
	add hl,hl			;abfb	29 	) 
	ld de,lae01h		;abfc	11 01 ae 	. . . 
	add hl,de			;abff	19 	. 
	ld a,(BRICK_COL)		;ac00	3a ab e2 	: . . 
	sla a		;ac03	cb 27 	. ' 
	ld e,a			;ac05	5f 	_ 
lac06h:
	ld d,000h		;ac06	16 00 	. . 
	add hl,de			;ac08	19 	. 
	ld e,(hl)			;ac09	5e 	^ 
	inc hl			;ac0a	23 	# 
	ld d,(hl)			;ac0b	56 	V 
	ex de,hl			;ac0c	eb 	. 
	ld a,000h		;ac0d	3e 00 	> . 
	jp (hl)			;ac0f	e9 	. 
lac10h:
	daa			;ac10	27 	' 
	ret po			;ac11	e0 	. 
lac12h:
	daa			;ac12	27 	' 
	ret po			;ac13	e0 	. 
lac14h:
	daa			;ac14	27 	' 
	ret po			;ac15	e0 	. 
lac16h:
	daa			;ac16	27 	' 
	ret po			;ac17	e0 	. 
lac18h:
	daa			;ac18	27 	' 
	ret po			;ac19	e0 	. 
lac1ah:
	daa			;ac1a	27 	' 
	ret po			;ac1b	e0 	. 
	daa			;ac1c	27 	' 
	ret po			;ac1d	e0 	. 
	daa			;ac1e	27 	' 
	ret po			;ac1f	e0 	. 
	jr z,$-30		;ac20	28 e0 	( . 
	jr z,$-30		;ac22	28 e0 	( . 
	jr z,lac06h		;ac24	28 e0 	( . 
	nop			;ac26	00 	. 
	nop			;ac27	00 	. 
	nop			;ac28	00 	. 
	nop			;ac29	00 	. 
	nop			;ac2a	00 	. 
	nop			;ac2b	00 	. 
	nop			;ac2c	00 	. 
	nop			;ac2d	00 	. 
	nop			;ac2e	00 	. 
	nop			;ac2f	00 	. 
	jr z,lac12h		;ac30	28 e0 	( . 
	jr z,lac14h		;ac32	28 e0 	( . 
	jr z,lac16h		;ac34	28 e0 	( . 
	jr z,lac18h		;ac36	28 e0 	( . 
	jr z,lac1ah		;ac38	28 e0 	( . 
	add hl,hl			;ac3a	29 	) 
	ret po			;ac3b	e0 	. 
	add hl,hl			;ac3c	29 	) 
	ret po			;ac3d	e0 	. 
	add hl,hl			;ac3e	29 	) 
	ret po			;ac3f	e0 	. 
	add hl,hl			;ac40	29 	) 
	ret po			;ac41	e0 	. 
	add hl,hl			;ac42	29 	) 
	ret po			;ac43	e0 	. 
	add hl,hl			;ac44	29 	) 
	ret po			;ac45	e0 	. 
	nop			;ac46	00 	. 
	nop			;ac47	00 	. 
	nop			;ac48	00 	. 
	nop			;ac49	00 	. 
	nop			;ac4a	00 	. 
	nop			;ac4b	00 	. 
	nop			;ac4c	00 	. 
	nop			;ac4d	00 	. 
	nop			;ac4e	00 	. 
	nop			;ac4f	00 	. 
	add hl,hl			;ac50	29 	) 
	ret po			;ac51	e0 	. 
	add hl,hl			;ac52	29 	) 
	ret po			;ac53	e0 	. 
	ld hl,(02ae0h)		;ac54	2a e0 2a 	* . * 
	ret po			;ac57	e0 	. 
	ld hl,(02ae0h)		;ac58	2a e0 2a 	* . * 
	ret po			;ac5b	e0 	. 
	ld hl,(02ae0h)		;ac5c	2a e0 2a 	* . * 
	ret po			;ac5f	e0 	. 
	ld hl,(02ae0h)		;ac60	2a e0 2a 	* . * 
	ret po			;ac63	e0 	. 
	dec hl			;ac64	2b 	+ 
	ret po			;ac65	e0 	. 
	nop			;ac66	00 	. 
	nop			;ac67	00 	. 
	nop			;ac68	00 	. 
	nop			;ac69	00 	. 
	nop			;ac6a	00 	. 
	nop			;ac6b	00 	. 
	nop			;ac6c	00 	. 
	nop			;ac6d	00 	. 
	nop			;ac6e	00 	. 
	nop			;ac6f	00 	. 
	dec hl			;ac70	2b 	+ 
	ret po			;ac71	e0 	. 
	dec hl			;ac72	2b 	+ 
	ret po			;ac73	e0 	. 
	dec hl			;ac74	2b 	+ 
	ret po			;ac75	e0 	. 
	dec hl			;ac76	2b 	+ 
	ret po			;ac77	e0 	. 
	dec hl			;ac78	2b 	+ 
	ret po			;ac79	e0 	. 
	dec hl			;ac7a	2b 	+ 
	ret po			;ac7b	e0 	. 
	dec hl			;ac7c	2b 	+ 
	ret po			;ac7d	e0 	. 
	inc l			;ac7e	2c 	, 
	ret po			;ac7f	e0 	. 
	inc l			;ac80	2c 	, 
	ret po			;ac81	e0 	. 
	inc l			;ac82	2c 	, 
	ret po			;ac83	e0 	. 
	inc l			;ac84	2c 	, 
	ret po			;ac85	e0 	. 
	nop			;ac86	00 	. 
	nop			;ac87	00 	. 
	nop			;ac88	00 	. 
	nop			;ac89	00 	. 
	nop			;ac8a	00 	. 
	nop			;ac8b	00 	. 
	nop			;ac8c	00 	. 
	nop			;ac8d	00 	. 
	nop			;ac8e	00 	. 
	nop			;ac8f	00 	. 
	inc l			;ac90	2c 	, 
	ret po			;ac91	e0 	. 
	inc l			;ac92	2c 	, 
	ret po			;ac93	e0 	. 
	inc l			;ac94	2c 	, 
	ret po			;ac95	e0 	. 
	inc l			;ac96	2c 	, 
	ret po			;ac97	e0 	. 
	dec l			;ac98	2d 	- 
	ret po			;ac99	e0 	. 
	dec l			;ac9a	2d 	- 
	ret po			;ac9b	e0 	. 
	dec l			;ac9c	2d 	- 
	ret po			;ac9d	e0 	. 
	dec l			;ac9e	2d 	- 
	ret po			;ac9f	e0 	. 
	dec l			;aca0	2d 	- 
	ret po			;aca1	e0 	. 
	dec l			;aca2	2d 	- 
	ret po			;aca3	e0 	. 
	dec l			;aca4	2d 	- 
	ret po			;aca5	e0 	. 
	nop			;aca6	00 	. 
	nop			;aca7	00 	. 
	nop			;aca8	00 	. 
	nop			;aca9	00 	. 
	nop			;acaa	00 	. 
	nop			;acab	00 	. 
	nop			;acac	00 	. 
	nop			;acad	00 	. 
	nop			;acae	00 	. 
	nop			;acaf	00 	. 
	dec l			;acb0	2d 	- 
	ret po			;acb1	e0 	. 
	ld l,0e0h		;acb2	2e e0 	. . 
	ld l,0e0h		;acb4	2e e0 	. . 
	ld l,0e0h		;acb6	2e e0 	. . 
	ld l,0e0h		;acb8	2e e0 	. . 
	ld l,0e0h		;acba	2e e0 	. . 
	ld l,0e0h		;acbc	2e e0 	. . 
lacbeh:
	ld l,0e0h		;acbe	2e e0 	. . 
lacc0h:
	ld l,0e0h		;acc0	2e e0 	. . 
lacc2h:
	cpl			;acc2	2f 	/ 
	ret po			;acc3	e0 	. 
lacc4h:
	cpl			;acc4	2f 	/ 
	ret po			;acc5	e0 	. 
lacc6h:
	nop			;acc6	00 	. 
	nop			;acc7	00 	. 
	nop			;acc8	00 	. 
	nop			;acc9	00 	. 
	nop			;acca	00 	. 
	nop			;accb	00 	. 
	nop			;accc	00 	. 
	nop			;accd	00 	. 
	nop			;acce	00 	. 
	nop			;accf	00 	. 
	cpl			;acd0	2f 	/ 
	ret po			;acd1	e0 	. 
lacd2h:
	cpl			;acd2	2f 	/ 
	ret po			;acd3	e0 	. 
lacd4h:
	cpl			;acd4	2f 	/ 
	ret po			;acd5	e0 	. 
lacd6h:
	cpl			;acd6	2f 	/ 
	ret po			;acd7	e0 	. 
	cpl			;acd8	2f 	/ 
	ret po			;acd9	e0 	. 
	cpl			;acda	2f 	/ 
	ret po			;acdb	e0 	. 
	jr nc,lacbeh		;acdc	30 e0 	0 . 
	jr nc,lacc0h		;acde	30 e0 	0 . 
	jr nc,lacc2h		;ace0	30 e0 	0 . 
	jr nc,lacc4h		;ace2	30 e0 	0 . 
	jr nc,lacc6h		;ace4	30 e0 	0 . 
	nop			;ace6	00 	. 
	nop			;ace7	00 	. 
	nop			;ace8	00 	. 
	nop			;ace9	00 	. 
	nop			;acea	00 	. 
	nop			;aceb	00 	. 
	nop			;acec	00 	. 
	nop			;aced	00 	. 
	nop			;acee	00 	. 
	nop			;acef	00 	. 
	jr nc,lacd2h		;acf0	30 e0 	0 . 
	jr nc,lacd4h		;acf2	30 e0 	0 . 
	jr nc,lacd6h		;acf4	30 e0 	0 . 
	ld sp,031e0h		;acf6	31 e0 31 	1 . 1 
	ret po			;acf9	e0 	. 
	ld sp,031e0h		;acfa	31 e0 31 	1 . 1 
	ret po			;acfd	e0 	. 
	ld sp,031e0h		;acfe	31 e0 31 	1 . 1 
	ret po			;ad01	e0 	. 
	ld sp,031e0h		;ad02	31 e0 31 	1 . 1 
	ret po			;ad05	e0 	. 
	nop			;ad06	00 	. 
	nop			;ad07	00 	. 
	nop			;ad08	00 	. 
	nop			;ad09	00 	. 
	nop			;ad0a	00 	. 
	nop			;ad0b	00 	. 
	nop			;ad0c	00 	. 
	nop			;ad0d	00 	. 
	nop			;ad0e	00 	. 
	nop			;ad0f	00 	. 
	ld (032e0h),a		;ad10	32 e0 32 	2 . 2 
	ret po			;ad13	e0 	. 
	ld (032e0h),a		;ad14	32 e0 32 	2 . 2 
	ret po			;ad17	e0 	. 
	ld (032e0h),a		;ad18	32 e0 32 	2 . 2 
	ret po			;ad1b	e0 	. 
	ld (032e0h),a		;ad1c	32 e0 32 	2 . 2 
	ret po			;ad1f	e0 	. 
	inc sp			;ad20	33 	3 
	ret po			;ad21	e0 	. 
	inc sp			;ad22	33 	3 
	ret po			;ad23	e0 	. 
	inc sp			;ad24	33 	3 
	ret po			;ad25	e0 	. 
	nop			;ad26	00 	. 
	nop			;ad27	00 	. 
	nop			;ad28	00 	. 
	nop			;ad29	00 	. 
	nop			;ad2a	00 	. 
	nop			;ad2b	00 	. 
	nop			;ad2c	00 	. 
	nop			;ad2d	00 	. 
	nop			;ad2e	00 	. 
	nop			;ad2f	00 	. 
	inc sp			;ad30	33 	3 
	ret po			;ad31	e0 	. 
	inc sp			;ad32	33 	3 
	ret po			;ad33	e0 	. 
	inc sp			;ad34	33 	3 
	ret po			;ad35	e0 	. 
	inc sp			;ad36	33 	3 
	ret po			;ad37	e0 	. 
	inc sp			;ad38	33 	3 
	ret po			;ad39	e0 	. 
	inc (hl)			;ad3a	34 	4 
	ret po			;ad3b	e0 	. 
	inc (hl)			;ad3c	34 	4 
	ret po			;ad3d	e0 	. 
	inc (hl)			;ad3e	34 	4 
	ret po			;ad3f	e0 	. 
	inc (hl)			;ad40	34 	4 
	ret po			;ad41	e0 	. 
	inc (hl)			;ad42	34 	4 
	ret po			;ad43	e0 	. 
	inc (hl)			;ad44	34 	4 
	ret po			;ad45	e0 	. 
	nop			;ad46	00 	. 
	nop			;ad47	00 	. 
	nop			;ad48	00 	. 
	nop			;ad49	00 	. 
	nop			;ad4a	00 	. 
	nop			;ad4b	00 	. 
	nop			;ad4c	00 	. 
	nop			;ad4d	00 	. 
	nop			;ad4e	00 	. 
	nop			;ad4f	00 	. 
	inc (hl)			;ad50	34 	4 
	ret po			;ad51	e0 	. 
	inc (hl)			;ad52	34 	4 
	ret po			;ad53	e0 	. 
	dec (hl)			;ad54	35 	5 
	ret po			;ad55	e0 	. 
	dec (hl)			;ad56	35 	5 
	ret po			;ad57	e0 	. 
	dec (hl)			;ad58	35 	5 
	ret po			;ad59	e0 	. 
	dec (hl)			;ad5a	35 	5 
	ret po			;ad5b	e0 	. 
	dec (hl)			;ad5c	35 	5 
	ret po			;ad5d	e0 	. 
	dec (hl)			;ad5e	35 	5 
	ret po			;ad5f	e0 	. 
	dec (hl)			;ad60	35 	5 
	ret po			;ad61	e0 	. 
	dec (hl)			;ad62	35 	5 
	ret po			;ad63	e0 	. 
	ld (hl),0e0h		;ad64	36 e0 	6 . 
	nop			;ad66	00 	. 
	nop			;ad67	00 	. 
	nop			;ad68	00 	. 
	nop			;ad69	00 	. 
	nop			;ad6a	00 	. 
	nop			;ad6b	00 	. 
	nop			;ad6c	00 	. 
	nop			;ad6d	00 	. 
	nop			;ad6e	00 	. 
	nop			;ad6f	00 	. 
	ld (hl),0e0h		;ad70	36 e0 	6 . 
	ld (hl),0e0h		;ad72	36 e0 	6 . 
	ld (hl),0e0h		;ad74	36 e0 	6 . 
	ld (hl),0e0h		;ad76	36 e0 	6 . 
	ld (hl),0e0h		;ad78	36 e0 	6 . 
	ld (hl),0e0h		;ad7a	36 e0 	6 . 
	ld (hl),0e0h		;ad7c	36 e0 	6 . 
	scf			;ad7e	37 	7 
	ret po			;ad7f	e0 	. 
	scf			;ad80	37 	7 
	ret po			;ad81	e0 	. 
	scf			;ad82	37 	7 
	ret po			;ad83	e0 	. 
	scf			;ad84	37 	7 
	ret po			;ad85	e0 	. 
	nop			;ad86	00 	. 
	nop			;ad87	00 	. 
	nop			;ad88	00 	. 
	nop			;ad89	00 	. 
	nop			;ad8a	00 	. 
	nop			;ad8b	00 	. 
	nop			;ad8c	00 	. 
	nop			;ad8d	00 	. 
	nop			;ad8e	00 	. 
	nop			;ad8f	00 	. 

; The background pattern is 4x4-periodic.
; This table has pointers to the background characters to replace a
; brick with the background.
TABLE_BACKGROUND_ERASE:
    dw lad98h
    dw lad9ch
    dw lada0h
    dw lada4h

lad98h:
    db 0x7a, 0x7b, 0x78, 0x79
lad9ch:
    db 0x7e, 0x7f, 0x7c, 0x7d
lada0h:
    db 0x72, 0x73, 0x70, 0x71
lada4h:
    db 0x76, 0x77, 0x74, 0x75

sub_ada8h:
	push iy		;ada8	fd e5 	. . 
	ld a,000h		;adaa	3e 00 	> . 
	ld (0e2b9h),a		;adac	32 b9 e2 	2 . . 
	ld a,(BRICK_ROW)		;adaf	3a aa e2 	: . . 
	cp 00ch		;adb2	fe 0c 	. . 
	jp c,ladb9h		;adb4	da b9 ad 	. . . 
	ld a,00bh		;adb7	3e 0b 	> . 
ladb9h:
	ld l,a			;adb9	6f 	o 
	ld h,000h		;adba	26 00 	& . 
	add hl,hl			;adbc	29 	) 
	add hl,hl			;adbd	29 	) 
	add hl,hl			;adbe	29 	) 
	add hl,hl			;adbf	29 	) 
	add hl,hl			;adc0	29 	) 
	ld de,lac10h		;adc1	11 10 ac 	. . . 
	add hl,de			;adc4	19 	. 
	ld a,(BRICK_COL)		;adc5	3a ab e2 	: . . 
	sla a		;adc8	cb 27 	. ' 
	ld e,a			;adca	5f 	_ 
	ld d,000h		;adcb	16 00 	. . 
	add hl,de			;adcd	19 	. 
	ld e,(hl)			;adce	5e 	^ 
	inc hl			;adcf	23 	# 
	ld d,(hl)			;add0	56 	V 
	push de			;add1	d5 	. 
	pop iy		;add2	fd e1 	. . 
	ld a,(BRICK_ROW)		;add4	3a aa e2 	: . . 
	cp 00ch		;add7	fe 0c 	. . 
	jp c,laddeh		;add9	da de ad 	. . . 
	ld a,00bh		;addc	3e 0b 	> . 
laddeh:
	ld l,a			;adde	6f 	o 
	ld h,000h		;addf	26 00 	& . 
	add hl,hl			;ade1	29 	) 
	add hl,hl			;ade2	29 	) 
	add hl,hl			;ade3	29 	) 
	add hl,hl			;ade4	29 	) 
	add hl,hl			;ade5	29 	) 
	ld de,lae01h		;ade6	11 01 ae 	. . . 
	add hl,de			;ade9	19 	. 
	ld a,(BRICK_COL)		;adea	3a ab e2 	: . . 
	cp 00bh		;aded	fe 0b 	. . 
	jp c,ladf4h		;adef	da f4 ad 	. . . 
	ld a,00ah		;adf2	3e 0a 	> . 
ladf4h:
	sla a		;adf4	cb 27 	. ' 
	ld e,a			;adf6	5f 	_ 
	ld d,000h		;adf7	16 00 	. . 
	add hl,de			;adf9	19 	. 
	ld e,(hl)			;adfa	5e 	^ 
	inc hl			;adfb	23 	# 
	ld d,(hl)			;adfc	56 	V 
	ex de,hl			;adfd	eb 	. 
	ld a,001h		;adfe	3e 01 	> . 
	jp (hl)			;ae00	e9 	. 
lae01h:
	add a,c			;ae01	81 	. 
	xor a			;ae02	af 	. 
	sub d			;ae03	92 	. 
	xor a			;ae04	af 	. 
	and d			;ae05	a2 	. 
	xor a			;ae06	af 	. 
	or d			;ae07	b2 	. 
	xor a			;ae08	af 	. 
	jp nz,0d2afh		;ae09	c2 af d2 	. . . 
	xor a			;ae0c	af 	. 
	jp po,0f2afh		;ae0d	e2 af f2 	. . . 
	xor a			;ae10	af 	. 
	add a,c			;ae11	81 	. 
	xor a			;ae12	af 	. 
	sub d			;ae13	92 	. 
	xor a			;ae14	af 	. 
	and d			;ae15	a2 	. 
	xor a			;ae16	af 	. 
	add a,c			;ae17	81 	. 
	xor a			;ae18	af 	. 
	add a,c			;ae19	81 	. 
	xor a			;ae1a	af 	. 
	add a,c			;ae1b	81 	. 
	xor a			;ae1c	af 	. 
	add a,c			;ae1d	81 	. 
	xor a			;ae1e	af 	. 
	add a,c			;ae1f	81 	. 
	xor a			;ae20	af 	. 
	or d			;ae21	b2 	. 
	xor a			;ae22	af 	. 
	jp nz,0d2afh		;ae23	c2 af d2 	. . . 
	xor a			;ae26	af 	. 
	jp po,0f2afh		;ae27	e2 af f2 	. . . 
	xor a			;ae2a	af 	. 
	add a,c			;ae2b	81 	. 
	xor a			;ae2c	af 	. 
	sub d			;ae2d	92 	. 
	xor a			;ae2e	af 	. 
	and d			;ae2f	a2 	. 
	xor a			;ae30	af 	. 
	or d			;ae31	b2 	. 
	xor a			;ae32	af 	. 
	jp nz,0d2afh		;ae33	c2 af d2 	. . . 
	xor a			;ae36	af 	. 
	add a,c			;ae37	81 	. 
	xor a			;ae38	af 	. 
	add a,c			;ae39	81 	. 
	xor a			;ae3a	af 	. 
	add a,c			;ae3b	81 	. 
	xor a			;ae3c	af 	. 
	add a,c			;ae3d	81 	. 
	xor a			;ae3e	af 	. 
	add a,c			;ae3f	81 	. 
	xor a			;ae40	af 	. 
	jp po,0f2afh		;ae41	e2 af f2 	. . . 
	xor a			;ae44	af 	. 
	add a,c			;ae45	81 	. 
	xor a			;ae46	af 	. 
	sub d			;ae47	92 	. 
	xor a			;ae48	af 	. 
	and d			;ae49	a2 	. 
	xor a			;ae4a	af 	. 
	or d			;ae4b	b2 	. 
	xor a			;ae4c	af 	. 
	jp nz,0d2afh		;ae4d	c2 af d2 	. . . 
	xor a			;ae50	af 	. 
	jp po,0f2afh		;ae51	e2 af f2 	. . . 
	xor a			;ae54	af 	. 
	add a,c			;ae55	81 	. 
	xor a			;ae56	af 	. 
	add a,c			;ae57	81 	. 
	xor a			;ae58	af 	. 
	add a,c			;ae59	81 	. 
	xor a			;ae5a	af 	. 
	add a,c			;ae5b	81 	. 
	xor a			;ae5c	af 	. 
	add a,c			;ae5d	81 	. 
	xor a			;ae5e	af 	. 
	add a,c			;ae5f	81 	. 
	xor a			;ae60	af 	. 
	sub d			;ae61	92 	. 
	xor a			;ae62	af 	. 
	and d			;ae63	a2 	. 
	xor a			;ae64	af 	. 
	or d			;ae65	b2 	. 
	xor a			;ae66	af 	. 
	jp nz,0d2afh		;ae67	c2 af d2 	. . . 
	xor a			;ae6a	af 	. 
	jp po,0f2afh		;ae6b	e2 af f2 	. . . 
	xor a			;ae6e	af 	. 
	add a,c			;ae6f	81 	. 
	xor a			;ae70	af 	. 
	sub d			;ae71	92 	. 
	xor a			;ae72	af 	. 
	and d			;ae73	a2 	. 
	xor a			;ae74	af 	. 
	or d			;ae75	b2 	. 
	xor a			;ae76	af 	. 
	add a,c			;ae77	81 	. 
	xor a			;ae78	af 	. 
	add a,c			;ae79	81 	. 
	xor a			;ae7a	af 	. 
	add a,c			;ae7b	81 	. 
	xor a			;ae7c	af 	. 
	add a,c			;ae7d	81 	. 
	xor a			;ae7e	af 	. 
	add a,c			;ae7f	81 	. 
	xor a			;ae80	af 	. 
	jp nz,0d2afh		;ae81	c2 af d2 	. . . 
	xor a			;ae84	af 	. 
	jp po,0f2afh		;ae85	e2 af f2 	. . . 
	xor a			;ae88	af 	. 
	add a,c			;ae89	81 	. 
	xor a			;ae8a	af 	. 
	sub d			;ae8b	92 	. 
	xor a			;ae8c	af 	. 
	and d			;ae8d	a2 	. 
	xor a			;ae8e	af 	. 
	or d			;ae8f	b2 	. 
	xor a			;ae90	af 	. 
	jp nz,0d2afh		;ae91	c2 af d2 	. . . 
	xor a			;ae94	af 	. 
	jp po,l81afh		;ae95	e2 af 81 	. . . 
	xor a			;ae98	af 	. 
	add a,c			;ae99	81 	. 
	xor a			;ae9a	af 	. 
	add a,c			;ae9b	81 	. 
	xor a			;ae9c	af 	. 
	add a,c			;ae9d	81 	. 
	xor a			;ae9e	af 	. 
	add a,c			;ae9f	81 	. 
	xor a			;aea0	af 	. 
	jp p,l81afh		;aea1	f2 af 81 	. . . 
	xor a			;aea4	af 	. 
	sub d			;aea5	92 	. 
	xor a			;aea6	af 	. 
	and d			;aea7	a2 	. 
	xor a			;aea8	af 	. 
	or d			;aea9	b2 	. 
	xor a			;aeaa	af 	. 
	jp nz,0d2afh		;aeab	c2 af d2 	. . . 
	xor a			;aeae	af 	. 
	jp po,0f2afh		;aeaf	e2 af f2 	. . . 
	xor a			;aeb2	af 	. 
	add a,c			;aeb3	81 	. 
	xor a			;aeb4	af 	. 
	sub d			;aeb5	92 	. 
	xor a			;aeb6	af 	. 
	add a,c			;aeb7	81 	. 
	xor a			;aeb8	af 	. 
	add a,c			;aeb9	81 	. 
	xor a			;aeba	af 	. 
	add a,c			;aebb	81 	. 
	xor a			;aebc	af 	. 
	add a,c			;aebd	81 	. 
	xor a			;aebe	af 	. 
	add a,c			;aebf	81 	. 
	xor a			;aec0	af 	. 
	and d			;aec1	a2 	. 
	xor a			;aec2	af 	. 
	or d			;aec3	b2 	. 
	xor a			;aec4	af 	. 
	jp nz,0d2afh		;aec5	c2 af d2 	. . . 
	xor a			;aec8	af 	. 
	jp po,0f2afh		;aec9	e2 af f2 	. . . 
	xor a			;aecc	af 	. 
	add a,c			;aecd	81 	. 
	xor a			;aece	af 	. 
	sub d			;aecf	92 	. 
	xor a			;aed0	af 	. 
	and d			;aed1	a2 	. 
	xor a			;aed2	af 	. 
	or d			;aed3	b2 	. 
	xor a			;aed4	af 	. 
	jp nz,l81afh		;aed5	c2 af 81 	. . . 
	xor a			;aed8	af 	. 
	add a,c			;aed9	81 	. 
	xor a			;aeda	af 	. 
	add a,c			;aedb	81 	. 
laedch:
	xor a			;aedc	af 	. 
	add a,c			;aedd	81 	. 
	xor a			;aede	af 	. 
	add a,c			;aedf	81 	. 
	xor a			;aee0	af 	. 
	jp nc,0e2afh		;aee1	d2 af e2 	. . . 
	xor a			;aee4	af 	. 
	jp p,l81afh		;aee5	f2 af 81 	. . . 
	xor a			;aee8	af 	. 
	sub d			;aee9	92 	. 
	xor a			;aeea	af 	. 
	and d			;aeeb	a2 	. 
	xor a			;aeec	af 	. 
	or d			;aeed	b2 	. 
	xor a			;aeee	af 	. 
	jp nz,0d2afh		;aeef	c2 af d2 	. . . 
	xor a			;aef2	af 	. 
	jp po,0f2afh		;aef3	e2 af f2 	. . . 
	xor a			;aef6	af 	. 
	add a,c			;aef7	81 	. 
	xor a			;aef8	af 	. 
	add a,c			;aef9	81 	. 
	xor a			;aefa	af 	. 
	add a,c			;aefb	81 	. 
	xor a			;aefc	af 	. 
	add a,c			;aefd	81 	. 
	xor a			;aefe	af 	. 
	add a,c			;aeff	81 	. 
	xor a			;af00	af 	. 
	add a,c			;af01	81 	. 
	xor a			;af02	af 	. 
	sub d			;af03	92 	. 
	xor a			;af04	af 	. 
	and d			;af05	a2 	. 
	xor a			;af06	af 	. 
	or d			;af07	b2 	. 
	xor a			;af08	af 	. 
	jp nz,0d2afh		;af09	c2 af d2 	. . . 
	xor a			;af0c	af 	. 
	jp po,0f2afh		;af0d	e2 af f2 	. . . 
	xor a			;af10	af 	. 
	add a,c			;af11	81 	. 
	xor a			;af12	af 	. 
	sub d			;af13	92 	. 
	xor a			;af14	af 	. 
	and d			;af15	a2 	. 
	xor a			;af16	af 	. 
	add a,c			;af17	81 	. 
	xor a			;af18	af 	. 
	add a,c			;af19	81 	. 
	xor a			;af1a	af 	. 
	add a,c			;af1b	81 	. 
	xor a			;af1c	af 	. 
	add a,c			;af1d	81 	. 
	xor a			;af1e	af 	. 
	add a,c			;af1f	81 	. 
	xor a			;af20	af 	. 
	or d			;af21	b2 	. 
	xor a			;af22	af 	. 
	jp nz,0d2afh		;af23	c2 af d2 	. . . 
	xor a			;af26	af 	. 
	jp po,0f2afh		;af27	e2 af f2 	. . . 
	xor a			;af2a	af 	. 
	add a,c			;af2b	81 	. 
	xor a			;af2c	af 	. 
	sub d			;af2d	92 	. 
	xor a			;af2e	af 	. 
	and d			;af2f	a2 	. 
	xor a			;af30	af 	. 
	or d			;af31	b2 	. 
	xor a			;af32	af 	. 
	jp nz,0d2afh		;af33	c2 af d2 	. . . 
	xor a			;af36	af 	. 
	add a,c			;af37	81 	. 
	xor a			;af38	af 	. 
	add a,c			;af39	81 	. 
	xor a			;af3a	af 	. 
	add a,c			;af3b	81 	. 
	xor a			;af3c	af 	. 
	add a,c			;af3d	81 	. 
	xor a			;af3e	af 	. 
	add a,c			;af3f	81 	. 
	xor a			;af40	af 	. 
	jp po,0f2afh		;af41	e2 af f2 	. . . 
	xor a			;af44	af 	. 
	add a,c			;af45	81 	. 
	xor a			;af46	af 	. 
	sub d			;af47	92 	. 
	xor a			;af48	af 	. 
	and d			;af49	a2 	. 
	xor a			;af4a	af 	. 
	or d			;af4b	b2 	. 
	xor a			;af4c	af 	. 
	jp nz,0d2afh		;af4d	c2 af d2 	. . . 
	xor a			;af50	af 	. 
	jp po,0f2afh		;af51	e2 af f2 	. . . 
	xor a			;af54	af 	. 
	add a,c			;af55	81 	. 
	xor a			;af56	af 	. 
	add a,c			;af57	81 	. 
	xor a			;af58	af 	. 
	add a,c			;af59	81 	. 
	xor a			;af5a	af 	. 
	add a,c			;af5b	81 	. 
	xor a			;af5c	af 	. 
	add a,c			;af5d	81 	. 
	xor a			;af5e	af 	. 
	add a,c			;af5f	81 	. 
	xor a			;af60	af 	. 
	sub d			;af61	92 	. 
	xor a			;af62	af 	. 
	and d			;af63	a2 	. 
	xor a			;af64	af 	. 
	or d			;af65	b2 	. 
	xor a			;af66	af 	. 
	jp nz,0d2afh		;af67	c2 af d2 	. . . 
	xor a			;af6a	af 	. 
	jp po,0f2afh		;af6b	e2 af f2 	. . . 
	xor a			;af6e	af 	. 
	add a,c			;af6f	81 	. 
	xor a			;af70	af 	. 
	sub d			;af71	92 	. 
	xor a			;af72	af 	. 
	and d			;af73	a2 	. 
	xor a			;af74	af 	. 
	or d			;af75	b2 	. 
	xor a			;af76	af 	. 
	add a,c			;af77	81 	. 
	xor a			;af78	af 	. 
	add a,c			;af79	81 	. 
	xor a			;af7a	af 	. 
	add a,c			;af7b	81 	. 
	xor a			;af7c	af 	. 
	add a,c			;af7d	81 	. 
	xor a			;af7e	af 	. 
	add a,c			;af7f	81 	. 
	xor a			;af80	af 	. 
	cp 001h		;af81	fe 01 	. . 
	jp z,laf8bh		;af83	ca 8b af 	. . . 
	res 7,(iy+000h)		;af86	fd cb 00 be 	. . . . 
	ret			;af8a	c9 	. 
laf8bh:
	bit 7,(iy+000h)		;af8b	fd cb 00 7e 	. . . ~ 
	jp lb000h		;af8f	c3 00 b0 	. . . 
	cp 001h		;af92	fe 01 	. . 
	jp z,laf9ch		;af94	ca 9c af 	. . . 
	res 6,(iy+000h)		;af97	fd cb 00 b6 	. . . . 
	ret			;af9b	c9 	. 
laf9ch:
	bit 6,(iy+000h)		;af9c	fd cb 00 76 	. . . v 
	jr lb000h		;afa0	18 5e 	. ^ 
	cp 001h		;afa2	fe 01 	. . 
	jp z,lafach		;afa4	ca ac af 	. . . 
	res 5,(iy+000h)		;afa7	fd cb 00 ae 	. . . . 
	ret			;afab	c9 	. 
lafach:
	bit 5,(iy+000h)		;afac	fd cb 00 6e 	. . . n 
	jr lb000h		;afb0	18 4e 	. N 
	cp 001h		;afb2	fe 01 	. . 
	jp z,lafbch		;afb4	ca bc af 	. . . 
	res 4,(iy+000h)		;afb7	fd cb 00 a6 	. . . . 
	ret			;afbb	c9 	. 
lafbch:
	bit 4,(iy+000h)		;afbc	fd cb 00 66 	. . . f 
	jr lb000h		;afc0	18 3e 	. > 
	cp 001h		;afc2	fe 01 	. . 
	jp z,lafcch		;afc4	ca cc af 	. . . 
	res 3,(iy+000h)		;afc7	fd cb 00 9e 	. . . . 
	ret			;afcb	c9 	. 
lafcch:
	bit 3,(iy+000h)		;afcc	fd cb 00 5e 	. . . ^ 
	jr lb000h		;afd0	18 2e 	. . 
	cp 001h		;afd2	fe 01 	. . 
	jp z,lafdch		;afd4	ca dc af 	. . . 
	res 2,(iy+000h)		;afd7	fd cb 00 96 	. . . . 
	ret			;afdb	c9 	. 
lafdch:
	bit 2,(iy+000h)		;afdc	fd cb 00 56 	. . . V 
	jr lb000h		;afe0	18 1e 	. . 
	cp 001h		;afe2	fe 01 	. . 
	jp z,lafech		;afe4	ca ec af 	. . . 
	res 1,(iy+000h)		;afe7	fd cb 00 8e 	. . . . 
	ret			;afeb	c9 	. 
lafech:
	bit 1,(iy+000h)		;afec	fd cb 00 4e 	. . . N 
	jr lb000h		;aff0	18 0e 	. . 
	cp 001h		;aff2	fe 01 	. . 
	jp z,laffch		;aff4	ca fc af 	. . . 
	res 0,(iy+000h)		;aff7	fd cb 00 86 	. . . . 
	ret			;affb	c9 	. 
laffch:
	bit 0,(iy+000h)		;affc	fd cb 00 46 	. . . F 
lb000h:
	pop iy		;b000	fd e1 	. . 
	ld hl,0e2b9h		;b002	21 b9 e2 	! . . 
	ld (hl),000h		;b005	36 00 	6 . 
	jr z,lb00dh		;b007	28 04 	( . 
	ld (hl),001h		;b009	36 01 	6 . 
	scf			;b00b	37 	7 
	ret			;b00c	c9 	. 
lb00dh:
	xor a			;b00d	af 	. 
	ret			;b00e	c9 	. 
sub_b00fh:
	push ix		;b00f	dd e5 	. . 
	push iy		;b011	fd e5 	. . 
	push hl			;b013	e5 	. 
	push de			;b014	d5 	. 
	push bc			;b015	c5 	. 
	ld a,(EXTRA_BALLS)		;b016	3a 25 e3 	: % . 
	or a			;b019	b7 	. 
	jp nz,lb020h		;b01a	c2 20 b0 	.   . 
	call sub_b028h		;b01d	cd 28 b0 	. ( . 
lb020h:
	pop bc			;b020	c1 	. 
	pop de			;b021	d1 	. 
	pop hl			;b022	e1 	. 
	pop iy		;b023	fd e1 	. . 
	pop ix		;b025	dd e1 	. . 
	ret			;b027	c9 	. 
sub_b028h:
    ; Capsules won't fall if there are less than 4 bricks remaining
	ld a,(BRICKS_LEFT)		;b028	3a 38 e0
	cp 4		            ;b02b	fe 04
	ret c			        ;b02d	d8
	ld ix,0e317h		;b02e	dd 21 17 e3 	. ! . . 
	ld iy,0e0c9h		;b032	fd 21 c9 e0 	. ! . . 
	ld a,(0e317h)		;b036	3a 17 e3 	: . . 
	or a			;b039	b7 	. 
	ret nz			;b03a	c0 	. 
	ld (ix+000h),001h		;b03b	dd 36 00 01 	. 6 . . 
	call sub_b0ddh		;b03f	cd dd b0 	. . . 
	jp c,lb073h		;b042	da 73 b0 	. s . 
	call sub_b10ah		;b045	cd 0a b1 	. . . 
	jp c,lb073h		;b048	da 73 b0 	. s . 
	ld a,(0e324h)		;b04b	3a 24 e3 	: $ . 
	cp 001h		;b04e	fe 01 	. . 
	jr z,lb063h		;b050	28 11 	( . 
	ld a,(0e321h)		;b052	3a 21 e3 	: ! . 
	or a			;b055	b7 	. 
	jr nz,lb068h		;b056	20 10 	  . 
	ld a,(0e322h)		;b058	3a 22 e3 	: " . 
	or a			;b05b	b7 	. 
	jr nz,lb06dh		;b05c	20 0f 	  . 
	ld hl,lb0bdh		;b05e	21 bd b0 	! . . 
	jr lb070h		;b061	18 0d 	. . 
lb063h:
	ld hl,lb0c5h		;b063	21 c5 b0 	! . . 
	jr lb070h		;b066	18 08 	. . 
lb068h:
	ld hl,lb0cdh		;b068	21 cd b0 	! . . 
	jr lb070h		;b06b	18 03 	. . 
lb06dh:
	ld hl,lb0d5h		;b06d	21 d5 b0 	! . . 
lb070h:
	call sub_b0adh		;b070	cd ad b0 	. . . 
lb073h:
	ld a,(BRICK_ROW)		;b073	3a aa e2 	: . . 
	sla a		;b076	cb 27 	. ' 
	sla a		;b078	cb 27 	. ' 
	sla a		;b07a	cb 27 	. ' 
	add a,018h		;b07c	c6 18 	. . 
	ld l,a			;b07e	6f 	o 
	ld a,(BRICK_COL)		;b07f	3a ab e2 	: . . 
	sla a		;b082	cb 27 	. ' 
	sla a		;b084	cb 27 	. ' 
	sla a		;b086	cb 27 	. ' 
	sla a		;b088	cb 27 	. ' 
	add a,010h		;b08a	c6 10 	. . 
	ld h,a			;b08c	67 	g 
	ld (iy+000h),l		;b08d	fd 75 00 	. u . 
	ld (iy+001h),h		;b090	fd 74 01 	. t . 
	ld (iy+002h),088h		;b093	fd 36 02 88 	. 6 . . 
	ld l,(ix+001h)		;b097	dd 6e 01 	. n . 
	ld h,000h		;b09a	26 00 	& . 
	ld de,lb0a5h		;b09c	11 a5 b0 	. . . 
	add hl,de			;b09f	19 	. 
	ld a,(hl)			;b0a0	7e 	~ 
	ld (iy+003h),a		;b0a1	fd 77 03 	. w . 
	ret			;b0a4	c9 	. 
lb0a5h:
	ld a,(bc)			;b0a5	0a 	. 
	inc bc			;b0a6	03 	. 
	dec b			;b0a7	05 	. 
	rlca			;b0a8	07 	. 
	ex af,af'			;b0a9	08 	. 
	dec c			;b0aa	0d 	. 
	ld c,005h		;b0ab	0e 05 	. . 
sub_b0adh:
	ld a,r		;b0ad	ed 5f 	. _ 
	add a,c			;b0af	81 	. 
	add a,b			;b0b0	80 	. 
	add a,e			;b0b1	83 	. 
	and 007h		;b0b2	e6 07 	. . 
	ld e,a			;b0b4	5f 	_ 
	ld d,000h		;b0b5	16 00 	. . 
	add hl,de			;b0b7	19 	. 
	ld a,(hl)			;b0b8	7e 	~ 
	ld (ix+001h),a		;b0b9	dd 77 01 	. w . 
	ret			;b0bc	c9 	. 
lb0bdh:
	nop			;b0bd	00 	. 
	ld bc,00302h		;b0be	01 02 03 	. . . 
	inc b			;b0c1	04 	. 
	ld bc,00203h		;b0c2	01 03 02 	. . . 
lb0c5h:
	nop			;b0c5	00 	. 
	ld (bc),a			;b0c6	02 	. 
	inc bc			;b0c7	03 	. 
	inc b			;b0c8	04 	. 
	ld (bc),a			;b0c9	02 	. 
	inc b			;b0ca	04 	. 
	nop			;b0cb	00 	. 
	inc bc			;b0cc	03 	. 
lb0cdh:
	nop			;b0cd	00 	. 
	ld bc,00403h		;b0ce	01 03 04 	. . . 
	ld bc,00304h		;b0d1	01 04 03 	. . . 
	nop			;b0d4	00 	. 
lb0d5h:
	nop			;b0d5	00 	. 
	ld bc,00302h		;b0d6	01 02 03 	. . . 
	ld bc,00003h		;b0d9	01 03 00 	. . . 
	ld (bc),a			;b0dc	02 	. 

sub_b0ddh:
    ; Get out of the portal is open
	ld a,(PORTAL_OPEN)		;b0dd	3a 26 e3
	or a			        ;b0e0	b7
	ret nz			        ;b0e1	c0

    ; A = CAPSULES_LEFT
	ld hl,CAPSULES_LEFT		;b0e2	21 23 e0
	ld a,(hl)			    ;b0e5	7e

    ; Skip the following if CAPSULES_LEFT was set for this level
    ; Otherwise, choose a random number
	or a			        ;b0e6	b7
	jr nz,lb0f7h		    ;b0e7	20 0e

    ; A = random number in [0, 31]
	ld a,r		    ;b0e9	ed 5f
	add a,c			;b0eb	81
	add a,b			;b0ec	80
	and 01fh		;b0ed	e6 1f

	ld (CAPSULES_RANDOM_NUM),a	;b0ef	32 24 e0

    ; Default value of 33 capsules available
	ld a, 33		            ;b0f2	3e 21
	ld (CAPSULES_LEFT),a		;b0f4	32 23 e0
lb0f7h:
    ; Decrease CAPSULES_LEFT
	dec (hl)			;b0f7	35 	5 
    
    ; Jump if the random number happens to be zero
	ld hl,CAPSULES_RANDOM_NUM		;b0f8	21 24 e0
	ld a,(hl)			            ;b0fb	7e
	or a			                ;b0fc	b7
	jr z,lb102h		                ;b0fd	28 03
	
    ; Decrease CAPSULES_LEFT and
    ; return 0
    dec (hl)			            ;b0ff	35
	xor a			                ;b100	af
	ret			                    ;b101	c9

lb102h:
	ld (ix+001h),005h		;b102	dd 36 01 05 	. 6 . . 
	ld (hl),0ffh		    ;b106	36 ff 	6 . 
	scf			            ;b108	37 	7 
	ret			            ;b109	c9 	. 
    

sub_b10ah:
	ld a,(0e327h)		;b10a	3a 27 e3 	: ' . 
	or a			;b10d	b7 	. 
	ret nz			;b10e	c0 	. 
	ld hl,0e025h		;b10f	21 25 e0 	! % . 
	ld a,(hl)			;b112	7e 	~ 
	or a			;b113	b7 	. 
	jr nz,lb124h		;b114	20 0e 	  . 
	ld a,r		;b116	ed 5f 	. _ 
	add a,e			;b118	83 	. 
	add a,d			;b119	82 	. 
	and 01fh		;b11a	e6 1f 	. . 
	ld (0e026h),a		;b11c	32 26 e0 	2 & . 
	ld a,032h		;b11f	3e 32 	> 2 
	ld (0e025h),a		;b121	32 25 e0 	2 % . 
lb124h:
	dec (hl)			;b124	35 	5 
	ld hl,0e026h		;b125	21 26 e0 	! & . 
	ld a,(hl)			;b128	7e 	~ 
	or a			;b129	b7 	. 
	jr z,lb12fh		;b12a	28 03 	( . 
	dec (hl)			;b12c	35 	5 
	xor a			;b12d	af 	. 
	ret			;b12e	c9 	. 
lb12fh:
	ld (ix+001h),006h		;b12f	dd 36 01 06 	. 6 . . 
	ld (hl),0ffh		;b133	36 ff 	6 . 
	scf			;b135	37 	7 
	ret			;b136	c9 	. 
sub_b137h:
	ld a,(LEVEL)		;b137	3a 1b e0
	cp FINAL_LEVEL		;b13a	fe 20
	ret z			;b13c	c8 	. 
	ld ix,0e317h		;b13d	dd 21 17 e3 	. ! . . 
	ld iy,0e0c9h		;b141	fd 21 c9 e0 	. ! . . 
	ld a,(ix+000h)		;b145	dd 7e 00 	. ~ . 
	or a			;b148	b7 	. 
	ret z			;b149	c8 	. 
	inc (iy+000h)		;b14a	fd 34 00 	. 4 . 
	ld a,(iy+000h)		;b14d	fd 7e 00 	. ~ . 
	cp 0bch		;b150	fe bc 	. . 
	ret c			;b152	d8 	. 
	ld (ix+000h),000h		;b153	dd 36 00 00 	. 6 . . 
	ld (iy+000h),0c0h		;b157	fd 36 00 c0 	. 6 . . 
	ret			;b15b	c9 	. 
sub_b15ch:
	ld a,(LEVEL)		;b15c	3a 1b e0
	cp FINAL_LEVEL		;b15f	fe 20
	ret z			;b161	c8 	. 
	ld a,(0e54bh)		;b162	3a 4b e5 	: K . 
	cp 006h		;b165	fe 06 	. . 
	ret z			;b167	c8 	. 
	ld ix,0e0c9h		;b168	dd 21 c9 e0 	. ! . . 
	ld iy,0e0cdh		;b16c	fd 21 cd e0 	. ! . . 
	ld a,(ix+000h)		;b170	dd 7e 00 	. ~ . 
	cp 0a8h		;b173	fe a8 	. . 
	ret c			;b175	d8 	. 
	cp 0b8h		;b176	fe b8 	. . 
	ret nc			;b178	d0 	. 
	ld a,(iy+001h)		;b179	fd 7e 01 	. ~ . 
	cp (ix+001h)		;b17c	dd be 01 	. . . 
	ret nc			;b17f	d0 	. 
	ld c,020h		;b180	0e 20 	.   
	ld a,(0e321h)		;b182	3a 21 e3 	: ! . 
	or a			;b185	b7 	. 
	jp z,lb18bh		;b186	ca 8b b1 	. . . 
	ld c,030h		;b189	0e 30 	. 0 
lb18bh:
	ld a,(iy+001h)		;b18b	fd 7e 01 	. ~ . 
	add a,c			;b18e	81 	. 
	cp (ix+001h)		;b18f	dd be 01 	. . . 
	ret c			;b192	d8 	. 
	ld (ix+000h),0c0h		;b193	dd 36 00 c0 	. 6 . . 
	ld (ix+002h),000h		;b197	dd 36 02 00 	. 6 . . 
	ld a,00bh		;b19b	3e 0b 	> . 
	call sub_52a0h		;b19d	cd a0 52 	. . R 
	call sub_b1a8h		;b1a0	cd a8 b1 	. . . 
	xor a			;b1a3	af 	. 
	ld (0e317h),a		;b1a4	32 17 e3 	2 . . 
	ret			;b1a7	c9 	. 
sub_b1a8h:
	ld a,(0e317h)		;b1a8	3a 17 e3 	: . . 
	or a			;b1ab	b7 	. 
	ret z			;b1ac	c8 	. 
	ld hl,0e320h		;b1ad	21 20 e3 	!   . 
	ld de,0e321h		;b1b0	11 21 e3 	. ! . 
	ld (hl),000h		;b1b3	36 00 	6 . 
	ld bc,00003h		;b1b5	01 03 00 	. . . 
	ldir		;b1b8	ed b0 	. . 
	ld a,(0e318h)		;b1ba	3a 18 e3 	: . . 
	rlca			;b1bd	07 	. 
	ld e,a			;b1be	5f 	_ 
	ld d,000h		;b1bf	16 00 	. . 
	ld hl,lb1cah		;b1c1	21 ca b1 	! . . 
	add hl,de			;b1c4	19 	. 
	ld e,(hl)			;b1c5	5e 	^ 
	inc hl			;b1c6	23 	# 
	ld d,(hl)			;b1c7	56 	V 
	ex de,hl			;b1c8	eb 	. 
	jp (hl)			;b1c9	e9 	. 
lb1cah:
	jp c,015b1h		;b1ca	da b1 15 	. . . 
	or d			;b1cd	b2 	. 
	ld e,0b2h		;b1ce	1e b2 	. . 
	dec sp			;b1d0	3b 	; 
	or d			;b1d1	b2 	. 
	ld d,e			;b1d2	53 	S 
	or d			;b1d3	b2 	. 
	ld (hl),c			;b1d4	71 	q 
	or d			;b1d5	b2 	. 
	add a,(hl)			;b1d6	86 	. 
	or d			;b1d7	b2 	. 
	ld e,0b2h		;b1d8	1e b2 	. . 
	ld a,(0e324h)		;b1da	3a 24 e3 	: $ . 
	or a			;b1dd	b7 	. 
	jp z,lb1e6h		;b1de	ca e6 b1 	. . . 
	ld a,002h		;b1e1	3e 02 	> . 
	ld (0e324h),a		;b1e3	32 24 e3 	2 $ . 
lb1e6h:
	ld a,001h		;b1e6	3e 01 	> . 
	ld (0e320h),a		;b1e8	32 20 e3 	2   . 
	call sub_b2a7h		;b1eb	cd a7 b2 	. . . 
    
    ; Loop over 3 balls
	ld b,3		                ;b1ee	06 03
	ld de,BALL_TABLE_LEN		;b1f0	11 14 00
	ld iy,BALL_TABLE1		    ;b1f3	fd 21 4e e2
lb1f7h:
    ; Process if the ball is active
	ld a,(iy+BALL_TABLE_IDX_ACTIVE)		;b1f7	fd 7e 00
	or a			;b1fa	b7 	. 
	jp nz,lb203h		;b1fb	c2 03 b2 	. . . 
    
    ; Next ball
	add iy,de		;b1fe	fd 19
	djnz lb1f7h		;b200	10 f5
	ret			;b202	c9 	. 
lb203h:
	ld (iy+BALL_TABLE_IDX_SPEED_COUNTER), 0		;b203	fd 36 0d 00
    
    ; Decrement ball speed
	ld a,(iy+BALL_TABLE_IDX_SPEED_POS)		    ;b207	fd 7e 07
	sub 1		                                ;b20a	d6 01
	ld (iy+BALL_TABLE_IDX_SPEED_POS),a		    ;b20c	fd 77 07

	ret nc			                            ;b20f	d0
    ; Reset the speed pos if speed below zero
	ld (iy+BALL_TABLE_IDX_SPEED_POS),000h		;b210	fd 36 07 00
	ret			                                ;b214	c9

    ; Dead code?
	ld a,001h		;b215	3e 01 	> . 
	ld (0e324h),a		;b217	32 24 e3 	2 $ . 
	call sub_b2a7h		;b21a	cd a7 b2 	. . . 
	ret			;b21d	c9 	. 

    ; Dead code?
	ld a,(0e324h)		;b21e	3a 24 e3 	: $ . 
	or a			;b221	b7 	. 
	jp z,lb22ah		;b222	ca 2a b2 	. * . 
	ld a,002h		;b225	3e 02 	> . 
	ld (0e324h),a		;b227	32 24 e3 	2 $ . 
lb22ah:
	call sub_b2a7h		;b22a	cd a7 b2 	. . . 
	ld a,002h		;b22d	3e 02 	> . 
	ld (0e54bh),a		;b22f	32 4b e5 	2 K . 
	ld (0e321h),a		;b232	32 21 e3 	2 ! . 
	ld a,0c0h		;b235	3e c0 	> . 
	call sub_5befh		;b237	cd ef 5b 	. . [ 
	ret			;b23a	c9 	. 

	ld a,(0e324h)		;b23b	3a 24 e3 	: $ . 
	or a			;b23e	b7 	. 
	jp z,lb247h		;b23f	ca 47 b2 	. G . 
	ld a,002h		;b242	3e 02 	> . 
	ld (0e324h),a		;b244	32 24 e3 	2 $ . 
lb247h:
	ld a,002h		;b247	3e 02 	> . 
	ld (EXTRA_BALLS),a		;b249	32 25 e3 	2 % . 
	call sub_b2a7h		;b24c	cd a7 b2 	. . . 
	call sub_b2c1h		;b24f	cd c1 b2 	. . . 
	ret			;b252	c9 	. 
	ld a,(0e324h)		;b253	3a 24 e3 	: $ . 
	or a			;b256	b7 	. 
	jp z,lb25fh		;b257	ca 5f b2 	. _ . 
	ld a,002h		;b25a	3e 02 	> . 
	ld (0e324h),a		;b25c	32 24 e3 	2 $ . 
lb25fh:
	call sub_b2a7h		;b25f	cd a7 b2 	. . . 
	ld a,004h		;b262	3e 04 	> . 
	ld (0e54bh),a		;b264	32 4b e5 	2 K . 
	ld a,001h		;b267	3e 01 	> . 
	ld (0e322h),a		;b269	32 22 e3 	2 " . 
	xor a			;b26c	af 	. 
	ld (SPEEDUP_ALL_BALLS_COUNTER),a		;b26d	32 29 e5 	2 ) . 
	ret			;b270	c9 	. 
	ld a,(0e324h)		;b271	3a 24 e3 	: $ . 
	or a			;b274	b7 	. 
	jp z,lb27dh		;b275	ca 7d b2 	. } . 
	ld a,002h		;b278	3e 02 	> . 
	ld (0e324h),a		;b27a	32 24 e3 	2 $ . 
lb27dh:
	ld a,001h		;b27d	3e 01 	> . 
	ld (PORTAL_OPEN),a		;b27f	32 26 e3 	2 & . 
	call sub_b2a7h		;b282	cd a7 b2 	. . . 
	ret			;b285	c9 	. 
	ld a,(0e324h)		;b286	3a 24 e3 	: $ . 
	or a			;b289	b7 	. 
	jp z,lb292h		;b28a	ca 92 b2 	. . . 
	ld a,002h		;b28d	3e 02 	> . 
	ld (0e324h),a		;b28f	32 24 e3 	2 $ . 
lb292h:
	call sub_b2a7h		;b292	cd a7 b2 	. . . 
	ld a,001h		;b295	3e 01 	> . 
	ld (0e327h),a		;b297	32 27 e3 	2 ' . 
	ld hl,LIVES		;b29a	21 1d e0 	! . . 
	inc (hl)			;b29d	34 	4 
	call DRAW_LIVES		;b29e	cd b9 71 	. . q 
	ld a,0c5h		;b2a1	3e c5 	> . 
	call sub_5befh		;b2a3	cd ef 5b 	. . [ 
	ret			;b2a6	c9 	. 
sub_b2a7h:
	ld a,(0e550h)		;b2a7	3a 50 e5 	: P . 
	cp 002h		;b2aa	fe 02 	. . 
	jr nz,lb2b2h		;b2ac	20 04 	  . 
	ld a,003h		;b2ae	3e 03 	> . 
	jr lb2bdh		;b2b0	18 0b 	. . 
lb2b2h:
	or a			;b2b2	b7 	. 
	jr nz,lb2c0h		;b2b3	20 0b 	  . 
	ld a,(0e551h)		;b2b5	3a 51 e5 	: Q . 
	or a			;b2b8	b7 	. 
	jr z,lb2c0h		;b2b9	28 05 	( . 
	ld a,005h		;b2bb	3e 05 	> . 
lb2bdh:
	ld (0e54bh),a		;b2bd	32 4b e5 	2 K . 
lb2c0h:
	ret			;b2c0	c9 	. 

; SEGUIR
sub_b2c1h:
	push ix		;b2c1	dd e5 	. . 
	pop iy		;b2c3	fd e1 	. . 

	ld b, 3 		        ;b2c5	06 03       3 balls to check
	ld iy,BALL_TABLE1		;b2c7	fd 21 4e e2
	ld ix,BALL1_SPR_PARAMS		    ;b2cb	dd 21 f5 e0
lb2cfh:
	ld a,(iy+BALL_TABLE_IDX_ACTIVE)		;b2cf	fd 7e 00
	or a			                    ;b2d2	b7
	jp nz,lb2e5h		                ;b2d3	c2 e5 b2 Process if ball active
    
    ; Point to the next ball's table
	ld de,BALL_TABLE_LEN		        ;b2d6	11 14 00
	add iy,de		                    ;b2d9	fd 19
    
	; BALL1_SPR_PARAMS, BALL2_SPR_PARAMS, and BALL3_SPR_PARAMS are space by 4 bytes
    ; Increment also the pointer to BALL(i)_Y
    ld de, 4		                    ;b2db	11 04 00
        
	add ix,de		;b2de	dd 19
	djnz lb2cfh		;b2e0	10 ed
    ; All balls checked, get out
	jp lb34dh		                    ;b2e2	c3 4d b3

lb2e5h:
	ld hl,lb352h		;b2e5	21 52 b3 	! R . 
	ld a,(iy+006h)		;b2e8	fd 7e 06 	. ~ . 
	bit 7,a		;b2eb	cb 7f 	.  
	jp z,lb2f5h		;b2ed	ca f5 b2 	. . . 
	neg		;b2f0	ed 44 	. D 
	ld hl,lb376h		;b2f2	21 76 b3 	! v . 
lb2f5h:
	ld e,a			;b2f5	5f 	_ 
	sla e		;b2f6	cb 23 	. # 
	sla e		;b2f8	cb 23 	. # 
	ld d,000h		;b2fa	16 00 	. . 
	add hl,de			;b2fc	19 	. 
	ld c,(iy+BALL_TABLE_IDX_SPEED_POS)		;b2fd	fd 4e 07

	ld a,(iy+BALL_TABLE_IDX_SPEED_COUNTER)	;b300	fd 7e 0d
	ld (0e53ch),a		;b303	32 3c e5 	2 < . 

	ld b, 3		            ;b306	06 03   Therea are 3 balls to loop over
	ld iy,BALL_TABLE1		;b308	fd 21 4e e2
	ld de,BALL_TABLE_LEN	;b30c	11 14 00
lb30fh:
    ; Ball is active
	ld (iy+BALL_TABLE_IDX_ACTIVE), 1	;b30f	fd 36 00 01
    
    ; Ball is moving normally, not glued
	ld (iy+BALL_TABLE_IDX_GLUE), 2		;b313	fd 36 01 02

	ld a,(hl)			;b317	7e 	~ 
	ld (iy+006h),a		;b318	fd 77 06 	. w . 

	ld a,(0e53ch)		;b31b	3a 3c e5 	: < . 
	ld (iy+BALL_TABLE_IDX_SPEED_COUNTER),a		;b31e	fd 77 0d

	ld (iy+BALL_TABLE_IDX_SPEED_POS),c		    ;b321	fd 71 07
    
    ; Next ball
	inc hl			;b324	23 	# 
	add iy,de		;b325	fd 19 	. . 
	djnz lb30fh		;b327	10 e6 	. . 

    ; Position of the ball's sprite
	ld l,(ix+BALL_SPR_PARAMS_IDX_Y)		;b329	dd 6e 00
	ld h,(ix+BALL_SPR_PARAMS_IDX_X)		;b32c	dd 66 01

	ld b, 3		                ;b32f	06 03       3 balls
	ld ix, BALL1_SPR_PARAMS		;b331	dd 21 f5 e0
	ld de, BALL_SPR_PARAMS_LEN  ;b335	11 04 00
lb338h:
    ; Set ball's sprite parameters
	ld (ix+BALL_SPR_PARAMS_IDX_Y),l		            ;b338	dd 75 00        Y
	ld (ix+BALL_SPR_PARAMS_IDX_X),h		            ;b33b	dd 74 01        X
	ld (ix+BALL_SPR_PARAMS_IDX_PATTERN_NUM), 128	;b33e	dd 36 02 80     Pattern of the ball
	ld (ix+BALL_SPR_PARAMS_IDX_COLOR),  15	        ;b342	dd 36 03 0f     White color

    ; Next ball
	ld de, 4		    ;b346	11 04 00    Useless, it was already initialized @b335
	add ix,de		    ;b349	dd 19
	djnz lb338h		    ;b34b	10 eb
lb34dh:
    ; Return
	pop iy		;b34d	fd e1
	pop ix		;b34f	dd e1
	ret			;b351	c9

lb352h:
	nop			;b352	00 	. 
	nop			;b353	00 	. 
	nop			;b354	00 	. 
	nop			;b355	00 	. 
	ld (bc),a			;b356	02 	. 
	inc bc			;b357	03 	. 
	inc b			;b358	04 	. 
	ld (bc),a			;b359	02 	. 
	ld (bc),a			;b35a	02 	. 
	inc bc			;b35b	03 	. 
	inc b			;b35c	04 	. 
	ld (bc),a			;b35d	02 	. 
	ld (bc),a			;b35e	02 	. 
	inc bc			;b35f	03 	. 
	inc b			;b360	04 	. 
	ld (bc),a			;b361	02 	. 
	ld (bc),a			;b362	02 	. 
	inc bc			;b363	03 	. 
	inc b			;b364	04 	. 
	ld (bc),a			;b365	02 	. 
	inc b			;b366	04 	. 
	dec b			;b367	05 	. 
	ld b,004h		;b368	06 04 	. . 
	dec b			;b36a	05 	. 
	ld b,007h		;b36b	06 07 	. . 
	dec b			;b36d	05 	. 
	dec b			;b36e	05 	. 
	ld b,007h		;b36f	06 07 	. . 
	dec b			;b371	05 	. 
	dec b			;b372	05 	. 
	ld b,007h		;b373	06 07 	. . 
	dec b			;b375	05 	. 
lb376h:
	nop			;b376	00 	. 
	nop			;b377	00 	. 
	nop			;b378	00 	. 
	nop			;b379	00 	. 
	cp 0fdh		;b37a	fe fd 	. . 
	call m,0fefeh		;b37c	fc fe fe 	. . . 
	defb 0fdh,0fch,0feh	;illegal sequence		;b37f	fd fc fe 	. . . 
	cp 0fdh		;b382	fe fd 	. . 
	call m,0fefeh		;b384	fc fe fe 	. . . 
	defb 0fdh,0fch,0feh	;illegal sequence		;b387	fd fc fe 	. . . 
	call m,0fafbh		;b38a	fc fb fa 	. . . 
	call m,0fafbh		;b38d	fc fb fa 	. . . 
	ld sp,hl			;b390	f9 	. 
	jp m,0fafbh		;b391	fa fb fa 	. . . 
	ld sp,hl			;b394	f9 	. 
	jp m,0fafbh		;b395	fa fb fa 	. . . 
	ld sp,hl			;b398	f9 	. 
    db 0xfa

; SEGUIR
sub_b39ah:
    push bc         ;b39a	c5
    xor a           ;b39b	af
    ld b, 0x10      ;b39c   06 10
lb39eh:
	add hl,hl			;b39e	29 	) 
	rla			;b39f	17 	. 
	jr c,lb3a5h		;b3a0	38 03 	8 . 
	cp c			;b3a2	b9 	. 
	jr c,lb3a7h		;b3a3	38 02 	8 . 
lb3a5h:
	sub c			;b3a5	91 	. 
	inc l			;b3a6	2c 	, 
lb3a7h:
	djnz lb39eh		;b3a7	10 f5 	. . 
	pop bc			;b3a9	c1 	. 
	ret			;b3aa	c9 	. 

	nop			;b3ab	00 	. 
	nop			;b3ac	00 	. 
	nop			;b3ad	00 	. 
	nop			;b3ae	00 	. 
	nop			;b3af	00 	. 
	nop			;b3b0	00 	. 
	nop			;b3b1	00 	. 
	nop			;b3b2	00 	. 
	nop			;b3b3	00 	. 
	nop			;b3b4	00 	. 
	nop			;b3b5	00 	. 
	nop			;b3b6	00 	. 
	nop			;b3b7	00 	. 
	nop			;b3b8	00 	. 
	nop			;b3b9	00 	. 
	nop			;b3ba	00 	. 
	nop			;b3bb	00 	. 
	nop			;b3bc	00 	. 
	nop			;b3bd	00 	. 
	nop			;b3be	00 	. 
	nop			;b3bf	00 	. 
	nop			;b3c0	00 	. 
	nop			;b3c1	00 	. 
	nop			;b3c2	00 	. 
	nop			;b3c3	00 	. 
	nop			;b3c4	00 	. 
	nop			;b3c5	00 	. 
	nop			;b3c6	00 	. 
	nop			;b3c7	00 	. 
	nop			;b3c8	00 	. 
	nop			;b3c9	00 	. 
	nop			;b3ca	00 	. 
	nop			;b3cb	00 	. 
	nop			;b3cc	00 	. 
	nop			;b3cd	00 	. 
	nop			;b3ce	00 	. 
	nop			;b3cf	00 	. 
	nop			;b3d0	00 	. 
	nop			;b3d1	00 	. 
	nop			;b3d2	00 	. 
	nop			;b3d3	00 	. 
	nop			;b3d4	00 	. 
	nop			;b3d5	00 	. 
	nop			;b3d6	00 	. 
	nop			;b3d7	00 	. 
	nop			;b3d8	00 	. 
	nop			;b3d9	00 	. 
	nop			;b3da	00 	. 
	nop			;b3db	00 	. 
	nop			;b3dc	00 	. 
	nop			;b3dd	00 	. 
	nop			;b3de	00 	. 
	nop			;b3df	00 	. 
	nop			;b3e0	00 	. 
	nop			;b3e1	00 	. 
	nop			;b3e2	00 	. 
	nop			;b3e3	00 	. 
	nop			;b3e4	00 	. 
	nop			;b3e5	00 	. 
	nop			;b3e6	00 	. 
	nop			;b3e7	00 	. 
	nop			;b3e8	00 	. 
	nop			;b3e9	00 	. 
	nop			;b3ea	00 	. 
	nop			;b3eb	00 	. 
	nop			;b3ec	00 	. 
	nop			;b3ed	00 	. 
	nop			;b3ee	00 	. 
	nop			;b3ef	00 	. 
	nop			;b3f0	00 	. 
	nop			;b3f1	00 	. 
	nop			;b3f2	00 	. 
	nop			;b3f3	00 	. 
	nop			;b3f4	00 	. 
	nop			;b3f5	00 	. 
	nop			;b3f6	00 	. 
	nop			;b3f7	00 	. 
	nop			;b3f8	00 	. 
	nop			;b3f9	00 	. 
	nop			;b3fa	00 	. 
	nop			;b3fb	00 	. 
	nop			;b3fc	00 	. 
	nop			;b3fd	00 	. 
	nop			;b3fe	00 	. 
	nop			;b3ff	00 	. 
	jp PLAY_SOUND		;b400	c3 e8 b4 	. . . 
	jp sub_b594h		;b403	c3 94 b5 	. . . 
	ld (02c27h),hl		;b406	22 27 2c 	" ' , 
	ld sp,03b36h		;b409	31 36 3b 	1 6 ; 
	ld b,b			;b40c	40 	@ 
	ld b,l			;b40d	45 	E 
	ld c,d			;b40e	4a 	J 
	ld c,a			;b40f	4f 	O 
	ld d,h			;b410	54 	T 
	ld e,c			;b411	59 	Y 
	ld e,(hl)			;b412	5e 	^ 
	ld h,e			;b413	63 	c 
	ld l,b			;b414	68 	h 
	ld l,l			;b415	6d 	m 
	ld (hl),d			;b416	72 	r 
	ld (hl),a			;b417	77 	w 
	ld a,h			;b418	7c 	| 
	add a,c			;b419	81 	. 
	add a,(hl)			;b41a	86 	. 
	adc a,e			;b41b	8b 	. 
	sub b			;b41c	90 	. 
	sub l			;b41d	95 	. 
	sbc a,d			;b41e	9a 	. 
	sbc a,a			;b41f	9f 	. 
	and h			;b420	a4 	. 
	xor c			;b421	a9 	. 
	pop af			;b422	f1 	. 
	rst 38h			;b423	ff 	. 
	pop af			;b424	f1 	. 
	ld d,l			;b425	55 	U 
	cp b			;b426	b8 	. 
	add a,c			;b427	81 	. 
	rst 38h			;b428	ff 	. 
	add a,c			;b429	81 	. 
	ld e,l			;b42a	5d 	] 
	cp b			;b42b	b8 	. 
	add a,c			;b42c	81 	. 
	rst 38h			;b42d	ff 	. 
	add a,c			;b42e	81 	. 
	ld l,d			;b42f	6a 	j 
	cp b			;b430	b8 	. 
	add a,c			;b431	81 	. 
	rst 38h			;b432	ff 	. 
	add a,c			;b433	81 	. 
	ld (hl),a			;b434	77 	w 
	cp b			;b435	b8 	. 
	add a,c			;b436	81 	. 
	rst 38h			;b437	ff 	. 
	add a,c			;b438	81 	. 
	add a,l			;b439	85 	. 
	cp b			;b43a	b8 	. 
	pop de			;b43b	d1 	. 
	rst 38h			;b43c	ff 	. 
	pop de			;b43d	d1 	. 
	or (hl)			;b43e	b6 	. 
	cp b			;b43f	b8 	. 
	and c			;b440	a1 	. 
	rst 38h			;b441	ff 	. 
	and c			;b442	a1 	. 
	pop bc			;b443	c1 	. 
	cp b			;b444	b8 	. 
	pop bc			;b445	c1 	. 
	rst 38h			;b446	ff 	. 
	pop bc			;b447	c1 	. 
	exx			;b448	d9 	. 
	cp b			;b449	b8 	. 
	add a,c			;b44a	81 	. 
	rst 38h			;b44b	ff 	. 
	add a,c			;b44c	81 	. 
	ei			;b44d	fb 	. 
	cp b			;b44e	b8 	. 
	and c			;b44f	a1 	. 
	rst 38h			;b450	ff 	. 
	and c			;b451	a1 	. 
	ex af,af'			;b452	08 	. 
	cp c			;b453	b9 	. 
	or c			;b454	b1 	. 
	rst 38h			;b455	ff 	. 
	or c			;b456	b1 	. 
	adc a,(hl)			;b457	8e 	. 
	cp b			;b458	b8 	. 
	or c			;b459	b1 	. 
	rst 38h			;b45a	ff 	. 
	or c			;b45b	b1 	. 
	dec (hl)			;b45c	35 	5 
	cp c			;b45d	b9 	. 
	pop bc			;b45e	c1 	. 
	rst 38h			;b45f	ff 	. 
	pop bc			;b460	c1 	. 
	sbc a,c			;b461	99 	. 
	cp b			;b462	b8 	. 
	pop bc			;b463	c1 	. 
	rst 38h			;b464	ff 	. 
	pop bc			;b465	c1 	. 
	ld b,b			;b466	40 	@ 
	cp c			;b467	b9 	. 
	or c			;b468	b1 	. 
	rst 38h			;b469	ff 	. 
	or c			;b46a	b1 	. 
	xor c			;b46b	a9 	. 
	cp b			;b46c	b8 	. 
	or c			;b46d	b1 	. 
	rst 38h			;b46e	ff 	. 
	or c			;b46f	b1 	. 
	ld c,(hl)			;b470	4e 	N 
	cp c			;b471	b9 	. 
	pop bc			;b472	c1 	. 
	nop			;b473	00 	. 
	pop bc			;b474	c1 	. 
	ld d,0bah		;b475	16 ba 	. . 
	pop bc			;b477	c1 	. 
	rst 38h			;b478	ff 	. 
	pop bc			;b479	c1 	. 
	ld e,(hl)			;b47a	5e 	^ 
	cp c			;b47b	b9 	. 
	pop bc			;b47c	c1 	. 
	nop			;b47d	00 	. 
	pop bc			;b47e	c1 	. 
	ld l,b			;b47f	68 	h 
	cp d			;b480	ba 	. 
	pop bc			;b481	c1 	. 
	rst 38h			;b482	ff 	. 
	pop bc			;b483	c1 	. 
	adc a,e			;b484	8b 	. 
	cp d			;b485	ba 	. 
	pop bc			;b486	c1 	. 
	nop			;b487	00 	. 
	pop bc			;b488	c1 	. 
	push af			;b489	f5 	. 
	cp d			;b48a	ba 	. 
	pop bc			;b48b	c1 	. 
	rst 38h			;b48c	ff 	. 
	pop bc			;b48d	c1 	. 
	inc bc			;b48e	03 	. 
	cp e			;b48f	bb 	. 
	pop bc			;b490	c1 	. 
	nop			;b491	00 	. 
	pop bc			;b492	c1 	. 
	inc h			;b493	24 	$ 
	cp e			;b494	bb 	. 
	pop bc			;b495	c1 	. 
	rst 38h			;b496	ff 	. 
	pop bc			;b497	c1 	. 
	dec (hl)			;b498	35 	5 
	cp e			;b499	bb 	. 
	pop bc			;b49a	c1 	. 
	add a,0c2h		;b49b	c6 c2 	. . 
	add a,e			;b49d	83 	. 
	cp e			;b49e	bb 	. 
	pop bc			;b49f	c1 	. 
	add a,0c2h		;b4a0	c6 c2 	. . 
	sub e			;b4a2	93 	. 
	cp h			;b4a3	bc 	. 
	pop bc			;b4a4	c1 	. 
	nop			;b4a5	00 	. 
	pop bc			;b4a6	c1 	. 
	exx			;b4a7	d9 	. 
	cp (hl)			;b4a8	be 	. 
	pop bc			;b4a9	c1 	. 
	rst 38h			;b4aa	ff 	. 
	pop bc			;b4ab	c1 	. 
	ld b,h			;b4ac	44 	D 
	cp a			;b4ad	bf 	. 
lb4aeh:
	nop			;b4ae	00 	. 
	or b			;b4af	b0 	. 
	call z,02890h		;b4b0	cc 90 28 	. . ( 
	adc a,c			;b4b3	89 	. 
	jr z,lb534h		;b4b4	28 7e 	( ~ 
	and a			;b4b6	a7 	. 
	ret z			;b4b7	c8 	. 
	push hl			;b4b8	e5 	. 
	pop ix		;b4b9	dd e1 	. . 
	dec (ix+009h)		;b4bb	dd 35 09 	. 5 . 
	ret nz			;b4be	c0 	. 
	ld a,(bc)			;b4bf	0a 	. 
	and a			;b4c0	a7 	. 
	scf			;b4c1	37 	7 
	ret nz			;b4c2	c0 	. 
	inc hl			;b4c3	23 	# 
	inc hl			;b4c4	23 	# 
	or (hl)			;b4c5	b6 	. 
	inc hl			;b4c6	23 	# 
	inc hl			;b4c7	23 	# 
	dec (hl)			;b4c8	35 	5 
	jr z,lb4d1h		;b4c9	28 06 	( . 
	inc hl			;b4cb	23 	# 
	ld c,(hl)			;b4cc	4e 	N 
	inc hl			;b4cd	23 	# 
	ld b,(hl)			;b4ce	46 	F 
	jr lb54dh		;b4cf	18 7c 	. | 
lb4d1h:
	dec hl			;b4d1	2b 	+ 
	dec (hl)			;b4d2	35 	5 
	inc hl			;b4d3	23 	# 
	inc hl			;b4d4	23 	# 
	jr z,lb4e1h		;b4d5	28 0a 	( . 
	ld c,(hl)			;b4d7	4e 	N 
	inc hl			;b4d8	23 	# 
	ld b,(hl)			;b4d9	46 	F 
	inc bc			;b4da	03 	. 
	inc bc			;b4db	03 	. 
	inc bc			;b4dc	03 	. 
	dec hl			;b4dd	2b 	+ 
	dec hl			;b4de	2b 	+ 
	jr lb545h		;b4df	18 64 	. d 
lb4e1h:
	ld (ix+000h),000h		;b4e1	dd 36 00 00 	. 6 . . 
	ld (SOUND_NUMBER),a		;b4e5	32 c0 e5 	2 . . 

PLAY_SOUND:
	push hl			;b4e8	e5 	. 
	push de			;b4e9	d5 	. 
	push bc			;b4ea	c5 	. 
	push af			;b4eb	f5 	. 
    
	; A = SOUND_NUMBER
    ld de,SOUND_NUMBER		;b4ec	11 c0 e5 	. . . 
	ld a,(de)			;b4ef	1a 	. 
	
    ld hl,0e5d3h		;b4f0	21 d3 e5 	! . . 
	cp 128		        ;b4f3	fe 80 	. . 
	jr nc,lb4fbh		;b4f5	30 04 	0 . 
    ; SOUND_NUMBER <= 128
	add a,006h		;b4f7	c6 06 	. . 
	jr lb515h		;b4f9	18 1a 	. . 
lb4fbh:
    ; SOUND_NUMBER > 128
	cp 192		    ;b4fb	fe c0 	. . 
	jr nc,lb503h		;b4fd	30 04 	0 . 
    ; SOUND_NUMBER <= 192
	add a,090h		;b4ff	c6 90 	. . 
	jr lb512h		;b501	18 0f 	. . 
lb503h:
    ; SOUND_NUMBER > 192
	sub 240		;b503	d6 f0 	. . 
	jr nc,lb559h		;b505	30 52 	0 R 
    ; SOUND_NUMBER < 240
    
    ; A = (A + 48)*2  + 16
	add a,48		;b507	c6 30 	. 0 
	add a,a			;b509	87 	. 
	add a,16		;b50a	c6 10 	. . 
	push af			;b50c	f5 	. 
	call sub_b51dh		;b50d	cd 1d b5 	. . . 
	pop af			;b510	f1 	. 
	inc a			;b511	3c 	< 
lb512h:
	ld hl,0e5e9h		;b512	21 e9 e5 	! . . 
lb515h:
	call sub_b51dh		;b515	cd 1d b5 	. . . 
lb518h:
	pop af			;b518	f1 	. 
	pop bc			;b519	c1 	. 
	pop de			;b51a	d1 	. 
	pop hl			;b51b	e1 	. 
	ret			;b51c	c9 	. 

sub_b51dh:
    ; BC = 0xb4.. , with A
	ld b,0b4h		;b51d	06 b4 	. . 
	ld c,a			;b51f	4f 	O 
    
    
	; C = [0xb4..]
    ld a,(bc)			;b520	0a 	. 
    ld c,a			;b521	4f 	O 
    
	; Exit if [0e5c2h] = 0
    ld a,(0e5c2h)		;b522	3a c2 e5 	: . . 
	and a			;b525	a7 	. 
	ret z			;b526	c8 	. 

	di			;b527	f3 	. 
	
    ld a,(hl)			;b528	7e 	~ 
	ld (hl),001h		;b529	36 01 	6 . 
    inc hl			;b52b	23 	#
    
	and a			;b52c	a7 	. 
	jr z,lb534h		;b52d	28 05 	( . 
	
    ld a,(bc)			;b52f	0a 	. 
	and 0f0h		;b530	e6 f0 	. . 
	cp (hl)			;b532	be 	. 
	ret c			;b533	d8 	. 
lb534h:
    ; Read in D
	ld a,(bc)			;b534	0a 	. 
	and 00fh		;b535	e6 0f 	. . 
	ld d,a			;b537	57 	W 
	inc bc			;b538	03 	. 

    ; Read in E
	ld a,(bc)			;b539	0a 	. 
	ld e,a			;b53a	5f 	_ 
	inc bc			;b53b	03 	. 

    ; Read in A
	ld a,(bc)			;b53c	0a 	. 
	and 0f0h		;b53d	e6 f0 	. . 

    ; Write (HL) <-- A, E, D
	ld (hl),a			;b53f	77 	w 
	inc hl			;b540	23 	# 
	ld (hl),e			;b541	73 	s 
	inc hl			;b542	23 	# 
	ld (hl),d			;b543	72 	r 
	inc hl			;b544	23 	# 
lb545h:
    ; Read in A
	ld a,(bc)			;b545	0a 	. 
	and 00fh		;b546	e6 0f 	. . 
    
    ; Write (HL) <-- A, C, B 
	ld (hl),a			;b548	77 	w 
	inc hl			;b549	23 	# 
	ld (hl),c			;b54a	71 	q 
	inc hl			;b54b	23 	# 
	ld (hl),b			;b54c	70 	p 
lb54dh:
	inc bc			;b54d	03 	. 

    ; Read in A
	ld a,(bc)			;b54e	0a 	. 
	inc hl			;b54f	23 	# 
    
    ; Write (HL) <-- A
	ld (hl),a			;b550	77 	w 
	inc bc			;b551	03 	. 

    ; Read in A
	ld a,(bc)			;b552	0a 	. 
	inc hl			;b553	23 	# 
    
    ; Write (HL) <-- A
	ld (hl),a			;b554	77 	w 
	inc hl			;b555	23 	# 
	
    ld (hl),001h		;b556	36 01 	6 . 
	ret			;b558	c9 	. 

lb559h:
	ld bc,lb518h		;b559	01 18 b5 	. . . 
	push bc			;b55c	c5 	. 
	inc de			;b55d	13 	. 
	rrca			;b55e	0f 	. 
	ret c			;b55f	d8 	. 
	rra			;b560	1f 	. 
	jr nc,lb56ah		;b561	30 07 	0 . 
	ld (de),a			;b563	12 	. 
	ld hl,0e5cbh		;b564	21 cb e5 	! . . 
	set 7,(hl)		;b567	cb fe 	. . 
	ret			;b569	c9 	. 
lb56ah:
	rrca			;b56a	0f 	. 
	jr nc,lb583h		;b56b	30 16 	0 . 
	ex de,hl			;b56d	eb 	. 
	ld e,0bfh		;b56e	1e bf 	. . 
sub_b570h:
	ld a,007h		;b570	3e 07 	> . 
	bit 7,e		;b572	cb 7b 	. { 
	ret z			;b574	c8 	. 
	res 7,e		;b575	cb bb 	. . 
	ld (hl),e			;b577	73 	s 
	call RDPSG		;b578	cd 96 00 	. . . 
	and 0c0h		;b57b	e6 c0 	. . 
	or e			;b57d	b3 	. 
	ld e,a			;b57e	5f 	_ 
	ld a,007h		;b57f	3e 07 	> . 
	jr lb58ch		;b581	18 09 	. . 
lb583h:
	inc de			;b583	13 	. 
	ld (de),a			;b584	12 	. 
	ret			;b585	c9 	. 
sub_b586h:
	inc a			;b586	3c 	< 
	inc hl			;b587	23 	# 
	rrc c		;b588	cb 09 	. . 
	ret nc			;b58a	d0 	. 
	ld e,(hl)			;b58b	5e 	^ 
lb58ch:
    ; Write value E to PSG register A

    ; Selected PSG register <-- A
	out (0a0h),a		;b58c	d3 a0 	. . 
	
    ; Register A <-- E
    push af			;b58e	f5 	. 
	ld a,e			;b58f	7b 	{ 
	out (0a1h),a		;b590	d3 a1 	. . 
	pop af			;b592	f1 	. 
	ret			;b593	c9 	. 

sub_b594h:
	ld a,(0e5c1h)		;b594	3a c1 e5 	: . . 
	and a			;b597	a7 	. 
	ret nz			;b598	c0 	. 
	ld hl,0e5c3h		;b599	21 c3 e5 	! . . 
	ld c,(hl)			;b59c	4e 	N 
	sub a			;b59d	97 	. 
	ld (hl),a			;b59e	77 	w 
	dec a			;b59f	3d 	= 
	ld d,003h		;b5a0	16 03 	. . 
	ld b,d			;b5a2	42 	B 
lb5a3h:
	call sub_b586h		;b5a3	cd 86 b5 	. . . 
	rlc c		;b5a6	cb 01 	. . 
	call sub_b586h		;b5a8	cd 86 b5 	. . . 
	djnz lb5a3h		;b5ab	10 f6 	. . 
	call sub_b586h		;b5ad	cd 86 b5 	. . . 
	inc hl			;b5b0	23 	# 
	ld e,(hl)			;b5b1	5e 	^ 
	call sub_b570h		;b5b2	cd 70 b5 	. p . 
	ld b,d			;b5b5	42 	B 
lb5b6h:
	call sub_b586h		;b5b6	cd 86 b5 	. . . 
	djnz lb5b6h		;b5b9	10 fb 	. . 
	ld b,d			;b5bb	42 	B 
lb5bch:
	call sub_b586h		;b5bc	cd 86 b5 	. . . 
	rlc c		;b5bf	cb 01 	. . 
	djnz lb5bch		;b5c1	10 f9 	. . 
	ld e,(hl)			;b5c3	5e 	^ 
	inc hl			;b5c4	23 	# 
	bit 3,(hl)		;b5c5	cb 5e 	. ^ 
	call nz,lb58ch		;b5c7	c4 8c b5 	. . . 
	res 3,(hl)		;b5ca	cb 9e 	. . 
	inc hl			;b5cc	23 	# 
	ld bc,(0e5dah)		;b5cd	ed 4b da e5 	. K . . 
	call 0b4b5h		;b5d1	cd b5 b4 	. . . 
	jr nc,lb5e3h		;b5d4	30 0d 	0 . 
	ld (0e5dch),a		;b5d6	32 dc e5 	2 . . 
lb5d9h:
	call sub_b63eh		;b5d9	cd 3e b6 	. > . 
	jr lb5d9h		;b5dc	18 fb 	. . 
lb5deh:
	pop af			;b5de	f1 	. 
	ld (0e5dah),bc		;b5df	ed 43 da e5 	. C . . 
lb5e3h:
	ld hl,0e5e9h		;b5e3	21 e9 e5 	! . . 
	ld bc,(0e5f0h)		;b5e6	ed 4b f0 e5 	. K . . 
	call 0b4b5h		;b5ea	cd b5 b4 	. . . 
	jr nc,lb5fch		;b5ed	30 0d 	0 . 
	ld (0e5f2h),a		;b5ef	32 f2 e5 	2 . . 
lb5f2h:
	call sub_b649h		;b5f2	cd 49 b6 	. I . 
	jr lb5f2h		;b5f5	18 fb 	. . 
lb5f7h:
	pop af			;b5f7	f1 	. 
	ld (0e5f0h),bc		;b5f8	ed 43 f0 e5 	. C . . 
lb5fch:
	ld hl,0e5deh		;b5fc	21 de e5 	! . . 
	ld d,001h		;b5ff	16 01 	. . 
	ld bc,(0e5c4h)		;b601	ed 4b c4 e5 	. K . . 
	call sub_b77bh		;b605	cd 7b b7 	. { . 
	ld (0e5c4h),bc		;b608	ed 43 c4 e5 	. C . . 
	ld hl,0e5e1h		;b60c	21 e1 e5 	! . . 
	ld d,010h		;b60f	16 10 	. . 
	ld a,(0e5cch)		;b611	3a cc e5 	: . . 
	call sub_b79bh		;b614	cd 9b b7 	. . . 
	call sub_b7cfh		;b617	cd cf b7 	. . . 
	ld a,c			;b61a	79 	y 
	ld (0e5cch),a		;b61b	32 cc e5 	2 . . 
	ld hl,0e5f4h		;b61e	21 f4 e5 	! . . 
	ld d,002h		;b621	16 02 	. . 
	ld bc,(0e5c6h)		;b623	ed 4b c6 e5 	. K . . 
	call sub_b77bh		;b627	cd 7b b7 	. { . 
	ld (0e5c6h),bc		;b62a	ed 43 c6 e5 	. C . . 
	ld hl,0e5f7h		;b62e	21 f7 e5 	! . . 
	ld d,040h		;b631	16 40 	. @ 
	ld a,(0e5ceh)		;b633	3a ce e5 	: . . 
	call sub_b79bh		;b636	cd 9b b7 	. . . 
	ld a,c			;b639	79 	y 
	ld (0e5ceh),a		;b63a	32 ce e5 	2 . . 
	ret			;b63d	c9 	. 
sub_b63eh:
	inc bc			;b63e	03 	. 
	ld a,(bc)			;b63f	0a 	. 
	bit 7,a		;b640	cb 7f 	.  
	jr z,lb5deh		;b642	28 9a 	( . 
	ld hl,lb666h		;b644	21 66 b6 	! f . 
	jr lb652h		;b647	18 09 	. . 
sub_b649h:
	inc bc			;b649	03 	. 
	ld a,(bc)			;b64a	0a 	. 
	bit 7,a		;b64b	cb 7f 	.  
	jr z,lb5f7h		;b64d	28 a8 	( . 
	ld hl,lb66eh		;b64f	21 6e b6 	! n . 
lb652h:
	rrca			;b652	0f 	. 
	rrca			;b653	0f 	. 
	rrca			;b654	0f 	. 
	rrca			;b655	0f 	. 
	and 007h		;b656	e6 07 	. . 
	ld e,a			;b658	5f 	_ 
	ld d,000h		;b659	16 00 	. . 
	add hl,de			;b65b	19 	. 
	ld e,(hl)			;b65c	5e 	^ 
	ld hl,0b676h		;b65d	21 76 b6 	! v . 
	add hl,de			;b660	19 	. 
	ld a,(bc)			;b661	0a 	. 
	and 00fh		;b662	e6 0f 	. . 
	ld e,a			;b664	5f 	_ 
	jp (hl)			;b665	e9 	. 
lb666h:
	nop			;b666	00 	. 
	ld c,022h		;b667	0e 22 	. " 
	jr c,lb6aeh		;b669	38 43 	8 C 
	ld b,c			;b66b	41 	A 
	ld d,b			;b66c	50 	P 
	ld c,(hl)			;b66d	4e 	N 
lb66eh:
	ld l,e			;b66e	6b 	k 
	and a			;b66f	a7 	. 
	sbc a,d			;b670	9a 	. 
	xor a			;b671	af 	. 
	cp a			;b672	bf 	. 
	rst 8			;b673	cf 	. 
	defb 0ddh,0ebh,021h	;illegal sequence		;b674	dd eb 21 	. . ! 
	push bc			;b677	c5 	. 
	push hl			;b678	e5 	. 
	ld d,001h		;b679	16 01 	. . 
	call sub_b6e6h		;b67b	cd e6 b6 	. . . 
lb67eh:
	ld de,0e5e6h		;b67e	11 e6 e5 	. . . 
	call sub_b7e6h		;b681	cd e6 b7 	. . . 
	ld hl,0e5e7h		;b684	21 e7 e5 	! . . 
	ld a,(hl)			;b687	7e 	~ 
	and 01fh		;b688	e6 1f 	. . 
	jr z,lb690h		;b68a	28 04 	( . 
	set 7,(hl)		;b68c	cb fe 	. . 
	inc hl			;b68e	23 	# 
	ld (hl),a			;b68f	77 	w 
lb690h:
	ld d,010h		;b690	16 10 	. . 
	ld a,e			;b692	7b 	{ 
	ld (0e5cch),a		;b693	32 cc e5 	2 . . 
	jr lb70eh		;b696	18 76 	. v 
	ld hl,0e5deh		;b698	21 de e5 	! . . 
	bit 3,a		;b69b	cb 5f 	. _ 
	jr z,lb6cdh		;b69d	28 2e 	( . 
	ld de,00801h		;b69f	11 01 08 	. . . 
	call sub_b82dh		;b6a2	cd 2d b8 	. - . 
	sub a			;b6a5	97 	. 
	ld (0e5e7h),a		;b6a6	32 e7 e5 	2 . . 
	call lb6aeh		;b6a9	cd ae b6 	. . . 
	jr lb690h		;b6ac	18 e2 	. . 
lb6aeh:
	ld (0e5e6h),a		;b6ae	32 e6 e5 	2 . . 
	jr nz,lb67eh		;b6b1	20 cb 	  . 
	ld (0e5e1h),a		;b6b3	32 e1 e5 	2 . . 
	ret			;b6b6	c9 	. 
	or 010h		;b6b7	f6 10 	. . 
	jr z,lb6c0h		;b6b9	28 05 	( . 
	ld (0e5e8h),a		;b6bb	32 e8 e5 	2 . . 
	or 080h		;b6be	f6 80 	. . 
lb6c0h:
	ld (0e5e7h),a		;b6c0	32 e7 e5 	2 . . 
	ret			;b6c3	c9 	. 
	or 010h		;b6c4	f6 10 	. . 
	ld (0e5cah),a		;b6c6	32 ca e5 	2 . . 
	ld d,008h		;b6c9	16 08 	. . 
	jr lb70eh		;b6cb	18 41 	. A 
lb6cdh:
	ld (hl),a			;b6cd	77 	w 
	and a			;b6ce	a7 	. 
	ret z			;b6cf	c8 	. 
	set 7,(hl)		;b6d0	cb fe 	. . 
	inc bc			;b6d2	03 	. 
	ld a,(bc)			;b6d3	0a 	. 
	rlca			;b6d4	07 	. 
	sra a		;b6d5	cb 2f 	. / 
	jr c,lb6dch		;b6d7	38 03 	8 . 
	ld a,(bc)			;b6d9	0a 	. 
	set 6,(hl)		;b6da	cb f6 	. . 
lb6dch:
	inc hl			;b6dc	23 	# 
	ld (hl),e			;b6dd	73 	s 
	inc hl			;b6de	23 	# 
	ld (hl),a			;b6df	77 	w 
	ret			;b6e0	c9 	. 
	ld hl,0e5c7h		;b6e1	21 c7 e5 	! . . 
	ld d,002h		;b6e4	16 02 	. . 
sub_b6e6h:
	ld a,(ix+00bh)		;b6e6	dd 7e 0b 	. ~ . 
	and 007h		;b6e9	e6 07 	. . 
	ld (ix+00ch),a		;b6eb	dd 77 0c 	. w . 
	bit 6,(ix+00bh)		;b6ee	dd cb 0b 76 	. . . v 
	jr z,lb700h		;b6f2	28 0c 	( . 
	ld a,(ix+00dh)		;b6f4	dd 7e 0d 	. ~ . 
	bit 7,a		;b6f7	cb 7f 	.  
	jr z,lb700h		;b6f9	28 05 	( . 
	neg		;b6fb	ed 44 	. D 
	ld (ix+00dh),a		;b6fd	dd 77 0d 	. w . 
lb700h:
	ld (hl),e			;b700	73 	s 
	inc bc			;b701	03 	. 
	ld a,(bc)			;b702	0a 	. 
	dec hl			;b703	2b 	+ 
	ld (hl),a			;b704	77 	w 
	ld hl,0e5d2h		;b705	21 d2 e5 	! . . 
	ld a,(hl)			;b708	7e 	~ 
	and d			;b709	a2 	. 
	jr z,lb759h		;b70a	28 4d 	( M 
	set 3,(hl)		;b70c	cb de 	. . 
lb70eh:
	jr lb759h		;b70e	18 49 	. I 
	ld hl,0e5f4h		;b710	21 f4 e5 	! . . 
	bit 3,a		;b713	cb 5f 	. _ 
	jr z,lb6cdh		;b715	28 b6 	( . 
	ld de,01002h		;b717	11 02 10 	. . . 
	call sub_b82dh		;b71a	cd 2d b8 	. - . 
	ld d,020h		;b71d	16 20 	.   
	ld a,e			;b71f	7b 	{ 
	ld (0e5cdh),a		;b720	32 cd e5 	2 . . 
	jr lb759h		;b723	18 34 	. 4 
	bit 3,a		;b725	cb 5f 	. _ 
	jr nz,lb72eh		;b727	20 05 	  . 
	rlca			;b729	07 	. 
	ld (0e5d2h),a		;b72a	32 d2 e5 	2 . . 
	ret			;b72d	c9 	. 
lb72eh:
	ld (0e5d1h),a		;b72e	32 d1 e5 	2 . . 
	inc bc			;b731	03 	. 
	ld a,(bc)			;b732	0a 	. 
	jr lb739h		;b733	18 04 	. . 
	rlca			;b735	07 	. 
	rlca			;b736	07 	. 
	rlca			;b737	07 	. 
	rlca			;b738	07 	. 
lb739h:
	ld (0e5cfh),a		;b739	32 cf e5 	2 . . 
	inc bc			;b73c	03 	. 
	ld a,(bc)			;b73d	0a 	. 
	ld (0e5d0h),a		;b73e	32 d0 e5 	2 . . 
	ld d,080h		;b741	16 80 	. . 
	jr lb759h		;b743	18 14 	. . 
	ld hl,0e5c9h		;b745	21 c9 e5 	! . . 
	ld d,004h		;b748	16 04 	. . 
	call lb700h		;b74a	cd 00 b7 	. . . 
lb74dh:
	ld de,0e5fch		;b74d	11 fc e5 	. . . 
	call sub_b7e6h		;b750	cd e6 b7 	. . . 
lb753h:
	ld d,040h		;b753	16 40 	. @ 
	ld a,e			;b755	7b 	{ 
	ld (0e5ceh),a		;b756	32 ce e5 	2 . . 
lb759h:
	ld a,(0e5c3h)		;b759	3a c3 e5 	: . . 
	or d			;b75c	b2 	. 
	ld (0e5c3h),a		;b75d	32 c3 e5 	2 . . 
	ret			;b760	c9 	. 
	bit 3,a		;b761	cb 5f 	. _ 
	jr nz,lb76fh		;b763	20 0a 	  . 
sub_b765h:
	ld (0e5fch),a		;b765	32 fc e5 	2 . . 
	and a			;b768	a7 	. 
	jr nz,lb74dh		;b769	20 e2 	  . 
	ld (0e5f7h),a		;b76b	32 f7 e5 	2 . . 
	ret			;b76e	c9 	. 
lb76fh:
	ld de,02004h		;b76f	11 04 20 	. .   
	call sub_b831h		;b772	cd 31 b8 	. 1 . 
	sub a			;b775	97 	. 
	call sub_b765h		;b776	cd 65 b7 	. e . 
	jr lb753h		;b779	18 d8 	. . 
sub_b77bh:
	ld e,(hl)			;b77b	5e 	^ 
	bit 7,e		;b77c	cb 7b 	. { 
	ret z			;b77e	c8 	. 
	inc hl			;b77f	23 	# 
	dec (hl)			;b780	35 	5 
	ret nz			;b781	c0 	. 
	ld a,e			;b782	7b 	{ 
	and 007h		;b783	e6 07 	. . 
	ld (hl),a			;b785	77 	w 
	inc hl			;b786	23 	# 
	ld a,(hl)			;b787	7e 	~ 
	bit 6,e		;b788	cb 73 	. s 
	jr z,lb78fh		;b78a	28 03 	( . 
	neg		;b78c	ed 44 	. D 
	ld (hl),a			;b78e	77 	w 
lb78fh:
	ld l,a			;b78f	6f 	o 
	ld h,000h		;b790	26 00 	& . 
	rlca			;b792	07 	. 
	jr nc,lb796h		;b793	30 01 	0 . 
	dec h			;b795	25 	% 
lb796h:
	add hl,bc			;b796	09 	. 
	ld b,h			;b797	44 	D 
	ld c,l			;b798	4d 	M 
	jr lb759h		;b799	18 be 	. . 
sub_b79bh:
	push hl			;b79b	e5 	. 
	pop ix		;b79c	dd e1 	. . 
	ld c,a			;b79e	4f 	O 
	ld b,(hl)			;b79f	46 	F 
	bit 7,b		;b7a0	cb 78 	. x 
	ret z			;b7a2	c8 	. 
	inc hl			;b7a3	23 	# 
	dec (hl)			;b7a4	35 	5 
	ret nz			;b7a5	c0 	. 
	ld a,b			;b7a6	78 	x 
	and 00fh		;b7a7	e6 0f 	. . 
	ld (hl),a			;b7a9	77 	w 
	inc hl			;b7aa	23 	# 
	dec (hl)			;b7ab	35 	5 
	jr z,lb7c1h		;b7ac	28 13 	( . 
	bit 6,b		;b7ae	cb 70 	. p 
	jr z,lb7bbh		;b7b0	28 09 	( . 
	inc c			;b7b2	0c 	. 
	inc c			;b7b3	0c 	. 
	ld a,00fh		;b7b4	3e 0f 	> . 
	cp c			;b7b6	b9 	. 
	jr nc,lb759h		;b7b7	30 a0 	0 . 
	ld c,a			;b7b9	4f 	O 
	ret			;b7ba	c9 	. 
lb7bbh:
	ld a,c			;b7bb	79 	y 
	and a			;b7bc	a7 	. 
	ret z			;b7bd	c8 	. 
	dec c			;b7be	0d 	. 
lb7bfh:
	jr lb759h		;b7bf	18 98 	. . 
lb7c1h:
	inc hl			;b7c1	23 	# 
	inc hl			;b7c2	23 	# 
	ld a,0f0h		;b7c3	3e f0 	> . 
	add a,(hl)			;b7c5	86 	. 
	ld (hl),a			;b7c6	77 	w 
	dec hl			;b7c7	2b 	+ 
	jr nz,lb807h		;b7c8	20 3d 	  = 
	ld (ix+000h),000h		;b7ca	dd 36 00 00 	. 6 . . 
	ret			;b7ce	c9 	. 
sub_b7cfh:
	ld a,c			;b7cf	79 	y 
	and a			;b7d0	a7 	. 
	ret z			;b7d1	c8 	. 
	ld hl,0e5e7h		;b7d2	21 e7 e5 	! . . 
	ld a,(hl)			;b7d5	7e 	~ 
	bit 7,a		;b7d6	cb 7f 	.  
	ret z			;b7d8	c8 	. 
	inc hl			;b7d9	23 	# 
	dec (hl)			;b7da	35 	5 
	ret nz			;b7db	c0 	. 
	and 01fh		;b7dc	e6 1f 	. . 
	ld (hl),a			;b7de	77 	w 
	dec c			;b7df	0d 	. 
	jr nz,lb7bfh		;b7e0	20 dd 	  . 
	dec hl			;b7e2	2b 	+ 
	ld (hl),a			;b7e3	77 	w 
	jr lb7bfh		;b7e4	18 d9 	. . 
sub_b7e6h:
	ld a,(de)			;b7e6	1a 	. 
	and a			;b7e7	a7 	. 
	jr z,lb803h		;b7e8	28 19 	( . 
	ld hl,lb4aeh		;b7ea	21 ae b4 	! . . 
	add a,l			;b7ed	85 	. 
	ld l,a			;b7ee	6f 	o 
	ld l,(hl)			;b7ef	6e 	n 
	ex de,hl			;b7f0	eb 	. 
	dec hl			;b7f1	2b 	+ 
	ld a,(de)			;b7f2	1a 	. 
	and 070h		;b7f3	e6 70 	. p 
	ld (hl),a			;b7f5	77 	w 
	dec hl			;b7f6	2b 	+ 
	ld (hl),e			;b7f7	73 	s 
	ld a,(de)			;b7f8	1a 	. 
	bit 7,a		;b7f9	cb 7f 	.  
	jr z,lb806h		;b7fb	28 09 	( . 
	and 00fh		;b7fd	e6 0f 	. . 
	push af			;b7ff	f5 	. 
	call lb807h		;b800	cd 07 b8 	. . . 
lb803h:
	pop af			;b803	f1 	. 
	ld e,a			;b804	5f 	_ 
	ret			;b805	c9 	. 
lb806h:
	pop af			;b806	f1 	. 
lb807h:
	inc (hl)			;b807	34 	4 
	ld e,(hl)			;b808	5e 	^ 
	ld d,0b4h		;b809	16 b4 	. . 
	ld a,(de)			;b80b	1a 	. 
	ld e,a			;b80c	5f 	_ 
	dec hl			;b80d	2b 	+ 
	ld (hl),001h		;b80e	36 01 	6 . 
	and 0c0h		;b810	e6 c0 	. . 
	scf			;b812	37 	7 
	rra			;b813	1f 	. 
	ld d,a			;b814	57 	W 
	cp 0e0h		;b815	fe e0 	. . 
	ld a,e			;b817	7b 	{ 
	jr z,lb824h		;b818	28 0a 	( . 
	and 078h		;b81a	e6 78 	. x 
	rrca			;b81c	0f 	. 
	rrca			;b81d	0f 	. 
	rrca			;b81e	0f 	. 
	inc a			;b81f	3c 	< 
	ld (hl),a			;b820	77 	w 
	ld a,e			;b821	7b 	{ 
	and 007h		;b822	e6 07 	. . 
lb824h:
	and 03fh		;b824	e6 3f 	. ? 
	inc a			;b826	3c 	< 
	dec hl			;b827	2b 	+ 
	ld (hl),a			;b828	77 	w 
	dec hl			;b829	2b 	+ 
	or d			;b82a	b2 	. 
	ld (hl),a			;b82b	77 	w 
lb82ch:
	ret			;b82c	c9 	. 
sub_b82dh:
	ld (ix+00bh),000h		;b82d	dd 36 0b 00 	. 6 . . 
sub_b831h:
	ld a,(0e5cbh)		;b831	3a cb e5 	: . . 
	ld l,a			;b834	6f 	o 
	ld a,(bc)			;b835	0a 	. 
	rrca			;b836	0f 	. 
	ld h,a			;b837	67 	g 
	ld a,e			;b838	7b 	{ 
	jr nc,lb83eh		;b839	30 03 	0 . 
	cpl			;b83b	2f 	/ 
lb83ch:
	and l			;b83c	a5 	. 
	ld l,a			;b83d	6f 	o 
lb83eh:
	or l			;b83e	b5 	. 
	ld l,a			;b83f	6f 	o 
	srl h		;b840	cb 3c 	. < 
	ld a,d			;b842	7a 	z 
	jr nc,lb848h		;b843	30 03 	0 . 
	cpl			;b845	2f 	/ 
	and l			;b846	a5 	. 
	ld l,a			;b847	6f 	o 
lb848h:
	or l			;b848	b5 	. 
	or 080h		;b849	f6 80 	. . 
	ld (0e5cbh),a		;b84b	32 cb e5 	2 . . 
	ld e,010h		;b84e	1e 10 	. . 
	srl h		;b850	cb 3c 	. < 
	ret c			;b852	d8 	. 
	pop af			;b853	f1 	. 
	ret			;b854	c9 	. 
	ld bc,la090h		;b855	01 90 a0 	. . . 
	add a,b			;b858	80 	. 
	nop			;b859	00 	. 
	or b			;b85a	b0 	. 
lb85bh:
	ret nz			;b85b	c0 	. 
	nop			;b85c	00 	. 
	ld a,a			;b85d	7f 	 
	sbc a,a			;b85e	9f 	. 
	xor c			;b85f	a9 	. 
	add a,b			;b860	80 	. 
	ld (hl),e			;b861	73 	s 
	and d			;b862	a2 	. 
	ld (hl),e			;b863	73 	s 
	rst 0			;b864	c7 	. 
	ld bc,la090h		;b865	01 90 a0 	. . . 
	ret nz			;b868	c0 	. 
lb869h:
	nop			;b869	00 	. 
	ld a,a			;b86a	7f 	 
	sbc a,a			;b86b	9f 	. 
lb86ch:
	xor c			;b86c	a9 	. 
	add a,b			;b86d	80 	. 
	ld c,h			;b86e	4c 	L 
lb86fh:
	and d			;b86f	a2 	. 
	ld c,h			;b870	4c 	L 
	rst 0			;b871	c7 	. 
lb872h:
	ld bc,la090h		;b872	01 90 a0 	. . . 
lb875h:
	ret nz			;b875	c0 	. 
	nop			;b876	00 	. 
	ld a,a			;b877	7f 	 
	sbc a,a			;b878	9f 	. 
	xor c			;b879	a9 	. 
	add a,b			;b87a	80 	. 
	dec sp			;b87b	3b 	; 
	and d			;b87c	a2 	. 
	ld bc,0c5c5h		;b87d	01 c5 c5 	. . . 
	ld bc,la090h		;b880	01 90 a0 	. . . 
	ret nz			;b883	c0 	. 
	nop			;b884	00 	. 
	ld bc,0a9a0h		;b885	01 a0 a9 	. . . 
	add a,b			;b888	80 	. 
	ld (hl),e			;b889	73 	s 
	sbc a,(hl)			;b88a	9e 	. 
	ld bc,00090h		;b88b	01 90 00 	. . . 
	inc e			;b88e	1c 	. 
	adc a,c			;b88f	89 	. 
	nop			;b890	00 	. 
	sbc a,a			;b891	9f 	. 
	xor c			;b892	a9 	. 
	and c			;b893	a1 	. 
	ret p			;b894	f0 	. 
	ld bc,l90a0h		;b895	01 a0 90 	. . . 
	nop			;b898	00 	. 
	ccf			;b899	3f 	? 
	xor c			;b89a	a9 	. 
	add a,b			;b89b	80 	. 
	djnz lb83ch		;b89c	10 9e 	. . 
	and c			;b89e	a1 	. 
	or b			;b89f	b0 	. 
	dec d			;b8a0	15 	. 
	and c			;b8a1	a1 	. 
	xor a			;b8a2	af 	. 
	push bc			;b8a3	c5 	. 
	ld bc,0c090h		;b8a4	01 90 c0 	. . . 
	and b			;b8a7	a0 	. 
	nop			;b8a8	00 	. 
	jr lb82ch		;b8a9	18 81 	. . 
	ld b,b			;b8ab	40 	@ 
	sbc a,(hl)			;b8ac	9e 	. 
	xor c			;b8ad	a9 	. 
	and c			;b8ae	a1 	. 
	cp a			;b8af	bf 	. 
	push bc			;b8b0	c5 	. 
	ld bc,l90a0h		;b8b1	01 a0 90 	. . . 
	and b			;b8b4	a0 	. 
	nop			;b8b5	00 	. 
	ld a,a			;b8b6	7f 	 
	xor c			;b8b7	a9 	. 
	add a,b			;b8b8	80 	. 
	ld h,b			;b8b9	60 	` 
	sbc a,a			;b8ba	9f 	. 
	and h			;b8bb	a4 	. 
	jr nc,$-54		;b8bc	30 c8 	0 . 
	ld bc,000a0h		;b8be	01 a0 00 	. . . 
	ex af,af'			;b8c1	08 	. 
	xor c			;b8c2	a9 	. 
	sbc a,(hl)			;b8c3	9e 	. 
	add a,b			;b8c4	80 	. 
	ld d,b			;b8c5	50 	P 
	rst 0			;b8c6	c7 	. 
	and c			;b8c7	a1 	. 
	or b			;b8c8	b0 	. 
lb8c9h:
	ex af,af'			;b8c9	08 	. 
	add a,b			;b8ca	80 	. 
	ld d,b			;b8cb	50 	P 
	ex af,af'			;b8cc	08 	. 
	add a,b			;b8cd	80 	. 
	ld d,b			;b8ce	50 	P 
	ex af,af'			;b8cf	08 	. 
lb8d0h:
	add a,b			;b8d0	80 	. 
	ld d,b			;b8d1	50 	P 
	ex af,af'			;b8d2	08 	. 
	add a,b			;b8d3	80 	. 
	ld d,b			;b8d4	50 	P 
	ld bc,l90a0h		;b8d5	01 a0 90 	. . . 
	nop			;b8d8	00 	. 
	djnz lb85bh		;b8d9	10 80 	. . 
	nop			;b8db	00 	. 
	xor c			;b8dc	a9 	. 
	sbc a,a			;b8dd	9f 	. 
	and c			;b8de	a1 	. 
	cp a			;b8df	bf 	. 
	call z,sub_8010h		;b8e0	cc 10 80 	. . . 
	nop			;b8e3	00 	. 
	djnz $-126		;b8e4	10 80 	. . 
	nop			;b8e6	00 	. 
	djnz lb869h		;b8e7	10 80 	. . 
	nop			;b8e9	00 	. 
	djnz lb86ch		;b8ea	10 80 	. . 
	nop			;b8ec	00 	. 
	djnz lb86fh		;b8ed	10 80 	. . 
	nop			;b8ef	00 	. 
	djnz lb872h		;b8f0	10 80 	. . 
	nop			;b8f2	00 	. 
	djnz lb875h		;b8f3	10 80 	. . 
	nop			;b8f5	00 	. 
	ld bc,l90a0h		;b8f6	01 a0 90 	. . . 
	ret nz			;b8f9	c0 	. 
	nop			;b8fa	00 	. 
	ld a,a			;b8fb	7f 	 
	add a,b			;b8fc	80 	. 
	ld b,b			;b8fd	40 	@ 
	xor c			;b8fe	a9 	. 
	sbc a,a			;b8ff	9f 	. 
	and c			;b900	a1 	. 
	jr nc,lb8c9h		;b901	30 c6 	0 . 
	ld bc,l90a0h		;b903	01 a0 90 	. . . 
	ret nz			;b906	c0 	. 
	nop			;b907	00 	. 
	ex af,af'			;b908	08 	. 
	ret nz			;b909	c0 	. 
	sub c			;b90a	91 	. 
	xor c			;b90b	a9 	. 
	add a,b			;b90c	80 	. 
	ld b,b			;b90d	40 	@ 
	and c			;b90e	a1 	. 
	jr nc,lb919h		;b90f	30 08 	0 . 
	sub d			;b911	92 	. 
	ex af,af'			;b912	08 	. 
	sub e			;b913	93 	. 
	ex af,af'			;b914	08 	. 
	sub h			;b915	94 	. 
	ex af,af'			;b916	08 	. 
	sub l			;b917	95 	. 
	ex af,af'			;b918	08 	. 
lb919h:
	sub (hl)			;b919	96 	. 
	ex af,af'			;b91a	08 	. 
	sub a			;b91b	97 	. 
	ex af,af'			;b91c	08 	. 
	sbc a,b			;b91d	98 	. 
	ex af,af'			;b91e	08 	. 
	sbc a,c			;b91f	99 	. 
	ex af,af'			;b920	08 	. 
	sbc a,d			;b921	9a 	. 
	ex af,af'			;b922	08 	. 
	sbc a,e			;b923	9b 	. 
	ex af,af'			;b924	08 	. 
	sbc a,h			;b925	9c 	. 
	ex af,af'			;b926	08 	. 
	sbc a,l			;b927	9d 	. 
	ex af,af'			;b928	08 	. 
	sbc a,(hl)			;b929	9e 	. 
	ex af,af'			;b92a	08 	. 
	sbc a,a			;b92b	9f 	. 
	ld a,a			;b92c	7f 	 
	ld a,a			;b92d	7f 	 
	rst 8			;b92e	cf 	. 
	ld a,a			;b92f	7f 	 
	ld bc,la0c0h		;b930	01 c0 a0 	. . . 
	sub b			;b933	90 	. 
	nop			;b934	00 	. 
	inc e			;b935	1c 	. 
	adc a,b			;b936	88 	. 
	ret p			;b937	f0 	. 
	sbc a,a			;b938	9f 	. 
	xor c			;b939	a9 	. 
	and c			;b93a	a1 	. 
	ret p			;b93b	f0 	. 
	ld bc,l90a0h		;b93c	01 a0 90 	. . . 
	nop			;b93f	00 	. 
	ccf			;b940	3f 	? 
	xor c			;b941	a9 	. 
	add a,b			;b942	80 	. 
	inc de			;b943	13 	. 
	sbc a,(hl)			;b944	9e 	. 
	and c			;b945	a1 	. 
	or b			;b946	b0 	. 
	dec d			;b947	15 	. 
	and c			;b948	a1 	. 
	ret p			;b949	f0 	. 
	ld bc,la090h		;b94a	01 90 a0 	. . . 
	nop			;b94d	00 	. 
	jr lb8d0h		;b94e	18 80 	. . 
	ld b,c			;b950	41 	A 
	sbc a,l			;b951	9d 	. 
	xor c			;b952	a9 	. 
	and c			;b953	a1 	. 
	cp a			;b954	bf 	. 
	ld bc,l90a0h		;b955	01 a0 90 	. . . 
	and b			;b958	a0 	. 
	nop			;b959	00 	. 
	nop			;b95a	00 	. 
	nop			;b95b	00 	. 
	nop			;b95c	00 	. 
	nop			;b95d	00 	. 
	ld b,0a9h		;b95e	06 a9 	. . 
	ld sp,hl			;b960	f9 	. 
	add a,e			;b961	83 	. 
	ld d,a			;b962	57 	W 
	pop de			;b963	d1 	. 
	xor h			;b964	ac 	. 
	pop af			;b965	f1 	. 
	sbc a,(hl)			;b966	9e 	. 
	dec b			;b967	05 	. 
	xor b			;b968	a8 	. 
	ld bc,005f8h		;b969	01 f8 05 	. . . 
	ld sp,hl			;b96c	f9 	. 
	pop de			;b96d	d1 	. 
	xor h			;b96e	ac 	. 
	pop af			;b96f	f1 	. 
	ld bc,009f8h		;b970	01 f8 09 	. . . 
	xor c			;b973	a9 	. 
	ld sp,hl			;b974	f9 	. 
	sbc a,(hl)			;b975	9e 	. 
	add a,h			;b976	84 	. 
	ld (hl),l			;b977	75 	u 
	pop de			;b978	d1 	. 
	dec e			;b979	1d 	. 
	pop af			;b97a	f1 	. 
	ex af,af'			;b97b	08 	. 
	xor b			;b97c	a8 	. 
	ld bc,009f8h		;b97d	01 f8 09 	. . . 
	xor c			;b980	a9 	. 
	add a,e			;b981	83 	. 
	ld d,a			;b982	57 	W 
	sbc a,(hl)			;b983	9e 	. 
	add hl,bc			;b984	09 	. 
	xor b			;b985	a8 	. 
	ld b,0a9h		;b986	06 a9 	. . 
	ld sp,hl			;b988	f9 	. 
	add a,h			;b989	84 	. 
	ld (hl),l			;b98a	75 	u 
	pop de			;b98b	d1 	. 
	ld l,0f1h		;b98c	2e f1 	. . 
	sbc a,(hl)			;b98e	9e 	. 
	ld b,0d1h		;b98f	06 d1 	. . 
	dec e			;b991	1d 	. 
	pop af			;b992	f1 	. 
	xor b			;b993	a8 	. 
	ld b,0d0h		;b994	06 d0 	. . 
	cp 009h		;b996	fe 09 	. . 
	xor c			;b998	a9 	. 
	add a,e			;b999	83 	. 
	ld d,a			;b99a	57 	W 
	sbc a,(hl)			;b99b	9e 	. 
	pop de			;b99c	d1 	. 
	dec e			;b99d	1d 	. 
	add hl,bc			;b99e	09 	. 
	xor b			;b99f	a8 	. 
	add hl,bc			;b9a0	09 	. 
	xor c			;b9a1	a9 	. 
	sbc a,(hl)			;b9a2	9e 	. 
	add a,h			;b9a3	84 	. 
	ld (hl),l			;b9a4	75 	u 
	add hl,bc			;b9a5	09 	. 
	xor b			;b9a6	a8 	. 
	ret m			;b9a7	f8 	. 
	ld b,0a9h		;b9a8	06 a9 	. . 
	sbc a,(hl)			;b9aa	9e 	. 
	add a,e			;b9ab	83 	. 
	ld d,a			;b9ac	57 	W 
	inc bc			;b9ad	03 	. 
	xor b			;b9ae	a8 	. 
	ld b,0a9h		;b9af	06 a9 	. . 
	sbc a,(hl)			;b9b1	9e 	. 
	add a,h			;b9b2	84 	. 
	ld (hl),l			;b9b3	75 	u 
	inc bc			;b9b4	03 	. 
	xor b			;b9b5	a8 	. 
	ld b,0a9h		;b9b6	06 a9 	. . 
	sbc a,(hl)			;b9b8	9e 	. 
	add a,e			;b9b9	83 	. 
	ld sp,hl			;b9ba	f9 	. 
	inc bc			;b9bb	03 	. 
	xor b			;b9bc	a8 	. 
	ld b,0a9h		;b9bd	06 a9 	. . 
	sbc a,(hl)			;b9bf	9e 	. 
	add a,e			;b9c0	83 	. 
	adc a,d			;b9c1	8a 	. 
	inc bc			;b9c2	03 	. 
	xor b			;b9c3	a8 	. 
	ld b,0f9h		;b9c4	06 f9 	. . 
	xor c			;b9c6	a9 	. 
	pop af			;b9c7	f1 	. 
	sbc a,(hl)			;b9c8	9e 	. 
	add a,e			;b9c9	83 	. 
	ld d,a			;b9ca	57 	W 
	pop de			;b9cb	d1 	. 
	xor h			;b9cc	ac 	. 
	dec b			;b9cd	05 	. 
	xor b			;b9ce	a8 	. 
	ld bc,006f8h		;b9cf	01 f8 06 	. . . 
	ld sp,hl			;b9d2	f9 	. 
	pop af			;b9d3	f1 	. 
	pop de			;b9d4	d1 	. 
	xor h			;b9d5	ac 	. 
	add hl,bc			;b9d6	09 	. 
	xor c			;b9d7	a9 	. 
	ld sp,hl			;b9d8	f9 	. 
	sbc a,(hl)			;b9d9	9e 	. 
	pop af			;b9da	f1 	. 
	add a,h			;b9db	84 	. 
	ld (hl),l			;b9dc	75 	u 
	pop de			;b9dd	d1 	. 
	dec e			;b9de	1d 	. 
	ex af,af'			;b9df	08 	. 
	xor b			;b9e0	a8 	. 
	ld bc,009f8h		;b9e1	01 f8 09 	. . . 
	xor c			;b9e4	a9 	. 
	sbc a,(hl)			;b9e5	9e 	. 
	add a,e			;b9e6	83 	. 
	ld d,a			;b9e7	57 	W 
	add hl,bc			;b9e8	09 	. 
	xor b			;b9e9	a8 	. 
	inc b			;b9ea	04 	. 
	xor c			;b9eb	a9 	. 
	ld sp,hl			;b9ec	f9 	. 
	sbc a,(hl)			;b9ed	9e 	. 
	pop af			;b9ee	f1 	. 
	add a,h			;b9ef	84 	. 
	ld (hl),l			;b9f0	75 	u 
	ret nc			;b9f1	d0 	. 
	cp 005h		;b9f2	fe 05 	. . 
	pop de			;b9f4	d1 	. 
	dec e			;b9f5	1d 	. 
	inc b			;b9f6	04 	. 
	xor b			;b9f7	a8 	. 
	pop de			;b9f8	d1 	. 
	ld l,005h		;b9f9	2e 05 	. . 
	ret nc			;b9fb	d0 	. 
	cp 01ch		;b9fc	fe 1c 	. . 
	xor c			;b9fe	a9 	. 
	sbc a,(hl)			;b9ff	9e 	. 
lba00h:
	add a,e			;ba00	83 	. 
	ld d,a			;ba01	57 	W 
	pop de			;ba02	d1 	. 
	dec e			;ba03	1d 	. 
	ld bc,00197h		;ba04	01 97 01 	. . . 
	sub (hl)			;ba07	96 	. 
	ld bc,00195h		;ba08	01 95 01 	. . . 
	sub h			;ba0b	94 	. 
	ld bc,00193h		;ba0c	01 93 01 	. . . 
	sub d			;ba0f	92 	. 
	ld bc,l90a8h		;ba10	01 a8 90 	. . . 
	ret m			;ba13	f8 	. 
	ret po			;ba14	e0 	. 
	nop			;ba15	00 	. 
	dec bc			;ba16	0b 	. 
	xor c			;ba17	a9 	. 
	or c			;ba18	b1 	. 
	add a,d			;ba19	82 	. 
	dec sp			;ba1a	3b 	; 
	ld bc,005a8h		;ba1b	01 a8 05 	. . . 
	xor c			;ba1e	a9 	. 
	or c			;ba1f	b1 	. 
	add a,d			;ba20	82 	. 
	dec sp			;ba21	3b 	; 
	ld bc,012a8h		;ba22	01 a8 12 	. . . 
	xor c			;ba25	a9 	. 
	or c			;ba26	b1 	. 
	add a,c			;ba27	81 	. 
	xor h			;ba28	ac 	. 
	ld (de),a			;ba29	12 	. 
	xor b			;ba2a	a8 	. 
	ld b,0a9h		;ba2b	06 a9 	. . 
	or c			;ba2d	b1 	. 
	add a,c			;ba2e	81 	. 
	ld l,b			;ba2f	68 	h 
	ld b,081h		;ba30	06 81 	. . 
	ld d,b			;ba32	50 	P 
	ld b,081h		;ba33	06 81 	. . 
	ld b,b			;ba35	40 	@ 
	ld (de),a			;ba36	12 	. 
	add a,c			;ba37	81 	. 
	ld d,b			;ba38	50 	P 
	ld (de),a			;ba39	12 	. 
	xor b			;ba3a	a8 	. 
	inc h			;ba3b	24 	$ 
	dec bc			;ba3c	0b 	. 
	xor c			;ba3d	a9 	. 
	or c			;ba3e	b1 	. 
	add a,d			;ba3f	82 	. 
	dec sp			;ba40	3b 	; 
	ld bc,005a8h		;ba41	01 a8 05 	. . . 
	xor c			;ba44	a9 	. 
	or c			;ba45	b1 	. 
	add a,d			;ba46	82 	. 
	dec sp			;ba47	3b 	; 
	ld bc,012a8h		;ba48	01 a8 12 	. . . 
	xor c			;ba4b	a9 	. 
	or c			;ba4c	b1 	. 
	add a,c			;ba4d	81 	. 
	xor h			;ba4e	ac 	. 
	ld (de),a			;ba4f	12 	. 
	xor b			;ba50	a8 	. 
	inc b			;ba51	04 	. 
	xor c			;ba52	a9 	. 
	or c			;ba53	b1 	. 
	add a,c			;ba54	81 	. 
	ld b,b			;ba55	40 	@ 
	dec b			;ba56	05 	. 
	add a,c			;ba57	81 	. 
	ld d,b			;ba58	50 	P 
	inc b			;ba59	04 	. 
	add a,c			;ba5a	81 	. 
	ld l,b			;ba5b	68 	h 
	dec b			;ba5c	05 	. 
	add a,c			;ba5d	81 	. 
	ld b,b			;ba5e	40 	@ 
	inc e			;ba5f	1c 	. 
	or c			;ba60	b1 	. 
	add a,c			;ba61	81 	. 
	ld d,b			;ba62	50 	P 
	rlca			;ba63	07 	. 
	xor b			;ba64	a8 	. 
	ld bc,000a8h		;ba65	01 a8 00 	. . . 
	inc c			;ba68	0c 	. 
	xor c			;ba69	a9 	. 
	add a,c			;ba6a	81 	. 
	dec e			;ba6b	1d 	. 
	or c			;ba6c	b1 	. 
	ld b,081h		;ba6d	06 81 	. . 
	dec e			;ba6f	1d 	. 
	ld d,080h		;ba70	16 80 	. . 
	ret p			;ba72	f0 	. 
	ld c,0a8h		;ba73	0e a8 	. . 
	add hl,bc			;ba75	09 	. 
	xor c			;ba76	a9 	. 
	or c			;ba77	b1 	. 
	add a,b			;ba78	80 	. 
	cp 009h		;ba79	fe 09 	. . 
	add a,c			;ba7b	81 	. 
	dec e			;ba7c	1d 	. 
	add hl,bc			;ba7d	09 	. 
	add a,c			;ba7e	81 	. 
	ld b,b			;ba7f	40 	@ 
	add hl,bc			;ba80	09 	. 
	add a,b			;ba81	80 	. 
	cp 018h		;ba82	fe 18 	. . 
	add a,c			;ba84	81 	. 
	dec e			;ba85	1d 	. 
	ld e,0a9h		;ba86	1e a9 	. . 
	ld bc,000a8h		;ba88	01 a8 00 	. . . 
	inc c			;ba8b	0c 	. 
	ld sp,hl			;ba8c	f9 	. 
	pop af			;ba8d	f1 	. 
	pop de			;ba8e	d1 	. 
	ld a,(de)			;ba8f	1a 	. 
	ld b,0d1h		;ba90	06 d1 	. . 
	ld a,(de)			;ba92	1a 	. 
	dec b			;ba93	05 	. 
	xor c			;ba94	a9 	. 
	ld sp,hl			;ba95	f9 	. 
	pop af			;ba96	f1 	. 
	sbc a,(hl)			;ba97	9e 	. 
	add a,d			;ba98	82 	. 
	rst 8			;ba99	cf 	. 
	ret nc			;ba9a	d0 	. 
	xor 001h		;ba9b	ee 01 	. . 
	xor b			;ba9d	a8 	. 
	dec b			;ba9e	05 	. 
	xor c			;ba9f	a9 	. 
	sbc a,(hl)			;baa0	9e 	. 
	add a,d			;baa1	82 	. 
	rst 8			;baa2	cf 	. 
	ld bc,005a8h		;baa3	01 a8 05 	. . . 
	xor c			;baa6	a9 	. 
	sbc a,(hl)			;baa7	9e 	. 
	add a,d			;baa8	82 	. 
	rst 8			;baa9	cf 	. 
	ld bc,0f9a8h		;baaa	01 a8 f9 	. . . 
	inc c			;baad	0c 	. 
lbaaeh:
	xor c			;baae	a9 	. 
	sbc a,(hl)			;baaf	9e 	. 
	add a,d			;bab0	82 	. 
	rst 8			;bab1	cf 	. 
lbab2h:
	ld b,0a8h		;bab2	06 a8 	. . 
	ret m			;bab4	f8 	. 
	ret m			;bab5	f8 	. 
	add hl,bc			;bab6	09 	. 
	xor c			;bab7	a9 	. 
	ld sp,hl			;bab8	f9 	. 
	pop af			;bab9	f1 	. 
	sbc a,(hl)			;baba	9e 	. 
	add a,d			;babb	82 	. 
	add a,c			;babc	81 	. 
	ret nc			;babd	d0 	. 
	call m,0a809h		;babe	fc 09 a8 	. . . 
	pop de			;bac1	d1 	. 
	dec de			;bac2	1b 	. 
	add hl,bc			;bac3	09 	. 
	xor c			;bac4	a9 	. 
	sbc a,(hl)			;bac5	9e 	. 
	add a,c			;bac6	81 	. 
	call m,040d1h		;bac7	fc d1 40 	. . @ 
	add hl,bc			;baca	09 	. 
	xor b			;bacb	a8 	. 
	ret nc			;bacc	d0 	. 
	call m,0a908h		;bacd	fc 08 a9 	. . . 
	sbc a,(hl)			;bad0	9e 	. 
	add a,e			;bad1	83 	. 
	ld d,a			;bad2	57 	W 
	pop de			;bad3	d1 	. 
	ld a,(de)			;bad4	1a 	. 
	ld bc,008a8h		;bad5	01 a8 08 	. . . 
	xor c			;bad8	a9 	. 
	sbc a,(hl)			;bad9	9e 	. 
	add a,h			;bada	84 	. 
	ld (hl),l			;badb	75 	u 
lbadch:
	ld bc,008a8h		;badc	01 a8 08 	. . . 
	xor c			;badf	a9 	. 
	sbc a,(hl)			;bae0	9e 	. 
	add a,e			;bae1	83 	. 
	ld d,a			;bae2	57 	W 
	ld bc,008a8h		;bae3	01 a8 08 	. . . 
	xor c			;bae6	a9 	. 
	sbc a,(hl)			;bae7	9e 	. 
	add a,h			;bae8	84 	. 
	ld (hl),l			;bae9	75 	u 
	ld bc,0f9a8h		;baea	01 a8 f9 	. . . 
	ld de,083a9h		;baed	11 a9 83 	. . . 
	ld d,a			;baf0	57 	W 
	ld bc,0f8a8h		;baf1	01 a8 f8 	. . . 
	nop			;baf4	00 	. 
	dec d			;baf5	15 	. 
	xor l			;baf6	ad 	. 
	or c			;baf7	b1 	. 
	add a,c			;baf8	81 	. 
	dec e			;baf9	1d 	. 
	dec d			;bafa	15 	. 
lbafbh:
	add a,b			;bafb	80 	. 
	sub a			;bafc	97 	. 
	dec c			;bafd	0d 	. 
	add a,b			;bafe	80 	. 
	ld e,a			;baff	5f 	_ 
lbb00h:
	ld bc,000a8h		;bb00	01 a8 00 	. . . 
	rlca			;bb03	07 	. 
	xor b			;bb04	a8 	. 
	ret m			;bb05	f8 	. 
	sub b			;bb06	90 	. 
	ret po			;bb07	e0 	. 
	rlca			;bb08	07 	. 
	xor c			;bb09	a9 	. 
	sbc a,(hl)			;bb0a	9e 	. 
	add a,b			;bb0b	80 	. 
	jp z,0f907h		;bb0c	ca 07 f9 	. . . 
	pop af			;bb0f	f1 	. 
	ret nc			;bb10	d0 	. 
	cp (hl)			;bb11	be 	. 
	rlca			;bb12	07 	. 
	xor b			;bb13	a8 	. 
	rlca			;bb14	07 	. 
	xor c			;bb15	a9 	. 
	sbc a,(hl)			;bb16	9e 	. 
	add a,b			;bb17	80 	. 
	adc a,a			;bb18	8f 	. 
	xor 007h		;bb19	ee 07 	. . 
	ld sp,hl			;bb1b	f9 	. 
	xor 0d0h		;bb1c	ee d0 	. . 
	ld (hl),c			;bb1e	71 	q 
	rlca			;bb1f	07 	. 
	rlca			;bb20	07 	. 
	xor b			;bb21	a8 	. 
	ret m			;bb22	f8 	. 
	nop			;bb23	00 	. 
	jr $-85		;bb24	18 a9 	. . 
	or c			;bb26	b1 	. 
	add a,b			;bb27	80 	. 
	ld a,b			;bb28	78 	x 
	jr $-126		;bb29	18 80 	. . 
	cp (hl)			;bb2b	be 	. 
	jr lbaaeh		;bb2c	18 80 	. . 
lbb2eh:
	cp (hl)			;bb2e	be 	. 
	jr lbab2h		;bb2f	18 81 	. . 
	dec e			;bb31	1d 	. 
	jr nz,lbadch		;bb32	20 a8 	  . 
	nop			;bb34	00 	. 
	ex af,af'			;bb35	08 	. 
	xor b			;bb36	a8 	. 
	ret m			;bb37	f8 	. 
	ex af,af'			;bb38	08 	. 
	xor c			;bb39	a9 	. 
	sbc a,(hl)			;bb3a	9e 	. 
lbb3bh:
	add a,b			;bb3b	80 	. 
	sub a			;bb3c	97 	. 
	ex af,af'			;bb3d	08 	. 
	ld sp,hl			;bb3e	f9 	. 
	pop af			;bb3f	f1 	. 
	ret nc			;bb40	d0 	. 
	adc a,a			;bb41	8f 	. 
	ex af,af'			;bb42	08 	. 
	xor b			;bb43	a8 	. 
lbb44h:
	ex af,af'			;bb44	08 	. 
	ld sp,hl			;bb45	f9 	. 
lbb46h:
	pop af			;bb46	f1 	. 
	ret nc			;bb47	d0 	. 
	and b			;bb48	a0 	. 
lbb49h:
	ex af,af'			;bb49	08 	. 
lbb4ah:
	xor c			;bb4a	a9 	. 
	add a,b			;bb4b	80 	. 
lbb4ch:
	jp z,0a808h		;bb4c	ca 08 a8 	. . . 
	xor b			;bb4f	a8 	. 
	ex af,af'			;bb50	08 	. 
	ld sp,hl			;bb51	f9 	. 
	pop af			;bb52	f1 	. 
	ret nc			;bb53	d0 	. 
	ret p			;bb54	f0 	. 
	ld b,0a9h		;bb55	06 a9 	. . 
	sbc a,(hl)			;bb57	9e 	. 
	ld sp,hl			;bb58	f9 	. 
	pop af			;bb59	f1 	. 
	add a,c			;bb5a	81 	. 
	dec e			;bb5b	1d 	. 
	pop de			;bb5c	d1 	. 
	inc e			;bb5d	1c 	. 
	ld (bc),a			;bb5e	02 	. 
lbb5fh:
	xor b			;bb5f	a8 	. 
	ret m			;bb60	f8 	. 
	ld b,0a9h		;bb61	06 a9 	. . 
	sbc a,(hl)			;bb63	9e 	. 
	ld sp,hl			;bb64	f9 	. 
	add a,c			;bb65	81 	. 
	dec e			;bb66	1d 	. 
	pop de			;bb67	d1 	. 
	inc e			;bb68	1c 	. 
	ld (bc),a			;bb69	02 	. 
	xor b			;bb6a	a8 	. 
	ret m			;bb6b	f8 	. 
	ld b,0a9h		;bb6c	06 a9 	. . 
	ld sp,hl			;bb6e	f9 	. 
	sbc a,(hl)			;bb6f	9e 	. 
	add a,c			;bb70	81 	. 
	dec e			;bb71	1d 	. 
	pop de			;bb72	d1 	. 
	inc e			;bb73	1c 	. 
	ld (bc),a			;bb74	02 	. 
	xor b			;bb75	a8 	. 
	ret m			;bb76	f8 	. 
	ld b,0a9h		;bb77	06 a9 	. . 
	ld sp,hl			;bb79	f9 	. 
	sbc a,(hl)			;bb7a	9e 	. 
	add a,c			;bb7b	81 	. 
	dec e			;bb7c	1d 	. 
	pop de			;bb7d	d1 	. 
	inc e			;bb7e	1c 	. 
	ld (bc),a			;bb7f	02 	. 
	xor b			;bb80	a8 	. 
	ret m			;bb81	f8 	. 
	nop			;bb82	00 	. 
	djnz lbb2eh		;bb83	10 a9 	. . 
	sbc a,l			;bb85	9d 	. 
	add a,b			;bb86	80 	. 
lbb87h:
	adc a,(hl)			;bb87	8e 	. 
	ex af,af'			;bb88	08 	. 
	add a,b			;bb89	80 	. 
	ld a,(hl)			;bb8a	7e 	~ 
	ex af,af'			;bb8b	08 	. 
	add a,b			;bb8c	80 	. 
	ld (hl),a			;bb8d	77 	w 
	ex af,af'			;bb8e	08 	. 
	add a,b			;bb8f	80 	. 
lbb90h:
	ld a,(hl)			;bb90	7e 	~ 
	ex af,af'			;bb91	08 	. 
	sub b			;bb92	90 	. 
	ex af,af'			;bb93	08 	. 
	sbc a,l			;bb94	9d 	. 
	add a,b			;bb95	80 	. 
	adc a,(hl)			;bb96	8e 	. 
	ex af,af'			;bb97	08 	. 
	sub b			;bb98	90 	. 
	ex af,af'			;bb99	08 	. 
	sbc a,l			;bb9a	9d 	. 
	add a,b			;bb9b	80 	. 
	ld a,(hl)			;bb9c	7e 	~ 
	ex af,af'			;bb9d	08 	. 
	sub b			;bb9e	90 	. 
	ex af,af'			;bb9f	08 	. 
	sbc a,l			;bba0	9d 	. 
	add a,b			;bba1	80 	. 
lbba2h:
	ld e,(hl)			;bba2	5e 	^ 
	ex af,af'			;bba3	08 	. 
	sub b			;bba4	90 	. 
	djnz lbb44h		;bba5	10 9d 	. . 
	add a,b			;bba7	80 	. 
	ld a,(hl)			;bba8	7e 	~ 
	djnz lbb3bh		;bba9	10 90 	. . 
	djnz lbb4ah		;bbab	10 9d 	. . 
	add a,b			;bbad	80 	. 
	adc a,(hl)			;bbae	8e 	. 
lbbafh:
	ex af,af'			;bbaf	08 	. 
	add a,b			;bbb0	80 	. 
	ld a,(hl)			;bbb1	7e 	~ 
	ex af,af'			;bbb2	08 	. 
	add a,b			;bbb3	80 	. 
	ld (hl),a			;bbb4	77 	w 
	ex af,af'			;bbb5	08 	. 
	add a,b			;bbb6	80 	. 
	ld a,(hl)			;bbb7	7e 	~ 
lbbb8h:
	ex af,af'			;bbb8	08 	. 
	sub b			;bbb9	90 	. 
	ex af,af'			;bbba	08 	. 
	sbc a,l			;bbbb	9d 	. 
	add a,b			;bbbc	80 	. 
	adc a,(hl)			;bbbd	8e 	. 
	ex af,af'			;bbbe	08 	. 
	sub b			;bbbf	90 	. 
	djnz lbb5fh		;bbc0	10 9d 	. . 
	add a,b			;bbc2	80 	. 
	adc a,(hl)			;bbc3	8e 	. 
	djnz lbb46h		;bbc4	10 80 	. . 
	sub (hl)			;bbc6	96 	. 
	djnz lbb49h		;bbc7	10 80 	. . 
	adc a,(hl)			;bbc9	8e 	. 
	djnz lbb4ch		;bbca	10 80 	. . 
	ld a,(hl)			;bbcc	7e 	~ 
	ld bc,01090h		;bbcd	01 90 10 	. . . 
	xor c			;bbd0	a9 	. 
	sbc a,l			;bbd1	9d 	. 
lbbd2h:
	add a,b			;bbd2	80 	. 
	adc a,(hl)			;bbd3	8e 	. 
	ex af,af'			;bbd4	08 	. 
	add a,b			;bbd5	80 	. 
	ld a,(hl)			;bbd6	7e 	~ 
	ex af,af'			;bbd7	08 	. 
	add a,b			;bbd8	80 	. 
	ld (hl),a			;bbd9	77 	w 
	ex af,af'			;bbda	08 	. 
	add a,b			;bbdb	80 	. 
	ld a,(hl)			;bbdc	7e 	~ 
	ex af,af'			;bbdd	08 	. 
	sub b			;bbde	90 	. 
	ex af,af'			;bbdf	08 	. 
	sbc a,l			;bbe0	9d 	. 
	add a,b			;bbe1	80 	. 
	adc a,(hl)			;bbe2	8e 	. 
	ex af,af'			;bbe3	08 	. 
	sub b			;bbe4	90 	. 
	ex af,af'			;bbe5	08 	. 
	sbc a,l			;bbe6	9d 	. 
	add a,b			;bbe7	80 	. 
	ld a,(hl)			;bbe8	7e 	~ 
	ex af,af'			;bbe9	08 	. 
	sub b			;bbea	90 	. 
	ex af,af'			;bbeb	08 	. 
	sbc a,l			;bbec	9d 	. 
	add a,b			;bbed	80 	. 
	ld e,(hl)			;bbee	5e 	^ 
	ex af,af'			;bbef	08 	. 
	sub b			;bbf0	90 	. 
	djnz lbb90h		;bbf1	10 9d 	. . 
	add a,b			;bbf3	80 	. 
	ld a,(hl)			;bbf4	7e 	~ 
	djnz lbb87h		;bbf5	10 90 	. . 
	djnz lbba2h		;bbf7	10 a9 	. . 
	sbc a,l			;bbf9	9d 	. 
	add a,b			;bbfa	80 	. 
	ld (hl),a			;bbfb	77 	w 
	ex af,af'			;bbfc	08 	. 
	add a,b			;bbfd	80 	. 
	ld l,d			;bbfe	6a 	j 
	ex af,af'			;bbff	08 	. 
	add a,b			;bc00	80 	. 
	ld e,(hl)			;bc01	5e 	^ 
	ex af,af'			;bc02	08 	. 
	add a,b			;bc03	80 	. 
	ld l,d			;bc04	6a 	j 
	ex af,af'			;bc05	08 	. 
	sub b			;bc06	90 	. 
	ex af,af'			;bc07	08 	. 
	sbc a,l			;bc08	9d 	. 
	add a,b			;bc09	80 	. 
	ld (hl),a			;bc0a	77 	w 
	ex af,af'			;bc0b	08 	. 
lbc0ch:
	sub b			;bc0c	90 	. 
	ex af,af'			;bc0d	08 	. 
	sbc a,l			;bc0e	9d 	. 
	add a,b			;bc0f	80 	. 
	ld l,d			;bc10	6a 	j 
	ex af,af'			;bc11	08 	. 
	sub b			;bc12	90 	. 
	ex af,af'			;bc13	08 	. 
	sbc a,l			;bc14	9d 	. 
	add a,b			;bc15	80 	. 
	ld c,a			;bc16	4f 	O 
	ex af,af'			;bc17	08 	. 
	sub b			;bc18	90 	. 
	djnz lbbb8h		;bc19	10 9d 	. . 
	add a,b			;bc1b	80 	. 
	ld l,d			;bc1c	6a 	j 
	djnz lbbafh		;bc1d	10 90 	. . 
	inc b			;bc1f	04 	. 
	sbc a,e			;bc20	9b 	. 
	add a,b			;bc21	80 	. 
	ccf			;bc22	3f 	? 
	inc b			;bc23	04 	. 
	sub b			;bc24	90 	. 
	inc b			;bc25	04 	. 
	sbc a,e			;bc26	9b 	. 
	add a,b			;bc27	80 	. 
	ccf			;bc28	3f 	? 
	inc d			;bc29	14 	. 
	sub b			;bc2a	90 	. 
	inc b			;bc2b	04 	. 
	sbc a,e			;bc2c	9b 	. 
	add a,b			;bc2d	80 	. 
	ccf			;bc2e	3f 	? 
	inc b			;bc2f	04 	. 
	sub b			;bc30	90 	. 
	inc b			;bc31	04 	. 
	sbc a,e			;bc32	9b 	. 
	add a,b			;bc33	80 	. 
	ccf			;bc34	3f 	? 
	inc d			;bc35	14 	. 
	sub b			;bc36	90 	. 
	inc b			;bc37	04 	. 
	sbc a,e			;bc38	9b 	. 
	add a,b			;bc39	80 	. 
	ccf			;bc3a	3f 	? 
	inc b			;bc3b	04 	. 
	sub b			;bc3c	90 	. 
	inc b			;bc3d	04 	. 
	sbc a,e			;bc3e	9b 	. 
	add a,b			;bc3f	80 	. 
	ccf			;bc40	3f 	? 
	inc d			;bc41	14 	. 
	sub b			;bc42	90 	. 
	ex af,af'			;bc43	08 	. 
	sbc a,l			;bc44	9d 	. 
	add a,b			;bc45	80 	. 
	ccf			;bc46	3f 	? 
	ex af,af'			;bc47	08 	. 
	add a,b			;bc48	80 	. 
	ld b,(hl)			;bc49	46 	F 
	ex af,af'			;bc4a	08 	. 
	add a,b			;bc4b	80 	. 
	ld c,a			;bc4c	4f 	O 
	ex af,af'			;bc4d	08 	. 
	add a,b			;bc4e	80 	. 
	ld l,d			;bc4f	6a 	j 
	jr nz,lbbd2h		;bc50	20 80 	  . 
	ld e,(hl)			;bc52	5e 	^ 
	jr nz,lbc75h		;bc53	20 20 	    
	xor b			;bc55	a8 	. 
	sub b			;bc56	90 	. 
	jr nz,lbc5dh		;bc57	20 04 	  . 
	xor c			;bc59	a9 	. 
	sbc a,l			;bc5a	9d 	. 
	add a,b			;bc5b	80 	. 
	ccf			;bc5c	3f 	? 
lbc5dh:
	inc b			;bc5d	04 	. 
	sub b			;bc5e	90 	. 
	inc b			;bc5f	04 	. 
	sbc a,e			;bc60	9b 	. 
	add a,b			;bc61	80 	. 
	ccf			;bc62	3f 	? 
	inc d			;bc63	14 	. 
	sub b			;bc64	90 	. 
	inc b			;bc65	04 	. 
	sbc a,e			;bc66	9b 	. 
	add a,b			;bc67	80 	. 
	ccf			;bc68	3f 	? 
	inc b			;bc69	04 	. 
	sub b			;bc6a	90 	. 
	inc b			;bc6b	04 	. 
	sbc a,e			;bc6c	9b 	. 
	add a,b			;bc6d	80 	. 
	ccf			;bc6e	3f 	? 
	inc d			;bc6f	14 	. 
	sub b			;bc70	90 	. 
	inc b			;bc71	04 	. 
	sbc a,e			;bc72	9b 	. 
	add a,b			;bc73	80 	. 
	ccf			;bc74	3f 	? 
lbc75h:
	inc b			;bc75	04 	. 
	sub b			;bc76	90 	. 
	inc b			;bc77	04 	. 
	sbc a,e			;bc78	9b 	. 
	add a,b			;bc79	80 	. 
	ccf			;bc7a	3f 	? 
	inc d			;bc7b	14 	. 
	sub b			;bc7c	90 	. 
	ex af,af'			;bc7d	08 	. 
	sbc a,l			;bc7e	9d 	. 
	add a,b			;bc7f	80 	. 
	ccf			;bc80	3f 	? 
	ex af,af'			;bc81	08 	. 
	add a,b			;bc82	80 	. 
	ld b,(hl)			;bc83	46 	F 
	ex af,af'			;bc84	08 	. 
	add a,b			;bc85	80 	. 
	ld c,a			;bc86	4f 	O 
	ex af,af'			;bc87	08 	. 
	add a,b			;bc88	80 	. 
	ld l,d			;bc89	6a 	j 
	jr nz,lbc0ch		;bc8a	20 80 	  . 
	ld e,(hl)			;bc8c	5e 	^ 
	jr nz,lbcafh		;bc8d	20 20 	    
	xor b			;bc8f	a8 	. 
	sub b			;bc90	90 	. 
	rra			;bc91	1f 	. 
	nop			;bc92	00 	. 
	ex af,af'			;bc93	08 	. 
	xor c			;bc94	a9 	. 
	ld sp,hl			;bc95	f9 	. 
	sbc a,l			;bc96	9d 	. 
	pop af			;bc97	f1 	. 
	add a,b			;bc98	80 	. 
	adc a,a			;bc99	8f 	. 
	call nc,00875h		;bc9a	d4 75 08 	. u . 
	call nc,00875h		;bc9d	d4 75 08 	. u . 
	add a,b			;bca0	80 	. 
	ld a,a			;bca1	7f 	 
	jp nc,0083bh		;bca2	d2 3b 08 	. ; . 
	add a,b			;bca5	80 	. 
	ld a,b			;bca6	78 	x 
	jp nc,0083bh		;bca7	d2 3b 08 	. ; . 
	add a,b			;bcaa	80 	. 
	ld a,a			;bcab	7f 	 
	call nc,00875h		;bcac	d4 75 08 	. u . 
lbcafh:
	sub b			;bcaf	90 	. 
	call nc,00875h		;bcb0	d4 75 08 	. u . 
	sbc a,l			;bcb3	9d 	. 
	add a,b			;bcb4	80 	. 
	adc a,a			;bcb5	8f 	. 
	jp nc,0083bh		;bcb6	d2 3b 08 	. ; . 
	sub b			;bcb9	90 	. 
	jp nc,0083bh		;bcba	d2 3b 08 	. ; . 
	sbc a,l			;bcbd	9d 	. 
	add a,b			;bcbe	80 	. 
	ld a,a			;bcbf	7f 	 
	push de			;bcc0	d5 	. 
	ld bc,l9008h		;bcc1	01 08 90 	. . . 
	push de			;bcc4	d5 	. 
	ld bc,09d08h		;bcc5	01 08 9d 	. . . 
	add a,b			;bcc8	80 	. 
	ld e,a			;bcc9	5f 	_ 
	jp nc,00881h		;bcca	d2 81 08 	. . . 
	sub b			;bccd	90 	. 
	jp nc,00881h		;bcce	d2 81 08 	. . . 
sub_bcd1h:
	sbc a,l			;bcd1	9d 	. 
	add a,b			;bcd2	80 	. 
	ld a,a			;bcd3	7f 	 
	push de			;bcd4	d5 	. 
	ld bc,0d508h		;bcd5	01 08 d5 	. . . 
	ld bc,l9008h		;bcd8	01 08 90 	. . . 
	jp nc,00881h		;bcdb	d2 81 08 	. . . 
	jp nc,00881h		;bcde	d2 81 08 	. . . 
	sbc a,l			;bce1	9d 	. 
	add a,b			;bce2	80 	. 
	adc a,a			;bce3	8f 	. 
	push de			;bce4	d5 	. 
	sbc a,(hl)			;bce5	9e 	. 
	ex af,af'			;bce6	08 	. 
	push de			;bce7	d5 	. 
	sbc a,(hl)			;bce8	9e 	. 
	ex af,af'			;bce9	08 	. 
	add a,b			;bcea	80 	. 
	ld a,a			;bceb	7f 	 
	jp nc,008cfh		;bcec	d2 cf 08 	. . . 
	add a,b			;bcef	80 	. 
	ld a,b			;bcf0	78 	x 
	jp nc,008cfh		;bcf1	d2 cf 08 	. . . 
	add a,b			;bcf4	80 	. 
	ld a,a			;bcf5	7f 	 
	push de			;bcf6	d5 	. 
	sbc a,(hl)			;bcf7	9e 	. 
	ex af,af'			;bcf8	08 	. 
	sub b			;bcf9	90 	. 
	push de			;bcfa	d5 	. 
	sbc a,(hl)			;bcfb	9e 	. 
	ex af,af'			;bcfc	08 	. 
	sbc a,l			;bcfd	9d 	. 
	add a,b			;bcfe	80 	. 
	adc a,a			;bcff	8f 	. 
	jp nc,008cfh		;bd00	d2 cf 08 	. . . 
	sub b			;bd03	90 	. 
	jp nc,008cfh		;bd04	d2 cf 08 	. . . 
	sbc a,l			;bd07	9d 	. 
	add a,b			;bd08	80 	. 
	adc a,a			;bd09	8f 	. 
	push de			;bd0a	d5 	. 
	call p,0d508h		;bd0b	f4 08 d5 	. . . 
	call p,sub_8008h		;bd0e	f4 08 80 	. . . 
	sub a			;bd11	97 	. 
	jp nc,008fah		;bd12	d2 fa 08 	. . . 
	jp nc,008fah		;bd15	d2 fa 08 	. . . 
	add a,b			;bd18	80 	. 
	adc a,a			;bd19	8f 	. 
	push de			;bd1a	d5 	. 
	call p,0d508h		;bd1b	f4 08 d5 	. . . 
	call p,sub_8008h		;bd1e	f4 08 80 	. . . 
	ld a,a			;bd21	7f 	 
	jp nc,008fah		;bd22	d2 fa 08 	. . . 
	jp nc,001fah		;bd25	d2 fa 01 	. . . 
	xor b			;bd28	a8 	. 
	ret m			;bd29	f8 	. 
	ex af,af'			;bd2a	08 	. 
	xor c			;bd2b	a9 	. 
	ld sp,hl			;bd2c	f9 	. 
	sbc a,l			;bd2d	9d 	. 
	pop af			;bd2e	f1 	. 
	add a,b			;bd2f	80 	. 
	adc a,a			;bd30	8f 	. 
	call nc,00875h		;bd31	d4 75 08 	. u . 
	call nc,00875h		;bd34	d4 75 08 	. u . 
	add a,b			;bd37	80 	. 
	ld a,a			;bd38	7f 	 
	jp nc,0083bh		;bd39	d2 3b 08 	. ; . 
	add a,b			;bd3c	80 	. 
	ld a,b			;bd3d	78 	x 
	jp nc,0083bh		;bd3e	d2 3b 08 	. ; . 
	add a,b			;bd41	80 	. 
	ld a,a			;bd42	7f 	 
	call nc,00875h		;bd43	d4 75 08 	. u . 
	sub b			;bd46	90 	. 
	call nc,00875h		;bd47	d4 75 08 	. u . 
	sbc a,l			;bd4a	9d 	. 
	add a,b			;bd4b	80 	. 
	adc a,a			;bd4c	8f 	. 
	jp nc,0083bh		;bd4d	d2 3b 08 	. ; . 
	sub b			;bd50	90 	. 
	jp nc,0083bh		;bd51	d2 3b 08 	. ; . 
	sbc a,l			;bd54	9d 	. 
	add a,b			;bd55	80 	. 
	ld a,a			;bd56	7f 	 
	push de			;bd57	d5 	. 
	ld bc,l9008h		;bd58	01 08 90 	. . . 
	push de			;bd5b	d5 	. 
	ld bc,09d08h		;bd5c	01 08 9d 	. . . 
	add a,b			;bd5f	80 	. 
	ld e,a			;bd60	5f 	_ 
	jp nc,00881h		;bd61	d2 81 08 	. . . 
	sub b			;bd64	90 	. 
	jp nc,00881h		;bd65	d2 81 08 	. . . 
	sbc a,l			;bd68	9d 	. 
	add a,b			;bd69	80 	. 
	ld a,a			;bd6a	7f 	 
	push de			;bd6b	d5 	. 
	ld bc,0d508h		;bd6c	01 08 d5 	. . . 
	ld bc,l9008h		;bd6f	01 08 90 	. . . 
	jp nc,00881h		;bd72	d2 81 08 	. . . 
	jp nc,00881h		;bd75	d2 81 08 	. . . 
	sbc a,l			;bd78	9d 	. 
	add a,b			;bd79	80 	. 
	ld a,b			;bd7a	78 	x 
	push de			;bd7b	d5 	. 
	sbc a,(hl)			;bd7c	9e 	. 
	ex af,af'			;bd7d	08 	. 
	push de			;bd7e	d5 	. 
	sbc a,(hl)			;bd7f	9e 	. 
	ex af,af'			;bd80	08 	. 
	add a,b			;bd81	80 	. 
	ld l,e			;bd82	6b 	k 
	jp nc,008cfh		;bd83	d2 cf 08 	. . . 
	add a,b			;bd86	80 	. 
	ld e,a			;bd87	5f 	_ 
	jp nc,008cfh		;bd88	d2 cf 08 	. . . 
	add a,b			;bd8b	80 	. 
	ld l,e			;bd8c	6b 	k 
	push de			;bd8d	d5 	. 
	sbc a,(hl)			;bd8e	9e 	. 
	ex af,af'			;bd8f	08 	. 
	sub b			;bd90	90 	. 
	push de			;bd91	d5 	. 
	sbc a,(hl)			;bd92	9e 	. 
	ex af,af'			;bd93	08 	. 
	sbc a,l			;bd94	9d 	. 
	add a,b			;bd95	80 	. 
	ld a,b			;bd96	78 	x 
	jp nc,008cfh		;bd97	d2 cf 08 	. . . 
	sub b			;bd9a	90 	. 
	jp nc,008cfh		;bd9b	d2 cf 08 	. . . 
	sbc a,l			;bd9e	9d 	. 
	add a,b			;bd9f	80 	. 
	ld l,e			;bda0	6b 	k 
	push de			;bda1	d5 	. 
	ld bc,l9008h		;bda2	01 08 90 	. . . 
	push de			;bda5	d5 	. 
	ld bc,09d08h		;bda6	01 08 9d 	. . . 
	add a,b			;bda9	80 	. 
	ld d,b			;bdaa	50 	P 
	jp nc,00881h		;bdab	d2 81 08 	. . . 
	sub b			;bdae	90 	. 
	jp nc,00881h		;bdaf	d2 81 08 	. . . 
	sbc a,l			;bdb2	9d 	. 
	add a,b			;bdb3	80 	. 
	ld l,e			;bdb4	6b 	k 
	push de			;bdb5	d5 	. 
	ld bc,0d508h		;bdb6	01 08 d5 	. . . 
	ld bc,l9008h		;bdb9	01 08 90 	. . . 
	jp nc,00881h		;bdbc	d2 81 08 	. . . 
	jp nc,00481h		;bdbf	d2 81 04 	. . . 
	sbc a,l			;bdc2	9d 	. 
	add a,b			;bdc3	80 	. 
	ld b,b			;bdc4	40 	@ 
	call nc,00475h		;bdc5	d4 75 04 	. u . 
	sub b			;bdc8	90 	. 
	inc b			;bdc9	04 	. 
	sbc a,l			;bdca	9d 	. 
	add a,b			;bdcb	80 	. 
	ld b,b			;bdcc	40 	@ 
	call nc,00475h		;bdcd	d4 75 04 	. u . 
	sub b			;bdd0	90 	. 
	ex af,af'			;bdd1	08 	. 
	jp nc,0083bh		;bdd2	d2 3b 08 	. ; . 
	jp nc,0043bh		;bdd5	d2 3b 04 	. ; . 
	sbc a,l			;bdd8	9d 	. 
	add a,b			;bdd9	80 	. 
	ld b,b			;bdda	40 	@ 
	call nc,00475h		;bddb	d4 75 04 	. u . 
	sub b			;bdde	90 	. 
	inc b			;bddf	04 	. 
	sbc a,l			;bde0	9d 	. 
	add a,b			;bde1	80 	. 
	ld b,b			;bde2	40 	@ 
	call nc,00475h		;bde3	d4 75 04 	. u . 
	sub b			;bde6	90 	. 
	ex af,af'			;bde7	08 	. 
	jp nc,0083bh		;bde8	d2 3b 08 	. ; . 
	jp nc,0043bh		;bdeb	d2 3b 04 	. ; . 
	sbc a,l			;bdee	9d 	. 
	add a,b			;bdef	80 	. 
	ld b,b			;bdf0	40 	@ 
	push de			;bdf1	d5 	. 
	ld bc,l9004h		;bdf2	01 04 90 	. . . 
	inc b			;bdf5	04 	. 
	sbc a,l			;bdf6	9d 	. 
	add a,b			;bdf7	80 	. 
	ld b,b			;bdf8	40 	@ 
	push de			;bdf9	d5 	. 
	ld bc,l9004h		;bdfa	01 04 90 	. . . 
	ex af,af'			;bdfd	08 	. 
	jp nc,00881h		;bdfe	d2 81 08 	. . . 
	jp nc,00881h		;be01	d2 81 08 	. . . 
	sbc a,l			;be04	9d 	. 
	add a,b			;be05	80 	. 
	ld b,b			;be06	40 	@ 
	push de			;be07	d5 	. 
	ld bc,sub_8008h		;be08	01 08 80 	. . . 
	ld b,a			;be0b	47 	G 
	push de			;be0c	d5 	. 
	ld bc,sub_8008h		;be0d	01 08 80 	. . . 
	ld d,b			;be10	50 	P 
	jp nc,00881h		;be11	d2 81 08 	. . . 
	add a,b			;be14	80 	. 
	ld l,e			;be15	6b 	k 
	jp nc,00881h		;be16	d2 81 08 	. . . 
	add a,b			;be19	80 	. 
	ld e,a			;be1a	5f 	_ 
	push de			;be1b	d5 	. 
	sbc a,(hl)			;be1c	9e 	. 
	ex af,af'			;be1d	08 	. 
	push de			;be1e	d5 	. 
	sbc a,(hl)			;be1f	9e 	. 
	ex af,af'			;be20	08 	. 
	jp nc,008cfh		;be21	d2 cf 08 	. . . 
	jp nc,008cfh		;be24	d2 cf 08 	. . . 
	push de			;be27	d5 	. 
	sbc a,(hl)			;be28	9e 	. 
	ex af,af'			;be29	08 	. 
	push de			;be2a	d5 	. 
	sbc a,(hl)			;be2b	9e 	. 
	ex af,af'			;be2c	08 	. 
	jp nc,008cfh		;be2d	d2 cf 08 	. . . 
	jp nc,008cfh		;be30	d2 cf 08 	. . . 
	sub b			;be33	90 	. 
	push de			;be34	d5 	. 
	call p,0d508h		;be35	f4 08 d5 	. . . 
	call p,0d208h		;be38	f4 08 d2 	. . . 
	jp m,0d208h		;be3b	fa 08 d2 	. . . 
	jp m,0d508h		;be3e	fa 08 d5 	. . . 
	call p,0d508h		;be41	f4 08 d5 	. . . 
	call p,0d208h		;be44	f4 08 d2 	. . . 
	jp m,0d208h		;be47	fa 08 d2 	. . . 
	jp m,09d04h		;be4a	fa 04 9d 	. . . 
	add a,b			;be4d	80 	. 
	ld b,b			;be4e	40 	@ 
	call nc,00475h		;be4f	d4 75 04 	. u . 
	sub b			;be52	90 	. 
	inc b			;be53	04 	. 
	sbc a,l			;be54	9d 	. 
	add a,b			;be55	80 	. 
	ld b,b			;be56	40 	@ 
	call nc,00475h		;be57	d4 75 04 	. u . 
	sub b			;be5a	90 	. 
	ex af,af'			;be5b	08 	. 
	jp nc,0083bh		;be5c	d2 3b 08 	. ; . 
	jp nc,0043bh		;be5f	d2 3b 04 	. ; . 
	sbc a,l			;be62	9d 	. 
	add a,b			;be63	80 	. 
	ld b,b			;be64	40 	@ 
	call nc,00475h		;be65	d4 75 04 	. u . 
	sub b			;be68	90 	. 
	inc b			;be69	04 	. 
	sbc a,l			;be6a	9d 	. 
	add a,b			;be6b	80 	. 
	ld b,b			;be6c	40 	@ 
	call nc,00475h		;be6d	d4 75 04 	. u . 
	sub b			;be70	90 	. 
	ex af,af'			;be71	08 	. 
	jp nc,0083bh		;be72	d2 3b 08 	. ; . 
	jp nc,0043bh		;be75	d2 3b 04 	. ; . 
	sbc a,l			;be78	9d 	. 
	add a,b			;be79	80 	. 
	ld b,b			;be7a	40 	@ 
	push de			;be7b	d5 	. 
	ld bc,l9004h		;be7c	01 04 90 	. . . 
	inc b			;be7f	04 	. 
	sbc a,l			;be80	9d 	. 
	add a,b			;be81	80 	. 
	ld b,b			;be82	40 	@ 
	push de			;be83	d5 	. 
	ld bc,l9004h		;be84	01 04 90 	. . . 
	ex af,af'			;be87	08 	. 
	jp nc,00881h		;be88	d2 81 08 	. . . 
	jp nc,00881h		;be8b	d2 81 08 	. . . 
	sbc a,l			;be8e	9d 	. 
	add a,b			;be8f	80 	. 
	ld b,b			;be90	40 	@ 
	push de			;be91	d5 	. 
	ld bc,sub_8008h		;be92	01 08 80 	. . . 
	ld b,a			;be95	47 	G 
	push de			;be96	d5 	. 
	ld bc,sub_8008h		;be97	01 08 80 	. . . 
	ld d,b			;be9a	50 	P 
	jp nc,00881h		;be9b	d2 81 08 	. . . 
	add a,b			;be9e	80 	. 
	ld l,e			;be9f	6b 	k 
	jp nc,00881h		;bea0	d2 81 08 	. . . 
	add a,b			;bea3	80 	. 
	ld e,a			;bea4	5f 	_ 
	push de			;bea5	d5 	. 
	sbc a,(hl)			;bea6	9e 	. 
	ex af,af'			;bea7	08 	. 
	push de			;bea8	d5 	. 
	sbc a,(hl)			;bea9	9e 	. 
	ex af,af'			;beaa	08 	. 
	jp nc,008cfh		;beab	d2 cf 08 	. . . 
	jp nc,008cfh		;beae	d2 cf 08 	. . . 
	push de			;beb1	d5 	. 
	sbc a,(hl)			;beb2	9e 	. 
	ex af,af'			;beb3	08 	. 
	push de			;beb4	d5 	. 
	sbc a,(hl)			;beb5	9e 	. 
	ex af,af'			;beb6	08 	. 
	jp nc,008cfh		;beb7	d2 cf 08 	. . . 
	jp nc,008cfh		;beba	d2 cf 08 	. . . 
	sub b			;bebd	90 	. 
	push de			;bebe	d5 	. 
	call p,0d508h		;bebf	f4 08 d5 	. . . 
	call p,0d208h		;bec2	f4 08 d2 	. . . 
	jp m,0d208h		;bec5	fa 08 d2 	. . . 
	jp m,0d508h		;bec8	fa 08 d5 	. . . 
	call p,0d508h		;becb	f4 08 d5 	. . . 
	call p,0d208h		;bece	f4 08 d2 	. . . 
	jp m,0d206h		;bed1	fa 06 d2 	. . . 
	jp m,0a801h		;bed4	fa 01 a8 	. . . 
	ret m			;bed7	f8 	. 
	nop			;bed8	00 	. 
	ld a,(bc)			;bed9	0a 	. 
	xor c			;beda	a9 	. 
	or c			;bedb	b1 	. 
	add a,b			;bedc	80 	. 
	adc a,a			;bedd	8f 	. 
	ld a,(bc)			;bede	0a 	. 
	add a,b			;bedf	80 	. 
	sub a			;bee0	97 	. 
	ld a,(bc)			;bee1	0a 	. 
	add a,b			;bee2	80 	. 
	or h			;bee3	b4 	. 
	inc d			;bee4	14 	. 
	add a,b			;bee5	80 	. 
	and b			;bee6	a0 	. 
	ld a,(bc)			;bee7	0a 	. 
	add a,b			;bee8	80 	. 
	sub a			;bee9	97 	. 
	inc d			;beea	14 	. 
	add a,b			;beeb	80 	. 
	adc a,a			;beec	8f 	. 
	ld a,(bc)			;beed	0a 	. 
	add a,b			;beee	80 	. 
	sub a			;beef	97 	. 
	ld a,(bc)			;bef0	0a 	. 
	add a,b			;bef1	80 	. 
	sub a			;bef2	97 	. 
	ld a,(bc)			;bef3	0a 	. 
	xor b			;bef4	a8 	. 
	ld a,(bc)			;bef5	0a 	. 
	xor c			;bef6	a9 	. 
	or c			;bef7	b1 	. 
	add a,b			;bef8	80 	. 
	sub a			;bef9	97 	. 
	ld a,(bc)			;befa	0a 	. 
	add a,b			;befb	80 	. 
	sub a			;befc	97 	. 
	ld a,(bc)			;befd	0a 	. 
	xor b			;befe	a8 	. 
	ld a,(bc)			;beff	0a 	. 
	xor c			;bf00	a9 	. 
	or c			;bf01	b1 	. 
	add a,b			;bf02	80 	. 
	sub a			;bf03	97 	. 
	ld a,(bc)			;bf04	0a 	. 
	add a,b			;bf05	80 	. 
	sub a			;bf06	97 	. 
	ld a,(bc)			;bf07	0a 	. 
	xor b			;bf08	a8 	. 
	dec b			;bf09	05 	. 
	xor c			;bf0a	a9 	. 
	or c			;bf0b	b1 	. 
	add a,b			;bf0c	80 	. 
	sub a			;bf0d	97 	. 
	dec b			;bf0e	05 	. 
	add a,b			;bf0f	80 	. 
	or h			;bf10	b4 	. 
	dec b			;bf11	05 	. 
	add a,b			;bf12	80 	. 
	cp (hl)			;bf13	be 	. 
	dec b			;bf14	05 	. 
	add a,b			;bf15	80 	. 
	cp 005h		;bf16	fe 05 	. . 
	add a,c			;bf18	81 	. 
	ld l,005h		;bf19	2e 05 	. . 
	add a,c			;bf1b	81 	. 
	ld l,b			;bf1c	68 	h 
	dec b			;bf1d	05 	. 
	add a,c			;bf1e	81 	. 
	xor h			;bf1f	ac 	. 
	dec b			;bf20	05 	. 
	add a,c			;bf21	81 	. 
	call m,sub_8205h		;bf22	fc 05 82 	. . . 
	ld e,l			;bf25	5d 	] 
	dec b			;bf26	05 	. 
	add a,c			;bf27	81 	. 
	call m,sub_8105h		;bf28	fc 05 81 	. . . 
	xor h			;bf2b	ac 	. 
	dec b			;bf2c	05 	. 
	add a,c			;bf2d	81 	. 
	ld l,b			;bf2e	68 	h 
	dec b			;bf2f	05 	. 
	add a,c			;bf30	81 	. 
	ld l,005h		;bf31	2e 05 	. . 
	add a,b			;bf33	80 	. 
	cp 005h		;bf34	fe 05 	. . 
	add a,b			;bf36	80 	. 
	sub 005h		;bf37	d6 05 	. . 
	add a,b			;bf39	80 	. 
	or h			;bf3a	b4 	. 
	dec b			;bf3b	05 	. 
	add a,b			;bf3c	80 	. 
	sub a			;bf3d	97 	. 
	dec b			;bf3e	05 	. 
	add a,b			;bf3f	80 	. 
	sub a			;bf40	97 	. 
	ld bc,000a8h		;bf41	01 a8 00 	. . . 
	dec b			;bf44	05 	. 
	xor c			;bf45	a9 	. 
	ld sp,hl			;bf46	f9 	. 
	sbc a,(hl)			;bf47	9e 	. 
	pop af			;bf48	f1 	. 
	add a,(hl)			;bf49	86 	. 
	xor (hl)			;bf4a	ae 	. 
	ret nc			;bf4b	d0 	. 
	sub 005h		;bf4c	d6 05 	. . 
	sub b			;bf4e	90 	. 
	dec b			;bf4f	05 	. 
	sbc a,(hl)			;bf50	9e 	. 
	add a,e			;bf51	83 	. 
	ld d,a			;bf52	57 	W 
	ret nc			;bf53	d0 	. 
	sub 005h		;bf54	d6 05 	. . 
	sub b			;bf56	90 	. 
	dec b			;bf57	05 	. 
	sbc a,(hl)			;bf58	9e 	. 
	add a,(hl)			;bf59	86 	. 
	xor (hl)			;bf5a	ae 	. 
	ret nc			;bf5b	d0 	. 
	sub 005h		;bf5c	d6 05 	. . 
	sub b			;bf5e	90 	. 
	dec b			;bf5f	05 	. 
	sbc a,(hl)			;bf60	9e 	. 
	add a,e			;bf61	83 	. 
	ld d,a			;bf62	57 	W 
	ret nc			;bf63	d0 	. 
	sub 005h		;bf64	d6 05 	. . 
	sub b			;bf66	90 	. 
	dec b			;bf67	05 	. 
	sbc a,(hl)			;bf68	9e 	. 
	add a,(hl)			;bf69	86 	. 
	xor (hl)			;bf6a	ae 	. 
	dec b			;bf6b	05 	. 
	sub b			;bf6c	90 	. 
	dec b			;bf6d	05 	. 
	sbc a,(hl)			;bf6e	9e 	. 
	add a,e			;bf6f	83 	. 
	ld d,a			;bf70	57 	W 
	ret nc			;bf71	d0 	. 
	sub 005h		;bf72	d6 05 	. . 
	sub b			;bf74	90 	. 
	dec b			;bf75	05 	. 
	sbc a,(hl)			;bf76	9e 	. 
	adc a,d			;bf77	8a 	. 
	ld l,(hl)			;bf78	6e 	n 
	ret nc			;bf79	d0 	. 
	sub 005h		;bf7a	d6 05 	. . 
	sub b			;bf7c	90 	. 
	dec b			;bf7d	05 	. 
	sbc a,(hl)			;bf7e	9e 	. 
	add a,e			;bf7f	83 	. 
	ld d,a			;bf80	57 	W 
	dec b			;bf81	05 	. 
	sub b			;bf82	90 	. 
	dec b			;bf83	05 	. 
	sbc a,(hl)			;bf84	9e 	. 
	add a,h			;bf85	84 	. 
	cp c			;bf86	b9 	. 
	ret nc			;bf87	d0 	. 
	sub 005h		;bf88	d6 05 	. . 
	sub b			;bf8a	90 	. 
	dec b			;bf8b	05 	. 
	sbc a,(hl)			;bf8c	9e 	. 
	add a,d			;bf8d	82 	. 
	ld e,l			;bf8e	5d 	] 
	ret nc			;bf8f	d0 	. 
	sub 005h		;bf90	d6 05 	. . 
	sub b			;bf92	90 	. 
	dec b			;bf93	05 	. 
	sbc a,(hl)			;bf94	9e 	. 
	add a,h			;bf95	84 	. 
	cp c			;bf96	b9 	. 
	dec b			;bf97	05 	. 
	sub b			;bf98	90 	. 
	dec b			;bf99	05 	. 
	sbc a,(hl)			;bf9a	9e 	. 
	add a,d			;bf9b	82 	. 
	ld e,l			;bf9c	5d 	] 
	ret nc			;bf9d	d0 	. 
	sub 005h		;bf9e	d6 05 	. . 
	sub b			;bfa0	90 	. 
	dec b			;bfa1	05 	. 
	sbc a,(hl)			;bfa2	9e 	. 
	add a,h			;bfa3	84 	. 
	cp c			;bfa4	b9 	. 
	ret nc			;bfa5	d0 	. 
	sub 005h		;bfa6	d6 05 	. . 
	sub b			;bfa8	90 	. 
	dec b			;bfa9	05 	. 
	sbc a,(hl)			;bfaa	9e 	. 
	add a,d			;bfab	82 	. 
	ld e,l			;bfac	5d 	] 
	dec b			;bfad	05 	. 
	sub b			;bfae	90 	. 
	dec b			;bfaf	05 	. 
	sbc a,(hl)			;bfb0	9e 	. 
	add a,h			;bfb1	84 	. 
	cp c			;bfb2	b9 	. 
	ret nc			;bfb3	d0 	. 
	sub 005h		;bfb4	d6 05 	. . 
	sub b			;bfb6	90 	. 
	dec b			;bfb7	05 	. 
	sbc a,(hl)			;bfb8	9e 	. 
	add a,d			;bfb9	82 	. 
	ld e,l			;bfba	5d 	] 
	ret nc			;bfbb	d0 	. 
	sub 005h		;bfbc	d6 05 	. . 
	sub b			;bfbe	90 	. 
	ld a,(bc)			;bfbf	0a 	. 
	xor b			;bfc0	a8 	. 
	ret m			;bfc1	f8 	. 
	dec b			;bfc2	05 	. 
	xor c			;bfc3	a9 	. 
	sbc a,(hl)			;bfc4	9e 	. 
	add a,b			;bfc5	80 	. 
	sub (hl)			;bfc6	96 	. 
	dec b			;bfc7	05 	. 
	add a,b			;bfc8	80 	. 
	or e			;bfc9	b3 	. 
	dec b			;bfca	05 	. 
	add a,b			;bfcb	80 	. 
	cp l			;bfcc	bd 	. 
	dec b			;bfcd	05 	. 
	add a,b			;bfce	80 	. 
	defb 0fdh,005h,081h	;illegal sequence		;bfcf	fd 05 81 	. . . 
	dec l			;bfd2	2d 	- 
	dec b			;bfd3	05 	. 
	add a,c			;bfd4	81 	. 
	ld h,a			;bfd5	67 	g 
	dec b			;bfd6	05 	. 
	add a,c			;bfd7	81 	. 
	xor e			;bfd8	ab 	. 
	dec b			;bfd9	05 	. 
	add a,c			;bfda	81 	. 
	ei			;bfdb	fb 	. 
	dec b			;bfdc	05 	. 
	add a,d			;bfdd	82 	. 
	ld e,h			;bfde	5c 	\ 
	dec b			;bfdf	05 	. 
	add a,c			;bfe0	81 	. 
	ei			;bfe1	fb 	. 
	dec b			;bfe2	05 	. 
	add a,c			;bfe3	81 	. 
	xor e			;bfe4	ab 	. 
	dec b			;bfe5	05 	. 
	add a,c			;bfe6	81 	. 
	ld h,a			;bfe7	67 	g 
	dec b			;bfe8	05 	. 
	add a,c			;bfe9	81 	. 
	dec l			;bfea	2d 	- 
	dec b			;bfeb	05 	. 
	add a,b			;bfec	80 	. 
	defb 0fdh,005h,080h	;illegal sequence		;bfed	fd 05 80 	. . . 
	push de			;bff0	d5 	. 
	dec b			;bff1	05 	. 
	add a,b			;bff2	80 	. 
	or e			;bff3	b3 	. 
	dec b			;bff4	05 	. 
	xor b			;bff5	a8 	. 
	ld sp,hl			;bff6	f9 	. 
	pop af			;bff7	f1 	. 
	ret nc			;bff8	d0 	. 
	sub 005h		;bff9	d6 05 	. . 
	ret nc			;bffb	d0 	. 
	sub 001h		;bffc	d6 01 	. . 
	ret m			;bffe	f8 	. 
	nop			;bfff	00 	. 
