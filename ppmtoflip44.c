/*
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
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <float.h>

#include "palette.h"
#include "colors.h"

#define PPM_HORIZ_PIXELS	128
#define PPM_VERT_PIXELS		192

struct pixmap24 {
	struct rgb pixel[PPM_VERT_PIXELS][PPM_HORIZ_PIXELS];
} __attribute__ ((packed));

struct pixmap24 inmap1, inmap2;

#define PIXELS_PER_SGVAL	4
#define SGVALS_PER_LINE		(PPM_HORIZ_PIXELS / PIXELS_PER_SGVAL)

unsigned char sgvbuf[PPM_VERT_PIXELS][SGVALS_PER_LINE];

#define PIXELS_PER_BYTE		4

unsigned char g6cbuf[PPM_VERT_PIXELS][PPM_HORIZ_PIXELS / PIXELS_PER_BYTE];

#define LINES_PER_PIXEL		(192 / PPM_VERT_PIXELS)
#define BLOCKS_PER_LINE		8
#define PIXELS_PER_BLOCK	(PPM_HORIZ_PIXELS / BLOCKS_PER_LINE)
#define BYTES_PER_BLOCK		(PIXELS_PER_BLOCK / PIXELS_PER_BYTE)

int colorset[PPM_VERT_PIXELS][BLOCKS_PER_LINE];

struct rgb_err {
	int8_t r, g, b;
};

struct blockdata {
	int colorset;
	struct rgb_err error;
};

/*
 * Use 25 of the available SG values
 *	8 colors x 3 non-zero patterns
 *	1 pattern used for "double black"
 */
struct {
	struct rgb left;
	struct rgb right;
	uint8_t val;
} sgval[25];

void usage(char *prg)
{
	printf("Usage: %s infile outfile\n", prg);
}

struct yiq {
	float y, i, q;
};

float yiq_distance(struct rgb c1, struct rgb c2)
{
	struct yiq y1, y2;
	float yd, id, qd;

	y1.y = 0.299000*c1.r + 0.587000*c1.g + 0.114000*c1.b;
	y1.i = 0.595716*c1.r - 0.274453*c1.g - 0.321263*c1.b;
	y1.q = 0.211456*c1.r - 0.522591*c1.g + 0.311135*c1.b;

	y2.y = 0.299000*c2.r + 0.587000*c2.g + 0.114000*c2.b;
	y2.i = 0.595716*c2.r - 0.274453*c2.g - 0.321263*c2.b;
	y2.q = 0.211456*c2.r - 0.522591*c2.g + 0.311135*c2.b;

	yd = y1.y - y2.y;
	id = y1.i - y2.i;
	qd = y1.q - y2.q;

	return (yd * yd) + (id * id) + (qd * qd);
}

inline uint8_t add_clamp(uint8_t a, int16_t b)
{
	int16_t tmp = a + b;

	if (tmp < 0)
		return 0;

	if (tmp > 255)
		return 255;

	return tmp;
}

void init_sgvals(void)
{
	int color, colorset, pattern;
	int off;

	/* preset to all black for all entries */
	memset(sgval, 0, sizeof(sgval));

	/* walk through each pattern for each color */
	for (pattern = 1; pattern <= 3; pattern++) {
		for (colorset = 0; colorset < 2; colorset++) {
			for (color = 0; color < 4; color++) {
				off = (pattern - 1) * 8 +
					colorset * 4 + color;
				sgval[off].val = 0x80 |
					(colorset << 6) | (color << 4);
				if (pattern & 2) {
					sgval[off].val |= 0x0a;
					sgval[off].left =
						palette[colorset][color];
				}
				if (pattern & 1) {
					sgval[off].val |= 0x05;
					sgval[off].right =
						palette[colorset][color];
				}
			}
		}
	}

	/* represent a double black pixel with the last entry */
	sgval[24].val = 0x80;
}

struct rgb_err pick_sgval(int line, int offset, struct rgb_err error)
{
	int i, pixbase, bestval = -1;
	struct rgb left, right;
	float errmin, curerr; 

	errmin = FLT_MAX;
	pixbase = offset * PIXELS_PER_SGVAL;

	/* average the two leftmost pixels */
	left.r = (inmap1.pixel[line][pixbase].r +
		  inmap1.pixel[line][pixbase+1].r) / 2;
	left.g = (inmap1.pixel[line][pixbase].g +
		  inmap1.pixel[line][pixbase+1].g) / 2;
	left.b = (inmap1.pixel[line][pixbase].b +
		  inmap1.pixel[line][pixbase+1].b) / 2;

	/* average the two rightmost pixels */
	right.r = (inmap1.pixel[line][pixbase+2].r +
		   inmap1.pixel[line][pixbase+3].r) / 2;
	right.g = (inmap1.pixel[line][pixbase+2].g +
		   inmap1.pixel[line][pixbase+3].g) / 2;
	right.b = (inmap1.pixel[line][pixbase+2].b +
		   inmap1.pixel[line][pixbase+3].b) / 2;

	/*
	 * adjust for in-bound quantization error
	 * using the Atkinson dithering algorithm
	 */
	add_clamp(left.r, 0.1250 * error.r);
	add_clamp(left.g, 0.1250 * error.g);
	add_clamp(left.b, 0.1250 * error.b);

	add_clamp(right.r, 0.1250 * error.r);
	add_clamp(right.g, 0.1250 * error.g);
	add_clamp(right.b, 0.1250 * error.b);

	/*
	 * walk the SG values looking for best match,
	 * and factor-in quantization error along the way
	 */
	for (i = 0; i < 25; i++) {
		struct rgb tmpright;

		curerr = yiq_distance(left, sgval[i].left);

		tmpright = right;

		add_clamp(tmpright.r, 0.1250 * (left.r - sgval[i].left.r));
		add_clamp(tmpright.g, 0.1250 * (left.g - sgval[i].left.g));
		add_clamp(tmpright.b, 0.1250 * (left.b - sgval[i].left.b));

		curerr += yiq_distance(tmpright, sgval[i].right);

		if (curerr < errmin) {
			errmin = curerr;
			bestval = i;
		}
	}

	/* write the chosen value to the output map */
	sgvbuf[line][offset] = sgval[bestval].val;

	/*
	 * Feed error from this pass back into
	 * input for next pass...
	 */
	inmap2.pixel[line][pixbase].r =
		add_clamp(inmap2.pixel[line][pixbase].r,
				inmap2.pixel[line][pixbase].r -
					sgval[bestval].left.r);
	inmap2.pixel[line][pixbase].g =
		add_clamp(inmap2.pixel[line][pixbase].g,
				inmap2.pixel[line][pixbase].g -
					sgval[bestval].left.g);
	inmap2.pixel[line][pixbase].b =
		add_clamp(inmap2.pixel[line][pixbase].b,
				inmap2.pixel[line][pixbase].b -
					sgval[bestval].left.b);
	inmap2.pixel[line][pixbase + 1].r =
		add_clamp(inmap2.pixel[line][pixbase + 1].r,
				inmap2.pixel[line][pixbase + 1].r -
					sgval[bestval].left.r);
	inmap2.pixel[line][pixbase + 1].g =
		add_clamp(inmap2.pixel[line][pixbase + 1].g,
				inmap2.pixel[line][pixbase + 1].g -
					sgval[bestval].left.g);
	inmap2.pixel[line][pixbase + 1].b =
		add_clamp(inmap2.pixel[line][pixbase + 1].b,
				inmap2.pixel[line][pixbase + 1].b -
					sgval[bestval].left.b);
	
	inmap2.pixel[line][pixbase + 2].r =
		add_clamp(inmap2.pixel[line][pixbase + 2].r,
				inmap2.pixel[line][pixbase + 2].r -
					sgval[bestval].right.r);
	inmap2.pixel[line][pixbase + 2].g =
		add_clamp(inmap2.pixel[line][pixbase + 2].g,
				inmap2.pixel[line][pixbase + 2].g -
					sgval[bestval].right.g);
	inmap2.pixel[line][pixbase + 2].b =
		add_clamp(inmap2.pixel[line][pixbase + 2].b,
				inmap2.pixel[line][pixbase + 2].b -
					sgval[bestval].right.b);
	inmap2.pixel[line][pixbase + 3].r =
		add_clamp(inmap2.pixel[line][pixbase + 3].r,
				inmap2.pixel[line][pixbase + 3].r -
					sgval[bestval].right.r);
	inmap2.pixel[line][pixbase + 3].g =
		add_clamp(inmap2.pixel[line][pixbase + 3].g,
				inmap2.pixel[line][pixbase + 3].g -
					sgval[bestval].right.g);
	inmap2.pixel[line][pixbase + 3].b =
		add_clamp(inmap2.pixel[line][pixbase + 3].b,
				inmap2.pixel[line][pixbase + 3].b -
					sgval[bestval].right.b);

	if (line == PPM_VERT_PIXELS - 1)
		goto out;

	/*
	 * distribute quantization error to the pixels on the
	 * next line, splitting the error for each half of the
	 * SG value to the corresponding pair of input pixels
	 */
	error.r = left.r - sgval[bestval].left.r;
	error.g = left.g - sgval[bestval].left.g;
	error.b = left.b - sgval[bestval].left.b;

	add_clamp(right.r, 0.1250 * (left.r - sgval[bestval].left.r));
	add_clamp(right.g, 0.1250 * (left.g - sgval[bestval].left.g));
	add_clamp(right.b, 0.1250 * (left.b - sgval[bestval].left.b));

	if (offset) {
		inmap1.pixel[line + 1][pixbase - 2].r = 
			add_clamp(inmap1.pixel[line + 1][pixbase - 2].r,
					0.1250 * error.r);
		inmap1.pixel[line + 1][pixbase - 2].g = 
			add_clamp(inmap1.pixel[line + 1][pixbase - 2].g,
					0.1250 * error.r);
		inmap1.pixel[line + 1][pixbase - 2].b = 
			add_clamp(inmap1.pixel[line + 1][pixbase - 2].b,
					0.1250 * error.r);
		inmap1.pixel[line + 1][pixbase - 1].r = 
			add_clamp(inmap1.pixel[line + 1][pixbase - 1].r,
					0.1250 * error.r);
		inmap1.pixel[line + 1][pixbase - 1].g = 
			add_clamp(inmap1.pixel[line + 1][pixbase - 1].g,
					0.1250 * error.r);
		inmap1.pixel[line + 1][pixbase - 1].b = 
			add_clamp(inmap1.pixel[line + 1][pixbase - 1].b,
					0.1250 * error.r);
	}
	inmap1.pixel[line + 1][pixbase].r = 
		add_clamp(inmap1.pixel[line + 1][pixbase].r,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase].g = 
		add_clamp(inmap1.pixel[line + 1][pixbase].g,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase].b = 
		add_clamp(inmap1.pixel[line + 1][pixbase].b,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase + 1].r = 
		add_clamp(inmap1.pixel[line + 1][pixbase + 1].r,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase + 1].g = 
		add_clamp(inmap1.pixel[line + 1][pixbase + 1].g,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase + 1].b = 
		add_clamp(inmap1.pixel[line + 1][pixbase + 1].b,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase + 2].r = 
		add_clamp(inmap1.pixel[line + 1][pixbase + 2].r,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase + 2].g = 
		add_clamp(inmap1.pixel[line + 1][pixbase + 2].g,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase + 2].b = 
		add_clamp(inmap1.pixel[line + 1][pixbase + 2].b,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase + 3].r = 
		add_clamp(inmap1.pixel[line + 1][pixbase + 3].r,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase + 3].g = 
		add_clamp(inmap1.pixel[line + 1][pixbase + 3].g,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase + 3].b = 
		add_clamp(inmap1.pixel[line + 1][pixbase + 3].b,
				0.1250 * error.r);

	if (line < PPM_VERT_PIXELS - 2) {
		inmap1.pixel[line + 2][pixbase].r = 
			add_clamp(inmap1.pixel[line + 2][pixbase].r,
					0.1250 * error.r);
		inmap1.pixel[line + 2][pixbase].g = 
			add_clamp(inmap1.pixel[line + 2][pixbase].g,
					0.1250 * error.r);
		inmap1.pixel[line + 2][pixbase].b = 
			add_clamp(inmap1.pixel[line + 2][pixbase].b,
					0.1250 * error.r);
		inmap1.pixel[line + 2][pixbase + 1].r = 
			add_clamp(inmap1.pixel[line + 2][pixbase + 1].r,
					0.1250 * error.r);
		inmap1.pixel[line + 2][pixbase + 1].g = 
			add_clamp(inmap1.pixel[line + 2][pixbase + 1].g,
					0.1250 * error.r);
		inmap1.pixel[line + 2][pixbase + 1].b = 
			add_clamp(inmap1.pixel[line + 2][pixbase + 1].b,
					0.1250 * error.r);
	}

	error.r = right.r - sgval[bestval].right.r;
	error.g = right.g - sgval[bestval].right.g;
	error.b = right.b - sgval[bestval].right.b;

	inmap1.pixel[line + 1][pixbase].r = 
		add_clamp(inmap1.pixel[line + 1][pixbase].r,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase].g = 
		add_clamp(inmap1.pixel[line + 1][pixbase].g,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase].b = 
		add_clamp(inmap1.pixel[line + 1][pixbase].b,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase + 1].r = 
		add_clamp(inmap1.pixel[line + 1][pixbase + 1].r,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase + 1].g = 
		add_clamp(inmap1.pixel[line + 1][pixbase + 1].g,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase + 1].b = 
		add_clamp(inmap1.pixel[line + 1][pixbase + 1].b,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase + 2].r = 
		add_clamp(inmap1.pixel[line + 1][pixbase + 2].r,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase + 2].g = 
		add_clamp(inmap1.pixel[line + 1][pixbase + 2].g,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase + 2].b = 
		add_clamp(inmap1.pixel[line + 1][pixbase + 2].b,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase + 3].r = 
		add_clamp(inmap1.pixel[line + 1][pixbase + 3].r,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase + 3].g = 
		add_clamp(inmap1.pixel[line + 1][pixbase + 3].g,
				0.1250 * error.r);
	inmap1.pixel[line + 1][pixbase + 3].b = 
		add_clamp(inmap1.pixel[line + 1][pixbase + 3].b,
				0.1250 * error.r);
	if (offset < 31) {
		inmap1.pixel[line + 1][pixbase + 4].r = 
			add_clamp(inmap1.pixel[line + 1][pixbase + 4].r,
					0.1250 * error.r);
		inmap1.pixel[line + 1][pixbase + 4].g = 
			add_clamp(inmap1.pixel[line + 1][pixbase + 4].g,
					0.1250 * error.r);
		inmap1.pixel[line + 1][pixbase + 4].b = 
			add_clamp(inmap1.pixel[line + 1][pixbase + 4].b,
					0.1250 * error.r);
		inmap1.pixel[line + 1][pixbase + 5].r = 
			add_clamp(inmap1.pixel[line + 1][pixbase + 5].r,
					0.1250 * error.r);
		inmap1.pixel[line + 1][pixbase + 5].g = 
			add_clamp(inmap1.pixel[line + 1][pixbase + 5].g,
					0.1250 * error.r);
		inmap1.pixel[line + 1][pixbase + 5].b = 
			add_clamp(inmap1.pixel[line + 1][pixbase + 5].b,
					0.1250 * error.r);
	}

	if (line < PPM_VERT_PIXELS - 2) {
		inmap1.pixel[line + 2][pixbase + 2].r = 
			add_clamp(inmap1.pixel[line + 2][pixbase + 2].r,
					0.1250 * error.r);
		inmap1.pixel[line + 2][pixbase + 2].g = 
			add_clamp(inmap1.pixel[line + 2][pixbase + 2].g,
					0.1250 * error.r);
		inmap1.pixel[line + 2][pixbase + 2].b = 
			add_clamp(inmap1.pixel[line + 2][pixbase + 2].b,
					0.1250 * error.r);
		inmap1.pixel[line + 2][pixbase + 3].r = 
			add_clamp(inmap1.pixel[line + 2][pixbase + 3].r,
					0.1250 * error.r);
		inmap1.pixel[line + 2][pixbase + 3].g = 
			add_clamp(inmap1.pixel[line + 2][pixbase + 3].g,
					0.1250 * error.r);
		inmap1.pixel[line + 2][pixbase + 3].b = 
			add_clamp(inmap1.pixel[line + 2][pixbase + 3].b,
					0.1250 * error.r);
	}

out:
	/*
	 * return outbound quantization
	 * error for current line
	 */
	return error;
}

struct blockdata process_block(int line, int block, struct rgb_err error)
{
	float distance[2];
	unsigned char c, data[2][BYTES_PER_BLOCK];
	int i, j, k, choice;
	int hpixel, hoffset = block * PIXELS_PER_BLOCK;
	int chosen[2][PIXELS_PER_BLOCK];
	struct blockdata rc;
	struct rgb workline[2][PIXELS_PER_BLOCK];
	struct rgb errout[2];

	for (i = 0; i < 2; i++) {
		for (j = 0; j < PIXELS_PER_BLOCK; j++)
			workline[i][j] = inmap2.pixel[line][hoffset + j];

		workline[i][0].r =
			add_clamp(workline[i][0].r, 0.1250 * error.r);
		workline[i][0].g =
			add_clamp(workline[i][0].g, 0.1250 * error.g);
		workline[i][0].b =
			add_clamp(workline[i][0].b, 0.1250 * error.b);

		workline[i][1].r =
			add_clamp(workline[i][1].r, 0.1250 * error.r);
		workline[i][1].g =
			add_clamp(workline[i][1].g, 0.1250 * error.g);
		workline[i][1].b =
			add_clamp(workline[i][1].b, 0.1250 * error.b);
	}

	for (i = 0; i < 2; i++) {
		distance[i] = 0.0;
		for (j = 0; j < BYTES_PER_BLOCK; j++) {
			data[i][j] = 0;
			for (k = 0; k < PIXELS_PER_BYTE; k++) {
				hpixel = j * PIXELS_PER_BYTE + k;
				c = color[i][RGB(workline[i][hpixel].r,
						 workline[i][hpixel].g,
						 workline[i][hpixel].b)];
				chosen[i][hpixel] = c;

				distance[i] += yiq_distance(palette[i][c],
							workline[i][hpixel]);

				data[i][j] = (data[i][j] << 2) | (c & 0x03);

				if (j == BYTES_PER_BLOCK - 1 &&
				    k == PIXELS_PER_BYTE - 1)
					continue;

				workline[i][hpixel + 1].r =
					add_clamp(workline[i][hpixel + 1].r, 
						  0.1250 * (workline[i][hpixel].r -
							    palette[i][c].r));
				workline[i][hpixel + 1].g =
					add_clamp(workline[i][hpixel + 1].g, 
						  0.1250 * (workline[i][hpixel].g -
							    palette[i][c].g));
				workline[i][hpixel + 1].b =
					add_clamp(workline[i][hpixel + 1].b, 
						  0.1250 * (workline[i][hpixel].b -
							    palette[i][c].b));

				workline[i][hpixel + 2].r =
					add_clamp(workline[i][hpixel + 2].r, 
						  0.1250 * (workline[i][hpixel].r -
							    palette[i][c].r));
				workline[i][hpixel + 2].g =
					add_clamp(workline[i][hpixel + 2].g, 
						  0.1250 * (workline[i][hpixel].g -
							    palette[i][c].g));
				workline[i][hpixel + 2].b =
					add_clamp(workline[i][hpixel + 2].b, 
						  0.1250 * (workline[i][hpixel].b -
							    palette[i][c].b));
			}
		}
		errout[i].r = workline[i][hpixel].r - palette[i][c].r;
		errout[i].g = workline[i][hpixel].g - palette[i][c].g;
		errout[i].b = workline[i][hpixel].b - palette[i][c].b;
	}

	/* choose set with least error */
	if (distance[1] < distance[0])
		choice = 1;
	else
		choice = 0;

	/* set values in g6cbuf */
	for (j = 0; j < BYTES_PER_BLOCK; j++)
		g6cbuf[line][block * BYTES_PER_BLOCK + j] = data[choice][j];

	/* skip further error dispersal if on last line */
	if (line == PPM_VERT_PIXELS - 1)
		goto exit;

	/* perturb the colors in the next line based on the this one's error */
	i = choice;
	for (j = 0; j < PIXELS_PER_BLOCK; j++) {
		if (block != 0) {
			inmap2.pixel[line + 1][hoffset + j - 1].r =
				add_clamp(inmap2.pixel[line + 1][hoffset + j - 1].r,
					  0.1250 * (workline[i][j].r -
						    palette[i][chosen[i][j]].r));
			inmap2.pixel[line + 1][hoffset + j - 1].g =
				add_clamp(inmap2.pixel[line + 1][hoffset + j - 1].g,
					  0.1250 * (workline[i][j].g -
						    palette[i][chosen[i][j]].g));
			inmap2.pixel[line + 1][hoffset + j - 1].b =
				add_clamp(inmap2.pixel[line + 1][hoffset + j - 1].b,
					  0.1250 * (workline[i][j].b -
						    palette[i][chosen[i][j]].b));
		}

		inmap2.pixel[line + 1][hoffset + j].r =
			add_clamp(inmap2.pixel[line + 1][hoffset + j].r,
				  0.1250 * (workline[i][j].r -
					    palette[i][chosen[i][j]].r));
		inmap2.pixel[line + 1][hoffset + j].g =
			add_clamp(inmap2.pixel[line + 1][hoffset + j].g,
				  0.1250 * (workline[i][j].g -
					    palette[i][chosen[i][j]].g));
		inmap2.pixel[line + 1][hoffset + j].b =
			add_clamp(inmap2.pixel[line + 1][hoffset + j].b,
				  0.1250 * (workline[i][j].b -
					    palette[i][chosen[i][j]].b));

		if (block == BLOCKS_PER_LINE - 1 && j == PIXELS_PER_BLOCK - 1)
			continue;

		inmap2.pixel[line + 1][hoffset + j + 1].r =
			add_clamp(inmap2.pixel[line + 1][hoffset + j + 1].r,
				  0.1250 * (workline[i][j].r -
					    palette[i][chosen[i][j]].r));
		inmap2.pixel[line + 1][hoffset + j + 1].g =
			add_clamp(inmap2.pixel[line + 1][hoffset + j + 1].g,
				  0.1250 * (workline[i][j].g -
					    palette[i][chosen[i][j]].g));
		inmap2.pixel[line + 1][hoffset + j + 1].b =
			add_clamp(inmap2.pixel[line + 1][hoffset + j + 1].b,
				  0.1250 * (workline[i][j].b -
					    palette[i][chosen[i][j]].b));
	}

	/* skip further error dispersal if on next to last line */
	if (line == PPM_VERT_PIXELS - 2)
		goto exit;

	for (j = 0; j < PIXELS_PER_BLOCK; j++) {
		inmap2.pixel[line + 2][hoffset + j].r =
			add_clamp(inmap2.pixel[line + 2][hoffset + j].r,
				  0.1250 * (workline[i][j].r -
					    palette[i][chosen[i][j]].r));
		inmap2.pixel[line + 2][hoffset + j].g =
			add_clamp(inmap2.pixel[line + 2][hoffset + j].g,
				  0.1250 * (workline[i][j].g -
					    palette[i][chosen[i][j]].g));
		inmap2.pixel[line + 2][hoffset + j].b =
			add_clamp(inmap2.pixel[line + 2][hoffset + j].b,
				  0.1250 * (workline[i][j].b -
					    palette[i][chosen[i][j]].b));
	}

exit:
	rc.colorset = choice;
	rc.error.r = errout[choice].r;
	rc.error.g = errout[choice].g;
	rc.error.b = errout[choice].b;

	return rc;
}

int main(int argc, char *argv[])
{
	int ppmfd, outfd;
	char hdbuf;
	int i, j, k, rc, insize;
	int whitecount = 0;
	FILE *outfile;
	struct blockdata blockout;
	struct rgb_err error;

	if (argc < 3) {
		usage(argv[0]);
		exit(EXIT_FAILURE);
	}

	/* open input ppm file */
	if (!strncmp(argv[1], "-", 1))
		ppmfd = 0;
	else
		ppmfd = open(argv[1], O_RDONLY);

	/* open output file */
	if (!strncmp(argv[2], "-", 1))
		outfd = 1;
	else
		outfd = open(argv[2], O_WRONLY | O_CREAT | O_TRUNC,
				S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
	outfile = fdopen(outfd, "w");

	while (whitecount < 4) {
		if (read(ppmfd, &hdbuf, 1) != 1)
			perror("head read");
		if (hdbuf == '\n' || isblank(hdbuf)) {
			whitecount++;
			while ((whitecount < 4) &&
				(hdbuf == '\n' || isblank(hdbuf))) {
				if (read(ppmfd, &hdbuf, 1) != 1)
					perror("ppm head read");
				if (hdbuf == '#')
					while (hdbuf != '\n') {
						if (read(ppmfd, &hdbuf, 1) != 1)
							perror("ppm head read");
					}
			}
		}
	}

	insize = 0;
	do {
		rc = read(ppmfd, (char *)&inmap1+insize, sizeof(inmap1)-insize);
		if (rc < 0 && rc != EINTR) {
			perror("ppm data read");
			exit(EXIT_FAILURE);
		}
		if (rc != EINTR)
			insize += rc;
	} while (rc != 0);
	close(ppmfd);

	inmap2 = inmap1;

	init_sgvals();

	for (i = 0; i < PPM_VERT_PIXELS; i++) {
		error.r = error.g = error.b = 0;
		for (j = 0; j < SGVALS_PER_LINE; j++) {
			error = pick_sgval(i, j, error);
		}
	}

	for (i = 0; i < PPM_VERT_PIXELS; i++) {
		error.r = error.g = error.b = 0;
		for (j = 0; j < BLOCKS_PER_LINE; j++) {
			blockout = process_block(i, j, error);
			colorset[i][j] = blockout.colorset;
			error = blockout.error;
		}
	}

	fprintf(outfile, "\torg $0600\n");

	for (i = 0; i < PPM_VERT_PIXELS; i++)
		for (j = 0; j < PPM_HORIZ_PIXELS / PIXELS_PER_BYTE; j += 8) {
			fprintf(outfile,
				"\tfcb\t$%02x,$%02x,$%02x,$%02x,"
				"$%02x,$%02x,$%02x,$%02x\n",
				g6cbuf[i][j],   g6cbuf[i][j+1],
				g6cbuf[i][j+2], g6cbuf[i][j+3],
				g6cbuf[i][j+4], g6cbuf[i][j+5],
				g6cbuf[i][j+6], g6cbuf[i][j+7]);
		}

	fprintf(outfile, "\torg $1e00\n");
	fprintf(outfile, "START\tlda\t#$ff\tSetup DP register\n");
	fprintf(outfile, "\ttfr\ta,dp\n");
	fprintf(outfile, "\tsetdp\t$ff\n");
	fprintf(outfile, "\torcc\t#$50\tDisable interrupts\n");
	fprintf(outfile, "\tclr\t$ffc3\tSetup G6C video mode at address $0600\n");
	fprintf(outfile, "\tclr\t$ffc5\n");
	fprintf(outfile, "\tclr\t$ffc7\n");
	fprintf(outfile, "VSTART\tldb\t$ff01\tDisable hsync interrupt generation\n");
	fprintf(outfile, "\tandb\t#$fa\n");
	fprintf(outfile, "\tstb\t$ff01\n");
	fprintf(outfile, "\ttst\t$ff00\n");
	fprintf(outfile, "\tlda\t$ff03\tEnable vsync interrupt generation\n");
	fprintf(outfile, "\tora\t#$05\n");
	fprintf(outfile, "\tsta\t$ff03\n");
	fprintf(outfile, "\ttst\t$ff02\n");
	fprintf(outfile, "\tsync\t\tWait for vsync interrupt\n");
	fprintf(outfile, "\tanda\t#$fa\tDisable vsync interrupt generation\n");
	fprintf(outfile, "\tsta\t$ff03\n");
	fprintf(outfile, "\ttst\t$ff02\n");
	fprintf(outfile, "\torb\t#$05\tEnable hsync interrupt generation\n");
	fprintf(outfile, "\tstb\t$ff01\n");
	fprintf(outfile, "\ttst\t$ff00\n");
	fprintf(outfile, "VINIT\tclr\t$ffcc\n");
	fprintf(outfile, "\tclr\t$ffce\n");
	fprintf(outfile, "*\n");
	fprintf(outfile, "* After the program starts, vsync interrupts aren't used...\n");
	fprintf(outfile, "*\n");
	fprintf(outfile, "VSYNC\tldb\t#$45\tCount lines during vblank and vertical borders\n");
	fprintf(outfile, "HCOUNT\ttst\t$ff00\n");
	fprintf(outfile, "\tsync\n");
	fprintf(outfile, "\tdecb\n");
	fprintf(outfile, "\tbne\tHCOUNT\n");
	fprintf(outfile, "\tlda\t#$e8\tSetup CSS options for raster effects\n");
	fprintf(outfile, "\tldb\t#$e0\n");

	for (i = 0; i < PPM_VERT_PIXELS; i++) {
		for (j = 0; j < LINES_PER_PIXEL; j++) {
			fprintf(outfile, "\ttst\t$ff00\tWait for next hsync interrupt\n");
			fprintf(outfile, "\tsync\n");

			fprintf(outfile, "\tnop\t\tExtra delay for beginning of visible line\n");
			fprintf(outfile, "\tnop\n");
			fprintf(outfile, "\tnop\n");

			for (k = 0; k < BLOCKS_PER_LINE; k++) {
				if (colorset[i][k] == 0)
					fprintf(outfile, "\tstb\t$ff22\n");
				else
					fprintf(outfile, "\tsta\t$ff22\n");
			}
		}
	}

	fprintf(outfile, "\tjmp\tSGVINIT\n");

	fprintf(outfile, "\torg $3600\n");

	for (i = 0; i < PPM_VERT_PIXELS; i++)
		for (j = 0; j < SGVALS_PER_LINE; j += 8) {
			fprintf(outfile,
				"\tfcb\t$%02x,$%02x,$%02x,$%02x,"
				"$%02x,$%02x,$%02x,$%02x\n",
				sgvbuf[i][j],   sgvbuf[i][j+1],
				sgvbuf[i][j+2], sgvbuf[i][j+3],
				sgvbuf[i][j+4], sgvbuf[i][j+5],
				sgvbuf[i][j+6], sgvbuf[i][j+7]);
		}

	fprintf(outfile, "\torg $4e00\n");
	fprintf(outfile, "SGVINIT\tclr\t$ffcd\n");
	fprintf(outfile, "\tclr\t$ffcf\n");
	fprintf(outfile, "\tlda\t#$e0\n");
	fprintf(outfile, "\tsta\t$ff22\n");
	fprintf(outfile, "SGVSYNC\tldb\t#$45\tCount lines during vblank and vertical borders\n");
	fprintf(outfile, "SHCOUNT\ttst\t$ff00\n");
	fprintf(outfile, "\tsync\n");
	fprintf(outfile, "\tdecb\n");
	fprintf(outfile, "\tbne\tSHCOUNT\n");
	fprintf(outfile, "\tldb\t#$c0\n");
	fprintf(outfile, "\ttst\t$ff00\n");
	fprintf(outfile, "\tsync\n");
	fprintf(outfile, "SGVACTV\tnop\n");
	fprintf(outfile, "\tandcc\t#$ff\n");
	fprintf(outfile, "\tlda\t#$00\tNeed CSS preset for background color!\n");
	fprintf(outfile, "\tsta\t$ff22\n");
	fprintf(outfile, "\tnop\n");
	fprintf(outfile, "\tnop\n");
	fprintf(outfile, "\tnop\n");
	fprintf(outfile, "\tnop\n");
	fprintf(outfile, "\tnop\n");
	fprintf(outfile, "\tnop\n");
	fprintf(outfile, "\tnop\n");
	fprintf(outfile, "\tnop\n");
	fprintf(outfile, "\tnop\n");
	fprintf(outfile, "\tnop\n");
	fprintf(outfile, "\tnop\n");
	fprintf(outfile, "\tnop\n");
	fprintf(outfile, "\tandcc\t#$ff\n");
	fprintf(outfile, "\tlda\t#$e0\tSet for G6C mode to get chosen background!\n");
	fprintf(outfile, "\tsta\t$ff22\n");
	fprintf(outfile, "\tnop\n");
	fprintf(outfile, "\tnop\n");
	fprintf(outfile, "\tnop\n");
	fprintf(outfile, "\tnop\n");
	fprintf(outfile, "\tdecb\n");
	fprintf(outfile, "\tbne\tSGVACTV\n");
	fprintf(outfile, "* Check for user break (development only)\n");
	fprintf(outfile, "CHKUART\tlda\t$ff69\tCheck for serial port activity\n");
	fprintf(outfile, "\tbita\t#$08\n");
	fprintf(outfile, "\tbeq\tVLOOP\n");
	fprintf(outfile, "\tlda\t$ff68\n");
	fprintf(outfile, "\tjmp\t[$fffe]\tRe-enter monitor\n");
	fprintf(outfile, "VLOOP\tjmp\tVINIT\n");

	fclose(outfile);

	return 0;
}
