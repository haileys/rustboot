CC=i386-elf-gcc
LD=i386-elf-ld
RUSTC=rustc
NASM=nasm
QEMU=qemu-system-i386

all: floppy.img

.SUFFIXES: .o .rs .asm

.PHONY: clean run

.rs.o:
	$(RUSTC) -O --target i386-intel-linux --crate-type lib -o $@ --emit obj $<

.asm.o:
	$(NASM) -f elf32 -o $@ $<

floppy.img: loader.bin main.bin
	cat $^ > $@

loader.bin: loader.asm
	$(NASM) -o $@ -f bin $<

main.bin: linker.ld main.o
	$(LD) -o $@ -T $^

run: floppy.img
	$(QEMU) -fda $<

clean:
	rm -f *.bin *.o *.img
