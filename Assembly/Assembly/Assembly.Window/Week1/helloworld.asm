.386
.model flat, stdcall
option casemap :none

include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

;extern _ExitProcess@4

;#define ExitProcess _ExitProcess@4


.data
    msg db "Hello, World!", 0ah      ;message (string) to be printed

.code

main:
    ;invoke StdOut, addr msg         ;call the proceduce StdOut to print message in msg's address
    push offset msg
    call StdOut
    
    
    ;ExitProcess(0)
    push 0
    call ExitProcess

end main