projectName=$1
#echo "argument: $projectName"

nasm -f elf $projectName.asm
ld -m elf_i386 -s -o $projectName $projectName.o
./$projectName