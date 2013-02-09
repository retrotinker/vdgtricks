*
* Copyright (c) 2012, John W. Linville <linville@tuxdriver.com>
* 
* Permission to use, copy, modify, and/or distribute this software for any
* purpose with or without fee is hereby granted, provided that the above
* copyright notice and this permission notice appear in all copies.
* 
* THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
* WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
* MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
* ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
* WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
* ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
* OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*
	nam	paltest2
	ttl	Display 44 colors using a "flicker" mode on the CoCo

LOAD	equ	$1e00

	org	LOAD

START	lda	#$ff	Setup DP register
	tfr	a,dp
	setdp	$ff

	orcc	#$50	Disable interrupts

	ldx	#$0600	Preload vertical "rainbow" image data
PSET	lda	#$ff
	sta	,x
	sta	1,x
	sta	2,x
	sta	3,x
	sta	4,x
	sta	5,x
	sta	6,x
	sta	7,x

	lda	#$aa
	sta	20,x
	sta	21,x
	sta	22,x
	sta	23,x
	sta	28,x
	sta	29,x
	sta	30,x
	sta	31,x

	lda	#$55
	sta	8,x
	sta	9,x
	sta	10,x
	sta	11,x
	sta	16,x
	sta	17,x
	sta	18,x
	sta	19,x

	clra
	sta	12,x
	sta	13,x
	sta	14,x
	sta	15,x
	sta	24,x
	sta	25,x
	sta	26,x
	sta	27,x

	leax	32,x
	cmpx	#$1200
	bne	PSET

	ldx	#$3600	Preload horizontal "rainbow" image data

	lda	#32
	ldb	#$0b
	pshs	b
	ldb	#$ef
SGLOOP0	stb	,x+
	deca
	bne	SGLOOP0
	lda	#32
	dec	,s
	bne	SGLOOP0
	leas	1,s

	lda	#28
	ldb	#$0b
	pshs	b
	ldb	#$cf
SGLOOP1	stb	,x+
	deca
	bne	SGLOOP1
	lda	#4
	ldb	#$80
SGLPEX1	stb	,x+
	deca
	bne	SGLPEX1
	lda	#28
	ldb	#$cf
	dec	,s
	bne	SGLOOP1
	leas	1,s

	lda	#24
	ldb	#$0b
	pshs	b
	ldb	#$af
SGLOOP2	stb	,x+
	deca
	bne	SGLOOP2
	lda	#8
	ldb	#$80
SGLPEX2	stb	,x+
	deca
	bne	SGLPEX2
	lda	#24
	ldb	#$af
	dec	,s
	bne	SGLOOP2
	leas	1,s

	lda	#20
	ldb	#$0b
	pshs	b
	ldb	#$df
SGLOOP3	stb	,x+
	deca
	bne	SGLOOP3
	lda	#12
	ldb	#$80
SGLPEX3	stb	,x+
	deca
	bne	SGLPEX3
	lda	#20
	ldb	#$df
	dec	,s
	bne	SGLOOP3
	leas	1,s

	lda	#16
	ldb	#$0b
	pshs	b
	ldb	#$8f
SGLOOP4	stb	,x+
	deca
	bne	SGLOOP4
	lda	#16
	ldb	#$80
SGLPEX4	stb	,x+
	deca
	bne	SGLPEX4
	lda	#16
	ldb	#$8f
	dec	,s
	bne	SGLOOP4
	leas	1,s

	lda	#12
	ldb	#$0b
	pshs	b
	ldb	#$9f
SGLOOP5	stb	,x+
	deca
	bne	SGLOOP5
	lda	#20
	ldb	#$80
SGLPEX5	stb	,x+
	deca
	bne	SGLPEX5
	lda	#12
	ldb	#$9f
	dec	,s
	bne	SGLOOP5
	leas	1,s

	lda	#8
	ldb	#$0b
	pshs	b
	ldb	#$ff
SGLOOP6	stb	,x+
	deca
	bne	SGLOOP6
	lda	#24
	ldb	#$80
SGLPEX6	stb	,x+
	deca
	bne	SGLPEX6
	lda	#8
	ldb	#$ff
	dec	,s
	bne	SGLOOP6
	leas	1,s

	lda	#4
	ldb	#$0b
	pshs	b
	ldb	#$bf
SGLOOP7	stb	,x+
	deca
	bne	SGLOOP7
	lda	#28
	ldb	#$80
SGLPEX7	stb	,x+
	deca
	bne	SGLPEX7
	lda	#4
	ldb	#$bf
	dec	,s
	bne	SGLOOP7
	leas	1,s

	lda	#32
	ldb	#$08
	pshs	b
	ldb	#$80
SGLOOP8	stb	,x+
	deca
	bne	SGLOOP8
	lda	#32
	dec	,s
	bne	SGLOOP8
	leas	1,s

VINIT	clr	$ffc5	Setup G3C video mode at address $0600
	clr	$ffc7

VSTART	ldb     $ff01	Disable hsync interrupt generation
	andb	#$fa
	stb     $ff01
	tst	$ff00

	lda     $ff03	Enable vsync interrupt generation
	ora     #$05
	sta     $ff03
	tst	$ff02

	sync		Wait for vsync interrupt

	anda	#$fa	Disable vsync interrupt generation
	sta     $ff03
	tst	$ff02

	orb     #$05	Enable hsync interrupt generation
	stb     $ff01
	tst	$ff00

*
* After the program starts, vsync interrupts aren't used...
*
	ldb	#$1f	Count lines during vblank and vertical borders
HCVSTRT	tst	$ff00
	sync
	decb
	bne	HCVSTRT

VSYNC	clr	$ffcc
	clr	$ffce

	lda	#$e8	Set for G6C mode to get chosen background!
	sta	$ff22

	ldb	#$25	Count lines during vblank and vertical borders
HCVSYNC	tst	$ff00
	sync
	decb
	bne	HCVSYNC

	lda	#$c8	Setup CSS options for raster effects
	ldb	#$c0

*
* This repeats 192 times, one for each line.  For a real bitmap,
* then each line will have individual sta/stb sequences and possibly
* with other cycle delays as appropriate for the given image.
*
	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

*
* Repeated 191 more times...
*

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	tst	$ff00	Wait for next hsync interrupt
	sync

	nop		Extra delay for beginning of visible line
	nop
	nop

	stb	$ff22	Change CSS up to 8 times per line
	sta	$ff22
	stb	$ff22
	stb	$ff22
	sta	$ff22
	stb	$ff22
	sta	$ff22
	sta	$ff22

	ldb	#$21	Count lines during vblank and vertical borders
HCVBLNK	tst	$ff00
	sync
	decb
	bne	HCVBLNK

	jmp	SGVINIT

	org	$4e00
SGVINIT	clr	$ffcd
	clr	$ffcf

SGVSYNC	ldb	#$26	Count lines during vblank and vertical borders
SHCVSYN	tst	$ff00
	sync
	decb
	bne	SHCVSYN

	ldb	#$c0
	tst	$ff00
	sync
SGVACTV	nop
	andcc	#$ff
	lda	#$08	Need CSS preset for background color!
	sta	$ff22
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	andcc	#$ff
	lda	#$c8	Set for G6C mode to get chosen background!
	sta	$ff22
	nop
	nop
	nop
	nop
	decb
	bne	SGVACTV

	ldb	#$1f	Count lines during vblank and vertical borders
SHCVBLK	tst	$ff00
	sync
	decb
	bne	SHCVBLK

VLOOP	jmp	VSYNC

	END	START
