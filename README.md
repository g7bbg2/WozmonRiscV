# WozmonRiscV
Wozmon ported to  CH32V003 in RiscV assembler<br><br>

Coded in raw CH32v Risc assembly language this is a port of
Wozmon.asm as found on the Web<br><

Uses riscv64-unknown-elf tools and minichlink from ch32vfun by Cnlohr<br>
... and WCH LINK programmer<br>
<b>RAM usage:</b><br>
<ul>
<li>0x20000700-0x2000077f input buffer</li>
<li>0x20000780-0x200007ff stack</li>
</ul>
<b>Register usage:</b><br>
<ul><br>
<li>a0=General purpose and used as a paramter for ECHO and p2hex</li>
<li>a1=genral pupose and for comparison</li>
<li>a5=Usart base address for ECHO</li>
<li>tp=Buffer text pointer</li>
<li>t0=L and H the accumulator for hex numbers</li>
<li>t1=TSL STH the address used as a store destination</li>
<li>t2=XAMH XAML the Examine ptr</li>
<li>s0=Mode this is null .'. or ':' used for deciding whar to do :-</li>
<li>s1=YSAV the text pointer is saved here to flag whether any hex digts have been collected</li>
</ul><br>

<b> Console is on internal USART 8,N,1 at 115200 baud<br>
Assumes terminal echoes a line feed on reception of a carriage return</b><br><br>
<b>Files:</b><br>
<ul>
<li><b>WozMonRiscV.S</b> assembler source code</li>
<li><b>a.sh</b> is a shell script to build without flashing</li>
<li><b>b.sh</b> is a shell script to build and flash to a CH32V003 uses minichlink</li>
<li><b>ch32v003.ld</b> is the script for the loader</li>
</ul>
