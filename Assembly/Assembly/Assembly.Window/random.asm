.686
.MODEL flat, STDCALL

INCLUDE \masm32\libs\kernel32.inc        ; GetStdHandle, WriteFile, ExitProcess
INCLUDELIB \masm32\libs\kernel32.lib

INCLUDE \masm32\libs\user32.inc          ; wsprintf
INCLUDELIB \masm32\libs\user32.lib

NumberOfNumbers = 30        ; Number of random numbers to be generated and shown
RangeOfNumbers = 12         ; Range of the random numbers (0..RangeOfNumbers-1)

.DATA
    RandSeed    dd  ?

.CODE
PseudoRandom PROC                       ; Deliver EAX: Range (0..EAX-1)
      push  edx                         ; Preserve EDX
      imul  edx,RandSeed,08088405H      ; EDX = RandSeed * 0x08088405 (decimal 134775813)
      inc   edx
      mov   RandSeed, edx               ; New RandSeed
      mul   edx                         ; EDX:EAX = EAX * EDX
      mov   eax, edx                    ; Return the EDX from the multiplication
      pop   edx                         ; Restore EDX
      ret
ret
PseudoRandom ENDP                       ; Return EAX: Random number in range

main PROC
    rdtsc
    mov RandSeed, eax                   ; Initialize random generator

    mov ecx, NumberOfNumbers            ; Loop counter - show ECX random numbers
    LL1:
    push ecx                            ; Preserve loop counter

    mov eax, RangeOfNumbers             ; Range (0..RangeOfNumbers-1)
    call PseudoRandom

    call write_number                   ; printf ("%u ", EAX)

    pop ecx                             ; Restore loop counter
    loop LL1

    invoke ExitProcess, 0
main ENDP

write_number PROC STDCALL USES ebx      ; printf ("%u ", EAX)
LOCAL numstring[12]:BYTE, NumberOfBytesWritten:DWORD
.CONST
    fmt db "%u ",0
.CODE
    invoke wsprintf, ADDR numstring, ADDR fmt, eax
    mov ebx, eax                        ; Preserve result - count of written bytes
    invoke GetStdHandle, -11            ; Get STD_OUTPUT_HANDLE
    mov edx, eax                        ; EAX will be used by the following INVOKE
    invoke WriteFile, edx, ADDR numstring, ebx, ADDR NumberOfBytesWritten, 0
    ret
write_number ENDP

END main