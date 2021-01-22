%macro writeString 2                    ;define a macro with 2 param
    mov eax,4                            ;system call number (sys_write)
    mov ebx,1                            ;to which file descriptor (1-> stdout)
    mov ecx,%1                          ;msg
    mov edx,%2                          ;length of msg
    int 80h                             ;call kernel
%endmacro

section .data
    lenMax equ 100
    msg1 db "Enter the first number: ",0    
    lenMsg1	equ	$ - msg1
    msg2 db "Enter the second number: ",0
    lenMsg2	equ	$ - msg2
    msg3 db "Sum of 2 numbers: ",0
    lenMsg3	equ	$ - msg3
    msgErr db "Invalid input: The non-numeric charactor",0ah
    lenMsgErr equ $ - msgErr
    check db 0
section .bss
    num1 resb lenMax
    num2 resb lenMax
    sum resb lenMax
section .text
    global _start
_start:
    call readInput
    cmp byte[check],1
    je _error

    call addBigNum 
    writeString msg3, lenMsg3
    writeString sum, lenMax
    jmp _end
    _error:
        writeString msgErr,lenMsgErr
    _end:
        mov	eax, 1	    ;system call number (sys_exit)
	    int	80h        ;call kernel

        
readInput:
    writeString msg1,lenMsg1                    ;call macro
	; Read and store the user input number
	mov eax, 3                                  ;system call number (sys_read)
	mov ebx, 2                                  ;stdin
	mov ecx,num1                                ;ecx stores offset of string to read
	mov edx, lenMax                             ;length of bytes to read
	int 80h                                     ;call kernel	
    mov esi, num1
    call checkNum
    mov edi,esi                                 ;edi points to end-point(null -after last char) of num1 
	
    writeString msg2,lenMsg2                    ;call macro
   	; Read and store the user input number
	mov eax, 3                                  ;system call number (sys_read)
	mov ebx, 2                                  ;stdin
	mov ecx,num2                                ;ecx stores offset of string to read
	mov edx, lenMax                             ;length of bytes to read
	int 80h                                     ;call kernel
    mov esi, num2
    call checkNum
    ret
checkNum:
    xor ecx,ecx
    _next:
        movzx ecx, byte [esi]              ;store 1-byte char pointed by esi to al 
	cmp eax,0
	je _isNum 
        cmp ecx,0ah                            ;check end-char of number
        je _isNum                           ;if yes
        cmp cl,'0'      
        jl _notNum  
        cmp cl,'9'
        jg _notNum                          ;check for non-numeric char, if exits, end loop
        inc esi
        jmp _next
    _isNum:                                 ;input is a number, return eax=1                         
        ret
    _notNum:                                ;input is not a number, return eax=0       
	mov byte[check],1
        ret 
addBigNum:      ;function to add 2 numbers, start: edi points to end point (0) of num1, esi points to end point (0) of num2
    xor edx,edx
    xor ecx,ecx                             ;counter
    _add:
        xor eax,eax
        cmp esi, num2                ;check if esi points to the first char of num2 (store address of num2)
        je L2                               ;if yes, meaning finished adding all digit of num2
        L1:                                 ;(if no) continue get char from num2
            dec esi                         
            movzx eax,byte [esi]        ;eax stores 1-byte char in esi 
            sub eax,'0'                     ;change char to a 1-digit number 
            cmp edi, num1            ;check if finished adding digit of num2
            jne L3                          ;if no, jmp L3
            mov ebx,0                       ;if yes, ebx=0
            jmp L4
        L2:                                 ;finished adding all digit of num2, eax=0
            mov eax,0   
            cmp edi,num1            ;check if finished adding all
            je _finishedAdd
        L3:                                 ;continue get char from num1 
            dec edi
            movzx ebx,byte [edi]        ;ebx stores 1-char after
            sub ebx,'0'                     ;change char to 1-digit number
        L4:                                 ;adding 
            add eax,ebx                     ;add 2 digit
            add eax,edx                     ;add rem
            mov edx,0                       
            mov ebx,10
            div ebx                         ;eax/ebx -> eax stores quotient, edx stores remainder
            push edx                        ;push edx to stack (digit of sum)
            inc ecx                         ;increase counter
            mov edx,eax                     ;stores rem
            jmp _add                        ;continue add
        _finishedAdd:                       ;finished adding all digit of 2 num
            mov esi, sum                    ;esi points to sum after
            cmp edx,0                       ;check for rem
            je L5                           ;if no rem, jmp to L5
            add edx,48                      ;if yes, add rem to the first byte of sum
            mov byte [esi],dl           
            inc esi
            xor edx,edx
            L5:
                cmp ecx,0                   ;check for end using counter
                je _finished                
                pop eax                     ;pop top-value(digit of sum) in stack and store into eax 
                dec ecx                     ;dec counter
                add eax,48                  ;move to ASKII representation
                mov byte [esi],al       ;add char to sum number
                inc esi                     
                jmp L5                        
            _finished:  
                mov eax,0ah                 ;enter after print sum
                mov byte [esi],al       
                ret   



