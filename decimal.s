.include "utils.s"
.text
.global main
main:
    call readHex
    call mod10
    mv s0, a0
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
