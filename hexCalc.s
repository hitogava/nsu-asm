.include "utils.s"

.text
.global main

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
    call performOperation
    exit 0

# void performOperation(int, int, char)
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
		add a3, a0, a1
		j printRes
	opSub:
		sub a3, a0, a1
		j printRes
	opAnd:
		and a3, a0, a1
		j printRes
	opOr:
		or a3, a0, a1
    
    printRes:
    	newLine
        mv a0, a3

        push ra
    	call printHex
        pop ra
    ret
