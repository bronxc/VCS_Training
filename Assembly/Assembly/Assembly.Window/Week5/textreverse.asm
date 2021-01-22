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


WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
EditWndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD


; **********************************************
; variable
; **********************************************
.data
; ----------------------------------------------
; constant
; ----------------------------------------------
; window's size
winWidth 	equ 460								; window's width
winHeight 	equ 180								; window's height

; textbox's size
tbWidth		equ 400								; textbox width
tbHeight	equ 30								; textbox height

; position of edit box
editX		equ 20								
editY		equ 30

; position of readonly box
readX		equ 20								
readY		equ 70

; 1000 character max in str (null at last)
strMaxSize	equ 1000

; ----------------------------------------------	
ClassName 	db "textbox",0
AppName  	db "Reverse textbox's string",0
EditClass 	db "edit",0
ReadClass	db "read", 0



; **********************************************
; uninitialized  data	
; **********************************************
.data?
hInstance	HINSTANCE ?
hwndEdit	dd ?
hwndRead	dd ?
OldWndProc	dd ?
buffer db 512 dup(?)
strOut db 512 dup(?)



; **********************************************
; code
; **********************************************
.code
start:
	; get instance handle of program
	; invoke GetModuleHandle, NULL
	push NULL
	call GetModuleHandle
	mov    hInstance,eax
	
	;invoke WinMain, hInstance,NULL,NULL, SW_SHOWDEFAULT
	push SW_SHOWDEFAULT
	push NULL
	push NULL
	push hInstance
	call WinMain
	
	;invoke ExitProcess,eax
	push eax
	call ExitProcess
	
	
; --------------------------------------------------------------------
; WndMain: create window, loop the app
; --------------------------------------------------------------------	
WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	
	; get window class information
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	
	push  hInst
	pop   wc.hInstance
	
	mov   wc.hbrBackground,COLOR_APPWORKSPACE
	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET ClassName
	
	; load the .exe icon
	push IDI_APPLICATION
	push NULL
	call LoadIcon
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	
	; load the .exe cursor
	push IDC_ARROW
	push NULL
	call LoadCursor
	mov   wc.hCursor,eax
	
	; register a window class to create the window then
	lea eax, wc
	push eax
	call RegisterClassEx
	
	; create the window
	push NULL
    push hInst
    push NULL
    push NULL
    push winHeight
    push winWidth
    push CW_USEDEFAULT
    push CW_USEDEFAULT
    push WS_OVERLAPPEDWINDOW or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX or WS_MAXIMIZEBOX or WS_VISIBLE
    push offset AppName
    push offset ClassName
    push WS_EX_CLIENTEDGE									; have border
    
	call CreateWindowEx
	mov   hwnd,eax
	
	; while true: keep the window running until client close it
	messageLoop:
		; get message from message loop
		push 0
		push 0
		push NULL
		;push offset msg
		lea eax, msg
		push eax
		call GetMessage
		
		; quit message (WM_DESTROY)
		or eax, eax
		jle endLoop
		
		; translate virtual-key messages into character messages
		lea eax, msg
		push eax
		call TranslateMessage   					
		
		lea eax, msg
		push eax
		call DispatchMessageA
		
		jmp messageLoop	
	endLoop:
	; <=> end the app
	mov eax, msg.wParam
	push eax
	call ExitProcess
	ret
	
WinMain endp


; --------------------------------------------------------------------
; WndProc: handle the message
; --------------------------------------------------------------------
WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	
	; --------------------------------------------------------------------
	;uMsg==WM_CREATE
	
	@wndIf:
	cmp uMsg, WM_CREATE
	jne @wndElseif
		;-----------------------------------------
		; create edit textbox
		;-----------------------------------------
		push NULL
		push hInstance
		push NULL
		push hWnd
		push tbHeight
		push tbWidth
		push editY
		push editX
		push WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_AUTOHSCROLL
		push NULL
		push offset EditClass
		push WS_EX_CLIENTEDGE
		
		call CreateWindowEx
		mov hwndEdit,eax
		
		;SetFocus
		push eax
		call SetFocus
		
		;-----------------------------------------
		; create readonly textbox
		;-----------------------------------------
		push NULL
		push hInstance
		push NULL
		push hWnd
		push tbHeight
		push tbWidth
		push readY
		push readX
		push WS_CHILD or WS_VISIBLE or WS_BORDER or ES_READONLY or ES_AUTOHSCROLL
		push NULL
		push offset EditClass
		push WS_EX_CLIENTEDGE
		
		call CreateWindowEx
		mov hwndRead, eax
		
		;-----------------------------------------
		; Subclass it!
		;-----------------------------------------
		; SetWindowLong
		lea eax, EditWndProc
		push eax
		push offset EditWndProc
		push GWL_WNDPROC
		push hwndEdit
		
		call SetWindowLong
		mov OldWndProc,eax
		
		jmp @wndEndif
		
		
	; --------------------------------------------------------------------		
	; uMsg==WM_DESTROY
	@wndElseif:
		cmp uMsg, WM_DESTROY
		jne @wndElse
		
		; PostQuitMessage
		push NULL
		call PostQuitMessage
		
		jmp @wndEndif
	
	; --------------------------------------------------------------------	
	; other
	@wndElse:
		;DefWindowProc
		push lParam
		push wParam
		push uMsg
		push hWnd
		call DefWindowProc
		ret
	
	@wndEndif:
	
	xor eax,eax
	ret
WndProc endp


; --------------------------------------------------------------------
; Edit window procedure: for the edit textbox window
; --------------------------------------------------------------------
EditWndProc PROC hEdit:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	
	; --------------------------------------------------------------------		
	; uMsg==WM_CHAR
	
	@editIf:
		cmp uMsg, WM_CHAR
		jne @editElseIf
		
		mov eax,wParam
		; ---------------------------------------
		; al != VK_TAB => character, backspace
		_editIF_if:
			cmp al, VK_TAB
			je _editIF_endif
			
			; pass message to wndpro process
			push lParam
			push eax
			push uMsg
			push hEdit
			push OldWndProc
			call CallWindowProc
			
			; get the string
			push strMaxSize
			push offset buffer
			push hwndEdit
			call GetWindowText
			
			; get length of string
			push offset buffer
			call lstrlen
			mov ebx, eax
			
			; reverse
			mov eax, offset buffer
			call strReverse
	
			;write it to readonly textbox
			push offset strOut
			push hwndRead
			call SetWindowText
						
		_editIF_endif:
		ret
		
	; --------------------------------------------------------------------	
	; uMsg==WM_KEYDOWN
	
	@editElseIf:
		cmp uMsg, WM_KEYDOWN
		jne @editElse
		
		mov eax,wParam
		; ---------------------------------------
		; al==VK_DELETE => update string
		_editElseIf_if:
			cmp al, VK_DELETE
			jne _editElseIf_else
			
			; pass message to wndpro process
			push lParam
			push eax
			push uMsg
			push hEdit
			push OldWndProc
			call CallWindowProc
			
			; get the string
			push strMaxSize
			push offset buffer
			push hwndEdit
			call GetWindowText
			
			; get length of string
			push offset buffer
			call lstrlen
			mov ebx, eax
			
			; reverse
			mov eax, offset buffer
			call strReverse
			
			;write it to readonly textbox
			push offset strOut
			push hwndRead
			call SetWindowText
			
			ret 
			;jmp @editEndif ;//ret
			
		; ----------------------------------------
		; other key
		_editElseIf_else:
			; pass message to wndpro process
			push lParam
			push wParam
			push uMsg
			push hEdit
			push OldWndProc
			call CallWindowProc
			ret
	
		;_editElseIf_endif:
		
	; --------------------------------------------------------------------
	; other message
	@editElse:
		; pass message to wndpro process
		push lParam
		push wParam
		push uMsg
		push hEdit
		push OldWndProc
		call CallWindowProc
		ret
		
	@editEndif:
	
	xor eax,eax
	ret
EditWndProc endp


; --------------------------------------------------------------------
; reverse the string
; --------------------------------------------------------------------
strReverse proc
	; input: eax - point to input string; ebx: store value of string_length
	; output: strOut
	mov ecx, offset strOut
	dec ebx
	
	@reverse:
		cmp ebx, 0
		jl @done_reverse
		
		xor edx, edx
		mov dl, byte ptr [eax + ebx]
		mov byte ptr [ecx], dl

		dec ebx
		inc ecx
		jmp @reverse
		
	@done_reverse:
		mov byte ptr [ecx], 0
		ret
strReverse endp

end start
