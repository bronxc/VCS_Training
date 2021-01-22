%macro writeString 2                    ;define a macro with 2 param
    mov eax,4                            ;system call number (sys_write)
    mov ebx,1                            ;to which file descriptor (1-> stdout)
    mov ecx,%1                          ;msg
    mov edx,%2                          ;length of msg
    int 80h                             ;call kernel
%endmacro

section .data
    ent db 0ah,0						;to print enter
    msg1 db "Enter N: ",0    
    lenMsg1 equ	$ - msg1
    msg2 db "The first N fibonaci number is: ",0ah,0
    lenMsg2 equ	$ - msg2
    msgErr db "Invalid input",0ah,0
    lenMsgErr equ $ - msgErr
    check db 0							;to check invalid input
    lenMax equ 100						;max length of fibonaci number
    lenN equ 10							;max length of N
    cnt dw 0                    ;store N in number
    
section .bss
    n_string resb lenN
    fiN resb lenMax
    fiN1 resb lenMax
    fiN2 resb lenMax
section .text
    global _start
_start:
    call readInput
    cmp byte[check],1
    je _msgErr                      		;if check =1 -> invalid input
    mov dword[cnt],eax                     	;cnt=N
    cmp dword[cnt],0                       	;N=0?
    je _end
    writeString msg2,lenMsg2		   	;N>0, start print first N fibonaci numbers
    startPrint:
        mov byte [fiN1],'1'		;f(1)=1
        mov byte [fiN2],'1'		;f(2)=1
        writeString fiN1,lenMax
	writeString ent,1		
        cmp dword[cnt],1   		;N=1?
        je _end

        writeString fiN2,lenMax
	writeString ent,1
        cmp dword[cnt],2		;N=2?
        je _end
        				;N>2                      
        sub dword[cnt],2
	mov edi,fiN1+1			;edi points f(n-1)
	mov esi,fiN2+1			;esi points f(n-2)
        F1:
            cmp dword[cnt],0		
            je _end
            dec dword[cnt]		
            call _fiN			;calculate f(n) by adding fiN1,fiN2 and stores into fiN
	    writeString fiN,lenMax	;print f(n)
            writeString ent,1
            call _update		;update fiN2<- f(n-1); fiN1<- f(n)
            jmp F1
    _msgErr:
        writeString msgErr,lenMsgErr	;invalid input
        writeString ent,1
    _end:
        mov eax, 1	    		;system call number (sys_exit)
	int 80h        			;call kernel



readInput:
    writeString msg1,lenMsg1
    ; Read and store the user input number
	mov eax, 3                                  ;system call number (sys_read)
	mov ebx, 2                                  ;stdin
	mov ecx,n_string                                ;ecx stores offset of string to read
	mov edx, lenN                             ;length of bytes to read
	int 80h                                     ;call kernel	
    mov esi, n_string	
    call _toNumber
    ret
_toNumber:                      ;start: esi is the pointer to the numberString
    xor eax,eax    
    xor ecx,ecx        
    _startConvert:                          
        movzx ecx, byte [esi]           	; move value 1 character (1byte) which [esi] pointer to ecx
        cmp ecx,0ah                         	; check for null
        je _done
        cmp ecx,'0'
        jl _err
        cmp ecx,'9'                         
        jg _err                             ;check for non-numeric
        sub ecx,'0'                         ;character char to int
        imul eax,10                         ;eax *= 10
        add eax,ecx                         ;eax += ecx
    _next:
        inc esi                             ;esi+=1 point to the next byte 
        jmp _startConvert                   
    _done:
        ret                                 ;return to the calling, eax stores value
    _err:
        mov byte[check],1	
        ret
_fiN:   ; add fiN1 and fiN2, store in fiN
        ; edi points to end-point (null) fiN1, esi points to end-point (null) fiN2
    xor edx,edx
    xor ecx,ecx                             ;counter
    _add:
        xor eax,eax
        cmp esi, fiN2               ;check if esi points to the first char of fiN2 (store address of fiN2)
        je L2                               ;if yes, meaning finished adding all digit of num2
        L1:                                 ;(if no) continue get char from num2
            dec esi                         
            movzx eax,byte [esi]        ;eax stores 1-byte char in esi 
            sub eax,'0'                     ;change char to a 1-digit number 
            cmp edi, fiN1                ;check if finished adding digit of fiN1
            jne L3                          ;if no, jmp L3
            mov ebx,0                       ;if yes, ebx=0
            jmp L4
        L2:                                 ;finished adding all digit of num2, eax=0
            mov eax,0   
            cmp edi, fiN1            	    ;check if finished adding all
            je _finishedAdd
        L3:                                 ;continue get char from num1 
            dec edi
            movzx ebx,byte [edi]            ;ebx stores 1-char after
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
            mov esi, fiN                    ;esi points fiN after to store sum
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
                mov byte [esi],al           ;add digit of sum to fiN
                inc esi                     
                jmp L5                        
            _finished:       
                ret
_update:    ;fiN2<-fiN1,fiN1<-fiN
    ;copy fiN1 and stores in fiN2
    mov esi, fiN1
    mov edi, fiN2		
    U1:
        cmp byte [esi],0
        je done1
        mov al,byte [esi]
        mov byte [edi],al
        inc edi
        inc esi
        jmp U1
    done1:
    mov edx,edi				;stores address end of fiN2
    ;copy fiN and stores in fiN1
    mov esi,fiN
    mov edi,fiN1
    U2:
        cmp byte [esi],0
        je done2
        mov al,byte [esi]
        mov byte [edi],al
        inc edi
        inc esi
        jmp U2 
    done2:
        mov esi,edx             ;esi points to end of fiN2
        ret                     ;edi points to end of fiN1
        
