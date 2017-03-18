bits 16

org 0xf0000

	mov al,0xaa
	out 0x0,al
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
	in al,0x25
	and al,0x20
	jz loop4
	pop ax
	out 0x20,al
	popfw
	ret

sub3:
loop3:
	in al,0x25
	and al,0x1
	jz loop3
	in al,0x20
	ret

main:
	mov ax,0xf000
	mov cs,ax
	mov al,0x1
	out 0x0,al
	mov ax,0x7000
	mov ss,ax
	mov ds,ax
	mov al,0x2
	out 0x0,al
	mov sp,0xffff
	mov al,0x3
	out 0x0,al
loop2:
	in al,0x25
	and al,0x40
	jz loop2
	mov al,0x4
	out 0x0,al
	mov al,0x7
	out 0x22,al
	mov al,0x80
	out 0x23,al
	mov ax,0x18
	out 0x20,ax
	mov al,0x3
	out 0x23,al
	mov al,0x1
	out 0x21,al
	mov al,0x5
	out 0x0,al
	mov ax,0x6000
	mov es,ax
	mov di,0x0
	mov al,0x6
	out 0x0,al
	mov al,0x48
	call sub2
	mov al,0x7
	out 0x0,al
	mov al,0x69
	call sub2
	mov al,0x8
	out 0x0,al
loop1:
	call sub3
	call sub2
	cmp al,0x0
	jz else2
	mov [es:di],al
	out 0x0,al
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
	out 0x0,al
	jmp loop1


times 0x1ff0-($-$$) db 0 

	jmp 0xf000:0x0000

times 0x2000-($-$$) db 0 