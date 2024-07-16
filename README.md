# WozmonRiscV
Wozmon ported to  CH32V003 in RiscV assembler<br><br>

Coded in raw CH32v Risc assembly language this is a port of
Wozmon.asm as found on the Web<br><br><br>

Uses riscv64-unknown-elf tools and minichlink from ch32vfun by Cnlohr<br>
... and WCH LINK programmer<br><br>
Register usage as follows:<br>
a0=Genral pupose and used as a paramter for ECHO and p2hex<br>
a1=genral pupose and for comparison<br>
a5=Usart base address for ECHO<br>
tp=Buffer text pointer<br>
t0=L and H the accumulator for hex numbers<br>
t1=TSL STH the address used as a store destination<br>
t2=XAMH XAML the Examine ptr<br>
s0=Mode this is null .'. or ':' used for deciding whar to do :-<br>
s1=YSAV the text pointer is saved here to flag whether any hex digts have been collected<br><br>

<b>WozMonRiscV.S assembler source code</b><br>
<b>.sh is a shell script to build without flashing</b><br>
<b>b.sh is a shell script to build and flash to a CH32V003 uses minichlink</b><br>
<b>ch32v003.ld is the script for the loader</b>
