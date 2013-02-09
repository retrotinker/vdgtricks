.PHONY: all clean

CFLAGS=-Wall

TARGETS=ppmtog6c8 ppmtosg24 ppmtoflip44 \
	testg6c8.bin testg6c8.s19 testg6c8.wav \
	testsg24.bin testsg24.s19 testsg24.wav \
	testflip44.bin testflip44.s19 testflip44.wav \
	paltest1.ppm \
	paltest1.bin paltest1.s19 paltest1.wav \
	paltest2.bin paltest2.s19 paltest2.wav

OBJECTS=gencolors.o test.ppm testg6c8.asm testsg24.asm testflip44.asm

EXTRA=gencolors colors.h

all: $(TARGETS)

%.bin: %.asm
	mamou -mb -tb -l -y -o$@ $<

%.s19: %.asm
	mamou -mr -ts -l -y -o$@ $<

%.wav: %.bin
	cecb bulkerase $@
	cecb copy -2 -b -g $< \
		$(@),$$(echo $< | cut -c1-8 | tr [:lower:] [:upper:])

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

gencolors.o: palette.h

gencolors: gencolors.o
	$(CC) $(CFLAGS) -o $@ $<

colors.h: gencolors
	./gencolors > $@

ppmtog6c8: colors.h

ppmtog6c8: ppmtog6c8.o palette.h colors.h
	$(CC) $(CFLAGS) -o $@ $<

ppmtosg24: ppmtosg24.o palette.h
	$(CC) $(CFLAGS) -o $@ $<

ppmtoflip44: ppmtoflip44.o palette.h
	$(CC) $(CFLAGS) -o $@ $<

paltest1.ppm: paltest1.dat
	xxd -p -r $< $@

test.ppm: test.jpg
	convert -resize 125x200%! -resize 128x192 -quantize YIQ +dither \
		-background blue -gravity center -extent 128x192 \
		test.jpg test.ppm

testg6c8.asm: test.ppm ppmtog6c8
	./ppmtog6c8 $< $@

testsg24.asm: test.ppm ppmtosg24
	./ppmtosg24 $< $@

testflip44.asm: test.ppm ppmtoflip44
	./ppmtoflip44 $< $@

clean:
	rm -f $(TARGETS) $(EXTRA) $(OBJECTS)
