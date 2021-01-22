.386
.model flat, stdcall
option casemap :none


include C:\masm32\include\kernel32.inc
include C:\masm32\include\masm32.inc
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\masm32.lib

.const
        lenMax equ 20
.data
        msg1 db "Number1: ",0
        msg2 db "Number2: ",0
        msg3 db "Ans: ",0
        msgErr db "Invalid Input ",0ah,0

        check db 0

        bignum dword 0
                dword 0
        carry dword 0

       ans db lenMax dup (0)

.data?
        num1 db lenMax dup(?)
        num2 db lenMax dup(?)
        
.code
toInteger:                             ;esi is the pointer to the numberString
    
    xor eax,eax  
    _startConvert:   
        movzx ecx, byte ptr [esi]           ; move value 1 character (1byte) which [esi] pointer to ecx
        
        cmp ecx,0                          ; check for null
        je _done

        cmp ecx,'0'
        jl _err
        cmp ecx,'9'                         
        jg _err                             ;check for non-numeric

        xor edx,edx
        mov eax,bignum
        imul eax,10                         ;eax *= 10
        mov bignum,eax
        mov carry,edx

        xor edx,edx
        mov eax, bignum+4
        imul eax,10
        add eax,carry
        mov bignum+4,eax

        cmp edx,0
        jne _err                            ;overflow


        sub ecx,'0'                         ;character char to int
        add bignum,ecx
        adc bignum+4,0

        inc esi                             ;esi+=1 point to the next byte 
        jmp _startConvert                   

    _err:
        mov check,1
    _done:
        ret                                 ;return to the calling
toString:                                  
                       
    mov ebx,10                              
    _divide:
        xor edx,edx
        dec esi

        div ebx                             ; divide eax by ebx, edx hold remainder
        add edx,48                          ; convert edx - current digit to ASKII - string representation of a digit
        mov byte ptr [esi], dl              ; get 1 byte contained character to store in 1 byte from esi location 
        
        cmp eax,0                           ; check if the integer can be devide anymore
        jnz _divide                         ; if no zero, continue divide
    
        ret                                 ; return and esi is the pointer to the string Number


main:
        invoke StdOut, addr msg1
        invoke StdIn,addr num1,lenMax

        mov esi,offset num1
        
        call toInteger

        mov eax,bignum
        mov esi, offset ans+lenMax
        call toString
	
		push esi
		
        mov eax,bignum+4
        dec esi
        call toString
        
		pop esi
		inc esi
		 
		 
		 
        invoke StdOut, addr msg3
        invoke StdOut,  esi
        jmp h
        g: 
            invoke StdOut, addr msgErr
        h:
        invoke ExitProcess,0
        
end main