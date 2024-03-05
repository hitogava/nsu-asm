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


main:
    # reading numbers and put into t0, t1 respectively
    readHex
    mv t0, a1
    readHex
    mv t1, a1

    # reading operator, put result of calculation in t2
    readCh
    li a1, 43
    beq a0, a1, opAdd
    li a1, 45
    beq a0, a1, opSub
    exit 1

    opAdd:
        add t2, t0, t1

        
        li a2, 0xf
        li a3, 9
        li a4, 0x6
        # correction number
        li a5, 0

        do_while:
   	
        	li a3, 9

			andi s0, t0, 0xf
			srli t0, t0, 4
			
			andi s1, t1, 0xf
			srli t1, t1, 4
			
			bnez s0, body
			beqz s1, do_while_end

            body:
                slli a2, a2, 4
                # overflow checking
                sub a3, a3, s0
                bgt s1, a3, shift
                slli a4, a4, 4
                j do_while

                shift:
                    add a5, a5, a4
                    slli a4, a4, 4
                	j do_while	

        do_while_end:
            add t2, t2, a5
            j end



    opSub:
     	sub t2, t0, t1

        
        li a2, 0xf
        li a4, 0x6
        # correction number
        li a5, 0

        do_while_sub:

			andi s0, t0, 0xf
			srli t0, t0, 4
			
			andi s1, t1, 0xf
			srli t1, t1, 4
			
			bnez s0, body_sub
			beqz s1, do_while_end_sub

            body_sub:
                slli a2, a2, 4
                # overflow checking
                blt s0, s1, shift_sub
                slli a4, a4, 4
                j do_while_sub

                shift_sub:
                    add a5, a5, a4
                    slli a4, a4, 4
                	j do_while_sub

        do_while_end_sub:
			sub t2, t2, a5
            j end

end:
	printHex
    exit 0
