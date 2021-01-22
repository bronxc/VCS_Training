section .data
	numMaxSize equ 10
	operMaxSize equ 4

	msgIn db "chose the operand:", 0ah, "1. add + ", 0ah, "2. sub - ", 0ah, "3. multiply * ", 0ah, "4. divide / ", 0ah, "the operand is: ", 0
	len_msgIn equ $-msgIn

	msgInNum1 db "enter the first number: ", 0
	len_msgInNum1 equ $-msgInNum1

	msgInNum2 db "enter the second number: ", 0
	len_msgInNum2 equ $-msgInNum2

	msgErr db "Error!", 0
	len_msgErr equ $-msgErr

	msgOut db "the result is: ", 0
	len_msgOut equ $-msgOut

	msgDivRem db 0ah, "the reminder is: ", 0
	len_msgDivRem equ $-msgDivRem

	cNeg db "-", 0
	cEnter db 0ah, 0
	result dd 0
	check db 0


section .bss
	strNum1 resb numMaxSize
	strNum2 resb numMaxSize
	res resb numMaxSize						; store the number to string output

	oper resb operMaxSize



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


; number to string
num2str:
	; In: eax
	; esi point to str output
	mov esi, res + numMaxSize	        	; addr (ptr) the res 
	mov ebx, 10								; for the div

@toStr:

	dec esi			                        ; next char
	xor edx, edx	                        	; rezo edx for the div
	div ebx			                        ; [edx]eax / ebx
	or edx, 30h		                        ; add 0x30 ('0' char) to edx (or faster)
	mov byte [esi], dl		            	; move the dl (store 8 bit (1 byte) of the current digit - a part of edx) to ..
	or eax, eax			                    ; check the eax is rezo?
	jnz @toStr			                    ; eax is not rezo 

	mov eax, esi		                        ; eax is rezo, pass the ptr to eax
				
	ret



input:
	; operand option:
	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, msgIn
	mov edx, len_msgIn
	int 0x80

	mov eax, 3								; syscall (read)
	mov ebx, 2
	mov ecx, oper  
	mov edx, operMaxSize         
	int 0x80

	; num1
	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, msgInNum1
	mov edx, len_msgInNum1
	int 0x80

	mov eax, 3								; syscall (read)
	mov ebx, 2
	mov ecx, strNum1  
	mov edx, numMaxSize         
	int 0x80

	; num2
	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, msgInNum2
	mov edx, len_msgInNum2
	int 0x80

	mov eax, 3								; syscall (read)
	mov ebx, 2
	mov ecx, strNum2 
	mov edx, numMaxSize         
	int 0x80

	ret


output:
	push eax
	push ebx
	push ecx
	push edx

	; msg Out
	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, msgOut
	mov edx, len_msgOut
	int 0x80

	pop edx
	pop ecx
	pop ebx
	pop eax

	ret


addition:
	add eax, ebx
	call output
	call num2str

	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, res
	mov edx, numMaxSize
	int 0x80

	ret


subtract:
@check:
	call output
	cmp eax, ebx
	jl _less    
	sub eax, ebx
	jmp _subOut
_less:
	sub ebx, eax
	push ebx
	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, cNeg
	mov edx, 1
	int 0x80

	pop ebx
	mov eax, ebx

_subOut:
	call num2str

	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, res
	mov edx, numMaxSize
	int 0x80

	ret


multiply:
	xor edx, edx
	mul ebx

	call output
	call num2str

	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, res
	mov edx, numMaxSize
	int 0x80

	ret


divide:
	xor edx, edx
	div ebx

	call output
	push edx
	call num2str

	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, res
	mov edx, numMaxSize
	int 0x80

	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, msgDivRem
	mov edx, len_msgDivRem
	int 0x80

	pop edx

	mov eax, edx
	call num2str

	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, res
	mov edx, numMaxSize
	int 0x80

	ret


; simple calculator
calculator:
@checkOper:
	cmp byte [oper], '1'
	je @add
	cmp byte [oper], '2'
	je @sub
	cmp byte [oper], '3'
	je @mul
	cmp byte [oper], '4'
	je @div
	jmp @errOper                        	; other option => error
@add:

	call addition
	jmp @doneCal
@sub:
	call subtract
	jmp @doneCal
@mul:
	call multiply
	jmp @doneCal
@div:
	call divide
	jmp @doneCal
@errOper:
	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, msgErr
	mov edx, len_msgErr
	int 0x80

@doneCal:
	ret


;
; the main is here
;
_start:
	call input

	; num2 => int
	mov esi, strNum2
	call str2num                            ; in: esi, out: eax
	mov ebx, eax

	; num1 => int
	mov esi, strNum1
	call str2num

	call calculator

	mov eax, 4								; syscall (write)
	mov ebx, 1
	mov ecx, cEnter
	mov edx, 1
	int 0x80

	; exit
	mov eax, 1
	int 0x80
