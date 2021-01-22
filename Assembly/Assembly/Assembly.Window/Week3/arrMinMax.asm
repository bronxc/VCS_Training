.386
.model flat, stdcall
option casemap :none

include C:\masm32\include\windows.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\masm32.inc

includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\masm32.lib

.const
    numMaxSize equ 11

.data?
    strNum db numMaxSize dup(?)
    res db numMaxSize dup(?)            ; store the number to string output

.data
    msgIn db "enter the array of positive integer number with the enter character between each number", 0ah, "it will stop when you enter a NaN", 0ah, "the array is: ", 0ah, 0
    msgOutMin db "the min number of array is: ", 0
    msgOutMax db 0ah, "the max number of array is: ", 0

    max dd 0
    min dd 2147483647
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
   mov ebx, 10			; for the div
   
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
    push numMaxSize
    push offset strNum
    call StdIn

    ret

output:
    ; min
    push offset msgOutMin
    call StdOut

    mov eax, min
    call num2str
    push eax
    call StdOut

    ; max
    push offset msgOutMax
    call StdOut

    mov eax, max
    call num2str
    push eax
    call StdOut

    ret

;
; the main is here
;
main:
    ; input message
    push offset msgIn
    call StdOut

@nextElem:
    call input
    
    mov esi, offset strNum
    call str2num                            ; in: esi, out: eax
    
    cmp check, 1
    je @done

@min:
    cmp eax, min
    jg @max
    mov min, eax
    
@max:
    cmp eax, max
    jl @nextElem
    mov max, eax 
    jmp @nextElem

@done:
    call output

    ; exit
    push 0
    call ExitProcess
end main