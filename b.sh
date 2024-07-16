xx=$1
#set +x
filename=${xx%.*}
rm -f $filename.elf $filename.bin $filename.o $filename.lst x.txt
~/Documents/ch32v003fun/minichlink/minichlink -u
riscv64-unknown-elf-as --gstabs -march-attr  -march=rv32ec -mabi=ilp32 -o $filename.o $filename.S -a > $filename.lst
if test $? -ne 0
then
	echo "Errors during assembling"
	exit
fi
riscv64-unknown-elf-ld -T ch32v003.ld --oformat=elf32-littleriscv $filename.o -o $filename.elf
if test $? -ne 0
then
	echo "Errors during loading"
	exit
fi
riscv64-unknown-elf-objcopy -O binary $filename.elf $filename.bin
if ! test -r ./$filename.bin
then
	echo "object copy failed"
	exit
fi
riscv64-unknown-elf-objdump -S $filename.elf >$filename.txt
ls -al $filename*
riscv64-unknown-elf-size $filename.elf
read -p "Press any key to continue ..."
~/Documents/ch32v003funold/minichlink/minichlink -w $filename.bin -d -r



