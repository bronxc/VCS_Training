- ASProtect 1.2x - 1.3x [Registered] - Find OEP and hide Olly (by ~Hellsp@wN~, 01 Dec 2004)
// Script for OllyScript plugin by SHaG - http://ollyscript.apsvans.com
/*
//////////////////////////////////////////////////
Author : ~Hellsp@wN~
Email : alt-fox@mail.ru
OS : OllyDbg 1.10 with OllyScript plugin v0.92
Date : 02.12.2004
Version: 1.0

1) Find OEP
2) Hide Olly !

Support with:
ASProtect 1.2x - 1.3x [Registered]
//////////////////////////////////////////////////
*/

var cbase
var csize
var eip_
var check

gmi eip, CODEBASE
mov cbase, $RESULT
log cbase
gmi eip, CODESIZE
mov csize, $RESULT
log csize

eob lab1
esto

lab1:
mov check,0
sto
log "Find anti Debugger call:"
trace:
inc check
log check
cmp check,20
je error
sto
mov eip_,[eip]
log eip_
cmp eip_,C084D0FF
jne trace
cmt eip,"[ IsDebuggerPresent ]"
log "call eax is found"
FIND eip,#74#
cmp $RESULT,0
je error
eob lab3
log $RESULT
bp $RESULT
esto

lab3:
log "Change flag !ZF"
mov !ZF,1
sto
bc $RESULT
eob lab4
esto

lab4:
cmt eip,"[ Anti Olly ]"
mov eip_,[eip]
log eip_
cmp eip_,00F88090
jne error
sto
sto
log "Change flag !ZF"
mov !ZF,1
eob end1
esto

end1:
bprm cbase, csize
eob end
eoe end
esto

end:
cmt eip," [ OEP ]"
bpmc
ret

error:
log "Not found"
MSG "Error"
ret




// [BACK] 