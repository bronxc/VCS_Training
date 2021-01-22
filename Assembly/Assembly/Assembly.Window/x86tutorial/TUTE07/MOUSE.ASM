.386
.model flat,stdcall
option casemap:none

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib

include \masm32\include\msvcrt.inc
includelib \masm32\lib\msvcrt.lib
extrn printf :near

.data
ClassName db "SimpleWinClass",0
AppName  db "Our First Window",0
MouseClick db 0         ; 0=no click yet

x_pos dd 0
y_pos dd 0

Format db "%d", 0ah, 0

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
hitpoint POINT <>

.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke GetCommandLine
	invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess,eax
WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInst
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_WINDOW+1
	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
           hInst,NULL
	mov   hwnd,eax
	INVOKE ShowWindow, hwnd,SW_SHOWNORMAL
	INVOKE UpdateWindow, hwnd
	.WHILE TRUE
                
				inc dword ptr [x_pos]
				inc dword ptr [y_pos]
				
				cmp dword ptr [x_pos], 1000
				jne @next1
				mov dword ptr [x_pos], 0
				
				@next1:
				cmp dword ptr [y_pos], 1000
				jne @next2
				mov dword ptr [y_pos], 0
				
				@next2:
				;invoke printf, offset Format, dword ptr [x_pos]
				push dword ptr [y_pos]
				push offset Format
				call printf
				add esp, 8
				
				INVOKE GetMessage, ADDR msg,NULL,0,0
                .BREAK .IF (!eax)
                INVOKE DispatchMessage, ADDR msg
				
	.ENDW
	mov     eax,msg.wParam
	
	
	
	
	ret
WinMain endp
WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL hdc:HDC
	LOCAL ps:PAINTSTRUCT

	.IF uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
	.ELSEIF uMsg==WM_LBUTTONDOWN
		mov eax,lParam
		and eax,0ffffh
		
		mov eax, dword ptr [x_pos]
		;mov hitpoint.x,eax
		mov hitpoint.x, eax
		
		mov eax,lParam
		shr eax,16
		
		mov eax, dword ptr [y_pos]
		;mov hitpoint.y,eax
		mov hitpoint.y, eax
		
		mov MouseClick,TRUE
		invoke InvalidateRect,hWnd,NULL,TRUE
	.ELSEIF uMsg==WM_PAINT
		invoke BeginPaint,hWnd, ADDR ps
		mov    hdc,eax
		.IF MouseClick
			invoke lstrlen,ADDR AppName
			invoke TextOut,hdc,hitpoint.x,hitpoint.y,ADDR AppName,eax
		.ENDIF
		invoke EndPaint,hWnd, ADDR ps
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.ENDIF
	xor    eax,eax
	ret
WndProc endp
end start
