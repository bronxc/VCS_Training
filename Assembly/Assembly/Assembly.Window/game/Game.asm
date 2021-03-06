include \masm32\lib\Irvine32.inc
include C:\Users\Greenleo\Desktop\VCS\Training\Assembly\VCS.Training.Assembly\Assembly.Window\game\Player1.inc
include C:\Users\Greenleo\Desktop\VCS\Training\Assembly\VCS.Training.Assembly\Assembly.Window\game\Player2.inc
include \masm32\lib\Menu.inc
includelib \masm32\lib\winmm.lib

PlaySound PROTO,
        pszSound:PTR BYTE, 
        hmod:DWORD, 
        fdwSound:DWORD

.data
	;sound cfgs
	deviceConnect BYTE "DeviceConnect",0
	SND_ALIAS    DWORD 00010000h
	SND_RESOURCE DWORD 00040005h
	SND_FILENAME DWORD 00020000h
	SND_ASYNC DWORD 0001h
	file BYTE "take.wav",0
	;visual cfg
	direita byte ">",0
	esquerda byte "<",0
	cima byte "^",0
	baixo byte "v",0
	score word 0	
	; Game configs
	max_x = 80
	max_y = 24
	field byte max_x dup (max_y dup (0))
	singleplayer_speed word 250
	multiplayer_speed word 200

.code
main PROC
	mov eax, SND_FILENAME
	or eax, SND_ASYNC
    INVOKE PlaySound, OFFSET file, NULL, eax
	call menu
	exit
main ENDP

Singleplayer_Game PROC
	call ClrScr
	call WaitMsg
	call ClrScr
	Singleplayer:
		movzx  eax,singleplayer_speed
		call Delay
		call ReadKey
		call get_p1
		call step_p1
		call check_p1
		call print_p1
		inc score
		.if singleplayer_speed > 20
			sub singleplayer_speed,5
		.endif
		cmp p1_status,0
		jne Singleplayer
		call show_score
		ret
Singleplayer_Game ENDP

Multiplayer_Game PROC
	call ClrScr
	call WaitMsg
	call ClrScr
	Multiplayer:
		movzx  eax,multiplayer_speed
		call Delay
		call ReadKey
		call get_p1
		call get_p2
		call check_p1
		cmp p1_status,0
		je Perdeu1
		call step_p1
		call print_p1
		call check_p2
		cmp p2_status,0
		je Perdeu2
		call step_p2
		call print_p2
		jmp Multiplayer
	Perdeu1:
		call show_score
		ret
	Perdeu2:
		call show_score_p2
		ret
Multiplayer_Game ENDP

reset PROC
	mov p1_x,12
	mov p1_y,12
	mov p1_dir,0 
	mov p1_status, 1
	mov score, 0
	mov ecx, 1280
reset ENDP
end main
