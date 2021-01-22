.386
.model flat, stdcall
option casemap :none

include C:\masm32\include\windows.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\masm32.inc

includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\masm32.lib

.const
    numMaxSize equ 10
    operMaxSize equ 4

.data?
    strNum1 db numMaxSize dup(?)
    strNum2 db numMaxSize dup(?)
    res db numMaxSize dup(?)            ; store the number to string output

    oper db operMaxSize dup(?)

.data
    msgIn db "chose the operand:", 0ah,
            "1. add + ", 0ah, "2. sub - ", 0ah, 
            "3. multiply * ", 0ah, "4. divide / ", 0ah, 
            "the operand is: ", 0

    msgInNum1 db "enter the first number: ", 0
    msgInNum2 db "enter the second number: ", 0
    msgErr db "Error!", 0

    msgOut db "the result is: ", 0
    msgDivRem db 0ah, "the reminder is: ", 0

    cNeg db "-", 0
    result dd 0
    check db 0

.code

; to change input number N to integer to check the condition -> check 
str2num:                                  
    ; input: esi point to the strN
    ; eax -> the value number
    ; check -> the result of checking condition; 1 -> err
    ; check for the no input entered (null)
    cmp byte ptr [esi], 0h
    je @err
    mov eax, 0            
    mov check, 0
@toNum:                          
    movzx ecx, byte ptr [esi]               ; move value 1 character (1byte) which [esi] pointer to ecx
    cmp ecx, 0h                             ; check for null
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
    mov check, 1
    ret


num2str:
   ; In: eax
   
   mov esi, offset res + numMaxSize	        ; addr (ptr) the res 
   xor ebx, ebx
   mov ebx, 10			; for the div
   mov byte ptr [esi], 0
@toStr:
	
   dec esi			                        ; next char
   xor edx, edx	                        	; rezo edx for the div
   div ebx			                        ; [edx]eax / ebx
   or edx, 30h		                        ; add 0x30 ('0' char) to edx (or faster)
   mov byte ptr [esi], dl		            ; move the dl (store 8 bit (1 byte) of the current digit - a part of edx) to ..
   or eax, eax			                    ; check the eax is rezo?
   jnz @toStr			                    ; eax is not rezo 
   
   mov eax, esi		                        ; eax is rezo, pass the ptr to eax
				
   ret


input:
    ; operand option:
    push offset msgIn
    call StdOut
    
    push operMaxSize
    push offset oper
    call StdIn

    ; num1
    push offset msgInNum1
    call StdOut

    push numMaxSize
    push offset strNum1
    call StdIn

    ; num2
    push offset msgInNum2
    call StdOut

    push numMaxSize
    push offset strNum2
    call StdIn

    ret

output:
    push eax
    push edx
    ; msg Out
    push offset msgOut
    call StdOut

    pop edx
    pop eax
    
    ret

addition:
    add eax, ebx
    call output
    
    call num2str
    push eax
    call StdOut

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
    push offset cNeg
    call StdOut
    mov eax, ebx

_subOut:
    call num2str
    push eax
    call StdOut

    ret


multiply:
    xor edx, edx
    mul ebx

    call output
    call num2str
    push eax
    call StdOut

    ret


divide:
    xor edx, edx
    div ebx
    
    call output
    push edx
    call num2str
    push eax
    call StdOut

    push offset msgDivRem
    call StdOut
    pop edx

    mov eax, edx
    call num2str
    push eax
    call StdOut

    ret


; simple calculator
calculator:
@checkOper:
    cmp oper, '1'
    je @add
    cmp oper, '2'
    je @sub
    cmp oper, '3'
    je @mul
    cmp oper, '4'
    je @div
    jmp @errOper                                        ; other option => error
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
    push offset msgErr
    call StdOut

@doneCal:
    ret


;
; the main is here
;
main:
    call input

    ; num2 => int
    mov esi, offset strNum2
    call str2num                            ; in: esi, out: eax
    mov ebx, eax

    ; num1 => int
    mov esi, offset strNum1
    call str2num
    
    call calculator

@exit:
    ; exit
    push 0
    call ExitProcess
end main