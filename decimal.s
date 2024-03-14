.include "utils.s"
.text
.global main
main:
    #call readHex
    call read_decimal
    mv s0, a0
    call print_decimal
    exit 0

mult:
    li t0, 0
    li t1, 0 # sum of powers
    li t2, 0x1
    li t3, 0x1
    li t4, 0 # buffer

    slli t2, t2, 31

    powers_loop:
        bge t3, t2, main_loop
        and t4, a1, t3
        add t1, t1, t4
        slli t3, t3, 1
        j powers_loop
    main_loop:
        beqz a0, main_loop_end
        add t0, t0, t1
        addi a0, a0, -1
        j main_loop
    main_loop_end:
        mv a0, t0
    ret

# int div10(int)
div10:
	slti t0, a0, 10
	beqz t0, div10_rec
	li a0, 0x0
	ret

div10_rec:
	push2 ra, s0
	srai s0, a0, 2
	srai a0, a0, 1
	call div10
	sub a0, s0, a0
	srai a0, a0, 1
	pop2 ra, s0
	ret

# int mod10(int)
mod10:
	push s1
	mv s1, a0
	push ra
	call div10
	pop ra
	li a1, 10
	push ra
	call mult
	pop ra
	sub a0, s1, a0
	pop s1
	ret

#int read_decimal()
read_decimal:
	li t0, 0
	li t2, 0x1
	slli t2, t2, 32
	push s0
	.rd_while:
		readCh
		and t1, t0, t2
		bnez t1, overflow_error
		beqi a0, 10, .rd_while_end
		
		addi a0, a0, -48
		sltiu a2, a0, 10
		beqz a2, invalid_char_error
		
		li a1, 10
		mv s0, a0
		mv a0, t0
		push ra
		call mult
		pop ra
		add t0, a0, s0
		
		j .rd_while
	.rd_while_end:
		mv a0, t0
	pop s0
	ret

# void print_decimal(int)
print_decimal:
	push2 s0, s1
	li s1, 0 # counter
	.pd_while:
		mv s0, a0
		push ra
		call mod10
		pop ra
		addi a0, a0, 48
		push a0
		addi s1, s1, 1
		mv a0, s0
		push ra
		call div10
		pop ra
		bnez a0, .pd_while
	.pd_while_end:
		.pd_for:
			pop a0
			syscall 11
			addi s1, s1, -1
			bnez s1, .pd_for
	
	pop2 s0, s1
	ret