.text
.macro syscall %n
	li a7, %n
	ecall
.end_macro

.macro exit %ecode
	li a0, %ecode
	syscall 93
.end_macro

.macro readCh
	syscall 12
.end_macro

.macro newLine
	mv a1, a0
	mv a0, t0
	syscall 11
	mv a0, a1
.end_macro

.macro echoSpace
	mv a1, a0
	li a0, 32
	syscall 11
	mv a0, a1
.end_macro

.macro echoCh
	syscall 11
.end_macro

.macro echoNextCh
	mv a1, a0
	addi a0, a0, 1
	syscall 11
	mv a0, a1
.end_macro

_start:
	li t0, 10
	j loop

loop:
	readCh
	beq a0, t0, end
	echoSpace
	echoCh
	echoSpace
	echoNextCh
	newLine
	j loop

end:
	exit 0
