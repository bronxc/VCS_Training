.386
.model flat, stdcall
option casemap :none

include C:\masm32\include\windows.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\masm32.inc

includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\masm32.lib

.const
    strSMaxSize equ 100
    strCMaxSize equ 10

.data?
    strS db strSMaxSize dup(?)          ; declare strSMaxSize-bytes to store
    strC db strCMaxSize dup(?)
    arrIndex byte strSMaxSize dup(?)    ; declare unititialized array of strSMaxSize 1-byte numbers
                                        ; store index_S where substring is found
    indexS db 4 dup(?)                  ; to store position of appearance of C in S
    count db 4 dup(?)                   ; to store the numbers of appearance of C in S

.data
    msgInS db "enter the string S: ", 0
    msgInC db "enter the string C: ", 0
    msgOut db "the number of substring C in S: ", 0

    pStrS dword 0                       ; 4byte number
    pArrIndex dword 0                   ; 4byte number
    strEnter db 0ah                     ; enter character -> to print enter

.code

findSubStr: 
    xor eax,eax
    xor ecx,ecx                         ; counter ecx starts with 0
    mov pArrIndex, offset arrIndex      ; pointer arrIndex
    mov pStrS, offset strS              ; pointer strS
    
@L1:                                    ; for the string S
    mov esi, pStrS                       
    cmp byte ptr [esi], 0               ; check end of string S - x stores the address of end-point(null) of string
    je @done                            ; end of S
    mov edi, offset strC

@L2:                                    ; check for the substring C
    movzx eax, byte ptr [edi]
    cmp eax, 0
    je _yes                             ; end of C - C exits in S 
    cmp byte ptr [esi], al              ; byte ptr of eax
    jne _no                             ; dont exits in that pos
    inc esi
    inc edi
    jmp @L2

_yes:
    mov eax, pStrS
    sub eax, offset strS
    add eax, 1
    mov esi, pArrIndex
    mov byte ptr [esi], al              ; store pos into the array
    inc ecx                             ; increase counter
    inc pStrS                           ; next char
    inc pArrIndex                       ; next index
    jmp @L1

_no:
    inc pStrS                           ; next char
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
    mov byte ptr [esi],dl 
    cmp eax, 0                          ; ? null
    jnz @toStr

    ret 


; get the input strings
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


; print the output
ouput:
    ; print the message output
    ; ecx stored the counter -> save in stack for the StdOut (msg -> ecx)
    push ecx
    
    push offset msgOut
    call StdOut
    ; get the value back to ecx
    pop ecx

    ; convert counter (ecx) to string -> esi -> count
    mov eax, ecx                            ; eax = counter
    mov esi, offset count + 3               ; esi points to end-point of count variable
    mov byte ptr [esi], 0ah                 ; the enter char in the last position -> no need to print enter char
    call num2str
    
    ; print counter (esi -> count variable)
    push esi
    call StdOut

    ; print the array of indexs substring
    mov edi, offset arrIndex            ; pointer
    
@printArr:
    movzx eax, byte ptr [edi]           ; get the value of index
    cmp eax, 0                           ; check for end of array
    je @done_out                        ; done print
    sub eax, 1                          ; postition starts by 0, the array stores pos started by 1
    
    mov esi, offset indexS +3           ; point to the end of indexS              
    mov byte ptr [esi], 20h             ; to print space (for the laziness)
    call num2str                        ; value in eax to string and stores in indexS -> esi
    
    ; print the index
    push esi
    call StdOut

    inc edi                             ; next index
    jmp @printArr

@done_out:
    ret


main:
    ; input
    call input

    ; find the substring C in S
    call findSubStr                         

    ; output
    call ouput

    ; exit    
    push 0
    call ExitProcess

end main