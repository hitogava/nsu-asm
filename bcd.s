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

    addi a0, a0, -48
    sltiu a2, a0, 10
    beqz a2, end

readFirstProlog:
	add t3, t3, a0
	slli t3, t3, 4
	j readFirst
	
readFirstDone:
	srli t3, t3, 4
	mv a1, t3
	mv t3, zero

readSecond:
	readCh
	beq a0, t0, readSecondDone
	
    addi a0, a0, -48
    sltiu a2, a0, 10
    beqz a2, end

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
	
	mv t0, zero
	mv t1, zero
	mv t2, zero
	mv t3, zero
	mv a2, zero

	beq a0, a5, opAdd
	
	li a5, 45
	beq a0, a5, opSub

# t1 = 0x0..6..0
# t2 = res
# t4 = 0x666...666
# t5 = 0x00f..0000
opAdd:
	add t2, a1, a3
    li a5, 9
    li t4, 0x6666666666666666
    li t5, 0xf
	loop:
		li a5, 9
		beqz a1, endLoop

		
		andi t0, a1, 0xf
    	srli a1, a1, 4
	
    	andi t3, a3, 0xf
    	srli a3, a3, 4
    
	    isOverflow:
	        sub a5, a5, t0
	        slt a2, a5, t3
	        bnez a2, shift
	        slli t5, t5, 4
	        beqz a2, loop
	        shift:
	            and a6, t4, t5
	            add t1, t1, a6
	            mv a6, zero
	    		slli t5, t5, 4
    	j loop
    endLoop:
    	bnez a3, loop
    	# correction
        add a1, t2, t1
        j printHex
    
opSub:
	li t4, 0x6666666666666666
    li t5, 0xf
	sub t2, a1, a3
	loop1:
		beqz a1, endLoop1
		andi t0, a1, 0xf
    	srli a1, a1, 4
	
    	andi t3, a3, 0xf
    	srli a3, a3, 4
    	isOverflow1:
    		blt t0, t3, shift1
    		slli t5, t5, 4
    		j loop1
    		shift1:
    			and a6, t4, t5
	            add t1, t1, a6
	            mv a6, zero
	    		slli t5, t5, 4
		
	endLoop1:
		bnez a3, loop1
    	# correction
        sub a1, t2, t1
        j printHex
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

end:
	exit 0