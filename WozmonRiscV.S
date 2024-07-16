
	.equ	Ram,0x20000000
	.equ	Ibuff,0x20000700

	.equ	RCC_BASE_ADDR,0x40021000
	.equ	RCC_APB2PCENR,0x18
	.equ	IOPDEN,1 << 5
	.equ	USARTEN,1 << 14
	.equ	InitRCC,IOPDEN | USARTEN
	.equ	GPIO_CFGLR,0
	.equ	GPIO_BSHR,0x10
		
	.equ	GPIOD_BASE_ADDR,0x40011400
	.equ	GPIO_CONFIG_PP_50MHZ,0b0011
	.equ	GPIO_CONFIG_PP_10MHZ,0b0001
	.equ	GPIO_CONFIG_MM,0b1000
	.equ	GPIO_CONFIG_FI,0b0100
	.equ	GPIOCLR,0b1111
	.equ	USART_TX,5
	.equ	USART_RX,6
	.equ	NRST,7
	.equ	InitGPIO,((GPIO_CONFIG_PP_10MHZ | GPIO_CONFIG_MM) << (USART_TX <<2)) | ( GPIO_CONFIG_FI << (USART_RX << 2)|(GPIO_CONFIG_FI <<(NRST <<2)))
	.equ	InitMask, ~((GPIOCLR << (USART_TX <<2)) | (GPIOCLR << (USART_RX <<2)) | (GPIOCLR << (NRST <<2)))
	
	
	.equ	USART_BASE,0x40013800
	.equ	USART_CTL0_UEN,1 << 13
	.equ	USART_CTL0_TEN,1 << 3
	.equ	USART_CTL0_REN,1 << 2
	.equ	USART_CTL0_OFFSET,0x0c
	.equ	USART_BAUD_OFFSET,8
	.equ	USART_STAT_OFFSET,0
	.equ	USART_DATA_OFFSET,4
	.equ	USART_STAT_TBE,1 << 6
	.equ	USART_STAT_RBNE,1 << 5
	.equ	baud_rate,115200
	.equ	SysClk,8000000
	.equ	USART_CLK,SysClk/baud_rate
	.equ	InitUSART,(USART_CTL0_TEN | USART_CTL0_REN)
	.macro	pchar	ch
	li	a0,\ch
	jal	ra,ECHO
	.endm
	
#
# a0=general character temp
# a1=used for comparison operations
# a5=USART base address
# tp=buffer/text ptr
# t0=LH for collection of hex numbers
# t1=STLH fo comparison STL/STH
# t2=XAMLH for adress usage
# s0=MODE
# s1=YSAV current text ptr save  area
#
#	.option	norvc
	.option	rvc
#	.include	"macros2.S"

	j	Reset

Reset:	la	gp,Ram			#+0x6c0
	la	sp,Ram+0x800		# enable RCU (GPIO port A)

	la	a5,RCC_BASE_ADDR
	la	a1,InitRCC		# enable GPIOD and USART
	sw	a1,RCC_APB2PCENR(a5)
	
	la	a5,GPIOD_BASE_ADDR	# init GPIO
	lw	a0,0(a5)
	la	a1,InitMask
	and	a0,a0,a1
	la	a1,InitGPIO		# enable TX, RX for USART
	or	a0,a0,a1
	sw	a1,GPIO_CFGLR(a5)

	la	a5,USART_BASE			# USART base address
	la	a1,InitUSART
	sw	a1,USART_CTL0_OFFSET(a5)	# enable USART RX and TX
	la	a1,USART_CLK
	sw	a1,USART_BAUD_OFFSET(a5)	# set baud rate
	lw	a1,USART_CTL0_OFFSET(a5)
	lui	a0,0x02				# enable USART
	or	a1,a1,a0
	sw	a1,USART_CTL0_OFFSET(a5)

	pchar	0x0d
	sb	a0,1(tp)
	la	tp,Ibuff-1
	li	a0,0


NotCR:	addi	a1,a0,-0x08		# Backspace?
	beq	a1,zero,BackSpace
	addi	a1,a0,-0x1b		# Escape?
	beq	a1,zero,Escape
	addi	tp,tp,1			# bump ptr
	la	a1,Ibuff+0x80		# end of buffer ?
	bne	a1,tp,NextChar		# nope carry on
Escape:	addi	a0,zero,'\\'		# prompt
	jal	ra,ECHO
GetLine:
	addi	a0,zero,0x0d		# C.R.	
	jal	ra,ECHO
	la	tp,Ibuff+1		# reset buffer ptr
BackSpace:
	addi	tp,tp,-1		# backup ptr
	la	a1,Ibuff		# a1-> start of buffer
	blt	tp,a1,GetLine		# empty? ....
NextChar:
	lw	a0,USART_STAT_OFFSET(a5)	# load status into a0
	andi	a0,a0,USART_STAT_RBNE		# isolate read buffer not empty (RBNE) bit
	beq	a0,zero,NextChar		# keep looping until ready to recv
	lbu	a0,USART_DATA_OFFSET(a5)	# load char into a0
	addi	a1,zero,'a'			# convert to upper case
	blt	a0,a1,toUpEx
	li	a1,'z'+1
	bge	a0,a1,toUpEx
	andi	a0,a0,0x5f
toUpEx:
	sb	a0,0(tp)		# save data
	addi	a1,a0,-0x1b
	beq	a1,zero,NotEsc
	jal	ra,ECHO			# display it
NotEsc:	addi	a1,a0,-0x0d		# was it CR?
	bne	a1,zero,NotCR		# no
	la	tp,Ibuff-1		# reset buffer ptr
	addi	a0,zero,0		# at this point set Mode=a0=0
SetStor:
SetMode:
	mv	s0,a0			# save (a0) to Mode (s0)
BlSkip:
	addi	tp,tp,1			# bump ptr
NextItem:
	lbu	a0,0(tp)		# get a byte from input buffer
	addi	a1,a0,-0x0d		# was it a CR?
	beq	a1,zero,GetLine		# yes parsing is done
	addi	a1,a0,-'.'		# < 0x2e
	blt	a1,zero,BlSkip		# yes treat as white space
	beq	a1,zero,SetMode		# =0x2e then go set mode
	addi	a1,a0,-':'		# 0x3a ? ....
	beq	a1,zero,SetStor		# ... yes set to store mode
	addi	a1,a0,-'R'		# 0x52 ? 
	beq	a1,zero,Run		# ... yes so execute the code
	mv	s1,tp			# YSAV(s1)=Current text ptr (tp)
	li	t0,0
NextHex:
	lbu	a0,0(tp)		# get the next byte
	addi	a0,a0,-'0'		# test for 0-9 and A-F
	blt	a0,zero,NotHex
	addi	a1,a0,-0x0a
	blt	a1,zero,Digit
	beq	a1,zero,NotHex
	addi	a0,a0,-0x07
	addi	a1,a0,-0x10
	bge	a1,zero,NotHex
Digit:	slli	t0,t0,4			# shift LH left 1 nibble
	or	t0,t0,a0		# mask in the new digit
	addi	tp,tp,1			# bump ptr
	j	NextHex			# carry on
NotHex:
	beq	s1,tp,Escape		# Ysav(s1)=Text Ptr (tp)no hex digits
	mv	a0,s0			# get Mode(s0)
	addi	a1,a0,-':'		# : says store
	bne	a1,zero,NotStor
	andi	a0,t1,3			# mask off byte index 0-3
	slli	a0,a0,3			# multiply by 8
	addi	a1,zero,0xff		# create byte mask
	sll	a1,a1,a0		# shift to position
	xori 	a1,a1,-1		# invert so e.g. 0F00->xF0FF
	sll	a3,t0,a0		# shift byte to be inserted
	andi	a2,t1,-4		# point to start of WORD for this byte
	lw	a0,0(a2)		# read WORD to change
	and	a0,a0,a1		# mask out byte
	or	a0,a0,a3		# insertnew byte
	sw 	a0,0(a2)		# write updated WORD
		
#	sb	t0,0(t1)		# save data(t0) to Storage ptr (STLH)
	addi	t1,t1,1			# bump storage ptr (STLH)
	j	NextItem
Run:
	jalr	ra,t2,0			#  run from address in XAMLH
	jal	ra,ECHO			# ********* temp ***********
	j	Escape
NotStor:
	bne	a0,zero,XamNext		# Mode=0 is first pass so set up ptrs
	mv	t1,t0			# STL/STH=LH
	mv	t2,t0			# XAMLH=LH
	addi	a1,zero,0
NxtPrnt:
	bne	a1,zero,PrData
	addi	a0,zero,0x0d
	jal	ra,ECHO
	srli	a0,t2,24		# print MSB bits (24:31) of address
	jal	ra,p2hex
	srli	a0,t2,16		# print bits (16:23) of address
	jal	ra,p2hex
	srli	a0,t2,8			# print bits (8:15) of address
	jal	ra,p2hex
	mv	a0,t2			# a0=XAMLH
	jal	ra,p2hex		# print LSB bits(0:7) of address
	addi	a0,zero,':'		# a colon
	jal	ra,ECHO	
PrData:
	addi	a0,zero,' '		# a blank
	jal	ra,ECHO
	lbu	a0,0(t2)		# get data from XAMLH
	jal	ra,p2hex
XamNext:
	li	s0,0			# set MODE=0
	beq	t0,t2,NextItem		# start=end then done
	addi	t2,t2,1			# bump XAML ptr
	blt	t0,t2,NextItem		# done ?
	andi	a1,t2,0x0f		# do mod 15 check
	j	NxtPrnt
#########################################################
#
# support sub routines from here
#	


ECHO:	lw	a1,USART_STAT_OFFSET(a5)	# load status into a4
	andi	a1,a1,USART_STAT_TBE		# isolate transmit buffer empty (TBE) bit
	beq	a1,zero,ECHO			# keep looping until ready to send
	sb	a0,USART_DATA_OFFSET(a5)	# write char from a0
	ret
		
p2hex:
	mv	a4,ra			# save return address
	mv	a3,a0			# save entry value	
	srli	a0,a0,4
	andi	a0,a0,0x0f
	li	a2,0x0a
	blt	a0,a2,pr2x0
	addi	a0,a0,7
pr2x0:	addi	a0,a0,'0'
	jal	ra,ECHO
	mv	a0,a3			# reget entry parameter
	andi	a0,a0,0x0f
	blt	a0,a2,pr2x1
	addi	a0,a0,7
pr2x1:	addi	a0,a0,'0'
	jal	ra,ECHO
	mv	a0,a3			# restore entry parameter
	mv	ra,a4
	ret
	


