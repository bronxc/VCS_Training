section .data
    numMaxSize equ 100
    
    msgIn1 db "enter the first number: ", 0    
    len_msgIn1 equ $-msgIn1
    
    msgIn2 db "enter the second number: ", 0
    len_msgIn2 equ $-msgIn2
    
    msgOut db "sum of 2 numbers: ", 0
    len_msgOut equ $-msgOut
    
    msgErr db "invalid input: The non-numeric charactor", 0ah, 0        ;msg error end with enter (0ah)
    len_msgErr	equ $-msgErr
    
    
section .bss
    num1 resb numMaxSize                    ;declare uninitialized numMaxSize-bytes followed address of num1
    num2 resb numMaxSize                    ;declare uninitialized numMaxSize-bytes followed address of num2
    sum resb numMaxSize                     ;declare uninitialized numMaxSize-bytes followed address of sum


section .text
    global _start

; check for valid num (input)
checkNum:                                  
    ; input: esi -> point to the string number
    ; output: eax -> 0: invalid, 1: valid
    xor eax,eax                         ; init: eax = 0 -> invalid

    ; check: no entered input -> null
    cmp byte [esi], 0ah
    jz @notNum

@next:
    mov al, byte [esi]              ; store 1-byte char pointed by esi to al  
    cmp al, 0ah                           ; check end-char of number
    jz @isNum                           ; if yes
    cmp al,'0'      
    jl @notNum  
    cmp al,'9'
    jg @notNum                          ;check for non-numeric char, if exits, end loop
    inc esi
    jmp @next

@isNum:                                 ;input is a number, return eax=1 
    mov eax, 1                           
    ret

@notNum:                                ;input is not a number, return eax=0
    ret 
    

; function to add 2 numbers
addBigNum:
    ; input: edi points to end point (0) of num1, esi points to end point (0) of num2
    xor edx, edx
    xor ecx, ecx                             ;counter

@add:
    xor eax, eax
    cmp esi, num2           		 ; check if esi points to the first char of num2 (store address of num2)
    je _L2                          	 ; if yes, meaning finished adding all digit of num2
	
_L1:                            	 ; (if no) continue get char from num2
    dec esi                         
    movzx eax, byte [esi] 	      	; eax stores 1-byte char in esi 
    sub eax,'0'                    	; change char to a 1-digit number 
    cmp edi, num1     		     	; check if finished adding digit of num2
    jne _L3                         	; if no, jmp L3
    mov ebx, 0                      	; if yes, ebx=0
    jmp _L4

_L2:                                	; finished adding all digit of num2, eax=0
    mov eax, 0   
    cmp edi, num1	            	; check if finished adding all
    je @finishedAdd

_L3:                                	; continue get char from num1 
    dec edi
    movzx ebx, byte [edi] 	      	; ebx stores 1-char after
    sub ebx,'0'                     ; change char to 1-digit number

_L4:                                ; adding 
    add eax, ebx                    ; add 2 digit
    add eax, edx                    ; add rem
    mov edx, 0                       
    mov ebx, 10
    div ebx                         ; eax/ebx -> eax stores quotient, edx stores remainder
    push edx                        ; push edx to stack (digit of sum)
    inc ecx                         ; increase counter
    mov edx, eax                    ; stores rem
    jmp @add                        ; continue add

@finishedAdd:                       ; finished adding all digit of 2 num
    mov esi, sum                    ; esi points to sum after
    cmp edx, 0                      ; check for rem
    je _L5                          ; if no rem, jmp to L5
    add edx, 48                     ; if yes, add rem to the first byte of sum
    mov byte [esi], dl           
    inc esi
    xor edx, edx
    
_L5:
    cmp ecx, 0                      ; check for end using counter
    je @done                
    pop eax                         ; pop top-value(digit of sum) in stack and store into eax 
    dec ecx                         ; dec counter
    add eax, 48                     ; + '0'
    mov byte [esi],al          	 ;add char to sum number
    inc esi                     
    jmp _L5                        

@done:  
    mov eax, 0ah                 ; enter after print sum
    mov byte [esi], al       
    ret


; get the input
input:
@num1:    
    ; enter num1    
    mov eax, 4				; syscall (write)
    mov ebx, 1
    mov ecx, msgIn1
    mov edx, len_msgIn1
    int 0x80
    
    mov eax, 3				; syscall (read)
    mov ebx, 2
    mov ecx, num1  
    mov edx, numMaxSize        
    int 0x80

    ; check
    mov esi, num1                   ; esi points to num1
    call checkNum                          ; check if it's a number, return eax =1 for yes and eax=0 for no
    mov edi, esi                           ; edi points to end-point (null) of num1
    cmp eax, 1
    je @num2
    call error_msg
    jmp @num1
    
@num2: 
    ; enter num2
    mov eax, 4				; syscall (write)
    mov ebx, 1
    mov ecx, msgIn2
    mov edx, len_msgIn2
    int 0x80
    
    mov eax, 3				; syscall (read)
    mov ebx, 2
    mov ecx, num2  
    mov edx, numMaxSize        
    int 0x80


    ; check
    mov esi, num2
    call checkNum                         
    cmp eax, 1                             ; if no error, esi points to end-point (null) of num2
    je @done_in
    call error_msg
    jmp @num2                      

@done_in:
    ret


; print input error
error_msg:
    push edi
    
    mov eax, 4				; syscall (write)
    mov ebx, 1
    mov ecx, msgErr
    mov edx, len_msgErr
    int 0x80
    
    pop edi
    ret


output:
    ; print output message
    mov eax, 4				; syscall (write)
    mov ebx, 1
    mov ecx, msgOut
    mov edx, len_msgOut
    int 0x80
    
    mov eax, 4				; syscall (write)
    mov ebx, 1
    mov ecx, sum
    mov edx, numMaxSize
    int 0x80

    ret


_start:
    call input        
                                            
    call addBigNum                          ;adding 2 numbers function uses esi,edi 
    
    call output

    ; exit
    mov eax, 1
    int 0x80
