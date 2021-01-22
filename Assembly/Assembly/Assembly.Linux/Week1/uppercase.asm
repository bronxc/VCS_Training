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

uppercase:
@toUpper:
    mov al, [edx]       ; edx is the pointer, so [edx] the current char
    cmp al, 0
    je @done            ; al is null, there is no other chars
    cmp al,'a'
    jb @next     ; al < 'a', not a "lowercase" char
    cmp al,'z'
    ja @next     ; al > 'z', not a "lowercase" char
    sub al, 20h         ; uppercase al (ascii code)
    mov [edx],al        ; write it back to string

@next:
    inc edx             ; not al, that's the character. edcx has to
                        ; be increased, to point to next char
    jmp @toUpper

@done:
    ret
	
	
_start:         
   ; Enter the string 
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
   
   mov edx, string
   call uppercase
	
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