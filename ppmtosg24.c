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

#define PPM_HORIZ_PIXELS	128
#define PPM_VERT_PIXELS		192

struct pixmap24 {
	struct rgb pixel[PPM_VERT_PIXELS][PPM_HORIZ_PIXELS];
} __attribute__ ((packed));

struct pixmap24 inmap;

#define PIXELS_PER_SGVAL	4
#define SGVALS_PER_LINE		(PPM_HORIZ_PIXELS / PIXELS_PER_SGVAL)

unsigned char cocobuf[PPM_VERT_PIXELS][SGVALS_PER_LINE];

struct rgb_err {
	int8_t r, g, b;
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
	left.r = (inmap.pixel[line][pixbase].r +
		  inmap.pixel[line][pixbase+1].r) / 2;
	left.g = (inmap.pixel[line][pixbase].g +
		  inmap.pixel[line][pixbase+1].g) / 2;
	left.b = (inmap.pixel[line][pixbase].b +
		  inmap.pixel[line][pixbase+1].b) / 2;

	/* average the two rightmost pixels */
	right.r = (inmap.pixel[line][pixbase+2].r +
		   inmap.pixel[line][pixbase+3].r) / 2;
	right.g = (inmap.pixel[line][pixbase+2].g +
		   inmap.pixel[line][pixbase+3].g) / 2;
	right.b = (inmap.pixel[line][pixbase+2].b +
		   inmap.pixel[line][pixbase+3].b) / 2;

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
	cocobuf[line][offset] = sgval[bestval].val;

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
		inmap.pixel[line + 1][pixbase - 2].r =
			add_clamp(inmap.pixel[line + 1][pixbase - 2].r,
					0.1250 * error.r);
		inmap.pixel[line + 1][pixbase - 2].g =
			add_clamp(inmap.pixel[line + 1][pixbase - 2].g,
					0.1250 * error.r);
		inmap.pixel[line + 1][pixbase - 2].b =
			add_clamp(inmap.pixel[line + 1][pixbase - 2].b,
					0.1250 * error.r);
		inmap.pixel[line + 1][pixbase - 1].r =
			add_clamp(inmap.pixel[line + 1][pixbase - 1].r,
					0.1250 * error.r);
		inmap.pixel[line + 1][pixbase - 1].g =
			add_clamp(inmap.pixel[line + 1][pixbase - 1].g,
					0.1250 * error.r);
		inmap.pixel[line + 1][pixbase - 1].b =
			add_clamp(inmap.pixel[line + 1][pixbase - 1].b,
					0.1250 * error.r);
	}
	inmap.pixel[line + 1][pixbase].r =
		add_clamp(inmap.pixel[line + 1][pixbase].r,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase].g =
		add_clamp(inmap.pixel[line + 1][pixbase].g,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase].b =
		add_clamp(inmap.pixel[line + 1][pixbase].b,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase + 1].r =
		add_clamp(inmap.pixel[line + 1][pixbase + 1].r,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase + 1].g =
		add_clamp(inmap.pixel[line + 1][pixbase + 1].g,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase + 1].b =
		add_clamp(inmap.pixel[line + 1][pixbase + 1].b,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase + 2].r =
		add_clamp(inmap.pixel[line + 1][pixbase + 2].r,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase + 2].g =
		add_clamp(inmap.pixel[line + 1][pixbase + 2].g,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase + 2].b =
		add_clamp(inmap.pixel[line + 1][pixbase + 2].b,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase + 3].r =
		add_clamp(inmap.pixel[line + 1][pixbase + 3].r,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase + 3].g =
		add_clamp(inmap.pixel[line + 1][pixbase + 3].g,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase + 3].b =
		add_clamp(inmap.pixel[line + 1][pixbase + 3].b,
				0.1250 * error.r);

	if (line < PPM_VERT_PIXELS - 2) {
		inmap.pixel[line + 2][pixbase].r =
			add_clamp(inmap.pixel[line + 2][pixbase].r,
					0.1250 * error.r);
		inmap.pixel[line + 2][pixbase].g =
			add_clamp(inmap.pixel[line + 2][pixbase].g,
					0.1250 * error.r);
		inmap.pixel[line + 2][pixbase].b =
			add_clamp(inmap.pixel[line + 2][pixbase].b,
					0.1250 * error.r);
		inmap.pixel[line + 2][pixbase + 1].r =
			add_clamp(inmap.pixel[line + 2][pixbase + 1].r,
					0.1250 * error.r);
		inmap.pixel[line + 2][pixbase + 1].g =
			add_clamp(inmap.pixel[line + 2][pixbase + 1].g,
					0.1250 * error.r);
		inmap.pixel[line + 2][pixbase + 1].b =
			add_clamp(inmap.pixel[line + 2][pixbase + 1].b,
					0.1250 * error.r);
	}

	error.r = right.r - sgval[bestval].right.r;
	error.g = right.g - sgval[bestval].right.g;
	error.b = right.b - sgval[bestval].right.b;

	inmap.pixel[line + 1][pixbase].r =
		add_clamp(inmap.pixel[line + 1][pixbase].r,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase].g =
		add_clamp(inmap.pixel[line + 1][pixbase].g,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase].b =
		add_clamp(inmap.pixel[line + 1][pixbase].b,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase + 1].r =
		add_clamp(inmap.pixel[line + 1][pixbase + 1].r,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase + 1].g =
		add_clamp(inmap.pixel[line + 1][pixbase + 1].g,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase + 1].b =
		add_clamp(inmap.pixel[line + 1][pixbase + 1].b,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase + 2].r =
		add_clamp(inmap.pixel[line + 1][pixbase + 2].r,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase + 2].g =
		add_clamp(inmap.pixel[line + 1][pixbase + 2].g,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase + 2].b =
		add_clamp(inmap.pixel[line + 1][pixbase + 2].b,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase + 3].r =
		add_clamp(inmap.pixel[line + 1][pixbase + 3].r,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase + 3].g =
		add_clamp(inmap.pixel[line + 1][pixbase + 3].g,
				0.1250 * error.r);
	inmap.pixel[line + 1][pixbase + 3].b =
		add_clamp(inmap.pixel[line + 1][pixbase + 3].b,
				0.1250 * error.r);
	if (offset < 31) {
		inmap.pixel[line + 1][pixbase + 4].r =
			add_clamp(inmap.pixel[line + 1][pixbase + 4].r,
					0.1250 * error.r);
		inmap.pixel[line + 1][pixbase + 4].g =
			add_clamp(inmap.pixel[line + 1][pixbase + 4].g,
					0.1250 * error.r);
		inmap.pixel[line + 1][pixbase + 4].b =
			add_clamp(inmap.pixel[line + 1][pixbase + 4].b,
					0.1250 * error.r);
		inmap.pixel[line + 1][pixbase + 5].r =
			add_clamp(inmap.pixel[line + 1][pixbase + 5].r,
					0.1250 * error.r);
		inmap.pixel[line + 1][pixbase + 5].g =
			add_clamp(inmap.pixel[line + 1][pixbase + 5].g,
					0.1250 * error.r);
		inmap.pixel[line + 1][pixbase + 5].b =
			add_clamp(inmap.pixel[line + 1][pixbase + 5].b,
					0.1250 * error.r);
	}

	if (line < PPM_VERT_PIXELS - 2) {
		inmap.pixel[line + 2][pixbase + 2].r =
			add_clamp(inmap.pixel[line + 2][pixbase + 2].r,
					0.1250 * error.r);
		inmap.pixel[line + 2][pixbase + 2].g =
			add_clamp(inmap.pixel[line + 2][pixbase + 2].g,
					0.1250 * error.r);
		inmap.pixel[line + 2][pixbase + 2].b =
			add_clamp(inmap.pixel[line + 2][pixbase + 2].b,
					0.1250 * error.r);
		inmap.pixel[line + 2][pixbase + 3].r =
			add_clamp(inmap.pixel[line + 2][pixbase + 3].r,
					0.1250 * error.r);
		inmap.pixel[line + 2][pixbase + 3].g =
			add_clamp(inmap.pixel[line + 2][pixbase + 3].g,
					0.1250 * error.r);
		inmap.pixel[line + 2][pixbase + 3].b =
			add_clamp(inmap.pixel[line + 2][pixbase + 3].b,
					0.1250 * error.r);
	}

out:
	/*
	 * return outbound quantization
	 * error for current line
	 */
	return error;
}

int main(int argc, char *argv[])
{
	int ppmfd, outfd;
	char hdbuf;
	int i, j, rc, insize;
	int whitecount = 0;
	FILE *outfile;
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
		rc = read(ppmfd, (char *)&inmap+insize, sizeof(inmap)-insize);
		if (rc < 0 && rc != EINTR) {
			perror("ppm data read");
			exit(EXIT_FAILURE);
		}
		if (rc != EINTR)
			insize += rc;
	} while (rc != 0);
	close(ppmfd);

	init_sgvals();

	for (i = 0; i < PPM_VERT_PIXELS; i++) {
		error.r = error.g = error.b = 0;
		for (j = 0; j < SGVALS_PER_LINE; j++) {
			error = pick_sgval(i, j, error);
		}
	}

	fprintf(outfile, "\torg $0600\n");

	for (i = 0; i < PPM_VERT_PIXELS; i++)
		for (j = 0; j < SGVALS_PER_LINE; j += 8) {
			fprintf(outfile,
				"\tfcb\t$%02x,$%02x,$%02x,$%02x,"
				"$%02x,$%02x,$%02x,$%02x\n",
				cocobuf[i][j],   cocobuf[i][j+1],
				cocobuf[i][j+2], cocobuf[i][j+3],
				cocobuf[i][j+4], cocobuf[i][j+5],
				cocobuf[i][j+6], cocobuf[i][j+7]);
		}

	fprintf(outfile, "\torg $1e00\n");

	fprintf(outfile, "START\tlda\t#$ff\t; Setup DP register\n");
	fprintf(outfile, "\ttfr\ta,dp\n");
	fprintf(outfile, "\tsetdp\t$ff\n");

	fprintf(outfile, "\torcc\t#$50\t; Disable interrupts\n");

	fprintf(outfile, "VINIT\tclr\t$ffc3\t; Setup SG24 video mode at address $0600\n");
	fprintf(outfile, "\tclr\t$ffc5\n");
	fprintf(outfile, "\tclr\t$ffc7\n");
	fprintf(outfile, "\tclr\t$ff22\n");

	fprintf(outfile, "* Check for user break (development only)\n");
	fprintf(outfile, "CHKUART\tlda\t$ff69\t\tCheck for serial port activity\n");
	fprintf(outfile, "\tbita\t#$08\n");
	fprintf(outfile, "\tbeq\tVLOOP\n");
	fprintf(outfile, "\tlda\t$ff68\n");
	fprintf(outfile, "\tjmp\t[$fffe]         Re-enter monitor\n");

	fprintf(outfile, "VLOOP\tjmp\tCHKUART\n");

	fclose(outfile);

	return 0;
}
