; **********************************************
; strucure
; **********************************************

; elf header
struc   elf64_hdr
	e_ident		resb	16
	e_type		resb	2
	e_machine	resb	2
	e_version	resb	4
	e_entry		resb	8
	e_phoff		resb	8
	e_shoff		resb	8
	e_flags 	resb	4
	e_ehsize 	resb	2
	e_phentsize resb	2
	e_phnum 	resb	2
	e_shentsize	resb	2
	e_shnum 	resb	2
	e_shstrndx 	resb	2
endstruc

; section header
struc   elf64_shdr
	sh_name			resb	4
	sh_type			resb	4
	sh_flags		resb	8
	sh_addr			resb	8
	sh_offset		resb	8
	sh_size			resb	8
	sh_link			resb	4
	sh_info 		resb	4
	sh_addralign 	resb	8
	sh_entsize	 	resb	8
endstruc

; program header
struc   elf64_phdr
	p_type		resb	4
	p_flags		resb	4
	p_offset	resb	8
	p_vaddr		resb	8
	p_paddr		resb	8
	p_filesz	resb	8
	p_memsz 	resb	8
	p_align 	resb	8
endstruc



; **********************************************
; variable
; **********************************************
section .data
	; ----------------------------------------------
	; constant
	; ----------------------------------------------
	fileMaxSize equ 1024
	nameMaxSize equ 256
	numMaxSize	equ 10
	
	
	; ----------------------------------------------
	; struct variable
	; ----------------------------------------------
	sElfHeader:
		 istruc elf64_hdr
		 iend
		 
	sSecHeader:
		 istruc elf64_shdr
		 iend	 
	
	sProHeader:
		 istruc elf64_phdr
		 iend
		 
	; ----------------------------------------------
	; message string
	; ----------------------------------------------
	
	; input msg
	msgIn db "enter file link: "
	len_msgIn equ $-msgIn
	
	; err msg
	msgElfFileErr db "File format do not match", 0ah, 0
	len_msgElfFileErr equ $-msgElfFileErr
	
	; ----------------------------------------------
	; elf header
	; ----------------------------------------------
	msgElfHeader db "ELF Header:", 0
	len_msgElfHeader equ $-msgElfHeader
	
	; magic 
	msgMagic db "Magic: ", 0
	len_msgMagic equ $-msgMagic
	
	;class
	msgClass db "Class: ", 09h, 09h, 09h, 09h, 0
	len_msgClass equ $-msgClass
	
	; Data
	msgData db "Data: ", 09h, 09h, 09h, 09h, 0
	len_msgData equ $-msgData
	
	; Version
	msgVersion db "Version: ", 09h, 09h, 09h, 09h, 0
	len_msgVersion equ $-msgVersion
	
	; OS/ABI
	msgOSABI db "OS/ABI: ", 09h, 09h, 09h, 09h, 0
	len_msgOSABI equ $-msgOSABI
	
	; ABI Version
	msgABIVersion db "ABI Version: ", 09h, 09h, 09h, 09h, 0
	len_msgABIVersion equ $-msgABIVersion
	
	; Type
	msgType db "Type: ", 09h, 09h, 09h, 09h, 0
	len_msgType equ $-msgType
	
	; Machine
	msgMachine db "Machine: ", 09h, 09h, 09h, 09h, 0
	len_msgMachine equ $-msgMachine
	
	; Entry point address
	msgEntry db "Entry point address: ", 09h, 09h, 09h, 0
	len_msgEntry equ $-msgEntry
	
	; Start of program headers
	msgStartPh db "Start of program headers: ", 09h, 09h, 0
	len_msgStartPh equ $-msgStartPh
	
	; Start of section headers
	msgStartSh db "Start of section headers: ", 09h, 09h, 0
	len_msgStartSh equ $-msgStartSh
	
	; Flags
	msgFlags db "Flags: ", 09h, 09h, 09h, 09h, 0
	len_msgFlags equ $-msgFlags
	
	; Size of this header
	msgSizeEh db "Size of this header: ", 09h, 09h, 09h, 0
	len_msgSizeEh equ $-msgSizeEh
	
	; Size of program headers
	msgSizePh db "Size of program headers: ", 09h, 09h, 0
	len_msgSizePh equ $-msgSizePh
	
	; Number of program headers
	msgNumPh db "Number of program headers: ", 09h, 09h, 0
	len_msgNumPh equ $-msgNumPh
	
	; Size of section headers
	msgSizeSh db "Size of section headers: ", 09h, 09h, 0
	len_msgSizeSh equ $-msgSizeSh
	
	; Number of section headers
	msgNumSh db "Number of section headers: ", 09h, 09h, 0
	len_msgNumSh equ $-msgNumSh
	
	; Section header string table index
	msgShStrIndex db "Section header string table index: ", 09h, 0
	len_msgShStrIndex equ $-msgShStrIndex
	
	
	; ----------------------------------------------
	; EI_CLASS
	ei_class 	db "ELF32", 0
				db "ELF64", 0
	
	len_ei_class equ ($-ei_class)/2
	
	; ----------------------------------------------
	; EI_DATA
	ei_data		db "2's complement, little endian", 0
				db "2's complement, big endian   ", 0
	len_ei_data equ ($-ei_data)/2 
	
	; ----------------------------------------------
	; EI_VERSION
	ei_version	db "1 (current)", 0
	len_ei_version equ $-ei_version
	
	; ----------------------------------------------
	; EI_OSABI
	ei_osabi	db "System V                    ", 0
				db "HP-UX                       ", 0
				db "NetBSD                      ", 0
				db "Linux                       ", 0
				db "GNU Hurd                    ", 0
				db "Solaris                     ", 0
				db "AIX                         ", 0
				db "IRIX                        ", 0
				db "FreeBSD                     ", 0
				db "Tru64                       ", 0
				db "Novell Modesto              ", 0
				db "OpenBSD                     ", 0
				db "OpenVMS                     ", 0
				db "NonStop Kernel              ", 0
				db "AROS                        ", 0
				db "Fenix OS                    ", 0
				db "CloudABI                    ", 0
				db "Stratus Technologies OpenVOS", 0

	len_ei_osabi equ ($-ei_osabi)/19
	
	; ----------------------------------------------
	; EI_ABIVERSION
	ei_abiversion db "0", 0
	len_ei_abiversion equ $-ei_abiversion
	
	; ----------------------------------------------
	; e_type
	et_type		db "NONE", 0
				db "REL ", 0
				db "EXEC", 0
				db "DYN ", 0
				db "CORE", 0
	
	len_et_type equ ($-et_type)/5
	
	; ----------------------------------------------
	; e_machine
	et_machine 	db "x86        ", 0									; 0x03
				db "IA-64      ", 0									; 0x32
				db "amd64      ", 0									; 0x3e
				db "ARM 64-bits", 0									; 0xB7
	
	len_et_machine equ ($-et_machine)/4
	
	; ----------------------------------------------
	; e_version
	et_version db "0x1", 0
	len_et_version equ $-et_version
	
	; ----------------------------------------------
	; e_flags
	et_flags db "0x0", 0
	len_et_flags equ $-et_flags
	
	
	; ----------------------------------------------
	; section header
	; ----------------------------------------------
	msgSectionHeader db "Section Headers:", 0
	len_msgSectionHeader equ $-msgSectionHeader
	
	; msg note keys to flags
	msgKeysToFlags 	db "Key to Flags:", 0ah,
					db "W (write), A (alloc), X (execute), M (merge), S (strings), I (info),", 0ah,
					db "L (link order), O (extra OS processing required), G (group), T (TLS),", 0ah,
					db "C (compressed), x (unknown), o (OS specific), E (exclude),", 0ah
					db "p (processor specific)", 0
	
	len_msgKeysToFlags equ $-msgKeysToFlags
  
	; field: collum
	msgColField db "[Nr]  Name", 09h, 09h, "Type", 09h, 09h, "Addr", 09h, "Off", 09h, "Size", 09h, "ES  Flg  Lk  Inf  Al"
	
	;
	
	
	
	
	; ----------------------------------------------
	; other variable
	; ----------------------------------------------
	cEnter db 0ah, 0
	len_cEnter equ $-cEnter
	
	cSpace db 20h, 0
	len_cSpace equ $-cSpace

	cSpaceX2 db 20h, 20h, 0
	len_cSpaceX2 equ $-cSpaceX2
	
	c0x db "0x", 0
	len_c0x equ $-c0x
	
	cByte db " (bytes)", 0
	len_cByte equ $-cByte
	
	strByte db " (bytes into file)", 0
	len_strByte equ $-strByte
	
	cL
	
	elf_checker db 0
	OSclass db 0
	
	strHex times 2 db "0"
	strDec times numMaxSize db "0"
	
	count dd 0	 
	shOffset dd 0
	phOffset dd 0
	
; **********************************************
; ultilize data	
; **********************************************
section .bss
	file_name resb nameMaxSize
	fd_in resb 1
	data resb fileMaxSize
	
	field resb 16
	
; **********************************************
; code
; **********************************************
section .text
	global _start

; ----------------------------------------------	
; main	
; ----------------------------------------------
_start:

	call input
	
	; check elf file format
	call check_elf										; input: data
	cmp byte [elf_checker], 0
	je @exit
	
	; elf header
	call readelf_h
	
	
	
	@exit:
	mov eax, 1
	int 0x80







; ----------------------------------------------
; section header: readelf -S
; ----------------------------------------------
readelf_S:
	























; ----------------------------------------------
; elf header: readelf -h
; ----------------------------------------------
readelf_h:
	call printEnter
	
	; print elf header msg
	mov ecx, msgElfHeader
	mov edx, len_msgElfHeader
	call printMsg
	
	; get elf header field
	call felf_hdr
	
	; print elf header field
	call print_elf_hdf
	call printEnter
	
	ret


; ----------------------------------------------
; get elf header field
felf_hdr: 
	; call get each field //call fe_ident
	call fe_ident
	call fe_type
	call fe_machine
	call fe_version
	
	; different with other clas 32/64
	; get in proc fe_ident
	cmp byte [OSclass], 1
	jne @felf_hdr_64
	
	@felf_hdr_32:
		call fe_entry32
		call fe_phoff32
		call fe_shoff32
		call fe_flags32
		call fe_ehsize32
		call fe_phentsize32
		call fe_phnum32
		call fe_shentsize32
		call fe_shnum32
		call fe_shstrndx32
		
		jmp @done_felf_hdr
		
	@felf_hdr_64:
		call fe_entry64
		call fe_phoff64
		call fe_shoff64
		call fe_flags64
		call fe_ehsize64
		call fe_phentsize64
		call fe_phnum64
		call fe_shentsize64
		call fe_shnum64
		call fe_shstrndx64
	
	@done_felf_hdr:
		ret
	

; ----------------------------------------------
; print elf header field
print_elf_hdf:
	; call print each field
	call print_elf_hdf_magic
	call print_elf_hdf_class
	call print_elf_hdf_data
	call print_elf_hdf_version
	call print_elf_hdf_osabi
	call print_elf_hdf_abiversion
	call print_elf_hdf_type
	call print_elf_hdf_machine
	call print_elf_hdf_e_version
	call print_elf_hdf_e_entry
	call print_elf_hdf_e_phoff
	call print_elf_hdf_e_shoff
	call print_elf_hdf_e_flags
	call print_elf_hdf_e_ehsize
	call print_elf_hdf_e_phentsize
	call print_elf_hdf_e_phnum
	call print_elf_hdf_e_shentsize
	call print_elf_hdf_e_shnum
	call print_elf_hdf_e_shstrndx
	
	ret


; ----------------------------------------------
; print magic
print_elf_hdf_magic:
	; in e_ident field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgMagic
	mov edx, len_msgMagic
	call printMsg
	
	; print field
	; init input to proc
	mov eax, sElfHeader + e_ident
	mov ebx, eax
	add ebx, 15													; 
	
	call printFieldData
	
	ret


; ----------------------------------------------
; print class
print_elf_hdf_class:
	; in e_ident field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgClass
	mov edx, len_msgClass
	call printMsg
	
	; get code
	xor eax, eax
	mov al, byte [OSclass]	
	
	; print field
	; init input to proc
	; offset code
	dec eax
	mov ebx, len_ei_class
	mul ebx
	
	mov ecx, ei_class
	add ecx, eax
	mov edx, len_ei_class
	
	call printMsg
	
	ret


; ----------------------------------------------
; print data
print_elf_hdf_data:
	; in e_ident field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgData
	mov edx, len_msgData
	call printMsg
	
	; get code
	xor eax, eax
	mov al, byte [sElfHeader + e_ident + 5]	
	
	; print field
	; init input to proc
	; offset code
	dec eax
	mov ebx, len_ei_data
	mul ebx
	
	mov ecx, ei_data
	add ecx, eax
	mov edx, len_ei_data
	
	call printMsg
	
	ret

; ----------------------------------------------
; print version
print_elf_hdf_version:
	; in e_ident field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgVersion
	mov edx, len_msgVersion
	call printMsg
	
	; print field
	; init input to proc
	
	mov ecx, ei_version
	mov edx, len_ei_version
	
	call printMsg
	
	ret


; ----------------------------------------------
; print OS/ABI
print_elf_hdf_osabi:
	; in e_ident field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgOSABI
	mov edx, len_msgOSABI
	call printMsg
	
	; get code
	xor eax, eax
	mov al, byte [sElfHeader + e_ident + 7]	
	
	; print field
	; init input to proc
	; offset code

	mov ebx, len_ei_osabi
	mul ebx
	
	mov ecx, ei_osabi
	add ecx, eax
	mov edx, len_ei_osabi
	
	call printMsg
	
	ret
	
; ----------------------------------------------
; print abi version
print_elf_hdf_abiversion:
	; in e_ident field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgABIVersion
	mov edx, len_msgABIVersion
	call printMsg
	
	; print field
	; init input to proc
	
	mov ecx, ei_abiversion
	mov edx, len_ei_abiversion
	
	call printMsg
	
	ret

	
; ----------------------------------------------
; print type
print_elf_hdf_type:
	; in e_type field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgType
	mov edx, len_msgType
	call printMsg
	
	; get code
	xor eax, eax
	mov ax, word [sElfHeader + e_type]	
	
	; print field
	; init input to proc
	; offset code
	mov ebx, len_et_type
	mul ebx
	
	mov ecx, et_type
	add ecx, eax
	mov edx, len_et_type
	
	call printMsg
	
	ret
	

; ----------------------------------------------
; print machine
print_elf_hdf_machine:
	; in e_machine field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgMachine
	mov edx, len_msgMachine
	call printMsg
	
	; get code
	xor eax, eax
	mov ax, word [sElfHeader + e_machine]
	
	@index1:
		cmp ax, 03h
		jne @index2
		mov eax, 0
		jmp @get_machine_offet
		
	@index2:
		cmp ax, 32h
		jne @index3
		mov eax, 1
		jmp @get_machine_offet
	
	@index3:
		cmp ax, 0xb7
		jne @index4
		mov eax, 3
		jmp @get_machine_offet
	
	@index4:
		mov eax, 2									; 0x3e : amd64
	
	; print field
	; init input to proc
	; offset code
	@get_machine_offet:
	mov ebx, len_et_machine
	mul ebx
	
	mov ecx, et_machine
	add ecx, eax
	mov edx, len_et_machine
	
	call printMsg
	
	ret
	

; ----------------------------------------------
; print e_version
print_elf_hdf_e_version:
	; in e_version field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgVersion
	mov edx, len_msgVersion
	call printMsg
	
	; print field
	; init input to proc
	
	mov ecx, et_version
	mov edx, len_et_version
	call printMsg
	
	ret
	

; ----------------------------------------------
; print entry
print_elf_hdf_e_entry:
	; in e_entry field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgEntry
	mov edx, len_msgEntry
	call printMsg
	
	; print field
	; init input to proc
	
	call print0x
	
	; print address
	mov eax, sElfHeader + e_entry
	mov ebx, eax
	
	add ebx, 3
	cmp byte[OSclass], 1
	je @print_elf_hdf_e_entry
	add ebx, 4
	
	; print
	@print_elf_hdf_e_entry:
	call printAddr
	
	ret



; ----------------------------------------------
; print e_phoff
print_elf_hdf_e_phoff:
	; in e_phoff field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgStartPh
	mov edx, len_msgStartPh
	call printMsg
	
	; print field
	; init input to proc

	mov eax, dword [sElfHeader + e_phoff]
	
	cmp byte[OSclass], 1
	je @print_elf_hdf_e_phoff
	mov eax, dword [sElfHeader + e_phoff + 4]
	
	; print
	@print_elf_hdf_e_phoff:
	; print decimal value
	mov dword [phOffset], eax								; store program header offset
	call printDec
	
	call printStrByte
	
	ret


; ----------------------------------------------
; print e_shoff
print_elf_hdf_e_shoff:
	; in e_shoff field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgStartSh
	mov edx, len_msgStartSh
	call printMsg
	
	; print field
	; init input to proc

	mov eax, dword [sElfHeader + e_shoff]
	
	cmp byte[OSclass], 1
	je @print_elf_hdf_e_shoff
	mov eax, dword [sElfHeader + e_shoff + 4]
	
	; print
	@print_elf_hdf_e_shoff:
	; print decimal value
	mov dword [shOffset], eax								; store section header offset
	call printDec
	
	call printStrByte
	
	ret

; ----------------------------------------------
; print flags
print_elf_hdf_e_flags:
	; in e_flags field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgFlags
	mov edx, len_msgFlags
	call printMsg
	
	; print field
	; init input to proc
	mov ecx, et_flags
	mov edx, len_et_flags
	call printMsg
	
	ret
	

; ----------------------------------------------
; print e_ehsize
print_elf_hdf_e_ehsize:
	; in e_ehsize field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgSizeEh
	mov edx, len_msgSizeEh
	call printMsg
	
	; print field
	; init input to proc
	
	xor eax, eax
	mov ax, word [sElfHeader + e_ehsize]
	
	; print decimal value
	call printDec
	call printByte
	
	ret

; ----------------------------------------------
; print e_phentsize
print_elf_hdf_e_phentsize:
	; in e_phentsize field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgSizePh
	mov edx, len_msgSizePh
	call printMsg
	
	; print field
	; init input to proc
	
	xor eax, eax
	mov ax, word [sElfHeader + e_phentsize]
	
	; print decimal value
	call printDec
	call printByte
	
	ret

; ----------------------------------------------
; print e_phnum
print_elf_hdf_e_phnum:
	; in e_phnum field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgNumPh
	mov edx, len_msgNumPh
	call printMsg
	
	; print field
	; init input to proc
	
	xor eax, eax
	mov ax, word [sElfHeader + e_phnum]
	
	; print decimal value
	call printDec
	
	ret

; ----------------------------------------------
; print e_shentsize
print_elf_hdf_e_shentsize:
	; in e_shentsize field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgSizeSh
	mov edx, len_msgSizeSh
	call printMsg
	
	; print field
	; init input to proc
	
	xor eax, eax
	mov ax, word [sElfHeader + e_shentsize]
	
	; print decimal value
	call printDec
	call printByte
	
	ret

; ----------------------------------------------
; print e_shnum
print_elf_hdf_e_shnum:
	; in e_shnum field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgNumSh
	mov edx, len_msgNumSh
	call printMsg
	
	; print field
	; init input to proc
	
	xor eax, eax
	mov ax, word [sElfHeader + e_shnum]
	
	; print decimal value
	call printDec
	
	ret

; ----------------------------------------------
; print e_shstrndx
print_elf_hdf_e_shstrndx:
	; in e_phnum field
	call printEnter
	call printSpaceX2
	
	; print name field
	mov ecx, msgShStrIndex
	mov edx, len_msgShStrIndex
	call printMsg
	
	; print field
	; init input to proc
	
	xor eax, eax
	mov ax, word [sElfHeader + e_shstrndx]
	
	; print decimal value
	call printDec
	
	ret




	
; ----------------------------------------------
; e_ident => magic
fe_ident:
	mov eax, data + 0x00
	mov ebx, eax
	add ebx, 15													; size = 16
	
	mov esi, sElfHeader + e_ident
	call getFieldData
	
	; get OS type x86/64 => store OSclass
	xor eax, eax
	mov al, byte [sElfHeader + e_ident + 4]	
	mov byte[OSclass], al										; store type of OS
	
	ret


; ----------------------------------------------
; e_type
fe_type:
	mov eax, data + 0x10
	mov ebx, eax
	add ebx, 1													; size = 2
	
	mov esi, sElfHeader + e_type
	call getFieldData
		
	ret

; ----------------------------------------------
; e_machine
fe_machine:
	mov eax, data + 0x12
	mov ebx, eax
	add ebx, 1
	
	mov esi, sElfHeader + e_machine
	call getFieldData
		
	ret

; ----------------------------------------------
; e_version	
fe_version:
	mov eax, data + 0x14
	mov ebx, eax
	add ebx, 3												; size = 4
	
	mov esi, sElfHeader + e_version
	call getFieldData
	

	ret


; ----------------------------------------------
; e_entry32	
fe_entry32:
	mov eax, data + 0x18
	mov ebx, eax
	add ebx, 3												; size = 4
	
	mov esi, sElfHeader + e_entry
	call getFieldData
		
	ret
	
; ----------------------------------------------
; e_entry64	
fe_entry64:
	mov eax, data + 0x18
	mov ebx, eax
	add ebx, 7												; size = 8
	
	mov esi, sElfHeader + e_entry
	call getFieldData
	
	ret	
	

; ----------------------------------------------
; e_phoff32	
fe_phoff32:
	mov eax, data + 0x1C
	mov ebx, eax
	add ebx, 3												; size = 4
	
	mov esi, sElfHeader + e_phoff
	call getFieldData
		
	ret


; ----------------------------------------------
; e_phoff64	
fe_phoff64:
	mov eax, data + 0x20
	mov ebx, eax
	add ebx, 7												; size = 8
	
	mov esi, sElfHeader + e_phoff
	call getFieldData
		
	ret

; ----------------------------------------------
; e_shoff32	
fe_shoff32:
	mov eax, data + 0x20
	mov ebx, eax
	add ebx, 3												; size = 4
	
	mov esi, sElfHeader + e_shoff
	call getFieldData
	
	ret


; ----------------------------------------------
; e_shoff64	
fe_shoff64:
	mov eax, data + 0x28
	mov ebx, eax
	add ebx, 7												; size = 8
	
	mov esi, sElfHeader + e_shoff
	call getFieldData
	
	ret
	
	
; ----------------------------------------------
; e_flags32	
fe_flags32:
	mov eax, data + 0x24
	mov ebx, eax
	add ebx, 3												; size = 4
	
	mov esi, sElfHeader + e_flags
	call getFieldData
	
	ret	
	
	
; ----------------------------------------------
; e_flags64	
fe_flags64:
	mov eax, data + 0x30
	mov ebx, eax
	add ebx, 3												; size = 4
	
	mov esi, sElfHeader + e_flags
	call getFieldData
	
	ret	
		

; ----------------------------------------------
; e_ehsize	
fe_ehsize32:
	mov eax, data + 0x28
	mov ebx, eax
	add ebx, 1												; size = 2
	
	mov esi, sElfHeader + e_ehsize
	call getFieldData
	
	ret	
	
; ----------------------------------------------
; e_ehsize	
fe_ehsize64:
	mov eax, data + 0x34
	mov ebx, eax
	add ebx, 1												; size = 2
	
	mov esi, sElfHeader + e_ehsize
	call getFieldData

	ret	
		
	
; ----------------------------------------------
; e_phentsize	
fe_phentsize32:
	mov eax, data + 0x2A
	mov ebx, eax
	add ebx, 1												; size = 2
	
	mov esi, sElfHeader + e_phentsize
	call getFieldData
	
	ret	
		
; ----------------------------------------------
; e_phentsize	
fe_phentsize64:
	mov eax, data + 0x36
	mov ebx, eax
	add ebx, 1												; size = 2
	
	mov esi, sElfHeader + e_phentsize
	call getFieldData
	
	ret	

; ----------------------------------------------
; e_phnum	
fe_phnum32:
	mov eax, data + 0x2C
	mov ebx, eax
	add ebx, 1												; size = 2
	
	mov esi, sElfHeader + e_phnum
	call getFieldData

	ret		
	
; ----------------------------------------------
; e_phnum	
fe_phnum64:
	mov eax, data + 0x38
	mov ebx, eax
	add ebx, 1												; size = 2
	
	mov esi, sElfHeader + e_phnum
	call getFieldData
	
	ret			
	
	
; ----------------------------------------------
; e_shentsize	
fe_shentsize32:
	mov eax, data + 0x2E
	mov ebx, eax
	add ebx, 1												; size = 2
	
	mov esi, sElfHeader + e_shentsize
	call getFieldData

	
	ret			
	
	
; ----------------------------------------------
; e_shentsize	
fe_shentsize64:
	mov eax, data + 0x3A
	mov ebx, eax
	add ebx, 1												; size = 2
	
	mov esi, sElfHeader + e_shentsize
	call getFieldData
	
	ret			
	
	
; ----------------------------------------------
; e_shnum	
fe_shnum32:
	mov eax, data + 0x30
	mov ebx, eax
	add ebx, 1												; size = 2
	
	mov esi, sElfHeader + e_shnum
	call getFieldData
	
	
	ret			
	
; ----------------------------------------------
; e_shnum	
fe_shnum64:
	mov eax, data + 0x3C
	mov ebx, eax
	add ebx, 1												; size = 2
	
	mov esi, sElfHeader + e_shnum
	call getFieldData
		
	ret		
	

; ----------------------------------------------
; e_shstrndx	
fe_shstrndx32:
	mov eax, data + 0x32
	mov ebx, eax
	add ebx, 1												; size = 2
	
	mov esi, sElfHeader + e_shstrndx
	call getFieldData
	
	
	ret	



; ----------------------------------------------
; e_shstrndx	
fe_shstrndx64:
	mov eax, data + 0x3E
	mov ebx, eax
	add ebx, 1												; size = 2
	
	mov esi, sElfHeader + e_shstrndx
	call getFieldData
	
	
	ret	
	
	
; ----------------------------------------------
; print field data; format hex
printFieldData:
	; input. eax: point to field; ebx: point to the end of field
	mov ebp, eax
	
	@printFieldData:
		mov al, byte [ebp]
		push ebx
		
		call bin2hex
		call printHex
		call printSpace
		
		pop ebx
		
		cmp ebp, ebx
		je @done_printFieldData
		
		inc ebp
		jmp @printFieldData
	
	@done_printFieldData:
		ret

; ----------------------------------------------
; get data to field with offset start and end
getFieldData:
	; input. eax: offset start; ebx: offset end + 1; esi: point to field
	@getFieldData:
		mov cl, byte [eax]
		mov byte [esi], cl
		
		cmp eax, ebx
		je @done_getFileData
		
		inc eax
		inc esi
		jmp @getFieldData
		
	@done_getFileData:
		
		ret


; ----------------------------------------------
; check elf file format
; ----------------------------------------------
check_elf:
	; input: data; output: elf_checker => 1: elf, 0: err
	cmp byte[data], 7fh									; DEL
	jne @err_elf
	cmp byte[data + 1], 45h								; 'E' character
	jne @err_elf
	cmp byte[data + 2], 4ch								; 'L' character
	jne @err_elf
	cmp byte[data + 3], 46h								; 'F' character
	je @success_elf
	
	@err_elf:
		mov byte [elf_checker], 0
		; print elf file err
		mov eax, 4
		mov ebx, 1
		mov ecx, msgElfFileErr
		mov edx, len_msgElfFileErr
		int 0x80
		
		ret
		
	@success_elf:
		mov byte [elf_checker], 1
		ret


; ----------------------------------------------
; input: enter file link, clean file link, read data file
; ----------------------------------------------
input:
	; read file link
	call read_file_name
	; clean file_name
	mov eax, file_name
	call clean_str
	; read data
	call read_file
	
	ret


; ----------------------------------------------
; read file link (name)
read_file_name:
	mov eax, 4
	mov ebx, 1
	mov ecx, msgIn
	mov edx, len_msgIn
	int 0x80
	
	
	mov eax, 3
	mov ebx, 2
	mov ecx, file_name
	mov edx, nameMaxSize
	int 0x80
	
	ret	


; ----------------------------------------------
; clean file name -> remove enter char at the end of string
clean_str:
	; in: eax -> str
	mov eax, file_name
	@clean:
		cmp byte [eax], 0
		je @done_clean
		
		cmp byte [eax], 0ah
		jne @next_clean
		
		mov byte [eax], 0x0
		jmp @done_clean

	@next_clean:
		inc eax
		jmp @clean
		
	@done_clean:
		ret


; ----------------------------------------------
; read data from file -> elf header
read_file:
	; open file
	mov eax, 5
	mov ebx, file_name
	mov ecx, 0
	mov edx, 0777
	int 0x80
	
	mov [fd_in], eax
	
	; read data from file
	mov eax, 3
	mov ebx, [fd_in]
	mov ecx, data
	mov edx, fileMaxSize
	int 0x80
	
	; close file
	mov eax, 6
	mov ebx, [fd_in]
	int 0x80
	
	ret
	
; ----------------------------------------------
; print readed data from file -> test 
; ----------------------------------------------
print_data:
	; print data => test
	mov eax, 4
	mov ebx, 1
	mov ecx, data
	mov edx, 1024
	int 0x80
	
	ret
	
	

; ----------------------------------------------
; binary to hex
; 4 bit => 1 hex => 1 char = 8 bit 
; ----------------------------------------------
bin2hex:
	; input: al => 8 bit binary
	; output: esi point to hex string => strHex : 16 bit
	; ------------------------------------------
	
	mov esi, strHex
	
	; first 4 highest bit
	mov bl, al											; bl = xxxxyyyyb
	shr bl, 4											; bl = 0000xxxxb
	call toHex
	mov byte [esi], bl
	
	inc esi												; next byte strHex
	; last 4 lowest bit
	mov bl, al
	shl bl, 4
	shr bl, 4
	call toHex
	mov byte [esi], bl
	
	ret

; ----------------------------------------------
; binary to hex
toHex:
	; input: bl => 4x0 + 4bit binary number (0000xxxxb)
	; output: bl => 8bit hex char
	; check hex number >= 0, <= 15
	cmp bl, 0
	jl @errNum
	cmp bl, 15
	jg @errNum
	
	; convert to hex character
	cmp bl, 9										; not necessary 'cause the flag don't change
	jg @toHexChar 
	
	@toHexNum:
		add bl, 48									; num char ascii
		jmp @done_toHex
		
	@toHexChar:
		add bl, 87									; 97: a (10: A)
		jmp @done_toHex

	@errNum:
		ret
		
	@done_toHex:
		ret


; ----------------------------------------------
; print hex number
printHex:

	; input: strHex (defaut)
	mov eax, 4
	mov ebx, 1
	mov ecx, strHex
	mov edx, 2
	int 0x80

	ret
	
; ----------------------------------------------
; print enter
printEnter:
	; input: cEnter (defaut)
	mov eax, 4
	mov ebx, 1
	mov ecx, cEnter
	mov edx, len_cEnter
	int 0x80
	
	ret
	
	
; ----------------------------------------------
; print space
printSpace:
	; input: cSpace (defaut)
	mov eax, 4
	mov ebx, 1
	mov ecx, cSpace
	mov edx, len_cSpace
	int 0x80
	
	ret

; ----------------------------------------------
; print space x 2
printSpaceX2:

	; input: cSpaceX2 (defaut)
	mov eax, 4
	mov ebx, 1
	mov ecx, cSpaceX2
	mov edx, len_cSpaceX2
	int 0x80
	
	ret	

; ----------------------------------------------
; print 0x
print0x:

	; input: c0x (defaut)
	mov eax, 4
	mov ebx, 1
	mov ecx, c0x
	mov edx, len_c0x
	int 0x80
	
	ret	

; ----------------------------------------------
; print bytes
printByte:

	; input: cByte (defaut)
	mov eax, 4
	mov ebx, 1
	mov ecx, cByte
	mov edx, len_cByte
	int 0x80
	
	ret	

; ----------------------------------------------
; print bytes into file
printStrByte:

	; input: strByte (defaut)
	mov eax, 4
	mov ebx, 1
	mov ecx, strByte
	mov edx, len_strByte
	int 0x80
	
	ret	

	
; ----------------------------------------------
; print message
printMsg:
	
	; input: cSpace (defaut)
	mov eax, 4
	mov ebx, 1
	int 0x80
	
	
	ret
	
; ----------------------------------------------
; reverse string: little endian data => big endian data
reverseStr:
	; input: eax point to the begin, ebx point to the end
	
	@reverse:
		cmp eax, ebx
		jge @done_reverseStr
		
		mov cl, byte [eax]
		xchg cl, byte [ebx]
		mov byte [eax], cl
	
		inc eax
		dec ebx
		jmp @reverse
		
	@done_reverseStr:
		ret
		


; ----------------------------------------------
; bin to decimal
bin2dec:
	; input: eax store value
	; output: esi point to the begin of decimal string number
	mov esi, strDec + 10
	mov ebx, 10
	
	@toDec:
		div ebx
		
		
		
		
	@done_bin2hec:
		ret
	
; ----------------------------------------------
; print decimal strDec
printDec:
   ; In: eax - value number
   ; esi point to strDec
   mov esi, strDec + numMaxSize
   mov ebx, 10			; for the div
   
@toStr:	
	dec esi									; next char
	xor edx, edx							; rezo edx for the div
	div ebx									; [edx]eax / ebx
	or edx, 30h								; add 0x30 ('0' char) to edx (or faster)
	mov byte [esi], dl						; move the dl (store 8 bit (1 byte) of the current digit - a part of edx) to ..
	or eax, eax								; check the eax is rezo?
	jnz @toStr								; eax is not rezo 

@cleanStrDec:
	cmp esi, strDec
	je @printDec
	dec esi
	cmp byte [esi], 0
	je @printDec
	mov byte [esi], 0
	jmp @cleanStrDec

@printDec:
	mov eax, 4
	mov ebx, 1
	mov ecx, strDec
	mov edx, numMaxSize
	int 0x80			
	ret
   	

; ----------------------------------------------
; print address hex	
printAddr:
	; input. eax: point to field; ebx: point to the end of field
	mov ebp, eax
	
	@deleterezo:
		cmp ebx, ebp
		je @printAddr
		
		mov al, byte [ebx]
		cmp al, 0
		jne @printAddr
		dec ebx
		jmp @deleterezo
	
	@printAddr:
		mov al, byte [ebx]
		push ebx
		
		call bin2hex
		call printHex
		
		pop ebx
		
		cmp ebp, ebx
		je @done_printAddr
		
		dec ebx
		jmp @printAddr
	
	@done_printAddr:
		ret
