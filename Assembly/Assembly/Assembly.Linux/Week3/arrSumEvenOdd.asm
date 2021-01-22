section .data
	numMaxSize equ 11

	msgIn db "enter the array of positive integer number with the enter character between each number", 0ah, "it will stop when you enter a NaN", 0ah, "the array is: ", 0ah, 0
	len_msgIn equ $-msgIn

	msgOutEven db "the sum of even number in array is: ", 0
	len_msgOutEven equ $-msgOutEven

	msgOutOdd db 0ah, "the sum of odd number in array is: ", 0
	len_msgOutOdd equ $-msgOutOdd


	sumEven dd 0
	sumOdd dd 0
	check db 0


section .bss
	strNum resb numMaxSize
	resEven resb numMaxSize
	resOdd resb numMaxSize

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

	mov eax, esi		                    ; eax is rezo, pass the ptr to eax
				
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
	mov eax, 4		; syscall (write)
	mov ebx, 1
	mov ecx, msgOutEven
	mov edx, len_msgOutEven
	int 0x80

	; min to string
	mov eax, [sumEven]
	mov esi, resEven + numMaxSize	        ; addr (ptr) the res 
	call num2str

	mov eax, 4		; syscall (write)
	mov ebx, 1
	mov ecx, resEven
	mov edx, numMaxSize
	int 0x80
   

	; max
	mov eax, 4		; syscall (write)
	mov ebx, 1
	mov ecx, msgOutOdd
	mov edx, len_msgOutOdd
	int 0x80

	; max to string
	mov eax, [sumOdd]
	mov esi, resOdd + numMaxSize	        ; addr (ptr) the res 
	call num2str

	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, resOdd
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

	; init for the div 2 => even or odd ?
	mov ebx, 2

@nextElem:
	call input

	mov esi, strNum
	call str2num                            ; in: esi, out: eax

	cmp byte [check], 1
	je @done

@even:
	mov ecx, eax
	xor edx, edx
	div ebx

	cmp edx, 0
	jne @odd
	add dword [sumEven], ecx
	jmp @nextElem

@odd:
	add dword [sumOdd], ecx 
	jmp @nextElem

@done:
	call output

	; exit
	mov eax, 1
	int 0x80
