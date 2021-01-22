section .data
   numMaxSize equ 32	
   
   msgNum1 db "enter the first positive number: ", 0
   len_msg1 equ $-msgNum1
   
   msgNum2 db "enter the second positive number: ", 0
   len_msg2 equ $-msgNum2
   
   msgOut db "the sum of two entered number is: ", 0
   len_msgOut equ $-msgOut


section .bss
   num1 resb numMaxSize 		; max is 31 num, last for 0x0
   num2 resb numMaxSize
   res resb numMaxSize + 1		; max is 32

section .text
   global _start

read:
   ; Read ther first num
   mov eax, 4		; syscall (write)
   mov ebx, 1
   mov ecx, msgNum1
   mov edx, len_msg1
   int 0x80

   ;Read and store the user input 1
   mov eax, 3		; syscall (read)
   mov ebx, 2
   mov ecx, num1  
   mov edx, numMaxSize         ; 31 bytes (31 char) of that information
   int 0x80
   
   ; Read ther second num
   mov eax, 4		; syscall (write)
   mov ebx, 1
   mov ecx, msgNum2
   mov edx, len_msg2
   int 0x80

   ;Read and store the user input 2
   mov eax, 3		; syscall (read)
   mov ebx, 2
   mov ecx, num2  
   mov edx, numMaxSize         ; 31 bytes (31 char) of that information
   int 0x80
   
   ret
   
write:
   mov eax, 4		; syscall (write)
   mov ebx, 1
   mov ecx, msgOut
   mov edx, len_msgOut
   int 0x80
   
   mov eax, 4		; syscall (write)
   mov ebx, 1
   mov ecx, res
   mov edx, numMaxSize
   int 0x80
   
   ret


str2num:
   ; In, Out through eax
   mov edx, eax
   xor eax, eax		; zero eax (xor faster)

@toNum:
   movzx ecx, byte [edx]	; get the char
   cmp ecx, 0			; null
   je @done
   cmp ecx, '0'
   jb @done			; < '0'
   cmp ecx, '9'
   ja @done			; > '9'
   sub ecx, '0'		; convert to number
   imul eax, 10		; mul by ten
   add eax, ecx		; add in the current digit
   
@next:
   inc edx			; next char
   jmp @toNum
   
@done:
   ret


num2str:
   ; In: eax
   
   mov esi, res + numMaxSize	; addr (ptr) the res 
   mov ebx, 10			; for the div
   
@toStr:
   dec esi			; next char
   xor edx, edx		; rezo edx for the div
   div ebx			; [edx]eax / ebx
   or edx, 0x30		; add 0x30 ('0' char) to edx (or faster)
   mov byte [esi], dl		; move the dl (store 8 bit (1 byte) of the current digit) to ..
   or eax, eax			; check the eax is rezo?
   jnz @toStr			; eax is not rezo 
   
   mov eax, esi		; eax is rezo, pass the ptr to eax, not necessary
   				; use the ptr -> chars (digit) stored in res variable
   ret
   
_start:
   call read
   
   mov eax, num1
   call str2num
   mov ebx, eax
   
   mov eax, num2
   call str2num
   add eax, ebx
   
   call num2str
   
   call write
   
   
   mov eax, 1
   int 0x80