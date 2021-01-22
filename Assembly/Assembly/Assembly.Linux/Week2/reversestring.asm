section .data
    strMaxSize equ 256

    msgIn db "enter the string: ",0 
    len_msgIn equ $-msgIn
            
    msgOut db "the reversed string is: ",0
    len_msgOut equ $-msgOut    
    

section .bss
    string resb strMaxSize


section .text
    global _start

findStrEnd:
    ; Intput: esi point to the first of string
    ; Output: eax point to the end of string (not null)
    mov eax, esi                     ; move address in esi into eax

@next:
    cmp byte [eax], 0ah            ; 1 character (1-byte) in [eax] == 0 ?
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
    mov al, byte [esi]
    xchg al, byte [edi]         ; exchange 2 value -> swap
    mov byte [esi], al   
    
    ; next char
    inc esi             
    dec edi
    jmp @swap 

@done:
    ret


input:
    ; print input message
    mov eax, 4				; syscall (write)
    mov ebx, 1
    mov ecx, msgIn
    mov edx, len_msgIn
    int 0x80

    ; read the string
    mov eax, 3				; syscall (read)
    mov ebx, 2
    mov ecx, string 
    mov edx, strMaxSize        
    int 0x80

    ret

output:
    ; print output message
    mov eax, 4				; syscall (write)
    mov ebx, 1
    mov ecx, msgOut
    mov edx, len_msgOut
    int 0x80
    
    ; print the reversed string
    mov eax, 4				; syscall (write)
    mov ebx, 1
    mov ecx, string
    mov edx, strMaxSize
    int 0x80

    ret

_start:    
    ; get input
    call input

    mov esi, string                  ; esi points to the first of string
    ; find the end of the string
    call findStrEnd                         ; output: eax point to the end (not null)
    
    ; reverse the string
    call reverseStr                         ; start reverse string 
    
    ; print output
    call output

    ; exit
    mov eax, 1
    int 0x80
