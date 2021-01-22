section .data
	cEnter db 0ah, 0						;to print enter
	fiMaxSize equ 100						;max length of fibonaci number
	numMaxSize equ 10							;max length of N

	msgIn db "enter N: ",0    
	len_msgIn equ $-msgIn

	msgOut db "The first N fibonaci number is: ",0
	len_msgOut equ $-msgOut

	msgErr db "Invalid input",0ah,0
	len_msgErr equ $ - msgErr

	check db 0							;to check invalid input
	count dw 0                    				;store N in number

   
section .bss
	strN resb numMaxSize
	fiN resb fiMaxSize
	fiN1 resb fiMaxSize
	fiN2 resb fiMaxSize


section .text
	global _start
    
    
input:
	; input msg
	mov eax, 4		; syscall (write)
	mov ebx, 1
	mov ecx, msgIn
	mov edx, len_msgIn
	int 0x80

	; Read 
	mov eax, 3                                  ;system call number (sys_read)
	mov ebx, 2                                  ;stdin
	mov ecx, strN                                ;ecx stores offset of string to read
	mov edx, numMaxSize                             ;length of bytes to read
	int 80h                                     ;call kernel	

	mov esi, strN	
	call str2num
	ret
    
 
str2num:                      
	;start: esi is the pointer to the numberString
	xor eax,eax    
	xor ecx,ecx        
@startConvert:                          
	movzx ecx, byte [esi]           	; move value 1 character (1byte) which [esi] pointer to ecx
	cmp ecx,0ah                         	; check for null
	je @done
	cmp ecx,'0'
	jl @err
	cmp ecx,'9'                         
	jg @err                             ;check for non-numeric
	sub ecx,'0'                         ;character char to int
	imul eax,10                         ;eax *= 10
	add eax,ecx                         ;eax += ecx
@next:
	inc esi                             ;esi+=1 point to the next byte 
	jmp @startConvert                   
@done:
	ret                                 ;return to the calling, eax stores value
@err:
	mov byte[check],1	
	ret
	   
        
fibonacci:   
	; add fiN1 and fiN2, store in fiN
	; edi points to end-point (null) fiN1, esi points to end-point (null) fiN2
	xor edx,edx
	xor ecx,ecx                             ;counter
@add:
	xor eax,eax
	cmp esi, fiN2               ;check if esi points to the first char of fiN2 (store address of fiN2)
	je _L2                               ;if yes, meaning finished adding all digit of num2
	
_L1:                                 ;(if no) continue get char from num2
	dec esi                         
	movzx eax,byte [esi]        ;eax stores 1-byte char in esi 
	sub eax,'0'                     ;change char to a 1-digit number 
	cmp edi, fiN1                ;check if finished adding digit of fiN1
	jne _L3                          ;if no, jmp L3
	mov ebx,0                       ;if yes, ebx=0
	jmp _L4

_L2:                                 ;finished adding all digit of num2, eax=0
	mov eax,0   
	cmp edi, fiN1            	    ;check if finished adding all
	je @finishedAdd

_L3:                                 ;continue get char from num1 
	dec edi
	movzx ebx,byte [edi]            ;ebx stores 1-char after
	sub ebx,'0'                     ;change char to 1-digit number

_L4:                                 ;adding 
	add eax,ebx                     ;add 2 digit
	add eax,edx                     ;add rem
	mov edx,0                       
	mov ebx,10
	div ebx                         ;eax/ebx -> eax stores quotient, edx stores remainder
	push edx                        ;push edx to stack (digit of sum)
	inc ecx                         ;increase counter
	mov edx,eax                     ;stores rem
	jmp @add                        ;continue add

@finishedAdd:                       ;finished adding all digit of 2 num
	mov esi, fiN                    ;esi points fiN after to store sum
	cmp edx, 0                       ;check for rem
	je _L5                           ;if no rem, jmp to L5
	add edx, 48                      ;if yes, add rem to the first byte of sum
	mov byte [esi],dl           
	inc esi
	xor edx, edx
	
_L5:
	cmp ecx,0                   ;check for end using counter
	je @finished                
	pop eax                     ;pop top-value(digit of sum) in stack and store into eax 
	dec ecx                     ;dec counter
	add eax, 48                  ;move to ASKII representation
	mov byte [esi],al           ;add digit of sum to fiN
	inc esi                     
	jmp _L5                        

@finished:       
	ret
			
                
update:    
	;fiN2<-fiN1,fiN1<-fiN
	;copy fiN1 and stores in fiN2
	mov esi, fiN1
	mov edi, fiN2		
@U1:
	cmp byte [esi],0
	je @done1
	mov al,byte [esi]
	mov byte [edi],al
	inc edi
	inc esi
	jmp @U1

@done1:
	mov edx,edi				;stores address end of fiN2
	;copy fiN and stores in fiN1
	mov esi,fiN
	mov edi,fiN1

@U2:
	cmp byte [esi],0
	je @done2
	mov al,byte [esi]
	mov byte [edi],al
	inc edi
	inc esi
	jmp @U2 

@done2:
	mov esi,edx             ;esi points to end of fiN2
	ret                     ;edi points to end of fiN1
	

print:
	mov eax, 4		; syscall (write)
	mov ebx, 1 
	int 0x80

	mov eax, 4		; syscall (write)
	mov ebx, 1
	mov ecx, cEnter
	mov edx, 1
	int 0x80

	ret

_start:
	call input

	cmp byte[check],1
	je @msgErr                      		;if check =1 -> invalid input

	mov dword[count],eax                     	;count=N
	cmp dword[count],0                       	;N=0?
	je @exit

	;N>0, start print first N fibonaci numbers
	mov ecx, msgOut
	mov edx, len_msgOut
	call print
    
    
@printFI:
	; intit
	mov byte [fiN1],'1'		;f(1)=1
	mov byte [fiN2],'1'		;f(2)=1
	
	; output msg
	mov ecx, fiN1
	mov edx, fiMaxSize
	call print

	cmp dword[count], 1   		;N=1?
	je @exit

	mov ecx, fiN2
	mov edx, fiMaxSize
	call print
	
	cmp dword[count], 2		;N=2?
	je @exit
	
	;N>2                      
	sub dword[count],2
	mov edi, fiN1+1			;edi points f(n-1)
	mov esi, fiN2+1			;esi points f(n-2)
        
_F1:
	cmp dword[count], 0		
	je @exit
	dec dword[count]		
	call fibonacci			;calculate f(n) by adding fiN1,fiN2 and stores into fiN

	mov ecx, fiN
	mov edx, fiMaxSize
	call print
	
	call update		;update fiN2<- f(n-1); fiN1<- f(n)
	jmp _F1

@msgErr:
	mov eax, 4		; syscall (write)
	mov ebx, 1
	mov ecx, msgErr
	mov edx, len_msgErr
	int 0x80

@exit:
	mov eax, 1	    		;system call number (sys_exit)
	int 80h        			;call kernel

