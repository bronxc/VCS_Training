.386
.model flat, stdcall
option casemap :none
include C:\masm32\include\windows.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\masm32.inc
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\masm32.lib
.const
    lenMax equ 100
    lenN equ 10
.data?
    n_string db lenN dup(?)
    fiN db lenMax dup(?)
    fiN1 db lenMax dup(?)
    fiN2 db lenMax dup(?)

.data
    msg1 db "Enter N: ",0
    msgErr db "Invalid input",0
    msg2 db "The first N fibonaci number is: ",0ah
    endN dword 0                                        ;to store address end-point (null) of location which stored fibonaci N
    endN1 dword 0                                       ;to store address end-point (null) of location which stored fibonaci N-1
    endN2 dword 0                                       ;to store address end-point (null) of location which stored fibonaci N-2
    firstN dword 0                                      ;to store address location which stored fibonaci N-1
    firstN1 dword 0                                     ;to store address location which stored fibonaci N-1
    firstN2 dword 0                                     ;to store address location which stored fibonaci N-1
    cnt dword 0                                         ;cnt to store N in number representation
    check byte 0                                        ;check for invalid input
    ent db 0ah                          
    
    
.code

_toNumber:                                  ;start: esi is the pointer to the numberString
    mov eax,0            
    _startConvert:                          
        movzx ecx, byte ptr [esi]           ; move value 1 character (1byte) which [esi] pointer to ecx
        cmp ecx,0h                          ; check for null
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
        ret                                 ;return to the calling
    _err:
        mov check,1
        ret
_update:            ;fiN2<- fiN1, fiN1<-fiN
    mov esi, firstN2
    mov edi, firstN1
    mov firstN2,edi
    mov edi, firstN
    mov firstN1,edi
    mov firstN,esi

    mov edi, endN1
    mov endN2,edi
    mov edi, endN
    mov endN1,edi
    
    ;endN update after adding   
_fiN:         ; add fiN1 and fiN2, store in fiN
    mov edi,endN1
    mov esi,endN2          ; edi points to end-point (null) fiN1, esi points to end-point (null) fiN2
    xor edx,edx
    xor ecx,ecx                             ;counter
    _add:
        xor eax,eax
        cmp esi, firstN2               ;check if esi points to the first char of fiN2 (store address of fiN2)
        je L2                               ;if yes, meaning finished adding all digit of num2
        L1:                                 ;(if no) continue get char from num2
            dec esi                         
            movzx eax,byte ptr [esi]        ;eax stores 1-byte char in esi 
            sub eax,'0'                     ;change char to a 1-digit number 
            cmp edi, firstN1                ;check if finished adding digit of fiN1
            jne L3                          ;if no, jmp L3
            mov ebx,0                       ;if yes, ebx=0
            jmp L4
        L2:                                 ;finished adding all digit of num2, eax=0
            mov eax,0   
            cmp edi, firstN1            ;check if finished adding all
            je _finishedAdd
        L3:                                 ;continue get char from num1 
            dec edi
            movzx ebx,byte ptr [edi]        ;ebx stores 1-char after
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
            mov esi, firstN                    ;esi points to fiN after
            cmp edx,0                       ;check for rem
            je L5                           ;if no rem, jmp to L5
            add edx,48                      ;if yes, add rem to the first byte of sum
            mov byte ptr [esi],dl           
            inc esi
            xor edx,edx
            L5:
                cmp ecx,0                   ;check for end using counter
                je _finished                
                pop eax                     ;pop top-value(digit of sum) in stack and store into eax 
                dec ecx                     ;dec counter
                add eax,48                  ;move to ASKII representation
                mov byte ptr [esi],al       ;add char to sum number
                inc esi                     
                jmp L5                        
            _finished:  
                mov endN,esi     
                ret
main:
    invoke StdOut, addr msg1
    invoke StdIn, addr n_string, lenN
    mov esi, offset n_string
    call _toNumber                      ;eax stores N after
    cmp check,1                         
    je _msgErr                          ; if check = 1 -> invalid input
    mov cnt, eax                        ; if no, variable cnt stores N after
    cmp cnt,0                           ; N = 0?
    je _end
    invoke StdOut, addr msg2            
    start:
        mov byte ptr [fiN1],'1'
        mov firstN1,offset fiN1
        mov endN1,offset fiN1 + 1

        mov byte ptr [fiN2],'1'
        mov firstN2, offset fiN2
        mov endN2, offset fiN2 + 1

        invoke StdOut, addr fiN1
        cmp cnt,1   
        je _end

        invoke StdOut, addr ent
        invoke StdOut,addr fiN2
        cmp cnt,2
        je _end

        invoke StdOut, addr ent
        ;N>2
        sub cnt,2
        mov firstN, offset fiN
        L1_1: 
            cmp cnt,0
            je _end
            dec cnt
            call _fiN                         
            invoke StdOut, firstN                   ;print N-th fibonaci number
            invoke StdOut, addr ent
            call _update
            jmp L1_1
    _msgErr:
        invoke StdOut, addr msgErr
        invoke StdOut, addr ent
    _end:
        invoke ExitProcess,0

end main