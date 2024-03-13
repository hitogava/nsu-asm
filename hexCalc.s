j main

.include "io.s"

.text

main:
	call readHex
	mv s0, a0
	call readHex	
	mv s1, a0
    
    # read operaiton
    readCh
    mv a2, a0
    mv a0, s0
    mv a1, s1
    # args: a0: n1, a1: n2, a2: op
    call performOperation
    exit 0
	
performOperation:

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
		j printRes
	opSub:
		sub a0, a0, a1
		j printRes
	opAnd:
		and a0, a0, a1
		j printRes
	opOr:
		or a0, a0, a1
    
    printRes:
    	mv s0, a0
    	newLine
        mv a0, s0

        push ra
    	call printHex
        pop ra
    ret