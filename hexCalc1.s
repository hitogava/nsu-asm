.data

buffer: .space 32

.text

.macro syscall %n
	li a7, %n
	ecall
.end_macro

.macro exit %ecode
	li a0, %ecode
	syscall 93
.end_macro

.macro newLine
	mv a6, a0
	mv a0, t0
	syscall 11
	mv a0, a6
.end_macro
.macro echoCh
	newLine
	syscall 11
.end_macro
.macro readCh
	syscall 12
.end_macro

main:
	li t0, 10 # <enter>
	
	
	li a1, 0  # 1 number
	li a3, 0  # 2 number
	
	
	li a2, 0  # flag
	li a4, 0  # operation
	li a5, 0  # operation buffer
	
	


readFirst:
	readCh
	beq a0, t0, readFirstDone
	
	# 0...9
	slti a2, a0, 48
	bnez a2, end
	slti a2, a0, 58
	bnez a2, digit1
	
	# A...F
	slti a2, a0, 65
	bnez a2, end
	slti a2, a0, 71
	bnez a2, capL1
	
	# a...f
	slti a2, a0, 97
	bnez a2, end
	slti a2, a0, 103
	bnez a2, L1
	
	j end

digit1:
	addi a0, a0, -48
	j readFirstProlog

capL1:
	addi a0, a0, -55
	j readFirstProlog

L1:
	addi a0, a0, -87
	j readFirstProlog

digit2:
	addi a0, a0, -48
	j readSecondProlog

capL2:
	addi a0, a0, -55
	j readSecondProlog
L2:
	addi a0, a0, -87
	j readSecondProlog


readFirstProlog:
	add t3, t3, a0
	slli t3, t3, 4
	j readFirst
	
readFirstDone:
	srli t3, t3, 4
	mv a1, t3
	mv t3, zero
	j readSecond

	j end
	
readSecond:
	readCh
	beq a0, t0, readSecondDone
	
	# 0...9
	slti a2, a0, 48
	bnez a2, end
	slti a2, a0, 58
	bnez a2, digit2
	
	# A...F
	slti a2, a0, 65
	bnez a2, end
	slti a2, a0, 71
	bnez a2, capL2
	
	# a...f
	slti a2, a0, 97
	bnez a2, end
	slti a2, a0, 103
	bnez a2, L2
	
	j end

readSecondProlog:
	add t3, t3, a0
	slli t3, t3, 4
	j readSecond

readSecondDone:
	srli t3, t3, 4
	mv a3, t3
	mv t3, zero
	
	#reading operation
	readCh
	newLine
	mv a4, a0
	li a5, 43
	beq a0, a5, opAdd
	
	li a5, 45
	beq a0, a5, opSub
	
	li a5, 38
	beq a0, a5, opAnd
	
	li a5, 124
	beq a0, a5, opOr

opAdd:
	add a1, a1, a3
	j printHex
opSub:
	sub a1, a1, a3
	j printHex
opAnd:
	and a1, a1, a3
	j printHex
opOr:
	or a1, a1, a3
	
	
printHex:
	li a3, 0
	li a2, 0
	la t0, buffer
	li a4, 10
	
hexLoop:
	andi a3, a1, 0xf
	srli a1, a1, 4
	#blt a3, a4, offset
	blt a3, a4, dig
	bge a3, a4, letter
	dig:
		addi a3, a3, 48
		j offset
	letter:
		addi a3, a3, 55
		j offset
	

offset:
	#addi a3, a3, 48
	sb a3, (t0)
	addi t0, t0, 1
	li a3, 0
	bne a1, zero, hexLoop
end:
	# printing values from array in reverse order
	li a3, 120 # x
	sb a3, (t0)
	addi t0, t0, 1
	li a3, 48 # 0
	sb a3, (t0),
	addi t0, t0, 1
	
	la a3, buffer
	for:
		addi t0, t0, -1
		lb a0, (t0)
		syscall 11	
		bgt t0, a3, for
	exit 0
