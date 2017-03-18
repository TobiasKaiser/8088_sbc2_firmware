bits 16

IO_LEDS equ 0x0
IO_SWITCH equ 0x0

REG_2 equ 0x20
IO_UART_RBR equ 0x20
IO_UART_THR equ 0x20
IO_UART_DLL equ 0x20
IO_UART_DLM equ 0x21
IO_UART_IER equ 0x21
IO_UART_IIR equ 0x22
IO_UART_FCR equ 0x22
IO_UART_LCR equ 0x23
IO_UART_MCR equ 0x24
IO_UART_LSR equ 0x25
IO_UART_MSR equ 0x26
IO_UART_SCR equ 0x27


org 0xf0000

	mov al,0xaa
	out IO_LEDS,al
	jmp main

sub1:
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

sub2:
	pushfw
	push ax
loop4:
	in al,IO_UART_LSR
	and al,0x20
	jz loop4
	pop ax
	out REG_2,al
	popfw
	ret

sub3:
loop3:
	in al,IO_UART_LSR
	and al,0x1
	jz loop3
	in al,IO_UART_RBR
	ret

main:
	mov ax,0xf000
	mov cs,ax
	mov al,0x1
	out IO_LEDS,al
	mov ax,0x7000
	mov ss,ax
	mov ds,ax
	mov al,0x2
	out IO_LEDS,al
	mov sp,0xffff
	mov al,0x3
	out IO_LEDS,al
loop2:
	in al,IO_UART_LSR
	and al,0x40
	jz loop2
	mov al,0x4
	out IO_LEDS,al
	mov al,0x7
	out IO_UART_FCR,al
	mov al,0x80
	out 0x23,al
	mov ax,0x18
	out REG_2,ax
	mov al,0x3
	out IO_UART_LCR,al
	mov al,0x1
	out IO_UART_DLM,al
	mov al,0x5
	out IO_LEDS,al
	mov ax,0x6000
	mov es,ax
	mov di,0x0
	mov al,0x6
	out IO_LEDS,al
	mov al,0x48
	call sub2
	mov al,0x7
	out IO_LEDS,al
	mov al,0x69
	call sub2
	mov al,0x8
	out IO_LEDS,al
loop1:
	call sub3
	call sub2
	cmp al,0x0
	jz else2
	mov [es:di],al
	out IO_LEDS,al
	inc di
	jmp loop1


else2:
	call sub3
	cmp al,0x0
	jz else
	mov sp,0xffff
	jmp 0x6000:0x0000

else:
	mov al,0x0
	mov [es:di],al
	inc di
	out IO_LEDS,al
	jmp loop1


times 0x1ff0-($-$$) db 0 

	jmp 0xf000:0x0000

times 0x2000-($-$$) db 0 