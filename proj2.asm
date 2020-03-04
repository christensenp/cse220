# Peter Christensen
# pwchristense
# 112123806

.text

checkIfGhost:
	li $t0, 'G'
	li $t1, 'H'
	li $t2, 'O'
	li $t3, 'S'
	li $t4, 'T'
	beq $t0, $a0, isGhost
	beq $t1, $a0, isGhost
	beq $t2, $a0, isGhost
	beq $t3, $a0, isGhost
	beq $t4, $a0, isGhost
	li $t0, 'g'
	li $t1, 'h'
	li $t2, 'o'
	li $t3, 's'
	li $t4, 't'
	beq $t0, $a0, isGhost
	beq $t1, $a0, isGhost
	beq $t2, $a0, isGhost
	beq $t3, $a0, isGhost
	beq $t4, $a0, isGhost
	
	li $v0, 0
	j returnGhost
	isGhost:
	li $v0, 1
	returnGhost:
	jr $ra
	
shiftString:
	### ao is the direction, 0 is left 1 is right | a1 is the string | a2 is the number of iterations
	li $t0, 0 				# counter
	beqz $a0, shiftStringLeftLoop
	shiftStringRightLoop:
		bgt $t0, $a2, shiftStringDone	# check terminating condition
		lbu $t4, ($a1)			# load the chararacter
		sb $t4, 1($a1)			# store the character into the next byte
		addi $t0, $t0, 1		# increment counter
		addi $a1, $a1, -1		# move the character to the left
		j shiftStringRightLoop
		
	shiftStringLeftLoop:
		bgt $t0, $a2, shiftStringDone	# check terminating condition
		lbu $t4, ($a1)			# load the chararacter
		sb $t4, -1($a1)			# store the character into the left byte
		addi $t0, $t0, 1		# increment counter
		addi $a1, $a1, 1		# move the character to the left
		j shiftStringLeftLoop
	
	shiftStringDone:
	jr $ra
strlen:
	li $t0, 0 		# counter for string length
	move $t1, $a0		# base address for string
	parseStringLoop:
		lbu $t2, ($t1)			# load next character
		beqz $t2, foundNullTerm		# stop at null terminator
		addi $t1, $t1, 1		# increment counter
		addi $t0, $t0, 1		# increment string len
		j parseStringLoop
	foundNullTerm:
	move $v0, $t0				# return result
   	jr $ra

insert:
	addi $sp, $sp, -20			# preserve registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	move $s0, $a0				# store args
	move $s1, $a1
	move $s2, $a2
	
	jal strlen				# get string length
	move $s3, $v0
	bltz $s2, invalidIndex			# check if index is valid
	bgt $s2, $s3, invalidIndex
	
	add $t1, $s3, $s0			# store address for end of string	
	sub $t2, $s3, $a2 			# number of iterations		
	li $t3, 0				# counter
	li $a0, 1				# shift to right
	move $a1, $t1 				
	move $a2, $t2
	jal shiftString
	add $t5, $s0, $s2 			# insert the character at the index
	sb $s1, ($t5)
	addi $s3, $s3, 1			# increment string length
	move $v0, $s3
	j donePartTwo
	
	invalidIndex:
		li $v0, -1
	donePartTwo:
	lw $ra, 0($sp)				# restore registers
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra


pacman:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	move $s0, $a0
	move $s3, $s0
	jal strlen
	move $s1, $v0				# max iters
	addi $s1, $s1, -1
	li $s2, 0				# counter
	
	eatCharLoop:
		lbu $t1, ($s3)			# load first char
		move $a0, $t1			# check if it is in ghost
		jal checkIfGhost
		bnez $v0, checkIfAtStart	# if it is, stop eating
		li $t0, '_'			# else replace it with a underscore
		sb $t0, ($s3)
		addi $s2, $s2, 1		# increment counter
		addi $s3, $s3, 1		# go to next char
		bgt $s2, $s1, ghostNotInMiddle	# if max iters reached stop eating
		j eatCharLoop
	checkIfAtStart:				# check if the ghost is the first char
		beqz $s2, ghostNotInMiddle		
		li $t2, '<'			# if isn't then replace the last underscore with a <
		addi $s3, $s3, -1
		addi $s2, $s2, -1
		sb $t2, ($s3)
		j returnPacMan	
	ghostNotInMiddle:			# insert < at the start or end
		move $a0, $s0
		li $a1, '<'
		move $a2, $s2
		jal insert
		
	returnPacMan:	
	move $a0, $s0				# get length of original string
	jal strlen
	move $v1, $v0				# put string length into return value
	move $v0, $s2	

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)	
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra

replace_first_pair:
	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	
	move $s0, $a0				# preserve args
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	lw $t0, 28($sp)				# retrieve fifth arg from stack
	move $s4, $t0				# counter
	
	jal strlen
	move $s5, $v0				# max iters
	move $t0, $s0				# base address
	add $t0, $t0, $s4
	li $t2, 0				# flag for first char
	replaceFirstLoop:
		lbu $t1, ($t0)
		bnez $t2, checkSecondPair			# if the flag is up check the next character
		addi $s4, $s4, 1				# increment counter and address
		addi $t0, $t0, 1		
		bne $t1, $s1, finishReplaceFirstLoop		# check if the character matches first of pair
		li $t2, 1
		j finishReplaceFirstLoop
		checkSecondPair: 				# check if the character matches the second of pair
			bne $t1, $s2, notSecondPair
			j foundFirstPair
		notSecondPair:					# if it doesnt reset flag
			li $t2, 0
		finishReplaceFirstLoop:				# check the termination condition
			blt $s4, $s5, replaceFirstLoop
			
	li $v0, -1
	j finishReplaceFirst		
	foundFirstPair:						# insert the replacement char at location of pair
		sb $s3, -1($t0)
		li $a0, 0
		move $a1, $t0				
		addi $a1, $a1, 1
		sub $s5, $s5, $s4
		move $a2, $s5
		jal shiftString					# shift string to the left after the pair location
		move $v0, $s4	
		addi $v0, $v0, -1
	
	finishReplaceFirst:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)	
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28	
	jr $ra

replace_all_pairs:
	addi $sp, $sp, -32
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	
	move $s0, $a0				# preserve args
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3

	li $s4, 0				# initial value for starting index
	li $s5, 0				# counter for replacements
	li $s6, -1
	replaceAllPairsLoop:
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		move $a3, $s3
		addi $sp, $sp, -4
		sw $s4, 0($sp)
	
		jal replace_first_pair
		addi $sp, $sp, 4
		beq $v0, $s6, foundAllPairs
		move $s4, $v0	
		addi $s4, $s4, 1
		addi $s5, $s5, 1
		j replaceAllPairsLoop
	
	foundAllPairs:
		move $v0, $s5

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)	
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	addi $sp, $sp, 32	
	jr $ra

bytepair_encode:
    jr $ra

replace_first_char:
    jr $ra

replace_all_chars:
    jr $ra

bytepair_decode:
    jr $ra
