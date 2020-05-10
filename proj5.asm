# Peter Christensen
# pwchristense
# 112123806

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text

# Part 1
init_list:
	sw $0, ($a0)
	sw $0, 4($a0)
	jr $ra

# Part 2
append:
	move $t0, $a0
	li $a0, 8
	li $v0, 9
	syscall
	
	sw $a1, ($v0)
	sw $0, 4($v0)
	
	lw $t1, ($t0)
	addi $t1, $t1, 1
	sw $t1, ($t0)
	
	lw $t2, 4($t0)
	move $t3, $t0 
	loopThroughList:
		beqz $t2, endOfList
		move $t3, $t2
		lw $t2, 4($t2)
		j loopThroughList
	
	endOfList:
	sw $v0, 4($t3)
	move $v0, $t1
	jr $ra


# Part 3
insert:
	addi $sp, $sp, -16			# preserve registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)

	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	
	bltz $s2 invalidIndex
	lw $t0, ($s0)
	bgt $s2, $t0 invalidIndex
	beq $s2, $t0 appendNode

	li $t0, 0				# node counter
	move $t1, $s0				# starting node
	goToIndexLoop:
		bge $t0, $s2, atIndex
		lw $t1, 4($t1)
		addi $t0, $t0, 1
		j goToIndexLoop
		
	atIndex:
		li $a0, 8
		li $v0, 9
		syscall
		lw $t0, 4($t1)
		sw $v0, 4($t1)
		sw $s1, ($v0)
		sw $t0, 4($v0)
		
	lw $t0, ($s0)
	addi $t0, $t0, 1
	move $v0, $t0
	j endInsert

	invalidIndex:
		li $v0, -1
		j endInsert
	appendNode:
		move $a0, $s0
		move $a1, $s1
		jal append
		
	endInsert:
	lw $ra, 0($sp)				# restore registers
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra


# Part 4
get_value:
	bltz $a1 invalidIndex_get
	lw $t0, ($a0)
	bge $a1, $t0 invalidIndex_get
	beqz $t0, invalidIndex_get
	
	li $t0, 0				# node counter
	lw $t1, 4($a0)				# starting node
	goToIndexLoop_get:
		bge $t0, $a1, atIndex_get
		lw $t1, 4($t1)
		addi $t0, $t0, 1
		j goToIndexLoop_get
	
	atIndex_get:
	lw $v1, ($t1)
	li $v0, 0
	j endGetValue
	
	invalidIndex_get:
		li $v0, -1
		li $v1, -1
	endGetValue:
	jr $ra

# Part 5
set_value:
	bltz $a1 invalidIndex_set
	lw $t0, ($a0)
	bge $a1, $t0 invalidIndex_set
	beqz $t0, invalidIndex_set
	
	li $t0, 0				# node counter
	lw $t1, 4($a0)				# starting node
	goToIndexLoop_set:
		bge $t0, $a1, atIndex_set
		lw $t1, 4($t1)
		addi $t0, $t0, 1
		j goToIndexLoop_set
	
	atIndex_set:
	lw $v1, ($t1)
	li $v0, 0
	sw $a2, ($t1)
	j endSetValue

	invalidIndex_set:
		li $v0, -1
		li $v1, -1
	endSetValue:
	jr $ra

# Part 6
index_of:
	lw $t2, ($a0)
	beqz $t2, emptyList
	
	li $t0, 0					# node counter
	lw $t1, 4($a0)					# starting node
	findNum:
		lw $t3, ($t1)
		beq $t3, $a1, numFound
		lw $t1, 4($t1)
		addi $t0, $t0, 1
		blt $t0, $t2, findNum
	emptyList:
		li $v0 -1
		j endIndexOf
	numFound:
	move $v0, $t0
	endIndexOf:
	jr $ra

# Part 7
remove:
	lw $t2, ($a0)
	beqz $t2, invalidInput_remove
	
	li $t0, 0					# node counter
	lw $t1, 4($a0)					# starting node
	move $t4, $a0
	findNum_remove:
		lw $t3, ($t1)
		beq $t3, $a1, numFound_remove
		move $t4, $t1
		lw $t1, 4($t1)
		addi $t0, $t0, 1
		blt $t0, $t2, findNum_remove
	invalidInput_remove:
		li $v0, -1
		li $v1, -1
		j endRemove
	numFound_remove:
		lw $t2, 4($t1)
		sw $t2, 4($t4)
		li $v0, 0
		move $v1, $t0	
	endRemove:
	jr $ra

# Part 8
create_deck:
	addi $sp, $sp, -28			# preserve registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)

	li $a0, 8
	li $v0, 9
	syscall
	
	move $s0, $v0				# array list pointer
	move $a0, $v0
	jal init_list
	
	li $s1, 2					# counter
	li $s2, 0x433244				# clubs
	li $s3, 0x443244				# diamonds
	li $s4, 0x483244				# hearts
	li $s5, 0x533244				# spades
	createNumCardsLoop:
		move $a0, $s0
		move $a1, $s2
		jal append
		move $a0, $s0
		move $a1, $s3
		jal append
		move $a0, $s0
		move $a1, $s4
		jal append
		move $a0, $s0
		move $a1, $s5
		jal append
		addi $s1, $s1, 1
		addi $s2, $s2, 0x100
		addi $s3, $s3, 0x100
		addi $s4, $s4, 0x100
		addi $s5, $s5, 0x100
		li $t0, 9
		ble $s1, $t0, createNumCardsLoop
	
	li $a1, 0x435444
	move $a0, $s0
	jal append
	li $a1, 0x445444
	move $a0, $s0
	jal append
	li $a1, 0x485444
	move $a0, $s0
	jal append
	li $a1, 0x535444
	move $a0, $s0
	jal append
			
	li $a1, 0x434A44
	move $a0, $s0
	jal append
	li $a1, 0x444A44
	move $a0, $s0
	jal append
	li $a1, 0x484A44
	move $a0, $s0
	jal append
	li $a1, 0x534A44
	move $a0, $s0
	jal append
	
	li $a1, 0x435144
	move $a0, $s0
	jal append
	li $a1, 0x445144
	move $a0, $s0
	jal append
	li $a1, 0x485144
	move $a0, $s0
	jal append
	li $a1, 0x535144
	move $a0, $s0
	jal append
	
	li $a1, 0x434B44
	move $a0, $s0
	jal append
	li $a1, 0x444B44
	move $a0, $s0
	jal append
	li $a1, 0x484B44
	move $a0, $s0
	jal append
	li $a1, 0x534B44
	move $a0, $s0
	jal append
	
	li $a1, 0x434144
	move $a0, $s0
	jal append
	li $a1, 0x444144
	move $a0, $s0
	jal append
	li $a1, 0x484144
	move $a0, $s0
	jal append
	li $a1, 0x534144
	move $a0, $s0
	jal append
	
	move $v0, $s0
	
	lw $ra, 0($sp)				# restore registers
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	jr $ra

# Part 9
draw_card:
	lw $t0, ($a0)
	beqz $t0, noCards
	
	lw $t0, 4($a0)
	lw $t1, ($t0)
	lw $t0, 4($t0)
	sw $t0, 4($a0)
	move $v1, $t1
	li $v0, 0
	lw $t0, ($a0)
	addi $t0, $t0, -1
	sw $t0, ($a0)
	j endDrawCard
	noCards:
		li $v0, -1
		li $v1, -1
	endDrawCard:
	jr $ra

# Part 10
deal_cards:
	addi $sp, $sp, -32			# preserve registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)

	move $s0, $a0				# deck
	move $s1, $a1				# player arraylist
	move $s2, $a2				# num of players
	move $s3, $a3				# cards per player

	lw $t0, ($s0)
	beqz $t0, invalidInput
	blez $s2, invalidInput
	blez $s3, invalidInput

	li $s4, 0				# cards dealt counter
	li $s5, 0				# player order counter
	lw $s6, ($s0)				# deck size
	dealCardsLoop:
		move $a0, $s0
		jal draw_card
		addi $v1, $v1, 0x11
		
		li $t0, 0			# player iterator counter
		move $t1, $s1
		loopToPlayer:
			lw $t2, ($t1)
			addi $t0, $t0, 1
			addi $t1, $t1, 4
			ble $t0, $s5 loopToPlayer
		
		move $a0, $t2
		move $a1, $v1
		jal append
		
		addi $s4, $s4, 1
		addi $s5, $s5, 1
		bne $s5, $s2, dontResetPlayerCounter
		li $s5, 0
		dontResetPlayerCounter:
		bge $s4, $s6, stopDealing
		mul $t0, $s2, $s3
		bge $s4, $t0, stopDealing
		j dealCardsLoop
		
	stopDealing:
		move $v0, $s4
		j endDealCards
	invalidInput:
		 li $v0, -1	
	endDealCards:
	lw $ra, 0($sp)				# restore registers
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	addi $sp, $sp, 32
	jr $ra
	jr $ra

# Part 11
card_points:
	sll $t1, $a0, 24
	srl $t1, $t1, 24
	li $t0, 'U'
	beq $t1, $t0, checkVal
	li $t0, 'D'
	bne $t1, $t0, invalidCard
	
	checkVal:
	sll $t0, $a0, 16
	srl $t0, $t0, 24
	li $t1, '2'
	blt $t0, $t1, invalidCard
	li $t1, '9'
	blt $t0, $t1, checkSuit
	li $t1, 'T'
	beq $t0, $t1, checkSuit
	li $t1, 'J'
	beq $t0, $t1, checkSuit
	li $t1, 'Q'
	beq $t0, $t1, checkSuit
	li $t1, 'K'
	beq $t0, $t1, checkSuit
	li $t1, 'A'
	beq $t0, $t1, checkSuit
	j invalidCard	
				
	checkSuit:
	sll $t1, $a0, 8
	srl $t1, $t1, 24
	li $t2, 'C'
	beq $t1, $t2, noPoints
	li $t2, 'D'
	beq $t1, $t2, noPoints
	li $t2, 'H'
	beq $t1, $t2, onePoint
	li $t2, 'S'
	bne $t1, $t2, invalidCard
	li $t3, 'Q'
	beq $t0, $t3, thirteenPoints
	noPoints:
		li $v0, 0
		j endCardPoints
	onePoint:
		li $v0, 1
		j endCardPoints
	thirteenPoints:
		li $v0, 13
		j endCardPoints
	invalidCard:
		li $v0, -1
	endCardPoints:
	jr $ra

# Part 12
simulate_game:
jr $ra

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
