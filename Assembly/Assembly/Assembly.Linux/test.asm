section	.text
	global _start       ;must be declared for using gcc
_start:                     ;tell linker entry point
	
	xor eax, eax
	mov al, byte[e_ident + 4]
	
	mov byte [OSclass], al
	
	xor eax, eax
	mov al, byte [OSclass]
	
	dec eax
	mov ebx, len_ei_class
	mul ebx
	
	mov ecx, ei_class
	add ecx, eax
	mov edx, len_ei_class
	
	mov	ebx, 1	    ;file descriptor (stdout)
	mov	eax, 4	    ;system call number (sys_write)
	
	
	int	0x80  
	
	
	
	cmp byte[OSclass], 1            ; 32 bit
	jne @64bit
	@32bit:
	    mov	ebx, 1	    ;file descriptor (stdout)
	    mov	eax, 4	    ;system call number (sys_write)
	    mov ecx, ei_data
	    mov edx, len_ei_data
	    int 80h
	
	
	@64bit:
	
	
	xor eax, eax
	mov ax, word [e_type]
	sub eax, 512
	;dec eax
	
	mov ebx, len_et_type
	mul ebx
	
	mov ecx, et_type
	add ecx, eax
	mov edx, len_et_type
	
	mov	ebx, 1	    ;file descriptor (stdout)
	mov	eax, 4	    ;system call number (sys_write)
	int 80h
	
	
	;call kernel
	mov	eax, 1	    ;system call number (sys_exit)
	int	0x80        ;call kernel



section	.data

ei_data		db "2's complement, little endian", 0ah
			db "2's complement, big endian   ", 0ah
len_ei_data equ ($-ei_data)/2				
				
OSclass     db 0
ei_class 	db "ELF32", 0ah
			db "ELF64", 0ah
	
len_ei_class equ ($-ei_class)/2

e_ident db 7fh, 45h, 4ch, 46h, 01h, 01h, 01h, 00h, 00h

et_type		db "NONE", 0
			db "REL ", 0
			db "EXEC", 0
			db "DYN ", 0
			db "CORE", 0
	
len_et_type equ ($-et_type)/5
	
e_type	db 00h, 02h
	