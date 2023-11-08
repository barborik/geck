ASM = nasm
LINK = gcc

AFLAGS = -f elf64
LFLAGS = -no-pie

TARGET = bin/geck

SRC = $(wildcard src/*.asm)
OBJ = $(patsubst src/%.asm, obj/%.o, $(SRC))

ifeq ($(OS),Windows_NT)
TARGET += .exe
endif

$(TARGET): $(OBJ)
	$(LINK) $(LFLAGS) $^ -o $@

obj/%.o: src/%.asm
	$(ASM) $(AFLAGS) $< -o $@
