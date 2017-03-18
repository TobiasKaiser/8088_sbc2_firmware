bits 16
org 0x0000
%include "../include/8088_sbc2_io.asm"

loop:
	in al, IO_SWITCH
	out IO_LEDS, al
	jmp loop