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
	li a0, 10
	syscall 11
.end_macro

.macro echoCh
	newLine
	syscall 11
.end_macro

.macro readCh
	syscall 12
.end_macro

.macro push %r
    addi sp, sp, -4
    sw %r, 0(sp)
.end_macro

.macro pop %r
    lw %r, 0(sp)
    addi sp, sp, 4
.end_macro

main:
	call readHex
	mv a2, a0
	call readHex
	mv a1, a0

    mv a0, a2

    call performOperation
	
performOperation:
    push a0
	readCh
	mv t2, a0 # operation
    pop a0
	
	li t3, 43 # buffer
	beq t2, t3, opAdd
	
	li t3, 45
	beq t2, t3, opSub
	
	li t3, 38
	beq t2, t3, opAnd
	
	li t3, 124
	beq t2, t3, opOr
	
	j end
	
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
    	push a0
    	newLine
        pop a0

        push a0
    	call printHex
        pop a0

    	exit 0
    ret

readHex:
	li t0, 0
	li t1, 0
	li t2, 10

    while:
        readCh

        beq a0, t2, end_loop

        # 0...9
        slti t0, a0, 48
        bnez t0, end
        slti t0, a0, 58
        bnez t0, digit

        # A...F
        slti t0, a0, 65
        bnez t0, end
        slti t0, a0, 71
        bnez t0, cap_letter

        # a...f
        slti t0, a0, 97
        bnez t0, end
        slti t0, a0, 103
        bnez t0, letter
        
        j end

        digit:
            addi a0, a0, -48
            j while_iter
        cap_letter:
            addi a0, a0, -55
            j while_iter
        letter:
            addi a0, a0, -87
            j while_iter

        while_iter:
            slli t1, t1, 4
            add t1, t1, a0
            j while

    end_loop:
    
    mv a0, t1
    ret

printHex:
	li a2, 0
	la t0, buffer
	li a4, 10
	
	hexLoop:
		andi a3, a0, 0xf
		srli a0, a0, 4
		
		blt a3, a4, dig
		bge a3, a4, let
		dig:
			addi a3, a3, 48
			j offset
		let:
			addi a3, a3, 55
			j offset
	
	offset:
		sb a3, (t0)
		addi t0, t0, 1
		bne a0, zero, hexLoop
	
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
	ret


end:
	exit 1
