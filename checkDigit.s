.text

.macro syscall %n
    addi a7, zero, %n
    ecall
.end_macro

.macro readChar
syscall 12
.end_macro

.macro echoChar
mv a1, a0
li a0, 10
syscall 11
mv a0, a1
syscall 11
li a1, 0
.end_macro

.macro exit %ecode
li a0, %ecode
syscall 93
.end_macro

main:
readChar
#slti t0, a0, 58
#li a2, 47
#slt a0, a2, a0
#and a0, t0, a0
#addi a0, a0, 48

andi a0, a0, 0xff
addi a0, a0, -48
sltiu a0, a0, 10
addi a0, a0, 48
echoChar
