.PHONY: all clean

CFLAGS=-Wall

TARGETS=ppmtog6c8 ppmtosg24 \
	testg6c8.s19 testsg24.s19 \
	rastdemo.s19

EXTRA=gencolors colors.h test.ppm testg6c8.asm testsg24.asm

all: $(TARGETS)

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

gencolors.o: palette.h

gencolors: gencolors.o
	$(CC) $(CFLAGS) -o $@ $^

colors.h: gencolors
	./gencolors > $@

ppmtog6c8: ppmtog6c8.c palette.h colors.h
	$(CC) $(CFLAGS) -o ppmtog6c8 ppmtog6c8.c

ppmtosg24: ppmtosg24.c palette.h
	$(CC) $(CFLAGS) -o ppmtosg24 ppmtosg24.c

rastdemo.s19: rastdemo.asm
	mamou -mb -ts -orastdemo.s19 rastdemo.asm -l -y

test.ppm: test.jpg
	convert -resize 125x200%! -resize 128x192 -quantize YIQ +dither \
		-background black -gravity center -extent 128x192 \
		test.jpg test.ppm

testg6c8.asm: test.ppm ppmtog6c8
	./ppmtog6c8 $< $@

testg6c8.s19: testg6c8.asm
	mamou -mb -ts -otestg6c8.s19 testg6c8.asm -l -y

testsg24.asm: test.ppm ppmtosg24
	./ppmtosg24 $< $@

testsg24.s19: testsg24.asm
	mamou -mb -ts -otestsg24.s19 testsg24.asm -l -y

clean:
	rm -f $(TARGETS) $(EXTRA)
