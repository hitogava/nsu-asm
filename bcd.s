.include "utils.s"

.text
.globl main

main:
	call readHex
	mv s0, a0
	call readHex
	mv s1, a0
	
    # reading operator, put result of calculation in s2
    readCh
    li a1, 43
    beq a0, a1, opAdd
    li a1, 45
    beq a0, a1, opSub
    
    error "Invalid operation"

    opAdd:
        add s2, s0, s1
    
        li a2, 0xf
        li a3, 9
        li a4, 0x6
        # correction number
        li a5, 0

        do_while:
			andi a1, s0, 0xf
			srli s0, s0, 4
			
			andi a6, s1, 0xf
			srli s1, s1, 4
			
			bnez a1, body
			beqz a6, do_while_end
			
			# a1 - num1 digit
			# a6 - num2 digit
            body:
                slli a2, a2, 4
                # overflow checking
                sub a3, a3, a1
                bgt a6, a3, shift
                slli a4, a4, 4
                j do_while

                shift:
                    add a5, a5, a4
                    slli a4, a4, 4
                	j do_while	

        do_while_end:
            add s2, s2, a5
            j end


    opSub:
     	sub s2, s0, s1
    
        li a2, 0xf
        li a4, 0x6
        # correction number
        li a5, 0

        do_while_sub:

			andi a1, s0, 0xf
			srli s0, s0, 4
			
			andi a6, s1, 0xf
			srli s1, s1, 4
			
			bnez a1, body_sub
			beqz a6, do_while_end_sub

            body_sub:
                slli a2, a2, 4
                # overflow checking
                blt a1, a6, shift_sub
                slli a4, a4, 4
                j do_while_sub

                shift_sub:
                    add a5, a5, a4
                    slli a4, a4, 4
                	j do_while_sub

        do_while_end_sub:
			sub s2, s2, a5
            j end

end:
	newLine
	mv a0, s2
	call printHex
    exit 0
