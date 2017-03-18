all: io_led_sw.hex counter.hex


%.hex: %.bin
	xxd -c 30 -p $< | tr -d '\n' > $@
	echo >> $@

%.bin: %.asm ../include/8088_sbc2_io.asm
	nasm $< -o $@