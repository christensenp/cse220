# Peter Christensen
# pwchristense
# 112123806

.text
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
	addi $sp, $sp, -16			# preserve registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	move $s0, $a0				# store args
	move $s1, $a1
	move $s2, $a2
	
	jal strlen				# get string length
	move $t0, $v0
	bltz $s2, invalidIndex			# check if index is valid
	bgt $s2, $t0, invalidIndex
	
	add $t1, $t0, $s0			# store address for end of string	
	#addi $t1, $t1, -1
	sub $t2, $t0, $a2 			# number of iterations		
	li $t3, 0				# counter
	shiftStringLoop:
		bgt $t3, $t2, insertChar	# check terminating condition
		lbu $t4, ($t1)			# load the chararacter
		sb $t4, 1($t1)			# store the character into the next byte
		addi $t3, $t3, 1		# increment counter
		addi $t1, $t1, -1		# move the character to the left
		j shiftStringLoop
	insertChar:
		add $t5, $s0, $s2 		# insert the character at the index
		sb $s1, ($t5)
	addi $t0, $t0, 1			# increment string length
	move $v0, $t0
	j donePartTwo
	
	invalidIndex:
		li $v0, -1
	donePartTwo:
	lw $ra, 0($sp)				# restore registers
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra

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
		bgt $s2, $s1, ghostAtEnd	# if max iters reached stop eating
		j eatCharLoop
	checkIfAtStart:				# check if the ghost is the first char
		beqz $s2, ghostAtStart		
		li $t2, '<'			# if isn't then replace the last underscore with a <
		addi $s3, $s3, -1
		addi $s2, $s2, -1
		sb $t2, ($s3)
		j returnPacMan	
	ghostAtStart:				# if it's not in the middle then insert the < at the counter
		move $a0, $s0
		li $a1, '<'
		move $a2, $s2
		jal insert
		j returnPacMan
	ghostAtEnd:
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
	jr $ra

replace_all_pairs:
	jr $ra

bytepair_encode:
    jr $ra

replace_first_char:
    jr $ra

replace_all_chars:
    jr $ra

bytepair_decode:
    jr $ra
