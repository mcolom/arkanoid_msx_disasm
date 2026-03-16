; z80dasm 1.1.6
; command line: z80dasm -g0x4000 -l -t arkanoid.rom
;
; $ z80asm disassembly.asm && shasum a.bin 
; 2183f07fa3ba87360100b2fa21fda0f55c0f8814  a.bin

include 'headers/bios.asm'

include 'tilemap.asm'
include 'sounds.asm'
include 'spr_params.asm'
include 'doors.asm'
include 'scores.asm'
include 'vaus.asm'
include 'cheats.asm'
include 'game_state.asm'
include 'level.asm'
include 'balls.asm'
include 'lasers.asm'
include 'aliens.asm'
include 'sound.asm'
include 'title.asm'
include 'glue.asm'
include 'sprites.asm'
include 'keyboard.asm'
include 'paddle.asm'
include 'bricks.asm'
include 'capsules.asm'
include 'doh.asm'
include 'portal.asm'
include 'lives.asm'
include 'demo.asm'
include 'text.asm'


	org	04000h

    ; MSX ROM header
	db "AB"             ; ROM SIGNATURE
    dw ROM_START        ; INIT
    dw 0                ; STATEMENT
    dw 0                ; DEVICE
    dw 0                ; TEXT
    db 0, 0, 0, 0, 0, 0 ; RESERVED

; Get the slot of the current page.
; This function takes into account if the slot is expanded or not.
GET_CURRENT_PAGE_SLOT:
    ; Reads the primary slot register
	call RSLREG		;4010	cd 38 01
    
    ; It tells which slots are assigned to each of the 4 pages
    ; p3p3.p2p2.p1p1.p0p0

	; A = 00.00.00.p1p1
    rrca			;4013	0f      p0p3p3p2p2p1p1p0
	rrca			;4014	0f      p0p0p3p3p2p2p1p1
	and 3		    ;4015	e6 03   00.00.00.p1p1    

    ; BC = slot corresponding to page 1 (this one)
	ld c,a			;4017	4f
	ld b,0		    ;4018	06 00   BC = 00.00.00.p1p1
    
    ; Check EXPTBL[s1]
    ; #80 = expanded, 0 = not expanded
	ld hl, EXPTBL	;401a	21 c1 fc
	add hl,bc		;401d	09
	or (hl)			;401e	b6
    
    ; A = 00.00.00.p1p1 if the slot is not expanded
    ; A = 10.00.00.p1p1 if the slot is     expanded
	
    ; Exit with A = slot for page 1 if the slot is not expanded
    ret p			;401f	f0
    
    ; The slot is expanded
    ld c,a			;4020	4f      ; C = 10.00.00.p1p1
    
    ; HL = mirror of the secondary slot selection register
	inc hl			;4021	23
	inc hl			;4022	23
	inc hl			;4023	23
	inc hl			;4024	23
    
    ; A = secondary slot
	ld a,(hl)		;4025	7e      q3q3.q2q2.q1q1.q0q0     AND
	and 00ch		;4026	e6 0c    11 . 00 . 00 . 00
    ;                                ==================
    ;                               q3q3. 00.  00.  00

	or c			;4028	b1
    ;                           q3q3. 00 . 00 .  00          OR
    ;                            10 . 00 . 00 . p1p1
    ;                            ===================
    ;                           1q3 . 00 . 00 . p1p1
	ret			    ;4029	c9
    
ROM_START:
	di			;402a	f3
	im 1		;402b	ed 56

	ld sp,0f370h		            ;402d	31 70 f3
	call GET_CURRENT_PAGE_SLOT	;4030	cd 10 40

    ;Switches indicated slot at indicated page on perpetually
    ; A - Slot ID
    ; H - Bit 6 and 7 must contain the page number (00-11)
    ld h,080h		;4033	26 80       page 2 (10.00.00.00)
	call ENASLT		;4035	cd 24 00
    
	; Clear memory from 0xe000 to 0xe5b3
    ld hl,DEMO_LEVEL		;4038	21 00
	ld de,CHEAT1_ACTIVATED		;403b	11 01
	ld bc,005b3h		;403e	01 b3
	ld (hl),0		    ;4041	36 00
	ldir		        ;4043	ed b0
    
    ; Clear variables
	ld hl,SOUND_NUMBER		;4045	21 c0 e5
	ld de,SOUND_NUMBER+1	;4048	11 c1 e5
	ld bc, 254		        ;404b	01 fe 00
	ld (hl), 0		        ;404e	36 00
	ldir		            ;4050	ed b0
    
	ld hl,00050h		;4052	21 50 00
	ld (0e008h),hl		;4055	22 08 e0

    ; Turn off CAPS lamp
	ld a, 1		        ;4058	3e 01
	call CHGCAP		    ;405a	cd 32 01    

	ld a,0ffh		    ;405d	3e ff
	ld (SOUND_REG_MASK),a	;405f	32 c3 e5

	ld a,0bfh		;4062	3e bf 	> . 
	ld (SOUND_VOICE_CONTROL),a		;4064	32 cb e5 	2 . . 

    ; Configure VDP TABLES
	ld hl,VDP_BASE_POINTERS		;4067	21 76 43
	ld de, GRPNAM		        ;406a	11 c7 f3
	ld bc, 10		            ;406d	01 0a 00
	ldir		                ;4070	ed b0

    ; Use 16x16 sprites
	ld hl, RG1SAV	;4072	21 e0 f3 Mirror of VDP register 1 (Basic: VDP(1))
	set 1,(hl)		;4075	cb ce

    ; Set border color to black
	ld a, 1		    ;4077	3e 01
	ld (BDRCLR),a	;4079	32 eb f3
    
	; Switches to SCREEN 2 (high resolution screen with 256×192 pixels)
    call INIGRP		;407c	cd 72 00
    
    ; Inhibits the screen display
	call DISSCR		;407f	cd 41 00

    ; Clear VRAM name table
    ld hl, 0x1800		;4082	21 00 18
	ld bc,  0x300		;4085	01 00 03
	xor a			    ;4088	af
	call FILVRM		    ;4089	cd 56 00
    
    ; Clear VRAM sprite attribute table
	ld hl,VRAM_SPRITES_ATTRIB_TABLE		;408c	21 00 1b
	ld bc, 128		                ;408f	01 80 00
	xor a			                ;4092	af
	call FILVRM		                ;4093	cd 56 00
    
    ; Fill pattern table (1/3)
	ld hl,TITLE_TILES		    ;4096	21 24 90
	ld de, 0 * 8*32*24/3	;4099	11 00 00
	call LDIRVM_32x24_THIRD		    ;409c	cd 20 42

    ; Fill pattern table (2/3)
	ld hl,TITLE_TILES		    ;409f	21 24 90
	ld de, 1 * 8*32*24/3	;40a2	11 00 08
	call LDIRVM_32x24_THIRD		    ;40a5	cd 20 42

    ; Fill pattern table (3/3)
	ld hl,TITLE_TILES		    ;40a8	21 24 90
	ld de, 2 * 8*32*24/3	;40ab	11 00 10
	call LDIRVM_32x24_THIRD		    ;40ae	cd 20 42

    ; Fill title's screen pattern table
	call FILL_COLORS_ALL_SCREEN		;40b1	cd ff 41

    ; Fill sprite pattern table
	ld hl,SPRITE_DEFINITIONS		    ;40b4	21 84 86
	ld de,VRAM_SPRITES_PATTERN_TABLE	;40b7	11 00 38
	ld bc, 0x800		                ;40ba	01 00 08
	call LDIRVM		                    ;40bd	cd 5c 00

    ; Complete the unrolled tables of brick actions for all 32 levels.
	call FILL_BRICK_ACTION_TABLE		;40c0	cd ff 43

	ld a,SOUND_NOP		;40c3	3e f8
	ld (SOUND_NUMBER),a	;40c5	32 c0 e5
	call PLAY_SOUND		;40c8	cd e8 b4

    ; Set VDP hook handler
	ld a, 0c3h		    ;40cb	3e c3       JP...
	ld (0fd9ah),a		;40cd	32 9a fd
	ld hl,VDP_HOOK_HANDLER		;40d0	21 4a 42
	ld (0fd9bh),hl		;40d3	22 9b fd
	ei			        ;40d6	fb
l40d7h:
    ; Check if the game is paused.
    ; If already paused, skip playing the pause sound and writing "PAUSE" again
	halt			                            ;40d7	76
	ld a,(CONTROLS)   ;40d8	3a bf e0
	bit 6,a		                                ;40db	cb 77
	jr z,l4103h		                            ;40dd	28 24

    ; Skip if state is title screen
	ld a,(GAME_STATE)		;40df	3a 0b e0
	or a			        ;40e2	b7
	jp z,l4103h		        ;40e3	ca 03 41

    ; Play pause sound
	ld a,SOUND_PAUSE		;40e6	3e 05
	ld (SOUND_NUMBER),a		;40e8	32 c0 e5
	call PLAY_SOUND		    ;40eb	cd e8 b4

	ei			    ;40ee

    ; Print "PAUSE"
	ld hl,PAUSE_STR		            ;40ef	21 1b 42
	ld de,0x1800 + 26 + 17*32		;40f2	11 3a 1a    Locate at [26, 17]
	ld bc,5 		                ;40f5	01 05 00    len("PAUSE")=5
	call LDIRVM		                ;40f8	cd 5c 00

; Do the pause...
l40fbh:
	halt			                ;40fb	76
	ld a,(CONTROLS)	;40fc	3a bf e0
	bit 6,a		                    ;40ff	cb 77
l4101h:
	jr z,l40fbh		                ;4101	28 f8    
; Pause finished

l4103h:
    ; Clear the "PAUSE" message
	ld hl,0x1800 + 26 + 17*32	;4103	21 3a 1a 	Locate at [26, 17]
	ld bc, 5		            ;4106	01 05 00
	ld a, 0		                ;4109	3e 00
	call FILVRM		            ;410b	cd 56 00

    ; Set the Y coordinate of all 32 sprites to 192 (invisible)
	ld hl, SPRITE_ATTRIBS_AREA	;410e	21 8d e1
	ld b,  TOTAL_SPRITES        ;4111	06 20       32 sprites
	ld de, SPR_PARAMS_LEN       ;4113	11 04 00
l4116h:
	ld (hl), 192		        ;4116	36 c0
	add hl,de			        ;4118	19
	djnz l4116h		            ;4119	10 fb
    
    ; Update active sprites
	ld b, TOTAL_SPRITES		    ;411b	06 20            32 sprites
	ld ix, SPR_PARAMS_BASE - SPR_PARAMS_LEN		        ;411d	dd 21 c9 e0
l4121h:
	ld iy,SPRITE_ATTRIBS_AREA		;4121	fd 21 8d e1
	ld de, SPR_PARAMS_LEN           ;4125	11 04 00
l4128h:
    ; Exit if empty entry
	ld a,(ix+SPR_PARAMS_IDX_PATTERN_NUM)		;4128	dd 7e 02
	or a			                            ;412b	b7
	jp z,l4158h		                            ;412c	ca 58 41
    ; X
	ld a,(ix+SPR_PARAMS_IDX_Y)		            ;412f	dd 7e 00
	cp 192		                                ;4132	fe c0
	jp z,l4158h		                            ;4134	ca 58 41
    ; Color
	ld a,(ix+SPR_PARAMS_IDX_COLOR)		        ;4137	dd 7e 03
	or a			                            ;413a	b7
	jp z,l4158h		                            ;413b	ca 58 41
    ; Y
	ld a,(ix+SPR_PARAMS_IDX_Y)		            ;413e	dd 7e 00
	ld (iy+SPR_PARAMS_IDX_Y),a		            ;4141	fd 77 00
    ; X
	ld a,(ix+SPR_PARAMS_IDX_X)		            ;4144	dd 7e 01
	ld (iy+SPR_PARAMS_IDX_X),a		            ;4147	fd 77 01
l414ah:
    ; Pattern num.
	ld a,(ix+SPR_PARAMS_IDX_PATTERN_NUM)		;414a	dd 7e 02
	ld (iy+SPR_PARAMS_IDX_PATTERN_NUM),a		;414d	fd 77 02
    ; Color
	ld a,(ix+SPR_PARAMS_IDX_COLOR)		        ;4150	dd 7e 03
	ld (iy+SPR_PARAMS_IDX_COLOR),a		        ;4153	fd 77 03

    ; Next...
	add iy,de		;4156	fd 19 	. . 
l4158h:
	add ix,de		;4158	dd 19 	. . 
	djnz l4128h		;415a	10 cc 	. . 

    ; If no capsule is falling, skip sprite switching
	ld a,(CAPSULE_IS_FALLING)		;415c	3a 17 e3
	or a			                ;415f	b7
	jp z,l418eh		                ;4160	ca 8e 41    Skip switching

    ; Toggle the sprite switching flag
	ld hl,SPRITE_SWITCH_FLAG	;4163	21 45 e5
	inc (hl)			        ;4166	34
	ld a,(hl)			        ;4167	7e
	and 1   		            ;4168	e6 01
	jp z,l418eh		            ;416a	ca 8e 41    Skip sprite switching

    ; Exchange sprites 0 and 4
    ;
    ; Put sprite 0 into the scratch area
	ld hl, SPRITE_ATTRIBS_AREA + 0*SPR_PARAMS_LEN	;416d	21 8d e1
	ld de, SPRITE_SWITCH_SCRATCH		            ;4170	11 46 e5
	ld bc, SPR_PARAMS_LEN		                    ;4173	01 04 00
	ldir		                                    ;4176	ed b0
    ; Put sprite 4 into sprite 1
	ld hl, SPRITE_ATTRIBS_AREA + 4*SPR_PARAMS_LEN	;4178	21 9d e1
	ld de, SPRITE_ATTRIBS_AREA		                ;417b	11 8d e1
	ld bc, SPR_PARAMS_LEN		                    ;417e	01 04 00
	ldir		                                    ;4181	ed b0
    ; Put scratch area into sprite 4
	ld hl, SPRITE_SWITCH_SCRATCH		            ;4183	21 46 e5
	ld de, SPRITE_ATTRIBS_AREA + 4*SPR_PARAMS_LEN	;4186	11 9d e1
	ld bc,SPR_PARAMS_LEN		                    ;4189	01 04 00
	ldir		                                    ;418c	ed b0
l418eh:
    ; Write sprite attribs in RAM to the VDP
	ld hl,VRAM_SPRITES_ATTRIB_TABLE		    ;418e	21 00 1b
	call SETWRT		                        ;4191	cd 53 00
	ld hl,SPRITE_ATTRIBS_AREA		        ;4194	21 8d e1
	ld a,(VDP_WRITE)		                ;4197	3a 07 00
	ld c,a			                        ;419a	4f
	ld b,TOTAL_SPRITES * SPR_PARAMS_LEN 	;419b	06 80   32 sprites, each entry 4 bytes
l419dh:
	outi		        ;419d	ed a3
	jr nz,l419dh		;419f	20 fc

    ; Jump to the right transition
	ld a,(GAME_TRANSITION_ACTION)		;41a1	3a 0a e0
	
    ; HL = GAME_TRANSITION_JUMP_TABLE + 2*GAME_TRANSITION_ACTION
    ld l,a			                    ;41a4	6f
	ld h, 0		                        ;41a5	26 00
	add hl,hl			                ;41a7	29
	ld de,GAME_TRANSITION_JUMP_TABLE	;41a8	11 b1 41
	add hl,de			                ;41ab	19
    
    ; DE = GAME_TRANSITION_JUMP_TABLE[2*GAME_TRANSITION_ACTION]
	ld e,(hl)			                ;41ac	5e
	inc hl			                    ;41ad	23
	ld d,(hl)			                ;41ae	56
	
    ; Jump to GAME_TRANSITION_JUMP_TABLE[2*GAME_TRANSITION_ACTION]
    ex de,hl			                ;41af	eb
	jp (hl)			                    ;41b0	e9

; Table for the parametrized jump at 41b0
GAME_TRANSITION_JUMP_TABLE:
    dw TRANSITION_START_LEVEL  ; GAME_TRANSITION_ACTION_START_LEVEL
    dw TRANSITION_PLAY_LEVEL   ; GAME_TRANSITION_ACTION_PLAY_LEVEL
    dw TRANSITION_NEXT_LEVEL   ; GAME_TRANSITION_ACTION_NEXT_LEVEL

; And its three actions:
TRANSITION_START_LEVEL:
    ; Enable the screen and draw the title's screen
    call ENASCR                 ;41b7
	call DRAW_TITLE_SCREEN	    ;41ba	cd 8a 4b
	jp go_on_after_transition	;41bd	c3 da 41
    
TRANSITION_PLAY_LEVEL:
	call EXECUTE_VAUS_ACTION_AND_LASERS_STEP_AND_PORTAL_ANIMATION   ;41c0	cd 35 68    Several functions in one call
	call UPDATE_OBJECTS		                                        ;41c3	cd f4 95
	call CHECK_DEMO_TIMEOUT		                                    ;41c6	cd 41 72
	
    ; Scores of the right
    ld a, 1 		            ;41c9	3e 01
	ld (SCORE_POSITION),a		;41cb	32 44 e5

    ; Draw scores and go on
	call DRAW_SCORE_NUMBERS		;41ce	cd b9 53
	jp go_on_after_transition	;41d1	c3 da 41

TRANSITION_NEXT_LEVEL:
	call NEXT_OR_SAME_LEVEL		;41d4	cd 94 7b
	jp go_on_after_transition	;41d7	c3 da 41

go_on_after_transition:
    ; Read a sound number from the table
	ld hl,SOUNDS_BUFFER		;41da	21 20 e5
	ld a,(hl)		        ;41dd	7e
    
    ; Done if it's zero
	or a			        ;41de	b7
	jp z,l40d7h		        ;41df	ca d7 40

    ; Play the sound
	ld (SOUND_NUMBER),a	    ;41e2	32 c0 e5
	call PLAY_SOUND		    ;41e5	cd e8 b4

	ei			            ;41e8	fb
    
    ; Overwrite the sound code in the table with a zero
	ld (hl), 0	;41e9	36 00

    ; Clear 7 values in the table
	inc hl			;41eb	23
	ld b, 7		    ;41ec	06 07
l41eeh:
	ld a,(hl)		;41ee	7e
	dec hl			;41ef	2b
	ld (hl),a		;41f0	77
	inc hl			;41f1	23
	inc hl			;41f2	23
	djnz l41eeh		;41f3	10

	dec hl			;41f5	2b
	ld (hl), 0		;41f6	36 00

    ; Sound done, decrement counter
	ld hl,SOUNDS_COUNT		;41f8	21 1e e5
	dec (hl)			    ;41fb	35 	5
    
    ; Done
	jp l40d7h		        ;41fc	c3 d7 40

FILL_COLORS_ALL_SCREEN:
	ld de,TITLE_COLORS_COMPRESSED   ;41ff	11 f4 93
	ld hl,02000h + 0 * 32*24*8/3    ;4202	21 00 20
	call DECOMPRESS_TILE_COLORS	    ;4205	cd 89 43

	ld de,TITLE_COLORS_COMPRESSED   ;4208	11 f4 93
	ld hl,02000h + 1 * 32*24*8/3    ;420b	21 00 28
	call DECOMPRESS_TILE_COLORS	    ;420e	cd 89 43

	ld de,TITLE_COLORS_COMPRESSED   ;4211	11 f4 93
	ld hl,02000h + 2 * 32*24*8/3    ;4214	21 00 30
	call DECOMPRESS_TILE_COLORS		;4217	cd 89 43
	ret			                    ;421a	c9

PAUSE_STR:
    db "PAUSE"

; Perform a LDIRVM of one third of 32x24 chars
LDIRVM_32x24_THIRD:
	ld bc, 32*24*8/3	;4220	01 00 08
	call LDIRVM		    ;4223	cd 5c 00
	ret			        ;4226	c9

; Clear the screen and the area in FALLING_CAPSULE_SPR_PARAMS
CLEAR_SCREEN:
    ; Clear name table
	ld hl,01800h		;4227	21 00 18
	ld bc,00300h		;422a	01 00 03
	xor a			    ;422d	af
	call FILVRM		    ;422e	cd 56 00

    ; Clear sprites attribute table
	ld hl,VRAM_SPRITES_ATTRIB_TABLE		;4231	21 00 1b
	ld bc, 128		                ;4234	01 80 00
	ld a,192		                ;4237	3e c0
	call FILVRM		                ;4239	cd 56 00

    ; Clear memory
	ld hl,SPR_PARAMS_BASE - SPR_PARAMS_LEN	;423c	21 c9 e0
	ld de,0e0cah		;423f	11 ca e0
	ld bc,128		    ;4242	01 80 00
	ld (hl),192		    ;4245	36 c0
	ldir		        ;4247	ed b0
	ret			        ;4249	c9

VDP_HOOK_HANDLER:
	call RDVDP		;424a	cd 3e 01
	call sub_b594h_sound	;424d	cd 94 b5
    
    ; Read keyboard matrix and obtain these keys:
    ; STOP, GRAPH, STOP,  CURSOR RIGHT, CURSOR LEFT, CURSOR DOWN, CURSOR UP.    
    
    ; Read line 6, bit 2: GRAPH
	ld a, 6		    ;4250	3e 06
	call SNSMAT		;4252	cd 41 01
	and 4		    ;4255	e6 04       0000.0100

    ; E = GRAPH in bit 1
	rra			    ;4257	1f  Put it in bit 1
	ld e,a			;4258	5f
    
    ; Read line 8, bits 7 (right), 6 (down), 5 (up), 4 (left), and 0 (space).
    ; 1111.0001
    ld a, 8		    ;4259	3e 08
	call SNSMAT		;425b	cd 41 01
	and 0f1h		;425e	e6 f1       1111.0001
    
    ; OR the GRAPH in bit 1
	or e			;4260	b3
    
    ; V = 1111.0011
    
    ; Now we have in A:
    ; B7: right
    ; B6: down
    ; B5: up
    ; B4: left
    ; B3: 0
    ; B2: 0
    ; B1: GRAPH
    ; B0: SPACE
    
	ld e,a			;4261	5f      E = (R, D, U, L, 0, 0, G, S)

	sra a		    ;4262	cb 2f   A = (R, R, D, U, L, 0, 0, G), carry=S

	and 0b8h		;4264	e6 b8   10111000    A = (R, 0, D, U, L, 0, 0, 0), carry=0

	ld d,a			;4266	57      D = (R, 0, D, U, L, 0, 0, 0)

    ; A = (R, 0, D, U, L, 0, 0, 0)
    ; carry = 0

	rla			    ;4267

    ; A = (0, D, U, L, 0, 0, 0, 0)
    ; carry=R

	rla			    ;4268

    ; A = (D, U, L, 0, 0, 0, 0, R)
    ; carry=0

	rla			    ;4269

    ; A = (U, L, 0, 0, 0, 0, R, 0)
    ; carry=D
        
	and 040h		;426a	e6 40        0  1  0  0  0  0  0  0
    
    ; A = (0, L, 0, 0, 0, 0, 0, 0)

	or d			;426c	b2
    
    ; (0, L, 0, 0, 0, 0, 0, 0)
    ; OR
    ; (R, 0, D, U, L, 0, 0, 0)
    ; ------------------------
    ; (R, L, D, U, L, 0, 0, 0)
    
	ld d,a			;426d	57
    
    ; D = (R, L, D, U, L, 0, 0, 0)
    
	ld a,e			;426e	7b

    ; A = (R, D, U, L, 0, 0, G, S)
    
	and 003h		;426f	e6 03 	. . 

    ; A = (0, 0, 0, 0, 0, 0, G, S)

	or d			;4271	b2

    ; A = (0, 0, 0, 0, 0, 0, G, S)
    ; OR
    ; D = (R, L, D, U, L, 0, 0, 0)
    ; ----------------------------
    ;     (R, L, D, U, L, 0, G, S)

    ; A = (R, L, D, U, L, 0, G, S)
	rrca			;4272	0f
    ; A = (S, R, L, D, U, L, 0, G)
    rrca			;4273	0f
    ; A = (G, S, R, L, D, U, L, 0)
	rrca			;4274	0f
    ; A = (0, G, S, R, L, D, U, L)
	rrca			;4275	0f
    ; A = (L, 0, G, S, R, L, D, U)
    
	cpl			    ;4276	2f  Active keys are now 1
    
	and 03fh		;4277	e6 3f   0011.1111
    
    ; A = (0, 0, G, S, R, L, D, U)
    
	jp l427ch		;4279	c3 7c 42    ; Useless...
l427ch:
	ld e,a			;427c	5f
    
    ; E = (0, 0, G, S, R, L, D, U)
    
	ld a, 7		    ;427d	3e 07
	call SNSMAT		;427f	cd 41 01
    
    ; A = (RET, SELECT, BS,	STOP, TAB, ESC, F5, F4)
	rla			    ;4282	17
    ; A = (SELECT, BS,	STOP, TAB, ESC, F5, F4, x)
	rla			    ;4283	17
    ; A = (BS,	STOP, TAB, ESC, F5, F4, x, x)

	cpl			    ;4284	2f  Active keys are now 1
    
	and 040h		;4285	e6 40   0100.0000
    
    ; A = (0, STOP, 0, 0, 0, 0, 0, 0)
	
    or e			;4287	b3
    
    ; (0, STOP, 0, 0, 0, 0, 0, 0)
    ; OR
    ; (0,     0,G, S, R, L, D, U)
    ; ---------------------------
    ; (0, STOP, G, S, R, L, D, U)

	ld e,a			;4288	5f
    
    ; E = (0, STOP, G, S, R, L, D, U)
    
	ld hl,KEYBOARD_INPUT		;4289	21 c0 e0
	ld a,(hl)			        ;428c	7e  A = keys
    
    ; A = (0, STOP1, G1, S1, R1, L1, D1, U1)
    
    ; KEYBOARD_INPUT <-- (0, STOP, G, S, R, L, D, U)
	ld (hl),e			        ;428d	73
    
	and 0f0h		;428e	e6 f0
    ; A = (0, STOP1, G1, S1, 0, 0, 0, 0)
    
	and e			;4290	a3
    ; (0, STOP, G, S,  0, 0, 0, 0)
    ; AND
    ; (0, STOP, G, S,  R, L, D, U)
    ; ---------------------------
    ; (0, STOP, G, S,  0, 0, 0, 0)
    
	xor e			;4291	ab
    ;  b7  b6  b5 b4  b3 b2 b1 b0 
    ; (0, STOP, G, S,  R, L, D, U)

	ld (CONTROLS),a		;4292	32 bf e0
	ld b,a			    ;4295	47

    ; Keep going if we're in the title screen
	ld a,(GAME_STATE)		;4296	3a 0b e0
	or a			        ;4299	b7
	jp nz,l42fch		    ;429a	c2 fc 42

    ; Check cheat...

    ; Check if UP key is pressed...
	bit 0,b		    ;429d	cb 40
	jp z,l42bbh		;429f	ca bb 42
    ; Check if DOWN key is pressed...
	bit 1,b		;42a2	cb 48
	jp z,l42bbh		;42a4	ca bb 42
    ; Check if GRAPH key is pressed...
	bit 5,b		    ;42a7	cb 68
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
    ;  7   6    5  4   3  2  1  0
    ; (0, STOP, G, S,  R, L, D, U)
    
    ; Check if the LEFT key is pressed...
	bit 2,b		    ;42bb	cb 50
	jp z,l42d9h		;42bd	ca d9 42
    ; Check if the RIGHT key is pressed...
	bit 3,b		    ;42c0	cb 58
	jp z,l42d9h		;42c2	ca d9 42
    ; Check if the GRAPH key is pressed...
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
    ; Check if the SPACE key is pressed...
	bit 4,b		    ;42d9	cb 60
	jp z,l42fch		;42db	ca fc 42

    ; Jump if GAME_TRANSITION_ACTION == GAME_TRANSITION_ACTION_START_LEVEL
	ld a,(GAME_TRANSITION_ACTION)		;42de	3a 0a e0
	or a			                    ;42e1	b7
	jp z,l42f6h		                    ;42e2	ca f6 42

    ; GAME_TRANSITION_ACTION <-- GAME_TRANSITION_ACTION_START_LEVEL
	xor a			                    ;42e5	af
	ld (GAME_TRANSITION_ACTION),a		;42e6	32 0a e0

    ; Clear memory
	ld hl,BRICK_HIT_ROW		    ;42e9	21 3c e5
	ld de,BRICK_HIT_ROW+1		;42ec	11 3d e5
	ld (hl), 0		            ;42ef	36 00
	ld bc,7		                ;42f1	01 07 00
	ldir		                ;42f4	ed b0
l42f6h:
    ; Use cursors, not the paddle
	ld a, 0		                 ;42f6	3e 00
	ld (USE_VAUS_PADDLE),a		;42f8	32 0c e0
	ret			                ;42fb	c9

l42fch:
    ; Read the joystick port
	ld a, 14		;42fc	3e 0e   PSG joystick port
	out (0a0h),a	;42fe	d3 a0
	in a,(0a2h)		;4300	db a2
    
	ld h,a		;4302	67
	ld b, 8		;4303	06 08   9 bits in serial
	ld c, 0		;4305	0e 00
	ld e, 0		;4307	1e 00

; This loop reads the 9 bits in serial from the paddle
l4309h:
    ; Choose PSG register 15
	ld a, 15		;4309	3e 0f
	out (0a0h),a	;430b	d3 a0
    
    ; Write value 0x1e to register 15
    ; 0x1e = 0001.1110
	ld a,01eh		;430d	3e 1e
	out (0a1h),a	;430f	d3 a1
l4311h:
    ; Write value 0x1f to register 15
    ; 0x1e = 0001.1111
	ld a,01fh		;4311	3e 1f
	out (0a1h),a	;4313	d3 a1
    
    ; Read the joystick port
	ld a, 14		;4315	3e 0e
	out (0a0h),a	;4317	d3 a0
	in a,(0a2h)		;4319	db a2
	
    ld e,a		;431b	5f
	srl a		;431c	cb 3f
	rl c		;431e	cb 11
    ; Next bit
	djnz l4309h		;4320	10 e7

l4322h:
    ; Store paddle count (9 bits)
	ld a,c			        ;4322	79
	ld (PADDLE_COUNT),a		;4323	32 c1 e0
	ld a,h			        ;4326	7c
	and 1		            ;4327	e6 01
	ld (PADDLE_COUNT+1),a	;4329	32 c2 e0    
    
	ld a,00fh		;432c	3e 0f
	out (0a0h),a	;432e	d3 a0
	ld a,01fh		;4330	3e 1f
	out (0a1h),a	;4332	d3 a1
	ld a,00fh		;4334	3e 0f
	out (0a1h),a	;4336	d3 a1
	ld a,01fh		;4338	3e 1f
	out (0a1h),a	;433a	d3 a1

    ; Read the joystick port
	ld a, 14		;433c	3e 0e
	out (0a0h),a	;433e	d3 a0
	in a,(0a2h)		;4340	db a2

    ; ToDO
    ; I think PADDLE_STATUS+1 is used to know if it's the Vaus paddle or
    ; a normal joystick.
    ; And PADDLE_STATUS seems unused.
	ld e,a			        ;4342	5f
	ld hl,PADDLE_STATUS		;4343	21 c4 e0
	ld a,(hl)			    ;4346	7e
	ld (hl),e			    ;4347	73
	and 00fh		        ;4348	e6 0f
	and e			        ;434a	a3
	xor e			        ;434b	ab
	ld (PADDLE_STATUS+1),a	;434c	32 c5 e0
	ld b,a			        ;434f	47

    ; Exit if we're not in the title screen
	ld a,(GAME_STATE)		;4350	3a 0b e0
	or a			        ;4353	b7
	ret nz			        ;4354	c0

    ; Exit depending on paddel status
	bit 1,b		    ;4355	cb 48
	ret z			;4357	c8

    ; Jump if GAME_TRANSITION_ACTION == GAME_TRANSITION_ACTION_START_LEVEL
	ld a,(GAME_TRANSITION_ACTION)		;4358	3a 0a e0
	or a			                    ;435b	b7
	jp z,l4370h		                    ;435c	ca 70 43

    ; GAME_TRANSITION_ACTION <-- GAME_TRANSITION_ACTION_START_LEVEL
	xor a			                ;435f	af
	ld (GAME_TRANSITION_ACTION),a	;4360	32 0a e0

    ; Reset variables
	ld hl,BRICK_HIT_ROW		;4363	21 3c e5
	ld de,BRICK_HIT_ROW+1	;4366	11 3d e5
	ld (hl), 0		        ;4369	36 00
	ld bc, 7		        ;436b	01 07 00
	ldir		            ;436e	ed b0
l4370h:
    ; Use the paddle, not cursors
	ld a, 1		            ;4370	3e 01
	ld (USE_VAUS_PADDLE),a	;4372	32 0c e0
	ret			            ;4375	c9

; VDP base pointers
; See https://www.msx.org/wiki/System_variables_and_work_area
VDP_BASE_POINTERS:
    dw 0x1800 ; Name table
    dw 0x2000 ; Color table
    dw 0x0000 ; Pattern table
    dw 0x1b00 ; Sprite attribute table
    dw VRAM_SPRITES_PATTERN_TABLE ; Sprite pattern table

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

; Decompress tile colors
DECOMPRESS_TILE_COLORS:
    ; HL = 0x2000, 0x2800, 0x3000
    ; Obtain upper limit by adding 8 to H.
    ; For example, HL = 0x2000 ==> limit at 0x2800
	ld a,h			;4389	7c
	add a,8		    ;438a	c6 08
	ld b,a			;438c	47
	ld c,l			;438d	4d

l438eh:
    ; Exit if limit reached
	ld a,h			;438e	7c
	cp b			;438f	b8
	ret z			;4390	c8

    ; Read value v and check if v < 16.
	ld a,(de)		;4391	1a
	and 0xf0		;4392	e6 f0   1111.0000

	cp 0		    ;4394	fe 00
	jr z,l43a0h		;4396	28 08   Jump if v < 16

    ; v >= 16
    ; Write the value to VRAM as is, and keep iterating
	ld a,(de)		;4398	1a
	call WRTVRM		;4399	cd 4d 00
	inc hl			;439c	23
	inc de			;439d	13
	jr l438eh		;439e	18 ee

l43a0h:
    ; v < 16: compressed
	push bc			;43a0	c5
    
    ; Read value
	ld a,(de)		;43a1	1a
	and 0x0f		;43a2	e6 0f   0000.1111
    
    ; Read the number of repetions in BC
	ld c,a			;43a4	4f
	inc de			;43a5	13
    
	ld a,(de)		;43a6	1a  
	ld b,a			;43a7	47
    
    ; Read the value
	inc de			;43a8	13
	ld a,(de)		;43a9	1a  A = value
    
    ; Now use the shadow registers
	ex af,af'		;43aa	08
	inc de			;43ab	13
    
	ld a,(de)		;43ac	1a  A' = value'
    inc de			;43ad	13
	
    ; Back to normal registers
    ex af,af'		;43ae	08
    
    ; Decrement the 16-bit counter in BC
	inc b			;43af	04
	dec b			;43b0	05
	jr nz,l43b4h	;43b1	20 01
	dec c			;43b3	0d

; Write BC times value and value'
l43b4h:
    ; Write value to VRAM
	call WRTVRM		;43b4	cd 4d 00
	inc hl			;43b7	23

    ; Write value' to VRAM
    ; Shadow regs
	ex af,af'		;43b8	08
	call WRTVRM		;43b9	cd 4d 00
	inc hl			;43bc	23
    ; Normal regs
	ex af,af'		;43bd	08
    
    ; Iterate with BC
	djnz l43b4h		;43be	10 f4
	dec c			;43c0	0d 	. 
	jp p,l43b4h		;43c1	f2 b4 43

	pop bc			;43c4	c1
    
    ; Keep iterating until all the tiles have been decompressed
	jr l438eh		;43c5	18 c7
    
    ; Dead code...
    ; It's the same, actually
	ld a,h			;43c7	7c
	add a,008h		;43c8	c6 08
	ld b,a			;43ca	47
	ld c,l			;43cb	4d
l43cch:
	ld a,h			;43cc	7c
	cp b			;43cd	b8
	ret z			;43ce	c8
	ld a,(de)		;43cf	1a
	and 0f0h		;43d0	e6 f0
	cp 000h		    ;43d2	fe 00
	jr z,l43dch		;43d4	28 06
	ld a,(de)		;43d6	1a
	ld (hl),a		;43d7	77
	inc hl			;43d8	23
	inc de			;43d9	13
	jr l43cch		;43da	18 f0
l43dch:
	push bc			;43dc	c5
	ld a,(de)		;43dd	1a
	and 00fh		;43de	e6 0f
	ld c,a			;43e0	4f
	inc de			;43e1	13
	ld a,(de)		;43e2	1a
	ld b,a			;43e3	47
	inc de			;43e4	13
	ld a,(de)		;43e5	1a
	ex af,af'		;43e6	08
	inc de			;43e7	13
	ld a,(de)		;43e8	1a
	inc de			;43e9	13
	ex af,af'		;43ea	08
	inc b			;43eb	04
	dec b			;43ec	05
	jr nz,l43f0h	;43ed	20 01
	dec c			;43ef	0d
l43f0h:
	ld (hl),a		;43f0	77
	inc hl			;43f1	23
	ex af,af'		;43f2	08
	ld (hl),a		;43f3	77
	inc hl			;43f4	23
	ex af,af'		;43f5	08
	djnz l43f0h		;43f6	10 f8
	dec c			;43f8	0d
	jp p,l43f0h		;43f9	f2 f0 43
	pop bc			;43fc	c1
	jr l43cch		;43fd	18 cd

; Complete the unrolled tables of brick actions for all 32 levels
FILL_BRICK_ACTION_TABLE:
    ; Here BRICK_HIT_ROW is a LEVEL counter
    
    ; LEVEL <-- 0
	xor a			        ;43ff	af
	ld (BRICK_HIT_ROW),a	;4400	32 3c e5
l4403h:
	ld a,(BRICK_HIT_ROW)	;4403	3a 3c e5
l4406h:
    ; DE = TBL_BRICK_ACTION_TABLE_OFFSETs_COPY[2*LEVEL]
	ld l,a		    ;4406	6f
	ld h, 0		    ;4407	26 00
	add hl,hl		;4409	29
	push hl			;440a	e5
	ld de,TBL_BRICK_ACTION_TABLE_OFFSETs_COPY	;440b	11 45 44
	add hl,de		;440e	19
	ld e,(hl)		;440f	5e
	inc hl			;4410	23
	ld d,(hl)		;4411	56
	pop hl			;4412	e1

    ; HL = COMPRESSED_BRICK_ACTIONS_PER_LEVEL[2*LEVEL]
	ld bc,COMPRESSED_BRICK_ACTIONS_PER_LEVEL		;4413	01 85 44
	add hl,bc			;4416	09
	ld c,(hl)			;4417	4e
	inc hl			    ;4418	23
	ld b,(hl)			;4419	46
	push bc			    ;441a	c5
	pop hl			    ;441b	e1

l441ch:
    ; Read the count.
    ; RLE compression for repeated bricks
	ld a,(hl)		;441c	7e      V <-- read COMPRESSED_BRICK_ACTIONS_PER_LEVEL
	and 00fh		;441d	e6 0f
	ld b,a			;441f	47      B <-- V & 0x0f. We keep the 4 LSB 

    ; Read the value
	ld a,(hl)	;4420	7e          V <-- read COMPRESSED_BRICK_ACTIONS_PER_LEVEL
	and 0f0h	;4421	e6 f0       V <-- V & 0x0f
	srl a		;4423	cb 3f
	srl a		;4425	cb 3f
	srl a		;4427	cb 3f
	srl a		;4429	cb 3f       V <-- V \ 16. We keep the 4 MSB
l442bh:
    ; Write the bricks "unrolled".
    ; This is used to identify the brick type and take the appropriate action.
	ld (de),a		;442b	12
	inc de			;442c	13
	djnz l442bh		;442d	10 fc

	; Next brick.
    ; Done if it's 0xff.
    inc hl			    ;442f	23
	ld a,(hl)		    ;4430	7e
	cp 0xff		        ;4431	fe ff
	jp nz,l441ch		;4433	c2 1c 44

    ; Increment LEVEL
    ; If it's 32, done. If not, next level
	ld hl,BRICK_HIT_ROW	;4436	21 3c e5
	inc (hl)			;4439	34
	ld a,(hl)			;443a	7e
	cp 32		        ;443b	fe 20
	jp nz,l4403h		;443d	c2 03 44

    ; LEVEL <-- 0
	xor a			        ;4440	af
	ld (BRICK_HIT_ROW),a	;4441	32 3c e5
	ret			            ;4444	c9


; TBL_BRICK_ACTION_TABLE_OFFSETs_COPY: ; 0x4445
; ...
; Pointers to the brick action tables (unrolled from COMPRESSED_BRICK_ACTIONS_PER_LEVEL),
; per level.
; 0x4445

; COMPRESSED_BRICK_ACTIONS_PER_LEVEL: ; 4485
; ...
; Compressed brick actions per level
; First nibble: count
; Second nibble: data
include 'compressed_brick_actions_per_level.asm'

DRAW_TITLE_SCREEN:
    ; Go on if we're at the title's screen
	ld a,(GAME_STATE)   ;4b8a	3a 0b e0
	or a			    ;4b8d	b7
	jp nz,l4d09h		;4b8e	c2 09 4d

    ; If in demo, go to show the story's text and start the demo
	ld a,(IN_DEMO)		;4b91	3a 0d e0
	or a			    ;4b94	b7
	jp nz,l4eddh		;4b95	c2 dd 4e

    ; Switch according to BRICK_HIT_ROW
	ld a,(BRICK_HIT_ROW)		            ;4b98	3a 3c e5
	cp TITLE_SCREEN_ACTION_WAIT_IN_TITLE_SCREEN	;4b9b	fe 01
	jp z,l4c48h		                            ;4b9d	ca 48 4c
    
	cp TITLE_SCREEN_ACTION_START_GAME		    ;4ba0	fe 02
	jp z,l4cc6h		                            ;4ba2	ca c6 4c
	cp TITLE_SCREEN_ACTION_DEMO		            ;4ba5	fe 05
    
	jp z,l4ca2h		                            ;4ba7	ca a2 4c
    
    ; Set border color to black and clear the screen
    ld a, 0		        ;4baa	3e 00
	ld (BDRCLR),a		;4bac	32 eb f3

	call CHGCLR		    ;4baf	cd 62 00
	call CLEAR_SCREEN	;4bb2	cd 27 42

    ; Draw the title's screen

    ; Fill pattern table (1/3)
	ld hl,TITLE_TILES		    ;4bb5	21 24 90
	ld de, 0 * 8*32*24/3		;4bb8	11 00 00
	call LDIRVM_32x24_THIRD		;4bbb	cd 20 42

	; Fill pattern table (2/3)
    ld hl,TITLE_TILES		    ;4bbe	21 24 90
	ld de, 1 * 8*32*24/3		;4bc1	11 00 08
	call LDIRVM_32x24_THIRD		;4bc4	cd 20 42

	; Fill pattern table (3/3)
    ld hl,TITLE_TILES		    ;4bc7	21 24 90
	ld de, 2 * 8*32*24/3		;4bca	11 00 10
	call LDIRVM_32x24_THIRD		;4bcd	cd 20 42

    ; Fill the patterns and colors
	call FILL_COLORS_ALL_SCREEN	;4bd0	cd ff 41

    ; Clear name table
	ld hl,01800h	;4bd3	21 00 18
	ld a, 0		    ;4bd6	3e 00
	ld bc, 32*24	;4bd8	01 00 03
	call FILVRM		;4bdb	cd 56 00

    call DRAW_UP_SCORES		;4bde	cd e0 4f

    ; Draw Arkanoid logo
	ld hl,ARKANOID_LOGO_CHARS		;4be1	21 3e 54
	ld de,018c0h		;4be4	11 c0 18
	ld bc,00060h		;4be7	01 60 00
	call LDIRVM		    ;4bea	cd 5c 00

    ; Write the grid inside the "Arkanoid"'s logo
	ld ix,SPR_PARAMS_BASE		            ;4bed	dd 21 cd e0
	ld (ix+SPR_PARAMS_IDX_Y), 52	        ;4bf1	dd 36 00 34
	ld (ix+SPR_PARAMS_IDX_X),148            ;4bf5	dd 36 01 94
	ld (ix+SPR_PARAMS_IDX_PATTERN_NUM),160	;4bf9	dd 36 02 a0
	ld (ix+SPR_PARAMS_IDX_COLOR),10	        ;4bfd	dd 36 03 0a

	ld a,TITLE_SCREEN_ACTION_WAIT_IN_TITLE_SCREEN		;4c01	3e 01
	ld (BRICK_HIT_ROW),a		                    ;4c03	32 3c e5

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
	ld hl,TAITO_HALF1_LOGO_CHARS		;4c2a	21 09 55
	ld de,01a2bh		;4c2d	11 2b 1a
	ld bc,0000bh		;4c30	01 0b 00
	call LDIRVM		    ;4c33	cd 5c 00

    ; Draw lower half of Taito's logo
	ld hl,TAITO_HALF2_LOGO_CHARS		;4c36	21 14 55
	ld de,01a4bh		;4c39	11 4b 1a
	ld bc,0000bh		;4c3c	01 0b 00
	call LDIRVM		    ;4c3f	cd 5c 00

    ; Reset the title ticks
	ld a, 0		        ;4c42	3e 00
	ld (TITLE_TICKS),a	;4c44	32 3f e5
	ret			        ;4c47	c9

l4c48h:
    ; TITLE_SCREEN_ACTION_WAIT_IN_TITLE_SCREEN
	ld a,(USE_VAUS_PADDLE)		;4c48	3a 0c e0
	or a			            ;4c4b	b7
	jp z,l4c5ah		            ;4c4c	ca 5a 4c    Jump if we're using the paddle

    ; Check if the paddle's button has been pressed
	ld a,(PADDLE_STATUS+1)		;4c4f	3a c5 e0
	bit 1,a		                ;4c52	cb 4f
	jp nz,l4c73h		        ;4c54	c2 73 4c
	jp start_game		            ;4c57	c3 62 4c
l4c5ah:
    ; Check if the space bar has been pressed
	ld a,(CONTROLS)		        ;4c5a	3a bf e0
	bit 4,a		                ;4c5d	cb 67
	jp nz,l4c73h		        ;4c5f	c2 73 4c
start_game:
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
	ld a,TITLE_SCREEN_ACTION_START_GAME		;4c73	3e 02
	ld (BRICK_HIT_ROW),a		            ;4c75	32 3c e5

    ; Print "GAME START"
	ld hl,GAME_START_STR	    ;4c78	21 cc 54
	ld de,0x1800 + 8 + 13*32	;4c7b	11 a8 19 Locate at [8, 13]
	ld bc, 17		            ;4c7e	01 11 00
	call LDIRVM		            ;4c81	cd 5c 00

    ; Play the "game start" music
	ld a,SOUND_GAME_START_MUSIC		;4c84	3e c3
	ld (SOUND_NUMBER),a		        ;4c86	32 c0 e5
	call PLAY_SOUND		            ;4c89	cd e8 b4

    ; Wait 256 ticks
	ei			            ;4c8c	fb
	ld hl, 256  		    ;4c8d	21 00 01
	call DELAY_HL_TICKS		;4c90	cd 80 43
	ret			            ;4c93	c9

l4c94h:
	ld a,TITLE_SCREEN_ACTION_DEMO	;4c94	3e 05
	ld (BRICK_HIT_ROW),a		    ;4c96	32 3c e5

	; Set we're in the demo
    ld a, 1		        ;4c99	3e 01
	ld (IN_DEMO),a		;4c9b	32 0d e0
    
	call CLEAR_SCREEN	;4c9e	cd 27 42
	ret			        ;4ca1	c9

l4ca2h:
    ; TITLE_SCREEN_ACTION_GOTO_TITLE_SCREEN

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
    ; BRICK_REPAINT_INITIAL
	xor a			            ;4cbb	af
	ld (BRICK_REPAINT_TYPE),a	;4cbc	32 22 e0
	jp l4d09h		            ;4cbf	c3 09 4d
DEMO_LEVELS_TABLE:
    db 12, 3, 6, 1

l4cc6h:
    ; TITLE_SCREEN_ACTION_START_GAME

    ; Set we're in normal play
	ld a, 1		            ;4cc6	3e 01
	ld (GAME_STATE),a		;4cc8	32 0b e0


    ; Clear variables
	ld hl,SCORE_BCD		;4ccb	21 15 e0
	ld de,SCORE_BCD+1	;4cce	11 16 e0
	ld bc, 1439		    ;4cd1	01 9f 05
	dec bc			    ;4cd4	0b
	ld (hl), 0	        ;4cd5	36 00
	ldir		        ;4cd7	ed b0
    
    ; Set that next points objective for a life if 20000
	ld a, 0x20		;4cd9	3e 20
	ld (0e01fh),a	;4cdb	32 1f e0

    ; We start normally with 2 lives
	ld c, 2		    ;4cde	0e 02

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
	cp BRICK_REPAINT_REMAINING      ;4d0c	fe 02
	jp z,l4d22h		                ;4d0e	ca 22 4d

    ; Clear variables
	ld hl,BRICK_MAP		;4d11	21 27 e0
	ld de,BRICK_MAP+1	;4d14	11 28 e0
	ld bc,0058dh		;4d17	01 8d 05
	dec bc			    ;4d1a	0b
	ld (hl), 0		    ;4d1b	36 00
	ldir		        ;4d1d	ed b0

	jp l4d30h		    ;4d1f	c3 30 4d
l4d22h:
    ; Clear variables
	ld hl,CONTROLS		;4d22	21 bf e0
	ld de,KEYBOARD_INPUT		    ;4d25	11 c0 e0
	ld bc,004f5h		            ;4d28	01 f5 04
	dec bc			                ;4d2b	0b
	ld (hl),0   		            ;4d2c	36 00
	ldir		                    ;4d2e	ed b0
l4d30h:
	call CLEAR_SCREEN		;4d30	cd 27 42
    
    ; Skip drawing scores and waiting if we're at the title screen
	ld a,(GAME_STATE)		;4d33	3a 0b e0
	or a			        ;4d36	b7
	jp z,l4d46h		        ;4d37	ca 46 4d
	
    call DRAW_UP_SCORES		;4d3a	cd e0 4f
    ; Write "ROUND 1"
	call DRAW_ROUND_MESSAGE ;4d3d	cd 01 51

    ; Wait 48 ticks
	ld hl, 48		        ;4d40	21 30 00
	call DELAY_HL_TICKS		;4d43	cd 80 43
l4d46h:
	ld a, GAME_TRANSITION_ACTION_PLAY_LEVEL		;4d46	3e 01
	ld (GAME_TRANSITION_ACTION),a		        ;4d48	32 0a e0

    ; Load in-game patterns into VRAM

    ; Fill pattern table (1/3)
	ld hl,IN_GAME_TILES		    ;4d4b	21 84 7d
	ld de, 0 * 8*32*24/3	    ;4d4e	11 00 00
	call LDIRVM_32x24_THIRD	    ;4d51	cd 20 42

	; Fill pattern table (21/3)
    ld hl,IN_GAME_TILES		    ;4d54	21 84 7d
	ld de, 1 * 8*32*24/3	    ;4d57	11 00 08
	call LDIRVM_32x24_THIRD	    ;4d5a	cd 20 42

	; Fill pattern table (3/3)
    ld hl,IN_GAME_TILES		    ;4d5d	21 84 7d
	ld de, 2 * 8*32*24/3		;4d60	11 00 10
	call LDIRVM_32x24_THIRD		;4d63	cd 20 42

    ; Decompress colors
	ld de,IN_GAME_COLORS		    ;4d66	11 84 85
	ld hl,02000h + 0 * 8*32*24/3	;4d69	21 00 20
	call DECOMPRESS_TILE_COLORS		;4d6c	cd 89 43

	ld de,IN_GAME_COLORS		    ;4d6f	11 84 85
	ld hl,02000h + 1 * 8*32*24/3	;4d72	21 00 28
	call DECOMPRESS_TILE_COLORS		;4d75	cd 89 43

	ld de,IN_GAME_COLORS		    ;4d78	11 84 85
	ld hl,02000h + 2 * 8*32*24/3	;4d7b	21 00 30
	call DECOMPRESS_TILE_COLORS		;4d7e	cd 89 43

    ; Clear screen
	ld hl,01800h	;4d81	21 00 18
	ld a, 0		    ;4d84	3e 00
	ld bc, 32*24	;4d86	01 00 03
	call FILVRM		;4d89	cd 56 00

    ; Draw score numbers on the right
	ld a, 1 		            ;4d8c	3e 01
	ld (SCORE_POSITION),a       ;4d8e	32 44 e5
	call DRAW_SCORE_NUMBERS		;4d91	cd b9 53

    ; Write "HIGH"
	ld hl,HIGH_LETTERS 		    ;4d94	21 1f 55
	ld de, 0x1800 + 25 + 1*32   ;4d97	11 39 18 Locate at [25, 1]
	ld bc,4     		        ;4d9a	01 04 00
	call LDIRVM		            ;4d9d	cd 5c 00

    ; Write "SCORE"
	ld hl,SCORE_LETTERS		    ;4da0	21 23 55
	ld de, 0x1800 + 27 + 2*32   ;4da3	11 5b 18 Locate at [27, 2]
	ld bc, 5	    	        ;4da6	01 05 00
	call LDIRVM		            ;4da9	cd 5c 00

    ; Write "SCORE"
    ; It uses a duplicated string: it could have used the same SCORE_LETTERS!
	ld hl, SCORE_LETTERS_DUP	    ;4dac	21 28 55
	ld de, 0x1800 + 27 + 6*32       ;4daf	11 db 18 Locate at [27, 6]
	ld bc, 5		                ;4db2	01 05 00
	call LDIRVM		                ;4db5	cd 5c 00

    ; Draw the game's frame
	call DRAW_FRAME		            ;4db8	cd 30 52

    ; Draw a trailing "0" in the HIGH SCORE
	ld hl, 0x1800 + 31 + 3*32    ;4dbb	21 7f 18
	ld a, "0"		             ;4dbe	3e 30 Locate at [31, 3]
	call WRTVRM		             ;4dc0	cd 4d 00

	; Draw a trailing "0" in the SCORE
    ld hl,0x1800 + 31 + 7*32	;4dc3	21 ff 18 Locate at [31, 7]
	ld a, "0"	                ;4dc6	3e 30
	call WRTVRM		            ;4dc8	cd 4d 00

	ld a, 0		                ;4dcb	3e 00
	ld (ROW_DRAW_COUNTER),a		;4dcd	32 6f e5

	ld b, 23		            ;4dd0	06 17
	ld iy,0x1800 + 2 + 1*32     ;4dd2	fd 21 22 18     Locate at [2, 1]
l4dd6h:
    ; DE = 2*ROW
	ld e,a			;4dd6	5f
	sla e		    ;4dd7	cb 23
	ld d, 0 		;4dd9	16 00
    
    ; Obtain a pointer to the row
    ; HL = VRAM_DATA_BACKGROUND_PERIODIC_PATTERNS[2*ROW]
	ld hl,VRAM_DATA_BACKGROUND_PERIODIC_PATTERNS    ;4ddb	21 b5 57
	add hl,de			;4dde	19
	ld e,(hl)			;4ddf	5e
	inc hl			    ;4de0	23
	ld d,(hl)			;4de1	56
	ex de,hl			;4de2	eb
	
    ; DE = locate address
    push iy		    ;4de3	fd e5
	pop de			;4de5	d1
    
	push bc			;4de6	c5
    ; Copy 24 - 2 (borders) patterns
	ld bc, 22		;4de7	01 16 00
	call LDIRVM		;4dea	cd 5c 00
	
    ; Next row, between 0 and 3
    ; The patterns are indeed periodic
    ld a,(ROW_DRAW_COUNTER)		;4ded	3a 6f e5
	inc a			            ;4df0	3c
	cp 4		                ;4df1	fe 04
	jr nz,l4df7h		        ;4df3	20 02
	ld a, 0		                ;4df5	3e 00
l4df7h:
	ld (ROW_DRAW_COUNTER),a		;4df7	32 6f e5

    ; Next row in the screen
	ld de, 32		;4dfa	11 20 00
	add iy,de		;4dfd	fd 19
	pop bc			;4dff	c1
	djnz l4dd6h		;4e00	10 d4

    ; Copy 3 times
	ld b, 3		         ;4e02	06 03
	ld iy,00380h		;4e04	fd 21 80 03 
l4e08h:
	ld hl,VRAM_DATA_DOH		;4e08	21 35 57
    
	ld a,(LEVEL)		;4e0b	3a 1b e0
	cp FINAL_LEVEL		;4e0e	fe 20
	jp z,l4e22h		    ;4e10	ca 22 4e
    
    ; Not final level
    ; DE = 2*(LEVEL & 3)
	and 3		;4e13	e6 03   A = LEVEL & 3
	ld e,a		;4e15	5f      E = LEVEL & 3
	ld d, 0		;4e16	16 00
	sla e		;4e18	cb 23

    ; HL = VRAM_DATA_POINTERS[2*(LEVEL & 3)]
	ld hl, VRAM_DATA_POINTERS		;4e1a	21 2d 55
	add hl,de			            ;4e1d	19
	ld e,(hl)			            ;4e1e	5e
	inc hl			                ;4e1f	23
	ld d,(hl)			            ;4e20	56
	ex de,hl			            ;4e21	eb

l4e22h:
    ; Fill VRAM tables from RAM
    
    ; DE points a location from 0x380
	push iy		    ;4e22	fd e5
	pop de			;4e24	d1

	push bc			;4e25	c5
    
    ; Set the periodic periodic patterns of 1/3 of the screen
    ; This actually sets the shapes, not the codes;
	ld bc, 128		;4e26	01 80 00
	call LDIRVM		;4e29	cd 5c 00
	pop bc			;4e2c	c1

	ld de, 2048		;4e2d	11 00 08
	add iy,de		;4e30	fd 19
	djnz l4e08h		;4e32	10 d4
    
    ; Draw the background
	call COLORIZE_BACKGROUND	;4e34	cd bd 5b

    call WRITE_ROUND_MSG		;4e37	cd 04 72

	call DRAW_LIVES		        ;4e3a	cd b9 71

	ld a,(LEVEL)		        ;4e3d	3a 1b e0
	cp FINAL_LEVEL		        ;4e40	fe 20
	jp z,l4e71h		            ;4e42	ca 71 4e

	ld hl,LEVELS_PTR_TABLE		;4e45	21 ef 5d

    ; Skip the following if we're not doing a full brick repaint
	ld a,(BRICK_REPAINT_TYPE)	;4e48	3a 22 e0
	cp BRICK_REPAINT_REMAINING  ;4e4b	fe 02
	jp z,l4e65h		            ;4e4d	ca 65 4e
    
    ; Copy current level (the bricks tilemap) to RAM
    
    ; DE = 2*LEVEL
	ld a,(LEVEL)	;4e50	3a 1b e0
	ld e,a			;4e53	5f
	sla e		    ;4e54	cb 23
	ld d, 0		    ;4e56	16 00
    
    ; HL = LEVELS_PTR_TABLE + 2*LEVEL
	add hl,de		;4e58	19

	; DE = LEVELS_PTR_TABLE[2*LEVEL]
    ld e,(hl)		;4e59	5e
	inc hl			;4e5a	23
	ld d,(hl)		;4e5b	56
    
    ; Copy bricks to RAM tilemap and draw it
	ex de,hl			;4e5c	eb  HL = LEVELS_PTR_TABLE[2*LEVEL]
	ld de,BRICK_MAP		;4e5d	11 27 e0
	ld bc,BRICK_MAP_LEN	;4e60	01 11 00
	ldir		        ;4e63	ed b0
l4e65h:
	call ADD_BRICKS_TO_TILEMAP		        ;4e65	cd 15 5c
	call DRAW_BACKGROUND_TILEMAP		    ;4e68	cd 79 5d
	call UPDATE_SPRITE_PATTERNS_ON_LEVEL	;4e6b	cd 65 51
	jp l4e74h		                        ;4e6e	c3 74 4e
l4e71h:
	call DRAW_DOH		                    ;4e71	cd 80 51
l4e74h:
    ; Full brick repaint
    ; BRICK_REPAINT_INITIAL
	xor a			                ;4e74	af
	ld (BRICK_REPAINT_TYPE),a		;4e75	32 22 e0

    ; Vaus and the READY string as sprites
	ld hl,VAUS_AND_READY_SPRITE_TABLE		;4e78	21 49 51
	ld de,VRAM_SPRITES_ATTRIB_TABLE		    ;4e7b	11 00 1b
	ld bc, 7 * 4		                    ;4e7e	01 1c 00 	7 sprites
	call LDIRVM		                        ;4e81	cd 5c 00
    
    ; Skip the following if we're at the title screen
	ld a,(GAME_STATE)		;4e84	3a 0b e0
	or a			        ;4e87	b7
	jp z,l4eb4h		        ;4e88	ca b4 4e
	
    ld a,(LEVEL)		;4e8b	3a 1b e0
	cp FINAL_LEVEL		;4e8e	fe 20
	jp z,l4ea5h		;4e90	ca a5 4e 	. . N 
	ld a,SOUND_LEVEL_START_MUSIC		;4e93	3e c4 	> . 
	ld (SOUND_NUMBER),a		;4e95	32 c0 e5 	2 . . 
	call PLAY_SOUND		;4e98	cd e8 b4 	. . . 

    ; Wait 144 ticks
	ei			            ;4e9b	fb
	ld hl, 144		        ;4e9c	21 90 00
	call DELAY_HL_TICKS		;4e9f	cd 80 43
	jp l4eb4h		        ;4ea2	c3 b4 4e
l4ea5h:
	ld a,SOUND_DOH_LEVEL_STARTS		;4ea5	3e c8 	> . 
	ld (SOUND_NUMBER),a		;4ea7	32 c0 e5 	2 . . 
	call PLAY_SOUND		;4eaa	cd e8 b4 	. . . 

    ; Wait 256 ticks
	ei			            ;4ead	fb
	ld hl,256   		    ;4eae	21 00 01
	call DELAY_HL_TICKS		;4eb1	cd 80 43
l4eb4h:
    ; Set ball active
	ld a, 1		                                ;4eb4	3e 01
	ld (BALL_TABLE1 + BALL_TABLE_IDX_ACTIVE),a  ;4eb6	32 4e e2

    ; Starting location of the ball in the demo
	ld a, 104		        ;4eb9	3e 68
	ld (BALL_X_DEMO),a		;4ebb	32 f6 e0
    
    ; We're not in the demo
	ld hl, 0		                ;4ebe	21 00 00
	ld (IN_DEMO),hl		            ;4ec1	22 0d e0

    ; Clear story-writting variables
	ld (STORY_WRITE_ROW),hl		    ;4ec4	22 0f e0
	ld (STORY_MSG_INDEX),hl	        ;4ec7	22 11 e0
	ld (STORY_ALREADY_WRITTEN),hl	;4eca	22 13 e0

    ; Clear sound
	ld a, SOUND_NOP_0	;4ecd	3e 00
	ld (SOUND_NUMBER),a	;4ecf	32 c0 e5
	call PLAY_SOUND		;4ed2	cd e8 b4

    ; Wait 1 tick
	ei			            ;4ed5	fb
	ld hl, 1    		    ;4ed6	21 01 00
	call DELAY_HL_TICKS		;4ed9	cd 80 43
	ret			            ;4edc	c9

l4eddh:
    ; In demo

    ; IY points to the strings of the story
	ld iy,STORY_STR		        ;4edd	fd 21 05 50
	ld ix,STORY_VDP_ROW_POINTERS	;4ee1	dd 21 ef 50

    ; Read controls or paddle
	ld a,(USE_VAUS_PADDLE)		;4ee5	3a 0c e0
	or a			            ;4ee8	b7
	jp z,l4ef7h		            ;4ee9	ca f7 4e

	ld a,(PADDLE_STATUS+1)		;4eec	3a c5 e0
	bit 1,a		                ;4eef	cb 4f
	jp nz,l4f6bh		        ;4ef1	c2 6b 4f    Button pressed
	jp l4effh		            ;4ef4	c3 ff 4e
l4ef7h:
	ld a,(CONTROLS)		        ;4ef7	3a bf e0
	bit 4,a		                ;4efa	cb 67
	jp nz,l4f6bh		        ;4efc	c2 6b 4f    Start pressed
l4effh:
    ; If the story's text has been already written, done
	ld hl,STORY_ALREADY_WRITTEN		;4eff	21 13 e0
	ld a,(hl)			;4f02	7e
	or a			    ;4f03	b7
	jp nz,l4f60h		;4f04	c2 60 4f
    
    ; Check the char delay counter.
    ; If not 2 already, exit
    ; This allows for a small pause between chars
	ld hl,STORY_CHAR_DELAY_COUNTER		;4f07	21 0e e0
	inc (hl)			                ;4f0a	34
	ld a,(hl)			                ;4f0b	7e
	cp 2		                        ;4f0c	fe 02
	ret nz			                    ;4f0e	c0
    
    ; Reset STORY_CHAR_DELAY_COUNTER
	ld (hl), 0		                    ;4f0f	36 00

    ; HL = STORY_VDP_ROW_POINTERS[2*STORY_WRITE_ROW]
	ld a,(STORY_WRITE_ROW)		;4f11	3a 0f e0
	ld e,a			            ;4f14	5f
	sla e		                ;4f15	cb 23
	ld d, 0		                ;4f17	16 00   DE = 2*STORY_WRITE_ROW
	add ix,de		            ;4f19	dd 19   IX = STORY_VDP_ROW_POINTERS + 2*STORY_WRITE_ROW
	ld e,(ix+0)		            ;4f1b	dd 5e 00
	ld d,(ix+1)		            ;4f1e	dd 56 01
	ex de,hl			        ;4f21	eb

	ld a,(STORY_CHAR_OF_LINE_INDEX)		;4f22	3a 10 e0
	ld e,a			                    ;4f25	5f
	ld d,000h		                    ;4f26	16 00   DE = STORY_CHAR_OF_LINE_INDEX
	add hl,de			                ;4f28	19      HL = STORY_VDP_ROW_POINTERS[2*STORY_WRITE_ROW] + STORY_CHAR_OF_LINE_INDEX

	ld a,(STORY_MSG_INDEX)		;4f29	3a 11 e0
	ld e,a			            ;4f2c	5f
	ld d, 0		                ;4f2d	16 00   DE = STORY_MSG_INDEX
	add iy,de		            ;4f2f	fd 19   Add STORY_MSG_INDEX to IY (pointer to the text)
    ; Line done then arrived at char #32
	ld a,(iy+000h)		        ;4f31	fd 7e 00
	cp 32		                ;4f34	fe 20
	jp z,l4f3ch		            ;4f36	ca 3c 4f    Jump if line done
    ; Write the character on the screen
	call WRTVRM		            ;4f39	cd 4d 00
l4f3ch:
	; Next char
    ld hl,STORY_MSG_INDEX		    ;4f3c	21 11 e0
	inc (hl)			            ;4f3f	34
    
    ; Increment counter of chars in line
	ld hl,STORY_CHAR_OF_LINE_INDEX	;4f40	21 10 e0
	inc (hl)			            ;4f43	34
    
    ; Increment counter of chars written to line
	ld hl,STORY_CHARS_WRITTEN_TO_LINE		;4f44	21 12 e0
	inc (hl)			                    ;4f47	34
    
    ; Exit if we haven't done all the chars in the line
	ld a,(hl)			        ;4f48	7e
	cp STORY_CHARS_PER_LINE		;4f49	fe 1a
	ret nz			            ;4f4b	c0

    ; All chars in the line done

    ; Reset STORY_CHARS_PER_LINE
	ld (hl), 0 		;4f4c	36 00

    ; Write next char at the beginning of the line
	xor a			                    ;4f4e	af
	ld (STORY_CHAR_OF_LINE_INDEX),a		;4f4f	32 10 e0

    ; Next row of the story.
    ; Exit if we've done already the STORY_NUM_LINES lines.
	ld hl,STORY_WRITE_ROW		;4f52	21 0f e0
	inc (hl)			        ;4f55	34

	ld a,(hl)			        ;4f56	7e
	cp STORY_NUM_LINES		    ;4f57	fe 09
	ret nz			            ;4f59	c0

    ; Notify we've already written all the story on the screen
	ld hl,STORY_ALREADY_WRITTEN		;4f5a	21 13 e0
	ld (hl), 1		                ;4f5d	36 01
	ret			                    ;4f5f	c9

l4f60h:
    ; Make a pause to see the text, before moving to the demo
	ld hl,STORY_SHOWN_PAUSE		;4f60	21 14 e0
	inc (hl)			        ;4f63	34
	ld a,(hl)			        ;4f64	7e
	cp 120		                ;4f65	fe 78
	ret nz			            ;4f67	c0
	jp l4f7ah		            ;4f68	c3 7a 4f
l4f6bh:
	ld hl,0		                ;4f6b	21 00 00
	ld (BRICK_HIT_ROW),hl		;4f6e	22 3c e5
	ld (VAUS_X2),hl		        ;4f71	22 3e e5

	ld (TITLE_TICKS+1),hl		;4f74	22 40 e5
    ld (COMPUTED_X_SPEED),hl	;4f77	22 42 e5
l4f7ah:
    ; Not in the demo anymore
	ld hl, 0		                ;4f7a	21 00 00
	ld (IN_DEMO),hl		            ;4f7d	22 0d e0

    ; Clear story-writting variables
	ld (STORY_WRITE_ROW),hl		    ;4f80	22 0f e0
	ld (STORY_MSG_INDEX),hl		    ;4f83	22 11 e0
	ld (STORY_ALREADY_WRITTEN),hl	;4f86	22 13 e0
    
    ; Done
	ret			                    ;4f89	c9

; Show the animation with the ending text
ENDING_TEXT_ANIMATION:
    ; This is called with:
    ; 	ld iy, ENDING_STR
	;   ld ix, TBL_VDP_POINTERS_LINE_ENDING_TEXT

	call CLEAR_SCREEN		    ;4f8a	cd 27 42
    
    ; They're reusing BRICK_HIT_ROW and BRICK_HIT_ROW.
    ; Here BRICK_HIT_ROW is the row and
    ; BRICK_HIT_ROW is the column.
    
    ; BRICK_HIT_ROW <-- 0
	xor a			        ;4f8d	af
	ld (BRICK_HIT_ROW),a	;4f8e	32 3c e5
l4f91h:
	push ix		            ;4f91	dd e5
	
    ; BRICK_HIT_ROW <-- 0
    xor a			        ;4f93	af
	ld (BRICK_HIT_COL),a	;4f94	32 3d e5
    
	; IX = TBL_VDP_POINTERS_LINE_ENDING_TEXT  + 2*BRICK_HIT_ROW
    ld a,(BRICK_HIT_ROW)	;4f97	3a 3c e5
	ld e,a			        ;4f9a	5f
	sla e		            ;4f9b	cb 23
	ld d, 0		            ;4f9d	16 00
	add ix,de		        ;4f9f	dd 19

    ; HL = TBL_VDP_POINTERS_LINE_ENDING_TEXT[2*BRICK_HIT_ROW]
	ld e,(ix+0)		;4fa1	dd 5e 00
	ld d,(ix+1)		;4fa4	dd 56 01    
	ex de,hl			;4fa7	eb 	. 
l4fa8h:
    ; Check if the caracter is a blank space
	ld a,(iy+0)		;4fa8	fd 7e 00
	cp " "	        ;4fab	fe 20
    
    ; If it's a space, neither write it nor make the pause
	jp z,l4fbbh		;4fad	ca bb 4f

	push hl			;4fb0	e5
    ; Write the character and make the pause
	call WRTVRM		;4fb1	cd 4d 00

    ; Wait 3 ticks
	ld hl, 3		        ;4fb4	21 03 00
	call DELAY_HL_TICKS		;4fb7	cd 80 43
	pop hl			        ;4fba	e1
l4fbbh:
    ; Next column
	inc hl		;4fbb	23
	inc iy		;4fbc	fd 23
	
    ld a,(BRICK_HIT_COL)	;4fbe	3a 3d e5
	inc a			        ;4fc1	3c
	cp 26		            ;4fc2	fe 1a
    
    ; Keep iterating columns if we haven't done 26
	ld (BRICK_HIT_COL),a		;4fc4	32 3d e5
	jp nz,l4fa8h		        ;4fc7	c2 a8 4f
    
    ; Row done
	pop ix		                ;4fca	dd e1
    
    ; Increment row number
	ld hl,BRICK_HIT_ROW		;4fcc	21 3c e5
	inc (hl)			    ;4fcf	34 	4 
    
    ; Keep executing if row != 9
	ld a,(hl)			;4fd0	7e
	cp 9		        ;4fd1	fe 09
	jp nz,l4f91h		;4fd3	c2 91 4f
    
    ; Done

    ; Pause for 1472 ticks
	ld hl, 1472		        ;4fd6	21 c0 05
	call DELAY_HL_TICKS		;4fd9	cd 80 43

    ; Clear screen and exit
	call CLEAR_SCREEN		;4fdc	cd 27 42
	ret			            ;4fdf	c9

; Draw the scores at the top of the screen
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
    db "THE ERA AND TIME OF       THIS STORY IS UNKNOWN.    AFTER THE "
    db "MOTHERSHIP      \"ARKANOID\" WAS DESTROYED, "
    db "A SPACECRAFT \"VAUS\"       SCRAMBLED AWAY FROM IT.   "
    db "BUT ONLY TO BE            TRAPPED IN SPACE WARPED   BY "
    db "SOMEONE......          "

; VDP pointers for the story rows
STORY_VDP_ROW_POINTERS: ; 0x50ef
    dw 0x1843, 0x1883, 0x18e3, 0x1923, 0x1963, 0x19a3, 0x1a03, 0x1a43, 0x1a83

; Draws the "ROUND x" message
DRAW_ROUND_MESSAGE:
    ; Write "ROUND "
	ld hl,ROUND_STR		;5101	21 44 51
	ld de,0194ch		;5104	11 4c 19
	ld bc,5		        ;5107	01 05 00
	call LDIRVM		    ;510a	cd 5c 00
l510dh:
    ; A = LEVEL_DISP + 1
	ld a,(LEVEL_DISP)		;510d	3a 1c e0
	add a,001h		        ;5110	c6 01
	daa			            ;5112	27
    
    ; E = LEVEL_DISP + 1
	ld e,a			        ;5113	5f
	push de			        ;5114	d5
    
    ; A = A >> 4
    ; This is to only consider the high nibble and put it in the
    ; low part of the byte
	srl a		            ;5115	cb 3f
	srl a		            ;5117	cb 3f
	srl a		            ;5119	cb 3f
	srl a		            ;511b	cb 3f
	
    ; Convert to an ASCII character
    add a,030h		        ;511d	c6 30

    ; Check if it's a heading zero
	cp 030h		        ;511f	fe 30
	jp nz,l5131h		;5121	c2 31 51
l5124h: ; It's a zero: just write the non-zero number
	pop de			;5124	d1  E = LEVEL_DISP + 1
	ld a,e			;5125	7b  A = LEVEL_DISP + 1
    ; A = (LEVEL_DISP + 1) & 00001111b + 0x30
	and 00fh		;5126	e6 0f
	add a,030h		;5128	c6 30
	ld hl,0x1800 + 18 + 10*32	;512a	21 52 19    Locate at [18, 10]
	call WRTVRM		;512d	cd 4d 00
	ret			    ;5130	c9
l5131h: ; It isn't a zero: write both numbers
	ld hl,0x1800 + 18 + 10*32	;5131	21 52 19    Locate at [18, 10]
	call WRTVRM		;5134	cd 4d 00
	pop de			;5137	d1
	ld a,e			;5138	7b
	and 00fh		;5139	e6 0f
	add a,030h		;513b	c6 30
	ld hl,0x1800 + 19 + 10*32	;513d	21 53 19    Locate at [19, 10]
	call WRTVRM		;5140	cd 4d 00
	ret			    ;5143	c9

ROUND_STR:
    db "ROUND"

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

; Update the sprite patterns according to the current level
UPDATE_SPRITE_PATTERNS_ON_LEVEL:
	; HL = LEVEL & 3
    ld a,(LEVEL)	;5165	3a 1b e0
	and 3		    ;5168	e6 03
	ld l,a			;516a	6f
	ld h, 0		    ;516b	26 00
    
	; HL = 2 * (LEVEL & 3)
    add hl,hl			;516d	29
    
    ; HL = SPRITE_PATTERN_POINTERS + 2 * (LEVEL & 3)
	ld de,SPRITE_PATTERN_POINTERS	;516e	11 15 58
	add hl,de			;5171	19

    ; E = SPRITE_PATTERN_POINTERS[2 * (LEVEL & 3)]
	ld e,(hl)			;5172	5e
	inc hl			    ;5173	23
    
    ; D = SPRITE_PATTERN_POINTERS[2 * (LEVEL & 3) + 1]
	ld d,(hl)			;5174	56

    ; HL points to the sprite pattern data pointer
	ex de,hl			;5175	eb

    ; Copy 4 sprite's pattern data to VRAM
    ; We copy a total of 4 sprites * 64 bytes = 256 bytes
	ld de,VRAM_SPRITES_PATTERN_TABLE + 24 * LEN_SPRITE_PATTERN    ;5176	11 00 3e
	ld bc, 4 * LEN_SPRITE_PATTERN		                          ;5179	01 00 01
	call LDIRVM		                                              ;517c	cd 5c 00
	ret			                                                  ;517f	c9

; Draw Doh
DRAW_DOH:
	ld a, 0		            ;5180	3e 00
	ld (ROW_DRAW_COUNTER),a		    ;5182	32 6f e5
	ld b, DOH_NUM_ROWS		;5185	06 0c
	ld iy,01869h		    ;5187	fd 21 69 18
l518bh:
	ld e,a			        ;518b	5f      E = row
    
    ; DE = 2*row
	sla e		            ;518c	cb 23 	E = 2*row
	ld d,0		            ;518e	16 00

    ; HL = DOH_ROW_POINTERS + 2*row
	ld hl,DOH_ROW_POINTERS		    ;5190	21 b8 51
	add hl,de			            ;5193	19

	; DE = DOH_ROW_POINTERS[2*row]
    ld e,(hl)			;5194	5e
	inc hl			    ;5195	23
	ld d,(hl)			;5196	56
    
	ex de,hl			;5197	eb      HL = DOH_ROW_POINTERS[2*row]
	push iy		        ;5198	fd e5   
	pop de			    ;519a	d1
	push bc			    ;519b	c5
    
    ; Draw a line of chars (8) of Doh
	ld bc, DOH_NUM_COLS	;519c	01 08 00
	call LDIRVM		    ;519f	cd 5c 00

    ; Increment row count
	ld a,(ROW_DRAW_COUNTER)		;51a2	3a 6f e5
	inc a			            ;51a5	3c
    
    ; Reset row index if we've done the last char
	cp DOH_NUM_ROWS		;51a6	fe 0c
	jr nz,l51ach		;51a8	20 02
	ld a, 0		        ;51aa	3e 00
l51ach:
	ld (ROW_DRAW_COUNTER),a		;51ac	32 6f e5
    
    ; Point to the next lext
	ld de, 32		                ;51af	11 20 00
	add iy,de		                ;51b2	fd 19
	pop bc			                ;51b4	c1
	djnz l518bh		                ;51b5	10 d4
	ret			                    ;51b7	c9

; Pointers to each of Doh's rows of patterns
DOH_ROW_POINTERS:
    dw DOH_ROW1, DOH_ROW2, DOH_ROW3, DOH_ROW4, DOH_ROW5, DOH_ROW6
    dw DOH_ROW7, DOH_ROW8, DOH_ROW9, DOH_ROW10, DOH_ROW11, DOH_ROW12

DOH_ROW1:
    db 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97 ; 0x51d0 - 0x51d7
DOH_ROW2:
    db 0x98, 0x99, 0x9a, 0x9b, 0x9c, 0x9d, 0x9e, 0x9f ; 0x51d8 - 0x51df
DOH_ROW3:
    db 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7 ; 0x51e0 - 0x51e7
DOH_ROW4:
    db 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf ; 0x51e8 - 0x51ef
DOH_ROW5:
    db 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7 ; 0x51f0 - 0x51f7
DOH_ROW6:
    db 0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf ; 0x51f8 - 0x51ff
DOH_ROW7:
    db 0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7 ; 0x5200 - 0x5207
DOH_ROW8:
    db 0xc8, 0xc9, 0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf ; 0x5208 - 0x520f
DOH_ROW9:
    db 0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7 ; 0x5210 - 0x5217
DOH_ROW10:
    db 0xd8, 0xd9, 0xda, 0xdb, 0xdc, 0xdd, 0xde, 0xdf ; 0x5218 - 0x521f
DOH_ROW11:
    db 0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7 ; 0x5220 - 0x5227
DOH_ROW12:
    db 0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed, 0xee, 0xef ; 0x5228 - 0x522f

; Draw the game's frame
DRAW_FRAME:
    ; Draw up frame
	ld hl,FRAME_UP_CHARS		;5230	21 71 52
	ld bc, 24		            ;5233	01 18 00
	ld de,0x1800 + 1 + 0*32		;5236	11 01 18    Locate at [1, 0]
	call LDIRVM		            ;5239	cd 5c 00

	ld b, 23		            ;523c	06 17
	ld de, 32		        ;   523e	11 20 00
    ; Draw left frame
l5241h:
	ld hl,0x1800 + 1 + 1*32		;5241	21 21 18    Locate at [1, 1]
	ld ix,FRAME_LATERAL_CHARS	;5244	dd 21 89 52
	ld a,(ix+000h)		        ;5248	dd 7e 00
l524bh:
	call WRTVRM		            ;524b	cd 4d 00
	add hl,de			        ;524e	19
	inc ix		                ;524f	dd 23
	ld a,(ix+000h)		        ;5251	dd 7e 00
	djnz l524bh		            ;5254	10 f5

    ; Draw right frame
	ld b, 23		            ;5256	06 17
	ld de, 32		            ;5258	11 20 00
	ld hl,0x1800 + 24 + 1*32	;525b	21 38 18    Locate at [24, 1]
	ld ix,FRAME_LATERAL_CHARS	;525e	dd 21 89 52
	ld a,(ix+000h)		        ;5262	dd 7e 00
l5265h:
	call WRTVRM		    ;5265	cd 4d 00
	add hl,de			;5268	19
	inc ix		        ;5269	dd 23
	ld a,(ix+000h)		;526b	dd 7e 00
	djnz l5265h		    ;526e	10 f5
	ret			        ;5270	c9

FRAME_UP_CHARS:
    db 2, 12, 12, 12, 8, 9, 10, 11, 12, 12, 12, 12, 12, 12, 12, 12, 8, 9, 10, 11, 12, 12, 12, 13
FRAME_LATERAL_CHARS:
    db 3, 4, 5, 6, 7, 3, 4, 5, 6, 7, 3, 4, 5, 6, 7, 3, 4, 5, 6, 7, 3, 4, 5

; Update the score and high score after adding points.
; The number of points if an entry in POINTS_TABLE as POINTS_TABLE + 3*A.
ADD_POINTS_AND_UPDATE_SCORES:
    ; Input value in A
	push hl			;52a0	e5 	. 
	push bc			;52a1	c5 	. 
	push de			;52a2	d5 	. 
	push af			;52a3	f5 	. 
	push ix		    ;52a4	dd e5
	push iy		    ;52a6	fd e5
	ld hl,00000h	;52a8	21 00 00
	ld e,a			;52ab	5f
	ld d,0		    ;52ac	16 00       DE = input
	add hl,de		;52ae	19
	add hl,de		;52af	19
	add hl,de		;52b0	19          HL = 3*input
    
	ld de,POINTS_TABLE	;52b1	11 63 53
	add hl,de		;52b4	19
	push hl			;52b5	e5
	pop ix		    ;52b6	dd e1       IX = POINTS_TABLE + 3*input
    
	; Jump if we're at the title screen
    ld a,(GAME_STATE)		;52b8	3a 0b e0
	cp 0		            ;52bb	fe 00
	jp z,l5310h		        ;52bd	ca 10 53
	
    ; Jump if we're at demo state
    cp 3		            ;52c0	fe 03
	jp z,l52ceh		        ;52c2	ca ce 52

    ld hl,SCORE_BCD		                    ;52c5	21 15 e0

    ; Update the score
	call BCD_UPDATE_SCORE_ADD_POINTS		;52c8	cd 8a 53
	jp l52d7h		                        ;52cb	c3 d7 52
l52ceh:
    ; We're in demo, don't update the score
	ld hl,ZEROS_BCD_BUFFER		            ;52ce	21 18 e0
	call BCD_UPDATE_SCORE_ADD_POINTS		;52d1	cd 8a 53
	jp l52d7h		                        ;52d4	c3 d7 52 Unneeded. A copy-paste of the previous? :)

; Compare the current score with the high score, and update the
; high score is needed.
l52d7h:
	ld iy,HIGH_SCORE_BCD		;52d7	fd 21 07 e0
	ld a,(SCORE_BCD_BUFFER + 2)	;52db	3a a2 e5
	cp (iy+002h)		        ;52de	fd be 02
	jp z,l52eah		    ;52e1	ca ea 52
	jp c,l530dh		    ;52e4	da 0d 53
	jp l5302h		    ;52e7	c3 02 53
l52eah:
	ld a,(SCORE_BCD_BUFFER + 1)		;52ea	3a a1 e5
	cp (iy+001h)		            ;52ed	fd be 01
	jp z,l52f9h		    ;52f0	ca f9 52
	jp c,l530dh		    ;52f3	da 0d 53
	jp l5302h		    ;52f6	c3 02 53
l52f9h:
	ld a,(SCORE_BCD_BUFFER)		    ;52f9	3a a0 e5
	cp (iy+000h)		            ;52fc	fd be 00
	jp c,l530dh		    ;52ff	da 0d 53
l5302h:
    ; Update high score with the current
	ld de,HIGH_SCORE_BCD		;5302	11 07 e0
	ld hl,SCORE_BCD_BUFFER		;5305	21 a0 e5
	ld bc, 3		            ;5308	01 03 00
	ldir		                ;530b	ed b0
l530dh:
    ; Check if according to the score a new live should be granted
	call CHECK_SCORE_LIFE_TARGET		;530d	cd 19 53
l5310h:
	pop iy		;5310	fd e1
	pop ix		;5312	dd e1
	pop af		;5314	f1
	pop de		;5315	d1
	pop bc		;5316	c1
	pop hl		;5317	e1
	ret			;5318	c9

; Updates the BCD scores and number of lives
; Give a live when the points target is reached
CHECK_SCORE_LIFE_TARGET:
    ; Compare the current score with the target to get a life
	ld hl,SCORE_BCD+2	    ;5319	21 17 e0
	ld a,(SCORE_LIFE_BCD+2)	;531c	3a 20 e0
	cp (hl)			        ;531f	be
	jp c,l5336h		        ;5320	da 36 53
	ret nz			        ;5323	c0
    
	dec hl			        ;5324	2b
	ld a,(SCORE_LIFE_BCD+1)	;5325	3a 1f e0
	cp (hl)			        ;5328	be
	jp c,l5336h		        ;5329	da 36 53
	ret nz			        ;532c	c0
    
	dec hl			        ;532d	2b
	ld a,(SCORE_LIFE_BCD)	;532e	3a 1e e0
	cp (hl)			        ;5331	be
	jp c,l5336h		        ;5332	da 36 53
	ret nz			        ;5335	c0
;
l5336h:
    ; Increment lives
	ld hl,LIVES		    ;5336	21 1d e0
	inc (hl)			;5339	34 	4
	call DRAW_LIVES		;533a	cd b9 71

    ; Play life sound
	ld a,SOUND_LIFE		;533d	3e c5
	call ADD_SOUND		;533f	cd ef 5b

    ; Increment target for the next life
	ld hl,SCORE_LIFE_BCD+3      ;5342	21 21 e0
	inc (hl)			        ;5345	34
    
    ; Set next target to 40000 points
	ld e,0x40		;5346	1e 40
	ld a,(hl)		;5348	7e
	cp 1		    ;5349	fe 01
	jp z,l5350h		;534b	ca 50 53
    
    ; Set next target to  60000 points
	ld e,060h		;534e	1e 60
l5350h:
    ; Write the score, avoiding heading zeros
	ld a,(SCORE_LIFE_BCD+1)		;5350	3a 1f e0
	add a,e			            ;5353	83
	daa			                ;5354	27
	ld (SCORE_LIFE_BCD+1),a		;5355	32 1f e0
	ret nc			            ;5358	d0
	ld a,(SCORE_LIFE_BCD+2)		;5359	3a 20 e0
	add a, 1		            ;535c	c6 01
	daa			                ;535e
	ld (SCORE_LIFE_BCD+2),a		;535f	32 20 e0
	ret			                ;5362	c9

POINTS_TABLE:
    db    5,    0, 0       ;  0
    db    6,    0, 0       ;  1
    db    7,    0, 0       ;  2
    db    8,    0, 0       ;  3
    db    9,    0, 0       ;  4
    db 0x10,    0, 0       ;  5
    db 0x11,    0, 0       ;  6
    db 0x12,    0, 0       ;  7
    db 0x40,    0, 0       ;  8
    db 0x60,    0, 0       ;  9
    db 0x80,    0, 0       ; 10
    db   0,     1, 0       ; 11
    db   0,  0x10, 0       ; 12

; BDC-encode a score from HL after adding points from (IX+0), (IX+1), (IX+2), 
BCD_UPDATE_SCORE_ADD_POINTS:
    ; Copy binary score to BCD buffer
	ld de,SCORE_BCD_BUFFER  ;538a	11 a0 e5
	ld bc, 3		        ;538d	01 03 00
	ldir		            ;5390	ed b0

    ; Decode SCORE_BCD_BUFFER in BCD
	ld a,(SCORE_BCD_BUFFER)	;5392	3a a0 e5
	add a,(ix+0)		    ;5395	dd 86 00
	daa			            ;5398	27
	ld (SCORE_BCD_BUFFER),a	;5399	32 a0 e5

	; Decode SCORE_BCD_BUFFER + 1 in BCD
    ld a,(SCORE_BCD_BUFFER + 1)	;539c	3a a1 e5
	adc a,(ix+1)		        ;539f	dd 8e 01
	daa			                ;53a2	27
	ld (SCORE_BCD_BUFFER + 1),a	;53a3	32 a1 e5

	; Decode SCORE_BCD_BUFFER + 2 in BCD
    ld a,(SCORE_BCD_BUFFER + 2)	;53a6	3a a2 e5
	adc a,(ix+2)		        ;53a9	dd 8e 02
	daa			                ;53ac	27
	ld (SCORE_BCD_BUFFER + 2),a	;53ad	32 a2 e5

	ex de,hl			        ;53b0	eb
    ; HL = SCORE_BCD_BUFFER
    ; DE = SCORE_BCD or 0xe018
    
	dec hl			            ;53b1	2b
	dec de			            ;53b2	1b

    ; Update SCORE_BCD
    ;
    ; Copy BCD-encoded score
    ; Repeat 3 times (DE--) <-- (HL--) 
	ld bc, 3		            ;53b3	01 03 00
	lddr		                ;53b6	ed b8
	ret			                ;53b8	c9

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

; The chars of the Arkanoid logo
ARKANOID_LOGO_CHARS:
    db 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 ; 0x543e - 0x5445
    db 0x0, 0x4, 0x7, 0xa, 0xd, 0x10, 0x13, 0x16 ; 0x5446 - 0x544d
    db 0x19, 0x1c, 0x1f, 0x23, 0x26, 0x29, 0x5c, 0x60 ; 0x544e - 0x5455
    db 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 ; 0x5456 - 0x545d
    db 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 ; 0x545e - 0x5465
    db 0x2, 0x5, 0x8, 0xb, 0xe, 0x11, 0x14, 0x17 ; 0x5466 - 0x546d
    db 0x1a, 0x1d, 0x1, 0x24, 0x27, 0x2a, 0x5d, 0x61 ; 0x546e - 0x5475
    db 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 ; 0x5476 - 0x547d
    db 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 ; 0x547e - 0x5485
    db 0x3, 0x6, 0x9, 0xc, 0xf, 0x12, 0x15, 0x18 ; 0x5486 - 0x548d
    db 0x1b, 0x1e, 0x21, 0x25, 0x28, 0x5b, 0x5e, 0x62 ; 0x548e - 0x5495
    db 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 ; 0x5496 - 0x549d

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

; First half parts of the chars of the TAITO logo
TAITO_HALF1_LOGO_CHARS:
    db 0x63, 0x65, 0x67, 0x69, 0x6b, 0x6d, 0x6f, 0x71 ; 0x5509 - 0x5510
    db 0x73, 0x75, 0x77                               ; 0x5511 - 0x5513

; Second half parts of the chars of the TAITO logo
TAITO_HALF2_LOGO_CHARS:
    db 0x64, 0x66, 0x68, 0x6a, 0x6c, 0x6e, 0x70, 0x72 ; 0x5514 - 0x551b
    db 0x74, 0x76, 0x78                               ; 0x551c - 0x551e

; Red characters for "HIGH" and "SCORE"
HIGH_LETTERS:
    db 0x2b, 0x2f, 0x3f, 0x2b
SCORE_LETTERS:
    db 0x3a, 0x3b, 0x3c, 0x3d, 0x3e
SCORE_LETTERS_DUP:
    db 0x3a, 0x3b, 0x3c, 0x3d, 0x3e

; 552d
include 'periodic_patterns.asm'

SPRITE_PATTERN_POINTERS:
    dw SPRITE_PATTERN1
    dw SPRITE_PATTERN2
    dw SPRITE_PATTERN3    
    dw SPRITE_PATTERN4
SPRITE_PATTERN1:
    include 'sprite_pattern1.asm'
SPRITE_PATTERN2:
    include 'sprite_pattern2.asm'
SPRITE_PATTERN3:
    include 'sprite_pattern3.asm'
SPRITE_PATTERN4:
    include 'sprite_pattern4.asm'


; Draw the background
COLORIZE_BACKGROUND:
	ld b, 3		    ;5bbd	06 03          3 blocks
	ld iy,02380h	;5bbf	fd 21 80 23    VDP color table
l5bc3h:
	ld c, 16*8+1		;5bc3	0e 81
	ld a,(LEVEL)		;5bc5	3a 1b e0
l5bc8h:
    ; The final level is special
	cp FINAL_LEVEL		;5bc8	fe 20
	jp z,l5bd7h		    ;5bca	ca d7 5b
	and 3h		        ;5bcd	e6 03
    
	; HL = BACKGROUND_COLORS_TABLE + LEVEL & 3
    ld e,a			                    ;5bcf	5f
	ld d,0  		                    ;5bd0	16 00   ; DE = LEVEL & 3
	ld hl,BACKGROUND_COLORS_TABLE		;5bd2	21 eb 5b
	add hl,de			                ;5bd5	19
    
    ; C = BACKGROUND_COLORS_TABLE[LEVEL & 3]
	ld c,(hl)	    ;5bd6	4e
l5bd7h:
	ld a,c			;5bd7	79  Byte to write to VRAM

    ; HL = 02380h, VRAM address
	push iy		    ;5bd8	fd e5
	pop hl			;5bda	e1

    ; Fill VRAM with 16*8 (16 characters) bytes of value A
	push bc			;5bdb	c5
	ld bc, 16*8	    ;5bdc	01 80 00
	call FILVRM		;5bdf	cd 56 00
	pop bc			;5be2	c1

    ; Next block
	ld de, 2048		;5be3	11 00 08
	add iy,de		;5be6	fd 19
	djnz l5bc3h		;5be8	10 d9
	ret			    ;5bea	c9
BACKGROUND_COLORS_TABLE:
    db 0x41, 0xc2, 0x41, 0x81

; Add a sound to the queue
; Param A: sound code
ADD_SOUND:
	push hl			;5bef	e5
	push de			;5bf0	d5
	push bc			;5bf1	c5
    
    ld c,a          ;5bf2	4f
    
    ; Exit if lasers are being fired. No sounds in that case.
	ld a,(LASERS_FIRING)		    ;5bf3	3a 19 e5
	or a			                ;5bf6	b7
	jp nz,l5c11h		            ;5bf7	c2 11 5c

    ; HL = SOUNDS_BUFFER + [SOUNDS_COUNT]
	ld a,(SOUNDS_COUNT)		        ;5bfa	3a 1e e5
	ld e,a			                ;5bfd	5f
	ld d, 0		                    ;5bfe	16 00
	ld hl,SOUNDS_BUFFER		;5c00	21 20 e5
	add hl,de			            ;5c03	19

    ; SOUNDS_BUFFER[SOUNDS_COUNT] = sound_code
	ld (hl),c			            ;5c04	71

    ; Increment SOUNDS_COUNT, with a limit of 7
	ld hl,SOUNDS_COUNT		        ;5c05	21 1e e5
	inc (hl)			            ;5c08	34
	ld a,(hl)			            ;5c09	7e
	cp 8		                    ;5c0a	fe 08
	jp nz,l5c11h		            ;5c0c	c2 11 5c
	ld (hl), 7		                ;5c0f	36 07
l5c11h:
	pop bc			;5c11	c1
	pop de			;5c12	d1
	pop hl			;5c13	e1
	ret			    ;5c14	c9

; Add the bricks to the tilemap
; It can be a full repaint if it's the start of the level, or a
; partial one if it's been modified (say, some bricks already destroyed).
ADD_BRICKS_TO_TILEMAP:
    ; We start with add all background tiles to the tilemap
	call ADD_BACKGROUND_TO_TILEMAP		;5c15	cd 9d 5d

    ; Then, we add the bricks
    
    ; Skip the following if we're not doing a full brick repaint
	ld a,(BRICK_REPAINT_TYPE)	;5c18	3a 22 e0
	cp BRICK_REPAINT_REMAINING  ;5c1b	fe 02
	jp z,l5c45h		            ;5c1d	ca 45 5c
    
    ; Do a full repaint

    ; HL = BRICKS_PER_LEVEL + LEVEL
	ld hl, BRICKS_PER_LEVEL		;5c20	21 00 5d
	ld a,(LEVEL)		;5c23	3a 1b e0
	ld e,a			    ;5c26	5f
	ld d, 0 		    ;5c27	16 00
	add hl,de			;5c29	19

    ; Set the number of bricks in this level
    ; BRICKS_LEFT <-- BRICKS_PER_LEVEL[LEVEL]
	ld a,(hl)			;5c2a	7e
	ld (BRICKS_LEFT),a	;5c2b	32 38 e0

    ; Set the number of hits needed to break a hard brick
	ld hl,HARD_BRICKS_REMAINING_HITS		;5c2e	21 39 e0
	ld de,HARD_BRICKS_REMAINING_HITS+1		;5c31	11 3a e0
    
    ; A = LEVEL/8 + 2
    ; From HARD_BRICKS_REMAINING_HITS with BRICK_COLS*BRICK_ROWS values of A = LEVEL/8 + 2
    ; The number of hits needed to break a hard brick is int((level+1) / 8) + 2.
	ld a,(LEVEL)	;5c34	3a 1b e0
	srl a		    ;5c37	cb 3f
	srl a		    ;5c39	cb 3f
	srl a		    ;5c3b	cb 3f
	inc a			;5c3d	3c
	inc a			;5c3e	3c

    ; Set [HARD_BRICKS_REMAINING_HITS] <-- BRICKS_LEFT/8 + 2 for all of
    ; them in this level.
	ld (hl),a		;5c3f	77
	ld bc, BRICK_COLS*BRICK_ROWS-1  ;5c40	01 83 00
	ldir		                    ;5c43	ed b0
l5c45h:
    ; Do a partial repaint
	ld ix,BACKGROUND_TILEMAP		;5c45	dd 21 6e e3

	ld de,LEVEL_COLORS_PTR_TABLE	;5c49	11 2f 5e

    ; HL = 2*LEVEL + LEVEL_COLORS_PTR_TABLE
	ld a,(LEVEL)		;5c4c	3a 1b e0
	ld l,a			    ;5c4f	6f
	ld h, 0 		    ;5c50	26 00
	add hl,hl			;5c52	29
	add hl,de			;5c53	19

    ; Get a pointer to the colors of the bricks in the level
    ; DE = LEVEL_COLORS_PTR_TABLE[2*LEVEL]
	ld e,(hl)			;5c54	5e
	inc hl			    ;5c55	23
	ld d,(hl)			;5c56	56

    ; IY points to the level colors
	push de			    ;5c57	d5
	pop iy		        ;5c58	fd e1

	ld de,LEVELS_PTR_TABLE		;5c5a	11 ef 5d
    
    ; HL = 2*LEVEL + LEVELS_PTR_TABLE
	ld a,(LEVEL)	;5c5d	3a 1b e0
	ld l,a			;5c60	6f
	ld h, 0		    ;5c61	26 00    
	add hl,hl		;5c63	29
	add hl,de		;5c64	19
    
    ; DE = LEVELS_PTR_TABLE[2*LEVEL]
	ld e,(hl)		;5c65	5e
	inc hl			;5c66	23
	ld d,(hl)		;5c67	56
	
    ; HL = LEVELS_PTR_TABLE[2*LEVEL]
    ex de,hl		;5c68	eb
    
    ; So far we have:
    ;   IX = BACKGROUND_TILEMAP
    ;   IY = LEVEL_COLORS_PTR_TABLE[2*LEVEL]
    ;   HL = LEVELS_PTR_TABLE[2*LEVEL]

    ; Set HL=BRICK_MAP if we're doing a full brick repaint.
    ; Otherwise, we'll keep HL = LEVELS_PTR_TABLE[2*LEVEL].
	ld a,(BRICK_REPAINT_TYPE)		;5c69	3a 22 e0
	cp BRICK_REPAINT_REMAINING      ;5c6c	fe 02
	jp nz,l5c74h		            ;5c6e	c2 74 5c
	ld hl,BRICK_MAP		            ;5c71	21 27 e0
l5c74h:
	ld b, BRICK_MAP_LEN		;5c74	06 11
    
    ; Counter
	xor a			        ;5c76	af
	ld (BRICK_BIT_COUNT),a	;5c77	32 89 e4
	xor a			        ;5c7a	af
	ld (BRICK_BLOCK),a	    ;5c7b	32 8a e4
l5c7eh:
	ld c, 8		            ;5c7e	0e 08
    ; Read a bitmask of bricks
	ld a,(hl)	            ;5c80	7e
l5c81h:
    ; Check the MSB (a 1 indicates there's a brick)
	rlca			                    ;5c81	07
	ld de,(BRICK_TILEMAP_OFFSET)	    ;5c82	ed 5b 86 e4
	jr nc,l5c8dh		                ;5c86	30 05   Skip if there's no brick to draw
    
    ; This adds the brick as part of the background tilemap
    ; Reads from IY=LEVEL_COLORS_PTR_TABLE and writes to IX=BACKGROUND_TILEMAP
	call ADD_BRICK_TO_TILEMAP		;5c88	cd 58 5d 
	
    jr l5cc6h		;5c8b	18 39
l5c8dh:
    ; No brick to draw.
	push hl			;5c8d	e5
	push af			;5c8e	f5
	inc ix		    ;5c8f	dd 23
	push ix		    ;5c91	dd e5
	push de			;5c93	d5

    ; DE = LEVELS_PTR_TABLE[2*LEVEL]
	ld de,LEVELS_PTR_TABLE		;5c94	11 ef 5d
	ld a,(LEVEL)		        ;5c97	3a 1b e0
	ld l,a			            ;5c9a	6f
	ld h, 0		                ;5c9b	26 00
	add hl,hl			        ;5c9d	29
	add hl,de			        ;5c9e	19
	ld e,(hl)			        ;5c9f	5e
	inc hl			            ;5ca0	23
	ld d,(hl)			        ;5ca1	56

    ; IX = LEVELS_PTR_TABLE[2*LEVEL]
	push de			;5ca2	d5
	pop ix		    ;5ca3	dd e1

    ; IX = LEVELS_PTR_TABLE[2*LEVEL] + (BRICK_BLOCK)
    ; It points to a particular brick's bitmask
    ;
    ; It's addressing the brick as the brick-block at position BRICK_BIT_COUNT at index IX
	ld a,(BRICK_BLOCK)	;5ca5	3a 8a e4
	ld e,a			;5ca8	5f
	ld d, 0 		;5ca9	16 00
	add ix,de		;5cab	dd 19
    
    ; DE = 2*(BRICK_BIT_COUNT) 
	ld a,(BRICK_BIT_COUNT)	;5cad	3a 89 e4
	rlca			        ;5cb0	07
	ld e,a			        ;5cb1	5f
	ld d, 0	            	;5cb2	16 00

    ; HL = CHECK_BIT_JUMP_TABLE[2*(BRICK_BIT_COUNT)]
	ld hl,CHECK_BIT_JUMP_TABLE		;5cb4	21 f0 5c
	add hl,de			            ;5cb7	19
	ld e,(hl)			            ;5cb8	5e
	inc hl			                ;5cb9	23
	ld d,(hl)			            ;5cba	56
	ex de,hl			            ;5cbb	eb

    ; Check bit
    ; We'll go on in the next instruction, l5cbdh
    ; We'll do a bit x,(ix+000h)
	jp (hl)			;5cbc	e9
l5cbdh:
	jr z,l5cc1h		;5cbd	28 02
	inc iy		    ;5cbf	fd 23
l5cc1h:
	pop de			;5cc1	d1
	pop ix		    ;5cc2	dd e1
	pop af			;5cc4	f1
	pop hl			;5cc5	e1
l5cc6h:
    ; Next tilemap offset
	inc de			                ;5cc6	13
	inc de			                ;5cc7	13
	ld (BRICK_TILEMAP_OFFSET),de	;5cc8	ed 53 86 e4
    ; Next brick block
	inc ix		                    ;5ccc	dd 23
    ; Next bit
	dec c			                ;5cce	0d

    ; Next bit in the block
	push af			        ;5ccf	f5
	ld a,(BRICK_BIT_COUNT)	;5cd0	3a 89 e4
	inc a			        ;5cd3	3c
	and 007h		        ;5cd4	e6 07
	ld (BRICK_BIT_COUNT),a	;5cd6	32 89 e4
	pop af			        ;5cd9	f1
	jr nz,l5c81h		    ;5cda	20 a5 Keep iterating bits in the block...

	; Next brick block
    inc hl			        ;5cdc	23
	push af			        ;5cdd	f5
	ld a,(BRICK_BLOCK)		;5cde	3a 8a e4
	inc a			        ;5ce1	3c
	ld (BRICK_BLOCK),a		;5ce2	32 8a e4
	pop af			        ;5ce5	f1
	djnz l5c7eh		        ;5ce6	10 96
    
    ; Reset tilemap offset and exit
	ld de, 0    		            ;5ce8	11 00 00
	ld (BRICK_TILEMAP_OFFSET),de	;5ceb	ed 53 86 e4
	ret			                    ;5cef	c9

; Check bit jump table
; IX points to the bitmask, and the jump table will check the
; corresponding bit.
CHECK_BIT_JUMP_TABLE:
    dw check_b7
    dw check_b6
    dw check_b5
    dw check_b4
    dw check_b3
    dw check_b2
    dw check_b1
    dw check_b0

BRICKS_PER_LEVEL:
    ;  L1  L2  L3  L4  L5  L6  L7 L8  L9  L10
    db 66, 66, 42, 80, 63, 51, 54, 7, 22, 25
    ; L11  L12 L13  L14, L15  L16  L17 L18  L19 L20
    db 49, 8,   56, 66,  113, 50,  47,  44, 43,  20
    ; L21 L22 L23 L24 L25 L26 L27 L28 L29 L30 L31 L32
    db 12, 64, 47, 53, 36, 10, 66, 45, 76, 55, 56, 26

check_b7:
	bit 7,(ix+000h)	;5d20	dd cb 00 7e
	jp l5cbdh		;5d24	c3 bd 5c
check_b6:
	bit 6,(ix+000h)	;5d27	dd cb 00 76
	jp l5cbdh		;5d2b	c3 bd 5c
check_b5:
	bit 5,(ix+000h)	;5d2e	dd cb 00 6e
	jp l5cbdh		;5d32	c3 bd 5c
check_b4:
	bit 4,(ix+000h)	;5d35	dd cb 00 66
	jp l5cbdh		;5d39	c3 bd 5c
check_b3:
	bit 3,(ix+000h)	;5d3c	dd cb 00 5e
	jp l5cbdh		;5d40	c3 bd 5c
check_b2:
	bit 2,(ix+000h)	;5d43	dd cb 00 56
	jp l5cbdh		;5d47	c3 bd 5c
check_b1:
	bit 1,(ix+000h)	;5d4a	dd cb 00 4e
	jp l5cbdh		;5d4e	c3 bd 5c
check_b0:
	bit 0,(ix+000h)	;5d51	dd cb 00 46
	jp l5cbdh		;5d55	c3 bd 5c

; Add a brick as part of the background tilemap
;
; Input IY=LEVEL_COLORS_PTR_TABLE
; Input IX=BACKGROUND_TILEMAP
; It reads from IY=LEVEL_COLORS_PTR_TABLE and writes to IX=BACKGROUND_TILEMAP
ADD_BRICK_TO_TILEMAP:
	push af			;5d58	f5
	push bc			;5d59	c5  Useless?
	push de			;5d5a	d5
	push hl			;5d5b	e5
	
    ; Translate the given color into an VDP pattern code
    ; HL = TBL_COLOR_TO_PATTERN + 2*IY[0]
    ld a,(iy+000h)	;5d5c	fd 7e 00
	ld l,a			;5d5f	6f
	ld h,000h		;5d60	26 00
	add hl,hl		;5d62	29
    ld de,TBL_COLOR_TO_PATTERN	;5d63	11 db 5d
	add hl,de		;5d66	19

    ; Read a pattern and...
	; A =  TBL_COLOR_TO_PATTERN[2*IY[0]]
    ld a,(hl)		;5d67	7e
    
	; ...write to the tilemap, IX[0] <-- TBL_COLOR_TO_PATTERN[2*IY[0]]
    ld (ix+000h),a	;5d68	dd 77 00
    
    ; Next
	inc hl			;5d6b	23
	inc ix		    ;5d6c	dd 23
	
    ; Write again, after incrementing the pointers
    ld a,(hl)		;5d6e	7e
	ld (ix+000h),a	;5d6f	dd 77 00
    
    ; Next color
	inc iy		    ;5d72	fd 23

	pop hl			;5d74	e1
	pop de			;5d75	d1
	pop bc			;5d76	c1
	pop af			;5d77	f1
	ret			    ;5d78	c9

; Draw the backgroud tilemap in BACKGROUND_TILEMAP to VRAM
DRAW_BACKGROUND_TILEMAP:
	ld hl,BACKGROUND_TILEMAP	;5d79	21 6e e3
	ld de,01862h		        ;5d7c	11 62 18    VDP name table
	defb 0ddh,02eh,00ch	;ld ixl, 12		;5d7f	dd 2e 0c
l5d82h:
	ld iy,32		;5d82	fd 21 20 00
	ld bc,22		;5d86	01 16 00    22 background chars per line

	push de			;5d89	d5	
    ; Copy 22 background chars to VRAM
    push hl			;5d8a	e5
	push bc			;5d8b	c5
	call LDIRVM		;5d8c	cd 5c 00
	pop bc			;5d8f	c1
	pop hl			;5d90	e1
    
    ; Next line
	add hl,bc		;5d91	09
	pop de			;5d92	d1
	add iy,de		;5d93	fd 19
	push iy		    ;5d95	fd e5
	pop de			;5d97	d1
	defb 0ddh,02dh	;dec ixl		;5d98	dd 2d
	jr nz,l5d82h	;5d9a	20 e6
	ret			    ;5d9c	c9

; Fill the playfield with background tiles
ADD_BACKGROUND_TO_TILEMAP:
    ; BRICK_HIT_ROW = 0
	xor a			        ;5d9d	af
	ld (BRICK_HIT_ROW),a	;5d9e	32 3c e5

	ld ix,BACKGROUND_TILEMAP		    ;5da1	dd 21 6e e3
l5da5h:
    ; BRICK_HIT_COL = 0
	xor a			        ;5da5	af
	ld (BRICK_HIT_COL),a	;5da6	32 3d e5
l5da9h:
    ; HL = TABLE_BACKGROUND_ENTRY1 + 4*(BRICK_HIT_ROW & 3)
	ld a,(BRICK_HIT_ROW)	;5da9	3a 3c e5
	and 3		            ;5dac	e6 03
	ld l,a			        ;5dae	6f
	ld h, 0		            ;5daf	26 00
	add hl,hl			    ;5db1	29
	add hl,hl			    ;5db2	29
	ld de,TABLE_BACKGROUND_ENTRY1	;5db3	11 98 ad
	add hl,de			            ;5db6	19

    ; Point to the background tile corresponding to the hit brick
    ; HL = TABLE_BACKGROUND_ENTRY1 + 4*(BRICK_HIT_ROW & 3) + BRICK_HIT_COL & 3
	ld a,(BRICK_HIT_COL)	;5db7	3a 3d e5
	and 3		            ;5dba	e6 03
	ld e,a			        ;5dbc	5f
	ld d, 0		            ;5dbd	16 00
	add hl,de			    ;5dbf	19
    
    ; Set the tile
	ld a,(hl)			;5dc0	7e
	ld (ix+000h),a		;5dc1	dd 77 00
	inc ix		        ;5dc4	dd 23

    ; Column on the right
	ld hl,BRICK_HIT_COL	;5dc6	21 3d e5
	inc (hl)			;5dc9	34 	4 
	ld a,(hl)			;5dca	7e
	
    ; Skip if COL is out of the limits
    cp 22		        ;5dcb	fe 16
	jp nz,l5da9h		;5dcd	c2 a9 5d
    
    ; Row below
	ld hl,BRICK_HIT_ROW	;5dd0	21 3c e5
	inc (hl)			;5dd3	34 	4 
    
    ; Skip if ROW is out of the limits
	ld a,(hl)			;5dd4	7e
	cp 12		        ;5dd5	fe 0c
	jp nz,l5da5h		;5dd7	c2 a5 5d    Next tile
	ret			;5dda	c9 	. 

; This table gives the pattern number of the brick in the VDP's patterns table 
TBL_COLOR_TO_PATTERN:
    db 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29
    db 0x5b, 0x5c, 0x5d, 0x5e, 0x60, 0x61, 0x62
    db 0x63, 0x64, 0x65, 0x66, 0x67, 0x68

; Pointers to the bitmask of each level
; dw_block.py ../arkanoid.rom --start 24047 --end 24110 --offset 16384
LEVELS_PTR_TABLE:
    dw 0x6615, 0x6626, 0x6637, 0x6648, 0x6659, 0x666a, 0x667b, 0x668c; 0x5def - 0x5dfe
    dw 0x669d, 0x66ae, 0x66bf, 0x66d0, 0x66e1, 0x66f2, 0x6703, 0x6714; 0x5dff - 0x5e0e
    dw 0x6725, 0x6736, 0x6747, 0x6758, 0x6769, 0x677a, 0x678b, 0x679c; 0x5e0f - 0x5e1e
    dw 0x67ad, 0x67be, 0x67cf, 0x67e0, 0x67f1, 0x6802, 0x6813, 0x6824; 0x5e1f - 0x5e2e

; Pointers to the colors of the bricks which are present in the bitmask
; /dw_block.py ../arkanoid.rom --start 24111 --end 24174 --offset 16384
LEVEL_COLORS_PTR_TABLE:
    dw 0x5e6f, 0x5eb1, 0x5ef3, 0x5f35, 0x5f85, 0x5fc4, 0x5ffd, 0x6033; 0x5e2f - 0x5e3e
    dw 0x6052, 0x607a, 0x60af, 0x60e0, 0x611a, 0x6152, 0x619a, 0x6213; 0x5e3f - 0x5e4e
    dw 0x624a, 0x627f, 0x62c7, 0x6306, 0x633c, 0x6374, 0x63c4, 0x63f3; 0x5e4f - 0x5e5e
    dw 0x6428, 0x6469, 0x6483, 0x64c5, 0x6505, 0x6569, 0x65a5, 0x65dd; 0x5e5f - 0x5e6e

include 'level_colors.asm'
include 'level_maps.asm'


; Several operations in one function:
; - Execute the corresponding Vaus action
; - Check and perform lasering
; - Check and perform portal animation
EXECUTE_VAUS_ACTION_AND_LASERS_STEP_AND_PORTAL_ANIMATION:
	call EXECUTE_VAUS_ACTION	;6835	cd c4 68
	call LASERS_STEP		    ;6838	cd 39 70
	call PORTAL_ANIMATION		;683b	cd 3f 68
	ret			                ;683e	c9

; Animation of the open portal
PORTAL_ANIMATION:
    ; If the portal is closed, exit
	ld a,(PORTAL_OPEN)		;683f	3a 26 e3
	or a			        ;6842	b7
	ret z			        ;6843	c8

    ; If the portal han been already drawn open, skip
	ld a,(PORTAL_ALREADY_DRAWN_OPEN)	;6844	3a 7c e5
	cp 1		                        ;6847	fe 01
	jp z,l686fh		                    ;6849	ca 6f 68
    
    ; We need to write the portal open

	ld b, 4		        ;684c	06 04
	ld hl,OPEN_PORTAL_PATTERNS		;684e	21 b8 68
	ld iy, 0x1800 + 24 + 20*32		;6851	fd 21 98 1a     Locate at [24, 20]
l6855h:
	push iy		    ;6855	fd e5
	pop de			;6857	d1

	push bc			;6858	c5
	push hl			;6859	e5
    ; Draw one char
	ld bc, 1		;685a	01 01 00
	call LDIRVM		;685d	cd 5c 00
	pop hl			;6860	e1
	pop bc			;6861	c1

    ; Next line
	ld de, 32		;6862	11 20 00
	add iy,de		;6865	fd 19
	inc hl			;6867	23
	djnz l6855h		;6868	10 eb
    
    ; Portal open already drawn
	ld a,1		                        ;686a	3e 01
	ld (PORTAL_ALREADY_DRAWN_OPEN),a	;686c	32 7c e5
;
l686fh:
    ; Check if we need to update the beam animation
	ld a,(PORTAL_ANIMATION_BEAM_COUNTER)	;686f	3a 7b e5
	cp 9		                            ;6872	fe 09
	jr c,l687ah		                        ;6874	38 04 Jump if PORTAL_ANIMATION_BEAM_COUNTER < 9
    
    ; PORTAL_ANIMATION_BEAM_COUNTER >= 9
	ld a, 0		;6876	3e 00
	jr l687fh	;6878	18 05
l687ah:
    ; Increment PORTAL_ANIMATION_BEAM_COUNTER
	inc a			                        ;687a	3c
	ld (PORTAL_ANIMATION_BEAM_COUNTER),a	;687b	32 7b e5
	ret			                            ;687e	c9
;
l687fh:
    ; Update PORTAL_ANIMATION_BEAM_COUNTER
	ld (PORTAL_ANIMATION_BEAM_COUNTER),a	;687f	32 7b e5

    ; A = inverted PORTAL_ANIMATION_BEAM_STEP
	ld a,(PORTAL_ANIMATION_BEAM_STEP)		;6882	3a 76 e5
	cp 0		                            ;6885	fe 00
	jp z,l688fh		                        ;6887	ca 8f 68

	ld a, 0		                            ;688a	3e 00
	jp l6891h		                        ;688c	c3 91 68
l688fh:
	ld a, 1		                            ;688f	3e 01
l6891h:
    ; Update PORTAL_ANIMATION_BEAM_STEP
	ld (PORTAL_ANIMATION_BEAM_STEP),a		;6891	32 76 e5
    
    ; Use the 4 patterns for the bean corresponding to the
    ; PORTAL_ANIMATION_BEAM_STEP.
    ; IX = PORTAL_BEAM_PATTERNS[2*PORTAL_ANIMATION_BEAM_STEP]
	sla a		    ;6894	cb 27
	sla a		    ;6896	cb 27
	ld l,a			;6898	6f
	ld h,000h		;6899	26 00
	ld de,PORTAL_BEAM_PATTERNS	;689b	11 bc 68
	add hl,de		;689e	19
	push hl			;689f	e5
	pop ix		    ;68a0	dd e1

    ; Animation of Vaus entering the portal.
    ; The portal opens as Vaus enters.
	ld b, 4 		            ;68a2	06 04       Four steps
    ld hl, 0x1800 + 24 + 20*32; ;68a4	21 98 1a    Locate VRAM [24, 20]
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

; Pattern codes to write the portal open
OPEN_PORTAL_PATTERNS:
    db 22, 23, 24, 25

; Pattern codes to write the portal beamns
PORTAL_BEAM_PATTERNS:
    db 26, 27,  28, 29  ; State 0
    db 30, 31, 109, 33  ; State 1

; Executes a Vaus action:
; - Follow the ball when in the demo 
; - Enlarge
; - Shrink
; - Get lasers
; - Explode
; - Go through the portal
EXECUTE_VAUS_ACTION:
    ; Reset the position of Vaus if we're starting a level
    ld a, (RESET_VAUS_SPR_POSITION)  ;68c4  3a a9 e5
    cp 1                             ;68c7  fe 01
	jp z,l68dch		                 ;68c9	ca dc 68

    ; Center Vaus
	ld hl,SPR_DATA_ARKANOID_CENTERED		    ;68cc	21 e7 6f
	ld de,SPR_PARAMS_BASE	                    ;68cf	11 cd e0
	ld bc, 4*SPR_PARAMS_LEN                     ;68d2	01 10 00
l68d5h:
	ldir		                                ;68d5	ed b0

	ld a, 1 	;68d7	3e 01
	ld (RESET_VAUS_SPR_POSITION),a		;68d9	32 a9 e5
l68dch:
	ld ix,VAUS_TABLE		;68dc	dd 21 4b e5
	ld iy,SPR_PARAMS_BASE	;68e0	fd 21 cd e0
    
    ; Choose action on VAUS_TABLE_ACTION_STATE
	ld a,(ix+VAUS_TABLE_IDX_ACTION_STATE)       ;68e4	dd 7e 00
	cp VAUS_ACTION_STATE_KEEP		            ;68e7	fe 01
	jp z,vaus_follow_ball_demo_or_read_controls ;68e9	ca 0f 69
	cp VAUS_ACTION_STATE_ENLARGING		        ;68ec	fe 02
	jp z,vaus_do_enlarge		                ;68ee	ca 3e 6c
	cp VAUS_ACTION_STATE_SHRINKING		        ;68f1	fe 03
	jp z,vaus_do_shrinking		                ;68f3	ca 78 6d
	cp VAUS_ACTION_STATE_LASER		            ;68f6	fe 04
	jp z,vaus_gets_lasers		                ;68f8	ca 31 6f
	cp VAUS_ACTION_STATE_UNLASER		        ;68fb	fe 05
	jp z,vaus_unlaser		                    ;68fd	ca ce 6c
	cp VAUS_ACTION_STATE_EXPLODING		        ;6900	fe 06
	jp z,vaus_destroyed		                    ;6902	ca 0e 6e
	cp VAUS_ACTION_STATE_THROUGH_PORTAL		    ;6905	fe 07
	jp z,vaus_crosses_portal		            ;6907	ca db 6a
    
    ; Transformation completed, keep current state
	ld (ix+VAUS_TABLE_IDX_ACTION_STATE),VAUS_ACTION_STATE_KEEP		;690a	dd 36 00 01
	ret nz			                                                ;690e	c0

vaus_follow_ball_demo_or_read_controls:
    ; VAUS_ACTION_STATE_KEEP
    ; If we're in the demo, set the Vaus' position to the balls's.
    ; If we're playing, fall to read_controls_move_vaus.

    ; Skip if we're not in the demo
	ld a,(GAME_STATE)		;690f	3a 0b e0
	or a			        ;6912	b7
	jp nz,read_controls_move_vaus		    ;6913	c2 24 69
    
    ; In the demo we set Vaus to the same X position as the ball
	ld a,(BALL_X_DEMO)		    ;6916	3a f6 e0
	sub 16		                ;6919	d6 10   X-16 actually
	ld (iy+SPR_PARAMS_IDX_X),a	;691b	fd 77 01
	ld (VAUS_X2),a		        ;691e	32 3e e5
	jp l6972h		            ;6921	c3 72 69

read_controls_move_vaus:
    ; Read the controls and increment the Vaus' X position
    
    ; Skip if we're using the keyboard
	ld a,(USE_VAUS_PADDLE)		;6924	3a 0c e0
	or a			            ;6927	b7
	jp nz,l6946h		        ;6928	c2 46 69    Go the the paddle function
    
    ; Using cursors
	ld a,(CONTROLS)		;692b	3a bf e0
	and 00fh            ;692e	e6 0f
	
    ; Get Vaus increment in X according to the controls
    ; A = TBL_INCREMENT_POS_VAUS_CONTROLS[2*CONTROLS + 1]
    ld l,a			;6930	6f
	ld h, 0 		;6931	26 00
	add hl,hl		;6933	29
	ld de,TBL_INCREMENT_POS_VAUS_CONTROLS	;6934	11 f7 6f
	add hl,de		;6937	19
	inc hl			;6938	23
	ld a,(hl)		;6939	7e

    ; VAUS_X <-- VAUS_X + TBL_INCREMENT_POS_VAUS_CONTROLS[2*CONTROLS + 1]
	add a,(iy+SPR_PARAMS_IDX_X)		;693a	fd 86 01
	ld (iy+SPR_PARAMS_IDX_X),a		;693d	fd 77 01
	ld (VAUS_X2),a		            ;6940	32 3e e5
	jp l6972h		                ;6943	c3 72 69
l6946h:
    ; Using the paddle
	ld b, 8		            ;6946	06 08
	ld hl,(PADDLE_COUNT)	;6948	2a c1 e0
	ld de, 160		        ;694b	11 a0 00
	xor a			        ;694e	af
	sbc hl,de		        ;694f	ed 52   HL = PADDLE_COUNT - 160
    
    ; Set with B=8 if PADDLE_COUNT < 160
	jp c,l6965h		        ;6951	da 65 69
    
    ; PADDLE_COUNT >= 160
	ld b, 176		;6954	06 b0
	ld de, 4		;6956	11 04 00
	add hl,de		;6959	19      HL = PADDLE_COUNT + 4
	ld c,l			;695a	4d
	ld de, 176		;695b	11 b0 00
	xor a			;695e	af
	sbc hl,de		;695f	ed 52   HL = PADDLE_COUNT + 4 - 176 = PADDLE_COUNT - 172
    
    ; We'll use B=176 if  PADDLE_COUNT + 4 >= 176, and
    ; B=8 otherwise.    
	jp nc,l6965h	;6961	d2 65 69
	ld b,c			;6964	41      B = PADDLE_COUNT + 4  (low)
l6965h:
	ld a,(iy+SPR_PARAMS_IDX_X)		;6965	fd 7e 01
	ld (0e54ah),a		            ;6968	32 4a e5
    ; Set new position from B
	ld a,b			                ;696b	78
	ld (iy+SPR_PARAMS_IDX_X),a		;696c	fd 77 01
	ld (VAUS_X2),a		            ;696f	32 3e e5

l6972h:
    ; Take the appropriate action if Vaus is changing its size
	ld a,(ix+VAUS_TABLE_IDX_RESIZING)	;6972	dd 7e 05
	cp 1		                        ;6975	fe 01
	jp z,l6a17h		                    ;6977	ca 17 6a
	cp 2		                        ;697a	fe 02
	jp z,l69eah		                    ;697c	ca ea 69

	ld a,(VAUS_X2)		;697f	3a 3e e5
	cp 153			;6982	fe 99
	jp c,l69abh		;6984	da ab 69
	cp 230			;6987	fe e6
	jr nc,l69abh		;6989	30 20 	0   

	ld a, 152		;698b	3e 98
	ld (VAUS_X2),a		;698d	32 3e e5

    ; Skip the following if the portal is closed
	ld a,(PORTAL_OPEN)		;6990	3a 26 e3
	or a			        ;6993	b7
	jp z,l69abh		        ;6994	ca ab 69

    ; The portal is open, let's go through!
	ld (ix+VAUS_TABLE_IDX_ACTION_STATE), VAUS_ACTION_STATE_THROUGH_PORTAL   ;6997	dd 36 00 07

	ld a,SOUND_VAUS_GOES_THROUGH_PORTAL_H	;699b	3e c1
	call ADD_SOUND		                    ;699d	cd ef 5b

	ld a, 12		                        ;69a0	3e 0c
	call ADD_POINTS_AND_UPDATE_SCORES		;69a2	cd a0 52
	call DEACTIVE_ALL_BALLS		            ;69a5	cd 10 97
	jp l69bch		                        ;69a8	c3 bc 69
l69abh:
    ; If VAUS_X2 <= 9 or VAUS_X2 < 240, then VAUS_X2 = 8
	ld a,(VAUS_X2)		;69ab	3a 3e e5
	cp 240		        ;69ae	fe f0
	jp nc,l69b7h		;69b0	d2 b7 69
    
    ; If VAUS_X2 >= 9, then go on
	cp 9		        ;69b3	fe 09
	jr nc,l69bch		;69b5	30 05
l69b7h:
    ; VAUS_X2 = 8
	ld a, 8		        ;69b7	3e 08
	ld (VAUS_X2),a		;69b9	32 3e e5

l69bch:
    ; Skip if Vaus is exploing
	ld a,(ix+VAUS_ACTION_STATE_EXPLODING)		;69bc	dd 7e 06
	cp 1		                                ;69bf	fe 01
	jp z,l69d6h		                            ;69c1	ca d6 69
    
    ; Move right all 4 sprites of the enlarged Vaus
	ld a,(VAUS_X2)		;69c4	3a 3e e5
	ld b, 4		        ;69c7	06 04
l69c9h:
	ld (iy+SPR_PARAMS_IDX_X),a	;69c9	fd 77 01
	add a, 16		            ;69cc	c6 10
	ld de, SPR_PARAMS_LEN		;69ce	11 04 00
	add iy,de		            ;69d1	fd 19
	djnz l69c9h		            ;69d3	10 f4
	ret			                ;69d5	c9
l69d6h:
    ; Keep sprite #0 in the same position, but move right
    ; sprites #1, #2, and #3.
	ld a,(VAUS_X2)		                                ;69d6	3a 3e e5
	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;69d9	fd 77 01
	add a, 16		                                    ;69dc	c6 10
	ld (iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;69de	fd 77 05
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;69e1	fd 77 09
	add a, 16		                                    ;69e4	c6 10
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;69e6	fd 77 0d
	ret			                                        ;69e9	c9

l69eah:
	ld a,(VAUS_X2)		;69ea	3a 3e e5
	cp 136		        ;69ed	fe 88
	jp c,l69abh		    ;69ef	da ab 69    Jump if X < 136
	cp 230		        ;69f2	fe e6
	jp nc,l69abh		;69f4	d2 ab 69    Jump if X >= 230
    
    ; 136 <= X < 230
    
    ; VAUS_X2 <-- 136
	ld a, 136		    ;69f7	3e 88
	ld (VAUS_X2),a		;69f9	32 3e e5
    
    ; Check if the portal is closed and jump if so
	ld a,(PORTAL_OPEN)		;69fc	3a 26 e3
	or a			        ;69ff	b7
	jp z,l69abh		        ;6a00	ca ab 69

    ; Set Vaus is crossing the protal
	ld (ix+VAUS_TABLE_IDX_ACTION_STATE), VAUS_ACTION_STATE_THROUGH_PORTAL		;6a03	dd 36 00 07

    ; Play the sound
	ld a,SOUND_VAUS_GOES_THROUGH_PORTAL_H	;6a07	3e c1
	call ADD_SOUND		                    ;6a09	cd ef 5b

    ; Add points
	ld a, 12		                        ;6a0c	3e 0c
	call ADD_POINTS_AND_UPDATE_SCORES		;6a0e	cd a0 52
	call DEACTIVE_ALL_BALLS		            ;6a11	cd 10 97
	jp l69bch		                        ;6a14	c3 bc 69
l6a17h:
	; Jump if Vaus has lasers
    ld a,(ix+VAUS_TABLE_IDX_HAS_LASER)		;6a17	dd 7e 06
	or a			                        ;6a1a	b7
	jp nz,l6a5dh		                    ;6a1b	c2 5d 6a
    
	ld a,(VAUS_X2)	;6a1e	3a 3e e5
	cp 131		    ;6a21	fe 83
	jp c,l6a30h		;6a23	da 30 6a    Jump if X < 131
	cp 158		    ;6a26	fe 9e
	jp nc,l6a30h	;6a28	d2 30 6a    Jump if X >= 158
    
    ; 131 <= X < 158

    ; VAUS_X2 <-- 130
	ld a, 130		;6a2b	3e 82
	ld (VAUS_X2),a	;6a2d	32 3e e5
l6a30h:
	cp -6		    ;6a30	fe fa
	jp nc,l6a3fh	;6a32	d2 3f 6a    Jump if X < -6
	cp 9		    ;6a35	fe 09
	jp nc,l6a3fh	;6a37	d2 3f 6a    Jump if X >= 9
    
    ; -6 <= X < 9
    
    ; VAUS_X2 <-- 8
	ld a,8 		    ;6a3a	3e 08 	> . 
	ld (VAUS_X2),a	;6a3c	32 3e e5 	2 > . 
l6a3fh:
    ; Jump if Vaus has lasers
	ld a,(ix+VAUS_TABLE_IDX_HAS_LASER)		;6a3f	dd 7e 06
	cp 1		                            ;6a42	fe 01
	jp z,l6a72h		                        ;6a44	ca 72 6a
    
    ; Update the position of the 4 sprites
	ld a,(VAUS_X2)		                    ;6a47	3a 3e e5

	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a	;6a4a	fd 77 01
	add a, 16		                                ;6a4d	c6 10
	ld (iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a	;6a4f	fd 77 05
	add a, 8		                                ;6a52	c6 08
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a	;6a54	fd 77 09
	add a, 8		                                ;6a57	c6 08
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a	;6a59	fd 77 0d
	ret			                                    ;6a5c	c9
l6a5dh:
	ld a,(VAUS_X2)	;6a5d	3a 3e e5
	cp 146		    ;6a60	fe 92       Jump if X < 146
	jp c,l6a30h		;6a62	da 30 6a
	cp 200		    ;6a65	fe c8
	jp nc,l6a30h	;6a67	d2 30 6a    Jump if X >= 200
    
    ; 146 <= X < 200

    ; VAUS_X2 <-- 160
	ld a,160		;6a6a	3e a0
	ld (VAUS_X2),a	;6a6c	32 3e e5
    
	jp l6a30h		;6a6f	c3 30 6a
l6a72h:
    ; Check cross-portal step
	ld a,(ix+VAUS_ACTION_STATE_THROUGH_PORTAL)		;6a72	dd 7e 07
	cp 2		                                    ;6a75	fe 02
	jp z,vaus_crossing_portal_step_2		                                ;6a77	ca 9f 6a
	cp 3		                                    ;6a7a	fe 03
	jp z,vaus_crossing_portal_step_3		                                ;6a7c	ca b3 6a
	cp 4		                                    ;6a7f	fe 04
	jp z,vaus_crossing_portal_step_4		                                ;6a81	ca c7 6a
	cp 5		                                    ;6a84	fe 05
	jp z,vaus_crossing_portal_step_5		                                ;6a86	ca 9e 6a
    
    ; Update the position of the 4 sprites
	ld a,(VAUS_X2)		                                ;6a89	3a 3e e5
    
	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6a8c	fd 77 01
	add a, 12		                                    ;6a8f	c6 0c
	ld (iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6a91	fd 77 05
	add a, 12		                                    ;6a94	c6 0c
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6a96	fd 77 09
	add a, -4		                                    ;6a99	c6 fc
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6a9b	fd 77 0d
vaus_crossing_portal_step_5:
	ret			                                        ;6a9e	c9
vaus_crossing_portal_step_2:
	; Update the position of the 4 sprites
    ld a,(VAUS_X2)		                                ;6a9f	3a 3e e5

	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6aa2	fd 77 01
	add a, 6		                                    ;6aa5	c6 06
	ld (iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6aa7	fd 77 05
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6aaa	fd 77 09
	add a, 6		                                    ;6aad	c6 06
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6aaf	fd 77 0d
	ret			                                        ;6ab2	c9
vaus_crossing_portal_step_3:
    ; Update the position of the 4 sprites
	ld a,(VAUS_X2)		                                ;6ab3	3a 3e e5

	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6ab6	fd 77 01
	add a, 12		                                    ;6ab9	c6 0c
	ld (iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6abb	fd 77 05
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6abe	fd 77 09
	add a, 12		                                    ;6ac1	c6 0c
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6ac3	fd 77 0d
	ret			                                        ;6ac6	c9
vaus_crossing_portal_step_4:
    ; Update the position of the 4 sprites
	ld a,(VAUS_X2)		                                ;6ac7	3a 3e e5

	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6aca	fd 77 01
	add a, 8		                                    ;6acd	c6 08
	ld (iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6acf	fd 77 05
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6ad2	fd 77 09
	add a, 8		                                    ;6ad5	c6 08
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6ad7	fd 77 0d
	ret			                                        ;6ada	c9

vaus_crosses_portal:
    ; VAUS_ACTION_STATE_THROUGH_PORTAL

    ; Increment portaling step counter
    ; Leave if it's not 10 yet
	ld ix,VAUS_TABLE + VAUS_TABLE_IDX_VAUS_PORTALING_STEP1		;6adb	dd 21 53 e5
	inc (ix+000h)		;6adf	dd 34 00
	ld a,(ix+000h)		;6ae2	dd 7e 00
	cp 10		        ;6ae5	fe 0a
	ret nz			    ;6ae7	c0
    
    ; Reset VAUS_TABLE_IDX_VAUS_PORTALING_STEP1 counter
	ld (ix+000h), 0		;6ae8	dd 36 00 00
            
    ; Since ix = VAUS_TABLE + VAUS_TABLE_IDX_VAUS_PORTALING_STEP1 (idx 8),
    ; ix+001h is index 9 in VAUS_TABLE: VAUS_TABLE_IDX_VAUS_PORTALING_STEP2

    ; DE = VAUS_TABLE_IDX_VAUS_PORTALING_STEP2 \ 2
	ld e,(ix+001h)		;6aec	dd 5e 01    VAUS_TABLE_IDX_VAUS_PORTALING_STEP2
	sla e		        ;6aef	cb 23
    ld d, 0		        ;6af1	16 00
    
    ; Jump if Vaus has lasers
	ld a,(VAUS_TABLE + VAUS_TABLE_IDX_HAS_LASER)	;6af3	3a 51 e5
	cp 1		                                    ;6af6	fe 01
	jp z,vaus_goes_to_portal_with_lasers		    ;6af8	ca 48 6b

    ; Jump if it's resizing
	ld a,(VAUS_TABLE + VAUS_TABLE_IDX_RESIZING)		;6afb	3a 50 e5
	cp 0		                                    ;6afe	fe 00
	jp nz,vaus_goes_to_portal_resizing              ;6b00	c2 2c 6b

    ; HL = TBL_VAUS_ENTERING_PORTAL_SPR_DATA[VAUS_TABLE_IDX_VAUS_PORTALING_STEP2 \ 2]
	ld hl,TBL_VAUS_ENTERING_PORTAL_SPR_DATA		;6b03	21 64 6b
	add hl,de			;6b06	19
	ld e,(hl)			;6b07	5e
	inc hl			    ;6b08	23
	ld d,(hl)			;6b09	56
	ex de,hl			;6b0a	eb

	; Copy 3 sprites from TBL_VAUS_ENTERING_PORTAL_SPR_DATA
    ; This makes the animation
    ld de,SPR_PARAMS_BASE	    	;6b0b	11 cd e0
	ld bc, 3 * SPR_PARAMS_LEN		;6b0e	01 0c 00
	ldir		                    ;6b11	ed b0
    
    ; Next portaling step.
    ; Leave if it's not 4
	inc (ix+001h)		            ;6b13	dd 34 01    VAUS_TABLE_IDX_VAUS_PORTALING_STEP2
	ld a,(ix+001h)		            ;6b16	dd 7e 01 	VAUS_TABLE_IDX_VAUS_PORTALING_STEP2
	cp 4		                    ;6b19	fe 04
	ret nz			                ;6b1b	c0

move_to_next_level:
    ; Vaus normal state
	ld a,VAUS_ACTION_STATE_WAIT_READY		            ;6b1c	3e 00
	ld (VAUS_TABLE + VAUS_TABLE_IDX_ACTION_STATE),a	    ;6b1e	32 4b e5

    ; Move to the next level
	ld a,GAME_TRANSITION_ACTION_NEXT_LEVEL		        ;6b21	3e 02
	ld (GAME_TRANSITION_ACTION),a		                ;6b23	32 0a e0

    ; Make a repaint. ToDo: why unknown?
	ld a,BRICK_REPAINT_UNKNOWN		;6b26	3e 01
	ld (BRICK_REPAINT_TYPE),a		;6b28	32 22 e0
	ret			                    ;6b2b	c9

vaus_goes_to_portal_resizing:
	; HL = TBL_VAUS_CROSSES_PORTAL_TRANSFORMED_SPR_DATA[VAUS_TABLE_IDX_VAUS_PORTALING_STEP2 \ 2]
    ld hl,TBL_VAUS_CROSSES_PORTAL_TRANSFORMED_SPR_DATA		;6b2c	21 9c 6b
	add hl,de			;6b2f	19
	ld e,(hl)			;6b30	5e
	inc hl			    ;6b31	23
	ld d,(hl)			;6b32	56
	ex de,hl			;6b33	eb

	; Copy 4 sprites from TBL_VAUS_CROSSES_PORTAL_TRANSFORMED_SPR_DATA
    ; This makes the animation    
	ld de, SPR_PARAMS_BASE		;6b34	11 cd e0
	ld bc, 4 * SPR_PARAMS_LEN	;6b37	01 10 00
	ldir		                ;6b3a	ed b0
    
    ; Next portaling step.
    ; Leave if it's not 5
	inc (ix+001h)		;6b3c	dd 34 01
	ld a,(ix+001h)		;6b3f	dd 7e 01
	cp 5		        ;6b42	fe 05
	ret nz			    ;6b44	c0
    
    ; Done
	jp move_to_next_level   ;6b45	c3 1c 6b

vaus_goes_to_portal_with_lasers:
    ; HL = TBL_VAUS_CROSSES_PORTAL_WITH_LASERS_SPR_DATA[VAUS_TABLE_IDX_VAUS_PORTALING_STEP2 \ 2]
	ld hl,TBL_VAUS_CROSSES_PORTAL_WITH_LASERS_SPR_DATA		;6b48	21 f6 6b
	add hl,de			;6b4b	19
	ld e,(hl)			;6b4c	5e
	inc hl			    ;6b4d	23
	ld d,(hl)			;6b4e	56
	ex de,hl			;6b4f	eb

	; Copy 4 sprites from TBL_VAUS_CROSSES_PORTAL_TRANSFORMED_SPR_DATA
    ; This makes the animation  
	ld de,SPR_PARAMS_BASE		;6b50	11 cd e0
	ld bc, 4 * SPR_PARAMS_LEN   ;6b53	01 10 00
	ldir		                ;6b56	ed b0

    ; Next portaling step.
    ; Leave if it's not 4
	inc (ix+001h)		;6b58	dd 34 01
	ld a,(ix+001h)		;6b5b	dd 7e 01
	cp 4		        ;6b5e	fe 04
	ret nz			    ;6b60	c0
    
    ; Done
	jp move_to_next_level   ;6b61	c3 1c 6b

; Sprite data to render Vaus crossing the portal.
; When entering, some sprites become invisible.
TBL_VAUS_ENTERING_PORTAL_SPR_DATA:  ; 6b64
    ; Addresses
    dw entering_portal_anim_1
    dw entering_portal_anim_2
    dw entering_portal_anim_3
    dw entering_portal_anim_4

    ; Each entry is a sprite params. tuple as follows:
    ; SPR_PARAMS_IDX_Y, SPR_PARAMS_IDX_X, SPR_PARAMS_IDX_PATTERN_NUM, SPR_PARAMS_IDX_COLOR
entering_portal_anim_1:
    db 174, 160, 8, 8   ;6b6c
    db 174, 176, 4, 14  ;6b70
    db 174, 192, 12, 8  ;6b74
entering_portal_anim_2:
    db 174, 168, 8, 8   ;6b78
    db 174, 184, 4, 14  ;6b7c
    db 0, 0, 0, 0       ;6b80
entering_portal_anim_3:
    db 174, 184, 8, 8   ;6b84
    db 0, 0, 0, 0       ;6b88
    db 0, 0, 0, 0       ;6b8c
entering_portal_anim_4:
    db 0, 0, 0, 0       ;6b90
    db 0, 0, 0, 0       ;6b94
    db 0, 0, 0, 0       ;6b98

; Sprite data to render Vaus crossing the portal,
; when it's transformed.
; When entering, some sprites become invisible.
TBL_VAUS_CROSSES_PORTAL_TRANSFORMED_SPR_DATA:
    ; Addresses
    dw entering_portal_transf_anim_1
    dw entering_portal_transf_anim_2
    dw entering_portal_transf_anim_3
    dw entering_portal_transf_anim_4
    dw entering_portal_transf_anim_5
    
    ; Sprite params
entering_portal_transf_anim_1:
    db 0xae, 0x90, 0x8, 0x8 ; 0x6ba6 - 0x6ba9
    db 0xae, 0xa0, 0x4, 0xe ; 0x6baa - 0x6bad
    db 0xae, 0xb0, 0x4, 0xe ; 0x6bae - 0x6bb1
    db 0xae, 0xc0, 0xc, 0x8 ; 0x6bb2 - 0x6bb5
entering_portal_transf_anim_2:
    db 0xae, 0x98, 0x8, 0x8 ; 0x6bb6 - 0x6bb9
    db 0xae, 0xa8, 0x4, 0xe ; 0x6bba - 0x6bbd
    db 0xae, 0xb8, 0x4, 0xe ; 0x6bbe - 0x6bc1
    db 0x0, 0x0, 0x0, 0x0 ; 0x6bc2 - 0x6bc5
entering_portal_transf_anim_3:
    db 0xae, 0xa8, 0x8, 0x8 ; 0x6bc6 - 0x6bc9
    db 0xae, 0xb8, 0x4, 0xe ; 0x6bca - 0x6bcd
    db 0x0, 0x0, 0x0, 0x0 ; 0x6bce - 0x6bd1
    db 0x0, 0x0, 0x0, 0x0 ; 0x6bd2 - 0x6bd5
entering_portal_transf_anim_4:
    db 0xae, 0xb8, 0x8, 0x8 ; 0x6bd6 - 0x6bd9
    db 0x0, 0x0, 0x0, 0x0 ; 0x6bda - 0x6bdd
    db 0x0, 0x0, 0x0, 0x0 ; 0x6bde - 0x6be1
    db 0x0, 0x0, 0x0, 0x0 ; 0x6be2 - 0x6be5
entering_portal_transf_anim_5:
    db 0x0, 0x0, 0x0, 0x0 ; 0x6be6 - 0x6be9
    db 0x0, 0x0, 0x0, 0x0 ; 0x6bea - 0x6bed
    db 0x0, 0x0, 0x0, 0x0 ; 0x6bee - 0x6bf1
    db 0x0, 0x0, 0x0, 0x0 ; 0x6bf2 - 0x6bf5

; Sprite data to render Vaus crossing the portal,
; when it's got lasers.
; When entering, some sprites become invisible.
TBL_VAUS_CROSSES_PORTAL_WITH_LASERS_SPR_DATA:
    ; Addresses
    dw entering_portal_with_lasers_anim_1
    dw entering_portal_with_lasers_anim_2
    dw entering_portal_with_lasers_anim_3
    dw entering_portal_with_lasers_anim_4

    ; Sprite params
entering_portal_with_lasers_anim_1:
    db 0xae, 0xa0, 0x14, 0xe ; 0x6bfe - 0x6c01
    db 0xae, 0xb0, 0x10, 0xe ; 0x6c02 - 0x6c05
    db 0xae, 0xb0, 0x1c, 0x8 ; 0x6c06 - 0x6c09
    db 0xae, 0xc0, 0x18, 0xe ; 0x6c0a - 0x6c0d
entering_portal_with_lasers_anim_2:
    db 0xae, 0xa8, 0x14, 0xe ; 0x6c0e - 0x6c11
    db 0xae, 0xb8, 0x10, 0xe ; 0x6c12 - 0x6c15
    db 0xae, 0xb8, 0x1c, 0x8 ; 0x6c16 - 0x6c19
    db 0x0, 0x0, 0x0, 0x0 ; 0x6c1a - 0x6c1d
entering_portal_with_lasers_anim_3:
    db 0xae, 0xb8, 0x14, 0xe ; 0x6c1e - 0x6c21
    db 0x0, 0x0, 0x0, 0x0 ; 0x6c22 - 0x6c25
    db 0x0, 0x0, 0x0, 0x0 ; 0x6c26 - 0x6c29
    db 0x0, 0x0, 0x0, 0x0 ; 0x6c2a - 0x6c2d
entering_portal_with_lasers_anim_4:
    db 0x0, 0x0, 0x0, 0x0 ; 0x6c2e - 0x6c31
    db 0x0, 0x0, 0x0, 0x0 ; 0x6c32 - 0x6c35
    db 0x0, 0x0, 0x0, 0x0 ; 0x6c36 - 0x6c39
    db 0x0, 0x0, 0x0, 0x0 ; 0x6c3a - 0x6c3d

vaus_do_enlarge:
    ; VAUS_ACTION_STATE_ENLARGING

	; ix = VAUS_TABLE
	; iy = SPR_PARAMS_BASE
    
    ; If it's got the lasers, remove them
	ld a,(ix+VAUS_TABLE_IDX_HAS_LASER)		;6c3e	dd 7e 06
	cp 1		                            ;6c41	fe 01
	jp z,vaus_unlaser		                        ;6c43	ca ce 6c
    
    ; Increase the laser step
	inc (ix+VAUS_TABLE_IDX_LASERING_STEP)		;6c46	dd 34 02
	ld a,(ix+VAUS_TABLE_IDX_LASERING_STEP)		;6c49	dd 7e 02
    
    ; If we're not in step 5, keep reading the controls
	cp 5		                                    ;6c4c	fe 05
	jp nz,vaus_follow_ball_demo_or_read_controls	;6c4e	c2 0f 69
    
    ; Reset laser step
	ld (ix+VAUS_TABLE_IDX_LASERING_STEP), 0		    ;6c51	dd 36 02 00
    
    ; Jump to the animation according to the resizing step
	ld a,(ix+VAUS_TABLE_IDX_RESIZING_STEP)		    ;6c55	dd 7e 01
	cp 1		                                    ;6c58	fe 01
	jp z,l6c94h		                                ;6c5a	ca 94 6c

    ; Sprite #2: central part of Vaus, gray
    ; Sprite #3: right edge of Vaus
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_PATTERN_NUM), 4	;6c5d	fd 36 0a 04     Center
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_PATTERN_NUM), 12	;6c61	fd 36 0e 0c     Right edge
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 14		    ;6c65	fd 36 0b 0e     Gray
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 8		    ;6c69	fd 36 0f 08     Red

    ; Move large Vaus to the left

    ; Sprite #0 (left edge), moves 4 pixels left
	ld a, -4		                                ;6c6d	3e fc
	add a,(iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)  ;6c6f	fd 86 01
	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a	;6c72	fd 77 01

    ; Sprite #1 (first half of the center), moves 4 pixels left
	ld a, -4		                                    ;6c75	3e fc
	add a,(iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6c77	fd 86 05
	ld (iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6c7a	fd 77 05

    ; Sprite #2 (second half of the center), moves 12 pixels left
	ld a, -12		                                    ;6c7d	3e f4
	add a,(iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6c7f	fd 86 09
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6c82	fd 77 09

    ; Sprite #3 (right edge), moves 12 pixels left
	ld a, -12		                                    ;6c85	3e f4
	add a,(iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6c87	fd 86 0d
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6c8a	fd 77 0d

	ld (ix+VAUS_TABLE_IDX_RESIZING), VAUS_ACTION_STATE_KEEP		;6c8d	dd 36 05 01
	jp l6cb8h		;6c91	c3 b8 6c 	. . l 
l6c94h:
    ; Sprite #0 (left edge), moves 4 pixels left
	ld a, -4		                                    ;6c94	3e fc
	add a,(iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6c96	fd 86 01
	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6c99	fd 77 01

    ; Sprite #1 (first half of the center), moves 4 pixels left
	ld a, -4		                                    ;6c9c	3e fc
	add a,(iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6c9e	fd 86 05
	ld (iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6ca1	fd 77 05

    ; Sprite #2 (second half of the center), moves 4 pixels right
	ld a, 4		                                        ;6ca4	3e 04
	ld a,(iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6ca6	fd 7e 09
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6ca9	fd 77 09

	; Sprite #3 (right edge), moves 4 pixels right
    ld a, 4		                                        ;6cac	3e 04
	add a,(iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6cae	fd 86 0d
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6cb1	fd 77 0d

    ; Set Vaus enlarging
	ld (ix+VAUS_TABLE_IDX_RESIZING), VAUS_ACTION_STATE_ENLARGING	;6cb4	dd 36 05 02
l6cb8h:
    ; Next enlarging step
	inc (ix+VAUS_TABLE_IDX_RESIZING_STEP)	;6cb8	dd 34 01
	ld a,(ix+VAUS_TABLE_IDX_RESIZING_STEP)	;6cbb	dd 7e 01
	cp 2		                            ;6cbe	fe 02
	jp nz,vaus_follow_ball_demo_or_read_controls		            ;6cc0	c2 0f 69
    
    ; Sizing is now in the last step
	ld (ix+VAUS_TABLE_IDX_ACTION_STATE),VAUS_ACTION_STATE_KEEP		;6cc3	dd 36 00 01
	ld (ix+VAUS_TABLE_IDX_RESIZING_STEP), 0		                    ;6cc7	dd 36 01 00
	jp vaus_follow_ball_demo_or_read_controls		                ;6ccb	c3 0f 69

vaus_unlaser:
    ; VAUS_ACTION_STATE_UNLASER
    
    ; Skip if we're not already in step 5
	inc (ix+VAUS_TABLE_IDX_LASERING_STEP)		    ;6cce	dd 34 02
	ld a,(ix+VAUS_TABLE_IDX_LASERING_STEP)		    ;6cd1	dd 7e 02
	cp 5		                                    ;6cd4	fe 05
	jp nz,vaus_follow_ball_demo_or_read_controls    ;6cd6	c2 0f 69
    ; Reset step
	ld (ix+VAUS_TABLE_IDX_LASERING_STEP),0		    ;6cd9	dd 36 02 00

    ; Execute action according to the unlasering transformation step
	ld a,(ix+VAUS_TABLE_IDX_LASER_TRANSFORMATION_STEP)		;6cdd	dd 7e 07
	cp 2		                                            ;6ce0	fe 02
	jp z,vaus_unlasering_step_2		                        ;6ce2	ca 2c 6d
	cp 3		                                            ;6ce5	fe 03
	jp z,vaus_unlasering_step_3		                        ;6ce7	ca 42 6d

    ; Move right
	ld a, 4		                                        ;6cea	3e 04
	add a,(iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6cec	fd 86 01
	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6cef	fd 77 01

    ; Move left
	ld a, -4		                                    ;6cf2	3e fc
    add a,(iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6cf4	fd 86 0d
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6cf7	fd 77 0d

	
    ; Keep playing
    ld (ix+VAUS_TABLE_IDX_RESIZING), VAUS_ACTION_STATE_KEEP	;6cfa	dd 36 05 01

    ; Next transformation step
	inc (ix+VAUS_TABLE_IDX_LASER_TRANSFORMATION_STEP)		;6cfe	dd 34 07
	ld a,(ix+VAUS_TABLE_IDX_LASER_TRANSFORMATION_STEP)		;6d01	dd 7e 07
    
    ; If in step 2, done
	cp 2		                                            ;6d04	fe 02
	jp nz,vaus_follow_ball_demo_or_read_controls		    ;6d06	c2 0f 69

    ; 
	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 8		;6d09	fd 36 03 08     Red
	ld (iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 14	    ;6d0d	fd 36 07 0e     Gray
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 8		;6d11	fd 36 0b 08     Red
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 0		;6d15	fd 36 0f 00     Transparent

	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_PATTERN_NUM), 8		;6d19	fd 36 02 08 Left edge
	ld (iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_PATTERN_NUM), 4		;6d1d	fd 36 06 04 Center
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_PATTERN_NUM), 12		;6d21	fd 36 0a 0c Right edge
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_PATTERN_NUM), 1		;6d25	fd 36 0e 01
    
    ; Done
	jp vaus_follow_ball_demo_or_read_controls		        ;6d29	c3 0f 69
;
vaus_unlasering_step_2:
    ; Move left
	ld a, -4		                                    ;6d2c	3e fc
	add a,(iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6d2e	fd 86 01
	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6d31	fd 77 01

    ; Move right
	ld a, 12		                                    ;6d34	3e 0c
	add a,(iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6d36	fd 86 09
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6d39	fd 77 09
    
    ; Next step
	inc (ix+VAUS_TABLE_IDX_LASER_TRANSFORMATION_STEP)	;6d3c	dd 34 07
	jp vaus_follow_ball_demo_or_read_controls		    ;6d3f	c3 0f 69
;
vaus_unlasering_step_3:
    ; Move left
	ld a, -4		                                    ;6d42	3e fc
	add a,(iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6d44	fd 86 01
	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6d47	fd 77 01

    ; Move right
	ld a, 4		                                        ;6d4a	3e 04
	add a,(iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6d4c	fd 86 09
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6d4f	fd 77 09

    ; Move right
	ld a, 24		                                    ;6d52	3e 18
	add a,(iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6d54	fd 86 0d
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6d57	fd 77 0d
    
    ; Keep playing
    ld (ix+VAUS_TABLE_IDX_RESIZING), VAUS_ACTION_STATE_WAIT_READY	;6d5a	dd 36 05 00
    
    ; Set no more lasers
	ld (ix+VAUS_TABLE_IDX_HAS_LASER), 0		                        ;6d5e	dd 36 06 00
	ld (ix+VAUS_TABLE_IDX_LASER_TRANSFORMATION_STEP), 0		        ;6d62	dd 36 07 00

    ; Clear enlarging state, if set
	ld a,(ix+VAUS_TABLE_IDX_ACTION_STATE)		;6d66	dd 7e 00
	cp VAUS_ACTION_STATE_ENLARGING		        ;6d69	fe 02
	jp nz,l6d71h		                        ;6d6b	c2 71 6d

    ; Done
	jp vaus_follow_ball_demo_or_read_controls		;6d6e	c3 0f 69
l6d71h:
	ld (ix+VAUS_TABLE_IDX_ACTION_STATE), VAUS_ACTION_STATE_KEEP		;6d71	dd 36 00 01
    ; Done
	jp vaus_follow_ball_demo_or_read_controls	                    ;6d75	c3 0f 69

vaus_do_shrinking:
    ; VAUS_ACTION_STATE_SHRINKING

    ; Incremente lasering step.
    ; If it's reached 5, leave
	inc (ix+VAUS_TABLE_IDX_LASERING_STEP)		        ;6d78	dd 34 02
	ld a,(ix+VAUS_TABLE_IDX_LASERING_STEP)		        ;6d7b	dd 7e 02
	cp 5		                                        ;6d7e	fe 05
	jp nz,vaus_follow_ball_demo_or_read_controls		;6d80	c2 0f 69

    ; Reset lasering step
	ld (ix+VAUS_TABLE_IDX_LASERING_STEP), 0		        ;6d83	dd 36 02 00

    ; Check resizing step and execute the right shrinking animation
	ld a,(ix+VAUS_TABLE_IDX_RESIZING_STEP)		        ;6d87	dd 7e 01
	cp 1		                                        ;6d8a	fe 01
	jp z,l6db6h		                                    ;6d8c	ca b6 6d

    ; Move sprite #0 (left edge) right
	ld a,4		                                        ;6d8f	3e 04
	add a,(iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6d91	fd 86 01
	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6d94	fd 77 01

    ; Move sprite #1 (first half of the center) right
	ld a, 4		                                        ;6d97	3e 04
	add a,(iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6d99	fd 86 05
	ld (iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6d9c	fd 77 05

    ; Move sprite #2 (second half of the center) left
	ld a, -4		                                    ;6d9f	3e fc
	add a,(iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6da1	fd 86 09
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6da4	fd 77 09

    ; Move sprite #3 (right edge) left
	ld a, -4		                                    ;6da7	3e fc
	add a,(iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6da9	fd 86 0d
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6dac	fd 77 0d

    ; Vaus normal state
	ld (ix+VAUS_TABLE_IDX_RESIZING), VAUS_ACTION_STATE_KEEP		;6daf	dd 36 05 01
	jp l6de1h		                                            ;6db3	c3 e1 6d
l6db6h:
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_PATTERN_NUM), 12		;6db6	fd 36 0a 0c     Right edge
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_PATTERN_NUM), 1		;6dba	fd 36 0e 01     But there's no pattern 1 :-?
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 8		        ;6dbe	fd 36 0b 08     Red
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 0		        ;6dc2	fd 36 0f 00     Transparent

    ; Left edge and first half of the center move left
	ld a, -4		                                ;6dc6	3e fc
	add a,(iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)	;6dc8	fd 86 01
	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a	;6dcb	fd 77 01

	add a, -4		                                ;6dce	c6 fc
	ld (iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a	;6dd0	fd 77 05

    ; Right edge and second half of the center move left
	add a, 4		                                ;6dd3	c6 04
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a	;6dd5	fd 77 09

	add a, 4		                                ;6dd8	c6 04
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a	;6dda	fd 77 0d
    
	ld (ix+VAUS_TABLE_IDX_RESIZING), VAUS_ACTION_STATE_WAIT_READY		;6ddd	dd 36 05 00
l6de1h:
    ; Vaus shrinking
    
    ; Check step 2
	inc (ix+VAUS_TABLE_IDX_RESIZING_STEP)		    ;6de1	dd 34 01
	ld a,(ix+VAUS_TABLE_IDX_RESIZING_STEP)	        ;6de4	dd 7e 01
	cp 2		                                    ;6de7	fe 02
	jp nz,vaus_follow_ball_demo_or_read_controls	;6de9	c2 0f 69
    
    ; Check step 1
	ld a,(ix+VAUS_TABLE_IDX_HAS_LASER)		    ;6dec	dd 7e 06
	cp 1		                                ;6def	fe 01
	jp z,l6dffh		                            ;6df1	ca ff 6d

    ; Resizing complete
	ld (ix+VAUS_TABLE_IDX_ACTION_STATE), 1		;6df4	dd 36 00 01
	ld (ix+VAUS_TABLE_IDX_RESIZING_STEP), 0		;6df8	dd 36 01 00
	jp vaus_follow_ball_demo_or_read_controls	;6dfc	c3 0f 69
l6dffh:
    ; Got laser
	ld (ix+VAUS_TABLE_IDX_ACTION_STATE),VAUS_ACTION_STATE_LASER		;6dff	dd 36 00 04
	ld (ix+VAUS_TABLE_IDX_RESIZING_STEP),0		                    ;6e03	dd 36 01 00
	ld (ix+VAUS_TABLE_IDX_LASER_TRANSFORMATION_STEP), 0		        ;6e07	dd 36 07 00
	jp vaus_follow_ball_demo_or_read_controls		                ;6e0b	c3 0f 69

vaus_destroyed:
    ; VAUS_ACTION_STATE_EXPLODING
	ld (ix+VAUS_TABLE_IDX_HAS_LASER), 0		        ;6e0e	dd 36 06 00
    
    ; It uses two variables VAUS_TABLE_IDX_DESTRUCTION_STEP1 and
    ; VAUS_TABLE_IDX_DESTRUCTION_STEP2 to control the animation steps.
    
    ; Exit if count not yet reached
	inc (ix+VAUS_TABLE_IDX_DESTRUCTION_STEP1)		;6e12	dd 34 03
	ld a,(ix+VAUS_TABLE_IDX_DESTRUCTION_STEP1)		;6e15	dd 7e 03
	cp 12		                                    ;6e18	fe 0c
	ret nz			                                ;6e1a	c0

    ld (ix+VAUS_TABLE_IDX_DESTRUCTION_STEP1), 0		;6e1b	dd 36 03 00
	inc (ix+VAUS_TABLE_IDX_DESTRUCTION_STEP2)		;6e1f	dd 34 04
	ld a,(ix+VAUS_TABLE_IDX_DESTRUCTION_STEP2)		;6e22	dd 7e 04
	cp 1		                                    ;6e25	fe 01
	jp nz,l6e64h		                            ;6e27	c2 64 6e

    ; Move right
	ld a,(iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6e2a	fd 7e 05
	add a, 16		                                    ;6e2d	c6 10

    ; Move right
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6e2f	fd 77 09
	add a, 16		                                    ;6e32	c6 10

    ; Set color
    ; This seems to be useless, since right after it's set to transparent.
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		    ;6e34	fd 77 0d

	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR),  8		;6e37	fd 36 03 08     Red
	ld (iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 14		;6e3b	fd 36 07 0e     Gray
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR),  8		;6e3f	fd 36 0b 08     Red
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR),  0		;6e43	fd 36 0f 00     Transparent

	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_PATTERN_NUM), 32	    ;6e47	fd 36 02 20     Left corner, breaking
	ld (iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_PATTERN_NUM), 36		;6e4b	fd 36 06 24     Center, breaking
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_PATTERN_NUM), 40		;6e4f	fd 36 0a 28     Right edge, breaking
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_PATTERN_NUM),  1		;6e53	fd 36 0e 01

    ; This code is redundant, since this was already set in 6e37
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 8		;6e57	fd 36 0b 08     Red
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 0		;6e5b	fd 36 0f 00     Transparent
	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 8		;6e5f	fd 36 03 08     Red
	ret			                                            ;6e63	c9

l6e64h:
    ; For info:
    ; IX points to VAUS_TABLE
    ; IY points to SPR_PARAMS
    
    ; Leave if VAUS_ACTION_STATE_LASER >= 3
	ld a,(ix+VAUS_ACTION_STATE_LASER)		            ;6e64	dd 7e 04
	cp 3		                                        ;6e67	fe 03
	jp nc,l6ee0h		                                ;6e69	d2 e0 6e
    
    ; VAUS_ACTION_STATE_LASER < 3

    ; Update X of sprites #0, ..., #6
	ld a, -8		                                    ;6e6c	3e f8
	add a,(iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6e6e	fd 86 05
	ld (iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6e71	fd 77 05

	ld a, -8		                                    ;6e74	3e f8
	add a,(iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6e76	fd 86 09
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6e79	fd 77 09

	ld a, -8		                                    ;6e7c	3e f8
	add a,(iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6e7e	fd 86 0d
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6e81	fd 77 0d
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 8	;6e84	fd 36 0f 08

	ld a,(iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6e88	fd 7e 01
	ld (iy+4*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6e8b	fd 77 11
	ld (iy+5*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6e8e	fd 77 15
	ld (iy+6*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6e91	fd 77 19
    
    ; Update Y of sprites #0, #4, #5, and #6
	ld a,(iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_Y)		;6e94	fd 7e 00
	ld (iy+4*SPR_PARAMS_LEN + SPR_PARAMS_IDX_Y),a		;6e97	fd 77 10
	ld (iy+5*SPR_PARAMS_LEN + SPR_PARAMS_IDX_Y),a		;6e9a	fd 77 14
	ld (iy+6*SPR_PARAMS_LEN + SPR_PARAMS_IDX_Y),a		;6e9d	fd 77 18

    ; Update X and Y of sprites #4, #5, and #6
	ld a, 8		                                        ;6ea0	3e 08
	add a,(iy+4*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6ea2	fd 86 11
	ld (iy+4*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6ea5	fd 77 11

	ld a, -16		                                    ;6ea8	3e f0
	add a,(iy+4*SPR_PARAMS_LEN + SPR_PARAMS_IDX_Y)		;6eaa	fd 86 10
	ld (iy+4*SPR_PARAMS_LEN + SPR_PARAMS_IDX_Y),a		;6ead	fd 77 10

	ld a, 24		                                    ;6eb0	3e 18
	add a,(iy+5*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6eb2	fd 86 15
	ld (iy+5*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6eb5	fd 77 15

	ld a, -16		                                    ;6eb8	3e f0
	add a,(iy+5*SPR_PARAMS_LEN + SPR_PARAMS_IDX_Y)		;6eba	fd 86 14
	ld (iy+5*SPR_PARAMS_LEN + SPR_PARAMS_IDX_Y),a		;6ebd	fd 77 14

	ld a, 32		                                    ;6ec0	3e 20
	add a,(iy+6*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6ec2	fd 86 19
	ld (iy+6*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6ec5	fd 77 19

	ld a, -16		                                    ;6ec8	3e f0
	add a,(iy+6*SPR_PARAMS_LEN + SPR_PARAMS_IDX_Y)		;6eca	fd 86 18
	ld (iy+6*SPR_PARAMS_LEN + SPR_PARAMS_IDX_Y),a		;6ecd	fd 77 18
    
    ; Set colors: gray and red
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 14		;6ed0	fd 36 0b 0e     Gray
	ld (iy+4*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 14		;6ed4	fd 36 13 0e     Red
	ld (iy+5*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 14		;6ed8	fd 36 17 0e     Red
	ld (iy+6*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR),  8		;6edc	fd 36 1b 08     Red
l6ee0h:
    ; Point to Arkanoid-destroyed patterns
    ; HL = VAUS_DESTROYED_PATTERNS[2*VAUS_TABLE_IDX_DESTRUCTION_STEP2]
	ld l,(ix+VAUS_TABLE_IDX_DESTRUCTION_STEP2)		;6ee0	dd 6e 04
	ld h, 0		                                    ;6ee3	26 00
	add hl,hl			                            ;6ee5	29
	ld de, VAUS_DESTROYED_PATTERNS		                            ;6ee6	11 19 70
	add hl,de			                            ;6ee9	19
	ld e,(hl)			                            ;6eea	5e
	inc hl			                                ;6eeb	23
	ld d,(hl)			                            ;6eec	56
	ex de,hl			                            ;6eed	eb

    ; Update the pattern code of 7 sprites
	push iy		;6eee	fd e5
	ld b, 7		;6ef0	06 07
l6ef2h:
	ld a,(hl)			                                        ;6ef2	7e
	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_PATTERN_NUM),a		;6ef3	fd 77 02
	inc hl			                                            ;6ef6	23
	ld de, SPR_PARAMS_LEN		                                ;6ef7	11 04 00
	add iy,de		                                            ;6efa	fd 19
	djnz l6ef2h		                                            ;6efc	10 f4
	pop iy		                                                ;6efe	fd e1

    ; Leave if VAUS_TABLE_IDX_DESTRUCTION_STEP2 != 4
	ld a,(ix+VAUS_TABLE_IDX_DESTRUCTION_STEP2)		            ;6f00	dd 7e 04
	cp 4		                                                ;6f03	fe 04
	ret nz			                                            ;6f05	c0
    
    ; VAUS_TABLE_IDX_DESTRUCTION_STEP2 == 4

    ; Reset destruction step
	ld (ix+VAUS_TABLE_IDX_DESTRUCTION_STEP2), 0		                    ;6f06	dd 36 04 00
    
	ld (ix+VAUS_TABLE_IDX_ACTION_STATE), VAUS_ACTION_STATE_WAIT_READY	;6f0a	dd 36 00 00

    ; Update the colors of 7 sprites as transparent (0)
	push iy		                                            ;6f0e	fd e5
	ld b, 7		                                            ;6f10	06 07
l6f12h:
	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 0		;6f12	fd 36 03 00
	ld de, SPR_PARAMS_LEN		                            ;6f16	11 04 00
	add iy,de		                                        ;6f19	fd 19
	djnz l6f12h		                                        ;6f1b	10 f5
	pop iy		                                            ;6f1d	fd e1

    ; No lasers
	ld a, 0		                            ;6f1f	3e 00
	ld (VAUS_X2),a		                    ;6f21	32 3e e5
	ld (ix+VAUS_TABLE_IDX_HAS_LASER), 0		;6f24	dd 36 06 00

	ld a,BRICK_REPAINT_REMAINING	;6f28	3e 02
	ld (BRICK_REPAINT_TYPE),a		;6f2a	32 22 e0
	ld (GAME_TRANSITION_ACTION),a	;6f2d	32 0a e0
	ret			                    ;6f30	c9

vaus_gets_lasers:
    ; VAUS_ACTION_STATE_LASER
    
    ; Got laser
	ld (ix+VAUS_TABLE_IDX_HAS_LASER), 1		;6f31	dd 36 06 01
    
    ; Exit if unlasering
	ld a,(ix+VAUS_ACTION_STATE_UNLASER)		;6f35	dd 7e 05
	cp 2		                            ;6f38	fe 02
	jp z,l6fe0h		                        ;6f3a	ca e0 6f

    ; Next lasering transformation step
	inc (ix+VAUS_TABLE_IDX_LASERING_STEP)		    ;6f3d	dd 34 02
	ld a,(ix+VAUS_TABLE_IDX_LASERING_STEP)		    ;6f40	dd 7e 02
	cp 10		                                    ;6f43	fe 0a
	jp nz,vaus_follow_ball_demo_or_read_controls	;6f45	c2 0f 69

    ; Transformation completed
	ld (ix+VAUS_TABLE_IDX_LASERING_STEP), 0		    ;6f48	dd 36 02 00
    
	ld a,(ix+VAUS_ACTION_STATE_THROUGH_PORTAL)		;6f4c	dd 7e 07
	cp 1		                                    ;6f4f	fe 01
	jp z,lasering_step_1		                    ;6f51	ca 80 6f
	cp 2		                                    ;6f54	fe 02
	jp z,lasering_step_2_and_3		                ;6f56	ca b6 6f
	cp 3		                                    ;6f59	fe 03
	jp z,lasering_step_2_and_3		                ;6f5b	ca b6 6f

    ; Move right
	ld a,4		                                        ;6f5e	3e 04
	add a,(iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6f60	fd 86 01
	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6f63	fd 77 01

	; Move left
    ld a, -4		                                    ;6f66	3e fc
	add a,(iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6f68	fd 86 09
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6f6b	fd 77 09

	; Move left
    ld a, - 24		                                    ;6f6e	3e e8
	add a,(iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6f70	fd 86 0d
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6f73	fd 77 0d

    ; Next lasering transformation step
	inc (ix+VAUS_TABLE_IDX_LASER_TRANSFORMATION_STEP)		;6f76	dd 34 07
	ld (ix+VAUS_TABLE_IDX_RESIZING),VAUS_ACTION_STATE_KEEP	;6f79	dd 36 05 01
    
    ; Done
	jp vaus_follow_ball_demo_or_read_controls		        ;6f7d	c3 0f 69

lasering_step_1:
    ; Move right
	ld a, 4		                                            ;6f80	3e 04
	add a,(iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		    ;6f82	fd 86 01
	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		    ;6f85	fd 77 01

	; Move left
    ld a, -12		                                        ;6f88	3e f4
	add a,(iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		    ;6f8a	fd 86 09
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		    ;6f8d	fd 77 09

	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_PATTERN_NUM), 20	    ;6f90	fd 36 02 14     Left edge
	ld (iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_PATTERN_NUM), 16		;6f94	fd 36 06 10     Gray center
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_PATTERN_NUM), 28		;6f98	fd 36 0a 1c     Red central part of the firing Vaus
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_PATTERN_NUM), 24		;6f9c	fd 36 0e 18     Right edge

	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 14		;6fa0	fd 36 03 0e 	Gray
	ld (iy+1*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 14		;6fa4	fd 36 07 0e 	Gray
	ld (iy+2*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR),  8		;6fa8	fd 36 0b 08 	Red
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_COLOR), 14		;6fac	fd 36 0f 0e 	Gray
	
    ; Next lasering transformation step 
    inc (ix+VAUS_TABLE_IDX_LASER_TRANSFORMATION_STEP)		;6fb0	dd 34 07

    ; Done
	jp vaus_follow_ball_demo_or_read_controls		        ;6fb3	c3 0f 69

lasering_step_2_and_3:
    ; Move left
	ld a, -4		                                    ;6fb6	3e fc
	add a,(iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6fb8	fd 86 01
	ld (iy+0*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6fbb	fd 77 01

    ; Move right
	ld a, 4		                                        ;6fbe	3e 04
	add a,(iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X)		;6fc0	fd 86 0d
	ld (iy+3*SPR_PARAMS_LEN + SPR_PARAMS_IDX_X),a		;6fc3	fd 77 0d

    ; Next lasering transformation step
	inc (ix+VAUS_TABLE_IDX_LASER_TRANSFORMATION_STEP)		;6fc6	dd 34 07
	ld a,(ix+VAUS_TABLE_IDX_LASER_TRANSFORMATION_STEP)		;6fc9	dd 7e 07
	cp 4		                                            ;6fcc	fe 04
	jp nz,vaus_follow_ball_demo_or_read_controls		    ;6fce	c2 0f 69

    ; Transformation done
	ld (ix+VAUS_TABLE_IDX_RESIZING),VAUS_ACTION_STATE_WAIT_READY	;6fd1	dd 36 05 00
	ld (ix+VAUS_TABLE_IDX_LASER_TRANSFORMATION_STEP), 0		        ;6fd5	dd 36 07 00

	ld (ix+VAUS_TABLE_IDX_ACTION_STATE), VAUS_ACTION_STATE_KEEP     ;6fd9	dd 36 00 01

    ; Done
	jp vaus_follow_ball_demo_or_read_controls		                ;6fdd	c3 0f 69

l6fe0h:
    ; Set Vaus shrinking
	ld (ix+VAUS_TABLE_IDX_ACTION_STATE), VAUS_ACTION_STATE_SHRINKING		;6fe0	dd 36 00 03
	jp vaus_follow_ball_demo_or_read_controls		                        ;6fe4	c3 0f 69

SPR_DATA_ARKANOID_CENTERED:
    ; (Y, X) position, sprite pattern number, and color of centered Vaus
    db 174, 80,   8,  8
    db 174, 96,   4, 14
    db 174, 112, 12,  8
    db 174, 128,  1,  0

; This table is used to get in increment is Vaus' position according to
; the controls
; Indexed as TBL_INCREMENT_POS_VAUS_CONTROLS[2*CONTROLS + 1]
TBL_INCREMENT_POS_VAUS_CONTROLS:
    db 0        ;6ff7
    db 0		;6ff8
	db 0		;6ff9
	db 0		;6ffa
	db 0		;6ffb
	db 0		;6ffc
	db 0		;6ffd
	db 0		;6ffe
	db 0		;6fff    
    db -4       ;7000   Left
    db 0        ;7001
    db -4       ;7002   Left ; ** Trick: set -10 (0xf6) for Turbo Mode! ;) UP + LEFT **
	db 0		;7003
    db -4       ;7004   Left
    db 0        ;7005
    db 0        ;7006
	db 0		;7007
	db 4		;7008   Right
	db 0		;7009
	db 4		;700a   Right   ; ** Trick: set 10 for Turbo Mode! ;) UP + RIGHT **
	db 0		;700b
	db 4		;700c   Right
	db 0		;700d
	db 0		;700e
	db 0		;700f
	db 0		;7010
	db 0		;7011
	db 0		;7012
	db 0		;7013
	db 0		;7014
	db 0		;7015
	db 0		;7016
	db 0		;7017
	db 0		;7018
; Turbo Mode:
; POKE 0X7002 0xF6
; POKE 0X700A 10

; Pattern codes of the destroyed Vaus
VAUS_DESTROYED_PATTERNS:
    db 0x0, 0x0, 0x0, 0x0, 0x2b, 0x70, 0x32, 0x70       ; 0x7019 - 0x7020
    db 0x2b, 0x70, 0x32, 0x70, 0x2b, 0x70, 0x32, 0x70   ; 0x7021 - 0x7028
    db 0x2b, 0x70, 0x38, 0x3c, 0x40, 0x44, 0x2c, 0x30   ; 0x7029 - 0x7030
    db 0x34, 0x54, 0x58, 0x5c, 0x60, 0x48, 0x4c, 0x50   ; 0x7031 - 0x7038


; Check if the lasers are active, and update them
LASERS_STEP:
	call CHECK_START_LASERS		;7039	cd 40 70
	call LASERS_FIRE_STEP		;703c	cd b0 70
	ret			                ;703f	c9

; Check if we've pressed the fire button, and start lasers
CHECK_START_LASERS:
	ld ix,VAUS_TABLE		            ;7040	dd 21 4b e5

    ; If Vaus doesn't have the lasers, exit
	ld a,(ix+VAUS_TABLE_IDX_HAS_LASER)	;7044	dd 7e 06
	or a			                    ;7047	b7
	ret z			                    ;7048	c8    
    ; We've got the lasers

    ; If we've going through the portal, exit
	ld a,(ix+VAUS_TABLE_IDX_ACTION_STATE)	;7049	dd 7e 00
	cp VAUS_ACTION_STATE_THROUGH_PORTAL		;704c	fe 07
	ret z			                        ;704e	c8

    ld b, 1		        ;704f	06 01
    
    ; If we're in the demo, skip the following
	ld a,(GAME_STATE)		;7051	3a 0b e0
	or a			        ;7054	b7
	jp z,l7074h		        ;7055	ca 74 70
	
    ; Skip if we're using cursors
    ld a,(USE_VAUS_PADDLE)		;7058	3a 0c e0
	or a			            ;705b	b7
	jp z,l706ah		            ;705c	ca 6a 70

    ; Check if the paddle's button has been pressed
	ld a,(PADDLE_STATUS+1)		;705f	3a c5 e0
	bit 1,a		                ;7062	cb 4f
	jp z,l70afh		            ;7064	ca af 70
	jp l7072h		            ;7067	c3 72 70
l706ah:
    ; Check if the fire button has been pressed
    ; If not, just exit
	ld a,(CONTROLS)	                ;706a	3a bf e0
	bit 4,a		                    ;706d	cb 67
	jp z,l70afh		                ;706f	ca af 70
l7072h:
    ; We've pressed fire!
    ; Loop over 2 lasers
	ld b, 2		            ;7072	06 02
l7074h:
	ld ix,LASER1_ACTIVE		    ;7074	dd 21 57 e5
	ld iy,LASER1_SPR_PARAMS		;7078	fd 21 e9 e0
l707ch:
	; If Vaus is not in normal state, move to the next laser
    ld a,(ix+VAUS_TABLE_IDX_ACTION_STATE)		;707c	dd 7e 00
	or a		                            	;707f	b7
	jp nz,l70a6h		                        ;7080	c2 a6 70
    
	ld (ix+VAUS_TABLE_IDX_ACTION_STATE), VAUS_ACTION_STATE_KEEP		;7083	dd 36 00 01
    ; Set laser's X to Vaus' X + 16 (a little bit upper)
	ld a,(VAUS_X)		                        ;7087	3a ce e0
	add a, 16		                            ;708a	c6 10
    ; Configure laser sprite
	ld (iy+SPR_PARAMS_IDX_Y), 174		        ;708c	fd 36 00 ae
	ld (iy+SPR_PARAMS_IDX_X)   ,a		        ;7090	fd 77 01
	ld (iy+SPR_PARAMS_IDX_PATTERN_NUM), 132		;7093	fd 36 02 84
	ld (iy+SPR_PARAMS_IDX_COLOR), 5		        ;7097	fd 36 03 05

    ; Play laser sound
	ld a,SOUND_VAUS_FIRING_X3	;709b	3e 06
	call ADD_SOUND		        ;709d	cd ef 5b

    ; Update ball's speed
	call UPDATE_SPEED_ALL_BALLS		;70a0	cd 6e 71
    
    ; And exit
	jp l70afh		                ;70a3	c3 af 70
l70a6h:
    ; Next laser sprite
	ld de,SPR_PARAMS_LEN	;70a6	11 04 00
	add iy,de		        ;70a9	fd 19
	add ix,de		        ;70ab	dd 19
	djnz l707ch		        ;70ad	10 cd
l70afh:
	ret			            ;70af	c9

; Perform one step of the firing lasers
; Move them up and check if they hit a brick
LASERS_FIRE_STEP:
	; Set lasers are being fired
    ld a, 1		               ;70b0	3e 01
	ld (LASERS_FIRING),a	;70b2	32 19 e5
    
	ld ix,LASER1_SPR_PARAMS	;70b5	dd 21 e9 e0
	ld iy,LASER1_ACTIVE		;70b9	fd 21 57 e5
    
    ; Iterate through 3 lasers
	ld b, 3		            ;70bd	06 03
l70bfh:
	push bc			        ;70bf	c5
    
    ; Reset BRICK_HIT_ROW
	xor a			        ;70c0	af
	ld (BRICK_HIT_ROW),a	;70c1	32 3c e5

    ; Check if this laser is active
    ; Next laser if not
	ld a,(iy+000h)	;70c4	fd 7e 00
	or a			;70c7	b7
	jp z,l715dh		;70c8	ca 5d 71

    ; Move up laser 5 pixels
	ld a, -5		                ;70cb	3e fb
	add a,(ix+SPR_PARAMS_IDX_Y)		;70cd	dd 86 00

    ; Check if the laser has reached the top of the playfield
    ; If so, set it invisible, and next laser
	ld (ix+SPR_PARAMS_IDX_Y),a		;70d0	dd 77 00
	cp 8		                    ;70d3	fe 08
	jp c,l7155h		                ;70d5	da 55 71
    
    ; Check if laser's Y is within the brick area (between 23 and 119)
    ; If not, next laser
	ld a,(ix+SPR_PARAMS_IDX_Y)		;70d8	dd 7e 00
	cp 23		                    ;70db	fe 17
	jp c,l715dh		                ;70dd	da 5d 71
	cp 119		                    ;70e0	fe 77
	jp nc,l715dh		            ;70e2	d2 5d 71

    ; A = (Y-23) / 8. It's looking ay Y-23 because the laser hits the brick above
	sub 23		;70e5	d6 17   Y = Y - 23
	srl a		;70e7	cb 3f   /2
	srl a		;70e9	cb 3f   /2
	srl a		;70eb	cb 3f   /2
    
    ; BRICK_ROW <- (Y-23) / 8
	ld (BRICK_ROW),a		;70ed	32 aa e2

    ; Check if laser's is within the X brick area (between 23 and 191)
	ld a,(ix+SPR_PARAMS_IDX_X)		;70f0	dd 7e 01
	cp 16		                    ;70f3	fe 10
	jp c,l7118h		                ;70f5	da 18 71
	cp 191		                    ;70f8	fe bf
	jp nc,l7118h		            ;70fa	d2 18 71
    
    ; A = (X-16)/16
	sub 16		;70fd	d6 10
	srl a		;70ff	cb 3f
	srl a		;7101	cb 3f
	srl a		;7103	cb 3f
	srl a		;7105	cb 3f

    ; BRICK_COL <- (X-16) / 16
	ld (BRICK_COL),a		;7107	32 ab e2
    
    ; Skip if there's no brick
	call BRICK_EXISTS_AT_ROWCOL		;710a	cd a8 ad
	jp nc,l7118h		;710d	d2 18 71

    ; BRICK_HIT_ROW <-- 1
	ld a, 1		            ;7110	3e 01
	ld (BRICK_HIT_ROW),a	;7112	32 3c e5

    ; Perform the corresponding brick action
	call APPLY_BRICK_HIT_EFFECT		;7115	cd 05 aa
l7118h:
    ; Check if X+14 is in [16, 191]
	ld a,(ix+SPR_PARAMS_IDX_X)	;7118	dd 7e 01
	add a, 14		            ;711b	c6 0e
	cp 16		                ;711d	fe 10
	jp c,l7142h		            ;711f	da 42 71
	cp 191		                ;7122	fe bf
	jp nc,l7142h		        ;7124	d2 42 71
    
    ; A = (X+14-16)/16 = (X-2)/16
	sub 16		;7127	d6 10
	srl a		;7129	cb 3f
	srl a		;712b	cb 3f
	srl a		;712d	cb 3f
	srl a		;712f	cb 3f
	
    ; BRICK_COL <- (X-2)/16
    ld (BRICK_COL),a		;7131	32 ab e2
    
    ; Skip if there's no brick
	call BRICK_EXISTS_AT_ROWCOL	;7134	cd a8 ad
	jp nc,l7142h		    ;7137	d2 42 71

    ; BRICK_HIT_ROW <-- 1
	ld a, 1	                ;713a	3e 01
	ld (BRICK_HIT_ROW),a	;713c	32 3c e5

    ; Perform the corresponding brick action
	call APPLY_BRICK_HIT_EFFECT		;713f	cd 05 aa
l7142h:
	ld a,(BRICK_HIT_ROW)		;7142	3a 3c e5
	or a			            ;7145	b7
	jp z,l715dh		            ;7146	ca 5d 71
    
    ; Set the laser's sprite invisible
	ld (ix+SPR_PARAMS_IDX_Y), 192		    ;7149	dd 36 00 c0
	ld (ix+SPR_PARAMS_IDX_PATTERN_NUM), 0	;714d	dd 36 02 00
	ld (iy+SPR_PARAMS_IDX_Y), 0		        ;7151	fd 36 00 00
l7155h:
    ; Set the laser's sprite invisible
	ld (ix+SPR_PARAMS_IDX_Y), 192	;7155	dd 36 00 c0
    ; Set the laser is no longer active
	ld (iy+000h), 0		            ;7159	fd 36 00 00
l715dh:
    ; Next laser
	pop bc			        ;715d	c1
	ld de, SPR_PARAMS_LEN	;715e	11 04 00
	add ix,de		        ;7161	dd 19
	add iy,de		        ;7163	fd 19
	dec b			        ;7165	05
	jp nz,l70bfh		    ;7166	c2 bf 70
    
    ; Set lasers are not being fired
	xor a			                ;7169	af
	ld (LASERS_FIRING),a	        ;716a	32 19 e5
	ret			                    ;716d	c9

; Speed up all active balls if the counter has reached its maximum
; It begins with a 'ret' at 716e, so it's unused finally.
UPDATE_SPEED_ALL_BALLS:
	; It seems they decided not to implement this.
    ret			;716e	c9

	push ix		;716f	dd e5
	push bc		;7171	c5

    ; Increase the counter
	ld hl,SPEEDUP_ALL_BALLS_COUNTER		;7172	21 29 e5
	inc (hl)			;7175	34
	ld a,(hl)			;7176	7e
	cp 8		        ;7177	fe 08
    ; If less than 8, get out
	jp c,l71a1h		    ;7179	da a1 71
    ; Reset counter
	ld (hl), 0		    ;717c	36 00

    ; Now a loop to increase the speed of all balls
	ld ix,BALL_TABLE1		;717e	dd 21 4e e2
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
	ld (ix + BALL_TABLE_IDX_SPEED_POS),a		;7191	dd 77 07
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
    
    ; Unused
    db 0x18, 0x18, 0x18, 0x18, 0x18, 0x3c, 0x6a, 0x99   ; 0x71a5 - 0x71ac
    db 0x7e, 0x8c, 0x0, 0x5, 0x7e, 0x8c, 0x1, 0x5       ; 0x71ad - 0x71b4
    db 0x7e, 0x8c, 0x2, 0x5                             ; 0x71b5

; Draw the lives
DRAW_LIVES:
    ; Leave if zero extra lives
	ld a,(LIVES)	;71b9	3a 1d e0
	or a			;71bc	b7
	ret z			;71bd	c8
    
	ld a,(LIVES)	;71be	3a 1d e0
l71c1h:
    ; Display only up to 6 lives
	cp 6		    ;71c1	fe 06
	jp c,l71c8h		;71c3	da c8 71
	ld a, 6		    ;71c6	3e 06
l71c8h:
	ld (BRICK_HIT_ROW),a		;71c8	32 3c e5    Remaining lives to draw
	xor a			            ;71cb	af
	ld (BRICK_HIT_COL),a		;71cc	32 3d e5    Index of the live being drawn
    
    ; Interesting: it seems they wanted to use IY as a VRAM pointer, but
    ; later they decided to use table LIVES_VDP_ADDRESSES. And they forgot to
    ; remove this instruction:
	ld iy,0x1800 + 26 + 11*32   ;71cf	fd 21 7a 19     Locate at [26, 11]
l71d3h:
    ; Get the address to write in VRAM
    ; DE = LIVES_VDP_ADDRESSES[2*BRICK_HIT_COL]
	ld a,(BRICK_HIT_COL)		;71d3	3a 3d e5
	ld l,a			            ;71d6	6f
	ld h,000h		            ;71d7	26 00
	add hl,hl			        ;71d9	29
	ld de, LIVES_VDP_ADDRESSES  ;71da	11 f8 71
	add hl,de			        ;71dd	19
	ld e,(hl)			        ;71de	5e
	inc hl			            ;71df	23
	ld d,(hl)			        ;71e0	56

    ; Write 2 patters for each life
	ld hl,LIVE_PATTERNS		    ;71e1	21 f6 71
	ld bc, 2		            ;71e4	01 02 00
l71e7h:
	call LDIRVM		            ;71e7	cd 5c 00

    ; Incremente count of drawn lives
	ld hl,BRICK_HIT_COL		    ;71ea	21 3d e5
	inc (hl)			        ;71ed	34
    
    ; Decrement remaining lives
	ld hl,BRICK_HIT_ROW		    ;71ee	21 3c e5
	dec (hl)			        ;71f1	35

	jp nz,l71d3h		        ;71f2	c2 d3 71
	ret			                ;71f5	c9

LIVE_PATTERNS:
    db 0x69, 0x6a

LIVES_VDP_ADDRESSES:
    dw 0x197a, 0x197c, 0x197e, 0x199a, 0x199c, 0x199e   ; 0x71f8




; Write "ROUND x"
WRITE_ROUND_MSG:
    ; Write "ROUND"
	ld hl,ROUND_STR2	            ;7204	21 3c 72
	ld de, 0x1800 + 26 + 22*32		;7207	11 da 1a    Locate at [26, 22]
	ld bc, 5		                ;720a	01 05 00    5 chars
	call LDIRVM		                ;720d	cd 5c 00
    
	; A = LEVEL (starting at 1) in BCD
    ld a,(LEVEL_DISP)		;7210	3a 1c e0
	add a,1		            ;7213	c6 01
	daa			            ;7215	27
    
    ; E = LEVEL >> 4 + 0x30
    ; E is the first digit in ASCII
	ld e,a		;7216	5f
	push de		;7217	d5
	srl a		;7218	cb 3f
	srl a		;721a	cb 3f
	srl a		;721c	cb 3f
	srl a		;721e	cb 3f
	add a,030h	;7220	c6 30
    
	; If it's a zero (0x30), draw a space instead to avoid the heading zero.
    cp 030h		    ;7222	fe 30
	jp nz,l7229h    ;7224	c2 29 72
    
	ld a, " "		;7227	3e 20
l7229h:
    ; Write first digit
	ld hl, 0x1800 + 29 + 23*32		;7229	21 fd 1a    Locate at [29, 23]
	call WRTVRM		                ;722c	cd 4d 00
	pop de			                ;722f	d1
    
    ; Write second digit
	ld a,e			                ;7230	7b
	and 00fh		                ;7231	e6 0f
	add a,030h		                ;7233	c6 30
	ld hl, 0x1800 + 30 + 23*32		;7235	21 fe 1a    Locate at [30, 23]
	call WRTVRM		                ;7238	cd 4d 00
	ret			                    ;723b	c9

; A duplication of the "ROUND" string, since we already have ROUND_STR.
; Perhaps at the beginning the strings were different?
ROUND_STR2:
    db "ROUND"

; Checks the demo's timeout and moves back to the title's screen
; when reached.
CHECK_DEMO_TIMEOUT:
    ; Skip if we're not in the demo
	ld a,(GAME_STATE)		;7241	3a 0b e0
	or a			        ;7244	b7
	jp nz,l726eh		    ;7245	c2 6e 72

    ; We're in the demo

    ; Increment demo timeout counter
    ; The demo timeout after 2880 (0xb40) counts 
	ld hl,(DEMO_TIMEOUT)		;7248	2a ad e5
	inc hl			            ;724b	23
	ld (DEMO_TIMEOUT),hl		;724c	22 ad e5
	ld a,l			            ;724f	7d
	cp 040h		                ;7250	fe 40
	jp nz,l726eh		        ;7252	c2 6e 72
	ld a,h			            ;7255	7c
	cp 00bh		                ;7256	fe 0b
	jp nz,l726eh		        ;7258	c2 6e 72

    ; Timeout: go to title's screen
    ; It uses the code to start a level, but actually here it will
    ; go to the title's screen
	ld a, GAME_TRANSITION_ACTION_START_LEVEL	;725b	3e 00
	ld (GAME_TRANSITION_ACTION),a		        ;725d	32 0a e0

    ; Clear variables
	ld hl,BRICK_HIT_ROW		;7260	21 3c e5
	ld de,BRICK_HIT_COL		;7263	11 3d e5
	ld bc, 7		        ;7266	01 07 00
	ld (hl), 0  	        ;7269	36 00
	ldir		            ;726b	ed b0
	ret			            ;726d	c9

l726eh:
	ld a,(LEVEL)		                ;726e	3a 1b e0
	cp FINAL_LEVEL		                ;7271	fe 20
	jp z,doh_level		                    ;7273	ca 86 72
	call UPDATE_ALIENS		            ;7276	cd 05 76
	call CHECK_LASERS_HITS_ALIEN	    ;7279	cd 88 78
	call CHECK_ALIEN_HIT_BY_VAUS	    ;727c	cd 42 79
	call UPDATE_ALIEN_APPEAR_FROM_DOOR	;727f	cd 0c 73
	call UPDATE_DOORS		            ;7282	cd a0 72
	ret			                        ;7285	c9

; This is Doh's stuff...
doh_level:
    ; Skip if Doh is already defeated
	ld a,(DOH_TABLE)		;7286	3a 0d e5
	or a			        ;7289	b7
	jp nz,l7296h		    ;728a	c2 96 72

    ; Doh's not defeated
	call DRAW_DOH_MOUTH_OPEN		;728d	cd 94 75
	call DOH_THROW_BULLETS_CYCLE	;7290	cd 69 74
	call CHECK_VAUS_KILLED_BY_DOH	;7293	cd 68 7a
l7296h:
    ; Doh's been defeated
	call DOH_MOVE_BULLETS		;7296	cd c7 74
	call DOH_UPDATE_COLOR		;7299	cd aa 73
	call DOH_DEFEATED_ANIMATION	;729c	cd f0 73
	ret			                ;729f	c9

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

    ; Increment X = (ix+DOOR_TABLE_IDX_DOOR_OPEN_COUNTER).
    ; If X = 0 THEN call SET_ALIEN_COLOR_BY_LEVEL and exit
    ; If X != 6 THEN exit
    ; Clear the DOOR_TABLE
    
	inc (ix+DOOR_TABLE_IDX_DOOR_OPEN_COUNTER)		;72d4	dd 34 04
	ld a,(ix+DOOR_TABLE_IDX_DOOR_OPEN_COUNTER)		;72d7	dd 7e 04
	cp 3		                                    ;72da	fe 03
	jp nz,l72e3h		                            ;72dc	c2 e3 72
	call SET_ALIEN_COLOR_BY_LEVEL		            ;72df	cd 77 73
	ret			                                    ;72e2	c9

l72e3h:
    ; The door is open for 6 cycles.
    ; If we haven't reached 6, then exit. Other wise, clear the whole table.
	cp 6		    ;72e3	fe 06
	ret nz			;72e5	c0
    
    ; Clear DOOR_TABLE
	ld hl,DOOR_TABLE		;72e6	21 70 e5
	ld de,DOOR_TABLE + 1	;72e9	11 71 e5
	ld bc,DOOR_TABLE_LEN    ;72ec	01 06 00
	ld (hl), 0  		    ;72ef	36 00
	ldir		            ;72f1	ed b0
	ret			            ;72f3	c9

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
	ld ix,ALIEN_DOOR_TICKS	;730c	dd 21 15 e5
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
	ld a,1  		                        ;7333	3e 01
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

ALIEN_COLOR_CODES:
    db 0 ; blue
    db 1 ; green
    db 2 ; sky blue
    db 3 ; red

; Set the alien's color according to the level
SET_ALIEN_COLOR_BY_LEVEL:
    ; Get the number of aliens in this level
	ld a,(LEVEL)                    ;7377	3a 1b e0
	ld e,a			                ;737a	5f
	ld d,000h		                ;737b	16 00   DE = LEVEL
	ld hl,TABLE_ALIENS_PER_LEVEL	;737d	21 53 73
	add hl,de			            ;7380	19      HL = TABLE_ALIENS_PER_LEVEL + LEVEL
	ld b,(hl)			            ;7381	46      B = TABLE_ALIENS_PER_LEVEL[LEVEL]

	ld iy,ALIEN_TABLE		        ;7382	fd 21 c7 e4
l7386h:
    ; Skip this alien if not active
	ld a,(iy+ALIEN_TABLE_IDX_ACTIVE) ;7386	fd 7e 01
	or a			                 ;7389	b7
	jp nz,l73a2h		             ;738a	c2 a2 73
    
    ; The alien is active
    
    ; Mark it as active. Why? We know already it's active...
	ld (iy+ALIEN_TABLE_IDX_ACTIVE), 1	;738d	fd 36 01 01
    
    ; Set the alien's color according to the current level
	ld a,(LEVEL)	    ;7391	3a 1b e0
	and 3		        ;7394	e6 03
	ld e,a			    ;7396	5f
	ld d,0		        ;7397	16 00          DE = LEVEL mod 4
	ld hl,ALIEN_COLOR_CODES	;7399	21 73 73
	add hl,de			;739c	19             HL = ALIEN_COLOR_CODES + LEVEL

    ; Set alien's color
	ld a,(hl)			            ;739d	7e  A = ALIEN_COLOR_CODES[LEVEL]
	ld (iy+ALIEN_TABLE_IDX_COLOR),a	;739e	fd 77 00
	ret			                    ;73a1	c9
l73a2h:
    ; Next alien
	ld de, ALIEN_TABLE_LEN	;73a2	11 14 00
	add iy,de		        ;73a5	fd 19
	djnz l7386h		        ;73a7	10 dd
	ret			            ;73a9	c9

; Change Doh's color, from back to red, and vice versa.
DOH_UPDATE_COLOR:
    ; Skip is Doh has been defeated
	ld ix,DOH_TABLE		                ;73aa	dd 21 0d e5
	ld a,(ix+DOH_TABLE_IDX_DEFEATED)	;73ae	dd 7e 00
	or a			                    ;73b1	b7
	ret nz			                    ;73b2	c0
    
    ; Skip if Doh hasn't been hit
	ld ix,TBL_DOH_HIT		                ;73b3	dd 21 05 e5
	ld a,(ix+TBL_DOH_HIT_IDX_DOH_BEEN_HIT)	;73b7	dd 7e 00
	or a			                    ;73ba	b7
	ret z			                    ;73bb	c8

    ; Delay counter
    ; Wait 3 cycles before changing the color
	inc (ix+TBL_DOH_HIT_IDX_HIT_CYCLE_NUM)		;73bc	dd 34 01
	ld a,(ix+TBL_DOH_HIT_IDX_HIT_CYCLE_NUM)		;73bf	dd 7e 01
	cp 3		                                ;73c2	fe 03
	ret nz			                            ;73c4	c0

    ; Reset delay counter
	ld (ix+TBL_DOH_HIT_IDX_HIT_CYCLE_NUM), 0		;73c5	dd 36 01 00
    
    ; Choose the color for Doh: turning into white, or getting back to red
	ld e,(ix+TBL_DOH_HIT_IDX_COLOR)		;73c9	dd 5e 02
	ld d, 0		                        ;73cc	16 00
	ld hl,TBL_DOH_HIT_COLORS		    ;73ce	21 50 74
	add hl,de			                ;73d1	19
	ld a,(hl)			                ;73d2	7e
	call COLORIZE_DOH		            ;73d3	cd 52 74
    
    ; Next color
    ; If >= 2, then color = 0
	inc (ix+TBL_DOH_HIT_IDX_COLOR)		;73d6	dd 34 02
	ld a,(ix+TBL_DOH_HIT_IDX_COLOR)		;73d9	dd 7e 02
	cp 2		                        ;73dc	fe 02
	ret nz			                    ;73de	c0
    
    ; Reset Doh's attributes
	ld (ix+TBL_DOH_HIT_IDX_DOH_BEEN_HIT), 0	 ;73df	dd 36 00 00
	ld (ix+TBL_DOH_HIT_IDX_HIT_CYCLE_NUM), 0 ;73e3	dd 36 01 00
	ld (ix+TBL_DOH_HIT_IDX_COLOR), 0	     ;73e7	dd 36 02 00
    ; This is reset (address 0xe508), but actually never checked.
	ld (ix+3), 0 		                     ;73eb	dd 36 03 00
	ret			                             ;73ef	c9

DOH_DEFEATED_ANIMATION:
    ; Skip if Doh hasn't been yet defeated
	ld ix,DOH_TABLE		                ;73f0	dd 21 0d e5
	ld a,(ix+DOH_TABLE_IDX_DEFEATED)	;73f4	dd 7e 00
	or a			                    ;73f7	b7
	ret z			                    ;73f8	c8
    
    ; Doh has been defeated

    ; Execute the corresponding "postmorten" action
	ld a,(ix+DOH_TABLE_IDX_POSTMORTEN_ACTION)	;73f9	dd 7e 01
	cp 1		                                ;73fc	fe 01
	jp z,remove_one_line_of_doh		            ;73fe	ca 10 74
	cp 2		                                ;7401	fe 02
	jp z,delay_before_ending		            ;7403	ca 41 74

    ; Colorize Doh with gray over black
	ld a,0xe1		                            ;7406	3e e1
	call COLORIZE_DOH		                    ;7408	cd 52 74

    ; Set the next action to 1
	ld (ix+DOH_TABLE_IDX_POSTMORTEN_ACTION), 1	;740b	dd 36 01 01
	ret			                                ;740f	c9

remove_one_line_of_doh:
	inc (ix+DOH_TABLE_IDX_ROW_DELAY)		;7410	dd 34 02
	ld a,(ix+DOH_TABLE_IDX_ROW_DELAY)		;7413	dd 7e 02
	cp 22		                            ;7416	fe 16
	ret nz			                        ;7418	c0

	ld (ix+DOH_TABLE_IDX_ROW_DELAY), 0		;7419	dd 36 02 00

    ; Erase one line of chars of Doh
	ld l,(ix+DOH_TABLE_IDX_ROW)		;741d	dd 6e 03
	ld h, 0		        ;7420	26 00
	add hl,hl			;7422	29
	add hl,hl			;7423	29
	add hl,hl			;7424	29
	add hl,hl			;7425	29
	add hl,hl			;7426	29
	ld de,0x1800 + 9 + 3*32		;7427	11 69 18    Locate at [9, 3]
	add hl,de			;742a	19
    ; Fill with 8 zeros
	ld bc, 8		    ;742b	01 08 00
	ld a, 0		        ;742e	3e 00
	call FILVRM		    ;7430	cd 56 00

	inc (ix+DOH_TABLE_IDX_ROW)		;7433	dd 34 03
	ld a,(ix+DOH_TABLE_IDX_ROW)		;7436	dd 7e 03
	cp 12		                    ;7439	fe 0c
	ret nz			                ;743b	c0

    ; The next "postmorten" cycle is 2: delay and ending text
	ld (ix+DOH_TABLE_IDX_POSTMORTEN_ACTION), 2		;743c	dd 36 01 02
	ret			                                    ;7440	c9
;
delay_before_ending:
    ; Increment the delay counter
    ; When it reaches 120, end the game
	inc (ix+DOH_TABLE_IDX_DELAY_BEFORE_ENDING)		;7441	dd 34 04
	ld a,(ix+DOH_TABLE_IDX_DELAY_BEFORE_ENDING)		;7444	dd 7e 04
	cp 120		                                    ;7447	fe 78
	ret nz			                                ;7449	c0

    ; Move to the game ending
	ld a,GAME_TRANSITION_ACTION_NEXT_LEVEL		    ;744a	3e 02
	ld (GAME_TRANSITION_ACTION),a		            ;744c	32 0a e0
	ret			                                    ;744f	c9

; This table picks the colors of Doh when hit
TBL_DOH_HIT_COLORS:
    db 0xf1 ; White over black
    db 0x81 ; Red over black

COLORIZE_DOH:
	push af			    ;7452	f5
    ; Fill first half of Doh
	ld hl,02480h		;7453	21 80 24
	ld bc,00380h		;7456	01 80 03
	call FILVRM		    ;7459	cd 56 00
	pop af			    ;745c	f1
    ; Fill second half of Doh
	push af			    ;745d	f5
	ld hl,02c80h		;745e	21 80 2c
	ld bc,00380h		;7461	01 80 03
	call FILVRM		    ;7464	cd 56 00
	pop af			    ;7467	f1
	ret			        ;7468	c9

; Check if Doh can throw bullets and throw them according to the
; corresponding counters.
DOH_THROW_BULLETS_CYCLE:
    ; Skip if all 3 bullets are already active
	ld a,(DOH_NUM_ACTIVE_BULLETS)	;7469	3a 1a e5
	cp 3		                    ;746c	fe 03
	ret z			                ;746e	c8

    ; If Doh can't throw bullets, check the bullets counter
	ld hl,DOH_CAN_THROW_BULLETS		;746f	21 78 e5
	ld a,(hl)			            ;7472	7e
	or a			                ;7473	b7
	jp z,l7483h		                ;7474	ca 83 74
    
    ; Doh can throw bullets

    ; Increment DOH_THROW_BULLETS_COUNTER
    ; Exit if it hasn't yet reached 120
	inc hl			    ;7477	23      Point to DOH_THROW_BULLETS_COUNTER
	inc (hl)			;7478	34
	ld a,(hl)			;7479	7e
	cp 120		        ;747a	fe 78
	ret nz			    ;747c	c0      Skip if 120 not reached
    
    ; DOH_THROW_BULLETS_COUNTER has reached 120.
    ; Reset counter.
    ld (hl), 0  		;747d	36 00
    
    ; DOH_CAN_THROW_BULLETS <-- 0
	dec hl			;747f	2b
	ld (hl), 0  	;7480	36 00
	ret			    ;7482	c9

l7483h:
    ; Increment the bullets counter and exit if
    ; it hasn't reached 12 yet
	ld a,(DOH_NEW_BULLET_COUNTER)		;7483	3a 81 e5
	add a, 1		                    ;7486	c6 01
	ld (DOH_NEW_BULLET_COUNTER),a		;7488	32 81 e5
	cp 12		                        ;748b	fe 0c
	ret c			                    ;748d	d8
    
    ; Reset bullets counter
	ld a, 0		                        ;748e	3e 00
	ld (DOH_NEW_BULLET_COUNTER),a		;7490	32 81 e5
    
    ; Now add bullets, using the inactive slots in the list
	ld b, 3		                ;7493	06 03
	ld ix,DOH_BULLETS_TABLE	    ;7495	dd 21 63 e5
	ld iy,DOH_BULLET_SPR_PARAMS	    ;7499	fd 21 0d e1
add_new_bullet:
    ; Go to the next bullet if this one is already active
	ld a,(ix+DOH_BULLETS_ACTIVE)	;749d	dd 7e 00
	or a			                ;74a0	b7
	jp nz,doh_goto_next_bullet		;74a1	c2 bd 74

	; Set bullet as active
    ld (ix+DOH_BULLETS_ACTIVE), 1	            ;74a4	dd 36 00 01
    
	ld (iy+SPR_PARAMS_IDX_Y), 80		        ;74a8	fd 36 00 50
	ld (iy+SPR_PARAMS_IDX_X), 100		        ;74ac	fd 36 01 64     Position (100, 80)
	ld (iy+SPR_PARAMS_IDX_PATTERN_NUM), 140		;74b0	fd 36 02 8c     Diamond
	ld (iy+SPR_PARAMS_IDX_COLOR), 14		    ;74b4	fd 36 03 0e     Gray color

    ; A new bullet in the list
	ld hl,DOH_NUM_ACTIVE_BULLETS		;74b8	21 1a e5
	inc (hl)			                ;74bb	34
	ret			                        ;74bc	c9

doh_goto_next_bullet:
	ld de, SPR_PARAMS_LEN		;74bd	11 04 00
	add iy,de		            ;74c0	fd 19
	add ix,de		            ;74c2	dd 19
	djnz add_new_bullet		            ;74c4	10 d7
	ret			                ;74c6	c9

; Move Doh's bullets
DOH_MOVE_BULLETS:
	ld b, 3		                ;74c7	06 03
	ld ix,DOH_BULLETS_TABLE		;74c9	dd 21 63 e5
	ld iy,DOH_BULLET_SPR_PARAMS		;74cd	fd 21 0d e1     Bullet
l74d1h:
	push bc			                    ;74d1
    
    ; Skip if the bullet is not active
	ld a,(ix+DOH_BULLETS_ACTIVE)		;74d2	dd 7e 00
	or a			                    ;74d5	b7
	jp z,doh_process_next_bullet        ;74d6	ca 66 75

    ; Skip if the bullets are following Vaus
	ld a,(ix+DOH_BULLETS_TABLE_IDX_FOLLOW_VAUS)   ;74d9	dd 7e 01
	or a			                              ;74dc
	jp nz,l7501h		                            ;74dd	c2 01 75
    
	; The bullets are not following Vaus
    ld (ix+DOH_BULLETS_TABLE_IDX_FOLLOW_VAUS), 1	;74e0	dd 36 01 01
    
    ; A <-- (BULLET_X - 8) \ 8
	ld hl,SPR_PARAMS_BASE		;74e4	21 cd e0
	inc hl			            ;74e7	23
	ld a,(hl)			        ;74e8	7e      A = BULLET_X
	sub 8		                ;74e9	d6 08   A = BULLET_X - 8
	and 0f8h		            ;74eb	e6 f8
	srl a		                ;74ed	cb 3f
	srl a		                ;74ef	cb 3f
	srl a		                ;74f1	cb 3f   A = (BULLET_X - 8) \ 8

    ; A <-- TBL_DOH_BULLET_SKEWNESS_1[(BULLET_X - 8) \ 8]
	ld hl,TBL_DOH_BULLET_SKEWNESS_1		;74f3	21 73 75
	ld e,a			                    ;74f6	5f
	ld d, 0		                        ;74f7	16 00
	add hl,de			                ;74f9	19
	ld a,(hl)			                ;74fa	7e

    ; Set bullet skewness so it follows Vaus
	ld (ix+DOH_BULLETS_TABLE_IDX_SKEWNESS),a	;74fb	dd 77 02
	ld (0e582h),a		;74fe	32 82 e5 	2 . . 
l7501h:
    ; Change the balls skewness only when DOH_BULLETS_TABLE_IDX_SKEWNESS_COUNTER
    ; reaches 3.
	ld a,(ix+DOH_BULLETS_TABLE_IDX_SKEWNESS_COUNTER)		;7501	dd 7e 03
	inc a			                                        ;7504	3c
	ld (ix+DOH_BULLETS_TABLE_IDX_SKEWNESS_COUNTER),a		;7505	dd 77 03
	cp 3		                                            ;7508	fe 03
	jp c,doh_process_next_bullet		                    ;750a	da 66 75

    ; Reset counter
	ld (ix+DOH_BULLETS_TABLE_IDX_SKEWNESS_COUNTER), 0		;750d	dd 36 03 00

	; But now set to 1 :D
    ld a, 1		                                            ;7511	3e 01
	ld (ix+DOH_BULLETS_TABLE_IDX_SKEWNESS_COUNTER),a		;7513	dd 77 03
    
    ; A <--(TBL_DOH_BULLET_SKEWNESS_2)[2*SKEWNESS]
	ld a,(ix+DOH_BULLETS_TABLE_IDX_SKEWNESS)	;7516	dd 7e 02
	ld l,a			                            ;7519	6f
	ld h, 0		                                ;751a	26 00
	add hl,hl			                        ;751c	29
	ld de,TBL_DOH_BULLET_SKEWNESS_2		        ;751d	11 86 75
	add hl,de			                        ;7520	19
	ld a,(hl)			                        ;7521	7e

    ; Set bullet's X <-- X + (TBL_DOH_BULLET_SKEWNESS_2)[2*SKEWNESS]
	ld b,a			                    ;7522	47          B = (TBL_DOH_BULLET_SKEWNESS_2)[2*SKEWNESS]
	ld a,(iy+SPR_PARAMS_IDX_X)		    ;7523	fd 7e 01
	add a,b			                    ;7526	80
	ld (iy+SPR_PARAMS_IDX_X),a		    ;7527	fd 77 01

	; A <-- (TBL_DOH_BULLET_SKEWNESS_2+1)[SKEWNESS]
    ld a,(ix+DOH_BULLETS_TABLE_IDX_SKEWNESS)	;752a	dd 7e 02
	ld l,a			                            ;752d	6f
	ld h, 0		                                ;752e	26 00
	add hl,hl			                        ;7530	29
	ld de,TBL_DOH_BULLET_SKEWNESS_2+1		    ;7531	11 87 75
	add hl,de			                        ;7534	19
	ld a,(hl)			                        ;7535	7e
    
	; Set bullet's Y <-- Y + (TBL_DOH_BULLET_SKEWNESS_2+1)[SKEWNESS]
    ld b,a			                            ;7536	47  B = (TBL_DOH_BULLET_SKEWNESS_2+1)[SKEWNESS]
	ld a,(iy+SPR_PARAMS_IDX_Y)		            ;7537	fd 7e 00
	add a,b			                            ;753a	80
	ld (iy+SPR_PARAMS_IDX_Y),a		            ;753b	fd 77 00
    
    ; If the ball's Y > 180, then reset its parameters
	cp 180		                        ;753e	fe b4
	jp c,doh_process_next_bullet		;7540	da 66 5
    
    ; Y > 180: remove bullet
    ld (ix+DOH_BULLETS_ACTIVE), 0		            ;7543	dd 36 00 00
	ld (ix+DOH_BULLETS_TABLE_IDX_FOLLOW_VAUS), 0	;7547	dd 36 01 00
	ld (ix+DOH_BULLETS_TABLE_IDX_SKEWNESS), 0	    ;754b	dd 36 02 00
	ld (iy+SPR_PARAMS_IDX_COLOR), 0		            ;754f	fd 36 03 00

	; Count how many bullets are out at this moment.
    ; If all 3 are out, allow Doh to throw more
    ld hl,DOH_NUM_BULLETS_OUT		;7553	21 77 e5
	inc (hl)			            ;7556	34
	ld a,(hl)			            ;7557	7e
	cp 3		                    ;7558	fe 03
	jp nz,doh_process_next_bullet	;755a	c2 66 75
    
    ; Reset counter
	ld (hl), 0		;755d	36 00
    
    ; Doh can now throw bullets
    ; DOH_CAN_THROW_BULLETS <-- 1
	inc hl			    ;755f	23  Point to DOH_CAN_THROW_BULLETS
	ld (hl), 1		    ;7560	36 01

    ; No active bullets now
	xor a			                    ;7562	af
	ld (DOH_NUM_ACTIVE_BULLETS),a		;7563	32 1a e5
doh_process_next_bullet:
	pop bc			        ;7566	c1
	ld de, SPR_PARAMS_LEN	;7567	11 04 00
	add ix,de		        ;756a	dd 19
	add iy,de		        ;756c	fd 19
	dec b			        ;756e	05
	jp nz,l74d1h		    ;756f	c2 d1 74
	ret			            ;7572	c9

TBL_DOH_BULLET_SKEWNESS_1:
    db 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6

TBL_DOH_BULLET_SKEWNESS_2:
    db -3, 4, -2, 4, -1, 4, 0, 4, 1, 4, 2, 4, 3, 4

; Draw Doh with his mouth open
DRAW_DOH_MOUTH_OPEN:
    ; Skip if the bullet is not active
	ld ix,DOH_BULLETS_TABLE		    ;7594	dd 21 63 e5
	ld a,(ix+DOH_BULLETS_ACTIVE)	;7598	dd 7e 00
	or a			                ;759b	b7
	jr nz,l75c8h		            ;759c	20 2a

    ; Skip if the 3rd bullet is not active.
    ; Doh closes his mouths as soon as the 3rd bullet disappears.
	ld a,(ix+2*DOH_BULLETS_TABLE_LEN + DOH_BULLETS_ACTIVE)	;759e	dd 7e 08
	or a			;75a1	b7
	ret z			;75a2	c8

    ; Draw Doh with his mouth open
	ld b, 3		                ;75a3	06 03       3 rows of chars
	ld ix,CHARS_DOH_OPEN_MOUTH	;75a5	dd 21 f9 75
	ld iy, 0x1800 + 11 + 8*32	;75a9	fd 21 0b 19 Locate at [11, 8]
l75adh:
	push ix		    ;75ad	dd e5
	push iy		    ;75af	fd e5
	pop de			;75b1	d1 	. 
	pop hl			;75b2	e1 	. 
	push bc			;75b3	c5 	. 
	ld bc, 4		;75b4	01 04 00    4 chars
	call LDIRVM		;75b7	cd 5c 00    Write to VRAM
	pop bc			;75ba	c1
    ; Next row
	ld de, DOH_BULLETS_TABLE_LEN    	;75bb	11 04 00
	add ix,de		;75be	dd 19
	ld de, 32   	;75c0	11 20 00
	add iy,de		;75c3	fd 19
	djnz l75adh		;75c5	10 e6
	ret			    ;75c7	c9

l75c8h:
    ; Closed Doh's mouth
	ld b,003h		                ;75c8	06 03
	ld ix,CHARS_DOH_CLOSED_MOUTH	;75ca	dd 21 ed 75
	ld iy,0190bh		            ;75ce	fd 21 0b 19
l75d2h:
	push ix		    ;75d2	dd e5
	push iy		    ;75d4	fd e5
	pop de			;75d6	d1
	pop hl			;75d7	e1
	push bc			;75d8	c5
	ld bc, 4		;75d9	01 04 00
    ; Write to VRAM
	call LDIRVM		;75dc	cd 5c 00
	pop bc			;75df	c1
    ; Next row
	ld de, 4		;75e0	11 04 00
	add ix,de		;75e3	dd 19
	ld de, 32		;75e5	11 20 00
	add iy,de		;75e8	fd 19
	djnz l75d2h		;75ea	10 e6
	ret			    ;75ec	c9

CHARS_DOH_CLOSED_MOUTH: ;75ed
    db 0xf0, 0xf1, 0xf2, 0xf3
    db 0xf4, 0xf5, 0xf6, 0xf7
    db 0xf8, 0xf9, 0xfa, 0xfb

CHARS_DOH_OPEN_MOUTH: ;75f9
    db 0xba, 0xbb, 0xbc, 0xbd
    db 0xc2, 0xc3, 0xc4, 0xc5
    db 0xca, 0xcb, 0xcc, 0xcd

; ToDo
; This is quite a long function!
; It'll be very useful to understand the alien's table
UPDATE_ALIENS:
    ld ix, ALIEN_TABLE
    ld iy, ALIEN_SPR_PARAMS
    ld b, 3
l760fh:
	push bc			                        ;760f	c5
    
    ; Skip if the alien is exploding
	ld a,(ix+ALIEN_TABLE_IDX_EXPLODING)		;7610	dd 7e 02
	cp 1		                            ;7613	fe 01
	jp z,alien_exploding                    ;7615	ca 22 77

    ; Check alien ticks
    ; We only execute every 5 ticks. Otherwise, move to the next alien
	inc (ix+ALIEN_TABLE_IDX_TICKS)		;7618	dd 34 03
	ld a,(ix+ALIEN_TABLE_IDX_TICKS)		;761b	dd 7e 03
	cp 5		                        ;761e	fe 05       Already in the 5th tick?
	jp nz,next_alien		            ;7620	c2 6d 78    No, next alien
	ld (ix+ALIEN_TABLE_IDX_TICKS),0	    ;7623	dd 36 03 00

    ; If the alien is not active, move to the next
	ld a,(ix+ALIEN_TABLE_IDX_ACTIVE)	;7627	dd 7e 01
	or a			                    ;762a	b7
	jp z,next_alien		                ;762b	ca 6d 78

    ; Check if the alien is in the door
	ld a,(ix+ALIEN_TABLE_IDX_IN_DOOR)		;762e	dd 7e 07
	cp 0		                            ;7631	fe 00
	jp nz,l7695h		                    ;7633	c2 95 76 Jump is he's in the door
    ; Set the alien is in the door
	ld (ix+ALIEN_TABLE_IDX_IN_DOOR), 1		;7636	dd 36 07 01

    ; Set the params of the alien (i.e. the position) according to the
    ; door he exits from.
	ld de,SPR_DOOR_1_TABLE		                ;763a	11 64 7b
	ld a,(DOOR_TABLE + DOOR_TABLE_IDX_DOOR)		;763d	3a 71 e5
	or a			                            ;7640	b7
	jp z,l7647h		                            ;7641	ca 47 76
	ld de,SPR_DOOR_2_TABLE		                ;7644	11 7c 7b
l7647h:
	ld a,(ix+ALIEN_TABLE_IDX_COLOR)		        ;7647	dd 7e 00

    ; HL = 2*color + SPR_DOOR_x_TABLE
	ld l,a			;764a	6f
	ld h, 0		    ;764b	26 00   HL = color
	add hl,hl		;764d	29      HL = 2*color
	add hl,de		;764e	19      HL = 2*color + table
    
    ; DE = SPR_DOOR_x_TABLE[2*color]
	ld e,(hl)			;764f	5e
	inc hl			    ;7650	23
	ld d,(hl)			;7651	56
	
    ; HL = SPR_DOOR_x_TABLE[2*color]
    ex de,hl			;7652	eb
	
    ; DE = ALIEN_SPR_PARAMS
    push iy		;7653	fd e5
	pop de		;7655	d1

    ; Copy sprite parameters ALIEN_SPR_PARAMS from SPR_DOOR_x_TABLE[2*color]
	ld bc,SPR_PARAMS_LEN	;7656	01 04 00
	ldir		            ;7659	ed b0

	; HL = ((VAUS_X - 8) >> 4) & 0xf0
    ld a,(VAUS_X)		;765b	3a ce e0
	sub 8		;765e	d6 08
	and 0f0h		;7660	e6 f0
	srl a		    ;7662	cb 3f
	srl a		    ;7664	cb 3f
	srl a		    ;7666	cb 3f
	srl a		    ;7668	cb 3f
	ld l,a			;766a	6f
	ld h, 0		    ;766b	26 00

    ; HL = TBL[((VAUS_X - 8) >> 4) & 0xf0]
    ; Choose if the alien should move left or right
	ld de,TBL_ALIEN_INITIAL_SPEED_X_LEFT_DOOR		        ;766d	11 ec 7a
	ld a,(iy+SPR_PARAMS_IDX_X)	;7670	fd 7e 01
    ; 40 is the position of the alien when it's on the left door
	cp 40		                ;7673	fe 28
	jr z,l767ah		            ;7675	28 03
	ld de,TBL_ALIEN_INITIAL_SPEED_X_RIGHT_DOOR		        ;7677	11 f9 7a
l767ah:
	add hl,de			;767a
	ld a,(hl)			;767b

    ; Set initial speed from the door according to the position of the alien
	ld (ix+ALIEN_TABLE_IDX_FROM_DOOR_HORIZ_SPEED),a		;767c	dd 77 06
	ld a,(ix+ALIEN_TABLE_IDX_FROM_DOOR_HORIZ_SPEED)		;767f	dd 7e 06
    
	; Set vertical speed
    ; ALIEN_VERT_SPEED = TBL_ALIEN_VERT_SPEED[2*initial_speed]
    and 3		                                        ;7682	e6 03
	ld l,a                                              ;7684	6f
	ld h, 0		                                        ;7685	26 00
	add hl,hl			                                ;7687	29      HL = 2*initial_speed
	ld de,TBL_ALIEN_VERT_SPEED		                    ;7688	11 06 7b
	add hl,de			                                ;768b	19      HL = TBL_ALIEN_VERT_SPEED + 2*initial_speed
    
    ; ALIEN_VERT_SPEED = TBL_ALIEN_VERT_SPEED[2*initial_speed]
	ld a,(hl)			                                ;768c	7e
	ld (ix+ALIEN_TABLE_IDX_VERT_SPEED),a		        ;768d	dd 77 08

    ; Set ALIEN_HORIZ_SPEED
	inc hl			                                    ;7690	23
	ld a,(hl)			                                ;7691	7e
	ld (ix+ALIEN_TABLE_IDX_HORIZ_SPEED),a		        ;7692	dd 77 09
l7695h:
    ; Skip if ALIEN_Y >= 64
	ld a,(iy+SPR_PARAMS_IDX_Y)		;7695	fd 7e 00
	cp 64		                    ;7698	fe 40
	jp nc,alien_walk		            ;769a	d2 ae 77

    ; Update vertical position according to the speed
    ; SPR_PARAMS_IDX_Y += ALIEN_TABLE_IDX_VERT_SPEED
	ld a,(ix+ALIEN_TABLE_IDX_VERT_SPEED)	;769d	dd 7e 08
	add a,(iy+SPR_PARAMS_IDX_Y)		        ;76a0	fd 86 00
	ld (iy+SPR_PARAMS_IDX_Y),a		        ;76a3	fd 77 00
    
    ; Update horizontal position according to the speed
    ; SPR_PARAMS_IDX_X += ALIEN_TABLE_IDX_HORIZ _SPEED
	ld a,(ix+ALIEN_TABLE_IDX_HORIZ_SPEED)	;76a6	dd 7e 09
	add a,(iy+SPR_PARAMS_IDX_X)		        ;76a9	fd 86 01
	ld (iy+SPR_PARAMS_IDX_X),a		        ;76ac	fd 77 01

    ; Perform next alien's action
	ld a,(ix+ALIEN_TABLE_IDX_NEXT_ACTION)		;76af	dd 7e 10
	cp 1		                    ;76b2	fe 01
	jp z,alien_inv_vert_speed		;76b4	ca 05 77
	cp 2		                    ;76b7	fe 02
	jp z,alien_inv_horiz_speed		;76b9	ca 10 77
	cp 3		                    ;76bc	fe 03
	jp z,set_alien_exploding		;76be	ca 1b 77
    
    ; Skip if Y >= 7
	ld a,(iy+SPR_PARAMS_IDX_Y)	            ;76c1	fd 7e 00
	cp 7		                            ;76c4	fe 07
	jp nc,l76d6h		                    ;76c6	d2 d6 76
    ; If VERT_SPEED < 0, then invert VERT_SPEED
	ld a,(ix+ALIEN_TABLE_IDX_VERT_SPEED)	;76c9	dd 7e 08
	bit 7,a		                            ;76cc	cb 7f
	jp z,l76d6h		                        ;76ce	ca d6 76
	neg		                                ;76d1	ed 44   Invert speed
	ld (ix+ALIEN_TABLE_IDX_VERT_SPEED),a	;76d3	dd 77 08

l76d6h:
    ; Skip if HORIZ_SPEED >= 0
	bit 7,(ix+ALIEN_TABLE_IDX_HORIZ_SPEED)		;76d6	dd cb 09 7e
	jr z,l76ech		                            ;76da	28 10

    ; Skip if X >= 16
	ld a,(iy+SPR_PARAMS_IDX_X)		            ;76dc	fd 7e 01
	cp 16		                                ;76df	fe 10
	jp nc,l76ech		                        ;76e1	d2 ec 76
    
    ; Invert HORIZ_SPEED
	ld a,(ix+ALIEN_TABLE_IDX_HORIZ_SPEED)		;76e4	dd 7e 09
	neg		                                    ;76e7	ed 44
	ld (ix+ALIEN_TABLE_IDX_HORIZ_SPEED),a		;76e9	dd 77 09
l76ech:
    ; Skip if HORIZ_SPEED < 0
	bit 7,(ix+ALIEN_TABLE_IDX_HORIZ_SPEED)		;76ec	dd cb 09 7e
	jr nz,l7763h		                        ;76f0	20 71

    ; Skip if X < 176
	ld a,(iy+SPR_PARAMS_IDX_X)		            ;76f2	fd 7e 01
	cp 176		                                ;76f5	fe b0
	jp c,l7763h		                            ;76f7	da 63 77

    ; Invert HORIZ_SPEED
	ld a,(ix+ALIEN_TABLE_IDX_HORIZ_SPEED)		;76fa	dd 7e 09
	neg		                                    ;76fd	ed 44
	ld (ix+ALIEN_TABLE_IDX_HORIZ_SPEED),a		;76ff	dd 77 09
	jp l7763h		                            ;7702	c3 63 77

; Actions:

; Invert alien's vertical speed
alien_inv_vert_speed:
	ld a,(ix+ALIEN_TABLE_IDX_VERT_SPEED)		;7705	dd 7e 08
	neg		                                    ;7708	ed 44
	ld (ix+ALIEN_TABLE_IDX_VERT_SPEED),a		;770a	dd 77 08
	jp l7763h		                            ;770d	c3 63 77

; Invert alien's horizontal speed
alien_inv_horiz_speed:
	ld a,(ix+ALIEN_TABLE_IDX_HORIZ_SPEED)		;7710	dd 7e 09
	neg		                                    ;7713	ed 44
	ld (ix+ALIEN_TABLE_IDX_HORIZ_SPEED),a		;7715	dd 77 09
	jp l7763h		                            ;7718	c3 63 77

; Set alien is exploding
set_alien_exploding:
	ld (ix+ALIEN_TABLE_IDX_EXPLODING), 1	;771b	dd 36 02 01
	jp l7763h		                        ;771f	c3 63 77

    ; The alien is exploding
alien_exploding:
    ; Increment counter of the explosion animation
    ; Skip of the counter hasn't already reached 10.
	inc (ix+ALIEN_TABLE_IDX_EXPLOSION_ANIM_TICKS)		;7722	dd 34 04
	ld a,(ix+ALIEN_TABLE_IDX_EXPLOSION_ANIM_TICKS)		;7725	dd 7e 04
	cp 10		                                        ;7728	fe 0a
	jp nz,next_alien		                            ;772a	c2 6d 78

    ; Reset animation ticks
	ld (ix+ALIEN_TABLE_IDX_EXPLOSION_ANIM_TICKS), 0		;772d	dd 36 04 00
    
    ;A = exploding animation sprite pattern
	ld a,(ix+ALIEN_TABLE_IDX_EXPLOSION_ANIM_NUM)    ;7731	dd 7e 05
	ld l,a			                                ;7734	6f
	ld h, 0		                                    ;7735	26 00
	ld de, TBL_SPR_PATTERN_NUMS_EXPLODING_ALIEN		;7737	11 0c 7b
	add hl,de			                            ;773a	19
	ld a,(hl)			                            ;773b	7e
    
    ; Set the corresponding sprite pattern in the animation step, and
    ; the color to red
	ld (iy+SPR_PARAMS_IDX_PATTERN_NUM),a	        ;773c	fd 77 02
	ld (iy+SPR_PARAMS_IDX_COLOR), 8		            ;773f	fd 36 03 08

    ; Increment the animation step
    ; If all 4 frames done, go to the next alien
	inc (ix+ALIEN_TABLE_IDX_EXPLOSION_ANIM_NUM)		;7743	dd 34 05
	ld a,(ix+ALIEN_TABLE_IDX_EXPLOSION_ANIM_NUM)	;7746	dd 7e 05
	cp 4		                                    ;7749	fe 04
	jp nz,next_alien		                        ;774b	c2 6d 78

	ld (iy+SPR_PARAMS_IDX_Y), 192		;774e	fd 36 00 c0     Invisible
	; HL = DE = ALIEN_TABLE
    push ix		;7752	dd e5
	push ix		;7754	dd e5
	pop hl		;7756	e1
	pop de		;7757	d1

    ; Set alien inactive after the 4 frames of the explosion
    inc de		;7758	13      ; Point to index 1: ALIEN_TABLE_IDX_ACTIVE
	ld (hl), 0	;7759	36 00
    
    ; Reset this alien's entry in ALIEN_TABLE
	ld bc, ALIEN_TABLE_LEN - 1  ;775b	01 13 00
	ldir		                ;775e	ed b0
	jp next_alien		        ;7760	c3 6d 78

l7763h:
    ; Increment the animation counter
    ; If it reaches 4, update the sprite's pattern
	inc (ix+ALIEN_TABLE_NEXT_FRAME_COUNTER)		;7763	dd 34 11
	ld a,(ix+ALIEN_TABLE_NEXT_FRAME_COUNTER)	;7766	dd 7e 11
	cp 4		                                ;7769	fe 04
	jp nz,next_alien		                    ;776b	c2 6d 78
	ld (ix+ALIEN_TABLE_NEXT_FRAME_COUNTER), 0	;776e	dd 36 11 00

    ; Update the alien's sprite pattern

    ; Obtain a pointer to the alien patterns according to the
    ; current level.
    ; DE = TBL_ALIEN_SPR_PATTERN_PTR_LEVEL[2*(LEVEL & 3)]
	ld a,(LEVEL)	;7772	3a 1b e0
	and 3		    ;7775	e6 03
	ld l,a			;7777	6f
	ld h, 0		    ;7778	26 00
	add hl,hl		;777a	29
	ld de,TBL_ALIEN_SPR_PATTERN_PTR_LEVEL	;777b	11 bd 7a
	add hl,de		;777e	19
	ld e,(hl)		;777f	5e
	inc hl			;7780	23
	ld d,(hl)		;7781	56
    
    ; Increment the alien's sprite pattern
	ld a,(ix+ALIEN_TABLE_IDX_FLYING_ANIM_NUM)	;7782	dd 7e 0a
	ld l,a			;7785	6f
	ld h,0		    ;7786	26 00
	add hl,de		;7788	19
	ld a,(hl)		;7789	7e
	ld (iy+SPR_PARAMS_IDX_PATTERN_NUM),a	    ;778a	fd 77 02
	inc (ix+ALIEN_TABLE_IDX_FLYING_ANIM_NUM)    ;778d	dd 34 0a

    ; Reset the animation's frame if it was the last
	ld a,(LEVEL)		;7790	3a 1b e0
	and 3		        ;7793	e6 03
	ld l,a			    ;7795	6f
	ld h, 0		        ;7796	26 00
	ld de,TBL_ALIEN_LAST_FRAME		;7798	11 aa 77
	add hl,de			;779b	19
	ld a,(hl)			;779c	7e
	cp (ix+ALIEN_TABLE_IDX_FLYING_ANIM_NUM)		;779d	dd be 0a
	jp nz,next_alien		                    ;77a0	c2 6d 78
    ; Reset animation
	ld (ix+ALIEN_TABLE_IDX_FLYING_ANIM_NUM),0	;77a3	dd 36 0a 00
	jp next_alien		                        ;77a7	c3 6d 78

; Last frame of the alien's animation.
; It's used the reset the animation.
TBL_ALIEN_LAST_FRAME:
    db 8, 8, 6, 17

; ALIEN_Y >= 64
; Each alien has a 5-step predefined set of speeds and ticks, that we
; shall call his "walk".
alien_walk:
    ; Mark this alien if he's gone as down as ALIEN_Y >= 64
    ; Skip if already marked
	ld a,(ix+ALIEN_TABLE_IDX_PERFORMING_WALK)		;77ae	dd 7e 0b
	cp 1		        ;77b1	fe 01
	jp z,l77f1h		    ;77b3	ca f1 77
    
	; Mark the alien
    ld (ix+ALIEN_TABLE_IDX_PERFORMING_WALK), 1		;77b6	dd 36 0b 01
    
    ; U = (ix+ALIEN_TABLE_IDX_WALK_STEP)
	; HL <-- 4*WALK_STEP
    ; It's multiplied by 4 because each entry is 4 bytes.
    ld a,(ix+ALIEN_TABLE_IDX_WALK_STEP)		;77ba	dd 7e 0c
	sla a		        ;77bd	cb 27
	sla a		        ;77bf	cb 27
	ld l,a			    ;77c1	6f
	ld h, 0		        ;77c2	26 00

    ; Choose a walk table depending on the alien's type (or color)
	ld a,(ix+ALIEN_TABLE_IDX_COLOR)		;77c4	dd 7e 00

	ld de,TBL_ALIEN_TYPE_0_SPEED		;77c7	11 10 7b
	cp 0		                        ;77ca	fe 00
	jp z,l77e2h		                    ;77cc	ca e2 77

	ld de,TBL_ALIEN_TYPE_1_WALK		    ;77cf	11 24 7b
	cp 1		                        ;77d2	fe 01
	jp z,l77e2h		                    ;77d4	ca e2 77

	ld de,TBL_ALIEN_TYPE_2_WALK         ;77d7	11 38 7b
	cp 2		                        ;77da	fe 02
	jp z,l77e2h		                    ;77dc	ca e2 77

	ld de,TBL_ALIEN_TYPE_3_WALK		    ;77df	11 50 7b
l77e2h:
    ; HL <-- TBL + 4*WALK_STEP
	add hl,de			                ;77e2	19
    
    ; A <-- TBL[4*WALK_STEP]
	ld a,(hl)			                ;77e3	7e
    
    ; Set new vertical speed
    ; SPEED_V <-- TBL[4*WALK_STEP]
	ld (ix+ALIEN_TABLE_IDX_VERT_SPEED),a	;77e4	dd 77 08
    
    ; Set new horizontal speed
    ; SPEED_H <-- TBL[4*WALK_STEP + 1]
	inc hl			                        ;77e7	23
	ld a,(hl)			                    ;77e8	7e
	ld (ix+ALIEN_TABLE_IDX_HORIZ_SPEED),a	;77e9	dd 77 09

    ; Increment ticks for this step of the walk
	inc hl			;77ec	23
	ld a,(hl)		;77ed	7e
	ld (ix+ALIEN_TABLE_IDX_WALK_NUM_TICKS),a	;77ee	dd 77 0f
l77f1h:
    ; Update alien's vertical position according to his speed
	ld a,(ix+ALIEN_TABLE_IDX_VERT_SPEED)	;77f1	dd 7e 08
	add a,(iy+SPR_PARAMS_IDX_Y)		        ;77f4	fd 86 00
	ld (iy+SPR_PARAMS_IDX_Y),a		        ;77f7	fd 77 00

    ; Update alien's horizontal position according to his speed
	ld a,(ix+ALIEN_TABLE_IDX_HORIZ_SPEED)	;77fa	dd 7e 09
	add a,(iy+SPR_PARAMS_IDX_X)		        ;77fd	fd 86 01
	ld (iy+SPR_PARAMS_IDX_X),a		        ;7800	fd 77 01
    
    ; Skip if X >= 17
	ld a,(iy+SPR_PARAMS_IDX_X)		        ;7803	fd 7e 01
	cp 17		                            ;7806	fe 11
	jr nc,l7817h		                    ;7808	30 0d
    ; X < 17
	ld a,(ix+ALIEN_TABLE_IDX_HORIZ_SPEED)	;780a	dd 7e 09
    ; Ensure the horizontal speed is negative
	bit 7,a		                            ;780d	cb 7f
	jp z,l7817h		                        ;780f	ca 17 78
	neg		                                ;7812	ed 44
	ld (ix+ALIEN_TABLE_IDX_HORIZ_SPEED),a	;7814	dd 77 09
l7817h:
	; Skip if X < 175
    ld a,(iy+SPR_PARAMS_IDX_X)		        ;7817	fd 7e 01
	cp 175		                            ;781a	fe af
	jr c,l782bh		                        ;781c	38 0d
    
    ; Ensure the horizontal speed is positive
	ld a,(ix+ALIEN_TABLE_IDX_HORIZ_SPEED)	;781e	dd 7e 09
	bit 7,a		                            ;7821	cb 7f
	jp nz,l782bh		                    ;7823	c2 2b 78
	neg		                                ;7826	ed 44
	ld (ix+ALIEN_TABLE_IDX_HORIZ_SPEED),a	;7828	dd 77 09
l782bh:
    ; We've done one more tick
    ; If no more ticks, get back to "not performing walk" state
	ld a,(ix+ALIEN_TABLE_IDX_WALK_NUM_TICKS)		;782b	dd 7e 0f
	dec a			                                ;782e	3d
	ld (ix+ALIEN_TABLE_IDX_WALK_NUM_TICKS),a		;782f	dd 77 0f
	jp nz,l7763h		                            ;7832	c2 63 77

	ld (ix+ALIEN_TABLE_IDX_PERFORMING_WALK), 0		;7835	dd 36 0b 00

    ; Skip if Y >= 174 (the bottom of the screen)
	ld a,(iy+SPR_PARAMS_IDX_Y)		;7839	fd 7e 00
	cp 174		                    ;783c	fe ae
	jp nc,l785bh		            ;783e	d2 5b 78    
    ; Y < 174

	ld a,(ix+ALIEN_TABLE_IDX_COLOR)		;7841	dd 7e 00
	cp 2		                        ;7844	fe 02
	jp z,l787dh		                    ;7846	ca 7d 78

    ; Increment walk step. Reset if it's already 5.
	inc (ix+ALIEN_TABLE_IDX_WALK_STEP)		;7849	dd 34 0c
	ld a,(ix+ALIEN_TABLE_IDX_WALK_STEP)		;784c	dd 7e 0c
	cp 5		                            ;784f	fe 05
l7851h:
	jp nz,l7763h		                ;7851	c2 63 77
	ld (ix+ALIEN_TABLE_IDX_WALK_STEP),0	;7854	dd 36 0c 00
	jp next_alien		                ;7858	c3 6d 78
l785bh:
    ; Remove alien
	ld (iy+SPR_PARAMS_IDX_Y), 192		;785b	fd 36 00 c0
	push ix		    ;785f	dd e5
	push ix		    ;7861	dd e5
	pop hl			;7863	e1
	pop de			;7864	d1
	inc de			;7865	13
	ld (hl), 0		;7866	36 00
	ld bc, ALIEN_TABLE_LEN-1	;7868	01 13 00
	ldir		    ;786b	ed b0
; Process next alien
next_alien:
	pop bc			        ;786d	c1
	ld de,ALIEN_TABLE_LEN	;786e	11 14 00
	add ix,de		        ;7871	dd 19
	ld de, SPR_PARAMS_LEN	;7873	11 04 00
	add iy,de		        ;7876	fd 19
	dec b			        ;7878	05
	jp nz,l760fh		    ;7879	c2 0f 76
	ret			            ;787c	c9

l787dh:
    ; Increment walk step.
    ; If it's 6, it's done.
	inc (ix+ALIEN_TABLE_IDX_WALK_STEP)		;787d	dd 34 0c
	ld a,(ix+ALIEN_TABLE_IDX_WALK_STEP)		;7880	dd 7e 0c
	cp 6		                            ;7883	fe 06
	jp l7851h		                        ;7885	c3 51 78

; Check if any of the 3 lasers hit an alien.
; If so, update points and deactivate that laser.
CHECK_LASERS_HITS_ALIEN:
    ; Check if laser #1 is active
	ld ix,LASER1_SPR_PARAMS		    ;7888	dd 21 e9 e0
	ld a,(LASER1_ACTIVE)		    ;788c	3a 57 e5
	or a			                ;788f	b7
	jp z,l78a1h		                ;7890	ca a1 78
	call CHECK_ALIEN_HIT_BY_LASER	;7893	cd d4 78
	jp c,l78a1h		                ;7896	da a1 78
    ; Set laser #1 inactive
	xor a			                ;7899	af
	ld (LASER1_ACTIVE),a		    ;789a	32 57 e5
	ld (ix+0), 192		            ;789d	dd 36 00 c0
l78a1h:
    ; Check if laser #2 is active
	ld ix,LASER2_SPR_PARAMS		    ;78a1	dd 21 ed e0
	ld a,(LASER2_ACTIVE)		    ;78a5	3a 5b e5
	or a			                ;78a8	b7
	jp z,l78bah		                ;78a9	ca ba 78
	call CHECK_ALIEN_HIT_BY_LASER	;78ac	cd d4 78
	jp c,l78bah		                ;78af	da ba 78
    ; Set laser #2 inactive
	xor a			                ;78b2	af
	ld (LASER2_ACTIVE),a		    ;78b3	32 5b e5
	ld (ix+0), 192		            ;78b6	dd 36 00 c0
l78bah:
    ; Check if laser #3 is active
	ld ix,LASER3_SPR_PARAMS		    ;78ba	dd 21 f1 e0
	ld a,(LASER3_ACTIVE)		    ;78be	3a 5f e5
	or a			                ;78c1	b7
	jp z,l78d3h		                ;78c2	ca d3 78
	call CHECK_ALIEN_HIT_BY_LASER	;78c5	cd d4 78
	jp c,l78d3h		                ;78c8	da d3 78
    ; Set laser #3 inactive
	xor a			                ;78cb	af
	ld (LASER3_ACTIVE),a		    ;78cc	32 5f e5
	ld (ix+0), 192		            ;78cf	dd 36 00 c0
l78d3h:
	ret			                    ;78d3	c9

; Check if the alien was hit by a laser.
; If so, clear the carry (carry set means no alien was hit)
CHECK_ALIEN_HIT_BY_LASER:
    ; IX = LASER(i)_SPR_PARAMS
	ld iy,ALIEN_SPR_PARAMS		;78d4	fd 21 01 e1
	ld hl,ALIEN_TABLE + 1		;78d8	21 c8 e4
	ld b, 3		                ;78db	06 03
l78ddh:
    ; Skip if alien is not active
	ld a,(hl)		;78dd	7e
	or a			;78de	b7
	jp z,l7935h		;78df	ca 35 79    Done, next alien

    ; Skip if alien is exploding
	push hl			;78e2	e5
	inc hl			;78e3	23  Point to ALIEN_TABLE_IDX_EXPLODING
	ld a,(hl)		;78e4	7e
	or a			;78e5	b7
	pop hl			;78e6	e1
	jp nz,l7935h	;78e7	c2 35 79    Done, next alien

	ld a,(ix+SPR_PARAMS_IDX_Y)	;78ea	dd 7e 00
	sub 16		                ;78ed	d6 10
	ld e,a			            ;78ef	5f          E = height - 16
	ld a,(iy+SPR_PARAMS_IDX_Y)  ;78f0	fd 7e 00
	ld d,a			            ;78f3	57          D = ALIEN_Y
	ld a,e			            ;78f4	7b          A = height - 16
	cp d			            ;78f5	ba          Compare ALIEN_Y with height - 16
	jp nc,l7935h		        ;78f6	d2 35 79    Skip if height - 16 >= ALIEN_Y
    
    ; height - 16 < ALIEN_DATA[0]
	ld a,(ix+SPR_PARAMS_IDX_Y)	;78f9	dd 7e 00
	add a,16		            ;78fc	c6 10
	ld e,a			            ;78fe	5f          E = height + 16
	ld a,(iy+SPR_PARAMS_IDX_Y)  ;78ff	fd 7e 00
	ld d,a			            ;7902	57          D = ALIEN_Y
	ld a,e			            ;7903	7b          A = height + 16
	cp d			            ;7904	ba          Compare ALIEN_Y with height + 16
	jp c,l7935h		            ;7905	da 35 79    Skip if height + 16 < ALIEN_Y
    
    ; height + 16 >= ALIEN_Y
    ; So:   height - 16 < ALIEN_Y <= height + 16

	ld a,(ix+SPR_PARAMS_IDX_X)  ;7908	dd 7e 01
	sub 16		                ;790b	d6 10
	ld e,a			            ;790d	5f          E = width - 16
	ld a,(iy+SPR_PARAMS_IDX_X)	;790e	fd 7e 01
	ld d,a			            ;7911	57          D = ALIEN_X
	ld a,e			            ;7912	7b          A = width - 16
	cp d			            ;7913	ba          Compare ALIEN_X with width - 16
	jp nc,l7935h		        ;7914	d2 35 79    Skip if width - 16 >= ALIEN_X

	ld a,(ix+SPR_PARAMS_IDX_X)	;7917	dd 7e 01
	add a,16		            ;791a	c6 10
	ld e,a			            ;791c	5f          A = width + 16
	ld a,(iy+SPR_PARAMS_IDX_X)	;791d	fd 7e 01
	ld d,a			            ;7920	57          D = ALIEN_X
	ld a,e			            ;7921	7b          A = width + 16
	cp d			            ;7922	ba          Compare ALIEN_X with width + 16
	jp c,l7935h		            ;7923	da 35 79 	Skip if width + 16 < ALIEN_X
    
    ; Finally:
    ;   height - 16 < ALIEN_Y <= height + 16      and
    ;   width  - 16 < ALIEN_X <= width  + 16
    ; The alien has been reached by the laser
    
    ; Play sound
	ld a, SOUND_ALIEN_DESTROYED		;7926	3e c2
	call ADD_SOUND		            ;7928	cd ef 5b

    ; Give points and update the scores
	ld a, 5		                        ;792b	3e 05
	call ADD_POINTS_AND_UPDATE_SCORES	;792d	cd a0 52
    
    ; Set ALIEN_TABLE_IDX_EXPLODING
	inc hl			                    ;7930	23
	ld (hl), 1		                    ;7931	36 01

	xor a			                    ;7933	af  Clear carry: alien was hit
	ret			                        ;7934	c9

l7935h:
    ; Next alien
	ld de,SPR_PARAMS_LEN	;7935	11 04 00
	add iy,de		        ;7938	fd 19
	ld de, ALIEN_TABLE_LEN	;793a	11 14 00
	add hl,de			    ;793d	19
	djnz l78ddh		        ;793e	10 9d
	scf			            ;7940	37              Set carry: no alien was hiy
	ret			            ;7941	c9

; Check if Vaus has hit the alien and give points
CHECK_ALIEN_HIT_BY_VAUS:
	ld ix,SPR_PARAMS_BASE		    ;7942	dd 21 cd e0
	ld iy,ALIEN_SPR_PARAMS		    ;7946	fd 21 01 e1
	ld hl,ALIEN_TABLE + 1		    ;794a	21 c8 e4
    
    ; Loop over 3 aliens
	ld b, 3		                    ;794d	06 03
l794fh:
    ; Skip if Vaus is exploding
	ld a,(VAUS_TABLE + VAUS_TABLE_IDX_ACTION_STATE)		;794f	3a 4b e5
	cp VAUS_ACTION_STATE_EXPLODING  ;7952	fe 06
	ret z			    ;7954	c8

    ; Skip this alien if not active
	ld a,(hl)			;7955	7e
	cp 1		        ;7956	fe 01
	jp nz,l7999h		;7958	c2 99 79

    ; Skip if ALIEN_Y < 160 or ALIEN_Y > 184
	ld a,(iy+SPR_PARAMS_IDX_Y)		;795b	fd 7e 00
	cp 160		                    ;795e	fe a0
	jp c,l7999h		                ;7960	da 99 79
	cp 184		                    ;7963	fe b8
	jp nc,l7999h		            ;7965	d2 99 79
    
    ; 160 < ALIEN_Y <= 184
    
    ; Skip if ALIEN_X <= X + 8
	ld a,(ix+SPR_PARAMS_IDX_X)		;7968	dd 7e 01
	add a,8		                    ;796b	c6 08
	cp (iy+SPR_PARAMS_IDX_X)		;796d	fd be 01
	jp nc,l7999h		            ;7970	d2 99 79
    
    ; ALIEN_X > X + 8

    ; Choose C = 40 or C = 56 according to VAUS_IS_ENLARGED
	ld c,40		    ;7973	0e 28
	ld a,(VAUS_IS_ENLARGED)	;7975	3a 21 e3
	or a			;7978	b7
	jp z,l797eh		;7979	ca 7e 79
	ld c,56		    ;797c	0e 38
l797eh:
	ld a,(ix+SPR_PARAMS_IDX_X)	;797e	dd 7e 01
	add a,c			            ;7981	81          A = X + size (40 or 56)

    ; Compare with ALIEN_X
	cp (iy+SPR_PARAMS_IDX_X)    ;7982	fd be 01
	jp c,l7999h		            ;7985	da 99 79    Skip
    
    ; ALIEN_X < X + constant (40 or 56)
    
    ; So for  X   X+8 < ALIEN_Y <= X + constant (40 or 56)
    ; And for Y:  160 < ALIEN_Y <= 184
	ld a, SOUND_ALIEN_DESTROYED		;7988	3e c2
	call ADD_SOUND		            ;798a	cd ef 5b

    ; Add points
	ld a,5  		                    ;798d	3e 05
	call ADD_POINTS_AND_UPDATE_SCORES	;798f	cd a0 52

    ; hl = ALIEN_TABLE + 1
	push hl			;7992
	
    ; Set alien active = 2
    ld (hl),2	    ;7993	36 02   ALIEN_TABLE_IDX_ACTIVE
    
    ; Set alien is exploding
	inc hl			;7995	23
	ld (hl), 1	    ;7996	36 01   ALIEN_TABLE_IDX_EXPLODING
	pop hl			;7998	e1
l7999h:
    ; Next alien
	ld de,SPR_PARAMS_LEN		;7999	11 04 00
	add iy,de		            ;799c	fd 19
	ld de,ALIEN_TABLE_LEN		;799e	11 14 00
	add hl,de			        ;79a1	19
	djnz l794fh		            ;79a2	10 ab
	ret			                ;79a4	c9

; Checks if any of the active balls hits and alien, and destroys it
CHECK_ANY_BALL_HITS_ALIEN:
	ld ix,BALL1_SPR_PARAMS		                ;79a5	dd 21 f5 e0
    
    ; First ball
	ld a,(BALL_TABLE1 + BALL_TABLE_IDX_ACTIVE)	;79a9	3a 4e e2
	or a			                            ;79ac	b7
	jp z,l79c2h		                            ;79ad	ca c2 79

    ; Check if the first ball hit an alien
	call CHECK_BALL_HITS_ALIEN		            ;79b0	cd fd 79
	jp c,l79c2h		                            ;79b3	da c2 79    Jump if no alien hit
    ; Alien's been hit
	ld iy,BALL_TABLE1		                    ;79b6	fd 21 4e e2
	call INVERT_BALL_VERTICAL_SKEWNESS		    ;79ba	cd 8a 9b

	ld a,SOUND_ALIEN_DESTROYED	                ;79bd	3e c2
	call ADD_SOUND		                        ;79bf	cd ef 5b
l79c2h:
    ; Second ball
	ld ix,BALL2_SPR_PARAMS		                ;79c2	dd 21 f9 e0
	ld a,(BALL_TABLE2)		                    ;79c6	3a 62 e2
	or a			                            ;79c9	b7
	jp z,l79dfh		                            ;79ca	ca df 79
    
    ; Check if the second ball hit an alien
	call CHECK_BALL_HITS_ALIEN		            ;79cd	cd fd 79
	jp c,l79dfh		                            ;79d0	da df 79
    ; Alien's been hit
	ld iy,BALL_TABLE2		                    ;79d3	fd 21 62 e2
	call INVERT_BALL_VERTICAL_SKEWNESS		    ;79d7	cd 8a 9b

	ld a,SOUND_ALIEN_DESTROYED	                ;79da	3e c2
	call ADD_SOUND		                        ;79dc	cd ef 5b
l79dfh:
    ; Third ball
	ld ix,BALL3_SPR_PARAMS		                ;79df	dd 21 fd e0
	ld a,(BALL_TABLE3)		                    ;79e3	3a 76 e2
	or a			                            ;79e6	b7
	jp z,l79fch		                            ;79e7	ca fc 79
    
    ; Check if the third ball hit an alien
	call CHECK_BALL_HITS_ALIEN		            ;79ea	cd fd 79
    ; Alien's been hit
	jp c,l79fch		                            ;79ed	da fc 79
	ld iy,BALL_TABLE3		                    ;79f0	fd 21 76 e2
	call INVERT_BALL_VERTICAL_SKEWNESS		    ;79f4	cd 8a 9b

	ld a,SOUND_ALIEN_DESTROYED	                ;79f7	3e c2
	call ADD_SOUND		                        ;79f9	cd ef 5b
l79fch:
	ret			                                ;79fc	c9

; Check if the ball has hit any of the aliens.
; If so, clear the carry.
CHECK_BALL_HITS_ALIEN:
    ; IX = BALL(i)_SPR_PARAMS
	ld iy,ALIEN_SPR_PARAMS		;79fd	fd 21 01 e1
	ld hl,ALIEN_TABLE + 1		;7a01	21 c8 e4
	ld b, 3		                ;7a04	06 03
l7a06h:
    ; Check ALIEN_TABLE_IDX_ACTIVE
    ; Next alien if not active
	ld a,(hl)			;7a06	7e
	cp 1		        ;7a07	fe 01
	jp nz,l7a5bh		;7a09	c2 5b 7a
    
    ; Skip also if it's transparent now
	ld a,(iy+SPR_PARAMS_IDX_COLOR)	;7a0c	fd 7e 03
	or a			                ;7a0f	b7
	jp z,l7a5bh		                ;7a10	ca 5b 7a

	ld a,(ix+SPR_PARAMS_IDX_Y)		;7a13	dd 7e 00
	sub 16		                    ;7a16	d6 10       A = BALL_Y - 16
	ld e,a			                ;7a18	5f          E = BALL_Y - 16
	ld a,(iy+SPR_PARAMS_IDX_Y)		;7a19	fd 7e 00    A = ALIEN_Y
	ld d,a			                ;7a1c	57          D = ALIEN_Y
	ld a,e			                ;7a1d	7b          A = BALL_Y - 16
	cp d			                ;7a1e	ba          Compare BALL_Y - 16 with ALIEN_Y
	jp nc,l7a5bh		            ;7a1f	d2 5b 7a    Leave if BALL_Y - 16 >= ALIEN_Y
    ; ALIEN_Y <= BALL_Y - 16

	ld a,(ix+SPR_PARAMS_IDX_Y)		;7a22	dd 7e 00
	add a, 4		                ;7a25	c6 04
	ld e,a			                ;7a27	5f          E = BALL_Y + 4
	ld a,(iy+SPR_PARAMS_IDX_Y)		;7a28	fd 7e 00
	ld d,a                          ;7a2b	57          D = ALIEN_Y
	ld a,e			                ;7a2c	7b          A = BALL_Y + 4
	cp d			                ;7a2d	ba          Compare BALL_Y + 4 with ALIEN_Y
	jp c,l7a5bh		                ;7a2e	da 5b 7a    Leave if ALIEN_Y > BALL_Y + 4    
    ; ALIEN_Y > BALL_Y + 4
    
    ; So far:
    ;  BALL_Y - 16 < ALIEN_Y <= BALL_Y + 4

    ; Now check the X coordinates

	ld a,(ix+SPR_PARAMS_IDX_X)		;7a31	dd 7e 01
	sub 16		                    ;7a34	d6 10
	ld e,a			                ;7a36	5f          E = BALL_X - 16
	ld a,(iy+SPR_PARAMS_IDX_X)		;7a37	fd 7e 01    A = ALIEN_X
	ld d,a			                ;7a3a	57          D = ALIEN_X
	ld a,e			                ;7a3b	7b          A = BALL_X - 16
	cp d			                ;7a3c	ba          Compare BALL_X - 16 with ALIEN_X
	jp nc,l7a5bh		            ;7a3d	d2 5b 7a    Leave if BALL_X - 16 >= ALIEN_X
    ; ALIEN_X <= BALL_X - 16

	ld a,(ix+SPR_PARAMS_IDX_X)		;7a40	dd 7e 01
	add a, 4		                ;7a43	c6 04
	ld e,a			                ;7a45	5f          E = BALL_X + 4
	ld a,(iy+SPR_PARAMS_IDX_X)		;7a46	fd 7e 01
	ld d,a			                ;7a49	57          D = ALIEN_X
	ld a,e			                ;7a4a	7b          A = BALL_X + 4
	cp d			                ;7a4b	ba          Compare BALL_X + 4 with ALIEN_X
	jp c,l7a5bh		                ;7a4c	da 5b 7a    Leave if ALIEN_X > BALL_X + 4
    ; ALIEN_X > BALL_Y + 4
    
    ; So far:
    ;  BALL_Y - 16 < ALIEN_Y <= BALL_Y + 4
    ;  BALL_X - 16 < ALIEN_X <= BALL_X + 4
    ;
    ; This means the alien's been hit by the ball
    
    ; Add points
	ld a, 5		                            ;7a4f	3e 05
	call ADD_POINTS_AND_UPDATE_SCORES		;7a51	cd a0 52
    
    ; Set ALIEN_EXPLODING in ALIEN_TABLE_IDX_ACTIVE
	ld (hl),ALIEN_ACTIVE_EXPLODING		;7a54	36 02
	inc hl			                    ;7a56	23

    ; Set the alien is exploding
    ld (hl),ALIEN_EXPLODING_FLAG	;7a57	36 01
	xor a			                ;7a59	af  Clear CARRY: alien's been hit
	ret			                    ;7a5a	c9

l7a5bh:
    ; Next alien
	ld de, SPR_PARAMS_LEN		;7a5b	11 04 00
	add iy,de		            ;7a5e	fd 19
	ld de, ALIEN_TABLE_LEN		;7a60	11 14 00
	add hl,de			        ;7a63	19
	djnz l7a06h		            ;7a64	10 a0
	scf			                ;7a66	37      Set CARRY: no alien was harmed in this function
	ret			                ;7a67	c9

; Checks if any of the bullets has touched Vaus
; If so, destroy Vaus
CHECK_VAUS_KILLED_BY_DOH:
    ; Skip if Vaus is exploding
    ld a,(VAUS_TABLE + VAUS_TABLE_IDX_ACTION_STATE)		;7a68	3a 4b e5
	cp VAUS_ACTION_STATE_EXPLODING	                    ;7a6b	fe 06
	ret z			                                    ;7a6d	c8
    
	ld ix,SPR_PARAMS_BASE		;7a6e	dd 21 cd e0     Vaus
	ld iy,DOH_BULLET_SPR_PARAMS		;7a72	fd 21 0d e1     Bullet
	ld hl,DOH_BULLETS_TABLE		;7a76	21 63 e5
	ld b, 3		                ;7a79	06 03
l7a7bh:
    ; Check DOH_BULLETS_ACTIVE
	ld a,(hl)	                    ;7a7b	7e
	or a			                ;7a7c	b7
	jp z,doh_next_bullet		    ;7a7d	ca b4 7a

    ; Next bullet if Y < 167
	ld a,(iy+SPR_PARAMS_IDX_Y)		;7a80	fd 7e 00
	cp 167		                    ;7a83	fe a7
	jp c,doh_next_bullet		    ;7a85	da b4 7a

    ; Next bullet if Y >= 184
	cp 184		                    ;7a88	fe b8
	jp nc,doh_next_bullet		    ;7a8a	d2 b4 7a
    
    ; 168 <= Y_bullet <= 183   --> Y-position of Vaus :S
	
    ; Skip if X_bullet <= X_vaus + 8
    ld a,(ix+SPR_PARAMS_IDX_X)		        ;7a8d	dd 7e 01
	add a, 8		                        ;7a90	c6 08
	cp (iy+SPR_PARAMS_IDX_X)		        ;7a92	fd be 01
	jp nc,doh_next_bullet		            ;7a95	d2 b4 7a

    ; Skip if X_bullet > X_vaus + 32
	ld a,(ix+SPR_PARAMS_IDX_X)		        ;7a98	dd 7e 01
	add a, 32		                        ;7a9b	c6 20
	cp (iy+SPR_PARAMS_IDX_X)		        ;7a9d	fd be 01
	jp c,doh_next_bullet		            ;7aa0	da b4 7a
    
    ;  X_bullet - 32 <= X_vaus < X_bullet - 8
    
    ; Vaus has been reached with one of the bullets! :S

    ; Set Vaus action state to exploding
	ld a,VAUS_ACTION_STATE_EXPLODING	                ;7aa3	3e 06
	ld (VAUS_TABLE + VAUS_TABLE_IDX_ACTION_STATE),a		;7aa5	32 4b e5

    ; Set invisible bullet
	ld (iy+SPR_PARAMS_IDX_Y), 192		;7aa8	fd 36 00 c0

	ld a,SOUND_VAUS_DESTROYED	;7aac	3e 07
	call ADD_SOUND		        ;7aae	cd ef 5b

	call DEACTIVE_ALL_BALLS		;7ab1	cd 10 97

    ; Next bullet
doh_next_bullet:
	ld de, SPR_PARAMS_LEN		;7ab4	11 04 00
	add iy,de		            ;7ab7	fd 19
	add hl,de			        ;7ab9	19
	djnz l7a7bh		            ;7aba	10 bf
	ret			                ;7abc	c9

; Obtain a pointer to the list of sprite patterns of the aliens, according to
; the current level.
; It's indexed as TBL_ALIEN_SPR_PATTERN_PTR_LEVEL[2*(LEVEL & 3)], 4 pointers
TBL_ALIEN_SPR_PATTERN_PTR_LEVEL:
    dw alien_patterns_1, alien_patterns_2, alien_patterns_3, alien_patterns_4 ; 0x7abd

alien_patterns_1:
    db 0xc0, 0xc4, 0xc8, 0xcc, 0xd0, 0xd4, 0xd8, 0xdc ; 0x7ac5 - 0x7acc
alien_patterns_2:
    db 0xc0, 0xc4, 0xc8, 0xcc, 0xd0, 0xd4, 0xd8, 0xcc ; 0x7acd - 0x7ad4
alien_patterns_3:
    db 0xc0, 0xc4, 0xc8, 0xcc, 0xd0, 0xd4
alien_patterns_4:
    db 0xc0, 0xc4 ; 0x7adb
    db 0xc8, 0xcc, 0xd0, 0xdc, 0xc0, 0xc4, 0xc8, 0xcc ; 0x7add - 0x7ae4
    db 0xd0, 0xdc, 0xd4, 0xd8, 0xd8, 0xd4, 0xd0       ; 0x7ae5 - 0x7aeb

; The initial horizontal speed of the alien exiting the
; left or right doors.
TBL_ALIEN_INITIAL_SPEED_X_LEFT_DOOR:  ; 7aec
    db 0, 0, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2
;
TBL_ALIEN_INITIAL_SPEED_X_RIGHT_DOOR:   ;7af9
    db 0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 2, 2, 2

TBL_ALIEN_VERT_SPEED:
    db 1, -1, 1, 0, 1, 1

; Sprite pattern numbers for the exploding alien
TBL_SPR_PATTERN_NUMS_EXPLODING_ALIEN:
    db 0x90, 0x94, 0x98, 0x9c     ;7b0c

; V_SPEED, H_SPEED, NUM_TICKS
;7b10
TBL_ALIEN_TYPE_0_SPEED:
    db 1, 0, 40, 0
    db 1, 2, 24, 0
    db -1, 2, 24, 0
    db -1, -2, 24, 0
    db 1, -2, 24, 0

;7b24
TBL_ALIEN_TYPE_1_WALK:
    db 1, 0, 56, 0 ; 0x7b24 - 0x7b27
    db 2, 3, 30, 0 ; 0x7b28 - 0x7b2b
    db -2, 3, 30, 0 ; 0x7b2c - 0x7b2f
    db -2, -3, 24, 0 ; 0x7b30 - 0x7b33
    db 2, -3, 24, 0 ; 0x7b34 - 0x7b37

;7b38
TBL_ALIEN_TYPE_2_WALK:
    db 1, 0, 32, 0 ; 0x7b38 - 0x7b3b
    db 1, 2, 0x8, 0 ; 0x7b3c - 0x7b3f
    db -1, 2, 0x8, 0 ; 0x7b40 - 0x7b43
    db -1, 0, 0x8, 0 ; 0x7b44 - 0x7b47
    db -1, 2, 24, 0 ; 0x7b48 - 0x7b4b
    db 1, 2, 24, 0 ; 0x7b4c - 0x7b4f

;7b50
TBL_ALIEN_TYPE_3_WALK:
    db 1, 0, 40, 0 ; 0x7b50 - 0x7b53
    db 1, -2, 24, 0 ; 0x7b54 - 0x7b57
    db -1, -2, 24, 0 ; 0x7b58 - 0x7b5b
    db -1, 2, 24, 0 ; 0x7b5c - 0x7b5f
    db 1, 2, 24, 0 ; 0x7b60 - 0x7b63

; This are lookup tables for the parameters of the sprite of the
; alien exiting the door
SPR_DOOR_1_TABLE:
    dw SPR_DOOR_1_TABLE_params1
    dw SPR_DOOR_1_TABLE_params2
    dw SPR_DOOR_1_TABLE_params3
    dw SPR_DOOR_1_TABLE_params4
;
SPR_DOOR_1_TABLE_params1:
    db 8, 136, 0xc0, 5
SPR_DOOR_1_TABLE_params2:
    db 8, 136, 0xc0, 3
SPR_DOOR_1_TABLE_params3:
    db 8, 136, 0xc0, 7
SPR_DOOR_1_TABLE_params4:
    db 8, 136, 0xc0, 8

; And the other door
SPR_DOOR_2_TABLE:
    dw SPR_DOOR_2_TABLE_params1
    dw SPR_DOOR_2_TABLE_params2
    dw SPR_DOOR_2_TABLE_params3
    dw SPR_DOOR_2_TABLE_params4
;
SPR_DOOR_2_TABLE_params1:
    db 8, 40, 192, 5
SPR_DOOR_2_TABLE_params2:
    db 8, 40, 192, 3
SPR_DOOR_2_TABLE_params3:
    db 8, 40, 192, 7
SPR_DOOR_2_TABLE_params4:
    db 8, 40, 192, 8

; This is called when the level is finished, or when a life is lost
NEXT_OR_SAME_LEVEL:
    ; Skip the following if we're at the title screen
	ld a,(GAME_STATE)		;7b94	3a 0b e0
	or a			        ;7b97	b7
	jp z,brick_repaint_action_done  ;7b98	ca 44 7c

    ; HL = 2*BRICK_REPAINT_TYPE
	ld a,(BRICK_REPAINT_TYPE)	;7b9b	3a 22 e0
	ld l,a			            ;7b9e	6f
	ld h, 0		                ;7b9f	26 00
	add hl,hl			        ;7ba1	29
    
	; HL = l7babh + 2*BRICK_REPAINT_TYPE
    ld de,l7babh		        ;7ba2	11 ab 7b
	add hl,de			        ;7ba5	19    
    
    ; DE = l7babh[2*BRICK_REPAINT_TYPE]
	ld e,(hl)			        ;7ba6	5e
	inc hl			            ;7ba7	23
	ld d,(hl)			        ;7ba8	56
    
    ; Jump to l7babh[2*BRICK_REPAINT_TYPE]
	ex de,hl			        ;7ba9	eb
	jp (hl)			            ;7baa	e9

l7babh:
    dw ACTION_INC_LEVEL
    dw ACTION_INC_LEVEL
    dw ACTION_LIFE_LOST

ACTION_INC_LEVEL:
    ; Increment the displayed level
	ld a,(LEVEL_DISP)		;7bb1	3a 1c e0
	add a, 1		        ;7bb4	c6 01
	daa			            ;7bb6	27
	ld (LEVEL_DISP),a		;7bb7	32 1c e0

    ; Increment the level
	ld hl,LEVEL		    ;7bba	21 1b e0
	inc (hl)			;7bbd	34 	4 
	ld a,(hl)			;7bbe	7e
    
    ; Check if we've completed the game
	cp FINAL_LEVEL+1	;7bbf	fe 21
	jp nz,l7c7dh		;7bc1	c2 7d 7c
    
    ; Yes, we've completed the game!
    
    ; Clear LEVEL and LEVEL_DISP
	ld (hl), 0		;7bc4	36 00
	inc hl			;7bc6	23
	ld (hl), 0		;7bc7	36 00

    ; Wait 60 ticks
	ld hl, 60		        ;7bc9	21 3c 00
	call DELAY_HL_TICKS		;7bcc	cd 80 43

	; Play the ending music
    ld a,SOUND_GAME_ENDING	;7bcf	3e c7
	ld (SOUND_NUMBER),a		;7bd1	32 c0 e5
	call PLAY_SOUND		    ;7bd4	cd e8 b4

	ei                      ;7bd7	fb

    ; Show the ending text animation
	ld iy, ENDING_STR		        ;7bd8	fd 21 88 7c
	ld ix, TBL_VDP_POINTERS_LINE_ENDING_TEXT		            ;7bdc	dd 21 72 7d
	call ENDING_TEXT_ANIMATION		;7be0	cd 8a 4f

    ; Wait 30 ticks
	ld hl, 30		        ;7be3	21 1e 00
	call DELAY_HL_TICKS		;7be6	cd 80 43

	call CLEAR_SCREEN		;7be9	cd 27 42 	. ' B 
    
    ; Draw the scores
	call DRAW_UP_SCORES		;7bec	cd e0 4f 	. . O 

    ; Draw GAME OVER with sprites.
    ; That's a very nice way to show the text over the
    ; patterns with trasparency.
	ld hl,GAME_OVER_SPRITE_TABLE		;7bef	21 6d 7c
	ld de,VRAM_SPRITES_ATTRIB_TABLE		    ;7bf2	11 00 1b
	ld bc, 4*4		                    ;7bf5	01 10 00    4 sprites
	call LDIRVM		                    ;7bf8	cd 5c 00

    ; Wait 240 ticks
	ld hl, 240  		    ;7bfb	21 f0 00
	call DELAY_HL_TICKS		;7bfe	cd 80 43

	call CLEAR_SCREEN		;7c01	cd 27 42 	. ' B 
	jp brick_repaint_action_done		;7c04	c3 44 7c 	. D | 

ACTION_LIFE_LOST:
    ; Wait 48 ticks
	ld hl, 48		    ;7c07	21 30 00
	call DELAY_HL_TICKS		;7c0a	cd 80 43

	; Decrement lives
    ld hl,LIVES		    ;7c0d	21 1d e0
	dec (hl)			;7c10	35 	5

    ; Was it the last life?
    ld a,(hl)			;7c11	7e
	cp -1		        ;7c12	fe ff
	jp nz,l7c7dh		;7c14	c2 7d 7c    Jump to l7c7dh if more lives left
    
    ; It was the last life
    ; Store the current level in HL or 0x321F (level 0x1F = 32+1, and displayed as 32) for Doh's
	ld hl,(LEVEL)		;7c17	2a 1b
	ld a,l			    ;7c1a	7d
	cp FINAL_LEVEL		;7c1b	fe 20
	jp nz,l7c23h		;7c1d	c2 23 7c
	ld hl,0321fh		;7c20	21 1f 32    Level 0x1f+1=32 and displayed as 32
l7c23h:
    ; Save current level, for cheat #2
	ld (CHEAT2_LEVEL),hl		;7c23	22 05 e0
    
    ; Play GAME OVER music
	ld a,SOUND_GAME_OVER	;7c26	3e c6
	ld (SOUND_NUMBER),a		;7c28	32 c0 e5
	call PLAY_SOUND		    ;7c2b	cd e8 b4
	ei			            ;7c2e	fb

    ; Write "GAME OVER" with sprites
	ld hl,GAME_OVER_SPR_PARAMS		                ;7c2f	21 5d 7c
	ld de,VRAM_SPRITES_ATTRIB_TABLE	    ;7c32	11 00 1b
	ld bc, 4*4		                    ;7c35	01 10 00 4 sprites
	call LDIRVM		                    ;7c38	cd 5c 00

    ; Wait 240 ticks
	ld hl, 240		        ;7c3b	21 f0 00
	call DELAY_HL_TICKS		;7c3e	cd 80 43

	call CLEAR_SCREEN		;7c41	cd 27 42

brick_repaint_action_done:
    ; Reset variables
	ld hl,BRICK_MAP		;7c44	21 27 e0
	ld de,BRICK_MAP+1	;7c47	11 28 e0
	ld bc,0058dh		;7c4a	01 8d 05
	dec bc			    ;7c4d	0b
	ld (hl), 0		    ;7c4e	36 00
	ldir		        ;7c50	ed b0

    ; Reset states
	xor a			                ;7c52	af
	ld (GAME_TRANSITION_ACTION),a	;7c53	32 0a e0
    ; Set we're in the title screen
	ld (GAME_STATE),a		        ;7c56	32 0b e0
    ; Reset Doh hits
	ld (DOH_RECEIVED_HITS),a		;7c59	32 b3 e5
	ret			                    ;7c5c	c9

; Sprite params. to write "GAME OVER"
GAME_OVER_SPR_PARAMS:
    db 0x88, 0x44, 0x70, 0xf, 0x88, 0x54, 0x74, 0xf ; 0x7c5d - 0x7c64
    db 0x88, 0x6c, 0x78, 0xf, 0x88, 0x7c, 0x7c, 0xf ; 0x7c65 - 0x7c6c

; To write "GAME OVER" with sprites
GAME_OVER_SPRITE_TABLE:
    ; V H P (EC, 0, 0, 0, C)
    db 0x4c, 0x5c, 0x70, 0x0f; "GA"
    db 0x4c, 0x6c, 0x74, 0x0f; "ME"
    ;
	db 0x4c, 0x84, 0x78, 0x0f; "OV"
    db 0x4c, 0x94, 0x7c, 0x0f; "ER"
    
l7c7dh:
	xor a			                ;7c7d	af
	ld (GAME_TRANSITION_ACTION),a	;7c7e	32 0a e0

    ; Wait 60 ticks
	ld hl, 60   		    ;7c81	21 3c 00
	call DELAY_HL_TICKS		;7c84	cd 80 43
	ret			            ;7c87	c9

ENDING_STR:
    db "DIMENSION-CONTROLLING FORT\"DOH\" HAS NOW BEEN        "
    db "DEMOLISHED, AND TIME      STARTED FLOWING REVERSELY.\"VAUS\" "
    db "MANAGED TO ESCAPE  FROM THE DISTORTED SPACE. BUT THE REAL "
    db "VOYAGE OF    \"ARKANOID\" IN THE GALAXY  HAS "
    db "ONLY STARTED......    "

; VDP addresses to locate the ending story text
TBL_VDP_POINTERS_LINE_ENDING_TEXT:  ; 0x7d72
    dw 0x1843, 0x1883, 0x18c3, 0x1903, 0x1963, 0x19a3, 0x1a03, 0x1a43, 0x1a83

; Patterns in game
; One third, 8*0x300/3 = 2048 bytes
IN_GAME_TILES:
include 'in_game_patterns.asm'  ; 0x7d84

; In-game compressed colors 
; One third, 8*0x300/3 = 2048 bytes
IN_GAME_COLORS:
include 'in_game_colors.asm'

; Unused
db 0xff, 0xff, 0x13

; Sprite definitios
SPRITE_DEFINITIONS:
include 'sprite_data.asm'

; Unused or unknonwn data
include 'unused_or_unknown.asm'

; 8*0x300 / 3 = 2048 (one third) of the title's tiles.
; However, title_patterns.asm has less that 2048 bytes.
; But it's not a problem since those extra other patterns will be
; colores all black or white.
TITLE_TILES:
include 'title_patterns.asm'

; Compressed colors in the title's screen
; Start: 0x93F4, end: 0x9572
TITLE_COLORS_COMPRESSED:
include 'title_colors.asm'

; Unused
; It contains the unused text "PUSH SPACE KEY"
db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 9573
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db "PUSH"
db 0
db "SPACE"
db 0
db "KEY"
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0xb7, 0

; Update capsules, ball, hard bricks, and aliens
UPDATE_OBJECTS:
	call CAPSULE_MOVE_DOWN_STEP		            ;95f4	cd 37 b1
	call CHECK_CAPSULE_CATCHED_AND_EXEC_ACTION	;95f7	cd 5c b1
	call BALL_MOVEMENT_STEP		                ;95fa	cd 72 98
	call CHECK_HARD_BRICKS_HIT		            ;95fd	cd ea 97
	call UPDATE_ALIEN_VERT_DIR_WHEN_BRICK		;9600	cd 26 97
	ret			                                ;9603	c9
    
; Give points according to the brick hit
GIVE_BRICK_HIT_POINTS:
	ld hl,BACKGROUND_TILEMAP	;9604	21 6e e3
    
    ; Skip if no brick row
	ld a,(BRICK_ROW)		    ;9607	3a aa e2
	or a			            ;960a	b7
	jr z,l9622h		            ;960b	28 15

    ; HL = 8*BRICK_ROW
	ld l,a		;960d	6f
	ld h, 0		;960e	26 00
	add hl,hl	;9610	29
	add hl,hl	;9611	29
	add hl,hl	;9612	29
    
	; C = 2*BRICK_ROW
    ld c,a		;9613	4f
	sla c		;9614	cb 21
    
    ; HL = 8*BRICK_ROW + 2*BRICK_ROW = 10*BRICK_ROW
	ld b, 0		;9616	06 00
	add hl,bc	;9618	09

	ld e,a			;9619	5f
	ld d, 0		    ;961a	16 00       ; DE = BRICK_ROW

	add hl,de		;961c	19          ; HL = 10*BRICK_ROW + BRICK_ROW = 11*BRICK_ROW
	add hl,hl		;961d	29          ; HL = 22*BRICK_ROW
	ld de,BACKGROUND_TILEMAP		;961e	11 6e e3
	add hl,de			            ;9621	19  HL = 22*BRICK_ROW + BACKGROUND_TILEMAP
l9622h:
	; DE = 2*BRICK_COL
    ld a,(BRICK_COL)	;9622	3a ab e2
	ld e,a			    ;9625	5f
	sla e		        ;9626	cb 23
	ld d, 0 		    ;9628	16 00
    
    ; HL = 22*BRICK_ROW + BACKGROUND_TILEMAP + 2*BRICK_COL
	add hl,de			;962a	19
    
    ; The tilemap has indeed 22 chars per line
    
    ; Let's now use the tilemap to give points according to the
    ; brick that has been hit.
    ; See the POINTS_TABLE
    
    ; A = [22*BRICK_ROW + BACKGROUND_TILEMAP + 2*BRICK_COL]
    ; A = BACKGROUND_TILEMAP[22*BRICK_ROW + 2*BRICK_COL]
	ld a,(hl)			;962b	7e

    ; Yellow brick: no points!
	ld c, 0		;962c	0e 00
	cp 023h		;962e	fe 23
	jr z,l9672h	;9630	28 40

    ; Light red brick
	ld c, 6	;9632	0e 06
	cp 025h		;9634	fe 25
	jr z,l9672h	;9636	28 3a

    ; Cyan brick
	ld c, 2		;9638	0e 02
	cp 027h		    ;963a	fe 27
	jr z,l9672h		;963c	28 34

    ; Green brick
	ld c, 3 		;963e	0e 03
	cp 029h		    ;9640	fe 29
	jr z,l9672h		;9642	28 2e

    ; Dark red brick
	ld c, 4		;9644	0e 04
	cp 05ch		    ;9646	fe 5c
	jr z,l9672h		;9648	28 28

    ; Light blue brick
	ld c, 5		;964a	0e 05
	cp 05eh		    ;964c	fe 5e
	jr z,l9672h		;964e	28 22

    ; Magenta brick
	ld c, 1		;9650	0e 01
	cp 061h		    ;9652	fe 61
	jr z,l9672h		;9654	28 1c

    ; Light yellow
	ld c, 7		;9656	0e 07
	cp 063h		    ;9658	fe 63
	jr z,l9672h		;965a	28 16

    ; Gray (hard) brick
	cp 065h		    ;965c	fe 65
	ret nz			;965e	c0      Exit if unknown color

    ; Gray (hard) brick
    ; The points of these bricks depends on the current level!
	ld a,(LEVEL)	;965f	3a 1b e0
	and 0f8h		;9662	e6 f8       hgfe.d000
	srl a		    ;9664	cb 3f
	srl a		    ;9666	cb 3f
	srl a		    ;9668	cb 3f       000h.gfed
    ; A = LEVEL \ 8

    ; HL = LEVEL \ 8
	ld l,a			;966a	6f
	ld h, 0		    ;966b	26 00
    
    ; HL = LEVEL\8 + TBL_POINTS_PER_BRICK
	ld de,TBL_POINTS_PER_BRICK	;966d	11 77 96
	add hl,de		;9670	19
    
    ; Obtain the points for the table TBL_POINTS_PER_BRICK.
    ; C = TBL_POINTS_PER_BRICK[LEVEL\8]
	ld c,(hl)		;9671	4e
l9672h:
    ; Add add the points
	ld a,c			                    ;9672	79
	call ADD_POINTS_AND_UPDATE_SCORES	;9673	cd a0 52
	ret			                        ;9676	c9
    
; Points per brick type
TBL_POINTS_PER_BRICK:
    db 8, 9, 10, 11

; If so, detect at which of the four sides and perform the
; corresponding ball bounce.
CHECK_DOH_HIT_AND_BOUNCE_BALL:
    ; For info:
    ; iy = BALL_TABLE1 ; E24E
    ; ix = BALL1_SPR_PARAMS
    
    ; If the ball is not active, exit
	ld a,(iy+BALL_TABLE_IDX_ACTIVE)	;967b	fd 7e 00
	or a			                ;967e	b7
	ret z			                ;967f	c8
    
    ; If BALL_Y < 19, exit
	ld a,(ix+SPR_PARAMS_IDX_Y)		;9680	dd 7e 00
	cp 19		                    ;9683	fe 13
	ret c			                ;9685	d8
    ; BALL_Y >= 19
    
    ; If BALL_Y <= 120, exit
	cp 120		                    ;9686	fe 78
	ret nc			                ;9688	d0
    ; BALL_Y < 120
    
    ; 19 <= BALL_Y < 120
    ; The Y coordinate of the ball is within Doh's range
    
	; If BALL_X < 76, exit
    ld a,(ix+SPR_PARAMS_IDX_X)		;9689	dd 7e 01
	cp 76		                    ;968c	fe 4c
	ret c			                ;968e	d8
    
    ; If BALL_X <= 129, exit
	cp 129		                    ;968f	fe 81
	ret nc			                ;9691	d0

    ; 76 <= BALL_Y < 129
    ; The X coordinate of the ball is also within Doh's range
    
    ; At this point the ball has entered the Doh's area
    ; The next step is to know at which side happened the hit
    
	; Jump if BALL_X - SPEED < 77 --> On the left on Doh
	; BALL_X  < 77 + SPEED
    ld a,(ix+SPR_PARAMS_IDX_X)		;9692	dd 7e 01
	sub (iy+BALL_TABLE_IDX_X_SPEED)   ;9695	fd 96 03
	cp 77		                    ;9698	fe 4d
	jr c,doh_hit_left		                ;969a	38 1d
    ; BALL_X - SPEED >= 77

    ; Jump if BALL_X - SPEED >= 128
	cp 128		        ;969c	fe 80
	jr nc,doh_hit_right		;969e	30 28
    ; BALL_X - SPEED < 128
    
    ; So (neglecting the speed):
    ; 77 <= BALL_X < 128
    
    ; This means we're in Doh's X area
    ; Now we'll do the same checks for the Y axis

	ld a,(ix+SPR_PARAMS_IDX_Y)		    ;96a0	dd 7e 00
	sub (iy+BALL_TABLE_IDX_Y_SPEED)	    ;96a3	fd 96 02
	cp 19		                        ;96a6	fe 13
	jr c,l96d7h		                    ;96a8	38 2d
    ; BALL_Y - SPEED > 19

    ; If we're hitting on the bottom and moving down, exit
    ; Indeed, we won't hit him it at the bottom we're moving down.
	ld a,(iy+BALL_TABLE_IDX_Y_SPEED)	;96aa	fd 7e 02
	bit 7,a		                        ;96ad	cb 7f
	ret z			                    ;96af	c8  Exit if positive

    ; Hitting at the bottom and moving up ==>
    ; ==> vertical bounce and locate the ball at the bottom
	call BALL_VERTICAL_BOUNCE		;96b0	cd 5b 9b
	ld (ix+SPR_PARAMS_IDX_Y), 119	;96b3	dd 36 00 77
	jr doh_hit_ball_bounces		                ;96b7	18 2b

; We hit Doh on the left
doh_hit_left:
    ; Note: I don't understand the reason this check: if you're
    ; hitting on the left, your X speed must be always positive.
    ; Perhaps a "corner case"... when you actually hit the corner :)
	ld a,(iy+BALL_TABLE_IDX_X_SPEED)		;96b9	fd 7e 03
	bit 7,a		                            ;96bc	cb 7f
	ret nz			                        ;96be	c0  ret if negative
    ; The speed is positive: do the bounce
	call BALL_HORIZONTAL_BOUNCE		        ;96bf	cd 80 9b
	ld (ix+001h),04bh		                ;96c2	dd 36 01 4b
	jr doh_hit_ball_bounces		                        ;96c6	18 1c

; We hit Doh on the right
doh_hit_right:
	ld a,(iy+BALL_TABLE_IDX_X_SPEED)	;96c8	fd 7e 03
	bit 7,a		                        ;96cb	cb 7f
	ret z			                    ;96cd	c8
    ; The speed is negative: do the bounce
	call BALL_HORIZONTAL_BOUNCE		    ;96ce	cd 80 9b
	ld (ix+SPR_PARAMS_IDX_X), 129		;96d1	dd 36 01 81
	jr doh_hit_ball_bounces		                    ;96d5	18 0d

; We hit Doh on the top
l96d7h:
	ld a,(iy+BALL_TABLE_IDX_Y_SPEED)		;96d7	fd 7e 02
	bit 7,a		                            ;96da	cb 7f
	ret nz			                        ;96dc	c0
    ; The speed is positive: do the bounce
	call BALL_VERTICAL_BOUNCE		        ;96dd	cd 5b 9b
	ld (ix+SPR_PARAMS_IDX_Y), 18		    ;96e0	dd 36 00 12

doh_hit_ball_bounces:
	ld a, SOUND_DOH_HIT	;96e4	3e 08
	call ADD_SOUND		;96e6	cd ef 5b

	ld a, 1		;96e9	3e 01 	> . 
	ld (DOH_BEEN_HIT),a		;96eb	32 b9 e2 	2 . . 

    ; Increment Doh hits
    ; Doh is defeated if hit 16 times
	ld ix,DOH_RECEIVED_HITS		;96ee	dd 21 b3 e5
	inc (ix+SPR_PARAMS_IDX_Y)		;96f2	dd 34 00
	ld a,(ix+SPR_PARAMS_IDX_Y)		;96f5	dd 7e 00
	cp 16		        ;96f8	fe 10
	jr nz,l970ah		;96fa	20 0e

    ; Doh has been defeated!
	ld a, 1		            ;96fc	3e 01
	ld (DOH_TABLE),a		;96fe	32 0d e5
	call DEACTIVE_ALL_BALLS	;9701	cd 10 97

	ld a,SOUND_DOH_DEFEATED	;9704	3e 09
	call ADD_SOUND		    ;9706	cd ef 5b
	ret			            ;9709	c9

l970ah:
	ld a, 1		        ;970a	3e 01
	ld (TBL_DOH_HIT),a	;970c	32 05 e5
	ret			        ;970f	c9

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

; Update the alien's vertical direction when he reaches a brick
UPDATE_ALIEN_VERT_DIR_WHEN_BRICK:
    ; Skip if we're at Doh's level
	ld a,(LEVEL)		;9726	3a 1b e0
	cp FINAL_LEVEL		;9729	fe 20
	ret z			    ;972b	c8
    
    ; This is used to count up to 3 aliens
	xor a			        ;972c	af
	ld (BRICK_HIT_ROW),a	;972d	32 3c e5
    
	ld iy,ALIEN_TABLE		;9730	fd 21 c7 e4
	ld ix,ALIEN_SPR_PARAMS	;9734	dd 21 01 e1
l9738h:
    ; Skip if the alien isn't active
	ld a,(iy+ALIEN_TABLE_IDX_ACTIVE)    ;9738	fd 7e 01
	or a			                    ;973b	b7
	jr z,l979bh		                    ;973c	28 5d

    ; Skip if the alien is exploding
	ld a,(iy+ALIEN_TABLE_IDX_EXPLODING)	;973e	fd 7e 02
	cp 1		                        ;9741	fe 01
	jr z,l979bh		                    ;9743	28 56
    
    ; Skip if the alien can travel through the bricks
	ld a,(iy+ALIEN_TABLE_IDX_CAN_CROSS_BRICKS)	;9745	fd 7e 13
	cp 1		                                ;9748	fe 01
	jr z,l979bh		                            ;974a	28 4f

    ; Set E=8 if the alien goes down.
    ; Set E=32 if the alien goes up.
    ; This is because if the alien goes up, it'll reach the
    ; brick with his head, but with his feet if he goes down.
	ld e, 8		                                ;974c	1e 08
	bit 7,(iy+ALIEN_TABLE_IDX_VERT_SPEED)		    ;974e	fd cb 08 7e
	jr z,l9756h		                            ;9752	28 02
	ld e, 32		                            ;9754	1e 20
l9756h:
	ld a,(ix+SPR_PARAMS_IDX_Y)		            ;9756	dd 7e 00

	; A = (ALIEN_Y - E) / 8
    sub e		;9759	93
	srl a		;975a	cb 3f
	srl a		;975c	cb 3f
	srl a		;975e	cb 3f
    
    ; Skip if if (ALIEN_Y - E) / 8 >= 12
	cp 12		        ;9760	fe 0c
	jr nc,l979bh		;9762	30 37
    
    ; (ALIEN_Y - E) / 8 < 12

    ; BRICK_ROW = (ALIEN_Y - E) / 8
	ld (BRICK_ROW),a	;9764	32 aa e2

	; A = (ALIEN_X - 16) / 32
    ld a,(ix+SPR_PARAMS_IDX_X)		;9767	dd 7e 01
	sub 16		                    ;976a	d6 10
	srl a		                    ;976c	cb 3f
	srl a		                    ;976e	cb 3f
	srl a		                    ;9770	cb 3f
	srl a		                    ;9772	cb 3f
    
	; Skip if (ALIEN_X - 16) / 32 >= 11
    cp 11		    ;9774	fe 0b
	jr nc,l979bh	;9776	30 23
    
    ; (ALIEN_X - 16) / 32 < 11
    
	; BRICK_COL = (ALIEN_X - 16) / 32
    ld (BRICK_COL),a		    ;9778	32 ab e2
    
    ; If ALIEN_Y <= 100, then allow him to cross bricks
	ld a,(ix+SPR_PARAMS_IDX_Y)	                ;977b	dd 7e 00
	cp 100		                                ;977e	fe 64
	jr c,l9786h		                            ;9780	38 04
	ld (iy+ALIEN_TABLE_IDX_CAN_CROSS_BRICKS),1	;9782	fd 36 13 01
l9786h:
    ; Skip if there's no brick for the alien to touch
	push iy		            ;9786	fd e5
	push ix		            ;9788	dd e5
	call BRICK_EXISTS_AT_ROWCOL	;978a	cd a8 ad
	pop ix		            ;978d	dd e1
	pop iy		            ;978f	fd e1
	jr nc,l979bh		    ;9791	30 08
    
    ; If the alien it a brick, then change its vertical direction
	ld a,(iy+ALIEN_TABLE_IDX_VERT_SPEED)		;9793	fd 7e 08
	neg		                                ;9796	ed 44
	ld (iy+ALIEN_TABLE_IDX_VERT_SPEED),a		;9798	fd 77 08
l979bh:
    ; Next alien
	ld de,ALIEN_TABLE_LEN	;979b	11 14 00
	add iy,de		        ;979e	fd 19
	ld de, SPR_PARAMS_LEN	;97a0	11 04 00
	add ix,de		        ;97a3	dd 19

    ; Done if we've already checked 3 aliens
	ld hl,BRICK_HIT_ROW	;97a5	21 3c e5
	inc (hl)			;97a8	34
	ld a,(hl)			;97a9	7e
	cp 3		        ;97aa	fe 03
	jr nz,l9738h		;97ac	20 8a
	ret			        ;97ae	c9

; Fills the HARD_BRICK_TABLE with the current information on the bricks
UPDATE_HARD_BRICK_TABLE:
	push ix		    ;97af	dd e5
	ld b, 8		    ;97b1	06 08
	ld de, 8		;97b3	11 08 00
	ld ix,HARD_BRICK_TABLE	;97b6	dd 21 0d e2
l97bah:
	ld a,(ix+HARD_BRICK_TABLE_IDX_ALREADY_HIT)		;97ba	dd 7e 00
	or a			;97bd	b7
	jr z,l97c6h		;97be	28 06
	add ix,de		;97c0	dd 19
	djnz l97bah		;97c2	10 f6
	jr l97e7h		;97c4	18 21
l97c6h:
	ld (ix+HARD_BRICK_TABLE_IDX_ALREADY_HIT), 1		;97c6	dd 36 00 01
	ld (ix+HARD_OR_UNBREAKABLE_BRICK),c		        ;97ca	dd 71 01
	ld (ix+HARD_BRICK_TABLE_IDX_VRAM1),l		    ;97cd	dd 75 02
	ld (ix+HARD_BRICK_TABLE_IDX_VRAM2),h		    ;97d0	dd 74 03
	ld (ix+HARD_BRICK_TABLE_IDX_TICKS1), 0		    ;97d3	dd 36 04 00
	ld (ix+HARD_BRICK_TABLE_IDX_ANIM_STEP), 0		;97d7	dd 36 05 00
    
    ; Store row
	ld a,(BRICK_HIT_ROW)		            ;97db	3a 3c e5
	ld (ix+HARD_BRICK_TABLE_IDX_ROW),a		;97de	dd 77 06

    ; Store col
	ld a,(BRICK_HIT_COL)		            ;97e1	3a 3d e5
	ld (ix+HARD_BRICK_TABLE_IDX_COL),a		;97e4	dd 77 07
l97e7h:
	pop ix		;97e7	dd e1
	ret			;97e9	c9

; Check if any of the hard bricks was hit, perform any animations, and
; remove it from the table if it's a destroyed hard brick.
CHECK_HARD_BRICKS_HIT:
    ; Skip if we're at DOh's level
    ld a,(LEVEL)		;97ea	3a 1b e0
	cp FINAL_LEVEL		;97ed	fe 20
	ret z			    ;97ef	c8
    
	ld b, HARD_BRICK_TABLE_NUM_ENTRIES		        ;97f0	06 08
	ld de, HARD_BRICK_TABLE_ENTRY_LEN		        ;97f2	11 08 00
	ld ix,HARD_BRICK_TABLE		                    ;97f5	dd 21 0d e2
l97f9h:
	push bc			                                ;97f9	c5

    ; Skip and move to the next entry if the brick was already hit
	ld a,(ix+HARD_BRICK_TABLE_IDX_ALREADY_HIT)		;97fa	dd 7e 00
	or a			                                ;97fd	b7
	jr z,l9859h		                                ;97fe	28 59

    ; No, it wasn't hit already
    ; Skip if the ticks are not 2
	inc (ix+HARD_BRICK_TABLE_IDX_TICKS1)	;9800	dd 34 04
	ld a,(ix+HARD_BRICK_TABLE_IDX_TICKS1)	;9803	dd 7e 04
	cp 2		                            ;9806	fe 02
	jr nz,l9859h		                    ;9808	20 4f

	ld (ix+HARD_BRICK_TABLE_IDX_TICKS1), 0	;980a	dd 36 04 00

	ld de,UNBREAKABLE_BRICK_ANIM_CHARS		;980e	11 6a 98
	bit 0,(ix+HARD_OR_UNBREAKABLE_BRICK)	;9811	dd cb 01 46
	jr nz,l981ah		                    ;9815	20 03
	ld de,HARD_BRICK_ANIM_CHARS		        ;9817	11 62 98
l981ah:
    ; HL = 2*ANIM_STEP + ANIM_CHARS, RAM origin
	ld l,(ix+HARD_BRICK_TABLE_IDX_ANIM_STEP)		;981a	dd 6e 05
	ld h, 0		                                    ;981d	26 00
	add hl,hl			                            ;981f	29
	add hl,de			                            ;9820	19
    
    ; DE = HARD_BRICK_TABLE[HARD_BRICK_TABLE_IDX_VRAM1 -or 2], VRAM destination
	ld e,(ix+HARD_BRICK_TABLE_IDX_VRAM1)		;9821	dd 5e 02
	ld d,(ix+HARD_BRICK_TABLE_IDX_VRAM2)		;9824	dd 56 03

    ; Write 2 chars
	ld bc, 2		    ;9827	01 02 00
	call LDIRVM		    ;982a	cd 5c 00

    ; Skip if the animation is not finished
	inc (ix+HARD_BRICK_TABLE_IDX_ANIM_STEP)		;982d	dd 34 05
	ld a,(ix+HARD_BRICK_TABLE_IDX_ANIM_STEP)	;9830	dd 7e 05
	cp 4		                                ;9833	fe 04
	jr nz,l9859h		                        ;9835	20 22

    ; Store brick row and col
	ld a,(ix+HARD_BRICK_TABLE_IDX_ROW)		;9837	dd 7e 06
	ld (BRICK_ROW),a		                ;983a	32 aa e2
	ld a,(ix+HARD_BRICK_TABLE_IDX_COL)		;983d	dd 7e 07
	ld (BRICK_COL),a		                ;9840	32 ab e2
    
    ; Erase the brick if destroyed
	call BRICK_EXISTS_AT_ROWCOL	;9843	cd a8 ad
	jr c,l984bh		        ;9846	38 03
    
    ; Erase that brick
	call ERASE_BRICK		;9848	cd 8f ab
l984bh:
    ; Remove the hard brick from the table (write 8 zeros)
	push ix		    ;984b	dd e5
	push ix		    ;984d	dd e5
	pop hl			;984f	e1
	pop de			;9850	d1
	inc de			;9851	13
	ld bc, 7	    ;9852	01 07 00
	ld (hl), 0  	;9855	36 00
	ldir		    ;9857	ed b0
l9859h:
    ; Next hard brick
	pop bc			                        ;9859	c1
	ld de, HARD_BRICK_TABLE_ENTRY_LEN		;985a	11 08 00
	add ix,de		                        ;985d	dd 19
	djnz l97f9h		                        ;985f	10 98
	ret			                            ;9861	c9

HARD_BRICK_ANIM_CHARS:
    db 0x65, 0x6c, 0x6b, 0x6c, 0x6b, 0x66, 0x65, 0x66
UNBREAKABLE_BRICK_ANIM_CHARS:
    db 0x67, 0x6c, 0x6b, 0x6c, 0x6b, 0x68, 0x67, 0x68

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
	ld l,(iy+SPR_PARAMS_IDX_X)		;9889	fd 6e 01
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
    dw ACTION_INITIALIZE_GLUED_BALL
    dw ACTION_BALL_FOLLOWS_VAUS_IF_GLUED
    dw ACTION_9941

; Initialize ball for the level start
ACTION_INITIALIZE_GLUED_BALL:
    ; iy = BALL_TABLE1
    ; ix = SPR_PARAMS_IDX_Y
	ld (ix+SPR_PARAMS_IDX_Y), 169		;   989e	dd 36 00 a9     Ball on Vaus
    ; The other two balls are invisible at row 192
	ld (ix+SPR_PARAMS_IDX_Y + 1*SPR_PARAMS_LEN), 192  ;98a2	dd 36 04 c0
	ld (ix+SPR_PARAMS_IDX_Y + 2*SPR_PARAMS_LEN), 192  ;98a6	dd 36 08 c0

	ld (iy+BALL_TABLE_IDX_VAUS_HIT_X),  26  ;98aa	fd 36 10 1a

    ; Configure sprite of the ball. Start as glued to Vaus.
	ld (ix+SPR_PARAMS_IDX_PATTERN_NUM), 0x80   ;98ae	dd 36 02 80
	ld (ix+SPR_PARAMS_IDX_COLOR), 15	       ;98b2	dd 36 03 0f     White color

    ; Glued
	ld (iy+BALL_TABLE_IDX_GLUE),1	           ;98b6	fd 36 01 01     Ball is glued
	
    ; Initialize glue timer
    ld (iy+BALL_TABLE_IDX_GLUE_COUNTER), 120	;98ba	fd 36 0e 78
    
    ; Set direction
	ld (iy+BALL_TABLE_IDX_SKEWNESS),3           ;98be	fd 36 06 03
	ld (iy+BALL_TABLE_IDX_Y_SPEED), -1		    ;98c2	fd 36 02 ff     Ball moves up

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

; If the ball is sticky, decrement the sticky counter and make the
; ball follow sticky Vaus.
; Otherwise, make it bounce normally.
ACTION_BALL_FOLLOWS_VAUS_IF_GLUED:
    ; Skip the following if we're at the title screen
	ld a,(GAME_STATE)		;98f8	3a 0b e0
	or a			        ;98fb	b7
	jp z,l9935h		        ;98fc	ca 35 99

	ld a,(USE_VAUS_PADDLE)		;98ff	3a 0c e0 	: . . 
	or a			;9902	b7 	. 
	jp z,l9910h		;9903	ca 10 99 	. . . 

	ld a,(PADDLE_STATUS+1)		;9906	3a c5 e0 	: . . 
	bit 1,a		;9909	cb 4f 	. O 
	jr nz,l9935h		;990b	20 28 	  ( 
	jp l9917h		;990d	c3 17 99 	. . . 
l9910h:
	ld a,(CONTROLS)		;9910	3a bf e0 	: . . 
	bit 4,a		;9913	cb 67 	. g 
	jr nz,l9935h		;9915	20 1e 	  . 
l9917h:
    ; Decrement the glue timer
	dec (iy+BALL_TABLE_IDX_GLUE_COUNTER)	;9917	fd 35 0e
	jr z,l9935h		                        ;991a	28 19

    ; Check GLUING_STATE_NO_LONGER_STICKY
	ld hl,GLUING_STATUS		;991c	21 24 e3
	bit 1,(hl)		        ;991f	cb 4e
	jp nz,l9930h		    ;9921	c2 30 99

    ; Set the position of the ball to where it hit Vaus.
    ; It's the position VAUS_X + VAUS_HIT
    ; Thus, this makes the ball follow sticky Vaus.
	ld a,(VAUS_X)		                    ;9924	3a ce e0
	add a,(iy+BALL_TABLE_IDX_VAUS_HIT_X)	;9927	fd 86 10
	ld (ix+SPR_PARAMS_IDX_X),a              ;992a	dd 77 01
	jp l99b8h		                        ;992d	c3 b8 99
l9930h:
    ; Vaus is not sticky
	ld a,GLUING_STATE_NOT_STICKY		;9930	3e 00
	ld (GLUING_STATUS),a		        ;9932	32 24 e3
l9935h:
	ld (iy+BALL_TABLE_IDX_GLUE), 2		;9935	fd 36 01 02     Ball moves normally

	ld a, SOUND_BALL_BOUNCES_ON_VAUS	;9939	3e 01
	call ADD_SOUND		                ;993b	cd ef 5b
	jp l99b8h		                    ;993e	c3 b8 99

; And this one with bouncing when reaching the limits of the playfield
ACTION_9941:
    ; iy = BALL_TABLE1
    ; ix = SPR_PARAMS_IDX_Y

    ; Update ball's position
	call UPDATE_BALL_POSITION		;9941	cd df 99 	. . . 

    ; Go on if the ball is active
	ld a,(iy+BALL_TABLE_IDX_ACTIVE)		;9944	fd 7e 00
	or a			                    ;9947	b7
	jp z,l99b8h		                    ;9948	ca b8 99

	ld a,(ix+SPR_PARAMS_IDX_X)		;994b	dd 7e 01
    
    ; Check if it's moving right
	bit 7,(iy+BALL_TABLE_IDX_X_SPEED)		;994e	fd cb 03 7e     Z if RIGHT
	jp nz,l996bh		            ;9952	c2 6b 99 Moving left, skip
    
    ; It's moving right, compare with 186 (right border)
	cp 186		                    ;9955	fe ba
	jp c,l996bh		                ;9957	da 6b 99    It's less than 186, jump
    
    ; It's moving right with X > 186
	call UPDATE_BALL_SPEED		;995a	cd f0 9a
	call BALL_HORIZONTAL_BOUNCE		        ;995d	cd 80 9b
    
    ; Set the position to 185
	ld a, 185		            ;9960	3e b9
	ld (ix+SPR_PARAMS_IDX_X),a		;9962	dd 77 01

	call CHECK_BALL_BOUNCES_AND_CHANGE_SKEWNESS		;9965	cd d1 99 	. . . 
	jp l9985h		;9968	c3 85 99 	. . . 

l996bh:
    ; Check if the ball is moving right
	bit 7,(iy+BALL_TABLE_IDX_X_SPEED)		;996b	fd cb 03 7e     Z if RIGHT
	jp z,l9985h		                ;996f	ca 85 99    Jump if it's moving RIGHT
    
    ; It's moving left
    ; Compare with 18 (left border)
	cp 18		        ;9972	fe 1
	jp nc,l9985h		;9974	d2 85 99    It's more than 18, skip
    
    ; It's touched the left border
	call UPDATE_BALL_SPEED		;9977	cd f0 9a
	call BALL_HORIZONTAL_BOUNCE		        ;997a	cd 80 9b

    ; Set the position to 18
	ld a, 18		            ;997d	3e 12
	ld (ix+SPR_PARAMS_IDX_X),a  ;997f	dd 77 01

	call CHECK_BALL_BOUNCES_AND_CHANGE_SKEWNESS		        ;9982	cd d1 99
l9985h:
	ld a,(ix+SPR_PARAMS_IDX_Y)		;9985	dd 7e 00

	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		    ;9988	fd cb 02 7e     Z if moving DOWN
	jp z,l99a2h		                    ;998c	ca a2 99        Moving down, skip
    
    ; Moving up
    cp 9		        ;998f	fe 09
	jp nc,l99a2h		;9991	d2 a2 99    More than 9, skip
    
    ; Has touched the ceiling
	call UPDATE_BALL_SPEED		;9994	cd f0 9a
	call BALL_VERTICAL_BOUNCE		        ;9997	cd 5b 9b
    
    ; Set position to 9
	ld a,9		                ;999a	3e 09
	ld (ix+SPR_PARAMS_IDX_Y),a		;999c	dd 77 00

	call CHECK_BALL_BOUNCES_AND_CHANGE_SKEWNESS     ;999f	cd d1 99
l99a2h:
	push ix		;99a2	dd e5 	. . 
	push iy		;99a4	fd e5 	. . 
	call CHECK_UPDATE_BALL_GLUE_AND_SKEWNESS		;99a6	cd a8 9b 	. . . 
	pop iy		;99a9	fd e1 	. . 
	pop ix		;99ab	dd e1 	. . 

	ld a,(ix+SPR_PARAMS_IDX_Y)		;99ad	dd 7e 00
	cp 184		                        ;99b0	fe b8
	jp c,l99b8h		                    ;99b2	da b8 99 Jump if Y < 184
    
    ; Y > 184: ball lost!
	call BALL_OUT_BELOW		;99b5	cd 2a 9b 	. * . 
l99b8h:
	pop iy		                    ;99b8	fd e1
	pop ix		                    ;99ba	dd e1

    ; Next ball (spr)
	ld de,SPR_PARAMS_LEN		;99bc	11 04 00
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

; Increment the number of bounces of the ball in the borders and
; change the skewness of the balls when the counter reaches 40.
CHECK_BALL_BOUNCES_AND_CHANGE_SKEWNESS:
    ; Increment the number of bounces of the ball in the borders
	ld hl,BALL_BOUNCES_COUNTER		;99d1	21 1c e5
	inc (hl)			            ;99d4	34
    
    ; If it has reached 40, change the skewness of the balls
	ld a,(hl)			            ;99d5	7e
	cp 40		                    ;99d6	fe 28
	ret nz			                ;99d8	c0
	ld (hl), 0		                ;99d9	36 00   Reset counter
	call CHANGE_BALLS_SKEWNESS		            ;99db	cd 38 ab
	ret			                    ;99de	c9

; Update the ball's position according to its skewness
UPDATE_BALL_POSITION: ; 99df
    ; iy = BALL_TABLE1
    ; ix = SPR_PARAMS_IDX_Y

	ld hl,TBL_PTR_BALL_SPEED_PER_SKEWNESS		                ;99df	21 98 9a
    
    ; If the ball's skewness is positive, invert it
	ld a,(iy+BALL_TABLE_IDX_SKEWNESS)	;99e2	fd 7e 06
	bit 7,a		                        ;99e5	cb 7f
	jr z,l99ebh		                    ;99e7	28 02   Jump if negative
    ; It's positive: invert it
	neg		                            ;99e9	ed 44
l99ebh:
	sla a		                        ;99eb	cb 27   A = skewness
	ld e,a			                    ;99ed	5f
	ld d, 0		                        ;99ee	16 00   DE = skewness
	add hl,de			                ;99f0	19      HL = TBL_PTR_BALL_SPEED_PER_SKEWNESS + skewness
	ld e,(hl)			                ;99f1	5e
	inc hl			                    ;99f2	23
	ld d,(hl)			                ;99f3	56      DE = TBL_PTR_BALL_SPEED_PER_SKEWNESS[skewness]
	
    ld l,(iy+BALL_TABLE_IDX_SPEED_POS)	;99f4	fd 6e 07    HL = BALL_SPEED_POS
	ld h, 0		                        ;99f7	26 00
	add hl,hl			                ;99f9	29          HL = 2*BALL_SPEED_POS
	add hl,de			                ;99fa	19          HL = 2*BALL_SPEED_POS + TBL_PTR_BALL_SPEED_PER_SKEWNESS[skewness]
    
    ; We obtain from the double indirection TBL_PTR_BALL_SPEED_PER_SKEWNESS[skewness][2*BALL_SPEED_POS] two values:
    ; BALL_TABLE_IDX_SPEED_MULTIPLIER
    ; BALL_TABLE_IDX_MOVE_TARGET

	ld a,(hl)			;99fb	7e          A = TBL_PTR_BALL_SPEED_PER_SKEWNESS[skewness][2*BALL_SPEED_POS]  Double indirection!
	ld (iy+BALL_TABLE_IDX_SPEED_MULTIPLIER),a	;99fc	fd 77 08
    

    ; Set BALL_TABLE_IDX_MOVE_TARGET
	inc hl			                            ;99ff	23
	ld a,(hl)			                        ;9a00	7e
	ld (iy+BALL_TABLE_IDX_MOVE_TARGET),a		;9a01	fd 77 09

    ; BALL_TABLE_IDX_MOVE_COUNTER is incremented and compared to BALL_TABLE_IDX_MOVE_TARGET
    ; When the objective is reached, BALL_TABLE_IDX_MOVE_COUNTER is reset.
    ;
    ; It's counter to update the position of the ball.
    ; If BALL_TABLE_IDX_MOVE_COUNTER < BALL_TABLE_IDX_MOVE_TARGET, the ball doesn't move.
	inc (iy+BALL_TABLE_IDX_MOVE_COUNTER)		;9a04	fd 34 05
	ld a,(iy+BALL_TABLE_IDX_MOVE_COUNTER)		;9a07	fd 7e 05
	cp (iy+BALL_TABLE_IDX_MOVE_TARGET)		    ;9a0a	fd be 09
	ret c			                            ;9a0d	d8  The balls won't move

	ld (iy+BALL_TABLE_IDX_MOVE_COUNTER), 0		;9a0e	fd 36 05 00
    
    ; Since the counter has reached its goal, now we'll read the skewness,
    ; obtain the speed, and apply it to the ball so it moves
    ;
    ; Otherwise, the ball won't move.

    ; Translate the skewness to an (X, Y) speed of the ball

    ; Choose TBL_SKEWNESS_POS_TO_XY_SPEED or TBL_SKEWNESS_NEG_TO_XY_SPEED according to
    ; the sign of BALL_TABLE_IDX_SKEWNESS
	ld hl,TBL_SKEWNESS_POS_TO_XY_SPEED	;9a12	21 78 9a
	ld a,(iy+BALL_TABLE_IDX_SKEWNESS)	;9a15	fd 7e 06
	bit 7,a		                        ;9a18	cb 7f
	jp z,l9a22h		                    ;9a1a	ca 22 9a Jump if it's positive
    ; It's negative: invert it
	neg		                            ;9a1d	ed 44
	ld hl,TBL_SKEWNESS_NEG_TO_XY_SPEED	;9a1f	21 88 9a

l9a22h:
	dec a		;9a22	3d      A = skewness - 1
	sla a		;9a23	cb 27   A = 2*(skewness - 1)
	ld e,a		;9a25	5f
	ld d, 0	;9a26	16 00   DE = 2*(skewness - 1) 
	add hl,de	;9a28	19      HL = TBL + 2*(skewness - 1)
    
    ; Set Y speed
    ; The value is stored at TBL[2*(skewness - 1)]
	ld a,(hl)			                ;9a29	7e
	ld (iy+BALL_TABLE_IDX_Y_SPEED),a	;9a2a	fd 77 02
    
    ; Set X speed
    ; The value is stored at TBL[2*(skewness - 1)+1]
	inc hl			                    ;9a2d	23
	ld a,(hl)			                ;9a2e	7e
	ld (iy+BALL_TABLE_IDX_X_SPEED),a	;9a2f	fd 77 03
    
    ; Apply the multiplier
	ld b,(iy+BALL_TABLE_IDX_SPEED_MULTIPLIER)		;9a32	fd 46 08
	inc b			                                ;9a35	04  Even if the value would be zero, loop at least once
l9a36h:
    ; Update Y-position of the ball according to its speed
	ld a,(iy+BALL_TABLE_IDX_Y_SPEED)	;9a36	fd 7e 02
	add a,(ix+SPR_PARAMS_IDX_Y)		    ;9a39	dd 86 00
	ld (ix+SPR_PARAMS_IDX_Y),a		    ;9a3c	dd 77 00

    ; Update X-position of the ball according to its speed
	ld a,(iy+BALL_TABLE_IDX_X_SPEED)	;9a3f	fd 7e 03
	add a,(ix+SPR_PARAMS_IDX_X)		    ;9a42	dd 86 01
	ld (ix+SPR_PARAMS_IDX_X),a		    ;9a45	dd 77 01

	xor a			;9a48	af 	. 
	ld (DOH_BEEN_HIT),a		;9a49	32 b9 e2 	2 . . 

	push bc			;9a4c	c5 	. 
	push ix		;9a4d	dd e5 	. . 
	push iy		;9a4f	fd e5 	. . 
	ld a,(LEVEL)		;9a51	3a 1b e0
	cp FINAL_LEVEL		;9a54	fe 20
	jr nz,l9a5dh		;9a56	20 05 	  . 

    ; Final level
	call CHECK_DOH_HIT_AND_BOUNCE_BALL		;9a58	cd 7b 96 	. { . 
	jr l9a60h		;9a5b	18 03 	. . 
l9a5dh:
    ; Not final level
    ; ToDo: check and process ball bounces from bricks
	call CHECK_BRICK_HIT_AND_BOUNCE_BALL		;9a5d	cd 2d 9c
l9a60h:
	pop iy		;9a60	fd e1
	pop ix		;9a62	dd e1
	pop bc		;9a64	c1
	ld a,(DOH_BEEN_HIT)		;9a65	3a b9 e2
	or a			;9a68	b7
	ret nz			;9a69	c0
	djnz l9a36h		;9a6a	10 ca
	push iy		;9a6c	fd e5
	push ix		;9a6e	dd e5
	call CHECK_ANY_BALL_HITS_ALIEN		;9a70	cd a5 79
	pop ix		;9a73	dd e1
	pop iy		;9a75	fd e1
	ret			;9a77	c9

; Positive skewness to (X, Y) speed
TBL_SKEWNESS_POS_TO_XY_SPEED: ;9a78
    ; (Y-speed, X-speed)
    db -1,  2
    db -1 , 2
    db -1,  1
    db -2,  1
    db -2, -1
    db -1, -1
    db -1, -2
    db -1, -2

; Negative skewness to (X, Y) ball speed
TBL_SKEWNESS_NEG_TO_XY_SPEED: ;9a88
    ; (Y-speed, X-speed)
    db 1, -2
    db 1, -2
    db 1, -1
    db 2, -1
    db 2,  1
    db 1,  1
    db 1,  2
    db 1,  2


; This table is addressed as TBL_PTR_BALL_SPEED_PER_SKEWNESS[skewness][2*BALL_SPEED_POS]
; And it gives two values:
;   BALL_TABLE_IDX_SPEED_MULTIPLIER
;   BALL_TABLE_IDX_MOVE_TARGET
TBL_PTR_BALL_SPEED_PER_SKEWNESS: ; 0x9a98
    dw l9ad0h, l9ad0h, l9ad0h, l9ab0h, l9ad0h, l9ad0h, l9ab0h, l9ad0h, l9ad0h, l9ad0h, l9ad0h, l9ad0h

; These values contain two values per position:
;   BALL_TABLE_IDX_SPEED_MULTIPLIER
;   BALL_TABLE_IDX_MOVE_TARGET

l9ab0h: ;9ab0
    db 0, 15
    db 0, 14
    db 0, 13
    db 0, 12
    db 1, 15
    db 1, 14
    db 1, 13
    db 1, 12
    db 0,  4
    db 2,  8
    db 0,  2
    db 2,  4
    db 0,  1
    db 2,  2
    db 1,  1
    db 2,  1

l9ad0h: ;0x9ad0
    db 0, 23
    db 0, 21
    db 0, 20
    db 0, 18
    db 1, 23
    db 1, 21
    db 1, 20
    db 1, 18
    db 0,  6
    db 2, 12
    db 0,  3
    db 1,  4
    db 1,  3
    db 1,  2
    db 0,  1
    db 1,  1

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

; This is called when a ball is lost, BALL_Y > 184.
; It checks if there are extra balls, and it so, an extra ball is lost.
; Otherwise, a life is lost.
BALL_OUT_BELOW:
    ; HL = DE = BALL_TABLE
	push iy		    ;9b2a	fd e5
	push iy		    ;9b2c	fd e5
	pop hl			;9b2e	e1
	pop de			;9b2f	d1

    ; 
	inc de			                ;9b30	13
	ld (hl), 0		                ;9b31	36 00
	ld bc, BALL_TABLE_LEN - 1		;9b33	01 13 00
	ldir		                    ;9b36	ed b0

	ld (ix+SPR_PARAMS_IDX_Y), 192	;9b38	dd 36 00 c0
	ld (ix+SPR_PARAMS_IDX_COLOR),0	;9b3c	dd 36 03 00

    ; If there are not extra balls, check if Vaus is going through the portal (it escapes).
	ld hl,EXTRA_BALLS	;9b40	21 25 e3
	ld a,(hl)			;9b43	7e
	or a			    ;9b44	b7
	jp z,l9b4ah		    ;9b45	ca 4a 9b    No extra balls
    
    ; Yes, we have extra balls.
    ; We don't lose a life, but one of the extra balls.
	dec (hl)			;9b48	35
	ret			        ;9b49	c9

l9b4ah:
    ; Skip if Vaus is going through the portal
	ld a,(VAUS_TABLE + VAUS_TABLE_IDX_ACTION_STATE)		    ;9b4a	3a 4b e5
	cp VAUS_ACTION_STATE_THROUGH_PORTAL	;9b4d	fe 07
	ret z			                    ;9b4f	c8

	; Set Vaus is exploding
    ld a,VAUS_ACTION_STATE_EXPLODING	;9b50	3e 06
	ld (VAUS_TABLE + VAUS_TABLE_IDX_ACTION_STATE),a		    ;9b52	32 4b e5
    
	ld a, SOUND_VAUS_DESTROYED		;9b55	3e 07
	call ADD_SOUND		            ;9b57	cd ef 5b
	ret			                    ;9b5a	c9

; The ball inverts its vertical direction, as well as its skewness
BALL_VERTICAL_BOUNCE:
    ; Invert ball's vertical speed
	push af			                ;9b5b	f5
	ld a,(iy+BALL_TABLE_IDX_Y_SPEED)	;9b5c	fd 7e 02
	neg		                        ;9b5f	ed 44
	ld (iy+BALL_TABLE_IDX_Y_SPEED),a	;9b61	fd 77 02
	pop af			                ;9b64	f1
    
    ; And invert its skewness
	push af			                    ;9b65	f5
    ; If skewness >= 0, invert it
    ld a,(iy+BALL_TABLE_IDX_SKEWNESS)	;9b66	fd 7e 06
	bit 7,a		                        ;9b69	cb 7f
	jp z,l9b70h		                    ;9b6b	ca 70 9b
	neg		                            ;9b6e	ed 44
l9b70h:
    ; If skewness >= 9, invert it
	sub 9		                        ;9b70	d6 09   A = SKEWNESS - 9
	bit 7,(iy+BALL_TABLE_IDX_SKEWNESS)	;9b72	fd cb 06 7e
	jp z,l9b7bh		                    ;9b76	ca 7b 9b
	neg		                            ;9b79	ed 44
l9b7bh:
    ; Update skewness
	ld (iy+BALL_TABLE_IDX_SKEWNESS),a	;9b7b	fd 77 06
	pop af			                    ;9b7e	f1
	ret			                        ;9b7f	c9

; The ball inverts its horizontal direction, as well as its skewness
BALL_HORIZONTAL_BOUNCE:
    ; Invert ball's vertical speed
	push af			                    ;9b80	f5
	ld a,(iy+BALL_TABLE_IDX_X_SPEED)		;9b81	fd 7e 03
	neg		                            ;9b84	ed 44
	ld (iy+BALL_TABLE_IDX_X_SPEED),a		;9b86	fd 77 03
	pop af			                    ;9b89	f1
    ; Fall to
    
; Invert ball's vertical skewness
INVERT_BALL_VERTICAL_SKEWNESS:
	push af			                    ;9b8a	f5 	.    
    ; If skewness >= 0,then invert it
	ld a,(iy+BALL_TABLE_IDX_SKEWNESS)	;9b8b	fd 7e 06
	bit 7,a		                        ;9b8e	cb 7f
	jp z,l9b95h		                    ;9b90	ca 95 9b
	neg		                            ;9b93	ed 44
l9b95h:
	ld c,a			                    ;9b95	4f
	ld a, 9		                        ;9b96	3e 09
	sub c			                    ;9b98	91      A = SKEWNESS -9

    ; If current skewness >= 0 then invert
	ld c,(iy+BALL_TABLE_IDX_SKEWNESS)	;9b99	fd 4e 06
	bit 7,c		                        ;9b9c	cb 79
	jp z,l9ba3h		                    ;9b9e	ca a3 9b
	neg		                            ;9ba1	ed 44
l9ba3h:
    ; Set new skewness
	ld (iy+BALL_TABLE_IDX_SKEWNESS),a	;9ba3	fd 77 06
	pop af			                    ;9ba6	f1
	ret			                        ;9ba7	c9

; Checks if the ball has reached Vaus
; If so, make it bounce with the proper skewness (or stick to Vaus if
; it's sticky).
CHECK_UPDATE_BALL_GLUE_AND_SKEWNESS:
	ld a,(ix+SPR_PARAMS_IDX_Y)		    ;9ba8	dd 7e 00
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;9bab	fd cb 02 7e     Z if the ball is moving DOWN
	ret nz			                    ;9baf	c0              Return if moving UP
    
    ; The ball is moving down

	cp 167		    ;9bb0	fe a7
	ret c			;9bb2	d8      Return if Y < 167
	cp 173		    ;9bb3	fe ad
	ret nc			;9bb5	d0      Return if Y >= 173

    ; 167 < BALL_Y < 173
    
    ld a,(VAUS_X)		;9bb6	3a ce e0
	add a,1		        ;9bb9	c6 01       A = VAUS_X + 1
    
	cp (ix+SPR_PARAMS_IDX_X)		;9bbb	dd be 01
	ret nc			                ;9bbe	d0  Exit if VAUS_X + 1 >= BALL_X
    
    ; VAUS_X < BALL_X - 1
    
    ; By default (Vaus not enlarged) set C=7, B=41
	ld c, 7 		;9bbf	0e 07
	ld b, 41		;9bc1	06 29

	ld a,(VAUS_TABLE + VAUS_TABLE_IDX_RESIZING)		    ;9bc3	3a 50 e5
	cp VAUS_ACTION_STATE_ENLARGING		;9bc6	fe 02
	jp nz,l9bcfh		                ;9bc8	c2 cf 9b
    ; If Vaus is enlarged, set C=10, B=57
	ld c, 10		;9bcb	0e 0a
	ld b, 57		;9bcd	06 39

l9bcfh:
	ld a,(VAUS_X)		            ;9bcf	3a ce e0    A = VAUS_X
	add a,b			                ;9bd2	80          A = VAUS_X + limit
    
    ; Check if VAUS_X + limit 
	cp (ix+SPR_PARAMS_IDX_X)		;9bd3	dd be 01
	ret c			                ;9bd6	d8      Return if BALL_X > VAUS_X + limit
    
    ; BALL_X <= VAUS_X + limit
    ; At this point the ball is hitting Vaus
    
    ; Set BALL_Y to 169
	ld (ix+SPR_PARAMS_IDX_Y), 169	;9bd7	dd 36 00 a9
    
    ; Check if Vaus is sticky.
    ; If so, glue the ball to Vaus.
    ; Otherwise, make the ball bouncing sound.
	ld a,(GLUING_STATUS)		;9bdb	3a 24 e3
	cp GLUING_STATE_STICKY		;9bde	fe 01
	jp z,l9bebh		            ;9be0	ca eb 9b

	ld a,SOUND_BALL_BOUNCES_ON_VAUS		;9be3	3e 01
	call ADD_SOUND		                ;9be5	cd ef 5b
	jp l9c05h		                    ;9be8	c3 05 9c
l9bebh:
	push bc			;9beb	c5 	. 
    
    ; Initialize BALL_TABLE_IDX_GLUE_COUNTER
	ld (iy+BALL_TABLE_IDX_GLUE_COUNTER), 240		;9bec	fd 36 0e f0

	; Set the ball is glued
    ld (iy+BALL_TABLE_IDX_GLUE), 1		            ;9bf0	fd 36 01 01

	ld a,(VAUS_X)		                ;9bf4	3a ce e0    A = VAUS_X
	ld c,a			                    ;9bf7	4f          C = VAUS_X
	ld a,(ix+SPR_PARAMS_IDX_X)	        ;9bf8	dd 7e 01    A = BALL_X
	sub c			                    ;9bfb	91          A = BALL_X - VAUS_X
	ld (iy+BALL_TABLE_IDX_VAUS_HIT_X),a ;9bfc	fd 77 10    Store X - VAUS_X
	pop bc			            ;9bff	c1

	ld a,SOUND_GLUED_BALL_CATCHED	;9c00	3e 04
	call ADD_SOUND		            ;9c02	cd ef 5b
l9c05h:
    ; Invert ball vertical direction
	ld a,(iy+BALL_TABLE_IDX_Y_SPEED)		;9c05	fd 7e 02
	neg		                            ;9c08	ed 44
	ld (iy+BALL_TABLE_IDX_Y_SPEED),a		;9c0a	fd 77 02

	ld a,(VAUS_X)		                ;9c0d	3a ce e0
	ld b,a			                    ;9c10	47 	G       B = VAUS_X
	ld a,(ix+SPR_PARAMS_IDX_X)		    ;9c11	dd 7e 01    A = BALL_X
	sub b			                    ;9c14	90          A = BALL_X - VAUS_X
	ld l,a			                    ;9c15	6f
	ld h,0  		                    ;9c16	26 00       HL = BALL_X - VAUS_X
    
    ; To compute the skewness of the ball when bouncing, it considers Vaus is
    ; divided into several pieces (7 if normal size, or 10 if enlarged) and
    ; according to which of them the ball has hit, it set the different skewnesses.    
    
    ; Divide X - VAUS_X by C (7 or 10 is Vaus is enlarged).
    ; The result is put in HL.
	call DIVIDE_HL_BY_C	                ;9c18	cd 9a b3

	; A = BALL_DIRECTION_TABLE[l]
    ; DE =  (X - VAUS_X) \ C
    ld e,l			                ;9c1b	5d
	ld d,0		                    ;9c1c	16 00
	ld hl,BALL_SKEWNESS_TABLE		;9c1e	21 27 9c
    ; HL = BALL_SKEWNESS_TABLE + (X - VAUS_X) \ C
	add hl,de			            ;9c21	19
    ; A = BALL_SKEWNESS_TABLE[(X - VAUS_X) \ C]
	ld a,(hl)			            ;9c22	7e
    
    ; Set ball skewness
	ld (iy+BALL_TABLE_IDX_SKEWNESS),a	;9c23	fd 77 06
	ret			                        ;9c26	c9

BALL_SKEWNESS_TABLE:                    ;9c27
    ; 7: most skewed, moving left
    ; 6: a little bit skewed, moving left
    ; 5: less skewed, moving left
    ;
    ; 4: not very skewed, moving right
    ; 3: a little skewed, moving right
    ; 2: most skewed, moving right
    db 7, 6, 5, 4, 3, 2

; Check and process ball bounces from bricks
; This includes CHECK_BRICK_HIT_AND_BOUNCE_BALL and other functions
include 'check_brick_hit_and_bounce_ball.asm'

; Take the appropriate action when a brick is hit
APPLY_BRICK_HIT_EFFECT:
	call UPDATE_BALL_SPEED		;aa05	cd f0 9a
    
    ; HL = TBL_BRICK_ACTION_TABLE_OFFSETs[2*LEVEL]
	ld a,(LEVEL)		        ;aa08	3a 1b e0
	sla a		                ;aa0b	cb 27
    ld e,a			            ;aa0d	5f
	ld d, 0		                ;aa0e	16 00    
    ld hl,TBL_BRICK_ACTION_TABLE_OFFSETs		    ;aa10	21 5c aa
	add hl,de			        ;aa13	19
	ld e,(hl)			        ;aa14	5e
	inc hl			            ;aa15	23
	ld d,(hl)			        ;aa16	56
	ex de,hl			        ;aa17	eb

    ; (BRICK_ACTION_TABLE_OFFSET) <-- TBL_BRICK_ACTION_TABLE_OFFSETs[2*LEVEL]
	ld (BRICK_ACTION_TABLE_OFFSET),hl		;aa18	22 bc e2

    ; BRICK_ROW = min(BRICK_ROW, 11)
	ld a,(BRICK_ROW)	;aa1b	3a aa e2
	cp 12		        ;aa1e	fe 0c
	jp c,laa25h		    ;aa20	da 25 aa
	ld a, 11		    ;aa23	3e 0b
laa25h:
    ; HL = BRICK_ROW
	ld l,a			;aa25	6f
	ld h, 0		    ;aa26	26 00
laa28h:
	push hl			;aa28	e5
	pop bc			;aa29	c1  BC = BRICK_ROW
	add hl,hl		;aa2a	29 	HL = 2*BRICK_ROW
	push hl			;aa2b	e5
	pop de			;aa2c	d1  DE = 2*BRICK_ROW
	add hl,hl		;aa2d	29  HL = 4*BRICK_ROW
	add hl,hl		;aa2e	29  HL = 8*BRICK_ROW
	add hl,bc		;aa2f	09  HL = 9*BRICK_ROW
	add hl,de		;aa30	19  HL = 11*BRICK_ROW

    ; BRICK_COL = min(BRICK_COL, 10)
	ld a,(BRICK_COL)	;aa31	3a ab e2
	cp 11		        ;aa34	fe 0b
	jp c,laa3bh		    ;aa36	da 3b aa
	ld a, 10		    ;aa39	3e 0a
laa3bh:
	ld e,a			    ;aa3b	5f
laa3ch:
	ld d, 0		        ;aa3c	16 00   DE = BRICK_COL
	add hl,de			;aa3e	19      HL = 11*BRICK_ROW + BRICK_COL
    
	; HL = 11*BRICK_ROW + BRICK_COL + (BRICK_ACTION_TABLE_OFFSET)
    ld de,(BRICK_ACTION_TABLE_OFFSET)		;aa3f	ed 5b bc e2
	add hl,de			;aa43	19 	. 
    
    ; DE = [11*BRICK_ROW + BRICK_COL + (BRICK_ACTION_TABLE_OFFSET)]
	ld e,(hl)			;aa44	5e
    
	sla e		        ;aa45	cb 23   DE = 2*[11*BRICK_ROW + BRICK_COL + (BRICK_ACTION_TABLE_OFFSET)]
    
    ; HL = TBL_BRICK_ACTIONS + 2*[11*BRICK_ROW + BRICK_COL + (BRICK_ACTION_TABLE_OFFSET)]
	ld d,000h		        ;aa47	16 00
	ld hl,TBL_BRICK_ACTIONS	;aa49	21 52 aa
	add hl,de			    ;aa4c	19
    
    ; DE = TBL_BRICK_ACTIONS[2*[BRICK_ROWS*BRICK_ROW + BRICK_COL + (BRICK_ACTION_TABLE_OFFSET)]]
	ld e,(hl)			    ;aa4d	5e
	inc hl			        ;aa4e	23
	ld d,(hl)			    ;aa4f	56
    
    ; Jump to the corresponding action
	ex de,hl			    ;aa50	eb
	jp (hl)			        ;aa51	e9
;
TBL_BRICK_ACTIONS:          ;aa52
    dw action_brick_hit
    dw action_brick_hit_and_capsule
    dw action_hard_brick_hit
    dw action_unbreakable_brick_hit
    dw action_reset_unused_vars

; This points to tables with the bricks "unrolled".
; This is used to identify the brick type and take the appropriate action.
; It's the same as TBL_BRICK_ACTION_TABLE_OFFSETs_COPY
TBL_BRICK_ACTION_TABLE_OFFSETs: ;aa5c
    dw 0xc000, 0xc084, 0xc108, 0xc18c, 0xc210, 0xc294, 0xc318, 0xc39c; 0xaa5c - 0xaa6b
    dw 0xc420, 0xc4a4, 0xc528, 0xc5ac, 0xc630, 0xc6b4, 0xc738, 0xc7bc; 0xaa6c - 0xaa7b
    dw 0xc840, 0xc8c4, 0xc948, 0xc9cc, 0xca50, 0xcad4, 0xcb58, 0xcbdc; 0xaa7c - 0xaa8b
    dw 0xcc60, 0xcce4, 0xcd68, 0xcdec, 0xce70, 0xcef4, 0xcf78, 0xcffc; 0xaa8c - 0xaa9b

; Reset two unused variables
action_reset_unused_vars:
    xor a                   ;aa9c
	ld (BRICK_UNUSED_1),a	;aa9d	32 ba e2
	ld (BRICK_UNUSED_2),a	;aaa0	32 bb e2
	ret			            ;aaa3	c9

; An unbreakable brick has been hit.
; If the counter reaches 20 hits, change the ball's skewness
action_unbreakable_brick_hit:
    ; Set these two vars, but it seems they're never checked
	xor a			        ;aaa4	af
	ld (BRICK_UNUSED_2),a	;aaa5	32 bb e2
	ld a, 1 		        ;aaa8	3e 01
	ld (BRICK_UNUSED_1),a	;aaaa	32 ba e2

    ; Increment and check skewness counter
	ld hl,ACTION_SKEWNESS_COUNTER		;aaad	21 ac e5
	inc (hl)			;aab0	34
	ld a,(hl)			;aab1	7e
	cp 20		        ;aab2	fe 14
	jp nz,action_unbreakable_brick_bounce	;aab4	c2 bc aa

    ; Reset counter and change skewness
	ld (hl), 0		            ;aab7	36 00
	call CHANGE_BALLS_SKEWNESS	;aab9	cd 38 ab

; The ball bounces after hitting an unbreakable brick
action_unbreakable_brick_bounce:
	ld c, 1		                    ;aabc	0e 01
	jp action_hard_brick_bounce	    ;aabe	c3 06 ab

; Check if we need to make a capsule appear, only if there are no
; extra balls.
action_brick_hit_and_capsule:
	call SET_RANDOM_CAPSULE_IF_NO_EXTRA_BALLS	;aac1	cd 0f b0
	jp action_brick_hit		                    ;aac4	c3 ef aa

; We've hit a hard brick.
; Decrease its hits counter, and destroy it if done.
action_hard_brick_hit:
    ; Initialize counter
	xor a			;aac7	af
	ld (BRICK_UNUSED_1),a	;aac8	32 ba e2
	ld a, 1		    ;aacb	3e 01
	ld (BRICK_UNUSED_2),a	;aacd	32 bb e2

    ; HL = BRICK_ROW
	ld a,(BRICK_ROW)	;aad0	3a aa e2
	ld l,a			    ;aad3	6f
	ld h, 0		        ;aad4	26 00

    ; BC = BRICK_ROW
	push hl			;aad6	e5
	pop bc			;aad7	c1
    
	; DE = 2*BRICK_ROW
    add hl,hl		;aad8	29
	push hl			;aad9	e5
	pop de			;aada	d1
    
	add hl,hl			;aadb	29  HL = 4*BRICK_ROW
	add hl,hl			;aadc	29 	HL = 8*BRICK_ROW
	add hl,bc			;aadd	09 	HL = 9*BRICK_ROW 
	add hl,de			;aade	19 	HL = 11*BRICK_ROW 
    
    ; HL = 11*BRICK_ROW  + BRICK_COL
	ld a,(BRICK_COL)	;aadf	3a ab e2
	ld e,a			    ;aae2	5f
	ld d, 0		        ;aae3	16 00   DE = BRICK_COL
	add hl,de			;aae5	19      HL = 11*BRICK_ROW  + BRICK_COL
     
    ; HL = 11*BRICK_ROW  + BRICK_COL + HARD_BRICKS_REMAINING_HITS
	ld de,HARD_BRICKS_REMAINING_HITS		;aae6	11 39 e0
	add hl,de			                    ;aae9	19
    
    ; Decrement the number of hits of the hard brick
    ; Dec HARD_BRICKS_REMAINING_HITS[BRICK_ROWS*BRICK_ROW  + BRICK_COL]
	dec (hl)			;aaea	35 	5 

    ; If not destroyed, jump to action_hard_brick_bounce
	ld c, 0		                        ;aaeb	0e 00
	jr nz,action_hard_brick_bounce		;aaed	20 17
    ; Otherwise, proceed to action_brick_hit and destroy it

; Decrease the number of bricks left, play the brick destroyed
; sound, and move to the next level if no more bricks.
action_brick_hit:
	xor a			        ;aaef	af
	ld (BRICK_UNUSED_1),a	;aaf0	32 ba e2
	ld (BRICK_UNUSED_2),a	;aaf3	32 bb e2
	push iy		            ;aaf6	fd e5
	call CHECK_AND_REMOVE_BRICK		;aaf8	cd d3 ab 	. . . 
	pop iy		                    ;aafb	fd e1
	call DEC_BRICKS_CHECK_LEVEL_DONE		;aafd	cd 7a ab
	ld a,SOUND_BRICK_DESTROYED		;ab00	3e 02
	call ADD_SOUND		            ;ab02	cd ef 5b
	ret			                    ;ab05	c9

action_hard_brick_bounce:
    ; A = BRICK_ROW + 1
	ld a,(BRICK_ROW)    ;ab06	3a aa e2
	inc a			    ;ab09	3c
    
	ld hl, 0		;ab0a	21 00 00
	ld de, 32		;ab0d	11 20 00
lab10h:
    ; HL = 32*BRICK_ROW
	add hl,de			;ab10	19
	dec a			    ;ab11	3d
	jp nz,lab10h		;ab12	c2 10 ab

    ; HL = 32*BRICK_ROW + 0x1842
	ld de,01842h		;ab15	11 42 18
	add hl,de			;ab18	19

    ; E = 2*BRICK_COL
	ld a,(BRICK_COL)	;ab19	3a ab e2
	ld e,a			    ;ab1c	5f
	sla e		        ;ab1d	cb 23
    
    ; HL = 32*BRICK_ROW + 0x1842 + 2*BRICK_COL
	ld d, 0		        ;ab1f	16 00
	add hl,de			;ab21	19

    ; BRICK_HIT_ROW <-- BRICK_ROW
	ld a,(BRICK_ROW)		;ab22	3a aa e2
	ld (BRICK_HIT_ROW),a	;ab25	32 3c e5

    ; BRICK_HIT_COL <-- BRICK_COL
	ld a,(BRICK_COL)		;ab28	3a ab e2
	ld (BRICK_HIT_COL),a	;ab2b	32 3d e5
    
    ; Update the hard-brick table
	call UPDATE_HARD_BRICK_TABLE		;ab2e	cd af 97

    ; Play a hard-brick hit sound
	ld a,SOUND_HARD_BRICK_HIT		;ab31	3e 03
	call ADD_SOUND		            ;ab33	cd ef 5b
	xor a			                ;ab36	af
	ret			                    ;ab37	c9

; Change the skewness of all balls
CHANGE_BALLS_SKEWNESS:
	push iy		            ;ab38	fd e5
	ld iy,BALL_TABLE1		;ab3a	fd 21 4e e2
	ld b, 3 		        ;ab3e	06 03       Check 3 balls
lab40h:
    ; Skip if ball is inactive
	ld a,(iy+BALL_TABLE_IDX_ACTIVE)		;ab40	fd 7e 00
	cp 1		                        ;ab43	fe 01
	jp nz,lab60h		                ;ab45	c2 60 ab
    
    ; If the skewness if negative, negate it and add 8.
    ; This is to deal with negative numbers in the skewness.
	ld a,(iy+BALL_TABLE_IDX_SKEWNESS)	;ab48	fd 7e 06
	bit 7,a		                        ;ab4b	cb 7f
	jp z,lab54h		                    ;ab4d	ca 54 ab
	neg		                            ;ab50	ed 44
	add a,8		                        ;ab52	c6 08
lab54h:
    ; HL = TBL_SKEWNESS + SKEWNESS
	dec a			;ab54	3d
	ld l,a			;ab55	6f
	ld h, 0		    ;ab56	26 00
	ld de,TBL_SKEWNESS	;ab58	11 6a ab
	add hl,de		;ab5b	19
    
    ; A = TBL_SKEWNESS[SKEWNESS]
	ld a,(hl)		;ab5c	7e
    ; Update skewness
	ld (iy+BALL_TABLE_IDX_SKEWNESS),a	;ab5d	fd 77 06
lab60h:
    ; Next ball
	ld de, BALL_TABLE_LEN		;ab60	11 14 00
	add iy,de		            ;ab63	fd 19
	djnz lab40h		            ;ab65	10 d9
	pop iy		                ;ab67	fd e1
	ret			                ;ab69	c9
TBL_SKEWNESS:
    db 2, 3, 4, 3, 6, 5, 6, 7, -2, -3, -4, -3, -6, -5, -6, -7   ;ab6a

; This is called after a brick has been hit.
; Decrement the number of bricks left, erase the brick, and if no
; more bricks, move to the next level
DEC_BRICKS_CHECK_LEVEL_DONE:
    call GIVE_BRICK_HIT_POINTS     ;ab7a   cd 04 96

	ld a,(BRICKS_LEFT)		;ab7d	3a 38 e0
	dec a			        ;ab80	3d
	ld (BRICKS_LEFT),a		;ab81	32 38 e0
	jr nz,ERASE_BRICK		    ;ab84	20 09

    ; BRICK_REPAINT_INITIAL
	xor a			            ;ab86	af
	ld (BRICK_REPAINT_TYPE),a	;ab87	32 22 e0

    ; Transition to the next level
	ld a,GAME_TRANSITION_ACTION_NEXT_LEVEL		;ab8a	3e 02
	ld (GAME_TRANSITION_ACTION),a		        ;ab8c	32 0a e0
    
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
	ld a,(BRICK_ROW)		;abad	3a aa e2
	and 3		            ;abb0	e6 03
	ld l,a			        ;abb2	6f
	ld h, 0		            ;abb3	26 00
    
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

; Check if the brick at (BRICK_ROW, BRICK_COL) is present and, if so,
; remove it.
CHECK_AND_REMOVE_BRICK:
    ; HL = 32*BRICK_ROW
	ld a,(BRICK_ROW)	;abd3	3a aa e2
	ld l,a			    ;abd6	6f
	ld h, 0		        ;abd7	26 00
	add hl,hl			;abd9	29
	add hl,hl			;abda	29
	add hl,hl			;abdb	29
	add hl,hl			;abdc	29
	add hl,hl			;abdd	29

    ; HL = BRICK_LEVEL_BITMASK + 32*BRICK_ROW
	ld de,BRICK_LEVEL_BITMASK		;abde	11 10 ac
	add hl,de			;abe1	19

    ; A = 2*BRICK_COL
	ld a,(BRICK_COL)	;abe2	3a ab e2
	sla a		        ;abe5	cb 27

    ; HL = BRICK_LEVEL_BITMASK + 32*BRICK_ROW + 2*BRICK_COL
    ld e,a			;abe7	5f
	ld d, 0		    ;abe8	16 00
	add hl,de		;abea	19
    
	; DE = BRICK_LEVEL_BITMASK[32*BRICK_ROW + 2*BRICK_COL]
    ld e,(hl)		;abeb	5e
	inc hl			;abec	23
	ld d,(hl)		;abed	56
    
    ; IY = BRICK_LEVEL_BITMASK[32*BRICK_ROW + 2*BRICK_COL]
	push de		;abee	d5
	pop iy		;abef	fd e1

    ; HL = 32*BRICK_ROW
	ld a,(BRICK_ROW)    ;abf1	3a aa e2
	ld l,a			    ;abf4	6f
	ld h, 0		        ;abf5	26 00
	add hl,hl		    ;abf7	29
	add hl,hl		    ;abf8	29
	add hl,hl		    ;abf9	29
	add hl,hl		    ;abfa	29
	add hl,hl		    ;abfb	29

    ; HL = BRICK_BIT_CHECK_JUMP_TABLE + 32*BRICK_ROW
	ld de,BRICK_BIT_CHECK_JUMP_TABLE	;abfc	11 01 ae
	add hl,de			                ;abff	19

    ; A = 2*BRICK_COL
	ld a,(BRICK_COL)	;ac00	3a ab e2
	sla a		        ;ac03	cb 27

    ; HL = BRICK_BIT_CHECK_JUMP_TABLE + 32*BRICK_ROW + 2*BRICK_COL
	ld e, a			;ac05	5f
	ld d, 0 		;ac06	16 00
	add hl,de		;ac08	19
    
    ; HL = BRICK_BIT_CHECK_JUMP_TABLE[32*BRICK_ROW + 2*BRICK_COL]
	ld e,(hl)		;ac09	5e
	inc hl			;ac0a	23
	ld d,(hl)		;ac0b	56
	ex de,hl		;ac0c	eb
    
    ; So finally we have:
    ;   IY = BRICK_LEVEL_BITMASK       [32*BRICK_ROW + 2*BRICK_COL]
    ;   HL = BRICK_BIT_CHECK_JUMP_TABLE[32*BRICK_ROW + 2*BRICK_COL]
    
    ; A = 0 ==> reset bit
    ; Jump to remove the brick from the bitmask
	ld a, 0		;ac0d	3e 00
	jp (hl)		;ac0f	e9


; This table is used to obtain the pointer IY to a specific brick in RAM.
; Each byte in RAM in a bitmask where a bit=1 means a brick present, anb bit=0 absent.
; The byte refers to a row of bricks.
; scripts$ ./dw_block.py ../arkanoid.rom --start 44048 --end 44431 --offset 16384
BRICK_LEVEL_BITMASK:
    dw BRICK_MAP, BRICK_MAP, BRICK_MAP, BRICK_MAP, BRICK_MAP, BRICK_MAP, BRICK_MAP, BRICK_MAP
    ; 0xac10 - 0xac1f
    dw BRICK_MAP+1, BRICK_MAP+1, BRICK_MAP+1, 0x0, 0x0, 0x0, 0x0, 0x0; 0xac20 - 0xac2f
    dw BRICK_MAP+1, BRICK_MAP+1, BRICK_MAP+1, BRICK_MAP+1, BRICK_MAP+1, BRICK_MAP+2, BRICK_MAP+2, BRICK_MAP+2; 0xac30 - 0xac3f
    dw BRICK_MAP+2, BRICK_MAP+2, BRICK_MAP+2, 0x0, 0x0, 0x0, 0x0, 0x0; 0xac40 - 0xac4f
    dw BRICK_MAP+2, BRICK_MAP+2, BRICK_MAP+3, BRICK_MAP+3, BRICK_MAP+3, BRICK_MAP+3, BRICK_MAP+3, BRICK_MAP+3; 0xac50 - 0xac5f
    dw BRICK_MAP+3, BRICK_MAP+3, BRICK_MAP+4, 0x0, 0x0, 0x0, 0x0, 0x0; 0xac60 - 0xac6f
    dw BRICK_MAP+4, BRICK_MAP+4, BRICK_MAP+4, BRICK_MAP+4, BRICK_MAP+4, BRICK_MAP+4, BRICK_MAP+4, BRICK_MAP+5; 0xac70 - 0xac7f
    dw BRICK_MAP+5, BRICK_MAP+5, BRICK_MAP+5, 0x0, 0x0, 0x0, 0x0, 0x0; 0xac80 - 0xac8f
    dw BRICK_MAP+5, BRICK_MAP+5, BRICK_MAP+5, BRICK_MAP+5, BRICK_MAP+6, BRICK_MAP+6, BRICK_MAP+6, BRICK_MAP+6; 0xac90 - 0xac9f
    dw BRICK_MAP+6, BRICK_MAP+6, BRICK_MAP+6, 0x0, 0x0, 0x0, 0x0, 0x0; 0xaca0 - 0xacaf
    dw BRICK_MAP+6, BRICK_MAP+7, BRICK_MAP+7, BRICK_MAP+7, BRICK_MAP+7, BRICK_MAP+7, BRICK_MAP+7, BRICK_MAP+7; 0xacb0 - 0xacbf
    dw BRICK_MAP+7, BRICK_MAP+8, BRICK_MAP+8, 0x0, 0x0, 0x0, 0x0, 0x0; 0xacc0 - 0xaccf
    dw BRICK_MAP+8, BRICK_MAP+8, BRICK_MAP+8, BRICK_MAP+8, BRICK_MAP+8, BRICK_MAP+8, BRICK_MAP+9, BRICK_MAP+9; 0xacd0 - 0xacdf
    dw BRICK_MAP+9, BRICK_MAP+9, BRICK_MAP+9, 0x0, 0x0, 0x0, 0x0, 0x0; 0xace0 - 0xacef
    dw BRICK_MAP+9, BRICK_MAP+9, BRICK_MAP+9, BRICK_MAP+10, BRICK_MAP+10, BRICK_MAP+10, BRICK_MAP+10, BRICK_MAP+10; 0xacf0 - 0xacff
    dw BRICK_MAP+10, BRICK_MAP+10, BRICK_MAP+10, 0x0, 0x0, 0x0, 0x0, 0x0; 0xad00 - 0xad0f
    dw BRICK_MAP+11, BRICK_MAP+11, BRICK_MAP+11, BRICK_MAP+11, BRICK_MAP+11, BRICK_MAP+11, BRICK_MAP+11, BRICK_MAP+11; 0xad10 - 0xad1f
    dw BRICK_MAP+12, BRICK_MAP+12, BRICK_MAP+12, 0x0, 0x0, 0x0, 0x0, 0x0; 0xad20 - 0xad2f
    dw BRICK_MAP+12, BRICK_MAP+12, BRICK_MAP+12, BRICK_MAP+12, BRICK_MAP+12, BRICK_MAP+13, BRICK_MAP+13, BRICK_MAP+13; 0xad30 - 0xad3f
    dw BRICK_MAP+13, BRICK_MAP+13, BRICK_MAP+13, 0x0, 0x0, 0x0, 0x0, 0x0; 0xad40 - 0xad4f
    dw BRICK_MAP+13, BRICK_MAP+13, BRICK_MAP+14, BRICK_MAP+14, BRICK_MAP+14, BRICK_MAP+14, BRICK_MAP+14, BRICK_MAP+14; 0xad50 - 0xad5f
    dw BRICK_MAP+14, BRICK_MAP+14, BRICK_MAP+15, 0x0, 0x0, 0x0, 0x0, 0x0; 0xad60 - 0xad6f
    dw BRICK_MAP+15, BRICK_MAP+15, BRICK_MAP+15, BRICK_MAP+15, BRICK_MAP+15, BRICK_MAP+15, BRICK_MAP+15, BRICK_MAP+16; 0xad70 - 0xad7f
    dw BRICK_MAP+16, BRICK_MAP+16, BRICK_MAP+16, 0x0, 0x0, 0x0, 0x0, 0x0; 0xad80 - 0xad8f

; The background pattern is 4x4-periodic.
; This table has pointers to the background characters to replace a
; brick with the background.
TABLE_BACKGROUND_ERASE:
    dw TABLE_BACKGROUND_ENTRY1
    dw TABLE_BACKGROUND_ENTRY2
    dw TABLE_BACKGROUND_ENTRY3
    dw TABLE_BACKGROUND_ENTRY4
;
TABLE_BACKGROUND_ENTRY1:
    db 0x7a, 0x7b, 0x78, 0x79
TABLE_BACKGROUND_ENTRY2:
    db 0x7e, 0x7f, 0x7c, 0x7d
TABLE_BACKGROUND_ENTRY3:
    db 0x72, 0x73, 0x70, 0x71
TABLE_BACKGROUND_ENTRY4:
    db 0x76, 0x77, 0x74, 0x75

; Check if there's a brick in [BRICK_COL, BRICK_ROW]
; Result in carry
BRICK_EXISTS_AT_ROWCOL:
	push iy		;ada8	fd e5

	ld a,0		        ;adaa	3e 00
	ld (DOH_BEEN_HIT),a		;adac	32 b9 e2
    
    ; A <- BRICK_ROW
    ; If A < 11 then A = 11
	ld a,(BRICK_ROW)		;adaf	3a aa e2
	cp 12		            ;adb2	fe 0c
	jp c,ladb9h		        ;adb4	da b9 ad
	ld a, 11		        ;adb7	3e 0b
ladb9h:
    ; HL = 32*BRICK_ROW
	ld l,a			        ;adb9	6f
	ld h,000h		        ;adba	26 00
	add hl,hl			    ;adbc	29
	add hl,hl			    ;adbd	29
	add hl,hl			    ;adbe	29
	add hl,hl			    ;adbf	29
	add hl,hl			    ;adc0	29

    ; HL = BRICK_LEVEL_BITMASK + 32*BRICK_ROW
	ld de,BRICK_LEVEL_BITMASK		;adc1	11 10 ac
	add hl,de			;adc4	19

    ; A = 2*BRICK_COL
	ld a,(BRICK_COL)	;adc5	3a ab e2
	sla a		        ;adc8	cb 27

	; HL = BRICK_LEVEL_BITMASK + 32*BRICK_ROW * 2*BRICK_COL
    ld e,a			;adca	5f
	ld d,000h		;adcb	16 00   DE = 2*BRICK_COL
	add hl,de		;adcd	19

    ; DE = BRICK_LEVEL_BITMASK[32*BRICK_ROW * 2*BRICK_COL]
	ld e,(hl)		;adce	5e
	inc hl			;adcf	23
	ld d,(hl)		;add0	56

    ; IY = BRICK_LEVEL_BITMASK[32*BRICK_ROW * 2*BRICK_COL]
	push de		;add1	d5
	pop iy		;add2	fd e1

    ; A <- BRICK_ROW
    ; If A < 11 then A = 11
	ld a,(BRICK_ROW)		;add4	3a aa e2
	cp 12		            ;add7	fe 0c
	jp c,laddeh		        ;add9	da de ad
	ld a, 11		        ;addc	3e 0b
laddeh:
    ; HL = 32*BRICK_ROW
	ld l,a			;adde	6f
	ld h,000h		;addf	26 00
	add hl,hl		;ade1	29
	add hl,hl		;ade2	29
	add hl,hl		;ade3	29
	add hl,hl		;ade4	29
	add hl,hl		;ade5	29

    ; HL = BRICK_BIT_CHECK_JUMP_TABLE + 32*BRICK_ROW
	ld de,BRICK_BIT_CHECK_JUMP_TABLE		;ade6	11 01 ae 	. . . 
	add hl,de			;ade9	19 	. 

    ; A = BRICK_COL
    ; If A < 10 then A = 10
	ld a,(BRICK_COL)	;adea	3a ab e2
	cp 11		        ;aded	fe 0b
	jp c,ladf4h		    ;adef	da f4 ad
	ld a, 10		    ;adf2	3e 0a
ladf4h:
	sla a		    ;adf4	cb 27   A = 2*BRICK_COL
    
    ; HL = BRICK_BIT_CHECK_JUMP_TABLE + 32*BRICK_ROW + 2*BRICK_COL
	ld e, a		;adf6	5f
	ld d, 0		;adf7	16 00
	add hl,de	;adf9	19

	; DE = BRICK_BIT_CHECK_JUMP_TABLE[32*BRICK_ROW + 2*BRICK_COL]
    ld e,(hl)		;adfa	5e
	inc hl			;adfb	23
	ld d,(hl)		;adfc	56
    
    ; HL = BRICK_BIT_CHECK_JUMP_TABLE[32*BRICK_ROW + 2*BRICK_COL]
	ex de,hl		;adfd	eb
    
    ; Jump to BRICK_BIT_CHECK_JUMP_TABLE[32*BRICK_ROW + 2*BRICK_COL]
    ; A = 1 ==> Check bit
	ld a, 1		;adfe	3e 01
	jp (hl)		;ae00	e9

; This is a jump table to check if a brick pointed by position IY is present.
; scripts$ ./dw_block.py ../arkanoid.rom --start 44545 --end 44950 --offset 16384
BRICK_BIT_CHECK_JUMP_TABLE:
    dw br_b7, br_b6, br_b5, br_b4, br_b3, br_b2, br_b1, br_b0; 0xae01 - 0xae10
    dw br_b7, br_b6, br_b5, br_b7, br_b7, br_b7, br_b7, br_b7; 0xae11 - 0xae20
    dw br_b4, br_b3, br_b2, br_b1, br_b0, br_b7, br_b6, br_b5; 0xae21 - 0xae30
    dw br_b4, br_b3, br_b2, br_b7, br_b7, br_b7, br_b7, br_b7; 0xae31 - 0xae40
    dw br_b1, br_b0, br_b7, br_b6, br_b5, br_b4, br_b3, br_b2; 0xae41 - 0xae50
    dw br_b1, br_b0, br_b7, br_b7, br_b7, br_b7, br_b7, br_b7; 0xae51 - 0xae60
    dw br_b6, br_b5, br_b4, br_b3, br_b2, br_b1, br_b0, br_b7; 0xae61 - 0xae70
    dw br_b6, br_b5, br_b4, br_b7, br_b7, br_b7, br_b7, br_b7; 0xae71 - 0xae80
    dw br_b3, br_b2, br_b1, br_b0, br_b7, br_b6, br_b5, br_b4; 0xae81 - 0xae90
    dw br_b3, br_b2, br_b1, br_b7, br_b7, br_b7, br_b7, br_b7; 0xae91 - 0xaea0
    dw br_b0, br_b7, br_b6, br_b5, br_b4, br_b3, br_b2, br_b1; 0xaea1 - 0xaeb0
    dw br_b0, br_b7, br_b6, br_b7, br_b7, br_b7, br_b7, br_b7; 0xaeb1 - 0xaec0
    dw br_b5, br_b4, br_b3, br_b2, br_b1, br_b0, br_b7, br_b6; 0xaec1 - 0xaed0
    dw br_b5, br_b4, br_b3, br_b7, br_b7, br_b7, br_b7, br_b7; 0xaed1 - 0xaee0
    dw br_b2, br_b1, br_b0, br_b7, br_b6, br_b5, br_b4, br_b3; 0xaee1 - 0xaef0
    dw br_b2, br_b1, br_b0, br_b7, br_b7, br_b7, br_b7, br_b7; 0xaef1 - 0xaf00
    dw br_b7, br_b6, br_b5, br_b4, br_b3, br_b2, br_b1, br_b0; 0xaf01 - 0xaf10
    dw br_b7, br_b6, br_b5, br_b7, br_b7, br_b7, br_b7, br_b7; 0xaf11 - 0xaf20
    dw br_b4, br_b3, br_b2, br_b1, br_b0, br_b7, br_b6, br_b5; 0xaf21 - 0xaf30
    dw br_b4, br_b3, br_b2, br_b7, br_b7, br_b7, br_b7, br_b7; 0xaf31 - 0xaf40
    dw br_b1, br_b0, br_b7, br_b6, br_b5, br_b4, br_b3, br_b2; 0xaf41 - 0xaf50
    dw br_b1, br_b0, br_b7, br_b7, br_b7, br_b7, br_b7, br_b7; 0xaf51 - 0xaf60
    dw br_b6, br_b5, br_b4, br_b3, br_b2, br_b1, br_b0, br_b7; 0xaf61 - 0xaf70
    dw br_b6, br_b5, br_b4, br_b7, br_b7, br_b7, br_b7, br_b7; 0xaf71 - 0xaf80

; Bit 7
br_b7:
	cp 001h		    ;af81	fe 01
	jp z,laf8bh		;af83	ca 8b af
	res 7,(iy+000h)	;af86	fd cb 00 be
	ret			    ;af8a	c9
laf8bh:
	bit 7,(iy+000h)	;af8b	fd cb 00 7e
	jp lb000h		;af8f	c3 00 b0

; Bit 6
br_b6:
	cp 001h		    ;af92	fe 01
	jp z,laf9ch		;af94	ca 9c af
	res 6,(iy+000h)	;af97	fd cb 00 b6
	ret			    ;af9b	c9
laf9ch:
	bit 6,(iy+000h)	;af9c	fd cb 00 76
	jr lb000h		;afa0	18 5e

; Bit 5
br_b5:
	cp 001h		    ;afa2	fe 01
	jp z,lafach		;afa4	ca ac af
	res 5,(iy+000h)	;afa7	fd cb 00 ae
	ret			    ;afab	c9
lafach:
	bit 5,(iy+000h)	;afac	fd cb 00 6e
	jr lb000h		;afb0	18 4e

; Bit 4
br_b4:
	cp 001h		    ;afb2	fe 01
	jp z,lafbch		;afb4	ca bc af
	res 4,(iy+000h)	;afb7	fd cb 00 a6
	ret			    ;afbb	c9
lafbch:
	bit 4,(iy+000h)	;afbc	fd cb 00 66
	jr lb000h		;afc0	18 3e

; Bit 3
br_b3:
	cp 001h		    ;afc2	fe 01
	jp z,lafcch		;afc4	ca cc af
	res 3,(iy+000h)	;afc7	fd cb 00 9e
	ret			    ;afcb	c9
lafcch:
	bit 3,(iy+000h)	;afcc	fd cb 00 5e
	jr lb000h		;afd0	18 2e

; Bit 2
br_b2:
	cp 001h		    ;afd2	fe 01
	jp z,lafdch		;afd4	ca dc af
	res 2,(iy+000h)	;afd7	fd cb 00 96
	ret			    ;afdb	c9
lafdch:
	bit 2,(iy+000h)	;afdc	fd cb 00 56. V 
	jr lb000h		;afe0	18 1e

; Bit 1
br_b1:
	cp 001h		    ;afe2	fe 01
	jp z,lafech		;afe4	ca ec af
	res 1,(iy+000h)	;afe7	fd cb 00 8e
	ret			    ;afeb	c9
lafech:
	bit 1,(iy+000h)	;afec	fd cb 00 4e. N 
	jr lb000h		;aff0	18 0e

; Bit 0
br_b0:
	cp 001h		    ;aff2	fe 01
	jp z,laffch		;aff4	ca fc af
	res 0,(iy+000h)	;aff7	fd cb 00 86
	ret			    ;affb	c9
laffch:
	bit 0,(iy+000h)	;affc	fd cb 00 46 	

lb000h:
	pop iy		        ;b000	fd e1
	ld hl,DOH_BEEN_HIT	;b002	21 b9 e2
	ld (hl),0		    ;b005	36 00
	jr z,lb00dh		    ;b007	28 04
	ld (hl),001h		;b009	36 01
	scf			        ;b00b	37      Set CARRY
	ret			        ;b00c	c9
lb00dh:
	xor a		        ;b00d	af      Clear CARRY
	ret			        ;b00e	c9

; Set a random capsule type if there are not extra balls.
; This is the function that prevents falling capsules when
; you're playing with several balls.
SET_RANDOM_CAPSULE_IF_NO_EXTRA_BALLS:
	push ix		            ;b00f	dd e5
	push iy		            ;b011	fd e5
	push hl			        ;b013	e5
	push de			        ;b014	d5
	push bc			        ;b015	c5
	ld a,(EXTRA_BALLS)		;b016	3a 25 e3
	or a			        ;b019	b7
	jp nz,lb020h		    ;b01a	c2 20 b0
	call SET_PROPER_RANDOM_CAPSULE_TYPE		;b01d	cd 28 b0
lb020h:
	pop bc		;b020
	pop de		;b021
	pop hl		;b022
	pop iy		;b023	fd e1
	pop ix		;b025	dd e1
	ret			;b027	c9

; Set a random capsule type, without choosing the type we
; already have.
SET_PROPER_RANDOM_CAPSULE_TYPE:
    ; Capsules won't fall if there are less than 4 bricks remaining
	ld a,(BRICKS_LEFT)		;b028	3a 38 e0
	cp 4		            ;b02b	fe 04
	ret c			        ;b02d	d8

	ld ix,CAPSULE_IS_FALLING		    ;b02e	dd 21 17 e3
	ld iy,FALLING_CAPSULE_SPR_PARAMS	;b032	fd 21 c9 e0
    
    ; Exit if the capsule is already falling
	ld a,(CAPSULE_IS_FALLING)		    ;b036	3a 17 e3
	or a			                    ;b039	b7
	ret nz			                    ;b03a	c0

	; Set the capsule is falling
    ld (ix+000h), 1		                ;b03b	dd 36 00 01

    ; Set a random capsule type.
    ; C if the capsule is magenta (open portal)
	call SET_RANDOM_CAPSULE_TYPE		;b03f	cd dd b0
	jp c,lb073h		                    ;b042	da 73 b0    Done if magenta brick

	call DECIDE_BRICK_IS_LIFE		     ;b045	cd 0a b1
	jp c,lb073h		                    ;b048	da 73 b0    Done if it's a live 

	ld a,(GLUING_STATUS)		;b04b	3a 24 e3
	cp GLUING_STATE_STICKY		;b04e	fe 01
	jr z,lb063h		            ;b050	28 11

	ld a,(VAUS_IS_ENLARGED)		;b052	3a 21 e3
	or a			            ;b055	b7
	jr nz,lb068h		        ;b056	20 10

	ld a,(VAUS_HAS_LASERS)		;b058	3a 22 e3
	or a			            ;b05b	b7
	jr nz,lb06dh		        ;b05c	20 0f

    ; We choose a table without the type we already have, to choose a
    ; random type from it.
	ld hl,TBL_FALLING_CAPSULE_TYPES_1		;b05e	21 bd b0
	jr lb070h		                        ;b061	18 0d
lb063h:
	ld hl,TBL_FALLING_CAPSULE_TYPES_2		;b063	21 c5 b0
	jr lb070h		                        ;b066	18 08
lb068h:
	ld hl,TBL_FALLING_CAPSULE_TYPES_3		;b068	21 cd b0
	jr lb070h		                        ;b06b	18 03
lb06dh:
	ld hl,TBL_FALLING_CAPSULE_TYPES_4		;b06d	21 d5 b0
lb070h:
	call SET_RANDOM_FALLING_CAPSULE		    ;b070	cd ad b0
lb073h:
    ; L = 8*BRICK_ROW + 24, Y coordinate
	ld a,(BRICK_ROW)		;b073	3a aa e2
	sla a		            ;b076	cb 27
	sla a		            ;b078	cb 27
	sla a		            ;b07a	cb 27
	add a, 24		        ;b07c	c6 18
	ld l,a			        ;b07e	6f
    
    ; H = 16*BRICK_COL + 16, X coordinate
	ld a,(BRICK_COL)		;b07f	3a ab e2
	sla a		            ;b082	cb 27
	sla a		            ;b084	cb 27
	sla a		            ;b086	cb 27
	sla a		            ;b088	cb 27
	add a, 16   		    ;b08a	c6 10
	ld h,a		        	;b08c	67
    
    ; IY is FALLING_CAPSULE_SPR_PARAMS
    ; IX is CAPSULE_IS_FALLING

	ld (iy+SPR_PARAMS_IDX_Y),l		        ;b08d	fd 75 00     8 * BRICK_ROW + 24
	ld (iy+SPR_PARAMS_IDX_X),h		        ;b090	fd 74 01    16 * BRICK_COL + 16
	ld (iy+SPR_PARAMS_IDX_PATTERN_NUM), 136	;b093	fd 36 02 88 Brick

	; HL = CAPSULE_TYPE
    ld l,(ix+001h)		;b097	dd 6e 01
	ld h, 0		        ;b09a	26 00
    
    ; Translate capsule type to color
	ld de,TBL_CAPSULE_TYPE_TO_COLOR		;b09c	11 a5 b0
	add hl,de			                ;b09f	19
	ld a,(hl)			                ;b0a0	7e
    
    ; Set color of the falling brick
	ld (iy+SPR_PARAMS_IDX_COLOR),a		;b0a1	fd 77 03
	ret			                        ;b0a4	c9

TBL_CAPSULE_TYPE_TO_COLOR:              ;b0a5
    db 10, 3, 5, 7, 8, 13, 14, 5

; Set the falling capsule to a type between 0 and 7
SET_RANDOM_FALLING_CAPSULE:
	ld a,r		    ;b0ad	ed 5f
	add a,c			;b0af	81
	add a,b			;b0b0	80
	add a,e			;b0b1	83
	and 7   		;b0b2	e6 07
    
    ; DE = random
	ld e,a		;b0b4	5f
	ld d, 0		;b0b5	16 00
	
    ; HL points to any of the TBL_FALLING_CAPSULE_TYPES_2_x
    ; HL = HL + random
    add hl,de			;b0b7	19
    
    ; A = HL[random]
	ld a,(hl)			;b0b8	7e

    ; (ix+001h) <-- HL[random]
    ; Set CAPSULE_TYPE to random
	ld (ix+001h),a		;b0b9	dd 77 01; This points to CAPSULE_TYPE, at 0xe318.
	ret			        ;b0bc	c9

; We choose randomly from these
TBL_FALLING_CAPSULE_TYPES_1:
    db 0, 1, 2, 3, 4, 1, 3, 2   ; All numbers
TBL_FALLING_CAPSULE_TYPES_2:
    db 0, 2, 3, 4, 2, 4, 0, 3   ; No 1
TBL_FALLING_CAPSULE_TYPES_3:
    db 0, 1, 3, 4, 1, 4, 3, 0   ; No 2
TBL_FALLING_CAPSULE_TYPES_4:
    db 0, 1, 2, 3, 1, 3, 0, 2   ; No 4

; Set a random type to the falling capsule.
; Return in C if it's the magenta brick.
SET_RANDOM_CAPSULE_TYPE:
    ; Exit if the portal is open
	ld a,(PORTAL_OPEN)		;b0dd	3a 26 e3
	or a			        ;b0e0	b7
	ret nz			        ;b0e1	c0

    ; A = CAPSULES_LEFT
	ld hl,CAPSULES_LEFT		;b0e2	21 23 e0
	ld a,(hl)			    ;b0e5	7e

    ; Skip if no more capsules left
	or a			        ;b0e6	b7
	jr nz,lb0f7h		    ;b0e7	20 0e

    ; A = random number in [0, 31]
	ld a,r		    ;b0e9	ed 5f
	add a,c			;b0eb	81
	add a,b			;b0ec	80
	and 01fh		;b0ed	e6 1f

    ; Set the number capsule number
	ld (CAPSULES_RANDOM_NUM),a	;b0ef	32 24 e0

    ; Default value of 33 capsules available
	ld a, 33		            ;b0f2	3e 21
	ld (CAPSULES_LEFT),a		;b0f4	32 23 e0
lb0f7h:
    ; Decrease CAPSULES_LEFT
	dec (hl)			        ;b0f7	35 	5 
    
    ; Jump if the random number happens to be zero
	ld hl,CAPSULES_RANDOM_NUM		;b0f8	21 24 e0
	ld a,(hl)			            ;b0fb	7e
	or a			                ;b0fc	b7
	jr z,lb102h		                ;b0fd	28 03
	
    ; Decrease CAPSULES_LEFT and return NC
    dec (hl)			            ;b0ff	35
	xor a			                ;b100	af
	ret			                    ;b101	c9

lb102h:
    ; IX+1 points to CAPSULE_TYPE
    ; Set it to the magenta type
	ld (ix+001h), 5h		;b102	dd 36 01 05
    ; Set CAPSULES_LEFT to 255
	ld (hl), 255		    ;b106	36 ff
    ; Return C
	scf			            ;b108	37
	ret			            ;b109	c9
    
; Check if the falling brick is a life.
; If so, check a counter (initilized randomly) to decide if we
; give the life or not. Lives are scarce!
DECIDE_BRICK_IS_LIFE:
    ; Skip if the brick is not a life
	ld a,(LIFE_OBTAINED_FLAG)		;b10a	3a 27 e3
	or a			                ;b10d	b7
	ret nz			                ;b10e	c0

	; Skip if capsule live's counter isn't 0
    ld hl,CAPSULE_LIVES_COUNTER_L		;b10f	21 25 e0
	ld a,(hl)			                ;b112	7e
	or a			                    ;b113	b7
	jr nz,lb124h		                ;b114	20 0e
    
    ; A = random number between 0 and 31
	ld a,r		    ;b116	ed 5f
	add a,e			;b118	83
	add a,d			;b119	82
	and 01fh		;b11a	e6 1f

    ; Write random number to the counter
	ld (CAPSULE_LIVES_COUNTER_H),a		;b11c	32 26 e0
    ld a, 0x32		                    ;b11f	3e 32
	ld (CAPSULE_LIVES_COUNTER_L),a		;b121	32 25 e0
    
lb124h:
    ; Dec and check counter
	dec (hl)			            ;b124	35
    ld hl,CAPSULE_LIVES_COUNTER_H	;b125	21 26 e0
	ld a,(hl)			            ;b128	7e
	or a			                ;b129	b7
	jr z,lb12fh		                ;b12a	28 03
    
	dec (hl)			            ;b12c	35
    
    ; Clear carry and exit
    ; It won't be a life
	xor a			                ;b12d	af
	ret			                    ;b12e	c9

lb12fh:
    ; IX+1 points to CAPSULE_TYPE
    ; Set it to a life!
	ld (ix+001h), 6		    ;b12f	dd 36 01 06
	ld (hl), 255		    ;b133	36 ff   Reset countdown
    
    ; Set carry and exit
	scf			        ;b135	37
	ret			        ;b136	c9

; Move the falling capsule one step down
CAPSULE_MOVE_DOWN_STEP:
    ; Skip if we're at the final level
	ld a,(LEVEL)		;b137	3a 1b e0
	cp FINAL_LEVEL		;b13a	fe 20
	ret z			    ;b13c	c8

    ; Skip if there's no capsule falling
	ld ix,CAPSULE_IS_FALLING	        ;b13d	dd 21 17 e3
	ld iy,FALLING_CAPSULE_SPR_PARAMS	;b141	fd 21 c9 e0
	ld a,(ix+000h)		                ;b145	dd 7e 00
	or a			                    ;b148	b7
	ret z			                    ;b149	c8

    ; Move capsule one step down
	inc (iy+SPR_PARAMS_IDX_Y)		;b14a	fd 34 00
    
    ; Exit if it's less than 188
	ld a,(iy+SPR_PARAMS_IDX_Y)		;b14d	fd 7e 00
	cp 188		                    ;b150	fe bc
	ret c			                ;b152	d8
    
    ; It's more than 188: make it disappear

    ; No capsule falling
	ld (ix+0), 0		            ;b153	dd 36 00 00
	ld (iy+SPR_PARAMS_IDX_Y), 192	;b157	fd 36 00 c0
	ret			                    ;b15b	c9

; Check if Vaus has captured a falling capsule, and execute the
; corresponding action in that case.
CHECK_CAPSULE_CATCHED_AND_EXEC_ACTION:
    ; Skip if we're in the final level
	ld a,(LEVEL)		;b15c	3a 1b e0
	cp FINAL_LEVEL		;b15f	fe 20
	ret z			    ;b161	c8
    
    ; Skip if Vaus is exploding
	ld a,(VAUS_TABLE + VAUS_TABLE_IDX_ACTION_STATE)		;b162	3a 4b e5
	cp VAUS_ACTION_STATE_EXPLODING	                    ;b165	fe 06
	ret z			                                    ;b167	c8

    ; Point to the falling capsule and to Vaus spr. params.
    ld ix,FALLING_CAPSULE_SPR_PARAMS		;b168	dd 21 c9 e0
	ld iy,SPR_PARAMS_BASE		            ;b16c	fd 21 cd e0

    ; Exit if the falling capsule height's is less than 168
	ld a,(ix+SPR_PARAMS_IDX_Y)		        ;b170	dd 7e 00
	cp 168		                            ;b173	fe a8
	ret c			                        ;b175	d8

    ; Exit if the falling capsule height's is more than 184
	cp 184		    ;b176	fe b8
	ret nc			;b178	d0
    
    ; The capsule's height is between 168 and 184    
    
    ; Exit if the capsule's X is smaller than Vaus' X
	ld a,(iy+SPR_PARAMS_IDX_X)		;b179	fd 7e 01
	cp (ix+SPR_PARAMS_IDX_X)		;b17c	dd be 01
	ret nc			                ;b17f	d0
    
    ; Depending on whether Vaus is enlarged or not, set C=48 or C=32.
	ld c, 32		            ;b180	0e 20
	ld a,(VAUS_IS_ENLARGED)		;b182	3a 21 e3
	or a			            ;b185	b7
	jp z,lb18bh		            ;b186	ca 8b b1
	ld c, 48		            ;b189	0e 30

lb18bh:
    ;  Exit if the capsule's X is larger than Vaus' X
	ld a,(iy+SPR_PARAMS_IDX_X)		;b18b	fd 7e 01
	add a,c			                ;b18e	81
	cp (ix+SPR_PARAMS_IDX_X)		;b18f	dd be 01
	ret c			                ;b192	d8
    
    ; At this point Vaus is touching the capsule
    
	; Remove the capsule, which has been catched
    ld (ix+SPR_PARAMS_IDX_Y), 192	        ;b193	dd 36 00 c0
    ld (ix+SPR_PARAMS_IDX_PATTERN_NUM),0	;b197	dd 36 02 00

    ; Add points
	ld a, 11		                        ;b19b	3e 0b    
	call ADD_POINTS_AND_UPDATE_SCORES		;b19d	cd a0 52

    ; Execute the corresponding action
	call EXECUTE_CAPSULE_ACTION		;b1a0	cd a8 b1
    
    ; No capsule falling
	xor a			                ;b1a3	af
	ld (CAPSULE_IS_FALLING),a		;b1a4	32 17 e3
	ret			                    ;b1a7	c9

; Execute the corresponding action when catching a falling capsule
EXECUTE_CAPSULE_ACTION:
    ; Skip if the capsule is not falling
	ld a,(CAPSULE_IS_FALLING)		;b1a8	3a 17 e3
	or a			                ;b1ab	b7
	ret z			                ;b1ac	c8
    
    ; Clear memory (3 bytes)
	ld hl,0e320h		        ;b1ad	21 20 e3
	ld de,VAUS_IS_ENLARGED		;b1b0	11 21 e3
	ld (hl),000h		        ;b1b3	36 00
	ld bc, 3		            ;b1b5	01 03 00
	ldir		                ;b1b8	ed b0

    ; Obtain the pointer to the capsule action table
	ld a,(CAPSULE_TYPE)		;b1ba	3a 18 e3
	rlca			        ;b1bd	07
	ld e,a			        ;b1be	5f
	ld d, 0		            ;b1bf	16 00
    
	ld hl,CAPSULE_ACTION_TABLE		;b1c1	21 ca b1
	add hl,de			            ;b1c4	19

    ; DE = CAPSULE_ACTION_TABLE[2*CAPSULE_TYPE]
	ld e,(hl)			;b1c5	5e
	inc hl			    ;b1c6	23
	ld d,(hl)			;b1c7	56
	ex de,hl			;b1c8	eb
    
    ; Execute the action
	jp (hl)			;b1c9	e9 	. 

; Jump table for the actions of each of the bricks you get
CAPSULE_ACTION_TABLE:
    dw CAPSULE_ACTION_YELLOW          ; 0xb1da
    dw CAPSULE_ACTION_GREEN           ; 0xb215
    dw CAPSULE_ACTION_BLUE            ; 0xb21e
    dw CAPSULE_ACTION_LIGHT_BLUE      ; 0xb23b
    dw CAPSULE_ACTION_LIGHT_RED       ; 0xb253
    dw CAPSULE_ACTION_LIGHT_MAGENTA   ; 0xb271
    dw CAPSULE_ACTION_GRAY            ; 0xb286    
    dw CAPSULE_ACTION_BLUE            ; 0xb21e

; Decrement the speed of all balls
CAPSULE_ACTION_YELLOW:
    ; Skip if Vaus is not sticky
	ld a,(GLUING_STATUS)	;b1da	3a 24 e3
	or a			        ;b1dd	b7
	jp z,lb1e6h		        ;b1de	ca e6 b1

    ; Vaus is sticky, set GLUING_STATE_NO_LONGER_STICKY
	ld a,GLUING_STATE_NO_LONGER_STICKY		;b1e1	3e 02
	ld (GLUING_STATUS),a		            ;b1e3	32 24 e3
lb1e6h:
	; The variable at 0e320h seems to be useless since it's only reset
    ld a, 1		                    ;b1e6	3e 01
	ld (0e320h),a		            ;b1e8	32 20 e3
    
	call VAUS_GET_NORMAL_STATE		;b1eb	cd a7 b2
    
    ; Loop over 3 balls
	ld b,3		                ;b1ee	06 03
	ld de,BALL_TABLE_LEN		;b1f0	11 14 00
	ld iy,BALL_TABLE1		    ;b1f3	fd 21 4e e2
lb1f7h:
    ; Process if the ball is active
	ld a,(iy+BALL_TABLE_IDX_ACTIVE)		;b1f7	fd 7e 00
	or a			                    ;b1fa	b7
	jp nz,lb203h	                    ;b1fb	c2 03 b2
    
    ; Next ball
	add iy,de		;b1fe	fd 19
	djnz lb1f7h		;b200	10 f5
	ret			    ;b202	c9
lb203h:
	ld (iy+BALL_TABLE_IDX_SPEED_COUNTER), 0		;b203	fd 36 0d 00
    
    ; Decrement ball speed
	ld a,(iy+BALL_TABLE_IDX_SPEED_POS)		    ;b207	fd 7e 07
	sub 1		                                ;b20a	d6 01
	ld (iy+BALL_TABLE_IDX_SPEED_POS),a		    ;b20c	fd 77 07

	ret nc			                            ;b20f	d0
    ; Reset the speed pos if speed below zero
	ld (iy+BALL_TABLE_IDX_SPEED_POS), 0 		;b210	fd 36 07 00
	ret			                                ;b214	c9

; Set Vaus sticky
CAPSULE_ACTION_GREEN:
	ld a,GLUING_STATE_STICKY	    ;b215	3e 01
	ld (GLUING_STATUS),a		    ;b217	32 24 e3
	call VAUS_GET_NORMAL_STATE		;b21a	cd a7 b2
	ret			                    ;b21d	c9

; Enlarge Vaus
CAPSULE_ACTION_BLUE:
    ; Skip if Vaus is not sticky
	ld a,(GLUING_STATUS)		;b21e	3a 24 e3
	or a			            ;b221	b7
	jp z,lb22ah		            ;b222	ca 2a b2
    
    ; Set GLUING_STATE_NO_LONGER_STICKY
	ld a,GLUING_STATE_NO_LONGER_STICKY		;b225	3e 02
	ld (GLUING_STATUS),a		            ;b227	32 24 e3
lb22ah:
	call VAUS_GET_NORMAL_STATE		        ;b22a	cd a7 b2
    
    ; Set Vaus is enlarging
	ld a,VAUS_ACTION_STATE_ENLARGING	                ;b22d	3e 02
	ld (VAUS_TABLE + VAUS_TABLE_IDX_ACTION_STATE),a		;b22f	32 4b e5
	ld (VAUS_IS_ENLARGED),a		                        ;b232	32 21 e3

    ; Play enlarging sound
	ld a,SOUND_VAUS_INCREASES_SIZE_H	;b235	3e c0
	call ADD_SOUND		                ;b237	cd ef 5b
	ret			                        ;b23a	c9

; Play with 3 balls
CAPSULE_ACTION_LIGHT_BLUE:
    ; Skip if Vaus is not sticky
	ld a,(GLUING_STATUS)		        ;b23b	3a 24 e3
	or a			                    ;b23e	b7
	jp z,lb247h		                    ;b23f	ca 47 b2
    
    ; Set GLUING_STATE_NO_LONGER_STICKY
	ld a,GLUING_STATE_NO_LONGER_STICKY	;b242	3e 02
	ld (GLUING_STATUS),a		        ;b244	32 24 e3
lb247h:
    ; We have catched the blue (3 balls) capsule.
    ; Set we have two extra balls now, get back to the normal size, and
    ; set the skewness for each of the three balls.
	ld a, 2		                ;b247	3e 02
	ld (EXTRA_BALLS),a		    ;b249	32 25 e3
	call VAUS_GET_NORMAL_STATE	;b24c	cd a7 b2
	call SET_THREE_BALLS_SKEWNESS		        ;b24f	cd c1 b2
	ret			                ;b252	c9
    
; Obtain lasers
CAPSULE_ACTION_LIGHT_RED:
    ; Skip if Vaus is not sticky
	ld a,(GLUING_STATUS)		;b253	3a 24 e3
	or a			            ;b256	b7
	jp z,lb25fh		            ;b257	ca 5f b2
    ; Set GLUING_STATE_NO_LONGER_STICKY
	ld a,GLUING_STATE_NO_LONGER_STICKY  ;b25a	3e 02
	ld (GLUING_STATUS),a		        ;b25c	32 24 e3
lb25fh:
	call VAUS_GET_NORMAL_STATE		    ;b25f	cd a7 b2
    
    ; Set Vaus is obtaining lasers
	ld a,VAUS_ACTION_STATE_LASER	                    ;b262	3e 04
	ld (VAUS_TABLE + VAUS_TABLE_IDX_ACTION_STATE),a		;b264	32 4b e5

	ld a, 1		                ;b267	3e 01
	ld (VAUS_HAS_LASERS),a		;b269	32 22 e3

	xor a			                    ;b26c	af
	ld (SPEEDUP_ALL_BALLS_COUNTER),a	;b26d	32 29 e5

	ret			                        ;b270	c9

; Open the portal
CAPSULE_ACTION_LIGHT_MAGENTA:
    ; Skip if Vaus is not sticky
	ld a,(GLUING_STATUS)		;b271	3a 24 e3
	or a			            ;b274	b7
	jp z,lb27dh		            ;b275	ca 7d b2
    ; Set not sticky
	ld a,GLUING_STATE_NO_LONGER_STICKY  ;b278	3e 02
	ld (GLUING_STATUS),a		        ;b27a	32 24 e3
lb27dh:
    ; We have catched the magenta capsule.
    ; Open the portal and get back to the normal size state.
	ld a, 1		            ;b27d	3e 01
	ld (PORTAL_OPEN),a		;b27f	32 26 e3
    
	call VAUS_GET_NORMAL_STATE  ;b282	cd a7 b2
	ret			                ;b285	c9 	. 

; Get a life!
CAPSULE_ACTION_GRAY:
    ; Skip if Vaus is not sticky
	ld a,(GLUING_STATUS)		;b286	3a 24 e3
	or a			            ;b289	b7
	jp z,lb292h		            ;b28a	ca 92 b2
    ; Set GLUING_STATE_NO_LONGER_STICKY
	ld a,GLUING_STATE_NO_LONGER_STICKY		;b28d	3e 02
	ld (GLUING_STATUS),a		            ;b28f	32 24 e3
lb292h:
	call VAUS_GET_NORMAL_STATE		;b292	cd a7 b2

	ld a,1		                    ;b295	3e 01
	ld (LIFE_OBTAINED_FLAG),a		;b297	32 27 e3
    
    ; Increment number of lives and draw them
	ld hl,LIVES		    ;b29a	21 1d e0
	inc (hl)			;b29d	34
	call DRAW_LIVES		;b29e	cd b9 71

    ; Play live sound
	ld a,SOUND_LIFE		;b2a1	3e c5
	call ADD_SOUND		;b2a3	cd ef 5b
	ret			        ;b2a6	c9

; Get Vaus back to normal state: not enlarged, no lasers
VAUS_GET_NORMAL_STATE:
	ld a,(VAUS_TABLE + VAUS_TABLE_IDX_RESIZING)   ;b2a7	3a 50 e5

	cp VAUS_ACTION_STATE_ENLARGING		;b2aa	fe 02
	jr nz,lb2b2h		                ;b2ac	20 04
    ; Vaus is enlarged, so make it normal size
	ld a,VAUS_ACTION_STATE_SHRINKING	;b2ae	3e 03
	jr lb2bdh		                    ;b2b0	18 0b
lb2b2h:
    ; Vaus is not large
    
    ; Is is enlarging? Is so, just exit
	or a			;b2b2	b7
	jr nz,lb2c0h	;b2b3	20 0b
    
    ; Vaus is at normal size. Check if it's got lasers
    ld a,(VAUS_TABLE + VAUS_TABLE_IDX_HAS_LASER)        ;b2b5	3a 51 e5
	or a			                                    ;b2b8	b7
	jr z,lb2c0h		                                    ;b2b9	28 05   No lasers, just exit
    
    ; It's got lasers: remove them
	ld a,VAUS_ACTION_STATE_UNLASER	                    ;b2bb	3e 05
lb2bdh:
    ; Set Vaus action state
	ld (VAUS_TABLE + VAUS_TABLE_IDX_ACTION_STATE),a		;b2bd	32 4b e5
lb2c0h:
	ret			                                        ;b2c0	c9

; This is called when you get the light blue capsule, to set the
; skewness of all three balls.
;
; It uses the NEW_SKEWNESS_POS_TABLE and NEW_SKEWNESS_NEG_TABLE to
; set the values.
SET_THREE_BALLS_SKEWNESS:
    ; This push/pop pair seems to be useless since ix and iy are
    ; set right after.
	push ix		;b2c1	dd e5
	pop iy		;b2c3	fd e1

	; Loop over B=3 balls
    ld b, 3 		        ;b2c5	06 03
	ld iy,BALL_TABLE1		;b2c7	fd 21 4e e2
	ld ix,BALL1_SPR_PARAMS  ;b2cb	dd 21 f5 e0
lb2cfh:
    ; Skip if the ball is not active
	ld a,(iy+BALL_TABLE_IDX_ACTIVE)		;b2cf	fd 7e 00
	or a			                    ;b2d2	b7
	jp nz,lb2e5h		                ;b2d3	c2 e5 b2
    
    ; Nont active: point to the next ball's table
	ld de,BALL_TABLE_LEN		        ;b2d6	11 14 00
	add iy,de		                    ;b2d9	fd 19
    
    ; Set pointers to the next ball
    ld de, SPR_PARAMS_LEN		                    ;b2db	11 04 00
        
	add ix,de		;b2de	dd 19
	djnz lb2cfh		;b2e0	10 ed
    ; All balls checked, get out
	jp lb34dh		                    ;b2e2	c3 4d b3

; Ball is active, process it
lb2e5h:
    ; Check skewness and point to the corresponding depending on
    ; its sign (positive or negative skewness).
	ld hl,NEW_SKEWNESS_POS_TABLE		    ;b2e5	21 52 b3
	ld a,(iy+BALL_TABLE_IDX_SKEWNESS)		;b2e8	fd 7e 06
	bit 7,a		                            ;b2eb	cb 7f
	jp z,lb2f5h		                        ;b2ed	ca f5 b2
	neg		                                ;b2f0	ed 44
	ld hl,NEW_SKEWNESS_NEG_TABLE		    ;b2f2	21 76 b3
lb2f5h:
    ; E = (negated) skewness << 2 = skewness \ 4
	ld e,a		;b2f5	5f
	sla e		;b2f6	cb 23
	sla e		;b2f8	cb 23

    ; HL += skewness \ 4
	ld d, 0		;b2fa	16 00
	add hl,de	;b2fc	19

	ld c,(iy+BALL_TABLE_IDX_SPEED_POS)		;b2fd	fd 4e 07
	ld a,(iy+BALL_TABLE_IDX_SPEED_COUNTER)	;b300	fd 7e 0d
	ld (BRICK_HIT_ROW),a		        ;b303	32 3c e5

    ; Loop over B=3 balls
	ld b, 3		            ;b306	06 03
	ld iy,BALL_TABLE1		;b308	fd 21 4e e2
	ld de,BALL_TABLE_LEN	;b30c	11 14 00
lb30fh:
    ; Set this ball is active
	ld (iy+BALL_TABLE_IDX_ACTIVE), 1	;b30f	fd 36 00 01
    
    ; Set ball is moving normally, not glued
	ld (iy+BALL_TABLE_IDX_GLUE), 2		;b313	fd 36 01 02

    ; Update skewness
	ld a,(hl)			                    ;b317	7e
	ld (iy+BALL_TABLE_IDX_SKEWNESS),a		;b318	fd 77 06

    ; Update speed and its counter
	ld a,(BRICK_HIT_ROW)		            ;b31b	3a 3c e5
	ld (iy+BALL_TABLE_IDX_SPEED_COUNTER),a	;b31e	fd 77 0d
	ld (iy+BALL_TABLE_IDX_SPEED_POS),c		;b321	fd 71 07
    
    ; Next ball
	inc hl			;b324	23
	add iy,de		;b325	fd 19
	djnz lb30fh		;b327	10 e6

    ; Position of the ball's sprite
	ld l,(ix+SPR_PARAMS_IDX_Y)		;b329	dd 6e 00
	ld h,(ix+SPR_PARAMS_IDX_X)		;b32c	dd 66 01

	ld b, 3		                ;b32f	06 03       3 balls
	ld ix, BALL1_SPR_PARAMS		;b331	dd 21 f5 e0
	ld de, SPR_PARAMS_LEN       ;b335	11 04 00
lb338h:
    ; Set ball's sprite parameters
	ld (ix+SPR_PARAMS_IDX_Y),l		            ;b338	dd 75 00        Y
	ld (ix+SPR_PARAMS_IDX_X),h		            ;b33b	dd 74 01        X
	ld (ix+SPR_PARAMS_IDX_PATTERN_NUM), 128	    ;b33e	dd 36 02 80     Pattern of the ball
	ld (ix+SPR_PARAMS_IDX_COLOR),  15	        ;b342	dd 36 03 0f     White color

    ; Next ball
	ld de, SPR_PARAMS_LEN	;b346	11 04 00    Useless, it was already initialized @b335
	add ix,de		        ;b349	dd 19
	djnz lb338h		        ;b34b	10 eb
lb34dh:
    ; Return
	pop iy		;b34d	fd e1
	pop ix		;b34f	dd e1
	ret			;b351	c9

NEW_SKEWNESS_POS_TABLE:
    db 0x0, 0x0, 0x0, 0x0, 0x2, 0x3, 0x4, 0x2 ; 0xb352 - 0xb359
    db 0x2, 0x3, 0x4, 0x2, 0x2, 0x3, 0x4, 0x2 ; 0xb35a - 0xb361
    db 0x2, 0x3, 0x4, 0x2, 0x4, 0x5, 0x6, 0x4 ; 0xb362 - 0xb369
    db 0x5, 0x6, 0x7, 0x5, 0x5, 0x6, 0x7, 0x5 ; 0xb36a - 0xb371
    db 0x5, 0x6, 0x7, 0x5                     ; 0xb372 - 0xb375

NEW_SKEWNESS_NEG_TABLE:
    db 0x0, 0x0, 0x0, 0x0, 0xfe, 0xfd, 0xfc, 0xfe     ; 0xb376 - 0xb37d
    db 0xfe, 0xfd, 0xfc, 0xfe, 0xfe, 0xfd, 0xfc, 0xfe ; 0xb37e - 0xb385
    db 0xfe, 0xfd, 0xfc, 0xfe, 0xfc, 0xfb, 0xfa, 0xfc ; 0xb386 - 0xb38d
    db 0xfb, 0xfa, 0xf9, 0xfa, 0xfb, 0xfa, 0xf9, 0xfa ; 0xb38e - 0xb395
    db 0xfb, 0xfa, 0xf9, 0xfa                         ; 0xb396 - 0xb399

; 16/8 division
; Divides HL by C.
; Place the quotient in HL and the remainder in A
; See: https://wikiti.brandonw.net/index.php?title=Z80_Routines:Math:Division
DIVIDE_HL_BY_C:
    push bc         ;b39a	c5

    xor a           ;b39b	af
    ld b, 16        ;b39c   06 10
lb39eh:
	add hl,hl		;b39e	29
	rla			    ;b39f	17
	jr c,lb3a5h		;b3a0	38 03
	cp c			;b3a2	b9
	jr c,lb3a7h		;b3a3	38 02
lb3a5h:
	sub c			;b3a5	91
	inc l			;b3a6	2c
lb3a7h:
	djnz lb39eh		;b3a7	10 f5
	pop bc			;b3a9	c1
	ret			    ;b3aa	c9
    
    ; Unused, 85 zeros
    ;b3ab
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ;b3ff

include "sound_src.asm"
