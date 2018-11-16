med:
	yasm -f elf -g dwarf2 med.asm
	ld -o med med.o

clean:
	rm med
	rm med.o
