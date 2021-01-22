include \masm32\include64\masm64rt.inc
include \masm32\include64\shlwapi.inc
include \masm32\include64\psapi.inc

includelib \masm32\lib64\shlwapi.lib
includelib \masm32\lib64\psapi.lib


; *******************************************************************
; variable
; *******************************************************************
.data 
; constant
bufferMaxSize equ 255

; app message
message db 0ah, "---------> Anti Browser <---------", 0ah, 0
cEnter db 0ah, 0

; browser's classname and filename 
cnFireFox db "Mozilla", 0
fnFireFox db "firefox.exe", 0

cnChrome db "Chrome_WidgetWin_1", 0
fnChrome db "chrome.exe", 0

cnMicroEdge db "TabWindowClass", 0
fnMicroEdge db "MicrosoftEdgeCP.exe", 0

fnEdge db "msedge.exe",0
fnCocCOc db "browser.exe", 0

; array of offset browser's info 
weClass QWORD offset cnFireFox, offset cnMicroEdge, offset cnChrome, 0h
weFile  QWORD offset fnFireFox, offset fnMicroEdge, offset fnChrome, offset fnEdge, offset fnCocCOc, 0h



; *******************************************************************
; uninitialized  data
; *******************************************************************
.data?
currentFileName		db 255 dup (?)
currentClassName	db 255 dup (?)

msg MSG <?>
timeID QWORD ?



; *******************************************************************
; code
; *******************************************************************
.code
main proc
    ; rcx, rdx, r8,r9, stack
	; -------------------------------------------------	
	; app message 
	mov rcx, offset message
	call StdOut
	
	; -------------------------------------------------	
	; set the timmer
	;invoke SetTimer, NULL, 0, 5000, addr TimerProc
	mov rcx, NULL
	mov rdx, 0
	mov r8, 5000
	mov r9, offset TimerProc
	call SetTimer
	
	mov timeID, rax
	
	; -------------------------------------------------	
	; Loop the app
	whileTrue:
		; invoke GetMessage, addr msg, NULL, 0, 0
		mov rcx, offset msg
		mov rdx, NULL
		mov r8, 0
		mov r9, 0
		call GetMessage
		
		;invoke TranslateMessage, addr msg
		mov rcx, offset msg
		call TranslateMessage
		
		;invoke DispatchMessage, addr msg
		mov rcx, offset msg
		call DispatchMessage
	jmp whileTrue
	
	
	; -------------------------------------------------	
	; exit the app
	
	;invoke KillTimer, timeID
	mov rcx, timeID
	call KillTimer
	
	;invoke ExitProcess, 0
	mov rcx, 0
	call ExitProcess
	
main endp


; --------------------------------------------------------------------
; TimerProc: call back
; --------------------------------------------------------------------	
TimerProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	; -------------------------------------------------	
	; get the running window
	;invoke EnumWindows, addr EnumFunc, NULL;
	mov rcx, offset EnumFunc
	mov rdx, NULL
	call EnumWindows
	
	ret
TimerProc endp


; --------------------------------------------------------------------
; EnumFunc: call back
; --------------------------------------------------------------------
EnumFunc proc hwnd:QWORD, lParam:LPARAM
LOCAL dwProcessId: QWORD
LOCAL hProcess:QWORD
	
	; -------------------------------------------------	
	; get window's classname
	;invoke GetClassName, hwnd, addr currentClassName, 255
	mov rcx, hwnd
	mov rdx, offset currentClassName
	mov r8, bufferMaxSize
	call GetClassName
	
	; -------------------------------------------------	
	; check is browser with class name
	mov rcx, offset currentClassName
	mov r12, offset weClass
	call isBrowser
	
	
	; compare if the classname pass
	@if:	
		cmp rax, 0
		je @endif
		; pass
		
		; -------------------------------------------------	
		; get the process to source file		
		;invoke GetWindowThreadProcessId, hwnd, addr dwProcessId
		mov rcx, hwnd
		lea rdx, dwProcessId
		call GetWindowThreadProcessId
		
		;invoke OpenProcess, PROCESS_ALL_ACCESS, FALSE, dwProcessId
		mov rcx, PROCESS_ALL_ACCESS
		mov rdx, FALSE
		mov r8, dwProcessId
		call OpenProcess
		
		mov hProcess, rax
		
		; -------------------------------------------------	
		; get the filename path, filename
		;invoke GetModuleFileNameEx, hProcess, 0, addr currentFileName, 255
		mov rcx, hProcess
		mov rdx, 0
		mov r8, offset currentFileName
		mov r9, bufferMaxSize
		call GetModuleFileNameEx
		
		;invoke PathStripPath, addr currentFileName
		mov rcx, offset currentFileName
		call PathStripPath
		
		; -------------------------------------------------	
		; check is browser with filename
		mov rcx, offset currentFileName
		mov r12, offset weFile
		call isBrowser
	
		; compare if the filename pass
		_if:
			cmp rax, 0
			je _endif
			
			; pass
			; -------------------------------------------------	
			; send msg to close the window
			;invoke PostMessage, hwnd, WM_CLOSE, 0, 0
			mov rcx, hwnd
			mov rdx, WM_CLOSE
			mov r8, 0
			mov r9, 0
			call PostMessage
			
			mov rcx, offset currentFileName
			call StdOut
			mov rcx, offset cEnter
			call StdOut
			
		_endif:
		; close the process
		;invoke CloseHandle, hProcess
		mov rcx, hProcess
		call CloseHandle
	;.ENDIF
	@endif:
	mov rax, 1		
	ret
EnumFunc endp


; --------------------------------------------------------------------
; isBrowser: check if it's browser
; --------------------------------------------------------------------	
isBrowser proc	
	; compare string with loop
	; intput.
	; rcx: addr of string needed to check
	; r12: addr of list offset string

	mov r13, rcx
	
	@compareLoop:
		mov r8, QWORD ptr [r12]
		cmp r8, 0h
		je @done_compareLoop
		
		xor rax, rax
		
		;invoke StrRStrIA , rcx, NULL, r8 
		mov rdx, NULL
		mov rcx, r13
		call StrRStrIA
		
		cmp rax, 0
		jne @done_compareLoop
		
		add r12, 8
		jmp @compareLoop
	
	@done_compareLoop:
	ret
isBrowser endp

end