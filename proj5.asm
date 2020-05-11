# Peter Christensen
# pwchristense
# 112123806

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text
######## a0 is desired suit | a1 is the pointer to player deck ###############3
findFirstCardOfSuit:
	lw $t0, ($a1)
	li $t1, 0				# counter
	move $t2, $a1
	searchDeck:
		lw $t2, 4($t2)
		lw $t4, ($t2)
		sll $t4, $t4, 8
		srl $t4, $t4, 24
		beq $t4, $a0, foundSuit
		addi $t1, $t1, 1
		blt $t1, $t0, searchDeck
		
	li $v0, -1
	lw $t0, 4($a1)
	lw $v1, ($t0)
	j endFindFirstCardOfSuit
	
	foundSuit:
	move $v0, $t1
	lw $v1, ($t2)
	endFindFirstCardOfSuit:
	jr $ra

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
		lw $t0, ($a0)
		addi $t0, $t0, -1
		sw $t0, ($a0)
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
	ble $t0, $t1, checkSuit
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
	addi $sp, $sp, -36			# preserve registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)

	move $s0, $a0				# deck
	move $s1, $a1				# player array
	move $s2, $a2				# rounds
	
	li $t0, 0				# player counter
	move $t1, $s1
	initPlayers:
		lw $a0, ($t1)
		jal init_list
		addi $t0, $t0, 1
		addi $t1, $t1, 4
		li $t2, 4
		blt $t0, $t2, initPlayers
	
	move $a0, $s0
	move $a1, $s1
	li $a2, 4
	li $a3, 13
	jal deal_cards
	
	li $s3, 0				# player counter
	move $s4, $s1
	findTwoClubs:
		lw $a0, ($s4)
		li $a1, 0x433255			
		jal index_of
		bgez $v0, foundTwoClubs
		addi $s3, $s3, 1
		addi $s4, $s4, 4
		li $t0, 4
		blt $s3, $t0, findTwoClubs
	
	foundTwoClubs:	
	lw $a0, ($s4)
	li $a1, 0x433255
	jal remove
	
	li $s4, 0
	li $s5, 0
	
	addi $sp, $sp, -12
	li $t0, -1
	sw $t0, 0($sp)
	sw $0, 4($sp)
	sw $0, 8($sp)
	
	li $t0, 3
	bge $s3, $t0, resetPlayerCounter
	addi $s3, $s3, 1
	j dontReset
	resetPlayerCounter:
	li $s3, 0
	dontReset:
	
	li $s6, 0
	playClubsLoop:
		li $t0, 0
		move $t1, $s1
		goToPlayerLoop:
			lw $s4, ($t1)
			addi $t0, $t0, 1
			addi $t1, $t1, 4
			ble $t0, $s3, goToPlayerLoop
		
		li $a0, 'C'
		move $a1, $s4
		jal findFirstCardOfSuit
		move $s5, $v1
		sll $t0, $v1, 16
		srl $t0, $t0, 24
		lw $t1, 4($sp)
		
		li $t9, '9'
		ble $t1, $t9, checkNumValue
		ble $t0, $t9, notHighestRank
		
		li $t9, 'T'
		beq $t0, $t9, notHighestRank
		li $t9, 'J'
		beq $t0, $t9, checkIfQueenKingAce
		li $t9, 'Q'
		beq $t0, $t9, checkIfKingAce
		li $t9, 'K'
		beq $t0, $t9, checkIfAce
		j highestRank
		
		checkIfAce:
			li $t9, 'A'
			beq $t1, $t9, notHighestRank
			j highestRank
		checkIfKingAce:
			li $t9, 'A'
			beq $t1, $t9, notHighestRank
			li $t9, 'K'
			beq $t1, $t9, notHighestRank
			j highestRank
		checkIfQueenKingAce:
			li $t9, 'A'
			beq $t1, $t9, notHighestRank
			li $t9, 'K'
			beq $t1, $t9, notHighestRank
			li $t9, 'Q'
			beq $t1, $t9, notHighestRank	
			j highestRank
		checkNumValue:
			blt $t0, $t9, notHighestRank	
		highestRank:
			sw $s3, 0($sp)
			sw $t0, 4($sp)
		notHighestRank:
		move $a0, $v1
		jal card_points
		lw $t0, 8($sp)
		add $t0, $t0, $v0
		sw $t0, 8($sp)
		
		move $a0, $s4
		move $a1, $s5
		jal remove
		
		addi $s6, $s6, 1
		li $t0, 3
		bge $s3, $t0, resetPlayer
		addi $s3, $s3, 1
		j dontReset_2
		resetPlayer:
		li $s3, 0
		dontReset_2:
		blt $s6, $t0, playClubsLoop
		
	li $s4, 0
	li $s5, 0
	li $s6, 0
	li $s7, 0
	
	lw $t0, ($sp)
	lw $t1, 8($sp)
	li $t9, 'H'
	lw $t8, 16($sp)	
	bne $t9, $t8, dontIncrementScore		
	addi $t1, $t1, 1
	dontIncrementScore:
	bnez $t0, playerTwo
	add $s4, $s4, $t1
	playerTwo:
	li $t2, 1
	bne $t0, $t2, playerThree
	add $s5, $s5, $t1
	playerThree:
	li $t2, 2
	bne $t0, $t2, playerFour
	add $s6, $s6, $t1
	playerFour:
	add $s7, $s7, $t1
	
	lw $s3, 0($sp)	
	addi $sp, $sp, 12
	
	# s3 is player who goes first next round
	addi $sp, $sp -4
	li $t0, 2
	sw $t0, ($sp)							# round counter
	playRoundsLoop:
		addi $sp, $sp, -28
		li $t0, -1
		sw $t0, 0($sp)
		sw $0, 4($sp)
		sw $0, 8($sp)
		sw $0, 12($sp)				# address of player
		sw $0, 16($sp)				# suit
		sw $0, 20($sp)				# players done with turn counter
		sw $0, 24($sp)				# card to remove
		
		li $t0, 0
		move $t1, $s1
		goToPlayerLoop_2:
			lw $t2, ($t1)
			sw $t2, 12($sp)
			addi $t0, $t0, 1
			addi $t1, $t1, 4
			ble $t0, $s3, goToPlayerLoop_2
		
		lw $t0, 12($sp)
		move $a0, $t0
		jal draw_card
		sw $v1, 16($sp)
		
		li $t0, 3
		bge $s3, $t0, resetPlayerCounter_2
		addi $s3, $s3, 1
		j dontReset_3
		resetPlayerCounter_2:
		li $s3, 0
		dontReset_3:
		playSuitLoop:
			li $t0, 0
			move $t1, $s1
			goToPlayerLoop_3:
				lw $t2, ($t1)
				sw $t2, 12($sp)
				addi $t0, $t0, 1
				addi $t1, $t1, 4
				ble $t0, $s3, goToPlayerLoop_3
			lw $t9, 16($sp)
			sll $t0, $t9, 8
			srl $t0, $t0, 24
			move $a0, $t0
			lw $t0, 12($sp)
			move $a1, $t0
			jal findFirstCardOfSuit
			
			sw $v1, 24($sp)
			sll $t0, $v1, 16
			srl $t0, $t0, 24
			lw $t1, 4($sp)
			li $t9, '9'
			ble $t1, $t9, checkNumValue_2
			ble $t0, $t9, notHighestRank_2
		
			li $t9, 'T'
			beq $t0, $t9, notHighestRank_2
			li $t9, 'J'
			beq $t0, $t9, checkIfQueenKingAce_2
			li $t9, 'Q'
			beq $t0, $t9, checkIfKingAce_2
			li $t9, 'K'
			beq $t0, $t9, checkIfAce_2
			j highestRank_2
		
			checkIfAce_2:
				li $t9, 'A'
				beq $t1, $t9, notHighestRank_2
				j highestRank_2
			checkIfKingAce_2:
				li $t9, 'A'
				beq $t1, $t9, notHighestRank_2
				li $t9, 'K'
				beq $t1, $t9, notHighestRank_2
				j highestRank_2
			checkIfQueenKingAce_2:
				li $t9, 'A'
				beq $t1, $t9, notHighestRank_2
				li $t9, 'K'
				beq $t1, $t9, notHighestRank_2
				li $t9, 'Q'
				beq $t1, $t9, notHighestRank_2	
				j highestRank_2
			checkNumValue_2:
				blt $t0, $t9, notHighestRank_2	
			highestRank_2:
				sw $s3, 0($sp)
				sw $t0, 4($sp)
			notHighestRank_2:
			move $a0, $v1
			jal card_points
			lw $t0, 8($sp)
			add $t0, $t0, $v0
			sw $t0, 8($sp)
		
			lw $a0, 12($sp)
			lw $a1, 24($sp)
			jal remove
			
			lw $t0, 20($sp)
			addi $t0, $t0, 1
			sw $t0, 20($sp)
			li $t0, 3
			bge $s3, $t0, resetPlayer_2
			addi $s3, $s3, 1
			j dontReset_4
			resetPlayer_2:
			li $s3, 0
			dontReset_4:
			lw $t1, 20($sp)
			blt $t1, $t0, playSuitLoop
		
		lw $t0, ($sp)
		lw $t1, 8($sp)
		li $t9, 'H'
		lw $t8, 16($sp)
		sll $t8, $t8, 8
		srl $t8, $t8, 24	
		bne $t9, $t8, dontIncrementScore_2		
		addi $t1, $t1, 1
		dontIncrementScore_2:
		bnez $t0, playerTwo_2
		add $s4, $s4, $t1
		j endScoring
		playerTwo_2:
		li $t2, 1
		bne $t0, $t2, playerThree_2
		add $s5, $s5, $t1
		j endScoring
		playerThree_2:
		li $t2, 2
		bne $t0, $t2, playerFour_2
		add $s6, $s6, $t1
		j endScoring
		playerFour_2:
		add $s7, $s7, $t1
		
		endScoring:
		lw $s3, ($sp)	
		addi $sp, $sp, 28
		
		lw $t0, ($sp)
		addi $t0, $t0, 1
		sw $t0, ($sp)
		ble $t0, $s2, playRoundsLoop
		
	addi $sp, $sp, 4
	
	move $s0, $s7
	sll $s0, $s0, 8
	add $s0, $s0, $s6
	sll $s0, $s0, 8
	add $s0, $s0, $s5
	sll $s0, $s0, 8
	add $s0, $s0, $s4
	move $v0, $s0
	
	lw $ra, 0($sp)				# restore registers
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

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
