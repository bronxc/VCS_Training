section .data
	msg db 'Hello, World!', 0xa	;string to be printed
	len_msg equ $-msg	        ;length of the string

section .bss

section .text
	global _start		        ;must be declared for linked (ld)

_start:				  			;linker entry point (lable)
	mov eax, 4		            ;syscall (sys_write)
	mov ebx, 1		            ;file descriptor (stdout) 
	mov ecx, msg		        ;message (string) to be wrote
	mov edx, len_msg	        ;message length
	int 0x80	    	        ;call kernel (the relevant interrupt)

	mov eax, 1		            ;syscall (sys_exit)
	int 0x80		            ;call kernel
