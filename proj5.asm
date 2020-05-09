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
jr $ra

# Part 7
remove:
jr $ra

# Part 8
create_deck:
jr $ra

# Part 9
draw_card:
jr $ra

# Part 10
deal_cards:
jr $ra

# Part 11
card_points:
jr $ra

# Part 12
simulate_game:
jr $ra

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
