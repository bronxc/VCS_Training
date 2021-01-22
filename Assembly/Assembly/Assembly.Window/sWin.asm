.386
.model flat, stdcall
option casemap:none



include C:\masm32\libs\windows.inc                                        ; .386 and .model are already declared in windows.inc
include C:\masm32\libs\kernel32.inc
include C:\masm32\libs\masm32.inc
include C:\masm32\libs\user32.inc 
include \masm32\libs\gdi32.inc

includelib C:\masm32\libs\user32.lib                                      ; calls to functions in user32.lib and kernel32.lib
includelib C:\masm32\libs\kernel32.lib
includelib C:\masm32\libs\masm32.lib
includelib \masm32\libs\gdi32.lib

WinMain proto, :DWORD, :DWORD, :DWORD, :DWORD


.DATA                                                               ; initialized data
    ClassName db "SimpleWinClass",0      ; the name of our window class
    AppName  db "Our First Window",0      ; the name of our window
	
	quitMsg db 1
	
	charO db "O", 0
	x_step dd 0
	y_pos dd 0
	x_pos dd 0
	
.DATA?                                                             ; Uninitialized data
hInstance HINSTANCE ?                              ; Instance handle of our program
CommandLine LPSTR ?

.CODE                                                                ; Here begins our code
 start:
     invoke GetModuleHandle, NULL             ; get the instance handle of our program.
                                                                            ; Under Win32, hmodule==hinstance
     mov    hInstance,eax
     invoke GetCommandLine                         ; get the command line. You don't have to call this function IF
                                                                            ; your program doesn't process the command line.
     mov    CommandLine,eax
     invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT        ; call the main function
     invoke ExitProcess,eax                            ; quit our program. The exit code is returned in eax from WinMain.

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
    LOCAL wc:WNDCLASSEX                                            ; create local variables on stack
    LOCAL msg:MSG
    LOCAL hwnd:HWND

    mov   wc.cbSize,SIZEOF WNDCLASSEX                    ; fill values in members of wc
    mov   wc.style, CS_HREDRAW or CS_VREDRAW
    mov   wc.lpfnWndProc, OFFSET WndProc
    mov   wc.cbClsExtra,NULL
    mov   wc.cbWndExtra,NULL
    push  hInstance
    pop   wc.hInstance
    mov   wc.hbrBackground,COLOR_WINDOW+1
    mov   wc.lpszMenuName,NULL
    mov   wc.lpszClassName,OFFSET ClassName
    invoke LoadIcon,NULL,IDI_APPLICATION
    mov   wc.hIcon,eax
    mov   wc.hIconSm,0
    invoke LoadCursor,NULL,IDC_ARROW
    mov   wc.hCursor,eax
    invoke RegisterClassEx, addr wc                        ; register our window class

    invoke CreateWindowEx,NULL,\
                ADDR ClassName,\
                ADDR AppName,\
                WS_OVERLAPPEDWINDOW,\
                CW_USEDEFAULT,\
                CW_USEDEFAULT,\
                CW_USEDEFAULT,\
                CW_USEDEFAULT,\
                NULL,\
                NULL,\
                hInst,\
                NULL
    mov   hwnd,eax
    invoke ShowWindow, hwnd,CmdShow                ; display our window on desktop
    invoke UpdateWindow, hwnd                                 ; refresh the client area
	
	
	invoke SetTimer, hwnd, 10, 0, NULL
	
    .WHILE TRUE                                                          ; Enter message loop
				invoke GetMessage, ADDR msg, NULL, 0, 0
				.BREAK .IF (!eax)
				
                invoke TranslateMessage, ADDR msg
                invoke DispatchMessage, ADDR msg
   .ENDW
    mov     eax,msg.wParam                                            ; return exit code in eax
    ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL hdc:HDC
	LOCAL ps:PAINTSTRUCT
	LOCAL rect:RECT
	
		
	mov   eax,uMsg                                                ; put the window message in eax for efficiency
    .IF eax==WM_DESTROY                             ; if the user closes our window
		invoke PostQuitMessage,NULL              ; quit our application
        xor eax,eax
		;mov byte ptr [quitMsg], 0
	
	
	.ELSEIF uMsg == WM_SIZE
		
		
		
		invoke InvalidateRect,hWnd,NULL,TRUE
		;invoke Sleep, 10
		invoke BeginPaint, hWnd, ADDR ps
		mov hdc, eax
		
		invoke lstrlen,ADDR charO
		invoke TextOut,hdc,dword ptr [x_pos],dword ptr [y_pos],ADDR charO,eax
			
		;invoke DrawText, hdc, ADDR charO, -1, ADDR rect, DT_SINGLELINE
		invoke EndPaint, hWnd, ADDR ps
		
		
		;push offset charO
		;call StdOut
		
		
		;invoke PostMessage, hWnd, uMsg, wParam, lParam
	
	.ELSEIF uMsg == WM_TIMER
		;ret
		; invoke SendMessage,hWnd,PBM_STEPIT,0,0
		;mov msg.hwnd, hwndTimer
		inc dword ptr [x_pos]
		inc dword ptr [y_pos]
		
    .ELSE
		;invoke DefWindowProc,hWnd,uMsg,wParam,lParam     ; Default message processing

    .ENDIF
	invoke DefWindowProc,hWnd,uMsg,wParam,lParam
	ret 
	
WndProc endp

end start