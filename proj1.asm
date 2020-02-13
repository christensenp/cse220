# Peter Christensen
# pwchristense
# 112123806

.data
# Command-line arguments
num_args: .word 0
addr_arg0: .word 0
addr_arg1: .word 0
addr_arg2: .word 0
addr_arg3: .word 0
addr_arg4: .word 0
no_args: .asciiz "You must provide at least one command-line argument.\n"

# Error messages
invalid_operation_error: .asciiz "INVALID_OPERATION\n"
invalid_args_error: .asciiz "INVALID_ARGS\n"

# Put your additional .data declarations here
space: .asciiz " "
newline: .asciiz "\n"

# Main program starts here
.text
.globl main
main:
    # Do not modify any of the code before the label named "start_coding_here"
    # Begin: save command-line arguments to main memory
    sw $a0, num_args
    beqz $a0, zero_args
    li $t0, 1
    beq $a0, $t0, one_arg
    li $t0, 2
    beq $a0, $t0, two_args
    li $t0, 3
    beq $a0, $t0, three_args
    li $t0, 4
    beq $a0, $t0, four_args
five_args:
    lw $t0, 16($a1)
    sw $t0, addr_arg4
four_args:
    lw $t0, 12($a1)
    sw $t0, addr_arg3
three_args:
    lw $t0, 8($a1)
    sw $t0, addr_arg2
two_args:
    lw $t0, 4($a1)
    sw $t0, addr_arg1
one_arg:
    lw $t0, 0($a1)
    sw $t0, addr_arg0
    j start_coding_here

zero_args:
    la $a0, no_args
    li $v0, 4
    syscall
    j exit
    # End: save command-line arguments to main memory

start_coding_here:
    # Start the assignment by writing your code here
    li $t1, 'B'
    li $t4, 'D'
    li $t5, 'C'
    li $t6, 'E'    
    lw $t2, addr_arg0  			# loads the address of the first arg
    addi $t3, $t2, 1 			# go to the address of the next character
    lbu $t2, 0($t2)  			# puts the first character of the first arg into $t2
    lbu $t3, 0($t3)  			# puts the second character of the first arg into $t3
    bne $t3, $zero, invalid_op 		# checks that the byte after arg0 is the null terminator
    beq $t1, $t2, B_op  		# checks if the first arg is B
    beq $t4, $t2, D_op 			# checks if the first arg is D
    beq $t5, $t2, C_op 			# checks if the first arg is C
    beq $t6, $t2, E_op  		# checks if the first arg is E
    j invalid_op
    
    B_op: 				# Completes B operation
    li $t1, 2				# checks if the number of args is correct
    la $t2, num_args
    lw $t2, ($t2) 
    bne $t1, $t2, invalid_args
    
    j exit
    
    D_op: 				# Completes D operation
    li $t1, 2				# checks if the number of args is correct
    la $t2, num_args
    lw $t2, ($t2) 
    bne $t1, $t2, invalid_args
    
    li $t1, '0'				# checks that the first two chars of the second arg are 0x
    li $t2, 'x'
    lw $t3, addr_arg1			
    lbu $t4, 0($t3)
    bne $t1, $t4, invalid_args
    lbu $t4, 1($t3)
    bne $t2, $t4, invalid_args
   
    li $t5, 0  		# counter
    li $t6, 8		# number of iterations
    addi $t3, $t3, 2    # address of char after 0x 
    loopThroughSecArg:
    lbu $t1, 0($t3)	# load character 
    li $t2, 0x30
    li $t4, 0x39 
    blt $t1, $t2, invalid_args		# checks if character is less than ascii value for 0
    bgt $t1, $t4, checkIfValidChar	# checks if character is greater than ascii value for 9
    addi $t1, $t1, -0x30 		# subtracts 0x30 to get the decimal value
    j createInstructions
    
    checkIfValidChar:
    li $t2, 0x41
    li $t4, 0x46 
    blt $t1, $t2, invalid_args		# checks if character is less than ascii value for A
    bgt $t1, $t4, invalid_args		# checks if character is greater than ascii value for F
    addi $t1, $t1, -0x37 		# subtracts 0x31 to get the decimal value
    
    createInstructions:
    sll $t9, $t9, 4			# shift left by 4 bits so that the values get added properly
    add $t9, $t9, $t1			
    
    addi $t3, $t3, 1 		# move to next character
    addi $t5, $t5, 1		# increment counter
    blt $t5, $t6, loopThroughSecArg	# loop back if the counter < number of iterations
    
    move $t1, $t9
    srl $t1, $t1, 26  			# extract the first 6 bits
    
    move $t2, $t9			# extract the middle 5 bits
    sll $t2, $t2, 6
    srl $t2, $t2, 27
 
    move $t3, $t9			# extract the middle 5 bits
    sll $t3, $t3, 11
    srl $t3, $t3, 27
    
    move $t4, $t9			# extract the last 16 bits
    sll $t4, $t4, 16
    sra $t4, $t4, 16
    move $t5, $t4			# checks if the first bit of the last 16 is 0
    srl $t5, $t5, 15
    bnez $t5, convertFromTwosCompl
    
    printInstructions:
    move $a0, $t1			# print the opcode
    li $v0, 1
    syscall
    la $a0, space			# print a space 
    li $v0, 4
    syscall
    move $a0, $t2			# print the rs
    li $v0, 1
    syscall
    la $a0, space			# print a space
    li $v0, 4
    syscall
    move $a0, $t3			# print the rt
    li $v0, 1
    syscall
    la $a0, space			# print a space 
    li $v0, 4
    syscall
    move $a0, $t4			# print the immediate
    li $v0, 1
    syscall
    la $a0, newline			# print a newline
    li $v0, 4
    syscall
    j exit
    
    convertFromTwosCompl:		# complement the bits and add 1
    xori $t4, $t4, 0xFFFFFFFF		
    addi $t4, $t4, 1
    subu $t4, $zero, $t4
    j printInstructions
    
    C_op:				# Completes C operation
    li $t1, 4				# checks if the number of args is correct
    la $t2, num_args
    lw $t2, ($t2) 
    bne $t1, $t2, invalid_args
    
    lw $t0, addr_arg1			# checks if the second arg is valid
    lbu $t1, 0($t0)
    lbu $t2, 1($t0)
    bnez $t2, invalid_args
    li $t2, 0x31
    beq $t1, $t2, firstArgValid
    li $t2, 0x32
    beq $t1, $t2, firstArgValid
    li $t2, 0x53
    bne $t1, $t2, invalid_args
    
    firstArgValid:
    lw $t0, addr_arg2			# checks if the third arg is valid
    lbu $t2, 0($t0)
    lbu $t3, 1($t0)
    bnez $t3, invalid_args
    li $t3, 0x31
    beq $t2, $t3, secondArgValid
    li $t3, 0x32
    beq $t2, $t3, secondArgValid
    li $t3, 0x53
    bne $t2, $t3, invalid_args
   
    secondArgValid:
    lw $t0, addr_arg3  
    li $t5, 0  		# counter
    li $t6, 8		# number of iterations
    addi $t0, $t0, 2    # address of char after 0x 
    loopThroughHexa:
    lbu $t7, 0($t0)	# load character 
    li $t8, 0x30
    li $t4, 0x39 
    blt $t7, $t8, invalid_args		# checks if character is less than ascii value for 0
    bgt $t7, $t4, convertChar	# checks if character is greater than ascii value for 9
    addi $t7, $t7, -0x30 		# subtracts 0x30 to get the decimal value
    j createBinary
    
    convertChar:
    li $t8, 0x41
    li $t4, 0x46 
    blt $t7, $t8, invalid_args		# checks if character is less than ascii value for A
    bgt $t7, $t4, invalid_args		# checks if character is greater than ascii value for F
    addi $t7, $t7, -0x37 		# subtracts 0x31 to get the decimal value
    
    createBinary:
    sll $s0, $s0, 4			# shift left by 4 bits so that the values get added properly
    add $s0, $s0, $t7			
    
    addi $t0, $t0, 1 		# move to next character
    addi $t5, $t5, 1		# increment counter
    blt $t5, $t6, loopThroughHexa	# loop back if the counter < number of iterations
    
    srl $t9, $s0, 31			# if the first bit is 0 no conversion is needed so print
    beqz $t9, printBinary
    beq $t1, $t2, printBinary		# check if the source and destination scheme are the same
    
    li $t0, 0x31			# check if it's in ones complement
    bne $t1, $t0, notInOnes
    addi $t0, $t0, 1
    beq $t2, $t0, convertToTwos 	# check if it needs to be converted to twos
    xori $s0, $s0, 0xFFFFFFFF		# complement the its to change it to binary
    ori $s0, $s0, 0x80000000		# add sign bit
    j printBinary


    notInOnes:
    li $t0, 0x32			# check if it's in two's complement
    bne $t1, $t0, notInTwos
    li $t0, 0x31			
    beq $t2, $t0, fromTwosToOnes	# check if it must be converted to ones 
    addi $s0, $s0, -1			
    xori $s0, $s0, 0xFFFFFFFF
    ori $s0, $s0, 0x80000000
    j printBinary
    
    notInTwos:				# if it's not in ones or twos it must be sign, so convert it to ones first
    andi $s0, $s0, 0x7FFFFFFF
    beqz $s0, printBinary
    j convertToOnes 
    
    fromTwosToOnes:
    addi $s0, $s0, -1	
    j printBinary
    
    convertToOnes:
    xori $s0, $s0, 0xFFFFFFFF		# complement the its to change it to binary
    li $t0, 0x32
    bne $t2, $t0, printBinary
    
    convertToTwos:
    addi $s0, $s0, 1
    j printBinary
    
    printBinary:
    move $a0, $s0
    li $v0, 35
    syscall
    
    j exit
    
    E_op:				# completes E operation
    li $t1, 5				# checks if the number of args is correct
    la $t2, num_args
    lw $t2, ($t2) 
    bne $t1, $t2, invalid_args
    
    lw $t1, addr_arg1 			# converting the first arg to a two digit decimal
    lbu $t2, 0($t1)
    lbu $t3, 1($t1)
    addi $t2, $t2, -0x30
    addi $t3, $t3, -0x30
    lbu $t5, 2($t1)			# checks if the decimal is out of range
    bnez $t5, invalid_args
    li $t4, 10
    mul $t2, $t2, $t4
    add $t1, $t2, $t3
    li $t2, 63				# checks if the decimal is out of range
    bgt $t1, $t2, invalid_args
    
    lw $t9, addr_arg2 			# converting the second arg to a two digit decimal
    lbu $t2, 0($t9)
    lbu $t3, 1($t9)
    addi $t2, $t2, -0x30
    addi $t3, $t3, -0x30
    lbu $t5, 2($t9)			# check if there is a third digit
    bnez $t5, invalid_args
    li $t4, 10
    mul $t2, $t2, $t4
    add $t9, $t2, $t3
    li $t2, 31				# checks if the decimal is out of range
    bgt $t9, $t2, invalid_args
    
    lw $t8, addr_arg3 			# converting the third arg to a two digit decimal
    lbu $t2, 0($t8)
    lbu $t3, 1($t8)
    addi $t2, $t2, -0x30
    addi $t3, $t3, -0x30
    lbu $t5, 2($t8)			# check if there is a third digit
    bnez $t5, invalid_args
    li $t4, 10
    mul $t2, $t2, $t4
    add $t8, $t2, $t3
    li $t2, 31				# checks if the decimal is out of range
    bgt $t8, $t2, invalid_args
    
    lw $t7, addr_arg4			# check if the first char is a negative sign
    lbu $t2, 0($t7) 
    move $t0, $t2
    li $t3, '-'
    li $t6, 5		# counter
    li $t5, 10
    li $t4, 10000
    bne $t2, $t3, notNegative
    addi $t7, $t7, 1
    li $s3, 0
    notNegative:
    lbu $t2, 0($t7)		# loading the digit
    addi $t2, $t2, -0x30
    mul $t2, $t2, $t4		# applying weight of place
    divu $t4, $t5		# calculating place value
    mflo $t4
    addi $t7, $t7, 1
    addi $t6, $t6, -1		# decrements the counter
    add $s3, $s3, $t2
    bgtz $t6, notNegative
    li $t2, 32767
    bgt $s3, $t2, invalid_args
    bne $t0, $t3, dontNegate
    li $t2, 32768
    bgt $s3, $t2, invalid_args
    subu $s3, $zero, $s3
    
    dontNegate:
    sll $t1, $t1, 26		# extract the bits for each part
    sll $t9, $t9, 21
    sll $t8, $t8, 16
    sll $s3, $s3, 16
    srl $s3, $s3, 16
    
    li $s0, 0			# concatenate the bits together
    or $s0, $t1, $t9
    or $s0, $s0, $t8
    or $s0, $s0, $s3
    move $a0, $s0
    li $v0, 34
    syscall
    j exit
    
    invalid_op:				# prints if the operation is invalid
    la $a0, invalid_operation_error
    li $v0, 4
    syscall
    j exit
    				
    invalid_args:			# prints if the number of arguments is invalid
    la $a0, invalid_args_error
    li $v0, 4
    syscall
    j exit

exit:
    li $v0, 10
    syscall
