include \masm32\include64\masm64rt.inc

includelib \masm32\lib64\shlwapi.lib
includelib \masm32\lib64\psapi.lib

include \masm32\include64\shlwapi.inc
include \masm32\include64\psapi.inc


TimerProc proto :QWORD, :DWORD, :QWORD, :QWORD



WINDOWENTRY64 STRUCT
    lpszClassname     QWORD   ?
    lpszFilename      QWORD   ?
WINDOWENTRY64 ENDS

.data 
string db "a string", 0ah, 0
cEnter db 0ah, 0

cnFireFox db "Mozilla", 0
fnFireFox db "firefox.exe", 0

cnChrome db "Chrome_WidgetWin_1", 0
fnChrome db "chrome.exe", 0

weClass QWORD offset cnFireFox, offset cnChrome, 0h
weFile  QWORD offset fnFireFox, offset fnChrome, 0h

currentFileNameTest db "C:\Program Files\Mozilla Firefox\firefox.exe", 0

.data?

we 					WINDOWENTRY64 <>
currentFileName		db 255 dup (?)
currentClassName	db 255 dup (?)

msg MSG <?>
timeID QWORD ?




.code
main proc
    ; rcx, rdx, r8,r9, stack
	; -------------------------------------------------	
	
	xor rbx, rbx
	
	;mov we.lpszClassname, offset weClass
	;mov we.lpszFilename, offset weFile
	
	mov rax, offset weClass
	mov we.lpszClassname, rax

	mov rax, offset weFile
	mov we.lpszFilename, rax
	
	invoke SetTimer, NULL, 0, 5000, addr TimerProc
	mov timeID, rax
	
	whileTrue:
		invoke GetMessage, addr msg, NULL, 0, 0
		invoke TranslateMessage, addr msg
		invoke DispatchMessage, addr msg
	
	jmp whileTrue
	
	; exit
	;mov rcx, 0
    ;call ExitProcess
	
	invoke ExitProcess, ebx
main endp


TimerProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	mov rcx, offset cnChrome
	call StdOut
	
	invoke EnumWindows, addr EnumFunc, addr we
	ret
	
TimerProc endp



EnumFunc proc hwnd:QWORD, lParam:LPARAM
LOCAL dwProcessId: DWORD
LOCAL hProcess:QWORD

	push rbx
	mov rbx, lParam

	invoke GetClassName, hwnd, addr currentClassName, 255

	;invoke StrRStrIA, addr currentClassName, NULL, (WINDOWENTRY64 PTR [rbx]).lpszClassname
	
	;invoke StrRStrIA, addr currentClassName, NULL, addr cnFireFox
	
	;mov r8, offset cnFireFox
	;mov rdx, NULL
	;mov rcx, offset currentClassName
	;call StrRStrIA
	
	mov rcx, offset currentClassName
	mov rdx, offset cnFireFox
	
	mov rax, 0
	@cmpStr:
		mov r8b, byte ptr [rcx]
		cmp r8b, byte ptr [rdx]
		jne @done_cmp
	
		inc rcx
		inc rdx
		
		cmp byte ptr [rdx], 0
		jne @cmpStr
		
		mov rax, 1
		
	@done_cmp:
	
	
	@if:	
		cmp rax, 0
		je @endif
			
		invoke GetWindowThreadProcessId, hwnd, addr dwProcessId
		invoke OpenProcess, PROCESS_ALL_ACCESS, FALSE, dwProcessId
		mov hProcess, rax
		
		invoke GetModuleFileNameEx, hProcess, 0, addr currentFileName, 255
		
		invoke lstrlenA, addr fnFireFox
		mov rbx, rax
		
		invoke lstrlenA, addr currentFileName
		mov rcx, offset currentFileName
		add rcx, rax
		sub rcx, rbx
		
		mov rdx, offset fnFireFox
	
		mov rax, 0
		@cmpStr1:
			mov r8b, byte ptr [rcx]
			cmp r8b, byte ptr [rdx]
			jne @done_cmp

			inc rcx
			inc rdx
			
			cmp byte ptr [rdx], 0
			jne @cmpStr1
			
			mov rax, 1
			
		@done_cmp1:
					
		
		_if:
			cmp rax, 0
			je _endif
			invoke PostMessage, hwnd, WM_CLOSE, 0, 0
		_endif:
		
		invoke CloseHandle, hProcess
		
	;.ENDIF
	@endif:
	
	mov rax, 1
	pop rbx
		
ret

EnumFunc endp



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