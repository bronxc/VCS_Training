%macro writeString 2                    ;define a macro with 2 param
    mov eax,4                            ;system call number (sys_write)
    mov ebx,1                            ;to which file descriptor (1-> stdout)
    mov ecx,%1                          ;msg
    mov edx,%2                          ;length of msg
    int 80h                             ;call kernel
%endmacro

section	.data
	msg1 db "Enter string S: ",0
	lenMsg1	equ	$ - msg1
    	msg2 db "Enter string C: ",0
	lenMsg2 equ $ - msg2
    	msg3 db "Numbers of appearance: ",0
    	lenMsg3 equ $ - msg3
    	ent db 0ah,0
	len1 equ 100                            ;max length of s-string
    	len2 equ 10                             ;max length of c-string
	count dd 0
	pos_arr times len1 db 0
section .bss
    string resb len1                        
    c_string resb len2
    
    pos resb 4                              ;to store pos (in string) of appearance of C in S
    cnt resb 4                              ;to store the numbers of appearance of C in S
    
section .text
    global _start
_start:
    call readInput
    
    call findingString                      ;update pos_arr, ecx store the numbers of appearance
    mov eax, dword[count]
    mov esi, cnt +3
    mov byte [esi],0ah
    call toString
    writeString esi,4                       ;print out the numbers of appearance
   
    mov edi, pos_arr                 ;edi will point to each number of pos_array from left to right   
    print_Arr:
            movzx eax, byte [edi]
            cmp eax,0
            je exit
            sub eax,1
            mov esi, pos+3
            mov byte [esi], 20h
            call toString
            writeString esi,4
            inc edi
            jmp print_Arr
    exit:
        writeString ent,2
        mov eax, 1	    ;system call number (sys_exit)
	    int	80h        ;call kernel
readInput:
    	writeString msg1,lenMsg1                    ;call macro
	; Read and store the user input 
	mov eax, 3                                  ;system call number (sys_read)
	mov ebx, 2                                  ;stdin
	mov ecx,string                                ;ecx stores offset of string to read
	mov edx, len1                             ;length of bytes to read
	int 80h                                     ;call kernel	
	writeString msg2,lenMsg2                    ;call macro
   	 ; Read and store the user input 
	mov eax, 3                                  ;system call number (sys_read)
	mov ebx, 2                                  ;stdin
	mov ecx,c_string                                ;ecx stores offset of string to read
	mov edx, len2                             ;length of bytes to read
	int 80h                                     ;call kernel

    	writeString msg3,lenMsg3
    	ret
toString:                                  ;start with eax contained the value integer of sum
                                           ;esi store the address memory of end point (null)
    mov ebx,10                              
    _divide:
        xor edx,edx
        dec esi
        div ebx                             ; divide eax by ebx, edx hold remainder
        add edx,48                          ; convert edx - current digit to ASKII - string representation of a digit
        mov byte [esi], dl             	    ; get 1 byte contained character to store in 1 byte from esi location 
        cmp eax,0                           ; check if the integer can be devide anymore
        jne _divide                         ; if no zero, continue divide
        ret                                 ; return and esi is the pointer to the string Number (sum-answer) 

findingString:
    	xor eax,eax
    	mov edx,pos_arr              		;y stores address of first num of array
    	mov ecx,string                 		;x stores address of string
    L1:
        mov esi,ecx                   
        cmp byte [esi],0ah            ;check end of string S - x stores the address of end-point(null) of string
        je finished                             ;end of S
        mov edi,c_string
        L2:
            movzx eax, byte [edi]
            cmp eax,0ah
            je _yes                             ;end of C - C exits in S 
            cmp byte [esi],al
            jne _no                             ;dont exits in that pos
            inc esi
            inc edi
            jmp L2
        _yes:
            mov eax,ecx
            sub eax, string
            add eax,1
            mov esi,edx
            mov byte [esi],al                   ;store pos into the array
         	
	    inc dword[count]                            ;count numbers of appearance
            inc ecx                             ;increase x (move to the next char of string S)
            inc edx                             ; stores the address of next byte in array
            jmp L1
        _no:
            inc ecx                              ;increase x (move to the next char of string S)
            jmp L1
        finished:
            ret
