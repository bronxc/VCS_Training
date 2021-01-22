

includelib \masm32\lib\shlwapi.lib
includelib \masm32\lib\psapi.lib
include \masm32\include\masm32rt.inc
;include \masm32\include\shlwapi.inc
;include \masm32\include\psapi.inc

extern StrCmpC: proc
extern StrRStrIA: proc
extern GetModuleFileNameEx: proc
extern PathStripPath: proc


;PathStripPath proto :DWORD
;GetModuleFileNameEx proto :DWORD, :DWORD, :DWORD, :DWORD
;StrRStrIA proto :DWORD, :DWORD, :DWORD
;StrCmpC proto :DWORD, :DWORD

EnumFunc proto :DWORD, :DWORD
TimerProc proto :DWORD, :DWORD, :DWORD, :DWORD




WINDOWENTRY32 STRUCT
    lpszClassname     DWORD   ?
    lpszFilename      DWORD   ?
WINDOWENTRY32 ENDS

.data

;szClassname                 byte            "Mozilla", 0; "IEFrame", 0;
;szFilename                  byte            "firefox.exe", 0
cEnter db 0ah, 0

;szClassname                 byte            "Google", 0; "IEFrame", 0
;szClassname                 byte            "Chrome_WidgetWin_1", 0; "IEFrame", 0

szClassname                 byte            "TabWindowClass", 0; "IEFrame", 0
;szFilename                  byte            "chrome.exe", 0
szFilename                  byte            "MicrosoftEdgeCP.exe", 0




.data?

we                          WINDOWENTRY32   <>
szCurrentFilename           byte 255 dup    (?)
szCurrentClassname          byte 255 dup    (?)

szWinText					byte 255 dup 	(?)
strLen	dd ?

msg MSG <?>
timeID dd  ?

.code
    Start:

xor ebx, ebx

mov we.lpszClassname, offset szClassname
mov we.lpszFilename, offset szFilename


invoke SetTimer, NULL, 0, 5, addr TimerProc
mov timeID, eax

whileTrue:
	invoke GetMessage, addr msg, NULL, 0, 0
	invoke TranslateMessage, addr msg
	invoke DispatchMessage, addr msg
	
jmp whileTrue

invoke ExitProcess, ebx


TimerProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	invoke EnumWindows, addr EnumFunc, addr we
	ret	
TimerProc endp



EnumFunc proc hwnd:DWORD, lParam:LPARAM
LOCAL dwProcessId:DWORD
LOCAL hProcess:DWORD

push ebx
mov ebx, lParam
    ;invoke GetClassName, hwnd, addr szCurrentClassname, 255
	
	push 255
	push offset szCurrentClassname
	push hwnd
	call GetClassName
	
	
	;invoke StrCmpC, addr szCurrentClassname, (WINDOWENTRY32 PTR [ebx]).lpszClassname
	
	;push offset cEnter
	;call StdOut
	;push offset szCurrentClassname
	;call StdOut
	
	;invoke StrRStrIA , addr szCurrentClassname, NULL, (WINDOWENTRY32 PTR [ebx]).lpszClassname
	push (WINDOWENTRY32 PTR [ebx]).lpszClassname
	push NULL
	push offset szCurrentClassname
	call StrRStrIA
	
    .IF eax != 0
		
		;invoke GetWindowThreadProcessId, hwnd, addr dwProcessId
		;invoke OpenProcess, PROCESS_ALL_ACCESS, FALSE, dwProcessId
        
		lea ecx, dwProcessId
		push ecx
		push hwnd
		call GetWindowThreadProcessId
		
		push dwProcessId
		push FALSE
		push PROCESS_ALL_ACCESS
		call OpenProcess
		
		mov hProcess, eax

		;invoke GetModuleFileNameEx, eax, 0, addr szCurrentFilename, 255
		;invoke PathStripPath, addr szCurrentFilename
		
		push 255
		push offset szCurrentFilename
		push 0
		push eax
		call GetModuleFileNameEx
		
		push offset szCurrentFilename
		call PathStripPath
		
		
		;push offset cEnter
		;call StdOut
		
		;push offset szCurrentFilename
		;call StdOut
		
		;invoke StrCmpC, (WINDOWENTRY32 PTR [ebx]).lpszFilename, addr szCurrentFilename
		push offset szCurrentFilename
		push (WINDOWENTRY32 PTR [ebx]).lpszFilename
		call StrCmpC


		.IF eax == 0
			
			push offset cEnter
			call StdOut
			push offset szCurrentClassname
			call StdOut
		
			push offset cEnter
			call StdOut
			
			push offset szCurrentFilename
			call StdOut
			
			invoke PostMessage, hwnd, WM_CLOSE, 0, 0

		.ENDIF

		invoke CloseHandle, hProcess

    .ENDIF

	mov eax, 1
	pop ebx

ret
EnumFunc endp



write_number PROC STDCALL USES ebx      ; printf ("%u ", EAX)
LOCAL numstring[12]:BYTE, NumberOfBytesWritten:DWORD
.CONST
    fmt db "%u ",0
.CODE
    invoke wsprintf, ADDR numstring, ADDR fmt, eax
    mov ebx, eax                        ; Preserve result - count of written bytes
    invoke GetStdHandle, -11            ; Get STD_OUTPUT_HANDLE
    mov edx, eax                        ; EAX will be used by the following INVOKE
    invoke WriteFile, edx, ADDR numstring, ebx, ADDR NumberOfBytesWritten, 0
    ret
write_number ENDP
    
end Start