all: rastdemo.s19

rastdemo.s19: rastdemo.asm
	mamou -mb -ts -orastdemo.s19 rastdemo.asm -l -y
