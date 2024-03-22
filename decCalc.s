.include "decimal.s"

.text
.globl main
main:
	call read_decimal
	call print_decimal
	exit 0
	mv s1, a0
	
	readCh
	mv a2, a0 # operation
	newLine
	
	mv a0, s0
	mv a1, s1
	call performOperation
	call print_decimal
	exit 0

performOperation:
	push2 s0, s1
	push2 s2, s3
	push2 s4, s5
	li t3, 43 # buffer
	beq a2, t3, opAdd
	
	li t3, 45
	beq a2, t3, opSub
	
	li t3, 38
	beq a2, t3, opAnd
	
	li t3, 124
	beq a2, t3, opOr
	
	error "Invalid operation"
	
	opAdd:
		add a0, a0, a1
		li a1, 0x80000000
		bltu a0, a1, .epilog
		sub a0, a0, a1
		neg a0, a0
		j .epilog
	opSub:
		sub a0, a0, a1
		j .epilog
	opAnd:
	opOr:
	
	.epilog:
		pop2 s4, s5
		pop2 s2, s3
		pop2 s0, s1
		ret
