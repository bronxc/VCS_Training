 .386
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

strSMaxSize equ 100                   ;max size of the string (32 character)
strCMaxSize equ 30
numMaxSize equ 32

.data?
    strS db strSMaxSize dup(?)     ;the string to be entered
    strC db strCMaxSize dup(?)
    
    arrIndex byte strSMaxSize dup(?)       ; ?????
    

.data
    msgInS db "enter the string S: ", 0
    msgInC db "enter the string C: ", 0
    msgOut db "the number of substring C in S: ", 0
    res db numMaxSize  dup(0)

    ;ent db 0ah
    ;spa db 20h

    count dd 0 
    pArr dd 0
    curIndexS dd 0

    ;pp dw 0

.code

findSubStr:
    ; eax: offset strS
    ; ebx: offset strC

@find:
    
    mov cl, byte ptr [eax]       ; eax is the pointer, so [eax] the current char
    mov dl, byte ptr [ebx]       
    cmp cl, 0
    je @done            ; cl is null, there is no other chars
    cmp cl, dl          ; = the first char in the string C
    je @check           ; check for the rest of string C
    
    jmp @next           ; cl != dl
    
@check:
    inc ebx
    mov dl, byte ptr [ebx]       
    cmp dl, 0
    je _lastChar

    inc eax
    mov cl, byte ptr [eax]       
    cmp cl, 0
    je @done
    cmp cl, dl
    je @check
    
    dec eax
    jmp @next
    

_lastChar:
    mov ebx, offset strC  
    sub curIndexS, offset strS
    
    push eax
    mov eax, curIndexS
    
    mov esi, pArr
    mov byte ptr [esi], al
    inc pArr
    
    ;inc arrIndex
    pop eax
    
    inc count

@next:
    inc eax             ; not al, that's the character. eax has to
                        ; be increased, to point to next char

    mov ebx, offset strC 
    mov curIndexS, eax
    jmp @find

@done:
    ret


; get input string
input:
    ;read string S
    push offset msgInS
    call StdOut

    push strSMaxSize
    push offset strS
    call StdIn

    ;read string C
    push offset msgInC
    call StdOut

    push strCMaxSize
    push offset strC
    call StdIn

    ret


; convert number to string
num2str:
   ; In: eax
   
   mov esi, offset res + numMaxSize	; addr (ptr) the res 
   mov ebx, 10			; for the div
   inc esi

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


; print the ouput
output:
    ret

space:
    push offset spa
    call StdOut
    ret 

pEnter:
    push offset ent
    call StdOut
    ret

main:
    
    ;read the input s, c 
    call input


    ;mov pp, offset arrIndex

    ;pass the arg
    mov eax, offset strS
    mov ebx, offset strC
    mov pArr, offset arrIndex 

    call findSubStr

    ;invoke StdOut, edx
    ;inc count

    mov eax, count
    call num2str
    invoke StdOut, eax
    
    ;call pEnter

    xor eax, eax

    mov edi, offset arrIndex
    ;inc edi
    ;inc edi
    movzx eax, byte ptr [edi]
    
    call num2str
    invoke StdOut, eax




    ;invoke ExitProcess, 0           ;end the program
    push 0
    call ExitProcess
    
end main