xx=$1
#set +x
filename=${xx%.*}
rm -f $filename.elf $filename.bin $filename.o $filename.lst
#~/Documents/ch32v003fun/minichlink/minichlink -u
riscv64-unknown-elf-as --gstabs -march-attr  -march=rv32ec -mabi=ilp32 -o $filename.o $filename.S -alms > $filename.lst
if test $? -ne 0
then
	echo "Errors during assembling"
	exit
fi
riscv64-unknown-elf-ld -T ch32v003.ld --oformat=elf32-littleriscv $filename.o -o $filename.elf
riscv64-unknown-elf-objcopy -O binary $filename.elf $filename.bin
riscv64-unknown-elf-objdump -S $filename.elf >$filename.txt
ls -al $filename*
riscv64-unknown-elf-size $filename.elf

#~/Documents/ch32v003funold/minichlink/minichlink -w $filename.bin -r -d


