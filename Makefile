.PHONY: all clean

CFLAGS=-Wall

TARGETS=ppmtog6c8 ppmtosg24 ppmtoflip44 \
	testg6c8.s19 testsg24.s19 \
	testflip44.s19 \
	paltest1.ppm \
	paltest1.s19 \
	paltest2.s19

OBJECTS=gencolors.o test.ppm testg6c8.asm testsg24.asm testflip44.asm

EXTRA=gencolors colors.h

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

ppmtoflip44: ppmtoflip44.c palette.h
	$(CC) $(CFLAGS) -o ppmtoflip44 ppmtoflip44.c

paltest1.s19: paltest1.asm
	mamou -mb -ts -opaltest1.s19 paltest1.asm -l -y

paltest1.ppm: paltest1.dat
	xxd -p -r $< $@

paltest2.s19: paltest2.asm
	mamou -mb -ts -opaltest2.s19 paltest2.asm -l -y

test.ppm: test.jpg
	convert -resize 125x200%! -resize 128x192 -quantize YIQ +dither \
		-background blue -gravity center -extent 128x192 \
		test.jpg test.ppm

testg6c8.asm: test.ppm ppmtog6c8
	./ppmtog6c8 $< $@

testg6c8.s19: testg6c8.asm
	mamou -mb -ts -otestg6c8.s19 testg6c8.asm -l -y

testsg24.asm: test.ppm ppmtosg24
	./ppmtosg24 $< $@

testsg24.s19: testsg24.asm
	mamou -mb -ts -otestsg24.s19 testsg24.asm -l -y

testflip44.asm: test.ppm ppmtoflip44
	./ppmtoflip44 $< $@

testflip44.s19: testflip44.asm
	mamou -mb -ts -otestflip44.s19 testflip44.asm -l -y

clean:
	rm -f $(TARGETS) $(EXTRA) $(OBJECTS)
