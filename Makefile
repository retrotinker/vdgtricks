.PHONY: all clean

CFLAGS=-Wall

RUN?=decb

TARGBASE=ppmtog6c8 ppmtosg24 ppmtoflip44 \
	paltest1.ppm

TARGDECB=testg6c8.bin testg6c8.wav \
	testsg24.bin testsg24.wav \
	testflip44.bin testflip44.wav \
	paltest1.bin paltest1.wav \
	paltest2.bin paltest2.wav \
	vdgtricks.dsk

TARGMON09=testg6c8.s19 \
	testsg24.s19 \
	testflip44.s19 \
	paltest1.s19 \
	paltest2.s19

TARGETS=$(TARGBASE)
ifeq ($(RUN),decb)
	TARGETS+=$(TARGDECB)
else ifeq ($(RUN),mon09)
	TARGETS+=$(TARGMON09)
else
$(error Invalid RUN definition!)
endif

OBJECTS=test.ppm testg6c8.asm testsg24.asm testflip44.asm

EXTRA=gencolors colors.h

VIDEO?=ntsc

ifeq ($(VIDEO),ntsc)
	ASMFLAGS='-aNTSC=1'
else ifeq ($(VIDEO),pal)
	ASMFLAGS='-aPAL=1'
else
$(error Invalid VIDEO definition!)
endif

all: $(TARGETS)

%.bin: %.asm
	mamou -mb -tb -l -y $(ASMFLAGS) -o$@ $<

%.s19: %.asm
	mamou -mr -ts -l -y $(ASMFLAGS) -o$@ $<

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

ppmtog6c8.o: colors.h

ppmtog6c8: ppmtog6c8.o palette.h
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

vdgtricks.dsk: paltest1.bin paltest2.bin COPYING README \
		testg6c8.bin testsg24.bin testflip44.bin
	decb dskini $@
	decb copy -2 -b paltest1.bin $@,PALTEST1.BIN
	decb copy -2 -b paltest2.bin $@,PALTEST2.BIN
	decb copy -2 -b testg6c8.bin $@,TESTG6C8.BIN
	decb copy -2 -b testsg24.bin $@,TESTSG24.BIN
	decb copy -2 -b testflip44.bin $@,TESTFLIP.BIN
	decb copy -3 -a -l COPYING $@,COPYING
	decb copy -3 -a -l README $@,README

clean:
	rm -f *.o $(TARGBASE) $(TARGDECB) $(TARGMON09) $(EXTRA) $(OBJECTS)
