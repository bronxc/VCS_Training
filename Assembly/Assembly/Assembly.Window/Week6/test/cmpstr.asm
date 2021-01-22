include \masm32\include64\masm64rt.inc

includelib \masm32\lib64\shlwapi.lib
includelib \masm32\lib64\psapi.lib

include \masm32\include64\shlwapi.inc
include \masm32\include64\psapi.inc


.data

	string db "123abc", 0
	strsub byte "123", 0
	
	msg db "done", 0
	cEnter db 0ah, 0
	
	currentFileName db "C:\Program Files\Mozilla Firefox\firefox.exe", 0
	fnFireFox db 0, "firefox.exe", 0
.code

main proc
	
	
	;invoke PathStripPath, addr currentFileName
	;mov rcx, offset currentFileName
	;call StdOut
	
	;invoke StrRStrIA, addr string, NULL, addr strsub
	
	;mov rcx, offset string
	;mov rdx, offset strsub
	
	;mov rax, 0
	;@cmpStr:
		;push rax
		;push rdx
		;push rcx
		;mov rax, rcx
		;call write_number
		
		;mov rcx, offset cEnter
		;call StdOut
		;pop rcx
		;pop rdx
		;pop rax
		
		;mov r8b, byte ptr [rcx]
		;cmp r8b, byte ptr [rdx]
		;jne @done_cmp
	
		;inc rcx
		;inc rdx
		
		;cmp byte ptr [rdx], 0
		;jne @cmpStr
		
		;mov rax, 1
		
	;@done_cmp:
	
	invoke lstrlenA, addr currentFileName
	mov rcx, offset currentFileName
	add rcx, rax
	dec rcx
	;dec rcx
	
	push rcx
	invoke lstrlenA, addr fnFireFox
	mov rdx, offset fnFireFox
	add rdx, rax
	dec rdx
	dec rdx
	
	pop rcx
	
	mov rax, 0
	
	@cmpEnd:
		xor r8, r8
		mov r8b, byte ptr [rcx]
		
		cmp r8b, byte ptr [rdx]
		jne @done_cmpEnd
		
		dec rcx
		dec rdx
		
		cmp byte ptr [rdx], 0
		jne @cmpEnd
		
		mov rax, 1
	@done_cmpEnd:
	
	;call write_number
	
	cmp rax, 0
	je @done
	;mov rcx, rax
	;call StdOut
	
	;call write_number
	invoke StdOut, addr msg
	
	@done:
	
	mov rcx, 0
	call ExitProcess

main endp



write_number PROC; STDCALL USES rbx      ; printf ("%u ", EAX)
LOCAL numstring[12]:BYTE, NumberOfBytesWritten:QWORD
.CONST
    fmt db "%u ",0
.CODE
    invoke wsprintf, ADDR numstring, ADDR fmt, rax
    mov rbx, rax                        ; Preserve result - count of written bytes
    invoke GetStdHandle, -11            ; Get STD_OUTPUT_HANDLE
    mov rdx, rax                        ; EAX will be used by the following INVOKE
    invoke WriteFile, rdx, ADDR numstring, rbx, ADDR NumberOfBytesWritten, 0
    ret
write_number ENDP

end