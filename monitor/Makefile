.PHONY: flash
flash: monitor.bin
	minipro -p AT28C64B -w monitor.bin

monitor.bin: monitor.asm ../include/8088_sbc2_io.asm
	nasm $< -o $@