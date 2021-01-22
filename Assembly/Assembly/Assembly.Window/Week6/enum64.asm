
include \masm32\include64\masm64rt.inc
includelib \masm32\lib64\msvcrt.lib


; disable any auto-generated prolog vs epilog
OPTION PROLOGUE:None
OPTION EPILOGUE:None

; data ---------------------------------------------------------------------------------
.DATA
timerID QWORD 1h
interval DWORD 5000	;  5 seconds
logEdit QWORD 0h
aboutButton QWORD 0h
hiddenButton QWORD 0h

chrome DW 'G', 'o', 'o', 'g', 'l', 'e', ' ', 'C', 'h', 'r', 'o', 'm', 'e', 0h
edge DW 'M', 'i', 'c', 'r', 'o', 's', 'o', 'f', 't', ' ', 'E', 'd', 'g', 'e', 0h
ff DW 'M', 'o', 'z', 'i', 'l', 'l', 'a', ' ', 'F', 'i', 'r', 'e', 'f', 'o', 'x',  0h

browserArfs QWORD OFFSET chrome, OFFSET edge, OFFSET ff, 0h

editWStr DW 'E', 'D', 'I', 'T', 0
nullWStr DW 0
enumWndError DW 'E',  'R',  'R',  'O',  'R',  ':',  ' ',  'c',  'a',  'n',  'n',  'o',  't',  ' ',  'e',  'n',  'u',  'm',  
	' ',  't',  'o',  'p',  ' ',  'l',  'e',  'v',  'e',  'l',  ' ',  'w',  'i',  'n',  'd',  'o',  'w',  's', 0h

.CONST
wndClassName DB 'AntiBrowserWndClass', 0h
wndTitle DB 'ASM #16: AntiBrowser', 0h

buttonStr DB 'BUTTON', 0h
aboutStr DB 'About', 0h
hiddenStr DB 'Hide', 0h
conght4Str DB 'Win32api & assembly practice', 0Ah, 'congh4@viettel.com.vn', 0h
logAppendFmt DB  '%', 's', 0ah, 0dh, '[',  '*',  ']',  ' ',  '%',  's', 0h

; code ---------------------------------------------------------------------------------
.CODE

;	wcslen(wchar_t * s)
customWstrlen PROC
	xor rax, rax
	mov rdi, rcx
	xor rcx, rcx
	dec rcx
	repne scasw
	add rcx, 2
	neg rcx
	mov rax, rcx
	ret 
customWstrlen ENDP

isBrowserWindow PROC
	push rbx
	push r12
	push r13
	push r14
	push r15
	push rbp
	mov rbp, rsp
	sub rsp, 2000h
	
	mov r15, rcx
	call customWstrlen
	mov r14, rax	; r14 = wlen(s)

	mov rbx, OFFSET browserArfs
	xor r12, r12
isBrowserWindowLoop:
	cmp r12d, 3h
	jge isBrowserWindowRet
	mov rcx, qword ptr[rbx + r12*8]	; b[i]
	call customWstrlen
	cmp r14, rax
	jle isBrowserWindowLoopInc

	std	; compare right to left
	mov rsi, rax
	shl rsi, 1
	add rsi, qword ptr[rbx + r12*8]
	sub rsi, 2	; point to last element

	mov rdi, r14
	shl rdi, 1
	add rdi, r15
	sub rdi, 2	; point to last element

	mov rcx, rax
	inc rcx
	repe cmpsw
	cld	; restore
	test rcx, rcx
	jne isBrowserWindowLoopInc
	mov rax, 1	; true
	jmp isBrowserWindowLeave

isBrowserWindowLoopInc:
	inc r12d
	jmp isBrowserWindowLoop
isBrowserWindowRet:
	xor rax, rax	; false
isBrowserWindowLeave:
	leave
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	ret
isBrowserWindow ENDP

; BOOL CALLBACK EnumWindowsProc(HWND hwnd, LPARAM lParam)
enumWindowsProc PROC
	push r12
	push r13
	push r14
	push r15
	push rbp
	mov rbp, rsp
	sub rsp, 2000h
	
	mov r12, rcx
	mov r13, rdx

	;	wchar_t buf[1024]
	;	wchar_t logBuf[1024];
	;	rbp - 800h	-> buf
	;	rbp - 1000h -> logBuf	buffer overflow	vul

	lea rbx, [rbp - 800h]	; bufOfNewLog
	lea r15, [rbp - 1000h]	; bufOfLogs

	mov rdx, 800h
	mov rcx, rbx
	call customZeroMemory

	; get wnd title
	mov r8, 800h
	dec r8
	mov rdx, rbx	; buf
	mov rcx, r12
	call GetWindowTextW
	test eax, eax
	jz enumWindowsProcRet

	; filter visable window
	mov r14, rax	; r14 = numOfNewLog
	mov rcx, r12
	call IsWindowVisible
	test eax, eax
	jz enumWindowsProcRet

	; filter only browser window
	mov rcx, rbx
	call isBrowserWindow
	test rax, rax
	jz enumWindowsProcRet

	mov r8, 800h
	mov rdx, r15
	mov rcx, logEdit
	call GetWindowTextW
	mov r13, rax	; r13 = numOfAlreadyLogs
	shl rax, 1	; numOfAlreadyLogs*2
	mov dword ptr[r15 + rax], 0A000Dh
	
	; implement swprintf_s(logBuf, L"%s\r\n[*] %s", logBuf, buf) -> fk
	mov rcx, r14
	lea rdi, [r15 + rax]
	add rdi, 4h
	mov rax, 020005d002a005bh	; '[*] '
	mov qword ptr[rdi], rax
	add rdi, 8h
	mov rsi, rbx
	rep movsw
	mov word ptr[rdi], 0	; null ptr

	mov rdx, r15
	mov rcx, logEdit
	call SetWindowTextW

	; destroy window
	; double tap try destroy -> then close

	mov rcx, r12
	call DestroyWindow

	mov rcx, r12
	call IsWindow
	jz enumWindowsProcRet

	xor r9, r9
	xor r8, r8
	mov rdx,WM_CLOSE 
	mov rcx, r12
	call SendMessageA

enumWindowsProcRet:
	mov rax, 1h
	leave
	pop r15
	pop r14
	pop r13
	pop r12
	ret
enumWindowsProc ENDP


; LRESULT CALLBACK windowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
windowProc PROC
	push r12
	push r13
	push r14
	push r15
	push rbp
	mov rbp, rsp
	sub rsp, 100h
	
	mov r12, rcx
	mov r13, rdx
	mov r14, r8
	mov r15, r9

	;	sizeof(RECT) = 0x10
	;	sizeof(PAINTSTRUCT) = 0x48
	;	rbp - 0x10	; RECT cRect
	;	rbp - 0x18	; hModule
	;	rbp - 0x60	; PAINTSTRUCT ps
	
	cmp rdx, WM_TIMER
	jz timerL
	cmp rdx, WM_COMMAND
	jz commandL
	cmp rdx, WM_PAINT
	jz paintL
	cmp rdx, WM_CREATE
	jz createL
	cmp rdx, WM_CLOSE
	jz closeL
	cmp rdx, WM_DESTROY
	jz destroyL

	; default
	call DefWindowProc
	jmp windowProcRet
timerL:
	xor rdx, rdx
	mov rcx, OFFSET enumWindowsProc
	call EnumWindows
	test rax, rax
	jnz timerLEnd

	lea rdx, enumWndError
	mov rcx, logEdit
	call SetWindowTextW
timerLEnd:
	jmp windowProcRet
commandL:
	cmp r15, aboutButton
	jnz cmdHiddenCheck
	mov ax, r14w
	cmp ah, BN_CLICKED
	jnz cmdHiddenCheck

	mov r9, MB_OK
	xor r9, MB_ICONINFORMATION
	mov r8, OFFSET aboutStr
	mov rdx, OFFSET conght4Str
	mov rcx, r12
	call MessageBoxA
cmdHiddenCheck:
	cmp r15, hiddenButton
	jnz cmdEnd
	mov ax, r14w
	cmp ah, BN_CLICKED
	jnz cmdEnd

	mov rdx, SW_HIDE
	mov rcx, r12
	call ShowWindow
cmdEnd:
	jmp windowProcRet
paintL:
	mov rdx, 60h
	lea rbx, [rbp - 60h]
	mov rcx, rbx
	call customZeroMemory

	mov rdx, rbx
	mov rcx, r12
	call BeginPaint
	
	; FillRect(hdc, &ps.rcPaint, (HBRUSH)(COLOR_WINDOW + 1))
	mov r8, COLOR_WINDOW
	inc r8
	lea rdx, [rbx + 0ch]
	mov rcx, rax
	call FillRect

	mov rdx, rbx
	mov rcx, r12
	call EndPaint
	jmp windowProcRet
createL:
	xor r9, r9
	mov r8d, interval
	mov rdx, timerID
	mov rcx, r12 
	call SetTimer
	mov timerID, rax

	lea rbx, [rbp - 10h]
	mov rdx, 10h
	mov rcx, rbx
	call customZeroMemory

	mov rdx, rbx
	mov rcx, r12
	call GetClientRect

	xor rcx, rcx 
	call GetModuleHandle
	mov qword ptr[rbp - 18h], rax

	mov qword ptr[rsp + 58h], 0
	mov rax,  qword ptr[rbp - 18h]
	mov qword ptr[rsp + 50h], rax	; hInstance
	mov qword ptr[rsp + 48h], 0
	mov qword ptr[rsp + 40h], r12	; hwnd
	mov eax, dword ptr[rbx + 0ch]
	sub eax, 40
	cdqe
	mov qword ptr[rsp + 38h], rax	; height
	mov eax, dword ptr[rbx + 08h]
	cdqe
	mov qword ptr[rsp + 30h], rax	; width
	mov qword ptr[rsp + 28h], 0
	mov qword ptr[rsp + 20h], 0
	mov r9d, WS_CHILD
	xor r9d, WS_VISIBLE
	xor r9d, WS_VSCROLL
	xor r9d, ES_AUTOVSCROLL
	xor r9d, ES_MULTILINE
	xor r9d, ES_READONLY
	lea r8, nullWStr	; wnd rep
	lea rdx, editWStr	; class
	xor rcx, rcx
	call CreateWindowExW
	mov logEdit, rax	

	mov qword ptr[rsp + 58h], 0
	mov rax,  qword ptr[rbp - 18h]
	mov qword ptr[rsp + 50h], rax	; hInstance
	mov qword ptr[rsp + 48h], 0
	mov qword ptr[rsp + 40h], r12	; hwnd
	mov qword ptr[rsp + 38h], 25	; height
	mov qword ptr[rsp + 30h], 60	; width
	mov eax, dword ptr[rbx + 0ch]
	sub eax, 30
	cdqe
	mov qword ptr[rsp + 28h], rax	; cRect.bottom - 30
	mov eax, dword ptr[rbx + 08h]
	sub eax, 65
	cdqe
	mov qword ptr[rsp + 20h], rax	; cRect.right - 65
	mov r9d, WS_CHILD
	xor r9d, WS_VISIBLE
	mov r8, OFFSET aboutStr	; wnd rep
	mov rdx, OFFSET buttonStr	; class
	xor rcx, rcx	
	call CreateWindowExA
	mov aboutButton, rax

	mov qword ptr[rsp + 58h], 0
	mov rax,  qword ptr[rbp - 18h]
	mov qword ptr[rsp + 50h], rax	; hInstance
	mov qword ptr[rsp + 48h], 0
	mov qword ptr[rsp + 40h], r12	; hwnd
	mov qword ptr[rsp + 38h], 25	; height
	mov qword ptr[rsp + 30h], 60	; width
	mov eax, dword ptr[rbx + 0ch]
	sub eax, 30
	cdqe
	mov qword ptr[rsp + 28h], rax	;  cRect.bottom - 30

	mov qword ptr[rsp + 20h], 5h
	mov r9d, WS_CHILD
	xor r9d, WS_VISIBLE
	mov r8, OFFSET hiddenStr	; wnd rep
	mov rdx, OFFSET buttonStr	; class
	xor rcx, rcx	
	call CreateWindowExA
	mov hiddenButton, rax

	jmp windowProcRet
closeL:
	mov rdx, timerID
	mov rcx, r12
	call KillTimer

	mov rcx, logEdit
	call DestroyWindow
	
	mov rcx, aboutButton
	call DestroyWindow

	mov rcx, hiddenButton
	call DestroyWindow

	mov rcx, r12
	call DestroyWindow
	xor rax, rax
	jmp windowProcRet

destroyL:
	xor rcx, rcx
	call PostQuitMessage
	xor rax, rax
	jmp windowProcRet

windowProcRet:
	leave
	pop r15
	pop r14
	pop r13
	pop r12
	ret
windowProc ENDP

; customZeroMemory(addr, size)
customZeroMemory PROC
	mov rdi, rcx	
	xor al, al
	mov rcx, rdx 
	rep stosb
	ret 10h
customZeroMemory ENDP

customWinMain PROC 
	push rbp
	mov rbp, rsp
	sub rsp, 200h

	; rbp - 0x8	 hInstance
	; sizeof(WNDCLASS) 0x48
	; sizeof(MSG) 0x30
	; rbp - 0x48 -> wc
	; rbp - 0x30 -> msg

	mov qword ptr [rbp - 8h],rcx
	mov r15, rcx	; r15 = hInstance
	mov rdx, 48h
	lea rbx, [rbp - 48h]	; rbx = wc
	mov rcx, rbx
	call customZeroMemory
	mov qword ptr[rbx + 18h], r15	; hInstance
	; only has up to mov r/m64, imm32
	; -> movabs
	mov rax, windowProc	
	mov qword ptr[rbx + 8h], rax	; winProc
	mov rax, OFFSET wndClassName	
	mov qword ptr[rbx + 40h], rax	; wndClassName

	mov rcx, rbx
	call RegisterClassA
	test eax, eax
	jz customWinMainRet

	mov qword ptr[rsp + 58h], 0
	mov qword ptr[rsp + 50h], r15
	mov qword ptr[rsp + 48h], 0
	mov qword ptr[rsp + 40h], 0
	mov qword ptr[rsp + 38h], 240
	mov qword ptr[rsp + 30h], 320
	mov qword ptr[rsp + 28h], CW_USEDEFAULT
	mov qword ptr[rsp + 20h], CW_USEDEFAULT
	mov r9d, WS_OVERLAPPEDWINDOW
	mov r8, OFFSET wndTitle
	mov rdx, OFFSET wndClassName
	xor rcx, rcx
	call CreateWindowExA
	test rax, rax
	jz customWinMainRet
	mov rdx, SW_SHOW
	mov rcx, rax
	call ShowWindow

	lea rbx, [rbp - 30h]
	mov rdx, 30h
	mov rcx, rbx
	call customZeroMemory
msgLoop:
	xor r9d, r9d
	xor r8d, r8d
	mov rdx, 0
	mov rcx, rbx
	call GetMessage
	test eax, eax
	jz customWinMainRet

	mov rcx, rbx
	call TranslateMessage
	mov rcx, rbx
	call DispatchMessage
	jmp msgLoop

customWinMainRet:
	leave
	ret 8h
customWinMain ENDP

main PROC
	push rbp
	mov rbp, rsp
	sub rsp, 20h

	xor ecx, ecx
	call GetModuleHandle
	mov rcx, rax
	call customWinMain

	leave
	ret
main ENDP
END