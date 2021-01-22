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
global killProcess
killProcess:
	push rbx
	push r12
	push r13
	push r14
	push r15
	enter 0x10, 0	

	mov r12, rdi
	xor rsi, rsi	; null signal
	mov rdi, r12
	call kill	; if the process exists or alive
	test rax, rax
	js killProcessLeave
	mov rsi, 0xf	; SIGTERM	
	mov rdi, r12
	call kill
killProcessLeave:
	leave
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	ret

global isInBlackList
isInBlackList:
	push rbx
	push r12
	push r13
	push r14
	push r15
	enter 0x100, 0
	mov rax, 1

	mov r12, blacklist
	mov r13, rdi
blLoop:
	mov r14, qword[r12]
	test r14, r14
	jz notIn
	; cmp r14, r13
	mov rdi, r14
	mov rsi, r13
	call strcmp
	jz isIn	

	add r12, 0x8	; -> next entry
	jmp blLoop 
isIn:
	mov rax, 1
	jmp blLeave
notIn:
	xor rax, rax
	jmp blLeave
blLeave:
	leave
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	ret
global isNumericStr
isNumericStr:
	push rbx
	push r12
	push r13
	push r14
	push r15
	enter 0x100, 0
	
	mov r12, rdi
numCheckLoop:
	mov al, byte[r12]
	test al, al
	jz isNumeric 
	cmp al, 0x30
	jl notNumeric
	cmp al, 0x39
	jg notNumeric

	inc r12
	jmp numCheckLoop 
isNumeric:	
	mov rax, 1
	jmp isNumericStrLeave
notNumeric:
	xor rax, rax
	jmp isNumericStrLeave 
isNumericStrLeave:
	leave
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	ret
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
	mov qword [rbp - 0x8], rax
readdirLoop:
	mov rdi, qword [rbp - 0x8]
	call readdir
	test rax, rax
	jz preLeave	; out of files

	mov rbx, rax	
	lea r12, [rbx + 0x13]	; r12 = d_name
	movzx rdx, byte[r12]
	test rdx, rdx
	jz readdirLoop	; if strlen = 0
	cmp rdx, 0x2E	; '.'	
	jz readdirLoop
	
	mov rdi, r12
	call isNumericStr
	test rax, rax
	jz readdirLoop
	
	mov rcx, r12
	mov rdx, procRootPath 
	mov rsi, fullpathFmt
	lea rdi, [rbp - 0x108]	
	call sprintf
	lea rdi, [rbp - 0x108]
	mov byte[rdi + rax], 0	; set null
	
	xor rsi, rsi	; readonly
	lea rdi, [rbp - 0x108]
	call open	
	mov r13, rax	; r13 = file fd
	inc rax
	test rax, rax
	jz ioErr

	; read process name
	mov rdx, 0x9F
	lea rsi, [rbp - 0x208] 
	mov rdi, r13
	call read		
	test rax, rax
	js ioErr
		
	lea r14, [rbp - 0x208]	; r14 = process name
	dec rax
	mov byte[r14 + rax], 0	; set null

	; close file
	mov rdi, r13
	call close

	mov rdi, r14
	call isInBlackList
	test rax, rax
	jz readdirLoop
	
	mov rdx, r12
	mov rsi, r14
	mov rdi, logFmtS
	call printf

	mov rdi, r12
	call atoi
	cdq
	mov rdi, rax
	call killProcess
	
	jmp readdirLoop
ioErr:
	mov rsi, r12
	mov rdi, ioErrS
	call printf
	jmp readdirLoop
opendirErr:
	mov rdi, opendirErrS
	call puts
	jmp alarmHandlerLeave
preLeave:
	mov rdi, qword[rbp - 0x8]
	call closedir	
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