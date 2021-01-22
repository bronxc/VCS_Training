bits 64

; -------------------------------------------------------------------
; C library's functions
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


; *******************************************************************
; variable
; *******************************************************************
section .data
timeout dq 10

message db 0ah,  "----------> Anti Netcat <----------", 0ah, 0
signalErr db "Error: Signal error", 0ah, 0
setTimerErr db "Error: Set Timer error", 0ah, 0

procPath db "/proc/", 0
openDirErr db "Error: open proc dir error", 0ah, 0
ioErr db "Error: cannot read info of process with ID %s", 0ah, 0h
logFmt db "Killing pname='%s', pid=%s", 0ah, 0h
fullPathFmt db `%s/%s/comm`, 0h

; ncList "nc" and "netcat"
nc1 db "netcat", 0h
nc2 db "nc", 0h
ncList dq nc1, nc2, 0h



; *******************************************************************
; code
; *******************************************************************
section .text
	global main

; --------------------------------------------------------------------------------------------------------
; main
; --------------------------------------------------------------------------------------------------------
main:
	; prepare the stack // align stack
	; push rbp
	; mov rbp, rsp
	; sub rsp, 100h
	enter 100h, 0								; 256
	
	; app message
	mov rdi, message
	call puts
	
	; ----------------------------------------------------------------
	; signal: alarmHandler - handler - offset function call back
	mov rsi, alarmHandler
	mov rdi, 0xe								; SIGALRM
	call signal									; output: rax => -1 = Flase/SIG_ERR
	
	inc rax
	test rax, rax 								; rax = 0 ???? => jmp
	jz @signalErr
	
	; ----------------------------------------------------------------
	; clean the stack for the 2 struct itimerspec - timerInfo
	; size: 20h	- 32 byte
	; rbp - 20h: sotre 2 struct itimerspec - timerInfo
	xor rsi, rsi
	mov esi, 20h								
	lea rdi, [rbp - 20h]
	call cleanStack
	
	; ----------------------------------------------------------------
	; settimer
	lea rbx, [rbp - 0x20]						; 2 struct itimerspec - timerInfo place
	
	mov rax, qword [timeout]					; 10s
	mov qword [rbx + 0x10], rax					; timerInfo.it_value.tv_sec = timeout; 
	mov qword [rbx], rax						; timerInfo.it_interval.tv_sec = timeout
	
	xor rdx, rdx								; flags = NULL
	mov rsi, rbx								; point to struct itimerspec
	mov rdi, 0	 								; ITIMER_REAL
	call setitimer								; Out. rax = 0 => PASS
	
	test rax, rax
	jnz @setTimerErr							; rax != 0 => ERR
	
; ---------------------------------------------------------------------
; loop the app
@whileTrue:
	call pause
	jmp @whileTrue
	
	xor rax, rax
	jmp mainEndp

; ---------------------------------------------------------------------
; error msg
@signalErr:
	mov rdi, signalErr
	call puts
	jmp mainEndp
	
@setTimerErr:
	mov rdi, setTimerErr
	call puts
	jmp mainEndp

; ---------------------------------------------------------------------
mainEndp:
	leave
	ret
	

; --------------------------------------------------------------------------------------------------------
; alarmHandler: call back
; --------------------------------------------------------------------------------------------------------
alarmHandler:
	; allign stack
	enter 300h, 0
	; rbp - 8h: handle to dir
	; rbp - 108h: store the full path
	; rbp - 208h: store the process name
	; max: 256 char
	
	; open dir
	mov rdi, procPath
	call opendir								; out. rax = 0 => ERR
	; check
	test rax, rax
	jz @openDirErr
	mov qword [rbp - 8h], rax

; ---------------------------------------------------------------------
; loop for read dir
@readDirLoop:
	; read dir
	mov rdi, qword [rbp - 8h]
	call readdir								; out. rax = 0 => out of files
	; check
	test rax, rax
	jz @closeDir

	; check dir (file)
	mov rbx, rax
	lea r12, [rbx + 13h]						; d_name // offset 19 // pid
	movzx rdx, byte [r12]
	; check dir_name
	test rdx, rdx								; 0h (NULL), strlen = 0
	jz @readDirLoop
	cmp rdx, 2Eh								; '.'
	jz @readDirLoop
	
	; ---------------------------------------------------------------------
	; check pid if a number
	mov rdi, r12								; pid
	call isNumber								; out. rax = 0 => False
	test rax, rax
	jz @readDirLoop
	
	; ---------------------------------------------------------------------
	; get the fill path to file
	mov rcx, r12								; d_name				//pid
	mov rdx, procPath 
	mov rsi, fullPathFmt						; format
	lea rdi, [rbp - 108h]						; off store the full path in stack
	call sprintf								; out. rax = length of the full path without /0 (null)
	
	lea rdi, [rbp - 108h]
	mov byte [rdi + rax], 0						; null
	
	; ---------------------------------------------------------------------
	; open the file
	xor rsi, rsi								; 0 - readonly
	lea rdi, [rbp - 108h]
	call open									; out. rax = -1 => Error
	mov r13, rax								; store the file fd
	; check
	inc rax
	test rax, rax
	jz @ioErr
	
	; ---------------------------------------------------------------------
	; read process name
	mov rdx, 9Fh								; num of readed bytes
	lea rsi, [rbp - 208h]						; off store the process name in stack
	mov rdi, r13
	call read									; out. rax <= 0 => ERR // length of the process name string
	; check
	test rax, rax
	js @ioErr
	
	lea r14, [rbp - 208h]						; process name
	dec rax
	mov byte [r14 + rax], 0						; /0 null
	
	; ---------------------------------------------------------------------
	; close file
	mov rdi, r13
	call close
	
	; ---------------------------------------------------------------------
	; time to kill
	; check if it is nc /netcat
	mov rdi, r14
	call isNetcat								; out. rax = 0 => False, rax = 1 => True
	; check
	test rax, rax
	jz @readDirLoop
	
	; ------------------------------------------
	; print msg kill
	mov rdx, r12								; d_name //pid
	mov rsi, r14								; process name (nc / netcat)
	mov rdi, logFmt								; format
	call printf
	
	; kill the process netcat
	mov rdi, r12								; pid string
	call atoi									; to number => rax
	cdq											; convert double to quad (rax - eax)
	mov rdi, rax								; pid number
	call killProcess
	
	; -------------------------------------------
	; end
	jmp @readDirLoop

; ------------------------------------------------------------
; error msg
@openDirErr:
	mov rdi, openDirErr
	call puts
	jmp alarmHandlerEndp
	
@closeDir:
	mov rdi, qword [rbp -8h]
	call closedir
	jmp alarmHandlerEndp

@ioErr:
	mov rsi, r12
	mov rdi, ioErr
	call printf
	jmp @readDirLoop

; --------------------------------------------------------------
alarmHandlerEndp:
	leave
	ret


	
; --------------------------------------------------------------------------------------------------------
; killProcess
; --------------------------------------------------------------------------------------------------------
killProcess:
	; in. rdi: pid number
	push rbx
	push r12
	push r13
	push r14
	push r15
	enter 10h, 0	
	
	; store thi pid
	mov r12, rdi
	
	; kill the process
	; soft kill
	mov rsi, 0xf								; SIGTERM	
	mov rdi, r12
	call kill									; if the process exists or alive
	; check										; out. rax = 0 => Success, -1 => Err
	test rax, rax
	js killProcessLeave
	
	; immediatedly and both parent and childs
	mov rsi, 9									; SIGKILL
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
	
	
; --------------------------------------------------------------------------------------------------------
; cleanStack
; --------------------------------------------------------------------------------------------------------
cleanStack:
	; in. 
	; esi/rsi: size
	; rdi: point to the stack place
	enter 0, 0
	mov ecx, esi
	xor rax, rax
	rep stosb
	leave
	ret
	
; --------------------------------------------------------------------------------------------------------
; isNumericStr
; --------------------------------------------------------------------------------------------------------
isNumber:
	; in. rdi: the string number be needed to check
	push rbx
	push r12
	push r13
	push r14
	push r15
	enter 0x100, 0
	
	mov r12, rdi

; ----------------------------------------------
@numCheckLoop:
	mov al, byte[r12]
	test al, al									; 0h (NULL) out of number string
	jz @isNumeric 
	cmp al, 30h									; '0' char ascii
	jl @notNumeric
	cmp al, 39h									; '9' char ascii
	jg @notNumeric

	inc r12
	jmp @numCheckLoop 

; ----------------------------------------------
; True
@isNumeric:	
	mov rax, 1
	jmp isNumberEndp

; ----------------------------------------------
; False
@notNumeric:
	xor rax, rax
	jmp isNumberEndp 

; ----------------------------------------------
isNumberEndp:
	leave
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	ret


; --------------------------------------------------------------------------------------------------------
; isNetcat
; --------------------------------------------------------------------------------------------------------
isNetcat:
	; in. rdi: process name
	; out. rax: 0 - Flase, 1 - True
	push rbx
	push r12
	push r13
	push r14
	push r15
	enter 0x100, 0
	mov rax, 1
	
	; get offset of netcat list - process name
	mov r12, ncList
	mov r13, rdi

; ----------------------------------------------
@ncLoop:
	mov r14, qword[r12]
	test r14, r14
	jz @notIn
	
	; cmp r14, r13
	mov rdi, r14
	mov rsi, r13
	call strcmp									; out. rax = 0 => TRUE
	jz @isIn	
	
	; next
	add r12, 0x8	
	jmp @ncLoop 

; ----------------------------------------------
@isIn:
	mov rax, 1
	jmp isNetcatEndp

; ----------------------------------------------
@notIn:
	xor rax, rax
	jmp isNetcatEndp

; ----------------------------------------------
isNetcatEndp:
	leave
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	ret