; Function CHECK_BRICK_HIT_AND_BOUNCE_BALL is so large and complex, that I
; though it merits to be in its own file.

; Seguir: know what BALL_BRS_Y2, BALL_BRS_X2, and BALL_BRS_Y1 mean
CHECK_BRICK_HIT_AND_BOUNCE_BALL:
    ; iy = BALL_TABLE1
    ; ix = SPR_PARAMS_IDX_Y

    ; Exit if we're at Doh's level
	ld a,(LEVEL)		;9c2d	3a 1b e0
	cp FINAL_LEVEL		;9c30	fe 20
	ret nc			    ;9c32	d0

    ; Jump if the ball's vertical speed is positive
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)	;9c33	fd cb 02 7e
	jp z,l9dcfh		                    ;9c37	ca cf 9d
    
    ; Jump if the ball's horizontal speed is negative
	bit 7,(iy+BALL_TABLE_IDX_X_SPEED)	;9c3a	fd cb 03 7e
	jp nz,l9dcfh		                ;9c3e	c2 cf 9d
    
    ; Horizontal speed positive
    ; Vertical speed negative

	ld a,(ix+SPR_PARAMS_IDX_Y)	;9c41	dd 7e 00    A = BALL_Y
	sub 24		                ;9c44	d6 18       A = BALL_Y - 24
	srl a		                ;9c46	cb 3f
	srl a		                ;9c48	cb 3f
	srl a		                ;9c4a	cb 3f       A = (BALL_Y - 24) \ 8
    ; A is the character-position of the ball
    
    ; Jump if (BALL_Y - 24) \ 8 >= 12
	cp 12		                ;9c4c	fe 0c
	jp nc,l9dcfh		        ;9c4e	d2 cf 9d
    ; (BALL_Y - 24) \ 8 < 12
    
    ; We'll consider 2 X-Y coordinates of the ball in brick space ("BRS")
    ; BALL_BRS_Y2 = (BALL_Y - 24) \ 8
    ; BALL_BRS_X2 = (BALL_X - 12) \ 16
    ;
    ; BALL_BRS_Y1 = (BALL_Y - BALL_Y_SPEED - 24) \ 8
    ; BALL_BRS_X1 = (BALL_X - SPEED_X - 12) \ 16
    ;
    ; The -24 is to look at the char above.
    ; Both (X1, Y1) and (X2, Y2) are basically the same, in one the
    ; speed being subtracted.
    

    ; Store (BALL_Y - 24) \ 8
	ld (BALL_BRS_Y2),a		        ;9c51	32 8a e5

	ld a,(ix+SPR_PARAMS_IDX_X)	;9c54	dd 7e 01
	sub 12		                ;9c57	d6 0c
	srl a		                ;9c59	cb 3f
	srl a		                ;9c5b	cb 3f
	srl a		                ;9c5d	cb 3f
	srl a		                ;9c5f	cb 3f   A = (BALL_X - 12) \ 16
    
    ; Store (BALL_X - 12) \ 16
	ld (BALL_BRS_X2),a		        ;9c61	32 8b e5

    ; Subtract Y speed to the ball
    ; A = BALL_Y - BALL_Y_SPEED
	ld a,(ix+SPR_PARAMS_IDX_Y)		;9c64	dd 7e 00
	sub (iy+BALL_TABLE_IDX_Y_SPEED)	;9c67	fd 96 02
    
    ; Store BALL_Y - BALL_Y_SPEED
	ld (BALL_Y_MINUS_SPEED),a		            ;9c6a	32 86 e5
    
    sub 24		;9c6d	d6 18
	srl a		;9c6f	cb 3f
	srl a		;9c71	cb 3f
	srl a		;9c73	cb 3f   A = (BALL_Y - BALL_Y_SPEED - 24) \ 8
    
    ; Jump if (BALL_Y - BALL_Y_SPEED - 24) \ 8 >= 13
	cp 13		        ;9c75	fe 0d
	jp nc,l9dcfh		;9c77	d2 cf 9d
    
    ; Store (BALL_Y - BALL_Y_SPEED - 24) \ 8 >= 13
	ld (BALL_BRS_Y1),a		;9c7a	32 8c e5

    ; A = BALL_X - SPEED_X
	ld a,(ix+SPR_PARAMS_IDX_X)		;9c7d	dd 7e 01
	sub (iy+BALL_TABLE_IDX_X_SPEED)	;9c80	fd 96 03

    ; Store BALL_X - SPEED_X
	ld (BALL_X_MINUS_SPEED),a		;9c83	32 87 e5
    
	sub 12		                    ;9c86	d6 0c
	srl a		                    ;9c88	cb 3f
	srl a		                    ;9c8a	cb 3f
	srl a		                    ;9c8c	cb 3f
	srl a		                    ;9c8e	cb 3f   A = (BALL_X - SPEED_X - 12) \ 16
    
    ; Jump if (BALL_X - SPEED_X - 12) \ 16 >= 11
    ; It's divided by 16 because a brick is made of 2 chars horizontally
	cp 11		                    ;9c90	fe 0b
	jp nc,l9dcfh		            ;9c92	d2 cf 9d
    
    ; Store (BALL_X - SPEED_X - 12) \ 16, an X coordinate
	ld (BALL_BRS_X1),a           ;9c95	32 8d e5

	call sub_a29ah		            ;9c98	cd 9a a2
	jp c,brick_hit_check_done		;9c9b	da 99 a2 	. . . 

	ld a,(BALL_BRS_X2)		;9c9e	3a 8b e5 	: . . 
	cp 11		;9ca1	fe 0b 	. . 
	jp nc,brick_hit_check_done		;9ca3	d2 99 a2 	. . . 

	ld a,(BALL_BRS_Y2)		;9ca6	3a 8a e5 	: . . 
	cp 11		;9ca9	fe 0b 	. . 
	jp nz,l9cbch		;9cab	c2 bc 9c 	. . . 

	ld a,(BALL_BRS_Y1)		;9cae	3a 8c e5 	: . . 
	cp 12		;9cb1	fe 0c 	. . 
	jp nz,l9cbch		;9cb3	c2 bc 9c 	. . . 

	call CHECK_VERTICAL_DOUBLE_IMPACT		;9cb6	cd 28 a3 	. ( . 
	jp brick_hit_check_done		;9cb9	c3 99 a2 	. . . 
l9cbch:
	ld a,(BALL_BRS_Y1)		    ;9cbc	3a 8c e5
	cp 12		                ;9cbf	fe 0c
	jp nc,brick_hit_check_done	;9cc1	d2 99 a2    Exit if Y2 >= 12
    ; Y2 < 12
    
	ld a,(BALL_BRS_Y1)		    ;9cc4	3a 8c e5
	ld c,a			            ;9cc7	4f          C = Y2
	ld a,(BALL_BRS_Y2)		    ;9cc8	3a 8a e5    A = Y1
	cp c			            ;9ccb	b9
	jp z,l9cd7h		            ;9ccc	ca d7 9c    Jump if Y1 == Y2
	dec c			            ;9ccf	0d          C = Y2 - 1
	cp c			            ;9cd0	b9
	jp z,l9ceah		            ;9cd1	ca ea 9c    Jump If Y1 == Y2 - 1
	jp brick_hit_check_done		;9cd4	c3 99 a2
l9cd7h:
	ld a,(BALL_BRS_X1)		;9cd7	3a 8d e5
	ld c,a			            ;9cda	4f          C = X2
	ld a,(BALL_BRS_X2)		;9cdb	3a 8b e5    A = X1
	cp c			            ;9cde	b9
	jp z,l9cfdh		            ;9cdf	ca fd 9c    Jump if X1 == X2
	inc c			            ;9ce2	0c
	cp c			            ;9ce3	b9          Jump if X1 == X2 + 1
	jp z,l9d18h		;9ce4	ca 18 9d 	. . . 
	jp brick_hit_check_done		;9ce7	c3 99 a2 	. . . 

l9ceah:
	ld a,(BALL_BRS_X1)		;9cea	3a 8d e5 	: . . 
	ld c,a			;9ced	4f 	O 
	ld a,(BALL_BRS_X2)		;9cee	3a 8b e5 	: . . 
	cp c			;9cf1	b9 	. 
	jp z,l9d36h		;9cf2	ca 36 9d 	. 6 . 
	inc c			;9cf5	0c 	. 
	cp c			;9cf6	b9 	. 
	jp z,l9d54h		;9cf7	ca 54 9d 	. T . 
	jp brick_hit_check_done		;9cfa	c3 99 a2 	. . . 

; Brick check (X2, Y1) and vertical bounce
l9cfdh:
    ; Check if there's a brick at (X2, Y1)
	ld a,(BALL_BRS_Y1)		    ;9cfd	3a 8c e5
	ld (BRICK_ROW),a		    ;9d00	32 aa e2
	ld a,(BALL_BRS_X2)		    ;9d03	3a 8b e5
	ld (BRICK_COL),a		    ;9d06	32 ab e2
	call THERE_IS_A_BRICK		;9d09	cd a8 ad
	jp nc,brick_hit_check_done	;9d0c	d2 99 a2
    
    ; Vertical bounce
	call BALL_VERTICAL_BOUNCE	;9d0f	cd 5b 9b
	call DO_BRICK_ACTION		;9d12	cd 05 aa
	jp brick_hit_check_done		;9d15	c3 99 a2

; Brick check (X2, Y1) and vertical bounce
; With DOUBLE_BRICK_IMPACT_1
l9d18h:
    ; Check if there's a brick at (X2, Y1)
	ld a,(BALL_BRS_Y1)		;9d18	3a 8c e5
	ld (BRICK_ROW),a		;9d1b	32 aa e2
	ld a,(BALL_BRS_X2)		;9d1e	3a 8b e5
	ld (BRICK_COL),a		;9d21	32 ab e2
	call THERE_IS_A_BRICK		;9d24	cd a8 ad
	jp nc,brick_hit_check_done	;9d27	d2 99 a2

    ; Double impact
	call DOUBLE_BRICK_IMPACT_1  ;9d2a	cd 01 a9
    
    ; Horizontal bounce
	call BALL_HORIZONTAL_BOUNCE	;9d2d	cd 80 9b
	call DO_BRICK_ACTION		;9d30	cd 05 aa
	jp brick_hit_check_done		;9d33	c3 99 a2

; Brick check (X1, Y2) and vertical bounce
l9d36h:
    ; Check if there's a brick at (X2, Y1)
	ld a,(BALL_BRS_Y2)		;9d36	3a 8a e5
	ld (BRICK_ROW),a		;9d39	32 aa e2
	ld a,(BALL_BRS_X1)		;9d3c	3a 8d e5
	ld (BRICK_COL),a		;9d3f	32 ab e2
	call THERE_IS_A_BRICK	;9d42	cd a8 ad
	jp nc,brick_hit_check_done		;9d45	d2 99 a2
    
    ; Double impact
	call DOUBLE_BRICK_IMPACT_2		    ;9d48	cd 10 a8
    
    ; Vertical bounce
	call BALL_VERTICAL_BOUNCE	;9d4b	cd 5b 9b
	call DO_BRICK_ACTION		;9d4e	cd 05 aa
	jp brick_hit_check_done		;9d51	c3 99 a2

l9d54h:
    ; Call CHECK_DOUBLE_IMPACT with (X1, Y2)
	ld a,(BALL_BRS_Y2)		;9d54	3a 8a e5
	ld (BRICK_ROW),a		;9d57	32 aa e2
	ld a,(BALL_BRS_X1)		;9d5a	3a 8d e5
	ld (BRICK_COL),a		;9d5d	32 ab e2
    
	call CHECK_DOUBLE_IMPACT    ;9d60	cd 70 a6
	jp nc,l9d99h		        ;9d63	d2 99 9d

    ; Check for a brick in (X1, Y2)
	call THERE_IS_A_BRICK	;9d66	cd a8 ad
	jp nc,l9d81h		    ;9d69	d2 81 9d

    ; Adjust the location of the ball sprite
	ld a,(BRICK_HIT_ROW)		;9d6c	3a 3c e5
	ld (ix+SPR_PARAMS_IDX_Y),a	;9d6f	dd 77 00

	ld a,(BRICK_HIT_COL)		;9d72	3a 3d e5
	ld (ix+SPR_PARAMS_IDX_X),a	;9d75	dd 77 01

    ; Vertical bounce
	call BALL_VERTICAL_BOUNCE	;9d78	cd 5b 9b
	call DO_BRICK_ACTION		;9d7b	cd 05 aa
	jp brick_hit_check_done		;9d7e	c3 99 a2
l9d81h:
    ; Check for brick
	ld a,(BALL_BRS_X2)		    ;9d81	3a 8b e5
	ld (BRICK_COL),a		    ;9d84	32 ab e2
	call THERE_IS_A_BRICK		;9d87	cd a8 ad
	jp nc,brick_hit_check_done	;9d8a	d2 99 a2
    
    ; Double impact
	call DOUBLE_BRICK_IMPACT_1  ;9d8d	cd 01 a9
    
    ; Horizontal bounce
	call BALL_HORIZONTAL_BOUNCE	;9d90	cd 80 9b
	call DO_BRICK_ACTION		;9d93	cd 05 aa
	jp brick_hit_check_done		;9d96	c3 99 a2

l9d99h:
    ; Check for brick at (X2, Y1)
	ld a,(BALL_BRS_Y1)		;9d99	3a 8c e5
	ld (BRICK_ROW),a		;9d9c	32 aa e2
	ld a,(BALL_BRS_X2)		;9d9f	3a 8b e5
	ld (BRICK_COL),a		;9da2	32 ab e2

	call THERE_IS_A_BRICK	;9da5	cd a8 ad
	jp nc,l9db7h		    ;9da8	d2 b7 9d

    ; Double impact
	call DOUBLE_BRICK_IMPACT_1		    ;9dab	cd 01 a9

    ; Horizontal bounce
	call BALL_HORIZONTAL_BOUNCE	;9dae	cd 80 9b
	call DO_BRICK_ACTION		;9db1	cd 05 aa
	jp brick_hit_check_done		;9db4	c3 99 a2

l9db7h:
    ; Check for brick
	ld a,(BALL_BRS_Y2)		    ;9db7	3a 8a e5
	ld (BRICK_ROW),a		    ;9dba	32 aa e2

	call THERE_IS_A_BRICK		;9dbd	cd a8 ad
	jp nc,brick_hit_check_done	;9dc0	d2 99 a2
    
    ; Double impact
	call DOUBLE_BRICK_IMPACT_2		        ;9dc3	cd 10 a8

    ; Vertical bounce
	call BALL_VERTICAL_BOUNCE	;9dc6	cd 5b 9b
	call DO_BRICK_ACTION		;9dc9	cd 05 aa
	jp brick_hit_check_done		;9dcc	c3 99 a2

l9dcfh:
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;9dcf	fd cb 02 7e 	. . . ~ 
	jp z,l9f6bh		;9dd3	ca 6b 9f 	. k . 
	bit 7,(iy+BALL_TABLE_IDX_X_SPEED)		;9dd6	fd cb 03 7e 	. . . ~ 
	jp z,l9f6bh		;9dda	ca 6b 9f 	. k . 
	ld a,(ix+SPR_PARAMS_IDX_Y)		;9ddd	dd 7e 00 	. ~ . 
	sub 018h		;9de0	d6 18 	. . 
	srl a		;9de2	cb 3f 	. ? 
	srl a		;9de4	cb 3f 	. ? 
	srl a		;9de6	cb 3f 	. ? 
	cp 12		;9de8	fe 0c 	. . 
	jp nc,l9f6bh		;9dea	d2 6b 9f 	. k . 
	ld (BALL_BRS_Y2),a		;9ded	32 8a e5 	2 . . 
	ld a,(ix+SPR_PARAMS_IDX_X)		;9df0	dd 7e 01 	. ~ . 
	sub 17		;9df3	d6 11 	. . 
	srl a		;9df5	cb 3f 	. ? 
	srl a		;9df7	cb 3f 	. ? 
	srl a		;9df9	cb 3f 	. ? 
	srl a		;9dfb	cb 3f 	. ? 
	ld (BALL_BRS_X2),a		;9dfd	32 8b e5 	2 . . 
	ld a,(ix+SPR_PARAMS_IDX_Y)		;9e00	dd 7e 00 	. ~ . 
	sub (iy+BALL_TABLE_IDX_Y_SPEED)		;9e03	fd 96 02 	. . . 
	ld (BALL_Y_MINUS_SPEED),a		;9e06	32 86 e5 	2 . . 
	sub 018h		;9e09	d6 18 	. . 
	srl a		;9e0b	cb 3f 	. ? 
	srl a		;9e0d	cb 3f 	. ? 
	srl a		;9e0f	cb 3f 	. ? 
	cp 00dh		;9e11	fe 0d 	. . 
	jp nc,l9f6bh		;9e13	d2 6b 9f 	. k . 
	ld (BALL_BRS_Y1),a		;9e16	32 8c e5 	2 . . 
	ld a,(ix+SPR_PARAMS_IDX_X)		;9e19	dd 7e 01 	. ~ . 
	sub (iy+BALL_TABLE_IDX_X_SPEED)		;9e1c	fd 96 03 	. . . 
	ld (BALL_X_MINUS_SPEED),a		;9e1f	32 87 e5 	2 . . 
	sub 17		;9e22	d6 11 	. . 
	srl a		;9e24	cb 3f 	. ? 
	srl a		;9e26	cb 3f 	. ? 
	srl a		;9e28	cb 3f 	. ? 
	srl a		;9e2a	cb 3f 	. ? 
	cp 11		;9e2c	fe 0b 	. . 
	jp nc,l9f6bh		;9e2e	d2 6b 9f 	. k . 
	ld (BALL_BRS_X1),a		;9e31	32 8d e5 	2 . . 
	call sub_a2adh		;9e34	cd ad a2 	. . . 
	jp c,brick_hit_check_done		;9e37	da 99 a2 	. . . 
	ld a,(BALL_BRS_X2)		;9e3a	3a 8b e5 	: . . 
	cp 11		;9e3d	fe 0b 	. . 
	jp nc,brick_hit_check_done		;9e3f	d2 99 a2 	. . . 
	ld a,(BALL_BRS_Y2)		;9e42	3a 8a e5 	: . . 
	cp 11		;9e45	fe 0b 	. . 
	jp nz,l9e58h		;9e47	c2 58 9e 	. X . 
	ld a,(BALL_BRS_Y1)		;9e4a	3a 8c e5 	: . . 
	cp 12		;9e4d	fe 0c 	. . 
	jp nz,l9e58h		;9e4f	c2 58 9e 	. X . 
	call CHECK_VERTICAL_DOUBLE_IMPACT		;9e52	cd 28 a3 	. ( . 
	jp brick_hit_check_done		;9e55	c3 99 a2 	. . . 

l9e58h:
	ld a,(BALL_BRS_Y1)		;9e58	3a 8c e5 	: . . 
	cp 12		;9e5b	fe 0c 	. . 
	jp nc,brick_hit_check_done		;9e5d	d2 99 a2 	. . . 
	ld a,(BALL_BRS_Y1)		;9e60	3a 8c e5 	: . . 
	ld c,a			;9e63	4f 	O 
	ld a,(BALL_BRS_Y2)		;9e64	3a 8a e5 	: . . 
	cp c			;9e67	b9 	. 
	jp z,l9e73h		;9e68	ca 73 9e 	. s . 
	dec c			;9e6b	0d 	. 
	cp c			;9e6c	b9 	. 
	jp z,l9e86h		;9e6d	ca 86 9e 	. . . 
	jp brick_hit_check_done		;9e70	c3 99 a2 	. . . 

l9e73h:
	ld a,(BALL_BRS_X1)		;9e73	3a 8d e5 	: . . 
	ld c,a			;9e76	4f 	O 
	ld a,(BALL_BRS_X2)		;9e77	3a 8b e5 	: . . 
	cp c			;9e7a	b9 	. 
	jp z,l9e99h		;9e7b	ca 99 9e 	. . . 
	dec c			;9e7e	0d 	. 
	cp c			;9e7f	b9 	. 
	jp z,l9eb4h		;9e80	ca b4 9e 	. . . 
	jp brick_hit_check_done		;9e83	c3 99 a2 	. . . 

l9e86h:
	ld a,(BALL_BRS_X1)		;9e86	3a 8d e5 	: . . 
	ld c,a			;9e89	4f 	O 
	ld a,(BALL_BRS_X2)		;9e8a	3a 8b e5 	: . . 
	cp c			;9e8d	b9 	. 
	jp z,l9ed2h		;9e8e	ca d2 9e 	. . . 
	dec c			;9e91	0d 	. 
	cp c			;9e92	b9 	. 
	jp z,l9ef0h		;9e93	ca f0 9e 	. . . 
	jp brick_hit_check_done		;9e96	c3 99 a2 	. . . 

l9e99h:
	; Check for brick at (X2, Y1)
    ld a,(BALL_BRS_Y1)		        ;9e99	3a 8c e5
	ld (BRICK_ROW),a		        ;9e9c	32 aa e2
	ld a,(BALL_BRS_X2)		        ;9e9f	3a 8b e5
	ld (BRICK_COL),a		        ;9ea2	32 ab e2

	call THERE_IS_A_BRICK		    ;9ea5	cd a8 ad
	jp nc,brick_hit_check_done		;9ea8	d2 99 a2
    
    ; Vertical bounce
	call BALL_VERTICAL_BOUNCE		;9eab	cd 5b 9b
	call DO_BRICK_ACTION		    ;9eae	cd 05 aa
	jp brick_hit_check_done		    ;9eb1	c3 99 a2

l9eb4h:
    ; Check for brick at (X2, Y1)
	ld a,(BALL_BRS_Y1)		        ;9eb4	3a 8c e5
	ld (BRICK_ROW),a		        ;9eb7	32 aa e2
	ld a,(BALL_BRS_X2)		        ;9eba	3a 8b e5
	ld (BRICK_COL),a		        ;9ebd	32 ab e2

	call THERE_IS_A_BRICK		    ;9ec0	cd a8 ad
	jp nc,brick_hit_check_done		;9ec3	d2 99 a2

    ; Double impact
	call DOUBLE_BRICK_IMPACT_1		            ;9ec6	cd 01 a9
    
    ; Horizontal bounce
	call BALL_HORIZONTAL_BOUNCE		;9ec9	cd 80 9b
	call DO_BRICK_ACTION		    ;9ecc	cd 05 aa
	jp brick_hit_check_done		    ;9ecf	c3 99 a2

l9ed2h:
    ; Check for brick at (X1, Y2)
	ld a,(BALL_BRS_Y2)		    ;9ed2	3a 8a e5
	ld (BRICK_ROW),a		    ;9ed5	32 aa e2
	ld a,(BALL_BRS_X1)		    ;9ed8	3a 8d e5
	ld (BRICK_COL),a		    ;9edb	32 ab e2

	call THERE_IS_A_BRICK		;9ede	cd a8 ad
	jp nc,brick_hit_check_done	;9ee1	d2 99 a2
    
    ; Double impact
	call DOUBLE_BRICK_IMPACT_2  ;9ee4	cd 10 a8
    
    ; Vertical bounce
	call BALL_VERTICAL_BOUNCE	;9ee7	cd 5b 9b
	call DO_BRICK_ACTION		;9eea	cd 05 aa
	jp brick_hit_check_done		;9eed	c3 99 a2

l9ef0h:
    ; Check for brick at (X1, Y2)
	ld a,(BALL_BRS_Y2)		;9ef0	3a 8a e5
	ld (BRICK_ROW),a		;9ef3	32 aa e2
	ld a,(BALL_BRS_X1)		;9ef6	3a 8d e5
	ld (BRICK_COL),a		;9ef9	32 ab e2
    
    ; Check double impact
	call CHECK_DOUBLE_IMPACT    ;9efc	cd 70 a6
	jp nc,l9f35h		        ;9eff	d2 35 9f

    ; Check for brick
	call THERE_IS_A_BRICK	;9f02	cd a8 ad
	jp nc,l9f1dh		    ;9f05	d2 1d 9f

	; Adjust the position of the ball
    ld a,(BRICK_HIT_ROW)		;9f08	3a 3c e5
	ld (ix+SPR_PARAMS_IDX_Y),a	;9f0b	dd 77 00

	ld a,(BRICK_HIT_COL)		;9f0e	3a 3d e5
	ld (ix+SPR_PARAMS_IDX_X),a	;9f11	dd 77 01

    ; Vertical bounce
	call BALL_VERTICAL_BOUNCE	;9f14	cd 5b 9b
	call DO_BRICK_ACTION		;9f17	cd 05 aa
	jp brick_hit_check_done		;9f1a	c3 99 a2

l9f1dh:
    ; Check for brick
	ld a,(BALL_BRS_X2)		    ;9f1d	3a 8b e5
	ld (BRICK_COL),a		    ;9f20	32 ab e2
	call THERE_IS_A_BRICK		;9f23	cd a8 ad
	jp nc,brick_hit_check_done	;9f26	d2 99 a2

    ; Double impact
	call DOUBLE_BRICK_IMPACT_1	;9f29	cd 01 a9

    ; Horizontal bounce
	call BALL_HORIZONTAL_BOUNCE	;9f2c	cd 80 9b
	call DO_BRICK_ACTION		;9f2f	cd 05 aa
	jp brick_hit_check_done		;9f32	c3 99 a2

l9f35h:
    ; Check for brick at (X2, Y1)
	ld a,(BALL_BRS_Y1)		;9f35	3a 8c e5
	ld (BRICK_ROW),a		;9f38	32 aa e2
	ld a,(BALL_BRS_X2)		;9f3b	3a 8b e5
	ld (BRICK_COL),a		;9f3e	32 ab e2

	call THERE_IS_A_BRICK	;9f41	cd a8 ad
	jp nc,l9f53h		    ;9f44	d2 53 9f

	; Double impact
    call DOUBLE_BRICK_IMPACT_1  ;9f47	cd 01 a9
    
    ; Horizontal bounce
	call BALL_HORIZONTAL_BOUNCE	;9f4a	cd 80 9b
	call DO_BRICK_ACTION		;9f4d	cd 05 aa
	jp brick_hit_check_done		;9f50	c3 99 a2

l9f53h:
    ; Check for brick
	ld a,(BALL_BRS_Y2)		    ;9f53	3a 8a e5
	ld (BRICK_ROW),a		    ;9f56	32 aa e2
	call THERE_IS_A_BRICK		;9f59	cd a8 ad
	jp nc,brick_hit_check_done	;9f5c	d2 99 a2

    ; Double impact
	call DOUBLE_BRICK_IMPACT_2  ;9f5f	cd 10 a8

    ; Vertical bounce
	call BALL_VERTICAL_BOUNCE	;9f62	cd 5b 9b
	call DO_BRICK_ACTION		;9f65	cd 05 aa
	jp brick_hit_check_done		;9f68	c3 99 a2

l9f6bh:
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;9f6b	fd cb 02 7e 	. . . ~ 
	jp nz,la102h		;9f6f	c2 02 a1 	. . . 
	bit 7,(iy+BALL_TABLE_IDX_X_SPEED)		;9f72	fd cb 03 7e 	. . . ~ 
	jp nz,la102h		;9f76	c2 02 a1 	. . . 
	ld a,(ix+SPR_PARAMS_IDX_Y)		;9f79	dd 7e 00 	. ~ . 
	sub 19		;9f7c	d6 13 	. . 
	srl a		;9f7e	cb 3f 	. ? 
	srl a		;9f80	c0b 3f 	. ? 
	srl a		;9f82	cb 3f 	. ? 
	cp 12		;9f84	fe 0c 	. . 
	jp nc,la102h		;9f86	d2 02 a1 	. . . 
	ld (BALL_BRS_Y2),a		;9f89	32 8a e5 	2 . . 
	ld a,(ix+SPR_PARAMS_IDX_X)		;9f8c	dd 7e 01 	. ~ . 
	sub 12		;9f8f	d6 0c 	. . 
	srl a		;9f91	cb 3f 	. ? 
	srl a		;9f93	cb 3f 	. ? 
	srl a		;9f95	cb 3f 	. ? 
	srl a		;9f97	cb 3f 	. ? 
	ld (BALL_BRS_X2),a		;9f99	32 8b e5 	2 . . 
	ld a,(ix+SPR_PARAMS_IDX_Y)		;9f9c	dd 7e 00 	. ~ . 
	sub (iy+BALL_TABLE_IDX_Y_SPEED)		;9f9f	fd 96 02 	. . . 
	ld (BALL_Y_MINUS_SPEED),a		;9fa2	32 86 e5 	2 . . 
	sub 19		;9fa5	d6 13 	. . 
	srl a		;9fa7	cb 3f 	. ? 
	srl a		;9fa9	cb 3f 	. ? 
	srl a		;9fab	cb 3f 	. ? 
	ld (BALL_BRS_Y1),a		;9fad	32 8c e5 	2 . . 
	ld a,(ix+SPR_PARAMS_IDX_X)		;9fb0	dd 7e 01 	. ~ . 
	sub (iy+BALL_TABLE_IDX_X_SPEED)		;9fb3	fd 96 03 	. . . 
	ld (BALL_X_MINUS_SPEED),a		;9fb6	32 87 e5 	2 . . 
	sub 12		;9fb9	d6 0c 	. . 
	srl a		;9fbb	cb 3f 	. ? 
	srl a		;9fbd	cb 3f 	. ? 
	srl a		;9fbf	cb 3f 	. ? 
	srl a		;9fc1	cb 3f 	. ? 
	cp 11		;9fc3	fe 0b 	. . 
	jp nc,la102h		;9fc5	d2 02 a1 	. . . 
	ld (BALL_BRS_X1),a		;9fc8	32 8d e5 	2 . . 

	call sub_a29ah		;9fcb	cd 9a a2 	. . . 
	jp c,brick_hit_check_done		;9fce	da 99 a2 	. . . 

	ld a,(BALL_BRS_X2)		;9fd1	3a 8b e5 	: . . 
	cp 11		;9fd4	fe 0b 	. . 
	jp nc,brick_hit_check_done		;9fd6	d2 99 a2 	. . . 
	ld a,(BALL_BRS_Y2)		;9fd9	3a 8a e5 	: . . 
	cp 0		;9fdc	fe 00 	. . 
	jp nz,l9fefh		;9fde	c2 ef 9f 	. . . 
	ld a,(BALL_BRS_Y1)		;9fe1	3a 8c e5 	: . . 
	cp 31		;9fe4	fe 1f 	. . 
	jp nz,l9fefh		;9fe6	c2 ef 9f 	. . . 
	call CHECK_VERTICAL_DOUBLE_IMPACT		;9fe9	cd 28 a3 	. ( . 
	jp brick_hit_check_done		;9fec	c3 99 a2 	. . . 

l9fefh:
	ld a,(BALL_BRS_Y1)		;9fef	3a 8c e5 	: . . 
	cp 12		;9ff2	fe 0c 	. . 
	jp nc,brick_hit_check_done		;9ff4	d2 99 a2 	. . . 
	ld a,(BALL_BRS_Y1)		;9ff7	3a 8c e5 	: . . 
	ld c,a			;9ffa	4f 	O 
	ld a,(BALL_BRS_Y2)		;9ffb	3a 8a e5 	: . . 
	cp c			;9ffe	b9 	. 
	jp z,la00ah		;9fff	ca 0a a0 	. . . 
	inc c			;a002	0c 	. 
	cp c			;a003	b9 	. 
	jp z,la01dh		;a004	ca 1d a0 	. . . 
	jp brick_hit_check_done		;a007	c3 99 a2 	. . . 

la00ah:
	ld a,(BALL_BRS_X1)		;a00a	3a 8d e5 	: . . 
	ld c,a			;a00d	4f 	O 
	ld a,(BALL_BRS_X2)		;a00e	3a 8b e5 	: . . 
	cp c			;a011	b9 	. 
	jp z,la030h		;a012	ca 30 a0 	. 0 . 
	inc c			;a015	0c 	. 
	cp c			;a016	b9 	. 
	jp z,la04bh		;a017	ca 4b a0 	. K . 
	jp brick_hit_check_done		;a01a	c3 99 a2 	. . . 

la01dh:
	ld a,(BALL_BRS_X1)		;a01d	3a 8d e5 	: . . 
	ld c,a			;a020	4f 	O 
	ld a,(BALL_BRS_X2)		;a021	3a 8b e5 	: . . 
	cp c			;a024	b9 	. 
	jp z,la069h		;a025	ca 69 a0 	. i . 
	inc c			;a028	0c 	. 
	cp c			;a029	b9 	. 
	jp z,la087h		;a02a	ca 87 a0 	. . . 
	jp brick_hit_check_done		;a02d	c3 99 a2 	. . . 

la030h:
	ld a,(BALL_BRS_Y1)		;a030	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;a033	32 aa e2 	2 . . 
	ld a,(BALL_BRS_X2)		;a036	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a039	32 ab e2 	2 . . 
	call THERE_IS_A_BRICK		;a03c	cd a8 ad 	. . . 
	jp nc,brick_hit_check_done		;a03f	d2 99 a2 	. . . 
	call BALL_VERTICAL_BOUNCE		;a042	cd 5b 9b 	. [ . 
	call DO_BRICK_ACTION		;a045	cd 05 aa 	. . . 
	jp brick_hit_check_done		;a048	c3 99 a2 	. . . 

la04bh:
	ld a,(BALL_BRS_Y1)		;a04b	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;a04e	32 aa e2 	2 . . 
	ld a,(BALL_BRS_X2)		;a051	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a054	32 ab e2 	2 . . 
	call THERE_IS_A_BRICK		;a057	cd a8 ad 	. . . 
	jp nc,brick_hit_check_done		;a05a	d2 99 a2 	. . . 

    ; Double impact
	call DOUBLE_BRICK_IMPACT_1		;a05d	cd 01 a9 	. . . 
	call BALL_HORIZONTAL_BOUNCE		;a060	cd 80 9b 	. . . 
	call DO_BRICK_ACTION		;a063	cd 05 aa 	. . . 
	jp brick_hit_check_done		;a066	c3 99 a2 	. . . 

la069h:
	ld a,(BALL_BRS_Y2)		;a069	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a06c	32 aa e2 	2 . . 
	ld a,(BALL_BRS_X1)		;a06f	3a 8d e5 	: . . 
	ld (BRICK_COL),a		;a072	32 ab e2 	2 . . 
	call THERE_IS_A_BRICK		;a075	cd a8 ad 	. . . 
	jp nc,brick_hit_check_done		;a078	d2 99 a2 	. . . 

    ; Double impact
	call DOUBLE_BRICK_IMPACT_2		;a07b	cd 10 a8 	. . . 

	call BALL_VERTICAL_BOUNCE		;a07e	cd 5b 9b 	. [ . 
	call DO_BRICK_ACTION		;a081	cd 05 aa 	. . . 
	jp brick_hit_check_done		;a084	c3 99 a2 	. . . 

la087h:
	ld a,(BALL_BRS_Y2)		;a087	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a08a	32 aa e2 	2 . . 
	ld a,(BALL_BRS_X1)		;a08d	3a 8d e5 	: . . 
la090h:
	ld (BRICK_COL),a		;a090	32 ab e2 	2 . . 
	call CHECK_DOUBLE_IMPACT		;a093	cd 70 a6 	. p . 
	jp nc,la0cch		;a096	d2 cc a0 	. . . 
	call THERE_IS_A_BRICK		;a099	cd a8 ad 	. . . 
	jp nc,la0b4h		;a09c	d2 b4 a0 	. . . 
	ld a,(BRICK_HIT_ROW)		;a09f	3a 3c e5 	: < . 
	ld (ix+SPR_PARAMS_IDX_Y),a		;a0a2	dd 77 00 	. w . 
	ld a,(BRICK_HIT_COL)		;a0a5	3a 3d e5 	: = . 
	ld (ix+SPR_PARAMS_IDX_X),a		;a0a8	dd 77 01 	. w . 
	call BALL_VERTICAL_BOUNCE		;a0ab	cd 5b 9b 	. [ . 
	call DO_BRICK_ACTION		;a0ae	cd 05 aa 	. . . 
	jp brick_hit_check_done		;a0b1	c3 99 a2 	. . . 

la0b4h:
	ld a,(BALL_BRS_X2)		;a0b4	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a0b7	32 ab e2 	2 . . 
	call THERE_IS_A_BRICK		;a0ba	cd a8 ad 	. . . 
	jp nc,brick_hit_check_done		;a0bd	d2 99 a2 	. . . 
la0c0h:
	call DOUBLE_BRICK_IMPACT_1		;a0c0	cd 01 a9 	. . . 
	call BALL_HORIZONTAL_BOUNCE		;a0c3	cd 80 9b 	. . . 
	call DO_BRICK_ACTION		;a0c6	cd 05 aa 	. . . 
	jp brick_hit_check_done		;a0c9	c3 99 a2 	. . . 

la0cch:
	ld a,(BALL_BRS_Y1)		;a0cc	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;a0cf	32 aa e2 	2 . . 
	ld a,(BALL_BRS_X2)		;a0d2	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a0d5	32 ab e2 	2 . . 
	call THERE_IS_A_BRICK		;a0d8	cd a8 ad 	. . . 
	jp nc,la0eah		;a0db	d2 ea a0 	. . . 

    ; Double impact
	call DOUBLE_BRICK_IMPACT_1		;a0de	cd 01 a9 	. . . 

	call BALL_HORIZONTAL_BOUNCE		;a0e1	cd 80 9b 	. . . 
	call DO_BRICK_ACTION		;a0e4	cd 05 aa 	. . . 
	jp brick_hit_check_done		;a0e7	c3 99 a2 	. . . 

la0eah:
	ld a,(BALL_BRS_Y2)		;a0ea	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a0ed	32 aa e2 	2 . . 
	call THERE_IS_A_BRICK		;a0f0	cd a8 ad 	. . . 
	jp nc,brick_hit_check_done		;a0f3	d2 99 a2 	. . . 

    ; Double impact
	call DOUBLE_BRICK_IMPACT_2		;a0f6	cd 10 a8 	. . . 

	call BALL_VERTICAL_BOUNCE		;a0f9	cd 5b 9b 	. [ . 
	call DO_BRICK_ACTION		;a0fc	cd 05 aa 	. . . 
	jp brick_hit_check_done		;a0ff	c3 99 a2 	. . . 

la102h:
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a102	fd cb 02 7e 	. . . ~ 
	jp nz,brick_hit_check_done		;a106	c2 99 a2 	. . . 
	bit 7,(iy+BALL_TABLE_IDX_X_SPEED)		;a109	fd cb 03 7e 	. . . ~ 
	jp z,brick_hit_check_done		;a10d	ca 99 a2 	. . . 
	ld a,(ix+SPR_PARAMS_IDX_Y)		;a110	dd 7e 00 	. ~ . 
	sub 19		;a113	d6 13 	. . 
	srl a		;a115	cb 3f 	. ? 
	srl a		;a117	cb 3f 	. ? 
	srl a		;a119	cb 3f 	. ? 
	cp 12		;a11b	fe 0c 	. . 
	jp nc,brick_hit_check_done		;a11d	d2 99 a2 	. . . 
	ld (BALL_BRS_Y2),a		;a120	32 8a e5 	2 . . 
	ld a,(ix+SPR_PARAMS_IDX_X)		;a123	dd 7e 01 	. ~ . 
	sub 17		;a126	d6 11 	. . 
	srl a		;a128	cb 3f 	. ? 
	srl a		;a12a	cb 3f 	. ? 
	srl a		;a12c	cb 3f 	. ? 
	srl a		;a12e	cb 3f 	. ? 
	ld (BALL_BRS_X2),a		;a130	32 8b e5 	2 . . 
	ld a,(ix+SPR_PARAMS_IDX_Y)		;a133	dd 7e 00 	. ~ . 
	sub (iy+BALL_TABLE_IDX_Y_SPEED)		;a136	fd 96 02 	. . . 
	ld (BALL_Y_MINUS_SPEED),a		;a139	32 86 e5 	2 . . 
	sub 19		;a13c	d6 13 	. . 
	srl a		;a13e	cb 3f 	. ? 
	srl a		;a140	cb 3f 	. ? 
	srl a		;a142	cb 3f 	. ? 
	ld (BALL_BRS_Y1),a		;a144	32 8c e5 	2 . . 
	ld a,(ix+SPR_PARAMS_IDX_X)		;a147	dd 7e 01 	. ~ . 
	sub (iy+BALL_TABLE_IDX_X_SPEED)		;a14a	fd 96 03 	. . . 
	ld (BALL_X_MINUS_SPEED),a		;a14d	32 87 e5 	2 . . 
	sub 17		;a150	d6 11 	. . 
	srl a		;a152	cb 3f 	. ? 
	srl a		;a154	cb 3f 	. ? 
	srl a		;a156	cb 3f 	. ? 
	srl a		;a158	cb 3f 	. ? 
	cp 11		;a15a	fe 0b 	. . 
	jp nc,brick_hit_check_done		;a15c	d2 99 a2 	. . . 
	ld (BALL_BRS_X1),a		;a15f	32 8d e5 	2 . . 
	call sub_a2adh		;a162	cd ad a2 	. . . 
	jp c,brick_hit_check_done		;a165	da 99 a2 	. . . 
	ld a,(BALL_BRS_X2)		;a168	3a 8b e5 	: . . 
	cp 11		;a16b	fe 0b 	. . 
	jp nc,brick_hit_check_done		;a16d	d2 99 a2 	. . . 
	ld a,(BALL_BRS_Y2)		;a170	3a 8a e5 	: . . 
	cp 0		;a173	fe 00 	. . 
	jp nz,la186h		;a175	c2 86 a1 	. . . 
	ld a,(BALL_BRS_Y1)		;a178	3a 8c e5 	: . . 
	cp 31		;a17b	fe 1f 	. . 
	jp nz,la186h		;a17d	c2 86 a1 	. . . 
	call CHECK_VERTICAL_DOUBLE_IMPACT		;a180	cd 28 a3 	. ( . 
	jp brick_hit_check_done		;a183	c3 99 a2 	. . . 

la186h:
	ld a,(BALL_BRS_Y1)		;a186	3a 8c e5 	: . . 
	cp 12		;a189	fe 0c 	. . 
	jp nc,brick_hit_check_done		;a18b	d2 99 a2 	. . . 
	ld a,(BALL_BRS_Y1)		;a18e	3a 8c e5 	: . . 
	ld c,a			;a191	4f 	O 
	ld a,(BALL_BRS_Y2)		;a192	3a 8a e5 	: . . 
	cp c			;a195	b9 	. 
	jp z,la1a1h		;a196	ca a1 a1 	. . . 
	inc c			;a199	0c 	. 
	cp c			;a19a	b9 	. 
	jp z,la1b4h		;a19b	ca b4 a1 	. . . 
	jp brick_hit_check_done		;a19e	c3 99 a2 	. . . 

la1a1h:
	ld a,(BALL_BRS_X1)		;a1a1	3a 8d e5 	: . . 
	ld c,a			;a1a4	4f 	O 
	ld a,(BALL_BRS_X2)		;a1a5	3a 8b e5 	: . . 
	cp c			;a1a8	b9 	. 
	jp z,la1c7h		;a1a9	ca c7 a1 	. . . 
	dec c			;a1ac	0d 	. 
	cp c			;a1ad	b9 	. 
	jp z,la1e2h		;a1ae	ca e2 a1 	. . . 
	jp brick_hit_check_done		;a1b1	c3 99 a2 	. . . 

la1b4h:
	ld a,(BALL_BRS_X1)		;a1b4	3a 8d e5 	: . . 
	ld c,a			;a1b7	4f 	O 
	ld a,(BALL_BRS_X2)		;a1b8	3a 8b e5 	: . . 
	cp c			;a1bb	b9 	. 
	jp z,la200h		;a1bc	ca 00 a2 	. . . 
	dec c			;a1bf	0d 	. 
	cp c			;a1c0	b9 	. 
	jp z,la21eh		;a1c1	ca 1e a2 	. . . 
	jp brick_hit_check_done		;a1c4	c3 99 a2 	. . . 

la1c7h:
	ld a,(BALL_BRS_Y1)		;a1c7	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;a1ca	32 aa e2 	2 . . 
	ld a,(BALL_BRS_X2)		;a1cd	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a1d0	32 ab e2 	2 . . 

	call THERE_IS_A_BRICK		;a1d3	cd a8 ad
	jp nc,brick_hit_check_done		;a1d6	d2 99 a2 	. . . 

	call BALL_VERTICAL_BOUNCE		;a1d9	cd 5b 9b 	. [ . 
	call DO_BRICK_ACTION		;a1dc	cd 05 aa 	. . . 
	jp brick_hit_check_done		;a1df	c3 99 a2 	. . . 

la1e2h:
	ld a,(BALL_BRS_Y1)		;a1e2	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;a1e5	32 aa e2 	2 . . 
	ld a,(BALL_BRS_X2)		;a1e8	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a1eb	32 ab e2 	2 . . 

	call THERE_IS_A_BRICK		;a1ee	cd a8 ad 	. . . 
	jp nc,brick_hit_check_done		;a1f1	d2 99 a2 	. . . 

    ; Double impact
	call DOUBLE_BRICK_IMPACT_1		;a1f4	cd 01 a9 	. . . 

	call BALL_HORIZONTAL_BOUNCE		;a1f7	cd 80 9b 	. . . 
	call DO_BRICK_ACTION		;a1fa	cd 05 aa 	. . . 
	jp brick_hit_check_done		;a1fd	c3 99 a2 	. . . 

la200h:
	ld a,(BALL_BRS_Y2)		;a200	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a203	32 aa e2 	2 . . 
	ld a,(BALL_BRS_X1)		;a206	3a 8d e5 	: . . 
	ld (BRICK_COL),a		;a209	32 ab e2 	2 . . 
	call THERE_IS_A_BRICK		;a20c	cd a8 ad 	. . . 
	jp nc,brick_hit_check_done		;a20f	d2 99 a2 	. . . 

    ; Double impact
	call DOUBLE_BRICK_IMPACT_2		;a212	cd 10 a8 	. . . 

	call BALL_VERTICAL_BOUNCE		;a215	cd 5b 9b 	. [ . 
	call DO_BRICK_ACTION		;a218	cd 05 aa 	. . . 
	jp brick_hit_check_done		;a21b	c3 99 a2 	. . . 

la21eh:
	ld a,(BALL_BRS_Y2)		;a21e	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a221	32 aa e2 	2 . . 
	ld a,(BALL_BRS_X1)		;a224	3a 8d e5 	: . . 
	ld (BRICK_COL),a		;a227	32 ab e2 	2 . . 

    ; ToDo
	call CHECK_DOUBLE_IMPACT		;a22a	cd 70 a6 	. p . 
	jp nc,la263h		;a22d	d2 63 a2 	. c . 

	call THERE_IS_A_BRICK		;a230	cd a8 ad 	. . . 
	jp nc,la24bh		;a233	d2 4b a2 	. K . 

	ld a,(BRICK_HIT_ROW)		;a236	3a 3c e5 	: < . 
	ld (ix+SPR_PARAMS_IDX_Y),a		;a239	dd 77 00 	. w . 
	ld a,(BRICK_HIT_COL)		;a23c	3a 3d e5 	: = . 
	ld (ix+SPR_PARAMS_IDX_X),a		;a23f	dd 77 01 	. w . 

	call BALL_VERTICAL_BOUNCE		;a242	cd 5b 9b 	. [ . 
	call DO_BRICK_ACTION		;a245	cd 05 aa 	. . . 
	jp brick_hit_check_done		;a248	c3 99 a2 	. . . 

la24bh:
	ld a,(BALL_BRS_X2)		;a24b	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a24e	32 ab e2 	2 . . 
	call THERE_IS_A_BRICK		;a251	cd a8 ad 	. . . 
	jp nc,brick_hit_check_done		;a254	d2 99 a2 	. . . 

    ; Double impact
	call DOUBLE_BRICK_IMPACT_1		;a257	cd 01 a9 	. . . 

	call BALL_HORIZONTAL_BOUNCE		;a25a	cd 80 9b 	. . . 
	call DO_BRICK_ACTION		;a25d	cd 05 aa 	. . . 
	jp brick_hit_check_done		;a260	c3 99 a2 	. . . 

la263h:
	ld a,(BALL_BRS_Y1)		;a263	3a 8c e5 	: . . 
	ld (BRICK_ROW),a		;a266	32 aa e2 	2 . . 
	ld a,(BALL_BRS_X2)		;a269	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a26c	32 ab e2 	2 . . 
	call THERE_IS_A_BRICK		;a26f	cd a8 ad 	. . . 
	jp nc,la281h		;a272	d2 81 a2 	. . . 

    ; Double impact
	call DOUBLE_BRICK_IMPACT_1		;a275	cd 01 a9 	. . . 

	call BALL_HORIZONTAL_BOUNCE		;a278	cd 80 9b 	. . . 
	call DO_BRICK_ACTION		;a27b	cd 05 aa 	. . . 
	jp brick_hit_check_done		;a27e	c3 99 a2 	. . . 

la281h:
	ld a,(BALL_BRS_Y2)		;a281	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a284	32 aa e2 	2 . . 
	call THERE_IS_A_BRICK		;a287	cd a8 ad 	. . . 
	jp nc,brick_hit_check_done		;a28a	d2 99 a2 	. . . 

    ; Double impact
	call DOUBLE_BRICK_IMPACT_2		;a28d	cd 10 a8 	. . . 

	call BALL_VERTICAL_BOUNCE		;a290	cd 5b 9b 	. [ . 
	call DO_BRICK_ACTION		;a293	cd 05 aa 	. . . 
	jp brick_hit_check_done		;a296	c3 99 a2 	. . . 
brick_hit_check_done:
	ret			;a299	c9 	. 

; Check "something" (ToDo) and set/clear the carry
; Carry reset: it's hit something
; Carry set: nothing to do, ball goes on normally
sub_a29ah:
    ; If X1 != 11, clear_carry_and_exit
	ld a,(BALL_BRS_X2)		    ;a29a	3a 8b e5
	cp 11		                ;a29d	fe 0b
	jp nz,clear_carry_and_exit	;a29f	c2 24 a3

    ; If X2 != 10, clear_carry_and_exit
	ld a,(BALL_BRS_X1)		;a2a2	3a 8d e5
	cp 10		                ;a2a5	fe 0a
	jp nz,clear_carry_and_exit	;a2a7	c2 24 a3

    ; X1 == 11 && X2 == 10 --> moving left
    ; This means we're at the right border and starting to move left    
	jp la2bdh		            ;a2aa	c3 bd a2

sub_a2adh:
	; If X1 != 15, clear_carry_and_exit
    ld a,(BALL_BRS_X2)		;a2ad	3a 8b e5
	cp 15		                ;a2b0	fe 0f
	jp nz,clear_carry_and_exit	;a2b2	c2 24 a3
    
    ; If X2 != 0, clear_carry_and_exit
	ld a,(BALL_BRS_X1)		;a2b5	3a 8d e5
	cp 0		                ;a2b8	fe 00
	jp nz,clear_carry_and_exit	;a2ba	c2 24 a3
    ; X1 == 15 && X2 == 0
la2bdh:
	ld a,(BALL_BRS_Y1)		;a2bd	3a 8c e5
	ld c,a			            ;a2c0	4f          C = Y2
	ld a,(BALL_BRS_Y2)		;a2c1	3a 8a e5    A = Y1
	cp c			            ;a2c4	b9
	jp z,la2dfh		            ;a2c5	ca df a2    Jump if Y1 == Y2
    
    ; Y1 != Y2

	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a2c8	fd cb 02 7e
	jp nz,la2d7h		                    ;a2cc	c2 d7 a2
	inc c			                        ;a2cf	0c
	cp c			                        ;a2d0	b9  Jump if Y1 == Y2 + 1
	jp z,la2eeh		                        ;a2d1	ca ee a2
    ; Y1 != Y2 + 1
	jp set_carry_and_exit		            ;a2d4	c3 26 a3
la2d7h:
	dec c			            ;a2d7	0d
	cp c			            ;a2d8	b9
	jp z,la2eeh		            ;a2d9	ca ee a2
	jp set_carry_and_exit		;a2dc	c3 26 a3

; Ball hitting the right wall, moving right-down
; Ball hitting the left wall, moving left-down
; Ball hitting the left wall, moving left-up
la2dfh:
    ; Set BRICK_ROW
	ld a,(BALL_BRS_Y1)		;a2df	3a 8c e5
	ld (BRICK_ROW),a		;a2e2	32 aa e2
	
    call GET_COMPUTED_VARS		        ;a2e5	cd d1 a3
    
    ; Horizontal bounce and exit with carry set
	call BALL_HORIZONTAL_BOUNCE	;a2e8	cd 80 9b
	jp set_carry_and_exit		;a2eb	c3 26 a3

; Ball hitting the left wall, moving left-down
; Ball hitting the right wall, moving right-up
la2eeh:
	ld a,(BALL_BRS_Y2)		;a2ee	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a2f1	32 aa e2 	2 . . 
	call sub_a591h		;a2f4	cd 91 a5 	. . . 
	jp nc,la2dfh		;a2f7	d2 df a2 	. . . 

	ld a,(BALL_BRS_X1)		;a2fa	3a 8d e5 	: . . 
	ld (BRICK_COL),a		;a2fd	32 ab e2 	2 . . 
	call THERE_IS_A_BRICK		;a300	cd a8 ad 	. . . 
	jp nc,no_brick_do_horizontal_bounce_set_carry		;a303	d2 1b a3 	. . . 

	ld a,(BRICK_HIT_ROW)		;a306	3a 3c e5 	: < . 
	ld (ix+SPR_PARAMS_IDX_Y),a		;a309	dd 77 00 	. w . 
	ld a,(BRICK_HIT_COL)		;a30c	3a 3d e5 	: = . 
	ld (ix+SPR_PARAMS_IDX_X),a		;a30f	dd 77 01 	. w . 

	call BALL_VERTICAL_BOUNCE		;a312	cd 5b 9b 	. [ . 

	call DO_BRICK_ACTION		;a315	cd 05 aa 	. . . 
	jp set_carry_and_exit		;a318	c3 26 a3 	. & . 

no_brick_do_horizontal_bounce_set_carry:
	call GET_COMPUTED_VARS		;a31b	cd d1 a3 	. . . 
	call BALL_HORIZONTAL_BOUNCE		;a31e	cd 80 9b 	. . . 
	jp set_carry_and_exit		;a321	c3 26 a3 	. & . 
clear_carry_and_exit:
    ; Clear carry flag and exit
	xor a		;a324	af
	ret			;a325	c9
set_carry_and_exit:
    ; Set carry flag and exit
	scf			;a326	37
	ret			;a327	c9

; Check for a vertical double impact and perform the
; corresponding brick action.
CHECK_VERTICAL_DOUBLE_IMPACT:
    ; Check if the ball might be hitting a brick in X
	ld a,(BALL_BRS_X2)		;a328	3a 8b e5
	ld b,a			        ;a32b	47
	ld a,(BRICK_COL)		;a32c	3a ab e2
	cp b			        ;a32f	b8
	jp nz,la354h		    ;a330	c2 54 a3

    ; Set BRICK_ROW and BRICK_COL
	ld a,(BALL_BRS_Y2)		;a333	3a 8a e5
	ld (BRICK_ROW),a		;a336	32 aa e2
	ld a,(BALL_BRS_X2)		;a339	3a 8b e5
	ld (BRICK_COL),a		;a33c	32 ab e2

    ; Check if there's actually a brick there.
    ; Exit otherwise.
	call THERE_IS_A_BRICK	;a33f	cd a8 ad
	jp nc,la351h		    ;a342	d2 51 a3

    ; Double impact
	call DOUBLE_BRICK_IMPACT_2	;a345	cd 10 a8

	call BALL_VERTICAL_BOUNCE	;a348	cd 5b 9b
	call DO_BRICK_ACTION		;a34b	cd 05 aa
	jp all_done		;a34e	c3 d0 a3
la351h:
	jp all_done		;a351	c3 d0 a3

la354h:
	ld a,(BALL_BRS_Y2)		;a354	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a357	32 aa e2 	2 . . 
	ld a,(BALL_BRS_X1)		;a35a	3a 8d e5 	: . . 
	bit 7,(iy+BALL_TABLE_IDX_X_SPEED)		;a35d	fd cb 03 7e 	. . . ~ 
	jp z,la367h		;a361	ca 67 a3 	. g . 
	ld a,(BALL_BRS_X2)		;a364	3a 8b e5 	: . . 
la367h:
	ld (BRICK_COL),a		;a367	32 ab e2 	2 . . 

	call CHECK_DOUBLE_IMPACT		;a36a	cd 70 a6 	. p . 
	jp nc,la3afh		;a36d	d2 af a3 	. . . 

	ld a,(BALL_BRS_Y2)		;a370	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a373	32 aa e2 	2 . . 
	ld a,(BALL_BRS_X1)		;a376	3a 8d e5 	: . . 
	ld (BRICK_COL),a		;a379	32 ab e2 	2 . . 

	call THERE_IS_A_BRICK		;a37c	cd a8 ad 	. . . 
	jp nc,la38eh		;a37f	d2 8e a3 	. . . 

	call DOUBLE_BRICK_IMPACT_2		;a382	cd 10 a8 	. . . 
	call BALL_VERTICAL_BOUNCE		;a385	cd 5b 9b 	. [ . 
	call DO_BRICK_ACTION		;a388	cd 05 aa 	. . . 
	jp all_done		;a38b	c3 d0 a3 	. . . 

la38eh:
	ld a,(BALL_BRS_Y2)		;a38e	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a391	32 aa e2 	2 . . 
	ld a,(BALL_BRS_X2)		;a394	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a397	32 ab e2 	2 . . 

	call THERE_IS_A_BRICK		;a39a	cd a8 ad 	. . . 
	jp nc,la3ach		;a39d	d2 ac a3 	. . . 
    
    ; Double impact
	call DOUBLE_BRICK_IMPACT_1		;a3a0	cd 01 a9 	. . . 

	call BALL_HORIZONTAL_BOUNCE		;a3a3	cd 80 9b 	. . . 
	call DO_BRICK_ACTION		;a3a6	cd 05 aa 	. . . 
	jp all_done		;a3a9	c3 d0 a3 	. . . 
la3ach:
	jp all_done		;a3ac	c3 d0 a3 	. . . 

la3afh:
	ld a,(BALL_BRS_Y2)		;a3af	3a 8a e5 	: . . 
	ld (BRICK_ROW),a		;a3b2	32 aa e2 	2 . . 
	ld a,(BALL_BRS_X2)		;a3b5	3a 8b e5 	: . . 
	ld (BRICK_COL),a		;a3b8	32 ab e2 	2 . . 

	call THERE_IS_A_BRICK		;a3bb	cd a8 ad 	. . . 
	jp nc,la3cdh		;a3be	d2 cd a3 	. . . 

    ; Double impact
	call DOUBLE_BRICK_IMPACT_2		;a3c1	cd 10 a8 	. . . 

	call BALL_VERTICAL_BOUNCE		;a3c4	cd 5b 9b 	. [ . 
	call DO_BRICK_ACTION		;a3c7	cd 05 aa 	. . . 
	jp all_done		;a3ca	c3 d0 a3 	. . . 
la3cdh:
	jp all_done		;a3cd	c3 d0 a3 	. . . 
all_done:
	ret			;a3d0	c9 	. 

; ToDo
; Among other things, this function writes:
;   COMPUTED_HIT_Y_NEG
;   COMPUTED_HIT_Y
;   COMPUTED_HIT_X_NEG
;   COMPUTED_HIT_X
;   COMPUTED_Y_SPEED
;   COMPUTED_X_SPEED
GET_COMPUTED_VARS:
	ld hl,COMPUTED_HIT_COUNTER		;a3d1	21 41 e5 	! A . 
	ld (hl), 0		;a3d4	36 00 	6 . 
	ld de,COMPUTED_X_SPEED		;a3d6	11 42 e5 	. B . 
	ld bc, 2		;a3d9	01 02 00 	. . . 
	ldir		;a3dc	ed b0 	. . 

	ld a,(BRICK_COL)		;a3de	3a ab e2 	: . . 
	sla a		;a3e1	cb 27 	. ' 
	sla a		;a3e3	cb 27 	. ' 
	sla a		;a3e5	cb 27 	. ' 
	sla a		;a3e7	cb 27 	. ' 
	ld b, 16		;a3e9	06 10 	. . 
	bit 7,(iy+BALL_TABLE_IDX_X_SPEED)		;a3eb	fd cb 03 7e 	. . . ~ 
	jp nz,la3f4h		;a3ef	c2 f4 a3 	. . . 
	ld b, 12		;a3f2	06 0c 	. . 
la3f4h:
	add a,b			;a3f4	80 	. 
	ld (COMPUTED_HIT_X),a		;a3f5	32 c7 e2 	2 . . 
	add a, 15		;a3f8	c6 0f 	. . 
	ld (COMPUTED_HIT_X_NEG),a		;a3fa	32 c6 e2 	2 . . 
	ld a,(iy+BALL_TABLE_IDX_SKEWNESS)		;a3fd	fd 7e 06 	. ~ . 
	bit 7,a		;a400	cb 7f 	. ␡ 
	jp z,la407h		;a402	ca 07 a4 	. . . 
	neg		;a405	ed 44 	. D 
la407h:
	dec a			;a407	3d 	= 
	sla a		;a408	cb 27 	. ' 
	ld l,a			;a40a	6f 	o 
	ld h,0		;a40b	26 00 	& . 
	ld de,TBL_a86c		;a40d	11 6c a8 	. l . 
	add hl,de			;a410	19 	. 
	ld a,(hl)			;a411	7e 	~ 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a412	fd cb 02 7e 	. . . ~ 
	jp nz,la41bh		;a416	c2 1b a4 	. . . 
	neg		;a419	ed 44 	. D 
la41bh:
	ld (COMPUTED_X_SPEED),a		;a41b	32 42 e5 	2 B . 
	inc hl			;a41e	23 	# 
	ld a,(hl)			;a41f	7e 	~ 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a420	fd cb 02 7e 	. . . ~ 
	jp nz,la429h		;a424	c2 29 a4 	. ) . 
	neg		;a427	ed 44 	. D 
la429h:
	ld (COMPUTED_Y_SPEED),a		;a429	32 43 e5 	2 C . 
	ld a,(COMPUTED_X_SPEED)		;a42c	3a 42 e5 	: B . 
	ld b,a			;a42f	47 	G 
	ld a,(BALL_X_MINUS_SPEED)		;a430	3a 87 e5 	: . . 
    
	ld hl,COMPUTED_HIT_X_NEG		            ;a433	21 c6 e2
	bit 7,(iy+BALL_TABLE_IDX_X_SPEED)		;a436	fd cb 03 7e
	jp nz,la452h		                    ;a43a	c2 52 a4    Jump if negative
	ld hl,COMPUTED_HIT_X		            ;a43d	21 c7 e2
	inc (hl)			;a440	34 	4 
la441h:
	push af			;a441	f5 	. 
	ld a,(COMPUTED_HIT_COUNTER)		;a442	3a 41 e5 	: A . 
	inc a			;a445	3c 	< 
	ld (COMPUTED_HIT_COUNTER),a		;a446	32 41 e5 	2 A . 
	pop af			;a449	f1 	. 
	add a,b			;a44a	80 	. 
	cp (hl)			;a44b	be  Compare with COMPUTED_HIT_X
	jp nc,la463h		;a44c	d2 63 a4 	. c . 
	jp la441h		;a44f	c3 41 a4 	. A . 
la452h:
	push af			;a452	f5 	. 
	ld a,(COMPUTED_HIT_COUNTER)		;a453	3a 41 e5 	: A . 
	inc a			;a456	3c 	< 
	ld (COMPUTED_HIT_COUNTER),a		;a457	32 41 e5 	2 A . 
	pop af			;a45a	f1 	. 
	add a,b			;a45b	80 	. 
	cp (hl)			;a45c	be 	. 
	jp c,la464h		;a45d	da 64 a4 	. d . 
	jp la452h		;a460	c3 52 a4 	. R . 
la463h:
	dec (hl)			;a463	35 	5 

la464h:
	ld a,(COMPUTED_HIT_COUNTER)	            ;a464	3a 41 e5
	ld b,a			            ;a467	47 	G       B = counter
	ld a,(COMPUTED_Y_SPEED)		;a468	3a 43 e5
	ld c,a			            ;a46b	4f          C = COMPUTED_Y_SPEED
	neg		                    ;a46c	ed 44       A = -COMPUTED_Y_SPEED

; A = -COMPUTED_Y_SPEED + counter * COMPUTED_Y_SPEED = (counter - 1) * COMPUTED_Y_SPEED
la46eh:
	add a,c         ;a46e	81
	djnz la46eh		;a46f	10 fd

	ld b,a			                ;a471	47          B = (counter - 1) * COMPUTED_Y_SPEED
	ld a,(BALL_Y_MINUS_SPEED)		;a472	3a 86 e5    A = BALL_Y_MINUS_SPEED
	add a,b			                ;a475	80          A = BALL_Y_MINUS_SPEED + (counter - 1) * COMPUTED_Y_SPEED
    
	ld b,a			                ;a476	47          B = BALL_Y_MINUS_SPEED + (counter - 1) * COMPUTED_Y_SPEED
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a477	fd cb 02 7e 	. . . ~ 
	jp nz,la49ch		;a47b	c2 9c a4 	. . . 

	ld a,(BRICK_ROW)    ;a47e	3a aa e2
	sla a		        ;a481	cb 27
	sla a		        ;a483	cb 27
	sla a		        ;a485	cb 27
	add a, 18		    ;a487	c6 12   A = 8*BRICK_ROW + 18
    
	cp b			    ;a489	b8      Compare with BALL_Y_MINUS_SPEED + (counter - 1) * COMPUTED_Y_SPEED
	jp c,la492h		    ;a48a	da 92 a4

	inc a			;a48d	3c 	< 
	ld b,a			;a48e	47 	G 
	jp la4bbh		;a48f	c3 bb a4 	. . . 
la492h:
	add a, 8		;a492	c6 08 	. . 
	cp b			;a494	b8 	. 
	jp nc,la4bbh		;a495	d2 bb a4 	. . . 
	ld b,a			;a498	47 	G 
	jp la4bbh		;a499	c3 bb a4 	. . . 
la49ch:
	ld a,(BRICK_ROW)		;a49c	3a aa e2 	: . . 
	sla a		;a49f	cb 27 	. ' 
	sla a		;a4a1	cb 27 	. ' 
	sla a		;a4a3	cb 27 	. ' 
	add a, 31		;a4a5	c6 1f 	. . 
	cp b			;a4a7	b8 	. 
	jp nc,la4afh		;a4a8	d2 af a4 	. . . 
	ld b,a			;a4ab	47 	G 
	jp la4bbh		;a4ac	c3 bb a4 	. . . 
la4afh:
	sub 8		;a4af	d6 08 	. . 
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
    
	ld a,(COMPUTED_HIT_X)		            ;a4bf	3a c7 e2
	bit 7,(iy+BALL_TABLE_IDX_X_SPEED)		;a4c2	fd cb 03 7e
	jp z,la4cch		                        ;a4c6	ca cc a4    Jump if positive
	ld a,(COMPUTED_HIT_X_NEG)		            ;a4c9	3a c6 e2
la4cch:
	ld (BRICK_HIT_COL),a		;a4cc	32 3d e5 	2 = . 
	ld hl,COMPUTED_HIT_COUNTER		;a4cf	21 41 e5 	! A . 
	ld (hl), 0		;a4d2	36 00 	6 . 
	ld de,COMPUTED_X_SPEED		;a4d4	11 42 e5 	. B . 
	ld bc, 2		;a4d7	01 02 00 	. . . 
	ldir		;a4da	ed b0 	. . 
	ld a,(BRICK_ROW)		;a4dc	3a aa e2 	: . . 
	sla a		;a4df	cb 27 	. ' 
	sla a		;a4e1	cb 27 	. ' 
	sla a		;a4e3	cb 27 	. ' 
	ld b, 24		;a4e5	06 18 	. . 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a4e7	fd cb 02 7e 	. . . ~ 
	jp nz,la4f0h		;a4eb	c2 f0 a4 	. . . 
	ld b, 19		;a4ee	06 13 	. . 
la4f0h:
	add a,b			;a4f0	80 	. 
	ld (COMPUTED_HIT_Y_NEG),a		;a4f1	32 c4 e2 	2 . . 
	add a, 7		;a4f4	c6 07 	. . 
	ld (COMPUTED_HIT_Y),a		;a4f6	32 c5 e2 	2 . . 
	ld a,(iy+BALL_TABLE_IDX_SKEWNESS)		;a4f9	fd 7e 06 	. ~ . 
	bit 7,a		;a4fc	cb 7f 	. ␡ 
	jp z,la503h		;a4fe	ca 03 a5 	. . . 
	neg		;a501	ed 44 	. D 
la503h:
	dec a			;a503	3d 	= 
	sla a		;a504	cb 27 	. ' 
	ld l,a			;a506	6f 	o 
	ld h,0		;a507	26 00 	& . 
	ld de,TBL_a86c		;a509	11 6c a8 	. l . 
	add hl,de			;a50c	19 	. 
	ld a,(hl)			;a50d	7e 	~ 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a50e	fd cb 02 7e 	. . . ~ 
	jp nz,la517h		;a512	c2 17 a5 	. . . 
	neg		;a515	ed 44 	. D 
la517h:
	ld (COMPUTED_X_SPEED),a		;a517	32 42 e5 	2 B . 
	inc hl			;a51a	23 	# 
	ld a,(hl)			;a51b	7e 	~ 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a51c	fd cb 02 7e 	. . . ~ 
	jp nz,la525h		;a520	c2 25 a5 	. % . 
	neg		;a523	ed 44 	. D 
la525h:
	ld (COMPUTED_Y_SPEED),a		;a525	32 43 e5 	2 C . 
	ld a,(COMPUTED_Y_SPEED)		;a528	3a 43 e5 	: C . 
	ld b,a			;a52b	47 	G 
	ld a,(BALL_Y_MINUS_SPEED)		;a52c	3a 86 e5 	: . . 
la52fh:
	ld hl,COMPUTED_HIT_Y		;a52f	21 c5 e2 	! . . 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a532	fd cb 02 7e 	. . . ~ 
	jp nz,la54eh		;a536	c2 4e a5 	. N . 
	ld hl,COMPUTED_HIT_Y_NEG		;a539	21 c4 e2 	! . . 
	inc (hl)			;a53c	34 	4 
la53dh:
	push af			;a53d	f5 	. 
	ld a,(COMPUTED_HIT_COUNTER)		;a53e	3a 41 e5 	: A . 
	inc a			;a541	3c 	< 
	ld (COMPUTED_HIT_COUNTER),a		;a542	32 41 e5 	2 A . 
	pop af			;a545	f1 	. 
	add a,b			;a546	80 	. 
	cp (hl)			;a547	be  Compare with COMPUTED_HIT_Y_NEG
	jp nc,la55fh		;a548	d2 5f a5 	. _ . 
	jp la53dh		;a54b	c3 3d a5 	. = . 
la54eh:
	push af			;a54e	f5 	. 
	ld a,(COMPUTED_HIT_COUNTER)		;a54f	3a 41 e5 	: A . 
	inc a			;a552	3c 	< 
	ld (COMPUTED_HIT_COUNTER),a		;a553	32 41 e5 	2 A . 
	pop af			;a556	f1 	. 
	add a,b			;a557	80 	. 
	cp (hl)			;a558	be 	. 
	jp c,la560h		;a559	da 60 a5 	. ` . 
	jp la54eh		;a55c	c3 4e a5 	. N . 
la55fh:
	dec (hl)			;a55f	35 	5 
la560h:
	ld a,(COMPUTED_HIT_COUNTER)		;a560	3a 41 e5 	: A . 
	ld b,a			;a563	47 	G 
	ld a,(COMPUTED_X_SPEED)		;a564	3a 42 e5 	: B . 
	ld c,a			;a567	4f 	O 
	neg		;a568	ed 44 	. D 
la56ah:
	add a,c			;a56a	81 	. 
	djnz la56ah		;a56b	10 fd 	. . 
	ld b,a			;a56d	47 	G 
	ld a,(BALL_X_MINUS_SPEED)		;a56e	3a 87 e5 	: . . 
	add a,b			;a571	80 	. 
	ld (BRICK_HIT_ROW),a		;a572	32 3c e5 	2 < . 
	ld b,a			;a575	47 	G 
	ld a, 188		;a576	3e bc 	> . 
	bit 7,(iy+BALL_TABLE_IDX_X_SPEED)		;a578	fd cb 03 7e 	. . . ~ 
	jp z,la589h		;a57c	ca 89 a5 	. . . 
	ld a, 15		;a57f	3e 0f 	> . 
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
	ld hl,COMPUTED_HIT_COUNTER		;a591	21 41 e5 	! A . 
	ld (hl), 0		;a594	36 00 	6 . 
	ld de,COMPUTED_X_SPEED		;a596	11 42 e5 	. B . 
	ld bc, 2		;a599	01 02 00 	. . . 
	ldir		;a59c	ed b0 	. . 
	ld a,(BRICK_ROW)		;a59e	3a aa e2 	: . . 
	sla a		;a5a1	cb 27 	. ' 
	sla a		;a5a3	cb 27 	. ' 
	sla a		;a5a5	cb 27 	. ' 
	ld b, 24		;a5a7	06 18 	. . 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a5a9	fd cb 02 7e 	. . . ~ 
	jp nz,la5b2h		;a5ad	c2 b2 a5 	. . . 
	ld b, 19		;a5b0	06 13 	. . 
la5b2h:
	add a,b			;a5b2	80 	. 
	ld (COMPUTED_HIT_Y_NEG),a		;a5b3	32 c4 e2 	2 . . 
	add a, 7		;a5b6	c6 07 	. . 
	ld (COMPUTED_HIT_Y),a		;a5b8	32 c5 e2 	2 . . 
	ld a,(iy+BALL_TABLE_IDX_SKEWNESS)		;a5bb	fd 7e 06 	. ~ . 
	bit 7,a		;a5be	cb 7f 	. ␡ 
	jp z,la5c5h		;a5c0	ca c5 a5 	. . . 
	neg		;a5c3	ed 44 	. D 
la5c5h:
	dec a			;a5c5	3d 	= 
	sla a		;a5c6	cb 27 	. ' 
	ld l,a			;a5c8	6f 	o 
	ld h, 0		;a5c9	26 00 	& . 
	ld de,TBL_a86c		;a5cb	11 6c a8 	. l . 
	add hl,de			;a5ce	19 	. 
	ld a,(hl)			;a5cf	7e 	~ 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a5d0	fd cb 02 7e 	. . . ~ 
	jp nz,la5d9h		;a5d4	c2 d9 a5 	. . . 
	neg		;a5d7	ed 44 	. D 
la5d9h:
	ld (COMPUTED_X_SPEED),a		;a5d9	32 42 e5 	2 B . 
	inc hl			;a5dc	23 	# 
	ld a,(hl)			;a5dd	7e 	~ 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a5de	fd cb 02 7e 	. . . ~ 
	jp nz,la5e7h		;a5e2	c2 e7 a5 	. . . 
	neg		;a5e5	ed 44 	. D 
la5e7h:
	ld (COMPUTED_Y_SPEED),a		;a5e7	32 43 e5 	2 C . 
	ld a,(COMPUTED_Y_SPEED)		;a5ea	3a 43 e5 	: C . 
	ld b,a			;a5ed	47 	G 
	ld a,(BALL_Y_MINUS_SPEED)		;a5ee	3a 86 e5 	: . . 
	ld hl,COMPUTED_HIT_Y		;a5f1	21 c5 e2 	! . . 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a5f4	fd cb 02 7e 	. . . ~ 
	jp nz,la610h		;a5f8	c2 10 a6 	. . . 
	ld hl,COMPUTED_HIT_Y_NEG		;a5fb	21 c4 e2 	! . . 
	inc (hl)			;a5fe	34 	4 
la5ffh:
	push af			;a5ff	f5 	. 
	ld a,(COMPUTED_HIT_COUNTER)		;a600	3a 41 e5 	: A . 
	inc a			;a603	3c 	< 
	ld (COMPUTED_HIT_COUNTER),a		;a604	32 41 e5 	2 A . 
	pop af			;a607	f1 	. 
	add a,b			;a608	80 	. 
	cp (hl)			;a609	be 	. 
	jp nc,la621h		;a60a	d2 21 a6 	. ! . 
	jp la5ffh		;a60d	c3 ff a5 	. . . 
la610h:
	push af			;a610	f5 	. 
	ld a,(COMPUTED_HIT_COUNTER)		;a611	3a 41 e5 	: A . 
	inc a			;a614	3c 	< 
	ld (COMPUTED_HIT_COUNTER),a		;a615	32 41 e5 	2 A . 
	pop af			;a618	f1 	. 
	add a,b			;a619	80 	. 
	cp (hl)			;a61a	be 	. 
	jp c,la622h		;a61b	da 22 a6 	. " . 
	jp la610h		;a61e	c3 10 a6 	. . . 
la621h:
	dec (hl)			;a621	35 	5 
la622h:
	ld a,(COMPUTED_HIT_COUNTER)		;a622	3a 41 e5 	: A . 
	ld b,a			;a625	47 	G 
	ld a,(COMPUTED_X_SPEED)		;a626	3a 42 e5 	: B . 
	ld c,a			;a629	4f 	O 
	neg		;a62a	ed 44 	. D 
la62ch:
	add a,c			;a62c	81 	. 
	djnz la62ch		;a62d	10 fd 	. . 
	ld b,a			;a62f	47 	G 
	ld a,(BALL_X_MINUS_SPEED)		;a630	3a 87 e5 	: . . 
	add a,b			;a633	80 	. 
	ld b,a			;a634	47 	G 
	ld a, -68		;a635	3e bc 	> . 
	bit 7,(iy+BALL_TABLE_IDX_X_SPEED)		;a637	fd cb 03 7e 	. . . ~ 
	jp z,la64eh		;a63b	ca 4e a6 	. N . 
	ld a, 15		;a63e	3e 0f 	> . 
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
	ld (BRICK_HIT_COL),a		;a65c	32 3d e5 	2 = . 
	ld a,(COMPUTED_HIT_Y_NEG)		;a65f	3a c4 e2 	: . . 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a662	fd cb 02 7e 	. . . ~ 
	jp z,la66ch		;a666	ca 6c a6 	. l . 
	ld a,(COMPUTED_HIT_Y)		;a669	3a c5 e2 	: . . 
la66ch:
	ld (BRICK_HIT_ROW),a		;a66c	32 3c e5 	2 < . 
	ret			;a66f	c9 	. 

; Check for an incoming double impact of the ball at two bricks
CHECK_DOUBLE_IMPACT:
    ; IY: BALL_TABLE
    
    ; Clear 2 variables
	ld hl,COMPUTED_HIT_COUNTER		;a670	21 41 e5 	! A . 
	ld (hl), 0		;a673	36 00 	6 . 
	ld de,COMPUTED_X_SPEED		;a675	11 42 e5 	. B . 
	ld bc, 2		    ;a678	01 02 00 	. . . 
	ldir		        ;a67b	ed b0 	. . 

	ld a,(BRICK_ROW)		;a67d	3a aa e2 	: . . 
	sla a		;a680	cb 27 	. ' 
	sla a		;a682	cb 27 	. ' 
	sla a		;a684	cb 27 	. ' 
	ld b, 19		;a686	06 13 	. . 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a688	fd cb 02 7e 	. . . ~ 
	jp z,la691h		;a68c	ca 91 a6 	. . . 
	ld b, 24		;a68f	06 18 	. . 
la691h:
	add a,b			;a691	80 	. 
	ld (COMPUTED_HIT_Y_NEG),a		;a692	32 c4 e2 	2 . . 
	add a, 7		;a695	c6 07 	. . 
	ld (COMPUTED_HIT_Y),a		;a697	32 c5 e2 	2 . . 

	ld a,(iy+BALL_TABLE_IDX_SKEWNESS)		;a69a	fd 7e 06 	. ~ . 
	bit 7,a		;a69d	cb 7f 	. ␡ 
	jp z,la6a4h		;a69f	ca a4 a6 	. . . 
	neg		;a6a2	ed 44 	. D 
la6a4h:
	dec a			;a6a4	3d 	= 
	sla a		;a6a5	cb 27 	. ' 
	ld l,a			;a6a7	6f 	o 
	ld h, 0		;a6a8	26 00 	& . 
	ld de,TBL_a86c		;a6aa	11 6c a8 	. l . 
	add hl,de			;a6ad	19 	. 
	ld a,(hl)			;a6ae	7e 	~ 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a6af	fd cb 02 7e 	. . . ~ 
	jp nz,la6b8h		;a6b3	c2 b8 a6 	. . . 
	neg		;a6b6	ed 44 	. D 
la6b8h:
	ld (COMPUTED_X_SPEED),a		;a6b8	32 42 e5 	2 B . 
	inc hl			;a6bb	23 	# 
	ld a,(hl)			;a6bc	7e 	~ 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a6bd	fd cb 02 7e 	. . . ~ 
	jp nz,la6c6h		;a6c1	c2 c6 a6 	. . . 
	neg		;a6c4	ed 44 	. D 
la6c6h:
	ld (COMPUTED_Y_SPEED),a		;a6c6	32 43 e5 	2 C . 
	jp la6cch		;a6c9	c3 cc a6 	. . . 
la6cch:
	ld a,(COMPUTED_Y_SPEED)		;a6cc	3a 43 e5 	: C . 
	ld b,a			;a6cf	47 	G 
	ld a,(BALL_Y_MINUS_SPEED)		;a6d0	3a 86 e5 	: . . 
	ld hl,COMPUTED_HIT_Y		;a6d3	21 c5 e2 	! . . 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a6d6	fd cb 02 7e 	. . . ~ 
	jp nz,la6f2h		;a6da	c2 f2 a6 	. . . 
	ld hl,COMPUTED_HIT_Y_NEG		;a6dd	21 c4 e2 	! . . 
	inc (hl)			;a6e0	34 	4 
la6e1h:
	push af			;a6e1	f5 	. 
	ld a,(COMPUTED_HIT_COUNTER)		;a6e2	3a 41 e5 	: A . 
	inc a			;a6e5	3c 	< 
	ld (COMPUTED_HIT_COUNTER),a		;a6e6	32 41 e5 	2 A . 
	pop af			;a6e9	f1 	. 
	add a,b			;a6ea	80 	. 
	cp (hl)			;a6eb	be 	. 
	jp nc,la703h		;a6ec	d2 03 a7 	. . . 
	jp la6e1h		;a6ef	c3 e1 a6 	. . . 
la6f2h:
	push af			;a6f2	f5 	. 
	ld a,(COMPUTED_HIT_COUNTER)		;a6f3	3a 41 e5 	: A . 
	inc a			;a6f6	3c 	< 
	ld (COMPUTED_HIT_COUNTER),a		;a6f7	32 41 e5 	2 A . 
	pop af			;a6fa	f1 	. 
	add a,b			;a6fb	80 	. 
	cp (hl)			;a6fc	be 	. 
	jp c,la704h		;a6fd	da 04 a7 	. . . 
	jp la6f2h		;a700	c3 f2 a6 	. . . 
la703h:
	dec (hl)			;a703	35 	5 
la704h:
	ld a,(COMPUTED_HIT_COUNTER)		;a704	3a 41 e5 	: A . 
	ld b,a			;a707	47 	G 
	ld a,(COMPUTED_X_SPEED)		;a708	3a 42 e5 	: B . 
	ld c,a			;a70b	4f 	O 
	neg		;a70c	ed 44 	. D 
la70eh:
	add a,c			;a70e	81 	. 
	djnz la70eh		;a70f	10 fd 	. . 
	ld b,a			;a711	47 	G 
	ld a,(BALL_X_MINUS_SPEED)		;a712	3a 87 e5 	: . . 
	add a,b			;a715	80 	. 
	ld b,a			;a716	47 	G 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a717	fd cb 02 7e 	. . . ~ 
	jp nz,la797h		;a71b	c2 97 a7 	. . . 
	bit 7,(iy+BALL_TABLE_IDX_X_SPEED)		;a71e	fd cb 03 7e 	. . . ~ 
	jp nz,la75eh		;a722	c2 5e a7 	. ^ . 
	ld a,(BRICK_COL)		;a725	3a ab e2 	: . . 
	sla a		;a728	cb 27 	. ' 
	sla a		;a72a	cb 27 	. ' 
	sla a		;a72c	cb 27 	. ' 
	sla a		;a72e	cb 27 	. ' 
	add a, 12		;a730	c6 0c 	. . 
	cp b			;a732	b8 	. 
	jp c,la73bh		;a733	da 3b a7 	. ; . 
	ld b,a			;a736	47 	G 
	scf			;a737	37 	7 
	jp la751h		;a738	c3 51 a7 	. Q . 
la73bh:
	add a, 31		;a73b	c6 1f 	. . 
	cp b			;a73d	b8 	. 
	jp nc,la746h		;a73e	d2 46 a7 	. F . 
	ld b,a			;a741	47 	G 
	or a			;a742	b7 	. 
	jp la751h		;a743	c3 51 a7 	. Q . 
la746h:
	sub 16		;a746	d6 10 	. . 
	cp b			;a748	b8 	. 
	jp c,la750h		;a749	da 50 a7 	. P . 
	scf			;a74c	37 	7 
	jp la751h		;a74d	c3 51 a7 	. Q . 
la750h:
	or a			;a750	b7 	. 
la751h:
    ; Set the row and col of the brick hit
    ; Row: (COMPUTED_HIT_Y_NEG)
    ; col: reg. B
	push af			;a751	f5 	. 
	ld a,(COMPUTED_HIT_Y_NEG)		;a752	3a c4 e2 	: . . 
	ld (BRICK_HIT_ROW),a		;a755	32 3c e5 	2 < . 
	ld a,b			;a758	78 	x 
	ld (BRICK_HIT_COL),a		;a759	32 3d e5 	2 = . 
	pop af			;a75c	f1 	. 
	ret			;a75d	c9 	. 

la75eh:
	ld a,(BRICK_COL)		;a75e	3a ab e2 	: . . 
	sla a		;a761	cb 27 	. ' 
	sla a		;a763	cb 27 	. ' 
	sla a		;a765	cb 27 	. ' 
	sla a		;a767	cb 27 	. ' 
	add a,16		;a769	c6 10 	. . 
	cp b			;a76b	b8 	. 
	jp c,la774h		;a76c	da 74 a7 	. t . 
	ld b,a			;a76f	47 	G 
	or a			;a770	b7 	. 
	jp la78ah		;a771	c3 8a a7 	. . . 
la774h:
	add a, 31		;a774	c6 1f 	. . 
	cp b			;a776	b8 	. 
	jp nc,la77fh		;a777	d2 7f a7 	. ␡ . 
	ld b,a			;a77a	47 	G 
	scf			;a77b	37 	7 
	jp la78ah		;a77c	c3 8a a7 	. . . 
la77fh:
	sub 16		;a77f	d6 10 	. . 
	cp b			;a781	b8 	. 
	jp c,la789h		;a782	da 89 a7 	. . . 
	scf			;a785	37 	7 
	jp la78ah		;a786	c3 8a a7 	. . . 
la789h:
	or a			;a789	b7 	. 
la78ah:
    ; Set the row and col of the brick hit
    ; Row: (COMPUTED_HIT_Y_NEG)
    ; col: reg. B
	push af			;a78a	f5 	. 
	ld a,(COMPUTED_HIT_Y_NEG)		;a78b	3a c4 e2 	: . . 
	ld (BRICK_HIT_ROW),a		;a78e	32 3c e5 	2 < . 
	ld a,b			;a791	78 	x 
	ld (BRICK_HIT_COL),a		;a792	32 3d e5 	2 = . 
	pop af			;a795	f1 	. 
	ret			;a796	c9 	. 

la797h:
	bit 7,(iy+BALL_TABLE_IDX_X_SPEED)		;a797	fd cb 03 7e 	. . . ~ 
	jp nz,la7d7h		;a79b	c2 d7 a7 	. . . 
	ld a,(BRICK_COL)		;a79e	3a ab e2 	: . . 
	sla a		;a7a1	cb 27 	. ' 
	sla a		;a7a3	cb 27 	. ' 
	sla a		;a7a5	cb 27 	. ' 
	sla a		;a7a7	cb 27 	. ' 
	add a, 12		;a7a9	c6 0c 	. . 
	cp b			;a7ab	b8 	. 
	jp c,la7b4h		;a7ac	da b4 a7 	. . . 
	ld b,a			;a7af	47 	G 
	scf			;a7b0	37 	7 
	jp la7cah		;a7b1	c3 ca a7 	. . . 
la7b4h:
	add a, 31		;a7b4	c6 1f 	. . 
	cp b			;a7b6	b8 	. 
	jp nc,la7bfh		;a7b7	d2 bf a7 	. . . 
	ld b,a			;a7ba	47 	G 
	or a			;a7bb	b7 	. 
	jp la7cah		;a7bc	c3 ca a7 	. . . 
la7bfh:
	sub 16		;a7bf	d6 10 	. . 
	cp b			;a7c1	b8 	. 
	jp c,la7c9h		;a7c2	da c9 a7 	. . . 
	scf			;a7c5	37 	7 
	jp la7cah		;a7c6	c3 ca a7 	. . . 
la7c9h:
	or a			;a7c9	b7 	. 
la7cah:
	push af			;a7ca	f5 	. 
	ld a,(COMPUTED_HIT_Y)		;a7cb	3a c5 e2 	: . . 
	ld (BRICK_HIT_ROW),a		;a7ce	32 3c e5 	2 < . 
	ld a,b			;a7d1	78 	x 
	ld (BRICK_HIT_COL),a		;a7d2	32 3d e5 	2 = . 
	pop af			;a7d5	f1 	. 
	ret			;a7d6	c9 	. 
la7d7h:
	ld a,(BRICK_COL)		;a7d7	3a ab e2 	: . . 
	sla a		;a7da	cb 27 	. ' 
	sla a		;a7dc	cb 27 	. ' 
	sla a		;a7de	cb 27 	. ' 
	sla a		;a7e0	cb 27 	. ' 
	add a, 16		;a7e2	c6 10 	. . 
	cp b			;a7e4	b8 	. 
	jp c,la7edh		;a7e5	da ed a7 	. . . 
	ld b,a			;a7e8	47 	G 
	or a			;a7e9	b7 	. 
	jp la803h		;a7ea	c3 03 a8 	. . . 
la7edh:
	add a,31		;a7ed	c6 1f 	. . 
	cp b			;a7ef	b8 	. 
	jp nc,la7f8h		;a7f0	d2 f8 a7 	. . . 
	ld b,a			;a7f3	47 	G 
	scf			;a7f4	37 	7 
	jp la803h		;a7f5	c3 03 a8 	. . . 
la7f8h:
	sub 16		;a7f8	d6 10 	. . 
	cp b			;a7fa	b8 	. 
	jp c,la802h		;a7fb	da 02 a8 	. . . 
	scf			;a7fe	37 	7 
	jp la803h		;a7ff	c3 03 a8 	. . . 
la802h:
	or a			;a802	b7 	. 
la803h:
	push af			;a803	f5 	. 
	ld a,(COMPUTED_HIT_Y)		;a804	3a c5 e2 	: . . 
	ld (BRICK_HIT_ROW),a		;a807	32 3c e5 	2 < . 
	ld a,b			;a80a	78 	x 
	ld (BRICK_HIT_COL),a		;a80b	32 3d e5 	2 = . 
	pop af			;a80e	f1 	. 
	ret			;a80f	c9 	. 

; Perform a double impact of the ball at two bricks
DOUBLE_BRICK_IMPACT_2:
	ld hl,COMPUTED_HIT_COUNTER		;a810	21 41 e5 	! A . 
	ld (hl), 0		;a813	36 00 	6 . 
	ld de,COMPUTED_X_SPEED		;a815	11 42 e5 	. B . 
	ld bc, 2		;a818	01 02 00 	. . . 
	ldir		;a81b	ed b0 	. . 
	ld a,(BRICK_ROW)		;a81d	3a aa e2 	: . . 
	sla a		;a820	cb 27 	. ' 
	sla a		;a822	cb 27 	. ' 
	sla a		;a824	cb 27 	. ' 
	ld b, 24		;a826	06 18 	. . 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a828	fd cb 02 7e 	. . . ~ 
	jp nz,la831h		;a82c	c2 31 a8 	. 1 . 
	ld b, 19		;a82f	06 13 	. . 
la831h:
	add a,b			;a831	80 	. 
	ld (COMPUTED_HIT_Y_NEG),a		;a832	32 c4 e2 	2 . . 
	add a, 7		;a835	c6 07 	. . 
	ld (COMPUTED_HIT_Y),a		;a837	32 c5 e2 	2 . . 
	ld a,(iy+BALL_TABLE_IDX_SKEWNESS)		;a83a	fd 7e 06 	. ~ . 
	bit 7,a		;a83d	cb 7f 	. ␡ 
	jp z,la844h		;a83f	ca 44 a8 	. D . 
	neg		;a842	ed 44 	. D 
la844h:
	dec a			;a844	3d 	= 
	sla a		;a845	cb 27 	. ' 
	ld l,a			;a847	6f 	o 
	ld h, 0		;a848	26 00 	& . 
	ld de,TBL_a86c		;a84a	11 6c a8 	. l . 
	add hl,de			;a84d	19 	. 
	ld a,(hl)			;a84e	7e 	~ 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a84f	fd cb 02 7e 	. . . ~ 
	jp nz,la858h		;a853	c2 58 a8 	. X . 
	neg		;a856	ed 44 	. D 
la858h:
	ld (COMPUTED_X_SPEED),a		;a858	32 42 e5 	2 B . 
	inc hl			;a85b	23 	# 
	ld a,(hl)			;a85c	7e 	~ 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a85d	fd cb 02 7e 	. . . ~ 
	jp nz,la866h		;a861	c2 66 a8 	. f . 
	neg		;a864	ed 44 	. D 
la866h:
	ld (COMPUTED_Y_SPEED),a		;a866	32 43 e5 	2 C . 
	jp la87ch		;a869	c3 7c a8 	. | .       ToDo: rewrite code

; ToDo
; Values are read and put at COMPUTED_X_SPEED
TBL_a86c:   ;a86c
    db 4, -1, 2, -1, 1, -1, 1, -2, -1, -2, -1, -1, -2, -1,  -4, -1

la87ch:
	ld a, (0xe543)      ;a87c    
	ld b,a			;a87f	47 	G 
	ld a,(BALL_Y_MINUS_SPEED)		;a880	3a 86 e5 	: . . 
	ld hl,COMPUTED_HIT_Y		;a883	21 c5 e2 	! . . 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a886	fd cb 02 7e 	. . . ~ 
	jp nz,la8a2h		;a88a	c2 a2 a8 	. . . 
	ld hl,COMPUTED_HIT_Y_NEG		;a88d	21 c4 e2 	! . . 
	inc (hl)			;a890	34 	4 
la891h:
	push af			;a891	f5 	. 
	ld a,(COMPUTED_HIT_COUNTER)		;a892	3a 41 e5 	: A . 
	inc a			;a895	3c 	< 
	ld (COMPUTED_HIT_COUNTER),a		;a896	32 41 e5 	2 A . 
	pop af			;a899	f1 	. 
	add a,b			;a89a	80 	. 
	cp (hl)			;a89b	be 	. 
	jp nc,la8b3h		;a89c	d2 b3 a8 	. . . 
	jp la891h		;a89f	c3 91 a8 	. . . 
la8a2h:
	push af			;a8a2	f5 	. 
	ld a,(COMPUTED_HIT_COUNTER)		;a8a3	3a 41 e5 	: A . 
	inc a			;a8a6	3c 	< 
	ld (COMPUTED_HIT_COUNTER),a		;a8a7	32 41 e5 	2 A . 
	pop af			;a8aa	f1 	. 
	add a,b			;a8ab	80 	. 
	cp (hl)			;a8ac	be 	. 
	jp c,la8b4h		;a8ad	da b4 a8 	. . . 
	jp la8a2h		;a8b0	c3 a2 a8 	. . . 
la8b3h:
	dec (hl)			;a8b3	35 	5 
la8b4h:
	ld a,(COMPUTED_HIT_COUNTER)		;a8b4	3a 41 e5 	: A . 
	ld b,a			;a8b7	47 	G 
	ld a,(COMPUTED_X_SPEED)		;a8b8	3a 42 e5 	: B . 
	ld c,a			;a8bb	4f 	O 
	neg		;a8bc	ed 44 	. D 
la8beh:
	add a,c			;a8be	81 	. 
	djnz la8beh		;a8bf	10 fd 	. . 
	ld b,a			;a8c1	47 	G 
	ld a,(BALL_X_MINUS_SPEED)		;a8c2	3a 87 e5 	: . . 
	add a,b			;a8c5	80 	. 
	ld b,a			;a8c6	47 	G 
	ld a,(BRICK_COL)		;a8c7	3a ab e2 	: . . 
	sla a		;a8ca	cb 27 	. ' 
	sla a		;a8cc	cb 27 	. ' 
	sla a		;a8ce	cb 27 	. ' 
	sla a		;a8d0	cb 27 	. ' 
	ld c, 17		;a8d2	0e 11 	. . 
	bit 7,(iy+BALL_TABLE_IDX_X_SPEED)		;a8d4	fd cb 03 7e 	. . . ~ 
	jp nz,la8ddh		;a8d8	c2 dd a8 	. . . 
	ld c, 12		;a8db	0e 0c 	. . 
la8ddh:
	add a,c			;a8dd	81 	. 
	cp b			;a8de	b8 	. 
	jp c,la8e6h		;a8df	da e6 a8 	. . . 
	ld b,a			;a8e2	47 	G 
	jp la8edh		;a8e3	c3 ed a8 	. . . 
la8e6h:
	add a, 15		;a8e6	c6 0f 	. . 
	cp b			;a8e8	b8 	. 
	jp nc,la8edh		;a8e9	d2 ed a8 	. . . 
	ld b,a			;a8ec	47 	G 
la8edh:
	ld (ix+SPR_PARAMS_IDX_X),b		;a8ed	dd 70 01 	. p . 
	ld a,(COMPUTED_HIT_Y_NEG)		;a8f0	3a c4 e2 	: . . 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a8f3	fd cb 02 7e 	. . . ~ 
	jp z,la8fdh		;a8f7	ca fd a8 	. . . 
	ld a,(COMPUTED_HIT_Y)		;a8fa	3a c5 e2 	: . . 
la8fdh:
	ld (ix+SPR_PARAMS_IDX_Y),a		;a8fd	dd 77 00 	. w . 
	ret			;a900	c9 	. 


; Perform a double impact of the ball at two bricks
;
; This function remove two bricks at the same time when the ball is going to their joint.
; When the balls goes down left.
DOUBLE_BRICK_IMPACT_1:
    ; Clear two variables
	ld hl,COMPUTED_HIT_COUNTER		;a901	21 41 e5
	ld (hl), 0		;a904	36 00
	ld de,COMPUTED_X_SPEED		;a906	11 42 e5
	ld bc, 2		    ;a909	01 02 00
	ldir		        ;a90c	ed b0
    
    ; A = 16*BRICK_COL
	ld a,(BRICK_COL)	;a90e	3a ab e2
	sla a		        ;a911	cb 27
	sla a		        ;a913	cb 27
	sla a		        ;a915	cb 27
	sla a		        ;a917	cb 27

    ; If SPEED_X < 0 then B=16 else B=13
    ; This sets the left or right side of the brick depending on the
    ; direction of the ball.
	ld b, 16		                    ;a919	06 10
	bit 7,(iy+BALL_TABLE_IDX_X_SPEED)	;a91b	fd cb 03 7e
	jp nz,la924h		                ;a91f	c2 24 a9    Jump if negative
	ld b, 12		                    ;a922	06 0c
la924h:
    ; COMPUTED_HIT_X <-- 16*BRICK_COL + B = 2*8*BRICK_COL + B
    ; This is in char coordinates.
	add a,b			        ;a924	80
	ld (COMPUTED_HIT_X),a	;a925	32 c7 e2

	add a, 15		                ;a928	c6 0f
	ld (COMPUTED_HIT_X_NEG),a		;a92a	32 c6 e2

    ; A = |skewness|
	ld a,(iy+BALL_TABLE_IDX_SKEWNESS)		;a92d	fd 7e 06
	bit 7,a		                            ;a930	cb 7f
	jp z,la937h		                        ;a932	ca 37 a9    Jump if positive
	neg		                                ;a935	ed 44
la937h:
	dec a		;a937	3d
	sla a		;a938	cb 27   A = 2*(skewness - 1)
la93ah:
	ld l,a		;a93a	6f
	ld h, 0		;a93b	26 00   HL = 2*(skewness - 1)

	ld de,TBL_a86c		;a93d	11 6c a8
	add hl,de			;a940	19          HL = TBL_a86c + 2*(skewness - 1)
	ld a,(hl)			;a941	7e          A = TBL_a86c[2*(skewness - 1)]
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a942	fd cb 02 7e
	jp nz,la94bh		;a946	c2 4b a9
	neg		            ;a949	ed 44
    ; A = TBL_a86c[2*(skewness - 1)]
la94bh:
	; Set COMPUTED_X_SPEED
    ld (COMPUTED_X_SPEED),a		;a94b	32 42 e5 	2 B . 

    ; Read next value
	inc hl			                        ;a94e	23
	ld a,(hl)			                    ;a94f	7e
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a950	fd cb 02 7e
	jp nz,la959h		                    ;a954	c2 59 a9
	neg		                                ;a957	ed 44
la959h:
    ; Set COMPUTED_Y_SPEED
	ld (COMPUTED_Y_SPEED),a		;a959	32 43 e5
    
	ld a,(COMPUTED_X_SPEED)		            ;a95c	3a 42 e5
	ld b,a			                ;a95f	47
	ld a,(BALL_X_MINUS_SPEED)		;a960	3a 87 e5 	: . . 
	ld hl,COMPUTED_HIT_X_NEG		;a963	21 c6 e2 	! . . 
	bit 7,(iy+BALL_TABLE_IDX_X_SPEED)		;a966	fd cb 03 7e 	. . . ~ 
	jp nz,la982h		;a96a	c2 82 a9 	. . . 
	ld hl,COMPUTED_HIT_X		;a96d	21 c7 e2 	! . . 
	inc (hl)			;a970	34 	4 
la971h:
	push af			;a971	f5 	. 
	ld a,(COMPUTED_HIT_COUNTER)		;a972	3a 41 e5 	: A . 
	inc a			;a975	3c 	< 
	ld (COMPUTED_HIT_COUNTER),a		;a976	32 41 e5 	2 A . 
	pop af			;a979	f1 	. 
	add a,b			;a97a	80 	. 
	cp (hl)			;a97b	be 	. 
	jp nc,la993h		;a97c	d2 93 a9 	. . . 
	jp la971h		;a97f	c3 71 a9 	. q . 
la982h:
	push af			;a982	f5 	. 
	ld a,(COMPUTED_HIT_COUNTER)		;a983	3a 41 e5 	: A . 
	inc a			;a986	3c 	< 
	ld (COMPUTED_HIT_COUNTER),a		;a987	32 41 e5 	2 A . 
	pop af			;a98a	f1 	. 
	add a,b			;a98b	80 	. 
	cp (hl)			;a98c	be 	. 
	jp c,la994h		;a98d	da 94 a9 	. . . 
	jp la982h		;a990	c3 82 a9 	. . . 
la993h:
	dec (hl)			;a993	35 	5 
la994h:
	ld a,(COMPUTED_HIT_COUNTER)		;a994	3a 41 e5 	: A . 
	ld b,a			;a997	47 	G 
	ld a,(COMPUTED_Y_SPEED)		;a998	3a 43 e5 	: C . 
	ld c,a			;a99b	4f 	O 
	neg		;a99c	ed 44 	. D 
la99eh:
	add a,c			;a99e	81 	. 
	djnz la99eh		;a99f	10 fd 	. . 

	ld b,a			;a9a1	47 	G 
	ld a,(BALL_Y_MINUS_SPEED)		;a9a2	3a 86 e5 	: . . 
	add a,b			;a9a5	80 	. 
	ld b,a			;a9a6	47 	G 
	bit 7,(iy+BALL_TABLE_IDX_Y_SPEED)		;a9a7	fd cb 02 7e 	. . . ~ 
	jp nz,la9cch		;a9ab	c2 cc a9 	. . . 
	ld a,(BRICK_ROW)		;a9ae	3a aa e2 	: . . 
	sla a		;a9b1	cb 27 	. ' 
	sla a		;a9b3	cb 27 	. ' 
	sla a		;a9b5	cb 27 	. ' 
	add a, 20		;a9b7	c6 14 	. . 
	cp b			;a9b9	b8 	. 
	jp c,la9c1h		;a9ba	da c1 a9 	. . . 
	ld b,a			;a9bd	47 	G 
	jp la9f1h		;a9be	c3 f1 a9 	. . . 
la9c1h:
	add a, 8		;a9c1	c6 08 	. . 
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
	add a, 31		;a9d5	c6 1f 	. . 
	cp b			;a9d7	b8 	. 
	jp nc,la9e0h		;a9d8	d2 e0 a9 	. . . 
	inc a			;a9db	3c 	< 
	ld b,a			;a9dc	47 	G 
	jp la9f1h		;a9dd	c3 f1 a9 	. . . 
la9e0h:
	sub 8		;a9e0	d6 08 	. . 
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
	ld (ix+SPR_PARAMS_IDX_Y),b		;a9f1	dd 70 00 	. p . 

	ld a,(COMPUTED_HIT_X)		;a9f4	3a c7 e2 	: . . 
	bit 7,(iy+BALL_TABLE_IDX_X_SPEED)		;a9f7	fd cb 03 7e 	. . . ~ 
	jp z,laa01h		;a9fb	ca 01 aa 	. . . 
	ld a,(COMPUTED_HIT_X_NEG)		;a9fe	3a c6 e2 	: . . 
laa01h:
	ld (ix+SPR_PARAMS_IDX_X),a		;aa01	dd 77 01 	. w . 
	ret			;aa04	c9 	. 
