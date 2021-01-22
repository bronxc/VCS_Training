; build with follow commands:
;d:/masm32/bin/ml /c /Cp /coff boucingball.asm 
;d:/masm32/bin/Link /subsystem:windows boucingball.obj

.686
.model flat,stdcall
option casemap:none
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD



include \masm32\include\gdi32.inc
includelib \masm32\lib\gdi32.lib

include \masm32\include\windows.inc
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib            
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib

include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib


; initialized data
.data
	AppName db 'Boucing Ball', 0
    ClassName db 'BasicWinClass', 0
	
	; constant
	sizeR equ 30
	step equ 4
	speed equ 10
	winWidth equ 800
	winHeight equ 600
	
	; the direction: 45, 135, 225, 315
	xVector dword 1, -1, -1, 1
	yVector dword -1, -1, 1, 1
	
; uninitialized data
.data?
    ; for the window, process handling, paint,...
	hInstance HINSTANCE ?							; instance handle (represents a module - exe)
    wc WNDCLASSEX <?>								; window class information
    msg MSG <?>										; message structure
    hWnd HWND ?										; represents a window (handle to)
    hBitmap HWND ?									; to the bitmap
	hdcMem HWND ?									; memory device context
	ps PAINTSTRUCT <?>								; paint structure
	xWinSize dword ?								; Width of window
	yWinSize dword ?								; Height of window
	
	; information about the obj (ball - circle, rectangle - background of bitmap) which will be pating
	; position
	cxPos dword ?									; x of the ball
	cyPos dword ?									; y of the ball
	; the total size
	cxTotal dword ?									; x radius + x move
	cyTotal dword ?									; y radius + y move
	; sizeR
	cxRadius dword ?
	cyRadius dword ?
	; step
	cxMove dword ?
	cyMove dword ?
	
	; for random number fuction
	RandSeed    dd  ?
	RangeOfNumbers dd ?         					; Range of the random numbers (0..RangeOfNumbers-1)
	
.code
main:
	; get instance handle of program
    push NULL
    call GetModuleHandle
    mov hInstance, eax
	
	; get window class information
    mov wc.cbSize, sizeof WNDCLASSEX        
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, offset WndProc
    mov wc.cbClsExtra, NULL
    mov wc.cbWndExtra, NULL
	
    push hInstance
    pop wc.hInstance
    mov wc.hbrBackground, COLOR_WINDOW+1			; color: white
    mov wc.lpszMenuName, NULL
    mov wc.lpszClassName, offset ClassName
	
	; load the .exe icon
    push IDI_APPLICATION
    push NULL
    call LoadIconA
	
    mov wc.hIcon, eax
    mov wc.hIconSm, eax
	
	; load the .exe cursor
    push IDC_ARROW
    push NULL
    call LoadCursorA
    mov wc.hCursor, eax
	
	; register a window class to create the window then
    push offset wc
    call RegisterClassExA  
	
	; create the window
    push NULL
    push hInstance
    push NULL
    push NULL
    push winHeight
    push winWidth
    push CW_USEDEFAULT
    push CW_USEDEFAULT
    push WS_OVERLAPPEDWINDOW
    push offset AppName
    push offset ClassName
    push NULL
    call CreateWindowExA
	
	; new window handle
    mov hWnd, eax           

	; set window to normal => it is visible
    push SW_NORMAL
    push hWnd
    call ShowWindow 
	
    ; display window
    push hWnd
    call UpdateWindow       

	; set timer => set redraw frequency
	push NULL
	push speed
	push 1
	push hWnd
	call SetTimer

; --------------------------------------------------------------------
; while (true) until client close the window
; --------------------------------------------------------------------
messageLoop:
	; get message from message loop
    push 0
    push 0
    push NULL
    push offset msg
    call GetMessageA        					
    
	; quit message (WM_DESTROY)
	or eax, eax
    jle endLoop
	
	; translate virtual-key messages into character messages
    push offset msg
    call TranslateMessage   					
    
	push offset msg
    call DispatchMessageA
	
    jmp messageLoop
	
endLoop:
	; <=> end the app
    mov eax, msg.wParam
    push eax
    call ExitProcess


; --------------------------------------------------------------------
; WndProc: handle the message, paint the ball
; --------------------------------------------------------------------
WndProc proc
    push ebp
    mov ebp, esp
    cmp dword ptr[ebp+12], WM_DESTROY
    jz WMDESTROY
    cmp dword ptr[ebp+12], WM_SIZE
    jz WMSIZE
    cmp dword ptr[ebp+12], WM_TIMER
    jz WMTIMER

; orther message: make sure that all the message is processed
FINISH:
    push dword ptr[ebp+20]
    push dword ptr[ebp+16]
    push dword ptr[ebp+12]
    push dword ptr[ebp+8]
    call DefWindowProc
	
    ; ret and release stack
	jmp EXIT_PROC

; --------------------------------------------------------------------
; Size message: for the first time and when resize the window
; --------------------------------------------------------------------
WMSIZE:
		push offset AppName
		call StdOut
		
		; get client window size
		; low-order
		xor eax, eax
		mov ax, word ptr[ebp+20]
		mov xWinSize, eax

		; high-order
		xor eax, eax
		mov ax, word ptr[ebp+20]+2
		mov yWinSize, eax
		
		
; --------------------------------------------------------------------
; random and get the begin position of circle (obj)
; cxPos (sizeR + step, winWidth - 3*sizeR + step); cyPos (sizeR + step, winHeight - 3*sizeR + step)
		
		; cxPos
		; mov dword ptr [RangeOfNumbers], 520
		mov eax, xWinSize
		mov dword ptr [RangeOfNumbers], eax
		sub dword ptr [RangeOfNumbers], 4*sizeR
		
		rdtsc
		mov RandSeed, eax                   		; Initialize random generator
		mov eax, dword ptr [RangeOfNumbers]         ; Range (0..RangeOfNumbers-1)
		call RandomNum								; output eax		
		
		add eax, sizeR
		add eax, step
		mov cxPos, eax
		
		; cyPos
		mov eax, yWinSize
		sub eax, 4*sizeR
		mov dword ptr [RangeOfNumbers], eax
		
		rdtsc
		mov RandSeed, eax                   		; Initialize random generator
		mov eax,  dword ptr [RangeOfNumbers]        ; Range (0..RangeOfNumbers-1)
		call RandomNum								; output eax		
		
		add eax, sizeR
		add eax, step
		mov cyPos, eax
		
; --------------------------------------------------------------------	
; init ballsize, step each move
	
		mov cxRadius, sizeR
		mov cyRadius, sizeR
		
		mov cxMove, step
		mov cyMove, step
		
		mov eax, cxMove
		add eax, cxRadius
		imul eax, 2
		mov cxTotal, eax
		mov eax, cyMove
		add eax, cyRadius
		imul eax, 2
		mov cyTotal, eax

; --------------------------------------------------------------------	
; get DC, bitmap

		; delete obj
		push hBitmap
		call DeleteObject
		
		; get DC
		push dword ptr[ebp+8]
		call GetDC
		
		; create DC
		mov ps.hdc, eax
		push ps.hdc
		call CreateCompatibleDC
		mov hdcMem, eax
		
		; create bitmap
		push cyTotal
		push cxTotal
		push ps.hdc
		call CreateCompatibleBitmap
		mov hBitmap, eax
		
		; release the DC
		push ps.hdc
		push dword ptr[ebp+8]
		call ReleaseDC
		
		; select/get the obj in DC context (the bitmap)
		push hBitmap
		push hdcMem
		call SelectObject
		

; --------------------------------------------------------------------		
; paint the rectangle => repaint the background of bitmap
; bottom

		mov ecx, cyTotal
		inc ecx
		push ecx
		
		; right
		mov ecx, cxTotal
		inc ecx
		push ecx
		
		; let top
		push -1
		push -1
		
		push hdcMem
		call Rectangle
	
		; paint the circle from the eclipse
		; solid with red color
		push 000000ffh
		call CreateSolidBrush						; output: eax
		
		; get obj
		push eax
		push hdcMem
		call SelectObject
		
		; the eclipse
		; bottom
		mov ecx, cyTotal
		sub ecx, cyMove
		push ecx
		
		; right
		mov ecx, cxTotal
		sub ecx, cxMove
		push ecx
		
		; top
		push cyMove
		; left
		push cxMove
		
		push hdcMem
		call Ellipse
		
; --------------------------------------------------------------------
; random and get the direction
; (1, -1) => 45; (-1, -1) => 135; (-1, 1) => 225; (1, 1) => 315
		
		; random 0..3 => direction: corner
		mov dword ptr [RangeOfNumbers], 4
		rdtsc
		mov RandSeed, eax                  	 		; Initialize random generator
		mov eax, RangeOfNumbers             		; Range (0..RangeOfNumbers-1)
		call RandomNum								; output eax
		
		; get the offset in the array of vector (4 bytes each value)
		mov ebx, 4
		mul ebx
		mov ebx, eax
		
		; get the value of vector x
		mov ecx, dword ptr [xVector + ebx]
		mov eax, cxMove
		imul eax, ecx
		mov cxMove, eax
		
		; get the value of vector y
		mov ecx, dword ptr [yVector + ebx]
		mov eax, cyMove
		imul eax, ecx
		mov cyMove, eax
		
; --------------------------------------------------------------------		
; just delete the DC
		push hdcMem
		call DeleteDC


; --------------------------------------------------------------------
; timer message
; --------------------------------------------------------------------
WMTIMER:
		; get DC, hdc memory
    	push dword ptr[ebp+8]						; handle window offset
		call GetDC						
		mov ps.hdc, eax

		push ps.hdc
		call CreateCompatibleDC
		mov hdcMem, eax

		push hBitmap
		push hdcMem
		call SelectObject
		
		; get the BitBlt
		; copy the resource bitmap to destination
		push SRCCOPY
		push 0
		push 0
		push hdcMem
		push cyTotal
		push cxTotal
		
		; get position
		; top
		mov eax, cyTotal
		xor edx, edx
		mov ebx, 2
		div ebx

		mov ecx, cyPos
		sub ecx, eax
		push ecx
		
		; left
		mov eax, cxTotal
		xor edx, edx
		mov ebx, 2
		div ebx

		mov ecx, cxPos
		sub ecx, eax
		push ecx
		
		; call BitBlt
		push ps.hdc									; destination
		call BitBlt
		
		; release
		push ps.hdc
		push dword ptr[ebp+8]						; handle window offset
		call ReleaseDC
		
		; delete
		push hdcMem
		call DeleteDC

; --------------------------------------------------------------------	
; update new position

		mov eax, cxPos
		add eax, cxMove
		mov cxPos, eax

		mov eax, cyPos
		add eax, cyMove
		mov cyPos, eax


		;cmp right
		mov eax, cxPos
		add eax, cxRadius

		cmp eax, xWinSize
		jge changex

		;cmp left
		mov eax, cxPos
		sub eax, cxRadius

		cmp eax, 0
		jle changex

		; cmp above
		mov eax, cyPos
		add eax, cyRadius
		cmp eax, yWinSize
		jge changey

		;cmp bottom
		mov eax, cyPos
		sub eax, cyRadius
		cmp eax, 0
		jle changey
		
		; nothing change: the circle have not touched the wall
		jmp FINISH

	; touch left or right wall => change direction of x
	changex:
		mov eax, cxMove
		imul eax, -1
		mov cxMove, eax

		;cmp above & bottom
		mov eax, cyPos
		add eax, cyRadius
		cmp eax, yWinSize
		jge changey

		mov eax, cyPos
		sub eax, cyRadius
		cmp eax, 0
		jle changey
		jmp FINISH

	; touch top or bottom wall => change direction of y
	changey:
		mov eax, cyMove
		imul eax, -1
		mov cyMove, eax
		jmp FINISH

; --------------------------------------------------------------------
WMDESTROY:
    push 0
    call PostQuitMessage
    xor eax, eax

EXIT_PROC:
    pop ebp
    ret 4*4											;  release the stack
	
WndProc endp
; main end

; --------------------------------------------------------------------
; random number
; --------------------------------------------------------------------
RandomNum PROC                       				; Deliver EAX: Range (0..EAX-1)
      push  edx                         			; Preserve EDX
      mov ebx, eax
	  
	  imul  edx, RandSeed, 08088405H      			; EDX = RandSeed * 0x08088405 (decimal 134775813)
      inc   edx
      mov   RandSeed, edx               			; New RandSeed
      mul   edx                         			; EDX:EAX = EAX * EDX
      mov   eax, edx                    			; Return the EDX from the multiplication
      
	  add eax, 13317								; just for a good number :>>>
	  xor edx, edx
	  div ebx
	  mov eax, edx
	  
	  pop   edx										; Restore EDX
	  ret
RandomNum ENDP                       				; Return EAX: Random number in range

end main