all:
	nasm -f elf64 $(source).asm
	g++ -no-pie ${source}.cpp ${source}.o -o ${source}
	rm $(source).o
