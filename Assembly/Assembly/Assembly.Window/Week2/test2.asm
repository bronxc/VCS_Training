.386
.model flat, stdcall
option casemap :none
include C:\masm32\include\windows.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\masm32.inc
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\masm32.lib
.const
    len1 equ 100
    len2 equ 10
.data?
    string db len1 dup(?)             ;declare len1-bytes to store
    c_string db len2 dup(?)
    pos_arr byte len1 dup(?)            ;declare unititialized array of len1 1-byte numbers
    pos db 4 dup(?)                     ; to store position of appearance of C in S
    cnt db 4 dup(?)                     ; to store the numbers of appearance of C in S
.data
    msg1 db "Enter string S: ",0         
    msg2 db "Enter string C: ",0             
    x dword 0                           ; 4byte number
    y dword 0                           ; 4byte number
    ent db 0ah                          ; enter character -> to print enter
.code
findingString: 
    xor eax,eax
    xor ecx,ecx                         ;counter ecx starts with 0
    mov y, offset pos_arr               ;y stores address of first num of array
    mov x,offset string                 ;x stores address of string
    L1:
        mov esi,x                       
        cmp byte ptr [esi],0            ;check end of string S - x stores the address of end-point(null) of string
        je finished                             ;end of S
        mov edi, offset c_string
        L2:
            movzx eax, byte ptr [edi]
            cmp eax,0
            je _yes                             ;end of C - C exits in S 
            cmp byte ptr [esi],al
            jne _no                             ;dont exits in that pos
            inc esi
            inc edi
            jmp L2
        _yes:
            mov eax, x
            sub eax,offset string
            add eax,1
            mov esi,y
            mov byte ptr [esi],al              ;store pos into the array
            inc ecx                            ;count numbers of appearance
            inc x                              ;increase x (move to the next char of string S)
            inc y                              ; stores the address of next byte in array
            jmp L1
        _no:
            inc x                               ;increase x (move to the next char of string S)
            jmp L1
        finished:
            ret
toString:                   ;use eax, esi : eax stores value integer, esi point to end-point of string
        mov ebx,10
        _divide:
            xor edx,edx
            dec esi
            div ebx
            add edx,48
            mov byte ptr [esi],dl 
            cmp eax,0
            jnz _divide
        _done:
            
            ret 
main:
    invoke StdOut, addr msg1
    invoke StdIn, addr string, len1         ;read string
    invoke StdOut, addr msg2
    invoke StdIn, addr c_string, len2       ;read c_string

    call findingString                      ;update pos_arr

    mov eax,ecx                             ;eax = numbers of appearance
    mov esi, offset cnt + 3                 ;esi points to end-point of cnt variable
    call toString
    invoke StdOut, esi                      ;print counter
    invoke StdOut, addr ent
    mov edi, offset pos_arr
    print_Arr:
        movzx eax, byte ptr [edi];
        cmp eax,0                           ;check for end of array
        je exit                             ;done print
        sub eax,1                           ;postition starts by 0, the array stores pos started by 1
        mov esi, offset pos +3              
        mov byte ptr [esi],20h              ;to print space
        call toString                       ;value in eax to string and stores in pos
        invoke StdOut,esi                   ;print pos (esi points first char of pos)
        inc edi                             ;increase edi, edi stores the addr of next number in arr
        jmp print_Arr
    exit:
        invoke StdOut, addr ent             ;print enter
        invoke ExitProcess,0
end main