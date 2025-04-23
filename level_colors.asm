
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
