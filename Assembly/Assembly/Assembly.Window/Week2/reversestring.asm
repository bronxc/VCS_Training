.386
.model flat, stdcall
option casemap :none

include C:\masm32\include\windows.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\masm32.inc

includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\masm32.lib

.const
    strMaxSize equ 256

.data?
    string db strMaxSize dup(?)             ;declare strMaxSize-bytes 
    
.data
    msgIn db "enter the string: ",0         
    msgOut db "the reversed string is: ",0
    

.code

findStrEnd:
    ; Intput: esi point to the first of string
    ; Output: eax point to the end of string (not null)
    mov eax, esi                     ; move address in esi into eax

@next:
    cmp byte ptr [eax],0            ; 1 character (1-byte) in [eax] == 0 ?
    jz @done_find                        ; it's null -> end
    inc eax                         ; next char
    jmp @next               

@done_find:
    dec eax                         ; eax point to the end (not null)
    ret


; reverse the string <use swapping directedly>
reverseStr:
    ; esi points to string (first-char)
    ; eax stores address of end-char (not null) of string

    mov edi, eax                    ; edi points to the end of string              

@swap:
    cmp esi, edi                    ; esi >= edi ? first >= last ?
    jge @done                       
    
    ; swap 2 characters (1-byte) at [esi] and [edi 
    mov al, byte ptr [esi]
    xchg al, byte ptr [edi]         ; exchange 2 value -> swap
    mov byte ptr [esi], al   
    
    ; next char
    inc esi             
    dec edi
    jmp @swap 

@done:
    ret


input:
    ; print input message
    push offset msgIn
    call StdOut

    ; read the string
    push strMaxSize
    push offset string
    call StdIn

    ret

output:
    ; print output message
    push offset msgOut
    call StdOut

    ; print the reversed string
    push offset string
    call StdOut

    ret

main:    
    ; get input
    call input

    mov esi, offset string                  ; esi points to the first of string
    ; find the end of the string
    call findStrEnd                         ; output: eax point to the end (not null)
    
    ; reverse the string
    call reverseStr                         ; start reverse string 
    
    ; print output
    call output

    ; exit
    push 0
    call ExitProcess

end main