.text
.eqv scr t6
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

.macro push2 %r1 %r2
    addi sp, sp, -8
    sw %r1, 0(sp)
    sw %r2, 4(sp)
.end_macro

.macro pop %r
    lw %r, 0(sp)
    addi sp, sp, 4
.end_macro

.macro pop2 %r1 %r2
    lw %r1, 0(sp)
    lw %r2, 4(sp)
    addi sp, sp, 8
.end_macro
.macro swap %r1 %r2
	xor %r1, %r1, %r2
	xor %r2, %r2, %r1
	xor %r1, %r1, %r2
.end_macro
.macro error %str
	.data
		str: .asciz %str
	.text
		newLine
		la a0, str
		syscall 4
		exit 1
.end_macro

.macro beqi %r, %i, %label
	li scr, %i
	beq %r, scr, %label
.end_macro

.macro bgti %r, %i, %label
	li scr, %i
	bgt %r, scr, %label
.end_macro

#int readHex()
readHex:
	li t0, 0
	li t1, 0
	li t2, 10
	li t3, 9
    while:
        beqz t3, hex_length_error
        readCh
        beq a0, t2, end_loop
        addi t3, t3, -1

        # 0...9
        slti t0, a0, 48
        bnez t0, invalid_char_error
        slti t0, a0, 58
        bnez t0, digit

        # A...F
        slti t0, a0, 65
        bnez t0, invalid_char_error
        slti t0, a0, 71
        bnez t0, cap_letter

        # a...f
        slti t0, a0, 97
        bnez t0, invalid_char_error
        slti t0, a0, 103
        bnez t0, letter
        
        j invalid_char_error

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

# void printHex(int)
printHex:
	li a2, 10
	li a3, 0
	hex_loop:
		andi a1, a0, 0xf
		bge a1, a2, let
		addi a1, a1, 48
		j hex_loop_iter
		let:
			addi a1, a1, 55
		hex_loop_iter:
			srli a0, a0, 4
			push a1
			addi a3, a3, 1
			bnez a0, hex_loop
				
	hex_loop_end:
		li a1, 120
		push a1
		li a1, 48
		push a1
		addi a3, a3, 2 # for 0x
		for:
			pop a0
			syscall 11
			addi a3, a3, -1
			bnez a3, for
		for_end:
			ret

hex_length_error:
	error "More than 8 digits"
invalid_char_error:
	error "Invalid character"
