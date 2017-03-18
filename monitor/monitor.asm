bits 16

%include "../include/8088_sbc2_io.asm"


org 0xf0000

	mov al,0xaa
	out IO_LEDS,al
	jmp main

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

uart_putc:
	pushfw
	push ax
loop4:
	in al,IO_UART_LSR
	and al,0x20
	jz loop4
	pop ax
	out IO_UART_THR,al
	popfw
	ret

uart_puts:
	xchg bx, ax

uart_puts_loop:
	mov al, [cs:bx]
	cmp al, 0x00
	jz uart_puts_loop_end

	call uart_putc
	inc bx
	jmp uart_puts_loop
uart_puts_loop_end:

	xchg bx, ax
	ret

uart_getc:
loop3:
	in al,IO_UART_LSR
	and al,0x1
	jz loop3
	in al,IO_UART_RBR
	ret

main:
	; Load code segment (-> ROM)
	mov ax,0xf000
	mov cs,ax
	; Load stack segment, data segment (-> RAM)
	mov ax,0x7000
	mov ss,ax
	mov ds,ax
	; Load SP
	mov sp,0xffff

	; Wait until UART is ready
loop2:
	in al,IO_UART_LSR
	and al,0x40
	jz loop2

	; Initialize UART
	mov al,0x7
	out IO_UART_FCR,al
	mov al,0x80
	out IO_UART_LCR,al
	mov ax,0x18
	out IO_UART_THR,ax
	mov al,0x3
	out IO_UART_LCR,al
	mov al,0x1
	out IO_UART_DLM,al

	; Use extra segment to store
	mov ax,0x0000
	mov es,ax
	mov di,0x0

	; Print welcome message
	mov ax, welcome_msg
	call uart_puts
	
load_loop:

	mov dl, 0 ; DL is where the byte we are loading will go

	; Load upper nibble
	call uart_getc
	call uart_putc

	; Is it between 0 and 9?
	cmp al, '0'
	jb upper_nibble_no_number
	cmp al, '9'
	ja upper_nibble_no_number

	sub al, '0'-0

	jmp upper_nibble_conv_success
upper_nibble_no_number:
	; Is it between A an F?
	cmp al, 'A'
	jb upper_nibble_no_upper_alpha
	cmp al, 'F'
	ja upper_nibble_no_upper_alpha

	sub al, 'A'-0xA

	jmp upper_nibble_conv_success
upper_nibble_no_upper_alpha:

	; Is it between a an f?
	cmp al, 'a'
	jb upper_nibble_no_lower_alpha
	cmp al, 'f'
	ja upper_nibble_no_lower_alpha

	sub al, 'a'-0xA
	jmp upper_nibble_conv_success
upper_nibble_no_lower_alpha:


	; not a valid hex digit - lets start the program
	jmp load_loop_end

upper_nibble_conv_success:
	shl al, 1
	shl al, 1
	shl al, 1
	shl al, 1
	or dl, al

	; ===> Load lower nibble
	call uart_getc
	call uart_putc
	
	; Is it between 0 and 9?
	cmp al, '0'
	jb lower_nibble_no_number
	cmp al, '9'
	ja lower_nibble_no_number

	sub al, '0'-0

	jmp lower_nibble_conv_success
lower_nibble_no_number:
	; Is it between A an F?
	cmp al, 'A'
	jb lower_nibble_no_upper_alpha
	cmp al, 'F'
	ja lower_nibble_no_upper_alpha

	sub al, 'A'-0xA

	jmp lower_nibble_conv_success
lower_nibble_no_upper_alpha:

	; Is it between a an f?
	cmp al, 'a'
	jb lower_nibble_no_lower_alpha
	cmp al, 'f'
	ja lower_nibble_no_lower_alpha

	sub al, 'a'-0xA

	jmp lower_nibble_conv_success
lower_nibble_no_lower_alpha:

	jmp load_loop_end

lower_nibble_conv_success:

	or dl, al

	mov al, dl
	mov [es:di],al
	
	out IO_LEDS,al
	inc di

	; separator

	mov ax, di
	and ax, 15
	jz separator_paragraph
	mov al, ' '
	call uart_putc
	jmp load_loop
separator_paragraph:

	mov ax, crnl
	call uart_puts

	jmp load_loop
load_loop_end:

	; Start program
	mov ax, start_msg
	call uart_puts
	jmp 0x0000:0x0000


welcome_msg:


	db `\r\n\8088_sbc2 monitor v1.0 (C) Tobias Kaiser 2017\r\n`
	db `   ___   ___   ___   ___        _          ____   \r\n`
	db `  ( _ ) / _ \\ ( _ ) ( _ )   ___| |__   ___|___ \\ \r\n`
	db `  / _ \\| | | |/ _ \\ / _ \\  / __| '_ \\ / __| __) |\r\n`
	db ` | (_) | |_| | (_) | (_) | \\__ \ |_) | (__ / __/ \r\n`
	db `  \\___/ \\___/ \\___/ \\___/  |___/_.__/ \\___|_____|\r\n`
	db `\t8088_sbc2 has 512 KByte SRAM at 0x00000, 8 KByte EEPROM at 0x80000,\r\n`
	db `\tIO map: 0x00 reads switches, 0x00 writes LED bar, 0x20 - 0x27: 16550 UART\r\n`
	db `Loader starts at 0x00000, entry point is 0x0000:0x0000.\r\n`
	db `Please enter program in HEX and start by pressing ENTER.\r\n\0`
	
start_msg: db `\r\nStarting program now...\r\n\0`

crnl: db `\r\n\0`

times 0x1ff0-($-$$) db 0 

	jmp 0xf000:0x0000

times 0x2000-($-$$) db 0 