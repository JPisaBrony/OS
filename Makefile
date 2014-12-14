all: os-image

run: all
	qemu-system-i386 -fda os-image -boot a -no-fd-bootchk

os-image: boot.bin kernel.bin
	cat $^ > os-image

kernel.bin: kernel_entry.o kernel.o
	ld -m elf_i386 -s -o kernel.bin -Ttext 0x1000 $^ --oformat binary

kernel.o: kernel.c
	gcc -m32 -ffreestanding -c $< -o $@

kernel_entry.o: kernel_entry.asm
	nasm $< -f elf -o $@

boot.bin: boot.asm
	nasm $< -f bin -o $@

clean:
	rm *.bin *.o