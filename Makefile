.PHONY: all clean

CFLAGS=-Wall

TARGETS=ppmtog6c8 ppmtosg24 gencolors colors.h rastdemo.s19

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

clean:
	rm -f $(TARGETS)
