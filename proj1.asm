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
    
    addi $t3, $t3, 1 	# move to next character
    addi $t5, $t5, 1	# increment counter
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
    
    j exit
    
    E_op:				# completes E operation
    li $t1, 5				# checks if the number of args is correct
    la $t2, num_args
    lw $t2, ($t2) 
    bne $t1, $t2, invalid_args
    
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
