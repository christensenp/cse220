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
	addi $sp, $sp, -36		# preserve registers
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
	
	bltz $s1, invalidIndex
	
	lh $s6, ($s0)			# queue size
	bge $s1, $s6, invalidIndex
	li $s7, 0			# swap counter
	maxHeapifyLoop:
		li $t0, 3
		mul $t0, $t0, $s1
		addi $s2, $t0, 1		# left
		addi $s3, $t0, 2		# middle
		addi $s4, $t0, 3		# right
		move $s5, $s1			# largest
		
		bge $s2, $s6, checkMid
		li $t0, 8
		mul $t1, $t0, $s2
		addi $t1, $t1, 4
		add $t1, $t1, $s0
		mul $t2, $t0, $s5
		addi $t2, $t2, 4	
		add $t2, $t2, $s0	

		move $a0, $t1
		move $a1, $t2
		jal compare_to
		blez $v0, checkMid
		move $s5, $s2
		
		checkMid:
		bge $s3, $s6, checkRight
		li $t0, 8
		mul $t1, $t0, $s3
		addi $t1, $t1, 4
		add $t1, $t1, $s0
		mul $t2, $t0, $s5
		addi $t2, $t2, 4
		add $t2, $t2, $s0		

		move $a0, $t1
		move $a1, $t2
		jal compare_to
		blez $v0, checkRight
		move $s5, $s3
		
		checkRight:
		bge $s4, $s6, checkLargest
		li $t0, 8
		mul $t1, $t0, $s4
		addi $t1, $t1, 4
		add $t1, $t1, $s0
		mul $t2, $t0, $s5
		addi $t2, $t2, 4	
		add $t2, $t2, $s0

		move $a0, $t1
		move $a1, $t2
		jal compare_to
		blez $v0, checkLargest
		move $s5, $s4
		
		checkLargest:
		beq $s5, $s1, breakHeapifyLoop
		
		li $t0, 8
		mul $s2, $t0, $s5
		addi $s2, $s2, 4
		add $s2, $s2, $s0
		mul $s3, $t0, $s1
		addi $s3, $s3, 4
		add $s3, $s3, $s0
		
		addi $sp, $sp, -8
		move $a0, $s2
		move $a1, $sp
		li $a2, 8
		jal memcpy
		
		move $a0, $s3
		move $a1, $s2
		li $a2, 8
		jal memcpy
		
		move $a0, $sp
		move $a1, $s3
		li $a2, 8 
		jal memcpy
		addi $sp, $sp, 8
		move $s1, $s5
		addi $s7, $s7, 1
		blt $s1, $s6, maxHeapifyLoop	

	invalidIndex:
		li $v0, -1
		j endHeapifyDown
	breakHeapifyLoop:
		move $v0, $s7
	endHeapifyDown:
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

# Part VII
dequeue:
	addi $sp, $sp, -16			# preserve registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)

	move $s0, $a0
	move $s1, $a1
	
	addi $a0, $s0, 4
	move $a1, $s1
	li $a2, 8
	jal memcpy
	
	lh $s2, ($s0)
	beqz $s2, queueEmpty_dequeue
	addi $s2, $s2, -1
	sh $s2, ($s0)
	li $t1, 8
	mul $t1, $t1, $s2
	addi $t1, $t1, 4
	add $t1, $t1, $s0
	addi $a1, $s0, 4
	move $a0, $t1
	li $a2, 8
	jal memcpy
	
	move $a0, $s0
	li $a1, 0
	jal heapify_down
	move $v0, $s2
	j endDequeue
	queueEmpty_dequeue:
		li $v0, -1
	endDequeue:
	lw $ra, 0($sp)				# restore registers
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra

# Part VIII
build_heap:
	addi $sp, $sp, -16			# preserve registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	
	move $s0, $a0
	
	lh $t0, ($s0)
	beqz $t0, emptyArray
	
	li $s1, 0				# swap counter
	addi $t0, $t0, -1
	li $t1, 3
	div $t0, $t1
	mflo $s2				# index
	
	callHeapifyDownLoop:
		move $a0, $s0
		move $a1, $s2
		jal heapify_down
		add $s1, $s1, $v0
		addi $s2, $s2, -1
		bgez $s2, callHeapifyDownLoop
	move $v0, $s1	
	j endBuildHeap
	emptyArray:
		li $v0, 0
	endBuildHeap:	
	lw $ra, 0($sp)				# restore registers
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra

# Part IX
increment_time:
	addi $sp, $sp, -20			# preserve registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)

	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	
	blez $s1, invalidInput_incTime
	blez $s2, invalidInput_incTime
	
	li $t0, 0				# customer counter
	lh $t1, ($s0)				# num of customers
	beqz $t1, invalidInput_incTime
	addi $t2, $s0, 4			# start of cust array
	li $t4, 0				# total wait time
	
	iterateCustomer:
		lh $t3, 6($t2)			# wait time
		add $t3, $t3, $s1	
		sh $t3, 6($t2)
		add $t4, $t4, $t3
		
		lh $t3, 4($t2)
		bge $t3, $s2, tooFamous
		add $t3, $t3, $s1
		sh $t3, 4($t2)
		
		tooFamous:
		addi $t0, $t0, 1
		addi $t2, $t2, 8
		blt $t0, $t1, iterateCustomer
		
	div $t4, $t0
	mflo $s3
	move $a0, $s0
	jal build_heap
	move $v0, $s3
	j endIncrementTime
	invalidInput_incTime:
		li $v0, -1
	endIncrementTime:
	lw $ra, 0($sp)				# restore registers
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra

# Part X
admit_customers:
	addi $sp, $sp, -20			# preserve registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)

	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	
	blez $s1, invalidInput_admitCust
	
	li $s3, 0				# customer counter
	lh $s4, ($s0)				# size of cust array
	beqz $s4, invalidInput_admitCust
	dequeueLoop:
		move $a0, $s0
		move $a1, $s2
		jal dequeue
		addi $s3, $s3, 1
		addi $s2, $s2, 8
		bge $s3, $s1, breakDequeueLoop
		bge $s3, $s4, breakDequeueLoop
		j dequeueLoop
	breakDequeueLoop:
	move $v0, $s3
	j endAdmitCustomers
	invalidInput_admitCust:
		li $v0, -1
	endAdmitCustomers:
	lw $ra, 0($sp)				# restore registers
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra

# Part XI
seat_customers:
	addi $sp, $sp, -36		# preserve registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)

	move $s0, $a0				# customer array
	move $s1, $a1				# num admitted
	move $s2, $a2				# budget
	
	blez $s1, invalidInput_seatCust
	blez $s2, invalidInput_seatCust
	
	li $t0, 1				# counter
	li $t1, 2
	calcCombinations:
		li $t2, 2
		mul $t1, $t1, $t2 
		addi $t0, $t0, 1
		blt $t0, $s1, calcCombinations
	
	move $s3, $t1				# total combinations
	li $s4, 0				# bit string
	li $s5, 0				# highest fame
	li $t9, -1				# current best bit string
	checkBitStringLoop:
		li $s6, 0			# current fame total
		li $s7, 0			# sum of wait time
		li $t0, 31			# shiftcounter
		sub $t1, $t0, $s1		# lower limit for shift counter
		checkCustomers:
			sllv $t2, $s4, $t0
			srl $t2, $t2, 31
			beqz $t2, custNotSeated
			
			li $t2, 31
			sub $t2, $t2, $t0
			li $t3, 8
			mul $t2, $t2, $t3
			add $t2, $t2, $s0
			lh $t3, 4($t2)		# fame
			lh $t4, 6($t2)		# wait time
			add $s6, $s6, $t3
			add $s7, $s7, $t4
			bgt $s7, $s2, incrementBitString
			
			custNotSeated:
			addi $t0, $t0, -1
			bgt $t0, $t1, checkCustomers
		
		ble $s6, $s5, incrementBitString
		move $s5, $s6
		move $t9, $s4
		
		incrementBitString:
		addi $s4, $s4, 1
		blt $s4, $s3, checkBitStringLoop
		
	move $v0, $t9	
	move $v1, $s5
	j endSeatCustomers
	invalidInput_seatCust:
		li $v0, -1
		li $v1, -1

	endSeatCustomers:
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
