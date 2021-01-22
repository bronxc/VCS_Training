.386
.model flat, stdcall
option casemap :none


include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

strMaxsize equ 32                   ;max size of the string (32 character)

.data?
    string db strMaxsize dup(?)     ;the string to be entered and printed
                                    ;strMaxsize dup(?) => x32 [?]

.data
    msgIn db "enter the string: ", 0
    msgOut db "the string you enter: ", 0

.code


main:
    ;invoke StdOut, addr msgIn       ;call the proceduce StdOut to print message in msgIn's address
    push offset msgIn
    call StdOut
    
    ;invoke StdIn, addr string, strMaxsize     ;StdIn to  get the string into string variable
    push strMaxsize
    push offset string
    call StdIn

    ;invoke StdOut, addr msgOut
    ;invoke StdOut, addr string      ;print the entered string 
    push offset msgOut
    call StdOut

    push offset string
    call StdOut

    ;invoke ExitProcess, 0           ;end the program
    push 0
    call ExitProcess

end main