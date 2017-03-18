.PHONY: flash
#flash: monitor.bin
#	minipro -p AT28C64B -w monitor.bin

monitor.bin: monitor.asm
	nasm $< -o $@