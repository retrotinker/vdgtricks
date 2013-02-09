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

	nam	paltest1
	ttl	Display all eight colors in graphics mode on Color Computer

LOAD	equ	$1e00

	org	LOAD

START	lda	#$ff	Setup DP register
	tfr	a,dp
	setdp	$ff

	orcc	#$50	Disable interrupts

	ldx	#$0600	Preload "rainbow" image data
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

VINIT	clr	$ffc5	Setup G3C video mode at address $0600
	clr	$ffc7
	lda	#$c8
	sta	$ff22

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
VSYNC	ldb	#$45	Count lines during vblank and vertical borders
HCOUNT	tst	$ff00
	sync

	decb
	bne	HCOUNT

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

	tst	$ff00	Wait for next hsync interrupt
	sync

VLOOP	jmp	VSYNC

	END	START
