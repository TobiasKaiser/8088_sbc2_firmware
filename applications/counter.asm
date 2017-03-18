bits 16
org 0x0000
%include "../include/8088_sbc2_io.asm"

main:
	mov dl, 0

loop:
	mov al, dl
	out IO_LEDS, al

	inc dl

	in al, IO_SWITCH
	mov ah, 0
	call delay_routine

	jmp loop

delay_routine:
	pushfw
	push ax
	push cx
loop5:
	mov cx,0x64
loop6:
	dec cx
	jnz loop6
	dec ax
	jnz loop5
	pop cx
	pop ax
	popfw
	ret