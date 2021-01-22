.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

.data
ClassName db "SimpleWinClass",0
AppName  db "Bouncing Ball",0
msgO db "msgOsdfsfdsfdfsdfsdsfdsfdsdsfdsfd", 0
Format db "%s", 0

.data?
hInstance dd ?
CommandLine dd ?

.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke GetCommandLine
	mov    CommandLine,eax
	invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess, eax

WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	
	mov   wc.cbSize, SIZEOF WNDCLASSEX
	mov   wc.style, CS_VREDRAW or ;CS_HREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra, NULL
	mov   wc.cbWndExtra, NULL
	push  hInstance
	pop   wc.hInstance
	mov   wc.hbrBackground, COLOR_WINDOW
	; mov   wc.hbrBackground, COLOR_WINDOWFRAME + 4
	mov   wc.lpszMenuName, NULL
	mov   wc.lpszClassName, OFFSET ClassName
	invoke LoadIcon, NULL, IDI_APPLICATION
	mov   wc.hIcon, eax
	mov   wc.hIconSm, eax
	invoke LoadCursor, NULL, IDC_ARROW
	mov   wc.hCursor, eax
	invoke RegisterClassEx, addr wc
	INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
           hInst,NULL
	mov   hwnd, eax
	
	push offset msgO
	call StdOut
	
	invoke ShowWindow, hwnd, SW_SHOWNORMAL
	
	;invoke PrintWindow, hwnd, offset msgO, 0
	
	
	
	;invoke UpdateWindow, hwnd
	;invoke wsprintfA, offset msgO, offset Format
	
	.WHILE TRUE
		invoke GetMessage, ADDR msg, NULL, 0, 0
		.BREAK .IF (!eax)
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
		
		push offset msgO
		call StdOut
		
	.ENDW
	mov     eax,msg.wParam
	ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	.if uMsg==WM_DESTROY
		invoke PostQuitMessage, NULL
	.else
		invoke DefWindowProc, hWnd, uMsg, wParam, lParam		
		ret
	.endif
	xor eax,eax
	ret
WndProc endp
end start