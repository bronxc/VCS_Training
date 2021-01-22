.386
.model flat, stdcall
option casemap :none
         
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

numMaxSize  equ 32

.data?
    num1 db (numMaxSize - 1) dup(?)
    num2 db (numMaxSize - 1) dup(?)

 
.data
    msgNum1 db "enter the first positive number: ", 0
    msgNum2 db "enter the second positive number: ", 0
    msgOut db "the sum of two entered number is: ", 0
 
    res db numMaxSize  dup(0)
 
.code
    
str2num:
   ; In, Out through eax
   mov edx, eax
   xor eax, eax		; zero eax (xor faster)

@toNum:
   movzx ecx, byte ptr [edx]	; get the char
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
   
   mov esi, offset res + numMaxSize	; addr (ptr) the res 
   mov ebx, 10			; for the div
   
@toStr:
	
   dec esi			; next char
   xor edx, edx		; rezo edx for the div
   div ebx			; [edx]eax / ebx
   or edx, 30h		; add 0x30 ('0' char) to edx (or faster)
   mov byte ptr [esi], dl		; move the dl (store 8 bit (1 byte) of the current digit - a part of edx) to ..
   or eax, eax			; check the eax is rezo?
   jnz @toStr			; eax is not rezo 
   
   mov eax, esi		; eax is rezo, pass the ptr to eax
				
	
   ret

write:
   push eax
   call StdOut
   ret

read:
   push ebx
   push eax
   call StdIn
   ret


main:
   ; Get the numbers in asciiz
   ;invoke     StdOut, offset msgNum1
   ;invoke     StdIn, offset num1, numMaxSize - 1
   
   mov eax, offset msgNum1
   call write

   mov ebx, numMaxSize - 1
   mov eax, offset num1
   call read                     ; it pass into num1 'cause of the ptr
   
   ;mov eax, 0
   ;mov eax, offset num1
   ;call write
   
   ;invoke     StdOut, offset msgNum2
   mov eax, offset msgNum2
   call write
   
   ;invoke     StdIn, offset num2, numMaxSize - 1
   mov ebx, numMaxSize - 1
   mov eax, offset num2
   call read

   ; Convert to numbers and sum
   mov        eax, offset num1
   call       str2num
   mov        ebx, eax

   mov        eax, offset num2
   call       str2num
   add        ebx, eax

	;Show the result
	;invoke     StdOut, offset msgOut		; print it first -> it cause to change the eax value
   mov eax, offset msgOut
   call write

	mov eax, ebx
	call       num2str
	;invoke     StdOut, eax
   call write

	;invoke     ExitProcess, 0
   push 0
   call ExitProcess

end main