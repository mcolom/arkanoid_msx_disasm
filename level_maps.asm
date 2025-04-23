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
	call m,0x7f00		;6639	fc 00 7f 	. .  
	ret p			;663c	f0 	. 
	ld bc,0c0ffh		;663d	01 ff c0 	. . . 
	rlca			;6640	07 	. 
	rst 38h			;6641	ff 	. 
	nop			;6642	00 	. 
	rra			;6643	1f 	. 
	call m,0x7f00		;6644	fc 00 7f 	. .  
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
	call m,0x833f		;6685	fc 3f 83 	. ? . 
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
	ld bc,0x80ff		;66bb	01 ff 80 	. . . 
	nop			;66be	00 	. 
	nop			;66bf	00 	. 
	nop			;66c0	00 	. 
	ld bc,020ffh		;66c1	01 ff 20 	. .   
	dec h			;66c4	25 	% 
	call p,0x95a2		;66c5	f4 a2 95 	. . . 
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
	jp 0x7ff8		;674c	c3 f8 7f 	. .  
	rrca			;674f	0f 	. 
	pop hl			;6750	e1 	. 
	call m,0x873f		;6751	fc 3f 87 	. ? . 
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
	ld hl,0x9109		;67c2	21 09 91 	! . . 
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
	call m,0x8007		;680f	fc 07 80 	. . . 
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

