section .data
    strSMaxSize equ 100
    strCMaxSize equ 10
    
    msgInS db "enter the string S: ", 0
    len_msgInS equ $-msgInS
    
    msgInC db "enter the string C: ", 0
    len_msgInC equ $-msgInC    
    
    msgOut db "the number of substring C in S: ", 0
    len_msgOut equ $-msgOut
    
    arrIndex times strSMaxSize db 0      ; store index_S where substring is found 
    count dd 0
    strEnter db 0ah                     ; enter character -> to print enter


section .bss
    strS resb strSMaxSize               ; declare strSMaxSize-bytes to store
    strC resb strCMaxSize  

    indexS resb 4                       ; to store position of appearance of C in S
    strCount resb 4                        ; to store the numbers of appearance of C in S


section .text
    global _start

findSubStr: 
    xor eax, eax
    mov edx, arrIndex      ; pointer arrIndex
    mov ecx, strS              ; pointer strS
    
@L1:                                    ; for the string S
    mov esi, ecx                       
    cmp byte [esi], 0ah               ; check end of string S - x stores the address of end-point(null) of string
    je @done                            ; end of S
    mov edi, strC

@L2:                                    ; check for the substring C
    movzx eax, byte [edi]
    cmp eax, 0ah
    je _yes                             ; end of C - C exits in S 
    cmp byte [esi], al              ; byte ptr of eax
    jne _no                             ; dont exits in that pos
    inc esi
    inc edi
    jmp @L2

_yes:
    mov eax, ecx
    sub eax, strS
    add eax, 1
    mov esi, edx
    mov byte [esi], al              ; store pos into the array
    
    inc dword[count]                             ; increase counter
    inc ecx                           ; next char
    inc edx                       ; next index
    jmp @L1

_no:
    inc ecx                           ; next char
    jmp @L1

@done:
    ret


; convert number to string
num2str:                                
    ; input: eax -> number
    ; esi : pointer -> end of string    
    mov ebx,10

@toStr:
    xor edx,edx
    dec esi
    div ebx
    add edx, 48                         ; char '0'
    mov byte [esi], dl 
    cmp eax, 0                          ; ? null
    jnz @toStr

    ret 


; get the input strings
input:
    ;read string S
    mov eax, 4				; syscall (write)
    mov ebx, 1
    mov ecx, msgInS
    mov edx, len_msgInS
    int 0x80
   
    mov eax, 3				; syscall (read)
    mov ebx, 2
    mov ecx, strS  
    mov edx, strSMaxSize        
    int 0x80

    ;read string C
    mov eax, 4				; syscall (write)
    mov ebx, 1
    mov ecx, msgInC
    mov edx, len_msgInC
    int 0x80
   
    mov eax, 3				; syscall (read)
    mov ebx, 2
    mov ecx, strC  
    mov edx, strCMaxSize        
    int 0x80
    ret


; print the output
ouput:
    ; print the message output
    mov eax, 4				; syscall (write)
    mov ebx, 1
    mov ecx, msgOut
    mov edx, len_msgOut
    int 0x80
    

    ; convert counter to string -> esi -> strCount
    mov eax, dword[count]                            ; eax = count
    mov esi, strCount + 3               ; esi points to end-point of count variable
    mov byte [esi], 0ah                 ; the enter char in the last position -> no need to print enter char
    call num2str
    
    ; print counter (esi -> count variable)
    mov eax, 4				; syscall (write)
    mov ebx, 1
    mov ecx, esi
    mov edx, 4
    int 0x80
    
    ; print the array of indexs substring
    mov edi, arrIndex            ; pointer
    
@printArr:
    movzx eax, byte [edi]           ; get the value of index
    cmp eax, 0                           ; check for end of array
    je @done_out                        ; done print
    sub eax, 1                          ; postition starts by 0, the array stores pos started by 1
    
    mov esi, indexS +3           ; point to the end of indexS              
    mov byte [esi], 20h             ; to print space (for the laziness)
    call num2str                        ; value in eax to string and stores in indexS -> esi
    
    ; print the index
    mov eax, 4				; syscall (write)
    mov ebx, 1
    mov ecx, esi
    mov edx, 4
    int 0x80
    
    inc edi                             ; next index
    jmp @printArr

@done_out:
    ret


_start:
    ; input
    call input

    ; find the substring C in S
    call findSubStr                         

    ; output
    call ouput

    ; exit    
    mov eax, 1
    int 0x80
