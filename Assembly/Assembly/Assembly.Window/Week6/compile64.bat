@echo off

set "projectName=%~1"

REM echo argument: %projectName%

\masm32\bin64\ml64 /Cp /c /I "\masm32\include64" %projectName%.asm
\masm32\bin64\Link /subsystem:console /LIBPATH:"\masm32\lib64" /entry:main %projectName%.obj
%projectName%.exe