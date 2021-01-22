includelib \masm32\lib\shlwapi.lib
includelib \masm32\lib\psapi.lib
include \masm32\include\masm32rt.inc
;include \masm32\include\shlwapi.inc
;include \masm32\include\psapi.inc

;extern StrCmpC: proc
extrn StrRStrIA: NEAR
;extern GetModuleFileNameEx: proc
;extern PathStripPath: proc


.data

	string db "abc123abc", 0
	strSub db "123", 0
	
	msg db "done", 0
	
	
.code
start:
	push offset strSub
	push NULL
	push offset string
	call StrRStrIA
	
	cmp eax, 0
	je @exit
	
	push offset msg
	call StdOut
	
	@exit:
	push 0
	call ExitProcess
	
	
end start