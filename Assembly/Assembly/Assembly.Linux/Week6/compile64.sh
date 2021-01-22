projectName=$1
#echo "argument: $projectName"

nasm -felf64 $projectName.asm -o $projectName.o
gcc -o $projectName $projectName.o -no-pie

./$projectName