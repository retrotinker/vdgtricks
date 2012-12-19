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
#include <math.h>

#include "palette.h"

#define MAXR	4
#define MAXG	4
#define MAXB	4

#define RGB(r, g, b)	((r * MAXG * MAXB) + (g * MAXB) + b)

/*
 * color_table is indexed by compacted r,g,b value and (once
 * initialized) returns closest known color index for the
 * given palette.
 */
uint8_t color_table[2][MAXR * MAXG * MAXB];

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

void init_colors(int set)
{
	int r, g, b, cmp;
	struct rgb cur;

	/*
	 * initialize color_table
	 */
	for (r = 0; r < MAXR; r++) {
		cur.r = r * 256 / MAXR;
		for (g = 0; g < MAXG; g++) {
			cur.g = g * 256 / MAXG;
			for (b = 0; b < MAXB; b++) {
				float cur_distance, closest_distance;
				int closest = 0;

				cur.b = b * 256 / MAXB;

				closest_distance = yiq_distance(cur,
							palette[set][0]);
				for (cmp = 1; cmp < PALETTE_SIZE; cmp++) {
					cur_distance =
						yiq_distance(cur,
							palette[set][cmp]);
					if (cur_distance < closest_distance) {
						closest_distance = cur_distance;
						closest = cmp;
					}
				}

				color_table[set][RGB(r,g,b)] = closest;
			}
		}
	}
}

void show_matches(int set)
{
	int i;

	for (i = 0; i < (MAXR * MAXG * MAXB); i++) {
		printf("RGB %3d, %3d, %3d => COLOR %3d\n",
			(i & (MAXR - 1) * MAXG * MAXB) / (MAXG * MAXB),
			(i & (MAXG - 1) * MAXB) / MAXB,
			 i & (MAXB - 1),
			color_table[set][i]);
	}
}

void gen_colors()
{
	int i, set;

	printf("#ifndef _COLORS_H_\n");
	printf("#define _COLORS_H_\n");
	printf("\n");
	printf("#include <stdint.h>\n");
	printf("\n");
	printf("#define MAXR\t%d\n", MAXR);
	printf("#define MAXG\t%d\n", MAXG);
	printf("#define MAXB\t%d\n", MAXB);
	printf("\n");
	printf("#define MASKR\t(256 - (256 / MAXR))\n");
	printf("#define MASKG\t(256 - (256 / MAXG))\n");
	printf("#define MASKB\t(256 - (256 / MAXB))\n");
	printf("\n");
	printf("#define MIN(a, b)\t(a < b ? a : b)\n");
	printf("\n");
	printf("#define RGB(r, g, b)\t(((((MIN(255, (r + (256 / MAXR / 2))) & MASKR) \\\n");
	printf("\t\t\t\t* MAXR) / 256) * MAXG * MAXB) + \\\n");
	printf("\t\t\t ((((MIN(255, (g + (256 / MAXR / 2))) & MASKG) \\\n");
	printf("\t\t\t\t* MAXG) / 256) * MAXB) + \\\n");
	printf("\t\t\t  (((MIN(255, (b + (256 / MAXR / 2))) & MASKB) \\\n");
	printf("\t\t\t\t* MAXB) / 256))\n");
	printf("\n");
	printf("uint8_t color[][%d] = {\n", MAXR * MAXG * MAXB);

	for (set = 0; set < 2; set++) {
		printf("\t{\n");
		for (i = 0; i < (MAXR * MAXG * MAXB); i++) {
			if (i % 8 == 0)
				printf("\t\t0x%02x,", color_table[set][i]);
			else
				printf("\t 0x%02x,", color_table[set][i]);
			if (i % 8 == 7)
				printf("\n");
		}
		printf("\t},\n");
	}

	printf("};\n");
	printf("\n");
	printf("#endif /* _COLORS_H_ */\n");
}

int main(int argc, char *argv[])
{
	init_colors(0);
	init_colors(1);
	/*
	 * show_matches(0);
	 * show_matches(1);
	 */
	gen_colors();

	return 0;
}
