
io_led_sw.hex: io_led_sw.bin
	xxd -c 30 -p $< | tr -d '\n' > $@
	echo >> $@

io_led_sw.bin: io_led_sw.asm ../include/8088_sbc2_io.asm
	nasm $< -o $@