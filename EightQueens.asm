	.data
str:
	.asciiz "Eight Queen problems,entering the number of queens:"
	
#$a0 -- the argument "row"
#$a1 -- the argument "QueensNumber"
#$a2 -- the argument "count"
#$v0 -- the return value of Queen(row,QueensNumber,count)
#$v1 -- the return value of Valid(row)
#$s0 -- the address of Site[0]
	
	.text	
main:
	addi $sp,$sp,-32                                               #adjust stack for Site[8]
	move $s0,$sp                                                   #$s0 points to Site[0]
	
	li $v0,4                                                       #system call code for print_str
	la $a0,str                                                     #address of string to print
	syscall                                                        #print the string
	
	li $v0,5                                                       #system call code for read_int
	syscall                                                        #read the int
	
	move $a1,$v0                                                   #save the argument "QueensNumber" to $a1
	move $a0,$0                                                    #save the argument "row" to $a0, and initialize it to 0
	move $a2,$0                                                    #save the argument "count" to $a2,and initialize it to 0
	move $v0,$0                                                    #save the return value of Queen(row,QueensNumber,count) to $v0 and initialize it to 0
	
	jal Queen                                                      #call funtion Queen() to compute the result
	move $a0,$v0                                                   #save the return value $v0 to $a0
	
	li $v0,1                                                       #system call code for print_int
	syscall                                                        #print the result
	
	addi $sp,$sp,32                                                #adjust stack to delete Site[8]
	
	li $v0,10                                                      #system call code for exit
	syscall                                                        #exit
	
Queen:
	addi $sp,$sp,-20                                               #adjust stack for 5 items
	sw $ra,16($sp)                                                 #save the return address
	sw $a0,12($sp)                                                 #save the argument "row"
	sw $a2,8($sp)                                                  #save the argument "count"
	sw $v0,4($sp)                                                  #save the return value
	addi $s2,$0,1                                                  #save the variable i to $s2 and initialize it to 1
	sw $s2,0($sp)                                                  #save the variable i
	
	bne $a0,$a1,LoopQueen                                          #if row!=QueensNumber,go to LoopQueen
	
	#if row==QueensNumber,do the following operation
	addi $a2,$a2,1                                                 #count=count+1
	sw $a2,8($sp)                                                  #save the new value of count
	j ReturnCount                                                  #go to ReturnCount

LoopQueen:
	bgt $s2,$a1,ReturnCount                                        #if i>QueensNumber,go to ReturnCount
	
	lw $a0,12($sp)                                                 #restore the argument "row"(important operation!!!)
	sll $t2,$a0,2                                                  #$t2=row*4
	add $s1,$t2,$s0                                                #address of Site[row]
	sw $s2,0($s1)                                                  #Site[row]=i
	
	jal Valid                                                      #$v1=Valid(row)
	beqz $v1,Break_i                                               #if Valid[row]==0,goto Break_i
	
	addi $a0,$a0,1                                                 #row=row+1
	jal Queen                                                      #go to Queen -- recursive calls
	move $a2,$v0                                                   #count=Queen(row+1,QueensNumber,count)
	sw $a2,8($sp)                                                  #save the new value of count
			
Break_i:
	lw $s2,0($sp)                                                  #restore the variable i(important operation!!!)
	addi $s2,$s2,1                                                 #i=i+1
	sw $s2,0($sp)                                                  #save the new value of i
	j LoopQueen                                                    #go to LoopQueen

ReturnCount:
	lw $s2,0($sp)                                                  #restore the variable i
	lw $a2,8($sp)                                                  #restore the argument count
	lw $a0,12($sp)                                                 #restore the argument row
	lw $ra,16($sp)                                                 #restore the return address
	addi $sp,$sp,20                                                #adjust stack to delete 5 items
	
	move $v0,$a2                                                   #set the return value to count
	jr $ra                                                         #return
		
Valid:
	move $t0,$0                                                    #save the variable i to $t0 and initialize it to 0
	j LoopValid                                                    #go to LoopValid

LoopValid:
	bge $t0,$a0,Return1                                            #if i>=row ,return 1
	
	sll $t1,$t0,2                                                  #$t1=i*4
	add $t1,$t1,$s0                                                #address of Site[i]
	sll $t2,$a0,2                                                  #$t2=row*4
	add $t2,$t2,$s0                                                #address of Site[row]
	lw $t3,0($t1)                                                  #$t3=Site[i]
	lw $t4,0($t2)                                                  #$t4=Site[row]
	
	beq $t3,$t4,Return0                                            #if Site[i]==Site[row],return 0
	
	sub $t5,$t4,$t3                                                #$t5=Site[row]-Site[i]
	abs $t5,$t5                                                    #$t5=abs(Site[row]-Site[i])
	sub $t6,$a0,$t0                                                #$t6=row-i
	
	beq $t5,$t6,Return0                                            #if abs(Site[row]-Site[i])==row-i,return 0
	
	addi $t0,$t0,1                                                 #i=i+1
	j LoopValid                                                    #go to LoopValid
	
Return0:
	move $v1,$0                                                    #set the return value to 0
	jr $ra                                                         #return
	
Return1:
	addi $v1,$0,1                                                  #set the return value to 1
	jr $ra                                                         #return