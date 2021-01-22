section .data
	numMaxSize equ 11

	msgIn db "enter the array of positive integer number with the enter character between each number", 0ah, "it will stop when you enter a NaN", 0ah, "the array is: ", 0ah, 0
	len_msgIn equ $-msgIn

	msgOutMin db "the min number of array is: ", 0
	len_msgOutMin equ $-msgOutMin

	msgOutMax db 0ah, "the max number of array is: ", 0
	len_msgOutMax equ $-msgOutMax


	min dd 2147483647
	max dd 0
	check db 0


section .bss
	strNum resb numMaxSize
	resMin resb numMaxSize
	resMax resb numMaxSize

section .text
	global _start
	
; to change input number N to integer to check the condition -> check 
str2num:                                  
	; input: esi point to the strN
	; eax -> the value number
	; check -> the result of checking condition; 1 -> err
	; check for the no input entered (null)
	cmp byte [esi], 0ah
	je @err
	mov eax, 0            
	mov byte [check], 0
@toNum:                          
	movzx ecx, byte [esi]               	; move value 1 character (1byte) which [esi] pointer to ecx
	cmp ecx, 0ah                            ; check for null
	je @done_convert
	cmp ecx,'0'
	jl @err
	cmp ecx,'9'                         
	jg @err                                 ;check for non-numeric
	sub ecx,'0'                             ;character char to int
	imul eax, 10                            ;eax *= 10
	add eax, ecx                            ;eax += ecx

@next:
	inc esi                                 ;esi+=1 point to the next byte 
	jmp @toNum                   

@done_convert:
	ret                                     ;return to the calling

@err:
	mov byte [check], 1
	ret


num2str:
	; In: eax
	; esi point to str output
	mov ebx, 10								; for the div
   
@toStr:

	dec esi			                        ; next char
	xor edx, edx	                        	; rezo edx for the div
	div ebx			                        ; [edx]eax / ebx
	or edx, 30h		                        ; add 0x30 ('0' char) to edx (or faster)
	mov byte [esi], dl		            	; move the dl (store 8 bit (1 byte) of the current digit - a part of edx) to ..
	or eax, eax			                    ; check the eax is rezo?
	jnz @toStr			                    ; eax is not rezo 

	mov eax, esi		                  	; eax is rezo, pass the ptr to eax
				
	ret


input:
	mov eax, 3								; syscall (read)
	mov ebx, 2
	mov ecx, strNum  
	mov edx, numMaxSize         
	int 0x80

	ret


output:
	; min
	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, msgOutMin
	mov edx, len_msgOutMin
	int 0x80

	; min to string
	mov eax, [min]
	mov esi, resMin + numMaxSize	        ; addr (ptr) the res 
	call num2str

	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, resMin
	mov edx, numMaxSize
	int 0x80


	; max
	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, msgOutMax
	mov edx, len_msgOutMax
	int 0x80

	; max to string
	mov eax, [max]
	mov esi, resMax + numMaxSize	        ; addr (ptr) the res 
	call num2str

	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, resMax
	mov edx, numMaxSize
	int 0x80

	ret
    
    
;
; the main is here
;
_start:
	; input message
	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, msgIn
	mov edx, len_msgIn
	int 0x80

   
@nextElem:
	call input

	mov esi, strNum
	call str2num                            ; in: esi, out: eax

	cmp byte [check], 1
	je @done

@min:
	cmp eax, [min]
	jg @max
	mov dword [min], eax

@max:
	cmp eax, [max]
	jl @nextElem
	mov dword [max], eax 
	jmp @nextElem

@done:
	call output

	; exit
	mov eax, 1
	int 0x80
