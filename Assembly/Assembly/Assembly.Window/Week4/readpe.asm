.386
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\msvcrt.inc
include \masm32\include\comdlg32.inc
includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\comdlg32.lib

extrn printf :near
extrn system :near

SIZEOF_NT_SIGNATURE equ sizeof DWORD
SIZEOF_IMAGE_FILE_HEADER equ 14h



; **********************************************
; variable
; **********************************************
.data
	; ----------------------------------------------
	; message string
	; ----------------------------------------------
	msgIn db "enter file link: ", 0
	ErrorMsg db 0ah, 0dh, "[-] Error while extracting PE information!", 0
	MappedOk db 0ah, 0dh, "[+] The file is mapped in memory!", 0ah, 0dh, 0ah, 0dh, 0
	DOSHeader db "[!] DOS Header", 0ah, 0dh, 0ah, 0dh, 0
	PEHeader db 0ah, 0dh, 0ah, 0dh, "[!] PE Header", 0ah, 0dh, 0ah, 0dh, 0
	OptHeader db 0ah, 0dh, 0ah, 0dh, "[!] Optional Header", 0ah, 0dh, 0ah, 0dh, 0
	DataDir db 0ah, 0dh, 0ah, 0dh, "[!] Data Directories", 0ah, 0dh, 0ah, 0dh, 0
	Sections db 0ah, 0dh, 0ah, 0dh, "[!] Sections", 0
	Imports db 0ah, 0dh, 0ah, 0dh, "[!] Imports", 0
	Exports db 0ah, 0dh, 0ah, 0dh, 0ah, 0dh, "[!] Exports", 0ah, 0dh, 0ah, 0dh, 0
	Resources db 0ah, 0dh, 0ah, 0dh, "[!] Resources", 0ah, 0dh, 0ah, 0dh, 0
	sectionless db 0ah, 0dh, 09h, "[-] Sectionless PE", 0ah, 0dh, 0
	no_exports db 09h, "[-] No exports table found", 0
	cmd db "pause > NUL", 0
	Format db "%x", 0											; format hex 


	; ----------------------------------------------
	; DOS Header
	; ----------------------------------------------
	e_magic_str db 09h, "e_magic: 0x", 0
	e_lfanew_str db	0ah, 0dh, 09h, "e_lfanew: 0x", 0

	; ----------------------------------------------
	; PE Header
	; ----------------------------------------------
	signature_str db 09h, "signature: 0x", 0
	machine_str db 0ah, 0dh, 09h, "machine: 0x", 0
	numberOfSections_str db	0ah, 0dh, 09h, "numberOfSections: 0x", 0
	sizeOfOptionalHeader_str db	0ah, 0dh, 09h, "sizeOfOptionalHeader: 0x", 0
	characteristics_str db 0ah, 0dh, 09h, "characteristics: 0x", 0

	; ----------------------------------------------
	; Optional Header
	; ----------------------------------------------
	magic_str db 09h, "magic: ", 0
	addressOfEntryPoint_str db 0ah, 0dh, 09h, "addressOfEntryPoint: 0x", 0
	imageBase_str db 0ah, 0dh, 09h, "imageBase: 0x", 0
	sectionAlignment_str db 0ah, 0dh, 09h, "sectionAlignment: 0x", 0
	fileAlignment_str db 0ah, 0dh, 09h, "fileAlignment: 0x", 0
	majorSubsystemVersion_str db 0ah, 0dh, 09h, "majorSubsystemVersion: 0x", 0
	sizeOfImage_str db 0ah, 0dh, 09h, "sizeOfImage: 0x", 0
	sizeOfHeaders_str db 0ah, 0dh, 09h, "sizeOfHeaders: 0x", 0
	subsystem_str db 0ah, 0dh, 09h, "subsystem: 0x", 0
	numberOfRvaAndSizes_str db 0ah, 0dh, 09h, "numberOfRvaAndSizes: 0x", 0


	; ----------------------------------------------
	; Data Directories
	; ----------------------------------------------
	ex_dir_rva db 09h, "export directory RVA: 0x", 0
	ex_dir_size db 0ah, 0dh, 09h, "export directory size: 0x", 0
	imp_dir_rva db 0ah, 0dh, 09h, "import directory RVA: 0x", 0
	imp_dir_size db 0ah, 0dh, 09h, "import directory size: 0x", 0
	res_dir_rva db 0ah, 0dh, 09h, "resource directory RVA: 0x", 0
	res_dir_size db 0ah, 0dh, 09h, "resource directory size: 0x", 0
	exc_dir_rva db 0ah, 0dh, 09h, "exception directory RVA: 0x", 0
	exc_dir_size db 0ah, 0dh, 09h, "exception directory size: 0x", 0
	sec_dir_rva db 0ah, 0dh, 09h, "security directory RVA: 0x", 0
	sec_dir_size db 0ah, 0dh, 09h, "security directory size: 0x", 0
	rel_dir_rva db 0ah, 0dh, 09h, "relocation directory RVA: 0x", 0
	rel_dir_size db 0ah, 0dh, 09h, "relocation directory size: 0x", 0
	debug_dir_rva db 0ah, 0dh, 09h, "debug directory RVA: 0x", 0
	debug_dir_size db 0ah, 0dh, 09h, "debug directory size: 0x", 0
	arch_dir_rva db 0ah, 0dh, 09h, "architecture directory RVA: 0x", 0
	arch_dir_size db 0ah, 0dh, 09h, "architecture directory size: 0x", 0
	reserved_dir_rva db 0ah, 0dh, 09h, "reserved directory RVA: 0x", 0
	reserved_dir_size db 0ah, 0dh, 09h, "reserved directory size: 0x", 0
	TLS_dir_rva db 0ah, 0dh, 09h, "TLS directory RVA: 0x", 0
	TLS_dir_size db 0ah, 0dh, 09h, "TLS directory size: 0x", 0
	conf_dir_rva db 0ah, 0dh, 09h, "configuration directory RVA: 0x", 0
	conf_dir_size db 0ah, 0dh, 09h, "configuration directory size: 0x", 0
	bound_dir_rva db 0ah, 0dh, 09h, "bound import directory RVA: 0x", 0
	bound_dir_size db 0ah, 0dh, 09h, "bound import directory size: 0x", 0
	IAT_dir_rva db 0ah, 0dh, 09h, "IAT directory RVA: 0x", 0
	IAT_dir_size db 0ah, 0dh, 09h, "IAT directory size: 0x", 0
	delay_dir_rva db 0ah, 0dh, 09h, "delay directory RVA: 0x", 0
	delay_dir_size db 0ah, 0dh, 09h, "delay directory size: 0x", 0
	NET_dir_rva db 0ah, 0dh, 09h, ".NET directory RVA: 0x", 0
	NET_dir_size db 0ah, 0dh, 09h, ".NET directory size: 0x", 0


	; ----------------------------------------------
	; Section Headers
	; ----------------------------------------------
	sec_name db	0ah, 0dh, 0ah, 0dh, 09h, "name: ", 0
	virt_size db 0ah, 0dh, 09h, "virtual size: 0x", 0
	virt_address db 0ah, 0dh, 09h, "virtual address: 0x", 0
	raw_size db	0ah, 0dh, 09h, "raw size: 0x", 0
	raw_address	db 0ah, 0dh, 09h, "raw address: 0x", 0
	reloc_address db 0ah, 0dh, 09h, "relocation address: 0x", 0
	linenumbers db 0ah, 0dh, 09h, "linenumbers: 0x", 0
	reloc_number db 0ah, 0dh, 09h, "relocations number: 0x", 0
	linenumbers_number db 0ah, 0dh, 09h, "linenumbers number: 0x", 0
	characteristics db 0ah, 0dh, 09h, "characteristics: 0x", 0

	; ----------------------------------------------
	; Imports
	; ----------------------------------------------
	dll_name db 0ah, 0dh, 0ah, 0dh, 09h, "DLL name: ", 0
	functions_list db 0ah, 0dh, 0ah, 0dh, 09h, "Functions list: ", 0ah, 0dh, 0
	hint db 0ah, 0dh, 09h, 09h, "Hint: 0x", 0
	function_name db 09h, "Name: ", 0

	; ----------------------------------------------
	; Exports
	; ----------------------------------------------
	numberOfFunctions db 0ah, 0dh, 09h, "NumberOfFunctions: 0x", 0
	nName db 09h, "nName: ", 0
	nBase db 0ah, 0dh, 09h, "nBase: 0x", 0
	numberOfNames db 0ah, 0dh, 09h, "numberOfNames: 0x", 0
	exportedFunctions db 0ah, 0dh, 09h, "Function list:", 0ah, 0dh, 0
	RVA	db 0ah, 0dh, 09h, "RVA: 0x", 0
	ordinal	db 09h, "Ordinal: 0x", 0
	funcName db	09h, "Name: ", 0

	; ----------------------------------------------
	; Resources
	; ----------------------------------------------
	resource_name db 09h, "resource name: ", 0



; **********************************************
; ultilize data	
; **********************************************	
.data?
; ----------------------------------------------
; DOS Header
	e_lfanew dd ?

; ----------------------------------------------
; Optional Header
	addr_opt_header dd ?

; ----------------------------------------------
; Handlers
	hConsoleIn dd ?
	hConsoleOut dd ?
	hFile dd ?
	hMap dd ?
	pMapping dd ?
	bytesWritten dd ?
	sections_count dd ?
	sizeOfOptionalHeader dd ?
	fileName db 512 dup (?)

; ----------------------------------------------
; Import
	sectionHeaderOffset dd ?
	importsRVA dd ?

; ----------------------------------------------
; Export Table
	exportsRVA dd ?
	exportedNamesOffset	dd ?
	exportedFunctionsOffset	dd ?
	exportedOrdinalsOffset dd ?
	numberOfNamesValue dd ?
	nBaseValue dd ?



; **********************************************
; code
; **********************************************	
.code
main:
	
	; ----------------------------------------------
	; Input - Init
	; ----------------------------------------------
	; Getting standard console I/O
	; invoke GetStdHandle, STD_INPUT_HANDLE
	push STD_INPUT_HANDLE
	call GetStdHandle
	mov hConsoleIn, eax
	
	; invoke GetStdHandle, STD_OUTPUT_HANDLE
	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov hConsoleOut, eax
	
	
	; print msgIn message
	push offset msgIn
	call print
	
	; read fileName - max 512 byte
	; invoke ReadConsole, hConsoleIn, addr fileName, 512, addr bytesWritten, 0
	push 0
	push offset bytesWritten
	push 512
	push offset fileName
	push hConsoleIn
	call ReadConsole
	
	; clean sting input //0xD, 0xA (13, 10) = carriage return
	mov eax, offset fileName
	add eax, bytesWritten
	sub eax, 2
	mov byte ptr [eax], 0
	
	; push offset fileName
	; call print
	
	; loading the file
	; invoke CreateFile, addr fileName, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	push 0
	push FILE_ATTRIBUTE_NORMAL
	push OPEN_EXISTING
	push 0
	push FILE_SHARE_READ
	push GENERIC_READ
	push offset fileName
	
	call CreateFile
	mov hFile, eax
	
	; Check if the file handle is valid
	cmp eax, INVALID_HANDLE_VALUE
	je errorExit
	
	; invoke CreateFileMapping, hFile, 0, PAGE_READONLY, 0, 0, 0
	push 0
	push 0
	push 0
	push PAGE_READONLY
	push 0
	push hFile
	
	call CreateFileMapping
	mov hMap, eax
	
	; Check if the map handle is valid
	cmp eax, INVALID_HANDLE_VALUE
	je errorExit
	
	; invoke MapViewOfFile, hMap, FILE_MAP_READ, 0, 0, 0
	push 0
	push 0
	push 0
	push FILE_MAP_READ
	push hMap
	
	call MapViewOfFile
	mov pMapping, eax
	
	;Check if the file is correctly mapped in memory
	cmp eax, 0
	je errorExit
	
	;File correctly mapped
	push offset MappedOk
	call print
	
; ***********************************************************************************************************
; ----------------------------------------------
; DOS header
; ----------------------------------------------
; ***********************************************************************************************************
	; get offset
	mov edi, pMapping
	assume edi: ptr IMAGE_DOS_HEADER
	
	; check if the file is a DOS file
	cmp [edi].e_magic, IMAGE_DOS_SIGNATURE
	jne errorExit
	
	; print
	; print DOSHeader
	push offset DOSHeader
	call print
	
	; print e_magic
	push offset e_magic_str
	call print
	movzx edx, [edi].e_magic
	call printHex
	
	; print e_lfanew
	push offset e_lfanew_str
	call print
	mov edx, [edi].e_lfanew
	call printHex

; ***********************************************************************************************************	
; ----------------------------------------------
; PE Header
; ----------------------------------------------
; ***********************************************************************************************************
	; check if the file is a PE file
	; get offset
	add edi, edx 												;address of the PE Header
	assume edi: ptr IMAGE_NT_HEADERS
	cmp [edi].Signature, IMAGE_NT_SIGNATURE
	jne errorExit
	
	; print PEHeader
	push offset PEHeader
	call print
	
	; print Signature
	push offset signature_str
	call print
	mov edx, [edi].Signature
	call printHex
	
	; get offset
	add edi, SIZEOF_NT_SIGNATURE
	assume edi: ptr IMAGE_FILE_HEADER
	
	; print Machine
	push offset machine_str
	call print
	movzx edx, [edi].Machine
	call printHex
	
	; print NumberOfSections
	push offset numberOfSections_str
	call print
	movzx edx, [edi].NumberOfSections
	push edx
	pop sections_count
	call printHex
	
	; print SizeOfOptionalHeader
	push offset sizeOfOptionalHeader_str
	call print
	movzx edx, [edi].SizeOfOptionalHeader
	push edx
	pop sizeOfOptionalHeader
	call printHex
	
	; print Characteristics
	push offset characteristics_str
	call print
	movzx edx, [edi].Characteristics
	call printHex
	

; ***********************************************************************************************************	
; ----------------------------------------------
; Optional header
; ----------------------------------------------
; ***********************************************************************************************************
	; get offset
	add edi, SIZEOF_IMAGE_FILE_HEADER
	assume edi: ptr IMAGE_OPTIONAL_HEADER
	
	; print OptHeader
	push offset OptHeader
	call print
	
	; print Magic
	push offset magic_str
	call print
	movzx edx, [edi].Magic
	call printHex
	
	; print AddressOfEntryPoint
	push offset addressOfEntryPoint_str
	call print
	mov edx, [edi].AddressOfEntryPoint
	call printHex
	
	; print ImageBase
	push offset imageBase_str
	call print
	mov edx, [edi].ImageBase
	call printHex
	
	; print SectionAlignment
	push offset sectionAlignment_str
	call print
	mov edx, [edi].SectionAlignment
	call printHex
	
	; print FileAlignment
	push offset fileAlignment_str
	call print
	mov edx, [edi].FileAlignment
	call printHex
	
	; print MajorSubsystemVersion
	push offset majorSubsystemVersion_str
	call print
	movzx edx, [edi].MajorSubsystemVersion
	call printHex
	
	; print SizeOfImage
	push offset sizeOfImage_str
	call print
	mov edx, [edi].SizeOfImage
	call printHex
	
	; print SizeOfHeaders
	push offset sizeOfHeaders_str
	call print
	mov edx, [edi].SizeOfHeaders
	call printHex
	
	; print Subsystem
	push offset subsystem_str
	call print
	movzx edx, [edi].Subsystem
	call printHex
	
	; print NumberOfRvaAndSizes
	push offset numberOfRvaAndSizes_str
	call print
	mov edx, [edi].NumberOfRvaAndSizes
	call printHex

; ***********************************************************************************************************	
; ----------------------------------------------
; Image data directory
; ----------------------------------------------
; ***********************************************************************************************************
	; check the number
	mov edx, sizeOfOptionalHeader
	sub edx, IMAGE_OPTIONAL_HEADER.NumberOfRvaAndSizes + 4
	cmp edx, 0
	je sections_start
	
	; print 
	add edi, 60h 												;address of the Image Data Directory Start
	
	
	; print DataDir
	push offset DataDir
	call print
	
	; print ex_dir_rva
	push offset ex_dir_rva
	call print
	mov edx, dword ptr [edi]
	mov exportsRVA, edx
	call printHex
	
	; print ex_dir_size
	push offset ex_dir_size
	call print
	
	mov edx, dword ptr [edi + 4h]
	call printHex
	
	; print imp_dir_rva
	push offset imp_dir_rva
	call print
	mov edx, dword ptr [edi + 8h]
	mov importsRVA, edx
	call printHex
	
	; print imp_dir_size
	push offset imp_dir_size
	call print
	mov edx, dword ptr [edi + 0Ch]
	call printHex
	
	; print res_dir_rva
	push offset res_dir_rva
	call print
	mov edx, dword ptr [edi + 10h]
	call printHex
	
	; print res_dir_size
	push offset res_dir_size
	call print
	mov edx, dword ptr [edi + 14h]
	call printHex
	
	; print exc_dir_rva
	push offset exc_dir_rva
	call print
	mov edx, dword ptr [edi + 18h]
	call printHex
	
	; print exc_dir_size
	push offset exc_dir_size
	call print
	mov edx, dword ptr [edi + 1Ch]
	call printHex
	
	; print sec_dir_rva
	push offset sec_dir_rva
	call print
	mov edx, dword ptr [edi + 20h]
	call printHex
	
	; print sec_dir_size
	push offset sec_dir_size
	call print
	mov edx, dword ptr [edi + 24h]
	call printHex
	
	; print rel_dir_rva
	push offset rel_dir_rva
	call print
	mov edx, dword ptr [edi + 28h]
	call printHex
	
	; print rel_dir_size
	push offset rel_dir_size
	call print
	mov edx, dword ptr [edi + 2Ch]
	call printHex
	
	; print debug_dir_rva
	push offset debug_dir_rva
	call print
	mov edx, dword ptr [edi + 30h]
	call printHex

	; print debug_dir_size
	push offset debug_dir_size
	call print
	mov edx, dword ptr [edi + 34h]
	call printHex
	
	; print arch_dir_rva
	push offset arch_dir_rva
	call print
	mov edx, dword ptr [edi + 38h]
	call printHex
	
	; print arch_dir_size
	push offset arch_dir_size
	call print
	mov edx, dword ptr [edi + 3Ch]
	call printHex
	
	; print reserved_dir_rva
	push offset reserved_dir_rva
	call print
	mov edx, dword ptr [edi + 40h]
	call printHex
	
	; print reserved_dir_size
	push offset reserved_dir_size
	call print
	mov edx, dword ptr [edi + 44h]
	call printHex
	
	; print TLS_dir_rva
	push offset TLS_dir_rva
	call print
	mov edx, dword ptr [edi + 48h]
	call printHex
	
	; print TLS_dir_size
	push offset TLS_dir_size
	call print
	mov edx, dword ptr [edi + 4Ch]
	call printHex
	
	; print conf_dir_rva
	push offset conf_dir_rva
	call print
	mov edx, dword ptr [edi + 50h]
	call printHex
	
	; print conf_dir_size
	push offset conf_dir_size
	call print
	mov edx, dword ptr [edi + 54h]
	call printHex
	
	; print bound_dir_rva
	push offset bound_dir_rva
	call print
	mov edx, dword ptr [edi + 58h]
	call printHex
	
	; print bound_dir_size
	push offset bound_dir_size
	call print
	mov edx, dword ptr [edi + 5Ch]
	call printHex
	
	; print IAT_dir_rva
	push offset IAT_dir_rva
	call print
	mov edx, dword ptr [edi + 60h]
	call printHex
	
	; print IAT_dir_size
	push offset IAT_dir_size
	call print
	mov edx, dword ptr [edi + 64h]
	call printHex
	
	; print delay_dir_rva
	push offset delay_dir_rva
	call print
	mov edx, dword ptr [edi + 68h]
	call printHex
	
	; print delay_dir_size
	push offset delay_dir_size
	call print
	mov edx, dword ptr [edi + 6Ch]
	call printHex
	
	; print NET_dir_rva
	push offset NET_dir_rva
	call print
	mov edx, dword ptr [edi + 70h]
	call printHex
	
	; print NET_dir_size
	push offset NET_dir_size
	call print
	mov edx, dword ptr [edi + 74h]
	call printHex
	

; ***********************************************************************************************************
; ----------------------------------------------
; Image data directory
; ----------------------------------------------
; ***********************************************************************************************************
	; offset
	sub edi, 60h
	sections_start:
		; offset
		add edi, sizeof IMAGE_OPTIONAL_HEADER
		assume edi: ptr IMAGE_SECTION_HEADER
		mov sectionHeaderOffset, edi
		
		; print Sections
		push offset Sections
		call print
		
		; print sectionless
		mov ebx, sections_count
		cmp ebx, 0
		jne sections
		push offset sectionless
		call print
		
		sections:
			cmp ebx, 0
			je imports
			sub ebx, 1
			
			; print sec_name
			push offset sec_name
			call print
			push edi
			call print
			
			; print virt_size
			push offset virt_size
			call print
			mov edx, dword ptr [edi + 8h]
			call printHex
			
			; print VirtualAddress
			push offset virt_address
			call print
			mov edx, [edi].VirtualAddress
			call printHex
			
			; print SizeOfRawData
			push offset raw_size
			call print
			mov edx, [edi].SizeOfRawData
			call printHex
			
			; print PointerToRawData
			push offset raw_address
			call print
			mov edx, [edi].PointerToRawData
			call printHex
			
			; print PointerToRelocations
			push offset reloc_address
			call print
			mov edx, [edi].PointerToRelocations
			call printHex
			
			; print PointerToLinenumbers
			push offset linenumbers
			call print
			mov edx, [edi].PointerToLinenumbers
			call printHex
			
			; print NumberOfRelocations
			push offset reloc_number
			call print
			movzx edx, [edi].NumberOfRelocations
			call printHex
			
			; print NumberOfLinenumbers
			push offset linenumbers_number
			call print
			movzx edx, [edi].NumberOfLinenumbers
			call printHex
			
			; print Characteristics
			push offset characteristics
			call print
			mov edx, [edi].Characteristics
			call printHex
			
			add edi, 28h
			jmp sections
	

; ***********************************************************************************************************
; ----------------------------------------------
; Imports
; ----------------------------------------------
; ***********************************************************************************************************
	imports:
		; print Imports
		push offset Imports
		call print
		
		; offset
		mov edi, importsRVA
		call RVAtoOffset
		mov edi, eax
		add edi, pMapping
		assume edi:ptr IMAGE_IMPORT_DESCRIPTOR
		
		next_import_DLL:
			cmp [edi].OriginalFirstThunk, 0
			jne extract_import
			
			cmp [edi].TimeDateStamp, 0
			jne extract_import
			
			cmp [edi].ForwarderChain, 0
			jne extract_import
			
			cmp [edi].Name1, 0
			jne extract_import
			
			cmp [edi].FirstThunk, 0
			jne extract_import
			
			jmp exports 										;no more imports to extract, go to exports
			
			; ----------------------------------------------
			; extract import
			extract_import:
				push edi
				mov edi, [edi].Name1
				call RVAtoOffset
				
				pop edi
				mov edx, eax
				add edx, pMapping
				
				; print dll_name
				push offset dll_name							;DLL Name
				call print
				push edx
				call print
				
				cmp [edi].OriginalFirstThunk, 0
				jne useOriginalFirstThunk
				
				mov esi, [edi].FirstThunk
				jmp useFirstThunk
				
				useOriginalFirstThunk:
					mov esi, [edi].OriginalFirstThunk
				
				useFirstThunk:
				push edi
				mov edi, esi
				call RVAtoOffset
				
				pop edi
				add eax, pMapping
				mov esi, eax
				
				; print function list
				push offset functions_list						;functions list
				call print
				
				; ----------------------------------------------
				; extract function
				extract_functions:
					cmp dword ptr [esi], 0
					je next_DLL
					
					test dword ptr [esi], IMAGE_ORDINAL_FLAG32
					jnz useOrdinal
					
					push edi
					mov edi, dword ptr [esi]
					call RVAtoOffset
					
					pop edi
					
					; offset
					mov edx, eax
					add edx, pMapping
					assume edx:ptr IMAGE_IMPORT_BY_NAME
					
					mov cx, [edx].Hint 							;point to the Hint
					movzx ecx, cx
					
					; print hint
					push offset hint
					call print
					push edx
					mov edx, ecx
					call printHex
					
					pop edx
					
					; print function name
					push offset function_name
					call print
					
					lea edx, [edx].Name1 ;point to the function Name
					push edx
					call print
					
					; loop
					jmp next_import
					
					useOrdinal:
						mov edx, dword ptr [esi]
						and edx, 0FFFFh
						call printHex
					
					next_import:
						add esi, 4
						jmp extract_functions
					
					next_DLL:
						add edi, sizeof IMAGE_IMPORT_DESCRIPTOR
						jmp next_import_DLL

	
; ***********************************************************************************************************	
; ----------------------------------------------
; Exports
; ----------------------------------------------
; ***********************************************************************************************************
	exports:
		; print export
		push offset Exports
		call print
		
		cmp exportsRVA, 0
		jne extract_exports
		
		; no export
		push offset no_exports
		call print
		jmp resources
		
		; ----------------------------------------------
		; extract export
		extract_exports:
			; offset
			mov edi, exportsRVA
			call RVAtoOffset
			mov edi, eax
			add edi, pMapping
			assume edi:ptr IMAGE_EXPORT_DIRECTORY
			
			; print nName
			push edi
			mov edi, [edi].nName
			call RVAtoOffset
			add eax, pMapping
			
			pop edi
			push offset nName
			call print
			push eax
			call print
			
			;print nBase
			push offset nBase
			call print
			mov edx, [edi].nBase
			mov nBaseValue, edx
			call printHex
			
			;print numberOfFunctions
			push offset numberOfFunctions
			call print
			mov edx, [edi].NumberOfFunctions
			call printHex
			
			; print NumberOfNames
			push offset numberOfNames
			call print
			mov edx, [edi].NumberOfNames
			mov numberOfNamesValue, edx
			call printHex
			
			;print exported functions
			push offset exportedFunctions
			call print
			
			;print check for ordinal exports
			mov edx, [edi].NumberOfFunctions
			cmp edx, [edi].NumberOfNames
			je noOrdinalExports
			
			;ordinal exports
			push edi
			mov edi, [edi].AddressOfNameOrdinals
			call RVAtoOffset
			
			add eax, pMapping
			mov exportedOrdinalsOffset, eax
			
			pop edi
			
			; ----------------------------------------------
			; no ordinal export
			noOrdinalExports:
				;AddressOfFunctions
				push edi
				mov edi, [edi].AddressOfFunctions
				call RVAtoOffset
				add eax, pMapping
				mov exportedFunctionsOffset, eax
				pop edi
				
				;AddressOfNames
				push edi
				mov edi, [edi].AddressOfNames
				call RVAtoOffset
				add eax, pMapping
				mov exportedNamesOffset, eax
				pop edi
				
				; ----------------------------------------------
				next_export:
					cmp numberOfNamesValue, 0
					jle resources
					
					mov eax, exportedOrdinalsOffset
					mov dx, [eax]
					movzx edx, dx 
					mov ecx, edx
					
					shl edx, 2
					add edx, exportedFunctionsOffset
					add ecx, nBaseValue
					
					; print RVA
					push offset RVA
					call print
					mov edx, dword ptr [edx]
					call printHex
					
					; print Ordinal
					push offset ordinal
					call print
					mov edx, ecx
					call printHex
					
					;print name
					push offset funcName
					call print
					
					mov edx, dword ptr exportedNamesOffset
					mov edi, dword ptr [edx]
					call RVAtoOffset
					
					add eax, pMapping
					push eax
					call print
					
					
					; next
					dec numberOfNamesValue
					add exportedNamesOffset, 4 					;point to the next name in the array
					add exportedOrdinalsOffset, 2
					jmp next_export
			

	
; ----------------------------------------------
; Resources
; ----------------------------------------------
	resources:
		; print resource
		push offset Resources
		call print
	
	
; ----------------------------------------------
; Closing handles, unmap the file and exit
; ----------------------------------------------	
	; invoke UnmapViewOfFile, pMapping
	push pMapping
	call UnmapViewOfFile
	
	; invoke CloseHandle, hFile
	push hFile
	call CloseHandle
	
	; invoke CloseHandle, hMap
	push hMap
	call CloseHandle
	
	; cmd
	push offset cmd
	call system
	
	; invoke ExitProcess, EXIT_SUCCESS
	push EXIT_SUCCESS
	call ExitProcess
	
	
; ----------------------------------------------
; Error Exit
; ----------------------------------------------
	errorExit:
		; invoke CloseHandle, hFile
		push hFile
		call CloseHandle
		
		; invoke CloseHandle, hMap
		push hMap
		call CloseHandle
		
		; print error msg
		push offset ErrorMsg
		call print
		
		; cmd
		push offset cmd
		call system
		
		; invoke ExitProcess, EXIT_FAILURE
		push EXIT_FAILURE
		call ExitProcess	

; ----------------------------------------------
; Print msg to console
; ----------------------------------------------
	; input: stack - string to write
	print proc
		pushad
		mov ebx, dword ptr [esp + 36]
		
		; invoke lstrlen, ebx
		push ebx
		call lstrlen
		
		; invoke WriteConsole, hConsoleOut, ebx, eax, addr bytesWritten, 0
		push 0
		push offset bytesWritten
		push eax
		push ebx
		push hConsoleOut
		call WriteConsole
		
		popad
		ret 4
	print endp
	
	
; ----------------------------------------------
; Print number to console
; format: hex number => 0x + 
; ----------------------------------------------	
	; Input - stack: edx - number value
	; number to write
	; length of the number
	printHex proc
		pushad
		push edx
		push offset Format
		call printf
		add esp, 8
		popad
		ret
	printHex endp	


; ----------------------------------------------
; Converts an RVA to an Offset
; ----------------------------------------------	
	; Input: the RVA is received into EDI, converted and the offset is put into EAX
	RVAtoOffset proc
		; offset
		mov edx, sectionHeaderOffset
		assume edx:ptr IMAGE_SECTION_HEADER
		
		; for the loop
		mov ecx, sections_count
		
		sections_cicle:
			cmp ecx, 0
			jle end_routine
			
			cmp edi, [edx].VirtualAddress
			jl next_section

			mov eax, [edx].VirtualAddress
			add eax, [edx].SizeOfRawData

			cmp edi, eax
			jge next_section

			mov eax, [edx].VirtualAddress
			sub edi, eax
			mov eax, [edx].PointerToRawData
			add eax, edi
			ret
	
		next_section:
			add edx, sizeof IMAGE_SECTION_HEADER
			dec ecx
		jmp sections_cicle
		
		end_routine:
			mov eax, edi
			ret
	
	RVAtoOffset endp

; ----------------------------------------------
; end main		
end main
