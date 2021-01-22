bits 64

extern puts
extern signal
extern setitimer
extern pause
extern opendir
extern readdir
extern closedir
extern sprintf
extern open
extern close
extern read
extern printf
extern kill
extern atoi
extern strcmp


section .text

global customZeroMem	; (void* mem, int size)
customZeroMem:
	enter 0, 0
	mov ecx, esi
	xor rax, rax
	rep stosb
	leave
	ret
global alarmHandler
alarmHandler:
	enter 0x300, 0
	; rbp - 0x8	; hanlde to dir
	; rbx 	-> struct dirent * de
	; [rbx] + 13h -> d_name

	; rbp - 0x108	fullpath
	; rbp- 0x208	processName
	
	mov rdi, procRootPath
	call opendir
	test rax, rax
	jz opendirErr
	
opendirErr:
	mov rdi, opendirErrS
	call puts
	
alarmHandlerLeave:
	leave
	ret

global main
main:
	; alternative for 
	; push rbp
	; mov rbp, rsp
	; sub rsp, 0x100
	enter 0x100, 0
	;
	; sizeof(struct itimerval) = 0x20 
	; rbp - 0x20 struct itimerval timerInfo
	;
	mov rdi, welcome
	call puts
	
	mov rsi, alarmHandler
	mov rdi, 0xe	; SIGALRM
	call signal	
	inc rax
	test rax, rax	; SIG_ERR -1	
	jz signalErr
	
	mov esi, 0x20
	lea rdi, [rbp - 0x20]	
	call customZeroMem
	
	lea rbx, [rbp - 0x20]
	mov rax, qword [timeout]
	mov qword [rbx + 0x10], rax	; timerInfo.it_value.tv_sec = timeout; 
	mov qword [rbx], rax		; timerInfo.it_interval.tv_sec = timeout
	xor rdx, rdx
	mov rsi, rbx
	mov rdi, 0	; ITIMER_REAL
	call setitimer
	test rax, rax
	jnz setitimerErr
	
jmp mainLeave
	
infLoop:
	call pause
	jmp infLoop

	xor rax, rax
	jmp mainLeave
setitimerErr:
	mov rdi, setitimerErrS
	call puts
	jmp mainLeave
signalErr:
	mov rdi, signalErrS
	call puts
mainLeave:	
	leave
	ret

section .data
timeout: dq 10

section .rodata
welcome: db `--- ASM #17 AntiNetcat ---`, 0h
signalErrS: db `ERROR: cannot associate signal with its handler\n`, 0h
setitimerErrS: db `ERROR: cannot setitimer\n`, 0h

procRootPath: db `/proc/`, 0h
opendirErrS: db `ERROR: cannot read proc snapshot`, 0h
ioErrS: db `ERROR: cannot read info of process with ID %s\n`, 0h
logFmtS: db `[*] killing pname='%s', pid=%s\n`, 0h
fullpathFmt: db `%s/%s/comm`, 0h

; blacklist 'nc' and 'netcat'
bl1: db `netcat`, 0h
bl2: db `nc`, 0h
blacklist: dq bl1, bl2, 0h