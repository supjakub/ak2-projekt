all: main

main.o: main.s
	nasm -f elf64 -g -F dwarf -o main.o main.s

main: main.o
	ld -o main main.o
	
