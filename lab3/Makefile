all:
	nasm -f elf64 $(source).asm
	ld ${source}.o -o ${source}
	rm $(source).o
