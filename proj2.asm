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
	### a0 is the direction, 0 is left 1 is right | a1 is the string | a2 is the number of iterations
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
	
clearArray:
	### a0 is the base address of the array | a1 is the size of the array
	li $t2, 0		# counter
	move $t0, $a0
	move $t1, $a1
	setZeroLoop:
		bge $t2, $t1, doneClearArray
		sb $0, ($t0)
		addi $t2, $t2, 1
		addi $t0, $t0, 1
		j setZeroLoop
	doneClearArray:
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
		move $a0, $s0			# initialize args of replace_first_pair
		move $a1, $s1
		move $a2, $s2
		move $a3, $s3
		addi $sp, $sp, -4		
		sw $s4, 0($sp)
	
		jal replace_first_pair		# call replace first pair 
		addi $sp, $sp, 4		
		beq $v0, $s6, foundAllPairs	# if it returns -1 then all pairs have been found
		move $s4, $v0			# put the return index into s4 so it can be used as arg for next call
		addi $s4, $s4, 1		# increment counters
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
	addi $sp, $sp, -36
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	
	move $a0, $a1				# clear arrays
	li $a1, 676
	jal clearArray
	move $a0, $a2
	li $a1, 52
	jal clearArray
	
	li $s7, 25
	li $s6, 0
	
	bytePairEncodeLoop:
	
	li $s3, 0				# max frequency
	li $s4, -1				# pair with max frequency
	move $a0, $s0
	jal strlen
	move $s5, $v0				# size of string / max iters
	addi $s5, $s5, -1
	li $t9, 0				# counter
	
	setFrequenciesLoop:
		bge $t9, $s5, doneSetFrequency
		li $t1, 26
		add $t3, $s0, $t9		# current indexing address
		lbu $t4, ($t3)			# load the char at index
		addi $t4, $t4, -97		# normalize characters to a = 0
		bltz $t4, finishSetFrequenciesLoop
		mul $t5, $t4, $t1		# get index for frequency array
		lbu $t4, 1($t3)			# load the char at the next index
		addi $t4, $t4, -97
		bltz $t4, finishSetFrequenciesLoop
		add $t5, $t5, $t4		# $t5 is the index for frequency array
		add $t6, $t5, $s1		# $t6 is the place in memory for frequency index
		
		
		lb $t0, ($t6)			# load the frequency for this pair
		addi $t0, $t0, 1		# increment frequency
		sb $t0, ($t6)
		beq $t0, $s3, checkAlphabetical
		blt $t0, $s3, finishSetFrequenciesLoop
		move $s4, $t5			# if the frequency is greater than max set new max pair
		move $s3, $t0			# also set new max frequency
		finishSetFrequenciesLoop:
		addi $t9, $t9, 1		# increment counter
		j setFrequenciesLoop
	
	
	checkAlphabetical:
		bgt $t5, $s4, finishSetFrequenciesLoop		# check if the pair is alphabetically greater
		move $s4, $t5
		j finishSetFrequenciesLoop
		
	
	doneSetFrequency:	
		beqz $s3, finishBytePairEncodeLoop	
		li $t0, 26
		div $s4, $t0			# divide the index for max frequency by 26 to get the first char
		mflo $t1			# $t1 has the first char
		mfhi $t2			# $t2 has the second char
		addi $t1, $t1, 97	
		addi $t2, $t2, 97
		move $a1, $t1
		move $a2, $t2
		move $a0, $s0
		move $a3, $s7
		addi $a3, $a3, 65
		li $t3, 2
		mul $t0, $s7, $t3		# index in replacement array
		add $t4, $t0, $s2		# address for index in replacement array
		sb $t1, ($t4)			# store the first char
		sb $t2, 1($t4)			# store the second char
		
		jal replace_all_pairs
		add $s6, $s6, $v0
		addi $s7, $s7, -1		# decrement capital letter
		j bytePairEncodeLoop
	
	finishBytePairEncodeLoop:
	move $v0, $s6

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)	
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	addi $sp, $sp, 36	
    	jr $ra

replace_first_char:
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
	lw $t0, 32($sp)				# retrieve fifth arg from stack
	move $s4, $t0				# counter
	
	jal strlen
	move $s5, $v0				# max iters
	move $t0, $s0				# base address
	add $s6, $t0, $s4
	replaceFirstCharLoop:
		lbu $t1, ($s6)	
		beq $t1, $s1, replaceChar			# check if the character matches first of pair
		addi $s4, $s4, 1				# increment counter and address
		addi $s6, $s6, 1	
		blt $s4, $s5, replaceFirstCharLoop		# check terminating condition
		
	li $v0, -1	
	j finishReplaceFirstChar
	
	replaceChar:
		li $a0, 1
		sub $t2, $s5, $s4
		addi $t2, $t2, 1
		move $a2, $t2
		move $a1, $s0
		add $a1, $a1, $s5
		jal shiftString
		sb $s2, ($s6)
		sb $s3, 1($s6)
		move $v0, $s4

	finishReplaceFirstChar:
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


replace_all_chars:
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
	replaceAllCharsLoop:
		move $a0, $s0			# initialize args of replace_first_char
		move $a1, $s1
		move $a2, $s2
		move $a3, $s3
		addi $sp, $sp, -4		
		sw $s4, 0($sp)
	
		jal replace_first_char		# call replace first pair 
		addi $sp, $sp, 4		
		beq $v0, $s6, foundAllChars	# if it returns -1 then all pairs have been found
		move $s4, $v0			# put the return index into s4 so it can be used as arg for next call
		addi $s4, $s4, 1		# increment counters
		addi $s5, $s5, 1
		j replaceAllCharsLoop
	
	foundAllChars:
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


bytepair_decode:
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
	
	li $s2, 50			# counter
	li $s3, 'Z'
	li $s4, 0			# counter for output
	bytePairDecodeLoop:
		add $t0, $s1, $s2
		lbu $t1, ($t0)
		beqz $t1, finishBytePairDecode
		lbu $t2, 1($t0)
		move $a0, $s0
		move $a1, $s3
		move $a2, $t1
		move $a3, $t2
		jal replace_all_chars
		add $s4, $s4, $v0
	
		addi $s2, $s2, -2
		addi $s3, $s3, -1
		bltz $s2, finishBytePairDecode
		j bytePairDecodeLoop
	
	finishBytePairDecode:
	move $v0, $s4
	
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
