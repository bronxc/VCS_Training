section .data                           ;Data segment
   msgIn db 'enter the string: ', 0 ;Ask the user to enter a number
   len_msgIn equ $-msgIn             ;The length of the message
   msgOut db 'the string you enter: ', 0
   len_msgOut equ $-msgOut                 
   
   strMax equ 32

section .bss           ;Uninitialized data
   string resb strMax	;the max len of string is 32 (char)
	
section .text          ;Code Segment
   global _start
	
_start:                
   mov eax, 4		; syscall (write)
   mov ebx, 1
   mov ecx, msgIn
   mov edx, len_msgIn
   int 0x80

   ;Read and store the user input
   mov eax, 3		; syscall (read)
   mov ebx, 2
   mov ecx, string  
   mov edx, strMax          ; 32 bytes (32 char) of that information
   int 0x80
	
   ;Output the message 'the string you enter: '
   mov eax, 4		; syscall (write)
   mov ebx, 1
   mov ecx, msgOut
   mov edx, len_msgOut
   int 0x80  

   ;Output the string entered
   mov eax, 4		; sys_write
   mov ebx, 1
   mov ecx, string
   mov edx, strMax
   int 0x80  
    
   ; Exit code
   mov eax, 1
   mov ebx, 0
   int 0x80