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

#include "palette.h"
#include "colors.h"

#define PPM_HORIZ_PIXELS	128
#define PPM_VERT_PIXELS		192

struct pixmap24 {
	struct rgb pixel[PPM_VERT_PIXELS][PPM_HORIZ_PIXELS];
} __attribute__ ((packed));

struct rgb_err {
	int8_t r, g, b;
};

struct pixmap24 inmap;

#define PIXELS_PER_BYTE		4

unsigned char cocobuf[PPM_VERT_PIXELS][PPM_HORIZ_PIXELS / PIXELS_PER_BYTE];

#define LINES_PER_PIXEL		(192 / PPM_VERT_PIXELS)
#define BLOCKS_PER_LINE		8
#define PIXELS_PER_BLOCK	(PPM_HORIZ_PIXELS / BLOCKS_PER_LINE)
#define BYTES_PER_BLOCK		(PIXELS_PER_BLOCK / PIXELS_PER_BYTE)

int colorset[PPM_VERT_PIXELS][BLOCKS_PER_LINE];

struct blockdata {
	int colorset;
	struct rgb_err error;
};

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
			workline[i][j] = inmap.pixel[line][hoffset + j];

		/*
		 * Make a wild guess that error from 2-pixels to the left
		 * matches the error from 1-pixel to the left...
		 */
		workline[i][0].r =
			add_clamp(workline[i][0].r, 0.2500 * error.r);
		workline[i][0].g =
			add_clamp(workline[i][0].g, 0.2500 * error.g);
		workline[i][0].b =
			add_clamp(workline[i][0].b, 0.2500 * error.b);

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

				if (j == BYTES_PER_BLOCK - 1 &&
				    k == PIXELS_PER_BYTE - 2)
					continue;

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

	/* set values in cocobuf */
	for (j = 0; j < BYTES_PER_BLOCK; j++)
		cocobuf[line][block * BYTES_PER_BLOCK + j] = data[choice][j];

	/* skip further error dispersal if on last line */
	if (line == PPM_VERT_PIXELS - 1)
		goto exit;

	/* perturb the colors in the next line based on the this one's error */
	i = choice;
	for (j = 0; j < PIXELS_PER_BLOCK; j++) {
		if (block != 0) {
			inmap.pixel[line + 1][hoffset + j - 1].r =
				add_clamp(inmap.pixel[line + 1][hoffset + j - 1].r,
					  0.1250 * (workline[i][j].r -
						    palette[i][chosen[i][j]].r));
			inmap.pixel[line + 1][hoffset + j - 1].g =
				add_clamp(inmap.pixel[line + 1][hoffset + j - 1].g,
					  0.1250 * (workline[i][j].g -
						    palette[i][chosen[i][j]].g));
			inmap.pixel[line + 1][hoffset + j - 1].b =
				add_clamp(inmap.pixel[line + 1][hoffset + j - 1].b,
					  0.1250 * (workline[i][j].b -
						    palette[i][chosen[i][j]].b));
		}

		inmap.pixel[line + 1][hoffset + j].r =
			add_clamp(inmap.pixel[line + 1][hoffset + j].r,
				  0.1250 * (workline[i][j].r -
					    palette[i][chosen[i][j]].r));
		inmap.pixel[line + 1][hoffset + j].g =
			add_clamp(inmap.pixel[line + 1][hoffset + j].g,
				  0.1250 * (workline[i][j].g -
					    palette[i][chosen[i][j]].g));
		inmap.pixel[line + 1][hoffset + j].b =
			add_clamp(inmap.pixel[line + 1][hoffset + j].b,
				  0.1250 * (workline[i][j].b -
					    palette[i][chosen[i][j]].b));

		if (block == BLOCKS_PER_LINE - 1 && j == PIXELS_PER_BLOCK - 1)
			continue;

		inmap.pixel[line + 1][hoffset + j + 1].r =
			add_clamp(inmap.pixel[line + 1][hoffset + j + 1].r,
				  0.1250 * (workline[i][j].r -
					    palette[i][chosen[i][j]].r));
		inmap.pixel[line + 1][hoffset + j + 1].g =
			add_clamp(inmap.pixel[line + 1][hoffset + j + 1].g,
				  0.1250 * (workline[i][j].g -
					    palette[i][chosen[i][j]].g));
		inmap.pixel[line + 1][hoffset + j + 1].b =
			add_clamp(inmap.pixel[line + 1][hoffset + j + 1].b,
				  0.1250 * (workline[i][j].b -
					    palette[i][chosen[i][j]].b));
	}

	/* skip further error dispersal if on next to last line */
	if (line == PPM_VERT_PIXELS - 2)
		goto exit;

	for (j = 0; j < PIXELS_PER_BLOCK; j++) {
		inmap.pixel[line + 2][hoffset + j].r =
			add_clamp(inmap.pixel[line + 2][hoffset + j].r,
				  0.1250 * (workline[i][j].r -
					    palette[i][chosen[i][j]].r));
		inmap.pixel[line + 2][hoffset + j].g =
			add_clamp(inmap.pixel[line + 2][hoffset + j].g,
				  0.1250 * (workline[i][j].g -
					    palette[i][chosen[i][j]].g));
		inmap.pixel[line + 2][hoffset + j].b =
			add_clamp(inmap.pixel[line + 2][hoffset + j].b,
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
		rc = read(ppmfd, (char *)&inmap+insize, sizeof(inmap)-insize);
		if (rc < 0 && rc != EINTR) {
			perror("ppm data read");
			exit(EXIT_FAILURE);
		}
		if (rc != EINTR)
			insize += rc;
	} while (rc != 0);
	close(ppmfd);

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

	fprintf(outfile, "VINIT\tclr\t$ffc3\t; Setup G6C video mode at address $0600\n");
	fprintf(outfile, "\tclr\t$ffc5\n");
	fprintf(outfile, "\tclr\t$ffc7\n");
	fprintf(outfile, "\tlda\t#$e8\n");
	fprintf(outfile, "\tsta\t$ff22\n");

	fprintf(outfile, "VSTART\tldb     $ff01\t; Disable hsync interrupt generation\n");
	fprintf(outfile, "\tandb\t#$fa\n");
	fprintf(outfile, "\tstb     $ff01\n");
	fprintf(outfile, "\ttst\t$ff00\n");

	fprintf(outfile, "\tlda     $ff03\t; Enable vsync interrupt generation\n");
	fprintf(outfile, "\tora     #$05\n");
	fprintf(outfile, "\tsta     $ff03\n");
	fprintf(outfile, "\ttst\t$ff02\n");

	fprintf(outfile, "\tsync\t\t; Wait for vsync interrupt\n");

	fprintf(outfile, "\tanda\t#$fa\t; Disable vsync interrupt generation\n");
	fprintf(outfile, "\tsta     $ff03\n");
	fprintf(outfile, "\ttst\t$ff02\n");

	fprintf(outfile, "\torb     #$05\t; Enable hsync interrupt generation\n");
	fprintf(outfile, "\tstb     $ff01\n");
	fprintf(outfile, "\ttst\t$ff00\n");

	fprintf(outfile, "*\n");
	fprintf(outfile, "* After the program starts, vsync interrupts aren't used...\n");
	fprintf(outfile, "*\n");
	fprintf(outfile, "VSYNC\tldb\t#$45\t; Count lines during vblank and vertical borders\n");
	fprintf(outfile, "HCOUNT\ttst\t$ff00\n");
	fprintf(outfile, "\tsync\n");

	fprintf(outfile, "\tdecb\n");
	fprintf(outfile, "\tbne\tHCOUNT\n");

	fprintf(outfile, "\tlda\t#$e8\t; Setup CSS options for raster effects\n");
	fprintf(outfile, "\tldb\t#$e0\n");

	for (i = 0; i < PPM_VERT_PIXELS; i++) {
		for (j = 0; j < LINES_PER_PIXEL; j++) {
			fprintf(outfile, "\ttst\t$ff00\t; Wait for next hsync interrupt\n");
			fprintf(outfile, "\tsync\n");

			fprintf(outfile, "\tnop\t\t; Extra delay for beginning of visible line\n");
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

	fprintf(outfile, "* Check for user break (development only)\n");
	fprintf(outfile, "CHKUART\tlda\t$ff69\t\tCheck for serial port activity\n");
	fprintf(outfile, "\tbita\t#$08\n");
	fprintf(outfile, "\tbeq\tVLOOP\n");
	fprintf(outfile, "\tlda\t$ff68\n");
	fprintf(outfile, "\tjmp\t[$fffe]         Re-enter monitor\n");

	fprintf(outfile, "VLOOP\tjmp\tVSYNC\n");

	fprintf(outfile, "\tEND\tSTART\n");

	fclose(outfile);

	return 0;
}
