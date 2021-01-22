%macro writeString 2                    ;define a macro with 2 param
    mov eax,4                            ;system call number (sys_write)
    mov ebx,1                            ;to which file descriptor (1-> stdout)
    mov ecx,%1                          ;msg
    mov edx,%2                          ;length of msg
    int 80h                             ;call kernel
%endmacro

section	.data
	lenMax equ 256
	msg1 db "Enter your string: ",0
	lenMsg1	equ	$ - msg1
    	msg2 db "Your reverse string: ",0
	lenMsg2 equ $ - msg2
    	ent db 0ah,0
section .bss
    	string resb lenMax
section	.text
	global _start       
_start:  
       
    	call readInput		;to read string
	mov esi, string
   	call string_endpoint
    	call reverse
    	writeString msg2,lenMsg2
   	writeString string,lenMax
	writeString ent,2
	mov	eax, 1	    ;system call number (sys_exit)
	int	80h        ;call kernel

   
string_endpoint:
    mov eax,esi
    _nextchar:
        cmp byte [eax],0
        jz _finished
        inc eax
	jmp _nextchar
    _finished:
        dec eax
        ret
reverse:
    mov edi,eax
    _startReverse:
        cmp esi,edi
        jge _done
        ;swap
        mov eax,0
        mov al,byte [esi]
        xchg al, byte [edi]
        mov byte [esi],al
        ;end swap
        inc esi
        dec edi
        jmp _startReverse
    _done:
        ret

readInput:
    writeString msg1,lenMsg1                    ;call macro
	; Read and store the user input string
	mov eax, 3                                  ;system call number (sys_read)
	mov ebx, 2                                  ;stdin
	mov ecx, string                             ;ecx stores offset of string to read
	mov edx, lenMax                             ;length of bytes to read
	int 80h                                     ;call kernel	

    ret
