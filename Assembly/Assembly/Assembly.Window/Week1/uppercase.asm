.386
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

strMaxsize equ 32                   ;max size of the string (32 character)

.data?
    string db strMaxsize dup(?)     ;the string to be entered
                                    ;strMaxsize dup(?) => x32 [?]

.data
    msgIn db "enter the string: ", 0
    msgOut db "the uppercase string you enter: ", 0


.code

uppercase:
@toUpper:
    mov al, [edx]       ; edx is the pointer, so [edx] the current char
    cmp al, 0
    je @done            ; al is null, there is no other chars
    cmp al,'a'
    jb @next     ; al < 'a', not a "lowercase" char
    cmp al,'z'
    ja @next     ; al > 'z', not a "lowercase" char
    sub al, 20h         ; uppercase al (ascii code)
    mov [edx],al        ; write it back to string

@next:
    inc edx             ; not al, that's the character. edcx has to
                        ; be increased, to point to next char
    jmp @toUpper

@done:
    ret

main:
    ;invoke StdOut, offset msgIn  
    push offset msgIn
    call StdOut

    ;invoke StdIn, offset string, strMaxsize     ;StdIn to  get the string into string variable
    push strMaxsize
    push offset string
    call StdIn

    mov edx, offset string
    call uppercase

    ;invoke StdOut, offset msgOut 
    ;invoke StdOut, offset string
    push offset msgOut
    call StdOut

    push offset string
    call StdOut

    ;invoke ExitProcess, 0           ;end the program
    push 0
    call ExitProcess
    
end main