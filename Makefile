.PHONY: all clean

CFLAGS=-Wall

TARGETS=gencolors colors.h rastdemo.s19

all: $(TARGETS)

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

gencolors.o: palette.h

gencolors: gencolors.o
	$(CC) $(CFLAGS) -o $@ $^

colors.h: gencolors
	./gencolors > $@

rastdemo.s19: rastdemo.asm
	mamou -mb -ts -orastdemo.s19 rastdemo.asm -l -y

clean:
	rm -f $(TARGETS)
