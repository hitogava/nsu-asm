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

# get input char from a0, build HEX number and put it into a1
.macro readHex  
    mv a1, zero
    mv a2, zero
    li a3, 10
    while:
        readCh

        beq a0, a3, end_loop

        # validating digit
        addi a0, a0, -48
        sltiu a2, a0, 10
        beqz a2, end

        slli a1, a1, 4
        add a1, a1, a0
        j while

    end_loop:
        
.end_macro

# print number from register t2
.macro printHex
	li t0, 10
	newLine
	li a3, 0
	li a2, 0
	la t0, buffer
	li a4, 10

	hexLoop:
		andi a3, t2, 0xf
		srli t2, t2, 4
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
		bne t2, zero, hexLoop
		
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
.end_macro

.text
.macro mult
	readHex
	mv t0, a1
	readHex
	mv t1, a1
	
	li t3, 0  # result of multiplication
	li t4, 0  # sum of powers

	li a1, 0x1
	slli a1, a1, 31
	li t5, 0x1 # mask
	
	powers_loop:
		bge t5, a1, main_loop
		and a2, t1, t5
		add t4, t4, a2
		slli t5, t5, 1
		j powers_loop
	main_loop:
		beqz t0, main_loop_end
		add t3, t3, t4
		addi t0, t0, -1
		j main_loop
	main_loop_end:
		mv t2, t3
		printHex
.end_macro
main:
	mult
	exit 0

end:
	exit 1	
