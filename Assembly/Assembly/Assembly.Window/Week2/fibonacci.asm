.386
.model flat, stdcall
option casemap :none

include C:\masm32\include\windows.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\masm32.inc

includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\masm32.lib

.const
    fiMaxSize equ 100
    numNMaxSize equ 10

.data?
    strN db numNMaxSize dup(?)
    fiN db fiMaxSize dup(?)
    fiN1 db fiMaxSize dup(?)
    fiN2 db fiMaxSize dup(?)

.data
    msgIn db "enter number N: ", 0
    msgErr db "invalid input! the input should be a positive integer number and less then 100", 0ah, "Please, enter other number", 0ah, 0ah, 0
    msgOut db "the first N fibonaci number is: ", 0ah, 0

    pEndN dword 0                                        ; point to the end (null) of fibonaci N <fiN>
    pEndN1 dword 0                                       ; point to the end (null) of fibonaci N-1 <fiN1>
    pEndN2 dword 0                                       ; point to the end (null) of fibonaci N-2 <fiN2>
    pFirstN dword 0                                      ; point to the first
    pFirstN1 dword 0                                     ; ...
    pFirstN2 dword 0                                     ; ...
    
    count dword 0                                        ; counter -> N 
    check byte 0                                         ; check for invalid input
    cEnter db 0ah, 0                          
    
    
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

@toNum:                          
    movzx ecx, byte ptr [esi]           ; move value 1 character (1byte) which [esi] pointer to ecx
    cmp ecx, 0h                          ; check for null
    je @done_convert
    cmp ecx,'0'
    jl @err
    cmp ecx,'9'                         
    jg @err                             ;check for non-numeric
    sub ecx,'0'                         ;character char to int
    imul eax, 10                         ;eax *= 10
    add eax, ecx                         ;eax += ecx

@next:
    inc esi                             ;esi+=1 point to the next byte 
    jmp @toNum                   

@done_convert:
    cmp eax, 100
    jg @err
    ret                                 ;return to the calling

@err:
    mov check, 1
    ret


; update pointer to fibonaci number
update:            
    ;fiN2<- fiN1, fiN1<-fiN
    mov esi, pFirstN2
    mov edi, pFirstN1
    mov pFirstN2, edi
    mov edi, pFirstN
    mov pFirstN1, edi
    mov pFirstN, esi

    mov edi, pEndN1
    mov pEndN2, edi
    mov edi, pEndN
    mov pEndN1, edi
    
    ret
;endN update after adding   


fibonacciN:         
    ; add fiN1 and fiN2, store in fiN
    mov edi, pEndN1
    mov esi, pEndN2                  ; edi points to end-point (null) fiN1, esi points to end-point (null) fiN2
    xor edx, edx
    xor ecx, ecx                     ; counter

@add:
    xor eax, eax
    cmp esi, pFirstN2                ; check if esi points to the first char of fiN2 (store address of fiN2)
    je _L2                           ; if yes, meaning finished adding all digit of num2
    
_L1:                                 ; (if no) continue get char from num2
    dec esi                         
    movzx eax, byte ptr [esi]        ; eax stores 1-byte char in esi 
    sub eax,'0'                      ; change char to a 1-digit number 
    cmp edi, pFirstN1                ; check if finished adding digit of fiN1
    jne _L3                          ; if no, jmp L3
    mov ebx, 0                       ; if yes, ebx=0
    jmp _L4

_L2:                                 ; finished adding all digit of num2, eax=0
    mov eax, 0   
    cmp edi, pFirstN1                ; check if finished adding all
    je @finishedAdd

_L3:                                 ; continue get char from num1 
    dec edi
    movzx ebx, byte ptr [edi]        ; ebx stores 1-char after
    sub ebx, '0'                     ; change char to 1-digit number

_L4:                                 ; adding 
    add eax, ebx                     ; add 2 digit
    add eax, edx                     ; add rem
    mov edx, 0                       
    mov ebx, 10
    div ebx                         ; eax/ebx -> eax stores quotient, edx stores remainder
    push edx                        ; push edx to stack (digit of sum)
    inc ecx                         ; increase counter
    mov edx,eax                     ; stores rem
    jmp @add                        ; continue add

@finishedAdd:                       ; finished adding all digit of 2 num
    mov esi, pFirstN                ; esi points to fiN after
    cmp edx, 0                      ; check for rem
    je _L5                          ; if no rem, jmp to L5
    add edx, 48                     ; if yes, add rem to the first byte of sum
    mov byte ptr [esi], dl           
    inc esi
    xor edx, edx
    
_L5:
    cmp ecx, 0                      ; check for end using counter
    je @done                
    pop eax                         ; pop top-value(digit of sum) in stack and store into eax 
    dec ecx                         ; dec counter
    add eax, 48                     ; + '0'
    mov byte ptr [esi], al          ; add char to sum
    inc esi                     
    jmp _L5                        

@done:  
    mov pEndN, esi     
    ret



input:
@input:    
    push offset msgIn
    call StdOut

    push numNMaxSize
    push offset strN
    call StdIn

    mov check, 0

    mov esi, offset strN
    call str2num                        ; ouput: eax = N's value 
    cmp check, 1                         
    je @msgErr                          ; if check = 1 -> invalid input
    jmp @done_input

@msgErr:
    invoke StdOut, addr msgErr
    jmp @input

@done_input:
    ret


output:
    ; print output message
    push offset msgOut
    call StdOut

    ; print fi 1 (n = 1)
    mov eax, offset fiN1
    call print_output
    
    cmp count, 1                        ; N = 1   
    je @done_out

    ; print the fi 2 (n = 2)
    mov eax, offset fiN2
    call print_output
    
    cmp count, 2                        ; N = 2
    je @done_out

    ; N>2
    sub count, 2                        ; sub 2 first printed fi num
    mov pFirstN, offset fiN +1

@nextFi: 
    cmp count, 0                        ; no needed fibonacci to print
    je @done_out
    dec count
    call fibonacciN                     ; calculate fiN
    mov esi, pFirstN                         
    
    ; print N-th fibonacci number
    mov eax, pFirstN
    call print_output
    
    call update
    jmp @nextFi

@done_out:
    ret
       

print_output:
    ; input: eax point to the needed string (fi number)
    push eax
    call StdOut

    push offset cEnter
    call StdOut

    ret


main:
    ; input
    call input
    
    mov count, eax                          ; count = value of N
    cmp count, 0                            ; N = 0?
    ; no number to be printed
    je exit
    
    ; init the first 2 fibonaci
    mov byte ptr [fiN1], '1'                ; init fibonacci N-1 value
    mov pFirstN1, offset fiN1
    mov pEndN1, offset fiN1 + 1

    mov byte ptr [fiN2], '1'                ; init 
    mov pFirstN2, offset fiN2
    mov pEndN2, offset fiN2 + 1

    call output

exit:
    invoke ExitProcess, 0

end main