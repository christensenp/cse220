# Peter Christensen
# pwchristensen
# 112123806

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text


####### shifts row of board either left or right starting from a given position ###### a0 is the game board | a1 is the shift direction | a2 is the row | a3 is the starting col ############
shift_row:
	addi $sp, $sp, -20			# preserve registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	move $s0, $a0
	move $s1, $a2
	move $s2, $a3					# pos for setting col
	
	li $t0, -1
	beq $a1, $t0, shiftRowLeft
	
	shiftRowRight:
	move $s3, $s2
	addi $s3, $s3, -1				# pos for getting col
	
	move $a0, $s0					# get the left tile
	move $a1, $s1
	move $a2, $s3
	jal get_tile
	move $a0, $s0					# set the right tile to the left tile
	move $a1, $s1
	move $a2, $s2
	move $a3, $v0
	jal set_tile
	
	addi $s2, $s2, -1
	addi $s3, $s3, -1
	bgez $s3, shiftRowRight
	
	move $a0, $s0					# shift in a zero
	move $a1, $s1
	move $a2, $0
	move $a3, $0
	jal set_tile
	j endShiftRow
	
	
	shiftRowLeft:
	move $s3, $s2
	addi $s3, $s3, 1				# pos for getting col
	
	move $a0, $s0					# get the left tile
	move $a1, $s1
	move $a2, $s3
	jal get_tile
	move $a0, $s0					# set the right tile to the left tile
	move $a1, $s1
	move $a2, $s2
	move $a3, $v0
	jal set_tile
	
	addi $s2, $s2, 1
	addi $s3, $s3, 1
	lb $t0, 1($s0)
	addi $t0, $t0, -1
	ble $s3, $t0, shiftRowLeft
	
	lb $t0, 1($s0)
	addi $t0, $t0, -1
	move $a0, $s0					# shift in a zero
	move $a1, $s1
	move $a2, $t0
	move $a3, $0
	jal set_tile
	j endShiftRow

	endShiftRow:
	lw $ra, 0($sp)				# restore registers
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra

####### shifts col of board either up or down starting from a given position ###### a0 is the game board | a1 is the shift direction | a2 is the col | a3 is the starting row ############
shift_col:
	addi $sp, $sp, -20			# preserve registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	move $s0, $a0
	move $s1, $a2
	move $s2, $a3					# pos for setting row
	
	li $t0, -1
	beq $a1, $t0, shiftColUp
	
	shiftColDown:
	move $s3, $s2
	addi $s3, $s3, -1				# pos for getting row
	
	move $a0, $s0					# get the top tile
	move $a1, $s3
	move $a2, $s1
	jal get_tile
	move $a0, $s0					# set the bottom tile to the left tile
	move $a1, $s2
	move $a2, $s1
	move $a3, $v0
	jal set_tile
	
	addi $s2, $s2, -1
	addi $s3, $s3, -1
	bgez $s3, shiftColDown
	
	move $a0, $s0					# shift in a zero
	move $a1, $0
	move $a2, $s1
	move $a3, $0
	jal set_tile
	j endShiftRow
	
	
	shiftColUp:
	move $s3, $s2
	addi $s3, $s3, 1				# pos for getting row
	
	move $a0, $s0					# get the top tile
	move $a1, $s3
	move $a2, $s1
	jal get_tile
	move $a0, $s0					# set the bottom tile to the top tile
	move $a1, $s2
	move $a2, $s1
	move $a3, $v0
	jal set_tile
	
	addi $s2, $s2, 1
	addi $s3, $s3, 1
	lb $t0, ($s0)
	addi $t0, $t0, -1
	ble $s3, $t0, shiftColUp
	
	lb $t0, ($s0)
	addi $t0, $t0, -1
	move $a0, $s0					# shift in a zero
	move $a1, $t0
	move $a2, $s1
	move $a3, $0
	jal set_tile
	j endShiftCol

	endShiftCol:
	lw $ra, 0($sp)				# restore registers
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra

###########3 checks every tile of a board for a specific value ######### a0 is the board | a1 is the value #####################3
check_all_tiles:
	addi $sp, $sp, -28			# preserve registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)

	move $s0, $a0
	move $s1, $a1
	lb $s4, ($s0)
	lb $s5, 1($s0)
	addi $s5, $s5, -1
	addi $s4, $s4, -1
		
	li $s2, 0				# row counter
	checkRowLoop:
		li $s3, 0			# col counter
		checkColLoop:
			move $a0, $s0
			move $a1, $s2
			move $a2, $s3
			jal get_tile
			beq $v0, $s1, keyFound
			addi $s3, $s3, 1
			blt $s3, $s5, checkColLoop
		addi $s2, $s2, 1
		blt $s2, $s4, checkRowLoop
	li $v0, -1
	j endCheckTiles

	keyFound:
		li $v0, 1	
	
	endCheckTiles:
	lw $ra, 0($sp)				# restore registers
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	jr $ra

# Part I
load_game_file:
	addi $sp, $sp, -4
	sw $s0, 0($sp)

	li $v0, 13
	move $s0, $a0
	move $a0, $a1
	li $a1, 0
	li $a2, 0
	syscall
	move $t0, $v0
	
	bltz $t0, fileError
	
	li $t2, 0			# counter for nonzero tiles
	li $t9, 10
	readFromFileLoop:
		addi $sp, $sp, -1
		move $a0, $t0
		move $a1, $sp
		li $t5, 0
		li $t6, 0
		li $t7, 0
		li $t8, 0
		
		findNumLoop:
			li $a2, 1
			li $v0, 14
			syscall
			blez $v0, endOfFile
			lb $t4, ($sp)
			addi $t4, $t4, -48
			bltz $t4, findNumLoop
		

		li $a2, 1
		li $v0, 14
		syscall
		bltz $v0, fileError
		beqz $v0, numberEnded
		lb $t5, ($sp)
		addi $t5, $t5, -48
		bltz $t5, numberEnded1
		mul $t4, $t4, $t9
		
		li $a2, 1
		li $v0, 14
		syscall
		bltz $v0, fileError
		beqz $v0, numberEnded
		lb $t6, ($sp)
		addi $t6, $t6, -48
		bltz $t6, numberEnded2
		mul $t4, $t4, $t9
		mul $t5, $t5, $t9
		
		li $a2, 1
		li $v0, 14
		syscall
		bltz $v0, fileError
		beqz $v0, numberEnded
		lb $t7, ($sp)
		addi $t7, $t7, -48
		bltz $t7, numberEnded3
		mul $t4, $t4, $t9
		mul $t5, $t5, $t9
		mul $t6, $t6, $t9
		
		li $a2, 1
		li $v0, 14
		syscall
		bltz $v0, fileError
		beqz $v0, numberEnded
		lb $t8, ($sp)
		addi $t8, $t8, -48
		bltz $t8, numberEnded4
		mul $t4, $t4, $t9
		mul $t5, $t5, $t9
		mul $t6, $t6, $t9
		mul $t7, $t7, $t9
		j numberEnded
		
		
		numberEnded1:
		li $t5, 0
		numberEnded2:
		li $t6, 0
		numberEnded3:
		li $t7, 0
		numberEnded4:
		li $t8, 0
		
		numberEnded:
		add $t1, $t4, $t5
		add $t1, $t1, $t6
		add $t1, $t1, $t7
		add $t1, $t1, $t8
		
		li $t3, 2
		blt $t2, $t3, initRowCol
		
		sh $t1, ($s0)
		addi $s0, $s0, 2
		
		beqz $t1, dontIncrement
		
		j endReadFromFileLoop
		
		initRowCol:
			sb $t1, ($s0)
			addi $s0, $s0, 1
			
		endReadFromFileLoop:
			addi $t2, $t2, 1
		
		dontIncrement: 
	
		addi $sp, $sp, 1
		j readFromFileLoop
		
	
	fileError:
		li $v0, -1
		j finishLoadBoard

	endOfFile:
	addi $sp, $sp, 1
	li $v0, 16
	move $a0, $t0
	syscall
	addi $t2, $t2, -2
	move $v0, $t2
	
	finishLoadBoard:
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	jr $ra

# Part II
save_game_file:
	
	li $v0, 13
	move $t0, $a0
	move $a0, $a1
	li $a1, 1
	li $a2, 0
	syscall
	move $t1, $v0
	bltz $t1, fileErrorSave

	addi $sp, $sp, -1			
	lb $t9, ($t0)
	addi $t0, $t0, 1
	addi $t9, $t9, 48
	sb $t9, 0($sp)
	
	move $a0, $t1			# write rows
	move $a1, $sp
	li $a2, 1
	li $v0, 15
	syscall 

	addi $sp, $sp, -1
	li $t2, 32
	sb $t2, ($sp)
	
	move $a0, $t1			# write space
	move $a1, $sp
	li $a2, 1
	li $v0, 15
	syscall 

	lb $t8, ($t0)
	addi $t0, $t0, 1
	addi $t8, $t8, 48
	addi $sp, $sp, -1
	sb $t8, ($sp)

	move $a0, $t1			# write cols
	move $a1, $sp
	li $a2, 1
	li $v0, 15
	syscall 
	
	addi $sp, $sp, -1
	li $t2, 10
	sb $t2, ($sp)
	
	move $a0, $t1			# write newline
	move $a1, $sp
	li $a2, 1
	li $v0, 15
	syscall 
	
	addi $sp, $sp 4
	
	
	addi $sp, $sp, -2
	li $t2, 32
	sb $t2, ($sp)
	li $t2, 10
	sb $t2, 1($sp)
	move $fp, $sp
	
	addi $t8, $t8, -48
	addi $t9, $t9, -48
	
	
	li $t4, 0			# counter for rows
	writeBoardToFileLoop:
		bge $t4, $t9, endSaveFile 
	
	
	li $t2, 1			# counter for cols
	writeBoardRows:
		addi $sp, $sp, -1
		lh $t3, ($t0)
		addi $t0, $t0, 2
		
		li $t5, 10
		blt $t3, $t5, singleDigit

		li $t5, 100
		blt $t3, $t5, doubleDigit
		
		li $t5, 1000
		blt $t3, $t5, tripleDigit
		
		li $t5, 10000
		blt $t3, $t5, quadDigit
		
		div $t3, $t5
		mflo $t6
		addi $t6, $t6, 48
		sb $t6, ($sp)
		move $a0, $t1
		move $a1, $sp
		li $a2, 1
		li $v0, 15
		syscall 
		addi $t6, $t6, -48
		mul $t6, $t6, $t5
		sub $t3, $t3, $t6
		
		quadDigit:
			li $t5, 1000
			div $t3, $t5
			mflo $t6
			addi $t6, $t6, 48
			sb $t6, ($sp)
			move $a0, $t1
			move $a1, $sp
			li $a2, 1
			li $v0, 15
			syscall 
			addi $t6, $t6, -48
			mul $t6, $t6, $t5	
			sub $t3, $t3, $t6

		tripleDigit:
			li $t5, 100
			div $t3, $t5
			mflo $t6
			addi $t6, $t6, 48
			sb $t6, ($sp)
			move $a0, $t1
			move $a1, $sp
			li $a2, 1
			li $v0, 15
			syscall 
			addi $t6, $t6, -48	
			mul $t6, $t6, $t5
			sub $t3, $t3, $t6
			

		doubleDigit:
			li $t5, 10
			div $t3, $t5
			mflo $t6
			addi $t6, $t6, 48
			sb $t6, ($sp)
			move $a0, $t1
			move $a1, $sp
			li $a2, 1
			li $v0, 15
			syscall 
			addi $t6, $t6, -48
			mul $t6, $t6, $t5
			sub $t3, $t3, $t6																																																																																											
																																																																																																																						
		singleDigit:
			addi $t3, $t3, 48
			sb $t3, ($sp)
			move $a0, $t1
			move $a1, $sp
			li $a2, 1
			li $v0, 15
			syscall 
		
		
		addi $sp, $sp, 1
		bge $t2, $t8, printNewLine
	
		move $a0, $t1
		move $a1, $fp
		li $a2, 1
		li $v0, 15
		syscall 
		
		addi $t2, $t2, 1
		
		j writeBoardRows
	
	printNewLine:
		move $a0, $t1
		addi $fp, $fp, 1
		move $a1, $fp
		addi $fp, $fp, -1
		li $a2, 1
		li $v0, 15
		syscall 
		addi $t4, $t4, 1
		j writeBoardToFileLoop

	j endSaveFile
	
	fileErrorSave:
		li $v0, -1
	endSaveFile:
	addi $sp, $sp, 2
	li $v0, 16
	move $a0, $t1
	syscall
	li $v0, 1
	
	jr $ra

# Part III
get_tile:
	lb $t0, ($a0)
	lb $t1, 1($a0)
	
	bge $a1, $t0, outOfBoundsError
	bge $a2, $t1, outOfBoundsError
	
	addi $a0, $a0, 2
	
	
	mul $t2, $a1, $t1
	add $t2, $t2, $a2
	li $t3, 2
	mul $t2, $t2, $t3
	
	add $a0, $a0, $t2
	lhu $t2, ($a0)
	move $v0, $t2
	
	j endGetTile
	
	outOfBoundsError:
		li $v0, -1
	endGetTile:
	jr $ra

# Part IV
set_tile:
	bltz $a3, invalidValue
	li $t0, 49152
	bgt $a3, $t0, invalidValue
	
	lb $t0, ($a0)
	lb $t1, 1($a0)
	addi $a0, $a0, 2
	
	bge $a1, $t0, invalidValue
	bge $a2, $t1, invalidValue
	
	mul $t2, $a1, $t1
	add $t2, $t2, $a2
	li $t3, 2
	mul $t2, $t2, $t3
	
	add $a0, $a0, $t2
	sh $a3, ($a0)
	move $v0, $a3
	j endSetTile
	
	invalidValue:
		li $v0, -1
	endSetTile:
	jr $ra

# Part V
can_be_merged:
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
	lw $s4, 32($sp)				# retrieve fifth arg from stack

	lb $s5, ($s0)
	lb $s6, 1($s0)
	
	bge $s1, $s5, invalidInput_merge	# check if rows and cols are valid
	bge $s2, $s6, invalidInput_merge
	bge $s3, $s5, invalidInput_merge
	bge $s4, $s6, invalidInput_merge

	li $t0, 1
	li $t1, -1
	
	sub $t2, $s1, $s3
	beq $t2, $t0, validRowChange
	beq $t2, $t1, validRowChange
	bnez $t2, invalidInput_merge
	
	sub $t2, $s2, $s4
	beq $t2, $t0, validInput_merge
	beq $t2, $t1, validInput_merge
	j invalidInput_merge
	
	validRowChange:
	sub $t2, $s2, $s4
	bnez $t2, invalidInput_merge
	
	validInput_merge:
	move $a0, $s0				# get value of first tile
	move $a1, $s1
	move $a2, $s2
	jal get_tile
	bltz $v0, invalidInput_merge
	move $s5, $v0
	
	move $a0, $s0				# get value of second tile
	move $a1, $s3
	move $a2, $s4
	jal get_tile
	bltz $v0, invalidInput_merge
	move $s6, $v0
	
	li $t0, 3				# check if tiles values are compatible
	blt $s5, $t0, firstTileLessThree
	
	bne $s5, $s6, invalidInput_merge
	j validTiles
	
	firstTileLessThree:
	li $t0, 1
	beq $s5, $t0, checkSecondEqualTwo
	li $t0, 2
	beq $s5, $t0, checkSecondEqualOne
	j invalidInput_merge
	
	checkSecondEqualTwo:
	li $t0, 2
	bne $s6, $t0, invalidInput_merge
	j validTiles
	
	checkSecondEqualOne:
	li $t0, 1
	bne $s6, $t0, invalidInput_merge
	j validTiles
	
	
	

	invalidInput_merge:
		li $v0, -1
		j endMerge
	
	validTiles:
	add $t0, $s5, $s6
	move $v0, $t0

	endMerge:
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

# Part VI
slide_row:
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
	
	lb $t0, ($s0)
	bge $s1, $t0, invalidArgs_row 		# check if rows and cols are valid
	
	li $t0, -1
	li $s5, 1
	beq $s2, $t0, shiftLeft
	li $t0, 1
	bne $s2, $t0, invalidArgs_row
	
	
	lb $s3, 1($s0)				# counter for col position
	addi $s3, $s3, -1
	
	checkRowFromRight:
	beqz $s3, noMerges
	move $a0, $s0
	move $a1, $s1
	move $a2, $s3
	jal get_tile
	beqz $v0, shiftRowRightNoMerge
	
	move $a0, $s0
	move $a1, $s1
	move $a2, $s3
	move $a3, $s1
	addi $s3, $s3, -1
	addi $sp, $sp -4
	sw $s3, 0($sp)
	jal can_be_merged
	addi $sp, $sp, 4	
	bltz $v0, checkRowFromRight		# check if the merge can be done
	
	move $a0, $s0				# merge two tiles 
	move $a1, $s1
	addi $s3, $s3, 1
	move $a2, $s3
	move $a3, $v0
	jal set_tile
	j shiftRowRightMerge
	
	shiftRowRightNoMerge:
	addi $s3, $s3, 1
	li $s5, 0
	
	shiftRowRightMerge:
	move $a0, $s0
	move $a1, $s2
	move $a2, $s1
	addi $s3, $s3, -1
	move $a3, $s3
	jal shift_row
	li $v0, 1
	bnez $s5, endSlideRow
	li $v0, 0
	j endSlideRow
	
	shiftLeft:
	li $s3, 0				# counter for col position
	lb $s4, 1($s0)				# terminating condition
	addi $s4, $s4, -1
	
	checkRowFromLeft:
	bge $s3, $s4, noMerges
	move $a0, $s0
	move $a1, $s1
	move $a2, $s3
	jal get_tile
	beqz $v0, shiftRowLeftNoMerge
	
	move $a0, $s0
	move $a1, $s1
	move $a2, $s3
	move $a3, $s1
	addi $s3, $s3, 1
	addi $sp, $sp -4
	sw $s3, 0($sp)
	jal can_be_merged
	addi $sp, $sp, 4	
	bltz $v0, checkRowFromLeft		# check if the merge can be done
	
	move $a0, $s0				# merge two tiles 
	move $a1, $s1
	addi $s3, $s3, -1
	move $a2, $s3
	move $a3, $v0
	jal set_tile
	j shiftRowLeftMerge
	
	shiftRowLeftNoMerge:
	addi $s3, $s3, -1
	li $s5, 0
	
	shiftRowLeftMerge:
	move $a0, $s0
	move $a1, $s2
	move $a2, $s1
	addi $s3, $s3, 1
	move $a3, $s3
	jal shift_row
	li $v0, 1
	bnez $s5, endSlideRow
	li $v0, 0
	j endSlideRow

	noMerges:
		li $v0, 0
		j endSlideRow

	invalidArgs_row:
		li $v0, -1
 
	endSlideRow:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)	
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	jr $ra

# Part VII
slide_col:
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
	
	lb $t0, 1($s0)
	bge $s1, $t0, invalidArgs_col		# check if rows and cols are valid
	
	li $t0, -1
	li $s5, 1
	beq $s2, $t0, shiftUp
	li $t0, 1
	bne $s2, $t0, invalidArgs_col
	
	lb $s3, ($s0)				# counter for row position
	addi $s3, $s3, -1
	
	checkColFromBot:
	beqz $s3, noMerges_col
	move $a0, $s0
	move $a1, $s3
	move $a2, $s1
	jal get_tile
	beqz $v0, shiftColDownNoMerge
	
	move $a0, $s0
	move $a1, $s3
	move $a2, $s1
	addi $s3, $s3, -1
	move $a3, $s3
	addi $sp, $sp -4
	sw $s1, 0($sp)
	jal can_be_merged
	addi $sp, $sp, 4	
	bltz $v0, checkColFromBot		# check if the merge can be done
	
	move $a0, $s0				# merge two tiles 
	addi $s3, $s3, 1
	move $a1, $s3
	move $a2, $s1
	move $a3, $v0
	jal set_tile
	j shiftColDownMerge
	
	shiftColDownNoMerge:
	addi $s3, $s3, 1
	li $s5, 0
	
	shiftColDownMerge:
	move $a0, $s0
	move $a1, $s2
	move $a2, $s1
	addi $s3, $s3, -1
	move $a3, $s3
	jal shift_col
	li $v0, 1
	bnez $s5, endSlideCol
	li $v0, 0
	j endSlideCol
	
	shiftUp:
	li $s3, 0				# counter for row position
	lb $s4, ($s0)				# terminating condition
	addi $s4, $s4, -1
	
	checkColFromTop:
	bge $s3, $s4, noMerges_col
	move $a0, $s0
	move $a1, $s3
	move $a2, $s1
	jal get_tile
	beqz $v0, shiftColUpNoMerge
	
	move $a0, $s0
	move $a1, $s3
	move $a2, $s1
	addi $s3, $s3, 1
	move $a3, $s3
	addi $sp, $sp -4
	sw $s1, 0($sp)
	jal can_be_merged
	addi $sp, $sp, 4	
	bltz $v0, checkColFromTop		# check if the merge can be done
	
	move $a0, $s0				# merge two tiles 
	addi $s3, $s3, -1
	move $a1, $s3
	move $a2, $s1
	move $a3, $v0
	jal set_tile
	j shiftColUpMerge
	
	shiftColUpNoMerge:
	addi $s3, $s3, -1
	li $s5, 0
	
	shiftColUpMerge:
	move $a0, $s0
	move $a1, $s2
	move $a2, $s1
	addi $s3, $s3, 1
	move $a3, $s3
	jal shift_col
	li $v0, 1
	bnez $s5, endSlideCol
	li $v0, 0
	j endSlideCol

	noMerges_col:
		li $v0, 0
		j endSlideCol

	invalidArgs_col:
		li $v0, -1
 
	endSlideCol:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)	
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	jr $ra

# Part VIII
slide_board_left:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)

	move $s0, $a0				# preserve args
	lb $s1, ($s0)				# num of rows to slide
	li $s2, 0				# counter
	li $s3, 0 				# sum of returns
	slideRowsLeftLoop:
	move $a0, $s0
	move $a1, $s2
	li $a2, -1
	jal slide_row
	add $s3, $s3, $v0
	addi $s2, $s2, 1
	blt $s2, $s1, slideRowsLeftLoop
	move $v0, $s3

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)	
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra

# Part IX
slide_board_right:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)

	move $s0, $a0				# preserve args
	lb $s1, ($s0)				# num of rows to slide
	li $s2, 0				# counter
	li $s3, 0 				# sum of returns
	slideRowsRightLoop:
	move $a0, $s0
	move $a1, $s2
	li $a2, 1
	jal slide_row
	add $s3, $s3, $v0
	addi $s2, $s2, 1
	blt $s2, $s1, slideRowsRightLoop
	move $v0, $s3

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)	
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra

# Part X
slide_board_up:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)

	move $s0, $a0				# preserve args
	lb $s1, 1($s0)				# num of cols to slide
	li $s2, 0				# counter
	li $s3, 0 				# sum of returns
	slideColsUpLoop:
	move $a0, $s0
	move $a1, $s2
	li $a2, -1
	jal slide_col
	add $s3, $s3, $v0
	addi $s2, $s2, 1
	blt $s2, $s1, slideColsUpLoop
	move $v0, $s3

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)	
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra

# Part XI
slide_board_down:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)

	move $s0, $a0				# preserve args
	lb $s1, 1($s0)				# num of cols to slide
	li $s2, 0				# counter
	li $s3, 0 				# sum of returns
	slideColsDownLoop:
	move $a0, $s0
	move $a1, $s2
	li $a2, 1
	jal slide_col
	add $s3, $s3, $v0
	addi $s2, $s2, 1
	blt $s2, $s1, slideColsDownLoop
	move $v0, $s3

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)	
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra

# Part XII
game_status:
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

	li $a1, 49152
	jal check_all_tiles
	bgtz $v0, gameWon

	li $s1, 0				# row counter 
	li $s2, 0				# row return counter
	lb $s5, ($s0)				# terminating condition
	
	iterateRowsLoop:
	bge $s1, $s5, initColsLoop
	li $s3, 0				# counter for col position
	lb $s4, 1($s0)				# terminating condition
	addi $s4, $s4, -1
	checkRowMoves:
	bge $s3, $s4, noMergesLeft
	move $a0, $s0
	move $a1, $s1
	move $a2, $s3
	jal get_tile
	beqz $v0, incrementCounter
	move $a0, $s0
	move $a1, $s1
	move $a2, $s3
	move $a3, $s1
	addi $s3, $s3, 1
	addi $sp, $sp -4
	sw $s3, 0($sp)
	jal can_be_merged
	addi $sp, $sp, 4	
	bgtz $v0, incrementCounter
	j checkRowMoves
	incrementCounter:
	addi $s2, $s2, 1
	addi $s1, $s1, 1
	j iterateRowsLoop
	
	noMergesLeft:
	lb $s3, 1($s0)				# counter for col position
	addi $s3, $s3, -1
	checkRowMovesRight:
	beqz $s3, noMovesRow
	move $a0, $s0
	move $a1, $s1
	move $a2, $s3
	jal get_tile
	beqz $v0, incrementCounter
	move $a0, $s0
	move $a1, $s1
	move $a2, $s3
	move $a3, $s1
	addi $s3, $s3, -1
	addi $sp, $sp -4
	sw $s3, 0($sp)
	jal can_be_merged
	addi $sp, $sp, 4	
	bgtz $v0, incrementCounter
	j checkRowMovesRight
	
	noMovesRow:
	addi $s1, $s1, 1
	j iterateRowsLoop
	
	initColsLoop:
	li $s1, 0				# col counter 
	li $s6, 0				# col return counter
	lb $s5, 1($s0)				# terminating condition
	
	iterateColsLoop:
	bge $s1, $s5, checkSum
	li $s3, 0				# counter for row position
	lb $s4, 1($s0)				# terminating condition
	addi $s4, $s4, -1
	checkColMoves:
	bge $s3, $s4, initNoMergesUp
	move $a0, $s0
	move $a1, $s3
	move $a2, $s1
	jal get_tile
	beqz $v0, incrementCounter2
	move $a0, $s0
	move $a1, $s3
	move $a2, $s1
	addi $s3, $s3, 1
	move $a3, $s3
	addi $sp, $sp -4
	sw $s1, 0($sp)
	jal can_be_merged
	addi $sp, $sp, 4	
	bgtz $v0, incrementCounter2
	j checkColMoves
	incrementCounter2:
	addi $s6, $s6, 1
	addi $s1, $s1, 1
	j iterateColsLoop
	
	initNoMergesUp:
	lb $s3, ($s0)				# counter for row position
	addi $s3, $s3, -1
	noMergesUp:
	beqz $s3, noMovesCol
	move $a0, $s0
	move $a1, $s3
	move $a2, $s1
	jal get_tile
	beqz $v0, incrementCounter2
	move $a0, $s0
	move $a1, $s3
	move $a2, $s1
	addi $s3, $s3, -1
	move $a3, $s3
	addi $sp, $sp -4
	sw $s1, 0($sp)
	jal can_be_merged
	addi $sp, $sp, 4	
	bgtz $v0, incrementCounter2
	j noMergesUp
	
	noMovesCol:
	addi $s1, $s1, 1
	j iterateColsLoop
	
	checkSum:
	bgtz $s2, hasMoves
	bgtz $s6, hasMoves
	li $v0, -1
	li $v1, -1
	j endGameStatus
	
	
	hasMoves:
	move $v0, $s2
	move $v1, $s6
	j endGameStatus
	
	gameWon:
	li $v0, -2
	li $v1, -2

	endGameStatus:
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

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
