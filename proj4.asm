# Peter Christensen
# pwchristense
# 112123806

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text
# Part I
compare_to:
	lhu $t0, 4($a0)			# customer 1 fame
	lhu $t1, 6($a0)			# customer 1 wait time
	lhu $t2, 4($a1) 		# customer 2 fame
	lhu $t3, 6($a1)			# customer 2 wait time
	
	li $t4, 10
	mul $t5, $t1, $t4
	add $t5, $t5, $t0		
	
	mul $t6, $t3, $t4
	add $t6, $t6, $t2
	
	blt $t5, $t6, returnLess
	bgt $t5, $t6, returnGreater
	
	blt $t0, $t2, returnLess
	bgt $t0, $t2, returnGreater
	li $v0, 0
	j endCompareTo
	returnLess:
		li $v0, -1
		j endCompareTo
	returnGreater:
		li $v0, 1
		j endCompareTo
	endCompareTo:
	jr $ra

# Part II
init_queue:
	blez $a1, invalidMaxSize
	
	sh $0, ($a0)
	addi $a0, $a0, 2
	sh $a1, ($a0)	
	addi $a0, $a0, 2
	
	li $t0, 2
	mul $t1, $t0, $a1
	li $t2, 0					# counter
	initCustArray:
		sw $0, ($a0)
		addi $a0, $a0, 4
		addi $t2, $t2, 1
		blt $t2, $t1, initCustArray
	move $v0, $a1
	j endInitQueue
	invalidMaxSize:
		li $v0, -1
	endInitQueue:
	jr $ra

# Part III
memcpy:
	blez $a2, invalidCopySize
	
	li $t0, 0				# counter
	memCopyLoop:
		lb $t1, ($a0)
		sb $t1, ($a1)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		addi $t0, $t0, 1
		blt $t0, $a2, memCopyLoop
	move $v0, $a2
	j endMemCopy
	invalidCopySize:
		li $v0, -1
	endMemCopy:
	jr $ra

# Part IV
contains:
	li $t0,	0				# counter for customers 
	li $t1, 0				# counter for indices in a level of heap
	li $t2, 1				# counter for heap level
	li $t3, 1				# max indices in a heap level
	
	lh $t4, ($a0)				# number of customers to check
	addi $a0, $a0, 4
	checkHeapLevel:
		lw $t5, ($a0)			# id of cust
		beq $t5, $a1, customerFound
		addi $t0, $t0, 1
		addi $t1, $t1, 1
		addi $a0, $a0, 8
		bge $t0, $t4, customerNotFound
		blt $t1, $t3, checkHeapLevel		# check if the level has been traversed
		li $t5, 3
		mul $t3, $t3, $t5
		addi $t2, $t2, 1
		li $t1, 0
		j checkHeapLevel
		
	customerFound:
		move $v0, $t2
		j endContains
	customerNotFound:
		li $v0, -1
	endContains:
	jr $ra

# Part V
enqueue:
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
	
	lw $a1, ($s1)
	jal contains
	bgtz $v0, custAlreadyQueued
	
	lh $t0, ($s0)				# size
	lh $t1, 2($s0)				# max size
	beq $t0, $t1, queueFull
	
	lh $t0, ($s0)
	li $t1, 8
	mul $t0, $t0, $t1
	addi $t0, $t0, 4
	li $t4, 0
	add $t4, $s0, $t0
	move $a0, $s1
	move $a1, $t4
	li $a2, 8
	jal memcpy
	
	lh $t0, ($s0)	
	beqz $t0, queueEmpty
	lh $s2, ($s0)				# index of child
	correctHeapLoop:
		addi $t1, $s2, -1
		li $t2, 3
		div $t1, $t2
		mflo $s3				# index of parent
		
		li $t0, 8
		mul $t1, $s2, $t0
		mul $t2, $s3, $t0
		addi $t1, $t1, 4
		addi $t2, $t2, 4
		
		add $s4, $t2, $s0
		add $s5, $t1, $s0
		move $a0, $s4
		move $a1, $s5
		jal compare_to
		blez $v0, successInsert
		
		addi $sp, $sp, -8
		move $a0, $s5
		move $a1, $sp
		li $a2, 8
		jal memcpy
		
		move $a0, $s4
		move $a1, $s5
		li $a2, 8
		jal memcpy
		
		move $a0, $sp
		move $a1, $s4
		li $a2, 8 
		jal memcpy
		addi $sp, $sp, 8
		move $s2, $s3
		j correctHeapLoop
		
	queueEmpty:
	successInsert:
		lh $t0, ($s0)
		addi $t0, $t0, 1
		sh $t0, ($s0)
		li $v0, 1
		move $v1, $t0
		j endEnqueue
	queueFull:
	custAlreadyQueued:
		li $v0, -1
		lh $v1, ($s0)
	endEnqueue:
	lw $ra, 0($sp)				# restore registers
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	jr $ra

# Part VI
heapify_down:
jr $ra

# Part VII
dequeue:
jr $ra

# Part VIII
build_heap:
jr $ra

# Part IX
increment_time:
jr $ra

# Part X
admit_customers:
jr $ra

# Part XI
seat_customers:
jr $ra

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
